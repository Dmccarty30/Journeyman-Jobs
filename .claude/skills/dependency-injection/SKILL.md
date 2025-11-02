# Dependency Injection Skill

**Skill Type**: Technical Pattern | **Domain**: State Management | **Complexity**: Intermediate

## Purpose

Master Riverpod's dependency injection patterns for Journeyman Jobs, enabling testable, modular, and maintainable state management. Implement provider composition, ref.watch/read patterns, and hierarchical service dependencies for the electrical trade platform.

## Core Capabilities

### 1. Riverpod Provider Fundamentals

```dart
// Provider Types Overview
Provider<T>              // Immutable, synchronous values
StateProvider<T>         // Simple mutable state
FutureProvider<T>        // Async data loading
StreamProvider<T>        // Reactive streams
NotifierProvider<T>      // Complex state logic (recommended)
AsyncNotifierProvider<T> // Async state with Notifier
```

### 2. Provider Declaration Patterns

#### Basic Providers

```dart
// Simple value provider
final apiBaseUrlProvider = Provider<String>((ref) {
  return 'https://api.journeymanjobs.com';
});

// Configuration provider with dependencies
final firebaseConfigProvider = Provider<FirebaseConfig>((ref) {
  final environment = ref.watch(environmentProvider);

  return FirebaseConfig(
    apiKey: environment == Environment.prod
      ? 'prod-key'
      : 'dev-key',
    projectId: 'journeyman-jobs',
  );
});

// Service provider with auto-dispose
final jobsServiceProvider = Provider.autoDispose<JobsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  // Automatically disposed when no longer used
  return JobsService(firestore: firestore, auth: auth);
});
```

#### State Providers

```dart
// Simple mutable state
final selectedJobIdProvider = StateProvider<String?>((ref) => null);

// Filter state with auto-dispose
final jobFilterProvider = StateProvider.autoDispose<JobFilter>((ref) {
  return JobFilter.initial();
});

// Usage in widgets
Consumer(
  builder: (context, ref, child) {
    // Read current value
    final selectedId = ref.watch(selectedJobIdProvider);

    // Update value
    ref.read(selectedJobIdProvider.notifier).state = 'job-123';

    return Text('Selected: $selectedId');
  },
);
```

### 3. Notifier Provider Patterns (Recommended)

#### Synchronous Notifier

```dart
// Model
@freezed
class JobFilter with _$JobFilter {
  const factory JobFilter({
    required Set<String> tradeTypes,
    required Set<String> locations,
    required PayRange payRange,
    required bool stormWorkOnly,
  }) = _JobFilter;

  const JobFilter._();

  bool get hasActiveFilters =>
    tradeTypes.isNotEmpty ||
    locations.isNotEmpty ||
    stormWorkOnly;
}

// Notifier
class JobFilterNotifier extends Notifier<JobFilter> {
  @override
  JobFilter build() {
    // Initial state
    return JobFilter(
      tradeTypes: {},
      locations: {},
      payRange: PayRange.any,
      stormWorkOnly: false,
    );
  }

  void addTradeType(String tradeType) {
    state = state.copyWith(
      tradeTypes: {...state.tradeTypes, tradeType},
    );
  }

  void removeTradeType(String tradeType) {
    state = state.copyWith(
      tradeTypes: state.tradeTypes.difference({tradeType}),
    );
  }

  void toggleStormWork() {
    state = state.copyWith(stormWorkOnly: !state.stormWorkOnly);
  }

  void clearAll() {
    state = JobFilter(
      tradeTypes: {},
      locations: {},
      payRange: PayRange.any,
      stormWorkOnly: false,
    );
  }
}

// Provider declaration
final jobFilterProvider = NotifierProvider<JobFilterNotifier, JobFilter>(() {
  return JobFilterNotifier();
});

// Auto-dispose variant
final jobFilterProvider = NotifierProvider.autoDispose<JobFilterNotifier, JobFilter>(() {
  return JobFilterNotifier();
});
```

#### Async Notifier

