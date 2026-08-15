// lib/home/widgets/anonymous_post_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/post_model.dart';
import '../utils/anonymous_identity.dart';
import 'post_options_sheet.dart';

class AnonymousPostCard extends StatefulWidget {
  const AnonymousPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
    required this.onShare,
    this.currentUid,
    this.onCommentCountChanged,
    this.isOwner = false,
    this.onEdit,
    this.onToggleHide,
    this.onDelete,
  });

  final PostModel post;
  final String? currentUid;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onComment;
  final VoidCallback onShare;

  /// Optional callback to notify parent feeds when commentCount updates
  final ValueChanged<int>? onCommentCountChanged;

  /// When true, shows the owner action menu (Edit/Hide/Delete) behind
  /// the "···" icon. Callers must only pass true for posts the
  /// current user actually owns.
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleHide;
  final VoidCallback? onDelete;

  @override
  State<AnonymousPostCard> createState() => _AnonymousPostCardState();
}

class _AnonymousPostCardState extends State<AnonymousPostCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _likeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.85,
    upperBound: 1.0,
  )..value = 1.0;

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    _likeController.forward(from: 0.85);
    widget.onLike();
  }

  void _handleOptionsTap() {
    if (!widget.isOwner) return;
    showPostOptionsSheet(
      context,
      isHidden: widget.post.isHidden,
      onEdit: widget.onEdit ?? () {},
      onToggleHide: widget.onToggleHide ?? () {},
      onDelete: widget.onDelete ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final gradient = AnonymousIdentity.gradientFor(post.seed);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(
                alpha: post.isHidden ? 0.55 : 0.82,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: post.isHidden
                    ? AppColors.muted.withValues(alpha: 0.4)
                    : AppColors.divider,
                width: post.isHidden ? 1 : 0.7,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.isHidden) ...[
                  _buildHiddenBadge(context),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _buildHeader(context, gradient),
                const SizedBox(height: AppSpacing.md),
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildImage(post.imageUrls.first),
                ],
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildTags(context),
                ],
                const SizedBox(height: AppSpacing.md),
                _buildActionRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenBadge(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.muted.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.muted.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_off_rounded,
                size: 12,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                'Only visible to you',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<Color> gradient) {
    final post = widget.post;
    final String alias =
        post.webDisplayAlias ?? AnonymousIdentity.aliasFor(post.seed);
    final String initial = alias.isNotEmpty
        ? alias[0].toUpperCase()
        : AnonymousIdentity.initialFor(post.seed);

    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradient),
          ),
          alignment: Alignment.center,
          child: Text(initial, style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      alias,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· ${post.timeAgo}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (post.wasEdited) ...[
                    const SizedBox(width: 4),
                    Text(
                      '· edited',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
              if (post.collegeTag != null)
                Text(
                  post.collegeTag!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
            ],
          ),
        ),
        if (widget.isOwner)
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: _handleOptionsTap,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.more_horiz_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ),
          )
        else
          const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.muted,
            size: 20,
          ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: AppColors.secondaryCard);
          },
          errorBuilder: (context, error, stack) =>
              Container(color: AppColors.secondaryCard),
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.post.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.secondaryCard,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text('#$tag', style: Theme.of(context).textTheme.labelSmall),
        );
      }).toList(),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final post = widget.post;
    return Row(
      children: [
        ScaleTransition(
          scale: _likeController,
          child: _ActionChip(
            icon: post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: post.isLiked ? AppColors.primaryBlue : AppColors.muted,
            label: '${post.likeCount}',
            onTap: _handleLikeTap,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _ActionChip(
          icon: Icons.mode_comment_outlined,
          label: '${post.commentCount}',
          onTap: widget.onComment,
        ),
        const SizedBox(width: AppSpacing.md),
        _ActionChip(
          icon: Icons.share_outlined,
          label: '${post.shareCount}',
          onTap: widget.onShare,
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: widget.onBookmark,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              post.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color:
              post.isBookmarked ? AppColors.primaryBlue : AppColors.muted,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 19, color: iconColor ?? AppColors.muted),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}