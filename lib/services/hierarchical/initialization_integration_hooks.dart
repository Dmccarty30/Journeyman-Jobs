import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_metadata.dart';
import '../../providers/riverpod/hierarchical_riverpod_provider.dart';
import '../auth_service.dart';

/// Integration hooks for connecting initialization stages with existing services
///
/// This class provides the bridge between the new initialization stage system
/// and the existing Flutter/Firebase/Riverpod architecture.
class InitializationIntegrationHooks {
  InitializationIntegrationHooks._();
  static final InitializationIntegrationHooks _instance = InitializationIntegrationHooks._();
  static InitializationIntegrationHooks get instance => _instance;

  /// Service references for integration
  AuthService? _authService;
  HierarchicalRiverpodProvider? _hierarchicalProvider;

  /// Initialize hooks with service references
  void initialize({
    AuthService? authService,
    HierarchicalRiverpodProvider? hierarchicalProvider,
  }) {
    _authService = authService;
    _hierarchicalProvider = hierarchicalProvider;
  }

  /// Execute pre-stage hooks (before stage execution)
  Future<HookExecutionResult> executePreStageHooks(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[IntegrationHooks] Executing pre-stage hooks for $stage');

    final metadata = InitializationMetadata.instance.getMetadata(stage);
    final preHooks = metadata.integrationHooks
        .where((hook) => hook.type == HookType.state || hook.type == HookType.data)
        .toList();

    final results = <HookResult>[];

    for (final hook in preHooks) {
      try {
        final result = await _executeHook(hook, stage, context, isPreHook: true);
        results.add(result);
      } catch (e, stackTrace) {
        debugPrint('[IntegrationHooks] Pre-hook failed: ${hook.name} - $e');
        results.add(HookResult(
          hook: hook,
          success: false,
          error: e.toString(),
          stackTrace: stackTrace,
        ));
      }
    }

    return HookExecutionResult(
      stage: stage,
      phase: ExecutionPhase.pre,
      results: results,
      success: results.every((result) => result.success || !hook.isRequired),
    );
  }

  /// Execute post-stage hooks (after stage execution)
  Future<HookExecutionResult> executePostStageHooks(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[IntegrationHooks] Executing post-stage hooks for $stage');

    final metadata = InitializationMetadata.instance.getMetadata(stage);
    final postHooks = metadata.integrationHooks
        .where((hook) => hook.type != HookType.state)
        .toList();

    final results = <HookResult>[];

    for (final hook in postHooks) {
      try {
        final result = await _executeHook(hook, stage, context, isPreHook: false);
        results.add(result);
      } catch (e, stackTrace) {
        debugPrint('[IntegrationHooks] Post-hook failed: ${hook.name} - $e');
        results.add(HookResult(
          hook: hook,
          success: false,
          error: e.toString(),
          stackTrace: stackTrace,
        ));
      }
    }

    return HookExecutionResult(
      stage: stage,
      phase: ExecutionPhase.post,
      results: results,
      success: results.every((result) => result.success || !hook.isRequired),
    );
  }

