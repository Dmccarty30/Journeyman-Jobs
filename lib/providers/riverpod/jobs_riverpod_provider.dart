import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
import '../../services/resilient_firestore_service.dart';
import '../../utils/concurrent_operations.dart';
import '../../utils/filter_performance.dart';
import '../../utils/memory_management.dart';

part 'jobs_riverpod_provider.g.dart';

/// Jobs state model for Riverpod
class JobsState {

  const JobsState({
    this.jobs = const <Job>[],
    this.visibleJobs = const <Job>[],
    this.activeFilter = const JobFilterCriteria.empty(),
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
@Riverpod(keepAlive: true)
ResilientFirestoreService firestoreService(FirestoreServiceRef ref) => ResilientFirestoreService();

/// Jobs notifier for managing job data and operations
@Riverpod(keepAlive: true)
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
  Future<void> loadJobs({
    JobFilterCriteria? filter,
    bool isRefresh = false,
    int limit = 20,
  }) async {
    const String operationId = 'load_jobs';
    
    if (_operationManager.isOperationInProgress(operationId)) {
      return;
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
        operationId,
        () => ref.read(firestoreServiceProvider).getJobs(
          filter: filter ?? state.activeFilter,
          startAfter: isRefresh ? null : state.lastDocument,
          limit: limit,
        ),
      );

      stopwatch.stop();

      // Update bounded job list
      if (isRefresh) {
        _boundedJobList.replaceAll(result.jobs);
      } else {
        _boundedJobList.addAll(result.jobs);
      }

      // Update virtual job list for performance
      _virtualJobList.updateJobs(_boundedJobList.jobs);

      // Update load times for performance tracking
      final List<Duration> newLoadTimes = List<Duration>.from(state.loadTimes)
        ..add(stopwatch.elapsed);
      if (newLoadTimes.length > 50) {
        newLoadTimes.removeAt(0); // Keep only last 50 measurements
      }

      state = state.copyWith(
        jobs: _boundedJobList.jobs,
        visibleJobs: _virtualJobList.visibleJobs,
        activeFilter: filter ?? state.activeFilter,
        isLoading: false,
        hasMoreJobs: result.hasMore,
        lastDocument: result.lastDocument,
        loadTimes: newLoadTimes,
        totalJobsLoaded: state.totalJobsLoaded + result.jobs.length,
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

  /// Apply filter to jobs
  Future<void> applyFilter(JobFilterCriteria filter) async {
    const String operationId = 'apply_filter';
    
    if (_operationManager.isOperationInProgress(operationId)) {
      return;
    }

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      // Use filter performance engine for optimization
      final optimizedFilter = _filterEngine.optimizeFilter(filter);
      
      await _operationManager.executeOperation(
        operationId,
        () => loadJobs(filter: optimizedFilter, isRefresh: true),
      );

      stopwatch.stop();
      _filterEngine.recordFilterTime(stopwatch.elapsed);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
    _virtualJobList.updateVisibleRange(startIndex, endIndex);
    state = state.copyWith(visibleJobs: _virtualJobList.visibleJobs);
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
      'filterPerformance': _filterEngine.getAverageFilterTime(),
    };

  /// Dispose resources
  void dispose() {
    _operationManager.dispose();
    _boundedJobList.dispose();
    _virtualJobList.dispose();
  }
}

/// Filtered jobs provider using family for auto-dispose
@riverpod
Future<List<Job>> filteredJobs(
  FilteredJobsRef ref,
  JobFilterCriteria filter,
) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  final result = await firestoreService.getJobs(
    filter: filter,
    limit: 50,
  );
  
  return result.jobs;
}

/// Auto-dispose provider for job search
@riverpod
Future<List<Job>> searchJobs(
  SearchJobsRef ref,
  String searchTerm,
) async {
  if (searchTerm.trim().isEmpty) {
    return <Job>[];
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  
  final JobFilterCriteria filter = JobFilterCriteria(
    searchTerm: searchTerm,
  );
  
  final result = await firestoreService.getJobs(
    filter: filter,
    limit: 20,
  );
  
  return result.jobs;
}

/// Job by ID provider
@riverpod
Future<Job?> jobById(JobByIdRef ref, String jobId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getJobById(jobId);
}

/// Recent jobs provider
@riverpod
Future<List<Job>> recentJobs(RecentJobsRef ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  const JobFilterCriteria filter = JobFilterCriteria(
    sortBy: 'postedDate',
    sortOrder: 'desc',
  );
  
  final result = await firestoreService.getJobs(
    filter: filter,
    limit: 10,
  );
  
  return result.jobs;
}

/// Storm jobs provider (high priority jobs)
@riverpod
Future<List<Job>> stormJobs(StormJobsRef ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  const JobFilterCriteria filter = JobFilterCriteria(
    jobType: <String>['storm', 'emergency'],
    sortBy: 'priority',
    sortOrder: 'desc',
  );
  
  final result = await firestoreService.getJobs(
    filter: filter,
    limit: 20,
  );
  
  return result.jobs;
}
