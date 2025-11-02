---
name: jj-riverpod-provider-architecture
description: Build Riverpod state management for IBEW electrical worker platform. Covers provider types (State, Future, Stream, Notifier), family providers, code generation, AsyncValue handling, filter pipelines, offline action queues, and storm work notifications. Use when creating feature state, managing job lists/filters, crew state, or implementing offline-first flows.
---

# JJ Riverpod Provider Architecture

## Purpose

Implement comprehensive Riverpod state management for Journeyman Jobs, handling job data, crew coordination, filters, real-time notifications, and offline-first synchronization for electrical field workers.

## When To Use

- Creating new feature state management
- Managing job lists and job filtering
- Handling crew state and messaging
- Implementing notifications (storm work, per diem alerts)
- Building offline-first data flows
- Setting up real-time data streams
- Organizing application-wide state

## Core Riverpod Concepts

### Provider Types Overview

| Provider Type | Use Case | When To Use | Example |
|---------------|----------|-------------|---------|
| **Provider** | Immutable data | Constants, services | `appConfigProvider` |
| **StateProvider** | Simple mutable state | Selected tab, flags | `selectedTabProvider` |
| **FutureProvider** | One-time async | User profile load | `userProfileProvider` |
| **StreamProvider** | Real-time updates | Job feed, messages | `jobStreamProvider` |
| **NotifierProvider** | Complex state logic | Jobs with methods | `jobsNotifierProvider` |
| **Family** | Parameterized providers | Job details by ID | `jobDetailsProvider(id)` |

### Provider Lifecycle

```dart
Created → Watched → Active → Unwatched → Disposed
    ↓                            ↓
  Read Once                  Auto-dispose (if configured)
```

## Essential Provider Patterns

### Pattern 1: Simple State (StateProvider)

**Use For**: Boolean flags, enums, simple values that change frequently

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple tab selection
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Simple filter type
final jobFilterTypeProvider = StateProvider<JobFilterType>(
  (ref) => JobFilterType.all,
);

// Storm work alert toggle
final showStormWorkOnlyProvider = StateProvider<bool>((ref) => false);

// Usage in widget
class JobsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) {
          // Update state
          ref.read(selectedTabProvider.notifier).state = index;
        },
        items: [...],
      ),
    );
  }
}
```

### Pattern 2: Async Data Loading (FutureProvider)

**Use For**: One-time data fetch, user profiles, initial configuration

```dart
// Load user profile once
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  
  return await firestore.getUserProfile(userId);
});

// Load IBEW locals directory
final localsDirectoryProvider = FutureProvider<List<Local>>((ref) async {
  final firestore = ref.watch(firestoreServiceProvider);
  return await firestore.getLocalsDirectory();
});

// Usage with AsyncValue handling
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    
    return profileAsync.when(
      // Loading state
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      
      // Error state
      error: (error, stack) => ErrorRecoveryWidget(
        error: error,
        onRetry: () => ref.refresh(userProfileProvider),
      ),
      
      // Success state
      data: (profile) => ProfileContent(profile: profile),
    );
  }
}
```

### Pattern 3: Real-Time Streams (StreamProvider)

**Use For**: Live job updates, storm work alerts, crew messages

```dart
// Real-time job feed
final jobStreamProvider = StreamProvider<List<Job>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final filters = ref.watch(jobFiltersProvider);
  
  // Return Firestore stream with filters
  return firestore.watchJobs(filters);
});

// Storm work notifications stream
final stormWorkStreamProvider = StreamProvider<List<Job>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  
  return firestore.watchStormWork();
});

// Crew messages stream
final crewMessagesStreamProvider = StreamProvider.family<List<Message>, String>(
  (ref, crewId) {
    final firestore = ref.watch(firestoreServiceProvider);
    return firestore.watchCrewMessages(crewId);
  },
);

