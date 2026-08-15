import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/post_repository.dart';
import '../home/widgets/app_drawer.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/feed_error_state.dart';
import 'widgets/floating_create_button.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_feed.dart';
import 'widgets/new_posts_pill.dart';
import 'widgets/story_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = PostRepository();
  final ScrollController _scrollController = ScrollController();

  HomeTab _currentTab = HomeTab.home;
  String? _uid;
  bool _authReady = false;

  /// Memoized once _uid is known — created here, not inline in build(),
  /// so unrelated setState calls elsewhere on this screen don't spin up
  /// a brand new stream subscription and flash the feed back to loading.
  Stream<List<PostModel>>? _feedStream;

  final List<StoryModel> _stories = const [];

  bool _showAppBarDivider = false;
  bool _hasNewPosts = false;
  String? _topPostId;
  List<PostModel> _latestPosts = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _ensureAuthenticated();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureAuthenticated() async {
    var user = FirebaseAuth.instance.currentUser;
    user ??= (await FirebaseAuth.instance.signInAnonymously()).user;
    if (!mounted) return;
    setState(() {
      _uid = user!.uid;
      _authReady = true;
      _feedStream = _repository.watchFeed(currentUid: user.uid);
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final double offset = _scrollController.offset;

    final bool elevated = offset > 4;
    if (elevated != _showAppBarDivider) {
      setState(() => _showAppBarDivider = elevated);
    }

    // If the user scrolls back to the top themselves, treat that as
    // having "seen" the latest posts — clear the pill without waiting
    // for them to tap it.
    if (_hasNewPosts && offset <= 40) {
      setState(() {
        _hasNewPosts = false;
        if (_latestPosts.isNotEmpty) _topPostId = _latestPosts.first.id;
      });
    }
  }

  /// Called (via post-frame callback) whenever the feed stream emits.
  /// Tracks whether new posts have landed above what the user has
  /// already scrolled past, and surfaces the NewPostsPill if so.
  void _onFeedUpdated(List<PostModel> posts) {
    if (posts.isEmpty) return;
    _latestPosts = posts;

    final String latestId = posts.first.id;
    _topPostId ??= latestId;
    if (latestId == _topPostId) return;

    final bool isScrolledDown = _scrollController.hasClients && _scrollController.offset > 160;
    if (isScrolledDown) {
      if (!_hasNewPosts && mounted) {
        setState(() => _hasNewPosts = true);
      }
    } else {
      _topPostId = latestId;
    }
  }

  Future<void> _handleNewPostsTap() async {
    HapticFeedback.selectionClick();
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    setState(() {
      _hasNewPosts = false;
      if (_latestPosts.isNotEmpty) _topPostId = _latestPosts.first.id;
    });
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to log out? You will need to sign back in to interact or post.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
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
    final uid = _uid;
    if (uid == null) return;
    HapticFeedback.lightImpact();
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
    HapticFeedback.lightImpact();
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
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushNamed('/create-post');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          content: Text(
            '$feature is coming soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      );
  }

  void _openSearch() => _showComingSoon('Search');

  void _openNotifications() => _showComingSoon('Notifications');

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed('/profile');
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  void _openDrawer() {
    HapticFeedback.selectionClick();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleTabSelected(HomeTab tab) {
    switch (tab) {
      case HomeTab.home:
      // Tapping Home while already on Home scrolls to top instead of
      // doing nothing — the standard double-tap-home affordance.
        if (_currentTab == HomeTab.home) {
          _scrollToTop();
        } else {
          setState(() => _currentTab = tab);
        }
        break;
      case HomeTab.explore:
        _openSearch();
        break;
      case HomeTab.notifications:
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

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady || _uid == null || _feedStream == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppColors.glow(opacity: 0.3),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primaryBackground,
      drawer: AppDrawer(
        uid: _uid!,
        onSignOut: _handleSignOut,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _showAppBarDivider ? AppColors.divider : Colors.transparent,
                width: 0.7,
              ),
            ),
          ),
          child: HomeAppBar(
            currentUserSeed: _uid!,
            hasUnreadNotifications: true,
            onMenuTap: _openDrawer,
            onSearchTap: _openSearch,
            onNotificationsTap: _openNotifications,
            onProfileTap: _openProfile,
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<PostModel>>(
            stream: _feedStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return FeedErrorState(
                  onRetry: () => setState(() {
                    _feedStream = _repository.watchFeed(currentUid: _uid!);
                  }),
                );
              }

              final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
              final posts = snapshot.data ?? const <PostModel>[];

              if (!isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _onFeedUpdated(posts);
                });
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                backgroundColor: AppColors.cardBackground,
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    if (_stories.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        sliver: SliverToBoxAdapter(
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
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: kBottomNavigationBarHeight + bottomPadding + AppSpacing.lg,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: AppSpacing.sm,
            left: 0,
            right: 0,
            child: NewPostsPill(
              visible: _hasNewPosts,
              onTap: _handleNewPostsTap,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingCreateButton(onTap: _openCreatePost),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _handleTabSelected,
      ),
    );
  }
}