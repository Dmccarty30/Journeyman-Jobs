// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_filter_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// SharedPreferences provider
@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

/// SharedPreferences provider
final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// SharedPreferences provider
  const SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'9b38b0605ab233f33b0ff939edd1100331a746fa';

/// Job filter notifier for managing filter state and presets
@ProviderFor(JobFilterNotifier)
const jobFilterNotifierProvider = JobFilterNotifierProvider._();

/// Job filter notifier for managing filter state and presets
final class JobFilterNotifierProvider
    extends $NotifierProvider<JobFilterNotifier, JobFilterState> {
  /// Job filter notifier for managing filter state and presets
  const JobFilterNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobFilterNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobFilterNotifierHash();

  @$internal
  @override
  JobFilterNotifier create() => JobFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobFilterState>(value),
    );
  }
}

String _$jobFilterNotifierHash() => r'c1b74e0d18d13d03de0dc14dd1b8f4fe4bfd586e';

abstract class _$JobFilterNotifier extends $Notifier<JobFilterState> {
  JobFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<JobFilterState, JobFilterState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JobFilterState, JobFilterState>,
        JobFilterState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Current filter provider (computed from state)
@ProviderFor(currentJobFilter)
const currentJobFilterProvider = CurrentJobFilterProvider._();

/// Current filter provider (computed from state)
final class CurrentJobFilterProvider extends $FunctionalProvider<
    JobFilterCriteria,
    JobFilterCriteria,
    JobFilterCriteria> with $Provider<JobFilterCriteria> {
  /// Current filter provider (computed from state)
  const CurrentJobFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentJobFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentJobFilterHash();

  @$internal
  @override
  $ProviderElement<JobFilterCriteria> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JobFilterCriteria create(Ref ref) {
    return currentJobFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobFilterCriteria value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobFilterCriteria>(value),
    );
  }
}

String _$currentJobFilterHash() => r'6151857777140c174666609911d4133be719f935';

/// Presets provider (computed from state)
@ProviderFor(filterPresets)
const filterPresetsProvider = FilterPresetsProvider._();

/// Presets provider (computed from state)
final class FilterPresetsProvider extends $FunctionalProvider<
    List<FilterPreset>,
    List<FilterPreset>,
    List<FilterPreset>> with $Provider<List<FilterPreset>> {
  /// Presets provider (computed from state)
  const FilterPresetsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filterPresetsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filterPresetsHash();

  @$internal
  @override
  $ProviderElement<List<FilterPreset>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<FilterPreset> create(Ref ref) {
    return filterPresets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FilterPreset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FilterPreset>>(value),
    );
  }
}

String _$filterPresetsHash() => r'727fc8eadd737bfa99cf80644c33313e991a5e9e';

/// Recent searches provider (computed from state)
@ProviderFor(recentSearches)
const recentSearchesProvider = RecentSearchesProvider._();

/// Recent searches provider (computed from state)
final class RecentSearchesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Recent searches provider (computed from state)
  const RecentSearchesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentSearchesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return recentSearches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$recentSearchesHash() => r'194a7220f55d3300a47dabdc094cca30d03778cf';

/// Pinned presets provider (computed from state)
@ProviderFor(pinnedPresets)
const pinnedPresetsProvider = PinnedPresetsProvider._();

/// Pinned presets provider (computed from state)
final class PinnedPresetsProvider extends $FunctionalProvider<
    List<FilterPreset>,
    List<FilterPreset>,
    List<FilterPreset>> with $Provider<List<FilterPreset>> {
  /// Pinned presets provider (computed from state)
  const PinnedPresetsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pinnedPresetsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pinnedPresetsHash();

  @$internal
  @override
  $ProviderElement<List<FilterPreset>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<FilterPreset> create(Ref ref) {
    return pinnedPresets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FilterPreset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FilterPreset>>(value),
    );
  }
}

String _$pinnedPresetsHash() => r'7edb3d5e1eaede9e03039b47213f28b6eb812343';

/// Recent presets provider (computed from state)
@ProviderFor(recentPresets)
const recentPresetsProvider = RecentPresetsProvider._();

/// Recent presets provider (computed from state)
final class RecentPresetsProvider extends $FunctionalProvider<
    List<FilterPreset>,
    List<FilterPreset>,
    List<FilterPreset>> with $Provider<List<FilterPreset>> {
  /// Recent presets provider (computed from state)
  const RecentPresetsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentPresetsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentPresetsHash();

  @$internal
  @override
  $ProviderElement<List<FilterPreset>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<FilterPreset> create(Ref ref) {
    return recentPresets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FilterPreset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FilterPreset>>(value),
    );
  }
}

String _$recentPresetsHash() => r'2197a594957457241d9f16fc851fb91baf2d357c';

/// Active filters status provider (computed from state)
@ProviderFor(hasActiveFilters)
const hasActiveFiltersProvider = HasActiveFiltersProvider._();

/// Active filters status provider (computed from state)
final class HasActiveFiltersProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Active filters status provider (computed from state)
  const HasActiveFiltersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasActiveFiltersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasActiveFiltersHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasActiveFilters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasActiveFiltersHash() => r'99f5d159294391ecbd1e57df0f38103d03823481';

/// Active filter count provider (computed from state)
@ProviderFor(activeFilterCount)
const activeFilterCountProvider = ActiveFilterCountProvider._();

/// Active filter count provider (computed from state)
final class ActiveFilterCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Active filter count provider (computed from state)
  const ActiveFilterCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeFilterCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeFilterCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeFilterCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeFilterCountHash() => r'be49f96340339f217402909d3c358f991c2585ec';

/// Quick filter suggestions provider (computed from state)
@ProviderFor(quickFilterSuggestions)
const quickFilterSuggestionsProvider = QuickFilterSuggestionsProvider._();

/// Quick filter suggestions provider (computed from state)
final class QuickFilterSuggestionsProvider extends $FunctionalProvider<
    List<QuickFilterSuggestion>,
    List<QuickFilterSuggestion>,
    List<QuickFilterSuggestion>> with $Provider<List<QuickFilterSuggestion>> {
  /// Quick filter suggestions provider (computed from state)
  const QuickFilterSuggestionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'quickFilterSuggestionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$quickFilterSuggestionsHash();

  @$internal
  @override
  $ProviderElement<List<QuickFilterSuggestion>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<QuickFilterSuggestion> create(Ref ref) {
    return quickFilterSuggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<QuickFilterSuggestion> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<QuickFilterSuggestion>>(value),
    );
  }
}

String _$quickFilterSuggestionsHash() =>
    r'9e8b447cdbc2bd2da68e05d424ba9c2b530771e8';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
