# Hierarchical State Design

**Skill Name**: Hierarchical State Design
**Domain**: State Management, Architecture, System Design

## Category
**State Architecture & Dependency Management**

## Who Uses This
- Architecture Specialists designing state management systems
- Backend Integration Specialists managing service dependencies
- Flutter Developers implementing complex state hierarchies
- System Designers planning initialization sequences

## Description

Comprehensive guide to designing hierarchical state management systems with Riverpod. This skill covers multi-level provider dependencies, initialization order management, state hierarchy patterns, and the architectural principles for building scalable, maintainable state trees.

Hierarchical state design is critical for complex applications where state providers depend on each other in specific sequences. Understanding dependency levels, initialization order, and state composition patterns prevents circular dependencies, race conditions, and initialization failures.

## Key Techniques

### 1. State Hierarchy Levels

**Level-Based Architecture**:
```dart
// LEVEL 0: Foundation - No dependencies
// Configuration, constants, environment variables
@Riverpod(keepAlive: true)
class AppConfig extends _$AppConfig {
  @override
  Configuration build() {
    return Configuration(
      apiUrl: const String.fromEnvironment('API_URL'),
      environment: const String.fromEnvironment('ENV'),
      logLevel: const String.fromEnvironment('LOG_LEVEL'),
    );
  }
}

@Riverpod(keepAlive: true)
String appVersion(AppVersionRef ref) {
  return '1.0.0'; // Could load from package info
}

// LEVEL 1: Core Services - Depend only on Level 0
@Riverpod(keepAlive: true)
class Logger extends _$Logger {
  @override
  LogService build() {
    final config = ref.watch(appConfigProvider);
    return LogService(level: config.logLevel);
  }
}

@Riverpod(keepAlive: true)
class Analytics extends _$Analytics {
  @override
  AnalyticsService build() {
    final config = ref.watch(appConfigProvider);
    final logger = ref.watch(loggerProvider);

    return AnalyticsService(
      apiKey: config.analyticsKey,
      logger: logger,
    );
  }
}

// LEVEL 2: Infrastructure - Depend on Level 0-1
@Riverpod(keepAlive: true)
class Database extends _$Database {
  @override
  Future<DatabaseService> build() async {
    final config = ref.watch(appConfigProvider);
    final logger = ref.watch(loggerProvider);

    final db = DatabaseService(
      path: config.databasePath,
      logger: logger,
    );

    await db.initialize();
    return db;
  }
}

@Riverpod(keepAlive: true)
class ApiClient extends _$ApiClient {
  @override
  Future<ApiService> build() async {
    final config = ref.watch(appConfigProvider);
    final logger = ref.watch(loggerProvider);
    final analytics = ref.watch(analyticsProvider);

    return ApiService(
      baseUrl: config.apiUrl,
      logger: logger,
      analytics: analytics,
    );
  }
}

// LEVEL 3: Domain Services - Depend on Level 0-2
@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  @override
  Future<AuthenticationService> build() async {
    final api = await ref.watch(apiClientProvider.future);
    final db = await ref.watch(databaseProvider.future);
    final logger = ref.watch(loggerProvider);

    return AuthenticationService(
      apiClient: api,
      database: db,
      logger: logger,
    );
  }
}

@Riverpod(keepAlive: true)
class JobRepository extends _$JobRepository {
  @override
  Future<JobRepositoryService> build() async {
    final api = await ref.watch(apiClientProvider.future);
    final db = await ref.watch(databaseProvider.future);
    final logger = ref.watch(loggerProvider);

    return JobRepositoryService(
      apiClient: api,
      database: db,
      logger: logger,
    );
  }
}

// LEVEL 4: Application State - Depend on Level 0-3
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Future<User?> build() async {
    final authService = await ref.watch(authServiceProvider.future);
    return authService.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authService = await ref.read(authServiceProvider.future);
      final user = await authService.login(email, password);
      state = AsyncValue.data(user);

      // Trigger dependent providers to refresh
      ref.invalidate(userJobsProvider);
      ref.invalidate(userProfileProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

@riverpod
Future<List<Job>> userJobs(UserJobsRef ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  final jobRepo = await ref.watch(jobRepositoryProvider.future);
  return jobRepo.fetchUserJobs(user.id);
}
```

### 2. Initialization Order Management

