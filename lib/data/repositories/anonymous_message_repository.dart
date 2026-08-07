import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/anonymous_message_model.dart';

class AnonymousMessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name used consistently across the app
  static const String _collectionName = 'anonymousMessages';

  // Generates or fetches the user's usernameSlug
  Future<String> getOrCreateUserSlug(String uid) async {
    final userDocRef = _firestore.collection('users').doc(uid);
    final doc = await userDocRef.get();

    if (doc.exists && doc.data()?.containsKey('usernameSlug') == true) {
      final slug = doc.data()!['usernameSlug'] as String?;
      if (slug != null && slug.trim().isNotEmpty) return slug.trim();
    }

    // Generate random handle if not present: bluemango-XXXXXX
    final randomDigits = Random().nextInt(899999) + 100000;
    final defaultSlug = 'bluemango-$randomDigits';

    await userDocRef.set({
      'usernameSlug': defaultSlug,
    }, SetOptions(merge: true));

    return defaultSlug;
  }

  // Fetch receiver user by usernameSlug
  Future<Map<String, dynamic>?> getUserBySlug(String slug) async {
    final cleanSlug = slug.trim().toLowerCase();

    final query = await _firestore
        .collection('users')
        .where('usernameSlug', isEqualTo: cleanSlug)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final data = doc.data();
    data['uid'] = doc.id;
    return data;
  }

  // Send message to user by usernameSlug
  Future<void> sendMessageToSlug({
    required String slug,
    required String messageText,
  }) async {
    final cleanSlug = slug.trim().toLowerCase();
    final user = await getUserBySlug(cleanSlug);

    if (user == null) {
      throw Exception('User profile not found.');
    }

    await _firestore.collection(_collectionName).add({
      'receiverUid': user['uid'],
      'receiverUsername': user['username'] ?? user['usernameSlug'] ?? 'Anonymous',
      'receiverUsernameSlug': cleanSlug,
      'message': messageText,
      'createdAt': FieldValue.serverTimestamp(),
      'hidden': false,
      'replied': false,
      'reported': false,
    });
  }

  // Watch Inbox messages for logged-in user
  Stream<List<AnonymousMessageModel>> watchUserInbox(String uid) {
    return _firestore
        .collection(_collectionName)
        .where('receiverUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AnonymousMessageModel.fromFirestore(doc.data(), doc.id))
        .where((msg) => !msg.hidden)
        .toList());
  }

  // Soft delete / hide inbox message
  Future<void> hideMessage(String messageId) async {
    await _firestore
        .collection(_collectionName)
        .doc(messageId)
        .update({'hidden': true});
  }

  // Hard delete message permanently from Firestore
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection(_collectionName).doc(messageId).delete();
  }

  // Mark message as replied
  Future<void> markAsReplied(String messageId) async {
    await _firestore
        .collection(_collectionName)
        .doc(messageId)
        .update({'replied': true});
  }
}