import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/post_model.dart';

class PostRepository {
  PostRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('posts');

  List<PostModel> _mapVisible(QuerySnapshot<Map<String, dynamic>> snapshot, String uid) {
    return snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc, uid))
        .where((post) => !post.isHidden)
        .toList();
  }

  /// Unlike [_mapVisible], this keeps hidden posts in the result —
  /// used only for queries scoped to a post's own owner, who needs
  /// to see (and unhide) their hidden posts.
  List<PostModel> _mapAll(QuerySnapshot<Map<String, dynamic>> snapshot, String uid) {
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc, uid)).toList();
  }

  Stream<List<PostModel>> watchFeed({
    required String currentUid,
    int limit = 50,
  }) {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => _mapVisible(snapshot, currentUid));
  }

  /// Posts authored by [uid] through this app — always includes their
  /// own hidden posts, since the owner needs to manage them.
  /// Requires a composite index on (seed ASC, createdAt DESC).
  Stream<List<PostModel>> watchUserPosts({
    required String uid,
    int limit = 100,
  }) {
    return _postsRef
        .where('seed', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => _mapAll(snapshot, uid));
  }

  /// Requires a composite index on (bookmarkedBy ARRAY, createdAt DESC).
  Stream<List<PostModel>> watchBookmarkedPosts({
    required String uid,
    int limit = 100,
  }) {
    return _postsRef
        .where('bookmarkedBy', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => _mapVisible(snapshot, uid));
  }

  Future<void> createPost({
    required String seed,
    required String content,
    String? collegeTag,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) {
    return _postsRef.add({
      'seed': seed,
      'createdAt': FieldValue.serverTimestamp(),
      'content': content,
      'collegeTag': collegeTag,
      'imageUrls': imageUrls,
      'tags': tags,
      'likeCount': 0,
      'commentCount': 0,
      'shareCount': 0,
      'likedBy': <String>[],
      'bookmarkedBy': <String>[],
      'hidden': false,
    });
  }

  /// Edits an app-authored post's editable fields. Callers must only
  /// invoke this for posts the current user owns.
  Future<void> updatePost({
    required String postId,
    required String content,
    String? collegeTag,
    List<String> tags = const [],
  }) {
    return _postsRef.doc(postId).update({
      'content': content,
      'collegeTag': collegeTag,
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String postId) {
    return _postsRef.doc(postId).delete();
  }

  /// 'hidden' is a field name shared by both this app's schema and
  /// the web app's, so this works regardless of a post's origin.
  Future<void> setHidden({
    required String postId,
    required bool hidden,
  }) {
    return _postsRef.doc(postId).update({'hidden': hidden});
  }

  Future<void> toggleLike({
    required String postId,
    required String uid,
    required bool isCurrentlyLiked,
    required bool isLegacyPost,
  }) {
    final docRef = _postsRef.doc(postId);
    final String countField = isLegacyPost ? 'likes' : 'likeCount';

    if (isCurrentlyLiked) {
      return docRef.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        countField: FieldValue.increment(-1),
      });
    }
    return docRef.update({
      'likedBy': FieldValue.arrayUnion([uid]),
      countField: FieldValue.increment(1),
    });
  }

  Future<void> toggleBookmark({
    required String postId,
    required String uid,
    required bool isCurrentlyBookmarked,
  }) {
    final docRef = _postsRef.doc(postId);
    return docRef.update({
      'bookmarkedBy': isCurrentlyBookmarked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }
}