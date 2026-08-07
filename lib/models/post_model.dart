import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.seed,
    required this.createdAt,
    required this.content,
    required this.isLegacyPost,
    this.updatedAt,
    this.webDisplayAlias,
    this.collegeTag,
    this.imageUrls = const [],
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isHidden = false,
  });

  final String id;
  final String seed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String content;
  final bool isLegacyPost;
  final String? webDisplayAlias;
  final String? collegeTag;
  final List<String> imageUrls;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final bool isHidden;

  factory PostModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      String currentUid,
      ) {
    final data = doc.data() ?? <String, dynamic>{};

    final bool isLegacyPost = !data.containsKey('seed');
    final String seed =
        data['seed'] as String? ?? data['anonymousName'] as String? ?? doc.id;

    final likedBy = List<String>.from(data['likedBy'] as List? ?? const []);
    final bookmarkedBy = List<String>.from(data['bookmarkedBy'] as List? ?? const []);
    final createdTimestamp = data['createdAt'];
    final updatedTimestamp = data['updatedAt'];

    final rawTags = List<String>.from(data['tags'] as List? ?? const []);
    final category = data['category'] as String?;
    final mood = data['mood'] as String?;

    return PostModel(
      id: doc.id,
      seed: seed,
      isLegacyPost: isLegacyPost,
      webDisplayAlias: isLegacyPost ? data['anonymousName'] as String? : null,
      createdAt: createdTimestamp is Timestamp ? createdTimestamp.toDate() : DateTime.now(),
      updatedAt: updatedTimestamp is Timestamp ? updatedTimestamp.toDate() : null,
      content: (data['content'] as String?) ?? (data['text'] as String?) ?? '',
      collegeTag: data['collegeTag'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? const []),
      tags: [
        ...rawTags,
        if (category != null && category.isNotEmpty) category,
        if (mood != null && mood.isNotEmpty) mood,
      ],
      likeCount: (data['likes'] as int?) ?? (data['likeCount'] as int?) ?? likedBy.length,
      commentCount: (data['commentCount'] as int?) ?? (data['repliesCount'] as int?) ?? 0,
      shareCount: data['shareCount'] as int? ?? 0,
      isLiked: likedBy.contains(currentUid),
      isBookmarked: bookmarkedBy.contains(currentUid),
      isHidden: data['hidden'] as bool? ?? false,
    );
  }

  bool get wasEdited => updatedAt != null;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}