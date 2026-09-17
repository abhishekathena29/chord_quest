import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../practice/ui/practice_screen.dart';
import '../provider/sheet_library_provider.dart';
import '../provider/sheet_viewer_provider.dart';

/// Renders a single [SheetSong] with alphaTab and exposes playback controls +
/// an entry into a live practice session.
class SheetViewerScreen extends StatelessWidget {
  const SheetViewerScreen({super.key, required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SheetViewerProvider(song: song),
      child: _ViewerView(song: song),
    );
  }
}

class _ViewerView extends StatelessWidget {
  const _ViewerView({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SheetViewerProvider>();
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(song: song),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _Intro(song: song),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          child: WebViewWidget(controller: p.controller),
                        ),
                      ),
                    ),
                    if (p.rendering) const _Loading(),
                    if (p.error != null) _ErrorPanel(message: p.error!),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _Controls(provider: p),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          CircleIconButton(
            icon: Icons.fiber_manual_record,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PracticeScreen(song: song)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '#${song.difficulty.label}',
          style: AppTypography.labelSm.copyWith(
            color: song.difficulty.color,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(song.title, style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _tag(song.difficulty.label, song.difficulty.color),
            const SizedBox(width: 6),
            _tag('${song.tempo} BPM', AppColors.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('${song.subtitle}.', style: AppTypography.bodyMd),
      ],
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(text, style: AppTypography.labelSm.copyWith(color: color)),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.provider});

  final SheetViewerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        borderRadius: AppRadius.xl,
        accentColor: AppColors.primary,
        child: Column(
          children: [
            Row(
              children: [
                _iconBtn(
                  provider.metronome ? Icons.timer : Icons.timer_outlined,
                  provider.toggleMetronome,
                  active: provider.metronome,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: provider.togglePlay,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.brandGradient),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      provider.playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const Spacer(),
                _iconBtn(Icons.stop, provider.stop),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.speed,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                Expanded(
                  child: Slider(
                    value: provider.speed,
                    min: 0.25,
                    max: 1.5,
                    divisions: 5,
                    activeColor: AppColors.primary,
                    label: '${(provider.speed * 100).round()}%',
                    onChanged: provider.setSpeed,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${(provider.speed * 100).round()}%',
                    style: AppTypography.labelSm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool active = false}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: active ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Could not render this score.\n$message',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd,
            ),
          ],
        ),
      ),
    );
  }
}
