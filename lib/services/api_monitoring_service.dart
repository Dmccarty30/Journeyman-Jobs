import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// API Monitoring Service for Firebase usage tracking and security.
///
/// SECURITY IMPLEMENTATION: 2025-10-30
/// Monitors API usage, tracks errors, and provides security alerts
/// for restricted API keys implementation.
///
/// Features:
/// - API usage tracking and monitoring
/// - Quota exceeded error detection
/// - Security event logging
/// - Performance metrics collection
/// - Rate limiting awareness
class ApiMonitoringService {
  static final ApiMonitoringService _instance = ApiMonitoringService._internal();
  factory ApiMonitoringService() => _instance;
  ApiMonitoringService._internal();

  // Usage tracking
  final Map<String, int> _operationCounts = {};
  final Map<String, DateTime> _lastOperationTime = {};
  final Map<String, int> _errorCounts = {};

  // Security monitoring
  final List<SecurityEvent> _securityEvents = [];
  Timer? _monitoringTimer;

  // Usage thresholds (adjust based on API key limits)
  static const int dailyQuotaWarningThreshold = 80000; // Warn at 80K of 100K
  static const int errorRateThreshold = 50; // Warn if 50+ errors in 5 minutes
  static const Duration monitoringInterval = Duration(minutes: 5);

  /// Initialize the API monitoring service
  void initialize() {
    if (!kDebugMode) {
      _startMonitoring();
      debugPrint('[ApiMonitoring] Service initialized for production monitoring');
    }
  }

  /// Record a successful API operation
  void recordOperation(String operation, {Map<String, dynamic>? metadata}) {
    final operationKey = operation.toLowerCase();
    _operationCounts[operationKey] = (_operationCounts[operationKey] ?? 0) + 1;
    _lastOperationTime[operationKey] = DateTime.now();

    debugPrint('[ApiMonitoring] Operation: $operation, Total: ${_operationCounts[operationKey]}');

    // Check for usage warnings
    _checkUsageThresholds();
  }

  /// Record an API operation error
  void recordError(String operation, String error, {Map<String, dynamic>? metadata}) {
    final operationKey = operation.toLowerCase();
    _errorCounts[operationKey] = (_errorCounts[operationKey] ?? 0) + 1;

    debugPrint('[ApiMonitoring] ERROR: $operation - $error');

    // Check for security-relevant errors
    _checkSecurityErrors(operation, error);

    // Log security event
    _logSecurityEvent(
      type: SecurityEventType.apiError,
      operation: operation,
      details: error,
      metadata: metadata,
    );
  }

  /// Record a Firebase authentication event
  void recordAuthEvent(String event, User? user, {String? error}) {
    debugPrint('[ApiMonitoring] Auth Event: $event, User: ${user?.uid}, Error: $error');

    _logSecurityEvent(
      type: error != null ? SecurityEventType.authError : SecurityEventType.authSuccess,
      operation: event,
      details: error ?? 'Success',
      metadata: {
        'userId': user?.uid,
        'email': user?.email,
        'isAnonymous': user?.isAnonymous,
      },
    );
  }

  /// Get current usage statistics
  Map<String, dynamic> getUsageStats() {
    return {
      'operations': Map.from(_operationCounts),
      'errors': Map.from(_errorCounts),
      'lastOperations': Map.from(_lastOperationTime),
      'totalOperations': _operationCounts.values.fold(0, (a, b) => a + b),
      'totalErrors': _errorCounts.values.fold(0, (a, b) => a + b),
      'securityEvents': _securityEvents.length,
    };
  }

  /// Check if operation is likely rate limited
  bool isRateLimited(String operation) {
    final operationKey = operation.toLowerCase();
    final lastTime = _lastOperationTime[operationKey];

    if (lastTime == null) return false;

    final timeSinceLastOp = DateTime.now().difference(lastTime);
    return timeSinceLastOp.inSeconds < 1; // Less than 1 second suggests rate limiting
  }

