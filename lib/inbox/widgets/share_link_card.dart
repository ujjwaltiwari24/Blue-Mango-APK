import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class ShareLinkCard extends StatefulWidget {
  const ShareLinkCard({super.key});

  @override
  State<ShareLinkCard> createState() => _ShareLinkCardState();
}

class _ShareLinkCardState extends State<ShareLinkCard> {
  static const String _baseUrl = 'https://bluemango.netlify.app/anonymous-chat/';
  bool _isCopied = false;

  void _copyToClipboard(String link) {
    Clipboard.setData(ClipboardData(text: link));
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anonymous link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.divider.withOpacity(0.1),
              ),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          );
        }

        String usernameSlug = user.uid;

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() ?? {};
          if (data['usernameSlug'] != null && data['usernameSlug'].toString().trim().isNotEmpty) {
            usernameSlug = data['usernameSlug'].toString().trim();
          } else if (data['username'] != null && data['username'].toString().trim().isNotEmpty) {
            usernameSlug = data['username'].toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
          }
        }

        final String shareLink = '$_baseUrl$usernameSlug';

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Anonymous Link',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isCopied ? Colors.green : AppColors.primaryBlue,
                      side: BorderSide(
                        color: _isCopied ? Colors.green : AppColors.primaryBlue.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    onPressed: () => _copyToClipboard(shareLink),
                    child: Text(_isCopied ? 'Copied!' : 'Copy Link'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SelectableText(
                shareLink,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}