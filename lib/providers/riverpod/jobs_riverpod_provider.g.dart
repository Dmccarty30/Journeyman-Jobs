// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreServiceHash() => r'8f72ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7i';

/// Firestore service provider
///
/// Copied from [firestoreService].
@ProviderFor(firestoreService)
final firestoreServiceProvider = Provider<ResilientFirestoreService>.internal(
  firestoreService,
  name: r'firestoreServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirestoreServiceRef = ProviderRef<ResilientFirestoreService>;
String _$filteredJobsHash() => r'7e61ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7j';

/// Filtered jobs provider using family for auto-dispose
///
/// Copied from [filteredJobs].
@ProviderFor(filteredJobs)
final filteredJobsProvider = AutoDisposeFutureProviderFamily<List<Job>, JobFilterCriteria>.internal(
  filteredJobs,
  name: r'filteredJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredJobsRef = AutoDisposeFutureProviderRef<List<Job>>;
String _$searchJobsHash() => r'6d50ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7k';

/// Auto-dispose provider for job search
///
/// Copied from [searchJobs].
@ProviderFor(searchJobs)
final searchJobsProvider = AutoDisposeFutureProviderFamily<List<Job>, String>.internal(
  searchJobs,
  name: r'searchJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SearchJobsRef = AutoDisposeFutureProviderRef<List<Job>>;
String _$jobByIdHash() => r'5c4fac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7l';

/// Job by ID provider
///
/// Copied from [jobById].
@ProviderFor(jobById)
final jobByIdProvider = AutoDisposeFutureProviderFamily<Job?, String>.internal(
  jobById,
  name: r'jobByIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobByIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef JobByIdRef = AutoDisposeFutureProviderRef<Job?>;
String _$recentJobsHash() => r'4b3eac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7m';

/// Recent jobs provider
///
/// Copied from [recentJobs].
@ProviderFor(recentJobs)
final recentJobsProvider = AutoDisposeFutureProvider<List<Job>>.internal(
  recentJobs,
  name: r'recentJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentJobsRef = AutoDisposeFutureProviderRef<List<Job>>;
String _$stormJobsHash() => r'3a2dac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7n';

/// Storm jobs provider (high priority jobs)
///
/// Copied from [stormJobs].
@ProviderFor(stormJobs)
final stormJobsProvider = AutoDisposeFutureProvider<List<Job>>.internal(
  stormJobs,
  name: r'stormJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stormJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StormJobsRef = AutoDisposeFutureProviderRef<List<Job>>;
String _$jobsNotifierHash() => r'2918ac1c2a3e4b5d6c7f8e9a0b1c2d3e4f5g6h7o';

/// Jobs notifier for managing job data and operations
///
/// Copied from [JobsNotifier].
@ProviderFor(JobsNotifier)
final jobsNotifierProvider = NotifierProvider<JobsNotifier, JobsState>.internal(
  JobsNotifier.new,
  name: r'jobsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobsNotifier = Notifier<JobsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member