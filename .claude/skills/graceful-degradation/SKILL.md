# Graceful Degradation

## Overview

Graceful degradation skill for implementing fallback strategies, offline mode, and progressive feature reduction when Journeyman Jobs encounters errors or resource constraints. Ensures field workers maintain core functionality even in adverse conditions like poor network connectivity, server failures, or device resource limitations.

**Domain**: Debug/Error Detection
**Agent**: Self-Healing Agent
**Frameworks**: Hive Mind (learning patterns) + SuperClaude
**Pre-configured Flags**: `--introspect --safe-mode --loop`

## Error Detection Patterns

### Degradation Triggers

**Network Failures**:
- Connection timeout errors
- HTTP 5xx server errors
- DNS resolution failures
- Slow network conditions (<100KB/s)
- Intermittent connectivity

**Resource Constraints**:
- Low memory warnings (<50MB available)
- CPU throttling on low-end devices
- Battery critical state (<10%)
- Storage space low (<100MB)
- Thermal throttling events

**Service Failures**:
- Firebase authentication failures
- Firestore query timeouts
- Cloud Functions unavailable
- Third-party API failures
- Backend service degradation

**Feature Complexity Issues**:
- Slow rendering performance (<30fps)
- Large data sets causing jank
- Complex animations causing frame drops
- Heavy computation blocking UI
- Background sync failures

### Detection Mechanisms

```dart
class DegradationDetector {
  // Network health monitoring
  Stream<NetworkHealth> get networkHealthStream {
    return NetworkMonitor.instance.healthStream.map((health) {
      if (health.latency > 1000) return NetworkHealth.poor;
      if (health.latency > 500) return NetworkHealth.moderate;
      return NetworkHealth.good;
    });
  }

  // Resource monitoring
  Stream<ResourceHealth> get resourceHealthStream {
    return ResourceMonitor.instance.healthStream.map((resources) {
      if (resources.availableMemory < 50 * 1024 * 1024) {
        return ResourceHealth.critical;
      }
      if (resources.cpuUsage > 80) return ResourceHealth.high;
      if (resources.batteryLevel < 10) return ResourceHealth.low;
      return ResourceHealth.good;
    });
  }

  // Service availability monitoring
  Stream<ServiceHealth> get serviceHealthStream {
    return ServiceMonitor.instance.healthStream.map((services) {
      if (services.firebaseStatus == ServiceStatus.down) {
        return ServiceHealth.degraded;
      }
      if (services.authStatus == ServiceStatus.slow) {
        return ServiceHealth.impaired;
      }
      return ServiceHealth.operational;
    });
  }
}
```

## Implementation Strategies

### 1. Progressive Feature Degradation

**Strategy**: Systematically reduce feature complexity based on severity of constraints.

