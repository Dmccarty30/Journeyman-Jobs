import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/error_handler.dart';

/// Provider-safe error handling utilities for Riverpod
///
/// This provides consistent error handling patterns across all Riverpod providers
/// with automatic user feedback and logging.
class ErrorHandlingProvider {
  /// Handle async operations in providers with proper error states
  static Future<AsyncValue<T>> handleAsyncOperation<T>({
    required AsyncValue<T> previous,
    required Future<T> Function() operation,
    String? operationName,
    String? errorMessage,
    Map<String, dynamic>? context,
    bool showToast = true,
  }) async {
    // Use AsyncValue.guard to handle the async operation
    return await AsyncValue.guard(() async => await operation());
  }

  /// Create a provider that handles errors automatically
  static AsyncNotifierProvider<SafeAsyncNotifier<T>, T> createSafeProvider<T>({
    required String name,
    required T Function() initialValue,
    required Future<T> Function() fetchData,
    String? errorMessage,
    Duration? timeout,
  }) {
    return AsyncNotifierProvider<SafeAsyncNotifier<T>, T>(
      () => SafeAsyncNotifier<T>(
        name: name,
        initialValue: initialValue,
        fetchData: fetchData,
        errorMessage: errorMessage,
        timeout: timeout,
      ),
    );
  }

  /// Wrap a provider with error handling
  static AsyncNotifierProvider<SafeAsyncNotifier<T>, T> wrapWithErrors<T>({
    required String name,
    required T Function() initialValue,
    required Future<T> Function() fetchData,
    String? errorMessage,
    Duration? timeout,
  }) {
    return AsyncNotifierProvider<SafeAsyncNotifier<T>, T>(
      () => SafeAsyncNotifier<T>(
        name: name,
        initialValue: initialValue,
        fetchData: fetchData,
        errorMessage: errorMessage,
        timeout: timeout,
      ),
    );
  }
}

/// AsyncNotifier that handles errors safely
class SafeAsyncNotifier<T> extends AsyncNotifier<T> {
  final String name;
  final T Function() initialValue;
  final Future<T> Function() fetchData;
  final String? errorMessage;
  final Duration? timeout;

  SafeAsyncNotifier({
    required this.name,
    required this.initialValue,
    required this.fetchData,
    this.errorMessage,
    this.timeout,
  });

  @override
  Future<T> build() async {
    try {
      final data = await fetchData();
      return data;
    } catch (e, _) {
      ErrorHandler.handleOperation<T>(
        () => initialValue(),
        operationName: name,
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    try {
      if (timeout != null) {
        final result = await fetchData().timeout(timeout!);
        state = AsyncValue.data(result);
      } else {
        final result = await fetchData();
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleOperation<T>(
        () => initialValue(),
        operationName: name,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void dispose() {
    // Cleanup if needed
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
      ErrorHandler.handleOperation<void>(
        () {},
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
        loading: () {
          // Don't update while loading
        },
        error: (error, stack) {
          // Don't update on error
          return;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleOperation<void>(
        () {},
        operationName: operationName ?? 'AsyncNotifier update',
      );
    }
  }
}