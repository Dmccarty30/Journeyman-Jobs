import 'dart:async';
import 'package:flutter/foundation.dart';

/// Abstract interface for error management to break circular dependencies
abstract class IErrorManager {
  /// Initialize the error manager
  Future<void> initialize();

  /// Log an error with context
  void logError(
    String type,
    String message, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });

  /// Set fallback mode
  void setFallbackMode(bool enabled);

  /// Isolate an error to prevent cascading failures
  void isolateError(String error);

  /// Handle stage failure during initialization
  Future<void> handleStageFailure(
    String stage,
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  );

  /// Check if a stage can be executed
  bool canExecuteStage(String stage);

  /// Record successful stage completion
  void recordStageSuccess(String stage);

  /// Record stage failure
  void recordStageFailure(String stage, dynamic error);

  /// Reset error manager state
  void reset();

  /// Dispose resources
  void dispose();
}

/// Simple implementation of error manager that avoids circular dependencies
class SimpleErrorManager implements IErrorManager {
  final List<Map<String, dynamic>> _errors = [];
  bool _fallbackMode = false;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    debugPrint('[SimpleErrorManager] Initialized');
  }

  @override
  void logError(
    String type,
    String message, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final error = {
      'type': type,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
    };

    _errors.add(error);

    // Keep only last 100 errors
    if (_errors.length > 100) {
      _errors.removeAt(0);
    }

    debugPrint('[SimpleErrorManager] $type: $message');
    if (context != null) {
      debugPrint('[SimpleErrorManager] Context: $context');
    }
  }

  @override
  void setFallbackMode(bool enabled) {
    _fallbackMode = enabled;
    debugPrint('[SimpleErrorManager] Fallback mode: $enabled');
  }

  @override
  void isolateError(String error) {
    debugPrint('[SimpleErrorManager] Isolated error: $error');
  }

  @override
  Future<void> handleStageFailure(
    String stage,
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic> context,
  ) async {
    logError(
      'StageFailure',
      'Stage $stage failed',
      stackTrace: stackTrace,
      context: {
        'stage': stage,
        'error': error.toString(),
        ...context,
      },
    );
  }

  @override
  bool canExecuteStage(String stage) {
    // Simple implementation - check if stage has had too many failures
    final stageErrors = _errors.where((e) => e['context']?['stage'] == stage);
    return stageErrors.length < 3; // Allow up to 3 failures per stage
  }

  @override
  void recordStageSuccess(String stage) {
    logError(
      'StageSuccess',
      'Stage $stage completed successfully',
      context: {'stage': stage},
    );
  }

  @override
  void recordStageFailure(String stage, dynamic error) {
    logError(
      'StageFailure',
      'Stage $stage failed',
      context: {
        'stage': stage,
        'error': error.toString(),
      },
    );
  }

  @override
  void reset() {
    _errors.clear();
    _fallbackMode = false;
    debugPrint('[SimpleErrorManager] Reset');
  }

  @override
  void dispose() {
    _errors.clear();
    _isInitialized = false;
    debugPrint('[SimpleErrorManager] Disposed');
  }

  /// Get all logged errors
  List<Map<String, dynamic>> get errors => List.unmodifiable(_errors);

  /// Check if fallback mode is enabled
  bool get isFallbackMode => _fallbackMode;
}