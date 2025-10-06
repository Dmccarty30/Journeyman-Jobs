import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
import '../../services/resilient_firestore_service.dart';
import '../../utils/concurrent_operations.dart';
// TODO: Add back when utility classes are implemented
// import '../../utils/filter_performance.dart';
// import '../../utils/memory_management.dart';

part 'jobs_riverpod_provider.g.dart';

/// Represents the state for the jobs feature, including lists of jobs,
/// loading status, and pagination details.
class JobsState {

  /// Creates an instance of the jobs state.
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
  /// The complete list of all jobs loaded so far.
  final List<Job> jobs;
  /// The sub-list of jobs currently visible in the UI, used for virtual scrolling.
  final List<Job> visibleJobs;
  /// The filter criteria currently applied to the job list.
  final JobFilterCriteria activeFilter;
  /// `true` if a job loading operation is in progress.
  final bool isLoading;
  /// A string description of the last error that occurred.
  final String? error;
  /// `true` if there are more jobs to be loaded from the backend.
  final bool hasMoreJobs;
  /// The last Firestore document from the previous fetch, used for pagination.
  final DocumentSnapshot? lastDocument;
  /// A list of recent load times for performance monitoring.
  final List<Duration> loadTimes;
  /// The total number of jobs currently loaded in the state.
  final int totalJobsLoaded;

  /// Creates a new [JobsState] instance with updated field values.
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

  /// Returns a new [JobsState] instance with the `error` field cleared.
  JobsState clearError() => copyWith(error: null);
}

/// Provides an app-wide instance of [ResilientFirestoreService].
@riverpod
ResilientFirestoreService firestoreService(Ref ref) => ResilientFirestoreService();

/// The state notifier for managing the [JobsState].
///
/// This class handles all logic for fetching, filtering, and paginating job data.
/// It is designed to be resilient and performant, with placeholders for future
/// optimizations like advanced memory management and filter performance engines.
@riverpod
class JobsNotifier extends _$JobsNotifier {
  late final ConcurrentOperationManager _operationManager;
  // TODO: Implement these utility classes when ready
  // late final FilterPerformanceEngine _filterEngine;
  // late final BoundedJobList _boundedJobList;
  // late final VirtualJobListState _virtualJobList;

  @override
  JobsState build() {
    _operationManager = ConcurrentOperationManager();
    // TODO: Implement these utility classes
    // _filterEngine = FilterPerformanceEngine();
    // _boundedJobList = BoundedJobList();
    // _virtualJobList = VirtualJobListState();

    return const JobsState();
  }

  /// Loads a list of jobs from Firestore, with support for pagination and filtering.
  ///
  /// - [filter]: The [JobFilterCriteria] to apply to the query.
  /// - [isRefresh]: If `true`, clears the existing job list before fetching.
  /// - [limit]: The number of jobs to fetch per page.
  Future<void> loadJobs({
    JobFilterCriteria? filter,
    bool isRefresh = false,
    int limit = 20,
  }) async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
    }

    print('[DEBUG] JobsNotifier.loadJobs called - isRefresh: $isRefresh, filter: ${filter?.toString()}');

    if (isRefresh) {
      state = state.copyWith(
        jobs: <Job>[],
        visibleJobs: <Job>[],
        hasMoreJobs: true,
        isLoading: true,
      );
      // TODO: Implement utility classes
      // _boundedJobList.clear();
      // _virtualJobList.clear();
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
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Applies a new filter to the job list.
  ///
  /// This will clear the current job list and reload data from Firestore
  /// using the new filter criteria.
  ///
  /// - [filter]: The [JobFilterCriteria] to apply.
  Future<void> applyFilter(JobFilterCriteria filter) async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
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
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Loads the next page of jobs if available.
  Future<void> loadMoreJobs() async {
    if (!state.hasMoreJobs || state.isLoading) {
      return;
    }

    await loadJobs();
  }

  /// Clears the current job list and re-fetches the first page.
  Future<void> refreshJobs() async {
    await loadJobs(isRefresh: true);
  }

  /// Updates the `visibleJobs` list to support UI virtualization.
  ///
  /// This allows the UI to render only a small subset of the full job list,
  /// improving performance for very long lists.
  ///
  /// - [startIndex]: The starting index of the visible range.
  /// - [endIndex]: The ending index of the visible range.
  void updateVisibleJobsRange(int startIndex, int endIndex) {
    // Basic implementation: filter the visible jobs based on the range
    if (startIndex < 0 || endIndex < 0 || startIndex > endIndex) {
      return;
    }

    final List<Job> visibleJobs;
    if (startIndex >= state.jobs.length) {
      visibleJobs = <Job>[];
    } else {
      final safeEndIndex = endIndex >= state.jobs.length ? state.jobs.length - 1 : endIndex;
      visibleJobs = state.jobs.sublist(startIndex, safeEndIndex + 1);
    }

    state = state.copyWith(visibleJobs: visibleJobs);
  }

  /// Retrieves a single job from the currently loaded state by its ID.
  ///
  /// Returns the [Job] if found, otherwise `null`.
  Job? getJobById(String jobId) {
    try {
      return state.jobs.firstWhere((Job job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Clears any error message from the state.
  void clearError() {
    state = state.clearError();
  }

  /// Returns a map of performance metrics related to job loading.
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
      // TODO: Add back when utility classes are implemented
      // 'memoryUsage': _boundedJobList.estimatedMemoryUsage,
      // 'filterPerformance': _filterEngine.getAverageFilterTime(),
    };

  /// Disposes of managed resources.
  ///
  /// This is currently a placeholder for future implementations of more
  /// complex state management utilities.
  void dispose() {
    // TODO: Implement dispose when utility classes are ready
    // _operationManager.dispose();
    // _boundedJobList.dispose();
    // _virtualJobList.dispose();
  }
}

/// An auto-disposing provider that fetches a filtered list of jobs.
///
/// This provider is useful for one-off filtered queries where the state does not
/// need to be preserved after the UI component is unmounted.
///
/// - [filter]: The [JobFilterCriteria] to apply.
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

/// An auto-disposing provider for performing a text-based job search.
///
/// - [searchTerm]: The text query to search for.
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

/// A provider that fetches a single job by its unique ID.
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

/// A provider that fetches the 10 most recently posted jobs.
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

/// A provider that fetches a list of high-priority storm and emergency jobs.
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
