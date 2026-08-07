import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../utils/anonymous_identity.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.uid,
    required this.onSignOut,
  });

  final String uid;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final gradient = AnonymousIdentity.gradientFor(uid);
    final alias = AnonymousIdentity.aliasFor(uid);

    return Drawer(
      backgroundColor: AppColors.primaryBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profile Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: gradient),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.cardBackground,
                      child: Text(
                        AnonymousIdentity.initialFor(uid),
                        style: TextStyle(
                          color: gradient.first,
                          fontWeight: FontWeight.bold,
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
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Anonymous Persona',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Menu Items
            _DrawerTile(
              icon: Icons.home_rounded,
              title: 'Home Feed',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            _DrawerTile(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            _DrawerTile(
              icon: Icons.bookmark_border_rounded,
              title: 'Bookmarks',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/settings');
              },
            ),

            const Spacer(),
            const Divider(color: AppColors.divider, height: 1),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: _DrawerTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                textColor: AppColors.error,
                iconColor: AppColors.error,
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
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textPrimary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 2,
      ),
      onTap: onTap,
    );
  }
}