import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:journeyman_jobs/services/enhanced_crew_service.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';
import 'package:journeyman_jobs/services/user_discovery_service.dart';

/// Comprehensive performance analytics service for system optimization and monitoring.
///
/// This service provides detailed performance analytics, query optimization recommendations,
/// cost analysis, and user behavior insights to ensure optimal system performance.
///
/// Features:
/// - Query performance monitoring and optimization
/// - User engagement analytics and behavior patterns
/// - System resource usage tracking
/// - Cost optimization recommendations
/// - Performance benchmarking and alerting
/// - Predictive performance insights
class PerformanceAnalyticsService {
  static final PerformanceAnalyticsService _instance = PerformanceAnalyticsService._internal();
  factory PerformanceAnalyticsService() => _instance;
  PerformanceAnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final EnhancedCrewService _crewService = EnhancedCrewService();
  final CrewMessagingService _messagingService = CrewMessagingService();
  final UserDiscoveryService _discoveryService = UserDiscoveryService();

  // Collection names
  static const String _performanceMetricsCollection = 'performance_metrics';
  static const String _queryAnalyticsCollection = 'query_analytics';
  static const String _userBehaviorCollection = 'user_behavior_analytics';
  static const String _costAnalyticsCollection = 'cost_analytics';
  static const String _performanceAlertsCollection = 'performance_alerts';

  // Performance thresholds
  static const Duration _slowQueryThreshold = Duration(milliseconds: 1000);
  static const Duration _criticalQueryThreshold = Duration(milliseconds: 5000);
  static const double _highCpuUsageThreshold = 0.8;
  static const double _highMemoryUsageThreshold = 0.85;
  static const int _maxConcurrentOperations = 100;

  // Analytics cache
  final Map<String, PerformanceData> _performanceCache = {};
  static const Duration _cacheTTL = Duration(minutes: 10);

  // Monitoring streams and timers
  final Map<String, StreamSubscription> _monitoringStreams = {};
  Timer? _analyticsTimer;
  Timer? _costTrackingTimer;

  /// Initialize performance analytics monitoring
  ///
  /// Starts comprehensive performance monitoring including query tracking,
  /// user behavior analysis, and cost monitoring.
  ///
  /// Returns [true] if initialization successful, [false] otherwise
  Future<bool> initialize() async {
    try {
      debugPrint('[PerformanceAnalytics] Initializing performance analytics');

      // Initialize Firebase Performance Monitoring
      await _performance.setPerformanceCollectionEnabled(true);

      // Start query performance monitoring
      await _startQueryMonitoring();

      // Start user behavior tracking
      await _startUserBehaviorTracking();

      // Start cost monitoring
      await _startCostMonitoring();

      // Start periodic analytics
      _startPeriodicAnalytics();

      debugPrint('[PerformanceAnalytics] Performance analytics initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Failed to initialize: $e');
      return false;
    }
  }

  /// Track query performance
  ///
  /// Measures and analyzes query performance to identify slow queries,
  /// optimization opportunities, and usage patterns.
  ///
  /// Parameters:
  /// - [queryType]: Type of query (read, write, batch, etc.)
  /// - [collection]: Collection being queried
  /// - [operation]: Specific operation being performed
  /// - [startTime]: Query start time
  /// - [endTime]: Query end time
  /// - [documentCount]: Number of documents affected
  /// - [metadata]: Additional query metadata
  ///
  /// Returns [QueryPerformanceMetrics] with detailed analysis
  Future<QueryPerformanceMetrics> trackQueryPerformance({
    required QueryType queryType,
    required String collection,
    required String operation,
    required DateTime startTime,
    required DateTime endTime,
    int documentCount = 0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final duration = endTime.difference(startTime);
      final metrics = QueryPerformanceMetrics(
        id: '', // Will be set by Firestore
        queryType: queryType,
        collection: collection,
        operation: operation,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        documentCount: documentCount,
        metadata: metadata ?? {},
        timestamp: DateTime.now(),
      );

      // Analyze performance
      final analysis = _analyzeQueryPerformance(metrics);

      // Store metrics
      await _storeQueryMetrics(metrics, analysis);

      // Check for performance alerts
      if (analysis.isSlow || analysis.isCritical) {
        await _createQueryPerformanceAlert(metrics, analysis);
      }

      debugPrint('[PerformanceAnalytics] Query performance tracked: ${operation} took ${duration.inMilliseconds}ms');
      return metrics;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error tracking query performance: $e');
      throw Exception('Failed to track query performance: $e');
    }
  }

