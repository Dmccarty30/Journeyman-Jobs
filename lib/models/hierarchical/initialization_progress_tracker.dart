import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'initialization_stage.dart';
import 'hierarchical_types.dart';
import 'initialization_dependency_graph.dart';

/// Progress tracking for initialization stages
///
/// Provides real-time progress updates with time estimates,
/// stage completion status, and error information.
class InitializationProgressTracker {
  InitializationProgressTracker({
    InitializationStrategy strategy = InitializationStrategy.adaptive,
    InitializationDependencyGraph? dependencyGraph,
  }) : _strategy = strategy,
       _dependencyGraph = dependencyGraph ?? InitializationDependencyGraph();

  InitializationStrategy _strategy;
  InitializationDependencyGraph _dependencyGraph;

  // Progress state
  final Map<InitializationStage, StageProgress> _stageProgress = {};
  final Set<InitializationStage> _completedStages = {};
  final Set<InitializationStage> _inProgressStages = {};
  final Set<InitializationStage> _failedStages = {};

  // Timing
  DateTime? _startTime;
  DateTime? _endTime;
  Duration _totalEstimatedDuration = Duration.zero;

  // Controllers
  final StreamController<InitializationProgress> _progressController =
      StreamController<InitializationProgress>.broadcast();

  bool _isInitialized = false;
  String? _currentError;

  /// Stream of progress updates
  Stream<InitializationProgress> get progressStream => _progressController.stream;

  /// Current progress snapshot
  InitializationProgress get currentProgress {
    final totalStages = InitializationStage.values.length;
    final completedStages = _completedStages.length;
    final progressPercentage = totalStages > 0 ? completedStages / totalStages : 0.0;

    final elapsed = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    final estimatedRemaining = _calculateEstimatedRemaining();

    return InitializationProgress(
      totalStages: totalStages,
      completedStages: completedStages,
      inProgressStages: _inProgressStages.length,
      failedStages: _failedStages.length,
      progressPercentage: progressPercentage,
      elapsedDuration: elapsed,
      estimatedTotalDuration: _totalEstimatedDuration,
      estimatedRemainingDuration: estimatedRemaining,
      currentStage: _getCurrentStage(),
      error: _currentError,
    );
  }

  /// Initializes the progress tracker with strategy and dependency graph
  void initialize(
    InitializationStrategy strategy,
    InitializationDependencyGraph dependencyGraph,
  ) {
    if (_isInitialized) return;

    _strategy = strategy;
    _dependencyGraph = dependencyGraph;

    // Calculate estimated duration based on strategy
    _totalEstimatedDuration = _calculateTotalEstimatedDuration();

    // Initialize progress for all stages
    for (final stage in InitializationStage.values) {
      _stageProgress[stage] = StageProgress(
        stage: stage,
        estimatedDuration: Duration(milliseconds: stage.estimatedMs),
        status: StageStatus.pending,
      );
    }

    _isInitialized = true;
    debugPrint('[InitializationProgressTracker] Initialized with strategy: $strategy');
  }

  /// Marks a stage as started
  void startStage(InitializationStage stage) {
    if (!_isInitialized) {
      throw StateError('Progress tracker not initialized');
    }

    _inProgressStages.add(stage);
    _stageProgress[stage] = _stageProgress[stage]!.copyWith(
      status: StageStatus.inProgress,
      startTime: DateTime.now(),
    );

    _emitProgressUpdate();
    debugPrint('[InitializationProgressTracker] Started stage: $stage');
  }

  /// Marks a stage as completed
  void completeStage(InitializationStage stage, StageExecutionResult result) {
    if (!_isInitialized) return;

    _inProgressStages.remove(stage);
    _completedStages.add(stage);
    _stageProgress[stage] = _stageProgress[stage]!.copyWith(
      status: StageStatus.completed,
      endTime: DateTime.now(),
      result: result,
    );

    _emitProgressUpdate();
    debugPrint('[InitializationProgressTracker] Completed stage: $stage');
  }

  /// Marks a stage as failed
  void failStage(InitializationStage stage, String error) {
    if (!_isInitialized) return;

    _inProgressStages.remove(stage);
    _failedStages.add(stage);
    _currentError = error;
    _stageProgress[stage] = _stageProgress[stage]!.copyWith(
      status: StageStatus.failed,
      endTime: DateTime.now(),
      error: error,
    );

    _emitProgressUpdate();
    debugPrint('[InitializationProgressTracker] Failed stage: $stage with error: $error');
  }

  /// Marks initialization as complete
  void complete() {
    _endTime = DateTime.now();
    _emitProgressUpdate();
    debugPrint('[InitializationProgressTracker] Initialization completed');
  }

