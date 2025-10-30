import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/hierarchical/initialization_stage.dart';

/// Abstract interface for performance monitoring to break circular dependencies
abstract class IPerformanceMonitor {
  /// Start monitoring performance
  void startMonitoring();

  /// Stop monitoring performance
  void stopMonitoring();

  /// Record a performance metric
  void recordMetric(String name, dynamic value, {Map<String, dynamic>? context});

  /// Get metrics for a specific stage
  StageMetrics? getStageMetrics(String stage);

  /// Record stage error
  void recordStageError(String stage, dynamic error);

  /// Get elapsed time since monitoring started
  Duration? get elapsedTime;

  /// Reset monitor state
  void reset();

  /// Dispose resources
  void dispose();
}

/// Simple implementation of performance monitor that avoids circular dependencies
class SimplePerformanceMonitor implements IPerformanceMonitor {
  bool _isMonitoring = false;
  final Map<String, List<dynamic>> _metrics = {};
  DateTime? _startTime;

  @override
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _startTime = DateTime.now();
    debugPrint('[SimplePerformanceMonitor] Started monitoring');
  }

  @override
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    debugPrint('[SimplePerformanceMonitor] Stopped monitoring. Duration: ${duration.inMilliseconds}ms');
    _startTime = null;
  }

  @override
  void recordMetric(String name, dynamic value, {Map<String, dynamic>? context}) {
    if (!_metrics.containsKey(name)) {
      _metrics[name] = [];
    }

    _metrics[name]!.add({
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
    });

    // Keep only last 50 metrics per name
    if (_metrics[name]!.length > 50) {
      _metrics[name]!.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('[SimplePerformanceMonitor] $name: $value');
    }
  }

  @override
  StageMetrics? getStageMetrics(String stage) {
    final stageMetrics = _metrics['stage_$stage'];
    if (stageMetrics == null || stageMetrics.isEmpty) return null;

    // Create a simple StageMetrics object from our stored data
    return StageMetrics(
      stage: InitializationStage.values.firstWhere(
        (s) => s.toString() == stage,
        orElse: () => InitializationStage.firebaseCore, // fallback
      ),
      customMetrics: {
        'count': stageMetrics.length,
        'lastValue': stageMetrics.last['value'],
        'lastUpdated': stageMetrics.last['timestamp'],
      },
    );
  }

  @override
  void recordStageError(String stage, dynamic error) {
    recordMetric(
      'stage_error_$stage',
      error.toString(),
      context: {'type': 'error', 'stage': stage},
    );
  }

  @override
  Duration? get elapsedTime {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }

  @override
  void reset() {
    _metrics.clear();
    _isMonitoring = false;
    _startTime = null;
    debugPrint('[SimplePerformanceMonitor] Reset');
  }

  @override
  void dispose() {
    _metrics.clear();
    _isMonitoring = false;
    _startTime = null;
    debugPrint('[SimplePerformanceMonitor] Disposed');
  }

  /// Get all recorded metrics
  Map<String, List<dynamic>> get metrics => Map.unmodifiable(_metrics);

  /// Check if currently monitoring
  bool get isMonitoring => _isMonitoring;
}