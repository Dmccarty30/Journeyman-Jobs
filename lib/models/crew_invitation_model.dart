import 'package:cloud_firestore/cloud_firestore.dart';

/// Crew invitation status enumeration
enum CrewInvitationStatus {
  pending,   // Invitation sent, awaiting response
  accepted,  // Invitation accepted by user
  declined,  // Invitation declined by user
  cancelled, // Invitation cancelled by foreman
  expired,   // Invitation expired (7 days)
}

/// Crew invitation model for handling crew member invitations
///
/// This model represents an invitation from a crew foreman to a potential
/// crew member. It includes all necessary information for the invitation
/// workflow including status tracking, expiration, and metadata.
class CrewInvitation {
  /// Unique identifier for the invitation
  final String id;

  /// ID of the crew being invited to
  final String crewId;

  /// ID of the user sending the invitation (foreman)
  final String inviterId;

  /// ID of the user receiving the invitation
  final String inviteeId;

  /// Current status of the invitation
  final CrewInvitationStatus status;

  /// When the invitation was created
  final Timestamp createdAt;

  /// When the invitation was last updated
  final Timestamp updatedAt;

  /// When the invitation expires (7 days from creation)
  final Timestamp expiresAt;

  /// Optional message from the inviter
  final String? message;

  /// Crew name for display purposes
  final String crewName;

  /// Inviter's name for display purposes
  final String inviterName;

  /// Invitee's name for display purposes
  final String? inviteeName;

  /// Job details associated with the crew
  final Map<String, dynamic>? jobDetails;

  const CrewInvitation({
    required this.id,
    required this.crewId,
    required this.inviterId,
    required this.inviteeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.message,
    required this.crewName,
    required this.inviterName,
    this.inviteeName,
    this.jobDetails,
  });

  /// Create a CrewInvitation from a Firestore document
  factory CrewInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse status from string
    CrewInvitationStatus status;
    try {
      status = CrewInvitationStatus.values.firstWhere(
        (s) => s.toString() == 'CrewInvitationStatus.${data['status']}',
      );
    } catch (e) {
      status = CrewInvitationStatus.pending; // Default fallback
    }

    return CrewInvitation(
      id: doc.id,
      crewId: data['crewId'] ?? '',
      inviterId: data['inviterId'] ?? '',
      inviteeId: data['inviteeId'] ?? '',
      status: status,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
      message: data['message'],
      crewName: data['crewName'] ?? '',
      inviterName: data['inviterName'] ?? '',
      inviteeName: data['inviteeName'],
      jobDetails: data['jobDetails'],
    );
  }

  /// Convert CrewInvitation to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'crewId': crewId,
      'inviterId': inviterId,
      'inviteeId': inviteeId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expiresAt': expiresAt,
      'message': message,
      'crewName': crewName,
      'inviterName': inviterName,
      'inviteeName': inviteeName,
      'jobDetails': jobDetails,
    };
  }

  /// Create a copy of this CrewInvitation with updated fields
  CrewInvitation copyWith({
    String? id,
    String? crewId,
    String? inviterId,
    String? inviteeId,
    CrewInvitationStatus? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? expiresAt,
    String? message,
    String? crewName,
    String? inviterName,
    String? inviteeName,
    Map<String, dynamic>? jobDetails,
  }) {
    return CrewInvitation(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      message: message ?? this.message,
      crewName: crewName ?? this.crewName,
      inviterName: inviterName ?? this.inviterName,
      inviteeName: inviteeName ?? this.inviteeName,
      jobDetails: jobDetails ?? this.jobDetails,
    );
  }

  /// Check if the invitation has expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt.toDate());
  }

  /// Check if the invitation is still active (pending and not expired)
  bool get isActive {
    return status == CrewInvitationStatus.pending && !isExpired;
  }

  /// Check if the invitation can be responded to (accepted/declined)
  bool get canRespond {
    return status == CrewInvitationStatus.pending && !isExpired;
  }

  /// Get the remaining time until expiration in hours
  int get hoursUntilExpiration {
    final now = DateTime.now();
    final expiration = expiresAt.toDate();
    return expiration.difference(now).inHours;
  }

  /// Validate the invitation data
  bool get isValid {
    return crewId.isNotEmpty &&
           inviterId.isNotEmpty &&
           inviteeId.isNotEmpty &&
           crewName.isNotEmpty &&
           inviterName.isNotEmpty;
  }

  @override
  String toString() {
    return 'CrewInvitation(id: $id, crewId: $crewId, status: $status, crewName: $crewName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrewInvitation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Crew invitation statistics for dashboard and analytics
class CrewInvitationStats {
  final int totalInvitations;
  final int pendingInvitations;
  final int acceptedInvitations;
  final int declinedInvitations;
  final int expiredInvitations;
  final int cancelledInvitations;
  final double acceptanceRate;

  const CrewInvitationStats({
    required this.totalInvitations,
    required this.pendingInvitations,
    required this.acceptedInvitations,
    required this.declinedInvitations,
    required this.expiredInvitations,
    required this.cancelledInvitations,
    required this.acceptanceRate,
  });

  /// Create stats from a list of invitations
  factory CrewInvitationStats.fromInvitations(List<CrewInvitation> invitations) {
    final total = invitations.length;
    final pending = invitations.where((i) => i.status == CrewInvitationStatus.pending).length;
    final accepted = invitations.where((i) => i.status == CrewInvitationStatus.accepted).length;
    final declined = invitations.where((i) => i.status == CrewInvitationStatus.declined).length;
    final expired = invitations.where((i) => i.status == CrewInvitationStatus.expired).length;
    final cancelled = invitations.where((i) => i.status == CrewInvitationStatus.cancelled).length;

    // Calculate acceptance rate from responded invitations
    final responded = accepted + declined;
    final acceptanceRate = responded > 0 ? accepted / responded : 0.0;

    return CrewInvitationStats(
      totalInvitations: total,
      pendingInvitations: pending,
      acceptedInvitations: accepted,
      declinedInvitations: declined,
      expiredInvitations: expired,
      cancelledInvitations: cancelled,
      acceptanceRate: acceptanceRate,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'totalInvitations': totalInvitations,
      'pendingInvitations': pendingInvitations,
      'acceptedInvitations': acceptedInvitations,
      'declinedInvitations': declinedInvitations,
      'expiredInvitations': expiredInvitations,
      'cancelledInvitations': cancelledInvitations,
      'acceptanceRate': acceptanceRate,
    };
  }
}