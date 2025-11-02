---
name: jj-mobile-performance-optimization
description: Optimize Flutter app performance for 8-12 hour electrical field worker shifts. Targets battery efficiency (<15%/hr active), 60fps scrolling, memory management (<150MB), cold start (<2s), network resilience, and offline performance. Use when app feels sluggish, battery drains fast, memory grows, or testing on low-end devices.
---

# JJ Mobile Performance Optimization

## Purpose

Ensure Journeyman Jobs runs efficiently on budget Android devices during full 8-12 hour electrical field worker shifts. Focus on battery life, frame rate, memory usage, and network resilience.

## When To Use

- App feels sluggish or unresponsive
- Battery drains faster than 15% per hour active use
- Memory usage growing over time
- Scroll performance drops below 60fps
- Cold start takes longer than 2 seconds
- Offline mode performs poorly
- Testing on low-end devices (2-4GB RAM)

## Performance Targets

| Metric | Target | Acceptable | Critical |
|--------|--------|------------|----------|
| **Frame Rate** | 60fps | 50fps+ | Scrolling, animations |
| **Battery (Active)** | <15%/hr | <20%/hr | 8-hour shift |
| **Battery (Background)** | <5%/hr | <8%/hr | Passive monitoring |
| **Memory Usage** | <150MB | <250MB | Typical usage |
| **Cold Start** | <2s | <3s | To interactive |
| **Network Latency** | <500ms | <1s | First meaningful paint |

## Core Optimization Strategies

### Strategy 1: Battery Optimization

**Goal**: Enable 8+ hour shifts without charging

#### Reduce Screen Rendering

```dart
// ✅ Use const constructors - prevents unnecessary rebuilds
const Padding(
  padding: EdgeInsets.all(16),
  child: const Text('Job Title'),
);

// ✅ Limit animation frame rate for non-critical animations
AnimationController(
  duration: const Duration(milliseconds: 300),
  vsync: this,
)..addListener(() {
  // Throttle updates to 30fps for non-critical animations
  if (_frameCount % 2 == 0) {
    setState(() {});
  }
  _frameCount++;
});

// ❌ Over-animating drains battery
AnimatedContainer(
  duration: const Duration(milliseconds: 16),  // 60fps constantly
  // ... runs even when off-screen
);
```

#### Optimize Image Loading

```dart
// ✅ Size-limited image caching
CachedNetworkImage(
  imageUrl: job.imageUrl,
  memCacheWidth: 300,  // Limit memory cache size
  memCacheHeight: 300,
  maxWidthDiskCache: 600,  // Limit disk cache size
  maxHeightDiskCache: 600,
  filterQuality: FilterQuality.medium,  // Balance quality/performance
);

// ✅ Lazy load images only when visible
ListView.builder(
  itemBuilder: (context, index) {
    return Visibility(
      visible: _isItemVisible(index),
      child: CachedNetworkImage(...),
    );
  },
);

// ❌ Loading full-resolution images
Image.network(
  job.imageUrl,  // Loads full size, wastes battery
);
```

#### Background Task Management

```dart
// ✅ Batch background operations
class BackgroundSyncService {
  Timer? _syncTimer;
  
  void startPeriodicSync() {
    // Sync every 15 minutes instead of constantly
    _syncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _batchSync(),
    );
  }
  
  Future<void> _batchSync() async {
    // Batch multiple operations together
    await Future.wait([
      _syncJobs(),
      _syncMessages(),
      _syncPreferences(),
    ]);
  }
  
  void dispose() {
    _syncTimer?.cancel();
  }
}

// ❌ Constant background polling
Timer.periodic(
  const Duration(seconds: 5),  // Too frequent!
  (_) => fetchUpdates(),
);
```

#### Network Request Optimization

```dart
// ✅ Debounce search queries
class SearchDebouncer {
  Timer? _debounce;
  
  void search(String query, Function(String) callback) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => callback(query),
    );
  }
  
  void dispose() => _debounce?.cancel();
}

// ✅ Cache API responses
final dio = Dio()
  ..interceptors.add(DioCacheInterceptor(
    options: CacheOptions(
      store: MemCacheStore(),
      maxStale: const Duration(hours: 1),
    ),
  ));

// ❌ API call on every keystroke
onChanged: (query) => fetchJobs(query),  // Hits API constantly
```

### Strategy 2: Frame Rate Optimization (60fps Target)

**Goal**: Smooth scrolling and interactions

#### ListView Performance

