# Notifier Logic Skill

**Skill Type**: Technical Pattern | **Domain**: State Management | **Complexity**: Advanced

## Purpose

Master Riverpod Notifier and AsyncNotifier patterns for implementing complex business logic in Journeyman Jobs. Handle state mutations, side effects, async operations, error handling, and optimistic updates for the electrical trade platform.

## Core Capabilities

### 1. Notifier Fundamentals

```dart
// Synchronous Notifier pattern
class CounterNotifier extends Notifier<int> {
  // Build method returns initial state
  @override
  int build() {
    return 0;
  }

  // State mutation methods
  void increment() {
    state = state + 1;
  }

  void decrement() {
    state = state - 1;
  }

  void reset() {
    state = 0;
  }
}

// Provider declaration
final counterProvider = NotifierProvider<CounterNotifier, int>(() {
  return CounterNotifier();
});
```

### 2. AsyncNotifier for Async Operations

```dart
// Async state management
class JobsNotifier extends AsyncNotifier<List<Job>> {
  late JobsService _service;

  @override
  Future<List<Job>> build() async {
    // Dependency injection
    _service = ref.watch(jobsServiceProvider);

    // Load initial data
    return _loadJobs();
  }

  Future<List<Job>> _loadJobs() async {
    try {
      final jobs = await _service.fetchJobs();
      return jobs;
    } catch (e, stack) {
      // Log error
      ref.read(errorLoggerProvider).logError(e, stack);
      rethrow; // AsyncValue handles error state
    }
  }

  // Refresh data
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return _loadJobs();
    });
  }

  // Add job with optimistic update
  Future<void> addJob(Job job) async {
    // Optimistic update
    final previousState = state;
    state = state.whenData((jobs) => [job, ...jobs]);

    try {
      await _service.createJob(job);
    } catch (e, stack) {
      // Rollback on error
      state = previousState;
      ref.read(errorLoggerProvider).logError(e, stack);
      rethrow;
    }
  }

  // Update job
  Future<void> updateJob(Job updatedJob) async {
    final previousState = state;

    state = state.whenData((jobs) {
      return jobs.map((job) {
        return job.id == updatedJob.id ? updatedJob : job;
      }).toList();
    });

    try {
      await _service.updateJob(updatedJob);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // Delete job
  Future<void> deleteJob(String jobId) async {
    final previousState = state;

    state = state.whenData((jobs) {
      return jobs.where((job) => job.id != jobId).toList();
    });

    try {
      await _service.deleteJob(jobId);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}

// Provider declaration
final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(() {
  return JobsNotifier();
});
```

### 3. JJ-Specific Notifier Implementations

#### Job Filter Notifier

```dart
class JobFilterNotifier extends Notifier<JobFilter> {
  @override
  JobFilter build() {
    return JobFilter.initial();
  }

  // Trade type filtering
  void addTradeType(String tradeType) {
    state = state.copyWith(
      tradeTypes: {...state.tradeTypes, tradeType},
    );
    _saveToPreferences();
  }

  void removeTradeType(String tradeType) {
    state = state.copyWith(
      tradeTypes: state.tradeTypes.difference({tradeType}),
    );
    _saveToPreferences();
  }

  void setTradeTypes(Set<String> tradeTypes) {
    state = state.copyWith(tradeTypes: tradeTypes);
    _saveToPreferences();
  }

  // Location filtering
  void addLocation(String location) {
    state = state.copyWith(
      locations: {...state.locations, location},
    );
    _saveToPreferences();
  }

  void removeLocation(String location) {
    state = state.copyWith(
      locations: state.locations.difference({location}),
    );
    _saveToPreferences();
  }

  // Pay range filtering
  void setPayRange(PayRange? payRange) {
    state = state.copyWith(payRange: payRange);
    _saveToPreferences();
  }

  // Boolean filters
  void toggleStormWork() {
    state = state.copyWith(stormWorkOnly: !state.stormWorkOnly);
    _saveToPreferences();
  }

  void toggleUnionOnly() {
    state = state.copyWith(unionOnly: !state.unionOnly);
    _saveToPreferences();
  }

  void toggleLocalOnly() {
    state = state.copyWith(localOnly: !state.localOnly);
    _saveToPreferences();
  }

  // Distance filtering
  void setMaxDistance(double? distance) {
    state = state.copyWith(maxDistance: distance);
    _saveToPreferences();
  }

  void setCenter(Location? location) {
    state = state.copyWith(centerLocation: location);
    _saveToPreferences();
  }

  // Clear all filters
  void clearAll() {
    state = JobFilter.initial();
    _clearPreferences();
  }

  // Persistence
  Future<void> _saveToPreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('job_filter', jsonEncode(state.toJson()));
  }

  Future<void> _clearPreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('job_filter');
  }

  // Load saved filter
  Future<void> loadSavedFilter() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final filterJson = prefs.getString('job_filter');

    if (filterJson != null) {
      try {
        state = JobFilter.fromJson(jsonDecode(filterJson));
      } catch (e) {
        // Invalid saved filter, use default
        state = JobFilter.initial();
      }
    }
  }
}

final jobFilterProvider = NotifierProvider<JobFilterNotifier, JobFilter>(() {
  return JobFilterNotifier();
});
```