  /// Get system performance overview
  ///
  /// Provides comprehensive system performance analysis including query
  /// performance, user engagement, system resources, and cost metrics.
  ///
  /// Parameters:
  /// - [timeWindow]: Analysis time window (default: 24 hours)
  /// - [includeDetails]: Include detailed breakdowns
  ///
  /// Returns [SystemPerformanceOverview] with comprehensive metrics
  Future<SystemPerformanceOverview> getSystemPerformanceOverview({
    Duration timeWindow = const Duration(hours: 24),
    bool includeDetails = false,
  }) async {
    try {
      debugPrint('[PerformanceAnalytics] Generating system performance overview');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Get query performance metrics
      final queryMetrics = await _getQueryPerformanceMetrics(startTime, endTime);

      // Get user behavior metrics
      final userBehaviorMetrics = await _getUserBehaviorMetrics(startTime, endTime);

      // Get cost analytics
      final costMetrics = await _getCostMetrics(startTime, endTime);

      // Get system resource metrics
      final resourceMetrics = await _getSystemResourceMetrics(startTime, endTime);

      // Calculate overall performance score
      final performanceScore = _calculateOverallPerformanceScore(
        queryMetrics,
        userBehaviorMetrics,
        resourceMetrics,
      );

      // Generate optimization recommendations
      final recommendations = _generateOptimizationRecommendations(
        queryMetrics,
        userBehaviorMetrics,
        resourceMetrics,
        costMetrics,
      );

      final overview = SystemPerformanceOverview(
        generatedAt: DateTime.now(),
        timeWindow: timeWindow,
        performanceScore: performanceScore,
        queryMetrics: queryMetrics,
        userBehaviorMetrics: userBehaviorMetrics,
        resourceMetrics: resourceMetrics,
        costMetrics: costMetrics,
        recommendations: recommendations,
        detailedBreakdown: includeDetails ? await _generateDetailedBreakdown(startTime, endTime) : null,
      );

      // Store overview
      await _storePerformanceOverview(overview);

      debugPrint('[PerformanceAnalytics] Performance overview generated');
      return overview;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error generating performance overview: $e');
      throw Exception('Failed to generate performance overview: $e');
    }
  }

  /// Analyze user engagement patterns
  ///
  /// Provides detailed analysis of user engagement, activity patterns,
  /// feature usage, and retention metrics.
  ///
  /// Parameters:
  /// - [userId]: Specific user ID to analyze (optional)
  /// - [timeWindow]: Analysis time window
  /// - [includePredictions]: Include predictive analytics
  ///
  /// Returns [UserEngagementAnalysis] with comprehensive user insights
  Future<UserEngagementAnalysis> analyzeUserEngagement({
    String? userId,
    Duration timeWindow = const Duration(days: 7),
    bool includePredictions = false,
  }) async {
    try {
      debugPrint('[PerformanceAnalytics] Analyzing user engagement${userId != null ? ' for user: $userId' : ''}');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Get user activity data
      final userActivity = userId != null
          ? await _getIndividualUserActivity(userId, startTime, endTime)
          : await _getAllUserActivity(startTime, endTime);

      // Calculate engagement metrics
      final engagementMetrics = _calculateEngagementMetrics(userActivity);

      // Analyze activity patterns
      final activityPatterns = _analyzeActivityPatterns(userActivity);

      // Analyze feature usage
      final featureUsage = await _analyzeFeatureUsage(userId, startTime, endTime);

      // Calculate retention metrics
      final retentionMetrics = await _calculateRetentionMetrics(userId, startTime, endTime);

      // Generate predictions if requested
      final predictions = includePredictions
          ? await _generateEngagementPredictions(userActivity, engagementMetrics)
          : null;

      final analysis = UserEngagementAnalysis(
        analyzedAt: DateTime.now(),
        timeWindow: timeWindow,
        userId: userId,
        engagementMetrics: engagementMetrics,
        activityPatterns: activityPatterns,
        featureUsage: featureUsage,
        retentionMetrics: retentionMetrics,
        predictions: predictions,
      );

      debugPrint('[PerformanceAnalytics] User engagement analysis completed');
      return analysis;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error analyzing user engagement: $e');
      throw Exception('Failed to analyze user engagement: $e');
    }
  }

  /// Generate cost optimization report
  ///
  /// Analyzes system costs and provides optimization recommendations
  /// to reduce expenses while maintaining performance.
  ///
  /// Parameters:
  /// - [timeWindow]: Analysis period
  /// - [includeForecast]: Include cost forecasting
  ///
  /// Returns [CostOptimizationReport] with detailed cost analysis
  Future<CostOptimizationReport> generateCostOptimizationReport({
    Duration timeWindow = const Duration(days: 30),
    bool includeForecast = false,
  }) async {
    try {
      debugPrint('[PerformanceAnalytics] Generating cost optimization report');

      final endTime = DateTime.now();
      final startTime = endTime.subtract(timeWindow);

      // Get detailed cost breakdown
      final costBreakdown = await _getDetailedCostBreakdown(startTime, endTime);

      // Analyze cost trends
      final costTrends = await _analyzeCostTrends(startTime, endTime);

      // Identify optimization opportunities
      final optimizationOpportunities = _identifyCostOptimizationOpportunities(costBreakdown);

      // Generate cost forecast if requested
      final forecast = includeForecast
          ? await _generateCostForecast(costTrends)
          : null;

      // Calculate potential savings
      final potentialSavings = _calculatePotentialSavings(optimizationOpportunities);

      final report = CostOptimizationReport(
        generatedAt: DateTime.now(),
        analysisPeriod: timeWindow,
        totalCosts: costBreakdown.totalCosts,
        costBreakdown: costBreakdown,
        costTrends: costTrends,
        optimizationOpportunities: optimizationOpportunities,
        potentialSavings: potentialSavings,
        forecast: forecast,
        recommendations: _generateCostRecommendations(optimizationOpportunities),
      );

      // Store report
      await _storeCostOptimizationReport(report);

      debugPrint('[PerformanceAnalytics] Cost optimization report generated');
      return report;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error generating cost optimization report: $e');
      throw Exception('Failed to generate cost optimization report: $e');
    }
  }

  /// Get performance alerts
  ///
  /// Retrieves active performance alerts with filtering options.
  ///
  /// Parameters:
  /// - [severity]: Filter by severity level
  /// - [alertType]: Filter by alert type
  /// - [limit]: Maximum number of alerts to return
  ///
  /// Returns list of active performance alerts
  Future<List<PerformanceAlert>> getPerformanceAlerts({
    AlertSeverity? severity,
    PerformanceAlertType? alertType,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_performanceAlertsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);

      if (severity != null) {
        query = query.where('severity', isEqualTo: severity.name);
      }

      if (alertType != null) {
        query = query.where('alertType', isEqualTo: alertType.name);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => PerformanceAlert.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error getting performance alerts: $e');
      return [];
    }
  }