// Usage
class JobFeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobStreamProvider);
    
    return jobsAsync.when(
      loading: () => const JobListSkeleton(),
      error: (e, s) => ErrorWidget(error: e),
      data: (jobs) {
        if (jobs.isEmpty) {
          return const EmptyJobsWidget();
        }
        return JobList(jobs: jobs);
      },
    );
  }
}
```

### Pattern 4: Complex State Logic (NotifierProvider)

**Use For**: Feature state with business logic, methods, and complex updates

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'jobs_notifier.g.dart';

// State class - immutable
@freezed
class JobsState with _$JobsState {
  const factory JobsState({
    required List<Job> jobs,
    required Set<String> bookmarkedIds,
    required bool isLoading,
    String? error,
  }) = _JobsState;
  
  factory JobsState.initial() => const JobsState(
    jobs: [],
    bookmarkedIds: {},
    isLoading: false,
  );
}

// Notifier - mutable logic
@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  JobsState build() {
    // Initialize state
    _loadJobs();
    return JobsState.initial();
  }
  
  Future<void> _loadJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final jobs = await firestore.getJobs();
      
      state = state.copyWith(
        jobs: jobs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  
  // Business logic methods
  Future<void> bookmarkJob(String jobId) async {
    // Optimistic update
    state = state.copyWith(
      bookmarkedIds: {...state.bookmarkedIds, jobId},
    );
    
    try {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.bookmarkJob(jobId);
    } catch (e) {
      // Rollback on failure
      final updated = {...state.bookmarkedIds}..remove(jobId);
      state = state.copyWith(bookmarkedIds: updated);
      rethrow;
    }
  }
  
  void clearBookmarks() {
    state = state.copyWith(bookmarkedIds: {});
  }
  
  Future<void> refresh() async {
    await _loadJobs();
  }
}

// Usage
class JobsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobsNotifierProvider);
    final notifier = ref.read(jobsNotifierProvider.notifier);
    
    return Scaffold(
      body: state.isLoading
          ? const LoadingIndicator()
          : JobList(
              jobs: state.jobs,
              bookmarkedIds: state.bookmarkedIds,
              onBookmark: notifier.bookmarkJob,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: notifier.refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### Pattern 5: Family Providers (Parameterized)

**Use For**: Data that varies by parameter (job ID, crew ID, local number)

```dart
// Job details by ID
@riverpod
Future<Job> jobDetails(JobDetailsRef ref, String jobId) async {
  final firestore = ref.watch(firestoreServiceProvider);
  return await firestore.getJob(jobId);
}

// Crew details by ID
@riverpod
Stream<Crew> crewStream(CrewStreamRef ref, String crewId) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchCrew(crewId);
}

// Local jobs by local number
@riverpod
Future<List<Job>> localJobs(LocalJobsRef ref, int localNumber) async {
  final firestore = ref.watch(firestoreServiceProvider);
  return await firestore.getJobsByLocal(localNumber);
}

// Usage
class JobDetailsScreen extends ConsumerWidget {
  final String jobId;
  
  const JobDetailsScreen({required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailsProvider(jobId));
    
    return jobAsync.when(
      loading: () => const JobDetailsSkeleton(),
      error: (e, s) => ErrorScreen(error: e),
      data: (job) => JobDetailsContent(job: job),
    );
  }
}
```

## Advanced Patterns for Electrical Platform

### Pattern 6: Computed/Derived State

**Use For**: Filtering, sorting, transformations without duplicating data

```dart
// Base jobs provider
@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  List<Job> build() {
    _loadJobs();
    return [];
  }
  
  Future<void> _loadJobs() async {
    final firestore = ref.read(firestoreServiceProvider);
    state = await firestore.getJobs();
  }
}

// Filtered jobs (computed)
@riverpod
List<Job> filteredJobs(FilteredJobsRef ref) {
  final allJobs = ref.watch(jobsNotifierProvider);
  final filters = ref.watch(jobFiltersProvider);
  
  return allJobs.where((job) {
    // Location filter
    if (filters.city != null && job.city != filters.city) {
      return false;
    }
    
    // Trade classification filter
    if (filters.trade != null && job.trade != filters.trade) {
      return false;
    }
    
    // Storm work filter
    if (filters.stormWorkOnly && !job.isStormWork) {
      return false;
    }
    
    // Per diem threshold
    if (filters.minPerDiem != null && 
        (job.perDiem ?? 0) < filters.minPerDiem!) {
      return false;
    }
    
    return true;
  }).toList();
}

// Sorted jobs (computed)
@riverpod
List<Job> sortedJobs(SortedJobsRef ref) {
  final filtered = ref.watch(filteredJobsProvider);
  final sortBy = ref.watch(sortByProvider);
  
  return List.from(filtered)..sort((a, b) {
    switch (sortBy) {
      case SortBy.date:
        return b.postedDate.compareTo(a.postedDate);
      case SortBy.perDiem:
        return (b.perDiem ?? 0).compareTo(a.perDiem ?? 0);
      case SortBy.distance:
        final userLocation = ref.watch(userLocationProvider);
        final distA = _calculateDistance(userLocation, a.location);
        final distB = _calculateDistance(userLocation, b.location);
        return distA.compareTo(distB);
    }
  });
}

