import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A flat circular icon button — solid dark fill with a white icon by
/// default, matching the reference's back/action buttons on detail screens.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.dark = true,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: dark ? AppColors.onSurface : AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: dark ? Colors.white : AppColors.onSurfaceVariant,
          size: size * 0.45,
        ),
      ),
    );
  }
}
