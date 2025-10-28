import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'crew_auth_service.dart';

/// Service for comprehensive logging and monitoring of crew authentication events.
///
/// This service provides security monitoring, anomaly detection, and audit
/// trail functionality for crew authentication operations. It tracks security
/// events, monitors unusual patterns, and provides alerts for potential threats.
///
/// Features:
/// - Comprehensive audit logging for all authentication events
/// - Anomaly detection for unusual access patterns
/// - Real-time security monitoring and alerting
/// - Performance metrics for authentication operations
/// - Security incident tracking and reporting
class CrewAuthMonitoringService {
  final FirebaseFirestore _firestore;

  // Collection names
  static const String _authMetricsCollection = 'crew_auth_metrics';
  static const String _securityEventsCollection = 'crew_security_events';
  static const String _anomalyDetectionCollection = 'crew_anomaly_detection';

  // Monitoring configuration
  static const Duration _metricsWindow = Duration(hours: 24);
  static const Duration _anomalyWindow = Duration(minutes: 15);
  static const int _maxFailedAttempts = 5;
  static const int _maxConcurrentSessions = 3;

  // Performance tracking
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<int>> _performanceMetrics = {};

  CrewAuthMonitoringService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// Logs an authentication event with comprehensive context.
  ///
  /// This method provides detailed logging of authentication events
  /// with security context, performance metrics, and anomaly detection.
  ///
  /// Parameters:
  /// - [event]: The authentication event that occurred
  /// - [userId]: The user ID involved in the event
  /// - [crewId]: The crew ID involved in the event
  /// - [context]: Additional context about the event
  /// - [metadata]: Optional metadata for the event
  Future<void> logAuthEvent({
    required CrewAuthEvent event,
    required String userId,
    required String crewId,
    required AuthEventContext context,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final timestamp = DateTime.now();

      // Create comprehensive event log
      final eventLog = {
        'eventId': _generateEventId(),
        'eventType': event.name,
        'userId': userId,
        'crewId': crewId,
        'timestamp': Timestamp.fromDate(timestamp),
        'context': context.toMap(),
        'metadata': metadata ?? {},
        'userAgent': context.userAgent,
        'ipAddress': context.ipAddress,
        'sessionId': context.sessionId,
        'operationDuration': _getOperationDuration(context.operationId),
      };

      // Log to primary auth events collection
      await _firestore.collection(_authLogsCollection).add(eventLog);

      // Check for security anomalies
      await _checkForAnomalies(userId, crewId, event, context, timestamp);

      // Update performance metrics
      await _updatePerformanceMetrics(event, context.operationId);

      // Check for security alerts
      await _checkForSecurityAlerts(userId, crewId, event, timestamp);

    } catch (e) {
      debugPrint('[CrewAuthMonitoringService] Failed to log auth event: $e');
    }
  }

  /// Tracks failed authentication attempts for security monitoring.
  ///
  /// This method monitors failed authentication attempts to detect
  /// potential brute force attacks or suspicious activity.
  ///
  /// Parameters:
  /// - [userId]: The user ID attempting authentication
  /// - [crewId]: The crew ID being accessed
  /// - [reason]: The reason for the authentication failure
  /// - [context]: Authentication context
  Future<void> trackFailedAttempt({
    required String userId,
    required String crewId,
    required String reason,
    required AuthEventContext context,
  }) async {
    try {
      final timestamp = DateTime.now();

      // Log failed attempt
      await _firestore.collection(_authLogsCollection).add({
        'eventId': _generateEventId(),
        'eventType': 'authentication_failed',
        'userId': userId,
        'crewId': crewId,
        'timestamp': Timestamp.fromDate(timestamp),
        'failureReason': reason,
        'context': context.toMap(),
        'isSecurityEvent': true,
      });

      // Check for brute force patterns
      await _checkBruteForcePatterns(userId, crewId, timestamp);

    } catch (e) {
      debugPrint('[CrewAuthMonitoringService] Failed to track failed attempt: $e');
    }
  }

  /// Monitors session activity for security anomalies.
  ///
  /// This method tracks session activity to detect unusual patterns
  /// like concurrent sessions, suspicious locations, or unusual timing.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  /// - [sessionEvent]: The session event that occurred
  /// - [context]: Session context
  Future<void> monitorSessionActivity({
    required String userId,
    required String crewId,
    required SessionEvent sessionEvent,
    required AuthEventContext context,
  }) async {
    try {
      final timestamp = DateTime.now();

      // Log session activity
      await _firestore.collection(_authLogsCollection).add({
        'eventId': _generateEventId(),
        'eventType': 'session_activity',
        'sessionEvent': sessionEvent.name,
        'userId': userId,
        'crewId': crewId,
        'timestamp': Timestamp.fromDate(timestamp),
        'context': context.toMap(),
      });

      // Check for session anomalies
      await _checkSessionAnomalies(userId, crewId, sessionEvent, timestamp);

    } catch (e) {
      debugPrint('[CrewAuthMonitoringService] Failed to monitor session activity: $e');
    }
  }