// Storm work jobs only (computed)
@riverpod
List<Job> stormWorkJobs(StormWorkJobsRef ref) {
  final allJobs = ref.watch(jobsNotifierProvider);
  return allJobs.where((job) => job.isStormWork).toList();
}
```

### Pattern 7: Offline Action Queue

**Use For**: Queuing actions when offline, syncing when back online

```dart
@freezed
class OfflineAction with _$OfflineAction {
  const factory OfflineAction.bookmarkJob(String jobId) = BookmarkJobAction;
  const factory OfflineAction.applyToJob(String jobId, Application app) = ApplyToJobAction;
  const factory OfflineAction.sendMessage(String crewId, Message msg) = SendMessageAction;
}

@riverpod
class OfflineQueue extends _$OfflineQueue {
  @override
  List<OfflineAction> build() {
    // Load persisted queue from storage
    _loadPersistedQueue();
    return [];
  }
  
  Future<void> _loadPersistedQueue() async {
    final storage = ref.read(storageServiceProvider);
    final persisted = await storage.getOfflineQueue();
    state = persisted;
  }
  
  void enqueue(OfflineAction action) {
    state = [...state, action];
    _persistQueue();
    
    // Try to sync immediately if online
    if (ref.read(connectivityProvider)) {
      _processQueue();
    }
  }
  
  Future<void> _processQueue() async {
    if (state.isEmpty) return;
    
    final firestore = ref.read(firestoreServiceProvider);
    final processed = <OfflineAction>[];
    
    for (final action in state) {
      try {
        await action.when(
          bookmarkJob: (jobId) => firestore.bookmarkJob(jobId),
          applyToJob: (jobId, app) => firestore.submitApplication(jobId, app),
          sendMessage: (crewId, msg) => firestore.sendCrewMessage(crewId, msg),
        );
        processed.add(action);
      } catch (e) {
        // Stop on first failure, retry later
        break;
      }
    }
    
    // Remove successfully processed actions
    state = state.where((a) => !processed.contains(a)).toList();
    await _persistQueue();
  }
  
  Future<void> _persistQueue() async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveOfflineQueue(state);
  }
}

// Listen for connectivity changes
@riverpod
void queueSyncListener(QueueSyncListenerRef ref) {
  ref.listen(connectivityProvider, (previous, next) {
    if (next && !previous) {
      // Just came back online, process queue
      ref.read(offlineQueueProvider.notifier)._processQueue();
    }
  });
}
```

### Pattern 8: Optimistic Updates

**Use For**: Immediate UI feedback while syncing in background

```dart
@riverpod
class JobBookmarks extends _$JobBookmarks {
  @override
  Set<String> build() {
    _loadBookmarks();
    return {};
  }
  
  Future<void> _loadBookmarks() async {
    final firestore = ref.read(firestoreServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    state = await firestore.getUserBookmarks(userId);
  }
  
  Future<void> toggleBookmark(String jobId) async {
    final isBookmarked = state.contains(jobId);
    
    // 1. OPTIMISTIC: Update UI immediately
    if (isBookmarked) {
      state = {...state}..remove(jobId);
    } else {
      state = {...state, jobId};
    }
    
    // 2. SYNC: Update backend
    try {
      final firestore = ref.read(firestoreServiceProvider);
      if (isBookmarked) {
        await firestore.removeBookmark(jobId);
      } else {
        await firestore.addBookmark(jobId);
      }
    } catch (e) {
      // 3. ROLLBACK on failure
      if (isBookmarked) {
        state = {...state, jobId};
      } else {
        state = {...state}..remove(jobId);
      }
      
      // 4. QUEUE for retry if offline
      if (!ref.read(connectivityProvider)) {
        ref.read(offlineQueueProvider.notifier).enqueue(
          OfflineAction.bookmarkJob(jobId),
        );
      }
      
      rethrow;
    }
  }
}
```

## Electrical Platform-Specific Patterns

### Storm Work Notifications

```dart
@riverpod
class StormWorkNotifier extends _$StormWorkNotifier {
  Timer? _checkTimer;
  
