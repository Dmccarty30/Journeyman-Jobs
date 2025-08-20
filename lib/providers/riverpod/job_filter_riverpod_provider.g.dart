// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_filter_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0';

/// SharedPreferences provider
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = FutureProviderRef<SharedPreferences>;
String _$currentJobFilterHash() => r'b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1';

/// Current filter provider (computed from state)
///
/// Copied from [currentJobFilter].
@ProviderFor(currentJobFilter)
final currentJobFilterProvider = AutoDisposeProvider<JobFilterCriteria>.internal(
  currentJobFilter,
  name: r'currentJobFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentJobFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentJobFilterRef = AutoDisposeProviderRef<JobFilterCriteria>;
String _$filterPresetsHash() => r'c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2';

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

typedef FilterPresetsRef = AutoDisposeProviderRef<List<FilterPreset>>;
String _$recentSearchesHash() => r'd4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3';

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

typedef RecentSearchesRef = AutoDisposeProviderRef<List<String>>;
String _$pinnedPresetsHash() => r'e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4';

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

typedef PinnedPresetsRef = AutoDisposeProviderRef<List<FilterPreset>>;
String _$recentPresetsHash() => r'f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5';

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

typedef RecentPresetsRef = AutoDisposeProviderRef<List<FilterPreset>>;
String _$hasActiveFiltersHash() => r'g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6';

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

typedef HasActiveFiltersRef = AutoDisposeProviderRef<bool>;
String _$activeFilterCountHash() => r'h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7';

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

typedef ActiveFilterCountRef = AutoDisposeProviderRef<int>;
String _$quickFilterSuggestionsHash() =>
    r'i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8';

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

typedef QuickFilterSuggestionsRef
    = AutoDisposeProviderRef<List<QuickFilterSuggestion>>;
String _$jobFilterNotifierHash() => r'j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9';

/// Job filter notifier for managing filter state and presets
///
/// Copied from [JobFilterNotifier].
@ProviderFor(JobFilterNotifier)
final jobFilterNotifierProvider =
    NotifierProvider<JobFilterNotifier, JobFilterState>.internal(
  JobFilterNotifier.new,
  name: r'jobFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobFilterNotifier = JobFilterNotifier;