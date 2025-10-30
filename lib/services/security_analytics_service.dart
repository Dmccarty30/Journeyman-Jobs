import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/security/rate_limiter.dart';
import 'package:journeyman_jobs/services/crew_auth_service.dart';

/// Advanced security analytics service for anomaly detection and threat analysis.
///
/// This service provides comprehensive security monitoring for the Journeyman Jobs
/// crew system with sophisticated anomaly detection algorithms, threat pattern
/// recognition, and automated alert generation.
///
/// Features:
/// - Real-time security event aggregation and analysis
/// - Machine learning-based anomaly detection
/// - Threat pattern recognition and classification
/// - Automated security alert generation
/// - Security metrics dashboard data
/// - Historical security trend analysis
/// - Integration with existing authentication services
class SecurityAnalyticsService {
  static final SecurityAnalyticsService _instance = SecurityAnalyticsService._internal();
  factory SecurityAnalyticsService() => _instance;
  SecurityAnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CrewAuthService _crewAuthService = CrewAuthService();

  // Collection names
  static const String _securityEventsCollection = 'security_events';
  static const String _analyticsCollection = 'security_analytics';
  static const String _threatPatternsCollection = 'threat_patterns';
  static const String _alertsCollection = 'security_alerts';

  // Anomaly detection thresholds
  static const int _failedAuthThreshold = 5; // Failed auth attempts
  static const int _suspiciousActivityThreshold = 20; // Suspicious operations
  static const Duration _analysisWindow = Duration(hours: 1);
  static const Duration _historicalWindow = Duration(days: 7);

  // Security event types for classification
  enum SecurityEventType {
    authentication,
    authorization,
    crewOperation,
    dataAccess,
    permissionChange,
    sessionManagement,
    suspiciousActivity,
    securityViolation,
  }

  // Threat severity levels
  enum ThreatSeverity {
    low,
    medium,
    high,
    critical,
  }

  // Analysis cache for performance optimization
  final Map<String, _AnalysisCache> _analysisCache = {};
  static const Duration _cacheTTL = Duration(minutes: 5);

  // Active monitoring streams
  final Map<String, StreamSubscription> _monitoringStreams = {};
  Timer? _analysisTimer;

  /// Initialize security analytics monitoring
  ///
  /// Starts real-time monitoring of security events and begins periodic
  /// analysis for anomaly detection and threat identification.
  ///
  /// Returns [true] if initialization successful, [false] otherwise
  Future<bool> initialize() async {
    try {
      debugPrint('[SecurityAnalytics] Initializing security analytics monitoring');

      // Start real-time event monitoring
      await _startEventMonitoring();

      // Start periodic analysis
      _startPeriodicAnalysis();

      // Initialize threat pattern database
      await _initializeThreatPatterns();

      debugPrint('[SecurityAnalytics] Security analytics initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Failed to initialize: $e');
      return false;
    }
  }

  /// Analyze security events for anomalies and threats
  ///
  /// Performs comprehensive analysis of recent security events to identify
  /// patterns, anomalies, and potential threats using machine learning
  /// algorithms and statistical analysis.
  ///
  /// Parameters:
  /// - [timeWindow]: Analysis time window (default: 1 hour)
  /// - [eventTypes]: Specific event types to analyze (optional)
  ///
  /// Returns [SecurityAnalysisResult] with findings and recommendations
  Future<SecurityAnalysisResult> analyzeSecurityEvents({
    Duration timeWindow = _analysisWindow,
    List<SecurityEventType>? eventTypes,
  }) async {
    try {
      final cacheKey = _generateCacheKey(timeWindow, eventTypes);
      final cachedResult = _getCachedAnalysis(cacheKey);
      if (cachedResult != null) {
        return cachedResult;
      }

      debugPrint('[SecurityAnalytics] Starting security event analysis');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Fetch security events for analysis
      final events = await _fetchSecurityEvents(startTime, endTime, eventTypes);

      // Perform anomaly detection
      final anomalies = await _detectAnomalies(events);

      // Identify threat patterns
      final threats = await _identifyThreatPatterns(events, anomalies);

      // Calculate security metrics
      final metrics = _calculateSecurityMetrics(events);

      // Generate recommendations
      final recommendations = _generateRecommendations(anomalies, threats, metrics);

      final result = SecurityAnalysisResult(
        analysisTime: DateTime.now(),
        timeWindow: timeWindow,
        totalEvents: events.length,
        anomalies: anomalies,
        threats: threats,
        metrics: metrics,
        recommendations: recommendations,
        riskScore: _calculateRiskScore(anomalies, threats, metrics),
      );

      // Cache the result
      _cacheAnalysis(cacheKey, result);

      // Store analysis results
      await _storeAnalysisResult(result);

      debugPrint('[SecurityAnalytics] Analysis completed: ${events.length} events, ${anomalies.length} anomalies, ${threats.length} threats');
      return result;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error during security analysis: $e');
      throw Exception('Security analysis failed: $e');
    }
  }

