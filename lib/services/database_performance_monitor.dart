import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Database performance monitoring service for Firestore operations
///
/// Tracks query performance, identifies bottlenecks, and provides analytics
/// for database optimization. Includes automatic performance alerts and
/// detailed metrics for troubleshooting.
class DatabasePerformanceMonitor {
  static final DatabasePerformanceMonitor _instance = DatabasePerformanceMonitor._internal();
  factory DatabasePerformanceMonitor() => _instance;
  DatabasePerformanceMonitor._internal();

  // Performance metrics storage
  final Map<String, QueryMetrics> _queryMetrics = {};
  final List<PerformanceAlert> _alerts = [];
  final StreamController<PerformanceAlert> _alertController = StreamController.broadcast();

  // Performance thresholds (in milliseconds)
  static const Duration _slowQueryThreshold = Duration(milliseconds: 1000);
  static const Duration _verySlowQueryThreshold = Duration(milliseconds: 3000);
  static const Duration _criticalQueryThreshold = Duration(milliseconds: 5000);

  // Maximum number of metrics to keep in memory
  static const int _maxMetricsEntries = 1000;

  /// Stream of performance alerts
  Stream<PerformanceAlert> get alerts => _alertController.stream;

  /// Start monitoring a database query
  ///
  /// Returns a [QueryMonitor] that should be used to track the query execution
  QueryMonitor startQuery({
    required String queryName,
    required String operation,
    Map<String, dynamic>? parameters,
    String? collection,
  }) {
    return QueryMonitor(
      queryName: queryName,
      operation: operation,
      parameters: parameters ?? {},
      collection: collection,
      onStart: _recordQueryStart,
      onComplete: _recordQueryComplete,
      onError: _recordQueryError,
    );
  }

  /// Record the start of a query execution
  void _recordQueryStart(String queryId, QueryMetrics metrics) {
    _queryMetrics[queryId] = metrics;

    if (kDebugMode) {
      print('🔍 Database Monitor: Started query $queryId');
      print('   Operation: ${metrics.operation}');
      print('   Collection: ${metrics.collection}');
    }
  }

  /// Record successful query completion
  void _recordQueryComplete(String queryId, List<QueryDocumentSnapshot> results) {
    final metrics = _queryMetrics[queryId];
    if (metrics == null) return;

    final duration = DateTime.now().difference(metrics.startTime);
    final endTime = DateTime.now();

    // Update metrics
    metrics
      ..duration = duration
      ..endTime = endTime
      ..resultCount = results.length
      ..success = true
      ..error = null;

    // Check for performance issues
    _checkPerformanceThresholds(queryId, metrics);

    // Log completion
    if (kDebugMode) {
      print('✅ Database Monitor: Query $queryId completed');
      print('   Duration: ${duration.inMilliseconds}ms');
      print('   Results: ${results.length} documents');
      print('   Collection: ${metrics.collection}');
    }

    // Clean up old metrics periodically
    _cleanupOldMetrics();
  }

  /// Record query error
  void _recordQueryComplete(String queryId, List<QueryDocumentSnapshot> results) {
    final metrics = _queryMetrics[queryId];
    if (metrics == null) return;

    final duration = DateTime.now().difference(metrics.startTime);
    final endTime = DateTime.now();

    // Update metrics
    metrics
      ..duration = duration
      ..endTime = endTime
      ..resultCount = results.length
      ..success = true
      ..error = null;

    // Check for performance issues
    _checkPerformanceThresholds(queryId, metrics);

    // Log completion
    if (kDebugMode) {
      print('✅ Database Monitor: Query $queryId completed');
      print('   Duration: ${duration.inMilliseconds}ms');
      print('   Results: ${results.length} documents');
      print('   Collection: ${metrics.collection}');
    }

    // Clean up old metrics periodically
    _cleanupOldMetrics();
  }

  /// Record query error
  void _recordQueryError(String queryId, dynamic error) {
    final metrics = _queryMetrics[queryId];
    if (metrics == null) return;

    final duration = DateTime.now().difference(metrics.startTime);
    final endTime = DateTime.now();

    // Update metrics
    metrics
      ..duration = duration
      ..endTime = endTime
      ..resultCount = 0
      ..success = false
      ..error = error.toString();

    // Create error alert
    final alert = PerformanceAlert(
      type: AlertType.error,
      queryName: metrics.queryName,
      message: 'Query failed: ${error.toString()}',
      timestamp: DateTime.now(),
      duration: duration,
      queryId: queryId,
    );

    _addAlert(alert);

    if (kDebugMode) {
      print('❌ Database Monitor: Query $queryId failed');
      print('   Error: $error');
      print('   Duration: ${duration.inMilliseconds}ms');
    }
  }