**Sequential Initialization Pattern**:
```dart
/// Service lifecycle manager that ensures proper initialization order
@Riverpod(keepAlive: true)
class ServiceLifecycle extends _$ServiceLifecycle {
  @override
  Future<ServiceLifecycleState> build() async {
    final logger = ref.watch(loggerProvider);
    logger.info('Starting service initialization...');

    try {
      // PHASE 1: Core services (parallel)
      await Future.wait([
        ref.read(loggerProvider.future),
        ref.read(analyticsProvider.future),
      ]);
      logger.info('Phase 1 complete: Core services');

      // PHASE 2: Infrastructure (parallel)
      await Future.wait([
        ref.read(databaseProvider.future),
        ref.read(apiClientProvider.future),
      ]);
      logger.info('Phase 2 complete: Infrastructure');

      // PHASE 3: Domain services (parallel)
      await Future.wait([
        ref.read(authServiceProvider.future),
        ref.read(jobRepositoryProvider.future),
        ref.read(notificationServiceProvider.future),
      ]);
      logger.info('Phase 3 complete: Domain services');

      // PHASE 4: Application state
      await ref.read(currentUserProvider.future);
      logger.info('Phase 4 complete: Application state');

      return const ServiceLifecycleState.ready();
    } catch (e, stack) {
      logger.error('Service initialization failed', error: e, stackTrace: stack);
      return ServiceLifecycleState.error(e.toString());
    }
  }

  Future<void> restart() async {
    ref.invalidateSelf();
    await build();
  }
}

@freezed
class ServiceLifecycleState with _$ServiceLifecycleState {
  const factory ServiceLifecycleState.initializing() = _Initializing;
  const factory ServiceLifecycleState.ready() = _Ready;
  const factory ServiceLifecycleState.error(String message) = _Error;
}

// App initialization widget
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycle = ref.watch(serviceLifecycleProvider);

    return lifecycle.when(
      data: (state) => state.when(
        initializing: () => const SplashScreen(),
        ready: () => child,
        error: (message) => ErrorScreen(message: message),
      ),
      loading: () => const SplashScreen(),
      error: (error, stack) => ErrorScreen(
        message: 'Failed to initialize: $error',
      ),
    );
  }
}
```

### 3. Dependency Injection Patterns

**Service Composition**:
```dart
// Base interface
abstract class IJobService {
  Future<List<Job>> fetchJobs();
  Future<Job> fetchJobDetails(String id);
  Future<void> applyToJob(String jobId);
}

// Implementation with dependencies
class JobService implements IJobService {
  JobService({
    required this.apiClient,
    required this.database,
    required this.analytics,
    required this.logger,
  });

  final ApiService apiClient;
  final DatabaseService database;
  final AnalyticsService analytics;
  final LogService logger;

  @override
  Future<List<Job>> fetchJobs() async {
    logger.debug('Fetching jobs...');

    try {
      // Try cache first
      final cached = await database.getCachedJobs();
      if (cached.isNotEmpty && !_isCacheExpired(cached)) {
        logger.debug('Returning cached jobs');
        return cached;
      }

      // Fetch from API
      final jobs = await apiClient.getJobs();
      await database.cacheJobs(jobs);

      analytics.track('jobs_fetched', {'count': jobs.length});
      return jobs;
    } catch (e) {
      logger.error('Failed to fetch jobs', error: e);
      rethrow;
    }
  }

  bool _isCacheExpired(List<Job> cached) {
    // Implementation...
    return false;
  }

  @override
  Future<Job> fetchJobDetails(String id) async {
    // Implementation...
    throw UnimplementedError();
  }

  @override
  Future<void> applyToJob(String jobId) async {
    // Implementation...
    throw UnimplementedError();
  }
}

// Provider with dependency injection
@Riverpod(keepAlive: true)
Future<IJobService> jobService(JobServiceRef ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final db = await ref.watch(databaseProvider.future);
  final analytics = ref.watch(analyticsProvider);
  final logger = ref.watch(loggerProvider);

  return JobService(
    apiClient: api,
    database: db,
    analytics: analytics,
    logger: logger,
  );
}

// Mock implementation for testing
class MockJobService implements IJobService {
  @override
  Future<List<Job>> fetchJobs() async {
    return [
      Job(id: '1', title: 'Test Job'),
      Job(id: '2', title: 'Another Job'),
    ];
  }

  @override
  Future<Job> fetchJobDetails(String id) async {
    return Job(id: id, title: 'Test Job Details');
  }

  @override
  Future<void> applyToJob(String jobId) async {
    // Mock implementation
  }
}

// Test override
void main() {
  testWidgets('Job list displays correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobServiceProvider.overrideWithValue(MockJobService()),
        ],
        child: const MyApp(),
      ),
    );

    // Test assertions...
  });
}
```

