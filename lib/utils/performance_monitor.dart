import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utility for tracking app performance metrics
///
/// Provides tools to monitor:
/// - Frame rendering performance (FPS)
/// - Memory usage tracking
/// - Operation timing
/// - Performance degradation detection
///
/// Usage:
/// ```dart
/// // Start FPS monitoring
/// PerformanceMonitor.instance.startFPSMonitoring();
///
/// // Time an operation
/// final stopwatch = PerformanceMonitor.instance.startTimer('loadLocals');
/// await loadLocals();
/// PerformanceMonitor.instance.stopTimer(stopwatch, 'loadLocals');
/// ```
class PerformanceMonitor {
  /// Singleton instance
  static final PerformanceMonitor instance = PerformanceMonitor._internal();

  PerformanceMonitor._internal();

  /// FPS monitoring active flag
  bool _fpsMonitoringActive = false;

  /// FPS threshold for warning (frames per second)
  static const double fpsWarningThreshold = 50.0;

  /// FPS threshold for critical (frames per second)
  static const double fpsCriticalThreshold = 30.0;

  /// List to store frame timings for analysis
  final List<double> _recentFPS = [];

  /// Maximum number of FPS samples to keep
  static const int maxFPSSamples = 100;

  /// Map to store operation timings
  final Map<String, List<int>> _operationTimings = {};

