import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../utils/anonymous_identity.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.uid,
    required this.onSignOut,
    this.currentRoute = '/home',
  });

  final String uid;
  final VoidCallback onSignOut;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final gradient = AnonymousIdentity.gradientFor(uid);
    final alias = AnonymousIdentity.aliasFor(uid);

    return Drawer(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profile Banner
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar with Persona Gradient Border
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: 0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryBackground,
                        child: Text(
                          AnonymousIdentity.initialFor(uid),
                          style: TextStyle(
                            color: gradient.first,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alias,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: gradient.first,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradient.first.withValues(alpha: 0.6),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Anonymous Persona',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Divider(color: AppColors.divider, height: 1),
            ),
            const SizedBox(height: AppSpacing.md),

            // Navigation Menu List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _DrawerTile(
                      icon: Icons.home_rounded,
                      title: 'Home Feed',
                      isSelected: currentRoute == '/home',
                      onTap: () {
                        Navigator.pop(context);
                        if (currentRoute != '/home') {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      isSelected: currentRoute == '/profile',
                      onTap: () {
                        Navigator.pop(context);
                        if (currentRoute != '/profile') {
                          Navigator.of(context).pushNamed('/profile');
                        }
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.bookmark_border_rounded,
                      title: 'Bookmarks',
                      isSelected: currentRoute == '/bookmarks',
                      onTap: () {
                        Navigator.pop(context);
                        if (currentRoute != '/bookmarks') {
                          Navigator.of(context).pushNamed('/bookmarks');
                        }
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      isSelected: currentRoute == '/settings',
                      onTap: () {
                        Navigator.pop(context);
                        if (currentRoute != '/settings') {
                          Navigator.of(context).pushNamed('/settings');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Divider(color: AppColors.divider, height: 1),
            ),

            // Destructive Action: Logout
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _DrawerTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  onSignOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDestructive
        ? AppColors.error
        : (isSelected ? AppColors.primaryBlue : AppColors.textPrimary);

    final tileBackground = isSelected
        ? AppColors.primaryBlue.withValues(alpha: 0.12)
        : (isDestructive ? AppColors.error.withValues(alpha: 0.08) : Colors.transparent);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: activeColor.withValues(alpha: 0.1),
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: tileBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isSelected
                  ? Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                width: 1,
              )
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: activeColor,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!isDestructive)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}