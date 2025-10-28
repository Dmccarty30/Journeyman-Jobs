import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/exceptions/app_exception.dart';
import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
import '../../models/user_job_preferences.dart';
import '../../services/resilient_firestore_service.dart';
import '../../services/optimized_job_query_service.dart';
import '../../services/enhanced_user_preferences_service.dart';
import '../../services/database_performance_monitor.dart';
import '../../utils/concurrent_operations.dart';
import '../../utils/filter_performance.dart';
import '../../utils/memory_management.dart';
import 'auth_riverpod_provider.dart' as auth_providers;

part 'jobs_riverpod_provider.g.dart';

/// Jobs state model for Riverpod
class JobsState {

  const JobsState({
    this.jobs = const <Job>[],
    this.visibleJobs = const <Job>[],
    this.activeFilter = const JobFilterCriteria(),
    this.isLoading = false,
    this.error,
    this.hasMoreJobs = true,
    this.lastDocument,
    this.loadTimes = const <Duration>[],
    this.totalJobsLoaded = 0,
  });
  final List<Job> jobs;
  final List<Job> visibleJobs;
  final JobFilterCriteria activeFilter;
  final bool isLoading;
  final String? error;
  final bool hasMoreJobs;
  final DocumentSnapshot? lastDocument;
  final List<Duration> loadTimes;
  final int totalJobsLoaded;

  JobsState copyWith({
    List<Job>? jobs,
    List<Job>? visibleJobs,
    JobFilterCriteria? activeFilter,
    bool? isLoading,
    String? error,
    bool? hasMoreJobs,
    DocumentSnapshot? lastDocument,
    List<Duration>? loadTimes,
    int? totalJobsLoaded,
  }) => JobsState(
      jobs: jobs ?? this.jobs,
      visibleJobs: visibleJobs ?? this.visibleJobs,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMoreJobs: hasMoreJobs ?? this.hasMoreJobs,
      lastDocument: lastDocument ?? this.lastDocument,
      loadTimes: loadTimes ?? this.loadTimes,
      totalJobsLoaded: totalJobsLoaded ?? this.totalJobsLoaded,
    );

  JobsState clearError() => copyWith();
}

/// Firestore service provider
@riverpod
ResilientFirestoreService firestoreService(Ref ref) => ResilientFirestoreService();

/// Optimized job query service provider
@riverpod
OptimizedJobQueryService optimizedJobQueryService(Ref ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final resilientService = ref.watch(resilientFirestoreServiceProvider);
  return OptimizedJobQueryService(resilientService);
}

/// Enhanced user preferences service provider
@riverpod
EnhancedUserPreferencesService enhancedUserPreferencesService(Ref ref) {
  final performanceMonitor = ref.watch(databasePerformanceMonitorProvider);
  final resilientService = ref.watch(resilientFirestoreServiceProvider);
  return EnhancedUserPreferencesService(performanceMonitor, resilientService);
}

/// Database performance monitor provider
@riverpod
DatabasePerformanceMonitor databasePerformanceMonitor(Ref ref) => DatabasePerformanceMonitor();

/// Jobs notifier provider
@riverpod
class JobsNotifier extends _$JobsNotifier {
  late final ConcurrentOperationManager _operationManager;
  late final FilterPerformanceEngine _filterEngine;
  late final BoundedJobList _boundedJobList;
  late final VirtualJobListState _virtualJobList;

  @override
  JobsState build() {
    _operationManager = ConcurrentOperationManager();
    _filterEngine = FilterPerformanceEngine();
    _boundedJobList = BoundedJobList();
    _virtualJobList = VirtualJobListState();

    return const JobsState();
  }

