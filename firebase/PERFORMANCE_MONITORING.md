# Firebase Performance Monitoring Strategy

## Overview
Comprehensive performance monitoring strategy for the Journeyman Jobs IBEW electrical worker application, focusing on database query optimization, storm response times, and crew coordination efficiency across 797+ IBEW locals.

## Key Performance Indicators (KPIs)

### Critical Performance Metrics

#### 🚨 Storm Emergency Response (P0 Priority)
- **Storm Job Discovery**: <100ms (25th percentile: 35ms, 95th percentile: 85ms)
- **Emergency Crew Mobilization**: <200ms (25th percentile: 75ms, 95th percentile: 180ms)
- **Weather Alert Processing**: <50ms (25th percentile: 15ms, 95th percentile: 45ms)
- **Critical Notification Delivery**: <30ms (25th percentile: 8ms, 95th percentile: 25ms)

#### ⚡ Job Search Performance (P1 Priority)
- **Local-based Job Search**: <200ms (25th percentile: 60ms, 95th percentile: 175ms)
- **Classification Filtering**: <150ms (25th percentile: 45ms, 95th percentile: 130ms)
- **Geographic Job Search**: <300ms (25th percentile: 100ms, 95th percentile: 280ms)
- **Wage-sorted Results**: <250ms (25th percentile: 80ms, 95th percentile: 220ms)

#### 👥 Crew Coordination (P1 Priority)
- **Crew Member Lookup**: <500ms (25th percentile: 150ms, 95th percentile: 450ms)
- **Availability Queries**: <300ms (25th percentile: 90ms, 95th percentile: 270ms)
- **Crew Messaging**: <200ms (25th percentile: 65ms, 95th percentile: 180ms)
- **Group Bid Processing**: <1000ms (25th percentile: 300ms, 95th percentile: 900ms)

#### 📍 Local Directory (P2 Priority)
- **State-based Local Search**: <200ms (25th percentile: 50ms, 95th percentile: 175ms)
- **Local Detail Retrieval**: <100ms (25th percentile: 30ms, 95th percentile: 85ms)
- **Classification Lookup**: <150ms (25th percentile: 40ms, 95th percentile: 130ms)

### Performance Targets Summary
```
🎯 Target Performance Levels:
├── Storm Emergency: 95% queries <100ms
├── Job Search: 85% queries <200ms
├── Crew Coordination: 90% queries <500ms
└── Local Directory: 98% queries <200ms
```

## Real-time Monitoring Setup

### Firebase Performance Monitoring Integration

#### 1. Performance SDK Configuration
```dart
// lib/services/performance_monitoring_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitoringService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  // Critical storm work monitoring
  static Future<T> monitorStormQuery<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace('storm_$operationName');
    await trace.start();

    try {
      final result = await operation();
      trace.putAttribute('query_success', 'true');
      return result;
    } catch (e) {
      trace.putAttribute('query_success', 'false');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  // Job search performance tracking
  static Future<T> monitorJobSearch<T>(
    String searchType,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace('job_search_$searchType');
    await trace.start();

    try {
      final result = await operation();
      trace.putAttribute('search_type', searchType);
      trace.putAttribute('results_found', 'true');
      return result;
    } finally {
      await trace.stop();
    }
  }
}
```

#### 2. Custom Metrics for IBEW Operations
```dart
class IBEWPerformanceMetrics {
  static final Map<String, Metric> _metrics = {};

  static void recordStormResponseTime(int milliseconds) {
    _getMetric('storm_response_time').putValue(milliseconds);
  }

  static void recordCrewCoordinationTime(int milliseconds) {
    _getMetric('crew_coordination_time').putValue(milliseconds);
  }

  static void recordLocalSearchTime(int milliseconds) {
    _getMetric('local_search_time').putValue(milliseconds);
  }

  static Metric _getMetric(String name) {
    return _metrics.putIfAbsent(
      name,
      () => FirebasePerformance.instance.newMetric(name),
    );
  }
}
```

### Query Performance Monitoring

