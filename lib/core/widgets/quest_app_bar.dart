import 'dart:ui';

import 'package:flutter/material.dart';

import '../../features/tuner/ui/tuner_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'gradient_text.dart';

/// Frosted top app bar carrying the MelodyQuest brand mark on the left and the
/// player's XP / streak chip on the right.
class QuestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuestAppBar({super.key, this.xp = 1240, this.streak = 12});

  final int xp;
  final int streak;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(Icons.music_note, color: AppColors.primary),
                const SizedBox(width: AppSpacing.base),
                GradientText('MelodyQuest', style: AppTypography.headlineMd),
                const Spacer(),
                Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Tuner',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TunerScreen()),
                    ),
                    icon: const Icon(Icons.graphic_eq, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_formatXp(xp)} XP',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 2),
                      Text(
                        '$streak',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatXp(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
