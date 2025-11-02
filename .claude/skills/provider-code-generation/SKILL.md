# Provider Code Generation

**Skill Name**: Provider Code Generation
**Domain**: State Management, Code Generation, Build Tools

## Category
**Development Tooling & Code Generation**

## Who Uses This
- Flutter Developers implementing Riverpod 2.0+
- Build Tool Specialists configuring code generation pipelines
- Architecture Specialists designing maintainable state systems
- Backend Integration Specialists working with type-safe providers

## Description

Comprehensive guide to Riverpod 2.0 code generation using `riverpod_generator` and `build_runner`. This skill covers AutoDispose patterns, Notifier implementations, code generation tools, configuration, and best practices for maintaining generated code in production applications.

Code generation with Riverpod eliminates boilerplate, improves type safety, and provides better developer experience through automatic provider creation, parameter handling, and lifecycle management.

## Key Techniques

### 1. Setup and Configuration

**pubspec.yaml Configuration**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  freezed_annotation: ^2.4.1

dev_dependencies:
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.0
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  custom_lint: ^0.5.0
  riverpod_lint: ^2.3.0

# Optional: Custom build configuration
build_runner:
  builders:
    riverpod_generator:
      options:
        # Generate .g.dart files instead of .riverpod.dart
        output_filename_pattern: "{name}.g.dart"
```

**analysis_options.yaml**:
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint

linter:
  rules:
    - prefer_const_constructors
    - avoid_print
    - prefer_final_fields
    - prefer_const_declarations

custom_lint:
  rules:
    # Riverpod-specific lints
    - provider_dependencies
    - scoped_providers_should_specify_dependencies
    - unsupported_provider_value
```

**Build Commands**:
```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean build (remove all generated files and rebuild)
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Generate with verbose output
flutter pub run build_runner build -v --delete-conflicting-outputs
```

### 2. Basic Provider Generation

**Simple Provider**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_provider.g.dart';

/// Application configuration provider
///
/// This provider supplies immutable configuration data
/// loaded from environment or config files.
@riverpod
AppConfig appConfig(AppConfigRef ref) {
  return const AppConfig(
    apiUrl: String.fromEnvironment('API_URL', defaultValue: 'https://api.example.com'),
    environment: String.fromEnvironment('ENV', defaultValue: 'production'),
    version: '1.0.0',
  );
}

// GENERATED CODE:
// final appConfigProvider = AutoDisposeProvider<AppConfig>((ref) { ... });
```

**Provider with KeepAlive**:
```dart
/// Logger service provider that persists for app lifetime
///
/// Uses keepAlive to prevent disposal during app lifecycle.
@Riverpod(keepAlive: true)
LogService logger(LoggerRef ref) {
  final config = ref.watch(appConfigProvider);
  return LogService(level: config.logLevel);
}

// GENERATED CODE:
// final loggerProvider = Provider<LogService>((ref) { ... });
```

**Provider with Parameters (Family)**:
```dart
/// Fetches job details by ID
///
/// This family provider creates a separate provider instance
/// for each unique job ID.
@riverpod
Future<Job> jobDetails(JobDetailsRef ref, String jobId) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchJobDetails(jobId);
}

// GENERATED CODE:
// final jobDetailsProvider = AutoDisposeFutureProviderFamily<Job, String>(...);

// Usage:
final job = ref.watch(jobDetailsProvider('job-123'));
```

**Provider with Multiple Parameters**:
```dart
/// Searches jobs with multiple filter criteria
///
/// Uses a custom parameter class for type-safe multi-parameter family.
@riverpod
Future<List<Job>> jobSearch(
  JobSearchRef ref,
  String query,
  JobCategory category,
) async {
  final api = ref.watch(apiServiceProvider);
  return api.searchJobs(query: query, category: category);
}

// GENERATED CODE:
// AutoDisposeFutureProvider with custom family key

// Usage:
final jobs = ref.watch(jobSearchProvider('plumber', JobCategory.construction));
```

### 3. Notifier Pattern (Stateful Providers)

**Basic Notifier**:
```dart
/// Counter state with increment/decrement operations
@riverpod
class Counter extends _$Counter {
  @override
  int build() {
    // Initial state
    return 0;
  }

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }

  void reset() {
    state = 0;
  }
}

// GENERATED CODE:
// class _$Counter extends AutoDisposeNotifier<int> { ... }
// final counterProvider = AutoDisposeNotifierProvider<Counter, int>(...);

