import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;
  final List<String> likes;
  final List<String> mediaUrls;
  final bool deleted;

  PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.mediaUrls = const [],
    this.deleted = false,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      deleted: data['deleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
      'mediaUrls': mediaUrls,
      'deleted': deleted,
    };
  }

  bool isValid() => authorId.isNotEmpty && content.isNotEmpty;
}