#### Search Notifier with Debouncing

```dart
class SearchNotifier extends AsyncNotifier<List<Job>> {
  late JobsService _service;
  Timer? _debounceTimer;

  @override
  Future<List<Job>> build() async {
    _service = ref.watch(jobsServiceProvider);

    // Cleanup timer on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return [];
  }

  // Debounced search
  void search(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final results = await _service.searchJobs(query);

      // Log search analytics
      ref.read(analyticsProvider).logSearch(query, results.length);

      return results;
    });
  }

  // Clear search
  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncValue.data([]);
  }
}

final searchProvider = AsyncNotifierProvider<SearchNotifier, List<Job>>(() {
  return SearchNotifier();
});
```

#### Favorites Notifier with Persistence

```dart
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  late JobsService _service;

  @override
  Future<Set<String>> build() async {
    _service = ref.watch(jobsServiceProvider);

    // Load favorites from local storage
    return _loadFavorites();
  }

  Future<Set<String>> _loadFavorites() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final favoritesJson = prefs.getString('favorites');

    if (favoritesJson != null) {
      final list = jsonDecode(favoritesJson) as List;
      return Set<String>.from(list);
    }

    return {};
  }

  // Add to favorites
  Future<void> addFavorite(String jobId) async {
    final previousState = state;

    // Optimistic update
    state = state.whenData((favorites) => {...favorites, jobId});

    try {
      // Sync to backend
      await _service.addFavorite(jobId);

      // Persist locally
      await _saveFavorites();
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String jobId) async {
    final previousState = state;

    state = state.whenData((favorites) {
      return favorites.difference({jobId});
    });

    try {
      await _service.removeFavorite(jobId);
      await _saveFavorites();
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String jobId) async {
    final isFavorite = state.value?.contains(jobId) ?? false;

    if (isFavorite) {
      await removeFavorite(jobId);
    } else {
      await addFavorite(jobId);
    }
  }

  // Check if job is favorited
  bool isFavorite(String jobId) {
    return state.value?.contains(jobId) ?? false;
  }

  // Persist favorites to local storage
  Future<void> _saveFavorites() async {
    final favorites = state.value ?? {};
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('favorites', jsonEncode(favorites.toList()));
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(() {
  return FavoritesNotifier();
});
```

#### App Settings Notifier

