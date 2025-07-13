import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Error severity levels for classification
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error categories for better organization
enum ErrorCategory {
  authentication,
  network,
  database,
  ui,
  memory,
  concurrency,
  business,
  unknown,
}

/// Sanitized error data structure
class SanitizedError {
  final String id;
  final String message;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final String stackTrace;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;

  SanitizedError({
    required this.id,
    required this.message,
    required this.severity,
    required this.category,
    required this.stackTrace,
    required this.context,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'severity': severity.name,
      'category': category.name,
      'stackTrace': stackTrace,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  @override
  String toString() => 'SanitizedError(id: $id, severity: ${severity.name}, category: ${category.name})';
}

/// Comprehensive error sanitization and handling service
class ErrorSanitizationService {
  static const List<String> _sensitiveKeys = [
    'password',
    'token',
    'key',
    'secret',
    'apikey',
    'auth',
    'credential',
    'ssn',
    'social_security',
    'credit_card',
    'phone',
    'email',
    'address',
    'zip',
    'postal',
  ];

  static const List<String> _sensitivePatterns = [
    r'\b\d{3}-\d{2}-\d{4}\b', // SSN
    r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', // Credit card
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', // Email
    r'\b\d{3}[\s-]?\d{3}[\s-]?\d{4}\b', // Phone
    r'AIza[0-9A-Za-z_-]{35}', // Google API key
    r'sk_[a-zA-Z0-9]{24}', // Stripe secret key
    r'pk_[a-zA-Z0-9]{24}', // Stripe public key
  ];

  static int _errorCounter = 0;
  static String? _currentUserId;
  static String? _currentSessionId;

  /// Set current user context
  static void setUserContext(String? userId, String? sessionId) {
    _currentUserId = userId;
    _currentSessionId = sessionId;
  }

  /// Sanitize and process an error
  static SanitizedError sanitizeError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    final errorId = _generateErrorId();
    final sanitizedMessage = _sanitizeMessage(error.toString());
    final sanitizedStackTrace = _sanitizeStackTrace(stackTrace?.toString() ?? '');
    final sanitizedContext = _sanitizeContext(context ?? {});
    final detectedCategory = category ?? _categorizeError(error);
    final detectedSeverity = severity ?? _determineSeverity(error, detectedCategory);

    return SanitizedError(
      id: errorId,
      message: sanitizedMessage,
      severity: detectedSeverity,
      category: detectedCategory,
      stackTrace: sanitizedStackTrace,
      context: sanitizedContext,
      timestamp: DateTime.now(),
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );
  }

  /// Report error to logging and crash reporting services
  static Future<void> reportError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity? severity,
    ErrorCategory? category,
    bool fatal = false,
  }) async {
    final sanitizedError = sanitizeError(
      error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
      category: category,
    );

    // Log to console in debug mode
    if (kDebugMode) {
      developer.log(
        'Error ${sanitizedError.id}: ${sanitizedError.message}',
        name: 'ErrorHandler',
        error: sanitizedError.message,
        stackTrace: stackTrace,
        level: _getSeverityLevel(sanitizedError.severity),
      );
    }

    // TODO: In production, integrate with Firebase Crashlytics
    // For now, store locally for offline analysis
    await _storeErrorLocally(sanitizedError);
  }

  /// Handle and report Flutter framework errors
  static void handleFlutterError(FlutterErrorDetails details) {
    reportError(
      details.exception,
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
        'information': details.informationCollector?.call().map((e) => e.toString()).toList(),
      },
      category: ErrorCategory.ui,
      severity: details.silent ? ErrorSeverity.low : ErrorSeverity.medium,
    );
  }

  /// Handle platform dispatcher errors
  static bool handlePlatformError(Object error, StackTrace stackTrace) {
    reportError(
      error,
      stackTrace: stackTrace,
      category: ErrorCategory.unknown,
      severity: ErrorSeverity.high,
      fatal: true,
    );
    return true; // Continue execution
  }

  /// Sanitize error message by removing sensitive information
  static String _sanitizeMessage(String message) {
    String sanitized = message;

    // Remove sensitive patterns
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAll(RegExp(pattern), '[REDACTED]');
    }

    // Remove file paths and personal directories
    sanitized = sanitized.replaceAll(RegExp(r'/Users/[^/]+'), '/Users/[USER]');
    sanitized = sanitized.replaceAll(RegExp(r'C:\\Users\\[^\\]+'), 'C:\\Users\\[USER]');

    return sanitized;
  }

  /// Sanitize stack trace
  static String _sanitizeStackTrace(String stackTrace) {
    if (stackTrace.isEmpty) return '';

    String sanitized = stackTrace;

    // Remove file paths
    sanitized = sanitized.replaceAll(RegExp(r'/Users/[^/]+'), '/Users/[USER]');
    sanitized = sanitized.replaceAll(RegExp(r'C:\\Users\\[^\\]+'), 'C:\\Users\\[USER]');

    // Limit stack trace length for storage efficiency
    final lines = sanitized.split('\n');
    if (lines.length > 20) {
      return '${lines.take(20).join('\n')}\n... (truncated)';
    }

    return sanitized;
  }

  /// Sanitize context data
  static Map<String, dynamic> _sanitizeContext(Map<String, dynamic> context) {
    final Map<String, dynamic> sanitized = {};

    for (final entry in context.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      // Check if key contains sensitive information
      if (_sensitiveKeys.any((sensitive) => key.contains(sensitive))) {
        sanitized[entry.key] = '[REDACTED]';
        continue;
      }

      // Sanitize string values
      if (value is String) {
        sanitized[entry.key] = _sanitizeMessage(value);
      } else if (value is Map) {
        sanitized[entry.key] = _sanitizeContext(Map<String, dynamic>.from(value));
      } else if (value is List) {
        sanitized[entry.key] = value.map((item) {
          if (item is String) return _sanitizeMessage(item);
          if (item is Map) return _sanitizeContext(Map<String, dynamic>.from(item));
          return item;
        }).toList();
      } else {
        sanitized[entry.key] = value;
      }
    }

    return sanitized;
  }

  /// Categorize error based on type and message
  static ErrorCategory _categorizeError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('auth') || errorString.contains('login') || errorString.contains('signin')) {
      return ErrorCategory.authentication;
    }
    if (errorString.contains('network') || errorString.contains('socket') || errorString.contains('connection')) {
      return ErrorCategory.network;
    }
    if (errorString.contains('firestore') || errorString.contains('database') || errorString.contains('firebase')) {
      return ErrorCategory.database;
    }
    if (errorString.contains('widget') || errorString.contains('render') || errorString.contains('layout')) {
      return ErrorCategory.ui;
    }
    if (errorString.contains('memory') || errorString.contains('outofmemory')) {
      return ErrorCategory.memory;
    }
    if (errorString.contains('concurrent') || errorString.contains('deadlock') || errorString.contains('race')) {
      return ErrorCategory.concurrency;
    }
    if (errorString.contains('business') || errorString.contains('validation')) {
      return ErrorCategory.business;
    }

    return ErrorCategory.unknown;
  }

  /// Determine error severity
  static ErrorSeverity _determineSeverity(dynamic error, ErrorCategory category) {
    final errorString = error.toString().toLowerCase();

    // Critical errors
    if (errorString.contains('outofmemory') || 
        errorString.contains('stackoverflow') ||
        errorString.contains('segmentation') ||
        category == ErrorCategory.memory) {
      return ErrorSeverity.critical;
    }

    // High severity errors
    if (errorString.contains('crash') ||
        errorString.contains('fatal') ||
        category == ErrorCategory.authentication ||
        category == ErrorCategory.concurrency) {
      return ErrorSeverity.high;
    }

    // Medium severity errors
    if (category == ErrorCategory.network ||
        category == ErrorCategory.database ||
        errorString.contains('timeout')) {
      return ErrorSeverity.medium;
    }

    // Default to low for UI and business logic errors
    return ErrorSeverity.low;
  }

  /// Generate unique error ID
  static String _generateErrorId() {
    _errorCounter++;
    return 'ERR_${DateTime.now().millisecondsSinceEpoch}_$_errorCounter';
  }

  /// Get log level for severity
  static int _getSeverityLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 700; // INFO
      case ErrorSeverity.medium:
        return 900; // WARNING
      case ErrorSeverity.high:
        return 1000; // SEVERE
      case ErrorSeverity.critical:
        return 1200; // SHOUT
    }
  }

  /// Store error locally for offline analysis
  static Future<void> _storeErrorLocally(SanitizedError error) async {
    // In a real implementation, this would store to local database
    // For now, we'll just ensure the error is processed
    if (kDebugMode) {
      print('Local error storage: ${error.id} (${error.severity.name})');
    }
  }

  /// Get error statistics
  static Map<String, dynamic> getErrorStats() {
    return {
      'totalErrors': _errorCounter,
      'currentUser': _currentUserId,
      'currentSession': _currentSessionId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Global error handler setup
class GlobalErrorHandler {
  static bool _initialized = false;

  /// Initialize global error handling
  static void initialize() {
    if (_initialized) return;

    // Handle Flutter framework errors
    FlutterError.onError = ErrorSanitizationService.handleFlutterError;

    // Handle platform dispatcher errors
    PlatformDispatcher.instance.onError = ErrorSanitizationService.handlePlatformError;

    _initialized = true;

    if (kDebugMode) {
      print('GlobalErrorHandler: Initialized');
    }
  }

  /// Report a handled error
  static Future<void> reportError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) async {
    await ErrorSanitizationService.reportError(
      error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
      category: category,
    );
  }

  /// Set user context for error reporting
  static void setUserContext(String? userId, String? sessionId) {
    ErrorSanitizationService.setUserContext(userId, sessionId);
  }
}