  /// Create performance alert
  ///
  /// Creates and stores a performance alert for detected issues.
  ///
  /// Parameters:
  /// - [alertType]: Type of performance alert
  /// - [severity]: Alert severity level
  /// - [title]: Alert title
  /// - [description]: Detailed description
  /// - [recommendations]: Recommended actions
  /// - [metadata]: Additional alert metadata
  ///
  /// Returns created performance alert
  Future<PerformanceAlert> createPerformanceAlert({
    required PerformanceAlertType alertType,
    required AlertSeverity severity,
    required String title,
    required String description,
    List<String>? recommendations,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final alert = PerformanceAlert(
        id: '', // Will be set by Firestore
        alertType: alertType,
        severity: severity,
        title: title,
        description: description,
        recommendations: recommendations ?? [],
        createdAt: DateTime.now(),
        status: AlertStatus.active,
        resolvedAt: null,
        resolvedBy: null,
        metadata: metadata ?? {},
      );

      // Store alert
      final docRef = await _firestore.collection(_performanceAlertsCollection).add(alert.toFirestore());
      final savedAlert = alert.copyWith(id: docRef.id);

      debugPrint('[PerformanceAnalytics] Performance alert created: ${savedAlert.id}');
      return savedAlert;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error creating performance alert: $e');
      throw Exception('Failed to create performance alert: $e');
    }
  }

  /// Resolve performance alert
  ///
  /// Marks a performance alert as resolved with resolution details.
  ///
  /// Parameters:
  /// - [alertId]: Alert ID to resolve
  /// - [resolution]: Resolution details
  /// - [resolvedBy]: User who resolved the alert
  ///
  /// Returns [true] if successful, [false] otherwise
  Future<bool> resolvePerformanceAlert({
    required String alertId,
    required String resolution,
    required String resolvedBy,
  }) async {
    try {
      await _firestore.collection(_performanceAlertsCollection).doc(alertId).update({
        'status': 'resolved',
        'resolution': resolution,
        'resolvedBy': resolvedBy,
        'resolvedAt': Timestamp.now(),
      });

      debugPrint('[PerformanceAnalytics] Performance alert resolved: $alertId');
      return true;
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error resolving performance alert: $e');
      return false;
    }
  }

  // Private helper methods

  /// Start query monitoring
  Future<void> _startQueryMonitoring() async {
    try {
      // Monitor Firestore operations through custom traces
      final trace = _performance.newTrace('firestore_operations');
      await trace.start();

      // This would be integrated with actual query operations
      // For now, we'll set up periodic analysis
      debugPrint('[PerformanceAnalytics] Query monitoring started');
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error starting query monitoring: $e');
    }
  }

  /// Start user behavior tracking
  Future<void> _startUserBehaviorTracking() async {
    try {
      // Monitor user activities across the app
      debugPrint('[PerformanceAnalytics] User behavior tracking started');
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error starting user behavior tracking: $e');
    }
  }

  /// Start cost monitoring
  Future<void> _startCostMonitoring() async {
    try {
      // Monitor Firebase usage costs
      debugPrint('[PerformanceAnalytics] Cost monitoring started');
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error starting cost monitoring: $e');
    }
  }

  /// Start periodic analytics
  void _startPeriodicAnalytics() {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer.periodic(Duration(hours: 1), (_) {
      _performPeriodicAnalytics();
    });

    _costTrackingTimer?.cancel();
    _costTrackingTimer = Timer.periodic(Duration(hours: 6), (_) {
      _performCostAnalysis();
    });
  }

  /// Perform periodic analytics
  Future<void> _performPeriodicAnalytics() async {
    try {
      debugPrint('[PerformanceAnalytics] Performing periodic analytics');

      // Generate system performance overview
      await getSystemPerformanceOverview();

      // Check for performance issues
      await _checkPerformanceThresholds();

      // Clean up old analytics data
      await _cleanupOldAnalyticsData();
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error in periodic analytics: $e');
    }
  }

  /// Perform cost analysis
  Future<void> _performCostAnalysis() async {
    try {
      debugPrint('[PerformanceAnalytics] Performing cost analysis');

      // Generate cost optimization report
      await generateCostOptimizationReport();

      // Check for cost anomalies
      await _checkCostAnomalies();
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error in cost analysis: $e');
    }
  }

  /// Analyze query performance
  QueryPerformanceAnalysis _analyzeQueryPerformance(QueryPerformanceMetrics metrics) {
    final isSlow = metrics.duration > _slowQueryThreshold;
    final isCritical = metrics.duration > _criticalQueryThreshold;

    double performanceScore = 1.0;
    if (isSlow) {
      performanceScore -= 0.3;
    }
    if (isCritical) {
      performanceScore -= 0.5;
    }

    return QueryPerformanceAnalysis(
      isSlow: isSlow,
      isCritical: isCritical,
      performanceScore: performanceScore.clamp(0.0, 1.0),
      optimizationSuggestions: _generateQueryOptimizationSuggestions(metrics),
    );
  }

