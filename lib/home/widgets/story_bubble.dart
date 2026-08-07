import 'package:flutter/material.dart';

import '../../models/story_model.dart';
import '../../core/theme/app_theme.dart';
import '../utils/anonymous_identity.dart';

class StoryBubble extends StatefulWidget {
  const StoryBubble({super.key, required this.story, required this.onTap});

  final StoryModel story;
  final VoidCallback onTap;

  @override
  State<StoryBubble> createState() => _StoryBubbleState();
}

class _StoryBubbleState extends State<StoryBubble> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final gradientColors = AnonymousIdentity.gradientFor(widget.story.seed);
    final alias = widget.story.isOwn ? 'Your Story' : AnonymousIdentity.aliasFor(widget.story.seed);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                height: 66,
                width: 66,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.story.viewed
                      ? null
                      : LinearGradient(colors: gradientColors),
                  color: widget.story.viewed ? AppColors.divider : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBackground,
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.secondaryCard,
                    child: widget.story.isOwn
                        ? const Icon(Icons.add_rounded, color: AppColors.primaryBlue)
                        : Text(
                      AnonymousIdentity.initialFor(widget.story.seed),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                alias,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}