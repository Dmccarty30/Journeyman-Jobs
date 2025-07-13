import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/filter_criteria.dart';
import '../models/filter_preset.dart';

/// Provider for managing job filters and presets with persistence and debouncing
class JobFilterProvider extends ChangeNotifier {
  static const String _filterKey = 'current_job_filter';
  static const String _presetsKey = 'filter_presets';
  static const String _recentSearchesKey = 'recent_searches';
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  
  JobFilterCriteria _currentFilter = JobFilterCriteria.empty();
  List<FilterPreset> _presets = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  JobFilterCriteria get currentFilter => _currentFilter;
  List<FilterPreset> get presets => _presets;
  List<String> get recentSearches => _recentSearches;
  bool get isLoading => _isLoading;
  bool get hasActiveFilters => _currentFilter.hasActiveFilters;
  int get activeFilterCount => _currentFilter.activeFilterCount;

  /// Get pinned presets
  List<FilterPreset> get pinnedPresets =>
      _presets.where((p) => p.isPinned).toList();

  /// Get recently used presets (sorted by last used)
  List<FilterPreset> get recentPresets {
    final sorted = List<FilterPreset>.from(_presets)
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return sorted.take(5).toList();
  }

  JobFilterProvider() {
    _loadFromStorage();
  }

  /// Load filters and presets from storage
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    _notifyImmediately(); // Immediate for loading state

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load current filter
      final filterJson = prefs.getString(_filterKey);
      if (filterJson != null) {
        _currentFilter = JobFilterCriteria.fromJson(jsonDecode(filterJson));
      }
      
      // Load presets
      final presetsJson = prefs.getString(_presetsKey);
      if (presetsJson != null) {
        final List<dynamic> presetsList = jsonDecode(presetsJson);
        _presets = presetsList.map((json) => FilterPreset.fromJson(json)).toList();
      } else {
        // Load default presets on first run
        _presets = DefaultFilterPresets.defaults;
        await _savePresets();
      }
      
