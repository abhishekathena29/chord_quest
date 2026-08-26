import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/ui/onboarding_screen.dart';

/// Root widget: applies the Luminous Harmonic theme and starts the user at the
/// onboarding flow (onboarding -> auth -> main shell).
class ChordQuestApp extends StatelessWidget {
  const ChordQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MelodyQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OnboardingScreen(),
    );
  }
}
