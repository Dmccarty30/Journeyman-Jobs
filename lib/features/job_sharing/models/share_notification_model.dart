/// Notification model for job sharing system
class ShareNotificationModel {
  final String id;
  final ShareNotificationType type;
  final String message;
  final String? senderName;
  final String? senderProfileImage;
  final String? jobId;
  final String? jobTitle;
  final String? jobCompany;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const ShareNotificationModel({
    required this.id,
    required this.type,
    required this.message,
    this.senderName,
    this.senderProfileImage,
    this.jobId,
    this.jobTitle,
    this.jobCompany,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  ShareNotificationModel copyWith({
    String? id,
    ShareNotificationType? type,
    String? message,
    String? senderName,
    String? senderProfileImage,
    String? jobId,
    String? jobTitle,
    String? jobCompany,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return ShareNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      jobCompany: jobCompany ?? this.jobCompany,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'message': message,
      'senderName': senderName,
      'senderProfileImage': senderProfileImage,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobCompany': jobCompany,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'readAt': readAt?.millisecondsSinceEpoch,
    };
  }

  factory ShareNotificationModel.fromJson(Map<String, dynamic> json) {
    return ShareNotificationModel(
      id: json['id'] as String,
      type: ShareNotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ShareNotificationType.jobShared,
      ),
      message: json['message'] as String,
      senderName: json['senderName'] as String?,
      senderProfileImage: json['senderProfileImage'] as String?,
      jobId: json['jobId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      jobCompany: json['jobCompany'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      readAt: json['readAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['readAt'] as int)
          : null,
    );
  }
}

/// Types of share notifications
enum ShareNotificationType {
  jobShared,     // User shared a job with others
  shareReceived, // User received a job share from someone
  shareViewed,   // Someone viewed a job user shared
  shareExpired,  // A share has expired
}
