import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_enums.dart';

/// Represents jobs shared within a crew with member responses and coordination.
///
/// Used for tracking job opportunities that have been shared to crew members,
/// collecting responses, and coordinating group applications for IBEW electrical work.
class JobNotification {
  /// Firebase auto-generated ID
  final String id;

  /// Reference to Job entity
  final String jobId;

  /// Reference to Crew
  final String crewId;

  /// Who shared the job
  final String sharedByUserId;

  /// Optional note from sharer
  final String? message;

  /// When job was shared
  final DateTime timestamp;

  /// Member reactions to the job share
  final Map<String, MemberResponse> memberResponses;

  /// Coordination status for group applications
  final GroupBidStatus groupBidStatus;

  /// Urgent/storm work flag
  final bool isPriority;

  /// Job application deadline
  final DateTime? expiresAt;

  /// How many members viewed
  final int viewCount;

  /// How many responded
  final int responseCount;

  /// Who actually applied
  final List<String> appliedMembers;

  const JobNotification({
    required this.id,
    required this.jobId,
    required this.crewId,
    required this.sharedByUserId,
    this.message,
    required this.timestamp,
    this.memberResponses = const {},
    this.groupBidStatus = GroupBidStatus.draft,
    this.isPriority = false,
    this.expiresAt,
    this.viewCount = 0,
    this.responseCount = 0,
    this.appliedMembers = const [],
  });

  /// Create from Firestore document
  factory JobNotification.fromMap(Map<String, dynamic> map) {
    // Parse member responses
    final responsesMap = <String, MemberResponse>{};
    if (map['memberResponses'] != null) {
      for (final entry in (map['memberResponses'] as Map<String, dynamic>).entries) {
        responsesMap[entry.key] = MemberResponse.fromMap(entry.value);
      }
    }

    return JobNotification(
      id: map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      crewId: map['crewId'] ?? '',
      sharedByUserId: map['sharedByUserId'] ?? '',
      message: map['message'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      memberResponses: responsesMap,
      groupBidStatus: GroupBidStatus.fromString(map['groupBidStatus']) ?? GroupBidStatus.draft,
      isPriority: map['isPriority'] ?? false,
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      viewCount: map['viewCount'] ?? 0,
      responseCount: map['responseCount'] ?? 0,
      appliedMembers: List<String>.from(map['appliedMembers'] ?? []),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    final responsesMap = <String, dynamic>{};
    for (final entry in memberResponses.entries) {
      responsesMap[entry.key] = entry.value.toMap();
    }

    return {
      'id': id,
      'jobId': jobId,
      'crewId': crewId,
      'sharedByUserId': sharedByUserId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'memberResponses': responsesMap,
      'groupBidStatus': groupBidStatus.name,
      'isPriority': isPriority,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'viewCount': viewCount,
      'responseCount': responseCount,
      'appliedMembers': appliedMembers,
    };
  }

  /// Create a copy with updated values
  JobNotification copyWith({
    String? id,
    String? jobId,
    String? crewId,
    String? sharedByUserId,
    String? message,
    DateTime? timestamp,
    Map<String, MemberResponse>? memberResponses,
    GroupBidStatus? groupBidStatus,
    bool? isPriority,
    DateTime? expiresAt,
    int? viewCount,
    int? responseCount,
    List<String>? appliedMembers,
  }) {
    return JobNotification(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      crewId: crewId ?? this.crewId,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      memberResponses: memberResponses ?? this.memberResponses,
      groupBidStatus: groupBidStatus ?? this.groupBidStatus,
      isPriority: isPriority ?? this.isPriority,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      responseCount: responseCount ?? this.responseCount,
      appliedMembers: appliedMembers ?? this.appliedMembers,
    );
  }

  /// Check if notification has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification is still active
  bool get isActive => !isExpired && groupBidStatus.isActive;

  /// Get response rate percentage
  double get responseRate {
    if (memberResponses.isEmpty) return 0.0;
    return (responseCount / memberResponses.length) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'JobNotification(id: $id, jobId: $jobId, crewId: $crewId)';
}

/// Represents a crew member's response to a job notification
class MemberResponse {
  /// User ID of the responding member
  final String userId;

  /// Type of response given
  final ResponseType type;

  /// When the response was made
  final DateTime timestamp;

  /// Optional response note
  final String? note;

  const MemberResponse({
    required this.userId,
    required this.type,
    required this.timestamp,
    this.note,
  });

  /// Create from Firestore document
  factory MemberResponse.fromMap(Map<String, dynamic> map) {
    return MemberResponse(
      userId: map['userId'] ?? '',
      type: ResponseType.fromString(map['type']) ?? ResponseType.pending,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      note: map['note'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }

  /// Create a copy with updated values
  MemberResponse copyWith({
    String? userId,
    ResponseType? type,
    DateTime? timestamp,
    String? note,
  }) {
    return MemberResponse(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberResponse &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          type == other.type;

  @override
  int get hashCode => userId.hashCode ^ type.hashCode;

  @override
  String toString() => 'MemberResponse(userId: $userId, type: $type)';
}