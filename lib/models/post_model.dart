import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;
  final List<String> likes;
  final List<String> mediaUrls;
  final bool deleted;
  final String? authorName; // Added field
  final int? commentCount; // Added field
  final List<String> comments; // Added field
  final Map<String, int> reactions; // Emoji -> count
  final Map<String, String> userReactions; // User ID -> emoji

  PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.mediaUrls = const [],
    this.deleted = false,
    this.authorName, // Added to constructor
    this.commentCount, // Added to constructor
    this.comments = const [], // Added to constructor
    this.reactions = const {},
    this.userReactions = const {},
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? data['createdAt'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      deleted: data['deleted'] ?? data['isDeleted'] ?? false,
      authorName: data['authorName'], // Added to fromFirestore
      commentCount: data['commentCount'], // Added to fromFirestore
      comments: List<String>.from(data['comments'] ?? []), // Added to fromFirestore
      reactions: Map<String, int>.from(data['reactions'] ?? {}),
      userReactions: Map<String, String>.from(data['userReactions'] ?? {}),
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
      'authorName': authorName, // Added to toFirestore
      'commentCount': commentCount, // Added to toFirestore
      'comments': comments, // Added to toFirestore
      'reactions': reactions,
      'userReactions': userReactions,
    };
  }

  bool isValid() => authorId.isNotEmpty && content.isNotEmpty;

  PostModel copyWith({
    String? id,
    String? authorId,
    String? content,
    Timestamp? timestamp,
    List<String>? likes,
    List<String>? mediaUrls,
    bool? deleted,
    String? authorName, // Added to copyWith
    int? commentCount, // Added to copyWith
    List<String>? comments, // Added to copyWith
    Map<String, int>? reactions,
    Map<String, String>? userReactions,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      deleted: deleted ?? this.deleted,
      authorName: authorName ?? this.authorName, // Added to copyWith
      commentCount: commentCount ?? this.commentCount, // Added to copyWith
      comments: comments ?? this.comments, // Added to copyWith
      reactions: reactions ?? this.reactions,
      userReactions: userReactions ?? this.userReactions,
    );
  }
}
