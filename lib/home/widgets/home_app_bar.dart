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
    this.hasUnreadNotifications = false,
  });

  final String currentUserSeed;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final bool hasUnreadNotifications;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final gradient = AnonymousIdentity.gradientFor(currentUserSeed);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground.withValues(alpha: 0.72),
            border: const Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.6),
            ),
          ),
          child: Row(
            children: [
              _buildLogoAndGreeting(context),
              const Spacer(),
              _CircleIconButton(
                icon: Icons.search_rounded,
                onTap: onSearchTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CircleIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationsTap,
                showDot: hasUnreadNotifications,
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradient),
                    boxShadow: AppColors.glow(color: gradient.first, opacity: 0.3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AnonymousIdentity.initialFor(currentUserSeed),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndGreeting(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.blur_on_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BlueMango', style: Theme.of(context).textTheme.titleMedium),
            Text(
              'Say it. Stay anonymous.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryCard,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              if (showDot)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}