// Usage:
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).increment();
```

**Async Notifier**:
```dart
/// Authentication state manager with async operations
@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    // Load initial state asynchronously
    final authService = await ref.watch(authServiceProvider.future);
    return authService.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final user = await authService.login(email, password);

      // Invalidate dependent providers
      ref.invalidate(userProfileProvider);
      ref.invalidate(userJobsProvider);

      return user;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final authService = await ref.read(authServiceProvider.future);
      await authService.logout();

      state = const AsyncValue.data(null);

      // Clear user-related state
      ref.invalidate(userProfileProvider);
      ref.invalidate(userJobsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshUser() async {
    final current = state.value;
    if (current == null) return;

    try {
      final authService = await ref.read(authServiceProvider.future);
      final updated = await authService.refreshUser(current.id);
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// GENERATED CODE:
// class _$AuthState extends AutoDisposeAsyncNotifier<User?> { ... }
// final authStateProvider = AutoDisposeAsyncNotifierProvider<AuthState, User?>(...);

// Usage:
final authAsync = ref.watch(authStateProvider);
authAsync.when(
  data: (user) => user != null ? HomePage() : LoginPage(),
  loading: () => LoadingScreen(),
  error: (err, stack) => ErrorScreen(error: err),
);
```

**Family Notifier**:
```dart
/// Job details manager with per-job state
@riverpod
class JobDetailsState extends _$JobDetailsState {
  @override
  Future<Job> build(String jobId) async {
    // Build method receives family parameter
    final api = ref.watch(apiServiceProvider);
    return api.fetchJobDetails(jobId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      return api.fetchJobDetails(arg); // 'arg' is the family parameter
    });
  }

  Future<void> applyToJob() async {
    final currentJob = state.value;
    if (currentJob == null) return;

    try {
      final api = ref.read(apiServiceProvider);
      await api.applyToJob(currentJob.id);

      // Update local state
      state = AsyncValue.data(
        currentJob.copyWith(hasApplied: true),
      );

      // Invalidate related providers
      ref.invalidate(userApplicationsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// GENERATED CODE:
// class _$JobDetailsState extends AutoDisposeAsyncNotifierFamily<Job, String> { ... }
// final jobDetailsStateProvider =
//   AutoDisposeAsyncNotifierProviderFamily<JobDetailsState, Job, String>(...);

// Usage:
final jobAsync = ref.watch(jobDetailsStateProvider('job-123'));
ref.read(jobDetailsStateProvider('job-123').notifier).refresh();
```

**KeepAlive Notifier**:
```dart
/// App settings that persist throughout app lifetime
@Riverpod(keepAlive: true)
class AppSettings extends _$AppSettings {
  @override
  Future<SettingsData> build() async {
    final db = await ref.watch(databaseProvider.future);
    return db.getSettings();
  }

  Future<void> updateTheme(ThemeMode theme) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(theme: theme);
    state = AsyncValue.data(updated);

    final db = await ref.read(databaseProvider.future);
    await db.saveSettings(updated);
  }

  Future<void> updateLocale(Locale locale) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(locale: locale);
    state = AsyncValue.data(updated);

    final db = await ref.read(databaseProvider.future);
    await db.saveSettings(updated);
  }
}

// GENERATED CODE:
// class _$AppSettings extends AsyncNotifier<SettingsData> { ... }
// final appSettingsProvider = AsyncNotifierProvider<AppSettings, SettingsData>(...);
```

### 4. AutoDispose Patterns

**Default AutoDispose**:
```dart
// AutoDispose by default (recommended for UI state)
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

// Automatically disposes when no longer watched
// Perfect for temporary UI state
```

**Manual KeepAlive Control**:
```dart
@riverpod
class SmartCache extends _$SmartCache {
  @override
  Map<String, dynamic> build() {
    // Keep alive for 5 minutes after last use
    final link = ref.keepAlive();

    Timer(const Duration(minutes: 5), () {
      link.close(); // Allow disposal after timeout
    });

    return {};
  }

  void add(String key, dynamic value) {
    state = {...state, key: value};
  }
}

// Usage:
// Provider stays alive while watched
// After unwatched, timer starts 5-minute countdown
// If rewatched before timer expires, timer restarts
```

**Conditional KeepAlive**:
```dart
@riverpod
class ConditionalCache extends _$ConditionalCache {
  @override
  List<Job> build() {
    // Keep alive while cache is not empty
    ref.listenSelf((previous, next) {
      if (next.isEmpty) {
        // Cache empty, allow disposal
        ref.invalidateSelf();
      }
    });

    return [];
  }

  void addJobs(List<Job> jobs) {
    state = [...state, ...jobs];
  }

  void clear() {
    state = [];
    // Will trigger disposal via listenSelf
  }
}
```

**Resource Cleanup with AutoDispose**:
```dart
@riverpod
class WebSocketConnection extends _$WebSocketConnection {
  @override
  Future<WebSocket> build() async {
    final ws = await WebSocket.connect('wss://api.example.com');

    // Cleanup when provider disposes
    ref.onDispose(() {
      ws.close();
    });

    return ws;
  }

  void sendMessage(String message) {
    final ws = state.value;
    if (ws != null) {
      ws.add(message);
    }
  }
}

// WebSocket automatically closes when provider disposes
```

### 5. Stream and Future Providers

**Stream Provider**:
```dart
/// Real-time message stream
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String chatId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
    .collection('chats/$chatId/messages')
    .orderBy('timestamp', descending: true)
    .snapshots()
    .map((snapshot) =>
      snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList(),
    );
}

// GENERATED CODE:
// final messagesProvider = AutoDisposeStreamProviderFamily<List<Message>, String>(...);

// Usage:
final messagesAsync = ref.watch(messagesProvider('chat-123'));
messagesAsync.when(
  data: (messages) => MessageList(messages: messages),
  loading: () => LoadingIndicator(),
  error: (err, stack) => ErrorView(error: err),
);
```

**Stream Notifier (StreamNotifier)**:
```dart
/// Location tracking with stream-based state
@riverpod
class LocationTracker extends _$LocationTracker {
  @override
  Stream<Position> build() {
    final locationService = ref.watch(locationServiceProvider);
    return locationService.positionStream;
  }

  void pauseTracking() {
    // Can manipulate stream behavior
    ref.invalidateSelf();
  }

  void resumeTracking() {
    ref.invalidateSelf();
  }
}

// GENERATED CODE:
// class _$LocationTracker extends AutoDisposeStreamNotifier<Position> { ... }
// final locationTrackerProvider =
//   AutoDisposeStreamNotifierProvider<LocationTracker, Position>(...);
```

**Future Provider**:
```dart
/// One-time async data fetch
@riverpod
Future<List<Job>> availableJobs(AvailableJobsRef ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchJobs();
}

// GENERATED CODE:
// final availableJobsProvider = AutoDisposeFutureProvider<List<Job>>(...);

// Usage:
final jobsAsync = ref.watch(availableJobsProvider);
jobsAsync.when(
  data: (jobs) => JobList(jobs: jobs),
  loading: () => LoadingIndicator(),
  error: (err, stack) => ErrorView(error: err),
);
```

### 6. Dependency Injection Patterns

**Service Provider**:
```dart
/// API service with automatic dependency injection
@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(loggerProvider);
  final authToken = ref.watch(authTokenProvider);

  return ApiService(
    baseUrl: config.apiUrl,
    logger: logger,
    authToken: authToken,
  );
}
```

**Repository Pattern**:
```dart
/// Job repository with injected dependencies
@Riverpod(keepAlive: true)
Future<JobRepository> jobRepository(JobRepositoryRef ref) async {
  final api = ref.watch(apiServiceProvider);
  final db = await ref.watch(databaseProvider.future);
  final cache = ref.watch(jobCacheProvider);
  final logger = ref.watch(loggerProvider);

  return JobRepositoryImpl(
    apiClient: api,
    database: db,
    cache: cache,
    logger: logger,
  );
}
```

**Interface-Based Injection**:
```dart
// Define interface
abstract class IAuthService {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
}

// Implementation
class AuthServiceImpl implements IAuthService {
  AuthServiceImpl({required this.apiClient});

  final ApiService apiClient;

  @override
  Future<User> login(String email, String password) async {
    // Implementation...
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    // Implementation...
  }

  @override
  Future<User?> getCurrentUser() async {
    // Implementation...
    throw UnimplementedError();
  }
}

// Provider returns interface
@Riverpod(keepAlive: true)
Future<IAuthService> authService(AuthServiceRef ref) async {
  final api = ref.watch(apiServiceProvider);
  return AuthServiceImpl(apiClient: api);
}

// Easy to mock for testing
class MockAuthService implements IAuthService {
  @override
  Future<User> login(String email, String password) async {
    return User(id: '1', email: email);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User?> getCurrentUser() async {
    return User(id: '1', email: 'test@example.com');
  }
}
```

### 7. Provider Lifecycle Hooks

**Initialization and Cleanup**:
```dart
@riverpod
class ManagedResource extends _$ManagedResource {
  @override
  Future<ResourceHandle> build() async {
    final logger = ref.watch(loggerProvider);
    logger.info('Initializing resource...');

    final resource = await _acquireResource();

    // Cleanup callback
    ref.onDispose(() {
      logger.info('Disposing resource...');
      resource.release();
    });

    // Listen to dependencies
    ref.listen(configProvider, (previous, next) {
      logger.info('Config changed, reloading resource...');
      ref.invalidateSelf();
    });

    return resource;
  }

  Future<ResourceHandle> _acquireResource() async {
    // Simulate resource acquisition
    await Future.delayed(const Duration(seconds: 1));
    return ResourceHandle();
  }
}

class ResourceHandle {
  void release() {
    // Cleanup logic
  }
}
```

**State Listeners**:
```dart
@riverpod
class NotificationManager extends _$NotificationManager {
  @override
  Future<void> build() async {
    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, next) {
      final wasLoggedIn = previous?.value != null;
      final isLoggedIn = next.value != null;

      if (!wasLoggedIn && isLoggedIn) {
        _showWelcomeNotification();
      } else if (wasLoggedIn && !isLoggedIn) {
        _clearNotifications();
      }
    });

    // Listen to job updates
    ref.listen(jobUpdatesProvider, (previous, next) {
      next.whenData((jobs) {
        _notifyNewJobs(jobs);
      });
    });
  }

  void _showWelcomeNotification() {
    // Implementation...
  }

  void _clearNotifications() {
    // Implementation...
  }

  void _notifyNewJobs(List<Job> jobs) {
    // Implementation...
  }
}
```

### 8. Testing with Generated Providers

**Unit Testing**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('Counter increments correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state
    expect(container.read(counterProvider), 0);

    // Increment
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);

    // Decrement
    container.read(counterProvider.notifier).decrement();
    expect(container.read(counterProvider), 0);
  });

  test('AuthState handles login correctly', () async {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(
          MockAuthService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Login
    await container.read(authStateProvider.notifier).login(
      'test@example.com',
      'password',
    );

    // Verify logged in
    final user = container.read(authStateProvider).value;
    expect(user, isNotNull);
    expect(user?.email, 'test@example.com');
  });
}
```

**Widget Testing**:
```dart
testWidgets('JobList displays jobs correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        availableJobsProvider.overrideWith((ref) async {
          return [
            Job(id: '1', title: 'Test Job 1'),
            Job(id: '2', title: 'Test Job 2'),
          ];
        }),
      ],
      child: const MaterialApp(
        home: JobListPage(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Test Job 1'), findsOneWidget);
  expect(find.text('Test Job 2'), findsOneWidget);
});
```

**Integration Testing**:
```dart
void main() {
  testWidgets('Complete job application flow', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: JobsPage()),
      ),
    );

    // Navigate to job details
    await tester.tap(find.text('Plumber Position'));
    await tester.pumpAndSettle();

    // Apply to job
    await tester.tap(find.text('Apply Now'));
    await tester.pumpAndSettle();

    // Verify application submitted
    final applications = container.read(userApplicationsProvider);
    expect(applications.value, hasLength(1));
  });
}
```

## Integration Points

### Build Pipeline Integration
```dart
// .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test
```

### IDE Integration
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Runner (watch)",
      "type": "shell",
      "command": "flutter pub run build_runner watch --delete-conflicting-outputs",
      "problemMatcher": [],
      "isBackground": true
    },
    {
      "label": "Build Runner (build)",
      "type": "shell",
      "command": "flutter pub run build_runner build --delete-conflicting-outputs",
      "problemMatcher": []
    }
  ]
}
```

## Best Practices

### 1. Always Use Part Directive
```dart
// ✅ GOOD
part 'my_provider.g.dart';

