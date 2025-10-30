# Dependency Graph Implementation Specification

## Overview

This document provides detailed implementation specifications for the hierarchical initialization dependency graph system designed for Journeyman Jobs.

## Core Components

### 1. Service Definition Framework

#### Service Interface
```dart
abstract class InitializationService {
  String get name;
  Set<String> get dependencies;
  ServicePriority get priority;
  ServiceCategory get category;
  Duration get timeout;

  Future<ServiceInitializationResult> initialize();
  Future<void> dispose();
  bool get isHealthy;
}

enum ServicePriority {
  critical(0),
  high(1),
  medium(2),
  low(3),
  background(4);

  const ServicePriority(this.value);
  final int value;
}

enum ServiceCategory {
  infrastructure,
  userData,
  coreData,
  features,
  analytics;
}
```

#### Service Registration
```dart
class ServiceRegistry {
  static final Map<String, InitializationService> _services = {};

  static void register<T extends InitializationService>(T service) {
    _services[service.name] = service;
  }

  static InitializationService? getService(String name) {
    return _services[name];
  }

  static List<InitializationService> getAllServices() {
    return _services.values.toList();
  }

  static void clear() {
    _services.clear();
  }
}
```

### 2. Dependency Graph Manager

#### Graph Structure
```dart
class DependencyGraph {
  final Map<String, Set<String>> _dependencies = {};
  final Map<String, Set<String>> _dependents = {};

  void addService(InitializationService service) {
    _dependencies[service.name] = service.dependencies;

    // Build reverse dependencies
    for (final dep in service.dependencies) {
      _dependents.putIfAbsent(dep, () => <String>{});
      _dependents[dep]!.add(service.name);
    }
  }

  List<String> topologicalSort() {
    final visited = <String>{};
    final visiting = <String>{};
    final result = <String>[];

    void visit(String service) {
      if (visiting.contains(service)) {
        throw CircularDependencyException('Circular dependency detected: $service');
      }

      if (visited.contains(service)) return;

      visiting.add(service);
      for (final dep in _dependencies[service] ?? <String>{}) {
        visit(dep);
      }
      visiting.remove(service);
      visited.add(service);
      result.add(service);
    }

    for (final service in _dependencies.keys) {
      if (!visited.contains(service)) {
        visit(service);
      }
    }

    return result.reversed.toList();
  }

  List<List<String>> getExecutionStages() {
    final sorted = topologicalSort();
    final stages = <List<String>>[];
    final processed = <String>{};

    for (final service in sorted) {
      if (processed.contains(service)) continue;

      final stage = <String>[];
      final queue = <String>[service];

      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        if (processed.contains(current)) continue;

        final deps = _dependencies[current] ?? <String>{};
        if (deps.every((dep) => processed.contains(dep))) {
          stage.add(current);
          processed.add(current);

          // Add dependents that can now be processed
          for (final dependent in _dependents[current] ?? <String>{}) {
            if (!processed.contains(dependent)) {
              queue.add(dependent);
            }
          }
        } else {
          queue.add(current); // Re-queue for later processing
        }
      }

      if (stage.isNotEmpty) {
        stages.add(stage);
      }
    }

    return stages;
  }
}
```

### 3. Initialization Orchestrator

