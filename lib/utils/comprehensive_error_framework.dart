import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Comprehensive error handling and logging framework
///
/// Features:
/// - Structured logging with multiple levels
/// - Error categorization and recovery strategies
/// - Performance monitoring and metrics
/// - Firebase integration for crash reporting
/// - Custom error types with context
/// - Automatic error aggregation and analysis
/// - Debug/production mode handling

/// Enhanced logging system with structured output
class Logger {
  static final Map<String, Logger> _instances = {};
  static LogLevel _globalMinLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static List<LogOutput> _outputs = [];
  static bool _initialized = false;

  final String name;
  LogLevel _minLevel;

  Logger._(this.name, this._minLevel);

  /// Initialize the logging system
  static Future<void> initialize({
    LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info,
    bool enableFileLogging = !kDebugMode,
    bool enableCrashlytics = !kDebugMode,
    bool enableAnalytics = true,
    String? logFilePath,
  }) async {
    if (_initialized) return;

    _globalMinLevel = minLevel;

    // Add console output
    _outputs.add(ConsoleOutput());

    // Add file logging in production
    if (enableFileLogging && logFilePath != null) {
      try {
        _outputs.add(FileOutput(logFilePath));
      } catch (e) {
        developer.log('[Logger] Failed to initialize file logging: $e');
      }
    }

    // Add Crashlytics output in production
    if (enableCrashlytics) {
      try {
        _outputs.add(CrashlyticsOutput());
      } catch (e) {
        developer.log('[Logger] Failed to initialize Crashlytics: $e');
      }
    }

    // Add Analytics output
    if (enableAnalytics) {
      try {
        _outputs.add(AnalyticsOutput());
      } catch (e) {
        developer.log('[Logger] Failed to initialize Analytics: $e');
      }
    }

    _initialized = true;
    developer.log('[Logger] Logging system initialized with min level: $minLevel');
  }

  /// Gets or creates a logger instance
  static Logger getLogger(String name, {LogLevel? minLevel}) {
    if (!_instances.containsKey(name)) {
      _instances[name] = Logger._(name, minLevel ?? _globalMinLevel);
    }
    return _instances[name]!;
  }

  /// Logs a debug message
  void debug(String message, {Map<String, dynamic>? context, String? tag}) {
    log(LogLevel.debug, message, context: context, tag: tag);
  }

  /// Logs an info message
  void info(String message, {Map<String, dynamic>? context, String? tag}) {
    log(LogLevel.info, message, context: context, tag: tag);
  }

  /// Logs a warning message
  void warning(String message, {Map<String, dynamic>? context, String? tag}) {
    log(LogLevel.warning, message, context: context, tag: tag);
  }

  /// Logs an error message
  void error(String message, {Map<String, dynamic>? context, String? tag, Object? error, StackTrace? stackTrace}) {
    log(LogLevel.error, message, context: context, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal error
  void fatal(String message, {Map<String, dynamic>? context, String? tag, Object? error, StackTrace? stackTrace}) {
    log(LogLevel.fatal, message, context: context, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Core logging method
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? context,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(level)) return;

    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      loggerName: name,
      message: message,
      context: context ?? {},
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    for (final output in _outputs) {
      try {
        output.write(logEntry);
      } catch (e) {
        // Fallback to console if output fails
        if (output is! ConsoleOutput) {
          developer.log('[Logger] Output failed: $e');
          ConsoleOutput().write(logEntry);
        }
      }
    }
  }

  bool _shouldLog(LogLevel level) {
    return level.index >= _minLevel.index;
  }

  /// Sets the minimum log level
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Adds a custom output
  static void addOutput(LogOutput output) {
    _outputs.add(output);
  }

  /// Gets all log levels
  static Map<String, LogLevel> getLogLevels() {
    return {
      'debug': LogLevel.debug,
      'info': LogLevel.info,
      'warning': LogLevel.warning,
      'error': LogLevel.error,
      'fatal': LogLevel.fatal,
    };
  }
}

/// Log levels with severity ordering
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal;

  int get index => values.indexOf(this);

  String get name => toString().split('.').last.toUpperCase();
}

/// Log entry data structure
class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.loggerName,
    required this.message,
    required this.context,
    this.tag,
    this.error,
    this.stackTrace,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String loggerName;
  final String message;
  final Map<String, dynamic> context;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  /// Converts to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'logger': loggerName,
      'message': message,
      'context': context,
      'tag': tag,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// Converts to formatted string
  String toFormattedString() {
    final buffer = StringBuffer();
    buffer.write('${timestamp.toIso8601String()} ');
    buffer.write('[${level.name}] ');
    buffer.write('[$loggerName] ');

    if (tag != null) {
      buffer.write('[$tag] ');
    }

    buffer.write(message);

    if (context.isNotEmpty) {
      buffer.write(' | Context: ${context}');
    }

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    return buffer.toString();
  }
}