// ❌ BAD
// Missing part directive - code generation will fail
```

### 2. Use Descriptive Names
```dart
// ✅ GOOD
@riverpod
Future<List<Job>> availableJobs(AvailableJobsRef ref) async { /* ... */ }

// ❌ BAD
@riverpod
Future<List<Job>> jobs1(Jobs1Ref ref) async { /* ... */ }
```

### 3. Prefer Codegen Over Manual
```dart
// ✅ GOOD: Type-safe, maintainable
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  void increment() => state++;
}

// ⚠️ ACCEPTABLE: Only for legacy code
final counterProvider = StateProvider<int>((ref) => 0);
```

### 4. Document Generated Providers
```dart
/// Fetches and caches job listings from the API.
///
/// This provider automatically:
/// - Fetches jobs from the API on first access
/// - Caches results for improved performance
/// - Auto-disposes when no longer watched
///
/// Dependencies:
/// - [apiServiceProvider]: For API calls
/// - [jobCacheProvider]: For local caching
@riverpod
Future<List<Job>> availableJobs(AvailableJobsRef ref) async {
  final api = ref.watch(apiServiceProvider);
  final cache = ref.watch(jobCacheProvider);

  // Check cache first
  final cached = cache.getJobs();
  if (cached != null) return cached;

  // Fetch from API
  final jobs = await api.fetchJobs();
  cache.setJobs(jobs);

  return jobs;
}
```

### 5. Use KeepAlive for Infrastructure
```dart
// ✅ GOOD: Infrastructure services stay alive
@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) { /* ... */ }

