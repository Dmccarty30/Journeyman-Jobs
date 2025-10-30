import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'initialization_stage.dart';
import 'initialization_dependency_graph.dart';
import 'hierarchical_types.dart';

/// Metadata and timing utilities for initialization stages
///
/// This class provides comprehensive metadata management for all initialization
/// stages including timing estimates, progress tracking, and performance metrics.
class InitializationMetadata {
  InitializationMetadata._();

  /// Singleton instance for metadata management
  static final InitializationMetadata _instance = InitializationMetadata._();
  static InitializationMetadata get instance => _instance;

  /// Metadata storage for all stages
  final Map<InitializationStage, StageMetadata> _metadata = {};

  /// Historical execution data for performance tuning
  final List<StageExecutionHistory> _executionHistory = [];

  /// Initialize metadata for all stages
  void initialize() {
    for (final stage in InitializationStage.values) {
      _metadata[stage] = _createStageMetadata(stage);
    }
  }

  /// Create initial metadata for a stage
  StageMetadata _createStageMetadata(InitializationStage stage) {
    return StageMetadata(
      stage: stage,
      estimatedDuration: stage.estimatedDuration,
      description: stage.description,
      isCritical: stage.isCritical,
      canRunInParallel: stage.canRunInParallel,
      retryPolicy: _getDefaultRetryPolicy(stage),
      timeoutPolicy: _getDefaultTimeoutPolicy(stage),
      progressCheckpoints: _getDefaultProgressCheckpoints(stage),
      integrationHooks: _getDefaultIntegrationHooks(stage),
      performanceMetrics: StagePerformanceMetrics.empty(),
    );
  }

  /// Get metadata for a specific stage
  StageMetadata getMetadata(InitializationStage stage) {
    return _metadata[stage] ?? _createStageMetadata(stage);
  }

  /// Update metadata for a stage
  void updateMetadata(InitializationStage stage, StageMetadata metadata) {
    _metadata[stage] = metadata;
  }

  /// Record stage execution for historical analysis
  void recordExecution(StageExecutionHistory execution) {
    _executionHistory.add(execution);

    // Limit history size to prevent memory leaks
    if (_executionHistory.length > 1000) {
      _executionHistory.removeAt(0);
    }

    // Update performance metrics based on new execution
    _updatePerformanceMetrics(execution.stage);
  }

  /// Update performance metrics based on historical data
  void _updatePerformanceMetrics(InitializationStage stage) {
    final stageHistory = _executionHistory
        .where((execution) => execution.stage == stage)
        .toList();

    if (stageHistory.isEmpty) return;

    final successfulExecutions = stageHistory
        .where((execution) => execution.isSuccess)
        .toList();

    if (successfulExecutions.isEmpty) return;

    // Calculate new average duration
    final totalDuration = successfulExecutions
        .fold<Duration>(Duration.zero, (sum, execution) => sum + execution.duration);
    final averageDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ successfulExecutions.length,
    );

    // Calculate success rate
    final successRate = successfulExecutions.length / stageHistory.length;