```dart
class FeatureDegradationManager {
  static const levels = [
    DegradationLevel.full,        // All features enabled
    DegradationLevel.reduced,     // Non-essential features disabled
    DegradationLevel.minimal,     // Core features only
    DegradationLevel.offline,     // Offline mode with cached data
    DegradationLevel.emergency,   // Critical operations only
  ];

  DegradationLevel currentLevel = DegradationLevel.full;

  void degradeTo(DegradationLevel level) {
    if (level == currentLevel) return;

    currentLevel = level;

    switch (level) {
      case DegradationLevel.full:
        _enableAllFeatures();
        break;
      case DegradationLevel.reduced:
        _disableNonEssentialFeatures();
        break;
      case DegradationLevel.minimal:
        _enableCoreOnly();
        break;
      case DegradationLevel.offline:
        _enableOfflineMode();
        break;
      case DegradationLevel.emergency:
        _enableEmergencyMode();
        break;
    }

    ErrorManager.reportDegradation(
      level: level,
      reason: 'Automatic degradation triggered',
      severity: ErrorSeverity.warning,
    );
  }

  void _disableNonEssentialFeatures() {
    // Disable animations
    AppTheme.enableAnimations = false;

    // Disable background sync
    BackgroundSyncManager.pause();

    // Reduce image quality
    ImageQuality.set(ImageQuality.medium);

    // Disable analytics
    AnalyticsManager.disable();

    // Disable real-time updates
    RealtimeUpdatesManager.pause();
  }

  void _enableCoreOnly() {
    // All reduced features plus:

    // Disable notifications
    NotificationManager.disableNonCritical();

    // Disable location updates
    LocationManager.pauseBackgroundUpdates();

    // Simplify UI
    UIComplexity.set(UIComplexity.simple);

    // Disable social features
    SocialFeatures.disable();
  }

  void _enableOfflineMode() {
    // Switch to cached data only
    DataSource.setMode(DataSourceMode.cacheOnly);

    // Queue write operations
    OfflineQueueManager.enableQueueing();

    // Disable server communication
    NetworkManager.pauseAllRequests();

    // Show offline indicator
    OfflineIndicator.show();
  }

  void _enableEmergencyMode() {
    // Minimal functionality for critical operations
    AppFeatures.enableOnly([
      Feature.viewCachedJobs,
      Feature.emergencyContact,
      Feature.offlineMap,
    ]);

    // Maximum resource conservation
    ResourceConservation.setLevel(ConservationLevel.maximum);
  }
}
```

### 2. Fallback Strategy Implementation

**Strategy**: Multi-tier fallback for data sources and services.

```dart
class FallbackStrategyManager {
  // Cascading data source fallback
  Future<List<Job>> fetchJobsWithFallback({
    required FilterCriteria filters,
    required GeoPoint userLocation,
  }) async {
    // Tier 1: Real-time Firestore query
    try {
      return await _fetchFromFirestore(filters, userLocation);
    } on FirebaseException catch (e) {
      ErrorManager.reportError(
        error: e,
        context: 'Firestore query failed',
        severity: ErrorSeverity.warning,
      );

      // Tier 2: Local cache
      try {
        return await _fetchFromCache(filters, userLocation);
      } catch (e) {
        ErrorManager.reportError(
          error: e,
          context: 'Cache query failed',
          severity: ErrorSeverity.warning,
        );

        // Tier 3: Static fallback data
        return _getStaticFallbackJobs(filters, userLocation);
      }
    }
  }

  Future<List<Job>> _fetchFromFirestore(
    FilterCriteria filters,
    GeoPoint location,
  ) async {
    // Primary data source
    return FirestoreService.instance.fetchJobs(
      filters: filters,
      location: location,
      timeout: Duration(seconds: 5),
    );
  }

  Future<List<Job>> _fetchFromCache(
    FilterCriteria filters,
    GeoPoint location,
  ) async {
    // Secondary data source (local database)
    final cachedJobs = await LocalDatabase.instance.queryJobs(
      filters: filters,
      location: location,
    );

    if (cachedJobs.isEmpty) {
      throw CacheEmptyException();
    }

    // Show staleness indicator
    CacheAgeIndicator.show(cachedJobs.first.cachedAt);

    return cachedJobs;
  }

  List<Job> _getStaticFallbackJobs(
    FilterCriteria filters,
    GeoPoint location,
  ) {
    // Tertiary fallback (bundled sample data)
    return SampleData.jobs
        .where((job) => _matchesFilters(job, filters))
        .take(10)
        .toList();
  }
}
```

### 3. Offline Mode Implementation

**Strategy**: Queue operations, sync when online, provide cached experience.

