import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../provider/sheet_library_provider.dart';
import 'sheet_viewer_screen.dart';

/// The "Learn" tab: a browsable library of sheet music to practice.
class SheetLibraryScreen extends StatelessWidget {
  const SheetLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SheetLibraryProvider(),
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SheetLibraryProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        120,
      ),
      children: [
        Text('SHEET MUSIC',
            style: AppTypography.labelSm
                .copyWith(color: AppColors.primary, letterSpacing: 2)),
        const SizedBox(height: AppSpacing.xs),
        Text('Practice Library', style: AppTypography.headlineLgMobile),
        const SizedBox(height: AppSpacing.md),
        _FilterRow(provider: p),
        const SizedBox(height: AppSpacing.md),
        for (final song in p.songs)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SongCard(song: song),
          ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.provider});

  final SheetLibraryProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(context, 'All', provider.filter == null,
              () => provider.setFilter(null)),
          for (final d in provider.difficulties)
            _chip(context, d.label, provider.filter == d,
                () => provider.setFilter(d),
                color: d.color),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool active,
      VoidCallback onTap,
      {Color? color}) {
    final c = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.base),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: active ? c : AppColors.surfaceContainerLowest
                .withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
                color: active ? Colors.transparent : AppColors.outlineVariant),
          ),
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: active ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SheetViewerScreen(song: song)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  song.difficulty.color.withValues(alpha: 0.8),
                  AppColors.secondary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(song.icon, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    style: AppTypography.labelMd
                        .copyWith(color: AppColors.onSurface, fontSize: 16)),
                Text(song.subtitle, style: AppTypography.labelSm),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _tag(song.difficulty.label, song.difficulty.color),
                    const SizedBox(width: 6),
                    _tag('${song.tempo} BPM', AppColors.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(text,
          style: AppTypography.labelSm.copyWith(color: color, fontSize: 10)),
    );
  }
}
