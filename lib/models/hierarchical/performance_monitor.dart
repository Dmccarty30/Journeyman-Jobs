import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'initialization_stage.dart';

/// Performance monitoring for initialization stages
///
/// Tracks execution times, memory usage, and performance metrics
/// to identify bottlenecks and optimize initialization.
class PerformanceMonitor {
  PerformanceMonitor({
    Duration sampleInterval = const Duration(milliseconds: 100),
    int maxSampleCount = 1000,
  }) : _sampleInterval = sampleInterval,
       _maxSampleCount = maxSampleCount;

  final Duration _sampleInterval;
  final int _maxSampleCount;

  // Performance tracking
  final Map<InitializationStage, StageMetrics> _stageMetrics = {};
  final List<PerformanceSample> _samples = [];
  final Queue<double> _memoryUsageHistory = Queue<double>();

  // Timing
  Stopwatch? _stopwatch;
  Timer? _samplingTimer;

  bool _isMonitoring = false;
  bool _isDisposed = false;

  /// Gets total elapsed monitoring time
  Duration get elapsedTime {
    return _stopwatch?.elapsed ?? Duration.zero;
  }

  /// Gets average memory usage during monitoring
  double get averageMemoryUsage {
    if (_memoryUsageHistory.isEmpty) return 0.0;
    return _memoryUsageHistory.reduce((a, b) => a + b) / _memoryUsageHistory.length;
  }

  /// Gets peak memory usage during monitoring
  double get peakMemoryUsage {
    if (_memoryUsageHistory.isEmpty) return 0.0;
    return _memoryUsageHistory.reduce(math.max);
  }

  /// Starts performance monitoring
  void startMonitoring() {
    if (_isDisposed || _isMonitoring) return;

    _isMonitoring = true;
    _stopwatch = Stopwatch()..start();

    // Start periodic sampling
    _samplingTimer = Timer.periodic(_sampleInterval, (_) {
      if (!_isDisposed) {
        _collectSample();
      }
    });

    debugPrint('[PerformanceMonitor] Started monitoring');
  }

  /// Stops performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _stopwatch?.stop();
    _samplingTimer?.cancel();

