import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/ui/auth_screen.dart';
import '../provider/onboarding_provider.dart';

/// Three-slide onboarding carousel shown before authentication.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _finish(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Consumer<OnboardingProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.base),
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
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: provider.pageController,
                        onPageChanged: provider.onPageChanged,
                        itemCount: provider.pages.length,
                        itemBuilder: (context, i) =>
                            _OnboardingPage(data: provider.pages[i]),
                      ),
                    ),
                    _Indicator(
                      count: provider.pages.length,
                      index: provider.index,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: GradientButton(
                        label: provider.isLastPage ? 'Get Started' : 'Next',
                        icon: provider.isLastPage ? Icons.arrow_forward : null,
                        onPressed: () => provider.isLastPage
                            ? _finish(context)
                            : provider.next(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(data.icon, size: 56, color: data.accent),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineLg,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLg,
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 28 : 8,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: AppColors.brandGradient)
                : null,
            color: active ? null : AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}