```dart
// ✅ Fixed itemExtent for smooth scrolling
ListView.builder(
  itemCount: jobs.length,
  itemExtent: 140,  // CRITICAL: Fixed height enables optimization
  cacheExtent: 280,  // Pre-cache 2 items above/below
  itemBuilder: (context, index) {
    return JobCard(
      key: ValueKey(jobs[index].id),  // Preserve state
      job: jobs[index],
    );
  },
);

// ✅ Separate list from heavy operations
class JobList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    
    // Keep list building logic isolated
    return ListView.builder(
      itemExtent: 140,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }
  
  Widget _buildJobCard(Job job) {
    // Heavy operations done outside list builder
    return JobCard(job: job);
  }
}

// ❌ Variable height items - causes jank
ListView.builder(
  itemBuilder: (context, index) {
    return JobCard(jobs[index]);  // No itemExtent - Flutter must measure each item
  },
);
```

#### Widget Build Optimization

```dart
// ✅ Use const constructors everywhere
class JobCard extends StatelessWidget {
  const JobCard({Key? key}) : super(key: key);  // const constructor

  @override
  Widget build(BuildContext context) {
    return const Card(  // const widget tree
      child: const Padding(
        padding: const EdgeInsets.all(16),  // const values
        child: const Text('Job Title'),
      ),
    );
  }
}

// ✅ Extract expensive widgets
class JobCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const _StaticHeader(),  // Doesn't rebuild
          _DynamicContent(job: job),  // Only this rebuilds
        ],
      ),
    );
  }
}

// ❌ Rebuilding entire widget tree
Widget build(BuildContext context) {
  return Card(
    child: Column(
      children: jobs.map((job) => 
        JobCard(job: job)  // Rebuilds all cards on any change
      ).toList(),
    ),
  );
}
```

#### Riverpod Selector Optimization

```dart
// ✅ Select specific fields to minimize rebuilds
Consumer(
  builder: (context, ref, child) {
    // Only rebuilds when jobCount changes
    final jobCount = ref.watch(
      jobsProvider.select((jobs) => jobs.length)
    );
    return Text('$jobCount jobs');
  },
);

// ✅ Use family providers for individual items
final jobProvider = Provider.family<Job, String>((ref, jobId) {
  return ref.watch(jobsProvider).firstWhere((j) => j.id == jobId);
});

// ❌ Watching entire provider
Consumer(
  builder: (context, ref, child) {
    final jobs = ref.watch(jobsProvider);  // Rebuilds on ANY job change
    return Text('${jobs.length} jobs');
  },
);
```

### Strategy 3: Memory Management

**Goal**: Maintain <150MB memory usage during typical usage

#### Dispose Resources Properly

```dart
// ✅ Always dispose controllers and streams
class JobsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _scrollController = ScrollController();
  StreamSubscription? _jobSubscription;
  
  @override
  void initState() {
    super.initState();
    _jobSubscription = jobStream.listen(_handleJobUpdate);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();  // CRITICAL: Prevent memory leaks
    _jobSubscription?.cancel();   // CRITICAL: Cancel streams
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(controller: _scrollController);
  }
}

// ❌ Forgetting to dispose
class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _controller = ScrollController();
  // No dispose() method - memory leak!
}
```

#### Image Memory Management

```dart
// ✅ Limit image cache size
void configureImageCache() {
  PaintingBinding.instance.imageCache.maximumSize = 100;  // Limit cached images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;  // 50MB
}

// ✅ Clear cache when memory pressure detected
void onMemoryPressure() {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
}

// ✅ Use ResizeImage for thumbnails
Image(
  image: ResizeImage(
    NetworkImage(job.imageUrl),
    width: 100,
    height: 100,
  ),
);
```

#### List Memory Management

```dart
// ✅ Dispose old items when list changes
class JobListManager {
  final _items = <String, Job>{};
  
  void updateJobs(List<Job> newJobs) {
    final newIds = newJobs.map((j) => j.id).toSet();
    
    // Remove items no longer in list
    _items.removeWhere((id, _) => !newIds.contains(id));
    
    // Add new items
    for (final job in newJobs) {
      _items[job.id] = job;
    }
  }
}

// ❌ Growing list indefinitely
final allJobs = <Job>[];
void addJobs(List<Job> newJobs) {
  allJobs.addAll(newJobs);  // Never removes old items
}
```

### Strategy 4: Cold Start Optimization

**Goal**: <2 second cold start to interactive

#### Lazy Load Heavy Dependencies

