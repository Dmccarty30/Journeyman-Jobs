# Optimization Strategy

## Overview

Optimization strategy skill for implementing performance improvements across Flutter UI, Firestore queries, and hierarchical initialization systems. Specializes in virtual scrolling, caching strategies, lazy loading, and resource optimization to ensure Journeyman Jobs runs efficiently on field worker devices with varying network conditions.

**Domain**: Debug/Error Detection
**Agent**: Performance Monitor Agent
**Frameworks**: SuperClaude (Sequential + Context7) + SPARC
**Pre-configured Flags**: `--seq --focus performance --think`

## Error Detection Patterns

### Performance Anti-Patterns

**Widget Inefficiencies**:
- Building widgets in loops without keys
- Unnecessary widget rebuilds
- Large build methods (>300 lines)
- Missing const constructors
- Inline function creation in build methods

**Data Fetching Issues**:
- Fetching all documents instead of paginated queries
- Missing Firestore indexes
- No local caching strategy
- Synchronous operations blocking UI
- Duplicate network requests

**Resource Management**:
- Images not properly cached
- Large asset bundles
- Unoptimized network payloads
- Memory leaks from undisposed resources
- Excessive background operations

### Detection Mechanisms

```dart
class OptimizationAnalyzer {
  // Detect rebuild inefficiencies
  void analyzeWidgetRebuilds(BuildContext context) {
    if (_rebuildCount[context.widget.runtimeType] > REBUILD_THRESHOLD) {
      ErrorManager.reportOptimizationOpportunity(
        type: 'excessive_rebuilds',
        widget: context.widget.runtimeType.toString(),
        count: _rebuildCount[context.widget.runtimeType],
      );
    }
  }

  // Detect query inefficiencies
  void analyzeFirestoreQuery(Query query) {
    if (!query.parameters.containsKey('limit')) {
      ErrorManager.reportOptimizationOpportunity(
        type: 'unbounded_query',
        query: query.toString(),
        recommendation: 'Add .limit() clause',
      );
    }
  }

  // Detect memory inefficiencies
  void analyzeMemoryUsage() {
    if (imageCache.currentSize > CACHE_THRESHOLD) {
      ErrorManager.reportOptimizationOpportunity(
        type: 'oversized_cache',
        cacheSize: imageCache.currentSize,
        recommendation: 'Implement cache eviction strategy',
      );
    }
  }
}
```

## Implementation Strategies

### 1. Virtual Scrolling Optimization

**Strategy**: Use ListView.builder with itemExtent for efficient scrolling of large job lists.

```dart
class OptimizedVirtualJobList extends ConsumerWidget {
  static const ITEM_HEIGHT = 120.0;
  static const INITIAL_LOAD_COUNT = 20;
  static const PAGINATION_THRESHOLD = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(paginatedJobsProvider);

    return jobsAsync.when(
      data: (jobs) => ListView.builder(
        // Fixed item height for optimal scrolling performance
        itemExtent: ITEM_HEIGHT,
        itemCount: jobs.length + 1, // +1 for loading indicator

        itemBuilder: (context, index) {
          // Pagination trigger
          if (index >= jobs.length - PAGINATION_THRESHOLD) {
            _loadMoreJobs(ref);
          }

          if (index >= jobs.length) {
            return PaginationLoadingIndicator();
          }

          return OptimizedJobCard(
            key: ValueKey(jobs[index].id),
            jobId: jobs[index].id,
          );
        },

        // Recycling optimization
        cacheExtent: ITEM_HEIGHT * 10, // Cache 10 items ahead
      ),
      loading: () => SkeletonJobList(itemHeight: ITEM_HEIGHT),
      error: (e, stack) => ErrorRecoveryWidget(
        error: e,
        onRetry: () => ref.refresh(paginatedJobsProvider),
      ),
    );
  }

  void _loadMoreJobs(WidgetRef ref) {
    ref.read(jobPaginationControllerProvider.notifier).loadNextPage();
  }
}
```

**Key Optimizations**:
- `itemExtent` for fixed height items (avoids layout calculations)
- Pagination with threshold-based loading
- Cache extent optimization for smooth scrolling
- Value keys for efficient widget recycling

### 2. Caching Strategy Implementation

**Strategy**: Multi-level caching (memory, disk, network) with intelligent invalidation.

