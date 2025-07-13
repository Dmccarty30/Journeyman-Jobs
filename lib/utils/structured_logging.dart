import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Log categories for IBEW electrical workers app
enum LogCategory {
  authentication,
  jobSearch,
  localsData,
  userProfile,
  networking,
  database,
  ui,
  performance,
  memory,
  business,
  system,
}

/// Structured log entry
class LogEntry {
  final String id;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final String? traceId;
  final Duration? duration;

  LogEntry({
    required this.id,
    required this.level,
    required this.category,
    required this.message,
    required this.context,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.traceId,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.name,
      'category': category.name,
      'message': message,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
      'traceId': traceId,
      'duration': duration?.inMilliseconds,
    };
  }

  @override
  String toString() => '${timestamp.toIso8601String()} [${level.name.toUpperCase()}] ${category.name}: $message';
}

/// Performance trace for monitoring
class PerformanceTrace {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic> attributes;

  PerformanceTrace._({
    required this.name,
    required this.startTime,
    this.attributes = const {},
  });

  static Future<PerformanceTrace> start(String name, {Map<String, dynamic>? attributes}) async {
    final startTime = DateTime.now();

    return PerformanceTrace._(
      name: name,
      startTime: startTime,
      attributes: attributes ?? {},
    );
  }

  Future<void> stop({Map<String, dynamic>? additionalAttributes}) async {
    final duration = DateTime.now().difference(startTime);

    // Log performance data
    StructuredLogger.info(
      'Performance trace completed: $name',
      category: LogCategory.performance,
      context: {
        'duration': duration.inMilliseconds,
        'attributes': {...attributes, ...?additionalAttributes},
      },
      duration: duration,
    );
  }
}