  @override
  List<Job> build() {
    _startChecking();
    return [];
  }
  
  void _startChecking() {
    // Check for storm work every 5 minutes
    _checkTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkForStormWork(),
    );
  }
  
  Future<void> _checkForStormWork() async {
    final firestore = ref.read(firestoreServiceProvider);
    final userLocation = ref.read(userLocationProvider);
    
    final stormJobs = await firestore.getStormWorkNearLocation(
      userLocation,
      radiusMiles: 100,
    );
    
    // Notify if new storm work found
    if (stormJobs.isNotEmpty && stormJobs != state) {
      state = stormJobs;
      ref.read(notificationServiceProvider).showStormWorkAlert(
        jobCount: stormJobs.length,
      );
    }
  }
  
  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
```

### Per Diem Calculator

```dart
@riverpod
class PerDiemCalculator extends _$PerDiemCalculator {
  @override
  Map<String, double> build() {
    return {};
  }
  
  double calculatePerDiem(Job job) {
    final cacheKey = '${job.id}_${job.city}_${job.state}';
    
    // Check cache
    if (state.containsKey(cacheKey)) {
      return state[cacheKey]!;
    }
    
    // Calculate based on location
    final userLocation = ref.read(userLocationProvider);
    final distance = _calculateDistance(userLocation, job.location);
    
    // Per diem tiers (IBEW standard rates)
    final perDiem = distance > 100 ? 75.0
                  : distance > 50  ? 50.0
                  : distance > 25  ? 30.0
                  : 0.0;
    
    // Cache result
    state = {...state, cacheKey: perDiem};
    
    return perDiem;
  }
  
  double _calculateDistance(LatLng from, LatLng to) {
    // Haversine formula for distance
    // ... implementation
  }
}
```

### Territory-Based Queries

```dart
@riverpod
Future<List<Job>> territoryJobs(TerritoryJobsRef ref, int localNumber) async {
  final firestore = ref.read(firestoreServiceProvider);
  
  // Get local's territory boundaries
  final local = await firestore.getLocal(localNumber);
  final territory = local.territory;
  
  // Query jobs within territory
  return await firestore.getJobsInTerritory(territory);
}

// Watch jobs for user's home local
@riverpod
Stream<List<Job>> homeLocalJobs(HomeLocalJobsRef ref) {
  final userLocal = ref.watch(userProfileProvider).value?.localNumber;
  if (userLocal == null) return Stream.value([]);
  
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchJobsByLocal(userLocal);
}
```

## Code Generation Setup

### Step 1: Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  freezed_annotation: ^2.4.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
```

### Step 2: Create Provider with Code Generation

```dart
// jobs_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

// IMPORTANT: This generates jobs_provider.g.dart
part 'jobs_provider.g.dart';

@riverpod
Future<List<Job>> jobs(JobsRef ref) async {
  final firestore = ref.watch(firestoreServiceProvider);
  return await firestore.getJobs();
}

@riverpod
class JobsNotifier extends _$JobsNotifier {
  @override
  List<Job> build() {
    return [];
  }
  
  void addJob(Job job) {
    state = [...state, job];
  }
}
```

### Step 3: Generate Code

```bash
# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
dart run build_runner watch --delete-conflicting-outputs
```

### Step 4: Use Generated Providers

```dart
// Auto-generated: jobsProvider, jobsNotifierProvider
class JobsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider);
    final notifier = ref.read(jobsNotifierProvider.notifier);
    
    return jobsAsync.when(...);
  }
}
```

## Testing Providers

### Unit Testing Providers

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('JobsNotifier adds job correctly', () {
    final container = ProviderContainer();
    
    final notifier = container.read(jobsNotifierProvider.notifier);
    final job = Job(id: '1', title: 'Electrician');
    
    notifier.addJob(job);
    
    final state = container.read(jobsNotifierProvider);
    expect(state, contains(job));
    
    container.dispose();
  });
  
  test('Filtered jobs apply filters correctly', () async {
    final container = ProviderContainer(
      overrides: [
        // Mock data
        jobsNotifierProvider.overrideWith((ref) => [
          Job(id: '1', city: 'Chicago', trade: 'Journeyman'),
          Job(id: '2', city: 'New York', trade: 'Apprentice'),
        ]),
      ],
    );
    
    // Set filter
    container.read(jobFiltersProvider.notifier).state = JobFilters(
      city: 'Chicago',
    );
    
    final filtered = container.read(filteredJobsProvider);
    expect(filtered.length, 1);
    expect(filtered.first.city, 'Chicago');
    
    container.dispose();
  });
}
```

### Widget Testing with Providers

```dart
testWidgets('JobsScreen shows loading indicator', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: JobsScreen(),
      ),
    ),
  );
  
  // Should show loading initially
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});

