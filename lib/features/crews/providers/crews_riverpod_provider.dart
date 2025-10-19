// lib/features/crews/providers/crews_riverpod_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';
import 'package:journeyman_jobs/features/crews/services/job_matching_service_impl.dart';
import 'package:journeyman_jobs/features/crews/services/job_sharing_service_impl.dart';
import '../../../providers/riverpod/app_state_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Note: SelectedCrewNotifier and selectedCrewProvider are defined in core_providers.dart
// to maintain compatibility across the app

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

  /// Creates a new crew with the specified preferences.
  ///
  /// Requires user authentication before creating crew.
  /// Implements defense-in-depth security by checking auth at the provider level.
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated.
  /// Throws [InsufficientPermissionsException] if user lacks permission.
  Future<void> createCrewWithPreferences({
    required String name,
    required String foremanId,
    required CrewPreferences preferences,
    String? logoUrl,
    int retryCount = 0,
  }) async {
    // WAVE 4: Auth check before data access (defense-in-depth)
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      throw UnauthenticatedException(
        'User must be authenticated to create a crew',
      );
    }

    // Verify user is creating crew for themselves
    if (currentUser.uid != foremanId) {
      throw InsufficientPermissionsException(
        'You can only create crews for yourself',
        requiredPermission: 'crew:create-self',
      );
    }

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
      // WAVE 4: Enhanced error handling with token refresh and retry logic
      if (e is FirebaseException &&
          (e.code == 'permission-denied' || e.code == 'unauthenticated')) {

        // Attempt token refresh once
        final tokenRefreshed = await _attemptTokenRefresh();

        if (tokenRefreshed && retryCount < 1) {
          // Retry operation once after token refresh
          return createCrewWithPreferences(
            name: name,
            foremanId: foremanId,
            preferences: preferences,
            logoUrl: logoUrl,
            retryCount: retryCount + 1,
          );
        } else {
          // Token refresh failed or retry exhausted - redirect to auth
          final userError = _mapFirebaseError(e);
          if (kDebugMode) {
            print('[CrewsProvider] Error creating crew: $e');
          }
          state = AsyncValue.error(
            UnauthenticatedException('Session expired. Please sign in again.'),
            stack,
          );
          return;
        }
      }

      // Map error to user-friendly message
      final userError = _mapFirebaseError(e);
      if (kDebugMode) {
        print('[CrewsProvider] Error creating crew: $userError');
      }

      state = AsyncValue.error(e, stack);
    }
  }

  /// Updates crew preferences.
  ///
  /// Requires user authentication and proper permissions before updating.
  /// Implements defense-in-depth security by checking auth at the provider level.
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated.
  /// Throws [InsufficientPermissionsException] if user lacks permission.
  Future<void> updateCrewPreferences({
    required String crewId,
    required CrewPreferences preferences,
    int retryCount = 0,
  }) async {
    // WAVE 4: Auth check before data access (defense-in-depth)
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      throw UnauthenticatedException(
        'User must be authenticated to update crew preferences',
      );
    }

    // Check if user has permission to edit crew
    final hasPermission = _ref.read(hasCrewPermissionProvider(crewId, 'canEditCrewInfo'));
    if (!hasPermission) {
      throw InsufficientPermissionsException(
        'You do not have permission to edit this crew',
        requiredPermission: 'crew:edit',
      );
    }

    state = const AsyncValue.loading();
    try {
      final crewService = _ref.read(crewServiceProvider);
      await crewService.updateCrew(
        crewId: crewId,
        preferences: preferences,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // WAVE 4: Enhanced error handling with token refresh and retry logic
      if (e is FirebaseException &&
          (e.code == 'permission-denied' || e.code == 'unauthenticated')) {

        // Attempt token refresh once
        final tokenRefreshed = await _attemptTokenRefresh();

        if (tokenRefreshed && retryCount < 1) {
          // Retry operation once after token refresh
          return updateCrewPreferences(
            crewId: crewId,
            preferences: preferences,
            retryCount: retryCount + 1,
          );
        } else {
          // Token refresh failed or retry exhausted - redirect to auth
          final userError = _mapFirebaseError(e);
          if (kDebugMode) {
            print('[CrewsProvider] Error updating crew: $e');
          }
          state = AsyncValue.error(
            UnauthenticatedException('Session expired. Please sign in again.'),
            stack,
          );
          return;
        }
      }

      // Map error to user-friendly message
      final userError = _mapFirebaseError(e);
      if (kDebugMode) {
        print('[CrewsProvider] Error updating crew: $userError');
      }

      state = AsyncValue.error(e, stack);
    }
  }

  /// Attempts to refresh the user's authentication token.
  ///
  /// Returns true if token refresh succeeded, false otherwise.
  /// Used for automatic recovery from expired token errors.
  Future<bool> _attemptTokenRefresh() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Force token refresh
      await user.getIdToken(true);

      if (kDebugMode) {
        print('[CrewsProvider] Token refresh successful');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[CrewsProvider] Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Maps Firebase errors to user-friendly error messages.
  ///
  /// Provides clear, actionable guidance for common error scenarios.
  String _mapFirebaseError(Object error) {
    if (error is UnauthenticatedException) {
      return 'Please sign in to manage crews';
    }

    if (error is InsufficientPermissionsException) {
      return error.message;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action. Please sign in.';
        case 'unauthenticated':
          return 'Authentication required. Please sign in to continue.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'deadline-exceeded':
          return 'Request timed out. Please try again.';
        case 'not-found':
          return 'The requested crew was not found.';
        case 'already-exists':
          return 'A crew with this name already exists.';
        default:
          return 'An error occurred: ${error.message ?? 'Unknown error'}';
      }
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-token-expired':
          return 'Your session has expired. Please sign in again.';
        case 'user-not-found':
          return 'User account not found. Please sign in.';
        case 'invalid-user-token':
          return 'Invalid session. Please sign in again.';
        default:
          return 'Authentication error: ${error.message ?? 'Unknown error'}';
      }
    }

    return 'An unexpected error occurred. Please try again.';
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
