# Initialization Strategy Skill

**Skill Type**: Technical Pattern | **Domain**: State Management | **Complexity**: Advanced

## Purpose

Master hierarchical initialization patterns for Journeyman Jobs, implementing level-based dependency resolution (Levels 0-4) for systematic app startup, service initialization, and state hydration in the electrical trade platform.

## Core Capabilities

### 1. Hierarchical Initialization System

```dart
// Initialization levels for dependency ordering
enum InitializationLevel {
  level0, // Core infrastructure (Firebase, Storage)
  level1, // Authentication & Identity
  level2, // Services & Repositories
  level3, // State Management & Caching
  level4, // UI & Feature Initialization
}

// Initialization stage tracking
enum InitializationStage {
  notStarted,
  inProgress,
  completed,
  failed;

  bool get isCompleted => this == InitializationStage.completed;
  bool get isFailed => this == InitializationStage.failed;
}

// Initialization result
@freezed
class InitializationResult with _$InitializationResult {
  const factory InitializationResult({
    required InitializationLevel level,
    required InitializationStage stage,
    required Duration duration,
    String? errorMessage,
  }) = _InitializationResult;

  const InitializationResult._();

  bool get isSuccess => stage == InitializationStage.completed;
}
```

### 2. Hierarchical Initialization Service

