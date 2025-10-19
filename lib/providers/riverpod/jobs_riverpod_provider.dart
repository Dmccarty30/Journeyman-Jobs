import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/exceptions/app_exception.dart';
import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
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
          // Token refresh failed or retry exhausted - redirect to auth
          final userError = _mapFirebaseError(e);
          state = state.copyWith(isLoading: false, error: userError);
          throw UnauthenticatedException(
            'Session expired. Please sign in again.',
          );
        }
      }

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