  /// Check query performance against thresholds and create alerts
  void _checkPerformanceThresholds(String queryId, QueryMetrics metrics) {
    if (!metrics.success) return;

    final duration = metrics.duration!;

    if (duration > _criticalQueryThreshold) {
      final alert = PerformanceAlert(
        type: AlertType.critical,
        queryName: metrics.queryName,
        message: 'Query took ${duration.inMilliseconds}ms (>${_criticalQueryThreshold.inMilliseconds}ms)',
        timestamp: DateTime.now(),
        duration: duration,
        queryId: queryId,
        recommendation: _getOptimizationRecommendation(metrics),
      );
      _addAlert(alert);
    } else if (duration > _verySlowQueryThreshold) {
      final alert = PerformanceAlert(
        type: AlertType.warning,
        queryName: metrics.queryName,
        message: 'Query took ${duration.inMilliseconds}ms (>${_verySlowQueryThreshold.inMilliseconds}ms)',
        timestamp: DateTime.now(),
        duration: duration,
        queryId: queryId,
      );
      _addAlert(alert);
    } else if (duration > _slowQueryThreshold) {
      final alert = PerformanceAlert(
        type: AlertType.info,
        queryName: metrics.queryName,
        message: 'Query took ${duration.inMilliseconds}ms (>${_slowQueryThreshold.inMilliseconds}ms)',
        timestamp: DateTime.now(),
        duration: duration,
        queryId: queryId,
      );
      _addAlert(alert);
    }
  }

  /// Get optimization recommendation based on query metrics
  String _getOptimizationRecommendation(QueryMetrics metrics) {
    final recommendations = <String>[];

    if (metrics.resultCount > 100) {
      recommendations.add('Consider adding pagination (limit: 20-50 documents)');
    }

    if (metrics.parameters.containsKey('where') &&
        metrics.parameters['where'] is Map &&
        (metrics.parameters['where'] as Map).length < 2) {
      recommendations.add('Add more specific filters to reduce result set');
    }

    if (metrics.collection == 'jobs' && !metrics.parameters.containsKey('index')) {
      recommendations.add('Ensure composite index exists for query pattern');
    }

    if (metrics.parameters.containsKey('orderBy') &&
        metrics.parameters['orderBy'] is List &&
        (metrics.parameters['orderBy'] as List).length == 1) {
      recommendations.add('Consider compound ordering for better index utilization');
    }

    if (recommendations.isEmpty) {
      return 'Review query complexity and consider result caching';
    }

    return recommendations.join('; ');
  }

  /// Add performance alert to the list and notify listeners
  void _addAlert(PerformanceAlert alert) {
    _alerts.add(alert);

    // Keep only recent alerts (last 100)
    if (_alerts.length > 100) {
      _alerts.removeRange(0, _alerts.length - 100);
    }

    _alertController.add(alert);
  }

  /// Clean up old metrics to prevent memory leaks
  void _cleanupOldMetrics() {
    if (_queryMetrics.length > _maxMetricsEntries) {
      final entriesToRemove = _queryMetrics.entries.take(_maxMetricsEntries ~/ 4);
      for (final entry in entriesToRemove) {
        _queryMetrics.remove(entry.key);
      }
    }
  }

  /// Get performance summary for all queries
  PerformanceSummary getPerformanceSummary() {
    final completedQueries = _queryMetrics.values.where((m) => m.duration != null).toList();

    if (completedQueries.isEmpty) {
      return PerformanceSummary(
        totalQueries: 0,
        averageDuration: Duration.zero,
        slowestQuery: null,
        fastestQuery: null,
        errorRate: 0.0,
        recentAlerts: List.from(_alerts),
      );
    }

    final durations = completedQueries.map((m) => m.duration!).toList();
    durations.sort();

    final totalDuration = durations.fold(Duration.zero, (sum, d) => sum + d);
    final averageDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ durations.length,
    );

    final errorCount = completedQueries.where((m) => !m.success!).length;
    final errorRate = errorCount / completedQueries.length;