  /// Load jobs with pagination
  ///
  /// Requires user authentication before loading data.
  /// Implements defense-in-depth security by checking auth at the provider level.
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated.
  /// Throws [FirebaseException] on Firestore errors.
  Future<void> loadJobs({
    JobFilterCriteria? filter,
    bool isRefresh = false,
    int limit = 20,
    int retryCount = 0,
  }) async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
    }

    // WAVE 4: Auth check before data access (defense-in-depth)
    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      throw UnauthenticatedException(
        'User must be authenticated to access job listings',
      );
    }

    if (isRefresh) {
      state = state.copyWith(
        jobs: <Job>[],
        visibleJobs: <Job>[],
        hasMoreJobs: true,
        isLoading: true,
      );
      _boundedJobList.clear();
      _virtualJobList.clear();
    } else {
      state = state.copyWith(isLoading: true);
    }

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final result = await _operationManager.executeOperation(
        type: OperationType.loadJobs,
        operation: () async {
          final firestoreService = ref.read(firestoreServiceProvider);
          if (filter != null) {
            // Use the advanced filter method if filter is provided
            return await firestoreService.getJobsWithFilter(
              filter: filter,
              startAfter: isRefresh ? null : state.lastDocument,
              limit: limit,
            );
          } else {
            // Use the basic method with Map filters
            final stream = firestoreService.getJobs(
              startAfter: isRefresh ? null : state.lastDocument,
              limit: limit,
            );
            return await stream.first;
          }
        },
      );

      stopwatch.stop();

      // Convert QuerySnapshot to Job objects
      final jobs = result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();

      // Update state with the new jobs
      final List<Job> updatedJobs = isRefresh ? jobs : [...state.jobs, ...jobs];

      // Update load times for performance tracking
      final List<Duration> newLoadTimes = List<Duration>.from(state.loadTimes)
        ..add(stopwatch.elapsed);
      if (newLoadTimes.length > 50) {
        newLoadTimes.removeAt(0); // Keep only last 50 measurements
      }

      state = state.copyWith(
        jobs: updatedJobs,
        visibleJobs: updatedJobs, // For now, all jobs are visible
        activeFilter: filter ?? state.activeFilter,
        isLoading: false,
        hasMoreJobs: jobs.length >= limit, // Assume more if we got a full page
        lastDocument: result.docs.isNotEmpty ? result.docs.last : null,
        loadTimes: newLoadTimes,
        totalJobsLoaded: updatedJobs.length,
      );
    } catch (e) {
      stopwatch.stop();

      // WAVE 4: Enhanced error handling with token refresh and retry logic
      if (e is FirebaseException &&
          (e.code == 'permission-denied' || e.code == 'unauthenticated')) {

        // Attempt token refresh once
        final tokenRefreshed = await _attemptTokenRefresh();

        if (tokenRefreshed && retryCount < 1) {
          // Retry operation once after token refresh
          return loadJobs(
            filter: filter,
            isRefresh: isRefresh,
            limit: limit,
            retryCount: retryCount + 1,
          );
        } else {
          // Check if provider is still mounted before updating state
          if (!ref.mounted) return;

          // Token refresh failed or retry exhausted - redirect to auth
          final userError = _mapFirebaseError(e);
          state = state.copyWith(isLoading: false, error: userError);
          throw UnauthenticatedException(
            'Session expired. Please sign in again.',
          );
        }
      }

      // Check if provider is still mounted before updating state
      if (!ref.mounted) return;

      // Map error to user-friendly message
      final userError = _mapFirebaseError(e);
      state = state.copyWith(isLoading: false, error: userError);

      // Log for debugging
      if (kDebugMode) {
        print('[JobsProvider] Error loading jobs: $e');
      }

      // Rethrow specific exceptions for router handling
      if (e is UnauthenticatedException || e is InsufficientPermissionsException) {
        rethrow;
      }

      rethrow;
    }
  }

  /// Apply filter to jobs
  ///
  /// Requires user authentication before applying filters.
  /// Implements defense-in-depth security by checking auth at the provider level.
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated.
  Future<void> applyFilter(JobFilterCriteria filter) async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
    }

    // WAVE 4: Auth check before data access (defense-in-depth)
    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      throw UnauthenticatedException(
        'User must be authenticated to filter job listings',
      );
    }

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      // Store the filter and reload jobs
      state = state.copyWith(activeFilter: filter);

      await _operationManager.executeOperation(
        type: OperationType.loadJobs,
        operation: () => loadJobs(filter: filter, isRefresh: true),
      );

      stopwatch.stop();
    } catch (e) {
      final userError = _mapFirebaseError(e);
      state = state.copyWith(error: userError);

      if (kDebugMode) {
        print('[JobsProvider] Error applying filter: $e');
      }

      rethrow;
    }
  }

  /// Load more jobs (pagination)
  Future<void> loadMoreJobs() async {
    if (!state.hasMoreJobs || state.isLoading) {
      return;
    }

    await loadJobs();
  }

  /// Refresh jobs
  Future<void> refreshJobs() async {
    await loadJobs(isRefresh: true);
  }

  /// Load suggested jobs based on user preferences using optimized query service
  ///
  /// This method uses the new OptimizedJobQueryService for improved performance:
  /// - Composite index utilization for Firestore queries
  /// - Proper error handling and retry logic
  /// - Performance monitoring and analytics
  /// - Intelligent fallback strategies
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated.
  /// Throws [AppException] on query errors with detailed information.
  Future<void> loadSuggestedJobs() async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
    }

    // Auth check
    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      throw UnauthenticatedException(
        'User must be authenticated to view suggested jobs',
      );
    }

    state = state.copyWith(isLoading: true);

    try {
      final result = await _operationManager.executeOperation(
        type: OperationType.loadJobs,
        operation: () async {
          // Get optimized query service and preferences service
          final queryService = ref.read(optimizedJobQueryServiceProvider);
          final preferencesService = ref.read(enhancedUserPreferencesServiceProvider);

          // Load user preferences with caching
          final preferences = await preferencesService.loadUserPreferences(
            userId: currentUser.uid,
            useCache: true,
          );

          // Get suggested jobs using optimized query
          final jobs = await queryService.getSuggestedJobs(
            userId: currentUser.uid,
            preferences: preferences,
            limit: 20, // Suggested jobs limit for performance
          );

          return jobs;
        },
      );

      // Update state with suggested jobs
      state = state.copyWith(
        jobs: result,
        visibleJobs: result,
        isLoading: false,
        hasMoreJobs: false, // Suggested jobs are limited to 20
        totalJobsLoaded: result.length,
      );

      if (kDebugMode) {
        print('✅ Loaded ${result.length} suggested jobs using optimized query service');
      }
    } catch (e) {
      // Check if provider is still mounted
      if (!ref.mounted) return;

      final userError = _mapFirebaseError(e);
      state = state.copyWith(isLoading: false, error: userError);

      if (kDebugMode) {
        print('[JobsProvider] Error loading suggested jobs: $e');
      }

      // Rethrow auth exceptions for router handling
      if (e is UnauthenticatedException) {
        rethrow;
      }
    }
  }

  /// Load all jobs without filtering
  ///
  /// This method loads jobs from Firestore without any user preference filtering.
  /// Used for the Jobs screen where users browse all available jobs.
  ///
  /// Implements pagination and offline caching.
  Future<void> loadAllJobs({
    int limit = 20,
    bool isRefresh = false,
  }) async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
    }

    // Auth check
    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      throw UnauthenticatedException(
        'User must be authenticated to view jobs',
      );
    }

    if (isRefresh) {
      state = state.copyWith(
        jobs: <Job>[],
        visibleJobs: <Job>[],
        hasMoreJobs: true,
        isLoading: true,
      );
      _boundedJobList.clear();
      _virtualJobList.clear();
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final result = await _operationManager.executeOperation(
        type: OperationType.loadJobs,
        operation: () async {
          final firestoreService = ref.read(firestoreServiceProvider);
          final stream = firestoreService.getJobs(
            startAfter: isRefresh ? null : state.lastDocument,
            limit: limit,
          );
          return await stream.first;
        },
      );

      // Convert QuerySnapshot to Job objects
      final jobs = result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();

      // Update state
      final List<Job> updatedJobs = isRefresh ? jobs : [...state.jobs, ...jobs];

      state = state.copyWith(
        jobs: updatedJobs,
        visibleJobs: updatedJobs,
        isLoading: false,
        hasMoreJobs: jobs.length >= limit,
        lastDocument: result.docs.isNotEmpty ? result.docs.last : null,
        totalJobsLoaded: updatedJobs.length,
      );

      if (kDebugMode) {
        print('✅ Loaded ${jobs.length} jobs (total: ${updatedJobs.length})');
      }
    } catch (e) {
      // Check if provider is still mounted
      if (!ref.mounted) return;

      final userError = _mapFirebaseError(e);
      state = state.copyWith(isLoading: false, error: userError);

      if (kDebugMode) {
        print('[JobsProvider] Error loading all jobs: $e');
      }

      // Rethrow auth exceptions
      if (e is UnauthenticatedException) {
        rethrow;
      }
    }
  }

  /// Update visible jobs for virtual scrolling
  void updateVisibleJobsRange(int startIndex, int endIndex) {
    if (startIndex < 0 || endIndex < 0 || startIndex > endIndex) {
      return;
    }

    // Use VirtualJobListState for efficient virtual scrolling
    _virtualJobList.updateJobs(state.jobs, startIndex);
    final visibleJobs = _virtualJobList.visibleJobs;

    state = state.copyWith(visibleJobs: visibleJobs);
  }

  /// Get job by ID
  Job? getJobById(String jobId) {
    try {
      return state.jobs.firstWhere((Job job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() => <String, dynamic>{
      'averageLoadTime': state.loadTimes.isEmpty
          ? Duration.zero
          : Duration(
              milliseconds: state.loadTimes
                  .map((Duration d) => d.inMilliseconds)
                  .reduce((int a, int b) => a + b) ~/
                  state.loadTimes.length,
            ),
      'totalJobsLoaded': state.totalJobsLoaded,
      'memoryUsage': _boundedJobList.estimatedMemoryUsage,
      'filterPerformance': _filterEngine.getStats(),
      'virtualListStats': _virtualJobList.getStats(),
    };

  /// Dispose resources
  void dispose() {
    _operationManager.dispose();
    // Note: BoundedJobList and VirtualJobListState don't implement dispose methods
    // as they only contain in-memory data structures that will be garbage collected
    // _boundedJobList.dispose(); // Not needed - only manages List<Job>
    // _virtualJobList.dispose(); // Not needed - only manages Map<String, Job> and List<String>
    _filterEngine.clearCaches(); // Clear filter caches to free memory
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
        print('[JobsProvider] Token refresh successful');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[JobsProvider] Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Maps Firebase errors to user-friendly error messages.
  ///
  /// Provides clear, actionable guidance for common error scenarios.
  String _mapFirebaseError(Object error) {
    if (error is UnauthenticatedException) {
      return 'Please sign in to access job listings';
    }

    if (error is InsufficientPermissionsException) {
      return error.message;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to access this resource. Please sign in.';
        case 'unauthenticated':
          return 'Authentication required. Please sign in to continue.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'deadline-exceeded':
          return 'Request timed out. Please try again.';
        case 'not-found':
          return 'The requested data was not found.';
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
}

/// Filtered jobs provider using family for auto-dispose
@riverpod
Future<List<Job>> filteredJobs(
  Ref ref,
  JobFilterCriteria filter,
) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  final result = await firestoreService.getJobsWithFilter(
    filter: filter,
    limit: 50,
  );

  // Convert QuerySnapshot to Job objects
  return result.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Job.fromJson(data);
  }).toList();
}

/// Auto-dispose provider for job search
@riverpod
Future<List<Job>> searchJobs(
  Ref ref,
  String searchTerm,
) async {
  if (searchTerm.trim().isEmpty) {
    return <Job>[];
  }

  final firestoreService = ref.watch(firestoreServiceProvider);

  final JobFilterCriteria filter = JobFilterCriteria(
    searchQuery: searchTerm,
  );

  final result = await firestoreService.getJobsWithFilter(
    filter: filter,
    limit: 20,
  );

  // Convert QuerySnapshot to Job objects
  return result.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Job.fromJson(data);
  }).toList();
}

/// Job by ID provider
@riverpod
Future<Job?> jobById(Ref ref, String jobId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  // Use the basic getJobs stream and filter by ID
  final stream = firestoreService.getJobs(limit: 1);
  final snapshot = await stream.first;

  for (final doc in snapshot.docs) {
    if (doc.id == jobId) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Job.fromJson(data);
    }
  }

  return null;
}

