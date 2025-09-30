class Conversation {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      lastMessage: json['lastMessage'] != null ? Message.fromMap(json['lastMessage']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage?.toJson(),
    };
  }

  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Conversation.fromJson(data);
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  List<String> mediaUrls = [];

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    final message = Message(
      id: map['id'],
      senderId: map['senderId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      type: MessageType.values.firstWhere(
        (t) => t.toString().split('.').last == map['type'],
      ),
    );
    message.mediaUrls = List<String>.from(map['mediaUrls'] ?? []);
    return message;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'mediaUrls': mediaUrls,
    };
  }

  factory Message.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message.fromMap(data);
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  void set mediaUrls(List<String> urls) {
    this.mediaUrls = urls;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  voiceNote,
}