  /// Generates a comprehensive security report for a time period.
  ///
  /// This method creates detailed security reports showing authentication
  /// patterns, security events, and potential threats.
  ///
  /// Parameters:
  /// - [startDate]: Start date for the report period
  /// - [endDate]: End date for the report period
  /// - [crewId]: Optional crew ID to filter by
  ///
  /// Returns:
  /// - [SecurityReport] containing comprehensive security analytics
  Future<SecurityReport> generateSecurityReport({
    required DateTime startDate,
    required DateTime endDate,
    String? crewId,
  }) async {
    try {
      // Query authentication events
      final eventsQuery = _firestore
          .collection(_authLogsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (crewId != null) {
        eventsQuery.where('crewId', isEqualTo: crewId);
      }

      final eventsSnapshot = await eventsQuery.get();
      final events = eventsSnapshot.docs;

      // Analyze events for security metrics
      final report = await _analyzeSecurityEvents(events, startDate, endDate);

      return report;
    } catch (e) {
      debugPrint('[CrewAuthMonitoringService] Failed to generate security report: $e');
      return SecurityReport.empty();
    }
  }

  /// Gets real-time security metrics for monitoring dashboard.
  ///
  /// This method provides current security metrics for real-time
  /// monitoring of authentication and access patterns.
  ///
  /// Parameters:
  /// - [crewId]: Optional crew ID to filter metrics
  ///
  /// Returns:
  /// - [SecurityMetrics] containing current security status
  Future<SecurityMetrics> getCurrentSecurityMetrics({String? crewId}) async {
    try {
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

      // Query recent events
      final eventsQuery = _firestore
          .collection(_authLogsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(twentyFourHoursAgo));

      if (crewId != null) {
        eventsQuery.where('crewId', isEqualTo: crewId);
      }

      final eventsSnapshot = await eventsQuery.get();
      final events = eventsSnapshot.docs;

      // Calculate metrics
      final metrics = _calculateSecurityMetrics(events, now);

      return metrics;
    } catch (e) {
      debugPrint('[CrewAuthMonitoringService] Failed to get security metrics: $e');
      return SecurityMetrics.empty();
    }
  }

  /// Tracks performance metrics for authentication operations.
  ///
  /// This method monitors the performance of authentication operations
  /// to identify bottlenecks and optimize user experience.
  ///
  /// Parameters:
  /// - [operation]: The authentication operation being performed
  /// - [operationId]: Unique ID for the operation instance
  /// - [startTime]: Start time of the operation
  /// - [endTime]: End time of the operation
  void trackPerformance({
    required String operation,
    required String operationId,
    required DateTime startTime,
    required DateTime? endTime,
  }) {
    if (endTime != null) {
      final duration = endTime.difference(startTime).inMilliseconds;

      // Store performance metric
      _performanceMetrics.putIfAbsent(operation, () => []);
      _performanceMetrics[operation]!.add(duration);

      // Keep only recent metrics (last 100 operations)
      if (_performanceMetrics[operation]!.length > 100) {
        _performanceMetrics[operation]!.removeAt(0);
      }

      // Clean up operation start time
      _operationStartTimes.remove(operationId);
    } else {
      // Store operation start time
      _operationStartTimes[operationId] = startTime;
    }
  }

  // Private helper methods

  /// Generates a unique event ID for tracking.
  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'evt_${timestamp}_$random';
  }

  /// Gets the duration of an operation.
  int? _getOperationDuration(String operationId) {
    final startTime = _operationStartTimes[operationId];
    if (startTime != null) {
      return DateTime.now().difference(startTime).inMilliseconds;
    }
    return null;
  }

  /// Checks for authentication anomalies.
  Future<void> _checkForAnomalies(
    String userId,
    String crewId,
    CrewAuthEvent event,
    AuthEventContext context,
    DateTime timestamp,
  ) async {
    try {
      // Check for rapid successive attempts
      await _checkRapidAttempts(userId, crewId, timestamp);

      // Check for unusual access patterns
      await _checkUnusualPatterns(userId, crewId, event, timestamp);

      // Check for geographic anomalies
      await _checkGeographicAnomalies(userId, context, timestamp);

    } catch (e) {
      debugPrint('[CrewAuthMonitoringService] Error checking anomalies: $e');
    }
  }

