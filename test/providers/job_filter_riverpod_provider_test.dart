import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/providers/riverpod/job_filter_riverpod_provider.dart';
import '../../lib/models/filter_criteria.dart';
import '../../lib/models/filter_preset.dart';
import '../../lib/utils/error_handler.dart';
import '../test_config.dart';
import '../fixtures/mock_data.dart';

import 'job_filter_riverpod_provider_test.mocks.dart';

/// Generate mocks
@GenerateMocks([ErrorHandler, SharedPreferences])
void main() {
  group('JobFilterRiverpodProvider Tests', () {
    late ProviderContainer container;
    late MockErrorHandler mockErrorHandler;
    late MockSharedPreferences mockPrefs;

    setUp(() async {
      mockErrorHandler = MockErrorHandler();
      mockPrefs = MockSharedPreferences();

      // Setup default mock behavior
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.getStringList(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('JobFilterNotifier', () {
      test('should initialize with default empty state', () {
        // Arrange & Act
        final filterState = container.read(jobFilterProvider);

        // Assert
        expect(filterState.currentFilter, isA<JobFilterCriteria>());
        expect(filterState.hasActiveFilters, isFalse);
        expect(filterState.activeFilterCount, equals(0));
        expect(filterState.presets, isEmpty);
        expect(filterState.recentSearches, isEmpty);
        expect(filterState.isLoading, isFalse);
        expect(filterState.error, isNull);
      });

      test('should load filters from storage', () async {
        // Arrange
        final filterJson = '{"searchQuery":"electrician","localNumbers":[3]}';
        final presetsJson = '[{"id":"preset1","name":"Test Preset","criteria":{}}]';
        final searches = ['electrician', 'lineman', 'wireman'];

        when(mockPrefs.getString('current_job_filter')).thenReturn(filterJson);
        when(mockPrefs.getString('filter_presets')).thenReturn(presetsJson);
        when(mockPrefs.getStringList('recent_searches')).thenReturn(searches);

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100)); // Wait for async load

        // Assert
        verify(mockPrefs.getString('current_job_filter')).called(1);
        verify(mockPrefs.getString('filter_presets')).called(1);
        verify(mockPrefs.getStringList('recent_searches')).called(1);
      });

      test('should update filter', () async {
        // Arrange
        final newFilter = JobFilterCriteria(
          searchQuery: 'test search',
          localNumbers: [3, 124],
          maxDistance: 50.0,
        );

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(newFilter);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.searchQuery, equals('test search'));
        expect(state.currentFilter.localNumbers, contains(3));
        expect(state.currentFilter.localNumbers, contains(124));
        expect(state.currentFilter.maxDistance, equals(50.0));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should clear all filters', () async {
        // Arrange
        final filter = JobFilterCriteria(
          searchQuery: 'test',
          localNumbers: [3],
          maxDistance: 25.0,
        );

        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(filter);

        // Act
        notifier.clearAllFilters();

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.searchQuery, isNull);
        expect(state.currentFilter.localNumbers, isEmpty);
        expect(state.currentFilter.maxDistance, isNull);
        expect(state.hasActiveFilters, isFalse);

        verify(mockPrefs.setString('current_job_filter', any)).called(2);
      });

      test('should update location filter', () async {
        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateLocationFilter(
          city: 'New York',
          state: 'NY',
          maxDistance: 100.0,
        );

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.city, equals('New York'));
        expect(state.currentFilter.state, equals('NY'));
        expect(state.currentFilter.maxDistance, equals(100.0));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update classification filter', () async {
        // Arrange
        final classifications = ['Inside Wireman', 'Lineman'];

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateClassificationFilter(classifications);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.classifications, equals(classifications));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update local numbers filter', () async {
        // Arrange
        final locals = [3, 124, 269];

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateLocalNumbersFilter(locals);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.localNumbers, equals(locals));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update construction types filter', () async {
        // Arrange
        final types = ['Commercial', 'Industrial'];

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateConstructionTypesFilter(types);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.constructionTypes, equals(types));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update date filters', () async {
        // Arrange
        final postedAfter = DateTime.now().subtract(const Duration(days: 7));
        final startDate = DateTime.now().add(const Duration(days: 1));

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateDateFilters(
          postedAfter: postedAfter,
          startDateBefore: startDate,
        );

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.postedAfter, equals(postedAfter));
        expect(state.currentFilter.startDateBefore, equals(startDate));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update per diem filter', () async {
        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updatePerDiemFilter(true);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.hasPerDiem, isTrue);

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update duration preference', () async {
        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateDurationPreference('Long-term');

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.durationPreference, equals('Long-term'));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update company filter', () async {
        // Arrange
        final companies = ['PowerGrid', 'ElectriCo', 'Current Solutions'];

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateCompanyFilter(companies);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.companies, equals(companies));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update sort options', () async {
        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateSortOptions(
          sortBy: JobSortOption.wage,
          sortDescending: true,
        );

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.sortBy, equals(JobSortOption.wage));
        expect(state.currentFilter.sortDescending, isTrue);

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should update search query and add to recent', () async {
        // Arrange
        const query = 'electrician jobs';

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateSearchQuery(query);

        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 350));

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.searchQuery, equals(query));
        expect(state.recentSearches, contains(query));

        verify(mockPrefs.setString('current_job_filter', any)).called(1);
        verify(mockPrefs.setStringList('recent_searches', any)).called(1);
      });

      test('should clear recent searches', () async {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateSearchQuery('test1');
        notifier.updateSearchQuery('test2');
        await Future.delayed(const Duration(milliseconds: 350));

        // Act
        notifier.clearRecentSearches();

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.recentSearches, isEmpty);

        verify(mockPrefs.setStringList('recent_searches', any)).called(2);
      });

      test('should save as preset', () async {
        // Arrange
        const presetName = 'My Filter';
        const description = 'Jobs for electricians';
        final currentFilter = JobFilterCriteria(
          searchQuery: 'electrician',
          localNumbers: [3],
        );

        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(currentFilter);

        // Act
        await notifier.saveAsPreset(presetName, description: description);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.presets, isNotEmpty);
        final preset = state.presets.firstWhere((p) => p.name == presetName);
        expect(preset.description, equals(description));
        expect(preset.criteria.searchQuery, equals('electrician'));

        verify(mockPrefs.setString('filter_presets', any)).called(1);
      });

      test('should apply preset', () async {
        // Arrange
        final preset = FilterPreset.create(
          name: 'Test Preset',
          criteria: JobFilterCriteria(
            searchQuery: 'lineman',
            localNumbers: [124],
          ),
        );

        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(JobFilterCriteria()); // Start with empty

        // Act
        notifier.applyPreset(preset.id);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.searchQuery, equals('lineman'));
        expect(state.currentFilter.localNumbers, contains(124));
      });

      test('should update preset', () async {
        // Arrange
        const presetId = 'test_preset_1';
        final preset = FilterPreset(
          id: presetId,
          name: 'Old Name',
          criteria: JobFilterCriteria(),
          createdAt: DateTime.now(),
        );

        final notifier = container.read(jobFilterProvider.notifier);
        // Manually add preset for test
        notifier.state = notifier.state.copyWith(presets: [preset]);

        // Act
        await notifier.updatePreset(
          presetId,
          name: 'New Name',
          description: 'Updated description',
        );

        // Assert
        final state = container.read(jobFilterProvider);
        final updatedPreset = state.presets.firstWhere((p) => p.id == presetId);
        expect(updatedPreset.name, equals('New Name'));
        expect(updatedPreset.description, equals('Updated description'));
      });

      test('should delete preset', () async {
        // Arrange
        const presetId = 'test_preset_1';
        final preset = FilterPreset(
          id: presetId,
          name: 'To Delete',
          criteria: JobFilterCriteria(),
          createdAt: DateTime.now(),
        );

        final notifier = container.read(jobFilterProvider.notifier);
        notifier.state = notifier.state.copyWith(presets: [preset]);

        // Act
        await notifier.deletePreset(presetId);

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.presets, isEmpty);
      });

      test('should toggle preset pinned status', () async {
        // Arrange
        const presetId = 'test_preset_1';
        final preset = FilterPreset(
          id: presetId,
          name: 'Test Preset',
          criteria: JobFilterCriteria(),
          createdAt: DateTime.now(),
          isPinned: false,
        );

        final notifier = container.read(jobFilterProvider.notifier);
        notifier.state = notifier.state.copyWith(presets: [preset]);

        // Act
        await notifier.togglePresetPinned(presetId);

        // Assert
        final state = container.read(jobFilterProvider);
        final updatedPreset = state.presets.firstWhere((p) => p.id == presetId);
        expect(updatedPreset.isPinned, isTrue);
      });

      test('should reset to default presets', () async {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.state = notifier.state.copyWith(presets: [
          FilterPreset(
            id: 'custom',
            name: 'Custom',
            criteria: JobFilterCriteria(),
            createdAt: DateTime.now(),
          ),
        ]);

        // Act
        await notifier.resetToDefaultPresets();

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.presets, isNotEmpty);
        // Should contain default presets
        expect(state.presets.any((p) => p.name.contains('Near Me')), isTrue);
      });

      test('should get quick filter suggestions', () {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);
        final suggestions = notifier.getQuickFilterSuggestions();

        // Assert - Should suggest filters when none are active
        expect(suggestions, isNotEmpty);
        expect(suggestions.any((s) => s.label == 'Near Me'), isTrue);
        expect(suggestions.any((s) => s.label == 'Recent'), isTrue);
        expect(suggestions.any((s) => s.label == 'Per Diem'), isTrue);
      });

      test('should suggest clear all when filters are active', () {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(JobFilterCriteria(searchQuery: 'test'));

        // Act
        final suggestions = notifier.getQuickFilterSuggestions();

        // Assert
        expect(suggestions.any((s) => s.label == 'Clear All'), isTrue);
      });

      test('should clear error', () {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);

        // Act
        notifier.clearError();

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.error, isNull);
      });
    });

    group('Computed Providers', () {
      test('currentJobFilterProvider should return current filter', () {
        // Arrange
        final filter = JobFilterCriteria(searchQuery: 'test');
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: filter,
              presets: [],
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final currentFilter = container.read(currentJobFilterProvider);

        // Assert
        expect(currentFilter.searchQuery, equals('test'));
      });

      test('filterPresetsProvider should return presets', () {
        // Arrange
        final presets = [
          FilterPreset(
            id: '1',
            name: 'Preset 1',
            criteria: JobFilterCriteria(),
            createdAt: DateTime.now(),
          ),
        ];
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(),
              presets: presets,
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final returnedPresets = container.read(filterPresetsProvider);

        // Assert
        expect(returnedPresets, equals(presets));
      });

      test('recentSearchesProvider should return recent searches', () {
        // Arrange
        final searches = ['search1', 'search2', 'search3'];
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(),
              presets: [],
              recentSearches: searches,
              isLoading: false,
            )),
          ],
        );

        // Act
        final returnedSearches = container.read(recentSearchesProvider);

        // Assert
        expect(returnedSearches, equals(searches));
      });

      test('hasActiveFiltersProvider should return true when filters are active', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(searchQuery: 'test'),
              presets: [],
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final hasActiveFilters = container.read(hasActiveFiltersProvider);

        // Assert
        expect(hasActiveFilters, isTrue);
      });

      test('activeFilterCountProvider should return count of active filters', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(
                searchQuery: 'test',
                localNumbers: [3, 124],
                maxDistance: 50.0,
              ),
              presets: [],
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final count = container.read(activeFilterCountProvider);

        // Assert
        expect(count, equals(3));
      });

      test('pinnedPresetsProvider should return only pinned presets', () {
        // Arrange
        final presets = [
          FilterPreset(
            id: '1',
            name: 'Pinned',
            criteria: JobFilterCriteria(),
            createdAt: DateTime.now(),
            isPinned: true,
          ),
          FilterPreset(
            id: '2',
            name: 'Not Pinned',
            criteria: JobFilterCriteria(),
            createdAt: DateTime.now(),
            isPinned: false,
          ),
        ];
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(),
              presets: presets,
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final pinnedPresets = container.read(pinnedPresetsProvider);

        // Assert
        expect(pinnedPresets, hasLength(1));
        expect(pinnedPresets.first.name, equals('Pinned'));
      });

      test('recentPresetsProvider should return presets sorted by last used', () {
        // Arrange
        final now = DateTime.now();
        final presets = [
          FilterPreset(
            id: '1',
            name: 'Oldest',
            criteria: JobFilterCriteria(),
            createdAt: now.subtract(const Duration(days: 3)),
            lastUsedAt: now.subtract(const Duration(days: 2)),
          ),
          FilterPreset(
            id: '2',
            name: 'Most Recent',
            criteria: JobFilterCriteria(),
            createdAt: now.subtract(const Duration(days: 2)),
            lastUsedAt: now.subtract(const Duration(hours: 1)),
          ),
          FilterPreset(
            id: '3',
            name: 'Middle',
            criteria: JobFilterCriteria(),
            createdAt: now.subtract(const Duration(days: 1)),
            lastUsedAt: now.subtract(const Duration(days: 1)),
          ),
        ];
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(),
              presets: presets,
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final recentPresets = container.read(recentPresetsProvider);

        // Assert
        expect(recentPresets, hasLength(3));
        expect(recentPresets.first.name, equals('Most Recent'));
        expect(recentPresets.last.name, equals('Oldest'));
      });

      test('quickFilterSuggestionsProvider should return suggestions', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(),
              presets: [],
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final suggestions = container.read(quickFilterSuggestionsProvider);

        // Assert
        expect(suggestions, isNotEmpty);
        expect(suggestions.first, isA<QuickFilterSuggestion>());
      });
    });

    group('Persistence', () {
      test('should save filter to storage on update', () async {
        // Arrange
        final filter = JobFilterCriteria(searchQuery: 'test');

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(filter);

        // Assert
        verify(mockPrefs.setString('current_job_filter', any)).called(1);
      });

      test('should save presets to storage on change', () async {
        // Arrange
        const presetName = 'Test Preset';

        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        await notifier.saveAsPreset(presetName);

        // Assert
        verify(mockPrefs.setString('filter_presets', any)).called(1);
      });

      test('should save recent searches to storage', () async {
        // Act
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateSearchQuery('test search');
        await Future.delayed(const Duration(milliseconds: 350));

        // Assert
        verify(mockPrefs.setStringList('recent_searches', any)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenThrow(Exception('Storage error'));

        // Act & Assert - Should not throw
        final notifier = container.read(jobFilterProvider.notifier);
        notifier.updateFilter(JobFilterCriteria(searchQuery: 'test'));

        // State should still be updated
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.searchQuery, equals('test'));
      });

      test('should handle JSON decode errors gracefully', () async {
        // Arrange
        when(mockPrefs.getString('current_job_filter')).thenReturn('invalid json');
        when(mockPrefs.getString('filter_presets')).thenReturn('[invalid json');

        // Act & Assert - Should not throw
        final notifier = container.read(jobFilterProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Should fall back to default values
        final state = container.read(jobFilterProvider);
        expect(state.currentFilter, isA<JobFilterCriteria>());
        expect(state.presets, isA<List<FilterPreset>>());
      });
    });

    group('Debounce Behavior', () {
      test('should debounce search query updates', () async {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);
        var saveCount = 0;
        when(mockPrefs.setStringList('recent_searches', any))
            .thenAnswer((_) async {
              saveCount++;
              return true;
            });

        // Act - Rapid successive updates
        notifier.updateSearchQuery('a');
        notifier.updateSearchQuery('ab');
        notifier.updateSearchQuery('abc');
        notifier.updateSearchQuery('abcd');

        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 350));

        // Assert - Should only save once
        expect(saveCount, equals(1));

        final state = container.read(jobFilterProvider);
        expect(state.currentFilter.searchQuery, equals('abcd'));
      });

      test('should debounce filter updates', () async {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);
        var invalidateCount = 0;
        container.listen(jobFilterProvider, (previous, next) {
          invalidateCount++;
        });

        // Act - Rapid successive updates
        notifier.updateSortOptions(sortBy: JobSortOption.date);
        notifier.updateSortOptions(sortBy: JobSortOption.wage);
        notifier.updateSortOptions(sortBy: JobSortOption.distance);

        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 350));

        // Assert - Should have multiple updates but debounced notifications
        expect(invalidateCount, greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('should handle empty recent searches list', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobFilterProvider.overrideWith((ref) => JobFilterState(
              currentFilter: JobFilterCriteria(),
              presets: [],
              recentSearches: [],
              isLoading: false,
            )),
          ],
        );

        // Act
        final searches = container.read(recentSearchesProvider);

        // Assert
        expect(searches, isEmpty);
      });

      test('should handle maximum recent searches limit', () async {
        // Arrange
        final notifier = container.read(jobFilterProvider.notifier);

        // Act - Add more than 10 searches
        for (int i = 0; i < 15; i++) {
          notifier.updateSearchQuery('search $i');
          await Future.delayed(const Duration(milliseconds: 50));
        }
        await Future.delayed(const Duration(milliseconds: 350));

        // Assert
        final state = container.read(jobFilterProvider);
        expect(state.recentSearches.length, lessThanOrEqualTo(10));
        expect(state.recentSearches.first, equals('search 14')); // Most recent first
      });

      test('should handle duplicate preset names', () async {
        // Arrange
        const presetName = 'Duplicate Name';
        final notifier = container.read(jobFilterProvider.notifier);

        // Act
        await notifier.saveAsPreset(presetName);
        await notifier.saveAsPreset(presetName);

        // Assert
        final state = container.read(jobFilterProvider);
        final duplicates = state.presets.where((p) => p.name == presetName);
        expect(duplicates, hasLength(2));
      });
    });
  });
}