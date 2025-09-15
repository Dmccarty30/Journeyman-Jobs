import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_attachment.dart';

/// Crew Communication Model for IBEW Electrical Workers
///
/// Represents messages within electrical worker crews including safety alerts,
/// work updates, coordination requests, and general communications.
/// Designed specifically for IBEW electrical worker coordination and safety protocols.
class CrewCommunication {
  /// Unique message identifier
  final String id;

  /// ID of the crew this message belongs to
  final String crewId;

  /// ID of the user who sent the message
  final String senderId;

  /// Message content text
  final String content;

  /// Type of message (text, announcement, work_update, etc.)
  final MessageType type;

  /// When the message was created
  final DateTime timestamp;

  /// File attachments (photos, documents, etc.)
  final List<MessageAttachment> attachments;

  /// Map of user IDs to timestamp when they read the message
  final Map<String, DateTime> readBy;

  /// Optional ID of the message this is replying to
  final String? replyToMessageId;

  /// Whether message is pinned by crew leader
  final bool isPinned;

  /// Whether the message has been edited
  final bool isEdited;

  /// When the message was last edited
  final DateTime? editedAt;

  /// Sender's display name (for convenience)
  final String? senderName;

  /// Sender's role in the crew (foreman, lineman, etc.)
  final String? senderRole;

  /// Urgency level for safety and coordination messages
  final MessageUrgency? urgency;

  /// Safety level classification for safety messages
  final SafetyLevel? safetyLevel;

  /// Whether message requires acknowledgment from all crew members
  final bool? requiresAcknowledgment;

  /// Map of user acknowledgments for safety/critical messages
  final Map<String, DateTime>? acknowledgments;

  /// Job details for coordination requests
  final Map<String, dynamic>? jobDetails;

  /// Deadline for responding to coordination requests
  final DateTime? responseDeadline;

  /// Number of required responses for coordination requests
  final int? requiredResponses;

  /// Map of user responses to coordination requests
  final Map<String, dynamic>? responses;

  /// Work progress information for work updates
  final Map<String, dynamic>? workProgress;

  /// Message priority level
  final MessagePriority? priority;

  /// Alert level for emergency messages
  final String? alertLevel;

  /// Location information for emergency or work updates
  final Map<String, dynamic>? location;

  /// Whether all members must respond (for emergencies)
  final bool? requiresAllMemberResponse;

  /// Emergency services information
  final Map<String, dynamic>? emergencyServices;

  /// Safety status for safety check-ins
  final SafetyStatus? safetyStatus;

  /// Safety clearances list for transmission work
  final List<String>? clearances;

  /// Number of crew members for safety check-ins
  final int? crewCount;

  /// User responses to emergency alerts
  final Map<String, dynamic>? memberResponses;

  /// Who pinned the message and when
  final String? pinnedBy;
  final DateTime? pinnedAt;

  /// Who edited the message
  final String? editedBy;

  /// Who verified safety check-in
  final String? verifiedBy;

  const CrewCommunication({
    required this.id,
    required this.crewId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.attachments = const [],
    this.readBy = const {},
    this.replyToMessageId,
    this.isPinned = false,
    this.isEdited = false,
    this.editedAt,
    this.senderName,
    this.senderRole,
    this.urgency,
    this.safetyLevel,
    this.requiresAcknowledgment,
    this.acknowledgments,
    this.jobDetails,
    this.responseDeadline,
    this.requiredResponses,
    this.responses,
    this.workProgress,
    this.priority,
    this.alertLevel,
    this.location,
    this.requiresAllMemberResponse,
    this.emergencyServices,
    this.safetyStatus,
    this.clearances,
    this.crewCount,
    this.memberResponses,
    this.pinnedBy,
    this.pinnedAt,
    this.editedBy,
    this.verifiedBy,
  });

  /// Get list of crew members who haven't read this message
  List<String> get unreadByMembers {
    // This would need crew member list to compare against readBy
    // For now, return empty list
    return [];
  }

