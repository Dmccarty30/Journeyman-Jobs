// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_filter_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'478f199fb7a4d61bcad4292f3db43e351478a6a7';

/// SharedPreferences provider
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$currentJobFilterHash() => r'1c38045fc754c82a9d5bb84b78182d4492095829';

/// Current filter provider (computed from state)
///
/// Copied from [currentJobFilter].
@ProviderFor(currentJobFilter)
final currentJobFilterProvider =
    AutoDisposeProvider<JobFilterCriteria>.internal(
  currentJobFilter,
  name: r'currentJobFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentJobFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentJobFilterRef = AutoDisposeProviderRef<JobFilterCriteria>;
String _$filterPresetsHash() => r'2d3d31ef20b7d6341c83a52cde26698b2ef9db41';

/// Presets provider (computed from state)
///
/// Copied from [filterPresets].
@ProviderFor(filterPresets)
final filterPresetsProvider = AutoDisposeProvider<List<FilterPreset>>.internal(
  filterPresets,
  name: r'filterPresetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filterPresetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilterPresetsRef = AutoDisposeProviderRef<List<FilterPreset>>;
String _$recentSearchesHash() => r'9821676370caa38ec8e142aef676b44a9d7d851d';

/// Recent searches provider (computed from state)
///
/// Copied from [recentSearches].
@ProviderFor(recentSearches)
final recentSearchesProvider = AutoDisposeProvider<List<String>>.internal(
  recentSearches,
  name: r'recentSearchesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentSearchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentSearchesRef = AutoDisposeProviderRef<List<String>>;
String _$pinnedPresetsHash() => r'49d89eb1d57185f91b4900b962afff0d1f995660';

/// Pinned presets provider (computed from state)
///
/// Copied from [pinnedPresets].
@ProviderFor(pinnedPresets)
final pinnedPresetsProvider = AutoDisposeProvider<List<FilterPreset>>.internal(
  pinnedPresets,
  name: r'pinnedPresetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pinnedPresetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PinnedPresetsRef = AutoDisposeProviderRef<List<FilterPreset>>;
String _$recentPresetsHash() => r'6f7ccf4d0ea932c82d27947e9eb6d8a7e73d2752';

/// Recent presets provider (computed from state)
///
/// Copied from [recentPresets].
@ProviderFor(recentPresets)
final recentPresetsProvider = AutoDisposeProvider<List<FilterPreset>>.internal(
  recentPresets,
  name: r'recentPresetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentPresetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentPresetsRef = AutoDisposeProviderRef<List<FilterPreset>>;
String _$hasActiveFiltersHash() => r'686d42b7186e13d87739c2c1a20e20c54b677d35';

/// Active filters status provider (computed from state)
///
/// Copied from [hasActiveFilters].
@ProviderFor(hasActiveFilters)
final hasActiveFiltersProvider = AutoDisposeProvider<bool>.internal(
  hasActiveFilters,
  name: r'hasActiveFiltersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveFiltersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasActiveFiltersRef = AutoDisposeProviderRef<bool>;
String _$activeFilterCountHash() => r'86ba906dbf54cf223e973341a724ef6332ee4ffc';

/// Active filter count provider (computed from state)
///
/// Copied from [activeFilterCount].
@ProviderFor(activeFilterCount)
final activeFilterCountProvider = AutoDisposeProvider<int>.internal(
  activeFilterCount,
  name: r'activeFilterCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeFilterCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveFilterCountRef = AutoDisposeProviderRef<int>;
String _$quickFilterSuggestionsHash() =>
    r'866dc1cf24f212387f97873161dc1e90ea0e667d';

/// Quick filter suggestions provider (computed from state)
///
/// Copied from [quickFilterSuggestions].
@ProviderFor(quickFilterSuggestions)
final quickFilterSuggestionsProvider =
    AutoDisposeProvider<List<QuickFilterSuggestion>>.internal(
  quickFilterSuggestions,
  name: r'quickFilterSuggestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quickFilterSuggestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuickFilterSuggestionsRef
    = AutoDisposeProviderRef<List<QuickFilterSuggestion>>;
String _$jobFilterNotifierHash() => r'ef09a79cb147695c9bd550fd9c5eec098dcd9497';

/// Job filter notifier for managing filter state and presets
///
/// Copied from [JobFilterNotifier].
@ProviderFor(JobFilterNotifier)
final jobFilterNotifierProvider =
    AutoDisposeNotifierProvider<JobFilterNotifier, JobFilterState>.internal(
  JobFilterNotifier.new,
  name: r'jobFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobFilterNotifier = AutoDisposeNotifier<JobFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
