import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Secure logging service that prevents PII exposure in production
///
/// This service provides comprehensive logging capabilities while ensuring
/// that Personally Identifiable Information (PII) and sensitive data
/// are never exposed in production logs or crash reports.
///
/// Features:
/// - Conditional logging based on build mode
/// - PII detection and filtering
/// - Structured logging with consistent formatting
/// - Performance monitoring for logging operations
/// - Security audit capabilities
/// - Development debugging without production risk
class SecureLoggingService {
  static const String _piiPatterns = '''
    social security number|ssn|tax id|employee id
    |phone number|phone|mobile|cell
    |email address|email|e-mail
    |credit card|card number|cvv|exp
    |password|pwd|secret|token|key
    |address|street|city|state|zip
    |account number|routing number|bank account
    |driver license|passport|id number
    |medical record|patient|diagnosis
    |salary|wage|income|pay|compensation
  ''';

  static final RegExp _piiRegex = RegExp(
    _piiPatterns.replaceAll(RegExp(r'\s+'), '|'),
    caseSensitive: false,
  );

  static final RegExp _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
  );

  static final RegExp _phoneRegex = RegExp(
    r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b|\(\d{3}\)\s*\d{3}[-.]?\d{4}',
  );

  static final RegExp _ssnRegex = RegExp(
    r'\b\d{3}-\d{2}-\d{4}\b|\b\d{9}\b',
  );

  static final RegExp _creditCardRegex = RegExp(
    r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b|\b\d{13,19}\b',
  );

  /// Log debug information (development only)
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;

    final sanitizedMessage = _sanitizeMessage(message);
    final sanitizedError = error != null ? _sanitizeMessage(error.toString()) : null;

    if (sanitizedMessage.isNotEmpty) {
      debugPrint('[$tag] DEBUG: $sanitizedMessage');
    }

    if (sanitizedError != null && sanitizedError.isNotEmpty) {
      debugPrint('[$tag] ERROR: $sanitizedError');
      if (stackTrace != null) {
        debugPrint('[$tag] STACK: $stackTrace');
      }
    }
  }

  /// Log information (development and staging)
  static void info(String message, {String? tag}) {
    if (kReleaseMode) return;

    final sanitizedMessage = _sanitizeMessage(message);
    if (sanitizedMessage.isNotEmpty) {
      debugPrint('[$tag] INFO: $sanitizedMessage');
    }
  }

  /// Log warnings (all environments except production)
  static void warning(String message, {String? tag}) {
    if (kReleaseMode) return;

    final sanitizedMessage = _sanitizeMessage(message);
    if (sanitizedMessage.isNotEmpty) {
      debugPrint('[$tag] WARNING: $sanitizedMessage');
    }
  }

  /// Log errors (all environments)
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Always log errors, but sanitize them
    final sanitizedMessage = _sanitizeMessage(message);
    final sanitizedError = error != null ? _sanitizeMessage(error.toString()) : null;

    if (sanitizedMessage.isNotEmpty) {
      debugPrint('[$tag] ERROR: $sanitizedMessage');
    }

    if (sanitizedError != null && sanitizedError.isNotEmpty) {
      debugPrint('[$tag] ERROR DETAILS: $sanitizedError');
    }

    if (stackTrace != null) {
      // Sanitize stack trace to remove any sensitive data from file paths
      final sanitizedStack = _sanitizeStackTrace(stackTrace);
      debugPrint('[$tag] STACK: $sanitizedStack');
    }
  }

  /// Log critical security events (always logged)
  static void security(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Security events are always logged but sanitized
    final sanitizedMessage = _sanitizeSecurityMessage(message);
    final sanitizedError = error != null ? _sanitizeMessage(error.toString()) : null;

    debugPrint('🚨 SECURITY ALERT: [$tag] $sanitizedMessage');

    if (sanitizedError != null && sanitizedError.isNotEmpty) {
      debugPrint('🚨 SECURITY ERROR: [$tag] $sanitizedError');
    }

    if (stackTrace != null) {
      debugPrint('🚨 SECURITY STACK: [$tag] $stackTrace');
    }
  }

  /// Log performance metrics (development and staging)
  static void performance(String operation, Duration duration, {String? tag, Map<String, dynamic>? metadata}) {
    if (kReleaseMode) return;

    final sanitizedMetadata = metadata?.map((key, value) {
      final sanitizedValue = value is String ? _sanitizeMessage(value) : value;
      return MapEntry(key, sanitizedValue);
    });

    debugPrint('[$tag] PERFORMANCE: $operation took ${duration.inMilliseconds}ms');
    if (sanitizedMetadata != null && sanitizedMetadata.isNotEmpty) {
      debugPrint('[$tag] PERFORMANCE METADATA: $sanitizedMetadata');
    }
  }

  /// Log user actions (with privacy protection)
  static void userAction(String action, {String? tag, String? userId, Map<String, dynamic>? context}) {
    if (kReleaseMode) return;

    // Sanitize user ID - never log actual user identifiers
    final sanitizedUserId = userId != null ? _hashUserId(userId) : null;

    // Sanitize context data
    final sanitizedContext = context?.map((key, value) {
      if (_isSensitiveField(key)) {
        return MapEntry(key, '[REDACTED]');
      }
      final sanitizedValue = value is String ? _sanitizeMessage(value) : value;
      return MapEntry(key, sanitizedValue);
    });

    debugPrint('[$tag] USER ACTION: $action ${sanitizedUserId != null ? 'by user: $sanitizedUserId' : ''}');
    if (sanitizedContext != null && sanitizedContext.isNotEmpty) {
      debugPrint('[$tag] ACTION CONTEXT: $sanitizedContext');
    }
  }

  /// Sanitize message to remove PII and sensitive information
  static String _sanitizeMessage(String message) {
    if (message.isEmpty) return message;

    String sanitized = message;

    // Remove email addresses
    sanitized = sanitized.replaceAll(_emailRegex, '[EMAIL_REDACTED]');

    // Remove phone numbers
    sanitized = sanitized.replaceAll(_phoneRegex, '[PHONE_REDACTED]');

    // Remove social security numbers
    sanitized = sanitized.replaceAll(_ssnRegex, '[SSN_REDACTED]');

    // Remove credit card numbers
    sanitized = sanitized.replaceAll(_creditCardRegex, '[CARD_REDACTED]');

    // Remove API keys and tokens
    sanitized = sanitized.replaceAll(RegExp(r'[A-Za-z0-9]{20,}'), '[KEY_REDACTED]');

    // Remove JWT tokens
    sanitized = sanitized.replaceAll(RegExp(r'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'), '[JWT_REDACTED]');

    // Remove password fields
    sanitized = sanitized.replaceAll(RegExp(r'(?i)password["\s]*[:=]["\s]*[^",\s}]+'), 'password: [REDACTED]');

    // Remove common PII patterns
    sanitized = sanitized.replaceAllMapped(_piiRegex, (match) => '[PII_REDACTED]');

    // Limit message length to prevent log flooding
    if (sanitized.length > 500) {
      sanitized = '${sanitized.substring(0, 497)}...';
    }

    return sanitized;
  }

  /// Sanitize security messages (less aggressive filtering)
  static String _sanitizeSecurityMessage(String message) {
    if (message.isEmpty) return message;

    String sanitized = message;

    // Only remove the most sensitive data from security logs
    sanitized = sanitized.replaceAll(RegExp(r'[A-Za-z0-9]{32,}'), '[SECRET_REDACTED]');
    sanitized = sanitized.replaceAll(_emailRegex, '[EMAIL_REDACTED]');
    sanitized = sanitized.replaceAll(_phoneRegex, '[PHONE_REDACTED]');

    return sanitized;
  }

  /// Sanitize stack trace to remove sensitive file paths
  static String _sanitizeStackTrace(StackTrace stackTrace) {
    String sanitized = stackTrace.toString();

    // Remove absolute paths, keep only relative paths
    sanitized = sanitized.replaceAll(RegExp(r'[A-Za-z]:\\[^)]*'), '[PATH_REDACTED]');
    sanitized = sanitized.replaceAll(RegExp(r'/[^)]*/'), '[PATH_REDACTED]/');

    return sanitized;
  }

  /// Check if a field name indicates sensitive data
  static bool _isSensitiveField(String fieldName) {
    final sensitiveFields = [
      'password', 'pwd', 'secret', 'token', 'key', 'api_key',
      'credit_card', 'card_number', 'cvv', 'exp', 'ssn',
      'social_security', 'email', 'phone', 'address',
      'account_number', 'routing_number', 'bank_account',
      'driver_license', 'passport', 'id_number',
      'medical_record', 'patient', 'diagnosis',
      'salary', 'wage', 'income', 'pay', 'compensation',
    ];

    return sensitiveFields.any((field) =>
      fieldName.toLowerCase().contains(field.toLowerCase())
    );
  }

  /// Hash user ID for logging (never log actual user identifiers)
  static String _hashUserId(String userId) {
    // Create a consistent hash for the user ID without exposing the actual ID
    final bytes = userId.codeUnits;
    int hash = 0;
    for (int i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash) + bytes[i];
      hash = hash & 0xFFFFFFFF; // Convert to 32-bit integer
    }
    return 'USER_${hash.abs().toRadixString(16).padLeft(8, '0')}';
  }

  /// Create a structured log entry for complex data
  static Map<String, dynamic> createLogEntry({
    required String level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final entry = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'message': _sanitizeMessage(message),
      if (tag != null) 'tag': tag,
      if (error != null) 'error': _sanitizeMessage(error.toString()),
      if (stackTrace != null) 'stack': _sanitizeStackTrace(stackTrace),
      if (metadata != null) 'metadata': _sanitizeMetadata(metadata),
    };

    return entry;
  }

  /// Sanitize metadata dictionary
  static Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic> metadata) {
    return metadata.map((key, value) {
      if (_isSensitiveField(key)) {
        return MapEntry(key, '[REDACTED]');
      }
      if (value is String) {
        return MapEntry(key, _sanitizeMessage(value));
      }
      return MapEntry(key, value);
    });
  }
}

/// Extension for easy logging access
extension SecureLogging on Object {
  void logDebug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    SecureLoggingService.debug(message, tag: tag ?? runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  void logInfo(String message, {String? tag}) {
    SecureLoggingService.info(message, tag: tag ?? runtimeType.toString());
  }

  void logWarning(String message, {String? tag}) {
    SecureLoggingService.warning(message, tag: tag ?? runtimeType.toString());
  }

  void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    SecureLoggingService.error(message, tag: tag ?? runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  void logSecurity(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    SecureLoggingService.security(message, tag: tag ?? runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  void logPerformance(String operation, Duration duration, {String? tag, Map<String, dynamic>? metadata}) {
    SecureLoggingService.performance(operation, duration, tag: tag ?? runtimeType.toString(), metadata: metadata);
  }

  void logUserAction(String action, {String? tag, String? userId, Map<String, dynamic>? context}) {
    SecureLoggingService.userAction(action, tag: tag ?? runtimeType.toString(), userId: userId, context: context);
  }
}