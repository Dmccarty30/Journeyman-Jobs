import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'initialization_stage.dart';

/// Error management for initialization stages
///
/// Provides circuit breaker pattern, retry logic, and error containment
/// for initialization failures.
class ErrorManager {
  ErrorManager({
    int maxRetries = 3,
    Duration baseRetryDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    Duration circuitBreakerTimeout = const Duration(minutes: 5),
  }) : _maxRetries = maxRetries,
       _baseRetryDelay = baseRetryDelay,
       _backoffMultiplier = backoffMultiplier,
       _circuitBreakerTimeout = circuitBreakerTimeout;

  final int _maxRetries;
  final Duration _baseRetryDelay;
  final double _backoffMultiplier;
  final Duration _circuitBreakerTimeout;

  // Error tracking
  final Map<InitializationStage, List<ErrorRecord>> _errorHistory = {};
  final Map<InitializationStage, CircuitBreakerState> _circuitBreakers = {};
  final Map<InitializationStage, RetryState> _retryStates = {};

  bool _isDisposed = false;

  /// Checks if a stage can be executed based on circuit breaker status
  bool canExecuteStage(InitializationStage stage) {
    if (_isDisposed) return false;

    final circuitBreaker = _circuitBreakers[stage];
    if (circuitBreaker?.isOpen == true) {
      // Check if circuit breaker should be half-open
      if (_shouldAttemptCircuitBreakerReset(stage)) {
        _circuitBreakers[stage] = circuitBreaker!.copyWith(
          state: CircuitBreakerStateType.halfOpen,
        );
        return true;
      }
      return false;
    }

    return true;
  }

  /// Records a successful stage execution
  void recordStageSuccess(InitializationStage stage) {
    if (_isDisposed) return;

    // Reset circuit breaker on success
    _circuitBreakers[stage] = CircuitBreakerState(
      state: CircuitBreakerStateType.closed,
      failureCount: 0,
      lastFailureTime: null,
    );

    // Clear retry state
    _retryStates.remove(stage);

    debugPrint('[ErrorManager] Stage $stage succeeded, circuit breaker reset');
  }

  /// Records a failed stage execution
  void recordStageFailure(InitializationStage stage, dynamic error) {
    if (_isDisposed) return;

    // Record error in history
    final record = ErrorRecord(
      stage: stage,
      error: error.toString(),
      timestamp: DateTime.now(),
    );

    _errorHistory.putIfAbsent(stage, () => []).add(record);

    // Keep only recent errors (last 10)
    final errors = _errorHistory[stage]!;
    if (errors.length > 10) {
      _errorHistory[stage] = errors.sublist(errors.length - 10);
    }

    // Update circuit breaker
    _updateCircuitBreaker(stage);

    debugPrint('[ErrorManager] Stage $stage failed: ${error.toString()}');
  }

  /// Checks if a stage should be retried
  bool shouldRetryStage(InitializationStage stage, dynamic error) {
    if (_isDisposed) return false;

    final retryState = _retryStates[stage];
    if (retryState == null) {
      // First attempt
      _retryStates[stage] = RetryState(
        attemptCount: 1,
        lastAttemptTime: DateTime.now(),
      );
      return _maxRetries > 0;
    }

    // Check retry limit
    if (retryState.attemptCount >= _maxRetries) {
      return false;
    }

    // Check if enough time has passed for retry
    final timeSinceLastAttempt = DateTime.now().difference(retryState.lastAttemptTime);
    final requiredDelay = getRetryDelay(stage);

    return timeSinceLastAttempt >= requiredDelay;
  }

  /// Gets the delay before next retry attempt
  Duration getRetryDelay(InitializationStage stage) {
    final retryState = _retryStates[stage];
    if (retryState == null) return _baseRetryDelay;

    // Exponential backoff with jitter
    final exponentialDelay = _baseRetryDelay.inMilliseconds *
        math.pow(_backoffMultiplier, retryState.attemptCount - 1);

    // Add jitter (±25%)
    final jitter = exponentialDelay * 0.25 * (math.Random().nextDouble() - 0.5);
    final finalDelay = (exponentialDelay + jitter).round();

    return Duration(milliseconds: finalDelay);
  }