```dart
class OfflineModeManager {
  final OfflineQueue operationQueue;
  final LocalCache cache;
  final ConnectivityMonitor connectivityMonitor;

  // Enable offline mode
  void enableOfflineMode() {
    // Switch to cache-first strategy
    DataStrategy.set(DataStrategy.cacheFirst);

    // Enable operation queueing
    operationQueue.enable();

    // Show offline banner
    OfflineBanner.show();

    // Listen for connectivity restoration
    connectivityMonitor.onlineStream.listen((_) {
      _syncQueuedOperations();
    });
  }

  // Queue write operations for later sync
  Future<void> queueOperation(OfflineOperation operation) async {
    await operationQueue.add(operation);

    // Optimistic update to local cache
    await cache.applyOptimisticUpdate(operation);

    // Notify user
    SnackbarManager.show(
      message: 'Saved offline. Will sync when online.',
      duration: Duration(seconds: 3),
    );
  }

  // Sync queued operations when online
  Future<void> _syncQueuedOperations() async {
    final operations = await operationQueue.getAll();

    if (operations.isEmpty) return;

    SyncProgressIndicator.show(total: operations.length);

    int synced = 0;
    int failed = 0;

    for (final operation in operations) {
      try {
        await _executeOperation(operation);
        await operationQueue.remove(operation);
        synced++;
      } catch (e) {
        failed++;
        ErrorManager.reportError(
          error: e,
          context: 'Offline sync failed',
          metadata: {'operation': operation.toString()},
        );
      }

      SyncProgressIndicator.update(synced: synced, failed: failed);
    }

    SyncProgressIndicator.hide();

    // Notify user of results
    if (failed == 0) {
      SnackbarManager.show(
        message: 'All changes synced successfully',
        type: SnackbarType.success,
      );
    } else {
      SnackbarManager.show(
        message: '$synced synced, $failed failed',
        type: SnackbarType.warning,
        action: SnackbarAction(
          label: 'Retry',
          onPressed: _syncQueuedOperations,
        ),
      );
    }
  }
}
```

### 4. Circuit Breaker Pattern

**Strategy**: Prevent cascading failures by breaking circuit on repeated errors.

```dart
class CircuitBreaker {
  final String serviceName;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  CircuitState state = CircuitState.closed;
  int failureCount = 0;
  DateTime? lastFailureTime;

  Future<T> execute<T>(Future<T> Function() operation) async {
    // Check circuit state
    if (state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        state = CircuitState.halfOpen;
      } else {
        throw CircuitBreakerOpenException(
          service: serviceName,
          message: 'Circuit breaker is open. Service temporarily unavailable.',
        );
      }
    }

    try {
      final result = await operation();

      // Success - reset failure count
      if (state == CircuitState.halfOpen) {
        state = CircuitState.closed;
        failureCount = 0;
        ErrorManager.reportRecovery(
          service: serviceName,
          message: 'Circuit breaker reset - service recovered',
        );
      }

      return result;
    } catch (e) {
      failureCount++;
      lastFailureTime = DateTime.now();

      // Check if threshold exceeded
      if (failureCount >= failureThreshold) {
        state = CircuitState.open;
        ErrorManager.reportCircuitBreak(
          service: serviceName,
          failureCount: failureCount,
          severity: ErrorSeverity.critical,
        );
      }

      rethrow;
    }
  }

  bool _shouldAttemptReset() {
    if (lastFailureTime == null) return false;
    return DateTime.now().difference(lastFailureTime!) > resetTimeout;
  }
}
```

## JJ-Specific Examples

### ResilientFirestoreService Integration

```dart
class ResilientFirestoreService extends UnifiedFirestoreService {
  final CircuitBreaker circuitBreaker;
  final FallbackStrategyManager fallbackManager;
  final OfflineModeManager offlineManager;

  @override
  Future<List<Job>> fetchJobs({
    required FilterCriteria filters,
    required GeoPoint location,
  }) async {
    // Use circuit breaker to prevent cascading failures
    return circuitBreaker.execute(() async {
      try {
        // Primary: Firestore with timeout
        return await super.fetchJobs(
          filters: filters,
          location: location,
        ).timeout(
          Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Firestore query timeout'),
        );
      } catch (e) {
        // Fallback strategy on failure
        return fallbackManager.fetchJobsWithFallback(
          filters: filters,
          userLocation: location,
        );
      }
    });
  }

  @override
  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    // Check network connectivity
    final isOnline = await ConnectivityMonitor.instance.isOnline;

    if (!isOnline) {
      // Queue for offline sync
      await offlineManager.queueOperation(
        UpdateJobOperation(jobId: jobId, data: data),
      );
      return;
    }

    // Execute online
    return circuitBreaker.execute(() async {
      return super.updateJob(jobId, data);
    });
  }
}
```

