import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Checks whether a given user email exists in the `admins` collection
  Future<bool> isAdminEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return false;

    try {
      final querySnapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  /// Fetches admin details (e.g., role: "ceo")
  Future<Map<String, dynamic>?> getAdminData(String? email) async {
    if (email == null || email.trim().isEmpty) return null;

    try {
      final querySnapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (e) {
      debugPrint('Error fetching admin data: $e');
    }
    return null;
  }
}