  /// Marks initialization as failed
  void error(String error) {
    _currentError = error;
    _endTime = DateTime.now();
    _emitProgressUpdate();
    debugPrint('[InitializationProgressTracker] Initialization failed: $error');
  }

  /// Resets the progress tracker
  void reset() {
    _stageProgress.clear();
    _completedStages.clear();
    _inProgressStages.clear();
    _failedStages.clear();
    _startTime = null;
    _endTime = null;
    _currentError = null;
    _isInitialized = false;
    debugPrint('[InitializationProgressTracker] Reset');
  }

  /// Disposes the progress tracker
  void dispose() {
    _progressController.close();
    debugPrint('[InitializationProgressTracker] Disposed');
  }

  Duration _calculateTotalEstimatedDuration() {
    switch (_strategy) {
      case InitializationStrategy.sequential:
        return _dependencyGraph.getSequentialDuration();
      case InitializationStrategy.parallel:
        return _dependencyGraph.getParallelDuration();
      case InitializationStrategy.criticalOnly:
        return Duration(milliseconds: 500); // Critical stages only
      case InitializationStrategy.minimal:
        return Duration(milliseconds: 500); // Minimal stages only
      case InitializationStrategy.homeLocalFirst:
        return Duration(milliseconds: 2000); // Home local focused
      case InitializationStrategy.comprehensive:
        return _dependencyGraph.getParallelDuration();
      case InitializationStrategy.adaptive:
        return Duration(milliseconds: 1500); // Balanced estimate
    }
  }

  Duration _calculateEstimatedRemaining() {
    if (_completedStages.isEmpty) return _totalEstimatedDuration;

    int totalEstimate = 0;
    int totalCompleted = 0;

    for (final stage in InitializationStage.values) {
      if (_completedStages.contains(stage)) {
        totalCompleted += stage.estimatedMs;
      } else if (!_failedStages.contains(stage)) {
        totalEstimate += stage.estimatedMs;
      }
    }

    return Duration(milliseconds: totalEstimate);
  }

  InitializationStage? _getCurrentStage() {
    if (_inProgressStages.isNotEmpty) {
      return _inProgressStages.first;
    }

    // Find next stage to execute
    for (final stage in InitializationStage.values) {
      if (!_completedStages.contains(stage) && !_failedStages.contains(stage)) {
        return stage;
      }
    }

    return null;
  }

  void _emitProgressUpdate() {
    if (!_progressController.isClosed) {
      _progressController.add(currentProgress);
    }
  }
}

/// Initialization progress snapshot
@immutable
class InitializationProgress {
  const InitializationProgress({
    required this.totalStages,
    required this.completedStages,
    required this.inProgressStages,
    required this.failedStages,
    required this.progressPercentage,
    required this.elapsedDuration,
    required this.estimatedTotalDuration,
    required this.estimatedRemainingDuration,
    this.currentStage,
    this.error,
  });

  final int totalStages;
  final int completedStages;
  final int inProgressStages;
  final int failedStages;
  final double progressPercentage;
  final Duration elapsedDuration;
  final Duration estimatedTotalDuration;
  final Duration estimatedRemainingDuration;
  final InitializationStage? currentStage;
  final String? error;

  bool get isComplete => completedStages + failedStages == totalStages;
  bool get hasError => error != null;
  bool get isSuccess => isComplete && !hasError;

  @override
  String toString() {
    return 'InitializationProgress('
        'progress: ${(progressPercentage * 100).toStringAsFixed(1)}%, '
        'completed: $completedStages/$totalStages, '
        'failed: $failedStages, '
        'elapsed: ${elapsedDuration.inMilliseconds}ms, '
        'remaining: ${estimatedRemainingDuration.inMilliseconds}ms'
        ')';
  }
}

/// Individual stage progress tracking
@immutable
class StageProgress {
  const StageProgress({
    required this.stage,
    required this.estimatedDuration,
    required this.status,
    this.startTime,
    this.endTime,
    this.result,
    this.error,
  });

  final InitializationStage stage;
  final Duration estimatedDuration;
  final StageStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final StageExecutionResult? result;
  final String? error;

  Duration? get actualDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  StageProgress copyWith({
    Duration? estimatedDuration,
    StageStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    StageExecutionResult? result,
    String? error,
  }) {
    return StageProgress(
      stage: stage,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'StageProgress('
        'stage: $stage, '
        'status: $status, '
        'estimated: ${estimatedDuration.inMilliseconds}ms, '
        'actual: ${actualDuration?.inMilliseconds ?? 0}ms'
        ')';
  }
}