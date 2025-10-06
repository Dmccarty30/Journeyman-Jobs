import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message within a chat conversation.
class MessageModel {
  /// The unique identifier for the message document.
  final String id;
  /// The user ID of the message's author.
  final String authorId;
  /// The text content of the message.
  final String content;
  /// The Firestore timestamp when the message was sent.
  final Timestamp timestamp;
  /// A list of user IDs who have read this message.
  final List<String> readBy;
  /// A list of URLs for any media (images, videos) attached to the message.
  final List<String> mediaUrls;
  /// A flag indicating if the message has been soft-deleted.
  final bool deleted;

  /// Creates an instance of [MessageModel].
  MessageModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.readBy = const [],
    this.mediaUrls = const [],
    this.deleted = false,
  });

  /// Creates a [MessageModel] instance from a Firestore [DocumentSnapshot].
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

  /// Converts the [MessageModel] instance to a map suitable for Firestore.
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

  /// Checks if the message has valid essential data.
  bool isValid() => authorId.isNotEmpty && content.isNotEmpty;

  /// Creates a new [MessageModel] instance with updated field values.
  MessageModel copyWith({
    String? id,
    String? authorId,
    String? content,
    Timestamp? timestamp,
    List<String>? readBy,
    List<String>? mediaUrls,
    bool? deleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      deleted: deleted ?? this.deleted,
    );
  }
}
