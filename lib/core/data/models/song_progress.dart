import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-song best results, stored at `users/{uid}/songProgress/{songId}`.
class SongProgress {
  const SongProgress({
    required this.songId,
    this.songTitle = '',
    this.attempts = 0,
    this.completions = 0,
    this.bestScorePct = 0,
    this.totalSeconds = 0,
    this.mastered = false,
    this.lastPracticedAt,
  });

  final String songId;
  final String songTitle;
  final int attempts;
  final int completions;
  final int bestScorePct;
  final int totalSeconds;
  final bool mastered;
  final DateTime? lastPracticedAt;

  factory SongProgress.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    int i(String key) => (d[key] as num?)?.toInt() ?? 0;
    return SongProgress(
      songId: doc.id,
      songTitle: d['songTitle'] as String? ?? '',
      attempts: i('attempts'),
      completions: i('completions'),
      bestScorePct: i('bestScorePct'),
      totalSeconds: i('totalSeconds'),
      mastered: d['mastered'] as bool? ?? false,
      lastPracticedAt: (d['lastPracticedAt'] as Timestamp?)?.toDate(),
    );
  }
}