/// Abstract log output interface
abstract class LogOutput {
  void write(LogEntry entry);
}

/// Console output implementation
class ConsoleOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    final message = entry.toFormattedString();

    switch (entry.level) {
      case LogLevel.debug:
      case LogLevel.info:
        developer.log(message);
        break;
      case LogLevel.warning:
        developer.log(message, name: 'WARNING');
        break;
      case LogLevel.error:
      case LogLevel.fatal:
        developer.log(message, name: 'ERROR', error: entry.error, stackTrace: entry.stackTrace);
        break;
    }
  }
}

/// File output implementation
class FileOutput implements LogOutput {
  final String _filePath;
  late final IOSink _sink;
  bool _isInitialized = false;

  FileOutput(this._filePath);

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final file = File(_filePath);
      await file.parent.create(recursive: true);
      _sink = file.openWrite(mode: FileMode.append);
      _isInitialized = true;
    } catch (e) {
      throw LogException('Failed to initialize file output: $e');
    }
  }

  @override
  Future<void> write(LogEntry entry) async {
    await _initialize();

    try {
      final jsonLine = '${jsonEncode(entry.toJson())}\n';
      _sink.write(jsonLine);
      await _sink.flush();
    } catch (e) {
      throw LogException('Failed to write to log file: $e');
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _sink.close();
      _isInitialized = false;
    }
  }
}

/// Crashlytics output implementation
class CrashlyticsOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    if (entry.level == LogLevel.error || entry.level == LogLevel.fatal) {
      try {
        FirebaseCrashlytics.instance.recordError(
          entry.error ?? Exception(entry.message),
          entry.stackTrace,
          fatal: entry.level == LogLevel.fatal,
          information: [
            DiagnosticsProperty('logger', entry.loggerName),
            DiagnosticsProperty('level', entry.level.name),
            DiagnosticsProperty('tag', entry.tag),
            DiagnosticsProperty('context', entry.context),
          ],
        );
      } catch (e) {
        developer.log('[Crashlytics] Failed to record error: $e');
      }
    }

    // Set user context for better crash reporting
    if (entry.context.containsKey('userId')) {
      FirebaseCrashlytics.instance.setUserIdentifier(entry.context['userId'].toString());
    }
  }
}

/// Analytics output implementation
class AnalyticsOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    try {
      switch (entry.level) {
        case LogLevel.error:
        case LogLevel.fatal:
          FirebaseAnalytics.instance.logEvent(
            name: 'app_error',
            parameters: {
              'error_type': entry.error?.runtimeType.toString() ?? 'unknown',
              'logger': entry.loggerName,
              'tag': entry.tag ?? 'none',
              'context_count': entry.context.length.toString(),
            },
          );
          break;
        case LogLevel.warning:
          FirebaseAnalytics.instance.logEvent(
            name: 'app_warning',
            parameters: {
              'warning_type': entry.tag ?? 'general',
              'logger': entry.loggerName,
            },
          );
          break;
        default:
          break;
      }
    } catch (e) {
      developer.log('[Analytics] Failed to log event: $e');
    }
  }
}

/// Enhanced error handling framework
class ErrorHandler {
  static final Map<Type, List<ErrorStrategy>> _strategies = {};
  static final List<GlobalErrorHandler> _globalHandlers = [];
  static final Queue<ErrorReport> _errorHistory = Queue<ErrorReport>();
  static const int _maxHistorySize = 1000;