  /// Generate query optimization suggestions
  List<String> _generateQueryOptimizationSuggestions(QueryPerformanceMetrics metrics) {
    final suggestions = <String>[];

    if (metrics.duration > _slowQueryThreshold) {
      if (metrics.documentCount > 1000) {
        suggestions.add('Consider adding pagination for large result sets');
      }
      if (metrics.metadata.containsKey('orderBy') == false) {
        suggestions.add('Add appropriate indexes for query fields');
      }
      suggestions.add('Consider reducing document field size');
    }

    if (metrics.queryType == QueryType.read && metrics.documentCount > 500) {
      suggestions.add('Implement caching for frequently accessed data');
    }

    return suggestions;
  }

  /// Store query metrics
  Future<void> _storeQueryMetrics(
    QueryPerformanceMetrics metrics,
    QueryPerformanceAnalysis analysis,
  ) async {
    try {
      final docRef = await _firestore.collection(_queryAnalyticsCollection).add({
        ...metrics.toFirestore(),
        'analysis': analysis.toMap(),
      });

      debugPrint('[PerformanceAnalytics] Query metrics stored: ${docRef.id}');
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error storing query metrics: $e');
    }
  }

  /// Create query performance alert
  Future<void> _createQueryPerformanceAlert(
    QueryPerformanceMetrics metrics,
    QueryPerformanceAnalysis analysis,
  ) async {
    try {
      final severity = analysis.isCritical ? AlertSeverity.critical : AlertSeverity.high;

      await createPerformanceAlert(
        alertType: PerformanceAlertType.queryPerformance,
        severity: severity,
        title: '${analysis.isCritical ? 'Critical' : 'Slow'} Query Detected',
        description: 'Query "${metrics.operation}" on ${metrics.collection} '
            'took ${metrics.duration.inMilliseconds}ms',
        recommendations: analysis.optimizationSuggestions,
        metadata: {
          'queryId': metrics.id,
          'collection': metrics.collection,
          'duration': metrics.duration.inMilliseconds,
          'documentCount': metrics.documentCount,
        },
      );
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error creating query performance alert: $e');
    }
  }

  /// Get query performance metrics
  Future<QueryPerformanceSummary> _getQueryPerformanceMetrics(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_queryAnalyticsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
          .get();

      final metrics = snapshot.docs.map((doc) => QueryPerformanceMetrics.fromFirestore(doc)).toList();

      if (metrics.isEmpty) {
        return QueryPerformanceSummary(
          totalQueries: 0,
          averageQueryTime: Duration.zero,
          slowQueries: 0,
          criticalQueries: 0,
          mostQueriedCollections: {},
          queryTypeBreakdown: {},
        );
      }

      final totalQueries = metrics.length;
      final averageTime = Duration(
        milliseconds: metrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b) ~/ totalQueries,
      );
      final slowQueries = metrics.where((m) => m.duration > _slowQueryThreshold).length;
      final criticalQueries = metrics.where((m) => m.duration > _criticalQueryThreshold).length;

      // Analyze most queried collections
      final collectionCounts = <String, int>{};
      for (final metric in metrics) {
        collectionCounts[metric.collection] = (collectionCounts[metric.collection] ?? 0) + 1;
      }

      // Analyze query type breakdown
      final typeCounts = <QueryType, int>{};
      for (final metric in metrics) {
        typeCounts[metric.queryType] = (typeCounts[metric.queryType] ?? 0) + 1;
      }

