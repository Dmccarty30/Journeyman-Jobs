import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../utils/error_handler.dart';
import '../../domain/exceptions/app_exception.dart';

/// Provider-safe error handling utilities for Riverpod
///
/// This provides consistent error handling patterns across all Riverpod providers
/// with automatic user feedback and logging.
class ErrorHandlingProvider {
  /// Handle async operations in providers with proper error states
  static AsyncValue<T> handleAsyncOperation<T>({
    required AsyncValue<T> previous,
    required Future<T> Function() operation,
    String? operationName,
    String? errorMessage,
    Map<String, dynamic>? context,
    bool showToast = true,
  }) {
    return AsyncValue<T>.guard(
      () async {
        try {
          return await operation();
        } catch (e, stackTrace) {
          await ErrorHandler._logError(
            e,
            stackTrace,
            operationName: operationName,
            context: context,
          );

          // Return the error state
          rethrow;
        }
      },
      error: (e, stackTrace) async {
        // Don't log again - already logged above
        return;
      },
    );
  }

  /// Create a provider that handles errors automatically
  static Provider<AsyncNotifier<T>> createSafeProvider<T>({
    required String name,
    required T Function() initialValue,
    required Future<T> Function() fetchData,
    String? errorMessage,
    Duration? timeout,
  }) {
    return Provider<AsyncNotifier<T>>((ref) {
      final notifier = _SafeAsyncNotifier<T>(
        name: name,
        initialValue: initialValue,
        fetchData: fetchData,
        errorMessage: errorMessage,
        timeout: timeout,
      );
      return notifier;
    });
  }

  /// Wrap a provider with error handling
  static AsyncNotifierProvider<T> wrapWithErrors<T>({
    required String name,
    required T Function() initialValue,
    required Future<T> Function() fetchData,
    String? errorMessage,
    Duration? timeout,
  }) {
    return AsyncNotifierProvider<T>((ref) {
      return _SafeAsyncNotifier<T>(
        name: name,
        initialValue: initialValue,
        fetchData: fetchData,
        errorMessage: errorMessage,
        timeout: timeout,
      );
    });
  }
}

/// AsyncNotifier that handles errors safely
class _SafeAsyncNotifier<T> extends AsyncNotifier<T> {
  final String name;
  final T Function() initialValue;
  final Future<T> Function() fetchData;
  final String? errorMessage;
  final Duration? timeout;

  _SafeAsyncNotifier({
    required this.name,
    required this.initialValue,
    required this.fetchData,
    this.errorMessage,
    this.timeout,
  }) {
    state = AsyncValue.data(initialValue());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      if (timeout != null) {
        state = await fetchData().timeout(timeout).then(
          (data) => AsyncValue.data(data),
          onError: (e, stackTrace) {
            ErrorHandler._logError(
              AppException(
                'Provider $name timed out after ${timeout!.inSeconds}s',
                code: 'provider_timeout',
              ),
              stackTrace,
              operationName: name,
            );
            return AsyncValue.error(
              AppException(
                errorMessage ?? 'Operation timed out',
                code: 'timeout',
              ),
              stackTrace,
            );
          },
        );
      } else {
        state = await fetchData().then(
          (data) => AsyncValue.data(data),
          onError: (e, stackTrace) {
            return AsyncValue.error(e, stackTrace);
          },
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Extension to add error handling to AsyncNotifier
extension AsyncNotifierErrorHandling<T> on AsyncNotifier<T> {
  /// Safely execute an operation with error handling
  Future<void> safeExecute(
    Future<void> Function() operation, {
    String? operationName,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      state = const AsyncValue.loading();
    }

    try {
      await operation();
      // Keep current state if operation completes without changing data
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      await ErrorHandler._logError(
        e,
        stackTrace,
        operationName: operationName ?? 'AsyncNotifier operation',
      );
    }
  }

  /// Safely update state with error handling
  void safeUpdate(T Function(T current) updateFn, {
    String? operationName,
  }) {
    try {
      state.when(
        data: (data) => state = AsyncValue.data(updateFn(data)),
        loading: () => {
          // Don't update while loading
        },
        error: (error, stack) {
          // Don't update on error
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stack);
      ErrorHandler._logError(
        e,
        stack,
        operationName: operationName ?? 'AsyncNotifier update',
      );
    }
  }
}