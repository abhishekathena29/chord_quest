import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mesh_background.dart';
import '../../../core/widgets/quest_app_bar.dart';
import '../../journey/ui/journey_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../../sheet_music/ui/sheet_library_screen.dart';
import '../provider/nav_provider.dart';

/// Top-level authenticated container: shared mesh background, frosted app bar,
/// and a glass bottom navigation bar switching between Learn / Journey / Profile.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [
    SheetLibraryScreen(),
    JourneyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavProvider(),
      child: Consumer<NavProvider>(
        builder: (context, nav, _) {
          return Scaffold(
            extendBody: true,
            appBar: const QuestAppBar(),
            body: MeshBackground(
              child: IndexedStack(
                index: nav.index,
                children: _screens,
              ),
            ),
            bottomNavigationBar: _GlassNavBar(nav: nav),
          );
        },
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({required this.nav});

  final NavProvider nav;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    tab: NavTab.learn,
                    icon: Icons.menu_book,
                    label: 'Learn',
                    nav: nav,
                  ),
                  _NavItem(
                    tab: NavTab.journey,
                    icon: Icons.auto_awesome_motion,
                    label: 'Journey',
                    nav: nav,
                  ),
                  _NavItem(
                    tab: NavTab.profile,
                    icon: Icons.person,
                    label: 'Profile',
                    nav: nav,
                  ),
                ],
              ),
            ),
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
    required this.label,
    required this.nav,
  });

  final NavTab tab;
  final IconData icon;
  final String label;
  final NavProvider nav;

  @override
  Widget build(BuildContext context) {
    final active = nav.tab == tab;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => nav.select(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 20 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: AppColors.brandGradient)
              : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelMd.copyWith(color: AppColors.onPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