```dart
class UnifiedCacheStrategy {
  final MemoryCache memoryCache;
  final DiskCache diskCache;
  final NetworkCache networkCache;

  // Three-tier cache lookup
  Future<T> getCachedData<T>({
    required String key,
    required Future<T> Function() fetchFn,
    Duration ttl = const Duration(hours: 1),
  }) async {
    // Level 1: Memory cache (fastest)
    if (memoryCache.has(key)) {
      return memoryCache.get<T>(key);
    }

    // Level 2: Disk cache (fast)
    if (await diskCache.has(key)) {
      final data = await diskCache.get<T>(key);
      memoryCache.set(key, data, ttl);
      return data;
    }

    // Level 3: Network fetch (slow)
    final data = await fetchFn();

    // Populate caches
    memoryCache.set(key, data, ttl);
    await diskCache.set(key, data, ttl);

    return data;
  }

  // Intelligent cache invalidation
  void invalidateCache(String pattern) {
    memoryCache.invalidatePattern(pattern);
    diskCache.invalidatePattern(pattern);
  }
}
```

**JJ-Specific Cache Zones**:
- **Hot Zone** (memory): Active job list, user preferences (TTL: 5min)
- **Warm Zone** (disk): Job details, user profile (TTL: 1hr)
- **Cold Zone** (network): All jobs, historical data (TTL: 24hr)

### 3. Lazy Loading Implementation

**Strategy**: Load data incrementally as needed, with skeleton screens for UX.

```dart
class LazyJobDetailsLoader extends ConsumerWidget {
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load core data immediately
    final jobCore = ref.watch(jobCoreProvider(jobId));

    return jobCore.when(
      data: (core) => LazyJobDetailsContent(
        core: core,
        // Load additional data on-demand
        detailsLoader: () => ref.watch(jobDetailsProvider(jobId)),
        commentsLoader: () => ref.watch(jobCommentsProvider(jobId)),
        historyLoader: () => ref.watch(jobHistoryProvider(jobId)),
      ),
      loading: () => SkeletonJobDetails(),
      error: (e, stack) => ErrorRecoveryWidget(error: e),
    );
  }
}

class LazyJobDetailsContent extends StatefulWidget {
  final JobCore core;
  final AsyncValue Function() detailsLoader;
  final AsyncValue Function() commentsLoader;
  final AsyncValue Function() historyLoader;

  @override
  _LazyJobDetailsContentState createState() => _LazyJobDetailsContentState();
}

class _LazyJobDetailsContentState extends State<LazyJobDetailsContent> {
  bool _loadedDetails = false;
  bool _loadedComments = false;
  bool _loadedHistory = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Core info always visible
          JobCoreInfo(core: widget.core),

          // Details loaded on scroll into view
          VisibilityDetector(
            key: Key('job_details'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.5 && !_loadedDetails) {
                setState(() => _loadedDetails = true);
              }
            },
            child: _loadedDetails
                ? JobDetailsSection(loader: widget.detailsLoader)
                : SkeletonJobSection(),
          ),

          // Comments loaded on scroll into view
          VisibilityDetector(
            key: Key('job_comments'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.5 && !_loadedComments) {
                setState(() => _loadedComments = true);
              }
            },
            child: _loadedComments
                ? JobCommentsSection(loader: widget.commentsLoader)
                : SkeletonCommentsSection(),
          ),

          // History loaded only if user expands
          ExpansionTile(
            title: Text('Job History'),
            onExpansionChanged: (expanded) {
              if (expanded && !_loadedHistory) {
                setState(() => _loadedHistory = true);
              }
            },
            children: [
              if (_loadedHistory)
                JobHistorySection(loader: widget.historyLoader)
              else
                SkeletonHistorySection(),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 4. Query Optimization

**Strategy**: Optimize Firestore queries with indexes, limits, and geographic filtering.

```dart
class OptimizedJobQueryStrategy {
  final FirebaseFirestore firestore;
  final DatabasePerformanceMonitor monitor;

  Future<List<Job>> fetchJobs({
    required FilterCriteria filters,
    required GeoPoint userLocation,
    int limit = 20,
  }) async {
    return monitor.trackQuery(
      queryName: 'jobs_filtered',
      operation: () async {
        Query query = firestore.collection('jobs');

        // Geographic optimization (shard by region)
        final shard = _calculateShard(userLocation);
        query = query.where('shard', isEqualTo: shard);

        // Composite index required: (shard, status, trade, createdAt)
        if (filters.status != null) {
          query = query.where('status', isEqualTo: filters.status);
        }

        if (filters.trade != null) {
          query = query.where('trade', isEqualTo: filters.trade);
        }

        // Sort by relevance (createdAt)
        query = query.orderBy('createdAt', descending: true);

        // Pagination limit
        query = query.limit(limit);

        final snapshot = await query.get();

        return snapshot.docs
            .map((doc) => Job.fromFirestore(doc))
            .toList();
      },
    );
  }

  String _calculateShard(GeoPoint location) {
    // Shard by geographic region for optimization
    final lat = (location.latitude / 10).floor();
    final lng = (location.longitude / 10).floor();
    return '${lat}_${lng}';
  }
}
```

**Required Firestore Indexes**:
```javascript
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "jobs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "shard", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "trade", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

## JJ-Specific Examples

### HierarchicalInitializationService Optimization