  /// Checks for rapid successive authentication attempts.
  Future<void> _checkRapidAttempts(
    String userId,
    String crewId,
    DateTime timestamp,
  ) async {
    final fiveMinutesAgo = timestamp.subtract(const Duration(minutes: 5));

    final rapidAttempts = await _firestore
        .collection(_authLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('crewId', isEqualTo: crewId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(fiveMinutesAgo))
        .get();

    if (rapidAttempts.size > 10) {
      await _createSecurityAlert(
        type: SecurityAlertType.rapidAttempts,
        userId: userId,
        crewId: crewId,
        severity: SecuritySeverity.high,
        details: 'User made ${rapidAttempts.size} authentication attempts in 5 minutes',
      );
    }
  }

  /// Checks for unusual access patterns.
  Future<void> _checkUnusualPatterns(
    String userId,
    String crewId,
    CrewAuthEvent event,
    DateTime timestamp,
  ) async {
    // Check for access at unusual times
    final hour = timestamp.hour;
    if (hour < 6 || hour > 22) {
      await _createSecurityAlert(
        type: SecurityAlertType.unusual_time,
        userId: userId,
        crewId: crewId,
        severity: SecuritySeverity.medium,
        details: 'Access attempted at unusual hour: $hour:00',
      );
    }
  }

  /// Checks for geographic anomalies.
  Future<void> _checkGeographicAnomalies(
    String userId,
    AuthEventContext context,
    DateTime timestamp,
  ) async {
    // This would integrate with IP geolocation services
    // For now, we'll just log the event for potential analysis
    debugPrint('[CrewAuthMonitoringService] Geographic check for user $userId from ${context.ipAddress}');
  }

  /// Checks for brute force patterns.
  Future<void> _checkBruteForcePatterns(
    String userId,
    String crewId,
    DateTime timestamp,
  ) async {
    final thirtyMinutesAgo = timestamp.subtract(const Duration(minutes: 30));

    final failedAttempts = await _firestore
        .collection(_authLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('crewId', isEqualTo: crewId)
        .where('eventType', isEqualTo: 'authentication_failed')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyMinutesAgo))
        .get();

    if (failedAttempts.size >= _maxFailedAttempts) {
      await _createSecurityAlert(
        type: SecurityAlertType.brute_force,
        userId: userId,
        crewId: crewId,
        severity: SecuritySeverity.critical,
        details: 'User had ${failedAttempts.size} failed authentication attempts in 30 minutes',
      );
    }
  }

  /// Checks for session anomalies.
  Future<void> _checkSessionAnomalies(
    String userId,
    String crewId,
    SessionEvent sessionEvent,
    DateTime timestamp,
  ) async {
    // Check for concurrent sessions
    final activeSessions = await _firestore
        .collection(_authLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('crewId', isEqualTo: crewId)
        .where('sessionEvent', isEqualTo: 'session_created')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(timestamp.subtract(const Duration(hours: 1))))
        .get();

    if (activeSessions.size > _maxConcurrentSessions) {
      await _createSecurityAlert(
        type: SecurityAlertType.concurrent_sessions,
        userId: userId,
        crewId: crewId,
        severity: SecuritySeverity.medium,
        details: 'User has ${activeSessions.size} concurrent sessions',
      );
    }
  }

  /// Creates a security alert.
  Future<void> _createSecurityAlert({
    required SecurityAlertType type,
    required String userId,
    required String crewId,
    required SecuritySeverity severity,
    required String details,
  }) async {
    await _firestore.collection(_securityEventsCollection).add({
      'alertId': _generateEventId(),
      'type': type.name,
      'userId': userId,
      'crewId': crewId,
      'severity': severity.name,
      'details': details,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'resolved': false,
    });

    debugPrint('[CrewAuthMonitoringService] Security Alert: $type for user $userId in crew $crewId');
  }