```dart
class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return AppSettings.initial();
  }

  // Load settings from storage
  Future<void> _loadSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final settingsJson = prefs.getString('app_settings');

    if (settingsJson != null) {
      try {
        state = AppSettings.fromJson(jsonDecode(settingsJson));
      } catch (e) {
        // Invalid settings, use default
        state = AppSettings.initial();
      }
    }
  }

  // Theme mode
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  // Notifications
  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _saveSettings();

    if (!enabled) {
      // Unsubscribe from FCM topics
      ref.read(fcmServiceProvider).unsubscribeFromAll();
    }
  }

  // High contrast mode
  void setHighContrastMode(bool enabled) {
    state = state.copyWith(highContrastMode: enabled);
    _saveSettings();
  }

  // Location services
  void setLocationServicesEnabled(bool enabled) {
    state = state.copyWith(locationServicesEnabled: enabled);
    _saveSettings();

    if (enabled) {
      // Request location permissions
      ref.read(locationServiceProvider).requestPermissions();
    }
  }

  // Notification preferences
  void updateNotificationPreferences(NotificationPreferences prefs) {
    state = state.copyWith(notificationPreferences: prefs);
    _saveSettings();
  }

  // Job search radius
  void setMaxJobSearchRadius(double radius) {
    state = state.copyWith(maxJobSearchRadius: radius);
    _saveSettings();
  }

  // Locale
  void setLocale(String locale) {
    state = state.copyWith(locale: locale);
    _saveSettings();
  }

  // Persist settings
  Future<void> _saveSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('app_settings', jsonEncode(state.toJson()));
  }

  // Reset to defaults
  void resetToDefaults() {
    state = AppSettings.initial();
    _saveSettings();
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(() {
  return AppSettingsNotifier();
});
```

### 4. Advanced Patterns

#### Notifier with Pagination

```dart
class PaginatedJobsNotifier extends AsyncNotifier<PaginatedList<Job>> {
  late JobsService _service;
  int _currentPage = 0;
  bool _isLoadingMore = false;

  @override
  Future<PaginatedList<Job>> build() async {
    _service = ref.watch(jobsServiceProvider);
    return _loadFirstPage();
  }

  Future<PaginatedList<Job>> _loadFirstPage() async {
    _currentPage = 0;
    return _service.fetchJobsPage(page: 0, pageSize: 20);
  }

  // Load next page
  Future<void> loadMore() async {
    if (_isLoadingMore) return;

    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    _isLoadingMore = true;

    try {
      final nextPage = await _service.fetchJobsPage(
        page: _currentPage + 1,
        pageSize: 20,
      );

      _currentPage++;

      state = AsyncValue.data(
        currentState.appendPage(nextPage),
      );
    } catch (e, stack) {
      // Don't lose current data on error
      ref.read(errorLoggerProvider).logError(e, stack);
    } finally {
      _isLoadingMore = false;
    }
  }

  // Refresh from start
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFirstPage());
  }
}

final paginatedJobsProvider = AsyncNotifierProvider<PaginatedJobsNotifier, PaginatedList<Job>>(() {
  return PaginatedJobsNotifier();
});
```

#### Notifier with Reactive Dependencies

```dart
class FilteredJobsNotifier extends AsyncNotifier<List<Job>> {
  late JobsService _service;

  @override
  Future<List<Job>> build() async {
    _service = ref.watch(jobsServiceProvider);

    // React to filter changes
    final filter = ref.watch(jobFilterProvider);

    // React to search query
    final searchQuery = ref.watch(searchQueryProvider);

    return _loadFilteredJobs(filter, searchQuery);
  }

  Future<List<Job>> _loadFilteredJobs(JobFilter filter, String searchQuery) async {
    final jobs = await _service.fetchJobs(
      filter: filter,
      searchQuery: searchQuery,
    );

    // Sort by relevance
    jobs.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return jobs;
  }

  // Manual refresh
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final filteredJobsProvider = AsyncNotifierProvider<FilteredJobsNotifier, List<Job>>(() {
  return FilteredJobsNotifier();
});
```

#### Notifier with Offline Support

