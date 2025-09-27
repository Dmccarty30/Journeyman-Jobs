/// Enum representing different types of messages in the system
enum MessageType {
  text,
  image,
  voice,
  document,
  jobShare,
  systemNotification,
}

/// Extension to provide string representation for serialization
extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.voice:
        return 'voice';
      case MessageType.document:
        return 'document';
      case MessageType.jobShare:
        return 'jobShare';
      case MessageType.systemNotification:
        return 'systemNotification';
    }
  }

  static MessageType fromString(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'voice':
        return MessageType.voice;
      case 'document':
        return MessageType.document;
      case 'jobShare':
        return MessageType.jobShare;
      case 'systemNotification':
        return MessageType.systemNotification;
      default:
        throw ArgumentError('Unknown message type: $value');
    }
  }
}
