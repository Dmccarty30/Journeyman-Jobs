import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_enums.dart';

/// Represents coordinated crew applications for IBEW electrical jobs.
///
/// Used when crew members coordinate to submit a group application
/// for electrical work opportunities, including storm work and regular contracts.
class GroupBid {
  /// Firebase auto-generated ID
  final String id;

  /// Reference to Crew
  final String crewId;

  /// Reference to Job
  final String jobId;

  /// Reference to JobNotification
  final String jobNotificationId;

  /// Members participating in group bid
  final List<String> participatingMembers;

  /// Proposed roles for each member
  final Map<String, String> memberRoles;

  /// When bid was submitted
  final DateTime submittedAt;

  /// Current bid status
  final GroupBidStatus status;

  /// Response from employer
  final String? employerResponse;

  /// When employer responded
  final DateTime? responseDate;

  /// Negotiated terms for the group bid
  final BidTerms terms;

  /// Who created the group bid
  final String createdByUserId;

  /// When the bid was created
  final DateTime createdAt;

  /// Last time the bid was modified
  final DateTime lastModified;

  const GroupBid({
    required this.id,
    required this.crewId,
    required this.jobId,
    required this.jobNotificationId,
    required this.participatingMembers,
    this.memberRoles = const {},
    required this.submittedAt,
    this.status = GroupBidStatus.draft,
    this.employerResponse,
    this.responseDate,
    required this.terms,
    required this.createdByUserId,
    required this.createdAt,
    required this.lastModified,
  });

