# Riverpod Provider Patterns

**Skill Name**: Riverpod Provider Patterns
**Domain**: State Management, Flutter, Riverpod

## Category
**State Management & Architecture**

## Who Uses This
- Flutter Developers implementing Riverpod 2.0+
- Backend Integration Specialists working with state synchronization
- Frontend Developers building reactive UIs
- Architecture Specialists designing state management systems

## Description

Comprehensive guide to Riverpod 2.0 provider patterns, covering both manual and code-generated approaches. This skill focuses on choosing the right provider type, implementing best practices, and understanding the trade-offs between manual and codegen patterns.

Riverpod 2.0 introduced significant improvements with code generation, making state management more type-safe and maintainable while reducing boilerplate. Understanding when to use manual vs. codegen patterns is critical for scalable Flutter applications.

## Key Techniques

### 1. Provider Type Selection Matrix

**Decision Tree**:
```dart
// IMMUTABLE DATA (read-only state)
// Use: Provider (manual) or @riverpod (codegen)
@riverpod
AppConfig appConfig(AppConfigRef ref) {
  return const AppConfig(
    apiUrl: 'https://api.example.com',
    timeout: Duration(seconds: 30),
  );
}

// Manual equivalent:
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
    apiUrl: 'https://api.example.com',
    timeout: Duration(seconds: 30),
  );
});

// SIMPLE COMPUTED STATE (derived from other providers)
// Use: Provider (manual) or @riverpod (codegen)
@riverpod
String userDisplayName(UserDisplayNameRef ref) {
  final user = ref.watch(currentUserProvider);
  return '${user.firstName} ${user.lastName}';
}

// MUTABLE STATE (simple value changes)
// Use: StateProvider (manual) or @riverpod (codegen with class)
final counterProvider = StateProvider<int>((ref) => 0);

// Codegen equivalent:
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

// COMPLEX STATE WITH LOGIC (business logic, async operations)
// Use: StateNotifierProvider (manual) or @riverpod class (codegen)
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// FUTURE-BASED STATE (async data loading)
// Use: FutureProvider (manual) or @riverpod Future (codegen)
@riverpod
Future<List<Job>> jobs(JobsRef ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchJobs();
}

// STREAM-BASED STATE (real-time updates)
// Use: StreamProvider (manual) or @riverpod Stream (codegen)
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String chatId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('chats/$chatId/messages')
    .orderBy('timestamp', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Message.fromJson(doc.data()))
      .toList());
}
```

### 2. Manual vs. Code Generation Patterns

**When to Use Manual Providers**:
```dart
// Simple, static configuration
final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData.light();
});

// Quick prototyping
final selectedIndexProvider = StateProvider<int>((ref) => 0);

// Legacy code migration (gradual transition)
final legacyDataProvider = Provider<LegacyData>((ref) {
  return LegacyData.instance;
});
```

**When to Use Code Generation**:
```dart
// Complex business logic with multiple methods
@riverpod
class JobListings extends _$JobListings {
  @override
  Future<List<Job>> build() async {
    return _fetchJobs();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchJobs());
  }

  Future<void> applyFilter(JobFilter filter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchJobs(filter: filter));
  }

  Future<List<Job>> _fetchJobs({JobFilter? filter}) async {
    final api = ref.read(apiServiceProvider);
    return api.fetchJobs(filter: filter);
  }
}

// Providers with parameters (family pattern)
@riverpod
Future<JobDetails> jobDetails(JobDetailsRef ref, String jobId) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchJobDetails(jobId);
}

// Type-safe dependency injection
@riverpod
ApiService apiService(ApiServiceRef ref) {
  final config = ref.watch(appConfigProvider);
  final authToken = ref.watch(authTokenProvider);
  return ApiService(
    baseUrl: config.apiUrl,
    authToken: authToken,
  );
}
```

### 3. AutoDispose Patterns