```dart
// Model
@freezed
class JobsState with _$JobsState {
  const factory JobsState({
    required List<Job> jobs,
    required bool isLoading,
    required String? error,
    required DateTime? lastUpdated,
  }) = _JobsState;
}

// Async Notifier
class JobsNotifier extends AsyncNotifier<List<Job>> {
  late JobsService _service;

  @override
  Future<List<Job>> build() async {
    // Dependency injection via ref
    _service = ref.watch(jobsServiceProvider);

    // Listen to filter changes
    final filter = ref.watch(jobFilterProvider);

    // Load initial data
    return _loadJobs(filter);
  }

  Future<List<Job>> _loadJobs(JobFilter filter) async {
    try {
      final jobs = await _service.fetchJobs(filter);
      return jobs;
    } catch (e, stack) {
      // Let AsyncValue handle error state
      throw JobsLoadException('Failed to load jobs: $e');
    }
  }

  Future<void> refresh() async {
    // Set loading state
    state = const AsyncValue.loading();

    // Reload data
    state = await AsyncValue.guard(() async {
      final filter = ref.read(jobFilterProvider);
      return _loadJobs(filter);
    });
  }

  Future<void> addJob(Job job) async {
    // Optimistic update
    state.whenData((jobs) {
      state = AsyncValue.data([job, ...jobs]);
    });

    // Persist to backend
    try {
      await _service.createJob(job);
    } catch (e) {
      // Rollback on error
      await refresh();
      rethrow;
    }
  }
}

// Provider declaration
final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(() {
  return JobsNotifier();
});
```

### 4. Provider Composition & Dependencies

#### Dependent Providers

```dart
// Base providers
final authProvider = Provider<AuthService>((ref) {
  return AuthService(firebase: ref.watch(firebaseProvider));
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.authStateChanges();
});

// Computed provider based on current user
final userJobsProvider = FutureProvider<List<Job>>((ref) async {
  // Watch current user
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) async {
      if (user == null) return [];

      final jobsService = ref.watch(jobsServiceProvider);
      return jobsService.fetchUserJobs(user.id);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider that invalidates on auth changes
final jobsServiceProvider = Provider.autoDispose<JobsService>((ref) {
  final auth = ref.watch(authProvider);
  final firestore = ref.watch(firestoreProvider);

  // Recreate service when auth changes
  ref.listen(currentUserProvider, (previous, next) {
    // Invalidate cache when user changes
    ref.invalidateSelf();
  });

  return JobsService(
    firestore: firestore,
    auth: auth,
  );
});
```

#### Family Providers

```dart
// Provider with parameter
final jobDetailsProvider = FutureProvider.autoDispose.family<Job, String>(
  (ref, jobId) async {
    final service = ref.watch(jobsServiceProvider);

    // Cancel request if provider disposed
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());

    return service.fetchJobById(jobId, cancelToken);
  },
);

// Usage in widget
Consumer(
  builder: (context, ref, child) {
    final jobAsync = ref.watch(jobDetailsProvider('job-123'));

    return jobAsync.when(
      data: (job) => JobDetailsView(job),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  },
);
```

### 5. Ref Patterns (ref.watch vs ref.read vs ref.listen)

#### ref.watch - Reactive Rebuilds

```dart
// Use ref.watch in build() for reactive updates
class JobsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds when jobs change
    final jobsAsync = ref.watch(jobsProvider);

    // Rebuilds only when filter.hasActiveFilters changes
    final hasFilters = ref.watch(
      jobFilterProvider.select((filter) => filter.hasActiveFilters),
    );

    return jobsAsync.when(
      data: (jobs) => JobsList(jobs, hasFilters: hasFilters),
      loading: () => LoadingIndicator(),
      error: (e, s) => ErrorView(e),
    );
  }
}
```

#### ref.read - One-Time Access

```dart
// Use ref.read for callbacks and one-time reads
class JobCard extends ConsumerWidget {
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          // Read notifier without rebuilding
          final notifier = ref.read(selectedJobProvider.notifier);
          notifier.state = job.id;

          // Navigate
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailsScreen(jobId: job.id),
            ),
          );
        },
        child: JobCardContent(job),
      ),
    );
  }
}
```

#### ref.listen - Side Effects

```dart
// Use ref.listen for side effects without rebuilding
class JobsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  @override
  void initState() {
    super.initState();

    // Listen for errors and show snackbar
    ref.listen<AsyncValue<List<Job>>>(
      jobsProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build UI
    return Scaffold(...);
  }
}
```

### 6. JJ-Specific Dependency Graph

