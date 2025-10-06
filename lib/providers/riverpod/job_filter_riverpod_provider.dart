import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/filter_criteria.dart';
import '../../models/filter_preset.dart';
import '../../utils/structured_logging.dart';

part 'job_filter_riverpod_provider.g.dart';

/// Represents the state for the job filtering feature.
///
/// This immutable class holds the currently applied filters, saved user presets,
/// recent search history, and the UI loading/error state.
class JobFilterState {

  /// Creates an instance of the job filter state.
  const JobFilterState({
    this.currentFilter = const JobFilterCriteria(),
    this.presets = const <FilterPreset>[],
    this.recentSearches = const <String>[],
    this.isLoading = false,
    this.error,
  });
  /// The currently active filter criteria.
  final JobFilterCriteria currentFilter;
  /// A list of all saved filter presets for the user.
  final List<FilterPreset> presets;
  /// A list of the user's most recent search queries.
  final List<String> recentSearches;
  /// `true` if the filter state is currently being loaded from storage.
  final bool isLoading;
  /// A string description of the last error that occurred.
  final String? error;

  /// Creates a new [JobFilterState] instance with updated field values.
  JobFilterState copyWith({
    JobFilterCriteria? currentFilter,
    List<FilterPreset>? presets,
    List<String>? recentSearches,
    bool? isLoading,
    String? error,
  }) => JobFilterState(
      currentFilter: currentFilter ?? this.currentFilter,
      presets: presets ?? this.presets,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );

  /// Returns a new [JobFilterState] instance with the `error` field cleared.
  JobFilterState clearError() => copyWith(error: null);

  /// A convenience getter that returns `true` if any filter criteria are currently active.
  bool get hasActiveFilters => currentFilter.hasActiveFilters;

  /// A convenience getter that returns the count of active filter criteria.
  int get activeFilterCount => currentFilter.activeFilterCount;

  /// Returns a list of all presets that have been marked as pinned by the user.
  List<FilterPreset> get pinnedPresets =>
      presets.where((FilterPreset p) => p.isPinned).toList();

  /// Returns a list of the most recently used presets, sorted by `lastUsedAt`.
  List<FilterPreset> get recentPresets {
    final List<FilterPreset> sorted = List<FilterPreset>.from(presets)
      ..sort((FilterPreset a, FilterPreset b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return sorted.take(5).toList();
  }
}

/// Provides a singleton instance of [SharedPreferences].
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async => SharedPreferences.getInstance();

/// The state notifier for managing the [JobFilterState].
///
/// This class handles all logic related to updating filters, managing presets,
/// and persisting the state to local storage. It uses debouncing to prevent
/// excessive updates during user input.
@riverpod
class JobFilterNotifier extends _$JobFilterNotifier {
  static const String _filterKey = 'current_job_filter';
  static const String _presetsKey = 'filter_presets';
  static const String _recentSearchesKey = 'recent_searches';
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  
  Timer? _debounceTimer;

  @override
  JobFilterState build() {
    _loadFromStorage();
    return const JobFilterState();
  }

  /// Loads the filter state from [SharedPreferences] upon initialization.
  Future<void> _loadFromStorage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      
      // Load current filter
      final String? filterJson = prefs.getString(_filterKey);
      JobFilterCriteria currentFilter = JobFilterCriteria.empty();
      if (filterJson != null) {
        final dynamic decoded = jsonDecode(filterJson);
        currentFilter = JobFilterCriteria.fromJson(
          Map<String, dynamic>.from(decoded as Map<String, dynamic>),
        );
      }
      
      // Load presets
      List<FilterPreset> loadedPresets = <FilterPreset>[];
      final String? presetsJson = prefs.getString(_presetsKey);
      if (presetsJson != null) {
        final dynamic decodedPresets = jsonDecode(presetsJson);
        final List<dynamic> presetsList = decodedPresets as List<dynamic>;
        loadedPresets = presetsList
            .map((e) => FilterPreset.fromJson(
                Map<String, dynamic>.from(e as Map<String, dynamic>),
              ),)
            .toList();
      } else {
        // Load default presets on first run
        loadedPresets = DefaultFilterPresets.defaults;
        await _savePresets(loadedPresets);
      }
      
      // Load recent searches
      final List<String> loadedSearches = 
          prefs.getStringList(_recentSearchesKey) ?? <String>[];

      state = state.copyWith(
        currentFilter: currentFilter,
        presets: loadedPresets,
        recentSearches: loadedSearches,
        isLoading: false,
      );
    } catch (e) {
      StructuredLogger.debug('Error loading filters: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Persists the current [JobFilterCriteria] to local storage.
  Future<void> _saveFilter() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_filterKey, jsonEncode(state.currentFilter.toJson()));
    } catch (e) {
      StructuredLogger.debug('Error saving filter: $e');
    }
  }