**Automatic Resource Cleanup**:
```dart
// AutoDispose for temporary UI state
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}
// Generated provider automatically disposes when no longer used

// Manual AutoDispose control
@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  Future<User> build() async {
    // This provider will NOT auto-dispose
    return _fetchUserProfile();
  }

  Future<User> _fetchUserProfile() async {
    final api = ref.read(apiServiceProvider);
    return api.fetchCurrentUser();
  }
}

// Conditional auto-dispose
@riverpod
class JobCache extends _$JobCache {
  @override
  Map<String, Job> build() {
    // Keep cache alive for 5 minutes after last use
    final timer = Timer(const Duration(minutes: 5), () {
      ref.invalidateSelf();
    });

    ref.onDispose(() => timer.cancel());

    return {};
  }

  void addJob(Job job) {
    state = {...state, job.id: job};
  }
}
```

### 4. Provider Lifecycle Hooks

**Initialization and Cleanup**:
```dart
@riverpod
class DatabaseConnection extends _$DatabaseConnection {
  @override
  Future<Database> build() async {
    final db = await openDatabase('app.db');

    // Cleanup when provider is disposed
    ref.onDispose(() {
      db.close();
    });

    // Listen to other providers
    ref.listen(authStateProvider, (previous, next) {
      if (next.value == null) {
        // User logged out, clear database
        db.delete('user_data');
      }
    });

    return db;
  }
}

// Error recovery
@riverpod
class ResilientApiClient extends _$ResilientApiClient {
  @override
  Future<ApiClient> build() async {
    try {
      return await _createClient();
    } catch (e) {
      // Schedule retry after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        ref.invalidateSelf();
      });
      rethrow;
    }
  }

  Future<ApiClient> _createClient() async {
    final config = ref.watch(appConfigProvider);
    return ApiClient(baseUrl: config.apiUrl);
  }
}
```

### 5. Family Providers (Parameterized Providers)

**Type-Safe Parameters**:
```dart
// Single parameter
@riverpod
Future<Job> job(JobRef ref, String jobId) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchJob(jobId);
}

// Usage:
final job = ref.watch(jobProvider('job-123'));

// Multiple parameters (use custom class)
@freezed
class JobQueryParams with _$JobQueryParams {
  const factory JobQueryParams({
    required String category,
    required String location,
    int? maxResults,
  }) = _JobQueryParams;
}

@riverpod
Future<List<Job>> jobsByQuery(
  JobsByQueryRef ref,
  JobQueryParams params,
) async {
  final api = ref.watch(apiServiceProvider);
  return api.searchJobs(
    category: params.category,
    location: params.location,
    limit: params.maxResults ?? 20,
  );
}

// Usage:
final jobs = ref.watch(jobsByQueryProvider(
  JobQueryParams(
    category: 'construction',
    location: 'Denver',
    maxResults: 50,
  ),
));

// Cache management for family providers
@riverpod
class JobDetailsCache extends _$JobDetailsCache {
  @override
  Map<String, Job> build() => {};

  Future<Job> fetch(String jobId) async {
    if (state.containsKey(jobId)) {
      return state[jobId]!;
    }

    final job = await ref.read(jobProvider(jobId).future);
    state = {...state, jobId: job};
    return job;
  }

  void invalidate(String jobId) {
    ref.invalidate(jobProvider(jobId));
    state = Map.from(state)..remove(jobId);
  }
}
```

### 6. Scoped Providers (Provider Overrides)

**Testing and Environment-Specific Configuration**:
```dart
// Define provider
@riverpod
ApiService apiService(ApiServiceRef ref) {
  final config = ref.watch(appConfigProvider);
  return ApiService(baseUrl: config.apiUrl);
}

// Override for testing
void main() {
  testWidgets('Job list loads correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(
            MockApiService(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Test implementation
  });
}

// Override for specific subtree
Widget build(BuildContext context) {
  return ProviderScope(
    overrides: [
      // Override for this widget tree only
      themeProvider.overrideWithValue(ThemeData.dark()),
    ],
    child: AdminPanel(),
  );
}

// Dynamic override based on feature flags
@riverpod
PaymentProcessor paymentProcessor(PaymentProcessorRef ref) {
  final featureFlags = ref.watch(featureFlagsProvider);

  if (featureFlags.useNewPaymentGateway) {
    return NewPaymentProcessor();
  }
  return LegacyPaymentProcessor();
}
```