### ErrorRecoveryWidget with Degradation

```dart
class ErrorRecoveryWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final bool allowDegradation;

  @override
  Widget build(BuildContext context) {
    // Determine error severity and fallback options
    final severity = _classifyError(error);
    final fallbackOptions = _getFallbackOptions(severity);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(severity),
              size: 64,
              color: _getErrorColor(severity),
            ),
            SizedBox(height: 16),
            Text(
              _getErrorMessage(error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              _getErrorAdvice(severity),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),

            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              ),

            // Fallback options
            if (allowDegradation && fallbackOptions.isNotEmpty)
              ..._buildFallbackOptions(fallbackOptions),

            // Offline mode option
            if (severity == ErrorSeverity.critical)
              TextButton.icon(
                onPressed: () => _enableOfflineMode(context),
                icon: Icon(Icons.cloud_off),
                label: Text('Continue Offline'),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFallbackOptions(List<FallbackOption> options) {
    return options.map((option) {
      return TextButton.icon(
        onPressed: option.action,
        icon: Icon(option.icon),
        label: Text(option.label),
      );
    }).toList();
  }

  void _enableOfflineMode(BuildContext context) {
    OfflineModeManager.instance.enableOfflineMode();
    Navigator.of(context).pop();
  }
}
```

### AdaptiveDegradationController

```dart
class AdaptiveDegradationController {
  final DegradationDetector detector;
  final FeatureDegradationManager degradationManager;

  void startMonitoring() {
    // Monitor network health
    detector.networkHealthStream.listen((health) {
      switch (health) {
        case NetworkHealth.poor:
          degradationManager.degradeTo(DegradationLevel.minimal);
          break;
        case NetworkHealth.moderate:
          degradationManager.degradeTo(DegradationLevel.reduced);
          break;
        case NetworkHealth.good:
          degradationManager.degradeTo(DegradationLevel.full);
          break;
      }
    });

    // Monitor resource health
    detector.resourceHealthStream.listen((resources) {
      switch (resources) {
        case ResourceHealth.critical:
          degradationManager.degradeTo(DegradationLevel.emergency);
          break;
        case ResourceHealth.high:
          degradationManager.degradeTo(DegradationLevel.minimal);
          break;
        case ResourceHealth.low:
          degradationManager.degradeTo(DegradationLevel.reduced);
          break;
        case ResourceHealth.good:
          // Don't upgrade if network is poor
          if (detector.currentNetworkHealth != NetworkHealth.poor) {
            degradationManager.degradeTo(DegradationLevel.full);
          }
          break;
      }
    });

    // Monitor service health
    detector.serviceHealthStream.listen((services) {
      if (services == ServiceHealth.degraded) {
        degradationManager.degradeTo(DegradationLevel.offline);
      }
    });
  }
}
```

## Performance Metrics

### Degradation Effectiveness

**Availability Metrics**:
- >99% uptime with graceful degradation
- <3s degradation transition time
- >95% offline operation success rate
- <5% data loss in offline mode
- >90% user satisfaction in degraded mode

**Performance Targets**:
- Offline mode: <100ms cache query latency
- Fallback data: <200ms load time
- Circuit breaker: <50ms decision time
- Queue sync: >100 operations/second
- Recovery time: <10s from degraded to full

**Resource Conservation**:
- 50% memory reduction in minimal mode
- 70% battery savings in offline mode
- 80% network reduction in degraded mode
- 90% CPU reduction in emergency mode

### Measurement Tools