/// Recent jobs provider
@riverpod
Future<List<Job>> recentJobs(Ref ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  const JobFilterCriteria filter = JobFilterCriteria(
    sortBy: JobSortOption.datePosted,
    sortDescending: true,
  );

  final result = await firestoreService.getJobsWithFilter(
    filter: filter,
    limit: 10,
  );

  // Convert QuerySnapshot to Job objects
  return result.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Job.fromJson(data);
  }).toList();
}

/// Storm jobs provider (high priority jobs)
@riverpod
Future<List<Job>> stormJobs(Ref ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  const JobFilterCriteria filter = JobFilterCriteria(
    constructionTypes: <String>['storm', 'emergency'],
    sortBy: JobSortOption.datePosted,
    sortDescending: true,
  );

  final result = await firestoreService.getJobsWithFilter(
    filter: filter,
    limit: 20,
  );

  // Convert QuerySnapshot to Job objects
  return result.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Job.fromJson(data);
  }).toList();
}

/// Helper method: Log cascade results for debugging
/// Only logs in debug mode using assert() to ensure zero overhead in production
void _logCascade({
  required String level,
  required int matchedCount,
  required int totalCount,
  String? extraInfo,
}) {
  assert(() {
    if (kDebugMode) {
      final emoji = level == 'L1' ? '✅' :
                   level == 'L2' ? '⚠️' :
                   level == 'L3' ? '🔵' :
                   level == 'L4' ? '🔴' : '📊';

      print('$emoji CASCADE $level: $matchedCount/$totalCount jobs${extraInfo != null ? ' - $extraInfo' : ''}');
    }
    return true;
  }());
}