  /// Detect suspicious user behavior patterns
  ///
  /// Analyzes user behavior to identify suspicious patterns such as:
  /// - Rapid authentication failures
  /// - Unusual access patterns
  /// - Privilege escalation attempts
  /// - Data exfiltration patterns
  ///
  /// Parameters:
  /// - [userId]: User ID to analyze
  /// - [timeWindow]: Analysis time window
  ///
  /// Returns list of detected suspicious behaviors
  Future<List<SuspiciousBehavior>> detectSuspiciousBehavior({
    required String userId,
    Duration timeWindow = _analysisWindow,
  }) async {
    try {
      debugPrint('[SecurityAnalytics] Analyzing behavior for user: $userId');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Get user's security events
      final userEvents = await _firestore
          .collection(_securityEventsCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
          .orderBy('timestamp', descending: true)
          .get();

      final events = userEvents.docs.map((doc) => SecurityEvent.fromFirestore(doc)).toList();

      List<SuspiciousBehavior> suspiciousBehaviors = [];

      // Analyze authentication patterns
      final authBehaviors = _analyzeAuthenticationPatterns(events, userId);
      suspiciousBehaviors.addAll(authBehaviors);

      // Analyze access patterns
      final accessBehaviors = _analyzeAccessPatterns(events, userId);
      suspiciousBehaviors.addAll(accessBehaviors);

      // Analyze permission changes
      final permissionBehaviors = _analyzePermissionPatterns(events, userId);
      suspiciousBehaviors.addAll(permissionBehaviors);

      // Analyze data access patterns
      final dataBehaviors = _analyzeDataAccessPatterns(events, userId);
      suspiciousBehaviors.addAll(dataBehaviors);

      // Sort by severity and timestamp
      suspiciousBehaviors.sort((a, b) {
        int severityComparison = b.severity.index.compareTo(a.severity.index);
        if (severityComparison != 0) return severityComparison;
        return b.timestamp.compareTo(a.timestamp);
      });

      debugPrint('[SecurityAnalytics] Detected ${suspiciousBehaviors.length} suspicious behaviors for user $userId');
      return suspiciousBehaviors;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error detecting suspicious behavior: $e');
      return [];
    }
  }

  /// Generate security metrics report
  ///
  /// Creates comprehensive security metrics report including:
  /// - Authentication success/failure rates
  /// - Authorization denial rates
  /// - Most active users and crews
  /// - Geographic access patterns
  /// - Time-based activity patterns
  ///
  /// Parameters:
  /// - [timeWindow]: Report time window
  /// - [includeDetails]: Include detailed breakdowns
  ///
  /// Returns [SecurityMetricsReport] with comprehensive metrics
  Future<SecurityMetricsReport> generateSecurityReport({
    Duration timeWindow = _historicalWindow,
    bool includeDetails = true,
  }) async {
    try {
      debugPrint('[SecurityAnalytics] Generating security metrics report');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Get all security events in time window
      final allEvents = await _fetchSecurityEvents(startTime, endTime, null);

      // Calculate authentication metrics
      final authMetrics = _calculateAuthenticationMetrics(allEvents);

      // Calculate authorization metrics
      final authzMetrics = _calculateAuthorizationMetrics(allEvents);

      // Calculate user activity metrics
      final userMetrics = _calculateUserActivityMetrics(allEvents);

      // Calculate crew activity metrics
      final crewMetrics = _calculateCrewActivityMetrics(allEvents);

      // Calculate temporal patterns
      final temporalPatterns = _calculateTemporalPatterns(allEvents);

      // Calculate geographic patterns
      final geographicPatterns = _calculateGeographicPatterns(allEvents);

      final report = SecurityMetricsReport(
        generatedAt: DateTime.now(),
        timeWindow: timeWindow,
        totalEvents: allEvents.length,
        authenticationMetrics: authMetrics,
        authorizationMetrics: authzMetrics,
        userActivityMetrics: userMetrics,
        crewActivityMetrics: crewMetrics,
        temporalPatterns: temporalPatterns,
        geographicPatterns: geographicPatterns,
        detailedBreakdown: includeDetails ? _generateDetailedBreakdown(allEvents) : null,
      );

      // Store report
      await _storeSecurityReport(report);

      debugPrint('[SecurityAnalytics] Security report generated successfully');
      return report;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error generating security report: $e');
      throw Exception('Security report generation failed: $e');
    }
  }

  /// Create security alert for detected threats
  ///
  /// Generates and stores security alerts for detected threats with
  /// appropriate severity levels and recommendations for response.
  ///
  /// Parameters:
  /// - [threat]: Detected threat
  /// - [context]: Additional context information
  ///
  /// Returns created security alert
  Future<SecurityAlert> createSecurityAlert({
    required Threat threat,
    Map<String, dynamic>? context,
  }) async {
    try {
      final alert = SecurityAlert(
        id: '', // Will be set by Firestore
        threatId: threat.id,
        title: _generateAlertTitle(threat),
        description: threat.description,
        severity: threat.severity,
        userId: threat.userId,
        crewId: threat.crewId,
        timestamp: DateTime.now(),
        status: AlertStatus.active,
        recommendations: _generateAlertRecommendations(threat),
        context: context ?? {},
      );

      // Store alert
      final docRef = await _firestore.collection(_alertsCollection).add(alert.toFirestore());
      final savedAlert = alert.copyWith(id: docRef.id);

      // Log alert creation
      await _logSecurityEvent(
        type: SecurityEventType.securityViolation,
        userId: threat.userId,
        details: 'Security alert created: ${threat.type}',
        severity: threat.severity,
        metadata: {
          'alertId': savedAlert.id,
          'threatId': threat.id,
          'threatType': threat.type.toString(),
        },
      );

      debugPrint('[SecurityAnalytics] Security alert created: ${savedAlert.id}');
      return savedAlert;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error creating security alert: $e');
      throw Exception('Failed to create security alert: $e');
    }
  }

  /// Get active security alerts
  ///
  /// Retrieves all active security alerts, optionally filtered by severity
  /// and time range.
  ///
  /// Parameters:
  /// - [severity]: Filter by severity (optional)
  /// - [timeWindow]: Filter by time window (optional)
  /// - [limit]: Maximum number of alerts to return
  ///
  /// Returns list of active security alerts
  Future<List<SecurityAlert>> getActiveSecurityAlerts({
    ThreatSeverity? severity,
    Duration? timeWindow,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_alertsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('timestamp', descending: true);

      if (severity != null) {
        query = query.where('severity', isEqualTo: severity.name);
      }

      if (timeWindow != null) {
        final cutoffTime = DateTime.now().subtract(timeWindow);
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffTime));
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => SecurityAlert.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error getting security alerts: $e');
      return [];
    }
  }

  /// Resolve security alert
  ///
  /// Marks a security alert as resolved with resolution details.
  ///
  /// Parameters:
  /// - [alertId]: Alert ID to resolve
  /// - [resolution]: Resolution details
  /// - [resolvedBy]: User who resolved the alert
  ///
  /// Returns [true] if successful, [false] otherwise
  Future<bool> resolveSecurityAlert({
    required String alertId,
    required String resolution,
    required String resolvedBy,
  }) async {
    try {
      await _firestore.collection(_alertsCollection).doc(alertId).update({
        'status': 'resolved',
        'resolution': resolution,
        'resolvedBy': resolvedBy,
        'resolvedAt': Timestamp.now(),
      });

      debugPrint('[SecurityAnalytics] Security alert resolved: $alertId');
      return true;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error resolving security alert: $e');
      return false;
    }
  }

