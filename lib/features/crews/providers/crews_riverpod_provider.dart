// lib/features/crews/providers/crews_riverpod_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';
import 'package:journeyman_jobs/features/crews/services/job_matching_service_impl.dart';
import 'package:journeyman_jobs/features/crews/services/job_sharing_service_impl.dart';
import '../../../providers/riverpod/app_state_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../domain/enums/crew_visibility.dart';
import '../../../models/crew_invitation_model.dart';
import '../models/models.dart';
import '../services/crew_service.dart';

part 'crews_riverpod_provider.g.dart';

/// JobSharingService provider
@riverpod
JobSharingService jobSharingService(Ref ref) => JobSharingService();

/// JobMatchingService provider
@riverpod
JobMatchingService jobMatchingService(Ref ref) {
  final jobSharingService = ref.watch(jobSharingServiceProvider);
  return JobMatchingService(jobSharingService);
}

/// CrewService provider
@Riverpod(keepAlive: true)
CrewService crewService(Ref ref) {
  final jobSharingService = ref.watch(jobSharingServiceProvider);
  final jobMatchingService = ref.watch(jobMatchingServiceProvider);
  final offlineDataService = ref.watch(offlineDataServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return CrewService(
    jobSharingService: jobSharingService,
    jobMatchingService: jobMatchingService,
    offlineDataService: offlineDataService,
    connectivityService: connectivityService,
  );
}

/// Stream of crews for the current user
@riverpod
Stream<List<Crew>> userCrewsStream(Ref ref) {
  final crewService = ref.watch(crewServiceProvider);
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  
  if (currentUser == null) return Stream.value([]);
  return crewService.getUserCrewsStream(currentUser.uid).map((snapshot) {
    return snapshot.docs.map((doc) => Crew.fromFirestore(doc)).toList();
  });
}

/// Current user's crews provider
@riverpod
List<Crew> userCrews(Ref ref) {
  final crewsAsync = ref.watch(userCrewsStreamProvider);
  
  return crewsAsync.when(
    data: (crews) => crews,
    loading: () => [],
    error: (_, _) => [],
  );
}

// Note: SelectedCrewNotifier and selectedCrewProvider are defined in core_providers.dart
// to maintain compatibility across the app

/// Provider to check if current user is in a specific crew
@riverpod
bool isUserInCrew(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final crews = ref.watch(userCrewsProvider);
  
  if (currentUser == null) return false;
  
  return crews.any((crew) => crew.id == crewId);
}

/// Provider to get user's role in a specific crew
@riverpod
MemberRole? userRoleInCrew(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final crews = ref.watch(userCrewsProvider);
  
  if (currentUser == null) return null;

  final crew = crews.firstWhere(
    (crew) => crew.id == crewId,
    orElse: () => Crew(
      id: '',
      name: '',
      foremanId: '',
      memberIds: [],
      preferences: CrewPreferences.empty(),
      createdAt: DateTime.now(),
      roles: {},
      stats: CrewStats.empty(),
      lastActivityAt: DateTime.now(),
      isActive: true,
      visibility: CrewVisibility.private,
      maxMembers: 50,
      inviteCodeCounter: 0,
    ),
  );
  
  if (crew.id.isEmpty) return null;
  
  return crew.roles[currentUser.uid];
}

/// Provider to check if user has a specific permission in a crew
@riverpod
bool hasCrewPermission(Ref ref, String crewId, String permission) {
  final role = ref.watch(userRoleInCrewProvider(crewId));
  if (role == null) return false;
  
  final permissions = MemberPermissions.fromRole(role);
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

/// Provider to get crew members stream
@riverpod
Stream<List<CrewMember>> crewMembersStream(Ref ref, String crewId) {
  final crewService = ref.watch(crewServiceProvider);
  return crewService.getCrewMembersStream(crewId).map((snapshot) {
    return snapshot.docs.map((doc) => CrewMember.fromFirestore(doc)).toList();
  });
}

/// Provider to get crew members
@riverpod
List<CrewMember> crewMembers(Ref ref, String crewId) {
  final membersAsync = ref.watch(crewMembersStreamProvider(crewId));
  
  return membersAsync.when(
    data: (members) => members,
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider to get current user's crew member data
@riverpod
CrewMember? currentUserCrewMember(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final members = ref.watch(crewMembersProvider(crewId));
  
  if (currentUser == null) return null;
  
  return members.firstWhere(
    (member) => member.userId == currentUser.uid,
    orElse: () => CrewMember(
      userId: '',
      crewId: '',
      role: MemberRole.member,
      joinedAt: DateTime.now(),
      permissions: MemberPermissions.fromRole(MemberRole.member),
      isAvailable: false,
      lastActive: DateTime.now(),
      isActive: false,
    ),
  );
}

/// Provider to check if current user is crew foreman
@riverpod
bool isCrewForeman(Ref ref, String crewId) {
  final role = ref.watch(userRoleInCrewProvider(crewId));
  return role == MemberRole.foreman;
}

/// Provider to check if current user is crew lead
@riverpod
bool isCrewLead(Ref ref, String crewId) {
  final role = ref.watch(userRoleInCrewProvider(crewId));
  return role == MemberRole.lead;
}

/// Provider to get crew by ID
@riverpod
Crew? crewById(Ref ref, String crewId) {
  final crews = ref.watch(userCrewsProvider);
  try {
    return crews.firstWhere((crew) => crew.id == crewId);
  } catch (e) {
    return null;
  }
}

/// Provider to get active crews only
@riverpod
List<Crew> activeCrews(Ref ref) {
  final crews = ref.watch(userCrewsProvider);
  return crews.where((crew) => crew.isActive).toList();
}

/// Provider to get crew count
@riverpod
int crewCount(Ref ref) {
  return ref.watch(userCrewsProvider).length;
}

/// Provider to check if user can create crews
@riverpod
bool canCreateCrews(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  // For now, any authenticated user can create crews
  return currentUser != null;
}

/// Provider to get crew creation limit
@riverpod
int crewCreationLimit(Ref ref) {
  // Default limit for now
  return 5;
}

/// Provider to check if user has reached crew creation limit
@riverpod
bool hasReachedCrewLimit(Ref ref) {
  final crewCount = ref.watch(crewCountProvider);
  final limit = ref.watch(crewCreationLimitProvider);
  return crewCount >= limit;
}


/// Provider for pending crew invitations (invitations received by current user)
@riverpod
List<CrewInvitation> pendingInvitations(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return [];

  // TODO: Implement actual invitation fetching from Firestore
  // For now, return empty list to prevent compilation errors
  return [];
}

/// Provider for sent crew invitations (invitations sent by current user)
@riverpod
List<CrewInvitation> sentInvitations(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return [];

  // TODO: Implement actual sent invitations fetching from Firestore
  // For now, return empty list to prevent compilation errors
  return [];
}

/// Provider for invitation history (all past invitations)
@riverpod
List<CrewInvitation> invitationHistory(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return [];

  // TODO: Implement actual invitation history fetching from Firestore
  // For now, return empty list to prevent compilation errors
  return [];
}