    debugPrint('[PerformanceMonitor] Stopped monitoring after ${elapsedTime.inMilliseconds}ms');
  }

  /// Gets performance metrics for a specific stage
  Future<StageMetrics?> getStageMetrics(InitializationStage stage) async {
    return _stageMetrics[stage];
  }

  /// Gets overall performance statistics
  PerformanceStats getStats() {
    final stageMetrics = Map.fromEntries(
      _stageMetrics.entries.map((entry) => MapEntry(
        entry.key,
        entry.value,
      )),
    );

    return PerformanceStats(
      totalDuration: elapsedTime,
      averageMemoryUsage: averageMemoryUsage,
      peakMemoryUsage: peakMemoryUsage,
      sampleCount: _samples.length,
      stageMetrics: stageMetrics,
    );
  }

  /// Records stage start
  void recordStageStart(InitializationStage stage) {
    if (_isDisposed) return;

    final metrics = StageMetrics(
      stage: stage,
      customMetrics: {
        'startTime': DateTime.now().toIso8601String(),
      },
    );

    _stageMetrics[stage] = metrics;
  }

  /// Records stage completion
  void recordStageComplete(InitializationStage stage) {
    if (_isDisposed) return;

    final metrics = _stageMetrics[stage];
    if (metrics == null) return;

    final startTime = DateTime.parse(metrics.customMetrics?['startTime'] ?? DateTime.now().toIso8601String());
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final completedMetrics = StageMetrics(
      stage: stage,
      customMetrics: {
        ...?metrics.customMetrics,
        'endTime': endTime.toIso8601String(),
        'duration': duration.inMilliseconds,
      },
    );

    _stageMetrics[stage] = completedMetrics;

    debugPrint('[PerformanceMonitor] Stage $stage completed in ${duration.inMilliseconds}ms');
  }

  /// Records memory usage at a specific point
  void recordMemoryUsage(double memoryUsageMB) {
    if (_isDisposed) return;

    _memoryUsageHistory.add(memoryUsageMB);

    // Keep only recent samples
    while (_memoryUsageHistory.length > _maxSampleCount) {
      _memoryUsageHistory.removeFirst();
    }
  }

  /// Analyzes performance and provides recommendations
  List<PerformanceRecommendation> analyzePerformance() {
    final recommendations = <PerformanceRecommendation>[];

    // Analyze overall performance
    if (elapsedTime.inMilliseconds > 5000) {
      recommendations.add(PerformanceRecommendation(
        type: RecommendationType.optimization,
        severity: RecommendationSeverity.high,
        message: 'Initialization time exceeds 5 seconds',
        suggestion: 'Consider implementing lazy loading or parallel execution',
      ));
    }

    // Analyze memory usage
    if (peakMemoryUsage > 100) {
      recommendations.add(PerformanceRecommendation(
        type: RecommendationType.memory,
        severity: RecommendationSeverity.medium,
        message: 'High memory usage detected: ${peakMemoryUsage.toStringAsFixed(1)}MB',
        suggestion: 'Consider implementing memory optimization techniques',
      ));
    }

    // Analyze individual stages
    for (final entry in _stageMetrics.entries) {
      final stage = entry.key;
      final metrics = entry.value;

      final durationMs = metrics.customMetrics?['duration'] as int?;
      if (durationMs != null) {
        final estimatedMs = stage.estimatedMs;
        final actualMs = durationMs;

        if (actualMs > estimatedMs * 1.5) {
          recommendations.add(PerformanceRecommendation(
            type: RecommendationType.stage,
            severity: RecommendationSeverity.medium,
            message: 'Stage $stage exceeded estimated time by ${(actualMs / estimatedMs).toStringAsFixed(1)}x',
            suggestion: 'Review stage implementation for performance bottlenecks',
            affectedStage: stage,
          ));
        }
      }
    }

    return recommendations;
  }

  /// Generates a performance report
  String generateReport() {
    final buffer = StringBuffer();
    final stats = getStats();
    final recommendations = analyzePerformance();

    buffer.writeln('=== Initialization Performance Report ===');
    buffer.writeln('Total Duration: ${stats.totalDuration.inMilliseconds}ms');
    buffer.writeln('Average Memory: ${stats.averageMemoryUsage.toStringAsFixed(1)}MB');
    buffer.writeln('Peak Memory: ${stats.peakMemoryUsage.toStringAsFixed(1)}MB');
    buffer.writeln('Sample Count: ${stats.sampleCount}');
    buffer.writeln();

    buffer.writeln('=== Stage Performance ===');
    for (final entry in stats.stageMetrics.entries) {
      final stage = entry.key;
      final metrics = entry.value;

      buffer.writeln('${stage.name}:');
      buffer.writeln('  Estimated: ${stage.estimatedMs}ms');

      final durationMs = metrics.customMetrics?['duration'] as int?;
      if (durationMs != null) {
        final actualMs = durationMs;
        final ratio = actualMs / stage.estimatedMs;
        buffer.writeln('  Actual: ${actualMs}ms (${ratio.toStringAsFixed(1)}x estimate)');
      } else {
        buffer.writeln('  Actual: Not completed');
      }

      buffer.writeln();
    }

    if (recommendations.isNotEmpty) {
      buffer.writeln('=== Recommendations ===');
      for (final rec in recommendations) {
        buffer.writeln('[${rec.severity.name.toUpperCase()}] ${rec.message}');
        buffer.writeln('  Suggestion: ${rec.suggestion}');
        if (rec.affectedStage != null) {
          buffer.writeln('  Affected Stage: ${rec.affectedStage!.name}');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Resets performance monitoring
  void reset() {
    _stageMetrics.clear();
    _samples.clear();
    _memoryUsageHistory.clear();
    _stopwatch?.reset();
    debugPrint('[PerformanceMonitor] Reset');
  }

  /// Disposes the performance monitor
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _isMonitoring = false;
    _stopwatch?.stop();
    _samplingTimer?.cancel();

    _stageMetrics.clear();
    _samples.clear();
    _memoryUsageHistory.clear();

    debugPrint('[PerformanceMonitor] Disposed');
  }

  void _collectSample() {
    final timestamp = DateTime.now();
    final memoryUsage = _getCurrentMemoryUsage();

    final sample = PerformanceSample(
      timestamp: timestamp,
      memoryUsageMB: memoryUsage,
      elapsedMs: elapsedTime.inMilliseconds,
    );

    _samples.add(sample);
    recordMemoryUsage(memoryUsage);

    // Keep only recent samples
    while (_samples.length > _maxSampleCount) {
      _samples.removeAt(0);
    }
  }

  double _getCurrentMemoryUsage() {
    // In a real implementation, this would use platform-specific APIs
    // to get actual memory usage. For now, we'll simulate it.
    final baseUsage = 50.0; // Base app memory usage
    final variation = math.Random().nextDouble() * 20; // Random variation
    return baseUsage + variation;
  }
}

/// Performance sample collected at regular intervals
@immutable
class PerformanceSample {
  const PerformanceSample({
    required this.timestamp,
    required this.memoryUsageMB,
    required this.elapsedMs,
  });

  final DateTime timestamp;
  final double memoryUsageMB;
  final int elapsedMs;
}

/// Overall performance statistics
@immutable
class PerformanceStats {
  const PerformanceStats({
    required this.totalDuration,
    required this.averageMemoryUsage,
    required this.peakMemoryUsage,
    required this.sampleCount,
    required this.stageMetrics,
  });

  final Duration totalDuration;
  final double averageMemoryUsage;
  final double peakMemoryUsage;
  final int sampleCount;
  final Map<InitializationStage, StageMetrics> stageMetrics;

  int get completedStages => stageMetrics.values
      .where((metrics) => metrics.customMetrics?['duration'] != null)
      .length;
}

/// Performance recommendation
@immutable
class PerformanceRecommendation {
  const PerformanceRecommendation({
    required this.type,
    required this.severity,
    required this.message,
    required this.suggestion,
    this.affectedStage,
  });

  final RecommendationType type;
  final RecommendationSeverity severity;
  final String message;
  final String suggestion;
  final InitializationStage? affectedStage;
}

/// Recommendation types
enum RecommendationType {
  optimization,
  memory,
  stage,
  configuration,
}

/// Recommendation severity levels
enum RecommendationSeverity {
  low,
  medium,
  high,
  critical,
}