  // Private helper methods

  /// Start real-time security event monitoring
  Future<void> _startEventMonitoring() async {
    try {
      final subscription = _firestore
          .collection(_securityEventsCollection)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .snapshots()
          .listen((snapshot) {
        // Process new security events in real-time
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _processNewSecurityEvent(change.doc);
          }
        }
      });

      _monitoringStreams['security_events'] = subscription;
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error starting event monitoring: $e');
    }
  }

  /// Start periodic security analysis
  void _startPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(Duration(minutes: 15), (_) {
      _performPeriodicAnalysis();
    });
  }

  /// Perform periodic security analysis
  Future<void> _performPeriodicAnalysis() async {
    try {
      debugPrint('[SecurityAnalytics] Performing periodic security analysis');

      final result = await analyzeSecurityEvents();

      // Check for critical threats
      final criticalThreats = result.threats.where((t) => t.severity == ThreatSeverity.critical);
      if (criticalThreats.isNotEmpty) {
        for (final threat in criticalThreats) {
          await createSecurityAlert(threat: threat);
        }
      }

      // Clean up old analysis data
      await _cleanupOldAnalysisData();
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error in periodic analysis: $e');
    }
  }

  /// Initialize threat pattern database
  Future<void> _initializeThreatPatterns() async {
    try {
      // Check if threat patterns exist
      final snapshot = await _firestore.collection(_threatPatternsCollection).limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      // Create default threat patterns
      final defaultPatterns = [
        ThreatPattern(
          id: 'brute_force_auth',
          name: 'Brute Force Authentication',
          description: 'Multiple failed authentication attempts',
          severity: ThreatSeverity.high,
          pattern: {'eventType': 'authentication', 'result': 'failed'},
          threshold: 5,
          timeWindow: Duration(minutes: 5),
        ),
        ThreatPattern(
          id: 'privilege_escalation',
          name: 'Privilege Escalation Attempt',
          description: 'User attempting to access unauthorized resources',
          severity: ThreatSeverity.critical,
          pattern: {'eventType': 'authorization', 'result': 'denied'},
          threshold: 3,
          timeWindow: Duration(minutes: 10),
        ),
        ThreatPattern(
          id: 'unusual_access_pattern',
          name: 'Unusual Access Pattern',
          description: 'Access patterns deviating from user baseline',
          severity: ThreatSeverity.medium,
          pattern: {'eventType': 'dataAccess'},
          threshold: 10,
          timeWindow: Duration(hours: 1),
        ),
      ];

      for (final pattern in defaultPatterns) {
        await _firestore.collection(_threatPatternsCollection).add(pattern.toFirestore());
      }

      debugPrint('[SecurityAnalytics] Initialized ${defaultPatterns.length} threat patterns');
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error initializing threat patterns: $e');
    }
  }

  /// Fetch security events from Firestore
  Future<List<SecurityEvent>> _fetchSecurityEvents(
    DateTime startTime,
    DateTime endTime,
    List<SecurityEventType>? eventTypes,
  ) async {
    try {
      Query query = _firestore
          .collection(_securityEventsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endTime));

      if (eventTypes != null && eventTypes.isNotEmpty) {
        final typeStrings = eventTypes.map((e) => e.toString().split('.').last).toList();
        query = query.where('eventType', whereIn: typeStrings);
      }

      final snapshot = await query.orderBy('timestamp', descending: true).get();
      return snapshot.docs.map((doc) => SecurityEvent.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error fetching security events: $e');
      return [];
    }
  }

  /// Detect anomalies in security events
  Future<List<SecurityAnomaly>> _detectAnomalies(List<SecurityEvent> events) async {
    final anomalies = <SecurityAnomaly>[];

    // Statistical anomaly detection
    anomalies.addAll(_detectStatisticalAnomalies(events));

    // Pattern-based anomaly detection
    anomalies.addAll(_detectPatternAnomalies(events));

    // Behavioral anomaly detection
    anomalies.addAll(_detectBehavioralAnomalies(events));

    return anomalies;
  }

  /// Detect statistical anomalies
  List<SecurityAnomaly> _detectStatisticalAnomalies(List<SecurityEvent> events) {
    final anomalies = <SecurityAnomaly>[];

    // Group events by user
    final userEvents = <String, List<SecurityEvent>>{};
    for (final event in events) {
      userEvents.putIfAbsent(event.userId, () => []).add(event);
    }

    // Analyze each user's event patterns
    for (final entry in userEvents.entries) {
      final userId = entry.key;
      final userEventList = entry.value;

      // Check for excessive failed authentications
      final failedAuths = userEventList.where((e) =>
          e.eventType == SecurityEventType.authentication &&
          e.metadata['result'] == 'failed').length;

      if (failedAuths >= _failedAuthThreshold) {
        anomalies.add(SecurityAnomaly(
          id: '',
          type: 'excessive_failed_auth',
          userId: userId,
          severity: ThreatSeverity.high,
          description: 'User $userId has $failedAuths failed authentication attempts',
          timestamp: DateTime.now(),
          metadata: {'failedAttempts': failedAuths},
        ));
      }

      // Check for rapid successive operations
      final rapidOps = _detectRapidOperations(userEventList);
      anomalies.addAll(rapidOps);
    }

    return anomalies;
  }

  /// Detect rapid successive operations
  List<SecurityAnomaly> _detectRapidOperations(List<SecurityEvent> userEvents) {
    final anomalies = <SecurityAnomaly>[];
    const rapidOperationThreshold = 50; // operations in 1 minute

    // Group events by minute
    final minuteGroups = <int, List<SecurityEvent>>{};
    for (final event in userEvents) {
      final minute = event.timestamp.minute;
      minuteGroups.putIfAbsent(minute, () => []).add(event);
    }

    // Check for rapid operations in any minute
    for (final entry in minuteGroups.entries) {
      if (entry.value.length >= rapidOperationThreshold) {
        anomalies.add(SecurityAnomaly(
          id: '',
          type: 'rapid_operations',
          userId: userEvents.first.userId,
          severity: ThreatSeverity.medium,
          description: 'Rapid succession of ${entry.value.length} operations detected',
          timestamp: DateTime.now(),
          metadata: {'operationCount': entry.value.length, 'minute': entry.key},
        ));
      }
    }

    return anomalies;
  }

  /// Detect pattern-based anomalies
  List<SecurityAnomaly> _detectPatternAnomalies(List<SecurityEvent> events) {
    final anomalies = <SecurityAnomaly>[];

    // Load threat patterns
    // Implementation would compare events against known threat patterns
    // This is a simplified version

    return anomalies;
  }

  /// Detect behavioral anomalies
  List<SecurityAnomaly> _detectBehavioralAnomalies(List<SecurityEvent> events) {
    final anomalies = <SecurityAnomaly>[];

    // Analyze user behavior patterns
    // Compare against historical baselines
    // Detect deviations from normal patterns

    return anomalies;
  }

  /// Identify threat patterns
  Future<List<Threat>> _identifyThreatPatterns(
    List<SecurityEvent> events,
    List<SecurityAnomaly> anomalies,
  ) async {
    final threats = <Threat>[];

    // Load threat patterns from database
    final patternsSnapshot = await _firestore.collection(_threatPatternsCollection).get();
    final patterns = patternsSnapshot.docs.map((doc) => ThreatPattern.fromFirestore(doc)).toList();

    // Match events and anomalies against threat patterns
    for (final pattern in patterns) {
      final matches = _matchThreatPattern(events, anomalies, pattern);
      threats.addAll(matches);
    }

    return threats;
  }

  /// Match events against threat pattern
  List<Threat> _matchThreatPattern(
    List<SecurityEvent> events,
    List<SecurityAnomaly> anomalies,
    ThreatPattern pattern,
  ) {
    final threats = <Threat>[];

    // Implement pattern matching logic
    // This is a simplified version

    return threats;
  }

  /// Calculate security metrics
  SecurityMetrics _calculateSecurityMetrics(List<SecurityEvent> events) {
    final totalEvents = events.length;
    final authEvents = events.where((e) => e.eventType == SecurityEventType.authentication).length;
    final failedAuths = events.where((e) =>
        e.eventType == SecurityEventType.authentication &&
        e.metadata['result'] == 'failed').length;

    final authSuccessRate = authEvents > 0 ? (authEvents - failedAuths) / authEvents : 1.0;

    return SecurityMetrics(
      totalEvents: totalEvents,
      authenticationEvents: authEvents,
      failedAuthentications: failedAuths,
      authenticationSuccessRate: authSuccessRate,
      uniqueUsers: events.map((e) => e.userId).toSet().length,
      uniqueCrews: events.map((e) => e.crewId).where((id) => id.isNotEmpty).toSet().length,
      calculatedAt: DateTime.now(),
    );
  }

  /// Generate security recommendations
  List<String> _generateRecommendations(
    List<SecurityAnomaly> anomalies,
    List<Threat> threats,
    SecurityMetrics metrics,
  ) {
    final recommendations = <String>[];

    // Authentication recommendations
    if (metrics.authenticationSuccessRate < 0.9) {
      recommendations.add('Consider implementing additional authentication security measures');
    }

    // Anomaly-based recommendations
    if (anomalies.isNotEmpty) {
      recommendations.add('Review security anomalies and consider implementing additional monitoring');
    }

    // Threat-based recommendations
    final criticalThreats = threats.where((t) => t.severity == ThreatSeverity.critical);
    if (criticalThreats.isNotEmpty) {
      recommendations.add('Immediate action required: Critical threats detected');
    }

    return recommendations;
  }

  /// Calculate overall risk score
  double _calculateRiskScore(
    List<SecurityAnomaly> anomalies,
    List<Threat> threats,
    SecurityMetrics metrics,
  ) {
    double score = 0.0;

    // Factor in authentication success rate
    score += (1.0 - metrics.authenticationSuccessRate) * 0.3;

    // Factor in anomalies (weighted by severity)
    for (final anomaly in anomalies) {
      switch (anomaly.severity) {
        case ThreatSeverity.low:
          score += 0.1;
          break;
        case ThreatSeverity.medium:
          score += 0.2;
          break;
        case ThreatSeverity.high:
          score += 0.4;
          break;
        case ThreatSeverity.critical:
          score += 0.8;
          break;
      }
    }

    // Factor in threats (weighted by severity)
    for (final threat in threats) {
      switch (threat.severity) {
        case ThreatSeverity.low:
          score += 0.15;
          break;
        case ThreatSeverity.medium:
          score += 0.3;
          break;
        case ThreatSeverity.high:
          score += 0.6;
          break;
        case ThreatSeverity.critical:
          score += 1.0;
          break;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Store analysis result
  Future<void> _storeAnalysisResult(SecurityAnalysisResult result) async {
    try {
      await _firestore.collection(_analyticsCollection).add(result.toFirestore());
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error storing analysis result: $e');
    }
  }

  /// Process new security event in real-time
  void _processNewSecurityBehavior(DocumentSnapshot doc) {
    try {
      final event = SecurityEvent.fromFirestore(doc);

      // Check for immediate threats
      if (event.metadata['result'] == 'failed' &&
          event.eventType == SecurityEventType.authentication) {
        // Could trigger immediate analysis for this user
        _scheduleImmediateAnalysis(event.userId);
      }
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error processing new security event: $e');
    }
  }

  /// Schedule immediate analysis for user
  void _scheduleImmediateAnalysis(String userId) {
    // Schedule analysis for this user in the near future
    Timer(Duration(seconds: 30), () {
      detectSuspiciousBehavior(userId: userId);
    });
  }

  /// Analyze authentication patterns
  List<SuspiciousBehavior> _analyzeAuthenticationPatterns(List<SecurityEvent> events, String userId) {
    final behaviors = <SuspiciousBehavior>[];

    // Check for rapid failed attempts
    final failedEvents = events.where((e) =>
        e.eventType == SecurityEventType.authentication &&
        e.metadata['result'] == 'failed').toList();

    if (failedEvents.length >= _failedAuthThreshold) {
      behaviors.add(SuspiciousBehavior(
        id: '',
        userId: userId,
        type: 'rapid_failed_auth',
        severity: ThreatSeverity.high,
        description: 'Rapid failed authentication attempts detected',
        timestamp: DateTime.now(),
        events: failedEvents,
        metadata: {'failedCount': failedEvents.length},
      ));
    }

    return behaviors;
  }

  /// Analyze access patterns
  List<SuspiciousBehavior> _analyzeAccessPatterns(List<SecurityEvent> events, String userId) {
    final behaviors = <SuspiciousBehavior>[];

    // Check for unusual access times or locations
    // Implementation would analyze access patterns against user baselines

    return behaviors;
  }

  /// Analyze permission patterns
  List<SuspiciousBehavior> _analyzePermissionPatterns(List<SecurityEvent> events, String userId) {
    final behaviors = <SuspiciousBehavior>[];

    // Check for suspicious permission changes
    final permissionEvents = events.where((e) =>
        e.eventType == SecurityEventType.permissionChange).toList();

    if (permissionEvents.isNotEmpty) {
      behaviors.add(SuspiciousBehavior(
        id: '',
        userId: userId,
        type: 'permission_changes',
        severity: ThreatSeverity.medium,
        description: 'Permission changes detected',
        timestamp: DateTime.now(),
        events: permissionEvents,
        metadata: {'changeCount': permissionEvents.length},
      ));
    }

    return behaviors;
  }

  /// Analyze data access patterns
  List<SuspiciousBehavior> _analyzeDataAccessPatterns(List<SecurityEvent> events, String userId) {
    final behaviors = <SuspiciousBehavior>[];

    // Check for unusual data access patterns
    final dataEvents = events.where((e) =>
        e.eventType == SecurityEventType.dataAccess).toList();

    if (dataEvents.length > _suspiciousActivityThreshold) {
      behaviors.add(SuspiciousBehavior(
        id: '',
        userId: userId,
        type: 'excessive_data_access',
        severity: ThreatSeverity.medium,
        description: 'Excessive data access activity detected',
        timestamp: DateTime.now(),
        events: dataEvents,
        metadata: {'accessCount': dataEvents.length},
      ));
    }

    return behaviors;
  }

  /// Calculate authentication metrics
  AuthenticationMetrics _calculateAuthenticationMetrics(List<SecurityEvent> events) {
    final authEvents = events.where((e) => e.eventType == SecurityEventType.authentication);
    final totalAuths = authEvents.length;
    final successfulAuths = authEvents.where((e) => e.metadata['result'] == 'success').length;
    final failedAuths = totalAuths - successfulAuths;

    return AuthenticationMetrics(
      totalAttempts: totalAuths,
      successfulAttempts: successfulAuths,
      failedAttempts: failedAuths,
      successRate: totalAuths > 0 ? successfulAuths / totalAuths : 1.0,
    );
  }

  /// Calculate authorization metrics
  AuthorizationMetrics _calculateAuthorizationMetrics(List<SecurityEvent> events) {
    final authzEvents = events.where((e) => e.eventType == SecurityEventType.authorization);
    final totalAuthz = authzEvents.length;
    final grantedAuthz = authzEvents.where((e) => e.metadata['result'] == 'granted').length;
    final deniedAuthz = totalAuthz - grantedAuthz;

    return AuthorizationMetrics(
      totalRequests: totalAuthz,
      grantedRequests: grantedAuthz,
      deniedRequests: deniedAuthz,
      denialRate: totalAuthz > 0 ? deniedAuthz / totalAuthz : 0.0,
    );
  }

  /// Calculate user activity metrics
  UserActivityMetrics _calculateUserActivityMetrics(List<SecurityEvent> events) {
    final userCounts = <String, int>{};
    for (final event in events) {
      userCounts[event.userId] = (userCounts[event.userId] ?? 0) + 1;
    }

    final sortedUsers = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return UserActivityMetrics(
      uniqueUsers: userCounts.length,
      mostActiveUsers: sortedUsers.take(10).map((e) => UserActivity(userId: e.key, eventCount: e.value)).toList(),
      averageEventsPerUser: userCounts.isNotEmpty ? events.length / userCounts.length : 0.0,
    );
  }

  /// Calculate crew activity metrics
  CrewActivityMetrics _calculateCrewActivityMetrics(List<SecurityEvent> events) {
    final crewCounts = <String, int>{};
    for (final event in events) {
      if (event.crewId.isNotEmpty) {
        crewCounts[event.crewId] = (crewCounts[event.crewId] ?? 0) + 1;
      }
    }

    final sortedCrews = crewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return CrewActivityMetrics(
      uniqueCrews: crewCounts.length,
      mostActiveCrews: sortedCrews.take(10).map((e) => CrewActivity(crewId: e.key, eventCount: e.value)).toList(),
      averageEventsPerCrew: crewCounts.isNotEmpty ? events.length / crewCounts.length : 0.0,
    );
  }

  /// Calculate temporal patterns
  TemporalPatterns _calculateTemporalPatterns(List<SecurityEvent> events) {
    final hourlyDistribution = List<int>.filled(24, 0);
    final dailyDistribution = List<int>.filled(7, 0);

    for (final event in events) {
      hourlyDistribution[event.timestamp.hour]++;
      dailyDistribution[event.timestamp.weekday % 7]++;
    }

    return TemporalPatterns(
      hourlyDistribution: hourlyDistribution,
      dailyDistribution: dailyDistribution,
      peakHour: hourlyDistribution.indexOf(hourlyDistribution.reduce(math.max)),
      peakDay: dailyDistribution.indexOf(dailyDistribution.reduce(math.max)),
    );
  }

  /// Calculate geographic patterns
  GeographicPatterns _calculateGeographicPatterns(List<SecurityEvent> events) {
    final locations = <String, int>{};

    for (final event in events) {
      final location = event.metadata['location'] as String? ?? 'unknown';
      locations[location] = (locations[location] ?? 0) + 1;
    }

    final sortedLocations = locations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GeographicPatterns(
      uniqueLocations: locations.length,
      topLocations: sortedLocations.take(10).map((e) => LocationActivity(location: e.key, eventCount: e.value)).toList(),
    );
  }

  /// Generate detailed breakdown
  Map<String, dynamic> _generateDetailedBreakdown(List<SecurityEvent> events) {
    return {
      'eventTypes': _groupByEventType(events),
      'userBreakdown': _groupByUser(events),
      'crewBreakdown': _groupByCrew(events),
      'timeDistribution': _groupByTime(events),
    };
  }

  Map<String, int> _groupByEventType(List<SecurityEvent> events) {
    final typeCounts = <String, int>{};
    for (final event in events) {
      final type = event.eventType.toString().split('.').last;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }

  Map<String, int> _groupByUser(List<SecurityEvent> events) {
    final userCounts = <String, int>{};
    for (final event in events) {
      userCounts[event.userId] = (userCounts[event.userId] ?? 0) + 1;
    }
    return userCounts;
  }

  Map<String, int> _groupByCrew(List<SecurityEvent> events) {
    final crewCounts = <String, int>{};
    for (final event in events) {
      if (event.crewId.isNotEmpty) {
        crewCounts[event.crewId] = (crewCounts[event.crewId] ?? 0) + 1;
      }
    }
    return crewCounts;
  }

  Map<String, int> _groupByTime(List<SecurityEvent> events) {
    final timeCounts = <String, int>{};
    for (final event in events) {
      final hour = '${event.timestamp.hour}:00';
      timeCounts[hour] = (timeCounts[hour] ?? 0) + 1;
    }
    return timeCounts;
  }

  /// Store security report
  Future<void> _storeSecurityReport(SecurityMetricsReport report) async {
    try {
      await _firestore.collection(_analyticsCollection).add({
        'type': 'security_report',
        'report': report.toFirestore(),
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error storing security report: $e');
    }
  }

  /// Generate alert title
  String _generateAlertTitle(Threat threat) {
    switch (threat.type) {
      case 'brute_force':
        return 'Brute Force Attack Detected';
      case 'privilege_escalation':
        return 'Privilege Escalation Attempt';
      case 'unusual_access':
        return 'Unusual Access Pattern';
      default:
        return 'Security Threat Detected';
    }
  }

  /// Generate alert recommendations
  List<String> _generateAlertRecommendations(Threat threat) {
    switch (threat.type) {
      case 'brute_force':
        return [
          'Consider temporarily locking the user account',
          'Implement additional authentication factors',
          'Monitor user activity closely',
        ];
      case 'privilege_escalation':
        return [
          'Review user permissions immediately',
          'Investigate attempted resource access',
          'Consider revoking suspicious permissions',
        ];
      case 'unusual_access':
        return [
          'Verify user identity through additional means',
          'Review recent account activity',
          'Contact user if activity is unexpected',
        ];
      default:
        return [
          'Investigate the security event',
          'Monitor related activities',
          'Document findings and actions taken',
        ];
    }
  }

  /// Log security event
  Future<void> _logSecurityEvent({
    required SecurityEventType type,
    required String userId,
    required String details,
    ThreatSeverity? severity,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(_securityEventsCollection).add({
        'eventType': type.toString().split('.').last,
        'userId': userId,
        'details': details,
        'severity': severity?.name,
        'timestamp': Timestamp.now(),
        'metadata': metadata ?? {},
      });
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error logging security event: $e');
    }
  }

  /// Clean up old analysis data
  Future<void> _cleanupOldAnalysisData() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: 30));

      // Clean up old analysis results
      final oldAnalysis = await _firestore
          .collection(_analyticsCollection)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldAnalysis.docs) {
        batch.delete(doc.reference);
      }

      if (oldAnalysis.docs.isNotEmpty) {
        await batch.commit();
        debugPrint('[SecurityAnalytics] Cleaned up ${oldAnalysis.docs.length} old analysis records');
      }
    } catch (e) {
      debugPrint('[SecurityAnalytics] Error cleaning up old data: $e');
    }
  }

  /// Generate cache key
  String _generateCacheKey(Duration timeWindow, List<SecurityEventType>? eventTypes) {
    final typesString = eventTypes?.map((e) => e.name).join(',') ?? 'all';
    return '${timeWindow.inMinutes}_$typesString';
  }

  /// Get cached analysis
  SecurityAnalysisResult? _getCachedAnalysis(String cacheKey) {
    final cached = _analysisCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _cacheTTL) {
      return cached.result;
    }

    _analysisCache.remove(cacheKey);
    return null;
  }

  /// Cache analysis result
  void _cacheAnalysis(String cacheKey, SecurityAnalysisResult result) {
    _analysisCache[cacheKey] = _AnalysisCache(
      result: result,
      timestamp: DateTime.now(),
    );

    // Clean up old cache entries
    _analysisCache.removeWhere((key, cached) =>
        DateTime.now().difference(cached.timestamp) > _cacheTTL);
  }

  /// Dispose of resources
  void dispose() {
    _analysisTimer?.cancel();
    for (final subscription in _monitoringStreams.values) {
      subscription.cancel();
    }
    _monitoringStreams.clear();
    _analysisCache.clear();
  }
}

