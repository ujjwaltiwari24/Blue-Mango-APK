import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/post_repository.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/floating_create_button.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_feed.dart';
import 'widgets/story_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = PostRepository();

  HomeTab _currentTab = HomeTab.home;
  String? _uid;
  bool _authReady = false;

  /// Stories remain local/mock for now — wiring them to Firestore is
  /// a separate pass (they need expiry/view-tracking semantics that
  /// don't belong bolted onto the post repository).
  final List<StoryModel> _stories = const [];

  @override
  void initState() {
    super.initState();
    _ensureAuthenticated();
  }

  Future<void> _ensureAuthenticated() async {
    var user = FirebaseAuth.instance.currentUser;
    user ??= (await FirebaseAuth.instance.signInAnonymously()).user;
    if (!mounted) return;
    setState(() {
      _uid = user!.uid;
      _authReady = true;
    });
  }

  Future<void> _handleLike(PostModel post) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _repository.toggleLike(
        postId: post.id,
        uid: uid,
        isCurrentlyLiked: post.isLiked,
        isLegacyPost: post.isLegacyPost,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t update like. Try again.')),
      );
    }
  }

  Future<void> _handleBookmark(PostModel post) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _repository.toggleBookmark(
        postId: post.id,
        uid: uid,
        isCurrentlyBookmarked: post.isBookmarked,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t update bookmark. Try again.')),
      );
    }
  }

  void _handleComment(PostModel post) {
    // TODO(comments-phase): Open comment sheet.
  }

  void _handleShare(PostModel post) {
    // TODO(share-phase): Open native share sheet.
  }

  void _openCreatePost() {
    Navigator.of(context).pushNamed('/create-post');
  }

  Future<void> _openSearch() async {
    // TODO(search-phase): Navigate to Search screen.
    // No push yet — resetting immediately so the nav doesn't
    // stay stuck highlighting a tab with nothing behind it.
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  Future<void> _openNotifications() async {
    // TODO(notifications-phase): Navigate to Notifications screen.
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed('/profile');
    // Returned from Profile — go back to highlighting Home instead
    // of leaving the nav bar showing Profile as active while the
    // feed is what's actually on screen.
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  void _handleTabSelected(HomeTab tab) {
    switch (tab) {
      case HomeTab.home:
        setState(() => _currentTab = tab);
        break;
      case HomeTab.explore:
        setState(() => _currentTab = tab);
        _openSearch();
        break;
      case HomeTab.notifications:
        setState(() => _currentTab = tab);
        _openNotifications();
        break;
      case HomeTab.profile:
        setState(() => _currentTab = tab);
        _openProfile();
        break;
      case HomeTab.create:
        _openCreatePost();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady || _uid == null) {
      return const Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      extendBody: true,
      appBar: HomeAppBar(
        currentUserSeed: _uid!,
        hasUnreadNotifications: true,
        onSearchTap: _openSearch,
        onNotificationsTap: _openNotifications,
        onProfileTap: _openProfile,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _repository.watchFeed(currentUid: _uid!),
        builder: (context, snapshot) {
          final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
          final posts = snapshot.data ?? const <PostModel>[];

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            backgroundColor: AppColors.cardBackground,
            // The feed is a live snapshot listener, so it's already
            // current — this just gives the pull gesture a brief,
            // expected visual response rather than doing nothing.
            onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 400)),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: StoryList(
                      stories: _stories,
                      onStoryTap: (story) {},
                    ),
                  ),
                ),
                HomeFeed(
                  posts: posts,
                  isLoading: isLoading,
                  onLike: _handleLike,
                  onBookmark: _handleBookmark,
                  onComment: _handleComment,
                  onShare: _handleShare,
                  onCreatePost: _openCreatePost,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 84,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            BottomNavigation(
              currentTab: _currentTab,
              onTabSelected: _handleTabSelected,
            ),
            Positioned(
              bottom: 28,
              child: FloatingCreateButton(onTap: _openCreatePost),
            ),
          ],
        ),
      ),
    );
  }
}