```dart
// ✅ Initialize critical services first
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Level 0: Critical only
  await Firebase.initializeApp();
  await AuthService.initialize();
  
  runApp(const MyApp());
  
  // Level 1+: Load after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeSecondaryServices();
  });
}

Future<void> _initializeSecondaryServices() async {
  // Load heavy services after UI is interactive
  await Future.wait([
    LocalStorageService.initialize(),
    AnalyticsService.initialize(),
    CrashReportingService.initialize(),
  ]);
}

// ❌ Loading everything before UI
Future<void> main() async {
  await Firebase.initializeApp();
  await LocalStorage.init();
  await Analytics.init();
  await LoadHeavyData();  // Blocks UI for seconds
  runApp(const MyApp());
}
```

#### Splash Screen Optimization

```dart
// ✅ Show UI immediately with loading states
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: ref.watch(initializationProvider).when(
        // Show skeleton UI immediately
        loading: () => const SplashWithSkeleton(),
        error: (e, s) => ErrorScreen(error: e),
        data: (_) => const HomeScreen(),
      ),
    );
  }
}

// ❌ Blocking splash screen
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeEverything().then((_) {
      // User stares at logo for 5+ seconds
      Navigator.pushReplacement(...);
    });
  }
}
```

### Strategy 5: Network Resilience

**Goal**: Graceful handling of poor/no connectivity

#### Request Prioritization

```dart
// ✅ Priority queue for network requests
enum RequestPriority { critical, high, normal, low }

class NetworkQueue {
  final _queues = <RequestPriority, Queue<Future<void> Function()>>{};
  
  Future<T> enqueue<T>(
    RequestPriority priority,
    Future<T> Function() request,
  ) async {
    _queues[priority] ??= Queue();
    _queues[priority]!.add(request);
    return _processNext();
  }
  
  Future<void> _processNext() async {
    // Process critical requests first
    for (final priority in RequestPriority.values) {
      final queue = _queues[priority];
      if (queue != null && queue.isNotEmpty) {
        final request = queue.removeFirst();
        await request();
      }
    }
  }
}

// ✅ Exponential backoff retry
Future<T> retryWithBackoff<T>(
  Future<T> Function() request, {
  int maxAttempts = 3,
}) async {
  int attempts = 0;
  while (attempts < maxAttempts) {
    try {
      return await request();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      
      // Wait 2^attempts seconds before retry
      await Future.delayed(Duration(seconds: math.pow(2, attempts).toInt()));
    }
  }
  throw Exception('Max retry attempts exceeded');
}
```

#### Offline Queue

```dart
// ✅ Queue operations when offline
class OfflineQueue {
  final _queue = Queue<PendingOperation>();
  
  Future<void> addOperation(PendingOperation op) async {
    if (await isOnline()) {
      await op.execute();
    } else {
      _queue.add(op);
      await _saveToStorage();
    }
  }
  
  Future<void> syncWhenOnline() async {
    while (_queue.isNotEmpty) {
      final op = _queue.removeFirst();
      try {
        await op.execute();
        await _saveToStorage();
      } catch (e) {
        _queue.addFirst(op);  // Put back if failed
        throw e;
      }
    }
  }
}

// Usage
await offlineQueue.addOperation(
  BookmarkJob(jobId: job.id),
);
```

## Profiling & Monitoring

### Flutter DevTools

```dart
// Enable performance overlay in debug mode
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: kDebugMode,  // Shows FPS
      home: const HomeScreen(),
    );
  }
}

// Profile widget builds
Timeline.startSync('BuildJobCard');
final widget = JobCard(job: job);
Timeline.finishSync();
```

### Custom Performance Metrics

```dart
// Track key metrics
class PerformanceMonitor {
  static final _metrics = <String, List<int>>{};
  
  static void recordMetric(String name, int value) {
    _metrics[name] ??= [];
    _metrics[name]!.add(value);
    
    // Log if exceeds threshold
    if (name == 'frame_time' && value > 16) {  // >16ms = dropped frame
      print('⚠️ Dropped frame: ${value}ms');
    }
  }
  
  static Map<String, double> getAverages() {
    return _metrics.map((key, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(key, avg);
    });
  }
}

// Usage
final stopwatch = Stopwatch()..start();
await fetchJobs();
PerformanceMonitor.recordMetric('api_latency', stopwatch.elapsedMilliseconds);
```

### Battery Monitoring

```dart
// Track battery usage
class BatteryMonitor {
  static DateTime? _sessionStart;
  static int? _startBatteryLevel;
  
  static Future<void> startSession() async {
    _sessionStart = DateTime.now();
    _startBatteryLevel = await Battery().batteryLevel;
  }
  
  static Future<Map<String, dynamic>> getSessionStats() async {
    final duration = DateTime.now().difference(_sessionStart!);
    final currentLevel = await Battery().batteryLevel;
    final drain = _startBatteryLevel! - currentLevel;
    
    return {
      'duration_hours': duration.inHours,
      'battery_drain_percent': drain,
      'drain_per_hour': drain / duration.inHours,
      'meets_target': (drain / duration.inHours) < 15,  // <15% per hour
    };
  }
}
```

