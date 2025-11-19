// lib/features/crews/providers/crews_riverpod_provider.dart
import '../../../domain/enums/member_role.dart';
import '../services/job_matching_service_impl.dart';
import '../services/job_sharing_service_impl.dart';
import '../../../providers/riverpod/app_state_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart';
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

/// Selected crew notifier
class SelectedCrewNotifier extends StateNotifier<Crew?> {
  SelectedCrewNotifier() : super(null);

  void setCrew(Crew crew) {
    state = crew;
    // Additional logic can be added here if needed when a crew is selected
    // For example, loading crew-specific data for tabs
  }

  void clearCrew() {
    state = null;
    // Additional logic can be added here if needed when a crew is cleared
  }
}

/// Selected crew provider
@riverpod
Crew? selectedCrew(Ref ref) {
  final crews = ref.watch(userCrewsProvider);
  // For now, return the first crew or null
  return crews.isNotEmpty ? crews.first : null;
}

/// Selected crew notifier provider
@riverpod
SelectedCrewNotifier selectedCrewNotifierProvider(Ref ref) {
  return SelectedCrewNotifier();
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
      lastActivityAt: DateTime.now(),
      // Added missing required parameter
      isActive: true,
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

/// Notifier for creating crews with preferences
class CrewCreationNotifier extends StateNotifier<AsyncValue<void>> {
  CrewCreationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> createCrewWithPreferences({
    required String name,
    required String foremanId,
    required CrewPreferences preferences,
    String? logoUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final crewService = _ref.read(crewServiceProvider);
      await crewService.createCrew(
        name: name,
        foremanId: foremanId,
        preferences: preferences,
        logoUrl: logoUrl,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateCrewPreferences({
    required String crewId,
    required CrewPreferences preferences,
  }) async {
    state = const AsyncValue.loading();
    try {
      final crewService = _ref.read(crewServiceProvider);
      await crewService.updateCrew(
        crewId: crewId,
        preferences: preferences,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for crew creation notifier
@riverpod
CrewCreationNotifier crewCreationNotifier(Ref ref) {
  return CrewCreationNotifier(ref);
}

/// Stream of crew creation state
@riverpod
AsyncValue<void> crewCreationState(Ref ref) {
  return ref.watch(crewCreationStateProvider);
}