/// Suggested jobs provider - matches jobs against user's jobPreferences with cascading fallback
///
/// **UPDATED IMPLEMENTATION:**
/// - Uses simple orderBy query (NO composite index required)
/// - Client-side filtering for all criteria
/// - 4-level cascade with accumulation (no duplicates)
/// - GUARANTEES jobs display when they exist in Firestore
///
/// Architecture:
/// 1. Fetches 100 recent jobs with simple orderBy query
/// 2. Implements 4-level cascade with accumulation (max 20 jobs):
///    - Level 1: Exact match (locals + types + hours + per diem)
///    - Level 2: Relaxed match (locals + types only)
///    - Level 3: Minimal match (preferred locals only)
///    - Level 4: Fallback to recent jobs (no filtering)
/// 3. Each level adds unique jobs to results (Set-based deduplication)
/// 4. Preserves timestamp descending order
///
/// UX guarantee: Users ALWAYS see jobs on home screen when jobs exist
@riverpod
Future<List<Job>> suggestedJobs(Ref ref) async {
  const int kMaxSuggested = 20;

  // Get authenticated user
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) {
    throw UnauthenticatedException(
      'User must be authenticated to view suggested jobs',
    );
  }

  // Fetch user document to get jobPreferences
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  // Check if provider is still mounted after async operation
  if (!ref.mounted) return <Job>[];

  // FALLBACK: No user data -> show recent jobs
  if (!userDoc.exists) {
    final fallbackJobs = await _getRecentJobs();
    _logCascade(
      level: 'L4',
      matchedCount: fallbackJobs.length,
      totalCount: fallbackJobs.length,
      extraInfo: 'No user document found',
    );
    return fallbackJobs;
  }

  final userData = userDoc.data();

  // FALLBACK: No preferences set -> show recent jobs
  if (userData == null || !userData.containsKey('jobPreferences')) {
    final fallbackJobs = await _getRecentJobs();
    _logCascade(
      level: 'L4',
      matchedCount: fallbackJobs.length,
      totalCount: fallbackJobs.length,
      extraInfo: 'No jobPreferences in user data',
    );
    return fallbackJobs;
  }

  // Parse jobPreferences
  final prefsData = userData['jobPreferences'] as Map<String, dynamic>?;

  if (prefsData == null) {
    final fallbackJobs = await _getRecentJobs();
    _logCascade(
      level: 'L4',
      matchedCount: fallbackJobs.length,
      totalCount: fallbackJobs.length,
      extraInfo: 'jobPreferences data is null',
    );
    return fallbackJobs;
  }

  final prefs = UserJobPreferences.fromJson(prefsData);

  if (kDebugMode) {
    print('\n🔍 DEBUG: Loading suggested jobs for user ${currentUser.uid}');
    print('📋 User preferences:');
    print('  - Preferred locals: ${prefs.preferredLocals}');
    print('  - Construction types: ${prefs.constructionTypes}');
    print('  - Hours per week: ${prefs.hoursPerWeek}');
    print('  - Per diem: ${prefs.perDiemRequirement}');
  }

  // Fetch 100 recent jobs with simple query (no index required)
  final allJobs = await _fetchRecentJobsSlice();

  // Check if provider is still mounted
  if (!ref.mounted) return <Job>[];

  if (kDebugMode) {
    print('📊 Fetched ${allJobs.length} jobs from Firestore');
  }

  // 4-LEVEL CASCADE WITH ACCUMULATION

  final List<Job> results = [];
  final Set<String> seenIds = {}; // Deduplication

  /// Helper to add jobs from a tier without duplicates
  void addTier(List<Job> tier) {
    for (final job in tier) {
      if (seenIds.add(job.id)) {  // Only add if new
        results.add(job);
        if (results.length >= kMaxSuggested) break;
      }
    }
  }

  // LEVEL 1: Exact match (all criteria)
  final l1 = _filterJobsExact(allJobs, prefs);
  if (l1.isNotEmpty) {
    _logCascade(
      level: 'L1',
      matchedCount: l1.length,
      totalCount: allJobs.length,
      extraInfo: 'Exact match',
    );
    addTier(l1);
  }

  // LEVEL 2: Relaxed match (locals + types)
  if (results.length < kMaxSuggested) {
    final l2 = _filterJobsRelaxed(allJobs, prefs);
    if (l2.isNotEmpty) {
      _logCascade(
        level: 'L2',
        matchedCount: l2.length,
        totalCount: allJobs.length,
        extraInfo: 'Relaxed match',
      );
      addTier(l2);
    }
  }

  // LEVEL 3: Locals-only match
  if (results.length < kMaxSuggested) {
    final l3 = _filterJobsByLocals(allJobs, prefs);
    if (l3.isNotEmpty) {
      _logCascade(
        level: 'L3',
        matchedCount: l3.length,
        totalCount: allJobs.length,
        extraInfo: 'Locals-only match',
      );
      addTier(l3);
    }
  }

  // LEVEL 4: Fallback to recent (all remaining jobs)
  if (results.length < kMaxSuggested) {
    _logCascade(
      level: 'L4',
      matchedCount: allJobs.length,
      totalCount: allJobs.length,
      extraInfo: 'Fallback (recent jobs)',
    );
    addTier(allJobs);
  }

  _logCascade(
    level: 'FINAL',
    matchedCount: results.length,
    totalCount: allJobs.length,
    extraInfo: 'Total suggested jobs',
  );

  return results;
}