  /// Starts monitoring frame rendering performance
  ///
  /// Logs warnings when FPS drops below thresholds.
  /// Call [stopFPSMonitoring] to stop monitoring.
  void startFPSMonitoring() {
    if (_fpsMonitoringActive) {
      if (kDebugMode) {
        print('[PerformanceMonitor] FPS monitoring already active');
      }
      return;
    }

    _fpsMonitoringActive = true;
    _recentFPS.clear();

    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      if (!_fpsMonitoringActive) return;

      for (final timing in timings) {
        // Calculate FPS from frame duration
        final totalSpan = timing.totalSpan;
        final fps = 1000000.0 / totalSpan.inMicroseconds;

        // Store FPS sample
        _recentFPS.add(fps);
        if (_recentFPS.length > maxFPSSamples) {
          _recentFPS.removeAt(0);
        }

        // Log warnings for low FPS
        if (fps < fpsCriticalThreshold) {
          if (kDebugMode) {
            print('🔴 CRITICAL: Low FPS detected: ${fps.toStringAsFixed(1)} fps');
            print('  - Build time: ${timing.buildDuration.inMilliseconds}ms');
            print('  - Raster time: ${timing.rasterDuration.inMilliseconds}ms');
          }
        } else if (fps < fpsWarningThreshold) {
          if (kDebugMode) {
            print('⚠️  WARNING: Low FPS detected: ${fps.toStringAsFixed(1)} fps');
          }
        }
      }
    });

    if (kDebugMode) {
      print('[PerformanceMonitor] FPS monitoring started');
    }
  }

  /// Stops FPS monitoring
  void stopFPSMonitoring() {
    _fpsMonitoringActive = false;

    if (kDebugMode) {
      print('[PerformanceMonitor] FPS monitoring stopped');

      if (_recentFPS.isNotEmpty) {
        final avgFPS = _recentFPS.reduce((a, b) => a + b) / _recentFPS.length;
        final minFPS = _recentFPS.reduce((a, b) => a < b ? a : b);
        final maxFPS = _recentFPS.reduce((a, b) => a > b ? a : b);

        print('[PerformanceMonitor] FPS Statistics:');
        print('  - Average: ${avgFPS.toStringAsFixed(1)} fps');
        print('  - Min: ${minFPS.toStringAsFixed(1)} fps');
        print('  - Max: ${maxFPS.toStringAsFixed(1)} fps');
        print('  - Samples: ${_recentFPS.length}');
      }
    }
  }

  /// Gets current FPS statistics
  ///
  /// Returns null if monitoring is not active or no samples collected.
  Map<String, double>? getFPSStats() {
    if (_recentFPS.isEmpty) return null;

    final avgFPS = _recentFPS.reduce((a, b) => a + b) / _recentFPS.length;
    final minFPS = _recentFPS.reduce((a, b) => a < b ? a : b);
    final maxFPS = _recentFPS.reduce((a, b) => a > b ? a : b);

    return {
      'average': avgFPS,
      'min': minFPS,
      'max': maxFPS,
      'samples': _recentFPS.length.toDouble(),
    };
  }

  /// Starts a timer for measuring operation performance
  ///
  /// Returns a Stopwatch instance that should be passed to [stopTimer].
  ///
  /// Example:
  /// ```dart
  /// final stopwatch = PerformanceMonitor.instance.startTimer('fetchData');
  /// await fetchData();
  /// PerformanceMonitor.instance.stopTimer(stopwatch, 'fetchData');
  /// ```
  Stopwatch startTimer(String operationName) {
    final stopwatch = Stopwatch()..start();

    if (kDebugMode) {
      print('[PerformanceMonitor] Started timing: $operationName');
    }

    return stopwatch;
  }

  /// Stops a timer and logs the operation duration
  ///
  /// [stopwatch] - The Stopwatch instance from [startTimer]
  /// [operationName] - Name of the operation being timed
  /// [threshold] - Optional warning threshold in milliseconds
  void stopTimer(
    Stopwatch stopwatch,
    String operationName, {
    int? threshold,
  }) {
    stopwatch.stop();
    final durationMs = stopwatch.elapsedMilliseconds;

    // Store timing for later analysis
    _operationTimings.putIfAbsent(operationName, () => []);
    _operationTimings[operationName]!.add(durationMs);

    // Keep only last 100 timings per operation
    if (_operationTimings[operationName]!.length > 100) {
      _operationTimings[operationName]!.removeAt(0);
    }

    if (kDebugMode) {
      final icon = threshold != null && durationMs > threshold ? '⚠️ ' : '✅';
      print('$icon [PerformanceMonitor] $operationName: ${durationMs}ms');

      if (threshold != null && durationMs > threshold) {
        print('  - Exceeded threshold of ${threshold}ms by ${durationMs - threshold}ms');
      }
    }
  }

  /// Gets timing statistics for a specific operation
  ///
  /// Returns null if no timings recorded for the operation.
  Map<String, double>? getOperationStats(String operationName) {
    final timings = _operationTimings[operationName];
    if (timings == null || timings.isEmpty) return null;

    final sum = timings.reduce((a, b) => a + b);
    final avg = sum / timings.length;
    final min = timings.reduce((a, b) => a < b ? a : b);
    final max = timings.reduce((a, b) => a > b ? a : b);

    return {
      'average': avg.toDouble(),
      'min': min.toDouble(),
      'max': max.toDouble(),
      'total': sum.toDouble(),
      'count': timings.length.toDouble(),
    };
  }

  /// Logs all operation statistics
  void logAllStats() {
    if (kDebugMode) {
      print('\n📊 [PerformanceMonitor] Operation Statistics:');

      if (_operationTimings.isEmpty) {
        print('  No operations timed yet');
        return;
      }

      for (final entry in _operationTimings.entries) {
        final stats = getOperationStats(entry.key)!;
        print('\n  ${entry.key}:');
        print('    - Average: ${stats['average']!.toStringAsFixed(2)}ms');
        print('    - Min: ${stats['min']!.toStringAsFixed(0)}ms');
        print('    - Max: ${stats['max']!.toStringAsFixed(0)}ms');
        print('    - Total: ${stats['total']!.toStringAsFixed(0)}ms');
        print('    - Count: ${stats['count']!.toStringAsFixed(0)}');
      }

      // FPS stats if available
      final fpsStats = getFPSStats();
      if (fpsStats != null) {
        print('\n  Frame Rate (FPS):');
        print('    - Average: ${fpsStats['average']!.toStringAsFixed(1)} fps');
        print('    - Min: ${fpsStats['min']!.toStringAsFixed(1)} fps');
        print('    - Max: ${fpsStats['max']!.toStringAsFixed(1)} fps');
        print('    - Samples: ${fpsStats['samples']!.toStringAsFixed(0)}');
      }

      print('\n');
    }
  }

  /// Clears all recorded performance data
  void clear() {
    _operationTimings.clear();
    _recentFPS.clear();

    if (kDebugMode) {
      print('[PerformanceMonitor] Performance data cleared');
    }
  }

  /// Times an async operation and returns its result
  ///
  /// Convenience method that combines [startTimer] and [stopTimer].
  ///
  /// Example:
  /// ```dart
  /// final locals = await PerformanceMonitor.instance.timeOperation(
  ///   'loadLocals',
  ///   () => firestoreService.getLocals().first,
  ///   threshold: 1000, // Warn if takes > 1 second
  /// );
  /// ```
  Future<T> timeOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    int? threshold,
  }) async {
    final stopwatch = startTimer(operationName);
    try {
      return await operation();
    } finally {
      stopTimer(stopwatch, operationName, threshold: threshold);
    }
  }
}

/// Extension on BuildContext for easy performance monitoring
extension PerformanceMonitorExtension on BuildContext {
  /// Times a widget build operation
  ///
  /// Example:
  /// ```dart
  /// return context.timeWidgetBuild('LocalCard', () {
  ///   return Card(child: ...);
  /// });
  /// ```
  Widget timeWidgetBuild(String widgetName, Widget Function() builder) {
    final stopwatch = PerformanceMonitor.instance.startTimer('build_$widgetName');
    final widget = builder();
    PerformanceMonitor.instance.stopTimer(
      stopwatch,
      'build_$widgetName',
      threshold: 16, // Warn if build takes > 16ms (1 frame)
    );
    return widget;
  }
}