    // Update metadata
    final currentMetadata = getMetadata(stage);
    updateMetadata(stage, currentMetadata.copyWith(
      averageDuration: averageDuration,
      successRate: successRate,
      performanceMetrics: currentMetadata.performanceMetrics.copyWith(
        averageDuration: averageDuration,
        successRate: successRate,
        totalExecutions: stageHistory.length,
        lastExecution: successfulExecutions.last.startTime,
      ),
    ));
  }

  /// Get execution recommendations based on historical data
  ExecutionRecommendations getExecutionRecommendations() {
    final recommendations = ExecutionRecommendations();

    // Analyze critical path stages
    final criticalPath = InitializationStage.values.where((s) => s.isCritical);
    for (final stage in criticalPath) {
      final metadata = getMetadata(stage);
      if (metadata.successRate < 0.9) {
        recommendations.recommendPrioritization(stage);
      }
      if (metadata.averageDuration?.inMilliseconds != null &&
          metadata.averageDuration!.inMilliseconds > stage.estimatedMs * 1.5) {
        recommendations.recommendOptimization(stage);
      }
    }

    // Analyze parallel execution opportunities
    for (final level in [0, 1, 2, 3, 4]) {
      final stages = InitializationStage.values.where((s) => s.level == level);
      final parallelStages = stages.where((s) => s.canRunInParallel).length;

      if (parallelStages > 1) {
        recommendations.recommendParallelExecution(stages.toList());
      }
    }

    return recommendations;
  }

  /// Get default retry policy for a stage
  RetryPolicy _getDefaultRetryPolicy(InitializationStage stage) {
    switch (stage) {
      case InitializationStage.firebaseCore:
      case InitializationStage.authentication:
        return RetryPolicy(
          maxRetries: 3,
          backoffStrategy: BackoffStrategy.exponential,
          baseDelay: Duration(milliseconds: 500),
          maxDelay: Duration(seconds: 5),
        );

      case InitializationStage.sessionManagement:
      case InitializationStage.userProfile:
      case InitializationStage.userPreferences:
        return RetryPolicy(
          maxRetries: 2,
          backoffStrategy: BackoffStrategy.linear,
          baseDelay: Duration(milliseconds: 1000),
          maxDelay: Duration(seconds: 3),
        );

      case InitializationStage.localsDirectory:
      case InitializationStage.jobsData:
        return RetryPolicy(
          maxRetries: 2,
          backoffStrategy: BackoffStrategy.exponential,
          baseDelay: Duration(milliseconds: 1000),
          maxDelay: Duration(seconds: 10),
        );

      case InitializationStage.crewFeatures:
      case InitializationStage.weatherServices:
      case InitializationStage.notifications:
        return RetryPolicy(
          maxRetries: 1,
          backoffStrategy: BackoffStrategy.fixed,
          baseDelay: Duration(milliseconds: 2000),
          maxDelay: Duration(milliseconds: 2000),
        );

      case InitializationStage.offlineSync:
      case InitializationStage.backgroundTasks:
      case InitializationStage.analytics:
        return RetryPolicy(
          maxRetries: 1,
          backoffStrategy: BackoffStrategy.linear,
          baseDelay: Duration(milliseconds: 500),
          maxDelay: Duration(milliseconds: 1000),
        );
    }
  }

  /// Get default timeout policy for a stage
  TimeoutPolicy _getDefaultTimeoutPolicy(InitializationStage stage) {
    return TimeoutPolicy(
      timeout: Duration(milliseconds: (stage.estimatedMs * 3).ceil()),
      warningThreshold: Duration(milliseconds: (stage.estimatedMs * 1.5).ceil()),
      criticalThreshold: Duration(milliseconds: (stage.estimatedMs * 2.5).ceil()),
    );
  }

  /// Get default progress checkpoints for a stage
  List<ProgressCheckpoint> _getDefaultProgressCheckpoints(InitializationStage stage) {
    switch (stage) {
      case InitializationStage.firebaseCore:
        return [
          ProgressCheckpoint(percentage: 0.3, message: 'Initializing Firestore'),
          ProgressCheckpoint(percentage: 0.6, message: 'Setting up Authentication'),
          ProgressCheckpoint(percentage: 0.9, message: 'Configuring Storage'),
        ];

      case InitializationStage.authentication:
        return [
          ProgressCheckpoint(percentage: 0.4, message: 'Checking current session'),
          ProgressCheckpoint(percentage: 0.8, message: 'Verifying user credentials'),
        ];

      case InitializationStage.sessionManagement:
        return [
          ProgressCheckpoint(percentage: 0.5, message: 'Setting up session handlers'),
          ProgressCheckpoint(percentage: 0.9, message: 'Configuring token refresh'),
        ];

      case InitializationStage.userProfile:
        return [
          ProgressCheckpoint(percentage: 0.3, message: 'Fetching user document'),
          ProgressCheckpoint(percentage: 0.7, message: 'Parsing user data'),
        ];

      case InitializationStage.userPreferences:
        return [
          ProgressCheckpoint(percentage: 0.4, message: 'Loading preferences'),
          ProgressCheckpoint(percentage: 0.8, message: 'Applying settings'),
        ];

      case InitializationStage.localsDirectory:
        return [
          ProgressCheckpoint(percentage: 0.2, message: 'Connecting to locals database'),
          ProgressCheckpoint(percentage: 0.5, message: 'Loading local unions'),
          ProgressCheckpoint(percentage: 0.8, message: 'Caching directory data'),
        ];

      case InitializationStage.jobsData:
        return [
          ProgressCheckpoint(percentage: 0.2, message: 'Building job query'),
          ProgressCheckpoint(percentage: 0.5, message: 'Fetching job listings'),
          ProgressCheckpoint(percentage: 0.8, message: 'Processing job data'),
        ];

      case InitializationStage.crewFeatures:
        return [
          ProgressCheckpoint(percentage: 0.3, message: 'Initializing crew database'),
          ProgressCheckpoint(percentage: 0.7, message: 'Setting up messaging'),
        ];

      case InitializationStage.weatherServices:
        return [
          ProgressCheckpoint(percentage: 0.4, message: 'Connecting to weather APIs'),
          ProgressCheckpoint(percentage: 0.8, message: 'Configuring alerts'),
        ];

      case InitializationStage.notifications:
        return [
          ProgressCheckpoint(percentage: 0.5, message: 'Registering for push notifications'),
          ProgressCheckpoint(percentage: 0.9, message: 'Setting up notification handlers'),
        ];

      case InitializationStage.offlineSync:
        return [
          ProgressCheckpoint(percentage: 0.3, message: 'Initializing offline storage'),
          ProgressCheckpoint(percentage: 0.7, message: 'Configuring sync strategies'),
        ];

      case InitializationStage.backgroundTasks:
        return [
          ProgressCheckpoint(percentage: 0.5, message: 'Scheduling periodic tasks'),
          ProgressCheckpoint(percentage: 0.9, message: 'Setting up maintenance jobs'),
        ];

      case InitializationStage.analytics:
        return [
          ProgressCheckpoint(percentage: 0.4, message: 'Initializing analytics service'),
          ProgressCheckpoint(percentage: 0.8, message: 'Setting up crash reporting'),
        ];
    }
  }

  /// Get default integration hooks for a stage
  List<IntegrationHook> _getDefaultIntegrationHooks(InitializationStage stage) {
    final hooks = <IntegrationHook>[];

    // Add common hooks
    hooks.add(IntegrationHook(
      name: 'error_logging',
      type: HookType.error,
      priority: HookPriority.high,
      action: 'Log stage errors to crash reporting service',
    ));

    hooks.add(IntegrationHook(
      name: 'performance_monitoring',
      type: HookType.performance,
      priority: HookPriority.medium,
      action: 'Track stage performance metrics',
    ));

    // Add stage-specific hooks
    switch (stage) {
      case InitializationStage.firebaseCore:
        hooks.add(IntegrationHook(
          name: 'firebase_status',
          type: HookType.status,
          priority: HookPriority.high,
          action: 'Update Firebase connection status in UI',
        ));
        break;

      case InitializationStage.authentication:
        hooks.add(IntegrationHook(
          name: 'auth_state_update',
          type: HookType.state,
          priority: HookPriority.high,
          action: 'Update authentication state in providers',
        ));
        break;

      case InitializationStage.userProfile:
        hooks.add(IntegrationHook(
          name: 'user_data_loaded',
          type: HookType.data,
          priority: HookPriority.medium,
          action: 'Notify UI components of user data availability',
        ));
        break;

      case InitializationStage.localsDirectory:
        hooks.add(IntegrationHook(
          name: 'locals_data_ready',
          type: HookType.data,
          priority: HookPriority.medium,
          action: 'Enable locals-based features',
        ));
        break;

      case InitializationStage.jobsData:
        hooks.add(IntegrationHook(
          name: 'jobs_loaded',
          type: HookType.data,
          priority: HookPriority.high,
          action: 'Enable job search and filtering features',
        ));
        break;

      case InitializationStage.notifications:
        hooks.add(IntegrationHook(
          name: 'notifications_ready',
          type: HookType.feature,
          priority: HookPriority.medium,
          action: 'Enable push notification features',
        ));
        break;

      default:
        break;
    }

    return hooks;
  }

  /// Get progress estimate for a stage based on historical data
  double getProgressEstimate(InitializationStage stage, Duration elapsedTime) {
    final metadata = getMetadata(stage);
    final avgDuration = metadata.averageDuration?.inMilliseconds ?? 0;
    final elapsedMs = elapsedTime.inMilliseconds;

    if (avgDuration == 0) {
      // No historical data, use linear estimate based on estimated duration
      return (elapsedMs / stage.estimatedMs).clamp(0.0, 0.95);
    }

    // Use historical average with some variance
    final estimate = elapsedMs / avgDuration;

    // Apply a sigmoid function for more realistic progress reporting
    // (slow start, faster middle, slow finish)
    final sigmoid = 1 / (1 + math.exp(-(estimate - 0.5) * 4));

    return sigmoid.clamp(0.0, 0.95);
  }

  /// Get timing estimates for initialization planning
  TimingEstimates getTimingEstimates({bool useHistoricalData = true}) {
    final stageEstimates = <InitializationStage, Duration>{};

    for (final stage in InitializationStage.values) {
      final duration = useHistoricalData
          ? getMetadata(stage).averageDuration ?? stage.estimatedDuration
          : stage.estimatedDuration;

      stageEstimates[stage] = duration!;
    }

    // Calculate total sequential duration
    final totalSequential = stageEstimates.values
        .fold<Duration>(Duration.zero, (sum, duration) => sum + duration);

    // Calculate parallel duration using execution plan
    final graph = InitializationDependencyGraph();
    final plan = graph.getParallelExecutionPlan();
    var totalParallel = Duration.zero;

    for (final level in plan.keys) {
      Duration maxLevelDuration = Duration.zero;
      for (final stage in plan[level]!) {
        if (stageEstimates[stage]! > maxLevelDuration) {
          maxLevelDuration = stageEstimates[stage]!;
        }
      }
      totalParallel = totalParallel + maxLevelDuration;
    }

    final speedupRatio = totalParallel.inMilliseconds > 0
        ? totalSequential.inMilliseconds / totalParallel.inMilliseconds
        : 1.0;

    return TimingEstimates(
      sequential: totalSequential,
      parallel: totalParallel,
      stageEstimates: stageEstimates,
      speedupRatio: speedupRatio,
    );
  }

  /// Clear all historical data
  void clearHistory() {
    _executionHistory.clear();

    // Reset performance metrics
    for (final stage in InitializationStage.values) {
      final metadata = getMetadata(stage);
      updateMetadata(stage, metadata.copyWith(
        averageDuration: stage.estimatedDuration,
        successRate: 1.0,
        performanceMetrics: StagePerformanceMetrics.empty(),
      ));
    }
  }
}

