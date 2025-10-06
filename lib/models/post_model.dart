import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single post within a crew's feed.
///
/// This model encapsulates all data related to a post, including its content,
/// author, media, and engagement metrics like likes, comments, and reactions.
class PostModel {
  /// The unique identifier for the post document.
  final String id;
  /// The user ID of the post's author.
  final String authorId;
  /// The text content of the post.
  final String content;
  /// The Firestore timestamp when the post was created.
  final Timestamp timestamp;
  /// A list of user IDs who have liked the post.
  final List<String> likes;
  /// A list of URLs for any media (images, videos) attached to the post.
  final List<String> mediaUrls;
  /// A flag indicating if the post has been soft-deleted.
  final bool deleted;
  /// The display name of the post's author.
  final String? authorName;
  /// The total number of comments on the post.
  final int? commentCount;
  /// A list of comment IDs associated with the post.
  final List<String> comments;
  /// A map of reactions, where the key is the emoji and the value is the count.
  final Map<String, int> reactions;
  /// A map tracking which user reacted with which emoji. Key is user ID, value is emoji.
  final Map<String, String> userReactions;

  /// Creates an instance of [PostModel].
  PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.mediaUrls = const [],
    this.deleted = false,
    this.authorName,
    this.commentCount,
    this.comments = const [],
    this.reactions = const {},
    this.userReactions = const {},
  });

  /// Creates a [PostModel] instance from a Firestore [DocumentSnapshot].
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
      authorName: data['authorName'],
      commentCount: data['commentCount'],
      comments: List<String>.from(data['comments'] ?? []),
      reactions: Map<String, int>.from(data['reactions'] ?? {}),
      userReactions: Map<String, String>.from(data['userReactions'] ?? {}),
    );
  }

  /// Converts the [PostModel] instance to a map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
      'mediaUrls': mediaUrls,
      'deleted': deleted,
      'authorName': authorName,
      'commentCount': commentCount,
      'comments': comments,
      'reactions': reactions,
      'userReactions': userReactions,
    };
  }

  /// Checks if the post has valid essential data.
  bool isValid() => authorId.isNotEmpty && content.isNotEmpty;

  /// Creates a new [PostModel] instance with updated field values.
  PostModel copyWith({
    String? id,
    String? authorId,
    String? content,
    Timestamp? timestamp,
    List<String>? likes,
    List<String>? mediaUrls,
    bool? deleted,
    String? authorName,
    int? commentCount,
    List<String>? comments,
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
      authorName: authorName ?? this.authorName,
      commentCount: commentCount ?? this.commentCount,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
      userReactions: userReactions ?? this.userReactions,
    );
  }
}