```dart
class DegradationMetrics {
  static final metrics = {
    // Availability
    'degradation_uptime': 'Uptime percentage with degradation',
    'offline_success_rate': 'Offline operation success rate',
    'data_loss_rate': 'Data loss percentage',

    // Performance
    'cache_latency_ms': 'Cache query latency',
    'fallback_latency_ms': 'Fallback data latency',
    'circuit_decision_ms': 'Circuit breaker decision time',

    // Resource conservation
    'memory_reduction': 'Memory reduction percentage',
    'battery_savings': 'Battery savings percentage',
    'network_reduction': 'Network usage reduction',
  };

  static void recordDegradation(DegradationLevel level) {
    FirebaseAnalytics.instance.logEvent(
      name: 'degradation_triggered',
      parameters: {
        'level': level.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

## Recovery Mechanisms

### Automatic Recovery

```dart
class AutoRecoveryManager {
  static void enableAutoRecovery() {
    // Monitor for recovery conditions
    DegradationDetector.instance.healthStream.listen((health) {
      if (_canRecover(health)) {
        _attemptRecovery(health);
      }
    });
  }

  static bool _canRecover(SystemHealth health) {
    return health.network == NetworkHealth.good &&
        health.resources == ResourceHealth.good &&
        health.services == ServiceHealth.operational;
  }

  static Future<void> _attemptRecovery(SystemHealth health) async {
    // Gradual recovery
    await FeatureDegradationManager.instance.recoverTo(DegradationLevel.full);

    // Sync offline operations
    await OfflineModeManager.instance.syncQueuedOperations();

    // Reset circuit breakers
    CircuitBreakerRegistry.resetAll();

    // Notify user
    SnackbarManager.show(
      message: 'Connection restored. All features available.',
      type: SnackbarType.success,
    );

    ErrorManager.reportRecovery(
      context: 'Automatic recovery complete',
      severity: ErrorSeverity.info,
    );
  }
}
```

## Monitoring Integration

### Degradation Dashboard

```dart
class DegradationDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DegradationState>(
      stream: DegradationMonitor.instance.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? DegradationState.initial();

        return Column(
          children: [
            StatusCard(
              title: 'Current Mode',
              value: state.currentLevel.toString(),
              color: _getLevelColor(state.currentLevel),
            ),
            StatusCard(
              title: 'Queued Operations',
              value: state.queuedOperations.toString(),
              color: state.queuedOperations > 0 ? Colors.orange : Colors.green,
            ),
            StatusCard(
              title: 'Circuit Breakers',
              value: '${state.openCircuits} open',
              color: state.openCircuits > 0 ? Colors.red : Colors.green,
            ),
            StatusCard(
              title: 'Cache Age',
              value: _formatCacheAge(state.cacheAge),
              color: _getCacheAgeColor(state.cacheAge),
            ),
          ],
        );
      },
    );
  }
}
```

## Self-Healing Patterns

### Learning-Based Degradation

```dart
class LearningDegradationEngine {
  final DegradationHistory history;

  void enableLearning() {
    // Learn optimal degradation levels from history
    history.patternsStream.listen((patterns) {
      // Predict degradation needs
      if (patterns.networkPoorProbability > 0.7) {
        _preemptiveDegradation(DegradationLevel.reduced);
      }

      // Adjust thresholds based on effectiveness
      if (patterns.offlineModeEffectiveness > 0.9) {
        _increaseDegradationSensitivity();
      }
    });
  }

  void _preemptiveDegradation(DegradationLevel level) {
    FeatureDegradationManager.instance.degradeTo(level);

    ErrorManager.reportInfo(
      message: 'Preemptive degradation based on learned patterns',
      metadata: {'level': level.toString()},
    );
  }
}
```

---

**Agent Assignment**: Self-Healing Agent (Debug Orchestrator)
**Complementary Skill**: Auto-Recovery
**Integration Points**: ErrorRecoveryManager, ResilientFirestoreService, CircuitBreaker
**Success Metrics**: >99% uptime, >95% offline success, <3s degradation time
