import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/filter_criteria.dart';
import '../../models/job_model.dart';
import '../../models/user_feedback_model.dart';
import '../../services/feedback_service.dart';
import '../../services/user_preference_service.dart';
import '../../services/local_model_service.dart';
import '../../services/resilient_firestore_service.dart';
import '../../utils/concurrent_operations.dart';
// TODO: Add back when utility classes are implemented
// import '../../utils/filter_performance.dart';
// import '../../utils/memory_management.dart';

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
  }) =>
      JobsState(
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
ResilientFirestoreService firestoreService(Ref ref) =>
    ResilientFirestoreService();

/// Feedback service provider
@riverpod
FeedbackService feedbackService(Ref ref) => FeedbackService();

/// User Preference Service provider
@riverpod
UserPreferenceService userPreferenceService(Ref ref) => UserPreferenceService();

/// Local AI Model Service provider
@riverpod
LocalModelService localModelServicePod(Ref ref) => LocalModelService();

/// Jobs notifier for managing job data and operations
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

  /// Load jobs with pagination
  Future<void> loadJobs({
    JobFilterCriteria? filter,
    bool isRefresh = false,
    int limit = 20,
  }) async {
    if (_operationManager.isOperationInProgress(OperationType.loadJobs)) {
      return;
    }

    if (kDebugMode) {
      debugPrint(
          '[DEBUG] JobsNotifier.loadJobs called - isRefresh: $isRefresh, filter: ${filter?.toString()}, limit: $limit');
    }

    if (isRefresh) {
      state = state.copyWith(
        jobs: <Job>[],
        visibleJobs: <Job>[],
        hasMoreJobs: true,
        isLoading: true,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final result = await _operationManager.executeOperation(
        type: OperationType.loadJobs,
        operation: () async {
          final firestoreService = ref.read(firestoreServiceProvider);
          if (kDebugMode) debugPrint('[DEBUG] Calling Firestore service...');

          if (filter != null) {
            return await firestoreService.getJobsWithFilter(
              filter: filter,
              startAfter: isRefresh ? null : state.lastDocument,
              limit: limit,
            );
          } else {
            if (kDebugMode) debugPrint('[DEBUG] Using basic jobs query');
            final stream = firestoreService.getJobs(
              startAfter: isRefresh ? null : state.lastDocument,
              limit: limit,
            );
            return await stream.first;
          }
        },
      );

      stopwatch.stop();
      if (kDebugMode) {
        debugPrint(
            '[DEBUG] Query completed in ${stopwatch.elapsedMilliseconds}ms');
        debugPrint('[DEBUG] Documents received: ${result.docs.length}');
      }

      if (result.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[DEBUG] Sample document ID: ${result.docs.first.id}');
          debugPrint(
              '[DEBUG] Sample document data keys: ${(result.docs.first.data() as Map<String, dynamic>).keys.toList()}');
          debugPrint('[DEBUG] Sample raw data: ${result.docs.first.data()}');
        }
      }

      // Convert QuerySnapshot to Job objects
      final jobs = result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        if (kDebugMode) {
          debugPrint(
              '[DEBUG] Parsing job ${doc.id}: raw hours=${data['hours']}, wage=${data['wage']}, perDiem=${data['perDiem']}, startDate=${data['startDate']}');
        }
        final job = Job.fromJson(data);
        if (kDebugMode) {
          debugPrint(
              '[DEBUG] Parsed job ${doc.id}: hours=${job.hours}, wage=${job.wage}, perDiem=${job.perDiem}, startDate=${job.startDate}');
        }
        return job;
      }).toList();

      if (kDebugMode) {
        debugPrint('[DEBUG] Successfully parsed ${jobs.length} jobs');
      }

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
      if (kDebugMode) {
        debugPrint('[DEBUG] State updated - total jobs: ${updatedJobs.length}');
      }

      // After loading jobs, check for matches and notify
      await checkForNewJobMatches(jobs);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) debugPrint('[DEBUG] LoadJobs ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Apply filter to jobs
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
    // Basic implementation: filter the visible jobs based on the range
    if (startIndex < 0 || endIndex < 0 || startIndex > endIndex) {
      return;
    }

    final List<Job> visibleJobs;
    if (startIndex >= state.jobs.length) {
      visibleJobs = <Job>[];
    } else {
      final safeEndIndex =
          endIndex >= state.jobs.length ? state.jobs.length - 1 : endIndex;
      visibleJobs = state.jobs.sublist(startIndex, safeEndIndex + 1);
    }

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

  /// Checks newly loaded jobs against user preferences and triggers notifications for matches.
  Future<void> checkForNewJobMatches(List<Job> newJobs) async {
    if (kDebugMode) {
      debugPrint('[DEBUG] Checking ${newJobs.length} new jobs for matches...');
    }
    // Placeholder for userId - in a real app, this would come from an auth provider.
    final String userId = 'dummy_user_id';
    final UserPreferenceService preferenceService =
        ref.read(userPreferenceServiceProvider);
    final LocalModelService localModelService =
        ref.read(localModelServicePodProvider);

    // Placeholder: Get user preferences.
    // In a real app, this would fetch actual user preferences from Firestore via preferenceService.
    final Map<String, dynamic> userPreferences =
        await preferenceService.getUserPreferences(userId) ??
            {
              'preferredLocation': 'Florida',
              'minWage': 30.0,
              'hasPerDiem': true,
            };
    if (kDebugMode) {
      debugPrint('[DEBUG] User preferences for matching: $userPreferences');
    }

    for (final job in newJobs) {
      // Placeholder for actual matching logic with AI model.
      // Here, we simulate a match based on simple criteria.
      bool isMatch = false;
      if (userPreferences.containsKey('minWage') &&
          job.wage != null &&
          job.wage! >= userPreferences['minWage']) {
        isMatch = true;
      }
      if (userPreferences.containsKey('hasPerDiem') &&
          userPreferences['hasPerDiem'] == true &&
          job.perDiem != null &&
          job.perDiem!.isNotEmpty) {
        isMatch = true;
      }
      // Simulate calling a local AI model for a more sophisticated match
      // For now, localModelService.matchUserExperienceToPreferences is used as a generic AI check
      // In a real scenario, a dedicated matching method might be more appropriate.
      // For simplicity, we'll just check if the model would "process" it.
      await localModelService
          .summarizeJob(job.jobTitle ?? job.company); // Simulate processing

      if (isMatch) {
        if (kDebugMode) {
          debugPrint(
              '[DEBUG] Job match found: ${job.jobTitle} at ${job.company}');
        }
        // Placeholder for triggering a notification.
        // In a real app, this would use flutter_local_notifications or FCM.
        _triggerNotification('New Job Match!',
            'A new job matching your preferences has been found: ${job.jobTitle} at ${job.company}.');
      }
    }
    if (kDebugMode) {
      debugPrint('[DEBUG] Finished checking new jobs for matches.');
    }
  }

  /// Placeholder for triggering local notifications.
  void _triggerNotification(String title, String body) {
    if (kDebugMode) debugPrint('[NOTIFICATION] $title: $body');
    // TODO: Integrate with flutter_local_notifications package here.
  }

  /// Collects user feedback for a specific job.
  Future<void> collectJobFeedback(Job job,
      {String? feedbackText, double rating = 0.0}) async {
    if (kDebugMode) {
      debugPrint('[DEBUG] Collecting feedback for job: ${job.id}');
    }
    final FeedbackService feedbackService = ref.read(feedbackServiceProvider);

    // Placeholder for userId - in a real app, this would come from an auth provider
    final String userId = 'dummy_user_id';

    final UserFeedback feedback = UserFeedback(
      id: '', // Firestore will assign an ID
      userId: userId,
      subjectId: job.id,
      subjectType: 'job',
      feedbackText: feedbackText ?? 'Job viewed', // Default feedback
      rating: rating,
      createdAt: Timestamp.now(),
    );

    try {
      await feedbackService.addFeedback(feedback);
      if (kDebugMode) {
        debugPrint(
            '[DEBUG] Feedback successfully collected for job: ${job.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ERROR] Failed to collect feedback for job ${job.id}: $e');
      }
      // Handle error, e.g., show a toast to the user
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
        // TODO: Add back when utility classes are implemented
        // 'memoryUsage': _boundedJobList.estimatedMemoryUsage,
        // 'filterPerformance': _filterEngine.getAverageFilterTime(),
      };

  /// Dispose resources
  void dispose() {
    // TODO: Implement dispose when utility classes are ready
    // _operationManager.dispose();
    // _boundedJobList.dispose();
    // _virtualJobList.dispose();
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