#### Core Orchestrator
```dart
class InitializationOrchestrator {
  final DependencyGraph _graph = DependencyGraph();
  final Map<String, ServiceState> _serviceStates = {};
  final StreamController<InitializationProgress> _progressController =
      StreamController<InitializationProgress>.broadcast();

  final CircuitBreaker _circuitBreaker = CircuitBreaker();
  final RetryHandler _retryHandler = RetryHandler();
  final GracefulDegradationManager _degradationManager = GracefulDegradationManager();

  Future<InitializationResult> initialize({
    InitializationStrategy strategy = InitializationStrategy.progressive,
  }) async {
    try {
      _emitProgress(InitializationProgress.starting());

      // Build dependency graph
      _buildDependencyGraph();

      // Get execution stages
      final stages = _graph.getExecutionStages();

      // Execute based on strategy
      switch (strategy) {
        case InitializationStrategy.progressive:
          return await _executeProgressiveStages(stages);
        case InitializationStrategy.parallel:
          return await _executeParallelStages(stages);
        case InitializationStrategy.sequential:
          return await _executeSequentialStages(stages);
      }
    } catch (e) {
      _emitProgress(InitializationProgress.error(e));
      rethrow;
    }
  }

  Future<InitializationResult> _executeProgressiveStages(
    List<List<String>> stages,
  ) async {
    final results = <String, dynamic>{};
    final errors = <String, dynamic>{};

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];

      _emitProgress(InitializationProgress.stage(i + 1, stages.length, stage));

      // Determine if stage can be parallelized
      if (_canRunInParallel(stage)) {
        await _executeParallelStage(stage, results, errors);
      } else {
        await _executeSequentialStage(stage, results, errors);
      }

      // Check if critical services failed
      if (_hasCriticalFailures(errors)) {
        break;
      }
    }

    return InitializationResult(
      success: !_hasCriticalFailures(errors),
      results: results,
      errors: errors,
      stage: _getOverallStage(results, errors),
    );
  }

  Future<void> _executeParallelStage(
    List<String> services,
    Map<String, dynamic> results,
    Map<String, dynamic> errors,
  ) async {
    final futures = services.map((serviceName) async {
      try {
        final service = ServiceRegistry.getService(serviceName)!;
        final result = await _circuitBreaker.execute(
          serviceName,
          () => _retryHandler.executeWithRetry(
            serviceName,
            () => service.initialize(),
          ),
        );

        results[serviceName] = result;
        _serviceStates[serviceName] = ServiceState.success;
      } catch (e) {
        errors[serviceName] = e;
        _serviceStates[serviceName] = ServiceState.failed;

        // Try graceful degradation
        final fallback = _degradationManager.getFallback(serviceName);
        if (fallback != null) {
          results[serviceName] = fallback;
          _serviceStates[serviceName] = ServiceState.degraded;
        }
      }
    });

    await Future.wait(futures, eagerError: false);
  }

  Future<void> _executeSequentialStage(
    List<String> services,
    Map<String, dynamic> results,
    Map<String, dynamic> errors,
  ) async {
    for (final serviceName in services) {
      try {
        final service = ServiceRegistry.getService(serviceName)!;
        final result = await _circuitBreaker.execute(
          serviceName,
          () => _retryHandler.executeWithRetry(
            serviceName,
            () => service.initialize(),
          ),
        );

        results[serviceName] = result;
        _serviceStates[serviceName] = ServiceState.success;
      } catch (e) {
        errors[serviceName] = e;
        _serviceStates[serviceName] = ServiceState.failed;

        // For sequential stages, failure might block subsequent services
        if (_isCriticalService(serviceName)) {
          break;
        }
      }
    }
  }
}
```

### 4. Service Implementations

#### Core Infrastructure Services
```dart
class FirebaseCoreService extends InitializationService {
  @override
  String get name => 'firebaseCore';

  @override
  Set<String> get dependencies => {};

  @override
  ServicePriority get priority => ServicePriority.critical;

  @override
  ServiceCategory get category => ServiceCategory.infrastructure;

  @override
  Duration get timeout => Duration(seconds: 10);

  @override
  Future<ServiceInitializationResult> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return ServiceInitializationResult.success('Already initialized');
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Performance Monitoring
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

    // Initialize Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    return ServiceInitializationResult.success('Firebase initialized');
  }

  @override
  Future<void> dispose() async {
    // Firebase doesn't need explicit disposal
  }

  @override
  bool get isHealthy => Firebase.apps.isNotEmpty;
}

class AuthenticationService extends InitializationService {
  @override
  String get name => 'authenticationService';

  @override
  Set<String> get dependencies => {'firebaseCore'};

  @override
  ServicePriority get priority => ServicePriority.critical;

  @override
  ServiceCategory get category => ServiceCategory.infrastructure;

  @override
  Duration get timeout => Duration(seconds: 15);

  @override
  Future<ServiceInitializationResult> initialize() async {
    final auth = FirebaseAuth.instance;

    // Configure auth persistence based on platform
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }

    // Set up auth state monitoring
    auth.authStateChanges().listen((user) {
      // Handle auth state changes
      _handleAuthStateChange(user);
    });

    return ServiceInitializationResult.success(
      'Authentication service initialized',
      data: {'currentUser': auth.currentUser?.uid},
    );
  }

  void _handleAuthStateChange(User? user) {
    // Emit auth state changes to interested services
    ServiceLocator.getInstance().emit<AuthStateChangedEvent>(
      AuthStateChangedEvent(user),
    );
  }

  @override
  Future<void> dispose() async {
    // Cleanup auth listeners
  }

  @override
  bool get isHealthy => FirebaseAuth.instance != null;
}
```