### 4. Circular Dependency Prevention

**Strategies to Avoid Cycles**:
```dart
// ❌ BAD: Circular dependency
@riverpod
class ServiceA extends _$ServiceA {
  @override
  String build() {
    final b = ref.watch(serviceBProvider); // Depends on B
    return 'A-$b';
  }
}

@riverpod
class ServiceB extends _$ServiceB {
  @override
  String build() {
    final a = ref.watch(serviceAProvider); // Depends on A - CIRCULAR!
    return 'B-$a';
  }
}

// ✅ GOOD: Extract shared dependency
@riverpod
class SharedConfig extends _$SharedConfig {
  @override
  Configuration build() {
    return Configuration(/* ... */);
  }
}

@riverpod
class ServiceA2 extends _$ServiceA2 {
  @override
  String build() {
    final config = ref.watch(sharedConfigProvider);
    return 'A-${config.value}';
  }
}

@riverpod
class ServiceB2 extends _$ServiceB2 {
  @override
  String build() {
    final config = ref.watch(sharedConfigProvider);
    return 'B-${config.value}';
  }
}

// ✅ GOOD: Use callbacks for cross-service communication
@riverpod
class EventBus extends _$EventBus {
  @override
  EventBusService build() {
    return EventBusService();
  }
}

@riverpod
class ServiceA3 extends _$ServiceA3 {
  @override
  ServiceAImpl build() {
    final eventBus = ref.watch(eventBusProvider);

    final service = ServiceAImpl(
      onEvent: (event) {
        eventBus.publish(event); // Publish events instead of direct dependency
      },
    );

    return service;
  }
}

@riverpod
class ServiceB3 extends _$ServiceB3 {
  @override
  ServiceBImpl build() {
    final eventBus = ref.watch(eventBusProvider);

    final service = ServiceBImpl();

    // Subscribe to events from A
    eventBus.subscribe<ServiceAEvent>((event) {
      service.handleEvent(event);
    });

    return service;
  }
}
```

### 5. State Composition Patterns

**Combining Multiple State Sources**:
```dart
// Individual state providers
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<UserProfileData> build() async {
    final authService = await ref.watch(authServiceProvider.future);
    return authService.getProfile();
  }
}

@riverpod
class UserSettings extends _$UserSettings {
  @override
  Future<UserSettingsData> build() async {
    final db = await ref.watch(databaseProvider.future);
    return db.getUserSettings();
  }
}

@riverpod
class UserPreferences extends _$UserPreferences {
  @override
  Future<UserPreferencesData> build() async {
    final db = await ref.watch(databaseProvider.future);
    return db.getUserPreferences();
  }
}

// Composite state provider
@freezed
class CompleteUserState with _$CompleteUserState {
  const factory CompleteUserState({
    required UserProfileData profile,
    required UserSettingsData settings,
    required UserPreferencesData preferences,
  }) = _CompleteUserState;
}

@riverpod
Future<CompleteUserState> completeUserState(
  CompleteUserStateRef ref,
) async {
  // Fetch all user data in parallel
  final results = await Future.wait([
    ref.watch(userProfileProvider.future),
    ref.watch(userSettingsProvider.future),
    ref.watch(userPreferencesProvider.future),
  ]);

  return CompleteUserState(
    profile: results[0] as UserProfileData,
    settings: results[1] as UserSettingsData,
    preferences: results[2] as UserPreferencesData,
  );
}

// Derived computed state
@riverpod
bool userHasCompleteProfile(UserHasCompleteProfileRef ref) {
  final profile = ref.watch(userProfileProvider);

  return profile.maybeWhen(
    data: (data) =>
        data.firstName.isNotEmpty &&
        data.lastName.isNotEmpty &&
        data.email.isNotEmpty &&
        data.phone.isNotEmpty,
    orElse: () => false,
  );
}

@riverpod
String userDisplayName(UserDisplayNameRef ref) {
  final profile = ref.watch(userProfileProvider);

  return profile.maybeWhen(
    data: (data) => '${data.firstName} ${data.lastName}',
    orElse: () => 'Guest',
  );
}
```

