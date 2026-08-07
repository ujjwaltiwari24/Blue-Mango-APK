import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/post_repository.dart';
import '../home/utils/anonymous_identity.dart';
import '../home/widgets/anonymous_post_card.dart';
import '../home/widgets/empty_state.dart';
import '../home/widgets/loading_card.dart';
import '../models/post_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _repository = PostRepository();
  late final TabController _tabController = TabController(length: 2, vsync: this);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  late final Stream<List<PostModel>> _userPostsStream =
  _repository.watchUserPosts(uid: _uid);
  late final Stream<List<PostModel>> _bookmarkedPostsStream =
  _repository.watchBookmarkedPosts(uid: _uid);

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Sign out?'),
        content: const Text('You\'ll need to sign back in to post, like, or bookmark.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _handleLike(PostModel post) async {
    try {
      await _repository.toggleLike(
        postId: post.id,
        uid: _uid,
        isCurrentlyLiked: post.isLiked,
        isLegacyPost: post.isLegacyPost,
      );
    } catch (_) {
      _showError('Couldn\'t update like. Try again.');
    }
  }

  Future<void> _handleBookmark(PostModel post) async {
    try {
      await _repository.toggleBookmark(
        postId: post.id,
        uid: _uid,
        isCurrentlyBookmarked: post.isBookmarked,
      );
    } catch (_) {
      _showError('Couldn\'t update bookmark. Try again.');
    }
  }

  void _handleEdit(PostModel post) {
    Navigator.of(context).pushNamed('/edit-post', arguments: post);
  }

  Future<void> _handleToggleHide(PostModel post) async {
    try {
      await _repository.setHidden(postId: post.id, hidden: !post.isHidden);
    } catch (_) {
      _showError('Couldn\'t update visibility. Try again.');
    }
  }

  Future<void> _handleDelete(PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Delete this post?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.deletePost(post.id);
    } catch (_) {
      _showError('Couldn\'t delete post. Try again.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: StreamBuilder<List<PostModel>>(
          stream: _userPostsStream,
          builder: (context, userPostsSnapshot) {
            final userPosts = userPostsSnapshot.data ?? const <PostModel>[];
            final visiblePostCount = userPosts.where((p) => !p.isHidden).length;
            final hiddenPostCount = userPosts.length - visiblePostCount;
            final likesReceived = userPosts.fold<int>(0, (sum, p) => sum + p.likeCount);
            final bool userPostsLoading =
                userPostsSnapshot.connectionState == ConnectionState.waiting;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    context,
                    postCount: visiblePostCount,
                    hiddenPostCount: hiddenPostCount,
                    likesReceived: likesReceived,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SegmentedTabBarDelegate(_tabController),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostListFromData(
                    posts: userPosts,
                    isLoading: userPostsLoading,
                    isOwnerTab: true,
                    emptyIcon: Icons.edit_note_rounded,
                    emptyTitle: 'No posts yet',
                    emptyMessage: 'Everything you share, anonymously,\nwill show up here.',
                  ),
                  StreamBuilder<List<PostModel>>(
                    stream: _bookmarkedPostsStream,
                    builder: (context, bookmarksSnapshot) {
                      return _buildPostListFromData(
                        posts: bookmarksSnapshot.data ?? const <PostModel>[],
                        isLoading: bookmarksSnapshot.connectionState == ConnectionState.waiting,
                        isOwnerTab: false,
                        emptyIcon: Icons.bookmark_border_rounded,
                        emptyTitle: 'No bookmarks yet',
                        emptyMessage: 'Save posts you want to\nfind again later.',
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, {
        required int postCount,
        required int hiddenPostCount,
        required int likesReceived,
      }) {
    final gradient = AnonymousIdentity.gradientFor(_uid);
    final alias = AnonymousIdentity.aliasFor(_uid);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Profile', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              _CircleIconButton(icon: Icons.logout_rounded, onTap: _handleSignOut),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradient),
                  boxShadow: AppColors.glow(color: gradient.first, opacity: 0.3),
                ),
                alignment: Alignment.center,
                child: Text(
                  AnonymousIdentity.initialFor(_uid),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alias, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text('Anonymous identity', style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    if (hiddenPostCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.visibility_off_rounded, size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            '$hiddenPostCount hidden ${hiddenPostCount == 1 ? 'post' : 'posts'}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatCard(label: 'Posts', value: '$postCount'),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(label: 'Likes received', value: '$likesReceived'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostListFromData({
    required List<PostModel> posts,
    required bool isLoading,
    required bool isOwnerTab,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        itemCount: 3,
        itemBuilder: (context, index) => const LoadingCard(),
      );
    }

    if (posts.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          EmptyState(icon: emptyIcon, title: emptyTitle, message: emptyMessage),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxl),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return AnonymousPostCard(
          key: ValueKey(post.id),
          post: post,
          onLike: () => _handleLike(post),
          onBookmark: () => _handleBookmark(post),
          onComment: () {},
          onShare: () {},
          isOwner: isOwnerTab,
          onEdit: isOwnerTab ? () => _handleEdit(post) : null,
          onToggleHide: isOwnerTab ? () => _handleToggleHide(post) : null,
          onDelete: isOwnerTab ? () => _handleDelete(post) : null,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider, width: 0.7),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryCard,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// Pinned, pill-style segmented tab bar — a more premium alternative
/// to the default underline TabBar, matching the app's rounded,
/// gradient-accented design language.
class _SegmentedTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SegmentedTabBarDelegate(this.controller);

  final TabController controller;

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.secondaryCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.muted,
          labelStyle: Theme.of(context).textTheme.labelLarge,
          unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
          splashBorderRadius: BorderRadius.circular(AppRadius.pill),
          tabs: const [
            Tab(text: 'My Posts'),
            Tab(text: 'Bookmarks'),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SegmentedTabBarDelegate oldDelegate) => false;
}