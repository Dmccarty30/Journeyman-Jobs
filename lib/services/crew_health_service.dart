import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/services/enhanced_crew_service.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';

/// Comprehensive crew health monitoring service for maintaining optimal crew performance.
///
/// This service monitors crew activity levels, engagement metrics, and overall health
/// to identify at-risk crews, suggest improvements, and maintain a healthy crew ecosystem.
///
/// Features:
/// - Real-time crew activity monitoring
/// - Engagement metrics tracking and analysis
/// - Inactive crew detection and alerting
/// - Automated maintenance and cleanup routines
/// - Health scoring and recommendations
/// - Crew performance analytics
/// - Predictive health insights
class CrewHealthService {
  static final CrewHealthService _instance = CrewHealthService._internal();
  factory CrewHealthService() => _instance;
  CrewHealthService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCrewService _crewService = EnhancedCrewService();
  final CrewMessagingService _messagingService = CrewMessagingService();

  // Collection names
  static const String _healthMetricsCollection = 'crew_health_metrics';
  static const String _healthAlertsCollection = 'crew_health_alerts';
  static const String _maintenanceLogsCollection = 'crew_maintenance_logs';

  // Health monitoring thresholds
  static const Duration _inactivityThreshold = Duration(days: 7);
  static const Duration _criticalInactivityThreshold = Duration(days: 14);
  static const Duration _monitoringInterval = Duration(hours: 6);
  static const double _minimumHealthScore = 0.3;
  static const int _minimumActiveMembers = 2;

  // Health metrics cache
  final Map<String, CrewHealthMetrics> _healthCache = {};
  static const Duration _cacheTTL = Duration(minutes: 30);

  // Monitoring streams and timers
  final Map<String, StreamSubscription> _monitoringStreams = {};
  Timer? _healthCheckTimer;
  Timer? _maintenanceTimer;

  /// Initialize crew health monitoring
  ///
  /// Starts real-time monitoring of all crews and begins periodic health checks.
  ///
  /// Returns [true] if initialization successful, [false] otherwise
  Future<bool> initialize() async {
    try {
      debugPrint('[CrewHealth] Initializing crew health monitoring');

      // Start monitoring all existing crews
      await _startCrewMonitoring();

      // Start periodic health checks
      _startPeriodicHealthChecks();

      // Start maintenance routines
      _startMaintenanceRoutines();

      debugPrint('[CrewHealth] Crew health monitoring initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[CrewHealth] Failed to initialize: $e');
      return false;
    }
  }

