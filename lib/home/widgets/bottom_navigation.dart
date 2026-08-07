import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

enum HomeTab { home, explore, create, notifications, profile }

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final HomeTab currentTab;
  final ValueChanged<HomeTab> onTabSelected;

  static const _tabs = [
    (tab: HomeTab.home, icon: Icons.home_rounded, outline: Icons.home_outlined),
    (tab: HomeTab.explore, icon: Icons.explore_rounded, outline: Icons.explore_outlined),
    (tab: HomeTab.create, icon: Icons.add_rounded, outline: Icons.add_rounded),
    (tab: HomeTab.notifications, icon: Icons.notifications_rounded, outline: Icons.notifications_outlined),
    (tab: HomeTab.profile, icon: Icons.person_rounded, outline: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider, width: 0.7),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _tabs.map((entry) {
          // The center "Create" slot stays visually empty here — the
          // real button is the FloatingCreateButton layered above it
          // in HomeScreen, docked into this notch.
          if (entry.tab == HomeTab.create) {
            return const SizedBox(width: 60);
          }
          final bool selected = entry.tab == currentTab;
          return _NavItem(
            icon: selected ? entry.icon : entry.outline,
            selected: selected,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabSelected(entry.tab);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.selected, required this.onTap});

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 24,
          color: selected ? AppColors.primaryBlue : AppColors.muted,
        ),
      ),
    );
  }
}