import 'package:flutter/material.dart';

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

/// Static profile data for "Jaxon Storm" plus the active weekly challenge.
class ProfileProvider extends ChangeNotifier {
  final String name = 'Jaxon Storm';
  final String rank = 'Lvl 42 Shredder';
  final int level = 42;
  final String location = 'Seattle, WA';
  final String joined = 'Joined May 2023';

  final List<ProfileStat> stats = const [
    ProfileStat(
        icon: Icons.local_fire_department,
        value: '15 Day',
        label: 'Streak',
        color: Color(0xFFF97316)),
    ProfileStat(
        icon: Icons.track_changes,
        value: '98.4%',
        label: 'Accuracy',
        color: Color(0xFF0891B2)),
    ProfileStat(
        icon: Icons.schedule,
        value: '124h',
        label: 'Practice Time',
        color: Color(0xFF9333EA)),
    ProfileStat(
        icon: Icons.verified,
        value: '86',
        label: 'Songs Mastered',
        color: Color(0xFF059669)),
  ];

  final List<ProfileBadge> badges = const [
    ProfileBadge(
        icon: Icons.star,
        label: 'Chord Master',
        colors: [Color(0xFFFDE047), Color(0xFFF97316)]),
    ProfileBadge(
        icon: Icons.electric_bolt,
        label: 'Virtuoso',
        colors: [Color(0xFF67E8F9), Color(0xFF3B82F6)]),
    ProfileBadge(
        icon: Icons.speed,
        label: 'Solo Speedster',
        colors: [Color(0xFFD8B4FE), Color(0xFFEC4899)]),
    ProfileBadge(
        icon: Icons.lock,
        label: 'Legendary',
        colors: [Color(0xFFE0E3E5), Color(0xFFE0E3E5)],
        locked: true),
  ];

  // Weekly challenge
  final String challengeTitle = 'Eruption Solo Speed';
  final String challengeBody =
      "Master the first 20 bars of Van Halen's 'Eruption' with at least 95% accuracy.";
  final double challengeProgress = 0.72;
}