#### Real-time Query Analysis
```dart
class QueryPerformanceAnalyzer {
  static const Map<String, int> performanceThresholds = {
    'storm_emergency': 100,     // Critical storm queries
    'job_search': 200,          // Standard job searches
    'crew_coordination': 500,   // Crew management queries
    'local_directory': 200,     // Local union lookups
  };

  static Future<QuerySnapshot> monitorQuery(
    Query query,
    String queryType,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await query.get();
      final duration = stopwatch.elapsedMilliseconds;

      // Log performance metrics
      _logQueryPerformance(queryType, duration, result.docs.length);

      // Alert if threshold exceeded
      if (duration > performanceThresholds[queryType]!) {
        _alertSlowQuery(queryType, duration);
      }

      return result;
    } finally {
      stopwatch.stop();
    }
  }

  static void _logQueryPerformance(String type, int duration, int resultCount) {
    print('Query Performance: $type - ${duration}ms - $resultCount results');

    // Send to analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'query_performance',
      parameters: {
        'query_type': type,
        'duration_ms': duration,
        'result_count': resultCount,
        'performance_grade': _getPerformanceGrade(type, duration),
      },
    );
  }

  static String _getPerformanceGrade(String type, int duration) {
    final threshold = performanceThresholds[type]!;
    if (duration <= threshold * 0.5) return 'excellent';
    if (duration <= threshold * 0.75) return 'good';
    if (duration <= threshold) return 'acceptable';
    return 'poor';
  }
}
```

## Index Performance Monitoring

### Index Utilization Tracking
```javascript
// Cloud Functions monitoring for index usage
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.monitorIndexUsage = functions.firestore
  .document('{collection}/{documentId}')
  .onWrite(async (change, context) => {
    const collection = context.params.collection;

    // Track index usage patterns
    await admin.firestore().collection('performance_metrics').add({
      collection: collection,
      operation: change.before.exists ? 'update' : 'create',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      indexesUsed: await getQueryIndexes(collection),
    });
  });

async function getQueryIndexes(collection) {
  // Monitor which indexes are being used for queries
  const recentQueries = await admin.firestore()
    .collection('query_logs')
    .where('collection', '==', collection)
    .where('timestamp', '>', new Date(Date.now() - 3600000)) // Last hour
    .get();

  return recentQueries.docs.map(doc => doc.data().indexUsed);
}
```

### Index Build Monitoring
```bash
#!/bin/bash
# firebase/scripts/monitor_index_builds.sh

echo "🔍 Monitoring Firestore Index Build Status"
echo "========================================"

# Check overall index status
echo "📊 Overall Index Status:"
firebase firestore:indexes

echo ""
echo "🚨 Failed Indexes:"
firebase firestore:indexes --filter="state:ERROR"

echo ""
echo "⏳ Building Indexes:"
firebase firestore:indexes --filter="state:CREATING"

echo ""
echo "✅ Active Indexes:"
firebase firestore:indexes --filter="state:READY" | head -20

# Alert if any storm-critical indexes are down
echo ""
echo "🌩️ Storm-Critical Index Health:"
firebase firestore:indexes --filter="collectionGroup:jobs" | grep "isStormWork\|urgency"
firebase firestore:indexes --filter="collectionGroup:crews" | grep "availableForStormWork\|availableForEmergencyWork"

# Performance metrics
echo ""
echo "📈 Performance Metrics:"
echo "Last updated: $(date)"
```

## Alert System Configuration

### Critical Performance Alerts

#### 1. Storm Emergency Alert Thresholds
```dart
class StormEmergencyAlerts {
  static const int criticalThreshold = 100; // ms
  static const int warningThreshold = 75;   // ms

  static void monitorStormQueries() {
    // Real-time monitoring for storm work queries
    Timer.periodic(Duration(seconds: 30), (timer) async {
      final avgResponseTime = await _getAverageStormResponseTime();

      if (avgResponseTime > criticalThreshold) {
        _sendCriticalAlert(
          'Storm query performance degraded: ${avgResponseTime}ms',
          AlertLevel.critical,
        );
      } else if (avgResponseTime > warningThreshold) {
        _sendWarningAlert(
          'Storm query performance warning: ${avgResponseTime}ms',
          AlertLevel.warning,
        );
      }
    });
  }

  static Future<void> _sendCriticalAlert(String message, AlertLevel level) async {
    // Send to monitoring systems
    await NotificationService.sendSystemAlert(
      title: '🚨 CRITICAL: Storm Response Performance',
      message: message,
      level: level,
      recipients: ['emergency-response-team', 'tech-leads'],
    );

    // Log to performance tracking
    await FirebaseAnalytics.instance.logEvent(
      name: 'performance_alert',
      parameters: {
        'alert_type': 'storm_emergency',
        'severity': level.toString(),
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

#### 2. Performance Dashboard Setup
```dart
class PerformanceDashboard {
  static Widget buildStormPerformanceWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('performance_metrics')
          .where('metric_type', isEqualTo: 'storm_response')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final metrics = snapshot.data!.docs;
        final avgResponseTime = _calculateAverageResponseTime(metrics);
        final statusColor = avgResponseTime < 100 ? Colors.green : Colors.red;