  /// Check if message has any attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Convert to Firestore document data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crewId': crewId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'readBy': readBy.map((key, value) => MapEntry(key, value.toIso8601String())),
      'replyToMessageId': replyToMessageId,
      'isPinned': isPinned,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'senderName': senderName,
      'senderRole': senderRole,
      'urgency': urgency?.name,
      'safetyLevel': safetyLevel?.name,
      'requiresAcknowledgment': requiresAcknowledgment,
      'acknowledgments': acknowledgments?.map((key, value) => MapEntry(key, value.toIso8601String())),
      'jobDetails': jobDetails,
      'responseDeadline': responseDeadline?.toIso8601String(),
      'requiredResponses': requiredResponses,
      'responses': responses,
      'workProgress': workProgress,
      'priority': priority?.name,
      'alertLevel': alertLevel,
      'location': location,
      'requiresAllMemberResponse': requiresAllMemberResponse,
      'emergencyServices': emergencyServices,
      'safetyStatus': safetyStatus?.name,
      'clearances': clearances,
      'crewCount': crewCount,
      'memberResponses': memberResponses,
      'pinnedBy': pinnedBy,
      'pinnedAt': pinnedAt?.toIso8601String(),
      'editedBy': editedBy,
      'verifiedBy': verifiedBy,
    };
  }

  /// Create from JSON data
  factory CrewCommunication.fromJson(Map<String, dynamic> json) {
    return CrewCommunication(
      id: json['id'] as String,
      crewId: json['crewId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      readBy: (json['readBy'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, DateTime.parse(value as String))) ?? {},
      replyToMessageId: json['replyToMessageId'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt'] as String) : null,
      senderName: json['senderName'] as String?,
      senderRole: json['senderRole'] as String?,
      urgency: json['urgency'] != null
          ? MessageUrgency.values.firstWhere(
              (u) => u.name == json['urgency'],
              orElse: () => MessageUrgency.normal,
            )
          : null,
      safetyLevel: json['safetyLevel'] != null
          ? SafetyLevel.values.firstWhere(
              (s) => s.name == json['safetyLevel'],
              orElse: () => SafetyLevel.general,
            )
          : null,
      requiresAcknowledgment: json['requiresAcknowledgment'] as bool?,
      acknowledgments: (json['acknowledgments'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, DateTime.parse(value as String))),
      jobDetails: json['jobDetails'] as Map<String, dynamic>?,
      responseDeadline: json['responseDeadline'] != null
          ? DateTime.parse(json['responseDeadline'] as String)
          : null,
      requiredResponses: json['requiredResponses'] as int?,
      responses: json['responses'] as Map<String, dynamic>?,
      workProgress: json['workProgress'] as Map<String, dynamic>?,
      priority: json['priority'] != null
          ? MessagePriority.values.firstWhere(
              (p) => p.name == json['priority'],
              orElse: () => MessagePriority.normal,
            )
          : null,
      alertLevel: json['alertLevel'] as String?,
      location: json['location'] as Map<String, dynamic>?,
      requiresAllMemberResponse: json['requiresAllMemberResponse'] as bool?,
      emergencyServices: json['emergencyServices'] as Map<String, dynamic>?,
      safetyStatus: json['safetyStatus'] != null
          ? SafetyStatus.values.firstWhere(
              (s) => s.name == json['safetyStatus'],
              orElse: () => SafetyStatus.allClear,
            )
          : null,
      clearances: (json['clearances'] as List<dynamic>?)?.cast<String>(),
      crewCount: json['crewCount'] as int?,
      memberResponses: json['memberResponses'] as Map<String, dynamic>?,
      pinnedBy: json['pinnedBy'] as String?,
      pinnedAt: json['pinnedAt'] != null ? DateTime.parse(json['pinnedAt'] as String) : null,
      editedBy: json['editedBy'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
    );
  }

  /// Create from Firestore DocumentSnapshot
  factory CrewCommunication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewCommunication.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Create a copy with updated fields
  CrewCommunication copyWith({
    String? id,
    String? crewId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    List<MessageAttachment>? attachments,
    Map<String, DateTime>? readBy,
    String? replyToMessageId,
    bool? isPinned,
    bool? isEdited,
    DateTime? editedAt,
    String? senderName,
    String? senderRole,
    MessageUrgency? urgency,
    SafetyLevel? safetyLevel,
    bool? requiresAcknowledgment,
    Map<String, DateTime>? acknowledgments,
    Map<String, dynamic>? jobDetails,
    DateTime? responseDeadline,
    int? requiredResponses,
    Map<String, dynamic>? responses,
    Map<String, dynamic>? workProgress,
    MessagePriority? priority,
    String? alertLevel,
    Map<String, dynamic>? location,
    bool? requiresAllMemberResponse,
    Map<String, dynamic>? emergencyServices,
    SafetyStatus? safetyStatus,
    List<String>? clearances,
    int? crewCount,
    Map<String, dynamic>? memberResponses,
    String? pinnedBy,
    DateTime? pinnedAt,
    String? editedBy,
    String? verifiedBy,
  }) {
    return CrewCommunication(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      readBy: readBy ?? this.readBy,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      urgency: urgency ?? this.urgency,
      safetyLevel: safetyLevel ?? this.safetyLevel,
      requiresAcknowledgment: requiresAcknowledgment ?? this.requiresAcknowledgment,
      acknowledgments: acknowledgments ?? this.acknowledgments,
      jobDetails: jobDetails ?? this.jobDetails,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      requiredResponses: requiredResponses ?? this.requiredResponses,
      responses: responses ?? this.responses,
      workProgress: workProgress ?? this.workProgress,
      priority: priority ?? this.priority,
      alertLevel: alertLevel ?? this.alertLevel,
      location: location ?? this.location,
      requiresAllMemberResponse: requiresAllMemberResponse ?? this.requiresAllMemberResponse,
      emergencyServices: emergencyServices ?? this.emergencyServices,
      safetyStatus: safetyStatus ?? this.safetyStatus,
      clearances: clearances ?? this.clearances,
      crewCount: crewCount ?? this.crewCount,
      memberResponses: memberResponses ?? this.memberResponses,
      pinnedBy: pinnedBy ?? this.pinnedBy,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      editedBy: editedBy ?? this.editedBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  @override
  String toString() => 'CrewCommunication(id: $id, type: $type, sender: $senderName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrewCommunication &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Types of messages in crew communication
///
/// Specialized message types for electrical worker crew coordination
enum MessageType {
  /// Regular text message
  text,

  /// Important announcements from crew leaders
  announcement,

  /// Work progress updates with optional attachments
  workUpdate,

  /// Coordination requests for job assignments
  coordinationRequest,

  /// Safety alerts and warnings
  safetyAlert,

  /// Emergency alerts requiring immediate attention
  emergencyAlert,

  /// Regular safety check-ins from field crews
  safetyCheckin;
}

/// Message urgency levels for prioritization
enum MessageUrgency {
  /// Normal priority message
  normal,

  /// High priority, requires prompt attention
  high,

  /// Critical priority, requires immediate attention
  critical;
}

/// Message priority levels
enum MessagePriority {
  /// Low priority message
  low,

  /// Normal priority message
  normal,

  /// High priority message
  high,

  /// Critical priority message
  critical;
}

/// Safety levels for electrical work communications
enum SafetyLevel {
  /// General safety reminder
  general,

  /// High voltage hazard present
  highVoltageHazard,

  /// Confined space hazard
  confinedSpace,

  /// Fall protection required
  fallProtection,

  /// Arc flash hazard
  arcFlashHazard,

  /// Environmental hazard (weather, etc.)
  environmental;
}

/// Safety status for check-ins and updates
enum SafetyStatus {
  /// All safety checks passed
  allClear,

  /// Minor safety concern identified
  concern,

  /// Major safety issue requiring attention
  hazard,

  /// Emergency situation
  emergency;
}

/// Custom exception for crew communication errors
class CrewCommunicationException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const CrewCommunicationException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'CrewCommunicationException: $code - $message';
}