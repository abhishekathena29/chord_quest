import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mesh_background.dart';
import '../../sheet_music/provider/sheet_library_provider.dart';
import '../provider/practice_provider.dart';

/// Live practice session: play the song's notes in order while the mic scores
/// you, and the take is recorded for optional transcription.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PracticeProvider(song: song),
      child: _PracticeView(song: song),
    );
  }
}

class _PracticeView extends StatelessWidget {
  const _PracticeView({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeProvider>();
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(song: song),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      if (p.permissionDenied) const _PermissionNotice(),
                      _AccuracyPanel(provider: p),
                      const SizedBox(height: AppSpacing.md),
                      _NotePanel(provider: p),
                      const SizedBox(height: AppSpacing.md),
                      if (p.state == PracticeState.finished)
                        _ResultPanel(provider: p),
                    ],
                  ),
                ),
              ),
              _TransportBar(provider: p),
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
                Text('Practice', style: AppTypography.labelSm),
                Text(song.title, style: AppTypography.headlineMd, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyPanel extends StatelessWidget {
  const _AccuracyPanel({required this.provider});

  final PracticeProvider provider;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.primary,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('${provider.accuracyPct}%', 'Accuracy', AppColors.primary),
              _stat('${provider.hits}', 'Notes Hit', AppColors.secondary),
              _stat(_fmt(provider.elapsed), 'Time', AppColors.tertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${provider.index} / ${provider.totalNotes} notes',
                style: AppTypography.labelSm),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.headlineMd.copyWith(color: color)),
        Text(label, style: AppTypography.labelSm),
      ],
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

class _NotePanel extends StatelessWidget {
  const _NotePanel({required this.provider});

  final PracticeProvider provider;

  @override
  Widget build(BuildContext context) {
    final running = provider.state == PracticeState.running;
    return GlassCard(
      child: Column(
        children: [
          Text('NEXT NOTE', style: AppTypography.labelSm),
          const SizedBox(height: AppSpacing.base),
          Text(
            running ? provider.nextNoteLabel : '—',
            style: AppTypography.headlineXl.copyWith(
              fontSize: 48,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.base),
            decoration: BoxDecoration(
              color: provider.onTarget
                  ? const Color(0xFF059669).withValues(alpha: 0.15)
                  : AppColors.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.onTarget ? Icons.check_circle : Icons.hearing,
                  size: 18,
                  color: provider.onTarget
                      ? const Color(0xFF059669)
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  running ? 'You: ${provider.detectedNote}' : 'Tap record to begin',
                  style: AppTypography.labelMd.copyWith(
                    color: provider.onTarget
                        ? const Color(0xFF059669)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.provider});

  final PracticeProvider provider;

  @override
  Widget build(BuildContext context) {
    final t = provider.transcription;
    return GlassCard(
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF059669)),
              const SizedBox(width: AppSpacing.base),
              Text('Session Saved', style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            provider.recordingPath == null
                ? 'No audio captured.'
                : 'Recording • ${provider.recordingLength.inSeconds}s',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.md),
          if (t == null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: provider.recordingPath == null || provider.transcribing
                    ? null
                    : provider.transcribe,
                icon: provider.transcribing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(provider.transcribing
                    ? 'Transcribing…'
                    : 'Convert to Sheet Music'),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (t.isSuccess ? AppColors.primary : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                t.isSuccess
                    ? 'Transcribed! Rendering will open in the viewer.'
                    : t.error ?? 'Transcription failed.',
                style: AppTypography.labelMd.copyWith(
                  color: t.isSuccess ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TransportBar extends StatelessWidget {
  const _TransportBar({required this.provider});

  final PracticeProvider provider;

  @override
  Widget build(BuildContext context) {
    final running = provider.state == PracticeState.running;
    return Center(
      child: GestureDetector(
        onTap: running ? provider.stop : provider.start,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: running
                ? null
                : const LinearGradient(colors: AppColors.brandGradient),
            color: running ? AppColors.error : null,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (running ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: 24,
              ),
            ],
          ),
          child: Icon(
            running ? Icons.stop : Icons.fiber_manual_record,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        glowColor: AppColors.error,
        child: Column(
          children: [
            const Icon(Icons.mic_off, color: AppColors.error, size: 28),
            const SizedBox(height: AppSpacing.base),
            Text('Microphone access is needed to score your practice.',
                textAlign: TextAlign.center, style: AppTypography.bodyMd),
            TextButton(
              onPressed: openAppSettings,
              child: Text('Open Settings',
                  style:
                      AppTypography.labelMd.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
