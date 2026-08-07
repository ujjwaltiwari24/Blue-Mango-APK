import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../utils/anonymous_identity.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.currentUserSeed,
    required this.onSearchTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    this.onMenuTap,
    this.hasUnreadNotifications = false,
  });

  final String currentUserSeed;
  final VoidCallback? onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final bool hasUnreadNotifications;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final gradient = AnonymousIdentity.gradientFor(currentUserSeed);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryBackground.withValues(alpha: 0.75),
            border: const Border(
              bottom: BorderSide(
                color: AppColors.divider,
                width: 0.6,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                height: kToolbarHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onMenuTap != null) ...[
                      _CircleIconButton(
                        icon: Icons.menu_rounded,
                        onTap: onMenuTap!,
                        tooltip: 'Open menu',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    _buildGreeting(context),
                    const Spacer(),
                    _CircleIconButton(
                      icon: Icons.search_rounded,
                      onTap: onSearchTap,
                      tooltip: 'Search',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _CircleIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: onNotificationsTap,
                      showDot: hasUnreadNotifications,
                      tooltip: 'Notifications',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildProfileAvatar(context, gradient),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'BlueMango',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'Say it. Stay anonymous.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context, List<Color> gradient) {
    return Tooltip(
      message: 'Profile',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onProfileTap,
          splashColor: gradient.first.withOpacity(0.2),
          child: Container(
            height: 36,
            width: 36,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: gradient.first.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppColors.glow(
                  color: gradient.first,
                  opacity: 0.3,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                AnonymousIdentity.initialFor(currentUserSeed),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.secondaryCard.withOpacity(0.8),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: AppColors.primaryBlue.withOpacity(0.15),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.textPrimary,
                size: 19,
              ),
              if (showDot)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBackground,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}