  /// Start periodic monitoring
  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(monitoringInterval, (_) {
      _performHealthCheck();
    });
  }

  /// Perform periodic health checks
  void _performHealthCheck() {
    final stats = getUsageStats();

    // Check error rates
    _errorCounts.forEach((operation, errorCount) {
      if (errorCount > errorRateThreshold) {
        debugPrint('[ApiMonitoring] HIGH ERROR RATE: $operation - $errorCount errors');
        _logSecurityEvent(
          type: SecurityEventType.highErrorRate,
          operation: operation,
          details: 'Error rate exceeded threshold: $errorCount errors',
        );
      }
    });

    // Check for unusual patterns
    _checkUnusualPatterns(stats);
  }

  /// Check usage thresholds and issue warnings
  void _checkUsageThresholds() {
    _operationCounts.forEach((operation, count) {
      if (count >= dailyQuotaWarningThreshold) {
        debugPrint('[ApiMonitoring] USAGE WARNING: $operation approaching quota limit');
        _logSecurityEvent(
          type: SecurityEventType.quotaWarning,
          operation: operation,
          details: 'Operation count: $count (threshold: $dailyQuotaWarningThreshold)',
        );
      }
    });
  }

  /// Check for security-relevant errors
  void _checkSecurityErrors(String operation, String error) {
    final lowerError = error.toLowerCase();

    // Check for quota/exceeded errors
    if (lowerError.contains('quota') ||
        lowerError.contains('exceeded') ||
        lowerError.contains('limit')) {
      _logSecurityEvent(
        type: SecurityEventType.quotaExceeded,
        operation: operation,
        details: error,
      );
    }

    // Check for permission denied errors
    if (lowerError.contains('permission') ||
        lowerError.contains('denied') ||
        lowerError.contains('unauthorized')) {
      _logSecurityEvent(
        type: SecurityEventType.permissionDenied,
        operation: operation,
        details: error,
      );
    }

    // Check for API key errors
    if (lowerError.contains('api key') ||
        lowerError.contains('invalid') ||
        lowerError.contains('forbidden')) {
      _logSecurityEvent(
        type: SecurityEventType.apiKeyError,
        operation: operation,
        details: error,
      );
    }
  }

  /// Check for unusual usage patterns
  void _checkUnusualPatterns(Map<String, dynamic> stats) {
    final totalOps = stats['totalOperations'] as int;
    final totalErrors = stats['totalErrors'] as int;

    // High error rate could indicate security issues
    if (totalOps > 0 && (totalErrors / totalOps) > 0.1) {
      debugPrint('[ApiMonitoring] UNUSUAL: High error rate detected (${(totalErrors/totalOps*100).toStringAsFixed(1)}%)');
    }
  }

  /// Log a security event
  void _logSecurityEvent({
    required SecurityEventType type,
    required String operation,
    required String details,
    Map<String, dynamic>? metadata,
  }) {
    final event = SecurityEvent(
      type: type,
      operation: operation,
      details: details,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _securityEvents.add(event);

    // Keep only recent events (last 100)
    if (_securityEvents.length > 100) {
      _securityEvents.removeAt(0);
    }

    debugPrint('[ApiMonitoring] SECURITY EVENT: ${type.name} - $details');
  }

  /// Get recent security events
  List<SecurityEvent> getRecentSecurityEvents({int limit = 10}) {
    return _securityEvents.reversed.take(limit).toList();
  }

  /// Clear monitoring data
  void clearData() {
    _operationCounts.clear();
    _errorCounts.clear();
    _lastOperationTime.clear();
    _securityEvents.clear();
    debugPrint('[ApiMonitoring] All monitoring data cleared');
  }

  /// Dispose monitoring resources
  void dispose() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    debugPrint('[ApiMonitoring] Service disposed');
  }
}

/// Security event types for monitoring
enum SecurityEventType {
  apiError,
  authError,
  authSuccess,
  quotaWarning,
  quotaExceeded,
  permissionDenied,
  apiKeyError,
  highErrorRate,
  unusualPattern,
}

/// Security event data class
class SecurityEvent {
  final SecurityEventType type;
  final String operation;
  final String details;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SecurityEvent({
    required this.type,
    required this.operation,
    required this.details,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'operation': operation,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}