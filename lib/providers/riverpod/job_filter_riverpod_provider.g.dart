// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_filter_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SharedPreferences provider

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// SharedPreferences provider

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// SharedPreferences provider
  SharedPreferencesProvider._()
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
final jobFilterProvider = JobFilterNotifierProvider._();

/// Job filter notifier for managing filter state and presets
final class JobFilterNotifierProvider
    extends $NotifierProvider<JobFilterNotifier, JobFilterState> {
  /// Job filter notifier for managing filter state and presets
  JobFilterNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobFilterProvider',
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

String _$jobFilterNotifierHash() => r'eb14ec0919fa755a9591b5bc907f04497d08e099';

/// Job filter notifier for managing filter state and presets

abstract class _$JobFilterNotifier extends $Notifier<JobFilterState> {
  JobFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<JobFilterState, JobFilterState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JobFilterState, JobFilterState>,
        JobFilterState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Current filter provider (computed from state)

@ProviderFor(currentJobFilter)
final currentJobFilterProvider = CurrentJobFilterProvider._();

/// Current filter provider (computed from state)

final class CurrentJobFilterProvider extends $FunctionalProvider<
    JobFilterCriteria,
    JobFilterCriteria,
    JobFilterCriteria> with $Provider<JobFilterCriteria> {
  /// Current filter provider (computed from state)
  CurrentJobFilterProvider._()
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

String _$currentJobFilterHash() => r'f8738d257f89b7eec21e2586b5457c5b053c0a29';

/// Presets provider (computed from state)

@ProviderFor(filterPresets)
final filterPresetsProvider = FilterPresetsProvider._();

/// Presets provider (computed from state)

final class FilterPresetsProvider extends $FunctionalProvider<
    List<FilterPreset>,
    List<FilterPreset>,
    List<FilterPreset>> with $Provider<List<FilterPreset>> {
  /// Presets provider (computed from state)
  FilterPresetsProvider._()
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

String _$filterPresetsHash() => r'f18ad7b508207d059adb0d4c04a639bacadb1664';

/// Recent searches provider (computed from state)

@ProviderFor(recentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

/// Recent searches provider (computed from state)

final class RecentSearchesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Recent searches provider (computed from state)
  RecentSearchesProvider._()
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

String _$recentSearchesHash() => r'0f72621c7736b425b45f6e78ceadfa3fc2997a77';

/// Pinned presets provider (computed from state)

@ProviderFor(pinnedPresets)
final pinnedPresetsProvider = PinnedPresetsProvider._();

/// Pinned presets provider (computed from state)

final class PinnedPresetsProvider extends $FunctionalProvider<
    List<FilterPreset>,
    List<FilterPreset>,
    List<FilterPreset>> with $Provider<List<FilterPreset>> {
  /// Pinned presets provider (computed from state)
  PinnedPresetsProvider._()
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

String _$pinnedPresetsHash() => r'3705eb9bf7814819aa048d4ad2ccc36b3905a206';

/// Recent presets provider (computed from state)

@ProviderFor(recentPresets)
final recentPresetsProvider = RecentPresetsProvider._();

/// Recent presets provider (computed from state)

final class RecentPresetsProvider extends $FunctionalProvider<
    List<FilterPreset>,
    List<FilterPreset>,
    List<FilterPreset>> with $Provider<List<FilterPreset>> {
  /// Recent presets provider (computed from state)
  RecentPresetsProvider._()
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

String _$recentPresetsHash() => r'34c106d504e42873398edeef789a972a9c391f74';

/// Active filters status provider (computed from state)

@ProviderFor(hasActiveFilters)
final hasActiveFiltersProvider = HasActiveFiltersProvider._();

/// Active filters status provider (computed from state)

final class HasActiveFiltersProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Active filters status provider (computed from state)
  HasActiveFiltersProvider._()
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

String _$hasActiveFiltersHash() => r'c7f34079f57d66daeed486953e9c8f46abf84527';

/// Active filter count provider (computed from state)

@ProviderFor(activeFilterCount)
final activeFilterCountProvider = ActiveFilterCountProvider._();

/// Active filter count provider (computed from state)

final class ActiveFilterCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Active filter count provider (computed from state)
  ActiveFilterCountProvider._()
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

String _$activeFilterCountHash() => r'2a42a31577a4f9a8b463d950818ccb2d45157215';

/// Quick filter suggestions provider (computed from state)

@ProviderFor(quickFilterSuggestions)
final quickFilterSuggestionsProvider = QuickFilterSuggestionsProvider._();

/// Quick filter suggestions provider (computed from state)

final class QuickFilterSuggestionsProvider extends $FunctionalProvider<
    List<QuickFilterSuggestion>,
    List<QuickFilterSuggestion>,
    List<QuickFilterSuggestion>> with $Provider<List<QuickFilterSuggestion>> {
  /// Quick filter suggestions provider (computed from state)
  QuickFilterSuggestionsProvider._()
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
    r'94136780b8fb3b7bc726f004899ac3f54fa1b2b7';