  /// Execute a single integration hook
  Future<HookResult> _executeHook(
    IntegrationHook hook,
    InitializationStage stage,
    Map<String, dynamic> context,
    {required bool isPreHook}) async {
    debugPrint('[IntegrationHooks] Executing hook: ${hook.name}');

    final stopwatch = Stopwatch()..start();

    try {
      switch (hook.name) {
        case 'error_logging':
          return await _executeErrorLoggingHook(stage, context);

        case 'performance_monitoring':
          return await _executePerformanceMonitoringHook(stage, context);

        case 'firebase_status':
          return await _executeFirebaseStatusHook(stage, context);

        case 'auth_state_update':
          return await _executeAuthStateUpdateHook(stage, context);

        case 'user_data_loaded':
          return await _executeUserDataLoadedHook(stage, context);

        case 'locals_data_ready':
          return await _executeLocalsDataReadyHook(stage, context);

        case 'jobs_loaded':
          return await _executeJobsLoadedHook(stage, context);

        case 'notifications_ready':
          return await _executeNotificationsReadyHook(stage, context);

        default:
          debugPrint('[IntegrationHooks] Unknown hook: ${hook.name}');
          return HookResult(hook: hook, success: true);
      }
    } finally {
      stopwatch.stop();
      debugPrint('[IntegrationHooks] Hook ${hook.name} completed in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// Hook: Error logging integration
  Future<HookResult> _executeErrorLoggingHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    // Log any errors from stage execution
    final error = context['error'] as String?;
    final stackTrace = context['stackTrace'] as StackTrace?;

    if (error != null) {
      debugPrint('[IntegrationHooks] Logging error for $stage: $error');
      // TODO: Integrate with crash reporting service (Firebase Crashlytics, etc.)
      // await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }

    return HookResult(hook: IntegrationHook(name: 'error_logging', type: HookType.error, priority: HookPriority.high, action: 'Log stage errors'), success: true);
  }

  /// Hook: Performance monitoring integration
  Future<HookResult> _executePerformanceMonitoringHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    final startTime = context['startTime'] as DateTime?;
    final duration = context['duration'] as Duration?;

    if (startTime != null && duration != null) {
      debugPrint('[IntegrationHooks] Recording performance for $stage: ${duration.inMilliseconds}ms');

      // Record execution in metadata
      final execution = StageExecutionHistory(
        stage: stage,
        startTime: startTime,
        endTime: startTime.add(duration),
        isSuccess: context['success'] as bool? ?? true,
        error: context['error'] as String?,
        metrics: context['metrics'] as StageMetrics?,
      );

      InitializationMetadata.instance.recordExecution(execution);
    }

    return HookResult(hook: IntegrationHook(name: 'performance_monitoring', type: HookType.performance, priority: HookPriority.medium, action: 'Track stage performance metrics'), success: true);
  }

  /// Hook: Firebase status update
  Future<HookResult> _executeFirebaseStatusHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    if (stage == InitializationStage.firebaseCore) {
      final success = context['success'] as bool? ?? false;
      debugPrint('[IntegrationHooks] Firebase initialization ${success ? "completed" : "failed"}');

      // Update Firebase connection status in providers
      _hierarchicalProvider?.updateFirebaseStatus(success);
    }

    return HookResult(hook: IntegrationHook(name: 'firebase_status', type: HookType.status, priority: HookPriority.high, action: 'Update Firebase connection status in UI'), success: true);
  }

  /// Hook: Authentication state update
  Future<HookResult> _executeAuthStateUpdateHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    if (stage == InitializationStage.authentication) {
      final success = context['success'] as bool? ?? false;
      debugPrint('[IntegrationHooks] Authentication ${success ? "completed" : "failed"}');

      if (success && _authService != null) {
        // Update authentication state in providers
        final currentUser = _authService!.currentUser;
        if (currentUser != null) {
          _hierarchicalProvider?.updateAuthenticationState(true, currentUser.uid);
        }
      }
    }

    return HookResult(hook: IntegrationHook(name: 'auth_state_update', type: HookType.state, priority: HookPriority.high, action: 'Update authentication state in providers'), success: true);
  }

  /// Hook: User data loaded notification
  Future<HookResult> _executeUserDataLoadedHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    if (stage == InitializationStage.userProfile) {
      final success = context['success'] as bool? ?? false;
      if (success) {
        debugPrint('[IntegrationHooks] User data loaded successfully');

        // Notify UI components of user data availability
        final userData = context['userData'] as Map<String, dynamic>?;
        if (userData != null) {
          _hierarchicalProvider?.updateUserData(userData);
        }
      }
    }

