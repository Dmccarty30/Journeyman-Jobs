import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Standardized error handling patterns for the Journeyman Jobs application
/// 
/// This utility provides consistent error handling, logging, and recovery
/// mechanisms across all application components to improve maintainability
/// and user experience.
/// 
/// ## Error Classification:
/// 
/// **NetworkError**: Connectivity and API-related failures
/// **AuthenticationError**: User authentication and authorization issues  
/// **ValidationError**: Data validation and input format problems
/// **StorageError**: Local storage and persistence failures
/// **UnknownError**: Unexpected or unclassified errors
/// 
/// ## Features:
/// 
/// - Consistent error classification and messaging
/// - Automatic error recovery strategies
/// - Structured logging for debugging
/// - User-friendly error messages
/// - Performance metrics for error tracking
/// 
/// ## Usage Examples:
/// 
/// **Basic Error Handling:**
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (error) {
///   final standardError = ErrorHandler.handleError(
///     error, 
///     context: 'Loading jobs data',
///     operation: 'loadJobs'
///   );
///   
///   // Display user-friendly message
///   showErrorMessage(standardError.userMessage);
/// }
/// ```
/// 
/// **With Recovery Strategy:**
/// ```dart
/// final result = await ErrorHandler.executeWithRetry(
///   operation: () => apiCall(),
///   maxRetries: 3,
///   context: 'API fetch',
/// );
/// ```

/// Enumeration of standardized error types
enum ErrorType {
  network,
  authentication,
  validation,
  storage,
  permission,
  timeout,
  unknown,
}

/// Standardized error class with consistent properties
class StandardError {
  final ErrorType type;
  final String code;
  final String message;
  final String userMessage;
  final String context;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic> metadata;
  final bool isRecoverable;
  final int retryCount;

  const StandardError({
    required this.type,
    required this.code,
    required this.message,
    required this.userMessage,
    required this.context,
    required this.timestamp,
    this.stackTrace,
    this.metadata = const {},
    this.isRecoverable = false,
    this.retryCount = 0,
  });

  /// Create a copy with updated properties
  StandardError copyWith({
    ErrorType? type,
    String? code,
    String? message,
    String? userMessage,
    String? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    bool? isRecoverable,
    int? retryCount,
  }) {
    return StandardError(
      type: type ?? this.type,
      code: code ?? this.code,
      message: message ?? this.message,
      userMessage: userMessage ?? this.userMessage,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Convert to JSON for logging
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'code': code,
      'message': message,
      'userMessage': userMessage,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isRecoverable': isRecoverable,
      'retryCount': retryCount,
    };
  }

  @override
  String toString() {
    return 'StandardError(type: $type, code: $code, context: $context, message: $message)';
  }
}

/// Recovery strategy enumeration
enum RecoveryStrategy {
  retry,
  fallback,
  ignore,
  escalate,
  cache,
}

/// Central error handling utility
class ErrorHandler {
  static final Map<String, int> _errorCounts = {};
  static final Map<String, DateTime> _lastErrorTimes = {};
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Handle and standardize any error
  static StandardError handleError(
    dynamic error, {
    required String context,
    String? operation,
    Map<String, dynamic>? metadata,
  }) {
    final timestamp = DateTime.now();
    final errorKey = '$context:${error.runtimeType}';
    
    // Track error frequency
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    _lastErrorTimes[errorKey] = timestamp;

    // Classify and handle specific error types
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error, context, operation, metadata, timestamp);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error, context, operation, metadata, timestamp);
    } else if (error is TimeoutException) {
      return _handleTimeoutError(error, context, operation, metadata, timestamp);
    } else if (error is FormatException) {
      return _handleValidationError(error, context, operation, metadata, timestamp);
    } else {
      return _handleUnknownError(error, context, operation, metadata, timestamp);
    }
  }

  /// Execute operation with automatic retry logic
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = maxRetryAttempts,
    Duration delay = retryDelay,
    String context = 'Unknown operation',
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        final standardError = handleError(
          error,
          context: context,
          metadata: {'attempt': attempts, 'maxRetries': maxRetries},
        );

        // Check if we should retry
        final canRetry = shouldRetry?.call(error) ?? standardError.isRecoverable;
        
        if (attempts > maxRetries || !canRetry) {
          if (kDebugMode) {
            print('ErrorHandler: Operation failed after $attempts attempts - $standardError');
          }
          rethrow;
        }

        // Wait before retry
        if (attempts <= maxRetries) {
          await Future.delayed(delay * attempts);
          
          if (kDebugMode) {
            print('ErrorHandler: Retrying operation (attempt $attempts/$maxRetries) - $context');
          }
        }
      }
    }
    
    throw Exception('Maximum retry attempts exceeded');
  }

  /// Get error statistics for monitoring
  static Map<String, dynamic> getErrorStats() {
    final now = DateTime.now();
    final recentErrors = <String, int>{};
    
    for (final entry in _errorCounts.entries) {
      final lastError = _lastErrorTimes[entry.key];
      if (lastError != null && now.difference(lastError).inMinutes < 60) {
        recentErrors[entry.key] = entry.value;
      }
    }

    return {
      'totalErrorTypes': _errorCounts.length,
      'recentErrors': recentErrors,
      'mostFrequentError': _getMostFrequentError(),
      'errorRate': _calculateErrorRate(),
    };
  }

  /// Handle Firebase Auth errors
  static StandardError _handleFirebaseAuthError(
    FirebaseAuthException error,
    String context,
    String? operation,
    Map<String, dynamic>? metadata,
    DateTime timestamp,
  ) {
    String userMessage;
    bool isRecoverable = false;

    switch (error.code) {
      case 'user-not-found':
        userMessage = 'No account found with this email address.';
        break;
      case 'wrong-password':
        userMessage = 'Incorrect password. Please try again.';
        isRecoverable = true;
        break;
      case 'email-already-in-use':
        userMessage = 'An account already exists with this email address.';
        break;
      case 'weak-password':
        userMessage = 'Password is too weak. Please choose a stronger password.';
        isRecoverable = true;
        break;
      case 'invalid-email':
        userMessage = 'Please enter a valid email address.';
        isRecoverable = true;
        break;
      case 'network-request-failed':
        userMessage = 'Network error. Please check your connection and try again.';
        isRecoverable = true;
        break;
      default:
        userMessage = 'Authentication failed. Please try again.';
        isRecoverable = true;
    }

    if (kDebugMode) {
      print('ErrorHandler: Firebase Auth Error - ${error.code}: ${error.message}');
    }

    return StandardError(
      type: ErrorType.authentication,
      code: error.code,
      message: error.message ?? 'Authentication error',
      userMessage: userMessage,
      context: context,
      timestamp: timestamp,
      stackTrace: error.stackTrace,
      metadata: {
        'operation': operation,
        'errorCode': error.code,
        ...?metadata,
      },
      isRecoverable: isRecoverable,
    );
  }

  /// Handle Firebase Firestore errors
  static StandardError _handleFirebaseError(
    FirebaseException error,
    String context,
    String? operation,
    Map<String, dynamic>? metadata,
    DateTime timestamp,
  ) {
    String userMessage;
    bool isRecoverable = false;
    ErrorType type = ErrorType.network;

    switch (error.code) {
      case 'permission-denied':
        userMessage = 'Access denied. Please check your permissions.';
        type = ErrorType.permission;
        break;
      case 'unavailable':
        userMessage = 'Service temporarily unavailable. Please try again later.';
        isRecoverable = true;
        break;
      case 'deadline-exceeded':
        userMessage = 'Request timed out. Please try again.';
        isRecoverable = true;
        type = ErrorType.timeout;
        break;
      case 'resource-exhausted':
        userMessage = 'Too many requests. Please wait a moment and try again.';
        isRecoverable = true;
        break;
      default:
        userMessage = 'Unable to load data. Please try again.';
        isRecoverable = true;
    }

    if (kDebugMode) {
      print('ErrorHandler: Firebase Error - ${error.code}: ${error.message}');
    }

    return StandardError(
      type: type,
      code: error.code,
      message: error.message ?? 'Firebase error',
      userMessage: userMessage,
      context: context,
      timestamp: timestamp,
      stackTrace: error.stackTrace,
      metadata: {
        'operation': operation,
        'errorCode': error.code,
        ...?metadata,
      },
      isRecoverable: isRecoverable,
    );
  }

  /// Handle timeout errors
  static StandardError _handleTimeoutError(
    TimeoutException error,
    String context,
    String? operation,
    Map<String, dynamic>? metadata,
    DateTime timestamp,
  ) {
    if (kDebugMode) {
      print('ErrorHandler: Timeout Error - ${error.message}');
    }

    return StandardError(
      type: ErrorType.timeout,
      code: 'timeout',
      message: error.message ?? 'Operation timed out',
      userMessage: 'Request timed out. Please check your connection and try again.',
      context: context,
      timestamp: timestamp,
      metadata: {
        'operation': operation,
        'duration': error.duration?.inMilliseconds,
        ...?metadata,
      },
      isRecoverable: true,
    );
  }

  /// Handle validation errors
  static StandardError _handleValidationError(
    FormatException error,
    String context,
    String? operation,
    Map<String, dynamic>? metadata,
    DateTime timestamp,
  ) {
    if (kDebugMode) {
      print('ErrorHandler: Validation Error - ${error.message}');
    }

    return StandardError(
      type: ErrorType.validation,
      code: 'format_error',
      message: error.message,
      userMessage: 'Invalid data format. Please check your input and try again.',
      context: context,
      timestamp: timestamp,
      metadata: {
        'operation': operation,
        'source': error.source,
        'offset': error.offset,
        ...?metadata,
      },
      isRecoverable: true,
    );
  }

  /// Handle unknown errors
  static StandardError _handleUnknownError(
    dynamic error,
    String context,
    String? operation,
    Map<String, dynamic>? metadata,
    DateTime timestamp,
  ) {
    if (kDebugMode) {
      print('ErrorHandler: Unknown Error - $error');
    }

    return StandardError(
      type: ErrorType.unknown,
      code: 'unknown_error',
      message: error.toString(),
      userMessage: 'An unexpected error occurred. Please try again.',
      context: context,
      timestamp: timestamp,
      stackTrace: StackTrace.current,
      metadata: {
        'operation': operation,
        'errorType': error.runtimeType.toString(),
        ...?metadata,
      },
      isRecoverable: true,
    );
  }

  /// Get most frequent error type
  static String? _getMostFrequentError() {
    if (_errorCounts.isEmpty) return null;
    
    return _errorCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Calculate error rate
  static double _calculateErrorRate() {
    final now = DateTime.now();
    int recentErrors = 0;
    
    for (final errorTime in _lastErrorTimes.values) {
      if (now.difference(errorTime).inMinutes < 60) {
        recentErrors++;
      }
    }
    
    return recentErrors / 60.0; // Errors per minute
  }

  /// Clear error statistics
  static void clearStats() {
    _errorCounts.clear();
    _lastErrorTimes.clear();
  }
}