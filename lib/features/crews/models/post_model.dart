// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a crew feed post
///
/// Posts are social content items that crews can create, like, comment on,
/// and share within the Journeyman Jobs platform.
class Post {
  /// Unique identifier for the post
  final String id;

  /// ID of the crew this post belongs to (null for global posts)
  final String? crewId;

  /// ID of the user who created the post
  final String userId;

  /// Display name of the post author
  final String authorName;

  /// Main text content of the post
  final String content;

  /// Optional image URL attached to the post
  final String? imageUrl;

  /// Timestamp when the post was created
  final DateTime createdAt;

  /// Timestamp when the post was last updated (null if never edited)
  final DateTime? updatedAt;

  /// Number of likes this post has received
  final int likeCount;

  /// Number of comments on this post
  final int commentCount;

  /// Number of times this post has been shared
  final int shareCount;

  /// List of user IDs who have liked this post
  final List<String> likedBy;

  /// Whether this post has been archived/hidden
  final bool isArchived;

  /// Type of post (announcement, update, discussion, etc.)
  final PostType type;

  /// Optional tags for categorizing posts
  final List<String> tags;

  const Post({
    required this.id,
    this.crewId,
    required this.userId,
    required this.authorName,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likedBy = const [],
    this.isArchived = false,
    this.type = PostType.update,
    this.tags = const [],
  });

  /// Create a Post from Firestore document
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      crewId: data['crewId'] as String?,
      userId: data['userId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown User',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      shareCount: data['shareCount'] as int? ?? 0,
      likedBy: (data['likedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      isArchived: data['isArchived'] as bool? ?? false,
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${data['type'] ?? 'update'}',
        orElse: () => PostType.update,
      ),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Convert Post to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'crewId': crewId,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'likedBy': likedBy,
      'isArchived': isArchived,
      'type': type.toString().split('.').last,
      'tags': tags,
    };
  }

  /// Create a copy of this Post with updated fields
  Post copyWith({
    String? id,
    String? crewId,
    String? userId,
    String? authorName,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<String>? likedBy,
    bool? isArchived,
    PostType? type,
    List<String>? tags,
  }) {
    return Post(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likedBy: likedBy ?? this.likedBy,
      isArchived: isArchived ?? this.isArchived,
      type: type ?? this.type,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing different types of posts
enum PostType {
  /// Regular crew update or announcement
  update,

  /// Important announcement requiring attention
  announcement,

  /// Discussion or question post
  discussion,

  /// Job-related post or opportunity
  jobRelated,

  /// Safety alert or notice
  safety,

  /// Social or off-topic post
  social,
}

/// Model representing a comment on a post
class PostComment {
  /// Unique identifier for the comment
  final String id;

  /// ID of the post this comment belongs to
  final String postId;

  /// ID of the user who created the comment
  final String userId;

  /// Display name of the comment author
  final String authorName;

  /// Text content of the comment
  final String content;

  /// Timestamp when the comment was created
  final DateTime createdAt;

  /// Timestamp when the comment was last updated (null if never edited)
  final DateTime? updatedAt;

  /// Number of likes this comment has received
  final int likeCount;

  /// List of user IDs who have liked this comment
  final List<String> likedBy;

  /// ID of the comment this is replying to (null for top-level comments)
  final String? parentCommentId;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.likedBy = const [],
    this.parentCommentId,
  });

  /// Create a PostComment from Firestore document
  factory PostComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostComment(
      id: doc.id,
      postId: data['postId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown User',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      likeCount: data['likeCount'] as int? ?? 0,
      likedBy: (data['likedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      parentCommentId: data['parentCommentId'] as String?,
    );
  }

  /// Convert PostComment to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'parentCommentId': parentCommentId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostComment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
