import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/exceptions/app_exception.dart';
import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
import '../../models/user_job_preferences.dart';
import '../../services/resilient_firestore_service.dart';
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

  /// Load suggested jobs based on user preferences
  ///
  /// This method integrates with the suggestedJobs provider to load
  /// jobs that match the user's preferences with cascading fallback.
  ///
  /// Architecture:
  /// 1. Fetches user's jobPreferences from Firestore
  /// 2. Uses cascading fallback to always show jobs
  /// 3. Caches results for offline access
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated.
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
          // Use the suggestedJobs provider to get matched jobs
          final jobs = await ref.read(suggestedJobsProvider.future);
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
        print('✅ Loaded ${result.length} suggested jobs');
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

/// Suggested jobs provider - matches jobs against user's jobPreferences with cascading fallback
///
/// Architecture:
/// 1. Fetches user's embedded jobPreferences from users/{uid}.jobPreferences
/// 2. Implements cascading fallback strategy to ALWAYS show jobs:
///    - Level 1: Exact match on all preferences (locals + construction types + hours + per diem)
///    - Level 2: Relaxed match (locals + construction types only)
///    - Level 3: Minimal match (preferred locals only)
///    - Level 4: Fallback to recent jobs (if no preferences or no matches at all)
/// 3. Queries jobs collection using most selective server-side filter (preferredLocals)
/// 4. Applies client-side filtering for remaining criteria
///
/// Performance optimization:
/// - Uses Firestore whereIn for preferredLocals (most selective filter)
/// - Client-side filtering avoids Firestore query limitations (max 1 whereIn per query)
/// - Limits to 20 results for home screen display
///
/// UX guarantee: Users ALWAYS see jobs on home screen, even without exact matches
@riverpod
Future<List<Job>> suggestedJobs(Ref ref) async {
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

  // FALLBACK LEVEL 4: No user data -> show recent jobs
  if (!userDoc.exists) {
    if (kDebugMode) {
      print('\n⚠️ No user data found - showing recent jobs');
    }
    return _getRecentJobs();
  }

  final userData = userDoc.data();

  // FALLBACK LEVEL 4: No preferences set -> show recent jobs
  if (userData == null || !userData.containsKey('jobPreferences')) {
    if (kDebugMode) {
      print('\n⚠️ No preferences set - showing recent jobs');
    }
    return _getRecentJobs();
  }

  // Parse jobPreferences from embedded subdocument
  final prefsData = userData['jobPreferences'] as Map<String, dynamic>?;

  // FALLBACK LEVEL 4: No preferences data -> show recent jobs
  if (prefsData == null) {
    if (kDebugMode) {
      print('\n⚠️ No preferences data - showing recent jobs');
    }
    return _getRecentJobs();
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

  // Strategy: Use most selective filter for Firestore query (preferredLocals)
  // Then apply cascading client-side filtering
  QuerySnapshot<Map<String, dynamic>> result;

  if (prefs.preferredLocals.isNotEmpty) {
    // Use preferredLocals as server-side filter (most selective)
    // Firestore allows max 10 values in whereIn, so take first 10 locals
    final localsToQuery = prefs.preferredLocals.take(10).toList();

    if (kDebugMode) {
      print('🔄 Querying jobs where local in: $localsToQuery');
    }

    result = await FirebaseFirestore.instance
        .collection('jobs')
        .where('local', whereIn: localsToQuery)
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(50) // Fetch 50 to have buffer for client-side filtering
        .get();

    // Check if provider is still mounted after async operation
    if (!ref.mounted) return <Job>[];
  } else {
    // No preferred locals - query all recent jobs
    if (kDebugMode) {
      print('🔄 No preferred locals - querying recent jobs');
    }

    result = await FirebaseFirestore.instance
        .collection('jobs')
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    // Check if provider is still mounted after async operation
    if (!ref.mounted) return <Job>[];
  }

  if (kDebugMode) {
    print('📊 Server query returned ${result.docs.length} jobs');
  }

  // Convert to Job objects
  final allJobs = result.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return Job.fromJson(data);
  }).toList();

  // CASCADING FILTER STRATEGY

  // LEVEL 1: Try exact match on ALL preferences
  List<Job> matchedJobs = _filterJobsExact(allJobs, prefs);

  if (matchedJobs.isNotEmpty) {
    if (kDebugMode) {
      print('✅ Level 1: Found ${matchedJobs.length} exact matches');
    }
    return matchedJobs.take(20).toList();
  }

  // LEVEL 2: Relax to locals + construction types only
  matchedJobs = _filterJobsRelaxed(allJobs, prefs);

  if (matchedJobs.isNotEmpty) {
    if (kDebugMode) {
      print('⚠️ Level 2: No exact matches, showing ${matchedJobs.length} relaxed matches (locals + construction types)');
    }
    return matchedJobs.take(20).toList();
  }

  // LEVEL 3: Further relax to preferred locals only
  if (prefs.preferredLocals.isNotEmpty && allJobs.isNotEmpty) {
    if (kDebugMode) {
      print('⚠️ Level 3: No relaxed matches, showing ${allJobs.length} jobs from preferred locals');
    }
    return allJobs.take(20).toList();
  }

  // LEVEL 4: Final fallback - show any recent jobs
  if (kDebugMode) {
    print('⚠️ Level 4: No matches found, falling back to recent jobs');
  }
  return _getRecentJobs();
}

