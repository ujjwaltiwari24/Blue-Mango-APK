import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/post_repository.dart';
import '../home/widgets/app_drawer.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = PostRepository();

  HomeTab _currentTab = HomeTab.home;
  String? _uid;
  bool _authReady = false;

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
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  Future<void> _openNotifications() async {
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed('/profile');
    if (!mounted) return;
    setState(() => _currentTab = HomeTab.home);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
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
        child: HomeAppBar(
          currentUserSeed: _uid!,
          hasUnreadNotifications: true,
          onMenuTap: _openDrawer,
          onSearchTap: _openSearch,
          onNotificationsTap: _openNotifications,
          onProfileTap: _openProfile,
        ),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _repository.watchFeed(currentUid: _uid!),
        builder: (context, snapshot) {
          final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
          final posts = snapshot.data ?? const <PostModel>[];

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            backgroundColor: AppColors.cardBackground,
            onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 400)),
            child: CustomScrollView(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingCreateButton(onTap: _openCreatePost),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _handleTabSelected,
      ),
    );
  }
}