### 7. Combining Multiple Providers

**Dependency Composition**:
```dart
// Simple composition
@riverpod
String welcomeMessage(WelcomeMessageRef ref) {
  final user = ref.watch(currentUserProvider);
  final timeOfDay = ref.watch(timeOfDayProvider);

  return 'Good $timeOfDay, ${user.firstName}!';
}

// Complex composition with error handling
@riverpod
class JobApplicationState extends _$JobApplicationState {
  @override
  Future<ApplicationStatus> build(String jobId) async {
    // Watch multiple providers
    final user = ref.watch(currentUserProvider);
    final job = await ref.watch(jobProvider(jobId).future);
    final resume = await ref.watch(userResumeProvider.future);

    // Compose state from multiple sources
    return ApplicationStatus(
      jobId: jobId,
      jobTitle: job.title,
      applicantId: user.id,
      hasResume: resume != null,
      canApply: resume != null && !job.isExpired,
    );
  }

  Future<void> submitApplication() async {
    final status = state.value;
    if (status == null || !status.canApply) return;

    state = const AsyncValue.loading();
    try {
      final api = ref.read(apiServiceProvider);
      await api.submitJobApplication(status.jobId);
      state = AsyncValue.data(status.copyWith(submitted: true));

      // Invalidate related providers
      ref.invalidate(userApplicationsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

## Integration Points

### Flutter Widget Integration
```dart
class JobListingsPage extends ConsumerWidget {
  const JobListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobListingsProvider);

    return jobsAsync.when(
      data: (jobs) => ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) => JobCard(job: jobs[index]),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}

// StatefulWidget integration
class JobSearchPage extends ConsumerStatefulWidget {
  const JobSearchPage({super.key});