        return Card(
          child: Column(
            children: [
              Text('🚨 Storm Response Performance'),
              Text(
                '${avgResponseTime.toStringAsFixed(1)}ms avg',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPerformanceChart(metrics),
            ],
          ),
        );
      },
    );
  }
}
```

### Automated Performance Reports

#### Daily Performance Summary
```dart
// Cloud Functions - Daily performance report
exports.generateDailyPerformanceReport = functions.pubsub
  .schedule('0 6 * * *') // 6 AM daily
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);

    // Collect performance metrics
    const stormMetrics = await getStormPerformanceMetrics(yesterday);
    const jobSearchMetrics = await getJobSearchMetrics(yesterday);
    const crewMetrics = await getCrewCoordinationMetrics(yesterday);

    // Generate report
    const report = {
      date: yesterday.toISOString().split('T')[0],
      storm_emergency: {
        avg_response_time: stormMetrics.avgTime,
        queries_under_100ms: stormMetrics.fastQueries,
        total_storm_queries: stormMetrics.totalQueries,
        performance_grade: getPerformanceGrade(stormMetrics.avgTime, 100)
      },
      job_search: {
        avg_response_time: jobSearchMetrics.avgTime,
        queries_under_200ms: jobSearchMetrics.fastQueries,
        total_searches: jobSearchMetrics.totalSearches,
        performance_grade: getPerformanceGrade(jobSearchMetrics.avgTime, 200)
      },
      crew_coordination: {
        avg_response_time: crewMetrics.avgTime,
        queries_under_500ms: crewMetrics.fastQueries,
        total_operations: crewMetrics.totalOperations,
        performance_grade: getPerformanceGrade(crewMetrics.avgTime, 500)
      }
    };

    // Store report and send alerts
    await admin.firestore().collection('performance_reports').add(report);
    await sendPerformanceReport(report);
  });
```

## Query Optimization Monitoring

### Slow Query Detection
```dart
class SlowQueryDetector {
  static const Map<String, Duration> queryTimeouts = {
    'storm_emergency': Duration(milliseconds: 100),
    'job_search': Duration(milliseconds: 200),
    'crew_coordination': Duration(milliseconds: 500),
    'local_directory': Duration(milliseconds: 200),
  };

  static Future<T> executeWithTimeout<T>(
    String queryType,
    Future<T> Function() query,
  ) async {
    final timeout = queryTimeouts[queryType]!;

    try {
      return await query().timeout(timeout);
    } on TimeoutException {
      // Log slow query
      _logSlowQuery(queryType, timeout.inMilliseconds);

      // Attempt retry with extended timeout
      return await query().timeout(timeout * 2);
    }
  }

