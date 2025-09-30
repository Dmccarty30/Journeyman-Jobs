import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;
  final List<String> readBy;
  final List<String> mediaUrls;
  final bool deleted;

  MessageModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.readBy = const [],
    this.mediaUrls = const [],
    this.deleted = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      deleted: data['deleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'content': content,
      'timestamp': timestamp,
      'readBy': readBy,
      'mediaUrls': mediaUrls,
      'deleted': deleted,
    };
  }

  bool isValid() => authorId.isNotEmpty && content.isNotEmpty;
}