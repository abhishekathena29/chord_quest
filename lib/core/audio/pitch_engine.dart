import 'dart:async';
import 'dart:typed_data';

import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';

/// A single pitch measurement emitted by [PitchEngine].
class PitchReading {
  const PitchReading({
    required this.frequency,
    required this.probability,
    required this.pitched,
  });

  /// Detected fundamental frequency in Hz.
  final double frequency;

  /// Confidence 0..1 that [frequency] is correct.
  final double probability;

  /// Whether the analysed window actually contained a pitched sound.
  final bool pitched;

  static const silent =
      PitchReading(frequency: 0, probability: 0, pitched: false);
}

/// Captures microphone audio and emits a stream of [PitchReading]s using the
/// YIN algorithm. Reused by both the tuner and live practice scoring.
///
/// This is intentionally UI-agnostic: providers subscribe to [readings] and map
/// the raw frequency to whatever they need (nearest string, expected note, …).
class PitchEngine {
  PitchEngine({
    this.sampleRate = 44100,
    this.bufferSize = 2048,
    this.minProbability = 0.7,
  })  : _recorder = AudioRecorder(),
        _detector = PitchDetector(
          audioSampleRate: sampleRate.toDouble(),
          bufferSize: bufferSize,
        );

  final int sampleRate;
  final int bufferSize;

  /// Readings below this YIN probability are reported as [PitchReading.silent].
  final double minProbability;

  final AudioRecorder _recorder;
  final PitchDetector _detector;

  final _controller = StreamController<PitchReading>.broadcast();

  /// Raw PCM16 mono chunks, emitted alongside [readings]. Lets a caller both
  /// score pitch and persist the audio from a single mic session.
  final _rawController = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get rawAudio => _rawController.stream;

  StreamSubscription<Uint8List>? _sub;

  // Rolling PCM16 byte buffer; detection runs once a full window accrues.
  final BytesBuilder _bytes = BytesBuilder(copy: false);
  bool _running = false;

  Stream<PitchReading> get readings => _controller.stream;
  bool get isRunning => _running;

  /// Whether the mic permission is granted; requests it if [request] is true.
  Future<bool> hasPermission({bool request = true}) =>
      _recorder.hasPermission();

  Future<void> start() async {
    if (_running) return;
    if (!await _recorder.hasPermission()) return;

    final stream = await _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        // Reduce processing artefacts so pitch detection stays clean.
        autoGain: true,
        echoCancel: false,
        noiseSuppress: true,
      ),
    );

    _running = true;
    _sub = stream.listen(_onData, onError: (_) {}, cancelOnError: false);
  }

  void _onData(Uint8List chunk) {
    if (_rawController.hasListener) _rawController.add(chunk);
    _bytes.add(chunk);
    final windowBytes = bufferSize * 2; // PCM16 => 2 bytes per sample
    if (_bytes.length < windowBytes) return;

    final all = _bytes.toBytes();
    _bytes.clear();

    // Analyse the most recent full window; keep any leftover for next round.
    final start = all.length - windowBytes;
    final window = Uint8List.sublistView(all, start);
    if (start > 0) {
      _bytes.add(Uint8List.sublistView(all, 0, start));
    }

    _detector.getPitchFromIntBuffer(window).then((result) {
      if (!_running) return;
      if (result.pitched && result.probability >= minProbability) {
        _controller.add(PitchReading(
          frequency: result.pitch,
          probability: result.probability,
          pitched: true,
        ));
      } else {
        _controller.add(PitchReading.silent);
      }
    }).catchError((_) {});
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _sub?.cancel();
    _sub = null;
    await _recorder.stop();
    _bytes.clear();
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
    await _controller.close();
    await _rawController.close();
  }
}