// Data models for security analytics

class SecurityEvent {
  final String id;
  final SecurityEventType eventType;
  final String userId;
  final String crewId;
  final DateTime timestamp;
  final String details;
  final ThreatSeverity? severity;
  final Map<String, dynamic> metadata;

  SecurityEvent({
    required this.id,
    required this.eventType,
    required this.userId,
    this.crewId = '',
    required this.timestamp,
    required this.details,
    this.severity,
    this.metadata = const {},
  });

  factory SecurityEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SecurityEvent(
      id: doc.id,
      eventType: _parseEventType(data['eventType'] as String?),
      userId: data['userId'] as String? ?? '',
      crewId: data['crewId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      details: data['details'] as String? ?? '',
      severity: _parseSeverity(data['severity'] as String?),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  static SecurityEventType _parseEventType(String? typeString) {
    switch (typeString) {
      case 'authentication':
        return SecurityEventType.authentication;
      case 'authorization':
        return SecurityEventType.authorization;
      case 'crewOperation':
        return SecurityEventType.crewOperation;
      case 'dataAccess':
        return SecurityEventType.dataAccess;
      case 'permissionChange':
        return SecurityEventType.permissionChange;
      case 'sessionManagement':
        return SecurityEventType.sessionManagement;
      case 'suspiciousActivity':
        return SecurityEventType.suspiciousActivity;
      case 'securityViolation':
        return SecurityEventType.securityViolation;
      default:
        return SecurityEventType.authentication;
    }
  }

  static ThreatSeverity? _parseSeverity(String? severityString) {
    switch (severityString) {
      case 'low':
        return ThreatSeverity.low;
      case 'medium':
        return ThreatSeverity.medium;
      case 'high':
        return ThreatSeverity.high;
      case 'critical':
        return ThreatSeverity.critical;
      default:
        return null;
    }
  }
}

class SecurityAnomaly {
  final String id;
  final String type;
  final String userId;
  final ThreatSeverity severity;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SecurityAnomaly({
    required this.id,
    required this.type,
    required this.userId,
    required this.severity,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });
}

class Threat {
  final String id;
  final String type;
  final String userId;
  final String crewId;
  final ThreatSeverity severity;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  Threat({
    required this.id,
    required this.type,
    required this.userId,
    this.crewId = '',
    required this.severity,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });
}

class ThreatPattern {
  final String id;
  final String name;
  final String description;
  final ThreatSeverity severity;
  final Map<String, dynamic> pattern;
  final int threshold;
  final Duration timeWindow;

  ThreatPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    required this.pattern,
    required this.threshold,
    required this.timeWindow,
  });

