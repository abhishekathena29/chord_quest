import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../shell/ui/main_shell.dart';
import '../provider/profile_setup_provider.dart';

/// A single, minimal screen shown once right after sign-up to learn the
/// player's guitar skill level, experience and goal.
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileSetupProvider(),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatelessWidget {
  const _ProfileSetupView();

  void _finish(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileSetupProvider>();
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _finish(context),
                      child: Text(
                        'Skip',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Let's set up your profile",
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineLg,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'A few quick questions to tailor your journey.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _Question(
                    title: 'Your skill level',
                    child: _ChipGroup<SkillLevel>(
                      options: SkillLevel.values,
                      labelOf: (v) => v.label,
                      selected: p.skill,
                      onSelected: p.selectSkill,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Question(
                    title: 'How long have you played?',
                    child: _ChipGroup<Experience>(
                      options: Experience.values,
                      labelOf: (v) => v.label,
                      selected: p.experience,
                      onSelected: p.selectExperience,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Question(
                    title: "What's your goal?",
                    child: _ChipGroup<PracticeGoal>(
                      options: PracticeGoal.values,
                      labelOf: (v) => v.label,
                      selected: p.goal,
                      onSelected: p.selectGoal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GradientButton(
                    label: 'Get Started',
                    onPressed: p.canContinue ? () => _finish(context) : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
  });

  final List<T> options;
  final String Function(T) labelOf;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.base,
      children: [
        for (final option in options)
          _Chip(
            label: labelOf(option),
            active: option == selected,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: AppColors.brandGradient)
              : null,
          color: active ? null : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
