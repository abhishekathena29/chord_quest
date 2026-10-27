import 'package:cloud_firestore/cloud_firestore.dart';

import '../../progress/progression.dart';

/// The `users/{uid}` document: identity, onboarding answers and running
/// progress totals. Totals are kept denormalised here so the app bar, home,
/// journey and profile screens can all render from a single document read.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.displayName = '',
    this.email = '',
    this.skillLevel,
    this.experience,
    this.goal,
    this.profileComplete = false,
    this.createdAt,
    this.xp = 0,
    this.streakCurrent = 0,
    this.streakLongest = 0,
    this.lastPracticeDay,
    this.totalPracticeSeconds = 0,
    this.sessionsCount = 0,
    this.notesHit = 0,
    this.songsMastered = 0,
    this.dailyGoalMinutes = 20,
    this.weeklyGoalMinutes = 60,
    this.todayKey,
    this.todaySeconds = 0,
    this.weekKey,
    this.weekSeconds = 0,
  });

  final String uid;
  final String displayName;
  final String email;

  // Profile-setup answers, stored as enum names (see profile_setup_provider).
  final String? skillLevel;
  final String? experience;
  final String? goal;
  final bool profileComplete;

  final DateTime? createdAt;

  final int xp;
  final int streakCurrent;
  final int streakLongest;

  /// Day key (`yyyy-MM-dd`) of the last day with a saved session.
  final String? lastPracticeDay;

  final int totalPracticeSeconds;
  final int sessionsCount;
  final int notesHit;
  final int songsMastered;

  final int dailyGoalMinutes;
  final int weeklyGoalMinutes;

  // Rolling buckets: the seconds only count while the key is still current.
  final String? todayKey;
  final int todaySeconds;
  final String? weekKey;
  final int weekSeconds;

  int get level => Progression.levelForXp(xp);
  String get rank => Progression.rankForXp(xp);

  String get firstName {
    final trimmed = displayName.trim();
    return trimmed.isEmpty ? 'Guitarist' : trimmed.split(' ').first;
  }

  /// The streak as the player sees it: it lapses once a whole day is missed.
  int currentStreak([DateTime? now]) {
    final today = now ?? DateTime.now();
    final last = lastPracticeDay;
    if (last == null) return 0;
    final yesterday = today.subtract(const Duration(days: 1));
    if (last == Progression.dayKey(today) ||
        last == Progression.dayKey(yesterday)) {
      return streakCurrent;
    }
    return 0;
  }

  int secondsToday([DateTime? now]) =>
      todayKey == Progression.dayKey(now ?? DateTime.now()) ? todaySeconds : 0;

  int secondsThisWeek([DateTime? now]) =>
      weekKey == Progression.weekKey(now ?? DateTime.now()) ? weekSeconds : 0;

  factory UserProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    int i(String key, [int fallback = 0]) =>
        (d[key] as num?)?.toInt() ?? fallback;
    return UserProfile(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? '',
      email: d['email'] as String? ?? '',
      skillLevel: d['skillLevel'] as String?,
      experience: d['experience'] as String?,
      goal: d['goal'] as String?,
      profileComplete: d['profileComplete'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      xp: i('xp'),
      streakCurrent: i('streakCurrent'),
      streakLongest: i('streakLongest'),
      lastPracticeDay: d['lastPracticeDay'] as String?,
      totalPracticeSeconds: i('totalPracticeSeconds'),
      sessionsCount: i('sessionsCount'),
      notesHit: i('notesHit'),
      songsMastered: i('songsMastered'),
      dailyGoalMinutes: i('dailyGoalMinutes', 20),
      weeklyGoalMinutes: i('weeklyGoalMinutes', 60),
      todayKey: d['todayKey'] as String?,
      todaySeconds: i('todaySeconds'),
      weekKey: d['weekKey'] as String?,
      weekSeconds: i('weekSeconds'),
    );
  }

  /// Fields written once when the document is first created.
  static Map<String, dynamic> initialData({
    required String displayName,
    required String email,
  }) => {
    'displayName': displayName,
    'email': email,
    'profileComplete': false,
    'createdAt': FieldValue.serverTimestamp(),
    'xp': 0,
    'streakCurrent': 0,
    'streakLongest': 0,
    'lastPracticeDay': null,
    'totalPracticeSeconds': 0,
    'sessionsCount': 0,
    'notesHit': 0,
    'songsMastered': 0,
    'dailyGoalMinutes': 20,
    'weeklyGoalMinutes': 60,
    'todayKey': null,
    'todaySeconds': 0,
    'weekKey': null,
    'weekSeconds': 0,
  };
}
