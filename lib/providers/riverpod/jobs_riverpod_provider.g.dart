// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Firestore service provider
@ProviderFor(firestoreService)
const firestoreServiceProvider = FirestoreServiceProvider._();

/// Firestore service provider
final class FirestoreServiceProvider extends $FunctionalProvider<
    ResilientFirestoreService,
    ResilientFirestoreService,
    ResilientFirestoreService> with $Provider<ResilientFirestoreService> {
  /// Firestore service provider
  const FirestoreServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firestoreServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firestoreServiceHash();

  @$internal
  @override
  $ProviderElement<ResilientFirestoreService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResilientFirestoreService create(Ref ref) {
    return firestoreService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResilientFirestoreService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResilientFirestoreService>(value),
    );
  }
}

String _$firestoreServiceHash() => r'665e0c40804f3306f3afbce70fab7d9fc5247907';

/// Jobs notifier for managing job data and operations
@ProviderFor(JobsNotifier)
const jobsNotifierProvider = JobsNotifierProvider._();

/// Jobs notifier for managing job data and operations
final class JobsNotifierProvider
    extends $NotifierProvider<JobsNotifier, JobsState> {
  /// Jobs notifier for managing job data and operations
  const JobsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobsNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobsNotifierHash();

  @$internal
  @override
  JobsNotifier create() => JobsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobsState>(value),
    );
  }
}

String _$jobsNotifierHash() => r'eaa70d0f9771f123801e9899315c4f251d1c6b29';

abstract class _$JobsNotifier extends $Notifier<JobsState> {
  JobsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<JobsState, JobsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JobsState, JobsState>, JobsState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Filtered jobs provider using family for auto-dispose
@ProviderFor(filteredJobs)
const filteredJobsProvider = FilteredJobsFamily._();

/// Filtered jobs provider using family for auto-dispose
final class FilteredJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Filtered jobs provider using family for auto-dispose
  const FilteredJobsProvider._(
      {required FilteredJobsFamily super.from,
      required JobFilterCriteria super.argument})
      : super(
          retry: null,
          name: r'filteredJobsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredJobsHash();

  @override
  String toString() {
    return r'filteredJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    final argument = this.argument as JobFilterCriteria;
    return filteredJobs(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredJobsHash() => r'd87176e3b18f3ffe0827695288d1091c9ee17bdc';

/// Filtered jobs provider using family for auto-dispose
final class FilteredJobsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Job>>, JobFilterCriteria> {
  const FilteredJobsFamily._()
      : super(
          retry: null,
          name: r'filteredJobsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Filtered jobs provider using family for auto-dispose
  FilteredJobsProvider call(
    JobFilterCriteria filter,
  ) =>
      FilteredJobsProvider._(argument: filter, from: this);

  @override
  String toString() => r'filteredJobsProvider';
}

/// Auto-dispose provider for job search
@ProviderFor(searchJobs)
const searchJobsProvider = SearchJobsFamily._();

/// Auto-dispose provider for job search
final class SearchJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Auto-dispose provider for job search
  const SearchJobsProvider._(
      {required SearchJobsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'searchJobsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchJobsHash();

  @override
  String toString() {
    return r'searchJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    final argument = this.argument as String;
    return searchJobs(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchJobsHash() => r'c973c85613a9a1fccaded8e95c8c0231f8543633';

/// Auto-dispose provider for job search
final class SearchJobsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Job>>, String> {
  const SearchJobsFamily._()
      : super(
          retry: null,
          name: r'searchJobsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Auto-dispose provider for job search
  SearchJobsProvider call(
    String searchTerm,
  ) =>
      SearchJobsProvider._(argument: searchTerm, from: this);

  @override
  String toString() => r'searchJobsProvider';
}

/// Job by ID provider
@ProviderFor(jobById)
const jobByIdProvider = JobByIdFamily._();

/// Job by ID provider
final class JobByIdProvider
    extends $FunctionalProvider<AsyncValue<Job?>, Job?, FutureOr<Job?>>
    with $FutureModifier<Job?>, $FutureProvider<Job?> {
  /// Job by ID provider
  const JobByIdProvider._(
      {required JobByIdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'jobByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobByIdHash();

  @override
  String toString() {
    return r'jobByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Job?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Job?> create(Ref ref) {
    final argument = this.argument as String;
    return jobById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JobByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobByIdHash() => r'55cd24edae351463fff57d8922094d773cb53c43';

/// Job by ID provider
final class JobByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Job?>, String> {
  const JobByIdFamily._()
      : super(
          retry: null,
          name: r'jobByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Job by ID provider
  JobByIdProvider call(
    String jobId,
  ) =>
      JobByIdProvider._(argument: jobId, from: this);

  @override
  String toString() => r'jobByIdProvider';
}

/// Recent jobs provider
@ProviderFor(recentJobs)
const recentJobsProvider = RecentJobsProvider._();

/// Recent jobs provider
final class RecentJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Recent jobs provider
  const RecentJobsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentJobsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentJobsHash();

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    return recentJobs(ref);
  }
}

String _$recentJobsHash() => r'00ef36440365b08fbee05afc728aacc3d2304bc3';

/// Storm jobs provider (high priority jobs)
@ProviderFor(stormJobs)
const stormJobsProvider = StormJobsProvider._();

/// Storm jobs provider (high priority jobs)
final class StormJobsProvider extends $FunctionalProvider<AsyncValue<List<Job>>,
        List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Storm jobs provider (high priority jobs)
  const StormJobsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'stormJobsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$stormJobsHash();

  @$internal
  @override
  $FutureProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Job>> create(Ref ref) {
    return stormJobs(ref);
  }
}

String _$stormJobsHash() => r'613175ea81d33573b25f79be03dacae9105fbefd';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