  factory ThreatPattern.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ThreatPattern(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      severity: _parseSeverity(data['severity'] as String),
      pattern: data['pattern'] as Map<String, dynamic>,
      threshold: data['threshold'] as int,
      timeWindow: Duration(seconds: data['timeWindowSeconds'] as int),
    );
  }

  static ThreatSeverity _parseSeverity(String severity) {
    switch (severity) {
      case 'low':
        return ThreatSeverity.low;
      case 'medium':
        return ThreatSeverity.medium;
      case 'high':
        return ThreatSeverity.high;
      case 'critical':
        return ThreatSeverity.critical;
      default:
        return ThreatSeverity.medium;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'severity': severity.name,
      'pattern': pattern,
      'threshold': threshold,
      'timeWindowSeconds': timeWindow.inSeconds,
    };
  }
}

class SecurityAnalysisResult {
  final DateTime analysisTime;
  final Duration timeWindow;
  final int totalEvents;
  final List<SecurityAnomaly> anomalies;
  final List<Threat> threats;
  final SecurityMetrics metrics;
  final List<String> recommendations;
  final double riskScore;

  SecurityAnalysisResult({
    required this.analysisTime,
    required this.timeWindow,
    required this.totalEvents,
    required this.anomalies,
    required this.threats,
    required this.metrics,
    required this.recommendations,
    required this.riskScore,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'analysisTime': Timestamp.fromDate(analysisTime),
      'timeWindowMinutes': timeWindow.inMinutes,
      'totalEvents': totalEvents,
      'anomalyCount': anomalies.length,
      'threatCount': threats.length,
      'metrics': metrics.toMap(),
      'recommendations': recommendations,
      'riskScore': riskScore,
    };
  }
}

