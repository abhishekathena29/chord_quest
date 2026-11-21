import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/session/user_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/quest_app_bar.dart';
import '../../journey/ui/journey_screen.dart';
import '../../practice/ui/song_picker.dart';
import '../../profile/ui/profile_screen.dart';
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
    final profile = context.watch<UserSession>().profile;
    return ChangeNotifierProvider(
      create: (_) => NavProvider(),
      child: Consumer<NavProvider>(
        builder: (context, nav, _) {
          return Scaffold(
            appBar: QuestAppBar(
              xp: profile?.xp ?? 0,
              streak: profile?.currentStreak() ?? 0,
            ),
            body: AppBackground(
              child: IndexedStack(
                index: nav.index,
                children: [
                  // Hidden tabs get TickerMode off, which is how the tuner
                  // knows to release the microphone.
                  for (var i = 0; i < _screens.length; i++)
                    TickerMode(enabled: i == nav.index, child: _screens[i]),
                ],
              ),
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
      onTap: () => pickSongToPractice(context),
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
