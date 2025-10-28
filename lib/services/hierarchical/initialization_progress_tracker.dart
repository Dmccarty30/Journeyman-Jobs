import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../models/hierarchical/hierarchical_types.dart';
import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_dependency_graph.dart';
import '../../models/hierarchical/initialization_metadata.dart';
import 'hierarchical_initializer.dart';

/// Progress tracking system for hierarchical initialization
///
/// Provides real-time progress updates with time estimates, stage status,
/// and detailed progress information for user feedback and debugging.
class InitializationProgressTracker {
  InitializationProgressTracker();

  final Map<InitializationStage, StageProgress> _stageProgress = {};
  final StreamController<InitializationProgress> _progressController =
      StreamController<InitializationProgress>.broadcast();

  InitializationStrategy _strategy = InitializationStrategy.adaptive;
  InitializationDependencyGraph? _dependencyGraph;
  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  bool _isInitialized = false;
  bool _isCompleted = false;
  bool _hasError = false;
  String _error = '';

  /// Stream of progress updates
  Stream<InitializationProgress> get progressStream => _progressController.stream;

  /// Current progress state
  InitializationProgress get currentProgress {
    final now = DateTime.now();
    final elapsed = now.difference(_startTime);
    final totalStages = InitializationStage.values.length;
    final completedStages = _stageProgress.values
        .where((p) => p.status == StageProgressStatus.completed)
        .length;
    final inProgressStages = _stageProgress.values
        .where((p) => p.status == StageProgressStatus.inProgress)
        .length;
    final failedStages = _stageProgress.values
        .where((p) => p.status == StageProgressStatus.failed)
        .length;

    // Calculate overall progress percentage
    double progressPercentage = 0.0;
    if (totalStages > 0) {
      // Weight completed stages fully, in-progress stages at 50%
      progressPercentage = (completedStages + (inProgressStages * 0.5)) / totalStages;
    }

    // Estimate remaining time
    Duration estimatedRemainingTime = Duration.zero;
    if (_dependencyGraph != null && completedStages > 0) {
      estimatedRemainingTime = _calculateEstimatedRemainingTime(elapsed, completedStages);
    }

    // Determine current phase
    final currentPhase = _determineCurrentPhase();

    // Get active stages
    final activeStages = _stageProgress.entries
        .where((entry) => entry.value.status == StageProgressStatus.inProgress)
        .map((entry) => entry.key)
        .toList();

    return InitializationProgress(
      strategy: _strategy,
      progressPercentage: progressPercentage,
      completedStages: completedStages,
      totalStages: totalStages,
      inProgressStages: inProgressStages,
      failedStages: failedStages,
      elapsedTime: elapsed,
      estimatedRemainingTime: estimatedRemainingTime,
      currentPhase: currentPhase,
      activeStages: activeStages,
      stageProgress: Map.unmodifiable(_stageProgress),
      isCompleted: _isCompleted,
      hasError: _hasError,
      error: _error,
      startTime: _startTime,
      endTime: _endTime,
    );
  }

  /// Initializes the progress tracker with strategy and dependency graph
  void initialize(
    InitializationStrategy strategy,
    InitializationDependencyGraph dependencyGraph,
  ) {
    if (_isInitialized) {
      debugPrint('[InitializationProgressTracker] Already initialized, resetting...');
      reset();
    }

    _strategy = strategy;
    _dependencyGraph = dependencyGraph;
    _startTime = DateTime.now();
    _isInitialized = true;

    // Initialize stage progress for all stages
    for (final stage in InitializationStage.values) {
      _stageProgress[stage] = StageProgress(
        stage: stage,
        status: StageProgressStatus.pending,
        startTime: null,
        endTime: null,
        estimatedDuration: stage.estimatedDuration,
        actualDuration: null,
        progressPercentage: 0.0,
        error: null,
      );
    }

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Initialized with strategy: $strategy');
  }

  /// Marks a stage as started
  void startStage(InitializationStage stage) {
    if (!_isInitialized) {
      debugPrint('[InitializationProgressTracker] Not initialized, ignoring startStage for $stage');
      return;
    }

    final progress = _stageProgress[stage];
    if (progress == null) {
      debugPrint('[InitializationProgressTracker] Stage $stage not found in progress tracker');
      return;
    }

    if (progress.status != StageProgressStatus.pending) {
      debugPrint('[InitializationProgressTracker] Stage $stage already started or completed');
      return;
    }

    _stageProgress[stage] = progress.copyWith(
      status: StageProgressStatus.inProgress,
      startTime: DateTime.now(),
      progressPercentage: 0.0,
    );

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Started stage: ${stage.displayName}');
  }

