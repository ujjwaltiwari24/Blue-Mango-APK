import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Owner-only action sheet for a post: Edit, Hide/Unhide, Delete.
/// Only ever shown for posts the current user authored through
/// this app — callers are responsible for that ownership check.
Future<void> showPostOptionsSheet(
    BuildContext context, {
      required bool isHidden,
      required VoidCallback onEdit,
      required VoidCallback onToggleHide,
      required VoidCallback onDelete,
    }) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _PostOptionsSheet(
      isHidden: isHidden,
      onEdit: onEdit,
      onToggleHide: onToggleHide,
      onDelete: onDelete,
    ),
  );
}

class _PostOptionsSheet extends StatelessWidget {
  const _PostOptionsSheet({
    required this.isHidden,
    required this.onEdit,
    required this.onToggleHide,
    required this.onDelete,
  });

  final bool isHidden;
  final VoidCallback onEdit;
  final VoidCallback onToggleHide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              _OptionRow(
                icon: Icons.edit_rounded,
                label: 'Edit post',
                onTap: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
              ),
              _OptionRow(
                icon: isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                label: isHidden ? 'Unhide from feed' : 'Hide from feed',
                subtitle: isHidden
                    ? 'Others will be able to see this post again.'
                    : 'Only you will be able to see this post.',
                onTap: () {
                  Navigator.of(context).pop();
                  onToggleHide();
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Divider(color: AppColors.divider, height: AppSpacing.sm),
              ),
              _OptionRow(
                icon: Icons.delete_outline_rounded,
                label: 'Delete post',
                subtitle: 'This can\'t be undone.',
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}