/// Notification model for job sharing system
class ShareNotificationModel {
  final String id;
  final String jobId;
  final String senderId;
  final String senderName;
  final List<String> recipientIds;
  final String? message;
  final String shareMethod;
  final DateTime timestamp;
  final ShareStatus status;
  final String? jobTitle;
  final String? jobLocal;
  final String? jobLocation;
  final String? jobPayRate;
  final DateTime? viewedAt;

  const ShareNotificationModel({
    required this.id,
    required this.jobId,
    required this.senderId,
    required this.senderName,
    required this.recipientIds,
    this.message,
    required this.shareMethod,
    required this.timestamp,
    required this.status,
    this.jobTitle,
    this.jobLocal,
    this.jobLocation,
    this.jobPayRate,
    this.viewedAt,
  });

  ShareNotificationModel copyWith({
    String? id,
    String? jobId,
    String? senderId,
    String? senderName,
    List<String>? recipientIds,
    String? message,
    String? shareMethod,
    DateTime? timestamp,
    ShareStatus? status,
    String? jobTitle,
    String? jobLocal,
    String? jobLocation,
    String? jobPayRate,
    DateTime? viewedAt,
  }) {
    return ShareNotificationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientIds: recipientIds ?? this.recipientIds,
      message: message ?? this.message,
      shareMethod: shareMethod ?? this.shareMethod,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      jobTitle: jobTitle ?? this.jobTitle,
      jobLocal: jobLocal ?? this.jobLocal,
      jobLocation: jobLocation ?? this.jobLocation,
      jobPayRate: jobPayRate ?? this.jobPayRate,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'senderId': senderId,
      'senderName': senderName,
      'recipientIds': recipientIds,
      'message': message,
      'shareMethod': shareMethod,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'jobTitle': jobTitle,
      'jobLocal': jobLocal,
      'jobLocation': jobLocation,
      'jobPayRate': jobPayRate,
      'viewedAt': viewedAt?.millisecondsSinceEpoch,
    };
  }

  factory ShareNotificationModel.fromJson(Map<String, dynamic> json) {
    return ShareNotificationModel(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      recipientIds: List<String>.from(json['recipientIds'] as List),
      message: json['message'] as String?,
      shareMethod: json['shareMethod'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      status: ShareStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShareStatus.pending,
      ),
      jobTitle: json['jobTitle'] as String?,
      jobLocal: json['jobLocal'] as String?,
      jobLocation: json['jobLocation'] as String?,
      jobPayRate: json['jobPayRate'] as String?,
      viewedAt: json['viewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['viewedAt'] as int)
          : null,
    );
  }

  factory ShareNotificationModel.fromMap(Map<String, dynamic> map) {
    return ShareNotificationModel.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}

/// Status of share notifications
enum ShareStatus {
  pending,    // Share created but not viewed
  viewed,     // Share has been viewed by recipient
  accepted,   // Share was accepted/accepted
  declined,   // Share was declined
  expired,    // Share has expired
}

/// Types of share notifications (legacy - kept for compatibility)
enum ShareNotificationType {
  jobShared,     // User shared a job with others
  shareReceived, // User received a job share from someone
  shareViewed,   // Someone viewed a job user shared
  shareExpired,  // A share has expired
}