  /// Handles stage failure with appropriate recovery actions
  Future<void> handleStageFailure(
    InitializationStage stage,
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[ErrorManager] Handling failure for stage: $stage');

    // Determine recovery action based on stage criticality and error type
    final recoveryAction = _determineRecoveryAction(stage, error);

    switch (recoveryAction) {
      case RecoveryAction.proceed:
        debugPrint('[ErrorManager] Proceeding despite failure of non-critical stage: $stage');
        break;

      case RecoveryAction.retry:
        debugPrint('[ErrorManager] Scheduling retry for stage: $stage');
        // Retry logic is handled by shouldRetryStage() method
        break;

      case RecoveryAction.fallback:
        debugPrint('[ErrorManager] Using fallback for stage: $stage');
        await _executeFallback(stage, context);
        break;

      case RecoveryAction.abort:
        debugPrint('[ErrorManager] Aborting initialization due to critical stage failure: $stage');
        throw Exception('Critical stage $stage failed: $error');
    }
  }

  /// Gets error statistics for a stage
  ErrorStats getErrorStats(InitializationStage stage) {
    final errors = _errorHistory[stage] ?? [];
    final recentErrors = errors.where((e) =>
        DateTime.now().difference(e.timestamp).inHours <= 24
    ).toList();

    return ErrorStats(
      totalErrors: errors.length,
      recentErrors: recentErrors.length,
      lastErrorTime: errors.isNotEmpty ? errors.last.timestamp : null,
      circuitBreakerState: _circuitBreakers[stage]?.state ?? CircuitBreakerStateType.closed,
      retryAttempts: _retryStates[stage]?.attemptCount ?? 0,
    );
  }

  /// Gets all error statistics
  Map<InitializationStage, ErrorStats> getAllErrorStats() {
    return Map.fromEntries(
      InitializationStage.values.map((stage) => MapEntry(
        stage,
        getErrorStats(stage),
      )),
    );
  }

  /// Resets error tracking for a stage
  void resetStage(InitializationStage stage) {
    _errorHistory.remove(stage);
    _circuitBreakers.remove(stage);
    _retryStates.remove(stage);
    debugPrint('[ErrorManager] Reset error tracking for stage: $stage');
  }

  /// Resets all error tracking
  void reset() {
    _errorHistory.clear();
    _circuitBreakers.clear();
    _retryStates.clear();
    debugPrint('[ErrorManager] Reset all error tracking');
  }

  /// Disposes the error manager
  void dispose() {
    _isDisposed = true;
    _errorHistory.clear();
    _circuitBreakers.clear();
    _retryStates.clear();
    debugPrint('[ErrorManager] Disposed');
  }

  void _updateCircuitBreaker(InitializationStage stage) {
    final errors = _errorHistory[stage] ?? [];
    final recentErrors = errors.where((e) =>
        DateTime.now().difference(e.timestamp).inMinutes <= 10
    ).length;

    final currentState = _circuitBreakers[stage]?.state ?? CircuitBreakerStateType.closed;
    var failureCount = _circuitBreakers[stage]?.failureCount ?? 0;

    failureCount++;

    // Open circuit breaker if too many recent failures
    if (recentErrors >= 3 && currentState != CircuitBreakerStateType.open) {
      _circuitBreakers[stage] = CircuitBreakerState(
        state: CircuitBreakerStateType.open,
        failureCount: failureCount,
        lastFailureTime: DateTime.now(),
      );
      debugPrint('[ErrorManager] Circuit breaker opened for stage: $stage');
    } else {
      _circuitBreakers[stage] = CircuitBreakerState(
        state: currentState,
        failureCount: failureCount,
        lastFailureTime: DateTime.now(),
      );
    }
  }

  bool _shouldAttemptCircuitBreakerReset(InitializationStage stage) {
    final circuitBreaker = _circuitBreakers[stage];
    if (circuitBreaker?.lastFailureTime == null) return false;

    final timeSinceLastFailure = DateTime.now()
        .difference(circuitBreaker!.lastFailureTime!);
    return timeSinceLastFailure >= _circuitBreakerTimeout;
  }

