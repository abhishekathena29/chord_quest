import 'package:flutter/material.dart';

import '../../../core/data/models/user_profile.dart';
import '../../../core/progress/progression.dart';

enum NodeStatus { completed, active, upcoming, locked }

/// A single sub-level node on the journey map.
class JourneyNode {
  const JourneyNode({
    required this.part,
    required this.title,
    required this.status,
    required this.unlockXp,
  });

  final String part; // e.g. "Part A"
  final String title; // e.g. "Chords 101"
  final NodeStatus status;
  final int unlockXp;
}

/// A level (group of nodes) on the journey map.
class JourneyLevel {
  const JourneyLevel({
    required this.title,
    required this.nodes,
    required this.accent,
  });

  final String title;
  final List<JourneyNode> nodes;
  final Color accent;
}

/// Journey map + daily-practice snapshot derived from the player's profile.
/// Nodes unlock as total XP passes each [Progression.milestones] threshold.
class JourneyProgress {
  JourneyProgress(this.profile);

  final UserProfile? profile;

  static const _accents = [
    Color(0xFF00DBE9),
    Color(0xFF006970),
    Color(0xFFA900A9),
  ];

  int get xp => profile?.xp ?? 0;

  NodeStatus _statusFor(int index, int active) {
    if (index < active) return NodeStatus.completed;
    if (index == active) return NodeStatus.active;
    if (index == active + 1) return NodeStatus.upcoming;
    return NodeStatus.locked;
  }

  // Levels are ordered top (hardest / locked) to bottom (completed) to match
  // the vertical map in the design.
  List<JourneyLevel> get levels {
    final active = Progression.activeMilestoneIndex(xp);
    final milestones = Progression.milestones;
    return [
      for (var level = Progression.rankTitles.length - 1; level >= 0; level--)
        JourneyLevel(
          title: 'Level ${level + 1}: ${Progression.rankTitles[level]}',
          accent: _accents[level],
          nodes: [
            for (var i = milestones.length - 1; i >= 0; i--)
              if (milestones[i].level == level)
                JourneyNode(
                  part: milestones[i].part,
                  title: milestones[i].title,
                  status: _statusFor(i, active),
                  unlockXp: milestones[i].xp,
                ),
          ],
        ),
    ];
  }

  // Daily practice snapshot
  int get minutesPlayed => (profile?.secondsToday() ?? 0) ~/ 60;
  int get minutesGoal => profile?.dailyGoalMinutes ?? 20;
  double get totalHours =>
      ((profile?.totalPracticeSeconds ?? 0) / 3600 * 10).round() / 10;
  int get sessions => profile?.sessionsCount ?? 0;

  double get dailyProgress =>
      minutesGoal == 0 ? 0 : (minutesPlayed / minutesGoal).clamp(0, 1);
}