/// Comprehensive structured logging service with sensitive data filtering
class StructuredLogger {
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
    'lat',
    'latitude',
    'lng',
    'longitude',
  ];

  static const List<String> _ibewSensitiveKeys = [
    'member_id',
    'local_number',
    'card_number',
    'license_number',
    'certification_id',
    'payroll_number',
    'badge_number',
  ];

  static int _logCounter = 0;
  static String? _currentUserId;
  static String? _currentSessionId;
  static String? _currentTraceId;
  static LogLevel _minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Initialize structured logging
  static void initialize({
    String? userId,
    String? sessionId,
    LogLevel? minLogLevel,
  }) {
    _currentUserId = userId;
    _currentSessionId = sessionId;
    _currentTraceId = _generateTraceId();
    
    if (minLogLevel != null) {
      _minLogLevel = minLogLevel;
    }

    info(
      'Structured logging initialized',
      category: LogCategory.system,
      context: {
        'minLogLevel': _minLogLevel.name,
        'userId': userId != null ? '[SET]' : null,
        'sessionId': sessionId != null ? '[SET]' : null,
      },
    );
  }

  /// Set user context
  static void setUserContext(String? userId, String? sessionId) {
    _currentUserId = userId;
    _currentSessionId = sessionId;
    _currentTraceId = _generateTraceId();

    info(
      'User context updated',
      category: LogCategory.authentication,
      context: {
        'userIdSet': userId != null,
        'sessionIdSet': sessionId != null,
      },
    );
  }

  /// Log debug message
  static void debug(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Duration? duration,
  }) {
    _log(LogLevel.debug, message, category, context, duration);
  }

  /// Log info message
  static void info(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Duration? duration,
  }) {
    _log(LogLevel.info, message, category, context, duration);
  }

  /// Log warning message
  static void warning(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Duration? duration,
  }) {
    _log(LogLevel.warning, message, category, context, duration);
  }

  /// Log error message
  static void error(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Duration? duration,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final enrichedContext = Map<String, dynamic>.from(context ?? {});
    if (error != null) {
      enrichedContext['error'] = error.toString();
    }
    if (stackTrace != null) {
      enrichedContext['stackTrace'] = stackTrace.toString();
    }

    _log(LogLevel.error, message, category, enrichedContext, duration);
  }

  /// Log critical message
  static void critical(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Duration? duration,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final enrichedContext = Map<String, dynamic>.from(context ?? {});
    if (error != null) {
      enrichedContext['error'] = error.toString();
    }
    if (stackTrace != null) {
      enrichedContext['stackTrace'] = stackTrace.toString();
    }

    _log(LogLevel.critical, message, category, enrichedContext, duration);
  }

  /// Log IBEW-specific job search activity
  static void logJobSearch({
    required String searchQuery,
    required String location,
    required List<String> classifications,
    required int resultsCount,
    Duration? searchDuration,
  }) {
    info(
      'Job search performed',
      category: LogCategory.jobSearch,
      context: {
        'query': _sanitizeValue(searchQuery),
        'location': _sanitizeValue(location),
        'classifications': classifications,
        'resultsCount': resultsCount,
        'hasResults': resultsCount > 0,
      },
      duration: searchDuration,
    );
  }

  /// Log IBEW local interaction
  static void logLocalInteraction({
    required String action,
    required String localNumber,
    String? localName,
    Map<String, dynamic>? additionalContext,
  }) {
    info(
      'IBEW local interaction: $action',
      category: LogCategory.localsData,
      context: {
        'action': action,
        'localNumber': _sanitizeValue(localNumber, isIBEWData: true),
        'localName': localName != null ? _sanitizeValue(localName) : null,
        ...?additionalContext,
      },
    );
  }

  /// Log user profile activity
  static void logUserProfile({
    required String action,
    Map<String, dynamic>? profileData,
  }) {
    info(
      'User profile: $action',
      category: LogCategory.userProfile,
      context: {
        'action': action,
        'profileData': profileData != null ? _sanitizeContext(profileData) : null,
      },
    );
  }

  /// Log business logic events
  static void logBusinessEvent({
    required String event,
    required Map<String, dynamic> data,
  }) {
    info(
      'Business event: $event',
      category: LogCategory.business,
      context: {
        'event': event,
        'data': _sanitizeContext(data),
      },
    );
  }

  /// Start performance trace
  static Future<PerformanceTrace> startTrace(
    String name, {
    Map<String, dynamic>? attributes,
  }) async {
    debug(
      'Starting performance trace: $name',
      category: LogCategory.performance,
      context: attributes,
    );

    return PerformanceTrace.start(name, attributes: attributes);
  }

  /// Core logging method
  static void _log(
    LogLevel level,
    String message,
    LogCategory category,
    Map<String, dynamic>? context,
    Duration? duration,
  ) {
    // Check if log level meets minimum threshold
    if (level.index < _minLogLevel.index) return;

    final logEntry = LogEntry(
      id: _generateLogId(),
      level: level,
      category: category,
      message: _sanitizeMessage(message),
      context: _sanitizeContext(context ?? {}),
      timestamp: DateTime.now(),
      userId: _currentUserId,
      sessionId: _currentSessionId,
      traceId: _currentTraceId,
      duration: duration,
    );

    // Output to console in debug mode
    if (kDebugMode) {
      _outputToConsole(logEntry);
    }

    // TODO: In production, integrate with Firebase Analytics
    // Store locally for offline analysis
    _storeLogLocally(logEntry);
  }

  /// Sanitize log message
  static String _sanitizeMessage(String message) {
    String sanitized = message;

    // Remove potential sensitive patterns
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), '[SSN]');
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), '[CARD]');
    sanitized = sanitized.replaceAll(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '[EMAIL]');
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{3}[\s-]?\d{3}[\s-]?\d{4}\b'), '[PHONE]');

    return sanitized;
  }

  /// Sanitize context data
  static Map<String, dynamic> _sanitizeContext(Map<String, dynamic> context) {
    final Map<String, dynamic> sanitized = {};

    for (final entry in context.entries) {
      sanitized[entry.key] = _sanitizeValue(entry.value);
    }

    return sanitized;
  }

  /// Sanitize individual values
  static dynamic _sanitizeValue(dynamic value, {bool isIBEWData = false}) {
    if (value == null) return null;

    if (value is String) {
      final keyLower = value.toLowerCase();
      
      // Check for sensitive keys
      for (final sensitive in _sensitiveKeys) {
        if (keyLower.contains(sensitive)) {
          return '[REDACTED]';
        }
      }

      // Check for IBEW-specific sensitive data
      if (isIBEWData) {
        for (final sensitive in _ibewSensitiveKeys) {
          if (keyLower.contains(sensitive)) {
            return '[IBEW_DATA]';
          }
        }
      }

      return _sanitizeMessage(value);
    }

    if (value is Map) {
      return _sanitizeContext(Map<String, dynamic>.from(value));
    }

    if (value is List) {
      return value.map((item) => _sanitizeValue(item, isIBEWData: isIBEWData)).toList();
    }

    return value;
  }

  /// Output log to console
  static void _outputToConsole(LogEntry logEntry) {
    final levelIcon = _getLevelIcon(logEntry.level);
    final categoryTag = '[${logEntry.category.name.toUpperCase()}]';
    
    developer.log(
      '$levelIcon $categoryTag ${logEntry.message}',
      name: 'JourneymanJobs',
      time: logEntry.timestamp,
      level: _getDeveloperLogLevel(logEntry.level),
    );

    if (logEntry.context.isNotEmpty) {
      developer.log(
        'Context: ${jsonEncode(logEntry.context)}',
        name: 'JourneymanJobs',
        time: logEntry.timestamp,
        level: _getDeveloperLogLevel(logEntry.level),
      );
    }
  }

  /// Store log locally
  static void _storeLogLocally(LogEntry logEntry) {
    // In a real implementation, this would store to local database
    // For now, we'll just track the log count
    _logCounter++;
  }

  /// Get level icon for console output
  static String _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  /// Get developer log level
  static int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  /// Generate unique log ID
  static String _generateLogId() {
    return 'LOG_${DateTime.now().millisecondsSinceEpoch}_${++_logCounter}';
  }

  /// Generate trace ID
  static String _generateTraceId() {
    return 'TRACE_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get logging statistics
  static Map<String, dynamic> getStats() {
    return {
      'totalLogs': _logCounter,
      'currentUser': _currentUserId,
      'currentSession': _currentSessionId,
      'currentTrace': _currentTraceId,
      'minLogLevel': _minLogLevel.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}