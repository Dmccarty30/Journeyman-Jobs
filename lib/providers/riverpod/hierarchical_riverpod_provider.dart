import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/hierarchical/hierarchical_data_model.dart';
import '../../models/hierarchical/union_model.dart';
import '../../models/user_model.dart';
import '../../services/hierarchical/hierarchical_service.dart';
import '../../services/hierarchical/hierarchical_initialization_service.dart';
import 'auth_riverpod_provider.dart';

part 'hierarchical_riverpod_provider.g.dart';

/// Provider for the hierarchical service
@riverpod
HierarchicalService hierarchicalService(HierarchicalServiceRef ref) {
  final service = HierarchicalService();

  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Provider for the hierarchical initialization service
@riverpod
HierarchicalInitializationService hierarchicalInitializationService(
  HierarchicalInitializationServiceRef ref,
) {
  final service = HierarchicalInitializationService(
    hierarchicalService: ref.watch(hierarchicalServiceProvider),
  );

  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Provider for hierarchical data state
@riverpod
class HierarchicalDataNotifier extends _$HierarchicalDataNotifier {
  late final HierarchicalService _hierarchicalService;
  late final HierarchicalInitializationService _initializationService;
  Timer? _refreshTimer;
  StreamSubscription<HierarchicalData>? _dataSubscription;

  @override
  HierarchicalDataState build() {
    _hierarchicalService = ref.watch(hierarchicalServiceProvider);
    _initializationService = ref.watch(hierarchicalInitializationServiceProvider);

    // Start with empty state
    final initialState = HierarchicalDataState(
      data: HierarchicalData.empty(),
      isLoading: false,
      error: null,
      lastUpdated: DateTime.now(),
    );

    // Listen to user authentication changes
    ref.listen(authStateStreamProvider, (previous, next) {
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
    });

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
          error: error.toString(),
          lastUpdated: DateTime.now(),
        );
      },
    );

    // Set up periodic refresh timer (every 5 minutes)
    _setupRefreshTimer();

    // Clean up on dispose
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _dataSubscription?.cancel();
    });

    return initialState;
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

  /// Refreshes hierarchical data
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

/// Provider for initialization state stream
@riverpod
Stream<HierarchicalInitializationState> hierarchicalInitializationState(
  HierarchicalInitializationStateRef ref,
) {
  final service = ref.watch(hierarchicalInitializationServiceProvider);
  return service.initializationStateStream;
}

/// Provider for union data
@riverpod
Union? union(UnionRef ref) {
  return ref.watch(hierarchicalDataProvider).data.union;
}

/// Provider for locals data
@riverpod
Map<int, LocalsRecord> locals(LocalsRef ref) {
  return ref.watch(hierarchicalDataProvider).data.locals;
}

/// Provider for members data
@riverpod
Map<String, UnionMember> members(MembersRef ref) {
  return ref.watch(hierarchicalDataProvider).data.members;
}

/// Provider for jobs data
@riverpod
Map<String, Job> jobs(JobsRef ref) {
  return ref.watch(hierarchicalDataProvider).data.jobs;
}

/// Provider for hierarchical statistics
@riverpod
HierarchicalStats hierarchicalStats(HierarchicalStatsRef ref) {
  return ref.watch(hierarchicalDataProvider).data.stats;
}

/// Provider for search results
@riverpod
class HierarchicalSearchNotifier extends _$HierarchicalSearchNotifier {
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