      // Load recent searches
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      debugPrint('Error loading filters: $e');
    } finally {
      _isLoading = false;
      _notifyImmediately(); // Immediate for loading completion
    }
  }

  /// Save current filter to storage
  Future<void> _saveFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_filterKey, jsonEncode(_currentFilter.toJson()));
    } catch (e) {
      debugPrint('Error saving filter: $e');
    }
  }

  /// Save presets to storage
  Future<void> _savePresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = _presets.map((p) => p.toJson()).toList();
      await prefs.setString(_presetsKey, jsonEncode(presetsJson));
    } catch (e) {
      debugPrint('Error saving presets: $e');
    }
  }

  /// Save recent searches to storage
  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  /// Debounce notifications to prevent rapid-fire query triggers
  void _debounceNotification() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      notifyListeners();
    });
  }

  /// Immediate notification (bypasses debouncing for critical updates)
  void _notifyImmediately() {
    _debounceTimer?.cancel();
    notifyListeners();
  }

  /// Update the current filter (debounced for smooth UX)
  void updateFilter(JobFilterCriteria newFilter) {
    _currentFilter = newFilter;
    _saveFilter(); // Save immediately for persistence
    _debounceNotification(); // Debounce UI updates
  }

  /// Clear all filters (immediate notification for deliberate action)
  void clearAllFilters() {
    _currentFilter = JobFilterCriteria.empty();
    _saveFilter();
    _notifyImmediately();
  }

  /// Clear a specific filter type (immediate notification for deliberate action)
  void clearFilterType(FilterType filterType) {
    _currentFilter = _currentFilter.clearFilter(filterType);
    _saveFilter();
    _notifyImmediately();
  }

  /// Update location filter (debounced for smooth distance slider)
  void updateLocationFilter({
    String? city,
    String? state,
    double? maxDistance,
  }) {
    _currentFilter = _currentFilter.copyWith(
      city: city,
      state: state,
      maxDistance: maxDistance,
    );
    _saveFilter();
    _debounceNotification(); // Debounce for smooth slider interaction
  }

  /// Update classification filter (immediate for deliberate selection)
  void updateClassificationFilter(List<String> classifications) {
    _currentFilter = _currentFilter.copyWith(
      classifications: classifications,
    );
    _saveFilter();
    _notifyImmediately(); // Immediate for checkbox selections
  }

  /// Update local numbers filter (immediate for deliberate selection)
  void updateLocalNumbersFilter(List<int> localNumbers) {
    _currentFilter = _currentFilter.copyWith(
      localNumbers: localNumbers,
    );
    _saveFilter();
    _notifyImmediately(); // Immediate for multi-select
  }

  /// Update construction types filter (immediate for deliberate selection)
  void updateConstructionTypesFilter(List<String> constructionTypes) {
    _currentFilter = _currentFilter.copyWith(
      constructionTypes: constructionTypes,
    );
    _saveFilter();
    _notifyImmediately(); // Immediate for checkbox selections
  }

  /// Update date filters (debounced for smooth date picker interaction)
  void updateDateFilters({
    DateTime? postedAfter,
    DateTime? startDateBefore,
    DateTime? startDateAfter,
  }) {
    _currentFilter = _currentFilter.copyWith(
      postedAfter: postedAfter,
      startDateBefore: startDateBefore,
      startDateAfter: startDateAfter,
    );
    _saveFilter();
    _debounceNotification(); // Debounce for date picker interactions
  }

  /// Update per diem filter (immediate for toggle action)
  void updatePerDiemFilter(bool? hasPerDiem) {
    _currentFilter = _currentFilter.copyWith(
      hasPerDiem: hasPerDiem,
    );
    _saveFilter();
    _notifyImmediately(); // Immediate for toggle switches
  }

  /// Update duration preference (immediate for dropdown selection)
  void updateDurationPreference(String? preference) {
    _currentFilter = _currentFilter.copyWith(
      durationPreference: preference,
    );
    _saveFilter();
    _notifyImmediately(); // Immediate for dropdown selections
  }

  /// Update company filter (immediate for deliberate selection)
  void updateCompanyFilter(List<String> companies) {
    _currentFilter = _currentFilter.copyWith(
      companies: companies,
    );
    _saveFilter();
    _notifyImmediately(); // Immediate for multi-select
  }

  /// Update sort options (debounced for rapid sort changes)
  void updateSortOptions({
    JobSortOption? sortBy,
    bool? sortDescending,
  }) {
    _currentFilter = _currentFilter.copyWith(
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
    _saveFilter();
    _debounceNotification(); // Debounce for rapid sort changes
  }

  /// Update search query (debounced for smooth typing experience)
  void updateSearchQuery(String? query) {
    _currentFilter = _currentFilter.copyWith(
      searchQuery: query,
    );
    _saveFilter();
    
    // Add to recent searches if not empty (but only on final submission)
    if (query != null && query.isNotEmpty) {
      // Only add to recent searches after debounce period to avoid spam
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () {
        _addRecentSearch(query);
        notifyListeners();
      });
    } else {
      // For empty queries, notify immediately
      _notifyImmediately();
    }
  }

  /// Add a recent search
  void _addRecentSearch(String search) {
    // Remove if already exists
    _recentSearches.remove(search);
    
    // Add to beginning
    _recentSearches.insert(0, search);
    
    // Keep only last 10
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }
    
    _saveRecentSearches();
  }

  /// Clear recent searches (immediate for deliberate action)
  void clearRecentSearches() {
    _recentSearches.clear();
    _saveRecentSearches();
    _notifyImmediately(); // Immediate for clear action
  }

  /// Save current filter as preset (immediate for deliberate action)
  Future<void> saveAsPreset(String name, {String? description, IconData? icon}) async {
    final preset = FilterPreset.create(
      name: name,
      description: description,
      criteria: _currentFilter,
      icon: icon,
    );
    
    _presets.add(preset);
    await _savePresets();
    _notifyImmediately(); // Immediate for preset creation
  }

  /// Apply a preset (immediate for deliberate action)
  void applyPreset(String presetId) {
    final preset = _presets.firstWhere(
      (p) => p.id == presetId,
      orElse: () => throw Exception('Preset not found'),
    );
    
    // Update preset usage
    final index = _presets.indexOf(preset);
    _presets[index] = preset.markAsUsed();
    
    // Apply the filter
    _currentFilter = preset.criteria;
    
    _saveFilter();
    _savePresets();
    _notifyImmediately(); // Immediate for preset application
  }

  /// Update a preset (immediate for deliberate action)
  Future<void> updatePreset(
    String presetId, {
    String? name,
    String? description,
    JobFilterCriteria? criteria,
    IconData? icon,
  }) async {
    final index = _presets.indexWhere((p) => p.id == presetId);
    if (index == -1) throw Exception('Preset not found');
    
    _presets[index] = _presets[index].copyWith(
      name: name,
      description: description,
      criteria: criteria,
      icon: icon,
    );
    
    await _savePresets();
    _notifyImmediately(); // Immediate for preset update
  }

  /// Delete a preset (immediate for deliberate action)
  Future<void> deletePreset(String presetId) async {
    _presets.removeWhere((p) => p.id == presetId);
    await _savePresets();
    _notifyImmediately(); // Immediate for preset deletion
  }

  /// Toggle preset pinned status (immediate for deliberate action)
  Future<void> togglePresetPinned(String presetId) async {
    final index = _presets.indexWhere((p) => p.id == presetId);
    if (index == -1) throw Exception('Preset not found');
    
    _presets[index] = _presets[index].togglePinned();
    await _savePresets();
    _notifyImmediately(); // Immediate for pin toggle
  }

  /// Reset to default presets (immediate for deliberate action)
  Future<void> resetToDefaultPresets() async {
    _presets = DefaultFilterPresets.defaults;
    await _savePresets();
    _notifyImmediately(); // Immediate for reset action
  }

  /// Get quick filter suggestions based on user data
  List<QuickFilterSuggestion> getQuickFilterSuggestions() {
    final suggestions = <QuickFilterSuggestion>[];
    
    // Suggest clearing all if filters are active
    if (hasActiveFilters) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'Clear All',
          icon: Icons.clear,
          onTap: clearAllFilters,
        ),
      );
    }

    // Suggest local jobs if no distance filter
    if (_currentFilter.maxDistance == null) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'Near Me',
          icon: Icons.location_on,
          onTap: () => updateLocationFilter(maxDistance: 25.0),
        ),
      );
    }
    
    // Suggest recent posts if no date filter
    if (_currentFilter.postedAfter == null) {
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
    if (_currentFilter.hasPerDiem == null) {
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

  /// Cleanup resources when provider is disposed
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Quick filter suggestion model
class QuickFilterSuggestion {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickFilterSuggestion({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}