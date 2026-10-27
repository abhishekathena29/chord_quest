import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../progress/progression.dart';
import 'models/practice_session.dart';
import 'models/song_progress.dart';
import 'models/user_profile.dart';

/// All Firestore reads/writes for a signed-in player.
///
/// Layout:
///   users/{uid}                      -> [UserProfile] (totals, streak, setup)
///   users/{uid}/sessions/{auto-id}   -> [PracticeSession] (one per take)
///   users/{uid}/songProgress/{song}  -> [SongProgress] (best per song)
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _user(uid).collection('sessions');

  CollectionReference<Map<String, dynamic>> _songProgress(String uid) =>
      _user(uid).collection('songProgress');

  /// Emits `null` while the profile document doesn't exist yet.
  Stream<UserProfile?> watchUser(String uid) => _user(uid).snapshots().map(
    (doc) => doc.exists ? UserProfile.fromSnapshot(doc) : null,
  );

  Stream<Map<String, SongProgress>> watchSongProgress(String uid) =>
      _songProgress(uid).snapshots().map(
        (snap) => {
          for (final doc in snap.docs) doc.id: SongProgress.fromSnapshot(doc),
        },
      );

  Stream<List<PracticeSession>> watchRecentSessions(
    String uid, {
    int limit = 5,
  }) => _sessions(uid)
      .orderBy('startedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map(PracticeSession.fromSnapshot).toList());

  Future<void> createUser({
    required String uid,
    required String displayName,
    required String email,
  }) => _user(uid).set(
    UserProfile.initialData(displayName: displayName, email: email),
  );

  /// Saves the post-signup questionnaire. If the profile document was never
  /// created (e.g. sign-up was interrupted) it is created here as well.
  Future<void> completeProfileSetup({
    required String uid,
    required bool documentExists,
    required String displayName,
    required String email,
    String? skillLevel,
    String? experience,
    String? goal,
  }) => _user(uid).set({
    if (!documentExists)
      ...UserProfile.initialData(displayName: displayName, email: email),
    'skillLevel': skillLevel,
    'experience': experience,
    'goal': goal,
    'profileComplete': true,
  }, SetOptions(merge: true));

  /// Stores a finished session and rolls it into the profile totals, streak
  /// and per-song bests in one atomic batch. A batch (rather than a
  /// transaction) is used so the write is queued and synced later when the
  /// device is offline; values that depend on current state are computed
  /// from the locally cached [profile] and [previous] song progress.
  Future<void> recordSession({
    required UserProfile profile,
    required PracticeSession session,
    SongProgress? previous,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final today = Progression.dayKey(at);
    final yesterday = Progression.dayKey(at.subtract(const Duration(days: 1)));
    final week = Progression.weekKey(at);

    final int streak;
    if (profile.lastPracticeDay == today) {
      streak = math.max(profile.streakCurrent, 1);
    } else if (profile.lastPracticeDay == yesterday) {
      streak = profile.streakCurrent + 1;
    } else {
      streak = 1;
    }

    final wasMastered = previous?.mastered ?? false;
    final masteredNow =
        session.completed && session.scorePct >= Progression.masteryScorePct;
    final newlyMastered = masteredNow && !wasMastered;

    final batch = _db.batch();

    batch.set(_sessions(profile.uid).doc(), session.toMap());

    batch.update(_user(profile.uid), {
      'xp': FieldValue.increment(session.xpEarned),
      'sessionsCount': FieldValue.increment(1),
      'notesHit': FieldValue.increment(session.notesHit),
      'totalPracticeSeconds': FieldValue.increment(session.durationSeconds),
      if (newlyMastered) 'songsMastered': FieldValue.increment(1),
      'streakCurrent': streak,
      'streakLongest': math.max(profile.streakLongest, streak),
      'lastPracticeDay': today,
      'todayKey': today,
      'todaySeconds': profile.todayKey == today
          ? FieldValue.increment(session.durationSeconds)
          : session.durationSeconds,
      'weekKey': week,
      'weekSeconds': profile.weekKey == week
          ? FieldValue.increment(session.durationSeconds)
          : session.durationSeconds,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    batch.set(_songProgress(profile.uid).doc(session.songId), {
      'songTitle': session.songTitle,
      'attempts': FieldValue.increment(1),
      'completions': FieldValue.increment(session.completed ? 1 : 0),
      'totalSeconds': FieldValue.increment(session.durationSeconds),
      'bestScorePct': math.max(previous?.bestScorePct ?? 0, session.scorePct),
      'mastered': wasMastered || masteredNow,
      'lastPracticedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Permanently removes every document belonging to [uid].
  Future<void> deleteAllUserData(String uid) async {
    for (final collection in [_sessions(uid), _songProgress(uid)]) {
      while (true) {
        final snap = await collection.limit(400).get();
        if (snap.docs.isEmpty) break;
        final batch = _db.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    await _user(uid).delete();
  }
}
