import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
/// Shimmer skeleton mirroring AnonymousPostCard's layout, shown
/// while the feed is loading. Implemented without a shimmer
/// package to keep the dependency footprint minimal.
class LoadingCard extends StatefulWidget {
  const LoadingCard({super.key});

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider, width: 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBlock(height: 40, width: 40, radius: 20),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBlock(height: 12, width: 110, radius: 6),
                    const SizedBox(height: 6),
                    _shimmerBlock(height: 10, width: 70, radius: 6),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _shimmerBlock(height: 12, width: double.infinity, radius: 6),
            const SizedBox(height: 6),
            _shimmerBlock(height: 12, width: 220, radius: 6),
            const SizedBox(height: AppSpacing.md),
            _shimmerBlock(height: 140, width: double.infinity, radius: AppRadius.md),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBlock({required double height, required double width, required double radius}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 3, 0),
              end: Alignment(0 + t * 3, 0),
              colors: const [
                AppColors.secondaryCard,
                AppColors.divider,
                AppColors.secondaryCard,
              ],
            ),
          ),
        );
      },
    );
  }
}