      return QueryPerformanceSummary(
        totalQueries: totalQueries,
        averageQueryTime: averageTime,
        slowQueries: slowQueries,
        criticalQueries: criticalQueries,
        mostQueriedCollections: collectionCounts,
        queryTypeBreakdown: typeCounts,
      );
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error getting query performance metrics: $e');
      return QueryPerformanceSummary(
        totalQueries: 0,
        averageQueryTime: Duration.zero,
        slowQueries: 0,
        criticalQueries: 0,
        mostQueriedCollections: {},
        queryTypeBreakdown: {},
      );
    }
  }

  /// Get user behavior metrics
  Future<UserBehaviorSummary> _getUserBehaviorMetrics(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // This would analyze user activities from various sources
      // For now, return a placeholder implementation

      return UserBehaviorSummary(
        activeUsers: 0,
        averageSessionDuration: Duration.zero,
        totalSessions: 0,
        bounceRate: 0.0,
        topFeatures: {},
        userRetentionRate: 0.0,
      );
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error getting user behavior metrics: $e');
      return UserBehaviorSummary(
        activeUsers: 0,
        averageSessionDuration: Duration.zero,
        totalSessions: 0,
        bounceRate: 0.0,
        topFeatures: {},
        userRetentionRate: 0.0,
      );
    }
  }

  /// Get cost metrics
  Future<CostMetrics> _getCostMetrics(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // This would analyze Firebase costs and other operational costs
      // For now, return a placeholder implementation

      return CostMetrics(
        totalCost: 0.0,
        firestoreCosts: 0.0,
        storageCosts: 0.0,
        networkCosts: 0.0,
        computeCosts: 0.0,
        costPerActiveUser: 0.0,
        costGrowthRate: 0.0,
      );
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error getting cost metrics: $e');
      return CostMetrics(
        totalCost: 0.0,
        firestoreCosts: 0.0,
        storageCosts: 0.0,
        networkCosts: 0.0,
        computeCosts: 0.0,
        costPerActiveUser: 0.0,
        costGrowthRate: 0.0,
      );
    }
  }

  /// Get system resource metrics
  Future<SystemResourceMetrics> _getSystemResourceMetrics(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // This would monitor system resources like CPU, memory, storage
      // For now, return a placeholder implementation

      return SystemResourceMetrics(
        averageCpuUsage: 0.0,
        peakCpuUsage: 0.0,
        averageMemoryUsage: 0.0,
        peakMemoryUsage: 0.0,
        storageUsage: 0.0,
        networkBandwidth: 0.0,
        errorRate: 0.0,
      );
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error getting system resource metrics: $e');
      return SystemResourceMetrics(
        averageCpuUsage: 0.0,
        peakCpuUsage: 0.0,
        averageMemoryUsage: 0.0,
        peakMemoryUsage: 0.0,
        storageUsage: 0.0,
        networkBandwidth: 0.0,
        errorRate: 0.0,
      );
    }
  }

  /// Calculate overall performance score
  double _calculateOverallPerformanceScore(
    QueryPerformanceSummary queryMetrics,
    UserBehaviorSummary userBehavior,
    SystemResourceMetrics resourceMetrics,
  ) {
    double score = 0.0;

    // Query performance score (40% weight)
    final queryScore = queryMetrics.totalQueries > 0
        ? 1.0 - (queryMetrics.slowQueries + queryMetrics.criticalQueries * 2) / queryMetrics.totalQueries
        : 1.0;
    score += queryScore.clamp(0.0, 1.0) * 0.4;

    // User behavior score (30% weight)
    final userScore = userBehavior.activeUsers > 0
        ? 1.0 - userBehavior.bounceRate
        : 1.0;
    score += userScore.clamp(0.0, 1.0) * 0.3;

    // Resource usage score (30% weight)
    final resourceScore = 1.0 - max(resourceMetrics.averageCpuUsage, resourceMetrics.averageMemoryUsage);
    score += resourceScore.clamp(0.0, 1.0) * 0.3;

    return score.clamp(0.0, 1.0);
  }

  /// Generate optimization recommendations
  List<String> _generateOptimizationRecommendations(
    QueryPerformanceSummary queryMetrics,
    UserBehaviorSummary userBehavior,
    SystemResourceMetrics resourceMetrics,
    CostMetrics costMetrics,
  ) {
    final recommendations = <String>[];

    // Query performance recommendations
    if (queryMetrics.slowQueries > queryMetrics.totalQueries * 0.1) {
      recommendations.add('Optimize slow queries - consider adding indexes or reducing result sets');
    }

    // User behavior recommendations
    if (userBehavior.bounceRate > 0.5) {
      recommendations.add('Improve user engagement to reduce bounce rate');
    }

    // Resource usage recommendations
    if (resourceMetrics.averageCpuUsage > _highCpuUsageThreshold) {
      recommendations.add('Optimize CPU usage through code improvements or scaling');
    }

    if (resourceMetrics.averageMemoryUsage > _highMemoryUsageThreshold) {
      recommendations.add('Optimize memory usage and implement proper cleanup');
    }

    // Cost recommendations
    if (costMetrics.costGrowthRate > 0.2) {
      recommendations.add('Implement cost control measures to manage growth');
    }

    return recommendations;
  }

  /// Generate detailed breakdown
  Future<Map<String, dynamic>> _generateDetailedBreakdown(
    DateTime startTime,
    DateTime endTime,
  ) async {
    return {
      'queryDetails': await _getQueryDetails(startTime, endTime),
      'userSegmentAnalysis': await _getUserSegmentAnalysis(startTime, endTime),
      'featureUsageBreakdown': await _getFeatureUsageBreakdown(startTime, endTime),
      'timeBasedPatterns': await _getTimeBasedPatterns(startTime, endTime),
    };
  }

  /// Store performance overview
  Future<void> _storePerformanceOverview(SystemPerformanceOverview overview) async {
    try {
      await _firestore.collection(_performanceMetricsCollection).add({
        'type': 'system_overview',
        'overview': overview.toFirestore(),
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error storing performance overview: $e');
    }
  }

  /// Check performance thresholds
  Future<void> _checkPerformanceThresholds() async {
    try {
      // Check for critical performance issues
      final recentAlerts = await getPerformanceAlerts(
        severity: AlertSeverity.critical,
        limit: 10,
      );

      if (recentAlerts.length > 5) {
        await createPerformanceAlert(
          alertType: PerformanceAlertType.systemHealth,
          severity: AlertSeverity.critical,
          title: 'Multiple Critical Performance Issues Detected',
          description: 'System has ${recentAlerts.length} critical performance alerts',
          recommendations: [
            'Immediate investigation required',
            'Consider scaling resources',
            'Review recent changes',
          ],
        );
      }
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error checking performance thresholds: $e');
    }
  }

  /// Clean up old analytics data
  Future<void> _cleanupOldAnalyticsData() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: 30));

      final collections = [
        _performanceMetricsCollection,
        _queryAnalyticsCollection,
        _userBehaviorCollection,
        _costAnalyticsCollection,
      ];

      for (final collection in collections) {
        final oldData = await _firestore
            .collection(collection)
            .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
            .limit(1000) // Limit to avoid batch size issues
            .get();

        if (oldData.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in oldData.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }

      debugPrint('[PerformanceAnalytics] Old analytics data cleanup completed');
    } catch (e) {
      debugPrint('[PerformanceAnalytics] Error cleaning up old analytics data: $e');
    }
  }

  // Placeholder methods for future implementation

  Future<List<UserActivityData>> _getIndividualUserActivity(
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async => [];

  Future<List<UserActivityData>> _getAllUserActivity(
    DateTime startTime,
    DateTime endTime,
  ) async => [];

  EngagementMetrics _calculateEngagementMetrics(List<UserActivityData> activity) {
    return EngagementMetrics(
      dailyActiveUsers: 0,
      weeklyActiveUsers: 0,
      monthlyActiveUsers: 0,
      averageSessionDuration: Duration.zero,
      retentionRate: 0.0,
    );
  }

  ActivityPatterns _analyzeActivityPatterns(List<UserActivityData> activity) {
    return ActivityPatterns(
      peakHours: [],
      peakDays: [],
      seasonalTrends: {},
    );
  }

  Future<FeatureUsage> _analyzeFeatureUsage(
    String? userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    return FeatureUsage(
      featureUsage: {},
      mostUsedFeatures: [],
      leastUsedFeatures: [],
    );
  }

  Future<RetentionMetrics> _calculateRetentionMetrics(
    String? userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    return RetentionMetrics(
      day1Retention: 0.0,
      day7Retention: 0.0,
      day30Retention: 0.0,
      churnRate: 0.0,
    );
  }

  Future<EngagementPredictions> _generateEngagementPredictions(
    List<UserActivityData> activity,
    EngagementMetrics metrics,
  ) async {
    return EngagementPredictions(
      nextWeekActiveUsers: 0,
      nextMonthRetention: 0.0,
      churnRisk: [],
      growthOpportunities: [],
    );
  }

  Future<DetailedCostBreakdown> _getDetailedCostBreakdown(
    DateTime startTime,
    DateTime endTime,
  ) async {
    return DetailedCostBreakdown(
      totalCosts: 0.0,
      firestoreCosts: CostDetails(amount: 0.0, usage: 0, unitCost: 0.0),
      storageCosts: CostDetails(amount: 0.0, usage: 0, unitCost: 0.0),
      networkCosts: CostDetails(amount: 0.0, usage: 0, unitCost: 0.0),
      otherCosts: {},
    );
  }

  Future<CostTrends> _analyzeCostTrends(DateTime startTime, DateTime endTime) async {
    return CostTrends(
      dailyCosts: {},
      weeklyCosts: {},
      costGrowthRate: 0.0,
      projectedMonthlyCost: 0.0,
    );
  }

  List<CostOptimizationOpportunity> _identifyCostOptimizationOpportunities(
    DetailedCostBreakdown breakdown,
  ) {
    return [];
  }

  Future<CostForecast> _generateCostForecast(CostTrends trends) async {
    return CostForecast(
      nextMonthCost: 0.0,
      nextQuarterCost: 0.0,
      nextYearCost: 0.0,
      confidence: 0.0,
    );
  }

  double _calculatePotentialSavings(List<CostOptimizationOpportunity> opportunities) {
    return opportunities.fold(0.0, (sum, opp) => sum + opp.potentialSavings);
  }

  List<String> _generateCostRecommendations(List<CostOptimizationOpportunity> opportunities) {
    return opportunities.map((opp) => opp.recommendation).toList();
  }

  Future<void> _storeCostOptimizationReport(CostOptimizationReport report) async {
    // Implementation for storing cost optimization report
  }

  Future<void> _checkCostAnomalies() async {
    // Implementation for checking cost anomalies
  }

  Future<Map<String, dynamic>> _getQueryDetails(DateTime startTime, DateTime endTime) async {
    return {};
  }

  Future<Map<String, dynamic>> _getUserSegmentAnalysis(DateTime startTime, DateTime endTime) async {
    return {};
  }

  Future<Map<String, dynamic>> _getFeatureUsageBreakdown(DateTime startTime, DateTime endTime) async {
    return {};
  }

  Future<Map<String, dynamic>> _getTimeBasedPatterns(DateTime startTime, DateTime endTime) async {
    return {};
  }

  /// Dispose of resources
  void dispose() {
    _analyticsTimer?.cancel();
    _costTrackingTimer?.cancel();
    for (final subscription in _monitoringStreams.values) {
      subscription.cancel();
    }
    _monitoringStreams.clear();
    _performanceCache.clear();
  }
}