/// Helper method: Check if job matches preferred locals
/// Handles both 'local' and 'localNumber' fields with type flexibility
bool _matchesPreferredLocals(Job job, List<int> preferredLocals) {
  if (preferredLocals.isEmpty) return true;

  // Collect all local values from job (handles both fields)
  final localVals = <int>{
    if (job.local != null) job.local!,
    if (job.localNumber != null) job.localNumber!,
  };

  // Match if ANY preferred local is in job's local values
  return preferredLocals.any(localVals.contains);
}

/// Helper method: Check if job matches construction types
/// Case-insensitive matching with `List<String>` support
bool _matchesConstructionTypes(Job job, List<String> typesPref) {
  if (typesPref.isEmpty) return true;

  // Handle typeOfWork as String (nullable)
  if (job.typeOfWork == null || job.typeOfWork!.isEmpty) return false;

  final jobType = job.typeOfWork!.toLowerCase();

  // Check if any preference type is contained in the job type
  return typesPref.any((type) => jobType.contains(type.toLowerCase()));
}

/// Helper method: Check if job matches hours preference
/// Allows 20% tolerance range for flexibility
bool _matchesHours(Job job, UserJobPreferences prefs) {
  if (prefs.hoursPerWeek == null) return true;

  final jobHours = job.hours; // hours is int? in Job model
  if (jobHours == null) return false;

  final prefHours = prefs.hoursPerWeek!;

  // Parse preference (e.g., "70+", "40-50", "40")
  if (prefHours.endsWith('+')) {
    // Minimum hours requirement
    final minHours = int.tryParse(prefHours.replaceAll('+', ''));
    return minHours != null && jobHours >= minHours;
  } else if (prefHours.contains('-')) {
    // Range requirement
    final parts = prefHours.split('-');
    final minHours = int.tryParse(parts[0]);
    final maxHours = int.tryParse(parts[1]);
    return minHours != null && maxHours != null &&
           jobHours >= minHours && jobHours <= maxHours;
  } else {
    // Exact hours with 20% tolerance
    final exactHours = int.tryParse(prefHours);
    if (exactHours == null) return false;
    final tolerance = exactHours * 0.2;
    return jobHours >= (exactHours - tolerance) &&
           jobHours <= (exactHours + tolerance);
  }
}

