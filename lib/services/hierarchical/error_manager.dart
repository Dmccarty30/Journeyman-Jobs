import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_metadata.dart';
import 'hierarchical_initializer.dart';

/// Error management system for hierarchical initialization
///
/// Provides comprehensive error handling including:
/// - Circuit breaker pattern for failing stages
/// - Retry logic with exponential backoff
/// - Error classification and containment
/// - Graceful degradation strategies
/// - Error reporting and analytics
class ErrorManager {
  ErrorManager({
    int maxRetries = 3,
    Duration baseRetryDelay = const Duration(milliseconds: 500),
    Duration maxRetryDelay = const Duration(seconds: 30),
    int failureThreshold = 3,
    Duration recoveryTimeout = const Duration(minutes: 5),
  }) : _maxRetries = maxRetries,
       _baseRetryDelay = baseRetryDelay,
       _maxRetryDelay = maxRetryDelay,
       _failureThreshold = failureThreshold,
       _recoveryTimeout = recoveryTimeout;

  final int _maxRetries;
  final Duration _baseRetryDelay;
  final Duration _maxRetryDelay;
  final int _failureThreshold;
  final Duration _recoveryTimeout;

  // Circuit breaker state
  final Map<InitializationStage, CircuitBreakerState> _circuitBreakers = {};

  // Retry tracking
  final Map<InitializationStage, RetryState> _retryStates = {};

  // Error history
  final List<InitializationError> _errorHistory = [];

  // Error handlers
  final Map<InitializationStage, List<ErrorHandler>> _errorHandlers = {};

  /// Registers an error handler for a specific stage
  void registerErrorHandler(InitializationStage stage, ErrorHandler handler) {
    _errorHandlers[stage] ??= [];
    _errorHandlers[stage]!.add(handler);
  }

  /// Removes error handlers for a stage
  void removeErrorHandlers(InitializationStage stage) {
    _errorHandlers.remove(stage);
  }

  /// Handles stage failure with circuit breaker and retry logic
  Future<void> handleStageFailure(
    InitializationStage stage,
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[ErrorManager] Handling failure for stage ${stage.displayName}: $error');

    // Record error
    _recordError(stage, error, stackTrace, context);

    // Update circuit breaker
    _updateCircuitBreaker(stage, error);

    // Run custom error handlers
    await _runErrorHandlers(stage, error, stackTrace, context);

    // Determine error severity and containment strategy
    final severity = _classifyError(error, stage);
    await _applyContainmentStrategy(stage, severity, error, context);
  }

  /// Records stage failure for circuit breaker
  void recordStageFailure(InitializationStage stage, Object error) {
    final circuitBreaker = _circuitBreakers[stage];
    if (circuitBreaker == null) {
      _circuitBreakers[stage] = CircuitBreakerState(
        state: CircuitBreakerStateType.open,
        failureCount: 1,
        lastFailureTime: DateTime.now(),
      );
    } else {
      circuitBreaker.failureCount++;
      circuitBreaker.lastFailureTime = DateTime.now();

      if (circuitBreaker.failureCount >= _failureThreshold) {
        circuitBreaker.state = CircuitBreakerStateType.open;
        debugPrint('[ErrorManager] Circuit breaker opened for stage ${stage.displayName}');
      }
    }

    // Update retry state
    final retryState = _retryStates[stage];
    if (retryState != null) {
      retryState.attempts++;
      retryState.lastAttemptTime = DateTime.now();
    }
  }

  /// Records stage success for circuit breaker
  void recordStageSuccess(InitializationStage stage) {
    final circuitBreaker = _circuitBreakers[stage];
    if (circuitBreaker != null) {
      circuitBreaker.failureCount = 0;
      circuitBreaker.state = CircuitBreakerStateType.closed;
      debugPrint('[ErrorManager] Circuit breaker closed for stage ${stage.displayName}');
    }

    // Reset retry state
    _retryStates.remove(stage);
  }

