import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_metadata.dart';

/// Performance monitoring system for hierarchical initialization
///
/// Provides comprehensive performance tracking including:
/// - Stage timing and duration analysis
/// - Memory usage monitoring
/// - Network request counting
/// - Cache hit rate tracking
/// - Bottleneck identification
/// - Performance optimization suggestions
class PerformanceMonitor {
  PerformanceMonitor({
    Duration monitoringInterval = const Duration(milliseconds: 100),
    int maxHistorySize = 1000,
  }) : _monitoringInterval = monitoringInterval,
       _maxHistorySize = maxHistorySize;

  final Duration _monitoringInterval;
  final int _maxHistorySize;

  // Timing data
  final Map<InitializationStage, StageTimingData> _stageTimings = {};
  final List<PerformanceSnapshot> _history = [];
  final Queue<PerformanceSnapshot> _recentSnapshots = Queue();

  // Monitoring state
  Stopwatch? _stopwatch;
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  DateTime _startTime = DateTime.now();
  DateTime? _endTime;

  // Performance metrics
  double _currentMemoryUsage = 0.0;
  int _totalNetworkRequests = 0;
  int _totalCacheHits = 0;
  int _totalCacheMisses = 0;

  /// Current elapsed time since monitoring started
  Duration get elapsedTime {
    if (_stopwatch == null) return Duration.zero;
    return _stopwatch!.elapsed;
  }

  /// Whether monitoring is currently active
  bool get isMonitoring => _isMonitoring;

  /// Gets stage-specific metrics
  StageMetrics? getStageMetrics(InitializationStage stage) {
    final timing = _stageTimings[stage];
    if (timing == null) return null;

    return StageMetrics(
      stage: stage,
      memoryUsageMB: timing.peakMemoryUsage,
      networkRequests: timing.networkRequests,
      cacheHits: timing.cacheHits,
      customMetrics: {
        'cacheMisses': timing.cacheMisses,
        'errorCount': timing.errorCount,
        'duration': timing.duration?.inMilliseconds,
      },
    );
  }

  /// Gets current performance snapshot
  PerformanceSnapshot get currentSnapshot {
    return PerformanceSnapshot(
      timestamp: DateTime.now(),
      elapsedTime: elapsedTime,
      memoryUsageMB: _currentMemoryUsage,
      networkRequests: _totalNetworkRequests,
      cacheHits: _totalCacheHits,
      cacheMisses: _totalCacheMisses,
      activeStages: _stageTimings.values.where((t) => t.isActive).length,
      completedStages: _stageTimings.values.where((t) => t.isCompleted).length,
    );
  }

