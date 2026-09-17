import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The primary flat content container: a solid surface, a thin hairline
/// border and a soft shadow. No blur, no glow — just a clean card.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.lg,
    this.onTap,
    this.accentColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  /// Optional soft brand tint applied to the fill and border — use sparingly,
  /// for a single hero card per screen at most.
  final Color? accentColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final fill = accentColor != null
        ? Color.alphaBlend(
            accentColor!.withValues(alpha: 0.05),
            AppColors.surfaceContainerLowest,
          )
        : AppColors.surfaceContainerLowest;
    final border =
        borderColor ??
        (accentColor != null
            ? accentColor!.withValues(alpha: 0.18)
            : AppColors.outlineVariant.withValues(alpha: 0.4));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: fill,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: border, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
