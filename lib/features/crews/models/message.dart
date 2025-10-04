import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  voice,
  document,
  jobShare,
  systemNotification
}

enum MessageStatus {
  sending,    // Message is being sent
  sent,       // Message sent to server
  delivered,  // Message delivered to recipients
  read,       // Message read by recipients
  failed      // Message failed to send
}

enum AttachmentType {
  image,
  document,
  voiceNote,
  video,
  certification, file, audio
}

class Attachment {
  final String url;                    // Firebase Storage URL
  final String filename;               // Original filename
  final AttachmentType type;           // Type of attachment
  final int sizeBytes;                 // File size
  final String? thumbnailUrl;          // For images/videos

  Attachment({
    required this.url,
    required this.filename,
    required this.type,
    required this.sizeBytes,
    this.thumbnailUrl,
  });

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      url: map['url'] ?? '',
      filename: map['filename'] ?? '',
      type: AttachmentType.values.firstWhere(
        (t) => t.toString().split('.').last == (map['type'] ?? 'document'),
        orElse: () => AttachmentType.document,
      ),
      sizeBytes: map['sizeBytes'] ?? 0,
      thumbnailUrl: map['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'filename': filename,
      'type': type.toString().split('.').last,
      'sizeBytes': sizeBytes,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  Attachment copyWith({
    String? url,
    String? filename,
    AttachmentType? type,
    int? sizeBytes,
    String? thumbnailUrl,
  }) {
    return Attachment(
      url: url ?? this.url,
      filename: filename ?? this.filename,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  // Helper method to get file size in human readable format
  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // Helper method to check if attachment is an image
  bool get isImage => type == AttachmentType.image;

  // Helper method to check if attachment is a video
  bool get isVideo => type == AttachmentType.video;

  // Helper method to check if attachment is a voice note
  bool get isVoiceNote => type == AttachmentType.voiceNote;
}

class Message {
  final String id;
  final String senderId;               // Who sent the message
  final String? recipientId;           // For DMs, null for crew messages
  final String? crewId;                // For crew messages
  final String content;                // Message text
  final MessageType type;              // Type of message
  final List<Attachment>? attachments; // Files, images, voice notes
  final DateTime sentAt;               // Timestamp
  final Map<String, DateTime> readBy;  // Read receipts
  final MessageStatus status;          // Message delivery status
  final bool isEdited;                 // If message was edited
  final DateTime? editedAt;            // When edited
  final DateTime? deliveredAt;         // When message was delivered to server
  final DateTime? readAt;              // When message was first read
  final Map<String, DateTime> deliveredTo; // Individual delivery timestamps per user
  final Map<String, DateTime> readStatus; //Individual read timestamps per user (new name for clarity)
  final List<String> readByList;       // List of user IDs who have read the message

  Message({
    required this.id,
    required this.senderId,
    this.recipientId,
    this.crewId,
    required this.content,
    required this.type,
    this.attachments,
    required this.sentAt,
    required this.readBy,
    this.status = MessageStatus.sent, // Default status
    required this.isEdited,
    this.editedAt,
    this.deliveredAt,
    this.readAt,
    this.deliveredTo = const {},
    Map<String, DateTime>? readStatus,
    List<String>? readByList,
  }) : readStatus = readStatus ?? readBy,
        readByList = readByList ?? readBy.keys.toList();

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse readBy map
    final readByMap = <String, DateTime>{};
    if (data['readBy'] != null) {
      (data['readBy'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Timestamp) {
          readByMap[key] = value.toDate();
        } else if (value is String) {
          readByMap[key] = DateTime.parse(value);
        }
      });
    }

    // Parse deliveredTo map
    final deliveredToMap = <String, DateTime>{};
    if (data['deliveredTo'] != null) {
      (data['deliveredTo'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Timestamp) {
          deliveredToMap[key] = value.toDate();
        } else if (value is String) {
          deliveredToMap[key] = DateTime.parse(value);
        }
      });
    }

    // Parse readStatus map
    final readStatusMap = <String, DateTime>{};
    if (data['readStatus'] != null) {
      (data['readStatus'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Timestamp) {
          readStatusMap[key] = value.toDate();
        } else if (value is String) {
          readStatusMap[key] = DateTime.parse(value);
        }
      });
    }

    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'],
      crewId: data['crewId'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.toString().split('.').last == (data['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      attachments: data['attachments'] != null
          ? List<Attachment>.from(
              (data['attachments'] as List<dynamic>)
                  .map((item) => Attachment.fromMap(item as Map<String, dynamic>)),
            )
          : null,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: readByMap,
      status: MessageStatus.values.firstWhere(
        (s) => s.toString().split('.').last == (data['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      isEdited: data['isEdited'] ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      deliveredTo: deliveredToMap,
      readStatus: readStatusMap,
      readByList: data['readByList'] != null ? List<String>.from(data['readByList']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'crewId': crewId,
      'content': content,
      'type': type.toString().split('.').last,
      'attachments': attachments?.map((attachment) => attachment.toMap()).toList(),
      'sentAt': Timestamp.fromDate(sentAt),
      'readBy': readBy.map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
      'status': status.toString().split('.').last,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'deliveredTo': deliveredTo.map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
      'readStatus': readStatus.map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
      'readByList': readByList,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? crewId,
    String? content,
    MessageType? type,
    List<Attachment>? attachments,
    DateTime? sentAt,
    Map<String, DateTime>? readBy,
    MessageStatus? status,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    Map<String, DateTime>? deliveredTo,
    Map<String, DateTime>? readStatus,
    List<String>? readByList,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      crewId: crewId ?? this.crewId,
      content: content ?? this.content,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      readStatus: readStatus ?? this.readStatus,
      readByList: readByList ?? this.readByList,
    );
  }

  // Helper method to check if message is a crew message
  bool get isCrewMessage => crewId != null;

  // Helper method to check if message is a direct message
  bool get isDirectMessage => recipientId != null;

  // Helper method to check if message has attachments
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  // Helper method to check if message has been read by a specific user
  bool isReadBy(String userId) {
    return readBy.containsKey(userId);
  }

  // Helper method to mark message as read by a user
  Message markAsRead(String userId) {
    if (isReadBy(userId)) return this;
    
    final updatedReadBy = Map<String, DateTime>.from(readBy);
    updatedReadBy[userId] = DateTime.now();
    
    return copyWith(readBy: updatedReadBy);
  }

  // Helper method to get read receipt count
  int get readReceiptCount => readBy.length;

  // Helper method to check if message is unread by anyone
  bool get isUnread => readBy.isEmpty;

  // Helper method to get the time when message was last read
  DateTime? get lastReadTime {
    if (readBy.isEmpty) return null;
    return readBy.values.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // Helper method to edit message content
  Message editContent(String newContent) {
    return copyWith(
      content: newContent,
      isEdited: true,
      editedAt: DateTime.now(),
    );
  }

  // Helper method to add attachment
  Message addAttachment(Attachment attachment) {
    final updatedAttachments = attachments != null 
        ? [...attachments!, attachment]
        : [attachment];
    
    return copyWith(attachments: updatedAttachments);
  }

  // Helper method to remove attachment
  Message removeAttachment(String attachmentUrl) {
    if (attachments == null) return this;
    
    final updatedAttachments = attachments!
        .where((attachment) => attachment.url != attachmentUrl)
        .toList();
    
    return copyWith(
      attachments: updatedAttachments.isEmpty ? null : updatedAttachments,
    );
  }
}