/// Helper method: Filter jobs with exact match on ALL preferences
/// Returns jobs matching: locals + construction types + hours + per diem
List<Job> _filterJobsExact(List<Job> jobs, UserJobPreferences prefs) {
  return jobs.where((job) {
    // Filter by construction types (typeOfWork)
    if (prefs.constructionTypes.isNotEmpty) {
      final jobType = job.typeOfWork?.toLowerCase();
      if (jobType == null) return false;

      final matchesType = prefs.constructionTypes.any(
        (type) => jobType.contains(type.toLowerCase()),
      );
      if (!matchesType) return false;
    }

    // Filter by hours per week
    if (prefs.hoursPerWeek != null && job.hours != null) {
      // Parse user preference (e.g., "70+" means >= 70)
      final prefHours = prefs.hoursPerWeek!;
      if (prefHours.endsWith('+')) {
        final minHours = int.tryParse(prefHours.replaceAll('+', ''));
        if (minHours != null && job.hours! < minHours) return false;
      } else {
        // Exact match or range
        final exactHours = int.tryParse(prefHours);
        if (exactHours != null && job.hours != exactHours) return false;
      }
    }

    // Filter by per diem requirement
    if (prefs.perDiemRequirement != null) {
      final prefPerDiem = prefs.perDiemRequirement!.toLowerCase();
      final jobPerDiem = job.perDiem?.toLowerCase() ?? '';

      // Match per diem requirements
      if (prefPerDiem.contains('200') && !jobPerDiem.contains('200')) {
        return false; // User wants $200+ per diem, job doesn't offer it
      }
    }

    return true; // Job matches all criteria
  }).toList();
}

/// Helper method: Filter jobs with relaxed match (locals + construction types only)
/// Ignores: hours per week and per diem requirements
List<Job> _filterJobsRelaxed(List<Job> jobs, UserJobPreferences prefs) {
  return jobs.where((job) {
    // Only filter by construction types - ignore hours and per diem
    if (prefs.constructionTypes.isNotEmpty) {
      final jobType = job.typeOfWork?.toLowerCase();
      if (jobType == null) return false;

      final matchesType = prefs.constructionTypes.any(
        (type) => jobType.contains(type.toLowerCase()),
      );
      return matchesType;
    }

    // If no construction type preferences, include all jobs from preferred locals
    return true;
  }).toList();
}

/// Helper method: Get recent jobs as final fallback
/// Returns most recent 20 jobs regardless of user preferences
Future<List<Job>> _getRecentJobs() async {
  final result = await FirebaseFirestore.instance
      .collection('jobs')
      .where('deleted', isEqualTo: false)
      .orderBy('timestamp', descending: true)
      .limit(20)
      .get();

  return result.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return Job.fromJson(data);
  }).toList();
}
