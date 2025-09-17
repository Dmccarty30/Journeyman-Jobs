// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreServiceHash() => r'92564222ab3e11e8e2f122719bfec20d520a3074';

/// Firestore service provider
///
/// Copied from [firestoreService].
@ProviderFor(firestoreService)
final firestoreServiceProvider =
    AutoDisposeProvider<ResilientFirestoreService>.internal(
  firestoreService,
  name: r'firestoreServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreServiceRef = AutoDisposeProviderRef<ResilientFirestoreService>;
String _$filteredJobsHash() => r'f808184942b66ac2530a8cee778bd335f94fdd4e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Filtered jobs provider using family for auto-dispose
///
/// Copied from [filteredJobs].
@ProviderFor(filteredJobs)
const filteredJobsProvider = FilteredJobsFamily();

/// Filtered jobs provider using family for auto-dispose
///
/// Copied from [filteredJobs].
class FilteredJobsFamily extends Family<AsyncValue<List<Job>>> {
  /// Filtered jobs provider using family for auto-dispose
  ///
  /// Copied from [filteredJobs].
  const FilteredJobsFamily();

  /// Filtered jobs provider using family for auto-dispose
  ///
  /// Copied from [filteredJobs].
  FilteredJobsProvider call(
    JobFilterCriteria filter,
  ) {
    return FilteredJobsProvider(
      filter,
    );
  }

  @override
  FilteredJobsProvider getProviderOverride(
    covariant FilteredJobsProvider provider,
  ) {
    return call(
      provider.filter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredJobsProvider';
}

/// Filtered jobs provider using family for auto-dispose
///
/// Copied from [filteredJobs].
class FilteredJobsProvider extends AutoDisposeFutureProvider<List<Job>> {
  /// Filtered jobs provider using family for auto-dispose
  ///
  /// Copied from [filteredJobs].
  FilteredJobsProvider(
    JobFilterCriteria filter,
  ) : this._internal(
          (ref) => filteredJobs(
            ref as FilteredJobsRef,
            filter,
          ),
          from: filteredJobsProvider,
          name: r'filteredJobsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredJobsHash,
          dependencies: FilteredJobsFamily._dependencies,
          allTransitiveDependencies:
              FilteredJobsFamily._allTransitiveDependencies,
          filter: filter,
        );

  FilteredJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final JobFilterCriteria filter;

  @override
  Override overrideWith(
    FutureOr<List<Job>> Function(FilteredJobsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredJobsProvider._internal(
        (ref) => create(ref as FilteredJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Job>> createElement() {
    return _FilteredJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredJobsProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredJobsRef on AutoDisposeFutureProviderRef<List<Job>> {
  /// The parameter `filter` of this provider.
  JobFilterCriteria get filter;
}

class _FilteredJobsProviderElement
    extends AutoDisposeFutureProviderElement<List<Job>> with FilteredJobsRef {
  _FilteredJobsProviderElement(super.provider);

  @override
  JobFilterCriteria get filter => (origin as FilteredJobsProvider).filter;
}

String _$searchJobsHash() => r'1742fb28e041cf640cdf8653ee5b6870b2943d37';

/// Auto-dispose provider for job search
///
/// Copied from [searchJobs].
@ProviderFor(searchJobs)
const searchJobsProvider = SearchJobsFamily();

/// Auto-dispose provider for job search
///
/// Copied from [searchJobs].
class SearchJobsFamily extends Family<AsyncValue<List<Job>>> {
  /// Auto-dispose provider for job search
  ///
  /// Copied from [searchJobs].
  const SearchJobsFamily();

  /// Auto-dispose provider for job search
  ///
  /// Copied from [searchJobs].
  SearchJobsProvider call(
    String searchTerm,
  ) {
    return SearchJobsProvider(
      searchTerm,
    );
  }

  @override
  SearchJobsProvider getProviderOverride(
    covariant SearchJobsProvider provider,
  ) {
    return call(
      provider.searchTerm,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchJobsProvider';
}

/// Auto-dispose provider for job search
///
/// Copied from [searchJobs].
class SearchJobsProvider extends AutoDisposeFutureProvider<List<Job>> {
  /// Auto-dispose provider for job search
  ///
  /// Copied from [searchJobs].
  SearchJobsProvider(
    String searchTerm,
  ) : this._internal(
          (ref) => searchJobs(
            ref as SearchJobsRef,
            searchTerm,
          ),
          from: searchJobsProvider,
          name: r'searchJobsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchJobsHash,
          dependencies: SearchJobsFamily._dependencies,
          allTransitiveDependencies:
              SearchJobsFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  SearchJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchTerm,
  }) : super.internal();

  final String searchTerm;

  @override
  Override overrideWith(
    FutureOr<List<Job>> Function(SearchJobsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchJobsProvider._internal(
        (ref) => create(ref as SearchJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Job>> createElement() {
    return _SearchJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchJobsProvider && other.searchTerm == searchTerm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchTerm.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchJobsRef on AutoDisposeFutureProviderRef<List<Job>> {
  /// The parameter `searchTerm` of this provider.
  String get searchTerm;
}

class _SearchJobsProviderElement
    extends AutoDisposeFutureProviderElement<List<Job>> with SearchJobsRef {
  _SearchJobsProviderElement(super.provider);

  @override
  String get searchTerm => (origin as SearchJobsProvider).searchTerm;
}

String _$jobByIdHash() => r'054afb4a6f2974156198be45901444ca798ea1f9';

/// Job by ID provider
///
/// Copied from [jobById].
@ProviderFor(jobById)
const jobByIdProvider = JobByIdFamily();

/// Job by ID provider
///
/// Copied from [jobById].
class JobByIdFamily extends Family<AsyncValue<Job?>> {
  /// Job by ID provider
  ///
  /// Copied from [jobById].
  const JobByIdFamily();

  /// Job by ID provider
  ///
  /// Copied from [jobById].
  JobByIdProvider call(
    String jobId,
  ) {
    return JobByIdProvider(
      jobId,
    );
  }

  @override
  JobByIdProvider getProviderOverride(
    covariant JobByIdProvider provider,
  ) {
    return call(
      provider.jobId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'jobByIdProvider';
}

/// Job by ID provider
///
/// Copied from [jobById].
class JobByIdProvider extends AutoDisposeFutureProvider<Job?> {
  /// Job by ID provider
  ///
  /// Copied from [jobById].
  JobByIdProvider(
    String jobId,
  ) : this._internal(
          (ref) => jobById(
            ref as JobByIdRef,
            jobId,
          ),
          from: jobByIdProvider,
          name: r'jobByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jobByIdHash,
          dependencies: JobByIdFamily._dependencies,
          allTransitiveDependencies: JobByIdFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  JobByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    FutureOr<Job?> Function(JobByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobByIdProvider._internal(
        (ref) => create(ref as JobByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Job?> createElement() {
    return _JobByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobByIdProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobByIdRef on AutoDisposeFutureProviderRef<Job?> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _JobByIdProviderElement extends AutoDisposeFutureProviderElement<Job?>
    with JobByIdRef {
  _JobByIdProviderElement(super.provider);

  @override
  String get jobId => (origin as JobByIdProvider).jobId;
}

String _$recentJobsHash() => r'a9698563aa709fb7a8e2a71c5a687bf23ad628af';

/// Recent jobs provider
///
/// Copied from [recentJobs].
@ProviderFor(recentJobs)
final recentJobsProvider = AutoDisposeFutureProvider<List<Job>>.internal(
  recentJobs,
  name: r'recentJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recentJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentJobsRef = AutoDisposeFutureProviderRef<List<Job>>;
String _$stormJobsHash() => r'421a5c47787c0eccd3abde306627c8602d58e12e';

/// Storm jobs provider (high priority jobs)
///
/// Copied from [stormJobs].
@ProviderFor(stormJobs)
final stormJobsProvider = AutoDisposeFutureProvider<List<Job>>.internal(
  stormJobs,
  name: r'stormJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$stormJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StormJobsRef = AutoDisposeFutureProviderRef<List<Job>>;
String _$jobsNotifierHash() => r'bb68107f35fb2309631b7e785b42d8374e30ca2a';

/// Jobs notifier for managing job data and operations
///
/// Copied from [JobsNotifier].
@ProviderFor(JobsNotifier)
final jobsNotifierProvider =
    AutoDisposeNotifierProvider<JobsNotifier, JobsState>.internal(
  JobsNotifier.new,
  name: r'jobsNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$jobsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobsNotifier = AutoDisposeNotifier<JobsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