  /// Updates progress for a stage (0.0 to 1.0)
  void updateStageProgress(InitializationStage stage, double progressPercentage) {
    if (!_isInitialized) return;

    final stageProgress = _stageProgress[stage];
    if (stageProgress == null || stageProgress.status != StageProgressStatus.inProgress) {
      return;
    }

    _stageProgress[stage] = stageProgress.copyWith(
      progressPercentage: progressPercentage.clamp(0.0, 1.0),
    );

    _emitProgress();
  }

  /// Marks a stage as completed
  void completeStage(InitializationStage stage, StageExecutionResult result) {
    if (!_isInitialized) return;

    final progress = _stageProgress[stage];
    if (progress == null) {
      debugPrint('[InitializationProgressTracker] Stage $stage not found in progress tracker');
      return;
    }

    _stageProgress[stage] = progress.copyWith(
      status: StageProgressStatus.completed,
      endTime: DateTime.now(),
      progressPercentage: 1.0,
      actualDuration: result.duration,
      metrics: result.metrics,
    );

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Completed stage: ${stage.displayName} '
              'in ${result.duration.inMilliseconds}ms');
  }

  /// Marks a stage as failed
  void failStage(InitializationStage stage, String error) {
    if (!_isInitialized) return;

    final progress = _stageProgress[stage];
    if (progress == null) {
      debugPrint('[InitializationProgressTracker] Stage $stage not found in progress tracker');
      return;
    }

    _stageProgress[stage] = progress.copyWith(
      status: StageProgressStatus.failed,
      endTime: DateTime.now(),
      progressPercentage: 0.0,
      error: error,
    );

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Failed stage: ${stage.displayName} - $error');
  }

  /// Marks a stage as skipped
  void skipStage(InitializationStage stage, String reason) {
    if (!_isInitialized) return;

    final progress = _stageProgress[stage];
    if (progress == null) {
      debugPrint('[InitializationProgressTracker] Stage $stage not found in progress tracker');
      return;
    }

    _stageProgress[stage] = progress.copyWith(
      status: StageProgressStatus.skipped,
      endTime: DateTime.now(),
      progressPercentage: 1.0,
      error: reason,
    );

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Skipped stage: ${stage.displayName} - $reason');
  }

  /// Marks initialization as completed
  void complete() {
    if (!_isInitialized) return;

    _isCompleted = true;
    _endTime = DateTime.now();

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Initialization completed');
  }

  /// Marks initialization as failed
  void error(String error) {
    if (!_isInitialized) return;

    _hasError = true;
    _error = error;
    _endTime = DateTime.now();

    _emitProgress();
    debugPrint('[InitializationProgressTracker] Initialization failed: $error');
  }

  /// Resets the progress tracker
  void reset() {
    _stageProgress.clear();
    _strategy = InitializationStrategy.adaptive;
    _dependencyGraph = null;
    _startTime = DateTime.now();
    _endTime = null;
    _isInitialized = false;
    _isCompleted = false;
    _hasError = false;
    _error = '';

    debugPrint('[InitializationProgressTracker] Reset');
  }

  /// Gets progress for a specific stage
  StageProgress? getStageProgress(InitializationStage stage) {
    return _stageProgress[stage];
  }

  /// Gets stages in a specific status
  List<InitializationStage> getStagesWithStatus(StageProgressStatus status) {
    return _stageProgress.entries
        .where((entry) => entry.value.status == status)
        .map((entry) => entry.key)
        .toList();
  }

  /// Calculates performance metrics
  ProgressMetrics getMetrics() {
    if (!_isInitialized) {
      return ProgressMetrics.empty();
    }

    final now = DateTime.now();
    final totalElapsed = now.difference(_startTime);
    final completedStages = _stageProgress.values
        .where((p) => p.status == StageProgressStatus.completed)
        .toList();

    if (completedStages.isEmpty) {
      return ProgressMetrics(
        totalElapsed: totalElapsed,
        averageStageTime: Duration.zero,
        fastestStage: null,
        slowestStage: null,
        accuracy: 0.0,
      );
    }

    // Calculate stage timing metrics
    final stageTimes = completedStages
        .map((p) => p.actualDuration ?? Duration.zero)
        .where((d) => d > Duration.zero)
        .toList();

    if (stageTimes.isEmpty) {
      return ProgressMetrics(
        totalElapsed: totalElapsed,
        averageStageTime: Duration.zero,
        fastestStage: null,
        slowestStage: null,
        accuracy: 0.0,
      );
    }

    final totalStageTime = stageTimes.fold(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    final averageStageTime = Duration(
      milliseconds: (totalStageTime.inMilliseconds / stageTimes.length).round(),
    );

    // Find fastest and slowest stages
    StageProgress? fastestStage, slowestStage;
    var fastestDuration = Duration.infinite;
    var slowestDuration = Duration.zero;

    for (final stage in completedStages) {
      final duration = stage.actualDuration ?? Duration.zero;
      if (duration > Duration.zero) {
        if (duration < fastestDuration) {
          fastestDuration = duration;
          fastestStage = stage;
        }
        if (duration > slowestDuration) {
          slowestDuration = duration;
          slowestStage = stage;
        }
      }
    }

    // Calculate estimation accuracy
    var totalError = 0.0;
    var accurateStages = 0;

    for (final stage in completedStages) {
      final estimated = stage.estimatedDuration.inMilliseconds.toDouble();
      final actual = (stage.actualDuration ?? Duration.zero).inMilliseconds.toDouble();

      if (estimated > 0 && actual > 0) {
        final error = (estimated - actual).abs() / estimated;
        totalError += error;
        accurateStages++;
      }
    }

    final accuracy = accurateStages > 0 ? 1.0 - (totalError / accurateStages) : 0.0;

    return ProgressMetrics(
      totalElapsed: totalElapsed,
      averageStageTime: averageStageTime,
      fastestStage: fastestStage,
      slowestStage: slowestStage,
      accuracy: accuracy.clamp(0.0, 1.0),
    );
  }

  /// Calculates estimated remaining time based on current progress
  Duration _calculateEstimatedRemainingTime(Duration elapsed, int completedStages) {
    if (_dependencyGraph == null || completedStages == 0) {
      return Duration.zero;
    }

    // Simple linear extrapolation
    final totalStages = InitializationStage.values.length;
    final remainingStages = totalStages - completedStages;
    final averageTimePerStage = elapsed.inMilliseconds / completedStages;

    // Adjust based on strategy
    double strategyMultiplier = 1.0;
    switch (_strategy) {
      case InitializationStrategy.minimal:
        strategyMultiplier = 0.6; // Fewer stages, faster
        break;
      case InitializationStrategy.homeLocalFirst:
        strategyMultiplier = 0.8; // Moderate pace
        break;
      case InitializationStrategy.comprehensive:
        strategyMultiplier = 1.2; // More stages, slower
        break;
      case InitializationStrategy.adaptive:
        strategyMultiplier = 1.0; // Baseline
        break;
    }

    final estimatedRemainingMs = (remainingStages * averageTimePerStage * strategyMultiplier).round();
    return Duration(milliseconds: estimatedRemainingMs);
  }

  /// Determines the current initialization phase
  InitializationPhase _determineCurrentPhase() {
    final completed = _stageProgress.values
        .where((p) => p.status == StageProgressStatus.completed)
        .length;
    final total = InitializationStage.values.length;

    if (completed == 0) return InitializationPhase.starting;
    if (completed < total * 0.25) return InitializationPhase.infrastructure;
    if (completed < total * 0.5) return InitializationPhase.userData;
    if (completed < total * 0.75) return InitializationPhase.coreData;
    if (completed < total * 0.9) return InitializationPhase.features;
    return InitializationPhase.finalizing;
  }

  /// Emits progress update to stream
  void _emitProgress() {
    if (!_progressController.isClosed) {
      _progressController.add(currentProgress);
    }
  }

  /// Disposes the progress tracker
  void dispose() {
    _progressController.close();
    debugPrint('[InitializationProgressTracker] Disposed');
  }
}