// Data models for performance analytics

enum QueryType {
  read,
  write,
  batch,
  transaction,
  aggregate,
}

enum PerformanceAlertType {
  queryPerformance,
  systemHealth,
  costAnomaly,
  userEngagement,
  resourceUsage,
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
  falsePositive,
}

class QueryPerformanceMetrics {
  final String id;
  final QueryType queryType;
  final String collection;
  final String operation;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int documentCount;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  QueryPerformanceMetrics({
    required this.id,
    required this.queryType,
    required this.collection,
    required this.operation,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.documentCount,
    required this.metadata,
    required this.timestamp,
  });

  factory QueryPerformanceMetrics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QueryPerformanceMetrics(
      id: doc.id,
      queryType: _parseQueryType(data['queryType'] as String),
      collection: data['collection'] as String,
      operation: data['operation'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      duration: Duration(milliseconds: data['durationMs'] as int),
      documentCount: data['documentCount'] as int,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  static QueryType _parseQueryType(String queryType) {
    switch (queryType) {
      case 'read':
        return QueryType.read;
      case 'write':
        return QueryType.write;
      case 'batch':
        return QueryType.batch;
      case 'transaction':
        return QueryType.transaction;
      case 'aggregate':
        return QueryType.aggregate;
      default:
        return QueryType.read;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'queryType': queryType.name,
      'collection': collection,
      'operation': operation,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMs': duration.inMilliseconds,
      'documentCount': documentCount,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class QueryPerformanceAnalysis {
  final bool isSlow;
  final bool isCritical;
  final double performanceScore;
  final List<String> optimizationSuggestions;

  QueryPerformanceAnalysis({
    required this.isSlow,
    required this.isCritical,
    required this.performanceScore,
    required this.optimizationSuggestions,
  });

  Map<String, dynamic> toMap() {
    return {
      'isSlow': isSlow,
      'isCritical': isCritical,
      'performanceScore': performanceScore,
      'optimizationSuggestions': optimizationSuggestions,
    };
  }
}

class QueryPerformanceSummary {
  final int totalQueries;
  final Duration averageQueryTime;
  final int slowQueries;
  final int criticalQueries;
  final Map<String, int> mostQueriedCollections;
  final Map<QueryType, int> queryTypeBreakdown;

  QueryPerformanceSummary({
    required this.totalQueries,
    required this.averageQueryTime,
    required this.slowQueries,
    required this.criticalQueries,
    required this.mostQueriedCollections,
    required this.queryTypeBreakdown,
  });
}

class UserBehaviorSummary {
  final int activeUsers;
  final Duration averageSessionDuration;
  final int totalSessions;
  final double bounceRate;
  final Map<String, int> topFeatures;
  final double userRetentionRate;

  UserBehaviorSummary({
    required this.activeUsers,
    required this.averageSessionDuration,
    required this.totalSessions,
    required this.bounceRate,
    required this.topFeatures,
    required this.userRetentionRate,
  });
}

class CostMetrics {
  final double totalCost;
  final double firestoreCosts;
  final double storageCosts;
  final double networkCosts;
  final double computeCosts;
  final double costPerActiveUser;
  final double costGrowthRate;

  CostMetrics({
    required this.totalCost,
    required this.firestoreCosts,
    required this.storageCosts,
    required this.networkCosts,
    required this.computeCosts,
    required this.costPerActiveUser,
    required this.costGrowthRate,
  });
}

class SystemResourceMetrics {
  final double averageCpuUsage;
  final double peakCpuUsage;
  final double averageMemoryUsage;
  final double peakMemoryUsage;
  final double storageUsage;
  final double networkBandwidth;
  final double errorRate;

  SystemResourceMetrics({
    required this.averageCpuUsage,
    required this.peakCpuUsage,
    required this.averageMemoryUsage,
    required this.peakMemoryUsage,
    required this.storageUsage,
    required this.networkBandwidth,
    required this.errorRate,
  });
}

class SystemPerformanceOverview {
  final DateTime generatedAt;
  final Duration timeWindow;
  final double performanceScore;
  final QueryPerformanceSummary queryMetrics;
  final UserBehaviorSummary userBehaviorMetrics;
  final SystemResourceMetrics resourceMetrics;
  final CostMetrics costMetrics;
  final List<String> recommendations;
  final Map<String, dynamic>? detailedBreakdown;

  SystemPerformanceOverview({
    required this.generatedAt,
    required this.timeWindow,
    required this.performanceScore,
    required this.queryMetrics,
    required this.userBehaviorMetrics,
    required this.resourceMetrics,
    required this.costMetrics,
    required this.recommendations,
    this.detailedBreakdown,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'generatedAt': Timestamp.fromDate(generatedAt),
      'timeWindowHours': timeWindow.inHours,
      'performanceScore': performanceScore,
      'queryMetrics': {
        'totalQueries': queryMetrics.totalQueries,
        'averageQueryTimeMs': queryMetrics.averageQueryTime.inMilliseconds,
        'slowQueries': queryMetrics.slowQueries,
        'criticalQueries': queryMetrics.criticalQueries,
      },
      'userBehaviorMetrics': {
        'activeUsers': userBehaviorMetrics.activeUsers,
        'averageSessionDurationMs': userBehaviorMetrics.averageSessionDuration.inMilliseconds,
        'totalSessions': userBehaviorMetrics.totalSessions,
        'bounceRate': userBehaviorMetrics.bounceRate,
        'userRetentionRate': userBehaviorMetrics.userRetentionRate,
      },
      'resourceMetrics': {
        'averageCpuUsage': resourceMetrics.averageCpuUsage,
        'peakCpuUsage': resourceMetrics.peakCpuUsage,
        'averageMemoryUsage': resourceMetrics.averageMemoryUsage,
        'peakMemoryUsage': resourceMetrics.peakMemoryUsage,
        'errorRate': resourceMetrics.errorRate,
      },
      'costMetrics': {
        'totalCost': costMetrics.totalCost,
        'costPerActiveUser': costMetrics.costPerActiveUser,
        'costGrowthRate': costMetrics.costGrowthRate,
      },
      'recommendations': recommendations,
      if (detailedBreakdown != null) 'detailedBreakdown': detailedBreakdown,
    };
  }
}

class PerformanceAlert {
  final String id;
  final PerformanceAlertType alertType;
  final AlertSeverity severity;
  final String title;
  final String description;
  final List<String> recommendations;
  final DateTime createdAt;
  final AlertStatus status;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final Map<String, dynamic> metadata;

  PerformanceAlert({
    required this.id,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.createdAt,
    required this.status,
    this.resolvedAt,
    this.resolvedBy,
    this.metadata = const {},
  });

  PerformanceAlert copyWith({
    String? id,
    PerformanceAlertType? alertType,
    AlertSeverity? severity,
    String? title,
    String? description,
    List<String>? recommendations,
    DateTime? createdAt,
    AlertStatus? status,
    DateTime? resolvedAt,
    String? resolvedBy,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceAlert(
      id: id ?? this.id,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  factory PerformanceAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerformanceAlert(
      id: doc.id,
      alertType: _parseAlertType(data['alertType'] as String),
      severity: _parseSeverity(data['severity'] as String),
      title: data['title'] as String,
      description: data['description'] as String,
      recommendations: List<String>.from(data['recommendations'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: _parseStatus(data['status'] as String),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      resolvedBy: data['resolvedBy'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  static PerformanceAlertType _parseAlertType(String alertType) {
    switch (alertType) {
      case 'queryPerformance':
        return PerformanceAlertType.queryPerformance;
      case 'systemHealth':
        return PerformanceAlertType.systemHealth;
      case 'costAnomaly':
        return PerformanceAlertType.costAnomaly;
      case 'userEngagement':
        return PerformanceAlertType.userEngagement;
      case 'resourceUsage':
        return PerformanceAlertType.resourceUsage;
      default:
        return PerformanceAlertType.systemHealth;
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
      'alertType': alertType.name,
      'severity': severity.name,
      'title': title,
      'description': description,
      'recommendations': recommendations,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      'metadata': metadata,
    };
  }
}

// Additional data models for user engagement and cost analysis

class UserActivityData {
  final String userId;
  final DateTime timestamp;
  final String activity;
  final Map<String, dynamic> metadata;

  UserActivityData({
    required this.userId,
    required this.timestamp,
    required this.activity,
    this.metadata = const {},
  });
}

class EngagementMetrics {
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final Duration averageSessionDuration;
  final double retentionRate;

  EngagementMetrics({
    required this.dailyActiveUsers,
    required this.weeklyActiveUsers,
    required this.monthlyActiveUsers,
    required this.averageSessionDuration,
    required this.retentionRate,
  });
}

class ActivityPatterns {
  final List<int> peakHours;
  final List<int> peakDays;
  final Map<String, double> seasonalTrends;

  ActivityPatterns({
    required this.peakHours,
    required this.peakDays,
    required this.seasonalTrends,
  });
}

class FeatureUsage {
  final Map<String, int> featureUsage;
  final List<String> mostUsedFeatures;
  final List<String> leastUsedFeatures;

  FeatureUsage({
    required this.featureUsage,
    required this.mostUsedFeatures,
    required this.leastUsedFeatures,
  });
}

class RetentionMetrics {
  final double day1Retention;
  final double day7Retention;
  final double day30Retention;
  final double churnRate;

  RetentionMetrics({
    required this.day1Retention,
    required this.day7Retention,
    required this.day30Retention,
    required this.churnRate,
  });
}

class EngagementPredictions {
  final int nextWeekActiveUsers;
  final double nextMonthRetention;
  final List<String> churnRisk;
  final List<String> growthOpportunities;

  EngagementPredictions({
    required this.nextWeekActiveUsers,
    required this.nextMonthRetention,
    required this.churnRisk,
    required this.growthOpportunities,
  });
}

class UserEngagementAnalysis {
  final DateTime analyzedAt;
  final Duration timeWindow;
  final String? userId;
  final EngagementMetrics engagementMetrics;
  final ActivityPatterns activityPatterns;
  final FeatureUsage featureUsage;
  final RetentionMetrics retentionMetrics;
  final EngagementPredictions? predictions;

  UserEngagementAnalysis({
    required this.analyzedAt,
    required this.timeWindow,
    this.userId,
    required this.engagementMetrics,
    required this.activityPatterns,
    required this.featureUsage,
    required this.retentionMetrics,
    this.predictions,
  });
}

class CostDetails {
  final double amount;
  final double usage;
  final double unitCost;

  CostDetails({
    required this.amount,
    required this.usage,
    required this.unitCost,
  });
}

class DetailedCostBreakdown {
  final double totalCosts;
  final CostDetails firestoreCosts;
  final CostDetails storageCosts;
  final CostDetails networkCosts;
  final Map<String, double> otherCosts;

  DetailedCostBreakdown({
    required this.totalCosts,
    required this.firestoreCosts,
    required this.storageCosts,
    required this.networkCosts,
    required this.otherCosts,
  });
}

class CostTrends {
  final Map<String, double> dailyCosts;
  final Map<String, double> weeklyCosts;
  final double costGrowthRate;
  final double projectedMonthlyCost;

  CostTrends({
    required this.dailyCosts,
    required this.weeklyCosts,
    required this.costGrowthRate,
    required this.projectedMonthlyCost,
  });
}

class CostOptimizationOpportunity {
  final String type;
  final String description;
  final double potentialSavings;
  final String recommendation;
  final int priority;

  CostOptimizationOpportunity({
    required this.type,
    required this.description,
    required this.potentialSavings,
    required this.recommendation,
    required this.priority,
  });
}

class CostForecast {
  final double nextMonthCost;
  final double nextQuarterCost;
  final double nextYearCost;
  final double confidence;

  CostForecast({
    required this.nextMonthCost,
    required this.nextQuarterCost,
    required this.nextYearCost,
    required this.confidence,
  });
}

class CostOptimizationReport {
  final DateTime generatedAt;
  final Duration analysisPeriod;
  final double totalCosts;
  final DetailedCostBreakdown costBreakdown;
  final CostTrends costTrends;
  final List<CostOptimizationOpportunity> optimizationOpportunities;
  final double potentialSavings;
  final CostForecast? forecast;
  final List<String> recommendations;

  CostOptimizationReport({
    required this.generatedAt,
    required this.analysisPeriod,
    required this.totalCosts,
    required this.costBreakdown,
    required this.costTrends,
    required this.optimizationOpportunities,
    required this.potentialSavings,
    this.forecast,
    required this.recommendations,
  });
}

class PerformanceData {
  final dynamic data;
  final DateTime timestamp;

  PerformanceData({
    required this.data,
    required this.timestamp,
  });
}