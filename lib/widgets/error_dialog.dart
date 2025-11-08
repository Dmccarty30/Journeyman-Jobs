import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Standardized error dialog for consistent error reporting
///
/// Features:
/// - Automatic error categorization (network, validation, system, etc.)
/// - User-friendly error messages
/// - Contextual error actions (retry, report, etc.)
/// - Consistent electrical theme
/// - Optional stack trace for debugging
class ErrorDialog extends StatelessWidget {
  final Object error;
  final String? operationName;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final bool showStackTrace;
  final Map<String, dynamic>? context;

  const ErrorDialog({
    super.key,
    required this.error,
    this.operationName,
    this.onRetry,
    this.onReport,
    this.showStackTrace = kDebugMode,
    this.context,
  });

  /// Show an error dialog
  static Future<void> show({
    required BuildContext context,
    required Object error,
    String? operationName,
    VoidCallback? onRetry,
    VoidCallback? onReport,
    bool showStackTrace = kDebugMode,
    Map<String, dynamic>? errorContext,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => ErrorDialog(
        error: error,
        operationName: operationName,
        onRetry: onRetry,
        onReport: onReport,
        showStackTrace: showStackTrace,
        context: errorContext,
      ),
    );
  }

  /// Get error category based on error type
  ErrorCategory _getErrorCategory(Object error) {
    // Check common error types
    if (error is SocketException) {
      return ErrorCategory.network;
    }
    if (error is TimeoutException) {
      return ErrorCategory.network;
    }
    if (error.toString().contains('network')) {
      return ErrorCategory.network;
    }
    if (error.toString().contains('permission')) {
      return ErrorCategory.permission;
    }
    if (error.toString().contains('unauthorized')) {
      return ErrorCategory.permission;
    }
    if (error.toString().contains('validation')) {
      return ErrorCategory.validation;
    }

    return ErrorCategory.system;
  }

  /// Get user-friendly error message
  String _getErrorMessage() {
    // Use ErrorHandler to get the friendly message
    return error.toString();
  }

  /// Get appropriate icon for error category
  IconData _getErrorIcon() {
    final category = _getErrorCategory(error);
    switch (category) {
      case ErrorCategory.network:
        return Icons.wifi_off;
      case ErrorCategory.validation:
        return Icons.error_outline;
      case ErrorCategory.permission:
        return Icons.security;
      case ErrorCategory.system:
        return Icons.bug_report;
    }
  }

  /// Get appropriate color for error category
  Color _getErrorColor() {
    final category = _getErrorCategory(error);
    switch (category) {
      case ErrorCategory.network:
        return Colors.orange;
      case ErrorCategory.validation:
        return Colors.amber;
      case ErrorCategory.permission:
        return Colors.red;
      case ErrorCategory.system:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _getErrorMessage();
    final errorIcon = _getErrorIcon();
    final errorColor = _getErrorColor();

    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(errorIcon, color: errorColor, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              operationName != null
                ? 'Error in $operationName'
                : 'An Error Occurred',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: errorColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: errorColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Technical details (debug mode only)
          if (showStackTrace) ...[
            ExpansionTile(
              title: Text(
                'Technical Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: const Icon(Icons.code, size: 16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (operationName != null)
                        Text(
                          'Operation: $operationName',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      Text(
                        'Error Type: ${error.runtimeType}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
      if (this.context != null) ...[
        const SizedBox(height: 8),
        Text(
          'Context:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          this.context.toString(),
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        // Retry button (if provided)
        if (onRetry != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),

        // Report button (debug mode only)
        if (showStackTrace && onReport != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onReport!();
            },
            icon: const Icon(Icons.bug_report),
            label: const Text('Report'),
          ),

        // Dismiss button
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          label: const Text('Dismiss'),
        ),
      ],
    );
  }
}

/// Error categorization for consistent error handling
enum ErrorCategory {
  network,
  validation,
  permission,
  system,
}

/// Standardized error snackbar for quick error notifications
class ErrorSnackBar {
  /// Show error snackbar
  static void show({
    required BuildContext context,
    required String message,
    VoidCallback? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: duration,
        action: action != null
          ? SnackBarAction(
              label: 'Fix',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                action();
              },
            )
          : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show network error snackbar
  static void showNetworkError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    show(
      context: context,
      message: 'Network error. Please check your connection.',
      action: onRetry,
    );
  }

  /// Show validation error snackbar
  static void showValidationError({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: 'Validation Error: $message',
    );
  }

  /// Show permission error snackbar
  static void showPermissionError({
    required BuildContext context,
    VoidCallback? onSignIn,
  }) {
    show(
      context: context,
      message: 'Permission denied. Please check your account settings.',
      action: onSignIn,
    );
    }
}

/// Widget that automatically handles errors from AsyncValue (Riverpod)
class AsyncValueErrorHandler<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T) builder;
  final Widget Function(Object)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final String? operationName;

  const AsyncValueErrorHandler({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.operationName,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) => builder(data),
      loading: () => loadingBuilder?.call() ?? const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) {
        if (errorBuilder != null) {
          return errorBuilder!(error);
        }

        // Default error handling
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ErrorDialog.show(
            context: context,
            error: error,
            operationName: operationName,
          );
        });

        // Return error placeholder
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to see details',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