  @override
  ConsumerState<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends ConsumerState<JobSearchPage> {
  @override
  void initState() {
    super.initState();
    // Initialize state
    Future.microtask(() {
      ref.read(jobListingsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: /* ... */,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(jobListingsProvider.notifier).refresh();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### Navigation Integration
```dart
// Navigate with provider updates
void navigateToJobDetails(BuildContext context, String jobId) {
  // Pre-load job details
  ref.read(jobDetailsProvider(jobId));

  context.push('/jobs/$jobId');
}

// GoRouter integration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      // Route definitions
    ],
  );
});
```

## Best Practices

### 1. Provider Naming Conventions
```dart
// ✅ GOOD: Clear, descriptive names
@riverpod
Future<List<Job>> jobs(JobsRef ref) async { /* ... */ }

@riverpod
class JobListings extends _$JobListings { /* ... */ }

@riverpod
String userDisplayName(UserDisplayNameRef ref) { /* ... */ }

// ❌ BAD: Vague or redundant names
@riverpod
Future<List<Job>> provider1(Provider1Ref ref) async { /* ... */ }

@riverpod
class JobProvider extends _$JobProvider { /* ... */ }
```

### 2. Prefer Code Generation for New Code
```dart
// ✅ GOOD: Type-safe, maintainable
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

// ⚠️ ACCEPTABLE: Legacy code or simple cases
final counterProvider = StateProvider<int>((ref) => 0);
```

### 3. Use AutoDispose by Default
```dart
// ✅ GOOD: Auto-dispose for UI state
@riverpod
class SearchFilters extends _$SearchFilters {
  @override
  JobSearchFilters build() => const JobSearchFilters();

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }
}

// ✅ GOOD: Keep alive for app-level state
@Riverpod(keepAlive: true)
class AppConfig extends _$AppConfig {
  @override
  Future<Configuration> build() async {
    return loadConfiguration();
  }
}
```

### 4. Handle Async Errors Gracefully
```dart
@riverpod
class JobSubmission extends _$JobSubmission {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submit(JobApplication application) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      await api.submitApplication(application);

      // Refresh related providers
      ref.invalidate(userApplicationsProvider);
    });
  }
}

// UI layer
final submissionState = ref.watch(jobSubmissionProvider);
submissionState.whenOrNull(
  error: (error, stack) => showErrorDialog(context, error),
);
```

### 5. Avoid Provider Bloat
```dart
// ❌ BAD: Too many responsibilities
@riverpod
class AppState extends _$AppState {
  // User, jobs, settings, notifications, etc.
  // This provider does too much!
}

// ✅ GOOD: Single responsibility
@riverpod
class UserProfile extends _$UserProfile { /* ... */ }

@riverpod
class JobListings extends _$JobListings { /* ... */ }

@riverpod
class AppSettings extends _$AppSettings { /* ... */ }

@riverpod
class NotificationState extends _$NotificationState { /* ... */ }
```

### 6. Minimize Provider Rebuilds
```dart
// ✅ GOOD: Watch only what you need
@riverpod
String userFirstName(UserFirstNameRef ref) {
  final user = ref.watch(
    currentUserProvider.select((user) => user.firstName),
  );
  return user;
}

// ❌ BAD: Watching entire object when only need one field
@riverpod
String userFirstName2(UserFirstName2Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user.firstName; // Rebuilds for any user change!
}
```

### 7. Document Complex Providers
```dart
/// Manages job application state with optimistic updates.
///
/// This provider coordinates between the local application cache
/// and the remote API, handling:
/// - Optimistic UI updates
/// - Retry logic for failed submissions
/// - Cache invalidation after successful submission
///
/// Dependencies:
/// - [apiServiceProvider]: API client
/// - [jobCacheProvider]: Local job cache
/// - [userProfileProvider]: Current user information
@riverpod
class JobApplicationManager extends _$JobApplicationManager {
  @override
  AsyncValue<ApplicationState> build() {
    return const AsyncValue.data(ApplicationState.initial());
  }

  // Implementation...
}
```

## Common Patterns

### Loading State Management
```dart
@riverpod
class DataLoader extends _$DataLoader {
  @override
  AsyncValue<Data> build() => const AsyncValue.loading();

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }

  Future<Data> _fetchData() async {
    final api = ref.read(apiServiceProvider);
    return api.fetchData();
  }
}
```

### Pagination Pattern
```dart
@riverpod
class PaginatedJobs extends _$PaginatedJobs {
  @override
  AsyncValue<List<Job>> build() {
    return const AsyncValue.data([]);
  }

  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final previousState = state.value ?? [];
    state = AsyncValue.data(previousState); // Keep existing data

    try {
      final api = ref.read(apiServiceProvider);
      final newJobs = await api.fetchJobs(page: _currentPage);

      if (newJobs.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage++;
        state = AsyncValue.data([...previousState, ...newJobs]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### Debounced Search
```dart
@riverpod
class DebouncedSearch extends _$DebouncedSearch {
  @override
  AsyncValue<List<Job>> build() => const AsyncValue.data([]);

  Timer? _debounceTimer;

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      return api.searchJobs(query);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

## Migration Guide

### From Manual to Codegen
```dart
// Before (manual)
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
}

// After (codegen)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

// Update references in UI
// Before: ref.watch(counterProvider)
// After: ref.watch(counterProvider) // Same!

// Before: ref.read(counterProvider.notifier).increment()
// After: ref.read(counterProvider.notifier).increment() // Same!
```

## Performance Considerations

1. **Use `select` for Fine-Grained Reactivity**
   - Prevents unnecessary rebuilds when watching large objects

2. **Prefer `read` for One-Time Access**
   - Use `ref.read` in callbacks and event handlers
   - Use `ref.watch` only when you need reactive updates

3. **Implement Proper Caching**
   - Use family providers for parameterized caching
   - Invalidate caches strategically to balance freshness and performance

4. **Monitor Provider Count**
   - Keep provider hierarchy shallow when possible
   - Avoid creating providers inside build methods

## References
- [Riverpod Documentation](https://riverpod.dev)
- [Code Generation Guide](https://riverpod.dev/docs/concepts/about_code_generation)
- [Provider Types Reference](https://riverpod.dev/docs/providers/provider)