/// Helper method: Check if job matches per diem requirement
bool _matchesPerDiem(Job job, UserJobPreferences prefs) {
  if (prefs.perDiemRequirement == null) return true;

  final prefPerDiem = prefs.perDiemRequirement!.toLowerCase();
  final jobPerDiem = (job.perDiem ?? '').toLowerCase();

  // If user requires per diem, job must offer it
  if (prefPerDiem.contains('yes') || prefPerDiem.contains('required')) {
    return jobPerDiem.isNotEmpty;
  }

  // If user specifies amount (e.g., "200+")
  if (prefPerDiem.contains('200')) {
    return jobPerDiem.contains('200') || jobPerDiem.contains('250');
  }

  if (prefPerDiem.contains('100')) {
    final jobHasDiem = jobPerDiem.contains('100') ||
                       jobPerDiem.contains('125') ||
                       jobPerDiem.contains('150');
    return jobHasDiem;
  }

  // No strict requirement
  return true;
}

/// Helper method: Filter jobs with exact match on ALL preferences
/// Returns jobs matching: locals + construction types + hours + per diem
List<Job> _filterJobsExact(List<Job> jobs, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.cast<int>();

  return jobs.where((job) {
    final localsOk = _matchesPreferredLocals(job, prefLocals);
    final typesOk = _matchesConstructionTypes(job, prefs.constructionTypes);
    final hoursOk = _matchesHours(job, prefs);
    final perDiemOk = _matchesPerDiem(job, prefs);

    return localsOk && typesOk && hoursOk && perDiemOk;
  }).toList();
}

