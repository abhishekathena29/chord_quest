import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/quest_app_bar.dart';
import '../../journey/ui/journey_screen.dart';
import '../../practice/ui/practice_screen.dart';
import '../../profile/provider/profile_provider.dart';
import '../../profile/ui/profile_screen.dart';
import '../../sheet_music/provider/sheet_library_provider.dart';
import '../../sheet_music/ui/sheet_library_screen.dart';
import '../../tuner/ui/tuner_screen.dart';
import '../provider/nav_provider.dart';

/// Top-level authenticated container: shared plain background, flat app bar,
/// and a flat bottom nav bar with a raised centre button that jumps straight
/// into a practice session.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [
    SheetLibraryScreen(),
    JourneyScreen(),
    TunerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<NavProvider>(
        builder: (context, nav, _) {
          return Scaffold(
            appBar: const QuestAppBar(),
            body: AppBackground(
              child: IndexedStack(index: nav.index, children: _screens),
            ),
            floatingActionButton: const _PracticeFab(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: _NavBar(nav: nav),
          );
        },
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.nav});

  final NavProvider nav;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  tab: NavTab.learn,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  nav: nav,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: NavTab.journey,
                  icon: Icons.auto_awesome_motion_outlined,
                  activeIcon: Icons.auto_awesome_motion,
                  nav: nav,
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: _NavItem(
                  tab: NavTab.tuner,
                  icon: Icons.graphic_eq,
                  activeIcon: Icons.graphic_eq,
                  nav: nav,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: NavTab.profile,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  nav: nav,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.icon,
    required this.activeIcon,
    required this.nav,
  });

  final NavTab tab;
  final IconData icon;
  final IconData activeIcon;
  final NavProvider nav;

  @override
  Widget build(BuildContext context) {
    final active = nav.tab == tab;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => nav.select(tab),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            active ? activeIcon : icon,
            size: 24,
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primary : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Raised centre action: jump straight into practicing a song.
class _PracticeFab extends StatelessWidget {
  const _PracticeFab();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickSongToPractice(context),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.brandGradient),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.fiber_manual_record,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

Future<void> _pickSongToPractice(BuildContext context) async {
  final songs = SheetLibraryProvider().songs;
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
    );
  }
}