/// Progress information for a single initialization stage
@immutable
class StageProgress {
  const StageProgress({
    required this.stage,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.estimatedDuration,
    required this.actualDuration,
    required this.progressPercentage,
    required this.error,
    this.metrics,
  });

  final InitializationStage stage;
  final StageProgressStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration estimatedDuration;
  final Duration? actualDuration;
  final double progressPercentage;
  final String? error;
  final StageMetrics? metrics;

  bool get isPending => status == StageProgressStatus.pending;
  bool get isInProgress => status == StageProgressStatus.inProgress;
  bool get isCompleted => status == StageProgressStatus.completed;
  bool get isFailed => status == StageProgressStatus.failed;
  bool get isSkipped => status == StageProgressStatus.skipped;
  bool get hasError => error != null;
  bool get isFinished => [StageProgressStatus.completed, StageProgressStatus.failed, StageProgressStatus.skipped].contains(status);

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return actualDuration;
  }

  double get accuracy {
    if (actualDuration == null || estimatedDuration.inMilliseconds == 0) {
      return 0.0;
    }

    final estimated = estimatedDuration.inMilliseconds.toDouble();
    final actual = actualDuration!.inMilliseconds.toDouble();
    final error = (estimated - actual).abs() / estimated;
    return (1.0 - error).clamp(0.0, 1.0);
  }

  StageProgress copyWith({
    StageProgressStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? estimatedDuration,
    Duration? actualDuration,
    double? progressPercentage,
    String? error,
    StageMetrics? metrics,
  }) {
    return StageProgress(
      stage: stage,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      error: error ?? this.error,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StageProgress &&
        other.stage == stage &&
        other.status == status &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.estimatedDuration == estimatedDuration &&
        other.actualDuration == actualDuration &&
        other.progressPercentage == progressPercentage &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      stage,
      status,
      startTime,
      endTime,
      estimatedDuration,
      actualDuration,
      progressPercentage,
      error,
    );
  }

  @override
  String toString() {
    return 'StageProgress('
        'stage: ${stage.displayName}, '
        'status: $status, '
        'progress: ${(progressPercentage * 100).toStringAsFixed(1)}%, '
        'duration: ${duration?.inMilliseconds ?? 0}ms'
        ')';
  }
}

