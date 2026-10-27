import 'package:cloud_firestore/cloud_firestore.dart';

/// One finished practice take, stored at `users/{uid}/sessions/{id}`.
class PracticeSession {
  const PracticeSession({
    required this.songId,
    required this.songTitle,
    required this.difficulty,
    required this.startedAt,
    required this.durationSeconds,
    required this.notesHit,
    required this.notesPlayed,
    required this.totalNotes,
    required this.accuracyPct,
    required this.xpEarned,
    this.id,
  });

  final String? id;
  final String songId;
  final String songTitle;
  final String difficulty;
  final DateTime startedAt;
  final int durationSeconds;
  final int notesHit;

  /// How far through the song the player got (index of the next note).
  final int notesPlayed;
  final int totalNotes;
  final int accuracyPct;
  final int xpEarned;

  bool get completed => totalNotes > 0 && notesPlayed >= totalNotes;

  /// Share of the song played correctly, 0–100. This is what song mastery
  /// and "best score" are based on.
  int get scorePct =>
      totalNotes == 0 ? 0 : ((notesHit / totalNotes) * 100).round().clamp(0, 100);

  Map<String, dynamic> toMap() => {
    'songId': songId,
    'songTitle': songTitle,
    'difficulty': difficulty,
    'startedAt': Timestamp.fromDate(startedAt),
    'endedAt': FieldValue.serverTimestamp(),
    'durationSeconds': durationSeconds,
    'notesHit': notesHit,
    'notesPlayed': notesPlayed,
    'totalNotes': totalNotes,
    'accuracyPct': accuracyPct,
    'scorePct': scorePct,
    'completed': completed,
    'xpEarned': xpEarned,
  };

  factory PracticeSession.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    int i(String key) => (d[key] as num?)?.toInt() ?? 0;
    return PracticeSession(
      id: doc.id,
      songId: d['songId'] as String? ?? '',
      songTitle: d['songTitle'] as String? ?? '',
      difficulty: d['difficulty'] as String? ?? '',
      startedAt:
          (d['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationSeconds: i('durationSeconds'),
      notesHit: i('notesHit'),
      notesPlayed: i('notesPlayed'),
      totalNotes: i('totalNotes'),
      accuracyPct: i('accuracyPct'),
      xpEarned: i('xpEarned'),
    );
  }
}
