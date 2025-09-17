import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../models/crew_member.dart';
import '../models/crew_enums.dart';
import '../services/crew_member_service.dart';

part 'crew_member_provider.g.dart';

/// Provider for CrewMemberService instance
@Riverpod()
CrewMemberService crewMemberService(CrewMemberServiceRef ref) => CrewMemberService();

/// State class for crew member management
class CrewMemberState {
  final bool isLoading;
  final Map<String, List<CrewMember>> membersByCrewId;
  final List<Map<String, dynamic>> pendingInvitations;
  final String? errorMessage;
  final bool isInviting;
  final bool isUpdatingRole;
  final bool isRemovingMember;
  final Set<String> loadingOperations;

  const CrewMemberState({
    this.isLoading = false,
    this.membersByCrewId = const {},
    this.pendingInvitations = const [],
    this.errorMessage,
    this.isInviting = false,
    this.isUpdatingRole = false,
    this.isRemovingMember = false,
    this.loadingOperations = const {},
  });

  CrewMemberState copyWith({
    bool? isLoading,
    Map<String, List<CrewMember>>? membersByCrewId,
    List<Map<String, dynamic>>? pendingInvitations,
    String? errorMessage,
    bool? isInviting,
    bool? isUpdatingRole,
    bool? isRemovingMember,
    Set<String>? loadingOperations,
  }) {
    return CrewMemberState(
      isLoading: isLoading ?? this.isLoading,
      membersByCrewId: membersByCrewId ?? this.membersByCrewId,
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      errorMessage: errorMessage,
      isInviting: isInviting ?? this.isInviting,
      isUpdatingRole: isUpdatingRole ?? this.isUpdatingRole,
      isRemovingMember: isRemovingMember ?? this.isRemovingMember,
      loadingOperations: loadingOperations ?? this.loadingOperations,
    );
  }

  /// Get members for specific crew
  List<CrewMember> getCrewMembers(String crewId) {
    return membersByCrewId[crewId] ?? [];
  }

  /// Check if a specific operation is loading
  bool isOperationLoading(String operation) {
    return loadingOperations.contains(operation);
  }

  /// Check if crew has specific role filled
  bool hasRole(String crewId, CrewRole role) {
    final members = getCrewMembers(crewId);
    return members.any((member) => member.role == role && member.isActive);
  }

  /// Get members by role
  List<CrewMember> getMembersByRole(String crewId, CrewRole role) {
    final members = getCrewMembers(crewId);
    return members.where((member) => member.role == role && member.isActive).toList();
  }

  /// Get active member count for crew
  int getActiveMemberCount(String crewId) {
    final members = getCrewMembers(crewId);
    return members.where((member) => member.isActive).length;
  }

  /// Get foreman for crew
  CrewMember? getForeman(String crewId) {
    final members = getCrewMembers(crewId);
    return members.where((member) => member.role == CrewRole.foreman && member.isActive).firstWhereOrNull((element) => true);
  }

  /// Get leadership members (foreman and lead journeymen)
  List<CrewMember> getLeadership(String crewId) {
    final members = getCrewMembers(crewId);
    return members.where((member) =>
      member.isActive &&
      (member.role == CrewRole.foreman || member.role == CrewRole.leadJourneyman)
    ).toList();
  }
}

/// CrewMember provider with IBEW compliance and real-time updates
class CrewMemberNotifier extends StateNotifier<CrewMemberState> {
  final CrewMemberService _service;
  final Map<String, StreamSubscription> _memberSubscriptions = {};
  Timer? _invitationRefreshTimer;