/// Status of stage progress
enum StageProgressStatus {
  pending,
  inProgress,
  completed,
  failed,
  skipped,
}

/// Overall initialization progress information
@immutable
class InitializationProgress {
  const InitializationProgress({
    required this.strategy,
    required this.progressPercentage,
    required this.completedStages,
    required this.totalStages,
    required this.inProgressStages,
    required this.failedStages,
    required this.elapsedTime,
    required this.estimatedRemainingTime,
    required this.currentPhase,
    required this.activeStages,
    required this.stageProgress,
    required this.isCompleted,
    required this.hasError,
    required this.error,
    required this.startTime,
    required this.endTime,
  });

  final InitializationStrategy strategy;
  final double progressPercentage;
  final int completedStages;
  final int totalStages;
  final int inProgressStages;
  final int failedStages;
  final Duration elapsedTime;
  final Duration estimatedRemainingTime;
  final InitializationPhase currentPhase;
  final List<InitializationStage> activeStages;
  final Map<InitializationStage, StageProgress> stageProgress;
  final bool isCompleted;
  final bool hasError;
  final String error;
  final DateTime startTime;
  final DateTime? endTime;

  bool get isStarting => currentPhase == InitializationPhase.starting;
  bool get isInfrastructure => currentPhase == InitializationPhase.infrastructure;
  bool get isUserData => currentPhase == InitializationPhase.userData;
  bool get isCoreData => currentPhase == InitializationPhase.coreData;
  bool get isFeatures => currentPhase == InitializationPhase.features;
  bool get isFinalizing => currentPhase == InitializationPhase.finalizing;
  bool get hasActiveStages => activeStages.isNotEmpty;
  bool get isHealthy => !hasError && failedStages == 0;

  String get progressDescription {
    if (isCompleted) return 'Initialization completed';
    if (hasError) return 'Initialization failed: $error';
    if (isStarting) return 'Starting initialization...';
    if (isInfrastructure) return 'Setting up core infrastructure...';
    if (isUserData) return 'Loading user data...';
    if (isCoreData) return 'Loading core application data...';
    if (isFeatures) return 'Initializing features...';
    if (isFinalizing) return 'Finalizing initialization...';
    return 'Initializing...';
  }

  @override
  String toString() {
    return 'InitializationProgress('
        'strategy: $strategy, '
        'progress: ${(progressPercentage * 100).toStringAsFixed(1)}%, '
        'completed: $completedStages/$totalStages, '
        'failed: $failedStages, '
        'elapsed: ${elapsedTime.inMilliseconds}ms, '
        'remaining: ${estimatedRemainingTime.inMilliseconds}ms'
        ')';
  }
}

/// Initialization phases for user feedback
enum InitializationPhase {
  starting,
  infrastructure,
  userData,
  coreData,
  features,
  finalizing,
}

/// Performance metrics for initialization progress
@immutable
class ProgressMetrics {
  const ProgressMetrics({
    required this.totalElapsed,
    required this.averageStageTime,
    required this.fastestStage,
    required this.slowestStage,
    required this.accuracy,
  });

  final Duration totalElapsed;
  final Duration averageStageTime;
  final StageProgress? fastestStage;
  final StageProgress? slowestStage;
  final double accuracy;

  factory ProgressMetrics.empty() {
    return ProgressMetrics(
      totalElapsed: Duration.zero,
      averageStageTime: Duration.zero,
      fastestStage: null,
      slowestStage: null,
      accuracy: 0.0,
    );
  }

  @override
  String toString() {
    return 'ProgressMetrics('
        'total: ${totalElapsed.inMilliseconds}ms, '
        'average: ${averageStageTime.inMilliseconds}ms, '
        'accuracy: ${(accuracy * 100).toStringAsFixed(1)}%'
        ')';
  }
}