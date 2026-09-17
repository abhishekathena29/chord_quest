import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The app's background surface: a flat base colour with a few faint,
/// slowly-drifting thread-like loops for texture. Wrap any screen body with
/// this for the shared background.
class AppBackground extends StatefulWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _ThreadPainter(t: _controller.value),
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// A handful of loose, hand-drawn-looking loops in the corners of the
/// screen, gently wobbling over a long cycle.
class _ThreadPainter extends CustomPainter {
  _ThreadPainter({required this.t});

  final double t; // 0..1, looping

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.outline.withValues(alpha: 0.12);

    final w = size.width;
    final h = size.height;
    final a = math.sin(t * 2 * math.pi);
    final b = math.cos(t * 2 * math.pi);

    // Top-right loop.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, -h * 0.02)
        ..cubicTo(
          w * 0.72 + a * 10,
          h * 0.06,
          w * 1.05,
          h * 0.02 - b * 8,
          w * 0.97,
          h * 0.2,
        )
        ..cubicTo(
          w * 0.92,
          h * 0.32 + b * 8,
          w * 0.7,
          h * 0.3,
          w * 0.68,
          h * 0.16,
        )
        ..cubicTo(
          w * 0.66,
          h * 0.05 - a * 8,
          w * 0.8,
          h * 0.01,
          w * 0.9,
          h * 0.07,
        ),
      paint,
    );

    // Left-side loop.
    canvas.drawPath(
      Path()
        ..moveTo(-w * 0.05, h * 0.26)
        ..cubicTo(
          w * 0.05 + b * 8,
          h * 0.18,
          w * 0.22,
          h * 0.16 - a * 8,
          w * 0.27,
          h * 0.3,
        )
        ..cubicTo(
          w * 0.32,
          h * 0.44 + a * 8,
          w * 0.16,
          h * 0.48,
          w * 0.06,
          h * 0.4,
        )
        ..cubicTo(
          -w * 0.02,
          h * 0.33 - b * 8,
          -w * 0.02,
          h * 0.58,
          w * 0.1,
          h * 0.64,
        ),
      paint,
    );

    // Bottom-right flourish.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.7, h * 1.02)
        ..cubicTo(
          w * 0.82 + a * 6,
          h * 0.94,
          w * 1.02,
          h * 0.96 - b * 6,
          w * 0.98,
          h * 0.86,
        )
        ..cubicTo(
          w * 0.95,
          h * 0.78 + b * 6,
          w * 0.84,
          h * 0.8,
          w * 0.82,
          h * 0.9,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ThreadPainter old) => old.t != t;
}
