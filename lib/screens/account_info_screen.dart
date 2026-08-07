import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _usernameSlugController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentUsernameSlug;
  DateTime? _lastUsernameChange;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameSlugController.dispose();
    super.dispose();
  }

  // Helper to ensure input is formatted strictly as a valid usernameSlug
  String _toUsernameSlug(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .replaceAll(RegExp(r'[^a-z0-9_.]'), ''); // Remove non-allowed special characters
  }

  Future<void> _fetchUserData() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          // Read directly from usernameSlug
          _currentUsernameSlug = data['usernameSlug'] as String?;
          _usernameSlugController.text = _currentUsernameSlug ?? '';
          if (data['lastUsernameChange'] != null) {
            _lastUsernameChange =
                (data['lastUsernameChange'] as Timestamp).toDate();
          }
        });
      }
    } catch (_) {
      _showSnackBar('Failed to load user data');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _daysRemainingUntilChange {
    if (_lastUsernameChange == null) return 0;
    final nextAvailableDate = _lastUsernameChange!.add(const Duration(days: 7));
    final difference = nextAvailableDate.difference(DateTime.now()).inDays;
    return difference > 0 ? difference + 1 : 0;
  }

  bool get _canChangeUsername => _daysRemainingUntilChange == 0;

  Future<void> _saveUsernameSlug() async {
    final rawInput = _usernameSlugController.text;
    final slug = _toUsernameSlug(rawInput);
    final uid = _currentUser?.uid;

    if (uid == null || slug.isEmpty) {
      _showSnackBar('Please enter a valid username.');
      return;
    }

    if (slug == _currentUsernameSlug) {
      _showSnackBar('Username slug is unchanged.');
      return;
    }

    if (!_canChangeUsername) {
      _showSnackBar(
        'You must wait $_daysRemainingUntilChange more days to change your username.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Saves ONLY usernameSlug in Firestore
      await _firestore.collection('users').doc(uid).set({
        'usernameSlug': slug,
        'lastUsernameChange': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _currentUsernameSlug = slug;
          _usernameSlugController.text = slug; // Reflect slugified version in field
          _lastUsernameChange = DateTime.now();
        });
        _showSnackBar('Username updated successfully!');
      }
    } catch (_) {
      _showSnackBar('Failed to update username. Try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text('Account Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      )
          : ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Email Display Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined,
                    color: AppColors.primaryBlue),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentUser?.email ?? 'Anonymous User',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Username Slug Section
          const Text(
            'Anonymous Username',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This handle will be saved as usernameSlug and shared across both app and website.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _usernameSlugController,
            enabled: _canChangeUsername && !_isSaving,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter username handle',
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.alternate_email_rounded,
                  color: AppColors.muted),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Cooldown notice
          if (!_canChangeUsername)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can change your username again in $_daysRemainingUntilChange days.',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Note: Username can only be changed once every 7 days.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_canChangeUsername && !_isSaving)
                  ? _saveUsernameSlug
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Save Username',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}