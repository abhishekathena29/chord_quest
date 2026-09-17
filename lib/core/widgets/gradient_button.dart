import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Solid, high-saturation gradient action button (primary -> secondary) with a
/// soft colour "bloom" glow. Presses in slightly on tap.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: widget.height,
          width: widget.expand ? double.infinity : null,
          padding: widget.expand
              ? null
              : const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? AppColors.brandGradient
                  : [AppColors.outlineVariant, AppColors.outlineVariant],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 16,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: AppSpacing.base),
                Icon(widget.icon, color: AppColors.onPrimary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