  static void _logSlowQuery(String queryType, int timeoutMs) {
    FirebaseAnalytics.instance.logEvent(
      name: 'slow_query_detected',
      parameters: {
        'query_type': queryType,
        'timeout_ms': timeoutMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Send alert for storm emergency timeouts
    if (queryType == 'storm_emergency') {
      NotificationService.sendSystemAlert(
        title: '🚨 CRITICAL: Storm Query Timeout',
        message: 'Storm emergency query exceeded ${timeoutMs}ms timeout',
        level: AlertLevel.critical,
      );
    }
  }
}
```

### Collection Scan Detection
```javascript
// Monitor for expensive collection scans
exports.monitorCollectionScans = functions.analytics
  .event('query_performance')
  .onLog(async (event) => {
    const queryData = event.data;

    if (queryData.collection_scan_detected) {
      await admin.firestore().collection('performance_alerts').add({
        alert_type: 'collection_scan',
        collection: queryData.collection,
        query_type: queryData.query_type,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        severity: 'high',
        message: `Collection scan detected in ${queryData.collection}`,
        recommendations: [
          'Create composite index',
          'Optimize query structure',
          'Consider query redesign'
        ]
      });

      // Auto-create index suggestion
      if (queryData.collection === 'jobs' && queryData.query_type === 'storm_emergency') {
        await suggestEmergencyIndex(queryData);
      }
    }
  });
```

## Performance Baseline Establishment

### Initial Performance Benchmarks
```dart
class PerformanceBaseline {
  static Map<String, PerformanceBaseline> baselines = {};

  final String queryType;
  final Duration p50Time;
  final Duration p95Time;
  final Duration p99Time;
  final DateTime establishedAt;

  PerformanceBaseline({
    required this.queryType,
    required this.p50Time,
    required this.p95Time,
    required this.p99Time,
    required this.establishedAt,
  });

  static Future<void> establishBaselines() async {
    // Storm emergency baseline
    baselines['storm_emergency'] = await _measurePerformance(
      'storm_emergency',
      () => _runStormEmergencyQueries(),
    );

    // Job search baseline
    baselines['job_search'] = await _measurePerformance(
      'job_search',
      () => _runJobSearchQueries(),
    );

    // Crew coordination baseline
    baselines['crew_coordination'] = await _measurePerformance(
      'crew_coordination',
      () => _runCrewCoordinationQueries(),
    );

    // Local directory baseline
    baselines['local_directory'] = await _measurePerformance(
      'local_directory',
      () => _runLocalDirectoryQueries(),
    );
  }

  static Future<PerformanceBaseline> _measurePerformance(
    String queryType,
    Future<void> Function() queryRunner,
  ) async {
    final List<Duration> measurements = [];

    // Run 100 test queries
    for (int i = 0; i < 100; i++) {
      final stopwatch = Stopwatch()..start();
      await queryRunner();
      stopwatch.stop();
      measurements.add(stopwatch.elapsed);
    }

    measurements.sort((a, b) => a.compareTo(b));

    return PerformanceBaseline(
      queryType: queryType,
      p50Time: measurements[49],  // 50th percentile
      p95Time: measurements[94],  // 95th percentile
      p99Time: measurements[98],  // 99th percentile
      establishedAt: DateTime.now(),
    );
  }
}
```

## Continuous Performance Optimization

### Auto-scaling Index Management
```javascript
// Auto-suggest new indexes based on query patterns
exports.analyzeQueryPatterns = functions.pubsub
  .schedule('0 */6 * * *') // Every 6 hours
  .onRun(async (context) => {
    const recentQueries = await getRecentSlowQueries();
    const indexSuggestions = await analyzeForIndexOpportunities(recentQueries);

    for (const suggestion of indexSuggestions) {
      if (suggestion.impact_score > 0.8) {
        await createIndexSuggestion(suggestion);

        // Auto-create critical storm indexes
        if (suggestion.query_type === 'storm_emergency' && suggestion.impact_score > 0.9) {
          await autoCreateCriticalIndex(suggestion);
        }
      }
    }
  });

async function analyzeForIndexOpportunities(queries) {
  const patterns = {};

  for (const query of queries) {
    const pattern = generateQueryPattern(query);
    if (!patterns[pattern]) {
      patterns[pattern] = {
        count: 0,
        avg_duration: 0,
        collections: new Set(),
        fields: new Set()
      };
    }

    patterns[pattern].count++;
    patterns[pattern].avg_duration += query.duration;
    patterns[pattern].collections.add(query.collection);
    query.fields.forEach(field => patterns[pattern].fields.add(field));
  }

  return Object.entries(patterns)
    .map(([pattern, data]) => ({
      pattern,
      frequency: data.count,
      avg_duration: data.avg_duration / data.count,
      impact_score: calculateImpactScore(data),
      suggested_index: generateIndexSuggestion(data)
    }))
    .filter(suggestion => suggestion.impact_score > 0.5)
    .sort((a, b) => b.impact_score - a.impact_score);
}
```

## Regional Performance Monitoring

### State-based Performance Tracking
```dart
class RegionalPerformanceMonitor {
  static Map<String, RegionalMetrics> stateMetrics = {};

  static void trackRegionalPerformance(String state, String queryType, int duration) {
    if (!stateMetrics.containsKey(state)) {
      stateMetrics[state] = RegionalMetrics(state: state);
    }

    stateMetrics[state]!.addMetric(queryType, duration);

    // Alert if regional performance degrades
    if (duration > getRegionalThreshold(state, queryType)) {
      _alertRegionalPerformanceDegradation(state, queryType, duration);
    }
  }

  static int getRegionalThreshold(String state, String queryType) {
    // Higher thresholds for states with more IBEW locals
    final localCount = IBEWLocalDirectory.getLocalCountForState(state);
    final baseThreshold = performanceThresholds[queryType] ?? 200;

    // Scale threshold based on local density
    if (localCount > 20) return (baseThreshold * 1.2).round();
    if (localCount > 10) return (baseThreshold * 1.1).round();
    return baseThreshold;
  }
}

class RegionalMetrics {
  final String state;
  final Map<String, List<int>> queryMetrics = {};

  RegionalMetrics({required this.state});

  void addMetric(String queryType, int duration) {
    queryMetrics.putIfAbsent(queryType, () => []).add(duration);

    // Keep only recent metrics (last 1000 measurements)
    if (queryMetrics[queryType]!.length > 1000) {
      queryMetrics[queryType]!.removeAt(0);
    }
  }

  double getAverageResponseTime(String queryType) {
    final metrics = queryMetrics[queryType];
    if (metrics == null || metrics.isEmpty) return 0.0;

    return metrics.reduce((a, b) => a + b) / metrics.length;
  }
}
```

## Success Metrics and Reporting

### Weekly Performance Review
```dart
class WeeklyPerformanceReport {
  static Future<Map<String, dynamic>> generateWeeklyReport() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 7));

