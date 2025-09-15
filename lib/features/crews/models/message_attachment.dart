import 'crew_enums.dart';

/// Message Attachment Model for Crew Communications
///
/// Represents file attachments in crew messages including photos,
/// documents, certificates, and other files relevant to electrical work.
class MessageAttachment {
  /// Unique attachment identifier
  final String id;

  /// Original filename
  final String fileName;

  /// Storage URL where the file is located
  final String url;

  /// Type of attachment (image, document, etc.)
  final AttachmentType type;

  /// File size in bytes
  final int sizeBytes;

  /// Optional thumbnail URL for images and videos
  final String? thumbnailUrl;

  /// MIME type of the file
  final String? mimeType;

  /// Optional description or caption
  final String? description;

  /// When the attachment was uploaded
  final DateTime? uploadedAt;

  /// Who uploaded the attachment
  final String? uploadedBy;

  const MessageAttachment({
    required this.id,
    required this.fileName,
    required this.url,
    required this.type,
    required this.sizeBytes,
    this.thumbnailUrl,
    this.mimeType,
    this.description,
    this.uploadedAt,
    this.uploadedBy,
  });

  /// Get human-readable file size
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '${sizeBytes}B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// Check if attachment is an image
  bool get isImage => type == AttachmentType.image;

  /// Check if attachment is a document
  bool get isDocument => type == AttachmentType.document;

  /// Check if attachment is a video
  bool get isVideo => type == AttachmentType.video;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'url': url,
      'type': type.name,
      'sizeBytes': sizeBytes,
      'thumbnailUrl': thumbnailUrl,
      'mimeType': mimeType,
      'description': description,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  /// Create from JSON
  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      url: json['url'] as String,
      type: AttachmentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AttachmentType.document,
      ),
      sizeBytes: json['sizeBytes'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      description: json['description'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : null,
      uploadedBy: json['uploadedBy'] as String?,
    );
  }

  /// Create a copy with updated fields
  MessageAttachment copyWith({
    String? id,
    String? fileName,
    String? url,
    AttachmentType? type,
    int? sizeBytes,
    String? thumbnailUrl,
    String? mimeType,
    String? description,
    DateTime? uploadedAt,
    String? uploadedBy,
  }) {
    return MessageAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      url: url ?? this.url,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mimeType: mimeType ?? this.mimeType,
      description: description ?? this.description,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }

  @override
  String toString() => 'MessageAttachment(id: $id, fileName: $fileName, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAttachment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}