  /// Checks if a stage can be executed based on circuit breaker state
  bool canExecuteStage(InitializationStage stage) {
    final circuitBreaker = _circuitBreakers[stage];
    if (circuitBreaker == null) {
      return true; // No circuit breaker, can execute
    }

    switch (circuitBreaker.state) {
      case CircuitBreakerStateType.closed:
        return true;
      case CircuitBreakerStateType.open:
        // Check if recovery timeout has passed
        final timeSinceLastFailure = DateTime.now().difference(circuitBreaker.lastFailureTime);
        if (timeSinceLastFailure >= _recoveryTimeout) {
          circuitBreaker.state = CircuitBreakerStateType.halfOpen;
          debugPrint('[ErrorManager] Circuit breaker half-open for stage ${stage.displayName}');
          return true;
        }
        return false;
      case CircuitBreakerStateType.halfOpen:
        return true;
    }
  }

  /// Checks if a stage should be retried
  bool shouldRetryStage(InitializationStage stage, Object error) {
    // Don't retry critical errors
    if (_isCriticalError(error)) {
      return false;
    }

    // Check retry limit
    final retryState = _retryStates[stage];
    if (retryState != null && retryState.attempts >= _maxRetries) {
      debugPrint('[ErrorManager] Max retries exceeded for stage ${stage.displayName}');
      return false;
    }

    // Check if error is retryable
    return _isRetryableError(error);
  }

  /// Gets retry delay with exponential backoff
  Duration getRetryDelay(InitializationStage stage) {
    final retryState = _retryStates[stage];
    if (retryState == null) {
      return _baseRetryDelay;
    }

    final attempt = retryState.attempts;
    final delay = _baseRetryDelay * math.pow(2, attempt - 1);
    final jitteredDelay = Duration(
      milliseconds: (delay.inMilliseconds * (0.5 + math.Random().nextDouble() * 0.5)).round(),
    );

    return jitteredDelay.clamp(_baseRetryDelay, _maxRetryDelay);
  }

  /// Gets error statistics
  ErrorStatistics getStatistics() {
    final totalErrors = _errorHistory.length;
    final errorsByStage = <InitializationStage, int>{};
    final errorsByType = <String, int>{};
    final criticalErrors = _errorHistory.where((e) => e.severity == ErrorSeverity.critical).length;

    for (final error in _errorHistory) {
      errorsByStage[error.stage] = (errorsByStage[error.stage] ?? 0) + 1;
      errorsByType[error.type] = (errorsByType[error.type] ?? 0) + 1;
    }

    final openCircuitBreakers = _circuitBreakers.values
        .where((cb) => cb.state == CircuitBreakerStateType.open)
        .length;

    return ErrorStatistics(
      totalErrors: totalErrors,
      criticalErrors: criticalErrors,
      errorsByStage: errorsByStage,
      errorsByType: errorsByType,
      openCircuitBreakers: openCircuitBreakers,
      failureRate: totalErrors > 0 ? criticalErrors / totalErrors : 0.0,
    );
  }