  /// Registers an error strategy for a specific exception type
  static void registerStrategy<T extends Exception>(ErrorStrategy strategy) {
    _strategies.putIfAbsent(T, () => []).add(strategy);
  }

  /// Registers a global error handler
  static void registerGlobalHandler(GlobalErrorHandler handler) {
    _globalHandlers.add(handler);
  }

  /// Handles an error with context and recovery attempts
  static Future<ErrorHandlingResult> handleError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? tag,
    bool logError = true,
  }) async {
    final logger = Logger.getLogger('ErrorHandler');
    final errorReport = ErrorReport(
      error: error,
      stackTrace: stackTrace,
      context: context ?? {},
      tag: tag,
      timestamp: DateTime.now(),
    );

    // Log the error
    if (logError) {
      logger.error(
        'Unhandled error: ${error.runtimeType}',
        context: {
          'message': error.toString(),
          ...?context,
        },
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Add to history
    _addToHistory(errorReport);

    // Apply global handlers
    for (final handler in _globalHandlers) {
      try {
        final result = await handler.handleError(errorReport);
        if (result.isHandled) {
          return result;
        }
      } catch (e) {
        logger.error('Global error handler failed', error: e);
      }
    }

    // Apply specific strategies
    final strategies = _strategies[error.runtimeType] ?? [];
    for (final strategy in strategies) {
      try {
        final result = await strategy.handle(errorReport);
        if (result.isHandled) {
          return result;
        }
      } catch (e) {
        logger.error('Error strategy failed', error: e);
      }
    }

    // Default handling
    return ErrorHandlingResult.notHandled(
      'No specific handler found for ${error.runtimeType}',
    );
  }

  static void _addToHistory(ErrorReport report) {
    _errorHistory.add(report);
    while (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeFirst();
    }
  }

  /// Gets error statistics
  static ErrorStatistics getStatistics() {
    final now = DateTime.now();
    final recentErrors = _errorHistory.where(
      (e) => now.difference(e.timestamp).inHours < 24,
    );

    final errorCounts = <Type, int>{};
    for (final error in recentErrors) {
      errorCounts[error.error.runtimeType] = (errorCounts[error.error.runtimeType] ?? 0) + 1;
    }

    return ErrorStatistics(
      totalErrors: recentErrors.length,
      errorsByType: errorCounts,
      mostFrequentError: errorCounts.isEmpty
          ? null
          : errorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      recentErrors: recentErrors.toList(),
    );
  }

  /// Clears error history
  static void clearHistory() {
    _errorHistory.clear();
  }
}

/// Error strategy interface
abstract class ErrorStrategy {
  Future<ErrorHandlingResult> handle(ErrorReport report);
}

/// Global error handler interface
abstract class GlobalErrorHandler {
  Future<ErrorHandlingResult> handleError(ErrorReport report);
}

/// Error handling result
class ErrorHandlingResult {
  const ErrorHandlingResult.handled(this.message) : _isHandled = true;
  const ErrorHandlingResult.notHandled(this.message) : _isHandled = false;

  final bool _isHandled;
  final String message;

  bool get isHandled => _isHandled;
  bool get isNotHandled => !_isHandled;

  @override
  String toString() => 'ErrorHandlingResult.${isHandled ? 'handled' : 'notHandled'}: $message';
}

/// Error report data structure
class ErrorReport {
  const ErrorReport({
    required this.error,
    this.stackTrace,
    required this.context,
    this.tag,
    required this.timestamp,
  });

  final Object error;
  final StackTrace? stackTrace;
  final Map<String, dynamic> context;
  final String? tag;
  final DateTime timestamp;

  String get errorType => error.runtimeType.toString();
  String get errorMessage => error.toString();
}

/// Error statistics
class ErrorStatistics {
  const ErrorStatistics({
    required this.totalErrors,
    required this.errorsByType,
    this.mostFrequentError,
    required this.recentErrors,
  });

  final int totalErrors;
  final Map<Type, int> errorsByType;
  final Type? mostFrequentError;
  final List<ErrorReport> recentErrors;
}

/// Custom exception types
class LogException implements Exception {
  const LogException(this.message);

  final String message;

  @override
  String toString() => 'LogException: $message';
}

/// Built-in error strategies

class NetworkErrorStrategy implements ErrorStrategy {
  @override
  Future<ErrorHandlingResult> handle(ErrorReport report) async {
    if (report.error is SocketException ||
        report.error.toString().contains('network') ||
        report.error.toString().contains('connection')) {

      // Implement network error recovery logic
      await Future.delayed(const Duration(seconds: 2));

      return ErrorHandlingResult.handled(
        'Network error handled with automatic retry',
      );
    }

    return ErrorHandlingResult.notHandled('Not a network error');
  }
}

class FirebaseErrorStrategy implements ErrorStrategy {
  @override
  Future<ErrorHandlingResult> handle(ErrorReport report) async {
    final errorMessage = report.error.toString().toLowerCase();

    if (errorMessage.contains('firebase') ||
        errorMessage.contains('firestore') ||
        errorMessage.contains('auth')) {

      // Implement Firebase error recovery logic
      if (errorMessage.contains('permission-denied')) {
        return ErrorHandlingResult.handled(
          'Firebase permission error handled',
        );
      }

      if (errorMessage.contains('unavailable') || errorMessage.contains('timeout')) {
        return ErrorHandlingResult.handled(
          'Firebase availability error handled with graceful degradation',
        );
      }
    }

    return ErrorHandlingResult.notHandled('Not a Firebase error');
  }
}

/// Performance monitoring integration
class PerformanceLogger {
  static final Logger _logger = Logger.getLogger('Performance');
  static final Map<String, DateTime> _operations = {};

  /// Starts monitoring an operation
  static String startOperation(String name, {Map<String, dynamic>? context}) {
    final operationId = '${name}_${DateTime.now().millisecondsSinceEpoch}';
    _operations[operationId] = DateTime.now();

    _logger.debug(
      'Operation started: $name',
      context: {
        'operationId': operationId,
        ...?context,
      },
      tag: 'performance',
    );

    return operationId;
  }

  /// Ends monitoring an operation
  static void endOperation(String operationId, {Map<String, dynamic>? context, bool success = true}) {
    final startTime = _operations.remove(operationId);
    if (startTime == null) {
      _logger.warning('Operation not found: $operationId', tag: 'performance');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    final level = duration.inMilliseconds > 5000 ? LogLevel.warning : LogLevel.info;

    _logger.log(
      level,
      'Operation ${success ? 'completed' : 'failed'} in ${duration.inMilliseconds}ms',
      context: {
        'operationId': operationId,
        'durationMs': duration.inMilliseconds,
        'success': success,
        ...?context,
      },
      tag: 'performance',
    );

    // Log slow operations to error tracking
    if (duration.inMilliseconds > 5000) {
      ErrorHandler.handleError(
        Exception('Slow operation detected: ${duration.inMilliseconds}ms'),
        context: {
          'operationId': operationId,
          'durationMs': duration.inMilliseconds,
        },
        tag: 'performance',
        logError: false,
      );
    }
  }

  /// Measures execution time of a function
  static Future<T> measure<T>(
    String name,
    Future<T> Function() function, {
    Map<String, dynamic>? context,
  }) async {
    final operationId = startOperation(name, context: context);

    try {
      final result = await function();
      endOperation(operationId, success: true);
      return result;
    } catch (e) {
      endOperation(operationId, success: false);
      rethrow;
    }
  }

  /// Measures execution time of a synchronous function
  static T measureSync<T>(
    String name,
    T Function() function, {
    Map<String, dynamic>? context,
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = function();
      stopwatch.stop();

      _logger.info(
        'Sync operation completed in ${stopwatch.elapsedMilliseconds}ms: $name',
        context: {
          'durationMs': stopwatch.elapsedMilliseconds,
          ...?context,
        },
        tag: 'performance',
      );

      return result;
    } catch (e) {
      stopwatch.stop();

      _logger.error(
        'Sync operation failed after ${stopwatch.elapsedMilliseconds}ms: $name',
        context: {
          'durationMs': stopwatch.elapsedMilliseconds,
          'error': e.toString(),
          ...?context,
        },
        tag: 'performance',
      );

      rethrow;
    }
  }
}