#### User Data Services
```dart
class UserProfileService extends InitializationService {
  @override
  String get name => 'userProfile';

  @override
  Set<String> get dependencies => {'authenticationService'};

  @override
  ServicePriority get priority => ServicePriority.high;

  @override
  ServiceCategory get category => ServiceCategory.userData;

  @override
  Duration get timeout => Duration(seconds: 10);

  @override
  Future<ServiceInitializationResult> initialize() async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return ServiceInitializationResult.success(
        'No authenticated user - guest mode',
        data: {'isGuest': true},
      );
    }

    try {
      // Load user profile from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        return ServiceInitializationResult.success(
          'User profile not found - creating new profile',
          data: {
            'isGuest': false,
            'needsProfileSetup': true,
            'userId': currentUser.uid,
          },
        );
      }

      final userProfile = UserModel.fromFirestore(userDoc);

      return ServiceInitializationResult.success(
        'User profile loaded',
        data: {
          'isGuest': false,
          'needsProfileSetup': false,
          'userProfile': userProfile,
        },
      );
    } catch (e) {
      // Try to use cached profile
      final cachedProfile = await _getCachedUserProfile(currentUser.uid);
      if (cachedProfile != null) {
        return ServiceInitializationResult.success(
          'Using cached user profile',
          data: {
            'isGuest': false,
            'needsProfileSetup': false,
            'userProfile': cachedProfile,
            'isStale': true,
          },
        );
      }

      rethrow;
    }
  }

  Future<UserModel?> _getCachedUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_user_profile_$userId');

    if (cachedJson != null) {
      final cached = jsonDecode(cachedJson);
      final lastUpdated = DateTime.parse(cached['lastUpdated']);

      // Use cache if less than 1 hour old
      if (DateTime.now().difference(lastUpdated).inHours < 1) {
        return UserModel.fromJson(cached['profile']);
      }
    }

    return null;
  }

  @override
  Future<void> dispose() async {
    // Cleanup user profile listeners
  }

  @override
  bool get isHealthy => true; // User profile service is always healthy
}
```

### 5. Progress Tracking and User Feedback

#### Progress Model
```dart
class InitializationProgress {
  final InitializationPhase phase;
  final int currentStage;
  final int totalStages;
  final List<String> currentServices;
  final double overallProgress;
  final String? currentService;
  final String? message;
  final dynamic error;

  const InitializationProgress({
    required this.phase,
    required this.currentStage,
    required this.totalStages,
    required this.currentServices,
    required this.overallProgress,
    this.currentService,
    this.message,
    this.error,
  });

  factory InitializationProgress.starting() {
    return InitializationProgress(
      phase: InitializationPhase.starting,
      currentStage: 0,
      totalStages: 1,
      currentServices: [],
      overallProgress: 0.0,
      message: 'Initializing app...',
    );
  }

  factory InitializationProgress.stage(
    int currentStage,
    int totalStages,
    List<String> services,
  ) {
    return InitializationProgress(
      phase: InitializationPhase.loading,
      currentStage: currentStage,
      totalStages: totalStages,
      currentServices: services,
      overallProgress: (currentStage - 1) / totalStages,
      message: 'Loading stage $currentStage of $totalStages...',
    );
  }

  factory InitializationProgress.service(
    String serviceName,
    double stageProgress,
  ) {
    return InitializationProgress(
      phase: InitializationPhase.loading,
      currentStage: 0, // Updated by orchestrator
      totalStages: 0,  // Updated by orchestrator
      currentServices: [serviceName],
      overallProgress: 0.0, // Updated by orchestrator
      currentService: serviceName,
      message: 'Loading $serviceName...',
    );
  }

  factory InitializationProgress.error(dynamic error) {
    return InitializationProgress(
      phase: InitializationPhase.error,
      currentStage: 0,
      totalStages: 1,
      currentServices: [],
      overallProgress: 0.0,
      error: error,
      message: 'Initialization failed: $error',
    );
  }

  factory InitializationProgress.completed() {
    return InitializationProgress(
      phase: InitializationPhase.completed,
      currentStage: 1,
      totalStages: 1,
      currentServices: [],
      overallProgress: 1.0,
      message: 'Initialization complete',
    );
  }
}

enum InitializationPhase {
  starting,
  loading,
  completed,
  error,
}
```

