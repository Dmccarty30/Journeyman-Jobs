import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring and tracking performance metrics across the app
class PerformanceMonitoringService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Track Firestore query performance with detailed metrics
  static void trackQueryPerformance(
    String queryType,
    Duration executionTime,
    int documentCount, {
    Map<String, dynamic>? additionalMetrics,
  }) {
    try {
      // Create performance trace
      final trace = _performance.newTrace('firestore_query_$queryType');
      trace.setMetric('execution_time_ms', executionTime.inMilliseconds);
      trace.setMetric('document_count', documentCount);
      trace.setMetric('cost_reads', documentCount); // Approximate cost in reads
      
      // Add performance threshold indicators
      trace.setMetric('is_fast', executionTime.inMilliseconds < 500 ? 1 : 0);
      trace.setMetric('is_slow', executionTime.inMilliseconds > 2000 ? 1 : 0);
      
      // Add additional metrics if provided
      if (additionalMetrics != null) {
        for (final entry in additionalMetrics.entries) {
          if (entry.value is int) {
            trace.setMetric(entry.key, entry.value as int);
          }
        }
      }
      
      trace.stop();

      // Also log to analytics for historical tracking
      _analytics.logEvent(
        name: 'query_performance',
        parameters: {
          'query_type': queryType,
          'execution_time_ms': executionTime.inMilliseconds,
          'document_count': documentCount,
          'efficiency_score': _calculateEfficiencyScore(executionTime, documentCount),
        },
      );
    } catch (e) {
      debugPrint('Failed to track query performance: $e');
    }
  }

  /// Track screen load performance
  static void trackScreenLoad(String screenName, Duration loadTime) {
    try {
      final trace = _performance.newTrace('screen_load_$screenName');
      trace.setMetric('load_time_ms', loadTime.inMilliseconds);
      trace.setMetric('is_acceptable', loadTime.inMilliseconds < 2000 ? 1 : 0);
      trace.setMetric('needs_optimization', loadTime.inMilliseconds > 3000 ? 1 : 0);
      trace.stop();

      _analytics.logEvent(
        name: 'screen_load_performance',
        parameters: {
          'screen_name': screenName,
          'load_time_ms': loadTime.inMilliseconds,
          'performance_grade': _getPerformanceGrade(loadTime),
        },
      );
    } catch (e) {
      debugPrint('Failed to track screen load: $e');
    }
  }

  /// Track cache performance metrics
  static void trackCachePerformance(
    String cacheType, 
    bool hit, 
    Duration responseTime, {
    int? cacheSize,
    String? operation,
  }) {
    try {
      _analytics.logEvent(
        name: 'cache_performance',
        parameters: {
          'cache_type': cacheType,
          'hit': hit,
          'response_time_ms': responseTime.inMilliseconds,
          'cache_size': cacheSize ?? 0,
          'operation': operation ?? 'read',
          'efficiency': hit ? 'high' : 'low',
        },
      );

      // Create trace for cache operations
      final trace = _performance.newTrace('cache_operation_$cacheType');
      trace.setMetric('response_time_ms', responseTime.inMilliseconds);
      trace.setMetric('cache_hit', hit ? 1 : 0);
      trace.setMetric('cache_miss', hit ? 0 : 1);
      if (cacheSize != null) {
        trace.setMetric('cache_size', cacheSize);
      }
      trace.stop();
    } catch (e) {
      debugPrint('Failed to track cache performance: $e');
    }
  }

  /// Track offline usage patterns
  static void trackOfflineUsage(
    int jobsAvailable, 
    int localsAvailable, {
    Duration? syncDuration,
    String? syncTrigger,
  }) {
    try {
      final coverage = _calculateOfflineCoverage(jobsAvailable, localsAvailable);
      
      _analytics.logEvent(
        name: 'offline_usage',
        parameters: {
          'offline_jobs_count': jobsAvailable,
          'offline_locals_count': localsAvailable,
          'offline_coverage': coverage,
          'sync_duration_ms': syncDuration?.inMilliseconds ?? 0,
          'sync_trigger': syncTrigger ?? 'automatic',
          'data_freshness': _getDataFreshnessScore(jobsAvailable, localsAvailable),
        },
      );
    } catch (e) {
      debugPrint('Failed to track offline usage: $e');
    }
  }

  /// Track memory usage and app performance
  static void trackMemoryUsage({
    required int memoryUsageMB,
    required String context,
    int? activeUsers,
    int? loadedJobs,
  }) {
    try {
      _analytics.logEvent(
        name: 'memory_performance',
        parameters: {
          'memory_usage_mb': memoryUsageMB,
          'context': context,
          'active_users': activeUsers ?? 0,
          'loaded_jobs': loadedJobs ?? 0,
          'memory_efficiency': memoryUsageMB < 100 ? 'good' : 
                              memoryUsageMB < 150 ? 'acceptable' : 'poor',
        },
      );
    } catch (e) {
      debugPrint('Failed to track memory usage: $e');
    }
  }

  /// Track user interaction performance
  static void trackUserInteraction({
    required String action,
    required Duration responseTime,
    String? screen,
    Map<String, dynamic>? context,
  }) {
    try {
      final trace = _performance.newTrace('user_interaction_$action');
      trace.setMetric('response_time_ms', responseTime.inMilliseconds);
      trace.setMetric('is_responsive', responseTime.inMilliseconds < 100 ? 1 : 0);
      trace.setMetric('is_laggy', responseTime.inMilliseconds > 500 ? 1 : 0);
      trace.stop();

      final parameters = <String, dynamic>{
        'action': action,
        'response_time_ms': responseTime.inMilliseconds,
        'screen': screen ?? 'unknown',
        'responsiveness': _getResponsivenessRating(responseTime),
      };

      if (context != null) {
        parameters.addAll(context);
      }

      _analytics.logEvent(name: 'user_interaction', parameters: parameters.cast<String, Object>());
    } catch (e) {
      debugPrint('Failed to track user interaction: $e');
    }
  }

  /// Track data synchronization performance
  static void trackDataSync({
    required String syncType,
    required Duration duration,
    required int itemsSynced,
    required bool success,
    String? errorMessage,
  }) {
    try {
      final trace = _performance.newTrace('data_sync_$syncType');
      trace.setMetric('sync_duration_ms', duration.inMilliseconds);
      trace.setMetric('items_synced', itemsSynced);
      trace.setMetric('success', success ? 1 : 0);
      trace.setMetric('sync_rate', itemsSynced > 0 ? duration.inMilliseconds ~/ itemsSynced : 0);
      trace.stop();

      _analytics.logEvent(
        name: 'data_sync_performance',
        parameters: {
          'sync_type': syncType,
          'duration_ms': duration.inMilliseconds,
          'items_synced': itemsSynced,
          'success': success,
          'error_message': errorMessage ?? '',
          'sync_efficiency': _calculateSyncEfficiency(duration, itemsSynced),
        },
      );
    } catch (e) {
      debugPrint('Failed to track data sync: $e');
    }
  }

  /// Create a custom trace for specific operations
  static Trace? createCustomTrace(String traceName) {
    try {
      return _performance.newTrace(traceName);
    } catch (e) {
      debugPrint('Failed to create custom trace: $e');
      return null;
    }
  }

  // Helper methods for calculating metrics

  static double _calculateEfficiencyScore(Duration executionTime, int documentCount) {
    if (documentCount == 0) return 0.0;
    
    // Score based on time per document (lower is better)
    final timePerDoc = executionTime.inMilliseconds / documentCount;
    
    if (timePerDoc < 10) return 100.0;      // Excellent
    if (timePerDoc < 25) return 80.0;       // Good
    if (timePerDoc < 50) return 60.0;       // Acceptable
    if (timePerDoc < 100) return 40.0;      // Poor
    return 20.0;                            // Very poor
  }

  static String _getPerformanceGrade(Duration loadTime) {
    final ms = loadTime.inMilliseconds;
    if (ms < 1000) return 'A';
    if (ms < 2000) return 'B';
    if (ms < 3000) return 'C';
    if (ms < 5000) return 'D';
    return 'F';
  }

  static String _calculateOfflineCoverage(int jobs, int locals) {
    if (jobs > 50 && locals > 100) return 'excellent';
    if (jobs > 20 && locals > 50) return 'good';
    if (jobs > 10 && locals > 25) return 'acceptable';
    return 'limited';
  }

  static String _getDataFreshnessScore(int jobs, int locals) {
    final totalData = jobs + locals;
    if (totalData > 150) return 'fresh';
    if (totalData > 75) return 'acceptable';
    if (totalData > 25) return 'stale';
    return 'very_stale';
  }

  static String _getResponsivenessRating(Duration responseTime) {
    final ms = responseTime.inMilliseconds;
    if (ms < 100) return 'excellent';
    if (ms < 300) return 'good';
    if (ms < 500) return 'acceptable';
    if (ms < 1000) return 'poor';
    return 'very_poor';
  }

  static String _calculateSyncEfficiency(Duration duration, int itemsSynced) {
    if (itemsSynced == 0) return 'failed';
    
    final itemsPerSecond = itemsSynced / duration.inSeconds;
    if (itemsPerSecond > 10) return 'excellent';
    if (itemsPerSecond > 5) return 'good';
    if (itemsPerSecond > 2) return 'acceptable';
    return 'poor';
  }

  /// Enable/disable performance monitoring
  static Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Failed to set performance collection: $e');
    }
  }

  /// Get current performance collection status
  static Future<bool> isPerformanceCollectionEnabled() async {
    try {
      return await _performance.isPerformanceCollectionEnabled();
    } catch (e) {
      debugPrint('Failed to get performance collection status: $e');
      return false;
    }
  }
}