import 'package:journeyman_jobs/domain/enums/member_role.dart';

class MemberPermissions {
  final bool canShareJob;
  final bool canDeletePost;
  final bool canEditMessages;
  final bool canInviteMembers;
  final bool canViewAnalytics;
  final bool canShareJobs;
  final bool canRemoveMembers;
  final bool canPostAnnouncements;
  final bool canEditCrewInfo;

  const MemberPermissions({
    required this.canShareJob,
    required this.canDeletePost,
    required this.canEditMessages,
    required this.canInviteMembers,
    required this.canViewAnalytics,
    required this.canShareJobs,
    required this.canRemoveMembers,
    required this.canPostAnnouncements,
    required this.canEditCrewInfo,
  });

  factory MemberPermissions.fromMap(Map<String, dynamic> map) {
    return MemberPermissions(
      canShareJob: map['canShareJob'] ?? false,
      canDeletePost: map['canDeletePost'] ?? false,
      canEditMessages: map['canEditMessages'] ?? false,
      canInviteMembers: map['canInviteMembers'] ?? false,
      canViewAnalytics: map['canViewAnalytics'] ?? false,
      canShareJobs: map['canShareJobs'] ?? false,
      canRemoveMembers: map['canRemoveMembers'] ?? false,
      canPostAnnouncements: map['canPostAnnouncements'] ?? false,
      canEditCrewInfo: map['canEditCrewInfo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canShareJob': canShareJob,
      'canDeletePost': canDeletePost,
      'canEditMessages': canEditMessages,
      'canInviteMembers': canInviteMembers,
      'canViewAnalytics': canViewAnalytics,
      'canShareJobs': canShareJobs,
      'canRemoveMembers': canRemoveMembers,
      'canPostAnnouncements': canPostAnnouncements,
      'canEditCrewInfo': canEditCrewInfo,
    };
  }

  MemberPermissions copyWith({
    bool? canShareJob,
    bool? canDeletePost,
    bool? canEditMessages,
    bool? canInviteMembers,
    bool? canViewAnalytics,
    bool? canShareJobs,
    bool? canRemoveMembers,
    bool? canPostAnnouncements,
    bool? canEditCrewInfo,
  }) {
    return MemberPermissions(
      canShareJob: canShareJob ?? this.canShareJob,
      canDeletePost: canDeletePost ?? this.canDeletePost,
      canEditMessages: canEditMessages ?? this.canEditMessages,
      canInviteMembers: canInviteMembers ?? this.canInviteMembers,
      canViewAnalytics: canViewAnalytics ?? this.canViewAnalytics,
      canShareJobs: canShareJobs ?? this.canShareJobs,
      canRemoveMembers: canRemoveMembers ?? this.canRemoveMembers,
      canPostAnnouncements: canPostAnnouncements ?? this.canPostAnnouncements,
      canEditCrewInfo: canEditCrewInfo ?? this.canEditCrewInfo,
    );
  }

  factory MemberPermissions.fromRole(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return const MemberPermissions(
          canShareJob: true,
          canDeletePost: true,
          canEditMessages: true,
          canInviteMembers: true,
          canViewAnalytics: true,
          canShareJobs: true,
          canRemoveMembers: true,
          canPostAnnouncements: true,
          canEditCrewInfo: true,
        );
      case MemberRole.foreman:
        return const MemberPermissions(
          canShareJob: true,
          canDeletePost: true,
          canEditMessages: true,
          canInviteMembers: true,
          canViewAnalytics: true,
          canShareJobs: true,
          canRemoveMembers: true,
          canPostAnnouncements: true
}
