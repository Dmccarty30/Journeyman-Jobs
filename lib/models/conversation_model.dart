import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the type of content a [Message] contains.
enum MessageType {
  /// A standard text message.
  text,
  /// A message containing one or more images.
  image,
  /// A message containing a voice recording.
  voiceNote,
}

/// Represents a chat conversation between two or more users.
class Conversation {
  /// The unique identifier for the conversation.
  final String id;
  /// A list of user IDs for all participants in the conversation.
  final List<String> participantIds;
  /// The most recent message sent in the conversation, if any.
  final Message? lastMessage;

  /// Creates a [Conversation] instance.
  Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
  });

  /// Creates a [Conversation] instance from a JSON map.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      lastMessage: json['lastMessage'] != null ? Message.fromMap(json['lastMessage']) : null,
    );
  }

  /// Converts the [Conversation] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage?.toJson(),
    };
  }

  /// Creates a [Conversation] instance from a Firestore [DocumentSnapshot].
  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Conversation.fromJson(data);
  }

  /// Converts the [Conversation] instance to a map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

/// Represents a single message within a [Conversation].
class Message {
  /// The unique identifier for the message.
  final String id;
  /// The ID of the user who sent the message.
  final String senderId;
  /// The main content of the message (text, or caption for media).
  final String content;
  /// The timestamp when the message was sent.
  final DateTime timestamp;
  /// The type of the message, e.g., text, image.
  final MessageType type;
  /// A list of URLs for any media attached to the message.
  List<String> mediaUrls = [];

  /// Creates a [Message] instance.
  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  /// Creates a [Message] instance from a map (typically from JSON).
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

  /// Converts the [Message] instance to a JSON map.
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

  /// Creates a [Message] instance from a Firestore [DocumentSnapshot].
  factory Message.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message.fromMap(data);
  }

  /// Converts the [Message] instance to a map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}
