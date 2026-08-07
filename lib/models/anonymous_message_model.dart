import 'package:cloud_firestore/cloud_firestore.dart';

class AnonymousMessageModel {
  final String id;
  final String receiverUid;
  final String receiverUsername;
  final String receiverUsernameSlug;
  final String message;
  final DateTime createdAt;
  final bool hidden;
  final bool replied;
  final bool reported;

  AnonymousMessageModel({
    required this.id,
    required this.receiverUid,
    required this.receiverUsername,
    required this.receiverUsernameSlug,
    required this.message,
    required this.createdAt,
    this.hidden = false,
    this.replied = false,
    this.reported = false,
  });

  factory AnonymousMessageModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return AnonymousMessageModel(
      id: id,
      receiverUid: data['receiverUid'] ?? '',
      receiverUsername: data['receiverUsername'] ?? '',
      receiverUsernameSlug: data['receiverUsernameSlug'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hidden: data['hidden'] ?? false,
      replied: data['replies'] ?? data['replied'] ?? false,
      reported: data['reported'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'receiverUid': receiverUid,
      'receiverUsername': receiverUsername,
      'receiverUsernameSlug': receiverUsernameSlug,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'hidden': hidden,
      'replied': replied,
      'reported': reported,
    };
  }
}