    return HookResult(hook: IntegrationHook(name: 'user_data_loaded', type: HookType.data, priority: HookPriority.medium, action: 'Notify UI components of user data availability'), success: true);
  }

  /// Hook: Locals data ready notification
  Future<HookResult> _executeLocalsDataReadyHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    if (stage == InitializationStage.localsDirectory) {
      final success = context['success'] as bool? ?? false;
      if (success) {
        debugPrint('[IntegrationHooks] Locals directory data ready');

        // Enable locals-based features
        _hierarchicalProvider?.updateLocalsDataStatus(true);

        // Trigger background data refresh if needed
        _scheduleBackgroundRefresh();
      }
    }

    return HookResult(hook: IntegrationHook(name: 'locals_data_ready', type: HookType.data, priority: HookPriority.medium, action: 'Enable locals-based features'), success: true);
  }

  /// Hook: Jobs loaded notification
  Future<HookResult> _executeJobsLoadedHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    if (stage == InitializationStage.jobsData) {
      final success = context['success'] as bool? ?? false;
      if (success) {
        debugPrint('[IntegrationHooks] Jobs data loaded successfully');

        // Enable job search and filtering features
        _hierarchicalProvider?.updateJobsDataStatus(true);

        // Notify job providers of new data
        final jobsData = context['jobsData'] as List<dynamic>?;
        if (jobsData != null) {
          _hierarchicalProvider?.updateJobsData(jobsData.cast<Map<String, dynamic>>());
        }
      }
    }

    return HookResult(hook: IntegrationHook(name: 'jobs_loaded', type: HookType.data, priority: HookPriority.high, action: 'Enable job search and filtering features'), success: true);
  }

  /// Hook: Notifications ready notification
  Future<HookResult> _executeNotificationsReadyHook(
    InitializationStage stage,
    Map<String, dynamic> context,
  ) async {
    if (stage == InitializationStage.notifications) {
      final success = context['success'] as bool? ?? false;
      if (success) {
        debugPrint('[IntegrationHooks] Notifications system ready');

        // Enable push notification features
        _hierarchicalProvider?.updateNotificationsStatus(true);

        // Register for specific notification types based on user preferences
        _registerForNotifications();
      }
    }

    return HookResult(hook: IntegrationHook(name: 'notifications_ready', type: HookType.feature, priority: HookPriority.medium, action: 'Enable push notification features'), success: true);
  }

  /// Schedule background data refresh
  void _scheduleBackgroundRefresh() {
    debugPrint('[IntegrationHooks] Scheduling background data refresh');

    // TODO: Implement background refresh scheduling
    // This could use WorkManager or similar background task scheduling
    Timer.periodic(const Duration(minutes: 30), (timer) {
      debugPrint('[IntegrationHooks] Executing background data refresh');
      // Refresh critical data in background
    });
  }

  /// Register for specific notification types
  void _registerForNotifications() {
    debugPrint('[IntegrationHooks] Registering for notifications');

    // TODO: Implement notification registration
    // This would subscribe to topics based on user preferences
    // FirebaseMessaging.instance.subscribeToTopic('job_alerts');
    // FirebaseMessaging.instance.subscribeToTopic('crew_updates');
  }

  /// Get progress update for a stage during execution
  ProgressUpdate getProgressUpdate(InitializationStage stage, double progress) {
    final metadata = InitializationMetadata.instance.getMetadata(stage);

    // Find the appropriate checkpoint
    ProgressCheckpoint? checkpoint;
    for (final cp in metadata.progressCheckpoints) {
      if (progress >= cp.percentage) {
        checkpoint = cp;
      } else {
        break;
      }
    }

    return ProgressUpdate(
      stage: stage,
      progress: progress,
      message: checkpoint?.message ?? 'Initializing...',
      estimatedTimeRemaining: _estimateTimeRemaining(stage, progress),
    );
  }

  /// Estimate remaining time for stage execution
  Duration _estimateTimeRemaining(InitializationStage stage, double progress) {
    if (progress <= 0.0) return const Duration(seconds: 30);
    if (progress >= 1.0) return Duration.zero;

    final metadata = InitializationMetadata.instance.getMetadata(stage);
    final avgDuration = metadata.averageDuration.inMilliseconds > 0
        ? metadata.averageDuration
        : stage.estimatedDuration;

    final elapsedMs = (avgDuration.inMilliseconds * progress).round();
    final remainingMs = avgDuration.inMilliseconds - elapsedMs;

    return Duration(milliseconds: remainingMs.clamp(0, double.infinity).round());
  }

  /// Handle stage execution failure
  Future<FailureHandlingResult> handleStageFailure(
    InitializationStage stage,
    String error,
    StackTrace? stackTrace,
  ) async {
    debugPrint('[IntegrationHooks] Handling failure for $stage: $error');

    final metadata = InitializationMetadata.instance.getMetadata(stage);
    final retryPolicy = metadata.retryPolicy;

    // Determine if stage is critical
    final isCritical = metadata.isCritical;

    // Check if we should retry
    final retryCount = (stackTrace != null) ? 1 : 0; // Simplified retry count
    final shouldRetry = retryCount < retryPolicy.maxRetries;

    if (shouldRetry) {
      final retryDelay = retryPolicy.getDelayForAttempt(retryCount + 1);
      debugPrint('[IntegrationHooks] Scheduling retry for $stage in ${retryDelay.inMilliseconds}ms');

      return FailureHandlingResult(
        action: FailureAction.retry,
        retryDelay: retryDelay,
        message: 'Retrying ${stage.displayName} in ${retryDelay.inSeconds} seconds...',
        isCritical: isCritical,
      );
    } else if (isCritical) {
      debugPrint('[IntegrationHooks] Critical stage $stage failed, app may not function properly');

      return FailureHandlingResult(
        action: FailureAction.criticalFailure,
        retryDelay: Duration.zero,
        message: 'Critical initialization failed: ${stage.displayName}',
        isCritical: true,
      );
    } else {
      debugPrint('[IntegrationHooks] Non-critical stage $stage failed, continuing initialization');

      return FailureHandlingResult(
        action: FailureAction.continue,
        retryDelay: Duration.zero,
        message: 'Non-critical initialization skipped: ${stage.displayName}',
        isCritical: false,
      );
    }
  }

  /// Get integration status summary
  IntegrationStatusSummary getStatusSummary() {
    return IntegrationStatusSummary(
      isInitialized: _authService != null && _hierarchicalProvider != null,
      hasAuthService: _authService != null,
      hasHierarchicalProvider: _hierarchicalProvider != null,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Result of hook execution
@immutable
class HookResult {
  const HookResult({
    required this.hook,
    required this.success,
    this.error,
    this.stackTrace,
    this.data,
  });

  final IntegrationHook hook;
  final bool success;
  final String? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? data;

  @override
  String toString() {
    return 'HookResult(${hook.name}: ${success ? "success" : "failed"})';
  }
}

/// Result of executing hooks for a phase
@immutable
class HookExecutionResult {
  const HookExecutionResult({
    required this.stage,
    required this.phase,
    required this.results,
    required this.success,
  });

  final InitializationStage stage;
  final ExecutionPhase phase;
  final List<HookResult> results;
  final bool success;

  List<HookResult> get failedResults => results.where((r) => !r.success).toList();
  bool get hasFailures => failedResults.isNotEmpty;

  @override
  String toString() {
    return 'HookExecutionResult($stage $phase: ${success ? "success" : "failed"}, ${results.length} hooks)';
  }
}

/// Execution phase for hooks
enum ExecutionPhase {
  pre,
  post,
}

/// Progress update during stage execution
@immutable
class ProgressUpdate {
  const ProgressUpdate({
    required this.stage,
    required this.progress,
    required this.message,
    required this.estimatedTimeRemaining,
  });

  final InitializationStage stage;
  final double progress;
  final String message;
  final Duration estimatedTimeRemaining;

  @override
  String toString() {
    return 'ProgressUpdate(${stage.displayName}: ${(progress * 100).toStringAsFixed(1)}% - $message)';
  }
}

/// Result of failure handling
@immutable
class FailureHandlingResult {
  const FailureHandlingResult({
    required this.action,
    required this.retryDelay,
    required this.message,
    required this.isCritical,
  });

  final FailureAction action;
  final Duration retryDelay;
  final String message;
  final bool isCritical;

  @override
  String toString() {
    return 'FailureHandlingResult($action: ${isCritical ? "critical" : "non-critical"})';
  }
}

/// Actions to take on failure
enum FailureAction {
  retry,
  continue,
  criticalFailure,
  abort,
}

/// Integration status summary
@immutable
class IntegrationStatusSummary {
  const IntegrationStatusSummary({
    required this.isInitialized,
    required this.hasAuthService,
    required this.hasHierarchicalProvider,
    required this.lastUpdated,
  });

  final bool isInitialized;
  final bool hasAuthService;
  final bool hasHierarchicalProvider;
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'IntegrationStatusSummary(initialized: $isInitialized, '
           'auth: $hasAuthService, provider: $hasHierarchicalProvider)';
  }
}

/// Extension to add isRequired property to IntegrationHook
extension IntegrationHookExtension on IntegrationHook {
  bool get isRequired => priority == HookPriority.critical || priority == HookPriority.high;
}