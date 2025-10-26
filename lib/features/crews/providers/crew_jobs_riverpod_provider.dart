// lib/features/crews/providers/crew_jobs_riverpod_provider.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/job_model.dart'; // Canonical Job model
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import 'crews_riverpod_provider.dart';

part 'crew_jobs_riverpod_provider.g.dart';

/// Crew filtered jobs stream provider - uses JobMatchingService to get jobs filtered by crew preferences
@riverpod
Stream<List<Job>> crewFilteredJobsStream(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final jobMatchingService = ref.watch(jobMatchingServiceProvider);

  if (currentUser == null) {
    return Stream.value([]);
  }

  return jobMatchingService.getCrewFilteredJobsStream(crewId).handleError((error, stackTrace) {
    // Log error or handle as needed
    if (kDebugMode) {
      print('Error in crew filtered jobs stream: $error');
    }
    return Stream.value([]);
  });
}

/// Crew filtered jobs - extracts data from AsyncValue
@riverpod
List<Job> crewFilteredJobs(Ref ref, String crewId) {
  final jobsAsync = ref.watch(crewFilteredJobsStreamProvider(crewId));
  
  return jobsAsync.when(
    data: (jobs) => jobs,
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider to check if crew filtered jobs are loading
@riverpod
bool isCrewJobsLoading(Ref ref, String crewId) {
  final jobsAsync = ref.watch(crewFilteredJobsStreamProvider(crewId));
  return jobsAsync.isLoading;
}

/// Provider for crew filtered jobs error
@riverpod
String? crewJobsError(Ref ref, String crewId) {
  final jobsAsync = ref.watch(crewFilteredJobsStreamProvider(crewId));
  return jobsAsync.error?.toString();
}