  /// Create from Firestore document
  factory GroupBid.fromMap(Map<String, dynamic> map) {
    return GroupBid(
      id: map['id'] ?? '',
      crewId: map['crewId'] ?? '',
      jobId: map['jobId'] ?? '',
      jobNotificationId: map['jobNotificationId'] ?? '',
      participatingMembers: List<String>.from(map['participatingMembers'] ?? []),
      memberRoles: Map<String, String>.from(map['memberRoles'] ?? {}),
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: GroupBidStatus.fromString(map['status']) ?? GroupBidStatus.draft,
      employerResponse: map['employerResponse'],
      responseDate: map['responseDate'] != null
          ? (map['responseDate'] as Timestamp).toDate()
          : null,
      terms: BidTerms.fromMap(map['terms'] ?? {}),
      createdByUserId: map['createdByUserId'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastModified: map['lastModified'] != null
          ? (map['lastModified'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crewId': crewId,
      'jobId': jobId,
      'jobNotificationId': jobNotificationId,
      'participatingMembers': participatingMembers,
      'memberRoles': memberRoles,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'status': status.name,
      'employerResponse': employerResponse,
      'responseDate': responseDate != null ? Timestamp.fromDate(responseDate!) : null,
      'terms': terms.toMap(),
      'createdByUserId': createdByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  /// Create a copy with updated values
  GroupBid copyWith({
    String? id,
    String? crewId,
    String? jobId,
    String? jobNotificationId,
    List<String>? participatingMembers,
    Map<String, String>? memberRoles,
    DateTime? submittedAt,
    GroupBidStatus? status,
    String? employerResponse,
    DateTime? responseDate,
    BidTerms? terms,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return GroupBid(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      jobId: jobId ?? this.jobId,
      jobNotificationId: jobNotificationId ?? this.jobNotificationId,
      participatingMembers: participatingMembers ?? this.participatingMembers,
      memberRoles: memberRoles ?? this.memberRoles,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      employerResponse: employerResponse ?? this.employerResponse,
      responseDate: responseDate ?? this.responseDate,
      terms: terms ?? this.terms,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Check if bid can be modified
  bool get canModify => status.canModify;

  /// Check if bid is active
  bool get isActive => status.isActive;

  /// Check if bid is final
  bool get isFinal => status.isFinal;

  /// Get number of participating members
  int get memberCount => participatingMembers.length;

  /// Check if user is participating in this bid
  bool hasParticipatingMember(String userId) => participatingMembers.contains(userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupBid &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GroupBid(id: $id, crewId: $crewId, jobId: $jobId, status: $status)';
}

/// Negotiated terms for group bids
class BidTerms {
  /// Group rate negotiated
  final double proposedRate;

  /// Proposed start date
  final DateTime startDate;

  /// Weeks estimated for completion
  final int estimatedDuration;

  /// Required certifications crew has
  final List<String> certificationsCovered;

  /// Special conditions or requirements
  final String? additionalTerms;

  /// Need employer housing
  final bool housingRequested;

  /// Need travel reimbursement
  final bool transportationRequested;

  /// Crew's preferred shift schedule
  final String? preferredSchedule;

  /// Any equipment the crew brings
  final List<String> crewEquipment;

  /// Per diem requirements
  final double? perDiemRequested;

  const BidTerms({
    required this.proposedRate,
    required this.startDate,
    required this.estimatedDuration,
    this.certificationsCovered = const [],
    this.additionalTerms,
    this.housingRequested = false,
    this.transportationRequested = false,
    this.preferredSchedule,
    this.crewEquipment = const [],
    this.perDiemRequested,
  });

  /// Create from Firestore document
  factory BidTerms.fromMap(Map<String, dynamic> map) {
    return BidTerms(
      proposedRate: (map['proposedRate'] ?? 0.0).toDouble(),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      estimatedDuration: map['estimatedDuration'] ?? 0,
      certificationsCovered: List<String>.from(map['certificationsCovered'] ?? []),
      additionalTerms: map['additionalTerms'],
      housingRequested: map['housingRequested'] ?? false,
      transportationRequested: map['transportationRequested'] ?? false,
      preferredSchedule: map['preferredSchedule'],
      crewEquipment: List<String>.from(map['crewEquipment'] ?? []),
      perDiemRequested: map['perDiemRequested']?.toDouble(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'proposedRate': proposedRate,
      'startDate': Timestamp.fromDate(startDate),
      'estimatedDuration': estimatedDuration,
      'certificationsCovered': certificationsCovered,
      'additionalTerms': additionalTerms,
      'housingRequested': housingRequested,
      'transportationRequested': transportationRequested,
      'preferredSchedule': preferredSchedule,
      'crewEquipment': crewEquipment,
      'perDiemRequested': perDiemRequested,
    };
  }

  /// Create a copy with updated values
  BidTerms copyWith({
    double? proposedRate,
    DateTime? startDate,
    int? estimatedDuration,
    List<String>? certificationsCovered,
    String? additionalTerms,
    bool? housingRequested,
    bool? transportationRequested,
    String? preferredSchedule,
    List<String>? crewEquipment,
    double? perDiemRequested,
  }) {
    return BidTerms(
      proposedRate: proposedRate ?? this.proposedRate,
      startDate: startDate ?? this.startDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      certificationsCovered: certificationsCovered ?? this.certificationsCovered,
      additionalTerms: additionalTerms ?? this.additionalTerms,
      housingRequested: housingRequested ?? this.housingRequested,
      transportationRequested: transportationRequested ?? this.transportationRequested,
      preferredSchedule: preferredSchedule ?? this.preferredSchedule,
      crewEquipment: crewEquipment ?? this.crewEquipment,
      perDiemRequested: perDiemRequested ?? this.perDiemRequested,
    );
  }

  /// Calculate total estimated cost for the job
  double calculateTotalCost(int crewSize) {
    final baseCost = proposedRate * crewSize * estimatedDuration * 40; // 40 hours per week
    final perDiemCost = (perDiemRequested ?? 0.0) * crewSize * estimatedDuration * 7; // 7 days per week
    return baseCost + perDiemCost;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidTerms &&
          runtimeType == other.runtimeType &&
          proposedRate == other.proposedRate &&
          startDate == other.startDate &&
          estimatedDuration == other.estimatedDuration;

  @override
  int get hashCode => proposedRate.hashCode ^ startDate.hashCode ^ estimatedDuration.hashCode;

  @override
  String toString() => 'BidTerms(rate: \$${proposedRate.toStringAsFixed(2)}/hr, duration: ${estimatedDuration}w)';
}