  /// Gets recent errors
  List<InitializationError> getRecentErrors({int limit = 10}) {
    final sortedErrors = List<InitializationError>.from(_errorHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedErrors.take(limit).toList();
  }

  /// Clears error history and resets circuit breakers
  void reset() {
    _errorHistory.clear();
    _circuitBreakers.clear();
    _retryStates.clear();
    _errorHandlers.clear();
    debugPrint('[ErrorManager] Reset error manager state');
  }

  /// Disposes the error manager
  void dispose() {
    reset();
    debugPrint('[ErrorManager] Disposed');
  }

  // Private methods

  /// Records an error in the error history
  void _recordError(
    InitializationStage stage,
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) {
    final initError = InitializationError(
      stage: stage,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: _classifyError(error, stage),
      type: error.runtimeType.toString(),
      context: Map.from(context),
    );

    _errorHistory.add(initError);

    // Keep only recent errors (last 100)
    if (_errorHistory.length > 100) {
      _errorHistory.removeRange(0, _errorHistory.length - 100);
    }
  }

  /// Updates circuit breaker state based on failure
  void _updateCircuitBreaker(InitializationStage stage, Object error) {
    final circuitBreaker = _circuitBreakers[stage] ?? CircuitBreakerState(
      state: CircuitBreakerStateType.closed,
      failureCount: 0,
      lastFailureTime: DateTime.now(),
    );

    circuitBreaker.failureCount++;
    circuitBreaker.lastFailureTime = DateTime.now();

    if (circuitBreaker.failureCount >= _failureThreshold) {
      circuitBreaker.state = CircuitBreakerStateType.open;
      debugPrint('[ErrorManager] Circuit breaker opened for stage ${stage.displayName}');
    }

    _circuitBreakers[stage] = circuitBreaker;
  }

  /// Runs registered error handlers for a stage
  Future<void> _runErrorHandlers(
    InitializationStage stage,
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    final handlers = _errorHandlers[stage];
    if (handlers == null || handlers.isEmpty) return;

    for (final handler in handlers) {
      try {
        await handler.handleError(error, stackTrace, context);
      } catch (handlerError) {
        debugPrint('[ErrorManager] Error handler failed for stage ${stage.displayName}: $handlerError');
      }
    }
  }

  /// Classifies error severity
  ErrorSeverity _classifyError(Object error, InitializationStage stage) {
    if (_isCriticalError(error)) {
      return ErrorSeverity.critical;
    }

    if (stage.isCritical) {
      return ErrorSeverity.high;
    }

    if (_isNetworkError(error)) {
      return ErrorSeverity.medium;
    }

    return ErrorSeverity.low;
  }

  /// Checks if error is critical
  bool _isCriticalError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('authentication') ||
           errorString.contains('permission denied') ||
           errorString.contains('firebase') ||
           errorString.contains('state error');
  }

  /// Checks if error is retryable
  bool _isRetryableError(Object error) {
    final errorString = error.toString().toLowerCase();

    // Network errors are usually retryable
    if (_isNetworkError(error)) {
      return true;
    }

    // Timeout errors are retryable
    if (errorString.contains('timeout') || errorString.contains('deadline')) {
      return true;
    }

    // Service unavailable is retryable
    if (errorString.contains('unavailable') || errorString.contains('service')) {
      return true;
    }

    // Don't retry authentication or permission errors
    if (errorString.contains('authentication') ||
        errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return false;
    }

    return true; // Default to retryable
  }

  /// Checks if error is network-related
  bool _isNetworkError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('socket') ||
           errorString.contains('host') ||
           errorString.contains('internet');
  }

  /// Applies containment strategy based on error severity
  Future<void> _applyContainmentStrategy(
    InitializationStage stage,
    ErrorSeverity severity,
    Object error,
    Map<String, dynamic> context,
  ) async {
    switch (severity) {
      case ErrorSeverity.critical:
        await _handleCriticalError(stage, error, context);
        break;
      case ErrorSeverity.high:
        await _handleHighSeverityError(stage, error, context);
        break;
      case ErrorSeverity.medium:
        await _handleMediumSeverityError(stage, error, context);
        break;
      case ErrorSeverity.low:
        await _handleLowSeverityError(stage, error, context);
        break;
    }
  }

  /// Handles critical errors
  Future<void> _handleCriticalError(
    InitializationStage stage,
    Object error,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[ErrorManager] Handling critical error for stage ${stage.displayName}');

    // For critical errors, we might want to:
    // 1. Show user-facing error message
    // 2. Offer retry option
    // 3. Possibly restart app or use fallback mode

    // This would integrate with app-wide error handling
    // For now, just log the error
  }

  /// Handles high severity errors
  Future<void> _handleHighSeverityError(
    InitializationStage stage,
    Object error,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[ErrorManager] Handling high severity error for stage ${stage.displayName}');

    // Try to use fallback data or cached data if available
    // Continue with other stages if possible
  }

  /// Handles medium severity errors
  Future<void> _handleMediumSeverityError(
    InitializationStage stage,
    Object error,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[ErrorManager] Handling medium severity error for stage ${stage.displayName}');

    // Usually network-related, can retry later
    // Use offline mode if available
  }

  /// Handles low severity errors
  Future<void> _handleLowSeverityError(
    InitializationStage stage,
    Object error,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[ErrorManager] Handling low severity error for stage ${stage.displayName}');

    // Non-critical features, can continue without them
    // Log for analytics but don't interrupt user experience
  }
}