```dart
// Main initialization coordinator
class HierarchicalInitializationService {
  final Map<InitializationLevel, InitializationStage> _stages = {};
  final Map<InitializationLevel, Duration> _durations = {};
  final List<String> _errors = [];

  // Track initialization progress
  final _progressController = StreamController<InitializationProgress>.broadcast();
  Stream<InitializationProgress> get progressStream => _progressController.stream;

  // Initialize app in stages
  Future<void> initialize() async {
    try {
      await _initializeLevel0(); // Core infrastructure
      await _initializeLevel1(); // Authentication
      await _initializeLevel2(); // Services
      await _initializeLevel3(); // State management
      await _initializeLevel4(); // UI initialization
    } catch (e, stack) {
      _logError('Initialization failed', e, stack);
      rethrow;
    } finally {
      _progressController.close();
    }
  }

  // Level 0: Core Infrastructure
  Future<void> _initializeLevel0() async {
    await _executeLevel(
      InitializationLevel.level0,
      'Core Infrastructure',
      () async {
        // Initialize Firebase
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Initialize local storage
        await _initializeLocalStorage();

        // Initialize error tracking
        await _initializeErrorTracking();

        // Initialize analytics
        await _initializeAnalytics();
      },
    );
  }

  // Level 1: Authentication & Identity
  Future<void> _initializeLevel1() async {
    await _executeLevel(
      InitializationLevel.level1,
      'Authentication',
      () async {
        // Initialize Firebase Auth
        final auth = FirebaseAuth.instance;

        // Restore auth session
        final user = auth.currentUser;

        if (user != null) {
          // Restore user session
          await _restoreUserSession(user);
        }

        // Set up auth state listener
        _setupAuthStateListener(auth);
      },
    );
  }

  // Level 2: Services & Repositories
  Future<void> _initializeLevel2() async {
    await _executeLevel(
      InitializationLevel.level2,
      'Services',
      () async {
        // Initialize Firestore with settings
        final firestore = FirebaseFirestore.instance;
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );

        // Initialize Cloud Messaging
        await _initializeFCM();

        // Initialize location services
        await _initializeLocationServices();

        // Pre-warm service connections
        await _prewarmServices();
      },
    );
  }

  // Level 3: State Management & Caching
  Future<void> _initializeLevel3() async {
    await _executeLevel(
      InitializationLevel.level3,
      'State Management',
      () async {
        // Hydrate app settings from storage
        await _hydrateAppSettings();

        // Hydrate user preferences
        await _hydrateUserPreferences();

        // Hydrate job filters
        await _hydrateJobFilters();

        // Load cached data
        await _loadCachedData();

        // Sync offline changes
        await _syncOfflineChanges();
      },
    );
  }

  // Level 4: UI & Feature Initialization
  Future<void> _initializeLevel4() async {
    await _executeLevel(
      InitializationLevel.level4,
      'UI Initialization',
      () async {
        // Pre-cache images
        await _precacheImages();

        // Initialize theme
        await _initializeTheme();

        // Setup deep linking
        await _setupDeepLinking();

        // Initialize notifications UI
        await _initializeNotifications();

        // Background sync setup
        await _setupBackgroundSync();
      },
    );
  }

  // Execute a level with timing and error tracking
  Future<void> _executeLevel(
    InitializationLevel level,
    String levelName,
    Future<void> Function() initializer,
  ) async {
    _stages[level] = InitializationStage.inProgress;
    _notifyProgress();

    final stopwatch = Stopwatch()..start();

    try {
      await initializer();

      stopwatch.stop();
      _durations[level] = stopwatch.elapsed;
      _stages[level] = InitializationStage.completed;

      _logInfo('$levelName completed in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, stack) {
      stopwatch.stop();
      _durations[level] = stopwatch.elapsed;
      _stages[level] = InitializationStage.failed;
      _errors.add('$levelName failed: $e');

      _logError('$levelName failed', e, stack);
      rethrow;
    } finally {
      _notifyProgress();
    }
  }

  // Progress notification
  void _notifyProgress() {
    final progress = InitializationProgress(
      stages: Map.from(_stages),
      durations: Map.from(_durations),
      errors: List.from(_errors),
    );

    _progressController.add(progress);
  }

  // Helper: Initialize local storage
  Future<void> _initializeLocalStorage() async {
    await GetStorage.init();
  }

  // Helper: Initialize error tracking
  Future<void> _initializeErrorTracking() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Helper: Initialize analytics
  Future<void> _initializeAnalytics() async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
  }

  // Helper: Restore user session
  Future<void> _restoreUserSession(User user) async {
    final storage = GetStorage();

    // Restore user profile
    final profileJson = storage.read('user_profile');
    if (profileJson != null) {
      // Hydrate user state
    }

    // Restore favorites
    final favoritesJson = storage.read('favorites');
    if (favoritesJson != null) {
      // Hydrate favorites
    }
  }

  // Helper: Setup auth state listener
  void _setupAuthStateListener(FirebaseAuth auth) {
    auth.authStateChanges().listen((user) {
      if (user == null) {
        // User logged out, clear cached data
        _clearUserData();
      } else {
        // User logged in, sync data
        _syncUserData(user);
      }
    });
  }

  // Helper: Initialize FCM
  Future<void> _initializeFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permissions
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await messaging.getToken();
    if (token != null) {
      // Save token to Firestore
      await _saveFCMToken(token);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Helper: Initialize location services
  Future<void> _initializeLocationServices() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Get current location
      try {
        final position = await Geolocator.getCurrentPosition();
        // Cache current location
        await _cacheCurrentLocation(position);
      } catch (e) {
        // Location unavailable, continue without it
      }
    }
  }

  // Helper: Prewarm services
  Future<void> _prewarmServices() async {
    // Make initial Firestore connection
    await FirebaseFirestore.instance
      .collection('jobs')
      .limit(1)
      .get();
  }

  // Helper: Hydrate app settings
  Future<void> _hydrateAppSettings() async {
    final storage = GetStorage();
    final settingsJson = storage.read('app_settings');

    if (settingsJson != null) {
      try {
        final settings = AppSettings.fromJson(jsonDecode(settingsJson));
        // Apply settings
      } catch (e) {
        // Invalid settings, use defaults
      }
    }
  }

  // Helper: Hydrate user preferences
  Future<void> _hydrateUserPreferences() async {
    final storage = GetStorage();
    final preferencesJson = storage.read('user_preferences');

    if (preferencesJson != null) {
      try {
        final prefs = UserPreferences.fromJson(jsonDecode(preferencesJson));
        // Apply preferences
      } catch (e) {
        // Invalid preferences, use defaults
      }
    }
  }

  // Helper: Hydrate job filters
  Future<void> _hydrateJobFilters() async {
    final storage = GetStorage();
    final filterJson = storage.read('job_filter');

    if (filterJson != null) {
      try {
        final filter = JobFilter.fromJson(jsonDecode(filterJson));
        // Apply filter
      } catch (e) {
        // Invalid filter, use defaults
      }
    }
  }

  // Helper: Load cached data
  Future<void> _loadCachedData() async {
    // Load cached jobs
    final storage = GetStorage();
    final cachedJobsJson = storage.read('cached_jobs');

    if (cachedJobsJson != null) {
      try {
        final jobs = (jsonDecode(cachedJobsJson) as List)
          .map((json) => Job.fromJson(json))
          .toList();

        // Hydrate jobs cache
      } catch (e) {
        // Invalid cache, clear it
        await storage.remove('cached_jobs');
      }
    }
  }

  // Helper: Sync offline changes
  Future<void> _syncOfflineChanges() async {
    final storage = GetStorage();
    final pendingChanges = storage.read('pending_changes') as List?;

    if (pendingChanges != null && pendingChanges.isNotEmpty) {
      for (final change in pendingChanges) {
        try {
          await _syncChange(change);
        } catch (e) {
          // Log sync error but continue
        }
      }

      // Clear synced changes
      await storage.remove('pending_changes');
    }
  }

  // Helper: Precache images
  Future<void> _precacheImages() async {
    // Precache app logo, icons, etc.
    // Implementation depends on image caching strategy
  }

  // Helper: Initialize theme
  Future<void> _initializeTheme() async {
    final storage = GetStorage();
    final themeMode = storage.read('theme_mode') ?? 'system';

    // Apply theme
  }

  // Helper: Setup deep linking
  Future<void> _setupDeepLinking() async {
    // Initialize app links/deep links
    // Implementation depends on deep linking package
  }

  // Helper: Initialize notifications
  Future<void> _initializeNotifications() async {
    // Setup local notifications
    // Implementation depends on notification package
  }

  // Helper: Setup background sync
  Future<void> _setupBackgroundSync() async {
    // Register background sync tasks
    // Implementation depends on background task package
  }

  void _logInfo(String message) {
    debugPrint('[Init] $message');
  }

  void _logError(String message, Object error, StackTrace stack) {
    debugPrint('[Init] ERROR: $message');
    debugPrint('[Init] $error');
    FirebaseCrashlytics.instance.recordError(error, stack);
  }

  Future<void> _clearUserData() async {
    // Implementation
  }

  Future<void> _syncUserData(User user) async {
    // Implementation
  }

  Future<void> _saveFCMToken(String token) async {
    // Implementation
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Implementation
  }

  Future<void> _cacheCurrentLocation(Position position) async {
    // Implementation
  }

  Future<void> _syncChange(dynamic change) async {
    // Implementation
  }
}

// Progress tracking model
@freezed
class InitializationProgress with _$InitializationProgress {
  const factory InitializationProgress({
    required Map<InitializationLevel, InitializationStage> stages,
    required Map<InitializationLevel, Duration> durations,
    required List<String> errors,
  }) = _InitializationProgress;

  const InitializationProgress._();

  double get progress {
    final completed = stages.values
      .where((stage) => stage == InitializationStage.completed)
      .length;
    return completed / InitializationLevel.values.length;
  }

  bool get isCompleted {
    return stages.values.every((stage) => stage == InitializationStage.completed);
  }

  bool get hasFailed {
    return stages.values.any((stage) => stage == InitializationStage.failed);
  }

  Duration get totalDuration {
    return durations.values.fold(
      Duration.zero,
      (total, duration) => total + duration,
    );
  }
}
```