  /// Starts performance monitoring
  void startMonitoring() {
    if (_isMonitoring) {
      debugPrint('[PerformanceMonitor] Already monitoring');
      return;
    }

    _isMonitoring = true;
    _startTime = DateTime.now();
    _stopwatch = Stopwatch()..start();

    // Start periodic monitoring
    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) {
      _collectPerformanceSnapshot();
    });

    debugPrint('[PerformanceMonitor] Started monitoring');
  }

  /// Stops performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) {
      debugPrint('[PerformanceMonitor] Not monitoring');
      return;
    }

    _isMonitoring = false;
    _endTime = DateTime.now();
    _stopwatch?.stop();
    _monitoringTimer?.cancel();

    // Collect final snapshot
    _collectPerformanceSnapshot();

    debugPrint('[PerformanceMonitor] Stopped monitoring after ${elapsedTime.inMilliseconds}ms');
  }

  /// Records stage start
  void recordStageStart(InitializationStage stage) {
    final timing = StageTimingData(
      stage: stage,
      startTime: DateTime.now(),
      endTime: null,
      networkRequests: 0,
      cacheHits: 0,
      cacheMisses: 0,
      errorCount: 0,
      startMemoryUsage: _currentMemoryUsage,
      peakMemoryUsage: _currentMemoryUsage,
    );

    _stageTimings[stage] = timing;
    debugPrint('[PerformanceMonitor] Started timing for stage: ${stage.displayName}');
  }

  /// Records stage completion
  void recordStageCompletion(InitializationStage stage, StageMetrics? metrics) {
    final timing = _stageTimings[stage];
    if (timing == null) {
      debugPrint('[PerformanceMonitor] No timing data for stage: ${stage.displayName}');
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(timing.startTime!);

    _stageTimings[stage] = timing.copyWith(
      endTime: endTime,
      duration: duration,
      metrics: metrics,
    );

    debugPrint('[PerformanceMonitor] Completed timing for stage: ${stage.displayName} '
              'in ${duration.inMilliseconds}ms');
  }

  /// Records network request for a stage
  void recordNetworkRequest(InitializationStage stage) {
    _totalNetworkRequests++;

    final timing = _stageTimings[stage];
    if (timing != null) {
      _stageTimings[stage] = timing.copyWith(
        networkRequests: timing.networkRequests + 1,
      );
    }
  }

  /// Records cache hit for a stage
  void recordCacheHit(InitializationStage stage) {
    _totalCacheHits++;

    final timing = _stageTimings[stage];
    if (timing != null) {
      _stageTimings[stage] = timing.copyWith(
        cacheHits: timing.cacheHits + 1,
      );
    }
  }

  /// Records cache miss for a stage
  void recordCacheMiss(InitializationStage stage) {
    _totalCacheMisses++;

    final timing = _stageTimings[stage];
    if (timing != null) {
      _stageTimings[stage] = timing.copyWith(
        cacheMisses: timing.cacheMisses + 1,
      );
    }
  }

  /// Records error for a stage
  void recordError(InitializationStage stage) {
    final timing = _stageTimings[stage];
    if (timing != null) {
      _stageTimings[stage] = timing.copyWith(
        errorCount: timing.errorCount + 1,
      );
    }
  }

  /// Records stage error with exception details
  void recordStageError(InitializationStage stage, dynamic error) {
    recordError(stage); // Reuse the existing error recording logic
    debugPrint('[PerformanceMonitor] Recorded error for stage ${stage.displayName}: $error');
  }

  /// Updates current memory usage
  void updateMemoryUsage(double memoryUsageMB) {
    _currentMemoryUsage = memoryUsageMB;

    // Update peak memory usage for active stages
    for (final stage in _stageTimings.keys) {
      final timing = _stageTimings[stage]!;
      if (timing.isActive && memoryUsageMB > timing.peakMemoryUsage) {
        _stageTimings[stage] = timing.copyWith(
          peakMemoryUsage: memoryUsageMB,
        );
      }
    }
  }

  /// Gets comprehensive performance analysis
  PerformanceAnalysis getAnalysis() {
    final snapshots = List<PerformanceSnapshot>.from(_history);
    if (snapshots.isEmpty) {
      return PerformanceAnalysis.empty();
    }

    // Calculate timing statistics
    final completedStages = _stageTimings.values.where((t) => t.isCompleted).toList();
    final totalStages = _stageTimings.length;

    Duration averageStageTime = Duration.zero;
    Duration fastestStage = const Duration(hours: 24);
    Duration slowestStage = Duration.zero;
    InitializationStage? slowestStageName;
    InitializationStage? fastestStageName;

    if (completedStages.isNotEmpty) {
      final totalDuration = completedStages.fold<Duration>(
        Duration.zero,
        (sum, timing) => sum + (timing.duration ?? Duration.zero),
      );
      averageStageTime = Duration(
        milliseconds: (totalDuration.inMilliseconds / completedStages.length).round(),
      );

      for (final timing in completedStages) {
        final duration = timing.duration ?? Duration.zero;
        if (duration < fastestStage) {
          fastestStage = duration;
          fastestStageName = timing.stage;
        }
        if (duration > slowestStage) {
          slowestStage = duration;
          slowestStageName = timing.stage;
        }
      }
    }

    // Calculate memory statistics
    final memoryUsages = snapshots.map((s) => s.memoryUsageMB).toList();
    final averageMemoryUsage = memoryUsages.isEmpty ? 0.0 :
        memoryUsages.reduce((a, b) => a + b) / memoryUsages.length;
    final peakMemoryUsage = memoryUsages.isEmpty ? 0.0 :
        memoryUsages.reduce(math.max);

    // Calculate network statistics
    final totalNetworkRequests = _totalNetworkRequests;
    final averageNetworkPerStage = completedStages.isNotEmpty ?
        totalNetworkRequests / completedStages.length : 0.0;

    // Calculate cache efficiency
    final totalCacheRequests = _totalCacheHits + _totalCacheMisses;
    final cacheHitRate = totalCacheRequests > 0 ?
        _totalCacheHits / totalCacheRequests : 0.0;

    // Identify bottlenecks
    final bottlenecks = _identifyBottlenecks();

    // Generate optimization suggestions
    final suggestions = _generateOptimizationSuggestions();

    return PerformanceAnalysis(
      totalDuration: elapsedTime,
      averageStageTime: averageStageTime,
      fastestStage: fastestStageName != null ? (fastestStageName!, fastestStage) : null,
      slowestStage: slowestStageName != null ? (slowestStageName!, slowestStage) : null,
      completedStages: completedStages.length,
      totalStages: totalStages,
      averageMemoryUsage: averageMemoryUsage,
      peakMemoryUsage: peakMemoryUsage,
      totalNetworkRequests: totalNetworkRequests,
      averageNetworkPerStage: averageNetworkPerStage,
      cacheHitRate: cacheHitRate,
      bottlenecks: bottlenecks,
      suggestions: suggestions,
      snapshots: snapshots,
    );
  }

  /// Gets real-time performance metrics
  RealTimeMetrics getRealTimeMetrics() {
    final currentSnapshot = this.currentSnapshot;

    // Calculate memory trend
    double memoryTrend = 0.0;
    if (_recentSnapshots.length >= 2) {
      final recent = List<PerformanceSnapshot>.from(_recentSnapshots);
      recent.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final oldest = recent.first;
      final newest = recent.last;
      final timeDiff = newest.timestamp.difference(oldest.timestamp).inMilliseconds;
      if (timeDiff > 0) {
        memoryTrend = (newest.memoryUsageMB - oldest.memoryUsageMB) / timeDiff * 1000; // MB per second
      }
    }

    return RealTimeMetrics(
      memoryUsageMB: currentSnapshot.memoryUsageMB,
      memoryTrendMBPerSec: memoryTrend,
      networkRequestsPerSec: _calculateNetworkRequestRate(),
      cacheHitRate: _calculateCacheHitRate(),
      activeStages: currentSnapshot.activeStages,
      completionRate: _calculateCompletionRate(),
      estimatedTimeRemaining: _estimateTimeRemaining(),
    );
  }

  /// Resets performance monitoring data
  void reset() {
    _stageTimings.clear();
    _history.clear();
    _recentSnapshots.clear();

    _currentMemoryUsage = 0.0;
    _totalNetworkRequests = 0;
    _totalCacheHits = 0;
    _totalCacheMisses = 0;

    _startTime = DateTime.now();
    _endTime = null;

    debugPrint('[PerformanceMonitor] Reset performance data');
  }

  /// Disposes performance monitor
  void dispose() {
    stopMonitoring();
    reset();
    debugPrint('[PerformanceMonitor] Disposed');
  }

  // Private methods

  /// Collects performance snapshot
  void _collectPerformanceSnapshot() {
    final snapshot = currentSnapshot;

    _history.add(snapshot);
    _recentSnapshots.add(snapshot);

    // Maintain history size limits
    if (_history.length > _maxHistorySize) {
      _history.removeRange(0, _history.length - _maxHistorySize);
    }

    // Keep only recent snapshots (last 50)
    while (_recentSnapshots.length > 50) {
      _recentSnapshots.removeFirst();
    }
  }

  /// Identifies performance bottlenecks
  List<PerformanceBottleneck> _identifyBottlenecks() {
    final bottlenecks = <PerformanceBottleneck>[];
    final completedStages = _stageTimings.values.where((t) => t.isCompleted).toList();

    if (completedStages.isEmpty) return bottlenecks;

    // Calculate average duration
    final totalDuration = completedStages.fold<Duration>(
      Duration.zero,
      (sum, timing) => sum + (timing.duration ?? Duration.zero),
    );
    final averageDuration = Duration(
      milliseconds: (totalDuration.inMilliseconds / completedStages.length).round(),
    );

    // Find stages that are significantly slower than average
    for (final timing in completedStages) {
      final duration = timing.duration ?? Duration.zero;
      final ratio = duration.inMilliseconds / averageDuration.inMilliseconds;

      if (ratio > 2.0) { // More than 2x slower than average
        bottlenecks.add(PerformanceBottleneck(
          stage: timing.stage,
          type: BottleneckType.slowExecution,
          severity: ratio > 4.0 ? BottleneckSeverity.high : BottleneckSeverity.medium,
          description: 'Stage takes ${ratio.toStringAsFixed(1)}x longer than average',
          impact: ratio,
        ));
      }
    }

    // Check for high memory usage stages
    for (final timing in completedStages) {
      if (timing.peakMemoryUsage > 100.0) { // More than 100MB
        bottlenecks.add(PerformanceBottleneck(
          stage: timing.stage,
          type: BottleneckType.highMemoryUsage,
          severity: timing.peakMemoryUsage > 200.0 ?
              BottleneckSeverity.high : BottleneckSeverity.medium,
          description: 'Stage uses ${timing.peakMemoryUsage.toStringAsFixed(1)}MB memory',
          impact: timing.peakMemoryUsage,
        ));
      }
    }

    // Check for high network usage stages
    for (final timing in completedStages) {
      if (timing.networkRequests > 10) { // More than 10 network requests
        bottlenecks.add(PerformanceBottleneck(
          stage: timing.stage,
          type: BottleneckType.excessiveNetworkRequests,
          severity: timing.networkRequests > 20 ?
              BottleneckSeverity.high : BottleneckSeverity.medium,
          description: 'Stage makes ${timing.networkRequests} network requests',
          impact: timing.networkRequests.toDouble(),
        ));
      }
    }

    // Sort by impact (descending)
    bottlenecks.sort((a, b) => b.impact.compareTo(a.impact));

    return bottlenecks;
  }

  /// Generates optimization suggestions
  List<OptimizationSuggestion> _generateOptimizationSuggestions() {
    final suggestions = <OptimizationSuggestion>[];
    final bottlenecks = _identifyBottlenecks();

    // Analyze bottlenecks and generate suggestions
    for (final bottleneck in bottlenecks) {
      switch (bottleneck.type) {
        case BottleneckType.slowExecution:
          suggestions.add(OptimizationSuggestion(
            type: SuggestionType.optimizeStage,
            title: 'Optimize ${bottleneck.stage.displayName}',
            description: 'This stage is significantly slower than average. Consider optimizing data loading, reducing computations, or implementing caching.',
            impact: SuggestionImpact.high,
            estimatedImprovement: bottleneck.impact * 0.3, // Could improve by 30%
          ));
          break;

        case BottleneckType.highMemoryUsage:
          suggestions.add(OptimizationSuggestion(
            type: SuggestionType.reduceMemoryUsage,
            title: 'Reduce memory usage in ${bottleneck.stage.displayName}',
            description: 'This stage uses excessive memory. Consider streaming data, using more efficient data structures, or implementing memory pooling.',
            impact: SuggestionImpact.medium,
            estimatedImprovement: bottleneck.impact * 0.2, // Could improve by 20%
          ));
          break;

        case BottleneckType.excessiveNetworkRequests:
          suggestions.add(OptimizationSuggestion(
            type: SuggestionType.optimizeNetwork,
            title: 'Optimize network requests in ${bottleneck.stage.displayName}',
            description: 'This stage makes many network requests. Consider batching requests, using GraphQL, or implementing better caching strategies.',
            impact: SuggestionImpact.medium,
            estimatedImprovement: bottleneck.impact * 0.4, // Could improve by 40%
          ));
          break;

        case BottleneckType.lowCacheHitRate:
          suggestions.add(OptimizationSuggestion(
            type: SuggestionType.improveCaching,
            title: 'Improve cache hit rate in ${bottleneck.stage.displayName}',
            description: 'This stage has a low cache hit rate. Consider implementing better caching strategies or cache warming.',
            impact: SuggestionImpact.medium,
            estimatedImprovement: bottleneck.impact * 0.25, // Could improve by 25%
          ));
          break;
      }
    }

    // General suggestions based on overall performance
    final analysis = getAnalysis();

    if (analysis.cacheHitRate < 0.5) {
      suggestions.add(OptimizationSuggestion(
        type: SuggestionType.improveCaching,
        title: 'Improve cache hit rate',
        description: 'Current cache hit rate is ${(analysis.cacheHitRate * 100).toStringAsFixed(1)}%. Implement better caching strategies to reduce network requests.',
        impact: SuggestionImpact.high,
        estimatedImprovement: 0.3, // Could improve by 30%
      ));
    }

    if (analysis.averageMemoryUsage > 50.0) {
      suggestions.add(OptimizationSuggestion(
        type: SuggestionType.reduceMemoryUsage,
        title: 'Reduce overall memory usage',
        description: 'Average memory usage is ${analysis.averageMemoryUsage.toStringAsFixed(1)}MB. Consider memory optimization techniques.',
        impact: SuggestionImpact.medium,
        estimatedImprovement: 0.2, // Could improve by 20%
      ));
    }

    return suggestions;
  }

  /// Calculates network request rate
  double _calculateNetworkRequestRate() {
    if (_recentSnapshots.length < 2) return 0.0;

    final recent = List<PerformanceSnapshot>.from(_recentSnapshots);
    recent.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final oldest = recent.first;
    final newest = recent.last;
    final timeDiff = newest.timestamp.difference(oldest.timestamp).inSeconds;

    if (timeDiff <= 0) return 0.0;

    final requestDiff = newest.networkRequests - oldest.networkRequests;
    return requestDiff / timeDiff;
  }

  /// Calculates cache hit rate
  double _calculateCacheHitRate() {
    final total = _totalCacheHits + _totalCacheMisses;
    return total > 0 ? _totalCacheHits / total : 0.0;
  }

  /// Calculates completion rate
  double _calculateCompletionRate() {
    final total = _stageTimings.length;
    final completed = _stageTimings.values.where((t) => t.isCompleted).length;
    return total > 0 ? completed / total : 0.0;
  }

  /// Estimates remaining time
  Duration _estimateTimeRemaining() {
    final total = _stageTimings.length;
    final completed = _stageTimings.values.where((t) => t.isCompleted).length;

    if (completed == 0) return Duration.zero;

    final completedTimings = _stageTimings.values
        .where((t) => t.isCompleted)
        .map((t) => t.duration ?? Duration.zero)
        .toList();

    if (completedTimings.isEmpty) return Duration.zero;

    final totalMs = completedTimings.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    final averageDuration = Duration(milliseconds: totalMs ~/ completedTimings.length);

    final remaining = total - completed;
    return Duration(milliseconds: (averageDuration.inMilliseconds * remaining).round());
  }
}