### 6. Lazy Loading and Progressive Initialization

**Optimize Startup Performance**:
```dart
// Core services initialized immediately
@Riverpod(keepAlive: true)
class CoreServices extends _$CoreServices {
  @override
  Future<void> build() async {
    // Only initialize essential services
    await Future.wait([
      ref.read(loggerProvider.future),
      ref.read(analyticsProvider.future),
    ]);
  }
}

// Feature services loaded on demand (AutoDispose)
@riverpod
Future<FeatureService> featureService(
  FeatureServiceRef ref,
  String featureName,
) async {
  final logger = ref.watch(loggerProvider);
  logger.info('Loading feature: $featureName');

  final api = await ref.watch(apiClientProvider.future);
  return FeatureService(featureName: featureName, apiClient: api);
}

// Progressive initialization with priority levels
enum InitPriority { critical, high, medium, low }

@Riverpod(keepAlive: true)
class ProgressiveInitializer extends _$ProgressiveInitializer {
  @override
  Future<Map<InitPriority, bool>> build() async {
    final state = <InitPriority, bool>{};

    // CRITICAL: Must complete before app starts
    await _initializePriority(InitPriority.critical);
    state[InitPriority.critical] = true;

    // HIGH: Initialize in background, block user interactions
    Future.microtask(() async {
      await _initializePriority(InitPriority.high);
      state[InitPriority.high] = true;
      this.state = AsyncValue.data(state);
    });

    // MEDIUM: Initialize when idle
    Future.delayed(const Duration(seconds: 2), () async {
      await _initializePriority(InitPriority.medium);
      state[InitPriority.medium] = true;
      this.state = AsyncValue.data(state);
    });

    // LOW: Initialize after everything else
    Future.delayed(const Duration(seconds: 5), () async {
      await _initializePriority(InitPriority.low);
      state[InitPriority.low] = true;
      this.state = AsyncValue.data(state);
    });

    return state;
  }

  Future<void> _initializePriority(InitPriority priority) async {
    switch (priority) {
      case InitPriority.critical:
        await Future.wait([
          ref.read(databaseProvider.future),
          ref.read(authServiceProvider.future),
        ]);
        break;
      case InitPriority.high:
        await Future.wait([
          ref.read(jobRepositoryProvider.future),
          ref.read(notificationServiceProvider.future),
        ]);
        break;
      case InitPriority.medium:
        await Future.wait([
          ref.read(searchServiceProvider.future),
          ref.read(messagingServiceProvider.future),
        ]);
        break;
      case InitPriority.low:
        await Future.wait([
          ref.read(analyticsServiceProvider.future),
          ref.read(crashReportingProvider.future),
        ]);
        break;
    }
  }
}
```

### 7. State Invalidation Cascades

**Managing State Refresh Propagation**:
```dart
@riverpod
class UserAuthState extends _$UserAuthState {
  @override
  Future<User?> build() async {
    final authService = await ref.watch(authServiceProvider.future);
    return authService.getCurrentUser();
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      final authService = await ref.read(authServiceProvider.future);
      await authService.logout();

      state = const AsyncValue.data(null);

      // Cascade invalidation to all dependent providers
      _invalidateUserRelatedState();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _invalidateUserRelatedState() {
    // Invalidate user-specific data
    ref.invalidate(userProfileProvider);
    ref.invalidate(userSettingsProvider);
    ref.invalidate(userJobsProvider);
    ref.invalidate(userApplicationsProvider);
    ref.invalidate(userMessagesProvider);

    // Invalidate caches
    ref.invalidate(jobCacheProvider);
    ref.invalidate(searchCacheProvider);

    // Reset UI state
    ref.invalidate(selectedJobProvider);
    ref.invalidate(searchFiltersProvider);
  }
}

// Automatic invalidation via listeners
@riverpod
Future<List<Job>> userFavoriteJobs(UserFavoriteJobsRef ref) async {
  final user = await ref.watch(userAuthStateProvider.future);

  // Automatically invalidates when user changes
  if (user == null) return [];

  final jobRepo = await ref.watch(jobRepositoryProvider.future);
  return jobRepo.fetchFavoriteJobs(user.id);
}

// Manual invalidation control
@riverpod
class JobCache extends _$JobCache {
  @override
  Map<String, Job> build() {
    // Listen for auth changes
    ref.listen(userAuthStateProvider, (previous, next) {
      final wasLoggedIn = previous?.value != null;
      final isLoggedIn = next.value != null;

      // Clear cache on logout
      if (wasLoggedIn && !isLoggedIn) {
        state = {};
      }
    });

    return {};
  }

  void addJob(Job job) {
    state = {...state, job.id: job};
  }

  void removeJob(String jobId) {
    state = Map.from(state)..remove(jobId);
  }

  void clear() {
    state = {};
  }
}
```

