import 'package:flutter/material.dart';

enum NodeStatus { completed, active, upcoming, locked }

/// A single sub-level node on the journey map.
class JourneyNode {
  const JourneyNode({
    required this.part,
    required this.title,
    required this.status,
  });

  final String part; // e.g. "Part A"
  final String title; // e.g. "Chords 101"
  final NodeStatus status;
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

/// Static journey data plus the daily-practice snapshot shown at the bottom.
class JourneyProvider extends ChangeNotifier {
  // Levels are ordered top (hardest / locked) to bottom (completed) to match
  // the vertical map in the design.
  final List<JourneyLevel> levels = const [
    JourneyLevel(
      title: 'Level 3: Shred Master',
      accent: Color(0xFFA900A9),
      nodes: [
        JourneyNode(part: 'Part C', title: 'Sweep Picking', status: NodeStatus.locked),
        JourneyNode(part: 'Part B', title: 'Tapping', status: NodeStatus.locked),
        JourneyNode(part: 'Part A', title: 'Fast Alt Picking', status: NodeStatus.locked),
      ],
    ),
    JourneyLevel(
      title: 'Level 2: Riff Rider',
      accent: Color(0xFF006970),
      nodes: [
        JourneyNode(part: 'Part C', title: 'Power Chords', status: NodeStatus.upcoming),
        JourneyNode(part: 'Part B', title: 'Chords 101', status: NodeStatus.active),
        JourneyNode(part: 'Part A', title: 'Open Strings', status: NodeStatus.completed),
      ],
    ),
    JourneyLevel(
      title: 'Level 1: String Starter',
      accent: Color(0xFF00DBE9),
      nodes: [
        JourneyNode(part: 'Complete', title: 'Fundamentals', status: NodeStatus.completed),
      ],
    ),
  ];

  // Daily practice snapshot
  final int minutesPlayed = 15;
  final int minutesGoal = 20;
  final double totalHours = 42.5;
  final int badges = 18;

  double get dailyProgress => minutesPlayed / minutesGoal;

  void openNode(JourneyNode node) {
    // Hook for navigating into a lesson; UI-only for now.
  }
}
