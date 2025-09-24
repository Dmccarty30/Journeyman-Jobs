// lib/features/crews/providers/crews_riverpod_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../models/models.dart';
import '../services/crew_service.dart' as crew_service;

part 'crews_riverpod_provider.g.dart';

/// CrewService provider
@riverpod
crew_service.CrewService crewService(Ref ref) => crew_service.CrewService();

/// Stream of crews for the current user
@riverpod
Stream<List<Crew>> userCrewsStream(Ref ref) {
  final crewService = ref.watch(crewServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
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
    error: (_, __) => [],
  );
}

/// Selected crew provider
@riverpod
Crew? selectedCrew(Ref ref) {
  final crews = ref.watch(userCrewsProvider);
  // For now, return the first crew or null
  return crews.isNotEmpty ? crews.first : null;
}

/// Provider to check if current user is in a specific crew
@riverpod
bool isUserInCrew(Ref ref, String crewId) {
  final currentUser = ref.watch(currentUserProvider);
  final crews = ref.watch(userCrewsProvider);
  
  if (currentUser == null) return false;
  
  return crews.any((crew) => crew.id == crewId);
}

/// Provider to get user's role in a specific crew
@riverpod
MemberRole? userRoleInCrew(Ref ref, String crewId) {
  final currentUser = ref.watch(currentUserProvider);
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
      isActive: false,
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
    error: (_, __) => [],
  );
}

/// Provider to get current user's crew member data
@riverpod
CrewMember? currentUserCrewMember(Ref ref, String crewId) {
  final currentUser = ref.watch(currentUserProvider);
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
  return crews.firstWhere(
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
      isActive: false,
    ),
  );
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
  final currentUser = ref.watch(currentUserProvider);
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
