import 'package:flutter/foundation.dart';

/// Structured logger for the transformer trainer components
/// Provides consistent logging with different levels and structured data
class StructuredLogger {
  static const String _tag = 'TransformerTrainer';
  
  /// Log levels
  static const String _debug = 'DEBUG';
  static const String _info = 'INFO';
  static const String _warning = 'WARNING';
  static const String _error = 'ERROR';
  
  /// Log a debug message
  static void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      _log(_debug, message, data);
    }
  }
  
  /// Log an info message
  static void info(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      _log(_info, message, data);
    }
  }
  
  /// Log a warning message
  static void warning(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      _log(_warning, message, data);
    }
  }
  
  /// Log an error message
  static void error(String message, {Map<String, dynamic>? data, Object? exception, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log(_error, message, data);
      if (exception != null) {
        debugPrint('Exception: $exception');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Internal logging method
  static void _log(String level, String message, Map<String, dynamic>? data) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$_tag] [$level] $message';
    
    debugPrint(logMessage);
    
    if (data != null && data.isNotEmpty) {
      debugPrint('Data: $data');
    }
  }
  
  /// Log performance metrics
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metrics}) {
    final data = <String, dynamic>{
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      ...?metrics,
    };
    
    info('Performance metric', data: data);
  }
  
  /// Log user interaction
  static void userInteraction(String action, {Map<String, dynamic>? context}) {
    final data = <String, dynamic>{
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?context,
    };
    
    info('User interaction', data: data);
  }
  
  /// Log training progress
  static void trainingProgress(String step, {Map<String, dynamic>? progress}) {
    final data = <String, dynamic>{
      'step': step,
      'timestamp': DateTime.now().toIso8601String(),
      ...?progress,
    };
    
    info('Training progress', data: data);
  }
}