// ❌ BAD: Service could dispose unexpectedly
@riverpod
ApiService apiService2(ApiService2Ref ref) { /* ... */ }
```

### 6. Handle Async Errors Properly
```dart
// ✅ GOOD: Proper error handling
@riverpod
class DataLoader extends _$DataLoader {
  @override
  Future<Data> build() async {
    return _loadData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadData());
  }

  Future<Data> _loadData() async {
    final api = ref.read(apiServiceProvider);
    return api.fetchData();
  }
}

// ❌ BAD: Unhandled errors
@riverpod
Future<Data> dataLoader2(DataLoader2Ref ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchData(); // Could throw!
}
```

### 7. Commit Generated Files
```dart
// .gitignore
# ❌ BAD: Don't ignore generated files
*.g.dart
*.freezed.dart

# ✅ GOOD: Commit generated files for:
# - Faster CI/CD (no need to regenerate)
# - Code review visibility
# - Reduced build times
```

## Common Patterns

### Pagination with Notifier
```dart
@riverpod
class PaginatedJobs extends _$PaginatedJobs {
  @override
  AsyncValue<List<Job>> build() {
    _loadFirstPage();
    return const AsyncValue.loading();
  }

  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> _loadFirstPage() async {
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiServiceProvider);
      final jobs = await api.fetchJobs(page: 1);
      _hasMore = jobs.isNotEmpty;
      return jobs;
    });
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final previous = state.value ?? [];

    try {
      _currentPage++;
      final api = ref.read(apiServiceProvider);
      final newJobs = await api.fetchJobs(page: _currentPage);

      if (newJobs.isEmpty) {
        _hasMore = false;
      } else {
        state = AsyncValue.data([...previous, ...newJobs]);
      }
    } catch (e, stack) {
      _currentPage--;
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### Debounced Search
```dart
@riverpod
class SearchResults extends _$SearchResults {
  @override
  AsyncValue<List<Job>> build() {
    return const AsyncValue.data([]);
  }

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

## Performance Considerations

1. **Run in Watch Mode**: Use `build_runner watch` during development
2. **Incremental Builds**: Only regenerates changed files
3. **Parallel Generation**: Multiple files generate concurrently
4. **Cache Utilization**: Build runner caches analysis results
5. **CI/CD Optimization**: Commit generated files to skip regeneration

## Troubleshooting

### Common Errors

**Missing Part Directive**:
```dart
// Error: Could not find part file
// Fix: Add part directive
part 'my_provider.g.dart';
```

**Conflicting Outputs**:
```bash
# Error: Conflicting outputs
# Fix: Use --delete-conflicting-outputs flag
flutter pub run build_runner build --delete-conflicting-outputs
```

**Type Inference Issues**:
```dart
// Error: Cannot infer type
// Fix: Explicitly specify return type
@riverpod
Future<List<Job>> jobs(JobsRef ref) async { // Explicit type
  return fetchJobs();
}
```

## References
- [Riverpod Generator Documentation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Build Runner Documentation](https://pub.dev/packages/build_runner)
- [Riverpod Lint Rules](https://pub.dev/packages/riverpod_lint)
