import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'gradient_text.dart';

/// Flat top app bar carrying the Chord Quest brand mark on the left and the
/// player's XP / streak chip on the right. Built on Flutter's own [AppBar] so
/// the status-bar safe area is handled correctly on every device.
class QuestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuestAppBar({super.key, this.xp = 1240, this.streak = 12});

  final int xp;
  final int streak;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.marginMobile,
      shape: Border(
        bottom: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.music_note, color: AppColors.primary),
          const SizedBox(width: AppSpacing.base),
          GradientText('Chord Quest', style: AppTypography.headlineMd),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.marginMobile),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppRadius.full),
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
        ),
      ],
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