  CrewMemberNotifier(this._service) : super(const CrewMemberState());

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _memberSubscriptions.values) {
      subscription.cancel();
    }
    _invitationRefreshTimer?.cancel();
    super.dispose();
  }

  /// Subscribe to crew members updates
  void subscribeToCrewMembers(String crewId) {
    // Cancel existing subscription for this crew
    _memberSubscriptions[crewId]?.cancel();

    _memberSubscriptions[crewId] = _service.getCrewMembersStream(crewId).listen(
      (members) {
        final updatedMembersMap = Map<String, List<CrewMember>>.from(state.membersByCrewId);
        updatedMembersMap[crewId] = members;
        
        state = state.copyWith(
          membersByCrewId: updatedMembersMap,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        dev.log('Error loading crew members: $error', name: 'CrewMemberProvider');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load crew members: ${error.toString()}',
        );
      },
    );
  }

  /// Send invitation to join crew
  Future<String> inviteMember({
    required String crewId,
    required Map<String, dynamic> invitationData,
  }) async {
    const operation = 'invite_member';
    
    try {
      state = state.copyWith(
        isInviting: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      final invitationId = await _service.sendInvitation(
        crewId: crewId,
        invitedBy: invitationData['invitedBy'] ?? '',  // Should be passed in data
        recipientId: invitationData['recipientId'] ?? invitationData['inviteValue'] ?? '',  // Use inviteValue as fallback
        message: invitationData['message'],
      );

      state = state.copyWith(
        isInviting: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Member invitation sent successfully: $invitationId', name: 'CrewMemberProvider');
      return invitationId;
    } catch (error) {
      dev.log('Error inviting member: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isInviting: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to invite member: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Update member role with IBEW validation
  Future<void> updateMemberRole({
    required String crewId,
    required String memberId,
    required CrewRole newRole,
  }) async {
    const operation = 'update_role';
    
    try {
      state = state.copyWith(
        isUpdatingRole: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      await _service.updateMemberRole(
        crewId: crewId,
        memberId: memberId,
        newRole: newRole,
        updatedBy: 'current-user-id', // TODO: Get current user ID from FirebaseAuth
      );

      state = state.copyWith(
        isUpdatingRole: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Member role updated successfully', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error updating member role: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isUpdatingRole: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to update member role: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Remove member from crew
  Future<void> removeMember({
    required String crewId,
    required String memberId,
  }) async {
    const operation = 'remove_member';
    
    try {
      state = state.copyWith(
        isRemovingMember: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      await _service.removeMember(
        crewId: crewId,
        memberId: memberId,
        removedBy: 'current-user-id', // TODO: Get current user ID from FirebaseAuth
        reason: 'Removed by admin',  // Default reason
      );

      state = state.copyWith(
        isRemovingMember: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Member removed successfully', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error removing member: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isRemovingMember: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to remove member: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Accept invitation to join crew
  Future<void> acceptInvitation(String invitationId) async {
    const operation = 'accept_invitation';
    
    try {
      state = state.copyWith(
        isLoading: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      await _service.acceptInvitation(invitationId);

      // Refresh invitations after accepting
      await refreshInvitations();

      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Invitation accepted successfully', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error accepting invitation: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to accept invitation: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Decline invitation to join crew
  Future<void> declineInvitation(String invitationId) async {
    const operation = 'decline_invitation';
    
    try {
      state = state.copyWith(
        isLoading: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      await _service.declineInvitation(invitationId);

      // Refresh invitations after declining
      await refreshInvitations();

      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Invitation declined successfully', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error declining invitation: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to decline invitation: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Load pending invitations
  Future<void> loadInvitations() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final invitations = await _service.getPendingInvitations();

      state = state.copyWith(
        isLoading: false,
        pendingInvitations: invitations,
      );

      dev.log('Loaded ${invitations.length} pending invitations', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error loading invitations: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load invitations: ${error.toString()}',
      );
    }
  }

  /// Refresh pending invitations
  Future<void> refreshInvitations() async {
    await loadInvitations();
  }

  /// Start periodic invitation refresh
  void startInvitationRefresh() {
    _invitationRefreshTimer?.cancel();
    _invitationRefreshTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => refreshInvitations(),
    );
    
    // Load initial invitations
    loadInvitations();
  }

  /// Stop periodic invitation refresh
  void stopInvitationRefresh() {
    _invitationRefreshTimer?.cancel();
    _invitationRefreshTimer = null;
  }

  /// Update member preferences
  Future<void> updateMemberPreferences({
    required String crewId,
    required String memberId,
    required CrewMemberPreferences preferences,
  }) async {
    const operation = 'update_preferences';
    
    try {
      state = state.copyWith(
        isLoading: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      await _service.updateMemberPreferences(
        crewId: crewId,
        userId: memberId,
        workPreferences: preferences,
      );

      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Member preferences updated successfully', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error updating member preferences: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to update member preferences: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Update member availability
  Future<void> updateMemberAvailability({
    required String crewId,
    required String memberId,
    required MemberAvailability availability,
  }) async {
    const operation = 'update_availability';
    
    try {
      state = state.copyWith(
        isLoading: true,
        loadingOperations: {...state.loadingOperations, operation},
        errorMessage: null,
      );

      await _service.updateMemberAvailability(
        crewId: crewId,
        userId: memberId,
        availability: availability,
      );

      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
      );

      dev.log('Member availability updated successfully', name: 'CrewMemberProvider');
    } catch (error) {
      dev.log('Error updating member availability: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isLoading: false,
        loadingOperations: state.loadingOperations.difference({operation}),
        errorMessage: 'Failed to update member availability: ${error.toString()}',
      );
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Refresh crew members
  Future<void> refreshCrewMembers(String crewId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Re-subscribe to get fresh data
      subscribeToCrewMembers(crewId);
    } catch (error) {
      dev.log('Error refreshing crew members: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh crew members: ${error.toString()}',
      );
    }
  }

  /// Get specific crew member
  Future<CrewMember?> getCrewMember(String crewId, String userId) async {
    try {
      return await _service.getCrewMember(crewId, userId);
    } catch (error) {
      dev.log('Error getting crew member: $error', name: 'CrewMemberProvider');
      state = state.copyWith(
        errorMessage: 'Failed to get crew member: ${error.toString()}',
      );
      return null;
    }
  }
}

/// Main provider for crew member state management
@Riverpod()
class CrewMemberStateNotifier extends _$CrewMemberStateNotifier {
  @override
  CrewMemberState build() {
    final service = ref.watch(crewMemberServiceProvider);
    return CrewMemberNotifier(service).state;
  }
}

/// Provider for crew members by crew ID with real-time updates
@Riverpod()
Stream<List<CrewMember>> crewMembersStream(CrewMembersStreamRef ref, String crewId) {
  final service = ref.watch(crewMemberServiceProvider);
  return service.getCrewMembersStream(crewId);
}

/// Provider for pending invitations
@Riverpod()
Future<List<Map<String, dynamic>>> pendingInvitations(PendingInvitationsRef ref) async {
  final service = ref.watch(crewMemberServiceProvider);
  return await service.getPendingInvitations();
}

/// Provider for specific crew member details
@Riverpod()
Future<CrewMember?> crewMemberDetails(CrewMemberDetailsRef ref, String crewId, String userId) async {
  final service = ref.watch(crewMemberServiceProvider);
  return await service.getCrewMember(crewId, userId);
}

/// Legacy provider for crew member state management (keeping for compatibility)
final crewMemberProvider = StateNotifierProvider<CrewMemberNotifier, CrewMemberState>((ref) {
  final service = ref.watch(crewMemberServiceProvider);
  return CrewMemberNotifier(service);
});

/// Provider for crew member count by crew
final crewMemberCountProvider = StreamProvider.family<int, String>((ref, crewId) {
  final membersStream = ref.watch(crewMembersStreamProvider(crewId));
  return membersStream.when(
    data: (members) => Stream.value(members.where((m) => m.isActive).length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

/// Provider for crew leadership (foreman and lead journeymen)
final crewLeadershipProvider = StreamProvider.family<List<CrewMember>, String>((ref, crewId) {
  final membersStream = ref.watch(crewMembersStreamProvider(crewId));
  return membersStream.when(
    data: (members) {
      final leadership = members.where((member) =>
        member.isActive &&
        (member.role == CrewRole.foreman || member.role == CrewRole.leadJourneyman)
      ).toList();
      return Stream.value(leadership);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Provider for crew foreman
final crewForemanProvider = StreamProvider.family<CrewMember?, String>((ref, crewId) {
  final membersStream = ref.watch(crewMembersStreamProvider(crewId));
  return membersStream.when(
    data: (members) {
      final foreman = members.where((member) =>
        member.isActive && member.role == CrewRole.foreman
      ).firstWhereOrNull((element) => true);
      return Stream.value(foreman);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Provider for member availability stream
final memberAvailabilityStreamProvider = StreamProvider.family<MemberAvailability?, ({String crewId, String userId})>((ref, params) {
  final service = ref.watch(crewMemberServiceProvider);
  return service.getMemberAvailabilityStream(params.crewId, params.userId);
});

/// Provider for checking if crew has specific role filled
final crewHasRoleProvider = StreamProvider.family<bool, ({String crewId, CrewRole role})>((ref, params) {
  final membersStream = ref.watch(crewMembersStreamProvider(params.crewId));
  return membersStream.when(
    data: (members) {
      final hasRole = members.any((member) =>
        member.isActive && member.role == params.role
      );
      return Stream.value(hasRole);
    },
    loading: () => Stream.value(false),
    error: (_, __) => Stream.value(false),
  );
});

/// Provider for members by role
final membersByRoleProvider = StreamProvider.family<List<CrewMember>, ({String crewId, CrewRole role})>((ref, params) {
  final membersStream = ref.watch(crewMembersStreamProvider(params.crewId));
  return membersStream.when(
    data: (members) {
      final roleMembers = members.where((member) =>
        member.isActive && member.role == params.role
      ).toList();
      return Stream.value(roleMembers);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