  /// Updates performance metrics.
  Future<void> _updatePerformanceMetrics(CrewAuthEvent event, String operationId) async {
    final duration = _getOperationDuration(operationId);
    if (duration != null) {
      await _firestore.collection(_authMetricsCollection).add({
        'event': event.name,
        'duration': duration,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  /// Checks for security alerts.
  Future<void> _checkForSecurityAlerts(
    String userId,
    String crewId,
    CrewAuthEvent event,
    DateTime timestamp,
  ) async {
    // Implement specific alert checks based on event type
    if (event == CrewAuthEvent.permissionCheckFailed) {
      // Check for repeated permission failures
      await _checkRepeatedPermissionFailures(userId, crewId, timestamp);
    }
  }

  /// Checks for repeated permission failures.
  Future<void> _checkRepeatedPermissionFailures(
    String userId,
    String crewId,
    DateTime timestamp,
  ) async {
    final tenMinutesAgo = timestamp.subtract(const Duration(minutes: 10));

    final permissionFailures = await _firestore
        .collection(_authLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('crewId', isEqualTo: crewId)
        .where('eventType', isEqualTo: 'permission_check_failed')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(tenMinutesAgo))
        .get();

    if (permissionFailures.size > 20) {
      await _createSecurityAlert(
        type: SecurityAlertType.permission_abuse,
        userId: userId,
        crewId: crewId,
        severity: SecuritySeverity.medium,
        details: 'User had ${permissionFailures.size} permission check failures in 10 minutes',
      );
    }
  }

  /// Analyzes security events for report generation.
  Future<SecurityReport> _analyzeSecurityEvents(
    List<QueryDocumentSnapshot> events,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Implement comprehensive security analysis
    int totalEvents = events.length;
    int securityEvents = 0;
    int failedAuthentications = 0;
    int successfulAuthentications = 0;

    for (final event in events) {
      final data = event.data() as Map<String, dynamic>;
      final eventType = data['eventType'] as String?;

      if (eventType == 'authentication_failed') {
        failedAuthentications++;
      } else if (eventType == 'permission_check_success') {
        successfulAuthentications++;
      }

      if (data['isSecurityEvent'] == true) {
        securityEvents++;
      }
    }

    return SecurityReport(
      periodStart: startDate,
      periodEnd: endDate,
      totalEvents: totalEvents,
      securityEvents: securityEvents,
      failedAuthentications: failedAuthentications,
      successfulAuthentications: successfulAuthentications,
      securityScore: _calculateSecurityScore(
        totalEvents,
        securityEvents,
        failedAuthentications,
      ),
    );
  }

  /// Calculates current security metrics.
  SecurityMetrics _calculateSecurityMetrics(
    List<QueryDocumentSnapshot> events,
    DateTime now,
  ) {
    int totalEvents = events.length;
    int securityAlerts = 0;
    int activeUsers = Set<String>.from(
      events.map((e) => (e.data() as Map<String, dynamic>)['userId'] as String),
    ).length;

    for (final event in events) {
      final data = event.data() as Map<String, dynamic>;
      if (data['isSecurityEvent'] == true) {
        securityAlerts++;
      }
    }

    return SecurityMetrics(
      totalEvents: totalEvents,
      securityAlerts: securityAlerts,
      activeUsers: activeUsers,
      lastUpdated: now,
    );
  }

  /// Calculates security score based on events.
  double _calculateSecurityScore(
    int totalEvents,
    int securityEvents,
    int failedAuthentications,
  ) {
    if (totalEvents == 0) return 100.0;

    double securityScore = 100.0;

    // Deduct points for security events
    securityScore -= (securityEvents / totalEvents) * 50;

    // Deduct points for failed authentications
    securityScore -= (failedAuthentications / totalEvents) * 30;

    return securityScore.clamp(0.0, 100.0);
  }
}

/// Context information for authentication events.
class AuthEventContext {
  final String operationId;
  final String userAgent;
  final String ipAddress;
  final String sessionId;
  final Map<String, dynamic> additionalData;

  AuthEventContext({
    required this.operationId,
    required this.userAgent,
    required this.ipAddress,
    required this.sessionId,
    this.additionalData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'operationId': operationId,
      'userAgent': userAgent,
      'ipAddress': ipAddress,
      'sessionId': sessionId,
      'additionalData': additionalData,
    };
  }
}

/// Enumeration of session events.
enum SessionEvent {
  created,
  expired,
  revoked,
  activity,
}

/// Enumeration of security alert types.
enum SecurityAlertType {
  rapid_attempts,
  unusual_time,
  brute_force,
  concurrent_sessions,
  permission_abuse,
  geographic_anomaly,
}

/// Enumeration of security severity levels.
enum SecuritySeverity {
  low,
  medium,
  high,
  critical,
}

/// Comprehensive security report.
class SecurityReport {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalEvents;
  final int securityEvents;
  final int failedAuthentications;
  final int successfulAuthentications;
  final double securityScore;

  SecurityReport({
    required this.periodStart,
    required this.periodEnd,
    required this.totalEvents,
    required this.securityEvents,
    required this.failedAuthentications,
    required this.successfulAuthentications,
    required this.securityScore,
  });

  static SecurityReport empty() => SecurityReport(
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
    totalEvents: 0,
    securityEvents: 0,
    failedAuthentications: 0,
    successfulAuthentications: 0,
    securityScore: 100.0,
  );
}

/// Real-time security metrics.
class SecurityMetrics {
  final int totalEvents;
  final int securityAlerts;
  final int activeUsers;
  final DateTime lastUpdated;

  SecurityMetrics({
    required this.totalEvents,
    required this.securityAlerts,
    required this.activeUsers,
    required this.lastUpdated,
  });

  static SecurityMetrics empty() => SecurityMetrics(
    totalEvents: 0,
    securityAlerts: 0,
    activeUsers: 0,
    lastUpdated: DateTime.now(),
  );
}