```dart
class OfflineJobsNotifier extends AsyncNotifier<List<Job>> {
  late JobsService _service;
  late LocalStorageService _storage;

  @override
  Future<List<Job>> build() async {
    _service = ref.watch(jobsServiceProvider);
    _storage = ref.watch(localStorageProvider);

    // Check connectivity
    final isOnline = ref.watch(connectivityProvider);

    if (isOnline) {
      return _loadFromNetwork();
    } else {
      return _loadFromCache();
    }
  }

  Future<List<Job>> _loadFromNetwork() async {
    try {
      final jobs = await _service.fetchJobs();

      // Cache for offline use
      await _storage.saveJobs(jobs);

      return jobs;
    } catch (e) {
      // Fallback to cache on network error
      return _loadFromCache();
    }
  }

  Future<List<Job>> _loadFromCache() async {
    return _storage.getJobs();
  }

  // Add job (queue if offline)
  Future<void> addJob(Job job) async {
    final isOnline = ref.read(connectivityProvider);

    if (isOnline) {
      await _service.createJob(job);
      await refresh();
    } else {
      // Queue for later sync
      await _storage.queuePendingJob(job);

      // Add to local state
      state = state.whenData((jobs) => [job, ...jobs]);
    }
  }

  // Sync pending changes when online
  Future<void> syncPendingChanges() async {
    final pendingJobs = await _storage.getPendingJobs();

    for (final job in pendingJobs) {
      try {
        await _service.createJob(job);
        await _storage.removePendingJob(job.id);
      } catch (e) {
        // Log sync error
        ref.read(errorLoggerProvider).logError(e);
      }
    }

    await refresh();
  }
}

final offlineJobsProvider = AsyncNotifierProvider<OfflineJobsNotifier, List<Job>>(() {
  return OfflineJobsNotifier();
});
```

## Best Practices

### 1. State Mutation Guidelines

```dart
// DO: Use immutable updates
void updateJob(Job job) {
  state = state.copyWith(selectedJob: job);
}

// DON'T: Mutate state directly
void updateJob(Job job) {
  state.selectedJob = job; // Compile error - state is final
}
```

### 2. Error Handling

```dart
// DO: Handle errors gracefully
Future<void> loadJobs() async {
  state = const AsyncValue.loading();

  state = await AsyncValue.guard(() async {
    try {
      return await _service.fetchJobs();
    } on NetworkException catch (e) {
      throw UserFriendlyException('No internet connection');
    } on ServerException catch (e) {
      throw UserFriendlyException('Server error: ${e.message}');
    }
  });
}

// DON'T: Let raw exceptions bubble up
Future<void> loadJobs() async {
  final jobs = await _service.fetchJobs(); // May throw raw exception
  state = AsyncValue.data(jobs);
}
```

### 3. Optimistic Updates

```dart
// DO: Rollback on error
Future<void> deleteJob(String jobId) async {
  final previousState = state;

  state = state.whenData((jobs) {
    return jobs.where((job) => job.id != jobId).toList();
  });

  try {
    await _service.deleteJob(jobId);
  } catch (e) {
    state = previousState; // Rollback
    rethrow;
  }
}
```

### 4. Resource Cleanup

```dart
class TimerNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    // Cleanup on dispose
    ref.onDispose(() {
      _timer?.cancel();
    });

    return 0;
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      state = state + 1;
    });
  }
}
```

## Common Pitfalls to Avoid

### ❌ Mistake 1: Forgetting to Update State

```dart
// BAD: Modifies data but doesn't update state
void addJob(Job job) {
  final jobs = state.value ?? [];
  jobs.add(job); // Mutates but doesn't trigger rebuild
}

// GOOD: Creates new state
void addJob(Job job) {
  state = state.whenData((jobs) => [...jobs, job]);
}
```

### ❌ Mistake 2: Blocking build() Method

```dart
// BAD: Synchronous heavy operation in build
@override
List<Job> build() {
  return _loadJobsFromDatabase(); // Blocks UI thread
}

// GOOD: Use AsyncNotifier for async operations
@override
Future<List<Job>> build() async {
  return await _loadJobsFromDatabase();
}
```

### ❌ Mistake 3: Not Handling Loading State

```dart
// BAD: No loading indicator
Future<void> refresh() async {
  state = await AsyncValue.guard(() => _loadJobs());
}

// GOOD: Show loading state
Future<void> refresh() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() => _loadJobs());
}
```

## Quality Standards

- **Immutability**: Always use copyWith for state updates
- **Error Handling**: Wrap async operations in AsyncValue.guard
- **Optimistic Updates**: Implement rollback for better UX
- **Resource Cleanup**: Use ref.onDispose for timers, streams
- **Testing**: Unit test all state mutations and business logic

## Related Skills

- `dependency-injection` - Access services via ref.watch
- `immutable-model-design` - Use copyWith for state updates
- `initialization-strategy` - Notifier initialization patterns
- `service-lifecycle` - Service disposal in notifiers
