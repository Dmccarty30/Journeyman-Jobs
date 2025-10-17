class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderInitials;
  final String content;
  final DateTime timestamp;
  final bool isCurrentUser;
  final String? messageType; // text, image, file, etc.
  final Map<String, dynamic>? metadata; // For attachments, reactions, etc.

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderInitials,
    required this.content,
    required this.timestamp,
    required this.isCurrentUser,
    this.messageType = 'text',
    this.metadata,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderInitials: map['senderInitials'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isCurrentUser: map['isCurrentUser'] ?? false,
      messageType: map['messageType'] ?? 'text',
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderInitials': senderInitials,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isCurrentUser': isCurrentUser,
      'messageType': messageType,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderInitials,
    String? content,
    DateTime? timestamp,
    bool? isCurrentUser,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderInitials: senderInitials ?? this.senderInitials,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, senderName: $senderName, content: $content, timestamp: $timestamp, isCurrentUser: $isCurrentUser)';
  }

  @override
  bool operator ==(covariant ChatMessage other) {
    if (identical(this, other)) return true;
  
    return other.id == id &&
        other.senderId == senderId &&
        other.senderName == senderName &&
        other.senderInitials == senderInitials &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.isCurrentUser == isCurrentUser &&
        other.messageType == messageType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderId.hashCode ^
        senderName.hashCode ^
        senderInitials.hashCode ^
        content.hashCode ^
        timestamp.hashCode ^
        isCurrentUser.hashCode ^
        messageType.hashCode;
  }
}