    final report = {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'storm_emergency': await _getStormMetrics(startDate, endDate),
      'job_search': await _getJobSearchMetrics(startDate, endDate),
      'crew_coordination': await _getCrewMetrics(startDate, endDate),
      'local_directory': await _getLocalMetrics(startDate, endDate),
      'regional_breakdown': await _getRegionalBreakdown(startDate, endDate),
      'index_health': await _getIndexHealthMetrics(),
      'recommendations': await _generateRecommendations(),
    };

    return report;
  }

  static Future<Map<String, dynamic>> _getStormMetrics(DateTime start, DateTime end) async {
    final metrics = await PerformanceMetricsService.getMetrics(
      'storm_emergency',
      start,
      end,
    );

    return {
      'total_queries': metrics.length,
      'avg_response_time': metrics.map((m) => m.duration).reduce((a, b) => a + b) / metrics.length,
      'queries_under_100ms': metrics.where((m) => m.duration < 100).length,
      'performance_grade': _calculateGrade(metrics, 100),
      'worst_performing_regions': _getWorstRegions(metrics),
      'improvement_suggestions': _getImprovementSuggestions(metrics),
    };
  }
}
```

## Documentation and Training

### Performance Monitoring Runbooks
1. **Storm Emergency Response**: Step-by-step procedures for handling performance issues during storm events
2. **Index Optimization**: Guidelines for creating and maintaining optimal indexes
3. **Alert Response**: Escalation procedures for different alert levels
4. **Capacity Planning**: Forecasting and scaling procedures

### Performance Training Materials
1. **Firebase Performance Best Practices**: Training for development team
2. **IBEW-Specific Optimizations**: Domain-specific performance considerations
3. **Storm Response Protocols**: Emergency performance procedures
4. **Monitoring Dashboard Usage**: How to interpret and act on performance data

---

**Implementation Timeline**: 2-week phased rollout
**Review Cycle**: Weekly during first month, then monthly
**Success Criteria**: 95% queries meet target performance thresholds
**Emergency Contact**: Performance team on-call rotation