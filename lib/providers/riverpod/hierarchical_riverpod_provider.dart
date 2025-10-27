// Hierarchical Riverpod providers (manual, non-codegen version)
// Replaces prior @riverpod annotations and part file with explicit providers to
// avoid missing generated types like HierarchicalServiceRef, UnionRef, etc.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/hierarchical/hierarchical_types.dart';
import '../../models/user_model.dart';
import '../../services/hierarchical/hierarchical_service.dart';
import '../../services/hierarchical/hierarchical_initialization_service.dart';
import 'auth_riverpod_provider.dart';

// Service provider for hierarchical data operations
final hierarchicalServiceProvider = Provider<HierarchicalService>((ref) {
  final service = HierarchicalService();
  // Dispose the service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

// Service provider for hierarchical initialization orchestration
final hierarchicalInitializationServiceProvider =
    Provider<HierarchicalInitializationService>((ref) {
  final service = HierarchicalInitializationService(
    hierarchicalService: ref.watch(hierarchicalServiceProvider),
  );
  // Dispose the service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// State for hierarchical data
@immutable
class HierarchicalDataState {
  final HierarchicalData data;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  const HierarchicalDataState({
    required this.data,
    required this.isLoading,
    this.error,
    required this.lastUpdated,
  });

  HierarchicalDataState copyWith({
    HierarchicalData? data,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return HierarchicalDataState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasError => error != null;
  bool get isLoaded => !isLoading && !hasError;
  bool get isEmpty => data.locals.isEmpty && data.members.isEmpty && data.jobs.isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HierarchicalDataState &&
        other.data == data &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(data, isLoading, error, lastUpdated);
  }

  @override
  String toString() {
    return 'HierarchicalDataState('
        'isLoading: $isLoading, '
        'hasError: $hasError, '
        'isEmpty: $isEmpty, '
        'lastUpdated: $lastUpdated'
        ')';
  }
}

/// Notifier managing HierarchicalDataState (no code-gen types)
class HierarchicalDataNotifier extends Notifier<HierarchicalDataState> {
  late final HierarchicalService _hierarchicalService;
  late final HierarchicalInitializationService _initializationService;

  Timer? _refreshTimer;
  StreamSubscription<HierarchicalData>? _dataSubscription;

  @override
  HierarchicalDataState build() {
    _hierarchicalService = ref.watch(hierarchicalServiceProvider);
    _initializationService = ref.watch(hierarchicalInitializationServiceProvider);

    // Listen to user authentication changes
    ref.listen<AsyncValue<User?>>(
      authStateStreamProvider,
      (previous, next) {
        next.when(
          data: (user) {
            if (user != null) {
              // User authenticated, initialize hierarchical data
              _initializeForUser();
            } else {
              // User signed out, clear hierarchical data
              _clearData();
            }
          },
          loading: () {
            // Auth loading, keep current state
          },
          error: (error, stackTrace) {
            // Auth error, try to initialize as guest
            _initializeAsGuest();
          },
        );
      },
    );

    // Listen to hierarchical service data stream
    _dataSubscription = _hierarchicalService.hierarchicalDataStream.listen(
      (data) {
        state = state.copyWith(
          data: data,
          error: null,
          lastUpdated: DateTime.now(),
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
          lastUpdated: DateTime.now(),
        );
      },
    );

    // Set up periodic refresh timer (every 5 minutes)
    _setupRefreshTimer();

    // Clean up on provider disposal
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _dataSubscription?.cancel();
    });

    // Initial state
    return HierarchicalDataState(
      data: HierarchicalData.empty(),
      isLoading: false,
      error: null,
      lastUpdated: DateTime.now(),
    );
  }

  /// Initializes hierarchical data for the current authenticated user
  Future<void> _initializeForUser() async {
    debugPrint('[HierarchicalDataNotifier] Initializing for authenticated user...');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _initializationService.initializeForCurrentUser();

      state = state.copyWith(
        data: data,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
      );

      debugPrint('[HierarchicalDataNotifier] User initialization completed');
    } catch (e) {
      debugPrint('[HierarchicalDataNotifier] User initialization failed: $e');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Initializes hierarchical data for guest users
  Future<void> _initializeAsGuest() async {
    debugPrint('[HierarchicalDataNotifier] Initializing as guest...');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _initializationService.initializeForCurrentUser();

      state = state.copyWith(
        data: data,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
      );

      debugPrint('[HierarchicalDataNotifier] Guest initialization completed');
    } catch (e) {
      debugPrint('[HierarchicalDataNotifier] Guest initialization failed: $e');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Clears all hierarchical data
  void _clearData() {
    debugPrint('[HierarchicalDataNotifier] Clearing hierarchical data...');

    _hierarchicalService.clearCache();
    _initializationService.reset();

    state = state.copyWith(
      data: HierarchicalData.empty(),
      isLoading: false,
      error: null,
      lastUpdated: DateTime.now(),
    );
  }

  /// Sets up periodic refresh timer
  void _setupRefreshTimer() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (state.data.isValid() && !state.isLoading) {
        _refreshData();
      }
    });
  }

  /// Public refresh method
  Future<void> refreshData({bool force = false}) async {
    if (state.isLoading && !force) {
      debugPrint('[HierarchicalDataNotifier] Refresh already in progress, skipping...');
      return;
    }

    debugPrint('[HierarchicalDataNotifier] Refreshing hierarchical data...');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _initializationService.initializeForCurrentUser(
        forceRefresh: true,
      );

      state = state.copyWith(
        data: data,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
      );

      debugPrint('[HierarchicalDataNotifier] Data refresh completed');
    } catch (e) {
      debugPrint('[HierarchicalDataNotifier] Data refresh failed: $e');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Internal refresh method (called by timer)
  Future<void> _refreshData() async {
    debugPrint('[HierarchicalDataNotifier] Performing periodic refresh...');

    try {
      await _hierarchicalService.refreshHierarchicalData();
      debugPrint('[HierarchicalDataNotifier] Periodic refresh completed');
    } catch (e) {
      debugPrint('[HierarchicalDataNotifier] Periodic refresh failed: $e');
      // Don't update state for background refresh failures
    }
  }

  /// Reinitializes data when user preferences change
  Future<void> reinitializeForUserPreferences(UserModel updatedUser) async {
    debugPrint('[HierarchicalDataNotifier] Reinitializing for updated user preferences...');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _initializationService.reinitializeForUserPreferences(updatedUser);

      state = state.copyWith(
        data: data,
        isLoading: false,
        error: null,
        lastUpdated: DateTime.now(),
      );

      debugPrint('[HierarchicalDataNotifier] User preferences reinitialization completed');
    } catch (e) {
      debugPrint('[HierarchicalDataNotifier] User preferences reinitialization failed: $e');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Searches hierarchical data
  HierarchicalSearchResult search(String query) {
    return _hierarchicalService.search(query);
  }

  /// Gets locals for a specific location
  List<LocalsRecord> getLocalsByLocation(String location) {
    return state.data.getLocalsByLocation(location);
  }

  /// Gets members for a specific local
  List<UnionMember> getMembersForLocal(int localNumber) {
    return state.data.getMembersForLocal(localNumber);
  }

  /// Gets jobs for a specific local
  List<Job> getJobsForLocal(int localNumber) {
    return state.data.getJobsForLocal(localNumber);
  }

  /// Gets available jobs
  List<Job> getAvailableJobs() {
    return state.data.getAvailableJobs();
  }

  /// Gets available members
  List<UnionMember> getAvailableMembers() {
    return state.data.getAvailableMembers();
  }

  /// Checks if data is fresh
  bool get isDataFresh {
    return DateTime.now().difference(state.lastUpdated).inMinutes < 5;
  }

  /// Performs health check
  Future<HierarchicalHealthCheckResult> performHealthCheck() async {
    return await _initializationService.performHealthCheck();
  }
}

// Primary hierarchical data provider (Notifier API, no code-gen)
final hierarchicalDataProvider =
    NotifierProvider<HierarchicalDataNotifier, HierarchicalDataState>(
  HierarchicalDataNotifier.new,
);

// Initialization state stream provider
final hierarchicalInitializationStateProvider =
    StreamProvider<HierarchicalInitializationState>((ref) {
  final service = ref.watch(hierarchicalInitializationServiceProvider);
  return service.initializationStateStream;
});

// Read-only slices of the hierarchical data
final unionProvider = Provider<Union?>((ref) {
  return ref.watch(hierarchicalDataProvider).data.union;
});

final localsProvider = Provider<Map<int, LocalsRecord>>((ref) {
  return ref.watch(hierarchicalDataProvider).data.locals;
});

final membersProvider = Provider<Map<String, UnionMember>>((ref) {
  return ref.watch(hierarchicalDataProvider).data.members;
});

final jobsProvider = Provider<Map<String, Job>>((ref) {
  return ref.watch(hierarchicalDataProvider).data.jobs;
});

final hierarchicalStatsProvider = Provider<HierarchicalStats>((ref) {
  return ref.watch(hierarchicalDataProvider).data.stats;
});

/// State for hierarchical search
@immutable
class HierarchicalSearchState {
  final String query;
  final HierarchicalSearchResult? results;
  final bool isSearching;
  final String? error;

  const HierarchicalSearchState({
    required this.query,
    this.results,
    required this.isSearching,
    this.error,
  });

  HierarchicalSearchState copyWith({
    String? query,
    HierarchicalSearchResult? results,
    bool? isSearching,
    String? error,
  }) {
    return HierarchicalSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }

  bool get hasError => error != null;
  bool get hasResults => results != null && results!.hasResults;
  bool get isEmpty => query.isEmpty && !isSearching && !hasResults;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HierarchicalSearchState &&
        other.query == query &&
        other.results == results &&
        other.isSearching == isSearching &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(query, results, isSearching, error);
  }

  @override
  String toString() {
    return 'HierarchicalSearchState('
        'query: "$query", '
        'isSearching: $isSearching, '
        'hasResults: $hasResults, '
        'hasError: $hasError'
        ')';
  }
}

/// Hierarchical search notifier (Notifier API)
class HierarchicalSearchNotifier extends Notifier<HierarchicalSearchState> {
  @override
  HierarchicalSearchState build() {
    return const HierarchicalSearchState(
      query: '',
      results: null,
      isSearching: false,
      error: null,
    );
  }

  /// Searches hierarchical data
  Future<void> search(String query) async {
    if (state.query == query && state.results != null) {
      return; // Same query, no need to search again
    }

    state = state.copyWith(
      query: query,
      isSearching: true,
      error: null,
    );

    try {
      final hierarchicalNotifier = ref.read(hierarchicalDataProvider.notifier);
      final results = hierarchicalNotifier.search(query);

      state = state.copyWith(
        results: results,
        isSearching: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  /// Clears search results
  void clearSearch() {
    state = const HierarchicalSearchState(
      query: '',
      results: null,
      isSearching: false,
      error: null,
    );
  }
}

// Provider for search state (Notifier API)
final hierarchicalSearchNotifierProvider =
    NotifierProvider<HierarchicalSearchNotifier, HierarchicalSearchState>(
  HierarchicalSearchNotifier.new,
);