import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/session/user_session.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_background.dart';
import 'features/auth/ui/auth_screen.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/profile_setup/ui/profile_setup_screen.dart';
import 'features/shell/ui/main_shell.dart';

/// Root widget: applies the Luminous Harmonic theme and lets [_AuthGate] pick
/// the flow (onboarding -> auth -> profile setup -> main shell) from the
/// signed-in state.
class ChordQuestApp extends StatelessWidget {
  const ChordQuestApp({super.key, this.createSession});

  /// Overrides the [UserSession] (tests inject fakes here).
  final UserSession Function()? createSession;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => createSession?.call() ?? UserSession(),
      child: MaterialApp(
        title: 'Chord Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Swaps the root screen whenever auth or profile state changes, so screens
/// never navigate between these stages themselves.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSession>();
    final Widget child = switch (session.status) {
      SessionStatus.loading => const _Splash(),
      SessionStatus.signedOut =>
        session.onboardingDone ? const AuthScreen() : const OnboardingScreen(),
      SessionStatus.needsSetup => const ProfileSetupScreen(),
      SessionStatus.ready => const MainShell(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(session.status), child: child),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppBackground(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
