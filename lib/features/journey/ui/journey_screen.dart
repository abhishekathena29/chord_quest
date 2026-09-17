import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shapes.dart';
import '../provider/journey_provider.dart';

/// The "Guitarist's Journey" — a vertical, gamified level map with a daily
/// practice summary card.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JourneyProvider(),
      child: const _JourneyView(),
    );
  }
}

class _JourneyView extends StatelessWidget {
  const _JourneyView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JourneyProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        Text(
          'YOUR PROGRESS',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text("Guitarist's Journey", style: AppTypography.headlineLgMobile),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Master the strings and unlock your musical potential.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.lg),
        // The vertical map with a glowing path line behind the nodes.
        Stack(
          alignment: Alignment.topCenter,
          children: [
            const Positioned.fill(child: _PathLine()),
            Column(
              children: [
                for (final level in provider.levels)
                  _LevelSection(level: level),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _DailyPracticeCard(provider: provider),
      ],
    );
  }
}

class _PathLine extends StatelessWidget {
  const _PathLine();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.primaryFixedDim.withValues(alpha: 0.5),
              AppColors.secondary.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.level});

  final JourneyLevel level;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.base,
            ),
            borderRadius: AppRadius.full,
            child: Text(
              level.title.toUpperCase(),
              style: AppTypography.labelMd.copyWith(
                color: level.accent,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < level.nodes.length; i++) ...[
            _NodeRow(node: level.nodes[i], alignRight: i.isEven),
            if (i != level.nodes.length - 1)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

/// A node plus its side label, laid out around the central path line.
class _NodeRow extends StatelessWidget {
  const _NodeRow({required this.node, required this.alignRight});

  final JourneyNode node;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final label = _Label(node: node);
    final gap = const SizedBox(width: AppSpacing.md);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: alignRight
              ? const SizedBox.shrink()
              : Align(alignment: Alignment.centerRight, child: label),
        ),
        gap,
        _NodeShape(node: node),
        gap,
        Expanded(
          child: alignRight
              ? Align(alignment: Alignment.centerLeft, child: label)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.node});

  final JourneyNode node;

  @override
  Widget build(BuildContext context) {
    final muted = node.status == NodeStatus.locked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          node.part,
          style: AppTypography.labelMd.copyWith(
            color: muted ? AppColors.outline : AppColors.onSurface,
          ),
        ),
        Text(
          node.title,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NodeShape extends StatelessWidget {
  const _NodeShape({required this.node});

  final JourneyNode node;

  @override
  Widget build(BuildContext context) {
    switch (node.status) {
      case NodeStatus.active:
        return _hex(
          size: 92,
          gradient: const LinearGradient(colors: AppColors.brandGradient),
          glow: AppColors.primary,
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.onPrimary,
            size: 44,
          ),
        );
      case NodeStatus.upcoming:
        return _hex(
          size: 76,
          color: AppColors.surfaceContainerLow,
          border: AppColors.primaryFixedDim,
          child: Icon(
            Icons.timer_outlined,
            color: AppColors.primary.withValues(alpha: 0.5),
            size: 30,
          ),
        );
      case NodeStatus.completed:
        return _hex(
          size: 76,
          color: AppColors.primaryContainer,
          border: AppColors.primary,
          child: const Icon(
            Icons.check_circle,
            color: AppColors.onPrimaryContainer,
            size: 32,
          ),
        );
      case NodeStatus.locked:
        return ClipPath(
          clipper: DiamondClipper(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              border: Border.all(color: AppColors.outlineVariant, width: 2),
            ),
            child: const Icon(Icons.lock, color: AppColors.outline, size: 24),
          ),
        );
    }
  }

  Widget _hex({
    required double size,
    Gradient? gradient,
    Color? color,
    Color? border,
    Color? glow,
    required Widget child,
  }) {
    Widget shape = ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          border: border != null ? Border.all(color: border, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
    if (glow != null) {
      shape = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: shape,
      );
    }
    return shape;
  }
}

class _DailyPracticeCard extends StatelessWidget {
  const _DailyPracticeCard({required this.provider});

  final JourneyProvider provider;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Practice',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Keep your streak alive!',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: provider.dailyProgress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.minutesPlayed} / ${provider.minutesGoal} Minutes Played',
                style: AppTypography.labelSm,
              ),
              Text(
                '${(provider.dailyProgress * 100).round()}% Today',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.history,
                  color: AppColors.primary,
                  label: 'TOTAL HOURS',
                  value: '${provider.totalHours}h',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.military_tech,
                  color: AppColors.secondary,
                  label: 'BADGES',
                  value: '${provider.badges} Earned',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSm.copyWith(fontSize: 10),
                ),
                Text(
                  value,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