/// Timing data for a single stage
@immutable
class StageTimingData {
  const StageTimingData({
    required this.stage,
    required this.startTime,
    this.endTime,
    this.duration,
    this.networkRequests = 0,
    this.cacheHits = 0,
    this.cacheMisses = 0,
    this.errorCount = 0,
    this.startMemoryUsage = 0.0,
    this.peakMemoryUsage = 0.0,
    this.metrics,
  });

  final InitializationStage stage;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;
  final int networkRequests;
  final int cacheHits;
  final int cacheMisses;
  final int errorCount;
  final double startMemoryUsage;
  final double peakMemoryUsage;
  final StageMetrics? metrics;

  bool get isActive => startTime != null && endTime == null;
  bool get isCompleted => startTime != null && endTime != null;
  bool get hasErrors => errorCount > 0;

  double get memoryGrowth => peakMemoryUsage - startMemoryUsage;
  double get cacheHitRate => (cacheHits + cacheMisses) > 0 ?
      cacheHits / (cacheHits + cacheMisses) : 0.0;

  StageTimingData copyWith({
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    int? networkRequests,
    int? cacheHits,
    int? cacheMisses,
    int? errorCount,
    double? startMemoryUsage,
    double? peakMemoryUsage,
    StageMetrics? metrics,
  }) {
    return StageTimingData(
      stage: stage,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      networkRequests: networkRequests ?? this.networkRequests,
      cacheHits: cacheHits ?? this.cacheHits,
      cacheMisses: cacheMisses ?? this.cacheMisses,
      errorCount: errorCount ?? this.errorCount,
      startMemoryUsage: startMemoryUsage ?? this.startMemoryUsage,
      peakMemoryUsage: peakMemoryUsage ?? this.peakMemoryUsage,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  String toString() {
    return 'StageTimingData('
        'stage: ${stage.displayName}, '
        'duration: ${duration?.inMilliseconds ?? 0}ms, '
        'networkRequests: $networkRequests, '
        'cacheHitRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
        'memoryGrowth: ${memoryGrowth.toStringAsFixed(1)}MB'
        ')';
  }
}

/// Performance snapshot at a point in time
@immutable
class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.timestamp,
    required this.elapsedTime,
    required this.memoryUsageMB,
    required this.networkRequests,
    required this.cacheHits,
    required this.cacheMisses,
    required this.activeStages,
    required this.completedStages,
  });

  final DateTime timestamp;
  final Duration elapsedTime;
  final double memoryUsageMB;
  final int networkRequests;
  final int cacheHits;
  final int cacheMisses;
  final int activeStages;
  final int completedStages;

  double get cacheHitRate => (cacheHits + cacheMisses) > 0 ?
      cacheHits / (cacheHits + cacheMisses) : 0.0;

  @override
  String toString() {
    return 'PerformanceSnapshot('
        'elapsed: ${elapsedTime.inMilliseconds}ms, '
        'memory: ${memoryUsageMB.toStringAsFixed(1)}MB, '
        'network: $networkRequests, '
        'cacheRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// Comprehensive performance analysis
@immutable
class PerformanceAnalysis {
  const PerformanceAnalysis({
    required this.totalDuration,
    required this.averageStageTime,
    required this.fastestStage,
    required this.slowestStage,
    required this.completedStages,
    required this.totalStages,
    required this.averageMemoryUsage,
    required this.peakMemoryUsage,
    required this.totalNetworkRequests,
    required this.averageNetworkPerStage,
    required this.cacheHitRate,
    required this.bottlenecks,
    required this.suggestions,
    required this.snapshots,
  });

  final Duration totalDuration;
  final Duration averageStageTime;
  final (InitializationStage, Duration)? fastestStage;
  final (InitializationStage, Duration)? slowestStage;
  final int completedStages;
  final int totalStages;
  final double averageMemoryUsage;
  final double peakMemoryUsage;
  final int totalNetworkRequests;
  final double averageNetworkPerStage;
  final double cacheHitRate;
  final List<PerformanceBottleneck> bottlenecks;
  final List<OptimizationSuggestion> suggestions;
  final List<PerformanceSnapshot> snapshots;

  bool get isComplete => completedStages == totalStages;
  bool get hasBottlenecks => bottlenecks.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  double get completionRate => totalStages > 0 ? completedStages / totalStages : 0.0;

  factory PerformanceAnalysis.empty() {
    return PerformanceAnalysis(
      totalDuration: Duration.zero,
      averageStageTime: Duration.zero,
      fastestStage: null,
      slowestStage: null,
      completedStages: 0,
      totalStages: 0,
      averageMemoryUsage: 0.0,
      peakMemoryUsage: 0.0,
      totalNetworkRequests: 0,
      averageNetworkPerStage: 0.0,
      cacheHitRate: 0.0,
      bottlenecks: [],
      suggestions: [],
      snapshots: [],
    );
  }

  @override
  String toString() {
    return 'PerformanceAnalysis('
        'totalDuration: ${totalDuration.inMilliseconds}ms, '
        'completedStages: $completedStages/$totalStages, '
        'averageMemory: ${averageMemoryUsage.toStringAsFixed(1)}MB, '
        'cacheHitRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
        'bottlenecks: ${bottlenecks.length}, '
        'suggestions: ${suggestions.length}'
        ')';
  }
}

/// Real-time performance metrics
@immutable
class RealTimeMetrics {
  const RealTimeMetrics({
    required this.memoryUsageMB,
    required this.memoryTrendMBPerSec,
    required this.networkRequestsPerSec,
    required this.cacheHitRate,
    required this.activeStages,
    required this.completionRate,
    required this.estimatedTimeRemaining,
  });

  final double memoryUsageMB;
  final double memoryTrendMBPerSec;
  final double networkRequestsPerSec;
  final double cacheHitRate;
  final int activeStages;
  final double completionRate;
  final Duration estimatedTimeRemaining;

  bool get isMemoryIncreasing => memoryTrendMBPerSec > 1.0;
  bool get isMemoryDecreasing => memoryTrendMBPerSec < -1.0;
  bool get hasGoodCachePerformance => cacheHitRate > 0.8;
  bool get isNearlyComplete => completionRate > 0.9;

  @override
  String toString() {
    return 'RealTimeMetrics('
        'memory: ${memoryUsageMB.toStringAsFixed(1)}MB, '
        'memoryTrend: ${memoryTrendMBPerSec.toStringAsFixed(2)}MB/s, '
        'networkRate: ${networkRequestsPerSec.toStringAsFixed(1)}/s, '
        'cacheRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
        'activeStages: $activeStages, '
        'completion: ${(completionRate * 100).toStringAsFixed(1)}%, '
        'remaining: ${estimatedTimeRemaining.inMilliseconds}ms'
        ')';
  }
}

/// Performance bottleneck information
@immutable
class PerformanceBottleneck {
  const PerformanceBottleneck({
    required this.stage,
    required this.type,
    required this.severity,
    required this.description,
    required this.impact,
  });

  final InitializationStage stage;
  final BottleneckType type;
  final BottleneckSeverity severity;
  final String description;
  final double impact;

  @override
  String toString() {
    return 'PerformanceBottleneck('
        'stage: ${stage.displayName}, '
        'type: $type, '
        'severity: $severity, '
        'impact: ${impact.toStringAsFixed(2)}'
        ')';
  }
}

/// Bottleneck types
enum BottleneckType {
  slowExecution,
  highMemoryUsage,
  excessiveNetworkRequests,
  lowCacheHitRate,
}

/// Bottleneck severity levels
enum BottleneckSeverity {
  low,
  medium,
  high,
  critical,
}

/// Optimization suggestion
@immutable
class OptimizationSuggestion {
  const OptimizationSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.impact,
    required this.estimatedImprovement,
  });

  final SuggestionType type;
  final String title;
  final String description;
  final SuggestionImpact impact;
  final double estimatedImprovement; // 0.0 to 1.0

  @override
  String toString() {
    return 'OptimizationSuggestion('
        'type: $type, '
        'impact: $impact, '
        'improvement: ${(estimatedImprovement * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// Suggestion types
enum SuggestionType {
  optimizeStage,
  improveCaching,
  reduceMemoryUsage,
  optimizeNetwork,
  parallelExecution,
  prefetchData,
}

/// Suggestion impact levels
enum SuggestionImpact {
  low,
  medium,
  high,
  critical,
}