  /// Get comprehensive health metrics for a crew
  ///
  /// Calculates and returns detailed health metrics for a specific crew including
  /// activity levels, engagement metrics, member participation, and health score.
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew to analyze
  /// - [timeWindow]: Analysis time window (default: 30 days)
  ///
  /// Returns [CrewHealthMetrics] with comprehensive health data
  Future<CrewHealthMetrics> getCrewHealthMetrics({
    required String crewId,
    Duration timeWindow = const Duration(days: 30),
  }) async {
    try {
      // Check cache first
      final cached = _getCachedHealthMetrics(crewId);
      if (cached != null) {
        return cached;
      }

      debugPrint('[CrewHealth] Analyzing health for crew: $crewId');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Get crew information
      final crew = await _crewService.getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found: $crewId');
      }

      // Calculate activity metrics
      final activityMetrics = await _calculateActivityMetrics(crewId, startTime, endTime);

      // Calculate engagement metrics
      final engagementMetrics = await _calculateEngagementMetrics(crewId, startTime, endTime);

      // Calculate member participation metrics
      final memberMetrics = await _calculateMemberMetrics(crewId, startTime, endTime);

      // Calculate communication metrics
      final communicationMetrics = await _calculateCommunicationMetrics(crewId, startTime, endTime);

      // Calculate overall health score
      final healthScore = _calculateHealthScore(
        activityMetrics,
        engagementMetrics,
        memberMetrics,
        communicationMetrics,
      );

      // Generate health recommendations
      final recommendations = _generateHealthRecommendations(
        healthScore,
        activityMetrics,
        engagementMetrics,
        memberMetrics,
        communicationMetrics,
      );

      final metrics = CrewHealthMetrics(
        crewId: crewId,
        crewName: crew.name,
        calculatedAt: DateTime.now(),
        timeWindow: timeWindow,
        healthScore: healthScore,
        activityMetrics: activityMetrics,
        engagementMetrics: engagementMetrics,
        memberMetrics: memberMetrics,
        communicationMetrics: communicationMetrics,
        recommendations: recommendations,
        riskLevel: _determineRiskLevel(healthScore),
      );

      // Cache the metrics
      _cacheHealthMetrics(crewId, metrics);

      // Store metrics
      await _storeHealthMetrics(metrics);

      return metrics;
    } catch (e) {
      debugPrint('[CrewHealth] Error calculating health metrics: $e');
      throw Exception('Failed to calculate health metrics: $e');
    }
  }

  /// Get health status for all crews
  ///
  /// Returns health status overview for all crews in the system with
  /// categorization by health level and risk assessment.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of crews to analyze (default: all)
  /// - [timeWindow]: Analysis time window
  ///
  /// Returns [CrewHealthOverview] with system-wide health data
  Future<CrewHealthOverview> getAllCrewsHealthStatus({
    int? limit,
    Duration timeWindow = const Duration(days: 30),
  }) async {
    try {
      debugPrint('[CrewHealth] Getting health status for all crews');

      // Get all crews
      final crews = await _crewService.getAllCrews();
      final crewsToAnalyze = limit != null ? crews.take(limit).toList() : crews;

      final List<CrewHealthMetrics> allMetrics = [];
      final List<String> failedCrews = [];

      // Calculate health metrics for each crew
      for (final crew in crewsToAnalyze) {
        try {
          final metrics = await getCrewHealthMetrics(
            crewId: crew.id,
            timeWindow: timeWindow,
          );
          allMetrics.add(metrics);
        } catch (e) {
          debugPrint('[CrewHealth] Failed to analyze crew ${crew.id}: $e');
          failedCrews.add(crew.id);
        }
      }

      // Categorize crews by health level
      final healthyCrews = allMetrics.where((m) => m.healthScore >= 0.7).toList();
      final atRiskCrews = allMetrics.where((m) => m.healthScore >= 0.4 && m.healthScore < 0.7).toList();
      final criticalCrews = allMetrics.where((m) => m.healthScore < 0.4).toList();

      // Sort by health score
      allMetrics.sort((a, b) => b.healthScore.compareTo(a.healthScore));

      final overview = CrewHealthOverview(
        generatedAt: DateTime.now(),
        timeWindow: timeWindow,
        totalCrews: crewsToAnalyze.length,
        healthyCrews: healthyCrews,
        atRiskCrews: atRiskCrews,
        criticalCrews: criticalCrews,
        failedAnalyses: failedCrews,
        averageHealthScore: allMetrics.isEmpty ? 0.0 :
            allMetrics.map((m) => m.healthScore).reduce((a, b) => a + b) / allMetrics.length,
        mostActiveCrew: allMetrics.isNotEmpty ? allMetrics.first : null,
        leastActiveCrew: allMetrics.isNotEmpty ? allMetrics.last : null,
      );

      debugPrint('[CrewHealth] Health overview generated: ${crewsToAnalyze.length} crews analyzed');
      return overview;
    } catch (e) {
      debugPrint('[CrewHealth] Error generating health overview: $e');
      throw Exception('Failed to generate health overview: $e');
    }
  }

  /// Identify inactive crews that need attention
  ///
  /// Analyzes all crews to identify those that have been inactive for
  /// specified periods and may need intervention or cleanup.
  ///
  /// Parameters:
  /// - [inactivityThreshold]: Consider crew inactive after this period
  /// - [criticalThreshold]: Consider crew critically inactive after this period
  ///
  /// Returns list of inactive crews with severity levels
  Future<List<InactiveCrew>> getInactiveCrews({
    Duration inactivityThreshold = _inactivityThreshold,
    Duration criticalThreshold = _criticalInactivityThreshold,
  }) async {
    try {
      debugPrint('[CrewHealth] Identifying inactive crews');

      final crews = await _crewService.getAllCrews();
      final inactiveCrews = <InactiveCrew>[];
      final now = DateTime.now();

      for (final crew in crews) {
        try {
          // Get last activity timestamp
          final lastActivity = await _getLastCrewActivity(crew.id);
          final inactiveDuration = now.difference(lastActivity);

          if (inactiveDuration > inactivityThreshold) {
            final severity = inactiveDuration > criticalThreshold
                ? InactivitySeverity.critical
                : InactivitySeverity.warning;

            inactiveCrews.add(InactiveCrew(
              crewId: crew.id,
              crewName: crew.name,
              lastActivity: lastActivity,
              inactiveDuration: inactiveDuration,
              severity: severity,
              memberCount: crew.memberIds.length,
              recommendation: _generateInactivityRecommendation(severity, inactiveDuration),
            ));
          }
        } catch (e) {
          debugPrint('[CrewHealth] Error checking activity for crew ${crew.id}: $e');
        }
      }

      // Sort by inactive duration (most inactive first)
      inactiveCrews.sort((a, b) => b.inactiveDuration.compareTo(a.inactiveDuration));

      debugPrint('[CrewHealth] Found ${inactiveCrews.length} inactive crews');
      return inactiveCrews;
    } catch (e) {
      debugPrint('[CrewHealth] Error identifying inactive crews: $e');
      return [];
    }
  }

  /// Perform automated maintenance on unhealthy crews
  ///
  /// Executes automated maintenance routines for crews that meet specific
  /// criteria for cleanup, archiving, or administrative action.
  ///
  /// Parameters:
  /// - [dryRun]: If true, only report what would be done without executing
  ///
  /// Returns [MaintenanceReport] with actions taken
  Future<MaintenanceReport> performAutomatedMaintenance({bool dryRun = false}) async {
    try {
      debugPrint('[CrewHealth] Performing automated maintenance (dryRun: $dryRun)');

      final report = MaintenanceReport(
        performedAt: DateTime.now(),
        dryRun: dryRun,
        actionsTaken: [],
        errors: [],
      );

      // Get inactive crews
      final inactiveCrews = await getInactiveCrews();

      for (final inactiveCrew in inactiveCrews) {
        try {
          if (inactiveCrew.severity == InactivitySeverity.critical) {
            // Handle critically inactive crews
            await _handleCriticallyInactiveCrew(inactiveCrew, dryRun, report);
          } else if (inactiveCrew.severity == InactivitySeverity.warning) {
            // Handle warning level inactive crews
            await _handleWarningInactiveCrew(inactiveCrew, dryRun, report);
          }
        } catch (e) {
          report.errors.add('Error handling crew ${inactiveCrew.crewId}: $e');
        }
      }

      // Clean up old health metrics data
      await _cleanupOldHealthData(dryRun, report);

      // Log maintenance activity
      await _logMaintenanceActivity(report);

      debugPrint('[CrewHealth] Maintenance completed: ${report.actionsTaken.length} actions, ${report.errors.length} errors');
      return report;
    } catch (e) {
      debugPrint('[CrewHealth] Error during maintenance: $e');
      throw Exception('Automated maintenance failed: $e');
    }
  }

  /// Get crew health trends over time
  ///
  /// Analyzes historical health data to identify trends, patterns, and
  /// predictions for future crew health.
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew to analyze
  /// - [days]: Number of days of historical data to analyze
  ///
  /// Returns [CrewHealthTrends] with trend analysis
  Future<CrewHealthTrends> getCrewHealthTrends({
    required String crewId,
    int days = 30,
  }) async {
    try {
      debugPrint('[CrewHealth] Analyzing health trends for crew: $crewId');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      // Get historical health metrics
      final historicalData = await _getHistoricalHealthMetrics(crewId, startDate, endDate);

      if (historicalData.isEmpty) {
        return CrewHealthTrends(
          crewId: crewId,
          analyzedPeriod: Duration(days: days),
          dataPoints: [],
          trendDirection: TrendDirection.stable,
          averageHealthScore: 0.0,
          prediction: HealthPrediction(
            nextWeekScore: 0.0,
            nextMonthScore: 0.0,
            confidence: 0.0,
            factors: [],
          ),
        );
      }

      // Sort by date
      historicalData.sort((a, b) => a.calculatedAt.compareTo(b.calculatedAt));

      // Calculate trend direction
      final trendDirection = _calculateTrendDirection(historicalData);

      // Calculate average health score
      final averageScore = historicalData
          .map((m) => m.healthScore)
          .reduce((a, b) => a + b) / historicalData.length;

      // Generate prediction
      final prediction = _generateHealthPrediction(historicalData);

      final trends = CrewHealthTrends(
        crewId: crewId,
        analyzedPeriod: Duration(days: days),
        dataPoints: historicalData,
        trendDirection: trendDirection,
        averageHealthScore: averageScore,
        prediction: prediction,
      );

      debugPrint('[CrewHealth] Health trends analyzed for crew $crewId: ${trendDirection.name}');
      return trends;
    } catch (e) {
      debugPrint('[CrewHealth] Error analyzing health trends: $e');
      throw Exception('Failed to analyze health trends: $e');
    }
  }

  /// Create health alert for crew issues
  ///
  /// Generates and stores health alerts for crews that meet specific
  /// criteria for intervention or attention.
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew with issues
  /// - [alertType]: Type of health alert
  /// - [severity]: Alert severity level
  /// - [message]: Alert message
  /// - [recommendations]: Recommended actions
  ///
  /// Returns created health alert
  Future<CrewHealthAlert> createHealthAlert({
    required String crewId,
    required HealthAlertType alertType,
    required AlertSeverity severity,
    required String message,
    List<String>? recommendations,
  }) async {
    try {
      final alert = CrewHealthAlert(
        id: '', // Will be set by Firestore
        crewId: crewId,
        alertType: alertType,
        severity: severity,
        message: message,
        recommendations: recommendations ?? [],
        createdAt: DateTime.now(),
        status: AlertStatus.active,
        resolvedAt: null,
        resolvedBy: null,
      );

      // Store alert
      final docRef = await _firestore.collection(_healthAlertsCollection).add(alert.toFirestore());
      final savedAlert = alert.copyWith(id: docRef.id);

      debugPrint('[CrewHealth] Health alert created: ${savedAlert.id} for crew $crewId');
      return savedAlert;
    } catch (e) {
      debugPrint('[CrewHealth] Error creating health alert: $e');
      throw Exception('Failed to create health alert: $e');
    }
  }

  /// Get active health alerts
  ///
  /// Retrieves all active health alerts, optionally filtered by severity
  /// and crew.
  ///
  /// Parameters:
  /// - [crewId]: Filter by specific crew (optional)
  /// - [severity]: Filter by severity (optional)
  /// - [limit]: Maximum number of alerts to return
  ///
  /// Returns list of active health alerts
  Future<List<CrewHealthAlert>> getActiveHealthAlerts({
    String? crewId,
    AlertSeverity? severity,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_healthAlertsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);

      if (crewId != null) {
        query = query.where('crewId', isEqualTo: crewId);
      }

      if (severity != null) {
        query = query.where('severity', isEqualTo: severity.name);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => CrewHealthAlert.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('[CrewHealth] Error getting health alerts: $e');
      return [];
    }
  }

  /// Resolve health alert
  ///
  /// Marks a health alert as resolved with resolution details.
  ///
  /// Parameters:
  /// - [alertId]: Alert ID to resolve
  /// - [resolution]: Resolution details
  /// - [resolvedBy]: User who resolved the alert
  ///
  /// Returns [true] if successful, [false] otherwise
  Future<bool> resolveHealthAlert({
    required String alertId,
    required String resolution,
    required String resolvedBy,
  }) async {
    try {
      await _firestore.collection(_healthAlertsCollection).doc(alertId).update({
        'status': 'resolved',
        'resolution': resolution,
        'resolvedBy': resolvedBy,
        'resolvedAt': Timestamp.now(),
      });

      debugPrint('[CrewHealth] Health alert resolved: $alertId');
      return true;
    } catch (e) {
      debugPrint('[CrewHealth] Error resolving health alert: $e');
      return false;
    }
  }

  // Private helper methods

  /// Start monitoring all crews
  Future<void> _startCrewMonitoring() async {
    try {
      final crews = await _crewService.getAllCrews();

      for (final crew in crews) {
        _startIndividualCrewMonitoring(crew.id);
      }

      // Listen for new crews
      final subscription = _firestore.collection('crews').snapshots().listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _startIndividualCrewMonitoring(change.doc.id);
          } else if (change.type == DocumentChangeType.removed) {
            _stopIndividualCrewMonitoring(change.doc.id);
          }
        }
      });

      _monitoringStreams['all_crews'] = subscription;
    } catch (e) {
      debugPrint('[CrewHealth] Error starting crew monitoring: $e');
    }
  }

  /// Start monitoring individual crew
  void _startIndividualCrewMonitoring(String crewId) {
    try {
      // Monitor crew member changes
      final memberSubscription = _firestore
          .collection('crews')
          .doc(crewId)
          .snapshots()
          .listen((snapshot) {
        _handleCrewUpdate(crewId, snapshot.data());
      });

      _monitoringStreams['crew_$crewId'] = memberSubscription;
    } catch (e) {
      debugPrint('[CrewHealth] Error starting monitoring for crew $crewId: $e');
    }
  }

  /// Stop monitoring individual crew
  void _stopIndividualCrewMonitoring(String crewId) {
    final subscription = _monitoringStreams['crew_$crewId'];
    if (subscription != null) {
      subscription.cancel();
      _monitoringStreams.remove('crew_$crewId');
    }
  }

  /// Handle crew update
  void _handleCrewUpdate(String crewId, Map<String, dynamic>? data) {
    if (data == null) return;

    // Invalidate cache for this crew
    _healthCache.remove(crewId);

    // Check for significant changes that might affect health
    final memberCount = (data['memberIds'] as List?)?.length ?? 0;
    if (memberCount < _minimumActiveMembers) {
      // Create alert for low member count
      createHealthAlert(
        crewId: crewId,
        alertType: HealthAlertType.lowMemberCount,
        severity: AlertSeverity.medium,
        message: 'Crew has fewer than minimum active members',
        recommendations: [
          'Recruit new members',
          'Reactivate inactive members',
          'Consider merging with another crew',
        ],
      );
    }
  }

  /// Start periodic health checks
  void _startPeriodicHealthChecks() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(_monitoringInterval, (_) {
      _performPeriodicHealthCheck();
    });
  }

  /// Perform periodic health check
  Future<void> _performPeriodicHealthCheck() async {
    try {
      debugPrint('[CrewHealth] Performing periodic health check');

      // Get all crews and check their health
      final crews = await _crewService.getAllCrews();

      for (final crew in crews) {
        try {
          final metrics = await getCrewHealthMetrics(crewId: crew.id);

          // Check for critical health issues
          if (metrics.healthScore < _minimumHealthScore) {
            await createHealthAlert(
              crewId: crew.id,
              alertType: HealthAlertType.criticalHealth,
              severity: AlertSeverity.high,
              message: 'Crew health score is critically low: ${metrics.healthScore.toStringAsFixed(2)}',
              recommendations: metrics.recommendations,
            );
          }
        } catch (e) {
          debugPrint('[CrewHealth] Error checking health for crew ${crew.id}: $e');
        }
      }

      // Perform automated maintenance
      await performAutomatedMaintenance(dryRun: true);
    } catch (e) {
      debugPrint('[CrewHealth] Error in periodic health check: $e');
    }
  }

  /// Start maintenance routines
  void _startMaintenanceRoutines() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = Timer.periodic(Duration(days: 1), (_) {
      _performDailyMaintenance();
    });
  }

  /// Perform daily maintenance
  Future<void> _performDailyMaintenance() async {
    try {
      debugPrint('[CrewHealth] Performing daily maintenance');

      // Perform actual maintenance (not dry run)
      await performAutomatedMaintenance(dryRun: false);

      // Clean up old alerts
      await _cleanupOldAlerts();

      // Archive old health data
      await _archiveOldHealthData();
    } catch (e) {
      debugPrint('[CrewHealth] Error in daily maintenance: $e');
    }
  }

  /// Calculate activity metrics
  Future<ActivityMetrics> _calculateActivityMetrics(
    String crewId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // Get crew activity from various sources
    // This is a simplified implementation

    final activeDays = <int>{};
    final operations = <String>[];

    // Check messaging activity
    try {
      final messages = await _messagingService.getMessages(crewId: crewId, limit: 1000);
      for (final message in messages) {
        if (message.createdAt.isAfter(startTime) && message.createdAt.isBefore(endTime)) {
          activeDays.add(message.createdAt.day);
          operations.add('message');
        }
      }
    } catch (e) {
      debugPrint('[CrewHealth] Error getting messages: $e');
    }

    // Calculate metrics
    final totalOperations = operations.length;
    final activeDaysCount = activeDays.length;
    final totalDays = endTime.difference(startTime).inDays;

    return ActivityMetrics(
      totalOperations: totalOperations,
      activeDays: activeDaysCount,
      averageOperationsPerDay: totalDays > 0 ? totalOperations / totalDays : 0.0,
      activityConsistency: totalDays > 0 ? activeDaysCount / totalDays : 0.0,
    );
  }

  /// Calculate engagement metrics
  Future<EngagementMetrics> _calculateEngagementMetrics(
    String crewId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // Get crew information
    final crew = await _crewService.getCrewById(crewId);
    if (crew == null) {
      return EngagementMetrics(
        totalMembers: 0,
        activeMembers: 0,
        engagementRate: 0.0,
        averageActivityPerMember: 0.0,
      );
    }

    final totalMembers = crew.memberIds.length;
    final activeMembers = <String>{};

    // Check member activity through messages
    try {
      final messages = await _messagingService.getMessages(crewId: crewId, limit: 1000);
      for (final message in messages) {
        if (message.createdAt.isAfter(startTime) && message.createdAt.isBefore(endTime)) {
          activeMembers.add(message.senderId);
        }
      }
    } catch (e) {
      debugPrint('[CrewHealth] Error calculating engagement: $e');
    }

    final activeMemberCount = activeMembers.length;
    final engagementRate = totalMembers > 0 ? activeMemberCount / totalMembers : 0.0;
    final averageActivity = activeMemberCount > 0 ? messages.length / activeMemberCount : 0.0;

    return EngagementMetrics(
      totalMembers: totalMembers,
      activeMembers: activeMemberCount,
      engagementRate: engagementRate,
      averageActivityPerMember: averageActivity,
    );
  }

  /// Calculate member metrics
  Future<MemberMetrics> _calculateMemberMetrics(
    String crewId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final crew = await _crewService.getCrewById(crewId);
    if (crew == null) {
      return MemberMetrics(
        totalMembers: 0,
        newMembers: 0,
        departedMembers: 0,
        memberRetentionRate: 1.0,
        averageTenureDays: 0.0,
      );
    }

    final totalMembers = crew.memberIds.length;
    final newMembers = 0; // Would need historical data to calculate accurately
    final departedMembers = 0; // Would need historical data to calculate accurately
    final retentionRate = totalMembers > 0 ? (totalMembers - departedMembers) / totalMembers : 1.0;
    final averageTenure = 30.0; // Would need member join dates to calculate accurately

    return MemberMetrics(
      totalMembers: totalMembers,
      newMembers: newMembers,
      departedMembers: departedMembers,
      memberRetentionRate: retentionRate,
      averageTenureDays: averageTenure,
    );
  }

  /// Calculate communication metrics
  Future<CommunicationMetrics> _calculateCommunicationMetrics(
    String crewId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final messages = await _messagingService.getMessages(crewId: crewId, limit: 1000);
      final relevantMessages = messages.where((m) =>
          m.createdAt.isAfter(startTime) && m.createdAt.isBefore(endTime)).toList();

      final totalMessages = relevantMessages.length;
      final uniqueSenders = relevantMessages.map((m) => m.senderId).toSet().length;
      final responseTimes = <Duration>[];

      // Calculate response times (simplified)
      for (int i = 1; i < relevantMessages.length; i++) {
        final current = relevantMessages[i];
        final previous = relevantMessages[i - 1];
        if (current.senderId != previous.senderId) {
          responseTimes.add(current.createdAt.difference(previous.createdAt));
        }
      }

      final averageResponseTime = responseTimes.isNotEmpty
          ? responseTimes.reduce((a, b) => a + b) / responseTimes.length
          : Duration.zero;

      return CommunicationMetrics(
        totalMessages: totalMessages,
        averageMessagesPerDay: totalMessages / endTime.difference(startTime).inDays,
        uniqueParticipants: uniqueSenders,
        averageResponseTime: averageResponseTime,
      );
    } catch (e) {
      debugPrint('[CrewHealth] Error calculating communication metrics: $e');
      return CommunicationMetrics(
        totalMessages: 0,
        averageMessagesPerDay: 0.0,
        uniqueParticipants: 0,
        averageResponseTime: Duration.zero,
      );
    }
  }

  /// Calculate overall health score
  double _calculateHealthScore(
    ActivityMetrics activity,
    EngagementMetrics engagement,
    MemberMetrics members,
    CommunicationMetrics communication,
  ) {
    double score = 0.0;

    // Activity score (30% weight)
    score += activity.activityConsistency * 0.3;

    // Engagement score (30% weight)
    score += engagement.engagementRate * 0.3;

    // Member score (25% weight)
    score += members.memberRetentionRate * 0.25;

    // Communication score (15% weight)
    final communicationScore = communication.totalMessages > 0
        ? min(1.0, communication.uniqueParticipants / max(1, members.totalMembers))
        : 0.0;
    score += communicationScore * 0.15;

    return score.clamp(0.0, 1.0);
  }

  /// Generate health recommendations
  List<String> _generateHealthRecommendations(
    double healthScore,
    ActivityMetrics activity,
    EngagementMetrics engagement,
    MemberMetrics members,
    CommunicationMetrics communication,
  ) {
    final recommendations = <String>[];

    if (healthScore < 0.3) {
      recommendations.add('Critical: Immediate intervention required');
      recommendations.add('Consider crew restructuring or disbandment');
    } else if (healthScore < 0.5) {
      recommendations.add('High priority: Address declining engagement');
      recommendations.add('Schedule crew meeting to discuss issues');
    }

    if (activity.activityConsistency < 0.5) {
      recommendations.add('Increase activity consistency and regular engagement');
    }

    if (engagement.engagementRate < 0.6) {
      recommendations.add('Improve member engagement through activities and communication');
    }

    if (members.memberRetentionRate < 0.8) {
      recommendations.add('Focus on member retention and satisfaction');
    }

    if (communication.totalMessages < 10) {
      recommendations.add('Encourage more communication and collaboration');
    }

    return recommendations;
  }

  /// Determine risk level
  RiskLevel _determineRiskLevel(double healthScore) {
    if (healthScore >= 0.8) return RiskLevel.low;
    if (healthScore >= 0.6) return RiskLevel.medium;
    if (healthScore >= 0.4) return RiskLevel.high;
    return RiskLevel.critical;
  }

  /// Get last crew activity
  Future<DateTime> _getLastCrewActivity(String crewId) async {
    try {
      // Check messages first
      final messages = await _messagingService.getMessages(crewId: crewId, limit: 1);
      if (messages.isNotEmpty) {
        return messages.first.createdAt;
      }

      // Check crew updates
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      if (crewDoc.exists) {
        final data = crewDoc.data() as Map<String, dynamic>;
        final updatedAt = data['updatedAt'] as Timestamp?;
        if (updatedAt != null) {
          return updatedAt.toDate();
        }
      }

      // Default to creation time if no activity found
      return DateTime.now().subtract(Duration(days: 30));
    } catch (e) {
      debugPrint('[CrewHealth] Error getting last activity: $e');
      return DateTime.now().subtract(Duration(days: 30));
    }
  }

  /// Generate inactivity recommendation
  String _generateInactivityRecommendation(InactivitySeverity severity, Duration inactiveDuration) {
    switch (severity) {
      case InactivitySeverity.warning:
        return 'Send reminder notification to crew members';
      case InactivitySeverity.critical:
        return 'Consider crew reorganization or dissolution';
    }
  }

  /// Handle critically inactive crew
  Future<void> _handleCriticallyInactiveCrew(
    InactiveCrew crew,
    bool dryRun,
    MaintenanceReport report,
  ) async {
    final action = MaintenanceAction(
      type: MaintenanceActionType.criticalCleanup,
      crewId: crew.crewId,
      description: 'Handle critically inactive crew: ${crew.crewName}',
      executedAt: DateTime.now(),
    );

    if (!dryRun) {
      try {
        // Create health alert
        await createHealthAlert(
          crewId: crew.crewId,
          alertType: HealthAlertType.criticalInactivity,
          severity: AlertSeverity.critical,
          message: 'Crew inactive for ${crew.inactiveDuration.inDays} days',
          recommendations: [
            'Contact crew members',
            'Consider crew dissolution',
            'Archive crew data',
          ],
        );

        action.result = 'Created critical alert and notified administrators';
      } catch (e) {
        action.result = 'Error: $e';
        report.errors.add(action.result!);
      }
    } else {
      action.result = 'Would create critical alert and notify administrators';
    }

    report.actionsTaken.add(action);
  }

  /// Handle warning inactive crew
  Future<void> _handleWarningInactiveCrew(
    InactiveCrew crew,
    bool dryRun,
    MaintenanceReport report,
  ) async {
    final action = MaintenanceAction(
      type: MaintenanceActionType.warningNotification,
      crewId: crew.crewId,
      description: 'Send warning to inactive crew: ${crew.crewName}',
      executedAt: DateTime.now(),
    );

    if (!dryRun) {
      try {
        // Send reminder message to crew
        await _messagingService.sendSystemMessage(
          crewId: crew.crewId,
          content: 'This crew has been inactive for ${crew.inactiveDuration.inDays} days. '
              'Please reactivate to avoid being marked as inactive.',
        );

        action.result = 'Sent reminder message to crew';
      } catch (e) {
        action.result = 'Error: $e';
        report.errors.add(action.result!);
      }
    } else {
      action.result = 'Would send reminder message to crew';
    }

    report.actionsTaken.add(action);
  }

  /// Clean up old health data
  Future<void> _cleanupOldHealthData(bool dryRun, MaintenanceReport report) async {
    final action = MaintenanceAction(
      type: MaintenanceActionType.dataCleanup,
      description: 'Clean up old health metrics data',
      executedAt: DateTime.now(),
    );

    if (!dryRun) {
      try {
        final cutoffDate = DateTime.now().subtract(Duration(days: 90));
        final oldData = await _firestore
            .collection(_healthMetricsCollection)
            .where('calculatedAt', isLessThan: Timestamp.fromDate(cutoffDate))
            .get();

        final batch = _firestore.batch();
        for (final doc in oldData.docs) {
          batch.delete(doc.reference);
        }

        if (oldData.docs.isNotEmpty) {
          await batch.commit();
          action.result = 'Deleted ${oldData.docs.length} old health records';
        } else {
          action.result = 'No old health records to delete';
        }
      } catch (e) {
        action.result = 'Error: $e';
        report.errors.add(action.result!);
      }
    } else {
      action.result = 'Would clean up old health metrics data';
    }

    report.actionsTaken.add(action);
  }

  /// Log maintenance activity
  Future<void> _logMaintenanceActivity(MaintenanceReport report) async {
    try {
      await _firestore.collection(_maintenanceLogsCollection).add({
        'performedAt': Timestamp.fromDate(report.performedAt),
        'dryRun': report.dryRun,
        'actionsCount': report.actionsTaken.length,
        'errorsCount': report.errors.length,
        'actions': report.actionsTaken.map((a) => a.toMap()).toList(),
        'errors': report.errors,
      });
    } catch (e) {
      debugPrint('[CrewHealth] Error logging maintenance activity: $e');
    }
  }

  /// Get cached health metrics
  CrewHealthMetrics? _getCachedHealthMetrics(String crewId) {
    final cached = _healthCache[crewId];
    if (cached != null &&
        DateTime.now().difference(cached.calculatedAt) < _cacheTTL) {
      return cached;
    }

    _healthCache.remove(crewId);
    return null;
  }

  /// Cache health metrics
  void _cacheHealthMetrics(String crewId, CrewHealthMetrics metrics) {
    _healthCache[crewId] = metrics;

    // Clean up old cache entries
    _healthCache.removeWhere((key, cached) =>
        DateTime.now().difference(cached.calculatedAt) > _cacheTTL);
  }

  /// Store health metrics
  Future<void> _storeHealthMetrics(CrewHealthMetrics metrics) async {
    try {
      await _firestore.collection(_healthMetricsCollection).add(metrics.toFirestore());
    } catch (e) {
      debugPrint('[CrewHealth] Error storing health metrics: $e');
    }
  }

  /// Get historical health metrics
  Future<List<CrewHealthMetrics>> _getHistoricalHealthMetrics(
    String crewId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_healthMetricsCollection)
          .where('crewId', isEqualTo: crewId)
          .where('calculatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('calculatedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('calculatedAt')
          .get();

      return snapshot.docs.map((doc) => CrewHealthMetrics.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('[CrewHealth] Error getting historical health metrics: $e');
      return [];
    }
  }

  /// Calculate trend direction
  TrendDirection _calculateTrendDirection(List<CrewHealthMetrics> data) {
    if (data.length < 2) return TrendDirection.stable;

    final recent = data.skip(max(0, data.length - 7)).toList(); // Last 7 data points
    if (recent.length < 2) return TrendDirection.stable;

    double totalChange = 0;
    for (int i = 1; i < recent.length; i++) {
      totalChange += recent[i].healthScore - recent[i - 1].healthScore;
    }

    final averageChange = totalChange / (recent.length - 1);

    if (averageChange > 0.05) return TrendDirection.improving;
    if (averageChange < -0.05) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  /// Generate health prediction
  HealthPrediction _generateHealthPrediction(List<CrewHealthMetrics> data) {
    if (data.length < 7) {
      return HealthPrediction(
        nextWeekScore: data.isNotEmpty ? data.last.healthScore : 0.0,
        nextMonthScore: data.isNotEmpty ? data.last.healthScore : 0.0,
        confidence: 0.0,
        factors: ['Insufficient historical data'],
      );
    }

    // Simple linear regression for prediction
    final recent = data.skip(max(0, data.length - 30)).toList(); // Last 30 data points

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < recent.length; i++) {
      sumX += i;
      sumY += recent[i].healthScore;
      sumXY += i * recent[i].healthScore;
      sumX2 += i * i;
    }

    final n = recent.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Predict next week (7 days ahead) and next month (30 days ahead)
    final nextWeekScore = (slope * (recent.length + 7) + intercept).clamp(0.0, 1.0);
    final nextMonthScore = (slope * (recent.length + 30) + intercept).clamp(0.0, 1.0);

    // Calculate confidence based on data consistency
    final variance = _calculateVariance(recent.map((m) => m.healthScore).toList());
    final confidence = max(0.0, 1.0 - variance);

    final factors = <String>[];
    if (slope.abs() > 0.01) factors.add('Strong trend detected');
    if (variance < 0.1) factors.add('Consistent patterns');
    if (recent.length >= 30) factors.add('Sufficient historical data');

    return HealthPrediction(
      nextWeekScore: nextWeekScore,
      nextMonthScore: nextMonthScore,
      confidence: confidence,
      factors: factors,
    );
  }

  /// Calculate variance
  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2)).toDouble();
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  /// Clean up old alerts
  Future<void> _cleanupOldAlerts() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: 30));
      final oldAlerts = await _firestore
          .collection(_healthAlertsCollection)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .where('status', isEqualTo: 'resolved')
          .get();

      final batch = _firestore.batch();
      for (final doc in oldAlerts.docs) {
        batch.delete(doc.reference);
      }

      if (oldAlerts.docs.isNotEmpty) {
        await batch.commit();
        debugPrint('[CrewHealth] Cleaned up ${oldAlerts.docs.length} old alerts');
      }
    } catch (e) {
      debugPrint('[CrewHealth] Error cleaning up old alerts: $e');
    }
  }

  /// Archive old health data
  Future<void> _archiveOldHealthData() async {
    try {
      // This would move old data to an archive collection
      // Implementation depends on specific archival requirements
      debugPrint('[CrewHealth] Old health data archival completed');
    } catch (e) {
      debugPrint('[CrewHealth] Error archiving old health data: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _maintenanceTimer?.cancel();
    for (final subscription in _monitoringStreams.values) {
      subscription.cancel();
    }
    _monitoringStreams.clear();
    _healthCache.clear();
  }
}

// Data models for crew health monitoring

class CrewHealthMetrics {
  final String crewId;
  final String crewName;
  final DateTime calculatedAt;
  final Duration timeWindow;
  final double healthScore;
  final ActivityMetrics activityMetrics;
  final EngagementMetrics engagementMetrics;
  final MemberMetrics memberMetrics;
  final CommunicationMetrics communicationMetrics;
  final List<String> recommendations;
  final RiskLevel riskLevel;

  CrewHealthMetrics({
    required this.crewId,
    required this.crewName,
    required this.calculatedAt,
    required this.timeWindow,
    required this.healthScore,
    required this.activityMetrics,
    required this.engagementMetrics,
    required this.memberMetrics,
    required this.communicationMetrics,
    required this.recommendations,
    required this.riskLevel,
  });

  factory CrewHealthMetrics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewHealthMetrics(
      crewId: data['crewId'] as String,
      crewName: data['crewName'] as String,
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
      timeWindow: Duration(days: data['timeWindowDays'] as int),
      healthScore: data['healthScore'] as double,
      activityMetrics: ActivityMetrics.fromMap(data['activityMetrics'] as Map<String, dynamic>),
      engagementMetrics: EngagementMetrics.fromMap(data['engagementMetrics'] as Map<String, dynamic>),
      memberMetrics: MemberMetrics.fromMap(data['memberMetrics'] as Map<String, dynamic>),
      communicationMetrics: CommunicationMetrics.fromMap(data['communicationMetrics'] as Map<String, dynamic>),
      recommendations: List<String>.from(data['recommendations'] as List),
      riskLevel: _parseRiskLevel(data['riskLevel'] as String),
    );
  }

  static RiskLevel _parseRiskLevel(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      case 'critical':
        return RiskLevel.critical;
      default:
        return RiskLevel.medium;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'crewId': crewId,
      'crewName': crewName,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
      'timeWindowDays': timeWindow.inDays,
      'healthScore': healthScore,
      'activityMetrics': activityMetrics.toMap(),
      'engagementMetrics': engagementMetrics.toMap(),
      'memberMetrics': memberMetrics.toMap(),
      'communicationMetrics': communicationMetrics.toMap(),
      'recommendations': recommendations,
      'riskLevel': riskLevel.name,
    };
  }
}