```dart
class OptimizedHierarchicalInitialization {
  static Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();

    // Parallel initialization within levels
    await _initializeLevel0Parallel();
    await _initializeLevel1Parallel();
    await _initializeLevel2Parallel();
    await _initializeLevel3Parallel();
    await _initializeLevel4Parallel();

    stopwatch.stop();

    PerformanceMonitor.instance.recordMetric(
      'initialization_time_ms',
      stopwatch.elapsedMilliseconds,
    );

    if (stopwatch.elapsedMilliseconds > 2000) {
      ErrorManager.reportPerformanceIssue(
        type: 'slow_initialization',
        duration: stopwatch.elapsed,
        severity: ErrorSeverity.warning,
      );
    }
  }

  static Future<void> _initializeLevel0Parallel() async {
    // Independent services can initialize in parallel
    await Future.wait([
      ErrorManager.initialize(),
      PerformanceMonitor.instance.initialize(),
      CrashReporter.initialize(),
    ]);
  }

  static Future<void> _initializeLevel1Parallel() async {
    await Future.wait([
      Firebase.initializeApp(),
      SecureStorage.initialize(),
      LocalDatabase.initialize(),
    ]);
  }

  // ... levels 2-4 with parallel execution
}
```

### ResilienceStrategy Optimization

```dart
class OptimizedResilienceStrategy implements ResilienceStrategy {
  final CircuitBreaker circuitBreaker;
  final AdaptiveRetryPolicy retryPolicy;

  @override
  Future<T> execute<T>(Future<T> Function() operation) async {
    // Fast path: circuit closed, no retry needed
    if (circuitBreaker.isClosed && retryPolicy.shouldSkipRetry) {
      return operation();
    }

    // Slow path: circuit open or retries needed
    if (circuitBreaker.isOpen) {
      throw CircuitBreakerOpenException();
    }

    int attempts = 0;
    while (true) {
      try {
        final result = await operation();
        circuitBreaker.recordSuccess();
        retryPolicy.reset();
        return result;
      } catch (e) {
        attempts++;
        circuitBreaker.recordFailure();

        if (attempts >= retryPolicy.maxRetries) {
          rethrow;
        }

        // Exponential backoff with jitter
        final delay = retryPolicy.calculateDelay(attempts);
        await Future.delayed(delay);
      }
    }
  }
}
```

### SearchStrategy Optimization

```dart
class OptimizedSearchStrategy implements SearchStrategy {
  final SearchCache cache;
  final SearchIndex index;

  @override
  Future<List<Job>> search({
    required String query,
    required FilterCriteria filters,
  }) async {
    // Check cache first
    final cacheKey = _buildCacheKey(query, filters);
    if (cache.has(cacheKey)) {
      return cache.get(cacheKey);
    }

    // Use pre-built search index
    final results = await index.search(
      query: query,
      filters: filters,
      algorithm: SearchAlgorithm.fuzzyMatch,
      maxResults: 50,
    );

    // Cache results
    cache.set(cacheKey, results, ttl: Duration(minutes: 5));

    return results;
  }

  String _buildCacheKey(String query, FilterCriteria filters) {
    return 'search_${query}_${filters.hashCode}';
  }
}
```

## Performance Metrics

### Optimization Targets

**Widget Rendering**:
- <100 widget rebuilds per interaction
- <10ms build method execution
- <5ms layout calculation
- >95% const widget usage
- Zero unnecessary rebuilds

**Data Loading**:
- <200ms initial job list load
- <100ms job detail load
- <50ms cache hit latency
- >90% cache hit rate
- <10KB average network payload

**Memory Efficiency**:
- <50MB image cache
- <20MB memory growth per hour
- <100 active widget instances
- >99% resource disposal rate
- Zero memory leaks

**Startup Optimization**:
- <1.5s cold start
- <300ms warm start
- <500ms per initialization level
- <5 parallel operations per level
- >95% initialization success rate

### Measurement Strategy

```dart
class OptimizationMetrics {
  static final metrics = {
    // Widget metrics
    'const_widget_ratio': 'Percentage of const widgets',
    'avg_build_time_ms': 'Average build method time',
    'rebuild_efficiency': 'Necessary vs total rebuilds',

    // Data metrics
    'cache_hit_rate': 'Cache hit percentage',
    'avg_payload_size_kb': 'Average network payload',
    'query_optimization_score': 'Query efficiency score',

    // Memory metrics
    'memory_growth_rate': 'MB growth per hour',
    'disposal_success_rate': 'Resource cleanup percentage',
    'cache_eviction_rate': 'Cache evictions per minute',

    // Startup metrics
    'parallel_init_count': 'Parallel operations per level',
    'init_level_duration': 'Duration per level array',
    'total_startup_time': 'End-to-end startup time',
  };

  static void recordOptimization(String type, Map<String, dynamic> data) {
    FirebaseAnalytics.instance.logEvent(
      name: 'optimization_applied',
      parameters: {
        'optimization_type': type,
        ...data,
      },
    );
  }
}
```

