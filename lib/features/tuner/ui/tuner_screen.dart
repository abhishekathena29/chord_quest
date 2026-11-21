import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/note_math.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../provider/tuner_provider.dart';

/// Real-time chromatic guitar tuner — a persistent bottom-nav tab. Shows a
/// waveform-style pitch display, a row of note circles, and the tuning
/// presets along the bottom.
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

class _TunerView extends StatefulWidget {
  const _TunerView();

  @override
  State<_TunerView> createState() => _TunerViewState();
}

/// Releases the microphone whenever the tuner is not on screen: when another
/// tab is selected or a route covers the shell (both turn [TickerMode] off),
/// and when the app is sent to the background.
class _TunerViewState extends State<_TunerView> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _stopListening);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TickerMode.valuesOf(context).enabled) _stopListening();
  }

  void _stopListening() {
    final p = context.read<TunerProvider>();
    if (p.listening) p.stop();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TunerProvider>();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                _StatusMessage(provider: p),
                const SizedBox(height: AppSpacing.md),
                _Waveform(provider: p),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  p.hasSignal
                      ? '${p.frequency.toStringAsFixed(0)} Hz'
                      : 'Listening for a note',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _NoteRow(provider: p),
                const SizedBox(height: AppSpacing.md),
                if (p.permission == MicPermission.permanentlyDenied)
                  _PermissionNotice(),
                _MicPill(provider: p),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        _TuningTabs(provider: p),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.provider});

  final TunerProvider provider;

  static const _inTuneColor = Color(0xFF059669);

  ({String text, Color color}) get _status {
    switch (provider.direction) {
      case TuneDirection.inTune:
        return (text: 'Perfect ;)', color: _inTuneColor);
      case TuneDirection.flat:
        return (text: 'Tune up a little', color: AppColors.secondary);
      case TuneDirection.sharp:
        return (text: 'Tune down a little', color: AppColors.secondary);
      case TuneDirection.none:
        return (
          text: provider.listening ? 'Pluck a string…' : 'Tap the mic to start',
          color: AppColors.onSurfaceVariant,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Text(
      s.text,
      style: AppTypography.headlineMd.copyWith(color: s.color),
    );
  }
}

/// A ruler-style pitch display: a field of thin static bars with one taller,
/// coloured bar sliding left/right to show how flat or sharp the note is.
class _Waveform extends StatelessWidget {
  const _Waveform({required this.provider});

  final TunerProvider provider;

  static const _inTuneColor = Color(0xFF059669);

  Color get _color {
    switch (provider.direction) {
      case TuneDirection.inTune:
        return _inTuneColor;
      case TuneDirection.flat:
      case TuneDirection.sharp:
        return AppColors.secondary;
      case TuneDirection.none:
        return AppColors.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cents = provider.hasSignal ? provider.cents.clamp(-50.0, 50.0) : 0.0;
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          cents: cents,
          active: provider.hasSignal,
          color: _color,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.cents,
    required this.active,
    required this.color,
  });

  final double cents; // -50..50
  final bool active;
  final Color color;

  static const _barCount = 33;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final gap = size.width / (_barCount - 1);
    final track = Paint()
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.outlineVariant.withValues(alpha: 0.6);

    for (var i = 0; i < _barCount; i++) {
      final distFromCentre = (i - (_barCount - 1) / 2).abs();
      final h =
          size.height * (0.25 + 0.1 * (1 - distFromCentre / (_barCount / 2)));
      final x = gap * i;
      canvas.drawLine(Offset(x, mid - h / 2), Offset(x, mid + h / 2), track);
    }

    // Sliding pointer bar: centre = in tune, offset = flat/sharp.
    final pointerX = size.width / 2 + (cents / 50) * (size.width / 2 - 12);
    final pointer = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = active ? color : AppColors.outline;
    canvas.drawLine(
      Offset(pointerX, mid - size.height * 0.4),
      Offset(pointerX, mid + size.height * 0.4),
      pointer,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.cents != cents || old.active != active || old.color != color;
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.provider});

  final TunerProvider provider;

  static const _solfege = {
    'C': 'Do',
    'D': 'Re',
    'E': 'Mi',
    'F': 'Fa',
    'G': 'Sol',
    'A': 'La',
    'B': 'Si',
  };

  /// "D#" -> "Re#": solfège of the natural note plus any accidental.
  static String _solfegeFor(String name) =>
      '${_solfege[name[0]] ?? ''}${name.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final strings = provider.tuning.strings;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < strings.length; i++)
          _NoteCircle(
            letter: NoteMath.noteName(strings[i].midi),
            lowercase: i == strings.length - 1,
            solfege: _solfegeFor(NoteMath.noteName(strings[i].midi)),
            active: provider.targetStringIndex == i && provider.hasSignal,
            tuned: provider.isStringTuned(i),
          ),
      ],
    );
  }
}

class _NoteCircle extends StatelessWidget {
  const _NoteCircle({
    required this.letter,
    required this.lowercase,
    required this.solfege,
    required this.active,
    required this.tuned,
  });

  final String letter;
  final bool lowercase;
  final String solfege;
  final bool active;
  final bool tuned;

  static const _inTuneColor = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (active) {
      bg = AppColors.primary;
      fg = Colors.white;
    } else if (tuned) {
      bg = _inTuneColor;
      fg = Colors.white;
    } else {
      bg = AppColors.surfaceContainerLow;
      fg = AppColors.onSurfaceVariant;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Text(
            lowercase ? letter.toLowerCase() : letter,
            style: AppTypography.labelMd.copyWith(color: fg),
          ),
        ),
        const SizedBox(height: 4),
        Text(solfege, style: AppTypography.labelSm),
      ],
    );
  }
}

/// Slim pill toggling the microphone on and off.
class _MicPill extends StatelessWidget {
  const _MicPill({required this.provider});

  final TunerProvider provider;

  @override
  Widget build(BuildContext context) {
    final listening = provider.listening;
    return GestureDetector(
      onTap: provider.toggleListening,
      child: Container(
        width: 64,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: listening ? AppColors.error : AppColors.onSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Icon(
          listening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _TuningTabs extends StatelessWidget {
  const _TuningTabs({required this.provider});

  final TunerProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: provider.tunings.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final active = provider.tuning == provider.tunings[i];
          return GestureDetector(
            onTap: () => provider.selectTuning(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: active ? AppColors.surfaceContainerLow : null,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                provider.tunings[i].name,
                style: AppTypography.labelMd.copyWith(
                  color: active ? AppColors.onSurface : AppColors.outline,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PermissionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        accentColor: AppColors.error,
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
              child: Text(
                'Open Settings',
                style: AppTypography.labelMd.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
