import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPanelScreen extends StatefulWidget {
  final String? adminRole;

  const AdminPanelScreen({super.key, this.adminRole});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isCheckingAuth = true;
  bool _isAdminAuthorized = false;
  String _userAdminPosition = 'CEO';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verifyAdminAccess();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Verifies current authenticated user against Firestore 'admins' collection schema
  Future<void> _verifyAdminAccess() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
          _isAdminAuthorized = false;
        });
      }
      return;
    }

    try {
      bool authorized = false;
      String position = widget.adminRole ?? 'CEO';

      // 1. Direct Document ID check (Email as Doc ID)
      if (user.email != null && user.email!.isNotEmpty) {
        final emailDoc = await _firestore
            .collection('admins')
            .doc(user.email!.toLowerCase())
            .get();
        if (emailDoc.exists) {
          authorized = true;
          position = emailDoc.data()?['Position'] ?? position;
        }
      }

      // 2. Direct Document ID check (UID as Doc ID fallback)
      if (!authorized) {
        final uidDoc = await _firestore.collection('admins').doc(user.uid).get();
        if (uidDoc.exists) {
          authorized = true;
          position = uidDoc.data()?['Position'] ?? position;
        }
      }

      // 3. Fallback Query by Email field
      if (!authorized && user.email != null && user.email!.isNotEmpty) {
        final emailQuery = await _firestore
            .collection('admins')
            .where('email', isEqualTo: user.email!.toLowerCase())
            .get();
        if (emailQuery.docs.isNotEmpty) {
          authorized = true;
          position = emailQuery.docs.first.data()['Position'] ?? position;
        }
      }

      if (mounted) {
        setState(() {
          _isAdminAuthorized = authorized;
          _userAdminPosition = position;
          _isCheckingAuth = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAdminAuthorized = false;
          _isCheckingAuth = false;
        });
      }
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xff18181B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError ? const Color(0xffEF4444) : const Color(0xff046CC8),
            width: 1,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xffF4F4F5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: const Color(0xff09090B),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xff046CC8),
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                "Verifying credentials...",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xffA1A1AA),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAdminAuthorized) {
      return Scaffold(
        backgroundColor: const Color(0xff09090B),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xffEF4444).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xffEF4444),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Access Denied",
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xffF4F4F5),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your account does not have administrator privileges to view this panel.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xff7D8597),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff18181B),
                        foregroundColor: const Color(0xffF4F4F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text(
                        "Return to Safety",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final displayRole = _userAdminPosition.toUpperCase();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xff09090B),
        appBar: AppBar(
          backgroundColor: const Color(0xff09090B),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          title: Row(
            children: [
              Text(
                'Admin Console',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xffF4F4F5),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff046CC8).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xff046CC8).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  displayRole,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xff44B0FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff111114),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xff046CC8),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: const Color(0xffF4F4F5),
                unselectedLabelColor: const Color(0xff7D8597),
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'User Directory'),
                  Tab(text: 'Admin Roster'),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Stats Dashboard Cards
              Row(
                children: [
                  Expanded(
                    child: _buildLiveStatCard(
                      'users',
                      'Total Users',
                      Icons.people_alt_rounded,
                      const Color(0xff046CC8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLiveStatCard(
                      'admins',
                      'Active Admins',
                      Icons.admin_panel_settings_rounded,
                      const Color(0xffF59E0B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Search Bar
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xff111114),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xffF4F4F5),
                    fontSize: 14,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, position, or identifier...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xff5C677D),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xff5C677D),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xffA1A1AA),
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Tab Bar Views
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

  /// Modern Stat Cards
  Widget _buildLiveStatCard(
      String collection, String title, IconData icon, Color accentColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String displayValue = '...';
        if (snapshot.hasError) {
          displayValue = 'ERR';
        } else if (snapshot.hasData) {
          displayValue = '${snapshot.data!.docs.length}';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff111114),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  Text(
                    displayValue,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xffF4F4F5),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xff7D8597),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// USERS DIRECTORY
  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoCard('Unable to retrieve user directory.', isError: true);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff046CC8)),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data();
            final name = (data['name'] ?? data['displayName'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final username = (data['username'] ?? data['usernameSlug'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                email.contains(_searchQuery) ||
                username.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return _buildInfoCard(
            _searchQuery.isEmpty ? 'No users registered yet.' : 'No users match "$_searchQuery".',
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final name = data['name'] ?? data['displayName'] ?? 'Anonymous';
            final email = data['email'] ?? 'No email bound';
            final username = data['username'] ?? data['usernameSlug'] ?? 'unassigned';

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xff111114),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xff046CC8).withOpacity(0.18),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xff44B0FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xffF4F4F5),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '$email  •  @$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xff7D8597),
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xff046CC8)),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditUserDialog(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xffEF4444)),
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

  /// ADMINS ROSTER (Mapped to: Name, Position, Rights schema)
  Widget _buildAdminsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('admins').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoCard('Unable to retrieve admin roster.', isError: true);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff046CC8)),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data();
            final name = (data['Name'] ?? data['name'] ?? '').toString().toLowerCase();
            final position = (data['Position'] ?? data['role'] ?? '').toString().toLowerCase();
            final docId = doc.id.toLowerCase();
            return name.contains(_searchQuery) ||
                position.contains(_searchQuery) ||
                docId.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return _buildInfoCard(
            _searchQuery.isEmpty ? 'No admin accounts configured.' : 'No admins match "$_searchQuery".',
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            final name = data['Name'] ?? data['name'] ?? doc.id;
            final position = (data['Position'] ?? data['role'] ?? 'ADMIN').toString().toUpperCase();
            final rights = data['Rights'] ?? 'Standard';
            final email = doc.id;

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xff111114),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xffF59E0B).withOpacity(0.25),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffF59E0B).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 18,
                    color: Color(0xffF59E0B),
                  ),
                ),
                title: Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xffF4F4F5),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Position: $position  •  Rights: $rights\n$email',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xffF59E0B),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xff046CC8)),
                      tooltip: 'Edit Admin Details',
                      onPressed: () => _showEditAdminDialog(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xffEF4444)),
                      tooltip: 'Remove Admin Access',
                      onPressed: () => _confirmDeleteDoc('admins', doc.id, name),
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

  /// EDIT USER DIALOG
  Future<void> _showEditUserDialog(
      String userId, Map<String, dynamic> currentData) async {
    final nameController = TextEditingController(
        text: currentData['name'] ?? currentData['displayName'] ?? '');
    final usernameController = TextEditingController(
        text: currentData['username'] ?? currentData['usernameSlug'] ?? '');
    final emailController =
    TextEditingController(text: currentData['email'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff111114),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          'Edit User Profile',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xffF4F4F5),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(nameController, 'Full Name'),
            const SizedBox(height: 12),
            _buildDialogTextField(usernameController, 'Username'),
            const SizedBox(height: 12),
            _buildDialogTextField(emailController, 'Email Address'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xff7D8597),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff046CC8),
              foregroundColor: const Color(0xffF4F4F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                await _firestore.collection('users').doc(userId).update({
                  'name': nameController.text.trim(),
                  'username': usernameController.text.trim(),
                  'email': emailController.text.trim(),
                });
                if (mounted) Navigator.pop(context);
                _showNotification('User profile updated successfully.');
              } catch (_) {
                if (mounted) Navigator.pop(context);
                _showNotification('Could not update user profile.', isError: true);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// EDIT ADMIN DIALOG (Updating Name, Position, Rights)
  Future<void> _showEditAdminDialog(
      String adminId, Map<String, dynamic> currentData) async {
    final nameController =
    TextEditingController(text: currentData['Name'] ?? currentData['name'] ?? '');
    final positionController =
    TextEditingController(text: currentData['Position'] ?? currentData['role'] ?? '');
    final rightsController =
    TextEditingController(text: currentData['Rights'] ?? 'All');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff111114),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          'Modify Admin Authority',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xffF4F4F5),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(nameController, 'Admin Name'),
            const SizedBox(height: 12),
            _buildDialogTextField(positionController, 'Position (e.g. CEO, MODERATOR)'),
            const SizedBox(height: 12),
            _buildDialogTextField(rightsController, 'Rights (e.g. All, ReadOnly)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xff7D8597),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff046CC8),
              foregroundColor: const Color(0xffF4F4F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                await _firestore.collection('admins').doc(adminId).update({
                  'Name': nameController.text.trim(),
                  'Position': positionController.text.trim(),
                  'Rights': rightsController.text.trim(),
                });
                if (mounted) Navigator.pop(context);
                _showNotification('Admin credentials updated.');
              } catch (_) {
                if (mounted) Navigator.pop(context);
                _showNotification('Could not update admin details.', isError: true);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// RECURSIVE DELETE EXECUTION WITH SAFETY GUARDS
  Future<void> _confirmDeleteDoc(
      String collection, String docId, String identifier) async {
    final currentUser = _auth.currentUser;

    // Safety Guard: Prevent admin self-deletion
    if (currentUser != null &&
        (docId == currentUser.uid ||
            docId.toLowerCase() == currentUser.email?.toLowerCase() ||
            identifier.toLowerCase() == currentUser.email?.toLowerCase())) {
      _showNotification(
        'Action blocked: You cannot revoke or delete your active session.',
        isError: true,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff111114),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xffEF4444).withOpacity(0.3)),
        ),
        title: Text(
          'Delete Record?',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xffF4F4F5),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$identifier" from $collection? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xffA1A1AA),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xff7D8597),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (collection == 'users') {
          // Subcollection cleanup prior to main doc deletion
          final userRef = _firestore.collection('users').doc(docId);
          final subcollections = ['bookmarks', 'notifications', 'activity'];
          for (final sub in subcollections) {
            final snapshot = await userRef.collection(sub).get();
            for (final subDoc in snapshot.docs) {
              await subDoc.reference.delete();
            }
          }
          await userRef.delete();
        } else {
          await _firestore.collection(collection).doc(docId).delete();
        }
        _showNotification('Record deleted successfully.');
      } catch (_) {
        _showNotification('Failed to delete record.', isError: true);
      }
    }
  }

  Widget _buildDialogTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: GoogleFonts.plusJakartaSans(color: const Color(0xffF4F4F5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xff7D8597)),
        filled: true,
        fillColor: const Color(0xff18181B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff046CC8)),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String message, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111114),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError
              ? const Color(0xffEF4444).withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: isError ? const Color(0xffEF4444) : const Color(0xff7D8597),
          fontSize: 13,
        ),
      ),
    );
  }
}