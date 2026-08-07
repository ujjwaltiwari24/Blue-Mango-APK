import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.onCreatePost,
    this.icon = Icons.chat_bubble_outline_rounded,
    this.title = 'It\'s quiet here',
    this.message = 'Be the first to share something honest.\nNo names. No judgment.',
    this.ctaLabel = 'Share your first post',
  });

  final VoidCallback? onCreatePost;
  final IconData icon;
  final String title;
  final String message;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppColors.glow(),
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onCreatePost != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _AnimatedCta(label: ctaLabel, onTap: onCreatePost!),
          ],
        ],
      ),
    );
  }
}

class _AnimatedCta extends StatefulWidget {
  const _AnimatedCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_AnimatedCta> createState() => _AnimatedCtaState();
}

class _AnimatedCtaState extends State<_AnimatedCta> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppColors.glow(opacity: 0.3),
          ),
          child: Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}