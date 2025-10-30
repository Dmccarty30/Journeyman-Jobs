import 'dart:async';
import '../resilience_strategy.dart';

/// No-retry resilience strategy for testing or bypass scenarios
///
/// Executes operations directly without any retry logic or circuit breaker.
/// Useful for:
/// - Unit testing where you want direct error propagation
/// - Development/debugging scenarios
/// - Non-critical operations that don't need resilience
class NoRetryResilienceStrategy implements ResilienceStrategy {
  // Statistics
  int _totalOperations = 0;
  int _successfulOperations = 0;
  int _failedOperations = 0;

  @override
  Future<T> execute<T>(Future<T> Function() operation) async {
    _totalOperations++;
    try {
      final result = await operation();
      _successfulOperations++;
      return result;
    } catch (error) {
      _failedOperations++;
      rethrow;
    }
  }

  @override
  Stream<T> executeStream<T>(Stream<T> Function() operation) {
    _totalOperations++;
    return operation().handleError((error) {
      _failedOperations++;
      throw error;
    }, test: (error) {
      // Count success if stream completes without error
      return true;
    }).map((value) {
      return value;
    });
  }

  @override
  Map<String, dynamic> getStatistics() {
    return {
      'totalOperations': _totalOperations,
      'successfulOperations': _successfulOperations,
      'failedOperations': _failedOperations,
      'successRate': _totalOperations > 0
          ? (_successfulOperations / _totalOperations * 100).toStringAsFixed(2)
          : '0.00',
      'resilience': 'disabled',
    };
  }

  @override
  void reset() {
    _totalOperations = 0;
    _successfulOperations = 0;
    _failedOperations = 0;
  }
}
