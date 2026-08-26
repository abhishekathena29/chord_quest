import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The "Atmosphere" layer of the design system: a base surface with soft
/// mesh-gradient blobs of primary / secondary / tertiary at low opacity.
///
/// Wrap any screen body with this to get the signature living background.
class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Stack(
        children: [
          // Cyan blob — top left
          _blob(
            alignment: const Alignment(-1.1, -1.1),
            color: AppColors.primaryContainer.withValues(alpha: 0.18),
            size: 420,
          ),
          // Magenta blob — top right
          _blob(
            alignment: const Alignment(1.2, -0.9),
            color: AppColors.secondary.withValues(alpha: 0.16),
            size: 380,
          ),
          // Violet blob — bottom left
          _blob(
            alignment: const Alignment(-1.1, 1.1),
            color: AppColors.tertiary.withValues(alpha: 0.12),
            size: 360,
          ),
          // Cyan blob — bottom right
          _blob(
            alignment: const Alignment(1.1, 1.2),
            color: AppColors.primaryContainer.withValues(alpha: 0.12),
            size: 400,
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _blob({
    required Alignment alignment,
    required Color color,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 140, spreadRadius: 80),
          ],
          color: color,
        ),
      ),
    );
  }
}
