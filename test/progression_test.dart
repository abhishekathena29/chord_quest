import 'package:flutter_test/flutter_test.dart';

import 'package:chord_quest/core/data/models/practice_session.dart';
import 'package:chord_quest/core/data/models/user_profile.dart';
import 'package:chord_quest/core/progress/progression.dart';

void main() {
  group('Progression', () {
    test('levels step every 200 XP', () {
      expect(Progression.levelForXp(0), 1);
      expect(Progression.levelForXp(199), 1);
      expect(Progression.levelForXp(200), 2);
    });

    test('session XP: notes, completion bonus, capped minutes', () {
      expect(
        Progression.xpForSession(
          notesHit: 10,
          completed: false,
          durationSeconds: 59,
        ),
        20,
      );
      expect(
        Progression.xpForSession(
          notesHit: 16,
          completed: true,
          durationSeconds: 125,
        ),
        32 + 25 + 10,
      );
      expect(
        Progression.xpForSession(
          notesHit: 0,
          completed: false,
          durationSeconds: 3600,
        ),
        50,
      );
    });

    test('journey milestone and rank follow XP thresholds', () {
      expect(Progression.activeMilestoneIndex(0), 0);
      expect(Progression.rankForXp(0), 'String Starter');
      expect(Progression.activeMilestoneIndex(600), 2);
      expect(Progression.rankForXp(600), 'Riff Rider');
      expect(Progression.rankForXp(5000), 'Shred Master');
    });

    test('week key is the Monday of that week', () {
      // 2026-10-29 is a Thursday.
      expect(Progression.weekKey(DateTime(2026, 10, 29)), '2026-10-26');
      expect(Progression.weekKey(DateTime(2026, 10, 26)), '2026-10-26');
      expect(Progression.weekKey(DateTime(2026, 11, 1)), '2026-10-26');
    });
  });

  group('UserProfile', () {
    final now = DateTime(2026, 10, 27, 10);

    test('streak survives until a full day is missed', () {
      const base = UserProfile(uid: 'u', streakCurrent: 4);
      expect(
        UserProfile(uid: 'u', streakCurrent: 4, lastPracticeDay: '2026-10-27')
            .currentStreak(now),
        4,
      );
      expect(
        UserProfile(uid: 'u', streakCurrent: 4, lastPracticeDay: '2026-10-26')
            .currentStreak(now),
        4,
      );
      expect(
        UserProfile(uid: 'u', streakCurrent: 4, lastPracticeDay: '2026-10-25')
            .currentStreak(now),
        0,
      );
      expect(base.currentStreak(now), 0);
    });

    test('daily seconds only count for the current day', () {
      const p = UserProfile(uid: 'u', todayKey: '2026-10-26', todaySeconds: 600);
      expect(p.secondsToday(now), 0);
      expect(p.secondsToday(DateTime(2026, 10, 26)), 600);
    });
  });

  group('PracticeSession', () {
    PracticeSession session({required int hit, required int played}) =>
        PracticeSession(
          songId: 's',
          songTitle: 'S',
          difficulty: 'beginner',
          startedAt: DateTime(2026),
          durationSeconds: 30,
          notesHit: hit,
          notesPlayed: played,
          totalNotes: 16,
          accuracyPct: 100,
          xpEarned: 0,
        );

    test('completion and score', () {
      expect(session(hit: 16, played: 16).completed, isTrue);
      expect(session(hit: 16, played: 16).scorePct, 100);
      expect(session(hit: 8, played: 8).completed, isFalse);
      expect(session(hit: 8, played: 8).scorePct, 50);
    });
  });
}