## Recovery Mechanisms

### Automatic Optimization Triggers

```dart
class AutoOptimizationEngine {
  static void enableAutoOptimization() {
    // Monitor performance and auto-optimize
    PerformanceMonitor.instance.metricsStream.listen((metrics) {
      // Optimize widgets if rebuilds excessive
      if (metrics.rebuildRate > REBUILD_THRESHOLD) {
        _optimizeWidgetRebuilds();
      }

      // Optimize queries if latency high
      if (metrics.queryLatency > LATENCY_THRESHOLD) {
        _optimizeQueries();
      }

      // Optimize memory if usage high
      if (metrics.memoryUsage > MEMORY_THRESHOLD) {
        _optimizeMemory();
      }
    });
  }

  static void _optimizeWidgetRebuilds() {
    // Enable aggressive const usage
    AppConfig.enforceConstWidgets = true;

    // Reduce animation complexity
    AppTheme.animationDuration = Duration(milliseconds: 150);

    // Batch setState calls
    WidgetOptimizer.enableBatchedUpdates();

    OptimizationMetrics.recordOptimization('widget_rebuilds', {
      'action': 'reduced_rebuilds',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void _optimizeQueries() {
    // Enable aggressive caching
    CacheStrategy.enableAggressiveCaching();

    // Reduce query limits
    QueryOptimizer.reduceQueryLimits();

    // Enable query coalescing
    QueryOptimizer.enableCoalescing();

    OptimizationMetrics.recordOptimization('queries', {
      'action': 'aggressive_caching',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void _optimizeMemory() {
    // Clear caches
    imageCache.clear();
    CacheManager.clearNonEssential();

    // Reduce cache sizes
    imageCache.maximumSize = 50;

    // Request GC
    developer.gc();

    OptimizationMetrics.recordOptimization('memory', {
      'action': 'cache_cleared',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## Monitoring Integration

### Optimization Dashboard

```dart
class OptimizationDashboard {
  static Widget build(BuildContext context) {
    return Column(
      children: [
        MetricCard(
          title: 'Widget Efficiency',
          metrics: [
            'Const Widget Ratio: ${_metrics.constWidgetRatio}%',
            'Avg Build Time: ${_metrics.avgBuildTime}ms',
            'Rebuild Efficiency: ${_metrics.rebuildEfficiency}%',
          ],
        ),
        MetricCard(
          title: 'Data Loading',
          metrics: [
            'Cache Hit Rate: ${_metrics.cacheHitRate}%',
            'Avg Payload: ${_metrics.avgPayloadSize}KB',
            'Query Score: ${_metrics.queryScore}/100',
          ],
        ),
        MetricCard(
          title: 'Memory',
          metrics: [
            'Growth Rate: ${_metrics.memoryGrowthRate}MB/hr',
            'Disposal Rate: ${_metrics.disposalRate}%',
            'Cache Size: ${_metrics.cacheSize}MB',
          ],
        ),
      ],
    );
  }
}
```

## Self-Healing Patterns

### Adaptive Optimization

```dart
class AdaptiveOptimizer {
  static void enableAdaptiveOptimization() {
    // Learn from usage patterns
    UsageAnalyzer.patternsStream.listen((patterns) {
      // Optimize frequently accessed data
      if (patterns.frequentJobs.isNotEmpty) {
        CacheStrategy.preloadJobs(patterns.frequentJobs);
      }

      // Optimize based on network conditions
      if (patterns.networkQuality == NetworkQuality.poor) {
        _enableLowBandwidthMode();
      }

      // Optimize based on device capabilities
      if (patterns.devicePerformance == DevicePerformance.low) {
        _enableLowEndDeviceMode();
      }
    });
  }

  static void _enableLowBandwidthMode() {
    // Reduce image quality
    ImageQuality.set(ImageQuality.low);

    // Aggressive caching
    CacheStrategy.ttl = Duration(hours: 24);

    // Reduce query frequency
    QueryOptimizer.pollingInterval = Duration(minutes: 5);
  }

  static void _enableLowEndDeviceMode() {
    // Disable animations
    AppTheme.enableAnimations = false;

    // Reduce list page size
    PaginationConfig.pageSize = 10;

    // Simplify UI
    UIComplexity.set(UIComplexity.simple);
  }
}
```

---

**Agent Assignment**: Performance Monitor Agent (Debug Orchestrator)
**Complementary Skill**: Performance Profiling
**Integration Points**: UnifiedFirestoreService, HierarchicalInitializationService, CacheStrategy
**Success Metrics**: <200ms query latency, >90% cache hit rate, <1.5s cold start