```dart
// Level 0: Core Infrastructure
final firebaseProvider = Provider<FirebaseApp>((ref) {
  return Firebase.initializeApp();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firebase = ref.watch(firebaseProvider);
  return FirebaseFirestore.instanceFor(app: firebase);
});

// Level 1: Authentication
final authServiceProvider = Provider<AuthService>((ref) {
  final firebase = ref.watch(firebaseProvider);
  return AuthService(firebase: firebase);
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges();
});

// Level 2: Services
final jobsServiceProvider = Provider.autoDispose<JobsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(currentUserProvider).value;

  return JobsService(
    firestore: firestore,
    userId: user?.id,
  );
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final messaging = ref.watch(fcmProvider);
  final user = ref.watch(currentUserProvider).value;

  return NotificationsService(
    messaging: messaging,
    userId: user?.id,
  );
});

// Level 3: State Management
final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(() {
  return JobsNotifier();
});

final jobFilterProvider = NotifierProvider<JobFilterNotifier, JobFilter>(() {
  return JobFilterNotifier();
});

// Level 4: Computed State
final filteredJobsProvider = Provider.autoDispose<AsyncValue<List<Job>>>((ref) {
  final jobsAsync = ref.watch(jobsProvider);
  final filter = ref.watch(jobFilterProvider);

  return jobsAsync.whenData((jobs) {
    return jobs.where((job) => _matchesFilter(job, filter)).toList();
  });
});
```

## Best Practices

### 1. Provider Naming Conventions

```dart
// Services: [name]ServiceProvider
final jobsServiceProvider = Provider<JobsService>(...);
final authServiceProvider = Provider<AuthService>(...);

// State: [name]Provider
final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(...);
final jobFilterProvider = NotifierProvider<JobFilterNotifier, JobFilter>(...);

// Computed: [computed][name]Provider
final filteredJobsProvider = Provider<List<Job>>(...);
final hasActiveFiltersProvider = Provider<bool>(...);

// Stream: [name]StreamProvider
final jobUpdatesStreamProvider = StreamProvider<Job>(...);
```

### 2. Auto-Dispose Strategy

```dart
// Use autoDispose for screen-level providers
final jobDetailsProvider = FutureProvider.autoDispose.family<Job, String>(...);

// Keep alive for app-level providers
final authServiceProvider = Provider<AuthService>(...);

// Keep alive with manual dispose control
final jobsProvider = AsyncNotifierProvider.autoDispose<JobsNotifier, List<Job>>(() {
  return JobsNotifier();
}).keepAlive(); // Keep alive manually
```

### 3. Error Handling in Providers

```dart
class JobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    try {
      final service = ref.watch(jobsServiceProvider);
      return await service.fetchJobs();
    } catch (e, stack) {
      // Log error
      ref.read(errorLoggerProvider).logError(e, stack);

      // Rethrow for AsyncValue.error state
      throw JobsException('Failed to load jobs', cause: e);
    }
  }
}
```

### 4. Testing with Dependency Injection

```dart
// Override providers in tests
testWidgets('JobsScreen displays jobs', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jobsServiceProvider.overrideWithValue(MockJobsService()),
        authServiceProvider.overrideWithValue(MockAuthService()),
      ],
      child: MaterialApp(home: JobsScreen()),
    ),
  );

  expect(find.byType(JobCard), findsWidgets);
});
```

## Common Pitfalls to Avoid

### ❌ Mistake 1: Using ref.watch in Callbacks

```dart
// BAD: ref.watch in callback causes rebuild
onPressed: () {
  final jobs = ref.watch(jobsProvider); // Don't do this!
  print(jobs);
}

// GOOD: Use ref.read for one-time access
onPressed: () {
  final jobs = ref.read(jobsProvider);
  print(jobs);
}
```

### ❌ Mistake 2: Not Using autoDispose

```dart
// BAD: Memory leak, provider never disposed
final jobDetailsProvider = FutureProvider.family<Job, String>(
  (ref, jobId) async => fetchJob(jobId),
);

// GOOD: Auto-dispose when screen closes
final jobDetailsProvider = FutureProvider.autoDispose.family<Job, String>(
  (ref, jobId) async => fetchJob(jobId),
);
```

### ❌ Mistake 3: Circular Dependencies

```dart
// BAD: Circular dependency
final providerA = Provider((ref) => ref.watch(providerB));
final providerB = Provider((ref) => ref.watch(providerA)); // Error!

// GOOD: Unidirectional dependencies
final baseProvider = Provider((ref) => BaseService());
final dependentProvider = Provider((ref) {
  final base = ref.watch(baseProvider);
  return DependentService(base);
});
```

## Quality Standards

- **Testability**: All services injectable via providers
- **Performance**: Use .select() for granular rebuilds
- **Memory**: Apply autoDispose to screen-level providers
- **Type Safety**: Strongly typed provider declarations

## Related Skills

- `immutable-model-design` - Data models for provider state
- `notifier-logic` - Business logic in Notifier classes
- `hierarchical-initialization` - Provider initialization order
- `riverpod-state-patterns` - Advanced state management patterns
