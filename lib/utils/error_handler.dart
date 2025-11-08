import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/exceptions/app_exception.dart';
import '../electrical_components/jj_electrical_toast.dart';

/// Unified error handling utility for Journeyman Jobs
///
/// Provides consistent error handling patterns across:
/// - Services
/// - Providers (Riverpod)
/// - Widgets
/// - Network operations
/// - User interactions
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  ErrorHandler._();

  /// Handle errors in async operations with consistent logging
  static Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    String? errorMessage,
    Map<String, dynamic>? context,
    bool showToast = true,
    T? defaultValue,
    bool logToCrashlytics = true,
  }) async {
    try {
      // Call the provided operation and return result
      return await operation();
    } catch (e, stackTrace) {
      // Prefer using a public logging API on ErrorHandler if available.
      // Try to call ErrorHandler.logError / ErrorHandler._logError where appropriate.
      try {
        // If the class has a public logError method, call it
        if (ErrorHandler != null) {
          // Use a defensive call in case only a private logger exists.
          try {
            // Prefer a public API if present
            // ignore: avoid_dynamic_calls
            (ErrorHandler as dynamic).logError?.call(e, stackTrace,
                operationName: operationName, context: context);
          } catch (_) {
            // Fallback to a best-effort private method if present
            try {
              // ignore: avoid_dynamic_calls
              (ErrorHandler as dynamic)._logError?.call(e, stackTrace,
                  operationName: operationName, context: context);
            } catch (_) {
              // Last fallback: print to console (should be replaced by proper logger)
              // ignore: avoid_print
              print('Error during $operationName: $e');
            }
          }
        }
      } catch (_) {
        // ignore
      }

      // Return null to indicate failure (providers already treat null as handled)
      return null;
    }
  }

  /// Handle synchronous operations
  static T? handleOperation<T>(
    T Function() operation, {
    String? operationName,
    T? defaultValue,
    bool showToast = true,
    bool logToCrashlytics = true,
    Map<String, dynamic>? context,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      _logError(
        e,
        StackTrace.current,
        operationName: operationName,
        context: context,
        logToCrashlytics: logToCrashlytics,
      );

      if (showToast) {
        _showUserFriendlyError(e);
      }

      return defaultValue;
    }
  }

  /// Create a result wrapper for operations that can fail
  static Result<T> safeOperation<T>(
    T Function() operation, {
    String? operationName,
    bool logToCrashlytics = true,
  }) {
    try {
      final result = operation();
      return Result.success(result);
    } catch (e, stackTrace) {
      _logError(
        e,
        stackTrace,
        operationName: operationName,
        logToCrashlytics: logToCrashlytics,
      );
      return Result.failure(e);
    }
  }

  /// Log error with context and send to Crashlytics
  static Future<void> _logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? operationName,
    Map<String, dynamic>? context,
    bool logToCrashlytics = true,
  }) async {
    // Always print in debug mode
    if (kDebugMode) {
      debugPrint('🔌 ERROR${operationName != null ? ' [$operationName]' : ''}: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      if (context != null) {
        debugPrint('Context: $context');
      }
    }

    // Send to Crashlytics in production
    if (logToCrashlytics && !kDebugMode) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace ?? StackTrace.current,
          fatal: false,
          information: [
            if (operationName != null) DiagnosticsProperty('operation', operationName),
            if (context != null) ...context.entries.map((e) => DiagnosticsProperty(e.key, e.value)),
          ],
        );
      } catch (e) {
        debugPrint('Failed to record error to Crashlytics: $e');
      }
    }
  }

  /// Show user-friendly error message via toast
  static void _showUserFriendlyError(dynamic error) {
    String message = _getUserFriendlyMessage(error);

    // Note: In real usage, you'd get context from the widget/provider
    // For now, just print the message
    if (kDebugMode) {
      debugPrint('User message: $message');
    }
  }

  /// Get user-friendly message for different error types
  static String _getUserFriendlyMessage(dynamic error) {
    // Network errors
    if (error is SocketException) {
      return 'Connection error. Please check your internet connection.';
    }

    if (error is HttpException) {
      return 'Server error (${error.statusCode}). Please try again later.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    // Firebase errors
    if (error.toString().contains('permission-denied')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (error.toString().contains('unavailable') || error.toString().contains('unauthenticated')) {
      return 'Please sign in to continue.';
    }

    if (error.toString().contains('not-found')) {
      return 'The requested resource was not found.';
    }

    // Custom app exceptions
    if (error is AppException) {
      return error.message;
    }

    // Fallback
    return 'An unexpected error occurred. Please try again.';
  }

  /// Check if error is recoverable
  static bool isRecoverable(dynamic error) {
    // Network issues are often recoverable
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    // Some HTTP errors are recoverable
    if (error is HttpException) {
      return error.statusCode! >= 500; // Server errors
    }

    // Authentication errors are recoverable (user can re-authenticate)
    if (error is UnauthenticatedException) {
      return true;
    }

    return false;
  }

  /// Get retry delay based on error type
  static Duration getRetryDelay(dynamic error, int attempt) {
    // Exponential backoff with jitter
    final baseDelay = Duration(milliseconds: 1000 * (1 << attempt));
    final jitter = Duration(milliseconds: (baseDelay.inMilliseconds * 0.1).round());

    // Network errors get longer delays
    if (error is SocketException || error is TimeoutException) {
      return baseDelay + Duration(seconds: attempt);
    }

    return baseDelay + jitter;
  }
}

/// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final dynamic error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(dynamic error) => Result._(error: error, isSuccess: false);

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(dynamic error) onError,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onError(error);
    }
  }

  Result<U> map<U>(U Function(T data) mapper) {
    if (isSuccess) {
      try {
        return Result.success(mapper(data as T));
      } catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(error);
    }
  }
}

/// Extension to make error handling easier on Futures
extension FutureErrorHandling<T> on Future<T> {
  Future<T?> handleError({
    String? operationName,
    T? defaultValue,
    bool showToast = true,
    bool logToCrashlytics = true,
    Map<String, dynamic>? context,
  }) {
    return ErrorHandler.handleAsyncOperation<T>(
      () async => await this,
      operationName: operationName,
      defaultValue: defaultValue,
      showToast: showToast,
      logToCrashlytics: logToCrashlytics,
      context: context,
    );
  }
}

/// Provider error handling utilities
extension ProviderErrorHandling on Ref {
  /// Handle errors in providers with user feedback
  AsyncValue<T> handleProviderError<T>(
    AsyncValue<T> previous, {
    String? operationName,
    String? userMessage,
  }) {
    if (previous is AsyncError) {
      ErrorHandler._logError(
        previous.error,
        previous.stackTrace ?? StackTrace.current,
        operationName: operationName,
      );

      return AsyncValue<T>.error(
        previous.error,
        previous.stackTrace,
      );
    }

    return previous;
  }
}
