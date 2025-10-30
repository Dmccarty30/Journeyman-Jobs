import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../services/user_discovery_service.dart';
import '../../models/users_record.dart';

/// Provider for the UserDiscoveryService instance.
///
/// This provider creates and manages the UserDiscoveryService singleton
/// for dependency injection throughout the application.
final userDiscoveryServiceProvider = Provider<UserDiscoveryService>((ref) {
  return UserDiscoveryService(
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for user search results with real-time updates.
///
/// This provider manages the state of user searches including loading
/// states, error handling, and result caching.
class UserSearchNotifier extends StateNotifier<AsyncValue<UserSearchResult>> {
  final UserDiscoveryService _service;

  UserSearchNotifier(this._service) : super(const AsyncValue.loading());

  /// Searches for users based on the provided query.
  ///
  /// Parameters:
  /// - [query]: Search query string
  /// - [limit]: Maximum number of results
  /// - [excludeUserId]: User ID to exclude from results
  Future<void> searchUsers({
    required String query,
    int limit = 20,
    String? excludeUserId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _service.searchUsers(
        query: query,
        limit: limit,
        excludeUserId: excludeUserId,
      );
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clears the current search results.
  void clearResults() {
    state = const AsyncValue.data(UserSearchResult(users: [], hasMore: false));
  }
}

/// Provider for the user search notifier.
final userSearchProvider = StateNotifierProvider<UserSearchNotifier, AsyncValue<UserSearchResult>>((ref) {
  final service = ref.watch(userDiscoveryServiceProvider);
  return UserSearchNotifier(service);
});

/// Provider for suggested users with real-time updates.
///
/// This provider manages suggested users for crew invitations
/// based on the current user's profile and characteristics.
class SuggestedUsersNotifier extends StateNotifier<AsyncValue<List<UsersRecord>>> {
  final UserDiscoveryService _service;
  final Ref _ref;

  SuggestedUsersNotifier(this._service, this._ref) : super(const AsyncValue.loading());

  /// Loads suggested users for the current user.
  ///
  /// Parameters:
  /// - [crewId]: Optional crew ID to exclude current members
  /// - [limit]: Maximum number of suggestions
  Future<void> loadSuggestedUsers({
    String? crewId,
    int limit = 10,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Get current user ID from auth provider
      final userId = _ref.read(authRiverpodProvider)?.uid;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final suggestions = await _service.getSuggestedUsers(
        userId: userId,
        crewId: crewId,
        limit: limit,
      );
      state = AsyncValue.data(suggestions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refreshes the suggested users list.
  Future<void> refresh({String? crewId, int limit = 10}) async {
    await loadSuggestedUsers(crewId: crewId, limit: limit);
  }

  /// Clears the suggested users.
  void clearSuggestions() {
    state = const AsyncValue.data([]);
  }
}

/// Provider for the suggested users notifier.
final suggestedUsersProvider = StateNotifierProvider<SuggestedUsersNotifier, AsyncValue<List<UsersRecord>>>((ref) {
  final service = ref.watch(userDiscoveryServiceProvider);
  return SuggestedUsersNotifier(service, ref);
});

/// Provider for debounced user search with performance optimization.
///
/// This provider implements debounced search to prevent excessive
/// API calls during rapid typing in search fields.
class DebouncedSearchNotifier extends StateNotifier<AsyncValue<UserSearchResult>> {
  final UserDiscoveryService _service;
  String? _currentQuery;
  Timer? _debounceTimer;

  DebouncedSearchNotifier(this._service) : super(const AsyncValue.data(UserSearchResult(users: [], hasMore: false)));

  /// Performs debounced search with configurable delay.
  ///
  /// Parameters:
  /// - [query]: Search query string
  /// - [delay]: Debounce delay in milliseconds (default: 300ms)
  /// - [limit]: Maximum number of results
  /// - [excludeUserId]: User ID to exclude from results
  void searchDebounced({
    required String query,
    int delay = 300,
    int limit = 20,
    String? excludeUserId,
  }) {
    // Cancel existing timer
    _debounceTimer?.cancel();

    // If query is empty, clear results immediately
    if (query.trim().isEmpty) {
      _currentQuery = null;
      state = const AsyncValue.data(UserSearchResult(users: [], hasMore: false));
      return;
    }

    // Set new timer
    _debounceTimer = Timer(Duration(milliseconds: delay), () async {
      if (query == _currentQuery) return; // Avoid duplicate searches

      _currentQuery = query;
      state = const AsyncValue.loading();

      try {
        final result = await _service.searchUsers(
          query: query,
          limit: limit,
          excludeUserId: excludeUserId,
        );
        state = AsyncValue.data(result);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
      }
    });
  }

  /// Cancels any pending search.
  void cancelSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Gets the current search query.
  String? get currentQuery => _currentQuery;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for the debounced search notifier.
final debouncedSearchProvider = StateNotifierProvider<DebouncedSearchNotifier, AsyncValue<UserSearchResult>>((ref) {
  final service = ref.watch(userDiscoveryServiceProvider);
  return DebouncedSearchNotifier(service);
});

/// Provider for user discovery analytics and metrics.
///
/// This provider tracks search performance, user engagement,
/// and discovery service metrics for optimization.
class UserDiscoveryMetricsNotifier extends StateNotifier<AsyncValue<UserDiscoveryMetrics>> {
  final UserDiscoveryService _service;

  UserDiscoveryMetricsNotifier(this._service) : super(const AsyncValue.loading());

  /// Loads user discovery metrics.
  Future<void> loadMetrics() async {
    state = const AsyncValue.loading();

    try {
      // This would typically fetch metrics from a monitoring service
      // For now, we'll provide basic metrics
      final metrics = UserDiscoveryMetrics(
        totalSearches: 0,
        averageSearchTime: 0,
        popularQueries: [],
        successRate: 0.0,
        lastUpdated: DateTime.now(),
      );
      state = AsyncValue.data(metrics);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Records a search event for analytics.
  void recordSearch(String query, int resultCount, Duration searchTime) {
    // This would typically send analytics data to a monitoring service
    debugPrint('Search recorded: $query ($resultCount results in ${searchTime.inMilliseconds}ms)');
  }
}

/// Provider for user discovery metrics.
final userDiscoveryMetricsProvider = StateNotifierProvider<UserDiscoveryMetricsNotifier, AsyncValue<UserDiscoveryMetrics>>((ref) {
  final service = ref.watch(userDiscoveryServiceProvider);
  return UserDiscoveryMetricsNotifier(service);
});

/// Combined provider for user discovery state management.
///
/// This provider combines multiple user discovery providers
/// for convenient access to related state.
class UserDiscoveryState {
  final AsyncValue<UserSearchResult> searchResults;
  final AsyncValue<List<UsersRecord>> suggestedUsers;
  final AsyncValue<UserDiscoveryMetrics> metrics;

  UserDiscoveryState({
    required this.searchResults,
    required this.suggestedUsers,
    required this.metrics,
  });
}

/// Provider for combined user discovery state.
final userDiscoveryStateProvider = Provider<UserDiscoveryState>((ref) {
  final searchResults = ref.watch(userSearchProvider);
  final suggestedUsers = ref.watch(suggestedUsersProvider);
  final metrics = ref.watch(userDiscoveryMetricsProvider);

  return UserDiscoveryState(
    searchResults: searchResults,
    suggestedUsers: suggestedUsers,
    metrics: metrics,
  );
});

/// Data class for user discovery metrics.
class UserDiscoveryMetrics {
  final int totalSearches;
  final int averageSearchTime;
  final List<String> popularQueries;
  final double successRate;
  final DateTime lastUpdated;

  UserDiscoveryMetrics({
    required this.totalSearches,
    required this.averageSearchTime,
    required this.popularQueries,
    required this.successRate,
    required this.lastUpdated,
  });
}

/// Import the auth provider (assuming it exists)
// This would typically be imported from the actual auth provider file
// import 'auth_riverpod_provider.dart';

// Temporary stub for auth provider - replace with actual implementation
final authRiverpodProvider = Provider<Map<String, String>?>((ref) => null);