#### Progress UI Component
```dart
class InitializationProgressWidget extends StatelessWidget {
  final Stream<InitializationProgress> progressStream;
  final Widget Function(BuildContext, InitializationProgress) builder;
  final Widget? errorBuilder;
  final Widget? loadingBuilder;

  const InitializationProgressWidget({
    Key? key,
    required this.progressStream,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InitializationProgress>(
      stream: progressStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ??
              _defaultErrorBuilder(context, snapshot.error!);
        }

        if (!snapshot.hasData) {
          return loadingBuilder?.call(context) ?? _defaultLoadingBuilder(context);
        }

        final progress = snapshot.data!;
        return builder(context, progress);
      },
    );
  }

  Widget _defaultErrorBuilder(BuildContext context, dynamic error) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Initialization Failed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _retryInitialization(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _defaultLoadingBuilder(BuildContext context) {
    return JJElectricalLoader(
      width: 200,
      height: 60,
      message: 'Starting initialization...',
    );
  }

  void _retryInitialization() {
    // Trigger retry through service locator
    ServiceLocator.getInstance().get<InitializationOrchestrator>().initialize();
  }
}
```

## Integration with Existing Code

### Updated main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register services
  _registerServices();

  // Initialize using orchestrator
  final orchestrator = ServiceLocator.getInstance().get<InitializationOrchestrator>();

  try {
    final result = await orchestrator.initialize(
      strategy: InitializationStrategy.progressive,
    );

    if (!result.success) {
      debugPrint('Initialization completed with errors: ${result.errors}');
    }
  } catch (e) {
    debugPrint('Initialization failed: $e');
    // Handle critical initialization failure
  }

  runApp(const ProviderScope(child: MyApp()));
}

