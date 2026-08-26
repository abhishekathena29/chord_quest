import 'package:flutter/material.dart';

/// A note plotted on the interactive staff.
class StaffNote {
  const StaffNote({
    required this.name,
    required this.color,
    required this.staffPosition,
    this.active = false,
  });

  final String name;

  /// 0 = top line, 1 = bottom line — vertical placement on the staff.
  final double staffPosition;
  final Color color;
  final bool active;
}

/// A fretted note marker on the fretboard.
class FretMarker {
  const FretMarker({
    required this.label,
    required this.color,
    required this.string, // 0 (top) .. 5 (bottom)
    required this.fret, // 0-based fret index
    this.active = false,
  });

  final String label;
  final Color color;
  final int string;
  final int fret;
  final bool active;
}

/// Session state for the study screen: playback, accuracy and the notes shown
/// on the staff and fretboard.
class StudyProvider extends ChangeNotifier {
  bool _playing = true;
  bool get playing => _playing;

  void togglePlay() {
    _playing = !_playing;
    notifyListeners();
  }

  final String sessionTime = '24:05';
  final int streakDays = 12;
  final int accuracy = 92;
  final int perfectNotes = 128;
  final String tuning = 'Standard Tuning';
  final bool advancedMode = true;

  final List<StaffNote> staffNotes = const [
    StaffNote(
        name: 'C4',
        color: Color(0xFF006970),
        staffPosition: 0.55,
        active: true),
    StaffNote(name: 'E4', color: Color(0xFFA900A9), staffPosition: 0.7),
    StaffNote(name: 'G4', color: Color(0xFF7212FF), staffPosition: 0.3),
    StaffNote(name: 'B4', color: Color(0xFF00DBE9), staffPosition: 0.85),
  ];

  final int strings = 6;
  final int frets = 9;

  final List<FretMarker> markers = const [
    FretMarker(
        label: 'C',
        color: Color(0xFF006970),
        string: 0,
        fret: 1,
        active: true),
    FretMarker(label: 'G', color: Color(0xFFA900A9), string: 3, fret: 4),
    FretMarker(label: 'E', color: Color(0xFF7212FF), string: 2, fret: 6),
  ];
}
