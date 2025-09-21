/// Notification model for job sharing system
/// Compatible with job_sharing_service.dart expectations
import '../../crews/models/crew_enums.dart';

class ShareNotificationModel {
  final String id;
  final String jobId;
  final String senderId;
  final String? senderName;
  final List<String> recipientIds;
  final String? message;
  final String shareMethod;
  final DateTime timestamp;
  final ShareStatus status;
  final String? jobTitle;
  final String? jobLocal;
  final String? jobLocation;
  final double? jobPayRate;

  const ShareNotificationModel({
    required this.id,
    required this.jobId,
    required this.senderId,
    this.senderName,
    required this.recipientIds,
    this.message,
    this.shareMethod = 'in_app',
    required this.timestamp,
    this.status = ShareStatus.pending,
    this.jobTitle,
    this.jobLocal,
    this.jobLocation,
    this.jobPayRate,
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
    double? jobPayRate,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'senderId': senderId,
      'senderName': senderName,
      'recipientIds': recipientIds,
      'message': message,
      'shareMethod': shareMethod,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'jobTitle': jobTitle,
      'jobLocal': jobLocal,
      'jobLocation': jobLocation,
      'jobPayRate': jobPayRate,
    };
  }

  factory ShareNotificationModel.fromMap(Map<String, dynamic> map) {
    return ShareNotificationModel(
      id: map['id'] as String,
      jobId: map['jobId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String?,
      recipientIds: List<String>.from(map['recipientIds'] as List),
      message: map['message'] as String?,
      shareMethod: map['shareMethod'] as String? ?? 'in_app',
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: ShareStatus.fromString(map['status'] as String? ?? 'pending') ?? ShareStatus.pending,
      jobTitle: map['jobTitle'] as String?,
      jobLocal: map['jobLocal'] as String?,
      jobLocation: map['jobLocation'] as String?,
      jobPayRate: (map['jobPayRate'] as num?)?.toDouble(),
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
    };
  }

  factory ShareNotificationModel.fromJson(Map<String, dynamic> json) {
    return ShareNotificationModel(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      recipientIds: List<String>.from(json['recipientIds'] as List),
      message: json['message'] as String?,
      shareMethod: json['shareMethod'] as String? ?? 'in_app',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      status: ShareStatus.fromString(json['status'] as String? ?? 'pending') ?? ShareStatus.pending,
      jobTitle: json['jobTitle'] as String?,
      jobLocal: json['jobLocal'] as String?,
      jobLocation: json['jobLocation'] as String?,
      jobPayRate: (json['jobPayRate'] as num?)?.toDouble(),
    );
  }
}