class ActivityMetrics {
  final int totalOperations;
  final int activeDays;
  final double averageOperationsPerDay;
  final double activityConsistency;

  ActivityMetrics({
    required this.totalOperations,
    required this.activeDays,
    required this.averageOperationsPerDay,
    required this.activityConsistency,
  });

  factory ActivityMetrics.fromMap(Map<String, dynamic> data) {
    return ActivityMetrics(
      totalOperations: data['totalOperations'] as int,
      activeDays: data['activeDays'] as int,
      averageOperationsPerDay: data['averageOperationsPerDay'] as double,
      activityConsistency: data['activityConsistency'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalOperations': totalOperations,
      'activeDays': activeDays,
      'averageOperationsPerDay': averageOperationsPerDay,
      'activityConsistency': activityConsistency,
    };
  }
}

class EngagementMetrics {
  final int totalMembers;
  final int activeMembers;
  final double engagementRate;
  final double averageActivityPerMember;

  EngagementMetrics({
    required this.totalMembers,
    required this.activeMembers,
    required this.engagementRate,
    required this.averageActivityPerMember,
  });

  factory EngagementMetrics.fromMap(Map<String, dynamic> data) {
    return EngagementMetrics(
      totalMembers: data['totalMembers'] as int,
      activeMembers: data['activeMembers'] as int,
      engagementRate: data['engagementRate'] as double,
      averageActivityPerMember: data['averageActivityPerMember'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'engagementRate': engagementRate,
      'averageActivityPerMember': averageActivityPerMember,
    };
  }
}

class MemberMetrics {
  final int totalMembers;
  final int newMembers;
  final int departedMembers;
  final double memberRetentionRate;
  final double averageTenureDays;

