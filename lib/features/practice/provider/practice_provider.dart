import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/audio/alphatex_notes.dart';
import '../../../core/audio/note_math.dart';
import '../../../core/audio/pitch_engine.dart';
import '../../../core/audio/wav_writer.dart';
import '../../sheet_music/provider/sheet_library_provider.dart';
import '../../transcription/service/transcription_service.dart';

enum PracticeState { idle, running, finished }

/// Drives a live practice session for one [SheetSong]:
///  * captures the mic once and uses it for BOTH note scoring and recording,
///  * scores the player against the song's note timeline (pitch-class match,
///    advancing on each correctly played note),
///  * saves the take as a WAV that can be sent for transcription.
class PracticeProvider extends ChangeNotifier {
  PracticeProvider({
    required this.song,
    PitchEngine? engine,
    TranscriptionService? transcriber,
  })  : _engine = engine ?? PitchEngine(),
        _transcriber = transcriber ?? const StubTranscriptionService() {
    _expected = AlphaTexNotes.parse(song.tex);
  }

  final SheetSong song;
  final PitchEngine _engine;
  final TranscriptionService _transcriber;

  late final List<Set<int>> _expected;

  StreamSubscription<PitchReading>? _pitchSub;
  StreamSubscription? _rawSub;
  Timer? _timer;
  WavWriter? _wav;

  PracticeState _state = PracticeState.idle;
  PracticeState get state => _state;

  bool _denied = false;
  bool get permissionDenied => _denied;

  // --- Scoring ---
  int _index = 0;
  int get index => _index;
  int get totalNotes => _expected.length;

  int _hits = 0;
  int get hits => _hits;

  bool _armed = true; // ready to accept the next note onset

  String _detectedNote = '--';
  String get detectedNote => _detectedNote;

  bool _onTarget = false;
  bool get onTarget => _onTarget;

  double get progress =>
      totalNotes == 0 ? 0 : (_index / totalNotes).clamp(0, 1);

  /// Accuracy = correct hits over notes attempted so far.
  int get accuracyPct => _index == 0 ? 100 : ((_hits / _index) * 100).round();

  /// The set of notes the player should sound next (labels for the UI).
  String get nextNoteLabel {
    if (_index >= _expected.length) return 'Done';
    return _expected[_index].map(NoteMath.noteLabel).join(' / ');
  }

  // --- Session / recording ---
  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  String? _recordingPath;
  String? get recordingPath => _recordingPath;

  Duration _recordingLength = Duration.zero;
  Duration get recordingLength => _recordingLength;

  // --- Transcription ---
  bool _transcribing = false;
  bool get transcribing => _transcribing;
  TranscriptionResult? _transcription;
  TranscriptionResult? get transcription => _transcription;

  Future<void> start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _denied = true;
      notifyListeners();
      return;
    }
    _denied = false;
    _reset();

    _wav = WavWriter(sampleRate: _engine.sampleRate, numChannels: 1);
    _rawSub = _engine.rawAudio.listen((chunk) => _wav?.add(chunk));
    _pitchSub = _engine.readings.listen(_onReading);
    await _engine.start();

    _state = PracticeState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void _onReading(PitchReading r) {
    if (!r.pitched) {
      _armed = true; // silence between notes re-arms the scorer
      if (_onTarget) {
        _onTarget = false;
        notifyListeners();
      }
      return;
    }

    final midi = NoteMath.nearestMidi(r.frequency);
    _detectedNote = NoteMath.noteLabel(midi);

    if (_index >= _expected.length) {
      notifyListeners();
      return;
    }

    final expected = _expected[_index];
    final match = expected.any((e) => e % 12 == midi % 12); // pitch-class match
    _onTarget = match;

    if (match && _armed) {
      _hits++;
      _index++;
      _armed = false; // require a gap before counting the next note
    }
    notifyListeners();
  }

  Future<void> stop() async {
    _timer?.cancel();
    await _pitchSub?.cancel();
    await _rawSub?.cancel();
    _pitchSub = null;
    _rawSub = null;
    await _engine.stop();

    // Persist the take as a WAV for playback / transcription.
    if (_wav != null && _wav!.byteLength > 0) {
      final dir = await getApplicationDocumentsDirectory();
      final name = 'practice_${song.id}_${_elapsed.inSeconds}s.wav';
      final file = await _wav!.writeTo('${dir.path}/$name');
      _recordingPath = file.path;
      _recordingLength = _wav!.duration;
    }
    _wav = null;

    _state = PracticeState.finished;
    notifyListeners();
  }

  Future<void> transcribe() async {
    if (_recordingPath == null || _transcribing) return;
    _transcribing = true;
    notifyListeners();
    _transcription = await _transcriber.transcribe(_recordingPath!);
    _transcribing = false;
    notifyListeners();
  }

  void _reset() {
    _index = 0;
    _hits = 0;
    _armed = true;
    _elapsed = Duration.zero;
    _detectedNote = '--';
    _onTarget = false;
    _recordingPath = null;
    _transcription = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pitchSub?.cancel();
    _rawSub?.cancel();
    _engine.dispose();
    super.dispose();
  }
}
