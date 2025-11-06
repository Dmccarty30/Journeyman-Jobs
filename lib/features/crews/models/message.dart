// lib/features/crews/models/message.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_model.dart';

/// Model representing a chat message in crew conversations
///
/// Messages are used for real-time communication between crew members
/// in the Journeyman Jobs platform.
class Message {
  /// Unique identifier for the message
  final String id;

  /// ID of the crew this message belongs to
  final String crewId;

  /// ID of the conversation this message is part of
  final String conversationId;

  /// ID of the user who sent the message
  final String userId;

  /// Display name of the message author
  final String authorName;

  /// Main text content of the message
  final String content;

  /// Timestamp when the message was created
  final DateTime createdAt;

  /// Timestamp when the message was last updated (null if never edited)
  final DateTime? updatedAt;

  /// Timestamp when the message was delivered
  final DateTime? deliveredAt;

  /// Timestamp when the message was read
  final DateTime? readAt;

  /// Whether this message has been edited
  final bool isEdited;

  /// Type of message (text, image, file, etc.)
  final MessageType type;

  /// List of attachments for this message
  final List<Attachment> attachments;

  /// ID of the message this is replying to (null for top-level messages)
  final String? replyToMessageId;

  /// Whether this message has been deleted
  final bool isDeleted;

  const Message({
    required this.id,
    required this.crewId,
    required this.conversationId,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.readAt,
    this.isEdited = false,
    this.type = MessageType.text,
    this.attachments = const [],
    this.replyToMessageId,
    this.isDeleted = false,
  });

  /// Create a Message from Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Message(
      id: doc.id,
      crewId: data['crewId'] as String? ?? '',
      conversationId: data['conversationId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown User',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      isEdited: data['isEdited'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      attachments: (data['attachments'] as List<dynamic>?)
              ?.map((a) => Attachment.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      replyToMessageId: data['replyToMessageId'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  /// Convert Message to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'crewId': crewId,
      'conversationId': conversationId,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isEdited': isEdited,
      'type': type.toString().split('.').last,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'replyToMessageId': replyToMessageId,
      'isDeleted': isDeleted,
    };
  }

  /// Create a copy of this Message with updated fields
  Message copyWith({
    String? id,
    String? crewId,
    String? conversationId,
    String? userId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isEdited,
    MessageType? type,
    List<Attachment>? attachments,
    String? replyToMessageId,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isEdited: isEdited ?? this.isEdited,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing different types of messages
enum MessageType {
  /// Plain text message
  text,

  /// Image message
  image,

  /// Video message
  video,

  /// Audio message
  audio,

  /// Document/file message
  document,

  /// Location sharing message
  location,

  /// System message (notifications, etc.)
  system,
}

/// Model representing file attachments in messages
class Attachment {
  /// Unique identifier for the attachment
  final String id;

  /// Type of attachment
  final AttachmentType type;

  /// Name of the file
  final String fileName;

  /// URL to download the file
  final String url;

  /// Size of the file in bytes
  final int? fileSize;

  /// MIME type of the file
  final String? mimeType;

  /// Thumbnail URL (for images/videos)
  final String? thumbnailUrl;

  /// Dimensions for image/video files
  final int? width;
  final int? height;

  /// Duration for audio/video files
  final Duration? duration;

  const Attachment({
    required this.id,
    required this.type,
    required this.fileName,
    required this.url,
    this.fileSize,
    this.mimeType,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
  });

  /// Create an Attachment from a map (Firestore data)
  factory Attachment.fromMap(Map<String, dynamic> data) {
    return Attachment(
      id: data['id'] as String? ?? '',
      type: AttachmentType.values.firstWhere(
        (e) => e.toString() == 'AttachmentType.${data['type'] ?? 'file'}',
        orElse: () => AttachmentType.file,
      ),
      fileName: data['fileName'] as String? ?? '',
      url: data['url'] as String? ?? '',
      fileSize: data['fileSize'] as int?,
      mimeType: data['mimeType'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      width: data['width'] as int?,
      height: data['height'] as int?,
      duration: data['duration'] != null 
          ? Duration(milliseconds: data['duration'] as int) 
          : null,
    );
  }

  /// Convert Attachment to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'fileName': fileName,
      'url': url,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'thumbnailUrl': thumbnailUrl,
      'width': width,
      'height': height,
      'duration': duration?.inMilliseconds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attachment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing different types of attachments
enum AttachmentType {
  /// Image file
  image,

  /// Video file
  video,

  /// Audio file
  audio,

  /// Document file (PDF, Word, etc.)
  document,

  /// Generic file type
  file,
}

/// Type alias for backward compatibility
typedef PostModel = Post;
