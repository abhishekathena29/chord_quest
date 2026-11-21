import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../sheet_music/provider/sheet_library_provider.dart';
import 'practice_screen.dart';

/// Opens a bottom sheet listing every song and, once one is picked, pushes a
/// [PracticeScreen] for it. Shared by the centre nav button, the home
/// "practice today" nudge and the active journey node.
Future<void> pickSongToPractice(BuildContext context) async {
  final songs = SheetLibraryProvider().allSongs;
  final song = await showModalBottomSheet<SheetSong>(
    context: context,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) => _SongPickerSheet(songs: songs),
  );
  if (song != null && context.mounted) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PracticeScreen(song: song)));
  }
}

class _SongPickerSheet extends StatelessWidget {
  const _SongPickerSheet({required this.songs});

  final List<SheetSong> songs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const Text(
              'Practice a song',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Scrolls when the list is taller than the sheet (small phones,
            // or as the library grows).
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final song in songs)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: song.difficulty.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.base),
                        ),
                        child: Icon(song.icon, color: song.difficulty.color),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.subtitle),
                      trailing: const Icon(
                        Icons.fiber_manual_record,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      onTap: () => Navigator.of(context).pop(song),
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