### 3. Riverpod Integration

```dart
// Initialization provider
final initializationServiceProvider = Provider<HierarchicalInitializationService>((ref) {
  return HierarchicalInitializationService();
});

// Progress stream provider
final initializationProgressProvider = StreamProvider<InitializationProgress>((ref) {
  final service = ref.watch(initializationServiceProvider);
  return service.progressStream;
});

// Initialization trigger provider
final initializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(initializationServiceProvider);
  await service.initialize();
});
```

### 4. Splash Screen Integration

```dart
class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(initializationProvider);

    return Scaffold(
      body: Center(
        child: initAsync.when(
          data: (_) {
            // Navigate to home
            Future.microtask(() {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            });

            return const CircularProgressIndicator();
          },
          loading: () => _buildLoadingView(ref),
          error: (error, stack) => _buildErrorView(error, ref),
        ),
      ),
    );
  }

  Widget _buildLoadingView(WidgetRef ref) {
    final progressAsync = ref.watch(initializationProgressProvider);

    return progressAsync.when(
      data: (progress) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Image.asset('assets/logo.png', width: 120),
          const SizedBox(height: 40),

          // Progress indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status text
          Text(
            'Initializing... ${(progress.progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildErrorView(Object error, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Initialization Failed',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref.invalidate(initializationProvider);
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
```

