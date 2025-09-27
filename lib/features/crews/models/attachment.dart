import 'attachment_type.dart';

/// Model representing a message attachment with full serialization support
class Attachment {
  final AttachmentType type;
  final String filename;
  final int? sizeBytes;
  final String url;

  const Attachment({
    required this.type,
    required this.filename,
    this.sizeBytes,
    required this.url,
  });

  /// Creates an Attachment from JSON data (for Firestore deserialization)
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: AttachmentTypeExtension.fromString(json['type'] ?? ''),
      filename: json['filename'] ?? '',
      sizeBytes: json['sizeBytes'],
      url: json['url'] ?? '',
    );
  }

  /// Converts the Attachment to JSON for serialization (Firestore persistence)
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'filename': filename,
      'sizeBytes': sizeBytes,
      'url': url,
    };
  }

  /// Factory constructor for creating attachments from file paths
  factory Attachment.fromFile(String filepath, AttachmentType type, String url) {
    return Attachment(
      type: type,
      filename: _extractFilename(filepath),
      url: url,
    );
  }

  /// Extracts filename from file path
  static String _extractFilename(String filepath) {
    // Handle both forward and back slashes
    final parts = filepath.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : filepath;
  }

  /// Returns the file extension (lowercase, without dot)
  String get fileExtension {
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filename.substring(dotIndex + 1).toLowerCase();
  }

  /// Checks if the attachment is a valid image file
  bool get isValidImage {
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return type == AttachmentType.image && validExtensions.contains(fileExtension);
  }

  /// Checks if the attachment is a valid document file
  bool get isValidDocument {
    const validExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    return type == AttachmentType.document && validExtensions.contains(fileExtension);
  }

  /// Gets a human-readable file size string
  String get formattedSize {
    if (sizeBytes == null) return 'Unknown size';

    const units = ['B', 'KB', 'MB', 'GB'];
    var size = sizeBytes!.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return size >= 100
        ? '${size.toInt()} ${units[unitIndex]}'
        : '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Creates a copy of the attachment with specified changes
  Attachment copyWith({
    AttachmentType? type,
    String? filename,
    int? sizeBytes,
    String? url,
  }) {
    return Attachment(
      type: type ?? this.type,
      filename: filename ?? this.filename,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      url: url ?? this.url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attachment &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          filename == other.filename &&
          sizeBytes == other.sizeBytes &&
          url == other.url;

  @override
  int get hashCode => Object.hash(type, filename, sizeBytes, url);

  @override
  String toString() {
    return 'Attachment(type: ${type.value}, filename: $filename, size: $formattedSize, url: $url)';
  }
}
