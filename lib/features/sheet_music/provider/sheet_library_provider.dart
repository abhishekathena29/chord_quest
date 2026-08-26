import 'package:flutter/material.dart';

enum Difficulty { beginner, intermediate, advanced }

extension DifficultyX on Difficulty {
  String get label => switch (this) {
        Difficulty.beginner => 'Beginner',
        Difficulty.intermediate => 'Intermediate',
        Difficulty.advanced => 'Advanced',
      };

  Color get color => switch (this) {
        Difficulty.beginner => const Color(0xFF059669),
        Difficulty.intermediate => const Color(0xFF006970),
        Difficulty.advanced => const Color(0xFFA900A9),
      };
}

/// A practiceable piece of sheet music, stored as compact alphaTex that
/// alphaTab renders into tablature + standard notation.
class SheetSong {
  const SheetSong({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.tempo,
    required this.tex,
    this.icon = Icons.music_note,
  });

  final String id;
  final String title;
  final String subtitle;
  final Difficulty difficulty;
  final int tempo;
  final String tex;
  final IconData icon;
}

/// Holds the bundled sheet-music library and the active difficulty filter.
///
/// Later this list will be augmented from Firestore (curated songs) and the
/// user's own transcribed recordings.
class SheetLibraryProvider extends ChangeNotifier {
  static const _songs = <SheetSong>[
    SheetSong(
      id: 'c-major-scale',
      title: 'C Major Scale',
      subtitle: 'Open position warm-up',
      difficulty: Difficulty.beginner,
      tempo: 90,
      icon: Icons.straighten,
      tex: '\\title "C Major Scale"\n\\tempo 90\n.\n'
          ':8 3.5 0.4 2.4 3.4 0.3 2.3 0.2 1.2 |'
          ':8 1.2 0.2 2.3 0.3 3.4 2.4 0.4 3.5',
    ),
    SheetSong(
      id: 'am-pentatonic',
      title: 'A Minor Pentatonic',
      subtitle: 'The rock/blues box',
      difficulty: Difficulty.beginner,
      tempo: 100,
      icon: Icons.grid_4x4,
      tex: '\\title "A Minor Pentatonic"\n\\tempo 100\n.\n'
          ':8 0.6 3.6 0.5 3.5 0.4 2.4 0.3 2.3 |'
          ':8 0.2 3.2 0.1 3.1 3.1 0.1 3.2 0.2',
    ),
    SheetSong(
      id: 'chromatic-warmup',
      title: 'Chromatic Warm-up',
      subtitle: 'Spider finger exercise',
      difficulty: Difficulty.beginner,
      tempo: 80,
      icon: Icons.fitness_center,
      tex: '\\title "Chromatic Warm-up"\n\\tempo 80\n.\n'
          ':16 1.6 2.6 3.6 4.6 1.5 2.5 3.5 4.5 1.4 2.4 3.4 4.4 1.3 2.3 3.3 4.3',
    ),
    SheetSong(
      id: 'power-chords',
      title: 'Power Chords 101',
      subtitle: 'E5 · A5 · D5 changes',
      difficulty: Difficulty.intermediate,
      tempo: 110,
      icon: Icons.bolt,
      tex: '\\title "Power Chords 101"\n\\tempo 110\n.\n'
          ':4 (0.6 2.5 2.4) (0.6 2.5 2.4) (0.5 2.4 2.3) (0.5 2.4 2.3) |'
          ':4 (0.4 2.3 2.2) (0.4 2.3 2.2) (0.5 2.4 2.3) (0.6 2.5 2.4)',
    ),
    SheetSong(
      id: 'ode-to-joy',
      title: 'Ode to Joy',
      subtitle: 'Beethoven · melody',
      difficulty: Difficulty.intermediate,
      tempo: 120,
      icon: Icons.piano,
      tex: '\\title "Ode to Joy"\n\\tempo 120\n.\n'
          ':4 2.4 2.4 3.4 0.3 | 0.3 3.4 2.4 0.4 |'
          ':4 1.2 1.2 0.4 2.4 | :2 2.4 :4 2.4 0.4',
    ),
  ];

  Difficulty? _filter;
  Difficulty? get filter => _filter;

  List<SheetSong> get songs => _filter == null
      ? _songs
      : _songs.where((s) => s.difficulty == _filter).toList();

  List<Difficulty> get difficulties => Difficulty.values;

  void setFilter(Difficulty? value) {
    _filter = value;
    notifyListeners();
  }
}
