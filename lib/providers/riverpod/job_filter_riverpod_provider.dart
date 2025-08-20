import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/filter_criteria.dart';
import '../../models/filter_preset.dart';
import '../../utils/structured_logging.dart';

part 'job_filter_riverpod_provider.g.dart';

/// Job filter state model for Riverpod
class JobFilterState {

  const JobFilterState({
    this.currentFilter = const JobFilterCriteria(),
    this.presets = const <FilterPreset>[],
    this.recentSearches = const <String>[],
    this.isLoading = false,
    this.error,
  });
  final JobFilterCriteria currentFilter;
  final List<FilterPreset> presets;
  final List<String> recentSearches;
  final bool isLoading;
  final String? error;

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

  JobFilterState clearError() => copyWith();

  /// True when any filter settings are active.
  bool get hasActiveFilters => currentFilter.hasActiveFilters;

  /// The number of active filter options currently applied.
  int get activeFilterCount => currentFilter.activeFilterCount;

  /// Get pinned presets
  List<FilterPreset> get pinnedPresets =>
      presets.where((FilterPreset p) => p.isPinned).toList();

  /// Get recently used presets (sorted by last used)
  List<FilterPreset> get recentPresets {
    final List<FilterPreset> sorted = List<FilterPreset>.from(presets)
      ..sort((FilterPreset a, FilterPreset b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return sorted.take(5).toList();
  }
}

/// SharedPreferences provider
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async => SharedPreferences.getInstance();

/// Job filter notifier for managing filter state and presets
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

  /// Load filters and presets from storage
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

  /// Save current filter to storage
  Future<void> _saveFilter() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_filterKey, jsonEncode(state.currentFilter.toJson()));
    } catch (e) {
      StructuredLogger.debug('Error saving filter: $e');
    }
  }

  /// Save presets to storage
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

  /// Save recent searches to storage
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

  /// Update the current filter (debounced for smooth UX)
  void updateFilter(JobFilterCriteria newFilter) {
    state = state.copyWith(currentFilter: newFilter);
    _saveFilter(); // Save immediately for persistence
    _debounceNotification(ref.invalidateSelf);
  }

  /// Clear all filters (immediate notification for deliberate action)
  void clearAllFilters() {
    state = state.copyWith(currentFilter: JobFilterCriteria.empty());
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Clear a specific filter type (immediate notification for deliberate action)
  void clearFilterType(FilterType filterType) {
    final clearedFilter = state.currentFilter.clearFilter(filterType);
    state = state.copyWith(currentFilter: clearedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update location filter (debounced for smooth distance slider)
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

  /// Update classification filter (immediate for deliberate selection)
  void updateClassificationFilter(List<String> classifications) {
    final updatedFilter = state.currentFilter.copyWith(
      classifications: classifications,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update local numbers filter (immediate for deliberate selection)
  void updateLocalNumbersFilter(List<int> localNumbers) {
    final updatedFilter = state.currentFilter.copyWith(
      localNumbers: localNumbers,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update construction types filter (immediate for deliberate selection)
  void updateConstructionTypesFilter(List<String> constructionTypes) {
    final updatedFilter = state.currentFilter.copyWith(
      constructionTypes: constructionTypes,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update date filters (debounced for smooth date picker interaction)
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

  /// Update per diem filter (immediate for toggle action)
  void updatePerDiemFilter(bool? hasPerDiem) {
    final updatedFilter = state.currentFilter.copyWith(
      hasPerDiem: hasPerDiem,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update duration preference (immediate for dropdown selection)
  void updateDurationPreference(String? preference) {
    final updatedFilter = state.currentFilter.copyWith(
      durationPreference: preference,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update company filter (immediate for deliberate selection)
  void updateCompanyFilter(List<String> companies) {
    final updatedFilter = state.currentFilter.copyWith(
      companies: companies,
    );
    state = state.copyWith(currentFilter: updatedFilter);
    _saveFilter();
    ref.invalidateSelf();
  }

  /// Update sort options (debounced for rapid sort changes)
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

  /// Update search query (debounced for smooth typing experience)
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

  /// Clear recent searches (immediate for deliberate action)
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: <String>[]);
    _saveRecentSearches();
    ref.invalidateSelf();
  }

  /// Save current filter as preset (immediate for deliberate action)
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

  /// Apply a preset (immediate for deliberate action)
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

  /// Update a preset (immediate for deliberate action)
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

  /// Delete a preset (immediate for deliberate action)
  Future<void> deletePreset(String presetId) async {
    final updatedPresets = state.presets.where((FilterPreset p) => p.id != presetId).toList();
    state = state.copyWith(presets: updatedPresets);
    await _savePresets(updatedPresets);
    ref.invalidateSelf();
  }

  /// Toggle preset pinned status (immediate for deliberate action)
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

  /// Reset to default presets (immediate for deliberate action)
  Future<void> resetToDefaultPresets() async {
    final List<FilterPreset> defaultPresets = DefaultFilterPresets.defaults;
    state = state.copyWith(presets: defaultPresets);
    await _savePresets(defaultPresets);
    ref.invalidateSelf();
  }

  /// Get quick filter suggestions based on user data
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

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Cleanup resources when provider is disposed
  void dispose() {
    _debounceTimer?.cancel();
  }
}

/// Quick filter suggestion model
class QuickFilterSuggestion {
  /// Creates a quick filter suggestion used to present common filter actions to the user.
  ///
  /// The [label] is the visible text, [icon] represents the action visually, and
  /// [onTap] is called when the suggestion is activated.
  const QuickFilterSuggestion({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  /// The visible label for the suggestion (e.g., "Near Me", "Recent").
  final String label;

  /// Icon shown alongside the suggestion label.
  final IconData icon;

  /// Callback invoked when the suggestion is selected/tapped.
  final VoidCallback onTap;
}

/// Current filter provider (computed from state)
@riverpod
JobFilterCriteria currentJobFilter(Ref ref) => ref.watch(jobFilterNotifierProvider).currentFilter;

/// Presets provider (computed from state)
@riverpod
List<FilterPreset> filterPresets(Ref ref) => ref.watch(jobFilterNotifierProvider).presets;

/// Recent searches provider (computed from state)
@riverpod
List<String> recentSearches(Ref ref) => ref.watch(jobFilterNotifierProvider).recentSearches;

/// Pinned presets provider (computed from state)
@riverpod
List<FilterPreset> pinnedPresets(Ref ref) => ref.watch(jobFilterNotifierProvider).pinnedPresets;

/// Recent presets provider (computed from state)
@riverpod
List<FilterPreset> recentPresets(Ref ref) => ref.watch(jobFilterNotifierProvider).recentPresets;

/// Active filters status provider (computed from state)
@riverpod
bool hasActiveFilters(Ref ref) => ref.watch(jobFilterNotifierProvider).hasActiveFilters;

/// Active filter count provider (computed from state)
@riverpod
int activeFilterCount(Ref ref) => ref.watch(jobFilterNotifierProvider).activeFilterCount;

/// Quick filter suggestions provider (computed from state)
@riverpod
List<QuickFilterSuggestion> quickFilterSuggestions(Ref ref) {
  final notifier = ref.watch(jobFilterNotifierProvider.notifier);
  return notifier.getQuickFilterSuggestions();
}