## Testing Workflow

### 1. Baseline Measurement

```bash
# Run profiling build
flutter run --profile

# Open DevTools
flutter pub global run devtools
```

**Measure**:
- Average frame time (should be <16ms)
- Memory usage over 30 minutes
- Battery drain over 1 hour
- Cold start time (5 consecutive launches)

### 2. Identify Bottlenecks

**DevTools Timeline**: Look for long frames (>16ms)
**Memory View**: Find memory leaks (growing heap)
**Network Tab**: Identify slow/excessive requests
**CPU Profiler**: Find expensive operations

### 3. Apply Optimizations

**Priority order**:
1. Fix dropped frames (impacts perceived performance)
2. Reduce memory leaks (prevents crashes)
3. Optimize network (reduces battery drain)
4. Improve cold start (first impression)

### 4. Validate Improvements

Re-measure all metrics and compare to baseline:
- Frame time should decrease by 20%+
- Memory should be stable (no growth)
- Battery drain should decrease by 15%+
- Cold start should decrease by 30%+

## Common Performance Issues

### Issue 1: Janky Scrolling

**Symptoms**: Stuttering when scrolling job lists

**Diagnosis**:
```dart
// Check Timeline in DevTools for long frames
// Look for expensive operations during scroll
```

**Solutions**:
- Add `itemExtent` to ListView
- Use const constructors
- Extract heavy widgets
- Profile with Timeline

### Issue 2: Memory Growth

**Symptoms**: App uses more RAM over time

**Diagnosis**:
```dart
// Memory tab in DevTools shows growing heap
// Look for undisposed controllers/streams
```

**Solutions**:
- Dispose controllers properly
- Cancel stream subscriptions
- Clear image cache periodically
- Use WeakReference for caches

### Issue 3: Battery Drain

**Symptoms**: >15% battery drain per hour

**Diagnosis**:
```dart
// Check battery stats on device
// Profile with Battery Historian
```

**Solutions**:
- Reduce animation frame rates
- Limit background operations
- Batch network requests
- Optimize image loading

### Issue 4: Slow Cold Start

**Symptoms**: >2 seconds to interactive

**Diagnosis**:
```dart
// Add Timeline markers to main()
Timeline.startSync('Initialize Firebase');
await Firebase.initializeApp();
Timeline.finishSync();
```

**Solutions**:
- Lazy load services
- Show UI before initialization complete
- Defer non-critical loading
- Use splash screen with skeleton

## Platform-Specific Optimization

### Android (Primary Target)

```dart
// ProGuard rules for release builds
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }

// Enable R8 full mode for better optimization
android {
    buildTypes {
        release {
            shrinkResources true
            minifyEnabled true
        }
    }
}
```

### Low-End Device Strategies

```dart
// Detect device capabilities and adjust
class DeviceCapabilities {
  static bool get isLowEnd {
    // Check RAM and adjust accordingly
    return DeviceInfoPlugin().androidInfo.then((info) {
      return info.totalMemory < 3 * 1024 * 1024 * 1024;  // <3GB
    });
  }
  
  static int get cacheSize {
    return isLowEnd ? 25 : 100;  // Smaller cache for low-end
  }
  
  static int get maxConcurrentImages {
    return isLowEnd ? 3 : 10;
  }
}
```

## Monitoring Dashboard

```dart
// Display performance metrics in debug mode
class PerformanceOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return kDebugMode
        ? Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricRow('FPS', '${_currentFps}'),
                  _MetricRow('Memory', '${_memoryMb}MB'),
                  _MetricRow('Battery', '${_batteryPercent}%'),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
```

## Checklist Before Release

- [ ] 60fps scrolling verified on low-end Android
- [ ] <15% battery drain per hour during 8-hour test
- [ ] Memory stable (<150MB) over 2-hour session
- [ ] Cold start <2 seconds (average of 5 launches)
- [ ] Offline mode fully functional
- [ ] Poor network (throttled 3G) tested
- [ ] No memory leaks (DevTools heap snapshot)
- [ ] All images cached and size-limited
- [ ] Background services optimized (<5%/hr)
- [ ] Release build tested on 3+ devices

## Resources

**Flutter Documentation**:
- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
- [DevTools](https://docs.flutter.dev/tools/devtools/overview)

**Tools**:
- Flutter DevTools (profiling)
- Battery Historian (battery analysis)
- Android Profiler (system-level monitoring)

---

**Skill Version**: 1.0.0  
**Last Updated**: 2025-10-31  
**Status**: ✅ Production Ready