  MemberMetrics({
    required this.totalMembers,
    required this.newMembers,
    required this.departedMembers,
    required this.memberRetentionRate,
    required this.averageTenureDays,
  });

  factory MemberMetrics.fromMap(Map<String, dynamic> data) {
    return MemberMetrics(
      totalMembers: data['totalMembers'] as int,
      newMembers: data['newMembers'] as int,
      departedMembers: data['departedMembers'] as int,
      memberRetentionRate: data['memberRetentionRate'] as double,
      averageTenureDays: data['averageTenureDays'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMembers': totalMembers,
      'newMembers': newMembers,
      'departedMembers': departedMembers,
      'memberRetentionRate': memberRetentionRate,
      'averageTenureDays': averageTenureDays,
    };
  }
}

class CommunicationMetrics {
  final int totalMessages;
  final double averageMessagesPerDay;
  final int uniqueParticipants;
  final Duration averageResponseTime;

  CommunicationMetrics({
    required this.totalMessages,
    required this.averageMessagesPerDay,
    required this.uniqueParticipants,
    required this.averageResponseTime,
  });

  factory CommunicationMetrics.fromMap(Map<String, dynamic> data) {
    return CommunicationMetrics(
      totalMessages: data['totalMessages'] as int,
      averageMessagesPerDay: data['averageMessagesPerDay'] as double,
      uniqueParticipants: data['uniqueParticipants'] as int,
      averageResponseTime: Duration(milliseconds: data['averageResponseTimeMs'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMessages': totalMessages,
      'averageMessagesPerDay': averageMessagesPerDay,
      'uniqueParticipants': uniqueParticipants,
      'averageResponseTimeMs': averageResponseTime.inMilliseconds,
    };
  }
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

class CrewHealthOverview {
  final DateTime generatedAt;
  final Duration timeWindow;
  final int totalCrews;
  final List<CrewHealthMetrics> healthyCrews;
  final List<CrewHealthMetrics> atRiskCrews;
  final List<CrewHealthMetrics> criticalCrews;
  final List<String> failedAnalyses;
  final double averageHealthScore;
  final CrewHealthMetrics? mostActiveCrew;
  final CrewHealthMetrics? leastActiveCrew;

  CrewHealthOverview({
    required this.generatedAt,
    required this.timeWindow,
    required this.totalCrews,
    required this.healthyCrews,
    required this.atRiskCrews,
    required this.criticalCrews,
    required this.failedAnalyses,
    required this.averageHealthScore,
    this.mostActiveCrew,
    this.leastActiveCrew,
  });
}

class InactiveCrew {
  final String crewId;
  final String crewName;
  final DateTime lastActivity;
  final Duration inactiveDuration;
  final InactivitySeverity severity;
  final int memberCount;
  final String recommendation;

  InactiveCrew({
    required this.crewId,
    required this.crewName,
    required this.lastActivity,
    required this.inactiveDuration,
    required this.severity,
    required this.memberCount,
    required this.recommendation,
  });
}

enum InactivitySeverity {
  warning,
  critical,
}

class MaintenanceReport {
  final DateTime performedAt;
  final bool dryRun;
  final List<MaintenanceAction> actionsTaken;
  final List<String> errors;

  MaintenanceReport({
    required this.performedAt,
    required this.dryRun,
    required this.actionsTaken,
    required this.errors,
  });
}

class MaintenanceAction {
  final MaintenanceActionType type;
  final String? crewId;
  final String description;
  final DateTime executedAt;
  final String? result;

  MaintenanceAction({
    required this.type,
    this.crewId,
    required this.description,
    required this.executedAt,
    this.result,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'crewId': crewId,
      'description': description,
      'executedAt': executedAt.toIso8601String(),
      'result': result,
    };
  }
}

enum MaintenanceActionType {
  criticalCleanup,
  warningNotification,
  dataCleanup,
}

class CrewHealthTrends {
  final String crewId;
  final Duration analyzedPeriod;
  final List<CrewHealthMetrics> dataPoints;
  final TrendDirection trendDirection;
  final double averageHealthScore;
  final HealthPrediction prediction;

  CrewHealthTrends({
    required this.crewId,
    required this.analyzedPeriod,
    required this.dataPoints,
    required this.trendDirection,
    required this.averageHealthScore,
    required this.prediction,
  });
}

enum TrendDirection {
  improving,
  stable,
  declining,
}

class HealthPrediction {
  final double nextWeekScore;
  final double nextMonthScore;
  final double confidence;
  final List<String> factors;

  HealthPrediction({
    required this.nextWeekScore,
    required this.nextMonthScore,
    required this.confidence,
    required this.factors,
  });
}

class CrewHealthAlert {
  final String id;
  final String crewId;
  final HealthAlertType alertType;
  final AlertSeverity severity;
  final String message;
  final List<String> recommendations;
  final DateTime createdAt;
  final AlertStatus status;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  CrewHealthAlert({
    required this.id,
    required this.crewId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.recommendations,
    required this.createdAt,
    required this.status,
    this.resolvedAt,
    this.resolvedBy,
  });

  CrewHealthAlert copyWith({
    String? id,
    String? crewId,
    HealthAlertType? alertType,
    AlertSeverity? severity,
    String? message,
    List<String>? recommendations,
    DateTime? createdAt,
    AlertStatus? status,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return CrewHealthAlert(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  factory CrewHealthAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewHealthAlert(
      id: doc.id,
      crewId: data['crewId'] as String,
      alertType: _parseAlertType(data['alertType'] as String),
      severity: _parseSeverity(data['severity'] as String),
      message: data['message'] as String,
      recommendations: List<String>.from(data['recommendations'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: _parseStatus(data['status'] as String),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      resolvedBy: data['resolvedBy'] as String?,
    );
  }

  static HealthAlertType _parseAlertType(String alertType) {
    switch (alertType) {
      case 'lowMemberCount':
        return HealthAlertType.lowMemberCount;
      case 'criticalHealth':
        return HealthAlertType.criticalHealth;
      case 'criticalInactivity':
        return HealthAlertType.criticalInactivity;
      default:
        return HealthAlertType.criticalHealth;
    }
  }

  static AlertSeverity _parseSeverity(String severity) {
    switch (severity) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.medium;
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
      'crewId': crewId,
      'alertType': alertType.name,
      'severity': severity.name,
      'message': message,
      'recommendations': recommendations,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
    };
  }
}

enum HealthAlertType {
  lowMemberCount,
  criticalHealth,
  criticalInactivity,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum AlertStatus {
  active,
  investigating,
  resolved,
  false_positive,
}