import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import 'anonymous_post_card.dart';
import 'empty_state.dart';
import 'loading_card.dart';

class HomeFeed extends StatelessWidget {
  const HomeFeed({
    super.key,
    required this.posts,
    required this.isLoading,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
    required this.onShare,
    required this.onCreatePost,
  });

  final List<PostModel> posts;
  final bool isLoading;
  final ValueChanged<PostModel> onLike;
  final ValueChanged<PostModel> onBookmark;
  final ValueChanged<PostModel> onComment;
  final ValueChanged<PostModel> onShare;
  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SliverList.builder(
        itemCount: 4,
        itemBuilder: (context, index) => const LoadingCard(),
      );
    }

    if (posts.isEmpty) {
      return SliverToBoxAdapter(child: EmptyState(onCreatePost: onCreatePost));
    }

    return SliverList.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return AnonymousPostCard(
          key: ValueKey(post.id),
          post: post,
          onLike: () => onLike(post),
          onBookmark: () => onBookmark(post),
          onComment: () => onComment(post),
          onShare: () => onShare(post),
        );
      },
    );
  }
}