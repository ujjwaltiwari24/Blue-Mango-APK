import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/admin_panel_screen.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/post_repository.dart';
import '../home/utils/anonymous_identity.dart';
import '../home/widgets/anonymous_post_card.dart';
import '../home/widgets/empty_state.dart';
import '../home/widgets/loading_card.dart';
import '../inbox/inbox_screen.dart';
import '../inbox/widgets/share_link_card.dart';
import '../models/post_model.dart';
import '../services/admin_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _repository = PostRepository();
  final _firestore = FirebaseFirestore.instance;
  final _adminService = AdminService();
  late final TabController _tabController;

  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;

  Stream<List<PostModel>>? _userPostsStream;
  Stream<List<PostModel>>? _bookmarkedPostsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _currentUser = FirebaseAuth.instance.currentUser;
    _setupStreamsForUser(_currentUser?.uid);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      if (user?.uid != _currentUser?.uid) {
        setState(() {
          _currentUser = user;
          _setupStreamsForUser(user?.uid);
        });
      }
    });
  }

  void _setupStreamsForUser(String? uid) {
    if (uid != null && uid.isNotEmpty) {
      _userPostsStream = _repository.watchUserPosts(uid: uid);
      _bookmarkedPostsStream = _repository.watchBookmarkedPosts(uid: uid);
    } else {
      _userPostsStream = null;
      _bookmarkedPostsStream = null;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to log out? You will need to sign back in to interact or post.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
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
    final uid = _currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      await _repository.toggleLike(
        postId: post.id,
        uid: uid,
        isCurrentlyLiked: post.isLiked,
        isLegacyPost: post.isLegacyPost,
      );
    } catch (_) {
      _showError('Couldn\'t update like. Try again.');
    }
  }

  Future<void> _handleBookmark(PostModel post) async {
    final uid = _currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      await _repository.toggleBookmark(
        postId: post.id,
        uid: uid,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUser?.uid ?? '';

    if (uid.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: StreamBuilder<List<PostModel>>(
          stream: _userPostsStream,
          builder: (context, userPostsSnapshot) {
            if (userPostsSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading posts: ${userPostsSnapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final rawUserPosts = userPostsSnapshot.data ?? const <PostModel>[];
            final userPosts = List<PostModel>.from(rawUserPosts)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final visiblePostCount = userPosts.where((p) => !p.isHidden).length;
            final hiddenPostCount = userPosts.length - visiblePostCount;
            final likesReceived = userPosts.fold<int>(
              0,
                  (sum, p) => sum + p.likeCount,
            );
            final bool userPostsLoading =
                userPostsSnapshot.connectionState == ConnectionState.waiting;

            return StreamBuilder<List<PostModel>>(
              stream: _bookmarkedPostsStream,
              builder: (context, bookmarksSnapshot) {
                if (bookmarksSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading bookmarks: ${bookmarksSnapshot.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                final rawBookmarks = bookmarksSnapshot.data ?? const <PostModel>[];
                final bookmarks = List<PostModel>.from(rawBookmarks)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                final bookmarkCount = bookmarks.length;
                final bool bookmarksLoading =
                    bookmarksSnapshot.connectionState == ConnectionState.waiting;

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: _firestore.collection('users').doc(uid).snapshots(),
                        builder: (context, userDocSnapshot) {
                          final userData = userDocSnapshot.data?.data() ?? {};
                          final customUsername = userData['username'] as String?;
                          final usernameSlug = userData['usernameSlug'] as String?;

                          return _buildHeader(
                            context,
                            uid: uid,
                            customUsername: customUsername,
                            usernameSlug: usernameSlug,
                            postCount: visiblePostCount,
                            hiddenPostCount: hiddenPostCount,
                            likesReceived: likesReceived,
                            bookmarkCount: bookmarkCount,
                          );
                        },
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
                        emptyMessage:
                        'Everything you share anonymously will show up here.',
                      ),
                      _buildPostListFromData(
                        posts: bookmarks,
                        isLoading: bookmarksLoading,
                        isOwnerTab: false,
                        emptyIcon: Icons.bookmark_border_rounded,
                        emptyTitle: 'No bookmarks yet',
                        emptyMessage:
                        'Posts you save will appear here for easy access.',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, {
        required String uid,
        String? customUsername,
        String? usernameSlug,
        required int postCount,
        required int hiddenPostCount,
        required int likesReceived,
        required int bookmarkCount,
      }) {
    final gradient = AnonymousIdentity.gradientFor(uid);
    final fallbackAlias = AnonymousIdentity.aliasFor(uid);
    final displayName = customUsername ?? fallbackAlias;
    final handle = usernameSlug != null && usernameSlug.isNotEmpty
        ? '@$usernameSlug'
        : '@${displayName.toLowerCase().replaceAll(' ', '-')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Back',
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.mail_outline_rounded,
                    tooltip: 'Secret Inbox',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InboxScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _LogoutButton(onTap: _handleSignOut),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // User Avatar & Identity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradient),
                  boxShadow: AppColors.glow(
                    color: gradient.first,
                    opacity: 0.35,
                  ),
                ),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBackground,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : AnonymousIdentity.initialFor(uid),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: gradient.first,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryCard,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 12,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Anonymous Persona',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hiddenPostCount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility_off_rounded,
                            size: 13,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$hiddenPostCount hidden',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Statistics Cards
          Row(
            children: [
              _StatCard(label: 'Posts', value: '$postCount'),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(label: 'Likes', value: '$likesReceived'),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(label: 'Saved', value: '$bookmarkCount'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Share Link Card
          const ShareLinkCard(),

          const SizedBox(height: AppSpacing.md),

          // Secret Inbox Action Tile
          _MenuActionCard(
            icon: Icons.inbox_rounded,
            title: 'Secret Inbox',
            subtitle: 'Read and manage incoming secret messages',
            iconColor: AppColors.primaryBlue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InboxScreen()),
              );
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // Account Info Tile
          _MenuActionCard(
            icon: Icons.manage_accounts_outlined,
            title: 'Account Info',
            subtitle: 'Manage email and custom username',
            iconColor: Colors.purpleAccent,
            onTap: () {
              Navigator.of(context).pushNamed('/account-info');
            },
          ),

          // 🔥 DYNAMIC FIRESTORE ADMIN PANEL ACCESS 🔥
          FutureBuilder<Map<String, dynamic>?>(
            future: _adminService.getAdminData(_currentUser?.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                return const SizedBox.shrink();
              }

              final adminData = snapshot.data!;
              final role =
              (adminData['role'] ?? 'Admin').toString().toUpperCase();

              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.12),
                        Colors.purple.withOpacity(0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.35),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminPanelScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: AppColors.primaryBlue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Admin Dashboard',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          role,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'System management & user moderation',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),
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
          EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            message: emptyMessage,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xxl,
      ),
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

class _MenuActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.primaryBlue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.cardBackground,
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

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                'Logout',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SegmentedTabBarDelegate(this.controller);

  final TabController controller;

  @override
  double get minExtent => 52.0;

  @override
  double get maxExtent => 52.0;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox(
      height: 52.0,
      child: Container(
        color: AppColors.primaryBackground,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
            splashBorderRadius: BorderRadius.circular(AppRadius.pill),
            tabs: const [
              Tab(text: 'My Posts'),
              Tab(text: 'Bookmarks'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SegmentedTabBarDelegate oldDelegate) {
    return oldDelegate.controller != controller;
  }
}