import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AdminPanelScreen extends StatefulWidget {
  final String? adminRole;

  const AdminPanelScreen({super.key, this.adminRole});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Helper function to verify if the currently signed-in user exists in the 'admins' collection
  Future<bool> _isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Check 1: Check if doc exists by UID
    final uidDoc = await _firestore.collection('admins').doc(user.uid).get();
    if (uidDoc.exists) return true;

    // Check 2: Check if doc exists by Email
    if (user.email != null && user.email!.isNotEmpty) {
      final emailQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: user.email!.toLowerCase())
          .get();
      if (emailQuery.docs.isNotEmpty) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final roleTag = widget.adminRole ?? 'ADMIN';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          title: Row(
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)),
                ),
                child: Text(
                  roleTag,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.primaryBlue,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(
                icon: Icon(Icons.people_outline_rounded, size: 20),
                text: 'User Directory',
              ),
              Tab(
                icon: Icon(Icons.shield_outlined, size: 20),
                text: 'Admin Roster',
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PLATFORM OVERVIEW (USERS & ADMINS COUNTS)
              const Text(
                'Platform Overview',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _buildLiveStatCard(
                      'users',
                      'Registered Users',
                      Icons.people_alt_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildLiveStatCard(
                      'admins',
                      'Active Admins',
                      Icons.admin_panel_settings_rounded,
                      Colors.orangeAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // TAB CONTENTS
              Expanded(
                child: TabBarView(
                  children: [
                    _buildUsersList(),
                    _buildAdminsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Live Stat Card
  Widget _buildLiveStatCard(String collection, String title, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String displayValue = '...';
        if (snapshot.hasError) {
          displayValue = 'Error';
        } else if (snapshot.hasData) {
          displayValue = '${snapshot.data!.docs.length}';
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                displayValue,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 1: USERS LIST ---
  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoCard('Error loading users: ${snapshot.error}', isError: true);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildInfoCard('No registered users found in Firestore.');
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final name = data['name'] ?? data['displayName'] ?? 'No Name';
            final email = data['email'] ?? 'No Email';
            final username = data['username'] ?? data['usernameSlug'] ?? 'N/A';

            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.divider.withOpacity(0.08)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '$email  •  @$username',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                      tooltip: 'Edit User',
                      onPressed: () => _showEditUserDialog(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      tooltip: 'Delete User',
                      onPressed: () => _confirmDeleteDoc('users', doc.id, name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: ADMINS LIST ---
  Widget _buildAdminsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('admins').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoCard('Error loading admins: ${snapshot.error}', isError: true);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildInfoCard('No admins registered.');
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final email = data['email'] ?? 'No Email';
            final role = (data['role'] ?? 'Admin').toString().toUpperCase();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                leading: const CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.security_rounded, size: 18, color: Colors.white),
                ),
                title: Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Role: $role',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                      tooltip: 'Edit Admin Role',
                      onPressed: () => _showEditAdminDialog(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      tooltip: 'Delete Admin',
                      onPressed: () => _confirmDeleteDoc('admins', doc.id, email),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- EDIT USER DIALOG ---
  Future<void> _showEditUserDialog(String userId, Map<String, dynamic> currentData) async {
    final nameController = TextEditingController(text: currentData['name'] ?? currentData['displayName'] ?? '');
    final usernameController = TextEditingController(text: currentData['username'] ?? currentData['usernameSlug'] ?? '');
    final emailController = TextEditingController(text: currentData['email'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Edit User Profile', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(userId).update({
                  'name': nameController.text.trim(),
                  'username': usernameController.text.trim(),
                  'email': emailController.text.trim(),
                });
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e')),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // --- EDIT ADMIN DIALOG ---
  Future<void> _showEditAdminDialog(String adminId, Map<String, dynamic> currentData) async {
    final emailController = TextEditingController(text: currentData['email'] ?? '');
    final roleController = TextEditingController(text: currentData['role'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Edit Admin Role', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Admin Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role (e.g. CEO, MODERATOR, ADMIN)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              try {
                await _firestore.collection('admins').doc(adminId).update({
                  'email': emailController.text.trim().toLowerCase(),
                  'role': roleController.text.trim(),
                });
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e')),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // --- DELETE CONFIRMATION & EXECUTION ---
  Future<void> _confirmDeleteDoc(String collection, String docId, String identifier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete from $collection?'),
        content: Text('Are you sure you want to delete "$identifier"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection(collection).doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Record deleted successfully from $collection')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoCard(String message, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isError ? AppColors.error.withOpacity(0.3) : AppColors.divider.withOpacity(0.08),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? AppColors.error : AppColors.muted,
          fontSize: 13,
        ),
      ),
    );
  }
}