/// Comprehensive metadata for a single initialization stage
@immutable
class StageMetadata {
  const StageMetadata({
    required this.stage,
    required this.estimatedDuration,
    required this.description,
    required this.isCritical,
    required this.canRunInParallel,
    required this.retryPolicy,
    required this.timeoutPolicy,
    required this.progressCheckpoints,
    required this.integrationHooks,
    required this.performanceMetrics,
    this.averageDuration,
    this.successRate = 1.0,
  });

  final InitializationStage stage;
  final Duration estimatedDuration;
  final String description;
  final bool isCritical;
  final bool canRunInParallel;
  final RetryPolicy retryPolicy;
  final TimeoutPolicy timeoutPolicy;
  final List<ProgressCheckpoint> progressCheckpoints;
  final List<IntegrationHook> integrationHooks;
  final StagePerformanceMetrics performanceMetrics;
  final Duration? averageDuration;
  final double successRate;

  StageMetadata copyWith({
    InitializationStage? stage,
    Duration? estimatedDuration,
    String? description,
    bool? isCritical,
    bool? canRunInParallel,
    RetryPolicy? retryPolicy,
    TimeoutPolicy? timeoutPolicy,
    List<ProgressCheckpoint>? progressCheckpoints,
    List<IntegrationHook>? integrationHooks,
    StagePerformanceMetrics? performanceMetrics,
    Duration? averageDuration,
    double? successRate,
  }) {
    return StageMetadata(
      stage: stage ?? this.stage,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      description: description ?? this.description,
      isCritical: isCritical ?? this.isCritical,
      canRunInParallel: canRunInParallel ?? this.canRunInParallel,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      timeoutPolicy: timeoutPolicy ?? this.timeoutPolicy,
      progressCheckpoints: progressCheckpoints ?? this.progressCheckpoints,
      integrationHooks: integrationHooks ?? this.integrationHooks,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      averageDuration: averageDuration ?? this.averageDuration,
      successRate: successRate ?? this.successRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StageMetadata &&
        other.stage == stage &&
        other.estimatedDuration == estimatedDuration &&
        other.description == description &&
        other.isCritical == isCritical &&
        other.canRunInParallel == canRunInParallel &&
        other.successRate == successRate;
  }

  @override
  int get hashCode {
    return Object.hash(
      stage,
      estimatedDuration,
      description,
      isCritical,
      canRunInParallel,
      successRate,
    );
  }

  @override
  String toString() {
    return 'StageMetadata(stage: $stage, critical: $isCritical, '
           'parallel: $canRunInParallel, successRate: ${(successRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Retry policy for failed stage executions
@immutable
class RetryPolicy {
  const RetryPolicy({
    required this.maxRetries,
    required this.backoffStrategy,
    required this.baseDelay,
    required this.maxDelay,
  });

  final int maxRetries;
  final BackoffStrategy backoffStrategy;
  final Duration baseDelay;
  final Duration maxDelay;

  Duration getDelayForAttempt(int attempt) {
    if (attempt <= 0) return Duration.zero;
    if (attempt > maxRetries) return maxDelay;

    switch (backoffStrategy) {
      case BackoffStrategy.fixed:
        return baseDelay;

      case BackoffStrategy.linear:
        return Duration(milliseconds: (baseDelay.inMilliseconds * attempt).clamp(
          baseDelay.inMilliseconds,
          maxDelay.inMilliseconds,
        ));

      case BackoffStrategy.exponential:
        final delayMs = baseDelay.inMilliseconds * (1 << (attempt - 1));
        return Duration(milliseconds: delayMs.clamp(
          baseDelay.inMilliseconds,
          maxDelay.inMilliseconds,
        ));
    }
  }

  @override
  String toString() {
    return 'RetryPolicy(maxRetries: $maxRetries, strategy: $backoffStrategy)';
  }
}

/// Backoff strategies for retry attempts
enum BackoffStrategy {
  fixed,
  linear,
  exponential,
}

/// Timeout policy for stage executions
@immutable
class TimeoutPolicy {
  const TimeoutPolicy({
    required this.timeout,
    required this.warningThreshold,
    required this.criticalThreshold,
  });

  final Duration timeout;
  final Duration warningThreshold;
  final Duration criticalThreshold;

  bool shouldWarn(Duration elapsed) => elapsed >= warningThreshold;
  bool isCritical(Duration elapsed) => elapsed >= criticalThreshold;
  bool isTimeout(Duration elapsed) => elapsed >= timeout;

  @override
  String toString() {
    return 'TimeoutPolicy(timeout: ${timeout.inSeconds}s, '
           'warning: ${warningThreshold.inSeconds}s, '
           'critical: ${criticalThreshold.inSeconds}s)';
  }
}

/// Progress checkpoint for detailed progress reporting
@immutable
class ProgressCheckpoint {
  const ProgressCheckpoint({
    required this.percentage,
    required this.message,
    this.timestamp,
  });

  final double percentage; // 0.0 to 1.0
  final String message;
  final DateTime? timestamp;

  @override
  String toString() {
    return 'ProgressCheckpoint(${(percentage * 100).toStringAsFixed(1)}%: $message)';
  }
}

/// Integration hook for stage execution events
@immutable
class IntegrationHook {
  const IntegrationHook({
    required this.name,
    required this.type,
    required this.priority,
    required this.action,
  });

  final String name;
  final HookType type;
  final HookPriority priority;
  final String action;

  @override
  String toString() {
    return 'IntegrationHook($name: $type - $action)';
  }
}

/// Types of integration hooks
enum HookType {
  state,
  data,
  feature,
  error,
  performance,
  status,
}

/// Priority levels for integration hooks
enum HookPriority {
  low,
  medium,
  high,
  critical,
}

/// Performance metrics for stage execution
@immutable
class StagePerformanceMetrics {
  const StagePerformanceMetrics({
    required this.averageDuration,
    required this.successRate,
    required this.totalExecutions,
    required this.lastExecution,
  });

  final Duration averageDuration;
  final double successRate;
  final int totalExecutions;
  final DateTime? lastExecution;

  factory StagePerformanceMetrics.empty() {
    return const StagePerformanceMetrics(
      averageDuration: Duration.zero,
      successRate: 1.0,
      totalExecutions: 0,
      lastExecution: null,
    );
  }

  StagePerformanceMetrics copyWith({
    Duration? averageDuration,
    double? successRate,
    int? totalExecutions,
    DateTime? lastExecution,
  }) {
    return StagePerformanceMetrics(
      averageDuration: averageDuration ?? this.averageDuration,
      successRate: successRate ?? this.successRate,
      totalExecutions: totalExecutions ?? this.totalExecutions,
      lastExecution: lastExecution ?? this.lastExecution,
    );
  }

  @override
  String toString() {
    return 'StagePerformanceMetrics(avg: ${averageDuration.inMilliseconds}ms, '
           'success: ${(successRate * 100).toStringAsFixed(1)}%, '
           'executions: $totalExecutions)';
  }
}

/// Historical execution record
@immutable
class StageExecutionHistory {
  const StageExecutionHistory({
    required this.stage,
    required this.startTime,
    required this.endTime,
    required this.isSuccess,
    this.error,
    this.retryCount = 0,
    this.metrics,
  });

  final InitializationStage stage;
  final DateTime startTime;
  final DateTime endTime;
  final bool isSuccess;
  final String? error;
  final int retryCount;
  final StageMetrics? metrics;

  Duration get duration => endTime.difference(startTime);

  @override
  String toString() {
    return 'StageExecutionHistory(stage: $stage, success: $isSuccess, '
           'duration: ${duration.inMilliseconds}ms, retries: $retryCount)';
  }
}

/// Execution recommendations based on analysis
class ExecutionRecommendations {
  ExecutionRecommendations() : _recommendations = [];

  final List<ExecutionRecommendation> _recommendations;

  void recommendPrioritization(InitializationStage stage) {
    _recommendations.add(ExecutionRecommendation(
      type: RecommendationType.prioritize,
      stage: stage,
      message: 'Stage has low success rate (${(InitializationMetadata.instance.getMetadata(stage).successRate * 100).toStringAsFixed(1)}%), consider prioritizing or optimizing',
    ));
  }

  void recommendOptimization(InitializationStage stage) {
    _recommendations.add(ExecutionRecommendation(
      type: RecommendationType.optimize,
      stage: stage,
      message: 'Stage consistently exceeds estimated duration, consider optimization',
    ));
  }

  void recommendParallelExecution(List<InitializationStage> stages) {
    _recommendations.add(ExecutionRecommendation(
      type: RecommendationType.parallel,
      stage: stages.first,
      message: 'Consider parallel execution for stages at level ${stages.first.level}',
      relatedStages: stages,
    ));
  }

  List<ExecutionRecommendation> get all => List.unmodifiable(_recommendations);

  bool get hasRecommendations => _recommendations.isNotEmpty;
}

/// Single execution recommendation
@immutable
class ExecutionRecommendation {
  const ExecutionRecommendation({
    required this.type,
    required this.stage,
    required this.message,
    this.relatedStages,
  });

  final RecommendationType type;
  final InitializationStage stage;
  final String message;
  final List<InitializationStage>? relatedStages;

  @override
  String toString() {
    return 'ExecutionRecommendation($type for $stage: $message)';
  }
}

/// Types of execution recommendations
enum RecommendationType {
  prioritize,
  optimize,
  parallel,
  monitor,
}

/// Timing estimates for initialization planning
@immutable
class TimingEstimates {
  const TimingEstimates({
    required this.sequential,
    required this.parallel,
    required this.stageEstimates,
    required this.speedupRatio,
  });

  final Duration sequential;
  final Duration parallel;
  final Map<InitializationStage, Duration> stageEstimates;
  final double speedupRatio;

  Duration get savings => sequential - parallel;
  double get savingsPercentage => (savings.inMilliseconds / sequential.inMilliseconds) * 100;

  @override
  String toString() {
    return 'TimingEstimates(sequential: ${sequential.inSeconds}s, '
           'parallel: ${parallel.inSeconds}s, '
           'speedup: ${speedupRatio.toStringAsFixed(2)}x)';
  }
}

/// Additional metadata types for the enhanced initialization system

/// Initialization context information
@immutable
class InitializationContext {
  const InitializationContext({
    required this.userId,
    required this.isFirstLaunch,
    required this.networkType,
    required this.batteryLevel,
    required this.devicePerformance,
    required this.previousLaunchData,
    this.userPreferences,
    this.location,
  });

  final String? userId;
  final bool isFirstLaunch;
  final NetworkType networkType;
  final double batteryLevel; // 0.0 to 1.0
  final DevicePerformance devicePerformance;
  final PreviousLaunchData? previousLaunchData;
  final Map<String, dynamic>? userPreferences;
  final String? location;

  bool get isLowBattery => batteryLevel < 0.2;
  bool get isOnMeteredNetwork => networkType == NetworkType.cellular;
  bool get isHighPerformanceDevice => devicePerformance == DevicePerformance.high;

  @override
  String toString() {
    return 'InitializationContext('
        'userId: $userId, '
        'isFirstLaunch: $isFirstLaunch, '
        'networkType: $networkType, '
        'batteryLevel: ${(batteryLevel * 100).toStringAsFixed(0)}%, '
        'devicePerformance: $devicePerformance'
        ')';
  }
}

/// Network type enumeration
enum NetworkType {
  wifi,
  cellular,
  ethernet,
  none,
}

/// Device performance level
enum DevicePerformance {
  low,
  medium,
  high,
}

/// Previous launch data for optimization
@immutable
class PreviousLaunchData {
  const PreviousLaunchData({
    required this.lastLaunchTime,
    required this.lastLaunchDuration,
    required this.lastStrategy,
    required this.failedStages,
    required this.completedStages,
    required this.averageStageTimes,
  });

  final DateTime lastLaunchTime;
  final Duration lastLaunchDuration;
  final InitializationStrategy lastStrategy;
  final List<InitializationStage> failedStages;
  final List<InitializationStage> completedStages;
  final Map<InitializationStage, Duration> averageStageTimes;

  bool get wasSuccessful => failedStages.isEmpty;
  bool get isRecent => DateTime.now().difference(lastLaunchTime).inHours < 24;

  @override
  String toString() {
    return 'PreviousLaunchData('
        'lastLaunchTime: $lastLaunchTime, '
        'lastLaunchDuration: ${lastLaunchDuration.inMilliseconds}ms, '
        'lastStrategy: $lastStrategy, '
        'wasSuccessful: $wasSuccessful'
        ')';
  }
}

/// Initialization configuration
@immutable
class InitializationConfig {
  const InitializationConfig({
    this.defaultStrategy = InitializationStrategy.adaptive,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.enablePerformanceMonitoring = true,
    this.enableErrorRecovery = true,
    this.enableProgressTracking = true,
    this.maxParallelStages = 4,
    this.cacheThreshold = const Duration(minutes: 5),
    this.enableBackgroundInitialization = true,
  });

  final InitializationStrategy defaultStrategy;
  final Duration timeout;
  final int maxRetries;
  final bool enablePerformanceMonitoring;
  final bool enableErrorRecovery;
  final bool enableProgressTracking;
  final int maxParallelStages;
  final Duration cacheThreshold;
  final bool enableBackgroundInitialization;

  InitializationConfig copyWith({
    InitializationStrategy? defaultStrategy,
    Duration? timeout,
    int? maxRetries,
    bool? enablePerformanceMonitoring,
    bool? enableErrorRecovery,
    bool? enableProgressTracking,
    int? maxParallelStages,
    Duration? cacheThreshold,
    bool? enableBackgroundInitialization,
  }) {
    return InitializationConfig(
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      enableErrorRecovery: enableErrorRecovery ?? this.enableErrorRecovery,
      enableProgressTracking: enableProgressTracking ?? this.enableProgressTracking,
      maxParallelStages: maxParallelStages ?? this.maxParallelStages,
      cacheThreshold: cacheThreshold ?? this.cacheThreshold,
      enableBackgroundInitialization: enableBackgroundInitialization ?? this.enableBackgroundInitialization,
    );
  }

  @override
  String toString() {
    return 'InitializationConfig('
        'defaultStrategy: $defaultStrategy, '
        'timeout: ${timeout.inSeconds}s, '
        'maxRetries: $maxRetries, '
        'enablePerformanceMonitoring: $enablePerformanceMonitoring, '
        'enableErrorRecovery: $enableErrorRecovery, '
        'enableProgressTracking: $enableProgressTracking, '
        'maxParallelStages: $maxParallelStages, '
        'cacheThreshold: ${cacheThreshold.inMinutes}min, '
        'enableBackgroundInitialization: $enableBackgroundInitialization'
        ')';
  }
}