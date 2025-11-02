# Performance Profiling

## Overview

Performance profiling skill for Flutter/Firebase applications in the Journeyman Jobs platform. Specializes in widget rebuild tracking, memory analysis, database query optimization, and real-time performance monitoring to ensure smooth 60fps experiences for field workers in demanding conditions.

**Domain**: Debug/Error Detection
**Agent**: Performance Monitor Agent
**Frameworks**: SuperClaude (Sequential + Context7) + SPARC
**Pre-configured Flags**: `--seq --focus performance --think`

## Error Detection Patterns

### Performance Degradation Indicators

**Widget Rendering Issues**:
- Frame drops below 60fps threshold
- Jank detection (frames taking >16ms)
- UI thread blocking operations
- Excessive widget rebuilds
- Large build method execution times

**Memory Issues**:
- Gradual memory growth (memory leaks)
- Sudden memory spikes
- Widget disposal failures
- Stream subscription leaks
- Image cache overflow

**Database Performance**:
- Firestore query latency >500ms
- Missing composite indexes
- Over-fetching data (large documents)
- Inefficient listener patterns
- Network timeout errors

**Initialization Performance**:
- Slow app startup (>3s cold start)
- Hierarchical initialization bottlenecks
- Level dependency chain delays
- Service initialization timeouts

### Detection Mechanisms

```dart
// Performance monitoring integration points
class PerformanceMonitor {
  // Frame timing tracking
  void trackFrameMetrics();

  // Widget rebuild counting
  void trackWidgetRebuilds(String widgetName);

  // Memory usage monitoring
  void trackMemoryUsage();

  // Database operation timing
  void trackDatabaseOperation(String operation, Duration duration);
}
```

## Implementation Strategies

### 1. Widget Rebuild Tracking

**Strategy**: Instrument critical widgets with rebuild counters and timing metrics.

```dart
class OptimizedJobCard extends ConsumerWidget {
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track rebuild count for performance analysis
    PerformanceMonitor.instance.trackWidgetRebuild('OptimizedJobCard');

    final job = ref.watch(jobProvider(jobId));

    return job.when(
      data: (jobData) => _buildJobCard(jobData),
      loading: () => SkeletonJobCard(),
      error: (error, stack) => ErrorRecoveryWidget(
        error: error,
        onRetry: () => ref.refresh(jobProvider(jobId)),
      ),
    );
  }
}
```

**Best Practices**:
- Use `const` constructors whenever possible
- Implement `RepaintBoundary` for complex subtrees
- Profile with DevTools timeline to identify hot spots
- Monitor rebuild counts in production via Firebase Performance

### 2. Memory Profiling

**Strategy**: Track memory allocations, monitor heap growth, detect leaks.

```dart
class MemoryProfiler {
  static Future<MemorySnapshot> captureSnapshot() async {
    final vm = await developer.Service.getVM();
    final isolate = await developer.Service.getIsolate(vm.isolates!.first.id!);

    return MemorySnapshot(
      heapUsage: isolate.heapUsage,
      timestamp: DateTime.now(),
      activeObjects: isolate.classHeap,
    );
  }

  static void detectLeaks(MemorySnapshot before, MemorySnapshot after) {
    final growth = after.heapUsage - before.heapUsage;

    if (growth > LEAK_THRESHOLD) {
      ErrorManager.reportMemoryLeak(
        growth: growth,
        snapshots: [before, after],
      );
    }
  }
}
```

**Leak Detection Targets**:
- Stream subscriptions (must be canceled)
- Animation controllers (must be disposed)
- Text editing controllers (must be disposed)
- Change notifiers (must be disposed)
- Image cache entries (must be cleared)

### 3. Database Query Profiling

**Strategy**: Instrument Firestore operations with timing and result size tracking.

```dart
class DatabasePerformanceMonitor {
  Future<T> trackQuery<T>({
    required String queryName,
    required Future<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      _recordQueryMetrics(
        queryName: queryName,
        duration: stopwatch.elapsed,
        success: true,
      );

      return result;
    } catch (e) {
      stopwatch.stop();

      _recordQueryMetrics(
        queryName: queryName,
        duration: stopwatch.elapsed,
        success: false,
        error: e,
      );

      rethrow;
    }
  }

  void _recordQueryMetrics({
    required String queryName,
    required Duration duration,
    required bool success,
    Object? error,
  }) {
    // Send to Firebase Performance
    final trace = FirebasePerformance.instance.newTrace('firestore_$queryName');
    trace.setMetric('duration_ms', duration.inMilliseconds);
    trace.putAttribute('success', success.toString());

    if (duration > Duration(milliseconds: 500)) {
      ErrorManager.reportPerformanceIssue(
        queryName: queryName,
        duration: duration,
        severity: ErrorSeverity.warning,
      );
    }
  }
}
```