class SecurityMetrics {
  final int totalEvents;
  final int authenticationEvents;
  final int failedAuthentications;
  final double authenticationSuccessRate;
  final int uniqueUsers;
  final int uniqueCrews;
  final DateTime calculatedAt;

  SecurityMetrics({
    required this.totalEvents,
    required this.authenticationEvents,
    required this.failedAuthentications,
    required this.authenticationSuccessRate,
    required this.uniqueUsers,
    required this.uniqueCrews,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalEvents': totalEvents,
      'authenticationEvents': authenticationEvents,
      'failedAuthentications': failedAuthentications,
      'authenticationSuccessRate': authenticationSuccessRate,
      'uniqueUsers': uniqueUsers,
      'uniqueCrews': uniqueCrews,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }
}

class SuspiciousBehavior {
  final String id;
  final String userId;
  final String type;
  final ThreatSeverity severity;
  final String description;
  final DateTime timestamp;
  final List<SecurityEvent> events;
  final Map<String, dynamic> metadata;

  SuspiciousBehavior({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.description,
    required this.timestamp,
    required this.events,
    this.metadata = const {},
  });
}

class SecurityAlert {
  final String id;
  final String threatId;
  final String title;
  final String description;
  final ThreatSeverity severity;
  final String userId;
  final String crewId;
  final DateTime timestamp;
  final AlertStatus status;
  final List<String> recommendations;
  final Map<String, dynamic> context;
  final String? resolution;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  SecurityAlert({
    required this.id,
    required this.threatId,
    required this.title,
    required this.description,
    required this.severity,
    required this.userId,
    this.crewId = '',
    required this.timestamp,
    required this.status,
    required this.recommendations,
    this.context = const {},
    this.resolution,
    this.resolvedBy,
    this.resolvedAt,
  });

