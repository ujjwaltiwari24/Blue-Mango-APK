import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/post_repository.dart';
import '../models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.editingPost});

  /// When non-null, the screen opens in edit mode, prefilled with
  /// this post's content, and saves via [PostRepository.updatePost]
  /// instead of creating a new document.
  final PostModel? editingPost;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const int _maxLength = 500;

  final _repository = PostRepository();
  late final TextEditingController _contentController;
  late final TextEditingController _collegeController;
  late final TextEditingController _tagsController;

  bool _isSubmitting = false;

  bool get _isEditing => widget.editingPost != null;

  @override
  void initState() {
    super.initState();
    final post = widget.editingPost;
    _contentController = TextEditingController(text: post?.content ?? '');
    _collegeController = TextEditingController(text: post?.collegeTag ?? '');
    _tagsController = TextEditingController(text: post?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _collegeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      if (_isEditing) {
        await _repository.updatePost(
          postId: widget.editingPost!.id,
          content: content,
          collegeTag: _collegeController.text.trim().isEmpty
              ? null
              : _collegeController.text.trim(),
          tags: _parseTags(_tagsController.text),
        );
      } else {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You need to be signed in to post.')),
          );
          return;
        }
        await _repository.createPost(
          seed: uid,
          content: content,
          collegeTag: _collegeController.text.trim().isEmpty
              ? null
              : _collegeController.text.trim(),
          tags: _parseTags(_tagsController.text),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Couldn\'t save changes. Try again.' : 'Couldn\'t post right now. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Edit Post' : 'New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _PostButton(
              isSubmitting: _isSubmitting,
              label: _isEditing ? 'Save' : 'Post',
              onTap: _submit,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContentField(context),
              const SizedBox(height: AppSpacing.md),
              _buildLabeledField(
                context,
                label: 'College (optional)',
                controller: _collegeController,
                hint: 'e.g. State University',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildLabeledField(
                context,
                label: 'Tags (comma separated, optional)',
                controller: _tagsController,
                hint: 'college, honest, career',
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Your identity stays anonymous. No name or photo is ever attached to this post.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _contentController,
            maxLength: _maxLength,
            minLines: 5,
            maxLines: 10,
            style: Theme.of(context).textTheme.bodyLarge,
            cursorColor: AppColors.primaryBlue,
            decoration: InputDecoration(
              hintText: 'Say something honest…',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_contentController.text.length}/$_maxLength',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String hint,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider, width: 0.7),
          ),
          child: TextField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primaryBlue,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  const _PostButton({
    required this.isSubmitting,
    required this.onTap,
    required this.label,
  });

  final bool isSubmitting;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        alignment: Alignment.center,
        child: isSubmitting
            ? const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}