## Integration Points

### Application Initialization
```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppInitializer(
      child: MaterialApp(
        home: const HomePage(),
      ),
    );
  }
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycle = ref.watch(serviceLifecycleProvider);

    return lifecycle.when(
      data: (state) => state.when(
        initializing: () => const SplashScreen(),
        ready: () => child,
        error: (message) => ErrorScreen(
          message: message,
          onRetry: () {
            ref.read(serviceLifecycleProvider.notifier).restart();
          },
        ),
      ),
      loading: () => const SplashScreen(),
      error: (error, stack) => ErrorScreen(
        message: 'Initialization failed: $error',
        onRetry: () {
          ref.invalidate(serviceLifecycleProvider);
        },
      ),
    );
  }
}
```

### Feature Modules
```dart
// Feature module with isolated state hierarchy
class JobsFeatureModule {
  static List<Override> getProviders() {
    return [
      // Override with feature-specific implementations
      jobRepositoryProvider.overrideWith((ref) async {
        final api = await ref.watch(apiClientProvider.future);
        return EnhancedJobRepository(apiClient: api);
      }),
    ];
  }
}

// Usage
Widget build(BuildContext context) {
  return ProviderScope(
    overrides: JobsFeatureModule.getProviders(),
    child: const JobsFeatureScreen(),
  );
}
```

## Best Practices

### 1. Define Clear Hierarchy Levels
```dart
// ✅ GOOD: Well-defined levels with clear dependencies
// Level 0: Config (no dependencies)
// Level 1: Core services (depend on Level 0)
// Level 2: Infrastructure (depend on Level 0-1)
// Level 3: Domain services (depend on Level 0-2)
// Level 4: Application state (depend on Level 0-3)

// ❌ BAD: Mixed levels, unclear dependencies
// Services at same level depending on each other
```

### 2. Use KeepAlive for Infrastructure
```dart
// ✅ GOOD: Infrastructure stays alive
@Riverpod(keepAlive: true)
class Database extends _$Database { /* ... */ }

// ❌ BAD: Infrastructure auto-disposes
@riverpod
class Database2 extends _$Database2 { /* ... */ }
// Could dispose and lose connection!
```

### 3. Initialize in Parallel When Possible
```dart
// ✅ GOOD: Parallel initialization within same level
await Future.wait([
  ref.read(serviceAProvider.future),
  ref.read(serviceBProvider.future),
  ref.read(serviceCProvider.future),
]);

// ❌ BAD: Sequential when unnecessary
await ref.read(serviceAProvider.future);
await ref.read(serviceBProvider.future);
await ref.read(serviceCProvider.future);
```

### 4. Handle Initialization Failures
```dart
// ✅ GOOD: Graceful failure handling
@Riverpod(keepAlive: true)
class CriticalService extends _$CriticalService {
  @override
  Future<ServiceImpl> build() async {
    try {
      return await _initializeService();
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.error('Critical service failed', error: e);

      // Don't silently fail - propagate error
      rethrow;
    }
  }
}

// ❌ BAD: Silent failures
@Riverpod(keepAlive: true)
class CriticalService2 extends _$CriticalService2 {
  @override
  Future<ServiceImpl?> build() async {
    try {
      return await _initializeService();
    } catch (e) {
      return null; // Swallowed error!
    }
  }
}
```