### 4. Real-Time Frame Monitoring

**Strategy**: Use Flutter's frame callback mechanism to detect jank.

```dart
class FrameMonitor {
  static const TARGET_FPS = 60;
  static const FRAME_BUDGET_MS = 16; // 1000ms / 60fps

  void startMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final totalDuration = buildDuration + rasterDuration;

      if (totalDuration > Duration(milliseconds: FRAME_BUDGET_MS)) {
        _reportJank(
          buildMs: buildDuration.inMilliseconds,
          rasterMs: rasterDuration.inMilliseconds,
          totalMs: totalDuration.inMilliseconds,
        );
      }
    }
  }

  void _reportJank({
    required int buildMs,
    required int rasterMs,
    required int totalMs,
  }) {
    ErrorManager.reportPerformanceIssue(
      type: 'frame_jank',
      details: {
        'build_ms': buildMs,
        'raster_ms': rasterMs,
        'total_ms': totalMs,
        'dropped_frames': (totalMs / FRAME_BUDGET_MS).floor() - 1,
      },
      severity: ErrorSeverity.warning,
    );
  }
}
```

## JJ-Specific Examples

### OptimizedVirtualJobList Performance Tracking

```dart
class OptimizedVirtualJobList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(filteredJobsProvider);

    // Performance monitoring integration
    PerformanceMonitor.instance.startTrace('job_list_render');

    return jobs.when(
      data: (jobList) {
        PerformanceMonitor.instance.setMetric('job_count', jobList.length);
        PerformanceMonitor.instance.stopTrace('job_list_render');

        return ListView.builder(
          itemCount: jobList.length,
          itemExtent: 120, // Fixed height for performance
          itemBuilder: (context, index) {
            return OptimizedJobCard(
              jobId: jobList[index].id,
              // Use itemExtent for optimal scrolling performance
            );
          },
        );
      },
      loading: () => SkeletonJobList(),
      error: (e, stack) => ErrorRecoveryWidget(error: e),
    );
  }
}
```

### ComprehensiveErrorFramework Integration

```dart
class ComprehensiveErrorFramework {
  static void initializePerformanceMonitoring() {
    // Frame monitoring
    FrameMonitor().startMonitoring();

    // Memory profiling (periodic snapshots)
    Timer.periodic(Duration(minutes: 5), (_) async {
      final snapshot = await MemoryProfiler.captureSnapshot();
      _analyzeMemoryTrends(snapshot);
    });

    // Database performance tracking
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Performance trace initialization
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }
}
```

### PerformanceMonitor Service Implementation

```dart
class PerformanceMonitor {
  static final instance = PerformanceMonitor._();
  PerformanceMonitor._();

  final Map<String, int> _widgetRebuildCounts = {};
  final Map<String, Trace> _activeTraces = {};

  void trackWidgetRebuild(String widgetName) {
    _widgetRebuildCounts[widgetName] =
        (_widgetRebuildCounts[widgetName] ?? 0) + 1;

    // Alert on excessive rebuilds
    if (_widgetRebuildCounts[widgetName]! > REBUILD_THRESHOLD) {
      ErrorManager.reportPerformanceIssue(
        type: 'excessive_rebuilds',
        widgetName: widgetName,
        count: _widgetRebuildCounts[widgetName]!,
        severity: ErrorSeverity.warning,
      );
    }
  }

  void startTrace(String traceName) {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    trace.start();
    _activeTraces[traceName] = trace;
  }

  void setMetric(String metricName, int value) {
    _activeTraces.values.forEach((trace) {
      trace.setMetric(metricName, value);
    });
  }

  void stopTrace(String traceName) {
    final trace = _activeTraces.remove(traceName);
    trace?.stop();
  }
}
```

## Performance Metrics

### Target Benchmarks

**Rendering Performance**:
- 60fps sustained during scrolling
- <16ms frame build time
- <16ms frame raster time
- Zero jank during animations
- Smooth list scrolling with 1000+ items

**Memory Usage**:
- <100MB baseline memory
- <200MB peak memory during operation
- Zero memory leaks over 24h session
- Image cache <50MB
- No widget disposal failures

**Database Performance**:
- <200ms average query latency
- <500ms p95 query latency
- <1s p99 query latency
- >95% cache hit rate for jobs
- <100KB average document size