## Best Practices

### 1. Dependency Ordering

Always initialize dependencies before dependents:

```
Level 0: Firebase, Storage, Analytics
↓
Level 1: Auth (depends on Firebase)
↓
Level 2: Services (depend on Auth, Firestore)
↓
Level 3: State (depends on Services)
↓
Level 4: UI (depends on State)
```

### 2. Error Recovery

```dart
// Graceful degradation for non-critical failures
Future<void> _initializeLevel4() async {
  try {
    await _precacheImages();
  } catch (e) {
    // Non-critical, log and continue
    _logError('Image precaching failed', e);
  }

  try {
    await _setupDeepLinking();
  } catch (e) {
    // Non-critical, log and continue
    _logError('Deep linking setup failed', e);
  }
}
```

### 3. Performance Monitoring

```dart
// Track initialization performance
Future<void> _executeLevel(...) async {
  final stopwatch = Stopwatch()..start();

  try {
    await initializer();

    stopwatch.stop();

    // Log to analytics
    FirebasePerformance.instance
      .newTrace('init_${level.name}')
      .setMetric('duration_ms', stopwatch.elapsedMilliseconds)
      .stop();
  } catch (e) {
    // Log error
  }
}
```

## Common Pitfalls to Avoid

### ❌ Mistake 1: Blocking UI Thread

```dart
// BAD: Synchronous heavy operation
Future<void> initialize() async {
  final largeData = _loadLargeFile(); // Blocks UI
}

// GOOD: Async with isolates
Future<void> initialize() async {
  final largeData = await compute(_loadLargeFile, null);
}
```

### ❌ Mistake 2: Ignoring Initialization Failures

```dart
// BAD: Silent failure
try {
  await _initializeLevel1();
} catch (e) {
  // Ignored!
}

// GOOD: Handle appropriately
try {
  await _initializeLevel1();
} catch (e) {
  _stages[level] = InitializationStage.failed;
  _errors.add(e.toString());
  rethrow; // Critical failure
}
```

### ❌ Mistake 3: Wrong Dependency Order

```dart
// BAD: Service before auth
await _initializeServices(); // Needs auth!
await _initializeAuth();

// GOOD: Auth before services
await _initializeAuth();
await _initializeServices();
```

## Quality Standards

- **Dependency Order**: Strict level-based initialization
- **Error Handling**: Graceful degradation for non-critical failures
- **Performance**: < 3s total initialization time
- **Monitoring**: Track each level's duration
- **Recovery**: Retry mechanism for transient failures

## Related Skills

- `service-lifecycle` - Service initialization and disposal
- `dependency-injection` - Provider dependency resolution
- `immutable-model-design` - State hydration models
- `notifier-logic` - State restoration in notifiers