/// Circuit breaker state for stage failure protection
@immutable
class CircuitBreakerState {
  const CircuitBreakerState({
    required this.state,
    required this.failureCount,
    required this.lastFailureTime,
  });

  final CircuitBreakerStateType state;
  final int failureCount;
  final DateTime lastFailureTime;

  bool get isClosed => state == CircuitBreakerStateType.closed;
  bool get isOpen => state == CircuitBreakerStateType.open;
  bool get isHalfOpen => state == CircuitBreakerStateType.halfOpen;
}

/// Circuit breaker state types
enum CircuitBreakerStateType {
  closed,   // Normal operation, requests allowed
  open,     // Failing, requests blocked
  halfOpen, // Testing if service has recovered
}

/// Retry state for tracking retry attempts
@immutable
class RetryState {
  const RetryState({
    required this.attempts,
    required this.lastAttemptTime,
  });

  final int attempts;
  final DateTime lastAttemptTime;

  bool get hasExceededMaxRetries(int maxRetries) => attempts >= maxRetries;
}

/// Initialization error record
@immutable
class InitializationError {
  const InitializationError({
    required this.stage,
    required this.error,
    required this.stackTrace,
    required this.timestamp,
    required this.severity,
    required this.type,
    required this.context,
  });

  final InitializationStage stage;
  final Object error;
  final StackTrace stackTrace;
  final DateTime timestamp;
  final ErrorSeverity severity;
  final String type;
  final Map<String, dynamic> context;

  bool get isCritical => severity == ErrorSeverity.critical;
  bool get isRecent => DateTime.now().difference(timestamp).inMinutes < 60;

  @override
  String toString() {
    return 'InitializationError('
        'stage: ${stage.displayName}, '
        'type: $type, '
        'severity: $severity, '
        'timestamp: $timestamp, '
        'error: $error'
        ')';
  }
}

/// Error severity levels
enum ErrorSeverity {
  critical,  // App cannot function
  high,      // Major functionality lost
  medium,    // Some functionality affected
  low,       // Minor issues, can continue
}

/// Error handler interface
abstract class ErrorHandler {
  const ErrorHandler();

  Future<void> handleError(
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  );
}

/// Specific error handler implementations
class NetworkErrorHandler extends ErrorHandler {
  const NetworkErrorHandler();

  @override
  Future<void> handleError(
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[NetworkErrorHandler] Handling network error: $error');
    // Implement network-specific error handling
    // Could include offline mode activation, retry scheduling, etc.
  }
}

class AuthenticationErrorHandler extends ErrorHandler {
  const AuthenticationErrorHandler();

  @override
  Future<void> handleError(
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[AuthenticationErrorHandler] Handling auth error: $error');
    // Implement auth-specific error handling
    // Could include sign-out, re-auth flow, etc.
  }
}

class DataErrorHandler extends ErrorHandler {
  const DataErrorHandler();

  @override
  Future<void> handleError(
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[DataErrorHandler] Handling data error: $error');
    // Implement data-specific error handling
    // Could include cache fallback, data refresh, etc.
  }
}

/// Error statistics
@immutable
class ErrorStatistics {
  const ErrorStatistics({
    required this.totalErrors,
    required this.criticalErrors,
    required this.errorsByStage,
    required this.errorsByType,
    required this.openCircuitBreakers,
    required this.failureRate,
  });

  final int totalErrors;
  final int criticalErrors;
  final Map<InitializationStage, int> errorsByStage;
  final Map<String, int> errorsByType;
  final int openCircuitBreakers;
  final double failureRate;

  bool get hasErrors => totalErrors > 0;
  bool get hasCriticalErrors => criticalErrors > 0;
  bool get hasOpenCircuitBreakers => openCircuitBreakers > 0;
  bool get isHealthy => failureRate < 0.1 && criticalErrors == 0;

  @override
  String toString() {
    return 'ErrorStatistics('
        'total: $totalErrors, '
        'critical: $criticalErrors, '
        'failureRate: ${(failureRate * 100).toStringAsFixed(1)}%, '
        'openCircuitBreakers: $openCircuitBreakers'
        ')';
  }
}