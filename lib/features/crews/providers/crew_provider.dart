import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crew.dart';
import '../models/crew_member.dart';
import '../models/crew_enums.dart';
import '../services/crew_service.dart';

/// Provider for CrewService instance
final crewServiceProvider = Provider<CrewService>((ref) {
  return CrewService();
});

/// State class for crew-related data
class CrewState {
  final bool isLoading;
  final List<Crew> userCrews;
  final List<Crew> searchResults;
  final String searchQuery;
  final Crew? selectedCrew;
  final List<CrewMember> selectedCrewMembers;
  final String? errorMessage;
  final bool hasMore;
  final bool isOffline;

  const CrewState({
    this.isLoading = false,
    this.userCrews = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.selectedCrew,
    this.selectedCrewMembers = const [],
    this.errorMessage,
    this.hasMore = true,
    this.isOffline = false,
  });

  CrewState copyWith({
    bool? isLoading,
    List<Crew>? userCrews,
    List<Crew>? searchResults,
    String? searchQuery,
    Crew? selectedCrew,
    List<CrewMember>? selectedCrewMembers,
    String? errorMessage,
    bool? hasMore,
    bool? isOffline,
  }) {
    return CrewState(
      isLoading: isLoading ?? this.isLoading,
      userCrews: userCrews ?? this.userCrews,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCrew: selectedCrew ?? this.selectedCrew,
      selectedCrewMembers: selectedCrewMembers ?? this.selectedCrewMembers,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  /// Clear error message
  CrewState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Set loading state
  CrewState setLoading(bool loading) {
    return copyWith(isLoading: loading, errorMessage: null);
  }

  /// Set error state with electrical worker context
  CrewState setError(String error) {
    // Provide electrical worker friendly error messages
    String userFriendlyError = error;
    if (error.contains('network')) {
      userFriendlyError = 'Network connection issues - check your connection in the field';
    } else if (error.contains('permission')) {
      userFriendlyError = 'Permission denied - contact your union local for access';
    } else if (error.contains('not found')) {
      userFriendlyError = 'Crew not found - it may have been disbanded';
    }
    
    return copyWith(
      isLoading: false,
      errorMessage: userFriendlyError,
    );
  }
}

/// Crew state notifier for electrical worker crews
class CrewNotifier extends StateNotifier<CrewState> {
  final CrewService _crewService;
  Timer? _searchDebounceTimer;
  StreamSubscription? _userCrewsSubscription;
  StreamSubscription? _selectedCrewSubscription;
  StreamSubscription? _crewMembersSubscription;

  CrewNotifier(this._crewService) : super(const CrewState());

  /// Initialize crew data for a user
  Future<void> initializeUserCrews(String userId) async {
    try {
      state = state.setLoading(true);

      // Set up real-time listener for user's crews
      _userCrewsSubscription?.cancel();
      _userCrewsSubscription = _crewService.getUserCrewsStream(userId).listen(
        (crews) {
          dev.log('Received ${crews.length} crews for user $userId');
          state = state.copyWith(
            userCrews: crews,
            isLoading: false,
            isOffline: false,
          );
        },
        onError: (error) {
          dev.log('Error listening to user crews: $error');
          state = state.setError(error.toString());
        },
      );
    } catch (e) {
      dev.log('Error initializing user crews: $e');
      state = state.setError(e.toString());
    }
  }

  /// Create a new crew
  Future<Crew?> createCrew({
    required String creatorId,
    required String name,
    String? description,
    String? imageUrl,
    List<String>? classifications,
    List<JobType>? jobTypes,
    int maxMembers = 10,
    bool isPublic = false,
  }) async {
    try {
      state = state.setLoading(true);

      final crew = await _crewService.createCrew(
        creatorId: creatorId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        classifications: classifications,
        jobTypes: jobTypes,
        maxMembers: maxMembers,
        isPublic: isPublic,
      );

      dev.log('Created crew: ${crew.name} (${crew.id})');
      
      // Update local state immediately for better UX
      final updatedCrews = [...state.userCrews, crew];
      state = state.copyWith(
        userCrews: updatedCrews,
        isLoading: false,
      );

      return crew;
    } catch (e) {
      dev.log('Error creating crew: $e');
      state = state.setError(e.toString());
      return null;
    }
  }

  /// Update crew details
  Future<bool> updateCrew({
    required String crewId,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? classifications,
    List<JobType>? jobTypes,
    int? maxMembers,
    bool? isPublic,
  }) async {
    try {
      state = state.setLoading(true);

      final updatedCrew = await _crewService.updateCrew(
        crewId: crewId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        classifications: classifications,
        jobTypes: jobTypes,
        maxMembers: maxMembers,
        isPublic: isPublic,
      );

      dev.log('Updated crew: ${updatedCrew.name}');

      // Update local state
      final updatedCrews = state.userCrews.map((crew) {
        return crew.id == crewId ? updatedCrew : crew;
      }).toList();

      state = state.copyWith(
        userCrews: updatedCrews,
        selectedCrew: updatedCrew,
        isLoading: false,
      );

      return true;
    } catch (e) {
      dev.log('Error updating crew: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Delete a crew
  Future<bool> deleteCrew(String crewId, String userId) async {
    try {
      state = state.setLoading(true);

      await _crewService.deleteCrew(crewId: crewId, userId: userId);

      dev.log('Deleted crew: $crewId');

      // Remove from local state
      final updatedCrews = state.userCrews.where((crew) => crew.id != crewId).toList();
      state = state.copyWith(
        userCrews: updatedCrews,
        selectedCrew: state.selectedCrew?.id == crewId ? null : state.selectedCrew,
        isLoading: false,
      );

      return true;
    } catch (e) {
      dev.log('Error deleting crew: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Search for crews with debouncing
  void searchCrews(String query) {
    _searchDebounceTimer?.cancel();
    state = state.copyWith(searchQuery: query);

    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        state = state.setLoading(true);

        // For now, search within user's crews
        // TODO: Implement global crew search when needed
        final results = state.userCrews.where((crew) {
          return crew.name.toLowerCase().contains(query.toLowerCase()) ||
                 (crew.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();

        state = state.copyWith(
          searchResults: results,
          isLoading: false,
        );
      } catch (e) {
        dev.log('Error searching crews: $e');
        state = state.setError(e.toString());
      }
    });
  }

  /// Select a crew to view details
  Future<void> selectCrew(String crewId) async {
    try {
      // Set loading for crew details
      state = state.copyWith(isLoading: true);

      // Set up real-time listeners for selected crew
      _selectedCrewSubscription?.cancel();
      _crewMembersSubscription?.cancel();

      _selectedCrewSubscription = _crewService.getCrewStream(crewId).listen(
        (crew) {
          if (crew != null) {
            state = state.copyWith(
              selectedCrew: crew,
              isLoading: false,
            );
          }
        },
        onError: (error) {
          dev.log('Error listening to crew: $error');
          state = state.setError(error.toString());
        },
      );

      _crewMembersSubscription = _crewService.getCrewMembersStream(crewId).listen(
        (members) {
          dev.log('Received ${members.length} members for crew $crewId');
          state = state.copyWith(
            selectedCrewMembers: members,
            isLoading: false,
          );
        },
        onError: (error) {
          dev.log('Error listening to crew members: $error');
          state = state.setError(error.toString());
        },
      );
    } catch (e) {
      dev.log('Error selecting crew: $e');
      state = state.setError(e.toString());
    }
  }

  /// Invite member to crew
  Future<bool> inviteMember({
    required String crewId,
    required String invitedUserId,
    required String invitedBy,
    String? message,
  }) async {
    try {
      state = state.setLoading(true);

      await _crewService.inviteMember(
        crewId: crewId,
        invitedUserId: invitedUserId,
        invitedBy: invitedBy,
        message: message,
      );

      dev.log('Invited user $invitedUserId to crew $crewId');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      dev.log('Error inviting member: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Accept crew invitation
  Future<bool> acceptInvitation({
    required String crewId,
    required String userId,
  }) async {
    try {
      state = state.setLoading(true);

      await _crewService.acceptInvitation(
        crewId: crewId,
        userId: userId,
      );

      dev.log('Accepted invitation to crew $crewId');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      dev.log('Error accepting invitation: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Decline crew invitation
  Future<bool> declineInvitation({
    required String crewId,
    required String userId,
  }) async {
    try {
      await _crewService.declineInvitation(
        crewId: crewId,
        userId: userId,
      );

      dev.log('Declined invitation to crew $crewId');
      return true;
    } catch (e) {
      dev.log('Error declining invitation: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Remove member from crew
  Future<bool> removeMember({
    required String crewId,
    required String memberId,
    required String removedBy,
  }) async {
    try {
      state = state.setLoading(true);

      await _crewService.removeMember(
        crewId: crewId,
        memberId: memberId,
        removedBy: removedBy,
      );

      dev.log('Removed member $memberId from crew $crewId');
      
      // Update local crew members
      final updatedMembers = state.selectedCrewMembers
          .where((member) => member.userId != memberId)
          .toList();
      
      state = state.copyWith(
        selectedCrewMembers: updatedMembers,
        isLoading: false,
      );

      return true;
    } catch (e) {
      dev.log('Error removing member: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Update member preferences
  Future<bool> updateMemberPreferences({
    required String crewId,
    required String userId,
    List<String>? availableDays,
    List<String>? preferredShifts,
    bool? willingToTravel,
    int? maxTravelDistance,
  }) async {
    try {
      await _crewService.updateMemberPreferences(
        crewId: crewId,
        userId: userId,
        availableDays: availableDays,
        preferredShifts: preferredShifts,
        willingToTravel: willingToTravel,
        maxTravelDistance: maxTravelDistance,
      );

      dev.log('Updated member preferences for $userId in crew $crewId');
      return true;
    } catch (e) {
      dev.log('Error updating member preferences: $e');
      state = state.setError(e.toString());
      return false;
    }
  }

  /// Clear selected crew and stop listening
  void clearSelectedCrew() {
    _selectedCrewSubscription?.cancel();
    _crewMembersSubscription?.cancel();
    state = state.copyWith(
      selectedCrew: null,
      selectedCrewMembers: [],
    );
  }

  /// Clear search results
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
    );
  }

  /// Handle offline mode for field workers
  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
    if (isOffline) {
      dev.log('Crew provider: Offline mode enabled for field work');
      // Cancel real-time listeners to save battery/data
      _userCrewsSubscription?.cancel();
      _selectedCrewSubscription?.cancel();
      _crewMembersSubscription?.cancel();
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _userCrewsSubscription?.cancel();
    _selectedCrewSubscription?.cancel();
    _crewMembersSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for crew state management
final crewProvider = StateNotifierProvider<CrewNotifier, CrewState>((ref) {
  final crewService = ref.watch(crewServiceProvider);
  return CrewNotifier(crewService);
});

/// Provider for user's crews stream
final userCrewsStreamProvider = StreamProvider.family<List<Crew>, String>((ref, userId) {
  final crewService = ref.watch(crewServiceProvider);
  return crewService.getUserCrewsStream(userId);
});

/// Provider for specific crew stream
final crewStreamProvider = StreamProvider.family<Crew?, String>((ref, crewId) {
  final crewService = ref.watch(crewServiceProvider);
  return crewService.getCrewStream(crewId);
});

/// Provider for crew members stream
final crewMembersStreamProvider = StreamProvider.family<List<CrewMember>, String>((ref, crewId) {
  final crewService = ref.watch(crewServiceProvider);
  return crewService.getCrewMembersStream(crewId);
});

/// Provider for user's crew count
final userCrewCountProvider = Provider<int>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.userCrews.length;
});

/// Provider for selected crew member count
final selectedCrewMemberCountProvider = Provider<int>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.selectedCrewMembers.length;
});

/// Provider for checking if user can create more crews (max 5)
final canCreateMoreCrewsProvider = Provider<bool>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.userCrews.length < 5;
});

/// Provider for search results count
final searchResultsCountProvider = Provider<int>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.searchResults.length;
});

/// Provider for checking if search is active
final hasActiveCrewSearchProvider = Provider<bool>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.searchQuery.isNotEmpty;
});

/// Provider for checking if crew is loading
final crewLoadingProvider = Provider<bool>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.isLoading;
});

/// Provider for crew error state
final crewErrorProvider = Provider<String?>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.errorMessage;
});

/// Provider for offline mode status
final crewOfflineModeProvider = Provider<bool>((ref) {
  final crewState = ref.watch(crewProvider);
  return crewState.isOffline;
});
