import 'package:cloud_firestore/cloud_firestore.dart';

/// Message types for crew messaging
enum CrewMessageType {
  text,        // Regular text message
  image,       // Image message
  voiceNote,   // Voice note
  location,    // Location sharing
  jobShare,    // Job sharing
  system,      // System notification (join/leave/invite)
  alert,       // Alert/announcement
}

/// Message priority levels
enum CrewMessagePriority {
  normal,      // Regular message
  high,        // Important message
  urgent,      // Urgent alert
}

/// Message read status for each recipient
class MessageReadStatus {
  final String userId;
  final DateTime readAt;
  final bool isRead;

  const MessageReadStatus({
    required this.userId,
    required this.readAt,
    this.isRead = true,
  });

  factory MessageReadStatus.fromFirestore(Map<String, dynamic> data) {
    return MessageReadStatus(
      userId: data['userId'] ?? '',
      readAt: (data['readAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'readAt': Timestamp.fromDate(readAt),
      'isRead': isRead,
    };
  }
}

/// Enhanced message model for crew messaging with real-time features
class CrewMessage {
  /// Unique message identifier
  final String id;

  /// Crew ID where this message was sent
  final String crewId;

  /// ID of the user who sent the message
  final String senderId;

  /// Sender's display name (cached for performance)
  final String senderName;

  /// Sender's avatar URL (cached)
  final String? senderAvatarUrl;

  /// Message content
  final String content;

  /// Message type
  final CrewMessageType type;

  /// Message priority
  final CrewMessagePriority priority;

  /// When the message was created
  final Timestamp createdAt;

  /// When the message was last edited
  final Timestamp? editedAt;

  /// Whether the message is deleted
  final bool isDeleted;

  /// Media URLs (for images, voice notes, etc.)
  final List<String> mediaUrls;

  /// Metadata for different message types
  final Map<String, dynamic>? metadata;

  /// Read status for each recipient
  final List<MessageReadStatus> readStatus;

  /// Reply-to message ID
  final String? replyToMessageId;

  /// Forwarded from message ID
  final String? forwardedFromMessageId;

  /// Reactions to this message
  final Map<String, String> reactions; // userId -> emoji

  const CrewMessage({
    required this.id,
    required this.crewId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.type,
    this.priority = CrewMessagePriority.normal,
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
    this.mediaUrls = const [],
    this.metadata,
    this.readStatus = const [],
    this.replyToMessageId,
    this.forwardedFromMessageId,
    this.reactions = const {},
  });

  /// Create CrewMessage from Firestore document
  factory CrewMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse message type
    CrewMessageType type;
    try {
      type = CrewMessageType.values.firstWhere(
        (t) => t.toString() == 'CrewMessageType.${data['type']}',
      );
    } catch (e) {
      type = CrewMessageType.text; // Default fallback
    }

    // Parse message priority
    CrewMessagePriority priority;
    try {
      priority = CrewMessagePriority.values.firstWhere(
        (p) => p.toString() == 'CrewMessagePriority.${data['priority']}',
      );
    } catch (e) {
      priority = CrewMessagePriority.normal; // Default fallback
    }

    // Parse read status
    final List<MessageReadStatus> readStatus = [];
    if (data['readStatus'] != null) {
      final readStatusData = data['readStatus'] as List;
      readStatus.addAll(readStatusData
          .map((status) => MessageReadStatus.fromFirestore(status as Map<String, dynamic>)));
    }

    // Parse reactions
    final Map<String, String> reactions = {};
    if (data['reactions'] != null) {
      final reactionsData = data['reactions'] as Map<String, dynamic>;
      reactions.addAll(reactionsData.map((key, value) => MapEntry(key, value.toString())));
    }

    return CrewMessage(
      id: doc.id,
      crewId: data['crewId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatarUrl: data['senderAvatarUrl'],
      content: data['content'] ?? '',
      type: type,
      priority: priority,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      editedAt: data['editedAt'],
      isDeleted: data['isDeleted'] ?? false,
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      metadata: data['metadata'],
      readStatus: readStatus,
      replyToMessageId: data['replyToMessageId'],
      forwardedFromMessageId: data['forwardedFromMessageId'],
      reactions: reactions,
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'crewId': crewId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt,
      'editedAt': editedAt,
      'isDeleted': isDeleted,
      'mediaUrls': mediaUrls,
      'metadata': metadata,
      'readStatus': readStatus.map((status) => status.toFirestore()).toList(),
      'replyToMessageId': replyToMessageId,
      'forwardedFromMessageId': forwardedFromMessageId,
      'reactions': reactions,
    };
  }

  /// Create a copy of this message with updated fields
  CrewMessage copyWith({
    String? id,
    String? crewId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    CrewMessageType? type,
    CrewMessagePriority? priority,
    Timestamp? createdAt,
    Timestamp? editedAt,
    bool? isDeleted,
    List<String>? mediaUrls,
    Map<String, dynamic>? metadata,
    List<MessageReadStatus>? readStatus,
    String? replyToMessageId,
    String? forwardedFromMessageId,
    Map<String, String>? reactions,
  }) {
    return CrewMessage(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      metadata: metadata ?? this.metadata,
      readStatus: readStatus ?? this.readStatus,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      forwardedFromMessageId: forwardedFromMessageId ?? this.forwardedFromMessageId,
      reactions: reactions ?? this.reactions,
    );
  }

  /// Check if message is edited
  bool get isEdited => editedAt != null && !editedAt!.toDate().isAtSameMomentAs(createdAt.toDate());

  /// Check if message is urgent
  bool get isUrgent => priority == CrewMessagePriority.urgent;

  /// Check if message is high priority
  bool get isHighPriority => priority == CrewMessagePriority.high;

  /// Check if message has media
  bool get hasMedia => mediaUrls.isNotEmpty;

  /// Check if message is a system message
  bool get isSystemMessage => type == CrewMessageType.system;

  /// Check if message has reactions
  bool get hasReactions => reactions.isNotEmpty;

  /// Get total reaction count
  int get reactionCount => reactions.length;

  /// Check if user has read this message
  bool isReadByUser(String userId) {
    return readStatus.any((status) => status.userId == userId && status.isRead);
  }

  /// Mark message as read by user
  CrewMessage markAsRead(String userId) {
    if (isReadByUser(userId)) return this;

    final newReadStatus = List<MessageReadStatus>.from(readStatus)
      ..add(MessageReadStatus(
        userId: userId,
        readAt: DateTime.now(),
        isRead: true,
      ));

    return copyWith(readStatus: newReadStatus);
  }

  /// Add reaction to message
  CrewMessage addReaction(String userId, String emoji) {
    final newReactions = Map<String, String>.from(reactions);
    newReactions[userId] = emoji;
    return copyWith(reactions: newReactions);
  }

  /// Remove reaction from message
  CrewMessage removeReaction(String userId) {
    final newReactions = Map<String, String>.from(reactions);
    newReactions.remove(userId);
    return copyWith(reactions: newReactions);
  }

  /// Validate message data
  bool get isValid {
    return crewId.isNotEmpty &&
           senderId.isNotEmpty &&
           senderName.isNotEmpty &&
           content.isNotEmpty &&
           (type == CrewMessageType.system || content.trim().isNotEmpty);
  }

  @override
  String toString() {
    return 'CrewMessage(id: $id, crewId: $crewId, senderId: $senderId, type: $type, content: "${content.length > 50 ? content.substring(0, 50) + "..." : content}")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrewMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Crew conversation summary for chat lists
class CrewConversation {
  final String crewId;
  final String crewName;
  final CrewMessage? lastMessage;
  final int unreadCount;
  final List<String> memberIds;
  final Timestamp lastActivity;
  final bool isMuted;
  final bool isPinned;

  const CrewConversation({
    required this.crewId,
    required this.crewName,
    this.lastMessage,
    this.unreadCount = 0,
    this.memberIds = const [],
    required this.lastActivity,
    this.isMuted = false,
    this.isPinned = false,
  });

  factory CrewConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    CrewMessage? lastMessage;
    if (data['lastMessage'] != null) {
      // Create a mock document for the message
      lastMessage = CrewMessage(
        id: data['lastMessage']['id'] ?? '',
        crewId: data['crewId'] ?? '',
        senderId: data['lastMessage']['senderId'] ?? '',
        senderName: data['lastMessage']['senderName'] ?? '',
        content: data['lastMessage']['content'] ?? '',
        type: CrewMessageType.text, // Default for summary
        createdAt: data['lastMessage']['createdAt'] ?? Timestamp.now(),
      );
    }

    return CrewConversation(
      crewId: doc.id,
      crewName: data['crewName'] ?? '',
      lastMessage: lastMessage,
      unreadCount: data['unreadCount'] ?? 0,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      lastActivity: data['lastActivity'] ?? Timestamp.now(),
      isMuted: data['isMuted'] ?? false,
      isPinned: data['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'crewName': crewName,
      'lastMessage': lastMessage?.toFirestore(),
      'unreadCount': unreadCount,
      'memberIds': memberIds,
      'lastActivity': lastActivity,
      'isMuted': isMuted,
      'isPinned': isPinned,
    };
  }

  /// Get display text for last message
  String get lastMessageText {
    if (lastMessage == null) return 'No messages yet';

    if (lastMessage!.isSystemMessage) {
      return lastMessage!.content;
    }

    String prefix = '';
    if (lastMessage!.type != CrewMessageType.text) {
      switch (lastMessage!.type) {
        case CrewMessageType.image:
          prefix = '📷 ';
          break;
        case CrewMessageType.voiceNote:
          prefix = '🎤 ';
          break;
        case CrewMessageType.location:
          prefix = '📍 ';
          break;
        case CrewMessageType.jobShare:
          prefix = '💼 ';
          break;
        case CrewMessageType.alert:
          prefix = '⚠️ ';
          break;
        default:
          prefix = '';
      }
    }

    final content = lastMessage!.content;
    if (content.length > 50) {
      return '$prefix${content.substring(0, 47)}...';
    }
    return '$prefix$content';
  }

  /// Get formatted time for last activity
  String get lastActivityText {
    final now = DateTime.now();
    final activity = lastActivity.toDate();
    final difference = now.difference(activity);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${activity.day}/${activity.month}/${activity.year}';
    }
  }
}