### 5. Document Dependencies
```dart
/// Job repository with comprehensive dependency management.
///
/// Dependencies (in initialization order):
/// - Level 0: [appConfigProvider] - API configuration
/// - Level 1: [loggerProvider] - Logging service
/// - Level 2: [apiClientProvider] - HTTP client
/// - Level 2: [databaseProvider] - Local cache
///
/// Dependents:
/// - [userJobsProvider] - User-specific job listings
/// - [jobSearchProvider] - Job search functionality
/// - [jobDetailsProvider] - Individual job details
@Riverpod(keepAlive: true)
Future<JobRepository> jobRepository(JobRepositoryRef ref) async {
  // Implementation...
}
```

### 6. Avoid Deep Hierarchies
```dart
// ✅ GOOD: Flat hierarchy (4-5 levels max)
// Level 0 → Level 1 → Level 2 → Level 3 → Level 4

// ❌ BAD: Deep hierarchy (hard to maintain)
// Level 0 → ... → Level 10
```

### 7. Use Dependency Injection Containers
```dart
// ✅ GOOD: Container pattern for complex DI
@Riverpod(keepAlive: true)
class ServiceContainer extends _$ServiceContainer {
  @override
  Future<DependencyContainer> build() async {
    final container = DependencyContainer();

    // Register services
    container.register<ILogger>(() => ref.read(loggerProvider));
    container.register<IDatabase>(() async =>
      await ref.read(databaseProvider.future));
    container.register<IApiClient>(() async =>
      await ref.read(apiClientProvider.future));

    await container.initialize();
    return container;
  }
}
```

## Common Patterns

### Service Locator Pattern
```dart
@Riverpod(keepAlive: true)
class ServiceLocator extends _$ServiceLocator {
  @override
  ServiceRegistry build() {
    final registry = ServiceRegistry();

    // Register all services
    registry.register(ref.read(loggerProvider));
    registry.register(ref.read(analyticsProvider));

    return registry;
  }

  T get<T>() {
    return state.get<T>();
  }
}
```

### Factory Pattern
```dart
@riverpod
JobService jobServiceFactory(
  JobServiceFactoryRef ref,
  JobServiceConfig config,
) {
  final api = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);

  return JobService(
    apiClient: api,
    database: db,
    config: config,
  );
}
```

### Repository Pattern
```dart
@Riverpod(keepAlive: true)
Future<IJobRepository> jobRepository(JobRepositoryRef ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final db = await ref.watch(databaseProvider.future);
  final cache = ref.watch(jobCacheProvider);

  return JobRepositoryImpl(
    apiClient: api,
    database: db,
    cache: cache,
  );
}
```

## Performance Considerations

1. **Minimize Provider Depth**: Keep hierarchies shallow (4-5 levels max)
2. **Parallel Initialization**: Initialize independent services concurrently
3. **Lazy Loading**: Use AutoDispose for feature-specific providers
4. **Cache Strategically**: Cache expensive computations at appropriate levels
5. **Monitor Rebuild Counts**: Use DevTools to identify unnecessary rebuilds

## Troubleshooting

### Circular Dependency Detection
```dart
// Add dependency tracking
@Riverpod(keepAlive: true)
class DependencyTracker extends _$DependencyTracker {
  @override
  Set<String> build() => {};

  void track(String providerName) {
    if (state.contains(providerName)) {
      throw CircularDependencyError(
        'Circular dependency detected: $providerName',
      );
    }
    state = {...state, providerName};
  }

  void untrack(String providerName) {
    state = Set.from(state)..remove(providerName);
  }
}
```

### Initialization Timeout Detection
```dart
@Riverpod(keepAlive: true)
class TimeoutAwareService extends _$TimeoutAwareService {
  @override
  Future<Service> build() async {
    return await _initializeWithTimeout();
  }

  Future<Service> _initializeWithTimeout() async {
    try {
      return await _initialize()
        .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      final logger = ref.read(loggerProvider);
      logger.error('Service initialization timeout');
      rethrow;
    }
  }

  Future<Service> _initialize() async {
    // Implementation...
    throw UnimplementedError();
  }
}
```

## References
- [Riverpod Documentation](https://riverpod.dev)
- [Dependency Injection Patterns](https://riverpod.dev/docs/concepts/providers)
- [Provider Lifecycle](https://riverpod.dev/docs/concepts/provider_observer)