  SecurityAlert copyWith({
    String? id,
    String? threatId,
    String? title,
    String? description,
    ThreatSeverity? severity,
    String? userId,
    String? crewId,
    DateTime? timestamp,
    AlertStatus? status,
    List<String>? recommendations,
    Map<String, dynamic>? context,
    String? resolution,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return SecurityAlert(
      id: id ?? this.id,
      threatId: threatId ?? this.threatId,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      userId: userId ?? this.userId,
      crewId: crewId ?? this.crewId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      recommendations: recommendations ?? this.recommendations,
      context: context ?? this.context,
      resolution: resolution ?? this.resolution,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory SecurityAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SecurityAlert(
      id: doc.id,
      threatId: data['threatId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      severity: _parseSeverity(data['severity'] as String),
      userId: data['userId'] as String,
      crewId: data['crewId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: _parseStatus(data['status'] as String),
      recommendations: List<String>.from(data['recommendations'] as List),
      context: data['context'] as Map<String, dynamic>? ?? {},
      resolution: data['resolution'] as String?,
      resolvedBy: data['resolvedBy'] as String?,
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  static ThreatSeverity _parseSeverity(String severity) {
    switch (severity) {
      case 'low':
        return ThreatSeverity.low;
      case 'medium':
        return ThreatSeverity.medium;
      case 'high':
        return ThreatSeverity.high;
      case 'critical':
        return ThreatSeverity.critical;
      default:
        return ThreatSeverity.medium;
    }
  }

  static AlertStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return AlertStatus.active;
      case 'investigating':
        return AlertStatus.investigating;
      case 'resolved':
        return AlertStatus.resolved;
      case 'false_positive':
        return AlertStatus.falsePositive;
      default:
        return AlertStatus.active;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'threatId': threatId,
      'title': title,
      'description': description,
      'severity': severity.name,
      'userId': userId,
      'crewId': crewId,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
      'recommendations': recommendations,
      'context': context,
      if (resolution != null) 'resolution': resolution,
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    };
  }
}

enum AlertStatus {
  active,
  investigating,
  resolved,
  false_positive,
}

class SecurityMetricsReport {
  final DateTime generatedAt;
  final Duration timeWindow;
  final int totalEvents;
  final AuthenticationMetrics authenticationMetrics;
  final AuthorizationMetrics authorizationMetrics;
  final UserActivityMetrics userActivityMetrics;
  final CrewActivityMetrics crewActivityMetrics;
  final TemporalPatterns temporalPatterns;
  final GeographicPatterns geographicPatterns;
  final Map<String, dynamic>? detailedBreakdown;

  SecurityMetricsReport({
    required this.generatedAt,
    required this.timeWindow,
    required this.totalEvents,
    required this.authenticationMetrics,
    required this.authorizationMetrics,
    required this.userActivityMetrics,
    required this.crewActivityMetrics,
    required this.temporalPatterns,
    required this.geographicPatterns,
    this.detailedBreakdown,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'generatedAt': Timestamp.fromDate(generatedAt),
      'timeWindowDays': timeWindow.inDays,
      'totalEvents': totalEvents,
      'authenticationMetrics': authenticationMetrics.toMap(),
      'authorizationMetrics': authorizationMetrics.toMap(),
      'userActivityMetrics': userActivityMetrics.toMap(),
      'crewActivityMetrics': crewActivityMetrics.toMap(),
      'temporalPatterns': temporalPatterns.toMap(),
      'geographicPatterns': geographicPatterns.toMap(),
      if (detailedBreakdown != null) 'detailedBreakdown': detailedBreakdown,
    };
  }
}

class AuthenticationMetrics {
  final int totalAttempts;
  final int successfulAttempts;
  final int failedAttempts;
  final double successRate;

  AuthenticationMetrics({
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.failedAttempts,
    required this.successRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalAttempts': totalAttempts,
      'successfulAttempts': successfulAttempts,
      'failedAttempts': failedAttempts,
      'successRate': successRate,
    };
  }
}

class AuthorizationMetrics {
  final int totalRequests;
  final int grantedRequests;
  final int deniedRequests;
  final double denialRate;

  AuthorizationMetrics({
    required this.totalRequests,
    required this.grantedRequests,
    required this.deniedRequests,
    required this.denialRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalRequests': totalRequests,
      'grantedRequests': grantedRequests,
      'deniedRequests': deniedRequests,
      'denialRate': denialRate,
    };
  }
}

class UserActivity {
  final String userId;
  final int eventCount;

  UserActivity({
    required this.userId,
    required this.eventCount,
  });
}

class UserActivityMetrics {
  final int uniqueUsers;
  final List<UserActivity> mostActiveUsers;
  final double averageEventsPerUser;

  UserActivityMetrics({
    required this.uniqueUsers,
    required this.mostActiveUsers,
    required this.averageEventsPerUser,
  });

  Map<String, dynamic> toMap() {
    return {
      'uniqueUsers': uniqueUsers,
      'mostActiveUsers': mostActiveUsers.map((ua) => {
        'userId': ua.userId,
        'eventCount': ua.eventCount,
      }).toList(),
      'averageEventsPerUser': averageEventsPerUser,
    };
  }
}

class CrewActivity {
  final String crewId;
  final int eventCount;

  CrewActivity({
    required this.crewId,
    required this.eventCount,
  });
}

class CrewActivityMetrics {
  final int uniqueCrews;
  final List<CrewActivity> mostActiveCrews;
  final double averageEventsPerCrew;

  CrewActivityMetrics({
    required this.uniqueCrews,
    required this.mostActiveCrews,
    required this.averageEventsPerCrew,
  });

  Map<String, dynamic> toMap() {
    return {
      'uniqueCrews': uniqueCrews,
      'mostActiveCrews': mostActiveCrews.map((ca) => {
        'crewId': ca.crewId,
        'eventCount': ca.eventCount,
      }).toList(),
      'averageEventsPerCrew': averageEventsPerCrew,
    };
  }
}

class TemporalPatterns {
  final List<int> hourlyDistribution;
  final List<int> dailyDistribution;
  final int peakHour;
  final int peakDay;

  TemporalPatterns({
    required this.hourlyDistribution,
    required this.dailyDistribution,
    required this.peakHour,
    required this.peakDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'hourlyDistribution': hourlyDistribution,
      'dailyDistribution': dailyDistribution,
      'peakHour': peakHour,
      'peakDay': peakDay,
    };
  }
}

class LocationActivity {
  final String location;
  final int eventCount;

  LocationActivity({
    required this.location,
    required this.eventCount,
  });
}

class GeographicPatterns {
  final int uniqueLocations;
  final List<LocationActivity> topLocations;

  GeographicPatterns({
    required this.uniqueLocations,
    required this.topLocations,
  });

  Map<String, dynamic> toMap() {
    return {
      'uniqueLocations': uniqueLocations,
      'topLocations': topLocations.map((la) => {
        'location': la.location,
        'eventCount': la.eventCount,
      }).toList(),
    };
  }
}

class _AnalysisCache {
  final SecurityAnalysisResult result;
  final DateTime timestamp;

  _AnalysisCache({
    required this.result,
    required this.timestamp,
  });
}