testWidgets('JobsScreen shows jobs after load', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jobsProvider.overrideWith((ref) async => [
          Job(id: '1', title: 'Electrician'),
        ]),
      ],
      child: MaterialApp(
        home: JobsScreen(),
      ),
    ),
  );
  
  // Wait for data
  await tester.pumpAndSettle();
  
  // Should show job card
  expect(find.text('Electrician'), findsOneWidget);
});
```

## Performance Optimization

### Selective Watching

```dart
// ❌ BAD: Rebuilds on ANY filter change
final filters = ref.watch(jobFiltersProvider);

// ✅ GOOD: Only rebuilds when city changes
final city = ref.watch(
  jobFiltersProvider.select((f) => f.city),
);

// ✅ GOOD: Only rebuilds when storm work flag changes
final stormWorkOnly = ref.watch(
  jobFiltersProvider.select((f) => f.stormWorkOnly),
);
```

### Caching Expensive Computations

```dart
@riverpod
Future<List<Job>> expensiveJobProcessing(ExpensiveJobProcessingRef ref) async {
  // Cache this provider's result for 5 minutes
  ref.cacheFor(const Duration(minutes: 5));
  
  final jobs = await ref.watch(jobsProvider.future);
  
  // Expensive operation
  return await _processJobsWithML(jobs);
}
```

### Auto-Dispose for Memory Management

```dart
// Auto-disposes when no longer watched
@riverpod
Future<Job> jobDetails(JobDetailsRef ref, String jobId) async {
  // Keeps provider alive for 5 minutes after last listener
  ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  
  final firestore = ref.watch(firestoreServiceProvider);
  return await firestore.getJob(jobId);
}
```

## Common Mistakes

### ❌ Mistake 1: Mutating State Directly

```dart
// WRONG
void addJob(Job job) {
  state.add(job);  // Mutates state directly!
}

// CORRECT
void addJob(Job job) {
  state = [...state, job];  // Creates new list
}
```

### ❌ Mistake 2: Circular Dependencies

```dart
// WRONG: Circular dependency
@riverpod
String userGreeting(UserGreetingRef ref) {
  final name = ref.watch(userNameProvider);  // Depends on userName
  return 'Hello, $name';
}

@riverpod
String userName(UserNameRef ref) {
  final greeting = ref.watch(userGreetingProvider);  // Depends on greeting!
  return greeting.split(' ')[1];
}

// CORRECT: Break the cycle
@riverpod
String userGreeting(UserGreetingRef ref) {
  final profile = ref.watch(userProfileProvider);
  return 'Hello, ${profile.name}';
}
```

### ❌ Mistake 3: Business Logic in UI

```dart
// WRONG: Logic in widget
class JobCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(jobProvider(jobId));
    
    // Business logic in UI!
    final shouldShowPerDiem = job.distance > 50;
    final perDiem = shouldShowPerDiem ? job.perDiem : 0;
    
    return Card(...);
  }
}

// CORRECT: Logic in provider
@riverpod
double jobPerDiem(JobPerDiemRef ref, String jobId) {
  final job = ref.watch(jobProvider(jobId)).value;
  if (job == null) return 0;
  
  final distance = ref.watch(jobDistanceProvider(jobId));
  return distance > 50 ? job.perDiem : 0;
}
```

## Checklist

- [ ] All providers use code generation (@riverpod)
- [ ] AsyncValue states (loading, error, data) handled
- [ ] Optimistic updates implemented for user actions
- [ ] Offline queue for failed operations
- [ ] Computed providers for filtering/sorting
- [ ] Family providers for parameterized data
- [ ] Unit tests for provider logic
- [ ] Widget tests with ProviderScope
- [ ] Performance profiling with DevTools
- [ ] Auto-dispose configured where appropriate
- [ ] No circular dependencies
- [ ] Business logic in providers, not UI

---

**Skill Version**: 1.0.0  
**Last Updated**: 2025-10-31  
**Status**: ✅ Production Ready
