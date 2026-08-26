import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mesh_background.dart';
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
      body: MeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(song: song),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.xl),
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

class _Header extends StatelessWidget {
  const _Header({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    style: AppTypography.headlineMd, maxLines: 1),
                Text(song.subtitle, style: AppTypography.labelSm),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PracticeScreen(song: song)),
            ),
            icon: const Icon(Icons.fiber_manual_record, size: 16),
            label: const Text('Practice'),
          ),
        ],
      ),
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
      child: GlassCard(
        borderRadius: AppRadius.xl,
        glowColor: AppColors.primary,
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
                const Icon(Icons.speed,
                    size: 18, color: AppColors.onSurfaceVariant),
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
                  child: Text('${(provider.speed * 100).round()}%',
                      style: AppTypography.labelSm),
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
      icon: Icon(icon,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant),
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
            Text('Could not render this score.\n$message',
                textAlign: TextAlign.center, style: AppTypography.bodyMd),
          ],
        ),
      ),
    );
  }
}