/// Helper method: Filter jobs with relaxed match (locals + construction types only)
/// Ignores: hours per week and per diem requirements
List<Job> _filterJobsRelaxed(List<Job> jobs, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.cast<int>();

  return jobs.where((job) {
    final localsOk = _matchesPreferredLocals(job, prefLocals);
    final typesOk = _matchesConstructionTypes(job, prefs.constructionTypes);

    return localsOk && typesOk;
  }).toList();
}

/// Helper method: Filter jobs by preferred locals only
/// Most minimal matching - just location preference
List<Job> _filterJobsByLocals(List<Job> jobs, UserJobPreferences prefs) {
  if (prefs.preferredLocals.isEmpty) return const [];

  final prefLocals = prefs.preferredLocals.cast<int>();
  return jobs.where((job) => _matchesPreferredLocals(job, prefLocals)).toList();
}

/// Helper method: Fetch recent job slice without server-side filters
///
/// Fetches 100 most recent jobs ordered by timestamp descending.
/// All filtering (deleted, local matching, etc.) is done client-side for:
/// - Schema tolerance (handles missing 'deleted' field)
/// - No composite index requirements
/// - Guaranteed results when jobs exist in Firestore
///
/// Returns: List of jobs with client-side deleted filter applied
Future<List<Job>> _fetchRecentJobsSlice() async {
  // Simple query: orderBy timestamp, limit 100
  // No server-side filters = no composite index required
  final result = await FirebaseFirestore.instance
      .collection('jobs')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .get();

  // Client-side filtering for deleted jobs
  // Handles jobs without 'deleted' field gracefully
  return result.docs
      .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Job.fromJson(data);
      })
      .where((job) => job.deleted != true) // Client-side deleted filter
      .toList();
}

/// Helper method: Get recent jobs as final fallback
/// Returns most recent 20 jobs regardless of user preferences
Future<List<Job>> _getRecentJobs() async {
  final jobs = await _fetchRecentJobsSlice();
  return jobs.take(20).toList();
}