**Startup Performance**:
- <2s cold start time
- <500ms warm start time
- <1s hierarchical initialization
- <300ms service initialization per level

### Measurement Tools

```dart
class PerformanceMetrics {
  static const metrics = {
    // Frame metrics
    'avg_frame_build_ms': 'Average frame build time',
    'avg_frame_raster_ms': 'Average frame raster time',
    'jank_count': 'Number of janky frames',
    'dropped_frames': 'Total dropped frames',

    // Memory metrics
    'heap_usage_mb': 'Current heap usage',
    'peak_memory_mb': 'Peak memory usage',
    'memory_growth_rate': 'Memory growth per hour',

    // Database metrics
    'query_latency_avg': 'Average query latency',
    'query_latency_p95': 'P95 query latency',
    'cache_hit_rate': 'Cache hit percentage',
    'network_errors': 'Network error count',

    // Startup metrics
    'cold_start_ms': 'Cold start duration',
    'warm_start_ms': 'Warm start duration',
    'init_level_0_ms': 'Level 0 initialization',
    'init_level_4_ms': 'Level 4 initialization',
  };
}
```

## Recovery Mechanisms

### Performance Degradation Response

```dart
class PerformanceDegradationHandler {
  static void handleSlowFrames() {
    // Reduce rendering complexity
    AppSettings.enableReducedAnimations();

    // Clear image cache
    imageCache.clear();
    imageCache.maximumSize = 100; // Reduce cache size

    // Disable non-essential features
    AppSettings.disableBackgroundSync();

    ErrorManager.reportPerformanceIssue(
      type: 'performance_degradation',
      action: 'reduced_rendering_mode',
      severity: ErrorSeverity.warning,
    );
  }

  static void handleMemoryPressure() {
    // Clear caches
    imageCache.clear();
    PaintingBinding.instance.imageCache.clear();

    // Cancel non-essential operations
    BackgroundTaskManager.cancelLowPriority();

    // Request garbage collection
    developer.gc();

    ErrorManager.reportMemoryPressure(
      action: 'cache_cleared',
      severity: ErrorSeverity.critical,
    );
  }
}
```

## Monitoring Integration

### Firebase Performance Integration

```dart
class FirebasePerformanceIntegration {
  static void initialize() {
    // Enable automatic traces
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

    // Custom traces for critical paths
    _setupCriticalPathTraces();

    // Network request monitoring
    _setupNetworkMonitoring();
  }

  static void _setupCriticalPathTraces() {
    // App startup trace
    final startupTrace = FirebasePerformance.instance.newTrace('app_startup');
    startupTrace.start();

    // Job list loading trace
    final jobListTrace = FirebasePerformance.instance.newTrace('job_list_load');

    // Job detail loading trace
    final jobDetailTrace = FirebasePerformance.instance.newTrace('job_detail_load');
  }

  static void _setupNetworkMonitoring() {
    // Monitor Firestore operations
    FirebaseFirestore.instance
        .collection('jobs')
        .snapshots()
        .listen((snapshot) {
      final trace = FirebasePerformance.instance.newTrace('firestore_jobs_query');
      trace.setMetric('document_count', snapshot.docs.length);
      trace.stop();
    });
  }
}
```

## Self-Healing Patterns

### Automatic Performance Optimization

```dart
class SelfOptimizingPerformance {
  static void enableAdaptiveOptimization() {
    // Monitor performance metrics
    PerformanceMonitor.instance.metricsStream.listen((metrics) {
      // Adaptive frame rate
      if (metrics.avgFrameTime > 16) {
        _reduceAnimationComplexity();
      }

      // Adaptive cache sizing
      if (metrics.memoryUsage > MEMORY_THRESHOLD) {
        _reduceCacheSize();
      }

      // Adaptive query optimization
      if (metrics.queryLatency > QUERY_THRESHOLD) {
        _enableAggressiveCaching();
      }
    });
  }

  static void _reduceAnimationComplexity() {
    AppTheme.animationDuration = Duration(milliseconds: 150); // Faster
    AppTheme.enableComplexAnimations = false;
  }

  static void _reduceCacheSize() {
    imageCache.maximumSize = 50; // Reduce from 1000
    imageCache.maximumSizeBytes = 10 << 20; // 10MB
  }

  static void _enableAggressiveCaching() {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
```

---

**Agent Assignment**: Performance Monitor Agent (Debug Orchestrator)
**Complementary Skill**: Optimization Strategy
**Integration Points**: ErrorManager, ComprehensiveErrorFramework, PerformanceMonitor service
**Success Metrics**: 60fps sustained, <100MB memory, <200ms query latency
