import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../provider/study_provider.dart';

/// "Guitar Study & Sheet Music" — an interactive staff, live accuracy ring,
/// fretboard visualiser and a floating playback control bar.
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudyProvider(),
      child: const _StudyView(),
    );
  }
}

class _StudyView extends StatelessWidget {
  const _StudyView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StudyProvider>();
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            140,
          ),
          children: [
            Text(
              'CURRENT SESSION',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Guitar Study & Sheet Music',
              style: AppTypography.headlineLgMobile,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    icon: Icons.timer,
                    color: AppColors.primary,
                    label: 'Session',
                    value: p.sessionTime,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatChip(
                    icon: Icons.bolt,
                    color: AppColors.secondary,
                    label: 'Streak',
                    value: '${p.streakDays} Days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InteractiveStaffCard(notes: p.staffNotes),
            const SizedBox(height: AppSpacing.md),
            _AccuracyCard(accuracy: p.accuracy, perfectNotes: p.perfectNotes),
            const SizedBox(height: AppSpacing.md),
            _FretboardCard(provider: p),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 100,
          child: Center(child: _ControlBar(provider: p)),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSm),
              Text(
                value,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractiveStaffCard extends StatelessWidget {
  const _InteractiveStaffCard({required this.notes});

  final List<StaffNote> notes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.description,
            color: AppColors.primary,
            title: 'Interactive Staff',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 150,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _StaffPainter(),
                    ),
                    for (var i = 0; i < notes.length; i++)
                      _StaffNoteDot(
                        note: notes[i],
                        x:
                            constraints.maxWidth *
                            (0.15 + 0.7 * (i / (notes.length - 1))),
                        height: constraints.maxHeight,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffNoteDot extends StatelessWidget {
  const _StaffNoteDot({
    required this.note,
    required this.x,
    required this.height,
  });

  final StaffNote note;
  final double x;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Staff occupies the middle 60% of the height.
    final y = height * (0.2 + note.staffPosition * 0.6);
    return Positioned(
      left: x - 16,
      top: y - 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: note.color.withValues(alpha: note.active ? 1 : 0.6),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: note.active
                  ? [
                      BoxShadow(
                        color: note.color.withValues(alpha: 0.6),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note.name,
            style: AppTypography.labelSm.copyWith(color: note.color),
          ),
        ],
      ),
    );
  }
}

class _StaffPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    const lines = 5;
    final top = size.height * 0.2;
    final span = size.height * 0.6;
    for (var i = 0; i < lines; i++) {
      final y = top + span * (i / (lines - 1));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({required this.accuracy, required this.perfectNotes});

  final int accuracy;
  final int perfectNotes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: CustomPaint(painter: _RingPainter(accuracy / 100)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$accuracy%',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text('Accuracy', style: AppTypography.labelSm),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perfect Notes',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '$perfectNotes',
                style: AppTypography.labelMd.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - 12) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = AppColors.primary.withValues(alpha: 0.12);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FretboardCard extends StatelessWidget {
  const _FretboardCard({required this.provider});

  final StudyProvider provider;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CardHeader(
                icon: Icons.grid_view,
                color: AppColors.secondary,
                title: 'Fretboard Master',
              ),
              const Spacer(),
              _pill(
                provider.tuning,
                AppColors.surfaceContainerHigh,
                AppColors.onSurfaceVariant,
              ),
            ],
          ),
          if (provider.advancedMode) ...[
            const SizedBox(height: AppSpacing.base),
            Align(
              alignment: Alignment.centerRight,
              child: _pill(
                'Advanced Mode',
                AppColors.secondaryFixed,
                AppColors.secondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 640,
                height: 170,
                child: CustomPaint(
                  painter: _FretboardPainter(
                    strings: provider.strings,
                    frets: provider.frets,
                    markers: provider.markers,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(color: fg, letterSpacing: 0.3),
      ),
    );
  }
}

class _FretboardPainter extends CustomPainter {
  _FretboardPainter({
    required this.strings,
    required this.frets,
    required this.markers,
  });

  final int strings;
  final int frets;
  final List<FretMarker> markers;

  @override
  void paint(Canvas canvas, Size size) {
    const padX = 32.0;
    const padY = 24.0;
    final usableW = size.width - padX * 2;
    final usableH = size.height - padY * 2;
    final fretW = usableW / frets;
    final stringGap = usableH / (strings - 1);

    // Strings (thicker toward the bottom).
    for (var s = 0; s < strings; s++) {
      final y = padY + stringGap * s;
      final paint = Paint()
        ..color = AppColors.outlineVariant.withValues(alpha: 0.4 + s * 0.08)
        ..strokeWidth = 1 + s * 0.5;
      canvas.drawLine(Offset(padX, y), Offset(size.width - padX, y), paint);
    }

    // Fret wires.
    final fretPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    for (var f = 0; f <= frets; f++) {
      final x = padX + fretW * f;
      canvas.drawLine(
        Offset(x, padY),
        Offset(x, size.height - padY),
        fretPaint,
      );
    }

    // Inlay dots on frets 3, 5, 7, 9.
    final inlay = Paint()..color = AppColors.surfaceContainerHighest;
    for (final f in [3, 5, 7]) {
      final x = padX + fretW * (f - 0.5);
      canvas.drawCircle(Offset(x, size.height / 2), 5, inlay);
    }

    // Note markers.
    for (final m in markers) {
      final x = padX + fretW * (m.fret + 0.5);
      final y = padY + stringGap * m.string;
      if (m.active) {
        canvas.drawCircle(
          Offset(x, y),
          22,
          Paint()..color = m.color.withValues(alpha: 0.3),
        );
      }
      canvas.drawCircle(Offset(x, y), 15, Paint()..color = m.color);
      canvas.drawCircle(
        Offset(x, y),
        15,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: 0.6),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: m.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.base),
        Text(
          title,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.provider});

  final StudyProvider provider;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: AppCard(
        borderRadius: AppRadius.full,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        accentColor: AppColors.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _round(Icons.replay_10, () {}),
            GestureDetector(
              onTap: provider.togglePlay,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.brandGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(
                  provider.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            _round(Icons.forward_10, () {}),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.onSurfaceVariant),
    );
  }
}
