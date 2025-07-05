import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/filter_criteria.dart';
import '../models/filter_preset.dart';

/// Provider for managing job filters and presets with persistence
class JobFilterProvider extends ChangeNotifier {
  static const String _filterKey = 'current_job_filter';
  static const String _presetsKey = 'filter_presets';
  static const String _recentSearchesKey = 'recent_searches';
  
  JobFilterCriteria _currentFilter = JobFilterCriteria.empty();
  List<FilterPreset> _presets = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;

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
    notifyListeners();

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
      notifyListeners();
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

  /// Update the current filter
  void updateFilter(JobFilterCriteria newFilter) {
    _currentFilter = newFilter;
    _saveFilter();
    notifyListeners();
  }

  /// Clear all filters
  void clearAllFilters() {
    _currentFilter = JobFilterCriteria.empty();
    _saveFilter();
    notifyListeners();
  }

  /// Clear a specific filter type
  void clearFilterType(FilterType filterType) {
    _currentFilter = _currentFilter.clearFilter(filterType);
    _saveFilter();
    notifyListeners();
  }

  /// Update location filter
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
    notifyListeners();
  }

  /// Update classification filter
  void updateClassificationFilter(List<String> classifications) {
    _currentFilter = _currentFilter.copyWith(
      classifications: classifications,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update local numbers filter
  void updateLocalNumbersFilter(List<int> localNumbers) {
    _currentFilter = _currentFilter.copyWith(
      localNumbers: localNumbers,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update construction types filter
  void updateConstructionTypesFilter(List<String> constructionTypes) {
    _currentFilter = _currentFilter.copyWith(
      constructionTypes: constructionTypes,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update wage filter
  void updateWageFilter({double? minWage, double? maxWage}) {
    _currentFilter = _currentFilter.copyWith(
      minWage: minWage,
      maxWage: maxWage,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update date filters
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
    notifyListeners();
  }

  /// Update per diem filter
  void updatePerDiemFilter(bool? hasPerDiem) {
    _currentFilter = _currentFilter.copyWith(
      hasPerDiem: hasPerDiem,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update duration preference
  void updateDurationPreference(String? preference) {
    _currentFilter = _currentFilter.copyWith(
      durationPreference: preference,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update company filter
  void updateCompanyFilter(List<String> companies) {
    _currentFilter = _currentFilter.copyWith(
      companies: companies,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update sort options
  void updateSortOptions({
    JobSortOption? sortBy,
    bool? sortDescending,
  }) {
    _currentFilter = _currentFilter.copyWith(
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
    _saveFilter();
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String? query) {
    _currentFilter = _currentFilter.copyWith(
      searchQuery: query,
    );
    _saveFilter();
    
    // Add to recent searches if not empty
    if (query != null && query.isNotEmpty) {
      _addRecentSearch(query);
    }
    
    notifyListeners();
  }

  /// Update voltage level filter
  void updateVoltageLevelsFilter(List<String> voltageLevels) {
    _currentFilter = _currentFilter.copyWith(
      voltageLevels: voltageLevels,
    );
    _saveFilter();
    notifyListeners();
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

  /// Clear recent searches
  void clearRecentSearches() {
    _recentSearches.clear();
    _saveRecentSearches();
    notifyListeners();
  }

  /// Save current filter as preset
  Future<void> saveAsPreset(String name, {String? description, IconData? icon}) async {
    final preset = FilterPreset.create(
      name: name,
      description: description,
      criteria: _currentFilter,
      icon: icon,
    );
    
    _presets.add(preset);
    await _savePresets();
    notifyListeners();
  }

  /// Apply a preset
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
    notifyListeners();
  }

  /// Update a preset
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
    notifyListeners();
  }

  /// Delete a preset
  Future<void> deletePreset(String presetId) async {
    _presets.removeWhere((p) => p.id == presetId);
    await _savePresets();
    notifyListeners();
  }

  /// Toggle preset pinned status
  Future<void> togglePresetPinned(String presetId) async {
    final index = _presets.indexWhere((p) => p.id == presetId);
    if (index == -1) throw Exception('Preset not found');
    
    _presets[index] = _presets[index].togglePinned();
    await _savePresets();
    notifyListeners();
  }

  /// Reset to default presets
  Future<void> resetToDefaultPresets() async {
    _presets = DefaultFilterPresets.defaults;
    await _savePresets();
    notifyListeners();
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
    
    // Suggest high paying if not filtered
    if (_currentFilter.minWage == null) {
      suggestions.add(
        QuickFilterSuggestion(
          label: 'High Pay',
          icon: Icons.attach_money,
          onTap: () => updateWageFilter(minWage: 50.0),
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