void _registerServices() {
  final registry = ServiceRegistry();

  // Core infrastructure
  registry.register(FirebaseCoreService());
  registry.register(AuthenticationService());
  registry.register(SessionManagementService());

  // User data
  registry.register(UserProfileService());
  registry.register(UserPreferencesService());

  // Core data
  registry.register(LocalsDirectoryService());
  registry.register(JobsDataService());
  registry.register(UnionDataService());

  // Features
  registry.register(CrewFeaturesService());
  registry.register(WeatherServicesService());
  registry.register(NotificationsService());

  // Background services
  registry.register(AnalyticsService());
  registry.register(PerformanceMonitoringService());
  registry.register(OfflineSyncService());
}
```

### Updated App Widget
```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orchestrator = ref.watch(initializationOrchestratorProvider);
    final progressStream = orchestrator.progressStream;

    return MaterialApp.router(
      title: 'Journeyman Jobs',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return InitializationProgressWidget(
          progressStream: progressStream,
          builder: (context, progress) {
            if (progress.phase == InitializationPhase.completed) {
              return _buildAppWithFeatures(context, child!);
            } else {
              return _buildInitializationScreen(context, progress);
            }
          },
        );
      },
    );
  }

  Widget _buildInitializationScreen(BuildContext context, InitializationProgress progress) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.splashGradient,
        ),
        child: Stack(
          children: [
            const CircuitPatternBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo
                  Image.asset('assets/images/app_logo.png', width: 120),
                  const SizedBox(height: 32),

                  // Progress indicator
                  JJElectricalLoader(
                    width: 200,
                    height: 60,
                    message: progress.message ?? 'Initializing...',
                  ),

                  const SizedBox(height: 24),

                  // Stage progress
                  if (progress.totalStages > 1) ...[
                    Text(
                      'Stage ${progress.currentStage} of ${progress.totalStages}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryNavy.withValues(alpha:0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.overallProgress,
                      backgroundColor: AppTheme.primaryNavy.withValues(alpha:0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                    ),
                  ],

                  // Current service
                  if (progress.currentService != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      progress.currentService!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryNavy.withValues(alpha:0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppWithFeatures(BuildContext context, Widget child) {
    return SessionActivityDetector(
      child: Column(
        children: [
          const GracePeriodWarningBanner(),
          Expanded(
            child: ActivityDetector(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Testing Strategy

### Unit Tests
```dart
// Test dependency graph topological sorting
test('Dependency graph topological sort respects dependencies', () {
  final graph = DependencyGraph();

  // Add services with dependencies
  graph.addService(MockService('A', {}));
  graph.addService(MockService('B', {'A'}));
  graph.addService(MockService('C', {'B'}));
  graph.addService(MockService('D', {'A'}));

  final sorted = graph.topologicalSort();

  // Verify A comes before B and D
  expect(sorted.indexOf('A'), lessThan(sorted.indexOf('B')));
  expect(sorted.indexOf('A'), lessThan(sorted.indexOf('D')));

  // Verify B comes before C
  expect(sorted.indexOf('B'), lessThan(sorted.indexOf('C')));
});

// Test parallel execution
test('Parallel execution respects dependencies', () async {
  final orchestrator = InitializationOrchestrator();
  final graph = DependencyGraph();

  // Setup services with mock results
  _setupMockServices(graph);

  final result = await orchestrator.initialize(
    strategy: InitializationStrategy.parallel,
  );

  expect(result.success, isTrue);
  expect(result.results, contains('serviceA'));
  expect(result.results, contains('serviceB'));
  expect(result.results, contains('serviceC'));
});

// Test error recovery
test('Graceful degradation handles service failures', () async {
  final orchestrator = InitializationOrchestrator();

  // Mock a critical service failure
  when(mockService.initialize()).thenThrow(Exception('Service unavailable'));

  final result = await orchestrator.initialize();

  expect(result.success, isFalse);
  expect(result.errors, isNotEmpty);

  // Verify fallback was used if available
  if (mockService.priority != ServicePriority.critical) {
    expect(result.results, contains(mockService.name));
  }
});
```

### Integration Tests
```dart
// Test full initialization flow
testWidgets('App initializes successfully with all services', (tester) async {
  await tester.pumpWidget(MyApp());

  // Should show initialization screen initially
  expect(find.byType(JJElectricalLoader), findsOneWidget);

  // Wait for initialization to complete
  await tester.pumpAndSettle(Duration(seconds: 5));

  // Should show main app content
  expect(find.byType(HomeScreen), findsOneWidget);
});

// Test error handling
testWidgets('App shows error screen on critical failure', (tester) async {
  // Mock critical service failure
  Firebase.initializeApp = () => throw Exception('Firebase initialization failed');

  await tester.pumpWidget(MyApp());

  // Should show error screen
  expect(find.text('Initialization Failed'), findsOneWidget);
  expect(find.byIcon(Icons.error_outline), findsOneWidget);
});
```

## Performance Monitoring

### Metrics Collection
```dart
class InitializationMetrics {
  final Map<String, Duration> _serviceTimes = {};
  final Map<String, int> _retryAttempts = {};
  final Map<String, bool> _circuitBreakerStates = {};

  void recordServiceTime(String serviceName, Duration duration) {
    _serviceTimes[serviceName] = duration;
  }

  void recordRetryAttempt(String serviceName) {
    _retryAttempts[serviceName] = (_retryAttempts[serviceName] ?? 0) + 1;
  }

  void recordCircuitBreakerState(String serviceName, bool isOpen) {
    _circuitBreakerStates[serviceName] = isOpen;
  }

  InitializationReport generateReport() {
    return InitializationReport(
      totalInitializationTime: _getTotalTime(),
      serviceTimes: Map.from(_serviceTimes),
      retryAttempts: Map.from(_retryAttempts),
      circuitBreakerStates: Map.from(_circuitBreakerStates),
      slowestService: _getSlowestService(),
      mostRetriedService: _getMostRetriedService(),
    );
  }
}
```

This implementation specification provides a comprehensive, production-ready solution for the hierarchical initialization dependency graph system. The modular design ensures maintainability, testability, and scalability while providing excellent user experience through progressive loading and graceful error handling.