import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../provider/profile_provider.dart';

/// "Guitarist Profile" — avatar header, bento stats grid, earned badges and an
/// active weekly-challenge card. Reads the [ProfileProvider] shared by
/// [MainShell] so the Home tab's greeting stays in sync.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        _Header(provider: p),
        const SizedBox(height: AppSpacing.lg),
        Text('Guitarist Profile', style: AppTypography.headlineLgMobile),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.15,
          children: [for (final s in p.stats) _StatCard(stat: s)],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Earned Badges', style: AppTypography.headlineMd),
            Text(
              'View All',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.spaceEvenly,
            children: [for (final b in p.badges) _BadgeTile(badge: b)],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Active Mission', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        _ChallengeCard(provider: p),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.tertiary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.inverseSurface,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.inverseOnSurface,
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${provider.level}',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(provider.name, style: AppTypography.headlineLg),
        const SizedBox(height: AppSpacing.xs),
        Text(
          provider.rank,
          style: AppTypography.headlineMd.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            _infoChip(Icons.location_on, provider.location),
            _infoChip(Icons.calendar_today, provider.joined),
          ],
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: AppTypography.labelSm),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: stat.color, size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stat.value,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          Text(stat.label, style: AppTypography.labelSm),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final ProfileBadge badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.locked ? 0.5 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: badge.colors,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                badge.icon,
                color: badge.locked
                    ? AppColors.onSurfaceVariant
                    : badge.colors.last,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            width: 72,
            child: Text(
              badge.label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSm.copyWith(
                color: badge.locked
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'WEEKLY CHALLENGE',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(provider.challengeTitle, style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.base),
          Text(provider.challengeBody, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTypography.labelSm),
              Text(
                '${(provider.challengeProgress * 100).round()}%',
                style: AppTypography.labelSm,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: provider.challengeProgress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Practice Now',
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
