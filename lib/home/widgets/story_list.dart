import 'package:flutter/material.dart';

import '../../models/story_model.dart';
import '../../core/theme/app_theme.dart';import 'story_bubble.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key, required this.stories, required this.onStoryTap});

  final List<StoryModel> stories;
  final ValueChanged<StoryModel> onStoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final story = stories[index];
          return RepaintBoundary(
            child: StoryBubble(story: story, onTap: () => onStoryTap(story)),
          );
        },
      ),
    );
  }
}