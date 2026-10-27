import 'package:flutter/material.dart';

import '../../../core/data/models/user_profile.dart';
import '../../../core/progress/progression.dart';
import '../../profile_setup/provider/profile_setup_provider.dart';

class ProfileStat {
  const ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
}

class ProfileBadge {
  const ProfileBadge({
    required this.icon,
    required this.label,
    required this.colors,
    this.locked = false,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final bool locked;
}

/// Read-only view of the signed-in player's [UserProfile] for the Profile
/// tab: stats grid, earned badges and the weekly practice challenge.
class ProfileView {
  ProfileView(UserProfile? profile)
    : _p = profile ?? const UserProfile(uid: '');

  final UserProfile _p;

  static const _lockedColors = [Color(0xFFE0E3E5), Color(0xFFE0E3E5)];

  String get name =>
      _p.displayName.trim().isEmpty ? 'Guitarist' : _p.displayName.trim();
  int get level => _p.level;
  String get rank => 'Lvl ${_p.level} ${_p.rank}';

  String? get skillLabel =>
      SkillLevel.values.asNameMap()[_p.skillLevel]?.label;

  String? get joined {
    final created = _p.createdAt;
    if (created == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Joined ${months[created.month - 1]} ${created.year}';
  }

  List<ProfileStat> get stats {
    final streak = _p.currentStreak();
    return [
      ProfileStat(
        icon: Icons.local_fire_department,
        value: '$streak Day${streak == 1 ? '' : 's'}',
        label: 'Streak',
        color: const Color(0xFFF97316),
      ),
      ProfileStat(
        icon: Icons.music_note,
        value: '${_p.sessionsCount}',
        label: 'Sessions',
        color: const Color(0xFF0891B2),
      ),
      ProfileStat(
        icon: Icons.schedule,
        value: formatDuration(_p.totalPracticeSeconds),
        label: 'Practice Time',
        color: const Color(0xFF9333EA),
      ),
      ProfileStat(
        icon: Icons.verified,
        value: '${_p.songsMastered}',
        label: 'Songs Mastered',
        color: const Color(0xFF059669),
      ),
    ];
  }

  List<ProfileBadge> get badges {
    ProfileBadge badge(
      IconData icon,
      String label,
      List<Color> colors,
      bool earned,
    ) => ProfileBadge(
      icon: earned ? icon : Icons.lock,
      label: label,
      colors: earned ? colors : _lockedColors,
      locked: !earned,
    );

    return [
      badge(Icons.play_arrow_rounded, 'First Steps',
          const [Color(0xFF67E8F9), Color(0xFF3B82F6)], _p.sessionsCount >= 1),
      badge(Icons.local_fire_department, 'On Fire',
          const [Color(0xFFFDE047), Color(0xFFF97316)], _p.streakLongest >= 7),
      badge(Icons.star, 'Chord Master',
          const [Color(0xFFD8B4FE), Color(0xFFEC4899)], _p.songsMastered >= 3),
      badge(Icons.speed, 'Marathon',
          const [Color(0xFF6EE7B7), Color(0xFF059669)],
          _p.totalPracticeSeconds >= 10 * 3600),
      badge(Icons.electric_bolt, 'Shredder',
          const [Color(0xFFFF9BF5), Color(0xFFA900A9)],
          _p.xp >= Progression.milestones[4].xp),
    ];
  }

  int get earnedBadges => badges.where((b) => !b.locked).length;

  // Weekly challenge: a practice-time goal that resets every Monday.
  String get challengeTitle => 'Practice ${_p.weeklyGoalMinutes} minutes';
  String get challengeBody {
    final done = _p.secondsThisWeek() ~/ 60;
    return done >= _p.weeklyGoalMinutes
        ? 'Goal reached this week. Keep the streak going!'
        : '$done of ${_p.weeklyGoalMinutes} minutes played this week. '
              'Every session counts.';
  }

  double get challengeProgress => _p.weeklyGoalMinutes == 0
      ? 0
      : (_p.secondsThisWeek() / (_p.weeklyGoalMinutes * 60)).clamp(0, 1);

  static String formatDuration(int seconds) {
    if (seconds < 3600) return '${seconds ~/ 60}m';
    final hours = seconds / 3600;
    return hours >= 10 ? '${hours.round()}h' : '${hours.toStringAsFixed(1)}h';
  }
}
