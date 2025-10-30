import 'dart:async';

/// Strategy interface for handling resilience in Firestore operations
///
/// Implementations provide different resilience patterns like:
/// - Circuit breaker pattern for cascading failures
/// - Retry logic with exponential backoff
/// - Timeout handling
/// - Fallback mechanisms
abstract class ResilienceStrategy {
  /// Execute a Future operation with resilience logic
  ///
  /// [operation] - The async operation to execute
  /// Returns the result of the operation
  /// Throws exception if operation fails after resilience attempts
  Future<T> execute<T>(Future<T> Function() operation);

  /// Execute a Stream operation with resilience logic
  ///
  /// [operation] - The stream operation to execute
  /// Returns a resilient stream
  Stream<T> executeStream<T>(Stream<T> Function() operation);

  /// Get current resilience statistics
  ///
  /// Returns metrics like failure count, circuit state, etc.
  Map<String, dynamic> getStatistics();

  /// Reset resilience state (useful for testing or manual recovery)
  void reset();
}

/// Exception thrown when circuit breaker is open
class CircuitBreakerOpenException implements Exception {
  final String message;
  final DateTime? resetTime;

  CircuitBreakerOpenException({
    this.message = 'Circuit breaker is open - service temporarily unavailable',
    this.resetTime,
  });

  @override
  String toString() {
    if (resetTime != null) {
      return '$message (resets at ${resetTime.toString()})';
    }
    return message;
  }
}

/// Exception thrown when max retries are exhausted
class MaxRetriesExceededException implements Exception {
  final String message;
  final int attemptCount;
  final dynamic lastError;

  MaxRetriesExceededException({
    required this.message,
    required this.attemptCount,
    this.lastError,
  });

  @override
  String toString() => '$message after $attemptCount attempts. Last error: $lastError';
}
