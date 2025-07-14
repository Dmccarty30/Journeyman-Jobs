import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/providers/job_filter_provider.dart';
import 'package:journeyman_jobs/models/filter_criteria.dart';
import 'package:journeyman_jobs/models/filter_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  late JobFilterProvider filterProvider;

  setUp(() {
    // Reset SharedPreferences
    SharedPreferences.setMockInitialValues({});
    filterProvider = JobFilterProvider();
  });

  tearDown(() {
    filterProvider.dispose();
  });

  group('JobFilterProvider - Initialization Tests', () {
    test('should initialize with empty filter', () {
      expect(filterProvider.currentFilter.hasActiveFilters, isFalse);
      expect(filterProvider.currentFilter.classifications, isEmpty);
      expect(filterProvider.currentFilter.localNumbers, isEmpty);
      expect(filterProvider.currentFilter.searchQuery, isNull);
    });

    test('should initialize with default presets on first run', () async {
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(filterProvider.presets, isNotEmpty);
      expect(filterProvider.presets.any((p) => p.name.contains('Near Me')), isTrue);
      expect(filterProvider.presets.any((p) => p.name.contains('High Wage')), isTrue);
    });

    test('should load saved filter from storage', () async {
      // Arrange
      final savedFilter = JobFilterCriteria(
        classifications: ['Inside Wireman'],
        maxDistance: 50,
        searchQuery: 'commercial',
      );

      SharedPreferences.setMockInitialValues({
        'current_job_filter': jsonEncode(savedFilter.toJson()),
      });

      // Act
      filterProvider = JobFilterProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(filterProvider.currentFilter.classifications, contains('Inside Wireman'));
      expect(filterProvider.currentFilter.maxDistance, equals(50));
      expect(filterProvider.currentFilter.searchQuery, equals('commercial'));
    });
  });

  group('JobFilterProvider - Filter Updates Tests', () {
    test('should update filter with debouncing', () async {
      // Arrange
      var notificationCount = 0;
      filterProvider.addListener(() => notificationCount++);

      final newFilter = JobFilterCriteria(
        classifications: ['Journeyman Lineman'],
      );

      // Act
      filterProvider.updateFilter(newFilter);
      
      // Should not notify immediately (debounced)
      expect(notificationCount, equals(0));
      
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));
      
      // Assert
      expect(notificationCount, equals(1));
      expect(filterProvider.currentFilter.classifications, contains('Journeyman Lineman'));
    });

    test('should clear all filters immediately', () async {
      // Arrange
      filterProvider.updateFilter(JobFilterCriteria(
        classifications: ['Inside Wireman'],
        maxDistance: 100,
        searchQuery: 'test',
      ));
      await Future.delayed(const Duration(milliseconds: 350));

      var notificationCount = 0;
      filterProvider.addListener(() => notificationCount++);

      // Act
      filterProvider.clearAllFilters();

      // Assert - Should notify immediately
      expect(notificationCount, equals(1));
      expect(filterProvider.currentFilter.hasActiveFilters, isFalse);
      expect(filterProvider.activeFilterCount, equals(0));
    });

    test('should clear specific filter type', () async {
      // Arrange
      filterProvider.updateFilter(JobFilterCriteria(
        classifications: ['Inside Wireman'],
        maxDistance: 50,
        companies: ['ABC Electric'],
      ));
      await Future.delayed(const Duration(milliseconds: 350));

      // Act
      filterProvider.clearFilterType(FilterType.location);
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(filterProvider.currentFilter.maxDistance, isNull);
      expect(filterProvider.currentFilter.classifications, isNotEmpty);
      expect(filterProvider.currentFilter.companies, isNotEmpty);
    });
  });

  group('JobFilterProvider - Location Filter Tests', () {
    test('should update location filter with debouncing', () async {
      // Arrange
      var notificationCount = 0;
      filterProvider.addListener(() => notificationCount++);

      // Act - Multiple rapid updates
      filterProvider.updateLocationFilter(maxDistance: 25);
      filterProvider.updateLocationFilter(maxDistance: 50);
      filterProvider.updateLocationFilter(maxDistance: 75);

      // Should not notify during rapid updates
      expect(notificationCount, equals(0));

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));

      // Assert - Only one notification after debounce
      expect(notificationCount, equals(1));
      expect(filterProvider.currentFilter.maxDistance, equals(75));
    });

    test('should update city and state', () async {
      // Act
      filterProvider.updateLocationFilter(
        city: 'Chicago',
        state: 'IL',
        maxDistance: 50,
      );
      await Future.delayed(const Duration(milliseconds: 350));

      // Assert
      expect(filterProvider.currentFilter.city, equals('Chicago'));
      expect(filterProvider.currentFilter.state, equals('IL'));
      expect(filterProvider.currentFilter.maxDistance, equals(50));
    });
  });

  group('JobFilterProvider - Classification Filter Tests', () {
    test('should update classifications immediately', () async {
      // Arrange
      var notificationCount = 0;
      filterProvider.addListener(() => notificationCount++);

      // Act
      filterProvider.updateClassificationFilter(['Inside Wireman', 'Journeyman Lineman']);

      // Assert - Should notify immediately
      expect(notificationCount, equals(1));
      expect(filterProvider.currentFilter.classifications.length, equals(2));
      expect(filterProvider.currentFilter.classifications, contains('Inside Wireman'));
      expect(filterProvider.currentFilter.classifications, contains('Journeyman Lineman'));
    });
  });

  group('JobFilterProvider - Search Query Tests', () {
    test('should debounce search query updates', () async {
      // Arrange
      var notificationCount = 0;
      filterProvider.addListener(() => notificationCount++);

      // Act - Simulate typing
      filterProvider.updateSearchQuery('c');
      filterProvider.updateSearchQuery('co');
      filterProvider.updateSearchQuery('com');
      filterProvider.updateSearchQuery('comm');
      filterProvider.updateSearchQuery('comme');
      filterProvider.updateSearchQuery('commer');
      filterProvider.updateSearchQuery('commerc');
      filterProvider.updateSearchQuery('commerci');
      filterProvider.updateSearchQuery('commercia');
      filterProvider.updateSearchQuery('commercial');

      // Should not notify during typing
      expect(notificationCount, equals(0));

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));

      // Assert - Only one notification
      expect(notificationCount, equals(1));
      expect(filterProvider.currentFilter.searchQuery, equals('commercial'));
    });

    test('should add to recent searches after debounce', () async {
      // Act
      filterProvider.updateSearchQuery('electrical contractor');
      
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));

      // Assert
      expect(filterProvider.recentSearches, contains('electrical contractor'));
    });

    test('should limit recent searches to 10', () async {
      // Act - Add 12 searches
      for (int i = 1; i <= 12; i++) {
        filterProvider.updateSearchQuery('search $i');
        await Future.delayed(const Duration(milliseconds: 350));
      }

      // Assert
      expect(filterProvider.recentSearches.length, equals(10));
      expect(filterProvider.recentSearches.first, equals('search 12'));
      expect(filterProvider.recentSearches.last, equals('search 3'));
    });
  });

  group('JobFilterProvider - Preset Management Tests', () {
    test('should save current filter as preset', () async {
      // Arrange
      filterProvider.updateFilter(JobFilterCriteria(
        classifications: ['Inside Wireman'],
        maxDistance: 50,
      ));
      await Future.delayed(const Duration(milliseconds: 350));

      final initialPresetCount = filterProvider.presets.length;

      // Act
      await filterProvider.saveAsPreset(
        'My Custom Filter',
        description: 'Inside wireman jobs within 50 miles',
      );

      // Assert
      expect(filterProvider.presets.length, equals(initialPresetCount + 1));
      
      final newPreset = filterProvider.presets.last;
      expect(newPreset.name, equals('My Custom Filter'));
      expect(newPreset.description, equals('Inside wireman jobs within 50 miles'));
      expect(newPreset.criteria.classifications, contains('Inside Wireman'));
      expect(newPreset.criteria.maxDistance, equals(50));
    });

    test('should apply preset and update usage', () async {
      // Arrange
      await filterProvider.saveAsPreset('Test Preset');
      final preset = filterProvider.presets.last;
      final presetId = preset.id;

      // Act
      filterProvider.applyPreset(presetId);
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      final updatedPreset = filterProvider.presets.firstWhere((p) => p.id == presetId);
      expect(updatedPreset.useCount, equals(1));
      expect(updatedPreset.lastUsedAt.isAfter(preset.lastUsedAt), isTrue);
    });

    test('should get pinned presets', () async {
      // Arrange
      await filterProvider.saveAsPreset('Preset 1');
      await filterProvider.saveAsPreset('Preset 2');
      final preset2Id = filterProvider.presets.last.id;

      // Act
      await filterProvider.togglePresetPinned(preset2Id);

      // Assert
      expect(filterProvider.pinnedPresets.length, greaterThan(0));
      expect(filterProvider.pinnedPresets.any((p) => p.id == preset2Id), isTrue);
    });

    test('should get recent presets sorted by last used', () async {
      // Arrange
      await filterProvider.saveAsPreset('Preset A');
      await filterProvider.saveAsPreset('Preset B');
      await filterProvider.saveAsPreset('Preset C');
      
      final presetA = filterProvider.presets[filterProvider.presets.length - 3];
      final presetB = filterProvider.presets[filterProvider.presets.length - 2];
      
      // Use preset B most recently
      filterProvider.applyPreset(presetB.id);
      await Future.delayed(const Duration(milliseconds: 10));

      // Act
      final recentPresets = filterProvider.recentPresets;

      // Assert
      expect(recentPresets.first.id, equals(presetB.id));
    });

    test('should delete preset', () async {
      // Arrange
      await filterProvider.saveAsPreset('To Delete');
      final presetId = filterProvider.presets.last.id;
      final initialCount = filterProvider.presets.length;

      // Act
      await filterProvider.deletePreset(presetId);

      // Assert
      expect(filterProvider.presets.length, equals(initialCount - 1));
      expect(filterProvider.presets.any((p) => p.id == presetId), isFalse);
    });
  });

  group('JobFilterProvider - Quick Filter Suggestions Tests', () {
    test('should suggest clear all when filters active', () {
      // Arrange
      filterProvider.updateClassificationFilter(['Inside Wireman']);

      // Act
      final suggestions = filterProvider.getQuickFilterSuggestions();

      // Assert
      expect(suggestions.any((s) => s.label == 'Clear All'), isTrue);
    });

    test('should suggest near me when no distance filter', () {
      // Act
      final suggestions = filterProvider.getQuickFilterSuggestions();

      // Assert
      expect(suggestions.any((s) => s.label == 'Near Me'), isTrue);
    });

    test('should suggest recent when no date filter', () {
      // Act
      final suggestions = filterProvider.getQuickFilterSuggestions();

      // Assert
      expect(suggestions.any((s) => s.label == 'Recent'), isTrue);
    });

    test('should suggest per diem when not filtered', () {
      // Act
      final suggestions = filterProvider.getQuickFilterSuggestions();

      // Assert
      expect(suggestions.any((s) => s.label == 'Per Diem'), isTrue);
    });
  });

  group('JobFilterProvider - Persistence Tests', () {
    test('should persist filter changes', () async {
      // Arrange
      final filter = JobFilterCriteria(
        classifications: ['Inside Wireman'],
        maxDistance: 75,
        hasPerDiem: true,
      );

      // Act
      filterProvider.updateFilter(filter);
      await Future.delayed(const Duration(milliseconds: 350));

      // Get SharedPreferences to verify
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('current_job_filter');

      // Assert
      expect(savedJson, isNotNull);
      final savedFilter = JobFilterCriteria.fromJson(jsonDecode(savedJson!));
      expect(savedFilter.classifications, contains('Inside Wireman'));
      expect(savedFilter.maxDistance, equals(75));
      expect(savedFilter.hasPerDiem, isTrue);
    });

    test('should persist preset changes', () async {
      // Act
      await filterProvider.saveAsPreset('Persistent Preset');
      
      // Get SharedPreferences to verify
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('filter_presets');

      // Assert
      expect(savedJson, isNotNull);
      final savedPresets = (jsonDecode(savedJson!) as List)
          .map((json) => FilterPreset.fromJson(json))
          .toList();
      expect(savedPresets.any((p) => p.name == 'Persistent Preset'), isTrue);
    });
  });

  group('JobFilterProvider - Sort Options Tests', () {
    test('should update sort options with debouncing', () async {
      // Arrange
      var notificationCount = 0;
      filterProvider.addListener(() => notificationCount++);

      // Act
      filterProvider.updateSortOptions(
        sortBy: JobSortOption.wage,
        sortDescending: false,
      );

      // Should debounce
      expect(notificationCount, equals(0));

      await Future.delayed(const Duration(milliseconds: 350));

      // Assert
      expect(notificationCount, equals(1));
      expect(filterProvider.currentFilter.sortBy, equals(JobSortOption.wage));
      expect(filterProvider.currentFilter.sortDescending, isFalse);
    });
  });

  group('JobFilterProvider - Memory Management Tests', () {
    test('should cancel debounce timer on dispose', () async {
      // Arrange
      filterProvider.updateSearchQuery('test');
      
      // Act
      filterProvider.dispose();
      
      // Wait for what would be debounce period
      await Future.delayed(const Duration(milliseconds: 350));
      
      // Assert - No errors should occur
      expect(true, isTrue); // If we get here, dispose worked correctly
    });
  });
}