  /// Persists the list of [FilterPreset]s to local storage.
  Future<void> _savePresets(List<FilterPreset> presets) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final List<Map<String, dynamic>> presetsJson = presets
          .map((FilterPreset p) => p.toJson())
          .toList();
      await prefs.setString(_presetsKey, jsonEncode(presetsJson));
    } catch (e) {
      StructuredLogger.debug('Error saving presets: $e');
    }
  }

  /// Persists the list of recent searches to local storage.
  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setStringList(_recentSearchesKey, state.recentSearches);
    } catch (e) {
      StructuredLogger.debug('Error saving recent searches: $e');
    }
  }

  /// Debounce notifications to prevent rapid-fire query triggers
  void _debounceNotification(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, callback);
  }

  /// Updates the current filter criteria and notifies listeners after a debounce period.
  void updateFilter(JobFilterCriteria newFilter) {
    state = state.copyWith(currentFilter: newFilter);
    _saveFilter(); // Save immediately for persistence
    _debounceNotification(ref.invalidateSelf);
  }

  /// Clears all active filters and immediately notifies listeners.
  void clearAllFilters() {
    state = state.copyWith(currentFilter: JobFilterCriteria.empty());
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Clears a specific category of filters and immediately notifies listeners.
  void clearFilterType(FilterType filterType) {
    final clearedFilter = state.currentFilter.clearFilter(filterType);
    state = state.copyWith(currentFilter: clearedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the location-related filters with debouncing.
  void updateLocationFilter({
    String? city,
    String? state,
    double? maxDistance,
  }) {
    final updatedFilter = this.state.currentFilter.copyWith(
      city: city,
      state: state,
      maxDistance: maxDistance,
    );
    this.state = this.state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    _debounceNotification(ref.invalidateSelf);
  }

  /// Updates the classification filter and notifies listeners immediately.
  void updateClassificationFilter(List<String> classifications) {
    final updatedFilter = state.currentFilter.copyWith(
      classifications: classifications,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the IBEW local numbers filter and notifies listeners immediately.
  void updateLocalNumbersFilter(List<int> localNumbers) {
    final updatedFilter = state.currentFilter.copyWith(
      localNumbers: localNumbers,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the construction types filter and notifies listeners immediately.
  void updateConstructionTypesFilter(List<String> constructionTypes) {
    final updatedFilter = state.currentFilter.copyWith(
      constructionTypes: constructionTypes,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the date-related filters with debouncing.
  void updateDateFilters({
    DateTime? postedAfter,
    DateTime? startDateBefore,
    DateTime? startDateAfter,
  }) {
    final updatedFilter = state.currentFilter.copyWith(
      postedAfter: postedAfter,
      startDateBefore: startDateBefore,
      startDateAfter: startDateAfter,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    _debounceNotification(ref.invalidateSelf);
  }

  /// Updates the per diem filter and notifies listeners immediately.
  void updatePerDiemFilter(bool? hasPerDiem) {
    final updatedFilter = state.currentFilter.copyWith(
      hasPerDiem: hasPerDiem,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the job duration preference and notifies listeners immediately.
  void updateDurationPreference(String? preference) {
    final updatedFilter = state.currentFilter.copyWith(
      durationPreference: preference,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the company filter and notifies listeners immediately.
  void updateCompanyFilter(List<String> companies) {
    final updatedFilter = state.currentFilter.copyWith(
      companies: companies,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Updates the sorting options with debouncing.
  void updateSortOptions({
    JobSortOption? sortBy,
    bool? sortDescending,
  }) {
    final updatedFilter = state.currentFilter.copyWith(
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    _debounceNotification(ref.invalidateSelf);
  }

  /// Updates the text search query with debouncing.
  ///
  /// Also adds the query to the recent searches list after the debounce period.
  void updateSearchQuery(String? query) {
    final updatedFilter = state.currentFilter.copyWith(
      searchQuery: query,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    
    // Add to recent searches if not empty (but only on final submission)
    if (query != null && query.isNotEmpty) {
      // Only add to recent searches after debounce period to avoid spam
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () {
        _addRecentSearch(query);
        ref.invalidateSelf();
      });
    } else {
      // For empty queries, notify immediately
      ref.invalidateSelf();
    }
  }

  /// Add a recent search
  void _addRecentSearch(String search) {
    final List<String> updatedSearches = List<String>.from(state.recentSearches);
    
    // Remove if already exists
    updatedSearches.remove(search);
    
    // Add to beginning
    updatedSearches.insert(0, search);
    
    // Keep only last 10
    if (updatedSearches.length > 10) {
      updatedSearches.removeRange(10, updatedSearches.length);
    }
    
    state = state.copyWith(recentSearches: updatedSearches);
    _saveRecentSearches();
  }

  /// Clears the list of recent searches and notifies listeners immediately.
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: <String>[]);
    _saveRecentSearches();
    ref.invalidateSelf();
  }

  /// Saves the current filter criteria as a new [FilterPreset].
  Future<void> saveAsPreset(String name, {String? description, IconData? icon}) async {
    final FilterPreset preset = FilterPreset.create(
      name: name,
      description: description,
      criteria: state.currentFilter,
      icon: icon,
    );
    
    final List<FilterPreset> updatedPresets = List<FilterPreset>.from(state.presets)..add(preset);
    state = state.copyWith(presets: updatedPresets);
    await _savePresets(updatedPresets);
    ref.invalidateSelf();
  }

  /// Applies a saved [FilterPreset] to the current filter state.
  ///
  /// Also updates the preset's usage metadata.
  void applyPreset(String presetId) {
    final preset = state.presets.firstWhere(
      (FilterPreset p) => p.id == presetId,
      orElse: () => throw Exception('Preset not found'),
    );
    
    // Update preset usage
    final List<FilterPreset> updatedPresets = List<FilterPreset>.from(state.presets);
    final int index = updatedPresets.indexWhere((FilterPreset p) => p.id == presetId);
    updatedPresets[index] = preset.markAsUsed();
    
    // Apply the filter
    state = state.copyWith(
      currentFilter: preset.criteria,
      presets: updatedPresets,
    );
    
    _saveFilter();
    _savePresets(updatedPresets);
    ref.invalidateSelf();
  }

  /// Updates an existing [FilterPreset] with new values.
  Future<void> updatePreset(
    String presetId, {
    String? name,
    String? description,
    JobFilterCriteria? criteria,
    IconData? icon,
  }) async {
    final List<FilterPreset> updatedPresets = List<FilterPreset>.from(state.presets);
    final int index = updatedPresets.indexWhere((FilterPreset p) => p.id == presetId);
    if (index == -1) {
      throw Exception('Preset not found');
    }
    
    updatedPresets[index] = updatedPresets[index].copyWith(
      name: name,
      description: description,
      criteria: criteria,
      icon: icon,
    );
    
    state = state.copyWith(presets: updatedPresets);
    await _savePresets(updatedPresets);
    ref.invalidateSelf();
  }

  /// Deletes a saved [FilterPreset] from the user's list.
  Future<void> deletePreset(String presetId) async {
    final updatedPresets = state.presets.where((FilterPreset p) => p.id != presetId).toList();
    state = state.copyWith(presets: updatedPresets);
    await _savePresets(updatedPresets);
    ref.invalidateSelf();
  }

  /// Toggles the `isPinned` status of a [FilterPreset].
  Future<void> togglePresetPinned(String presetId) async {
    final List<FilterPreset> updatedPresets = List<FilterPreset>.from(state.presets);
    final int index = updatedPresets.indexWhere((FilterPreset p) => p.id == presetId);
    if (index == -1) {
      throw Exception('Preset not found');
    }
    
    updatedPresets[index] = updatedPresets[index].togglePinned();
    state = state.copyWith(presets: updatedPresets);
    await _savePresets(updatedPresets);
    ref.invalidateSelf();
  }

  /// Resets the user's presets to the default list.
  Future<void> resetToDefaultPresets() async {
    final List<FilterPreset> defaultPresets = DefaultFilterPresets.defaults;
    state = state.copyWith(presets: defaultPresets);
    await _savePresets(defaultPresets);
    ref.invalidateSelf();
  }

  /// Generates a list of context-aware quick filter suggestions for the UI.
  List<QuickFilterSuggestion> getQuickFilterSuggestions() {
    final List<QuickFilterSuggestion> suggestions = <QuickFilterSuggestion>[];
    
    // Suggest clearing all if filters are active
    if (state.hasActiveFilters) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'Clear All',
          icon: Icons.clear,
          onTap: clearAllFilters,
        ),
      );
    }

    // Suggest local jobs if no distance filter
    if (state.currentFilter.maxDistance == null) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'Near Me',
          icon: Icons.location_on,
          onTap: () => updateLocationFilter(maxDistance: 25),
        ),
      );
    }
    
    // Suggest recent posts if no date filter
    if (state.currentFilter.postedAfter == null) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'Recent',
          icon: Icons.new_releases,
          onTap: () => updateDateFilters(
            postedAfter: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ),
      );
    }
    
    // Suggest per diem if not filtered
    if (state.currentFilter.hasPerDiem == null) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'Per Diem',
          icon: Icons.hotel,
          onTap: () => updatePerDiemFilter(true),
        ),
      );
    }
    
    return suggestions;
  }

  /// Clears any error message from the state.
  void clearError() {
    state = state.clearError();
  }

  /// Cleans up resources, such as the debounce timer, when the provider is disposed.
  void dispose() {
    _debounceTimer?.cancel();
  }
}

/// A model for a UI suggestion that applies a common filter action.
class QuickFilterSuggestion {
  /// Creates an instance of [QuickFilterSuggestion].
  ///
  /// The [label] is the visible text, [icon] represents the action visually, and
  /// [onTap] is the callback executed when the suggestion is tapped.
  const QuickFilterSuggestion({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  /// The text label for the suggestion (e.g., "Near Me").
  final String label;

  /// The icon to display next to the suggestion label.
  final IconData icon;

  /// The function to call when the suggestion is tapped.
  final VoidCallback onTap;
}

/// A provider that exposes the current [JobFilterCriteria] from the main notifier.
@riverpod
JobFilterCriteria currentJobFilter(Ref ref) => ref.watch(jobFilterProvider).currentFilter;

/// A provider that exposes the list of all saved [FilterPreset]s.
@riverpod
List<FilterPreset> filterPresets(Ref ref) => ref.watch(jobFilterProvider).presets;

/// A provider that exposes the list of recent search queries.
@riverpod
List<String> recentSearches(Ref ref) => ref.watch(jobFilterProvider).recentSearches;

/// A provider that exposes a filtered list of only the pinned presets.
@riverpod
List<FilterPreset> pinnedPresets(Ref ref) => ref.watch(jobFilterProvider).pinnedPresets;

/// A provider that exposes a sorted list of the most recently used presets.
@riverpod
List<FilterPreset> recentPresets(Ref ref) => ref.watch(jobFilterProvider).recentPresets;

/// A provider that exposes a boolean indicating if any filters are currently active.
@riverpod
bool hasActiveFilters(Ref ref) => ref.watch(jobFilterProvider).hasActiveFilters;

/// A provider that exposes the integer count of currently active filters.
@riverpod
int activeFilterCount(Ref ref) => ref.watch(jobFilterProvider).activeFilterCount;

/// A provider that generates and exposes a list of [QuickFilterSuggestion]s.
@riverpod
List<QuickFilterSuggestion> quickFilterSuggestions(Ref ref) {
  final notifier = ref.watch(jobFilterProvider.notifier);
  return notifier.getQuickFilterSuggestions();
}