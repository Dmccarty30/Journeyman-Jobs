import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew.dart';

class MemberPermissions {
  final bool canInviteMembers;
  final bool canRemoveMembers;
  final bool canShareJobs;
  final bool canPostAnnouncements;
  final bool canEditCrewInfo;
  final bool canViewAnalytics;

  MemberPermissions({
    required this.canInviteMembers,
    required this.canRemoveMembers,
    required this.canShareJobs,
    required this.canPostAnnouncements,
    required this.canEditCrewInfo,
    required this.canViewAnalytics,
  });

  factory MemberPermissions.fromRole(MemberRole role) {
    switch (role) {
      case MemberRole.foreman:
        return MemberPermissions(
          canInviteMembers: true,
          canRemoveMembers: true,
          canShareJobs: true,
          canPostAnnouncements: true,
          canEditCrewInfo: true,
          canViewAnalytics: true,
        );
      case MemberRole.lead:
        return MemberPermissions(
          canInviteMembers: true,
          canRemoveMembers: false,
          canShareJobs: true,
          canPostAnnouncements: true,
          canEditCrewInfo: false,
          canViewAnalytics: false,
        );
      case MemberRole.member:
        return MemberPermissions(
          canInviteMembers: false,
          canRemoveMembers: false,
          canShareJobs: false,
          canPostAnnouncements: false,
          canEditCrewInfo: false,
          canViewAnalytics: false,
        );
    }
  }

  factory MemberPermissions.fromMap(Map<String, dynamic> map) {
    return MemberPermissions(
      canInviteMembers: map['canInviteMembers'] ?? false,
      canRemoveMembers: map['canRemoveMembers'] ?? false,
      canShareJobs: map['canShareJobs'] ?? false,
      canPostAnnouncements: map['canPostAnnouncements'] ?? false,
      canEditCrewInfo: map['canEditCrewInfo'] ?? false,
      canViewAnalytics: map['canViewAnalytics'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canInviteMembers': canInviteMembers,
      'canRemoveMembers': canRemoveMembers,
      'canShareJobs': canShareJobs,
      'canPostAnnouncements': canPostAnnouncements,
      'canEditCrewInfo': canEditCrewInfo,
      'canViewAnalytics': canViewAnalytics,
    };
  }

  MemberPermissions copyWith({
    bool? canInviteMembers,
    bool? canRemoveMembers,
    bool? canShareJobs,
    bool? canPostAnnouncements,
    bool? canEditCrewInfo,
    bool? canViewAnalytics,
  }) {
    return MemberPermissions(
      canInviteMembers: canInviteMembers ?? this.canInviteMembers,
      canRemoveMembers: canRemoveMembers ?? this.canRemoveMembers,
      canShareJobs: canShareJobs ?? this.canShareJobs,
      canPostAnnouncements: canPostAnnouncements ?? this.canPostAnnouncements,
      canEditCrewInfo: canEditCrewInfo ?? this.canEditCrewInfo,
      canViewAnalytics: canViewAnalytics ?? this.canViewAnalytics,
    );
  }
}

class CrewMember {
  final String userId;                 // Reference to User
  final String crewId;                 // Reference to Crew
  final MemberRole role;               // Member's role in crew
  final DateTime joinedAt;             // When member joined
  final MemberPermissions permissions; // Granular permissions
  final bool isAvailable;              // Current availability status
  final String? customTitle;           // Optional role title
  final DateTime lastActive;           // Last interaction timestamp

  CrewMember({
    required this.userId,
    required this.crewId,
    required this.role,
    required this.joinedAt,
    required this.permissions,
    required this.isAvailable,
    this.customTitle,
    required this.lastActive,
  });

  factory CrewMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewMember(
      userId: doc.id, // Document ID is the userId
      crewId: data['crewId'] ?? '',
      role: MemberRole.values.firstWhere(
        (r) => r.toString().split('.').last == (data['role'] ?? 'member'),
        orElse: () => MemberRole.member,
      ),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      permissions: MemberPermissions.fromMap(data['permissions'] ?? {}),
      isAvailable: data['isAvailable'] ?? true,
      customTitle: data['customTitle'],
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'crewId': crewId,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'permissions': permissions.toMap(),
      'isAvailable': isAvailable,
      'customTitle': customTitle,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  CrewMember copyWith({
    String? userId,
    String? crewId,
    MemberRole? role,
    DateTime? joinedAt,
    MemberPermissions? permissions,
    bool? isAvailable,
    String? customTitle,
    DateTime? lastActive,
  }) {
    return CrewMember(
      userId: userId ?? this.userId,
      crewId: crewId ?? this.crewId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      permissions: permissions ?? this.permissions,
      isAvailable: isAvailable ?? this.isAvailable,
      customTitle: customTitle ?? this.customTitle,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  // Helper method to check if member has a specific permission
  bool hasPermission(String permission) {
    switch (permission) {
      case 'canInviteMembers':
        return permissions.canInviteMembers;
      case 'canRemoveMembers':
        return permissions.canRemoveMembers;
      case 'canShareJobs':
        return permissions.canShareJobs;
      case 'canPostAnnouncements':
        return permissions.canPostAnnouncements;
      case 'canEditCrewInfo':
        return permissions.canEditCrewInfo;
      case 'canViewAnalytics':
        return permissions.canViewAnalytics;
      default:
        return false;
    }
  }

  // Helper method to update role and permissions together
  CrewMember updateRole(MemberRole newRole) {
    return copyWith(
      role: newRole,
      permissions: MemberPermissions.fromRole(newRole),
    );
  }

  // Helper method to mark member as active
  CrewMember markActive() {
    return copyWith(
      lastActive: DateTime.now(),
      isAvailable: true,
    );
  }

  // Helper method to mark member as inactive
  CrewMember markInactive() {
    return copyWith(
      isAvailable: false,
    );
  }
}