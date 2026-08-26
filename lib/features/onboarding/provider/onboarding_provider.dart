import 'package:flutter/material.dart';

/// A single onboarding slide.
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
}

/// Drives the onboarding carousel: current page, navigation and completion.
class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();

  final List<OnboardingPageData> pages = const [
    OnboardingPageData(
      icon: Icons.auto_awesome_motion,
      title: 'Learn by Questing',
      body:
          'Climb a living level map — from String Starter to Shred Master — '
          'one riff at a time.',
      accent: Color(0xFF00DBE9),
    ),
    OnboardingPageData(
      icon: Icons.graphic_eq,
      title: 'Play Along in Real Time',
      body:
          'Interactive sheet music and a glowing fretboard listen as you play '
          'and score every note.',
      accent: Color(0xFFA900A9),
    ),
    OnboardingPageData(
      icon: Icons.local_fire_department,
      title: 'Build Your Streak',
      body:
          'Earn XP, unlock badges and keep your daily streak alive as you '
          'master the electric guitar.',
      accent: Color(0xFF7212FF),
    ),
  ];

  int _index = 0;
  int get index => _index;

  bool get isLastPage => _index == pages.length - 1;

  void onPageChanged(int value) {
    _index = value;
    notifyListeners();
  }

  void next() {
    if (isLastPage) return;
    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
