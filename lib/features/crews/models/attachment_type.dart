/// Enum representing different types of message attachments
enum AttachmentType {
  image,
  document,
  video,
  voiceNote,
  certification,
}

/// Extension to provide string representation for serialization
extension AttachmentTypeExtension on AttachmentType {
  String get value {
    switch (this) {
      case AttachmentType.image:
        return 'image';
      case AttachmentType.document:
        return 'document';
      case AttachmentType.video:
        return 'video';
      case AttachmentType.voiceNote:
        return 'voiceNote';
      case AttachmentType.certification:
        return 'certification';
    }
  }

  static AttachmentType fromString(String value) {
    switch (value) {
      case 'image':
        return AttachmentType.image;
      case 'document':
        return AttachmentType.document;
      case 'video':
        return AttachmentType.video;
      case 'voiceNote':
        return AttachmentType.voiceNote;
      case 'certification':
        return AttachmentType.certification;
      default:
        throw ArgumentError('Unknown attachment type: $value');
    }
  }
}
