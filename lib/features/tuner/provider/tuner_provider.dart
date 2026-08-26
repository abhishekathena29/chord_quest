import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/audio/note_math.dart';
import '../../../core/audio/pitch_engine.dart';

/// One string of a tuning, identified by its target MIDI note.
class GuitarString {
  const GuitarString({required this.midi});

  final int midi;

  String get label => NoteMath.noteLabel(midi);
  double get frequency => NoteMath.frequencyFromMidi(midi);
}

/// A named tuning preset (strings ordered low → high, i.e. 6th → 1st string).
class TuningPreset {
  const TuningPreset({required this.name, required this.midis});

  final String name;
  final List<int> midis;

  List<GuitarString> get strings =>
      midis.map((m) => GuitarString(midi: m)).toList();
}

/// Whether the currently sounding note is flat, sharp or in tune.
enum TuneDirection { flat, inTune, sharp, none }

enum MicPermission { unknown, granted, denied, permanentlyDenied }

/// Standard reference MIDI notes: E2 A2 D3 G3 B3 E4.
const _standard = [40, 45, 50, 55, 59, 64];

class TunerProvider extends ChangeNotifier {
  TunerProvider({PitchEngine? engine}) : _engine = engine ?? PitchEngine();

  final PitchEngine _engine;
  StreamSubscription<PitchReading>? _sub;

  // How close (in cents) counts as "in tune".
  static const double inTuneCents = 5;

  final List<TuningPreset> tunings = const [
    TuningPreset(name: 'Standard', midis: _standard),
    TuningPreset(name: 'Drop D', midis: [38, 45, 50, 55, 59, 64]),
    TuningPreset(name: 'Half Step Down', midis: [39, 44, 49, 54, 58, 63]),
    TuningPreset(name: 'DADGAD', midis: [38, 45, 50, 55, 57, 62]),
    TuningPreset(name: 'Open G', midis: [38, 43, 50, 55, 59, 62]),
  ];

  int _tuningIndex = 0;
  TuningPreset get tuning => tunings[_tuningIndex];

  MicPermission _permission = MicPermission.unknown;
  MicPermission get permission => _permission;

  bool _listening = false;
  bool get listening => _listening;

  // --- Live readout ---
  bool _hasSignal = false;
  bool get hasSignal => _hasSignal;

  double _frequency = 0;
  double get frequency => _frequency;

  /// Detected note label (e.g. "A2") — nearest chromatic note.
  String _note = '--';
  String get note => _note;

  /// Deviation in cents from the nearest string in the current tuning.
  double _cents = 0;
  double get cents => _cents;

  /// Index into [tuning.strings] of the string being tuned (-1 if none).
  int _targetStringIndex = -1;
  int get targetStringIndex => _targetStringIndex;

  /// Per-string "already in tune this session" flags for the string display.
  final Set<int> _tunedStrings = {};
  bool isStringTuned(int index) => _tunedStrings.contains(index);

  TuneDirection get direction {
    if (!_hasSignal || _targetStringIndex < 0) return TuneDirection.none;
    if (_cents.abs() <= inTuneCents) return TuneDirection.inTune;
    return _cents < 0 ? TuneDirection.flat : TuneDirection.sharp;
  }

  void selectTuning(int index) {
    if (index == _tuningIndex) return;
    _tuningIndex = index;
    _tunedStrings.clear();
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (_listening) {
      await stop();
    } else {
      await start();
    }
  }

  Future<void> start() async {
    final status = await Permission.microphone.request();
    _permission = switch (status) {
      PermissionStatus.granted || PermissionStatus.limited =>
        MicPermission.granted,
      PermissionStatus.permanentlyDenied => MicPermission.permanentlyDenied,
      _ => MicPermission.denied,
    };
    if (_permission != MicPermission.granted) {
      notifyListeners();
      return;
    }

    _sub ??= _engine.readings.listen(_onReading);
    await _engine.start();
    _listening = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _engine.stop();
    _listening = false;
    _hasSignal = false;
    _targetStringIndex = -1;
    _note = '--';
    _cents = 0;
    notifyListeners();
  }

  void _onReading(PitchReading r) {
    if (!r.pitched || r.frequency <= 0) {
      if (_hasSignal) {
        _hasSignal = false;
        notifyListeners();
      }
      return;
    }

    _hasSignal = true;
    _frequency = r.frequency;
    _note = NoteMath.noteLabel(NoteMath.nearestMidi(r.frequency));

    // Snap to the closest string in the current tuning.
    final strings = tuning.strings;
    var best = 0;
    var bestCents = double.infinity;
    for (var i = 0; i < strings.length; i++) {
      final c = NoteMath.centsFromTarget(r.frequency, strings[i].midi).abs();
      if (c < bestCents) {
        bestCents = c;
        best = i;
      }
    }
    _targetStringIndex = best;
    _cents = NoteMath.centsFromTarget(r.frequency, strings[best].midi);

    if (_cents.abs() <= inTuneCents) {
      _tunedStrings.add(best);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _engine.dispose();
    super.dispose();
  }
}
