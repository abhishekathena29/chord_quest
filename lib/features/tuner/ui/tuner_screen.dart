import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mesh_background.dart';
import '../provider/tuner_provider.dart';

/// Real-time chromatic guitar tuner. Pushed as its own route.
class TunerScreen extends StatelessWidget {
  const TunerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TunerProvider(),
      child: const _TunerView(),
    );
  }
}

class _TunerView extends StatelessWidget {
  const _TunerView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TunerProvider>();
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _TuningSelector(provider: p),
                      const SizedBox(height: AppSpacing.lg),
                      _Gauge(provider: p),
                      const SizedBox(height: AppSpacing.lg),
                      _StringRow(provider: p),
                      const SizedBox(height: AppSpacing.lg),
                      if (p.permission == MicPermission.permanentlyDenied)
                        _PermissionNotice(),
                      _MicButton(provider: p),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        p.listening
                            ? 'Pluck a string…'
                            : 'Tap to start the tuner',
                        style: AppTypography.labelMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.base),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          ),
          const SizedBox(width: AppSpacing.base),
          Text('Guitar Tuner', style: AppTypography.headlineMd),
        ],
      ),
    );
  }
}

class _TuningSelector extends StatelessWidget {
  const _TuningSelector({required this.provider});

  final TunerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.tunings.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.base),
        itemBuilder: (context, i) {
          final active = provider.tuning == provider.tunings[i];
          return GestureDetector(
            onTap: () => provider.selectTuning(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: AppColors.brandGradient)
                    : null,
                color: active ? null : AppColors.surfaceContainerLowest
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: active ? Colors.transparent : AppColors.outlineVariant,
                ),
              ),
              child: Text(
                provider.tunings[i].name,
                style: AppTypography.labelMd.copyWith(
                  color:
                      active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({required this.provider});

  final TunerProvider provider;

  Color get _statusColor {
    switch (provider.direction) {
      case TuneDirection.inTune:
        return const Color(0xFF059669);
      case TuneDirection.flat:
      case TuneDirection.sharp:
        return AppColors.secondary;
      case TuneDirection.none:
        return AppColors.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inTune = provider.direction == TuneDirection.inTune;
    return GlassCard(
      glowColor: provider.hasSignal ? _statusColor : null,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _GaugePainter(
                cents: provider.hasSignal ? provider.cents.clamp(-50, 50) : 0,
                active: provider.hasSignal,
                color: _statusColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            provider.hasSignal ? provider.note : '--',
            style: AppTypography.headlineXl.copyWith(
              color: provider.hasSignal ? _statusColor : AppColors.outline,
              fontSize: 56,
            ),
          ),
          Text(
            provider.hasSignal
                ? '${provider.frequency.toStringAsFixed(1)} Hz'
                : 'Listening for a note',
            style: AppTypography.labelMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedOpacity(
            opacity: provider.hasSignal ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              inTune
                  ? 'In Tune ✓'
                  : '${provider.cents.abs().round()}¢ ${provider.direction == TuneDirection.flat ? 'flat' : 'sharp'}',
              style: AppTypography.labelMd.copyWith(color: _statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.cents,
    required this.active,
    required this.color,
  });

  final double cents; // -50..50
  final bool active;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = math.min(size.width / 2, size.height) - 12;
    const startAngle = math.pi; // 180°
    const sweep = math.pi; // half circle

    // Track arc.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = AppColors.outlineVariant.withValues(alpha: 0.4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      track,
    );

    // Centre "in tune" tick.
    final tickPaint = Paint()
      ..color = AppColors.onSurfaceVariant
      ..strokeWidth = 3;
    for (var c = -50; c <= 50; c += 10) {
      final a = startAngle + sweep * ((c + 50) / 100);
      final outer = center + Offset(math.cos(a), math.sin(a)) * radius;
      final len = c == 0 ? 16.0 : 8.0;
      final inner =
          center + Offset(math.cos(a), math.sin(a)) * (radius - len);
      canvas.drawLine(
        inner,
        outer,
        tickPaint
          ..color = c == 0
              ? const Color(0xFF059669)
              : AppColors.outlineVariant,
      );
    }

    // Needle.
    final a = startAngle + sweep * ((cents + 50) / 100);
    final needle = Paint()
      ..color = active ? color : AppColors.outline
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center + Offset(math.cos(a), math.sin(a)) * (radius - 4),
      needle,
    );
    canvas.drawCircle(center, 7, Paint()..color = active ? color : AppColors.outline);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.cents != cents || old.active != active || old.color != color;
}

class _StringRow extends StatelessWidget {
  const _StringRow({required this.provider});

  final TunerProvider provider;

  @override
  Widget build(BuildContext context) {
    final strings = provider.tuning.strings;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < strings.length; i++)
          _StringChip(
            label: strings[i].label,
            active: provider.targetStringIndex == i && provider.hasSignal,
            tuned: provider.isStringTuned(i),
          ),
      ],
    );
  }
}

class _StringChip extends StatelessWidget {
  const _StringChip({
    required this.label,
    required this.active,
    required this.tuned,
  });

  final String label;
  final bool active;
  final bool tuned;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (active) {
      bg = AppColors.primary;
      fg = AppColors.onPrimary;
    } else if (tuned) {
      bg = const Color(0xFF059669);
      fg = Colors.white;
    } else {
      bg = AppColors.surfaceContainerHigh;
      fg = AppColors.onSurfaceVariant;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 16,
                )
              ]
            : null,
      ),
      child: Text(label, style: AppTypography.labelMd.copyWith(color: fg)),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.provider});

  final TunerProvider provider;

  @override
  Widget build(BuildContext context) {
    final listening = provider.listening;
    return GestureDetector(
      onTap: provider.toggleListening,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: listening
              ? null
              : const LinearGradient(colors: AppColors.brandGradient),
          color: listening ? AppColors.error : null,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (listening ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: Icon(
          listening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

class _PermissionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        glowColor: AppColors.error,
        child: Column(
          children: [
            const Icon(Icons.mic_off, color: AppColors.error, size: 32),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Microphone access is blocked. Enable it in Settings to use the tuner.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: openAppSettings,
              child: Text('Open Settings',
                  style: AppTypography.labelMd
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
