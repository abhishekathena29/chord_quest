import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../profile/provider/profile_provider.dart';
import '../../shell/provider/nav_provider.dart';
import '../provider/sheet_library_provider.dart';
import 'sheet_viewer_screen.dart';

/// The Home / Learn tab: a greeting dashboard with a quick-practice nudge, a
/// carousel of songs to try next, and the full filterable library below.
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
    final profile = context.watch<ProfileProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        _HomeHeader(name: profile.name),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'KEEP LEARNING',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Pick up where you left off', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        _SongCarousel(songs: p.songs),
        const SizedBox(height: AppSpacing.lg),
        Text('All Songs', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        _FilterRow(provider: p),
        const SizedBox(height: AppSpacing.md),
        for (final song in p.songs)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SongRow(song: song),
          ),
      ],
    );
  }
}

/// The dark greeting block: name + notification icon on top, a nested
/// darker pill nudging the player toward today's practice underneath.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final firstName = name.split(' ').first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hello, $firstName 👋',
                  style: AppTypography.headlineMd.copyWith(color: Colors.white),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => context.read<NavProvider>().select(NavTab.journey),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.onSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.base),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Do you want to practice today?',
                      style: AppTypography.labelMd.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongCarousel extends StatelessWidget {
  const _SongCarousel({required this.songs});

  final List<SheetSong> songs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => _SongCarouselCard(song: songs[i]),
      ),
    );
  }
}

class _SongCarouselCard extends StatelessWidget {
  const _SongCarouselCard({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SheetViewerScreen(song: song)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Icon(
                song.icon,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          _chip(
            context,
            'All',
            provider.filter == null,
            () => provider.setFilter(null),
          ),
          for (final d in provider.difficulties)
            _chip(
              context,
              d.label,
              provider.filter == d,
              () => provider.setFilter(d),
              color: d.color,
            ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool active,
    VoidCallback onTap, {
    Color? color,
  }) {
    final c = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.base),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: active ? c : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
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

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song});

  final SheetSong song;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SheetViewerScreen(song: song))),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: song.difficulty.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(song.icon, color: song.difficulty.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 16,
                  ),
                ),
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
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
