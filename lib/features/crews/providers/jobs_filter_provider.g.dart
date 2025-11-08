// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for jobs filter state

@ProviderFor(JobsFilter)
const jobsFilterProvider = JobsFilterProvider._();

/// Provider for jobs filter state
final class JobsFilterProvider
    extends $NotifierProvider<JobsFilter, JobsFilterState> {
  /// Provider for jobs filter state
  const JobsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobsFilterHash();

  @$internal
  @override
  JobsFilter create() => JobsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobsFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobsFilterState>(value),
    );
  }
}

String _$jobsFilterHash() => r'95e625d46d337ec3e330755a7a504b41120f256a';

/// Provider for jobs filter state

abstract class _$JobsFilter extends $Notifier<JobsFilterState> {
  JobsFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<JobsFilterState, JobsFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JobsFilterState, JobsFilterState>,
              JobsFilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for filtered jobs based on crew preferences AND user filters

@ProviderFor(filteredCrewJobs)
const filteredCrewJobsProvider = FilteredCrewJobsFamily._();

/// Provider for filtered jobs based on crew preferences AND user filters

final class FilteredCrewJobsProvider
    extends $FunctionalProvider<List<Job>, List<Job>, List<Job>>
    with $Provider<List<Job>> {
  /// Provider for filtered jobs based on crew preferences AND user filters
  const FilteredCrewJobsProvider._({
    required FilteredCrewJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredCrewJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredCrewJobsHash();

  @override
  String toString() {
    return r'filteredCrewJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Job> create(Ref ref) {
    final argument = this.argument as String;
    return filteredCrewJobs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Job> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Job>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredCrewJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredCrewJobsHash() => r'1f97e1a06e7e719428307790902b5ce04f30b9ba';

/// Provider for filtered jobs based on crew preferences AND user filters

final class FilteredCrewJobsFamily extends $Family
    with $FunctionalFamilyOverride<List<Job>, String> {
  const FilteredCrewJobsFamily._()
    : super(
        retry: null,
        name: r'filteredCrewJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for filtered jobs based on crew preferences AND user filters

  FilteredCrewJobsProvider call(String crewId) =>
      FilteredCrewJobsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'filteredCrewJobsProvider';
}

/// Provider to check if any filters are active

@ProviderFor(hasActiveJobFilters)
const hasActiveJobFiltersProvider = HasActiveJobFiltersProvider._();

/// Provider to check if any filters are active

final class HasActiveJobFiltersProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if any filters are active
  const HasActiveJobFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasActiveJobFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasActiveJobFiltersHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasActiveJobFilters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasActiveJobFiltersHash() =>
    r'2510b4083993871ad4ba3b33a539c54a02ac227a';

/// Provider to get filter summary text

@ProviderFor(jobFilterSummary)
const jobFilterSummaryProvider = JobFilterSummaryProvider._();

/// Provider to get filter summary text

final class JobFilterSummaryProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider to get filter summary text
  const JobFilterSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobFilterSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobFilterSummaryHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return jobFilterSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$jobFilterSummaryHash() => r'cef3ab5689e2c20695011da5af0f0c8966a43058';