    return PerformanceSummary(
      totalQueries: completedQueries.length,
      averageDuration: averageDuration,
      slowestQuery: completedQueries.reduce((a, b) =>
          (a.duration?.inMilliseconds ?? 0) > (b.duration?.inMilliseconds ?? 0) ? a : b),
      fastestQuery: completedQueries.reduce((a, b) =>
          (a.duration?.inMilliseconds ?? 0) < (b.duration?.inMilliseconds ?? 0) ? a : b),
      errorRate: errorRate,
      recentAlerts: List.from(_alerts.take(10)),
    );
  }

  /// Get metrics for a specific query name
  List<QueryMetrics> getQueryMetrics(String queryName) {
    return _queryMetrics.values
        .where((m) => m.queryName == queryName)
        .toList()
      ..sort((a, b) => (b.startTime).compareTo(a.startTime));
  }

  /// Get recent alerts with optional filtering
  List<PerformanceAlert> getRecentAlerts({
    AlertType? type,
    Duration? since,
    int? limit,
  }) {
    var alerts = List<PerformanceAlert>.from(_alerts);

    if (type != null) {
      alerts = alerts.where((a) => a.type == type).toList();
    }

    if (since != null) {
      final cutoff = DateTime.now().subtract(since);
      alerts = alerts.where((a) => a.timestamp.isAfter(cutoff)).toList();
    }

    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && limit > 0) {
      alerts = alerts.take(limit).toList();
    }

    return alerts;
  }

  /// Clear all monitoring data
  void clearData() {
    _queryMetrics.clear();
    _alerts.clear();
  }

  /// Dispose the monitor and clean up resources
  void dispose() {
    _alertController.close();
    clearData();
  }
}

/// Monitor class for tracking individual query execution
class QueryMonitor {
  final String queryId;
  final String queryName;
  final String operation;
  final Map<String, dynamic> parameters;
  final String? collection;
  final DateTime startTime;
  final void Function(String, QueryMetrics) onStart;
  final void Function(String, List<QueryDocumentSnapshot>) onComplete;
  final void Function(String, dynamic) onError;

  QueryMonitor({
    required this.queryName,
    required this.operation,
    required this.parameters,
    this.collection,
    required this.onStart,
    required this.onComplete,
    required this.onError,
  }) : queryId = '${queryName}_${DateTime.now().millisecondsSinceEpoch}',
       startTime = DateTime.now() {

    final metrics = QueryMetrics(
      queryId: queryId,
      queryName: queryName,
      operation: operation,
      parameters: parameters,
      collection: collection,
      startTime: startTime,
    );

    onStart(queryId, metrics);
  }

  /// Complete the query with results
  void complete(List<QueryDocumentSnapshot> results) {
    onComplete(queryId, results);
  }

  /// Record an error for the query
  void error(dynamic error) {
    onError(queryId, error);
  }
}

/// Metrics data for a single query execution
class QueryMetrics {
  final String queryId;
  final String queryName;
  final String operation;
  final Map<String, dynamic> parameters;
  final String? collection;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;
  int? resultCount;
  bool success = false;
  String? error;

  QueryMetrics({
    required this.queryId,
    required this.queryName,
    required this.operation,
    required this.parameters,
    this.collection,
    required this.startTime,
  });
}

/// Performance alert for database issues
class PerformanceAlert {
  final AlertType type;
  final String queryName;
  final String message;
  final DateTime timestamp;
  final Duration duration;
  final String queryId;
  final String? recommendation;

  PerformanceAlert({
    required this.type,
    required this.queryName,
    required this.message,
    required this.timestamp,
    required this.duration,
    required this.queryId,
    this.recommendation,
  });
}

/// Alert severity levels
enum AlertType {
  info,      // Informational (slow queries)
  warning,   // Warning (very slow queries)
  critical,  // Critical (extremely slow queries)
  error,     // Error (query failed)
}

/// Performance summary for monitoring dashboard
class PerformanceSummary {
  final int totalQueries;
  final Duration averageDuration;
  final QueryMetrics? slowestQuery;
  final QueryMetrics? fastestQuery;
  final double errorRate;
  final List<PerformanceAlert> recentAlerts;

  const PerformanceSummary({
    required this.totalQueries,
    required this.averageDuration,
    this.slowestQuery,
    this.fastestQuery,
    required this.errorRate,
    required this.recentAlerts,
  });
}