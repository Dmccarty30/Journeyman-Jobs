import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../resilience_strategy.dart';

/// Circuit breaker resilience strategy with exponential backoff
///
/// Provides automatic retry logic for transient failures with:
/// - Exponential backoff between retries
/// - Circuit breaker pattern to prevent cascading failures
/// - Error classification (retryable vs non-retryable)
/// - Comprehensive statistics and monitoring
class CircuitBreakerResilienceStrategy implements ResilienceStrategy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final Duration circuitBreakerTimeout;
  final int failureThreshold;

  // Circuit breaker state
  bool _circuitOpen = false;
  DateTime? _circuitOpenTime;
  int _failureCount = 0;

  // Statistics
  int _totalOperations = 0;
  int _successfulOperations = 0;
  int _failedOperations = 0;
  int _retriedOperations = 0;
  int _circuitBreakerTrips = 0;

  CircuitBreakerResilienceStrategy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
    this.circuitBreakerTimeout = const Duration(minutes: 5),
    this.failureThreshold = 5,
  });

  @override
  Future<T> execute<T>(Future<T> Function() operation) async {
    _totalOperations++;

    if (_isCircuitOpen()) {
      _failedOperations++;
      throw CircuitBreakerOpenException(
        message: 'Service temporarily unavailable (circuit breaker open)',
        resetTime: _getCircuitResetTime(),
      );
    }

    return await _executeWithRetry(operation, retryCount: 0);
  }

  @override
  Stream<T> executeStream<T>(Stream<T> Function() operation) {
    _totalOperations++;

    if (_isCircuitOpen()) {
      _failedOperations++;
      return Stream.error(CircuitBreakerOpenException(
        message: 'Service temporarily unavailable (circuit breaker open)',
        resetTime: _getCircuitResetTime(),
      ));
    }

    return operation().handleError((error) async {
      if (_isRetryableError(error) && _failureCount < maxRetries) {
        final delay = _calculateRetryDelay(_failureCount);

        if (kDebugMode) {
          print('Stream error (attempt ${_failureCount + 1}/$maxRetries), retrying in ${delay.inMilliseconds}ms: $error');
        }

        _retriedOperations++;
        await Future.delayed(delay);
        _failureCount++;

        // Return new stream with retry
        return executeStream(operation);
      } else {
        _onFailure();
        throw error;
      }
    });
  }

  @override
  Map<String, dynamic> getStatistics() {
    return {
      'totalOperations': _totalOperations,
      'successfulOperations': _successfulOperations,
      'failedOperations': _failedOperations,
      'retriedOperations': _retriedOperations,
      'successRate': _totalOperations > 0
          ? (_successfulOperations / _totalOperations * 100).toStringAsFixed(2)
          : '0.00',
      'circuitBreaker': {
        'isOpen': _circuitOpen,
        'openSince': _circuitOpenTime?.toIso8601String(),
        'failureCount': _failureCount,
        'trips': _circuitBreakerTrips,
        'resetTime': _getCircuitResetTime()?.toIso8601String(),
      },
      'retryConfiguration': {
        'maxRetries': maxRetries,
        'initialDelayMs': initialDelay.inMilliseconds,
        'maxDelayMs': maxDelay.inMilliseconds,
        'failureThreshold': failureThreshold,
      },
    };
  }

  @override
  void reset() {
    _resetCircuitBreaker();
    _totalOperations = 0;
    _successfulOperations = 0;
    _failedOperations = 0;
    _retriedOperations = 0;
    _circuitBreakerTrips = 0;

    if (kDebugMode) {
      print('CircuitBreakerResilienceStrategy reset');
    }
  }

  /// Execute operation with retry logic
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    required int retryCount,
  }) async {
    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (error) {
      if (_isRetryableError(error) && retryCount < maxRetries) {
        final delay = _calculateRetryDelay(retryCount);

        if (kDebugMode) {
          print('Operation failed (attempt ${retryCount + 1}/$maxRetries), retrying in ${delay.inMilliseconds}ms: $error');
        }

        _retriedOperations++;
        await Future.delayed(delay);

        return _executeWithRetry(
          operation,
          retryCount: retryCount + 1,
        );
      } else {
        _onFailure();
        if (retryCount >= maxRetries) {
          throw MaxRetriesExceededException(
            message: 'Operation failed',
            attemptCount: retryCount + 1,
            lastError: error,
          );
        }
        rethrow;
      }
    }
  }

  /// Check if circuit breaker is open
  bool _isCircuitOpen() {
    if (!_circuitOpen) return false;

    // Check if timeout has elapsed
    if (_circuitOpenTime != null &&
        DateTime.now().difference(_circuitOpenTime!) > circuitBreakerTimeout) {
      _resetCircuitBreaker();
      return false;
    }

    return true;
  }

  /// Get circuit reset time
  DateTime? _getCircuitResetTime() {
    if (!_circuitOpen || _circuitOpenTime == null) return null;
    return _circuitOpenTime!.add(circuitBreakerTimeout);
  }

  /// Handle successful operation
  void _onSuccess() {
    if (_circuitOpen) {
      _resetCircuitBreaker();
    }
    _failureCount = 0;
    _successfulOperations++;
  }

  /// Handle failed operation
  void _onFailure() {
    _failureCount++;
    _failedOperations++;

    // Open circuit breaker after threshold failures
    if (_failureCount >= failureThreshold && !_circuitOpen) {
      _circuitOpen = true;
      _circuitOpenTime = DateTime.now();
      _circuitBreakerTrips++;

      if (kDebugMode) {
        print('Circuit breaker opened due to $_failureCount consecutive failures');
      }
    }
  }

  /// Reset circuit breaker to closed state
  void _resetCircuitBreaker() {
    if (_circuitOpen && kDebugMode) {
      print('Circuit breaker reset to closed state');
    }

    _circuitOpen = false;
    _circuitOpenTime = null;
    _failureCount = 0;
  }

  /// Check if an error is retryable
  bool _isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'internal':
        case 'cancelled':
        case 'resource-exhausted':
        case 'aborted':
          return true;
        case 'permission-denied':
        case 'not-found':
        case 'already-exists':
        case 'failed-precondition':
        case 'out-of-range':
        case 'unimplemented':
        case 'data-loss':
        case 'unauthenticated':
          return false;
        default:
          return false;
      }
    }

    // Network-related errors are generally retryable
    if (error is TimeoutException ||
        error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return true;
    }

    return false;
  }

  /// Calculate retry delay with exponential backoff and jitter
  Duration _calculateRetryDelay(int retryCount) {
    // Exponential backoff: delay * 2^retryCount
    final exponentialDelay = initialDelay * pow(2, retryCount);

    // Cap at max delay
    final cappedDelayMs = min(
      exponentialDelay.inMilliseconds,
      maxDelay.inMilliseconds,
    );

    // Add jitter to prevent thundering herd (±10%)
    final jitter = Random().nextDouble() * 0.2 - 0.1; // -10% to +10%
    final jitterMs = (cappedDelayMs * jitter).round();

    return Duration(milliseconds: cappedDelayMs + jitterMs);
  }
}
