/// Pure game-progression rules shared by the practice, journey and profile
/// features: how much XP a session earns, how XP maps to a level/rank, and
/// which journey node is unlocked. Kept free of Flutter/Firebase so it's easy
/// to unit-test and to tweak in one place.
class Progression {
  Progression._();

  /// XP needed per numeric level (Lvl 1 at 0 XP, Lvl 2 at 200 XP, …).
  static const int xpPerLevel = 200;

  /// A song counts as mastered once a full run-through scores at least this.
  static const int masteryScorePct = 90;

  /// Sessions shorter than this with no notes hit are not saved.
  static const int minSessionSeconds = 5;

  static int levelForXp(int xp) => 1 + xp ~/ xpPerLevel;

  /// XP awarded for one practice session.
  ///  * 2 XP per correct note
  ///  * 25 XP bonus for playing the song through to the end
  ///  * 5 XP per full minute practised (capped at 50)
  static int xpForSession({
    required int notesHit,
    required bool completed,
    required int durationSeconds,
  }) {
    final minutes = (durationSeconds ~/ 60).clamp(0, 10);
    return notesHit * 2 + (completed ? 25 : 0) + minutes * 5;
  }

  /// Journey nodes from first to last, with the total XP that unlocks each.
  static const List<JourneyMilestone> milestones = [
    JourneyMilestone(id: 'fundamentals', level: 0, part: 'Complete', title: 'Fundamentals', xp: 0),
    JourneyMilestone(id: 'open-strings', level: 1, part: 'Part A', title: 'Open Strings', xp: 250),
    JourneyMilestone(id: 'chords-101', level: 1, part: 'Part B', title: 'Chords 101', xp: 600),
    JourneyMilestone(id: 'power-chords', level: 1, part: 'Part C', title: 'Power Chords', xp: 1000),
    JourneyMilestone(id: 'alt-picking', level: 2, part: 'Part A', title: 'Fast Alt Picking', xp: 1600),
    JourneyMilestone(id: 'tapping', level: 2, part: 'Part B', title: 'Tapping', xp: 2400),
    JourneyMilestone(id: 'sweep-picking', level: 2, part: 'Part C', title: 'Sweep Picking', xp: 3400),
  ];

  static const List<String> rankTitles = [
    'String Starter',
    'Riff Rider',
    'Shred Master',
  ];

  /// Index into [milestones] of the node the player is currently working on.
  static int activeMilestoneIndex(int xp) {
    var index = 0;
    for (var i = 0; i < milestones.length; i++) {
      if (xp >= milestones[i].xp) index = i;
    }
    return index;
  }

  static String rankForXp(int xp) =>
      rankTitles[milestones[activeMilestoneIndex(xp)].level];

  /// Local calendar day as `yyyy-MM-dd` — used for streaks and daily totals.
  static String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Day key of the Monday that starts [date]'s week — used for weekly totals.
  static String weekKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return dayKey(day.subtract(Duration(days: day.weekday - DateTime.monday)));
  }
}

class JourneyMilestone {
  const JourneyMilestone({
    required this.id,
    required this.level,
    required this.part,
    required this.title,
    required this.xp,
  });

  final String id;

  /// 0-based index into [Progression.rankTitles].
  final int level;
  final String part;
  final String title;

  /// Total XP at which this node unlocks.
  final int xp;
}