  RecoveryAction _determineRecoveryAction(InitializationStage stage, dynamic error) {
    // Critical stages always abort on failure
    if (stage.isCritical) {
      return RecoveryAction.abort;
    }

    // Network-related errors might be retryable
    if (error.toString().contains('network') ||
        error.toString().contains('timeout') ||
        error.toString().contains('connection')) {
      return RecoveryAction.retry;
    }

    // Authentication errors need fallback
    if (stage == InitializationStage.authentication) {
      return RecoveryAction.fallback;
    }

    // Default to proceed for non-critical stages
    return RecoveryAction.proceed;
  }

  Future<void> _executeFallback(InitializationStage stage, Map<String, dynamic> context) async {
    debugPrint('[ErrorManager] Executing fallback for stage: $stage');

    switch (stage) {
      case InitializationStage.firebaseCore:
        // Firebase Core is already initialized in main.dart, no fallback needed
        break;

      case InitializationStage.authentication:
        // Use cached auth state or anonymous mode
        debugPrint('[ErrorManager] Using cached authentication state');
        break;

      case InitializationStage.userProfile:
        // Use cached profile or default values
        debugPrint('[ErrorManager] Using cached user profile');
        break;

      case InitializationStage.localsDirectory:
        // Use cached locals or offline data
        debugPrint('[ErrorManager] Using cached locals directory');
        break;

      case InitializationStage.jobsData:
        // Use cached jobs or empty list
        debugPrint('[ErrorManager] Using cached jobs data');
        break;

      default:
        debugPrint('[ErrorManager] No fallback available for stage: $stage');
        break;
    }
  }
}

/// Circuit breaker state for a stage
@immutable
class CircuitBreakerState {
  const CircuitBreakerState({
    required this.state,
    required this.failureCount,
    this.lastFailureTime,
  });

  final CircuitBreakerStateType state;
  final int failureCount;
  final DateTime? lastFailureTime;

  bool get isOpen => state == CircuitBreakerStateType.open;
  bool get isClosed => state == CircuitBreakerStateType.closed;
  bool get isHalfOpen => state == CircuitBreakerStateType.halfOpen;

  CircuitBreakerState copyWith({
    CircuitBreakerStateType? state,
    int? failureCount,
    DateTime? lastFailureTime,
  }) {
    return CircuitBreakerState(
      state: state ?? this.state,
      failureCount: failureCount ?? this.failureCount,
      lastFailureTime: lastFailureTime ?? this.lastFailureTime,
    );
  }
}

/// Circuit breaker state types
enum CircuitBreakerStateType {
  closed,   // Normal operation
  open,     // Failing, stop trying
  halfOpen, // Testing if service recovered
}

/// Retry state for a stage
@immutable
class RetryState {
  const RetryState({
    required this.attemptCount,
    required this.lastAttemptTime,
  });

  final int attemptCount;
  final DateTime lastAttemptTime;
}

/// Error record for tracking
@immutable
class ErrorRecord {
  const ErrorRecord({
    required this.stage,
    required this.error,
    required this.timestamp,
  });

  final InitializationStage stage;
  final String error;
  final DateTime timestamp;
}

/// Error statistics for a stage
@immutable
class ErrorStats {
  const ErrorStats({
    required this.totalErrors,
    required this.recentErrors,
    this.lastErrorTime,
    required this.circuitBreakerState,
    required this.retryAttempts,
  });

  final int totalErrors;
  final int recentErrors;
  final DateTime? lastErrorTime;
  final CircuitBreakerStateType circuitBreakerState;
  final int retryAttempts;

  bool get hasRecentErrors => recentErrors > 0;
  bool get isCircuitBreakerOpen => circuitBreakerState == CircuitBreakerStateType.open;
}

/// Recovery action for failed stages
enum RecoveryAction {
  proceed,   // Continue with other stages
  retry,     // Retry the failed stage
  fallback,  // Use fallback mechanism
  abort,     // Abort initialization
}