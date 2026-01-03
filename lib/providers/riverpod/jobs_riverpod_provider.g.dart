// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firestore service provider

@ProviderFor(firestoreService)
final firestoreServiceProvider = FirestoreServiceProvider._();

/// Firestore service provider

final class FirestoreServiceProvider extends $FunctionalProvider<
    ResilientFirestoreService,
    ResilientFirestoreService,
    ResilientFirestoreService> with $Provider<ResilientFirestoreService> {
  /// Firestore service provider
  FirestoreServiceProvider._()
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

/// Feedback service provider

@ProviderFor(feedbackService)
final feedbackServiceProvider = FeedbackServiceProvider._();

/// Feedback service provider

final class FeedbackServiceProvider extends $FunctionalProvider<FeedbackService,
    FeedbackService, FeedbackService> with $Provider<FeedbackService> {
  /// Feedback service provider
  FeedbackServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedbackServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedbackServiceHash();

  @$internal
  @override
  $ProviderElement<FeedbackService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedbackService create(Ref ref) {
    return feedbackService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedbackService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedbackService>(value),
    );
  }
}

String _$feedbackServiceHash() => r'e3a2aa2c2ed5ebd1eea084b6f68c0bef3a68b8e7';

/// User Preference Service provider

@ProviderFor(userPreferenceService)
final userPreferenceServiceProvider = UserPreferenceServiceProvider._();

/// User Preference Service provider

final class UserPreferenceServiceProvider extends $FunctionalProvider<
    UserPreferenceService,
    UserPreferenceService,
    UserPreferenceService> with $Provider<UserPreferenceService> {
  /// User Preference Service provider
  UserPreferenceServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userPreferenceServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPreferenceServiceHash();

  @$internal
  @override
  $ProviderElement<UserPreferenceService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserPreferenceService create(Ref ref) {
    return userPreferenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPreferenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPreferenceService>(value),
    );
  }
}

String _$userPreferenceServiceHash() =>
    r'1cd146953c28b40960faa768664c813321f0f342';

/// Local AI Model Service provider

@ProviderFor(localModelServicePod)
final localModelServicePodProvider = LocalModelServicePodProvider._();

/// Local AI Model Service provider

final class LocalModelServicePodProvider extends $FunctionalProvider<
    LocalModelService,
    LocalModelService,
    LocalModelService> with $Provider<LocalModelService> {
  /// Local AI Model Service provider
  LocalModelServicePodProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localModelServicePodProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localModelServicePodHash();

  @$internal
  @override
  $ProviderElement<LocalModelService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalModelService create(Ref ref) {
    return localModelServicePod(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalModelService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalModelService>(value),
    );
  }
}

String _$localModelServicePodHash() =>
    r'3e81c0dbab2f0c8336d4275401721ea63283bbe3';

/// Jobs notifier for managing job data and operations

@ProviderFor(JobsNotifier)
final jobsProvider = JobsNotifierProvider._();

/// Jobs notifier for managing job data and operations
final class JobsNotifierProvider
    extends $NotifierProvider<JobsNotifier, JobsState> {
  /// Jobs notifier for managing job data and operations
  JobsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobsProvider',
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

String _$jobsNotifierHash() => r'8ca79f824c99c26619040d418121349e49c93e3b';

/// Jobs notifier for managing job data and operations

abstract class _$JobsNotifier extends $Notifier<JobsState> {
  JobsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<JobsState, JobsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JobsState, JobsState>, JobsState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Filtered jobs provider using family for auto-dispose

@ProviderFor(filteredJobs)
final filteredJobsProvider = FilteredJobsFamily._();

/// Filtered jobs provider using family for auto-dispose

final class FilteredJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Filtered jobs provider using family for auto-dispose
  FilteredJobsProvider._(
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

String _$filteredJobsHash() => r'f34109b3e9daa3e8f76eee9badfa2c7817cc0ada';

/// Filtered jobs provider using family for auto-dispose

final class FilteredJobsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Job>>, JobFilterCriteria> {
  FilteredJobsFamily._()
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
final searchJobsProvider = SearchJobsFamily._();

/// Auto-dispose provider for job search

final class SearchJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Auto-dispose provider for job search
  SearchJobsProvider._(
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

String _$searchJobsHash() => r'ddc3acadff3d73c6ab9b471f80bdbc3b95ee5097';

/// Auto-dispose provider for job search

final class SearchJobsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Job>>, String> {
  SearchJobsFamily._()
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
final jobByIdProvider = JobByIdFamily._();

/// Job by ID provider

final class JobByIdProvider
    extends $FunctionalProvider<AsyncValue<Job?>, Job?, FutureOr<Job?>>
    with $FutureModifier<Job?>, $FutureProvider<Job?> {
  /// Job by ID provider
  JobByIdProvider._(
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

String _$jobByIdHash() => r'fe0b6ad481434b99b4f2dd06952e724f38be0922';

/// Job by ID provider

final class JobByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Job?>, String> {
  JobByIdFamily._()
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
final recentJobsProvider = RecentJobsProvider._();

/// Recent jobs provider

final class RecentJobsProvider extends $FunctionalProvider<
        AsyncValue<List<Job>>, List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Recent jobs provider
  RecentJobsProvider._()
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

String _$recentJobsHash() => r'8341fc7b0b1a2cdd2a579f40045cde688c655cb9';

/// Storm jobs provider (high priority jobs)

@ProviderFor(stormJobs)
final stormJobsProvider = StormJobsProvider._();

/// Storm jobs provider (high priority jobs)

final class StormJobsProvider extends $FunctionalProvider<AsyncValue<List<Job>>,
        List<Job>, FutureOr<List<Job>>>
    with $FutureModifier<List<Job>>, $FutureProvider<List<Job>> {
  /// Storm jobs provider (high priority jobs)
  StormJobsProvider._()
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

String _$stormJobsHash() => r'd996a8a060f5630019fcddb8edd0c1fa279dcfad';
