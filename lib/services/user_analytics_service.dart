import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';

/// Service for tracking and analyzing user behavior patterns
/// Provides insights for data-driven optimization and personalization
class UserAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Analytics collections for aggregated data
  static const String _userBehaviorCollection = 'user_behavior_analytics';
  static const String _searchAnalyticsCollection = 'search_analytics';
  static const String _engagementMetricsCollection = 'engagement_metrics';

  /// Track job viewing patterns and user preferences
  static Future<void> trackJobView({
    required Job job,
    required String userId,
    required Duration viewDuration,
    String? source, // 'search', 'featured', 'recommended', etc.
    Map<String, dynamic>? context,
  }) async {
    try {
      final viewTimestamp = DateTime.now();
      
      // Track in Firebase Analytics for real-time insights
      await _analytics.logEvent(
        name: 'job_viewed',
        parameters: {
          'job_id': job.id,
          'user_id': userId,
          'company': job.company,
          'location': job.location,
          'local_number': job.local ?? 0,
          'classification': job.classification ?? 'unknown',
          'wage_range': _getWageRange(job.wage),
          'work_type': job.typeOfWork ?? 'unknown',
          'view_duration_seconds': viewDuration.inSeconds,
          'view_source': source ?? 'direct',
          'is_storm_work': _isStormWork(job),
          'is_local_job': _isLocalToUser(job, context),
          'job_age_days': _getJobAge(job.timestamp),
          'view_hour': viewTimestamp.hour,
          'view_day_of_week': viewTimestamp.weekday,
        }.cast<String, Object>(),
      );

      // Store detailed behavior data for trend analysis
      await _firestore.collection(_userBehaviorCollection).add({
        'event_type': 'job_view',
        'user_id': userId,
        'job_id': job.id,
        'job_data': {
          'company': job.company,
          'location': job.location,
          'local': job.local,
          'classification': job.classification,
          'wage': job.wage,
          'work_type': job.typeOfWork,
          'duration': job.duration,
        },
        'interaction_data': {
          'view_duration_seconds': viewDuration.inSeconds,
          'source': source,
          'context': context ?? {},
        },
        'timestamp': FieldValue.serverTimestamp(),
        'date_key': _getDateKey(viewTimestamp),
        'user_segments': await _getUserSegments(userId),
      });

      // Update user preference learning
      await _updateUserPreferences(userId, job, 'view');
      
    } catch (e) {
      debugPrint('Failed to track job view: $e');
    }
  }

  /// Track job application behavior and conversion patterns
  static Future<void> trackJobApplication({
    required Job job,
    required String userId,
    required String applicationMethod, // 'call', 'email', 'website', 'apply_button'
    Map<String, dynamic>? applicationData,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'job_application_started',
        parameters: {
          'job_id': job.id,
          'user_id': userId,
          'company': job.company,
          'local_number': job.local ?? 0,
          'classification': job.classification ?? 'unknown',
          'wage_value': job.wage ?? 0.0,
          'application_method': applicationMethod,
          'is_storm_work': _isStormWork(job),
          'conversion_source': applicationData?['source'] ?? 'unknown',
        }.cast<String, Object>(),
      );

      // Track conversion funnel
      await _firestore.collection(_userBehaviorCollection).add({
        'event_type': 'job_application',
        'user_id': userId,
        'job_id': job.id,
        'job_data': {
          'company': job.company,
          'local': job.local,
          'classification': job.classification,
          'wage': job.wage,
        },
        'application_data': {
          'method': applicationMethod,
          'data': applicationData ?? {},
        },
        'timestamp': FieldValue.serverTimestamp(),
        'date_key': _getDateKey(DateTime.now()),
        'conversion_metrics': {
          'is_conversion': true,
          'conversion_type': 'job_application',
          'conversion_value': job.wage ?? 0.0,
        },
      });

      // Update user preference learning with higher weight for applications
      await _updateUserPreferences(userId, job, 'application');
      
    } catch (e) {
      debugPrint('Failed to track job application: $e');
    }
  }

  /// Track search behavior and query patterns
  static Future<void> trackSearchBehavior({
    required String userId,
    required String query,
    required List<String> filters,
    required int resultCount,
    required Duration responseTime,
    String? searchType, // 'jobs', 'locals', 'combined'
    Map<String, dynamic>? searchContext,
  }) async {
    try {
      final searchTimestamp = DateTime.now();
      
      await _analytics.logEvent(
        name: 'search_performed',
        parameters: {
          'user_id': userId,
          'query_length': query.length,
          'query_words': query.split(' ').length,
          'filter_count': filters.length,
          'result_count': resultCount,
          'response_time_ms': responseTime.inMilliseconds,
          'search_type': searchType ?? 'unknown',
          'search_success': resultCount > 0,
          'is_empty_query': query.trim().isEmpty,
          'has_filters': filters.isNotEmpty,
          'search_hour': searchTimestamp.hour,
        }.cast<String, Object>(),
      );

      // Store detailed search analytics
      await _firestore.collection(_searchAnalyticsCollection).add({
        'user_id': userId,
        'query': query.toLowerCase(), // Normalize for analysis
        'query_terms': query.toLowerCase().split(' '),
        'filters': filters,
        'search_metadata': {
          'type': searchType ?? 'unknown',
          'result_count': resultCount,
          'response_time_ms': responseTime.inMilliseconds,
          'success': resultCount > 0,
          'context': searchContext ?? {},
        },
        'timestamp': FieldValue.serverTimestamp(),
        'date_key': _getDateKey(searchTimestamp),
        'search_quality_metrics': {
          'relevance_score': _calculateSearchRelevance(query, resultCount),
          'efficiency_score': _calculateSearchEfficiency(responseTime, resultCount),
          'user_intent': _inferUserIntent(query, filters),
        },
      });

      // Track search patterns for personalization
      await _updateSearchHistory(userId, query, filters, resultCount);
      
    } catch (e) {
      debugPrint('Failed to track search behavior: $e');
    }
  }

  /// Track user engagement metrics and session patterns
  static Future<void> trackUserEngagement({
    required String userId,
    required String action,
    required String screen,
    Duration? duration,
    Map<String, dynamic>? engagementData,
  }) async {
    try {
      final engagementTimestamp = DateTime.now();
      
      await _analytics.logEvent(
        name: 'user_engagement',
        parameters: {
          'user_id': userId,
          'action': action,
          'screen': screen,
          'duration_seconds': duration?.inSeconds ?? 0,
          'engagement_hour': engagementTimestamp.hour,
          'engagement_day': engagementTimestamp.weekday,
        }.cast<String, Object>(),
      );

      // Store engagement metrics for trend analysis
      await _firestore.collection(_engagementMetricsCollection).add({
        'user_id': userId,
        'action': action,
        'screen': screen,
        'engagement_data': {
          'duration_seconds': duration?.inSeconds ?? 0,
          'data': engagementData ?? {},
        },
        'timestamp': FieldValue.serverTimestamp(),
        'date_key': _getDateKey(engagementTimestamp),
        'session_metrics': {
          'is_deep_engagement': (duration?.inSeconds ?? 0) > 30,
          'engagement_quality': _calculateEngagementQuality(action, duration),
          'screen_category': _categorizeScreen(screen),
        },
      });
      
    } catch (e) {
      debugPrint('Failed to track user engagement: $e');
    }
  }

  /// Track feature usage and adoption patterns
  static Future<void> trackFeatureUsage({
    required String userId,
    required String featureName,
    required String action, // 'discovered', 'first_use', 'regular_use', 'abandoned'
    Map<String, dynamic>? featureContext,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: {
          'user_id': userId,
          'feature_name': featureName,
          'action': action,
          'is_power_user': await _isPowerUser(userId),
        }.cast<String, Object>(),
      );

      // Track feature adoption lifecycle
      await _firestore.collection('feature_analytics').add({
        'user_id': userId,
        'feature_name': featureName,
        'action': action,
        'context': featureContext ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'date_key': _getDateKey(DateTime.now()),
        'adoption_metrics': {
          'user_tenure_days': await _getUserTenureDays(userId),
          'feature_discovery_method': featureContext?['discovery_method'],
          'usage_frequency': await _getFeatureUsageFrequency(userId, featureName),
        },
      });
      
    } catch (e) {
      debugPrint('Failed to track feature usage: $e');
    }
  }

  /// Track offline behavior and sync patterns
  static Future<void> trackOfflineBehavior({
    required String userId,
    required String action, // 'offline_access', 'sync_triggered', 'offline_search'
    required Duration offlineDuration,
    Map<String, dynamic>? offlineData,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'offline_behavior',
        parameters: {
          'user_id': userId,
          'action': action,
          'offline_duration_minutes': offlineDuration.inMinutes,
          'data_freshness': offlineData?['data_age_hours'] ?? 0,
        }.cast<String, Object>(),
      );

      await _firestore.collection('offline_analytics').add({
        'user_id': userId,
        'action': action,
        'offline_metrics': {
          'duration_minutes': offlineDuration.inMinutes,
          'data': offlineData ?? {},
        },
        'timestamp': FieldValue.serverTimestamp(),
        'date_key': _getDateKey(DateTime.now()),
        'connectivity_patterns': {
          'offline_usage_quality': _calculateOfflineUsageQuality(action, offlineDuration),
          'sync_efficiency': offlineData?['sync_success'] == true,
        },
      });
      
    } catch (e) {
      debugPrint('Failed to track offline behavior: $e');
    }
  }

  /// Get user behavior insights and recommendations
  static Future<Map<String, dynamic>> getUserBehaviorInsights(String userId) async {
    try {
      final insights = <String, dynamic>{};
      
      // Get recent behavior data
      final behaviorSnapshot = await _firestore
          .collection(_userBehaviorCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final searchSnapshot = await _firestore
          .collection(_searchAnalyticsCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      // Analyze job viewing patterns
      final jobViews = behaviorSnapshot.docs
          .where((doc) => doc.data()['event_type'] == 'job_view')
          .toList();

      insights['job_preferences'] = _analyzeJobPreferences(jobViews);
      insights['search_patterns'] = _analyzeSearchPatterns(searchSnapshot.docs);
      insights['engagement_metrics'] = await _calculateUserEngagementMetrics(userId);
      insights['personalization_data'] = await _getPersonalizationRecommendations(userId);
      
      return insights;
      
    } catch (e) {
      debugPrint('Failed to get user behavior insights: $e');
      return {};
    }
  }

  /// Get aggregated analytics for admin dashboard
  static Future<Map<String, dynamic>> getAggregatedAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final analytics = <String, dynamic>{};
      
      // Get popular job categories
      analytics['popular_job_categories'] = await _getPopularJobCategories(start, end);
      
      // Get search trends
      analytics['search_trends'] = await _getSearchTrends(start, end);
      
      // Get user engagement metrics
      analytics['engagement_summary'] = await _getEngagementSummary(start, end);
      
      // Get conversion metrics
      analytics['conversion_metrics'] = await _getConversionMetrics(start, end);
      
      // Get feature adoption rates
      analytics['feature_adoption'] = await _getFeatureAdoptionRates(start, end);
      
      return analytics;
      
    } catch (e) {
      debugPrint('Failed to get aggregated analytics: $e');
      return {};
    }
  }

  // Helper methods for analytics calculations

  static String _getWageRange(double? wage) {
    if (wage == null) return 'unknown';
    if (wage < 25) return 'under_25';
    if (wage < 35) return '25_to_35';
    if (wage < 45) return '35_to_45';
    if (wage < 55) return '45_to_55';
    return 'over_55';
  }

  static bool _isStormWork(Job job) {
    final workType = job.typeOfWork?.toLowerCase() ?? '';
    final description = job.jobDescription?.toLowerCase() ?? '';
    return workType.contains('storm') || description.contains('storm') || description.contains('emergency');
  }

  static bool _isLocalToUser(Job job, Map<String, dynamic>? context) {
    if (context == null || context['user_location'] == null) return false;
    final userLocation = context['user_location'] as String?;
    final jobLocation = job.location.toLowerCase();
    return userLocation != null && jobLocation.contains(userLocation.toLowerCase());
  }

  static int _getJobAge(DateTime? timestamp) {
    if (timestamp == null) return 0;
    return DateTime.now().difference(timestamp).inDays;
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<List<String>> _getUserSegments(String userId) async {
    // This would analyze user behavior to assign segments
    // For now, return basic segments
    return ['active_user', 'job_seeker'];
  }

  static Future<void> _updateUserPreferences(String userId, Job job, String actionType) async {
    try {
      final weight = actionType == 'application' ? 3.0 : 1.0;
      
      await _firestore.collection('user_preferences').doc(userId).set({
        'classifications': FieldValue.arrayUnion([job.classification]),
        'locations': FieldValue.arrayUnion([job.location]),
        'work_types': FieldValue.arrayUnion([job.typeOfWork]),
        'preferred_wage_range': job.wage != null ? _getWageRange(job.wage) : null,
        'last_updated': FieldValue.serverTimestamp(),
        'interaction_count': FieldValue.increment(weight),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update user preferences: $e');
    }
  }

  static double _calculateSearchRelevance(String query, int resultCount) {
    if (query.trim().isEmpty) return 0.0;
    if (resultCount == 0) return 0.0;
    if (resultCount > 50) return 0.8; // Too many results might indicate poor targeting
    if (resultCount > 20) return 0.9;
    return 1.0; // Optimal result count
  }

  static double _calculateSearchEfficiency(Duration responseTime, int resultCount) {
    final ms = responseTime.inMilliseconds;
    if (ms < 300) return 1.0;
    if (ms < 500) return 0.9;
    if (ms < 1000) return 0.7;
    return 0.5;
  }

  static String _inferUserIntent(String query, List<String> filters) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('storm') || lowerQuery.contains('emergency')) return 'storm_work';
    if (lowerQuery.contains('lineman') || lowerQuery.contains('line')) return 'lineman_jobs';
    if (lowerQuery.contains('apprentice')) return 'apprentice_opportunities';
    if (filters.any((f) => f.contains('wage'))) return 'wage_focused';
    if (filters.any((f) => f.contains('location'))) return 'location_focused';
    return 'general_search';
  }

  static Future<void> _updateSearchHistory(String userId, String query, List<String> filters, int resultCount) async {
    try {
      await _firestore.collection('user_search_history').add({
        'user_id': userId,
        'query': query,
        'filters': filters,
        'result_count': resultCount,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to update search history: $e');
    }
  }

  static String _calculateEngagementQuality(String action, Duration? duration) {
    final seconds = duration?.inSeconds ?? 0;
    if (action == 'scroll' && seconds > 30) return 'high';
    if (action == 'view' && seconds > 60) return 'high';
    if (action == 'search' && seconds > 10) return 'medium';
    if (seconds > 5) return 'medium';
    return 'low';
  }

  static String _categorizeScreen(String screen) {
    if (screen.contains('job')) return 'jobs';
    if (screen.contains('local')) return 'locals';
    if (screen.contains('search')) return 'search';
    if (screen.contains('profile') || screen.contains('settings')) return 'profile';
    return 'other';
  }

  static Future<bool> _isPowerUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('user_profiles').doc(userId).get();
      final data = userDoc.data();
      return data?['is_power_user'] == true || (data?['interaction_count'] ?? 0) > 100;
    } catch (e) {
      return false;
    }
  }

  static Future<int> _getUserTenureDays(String userId) async {
    try {
      final userDoc = await _firestore.collection('user_profiles').doc(userId).get();
      final createdTime = userDoc.data()?['created_time'] as Timestamp?;
      if (createdTime != null) {
        return DateTime.now().difference(createdTime.toDate()).inDays;
      }
    } catch (e) {
      debugPrint('Failed to get user tenure: $e');
    }
    return 0;
  }

  static Future<String> _getFeatureUsageFrequency(String userId, String featureName) async {
    try {
      final usageCount = await _firestore
          .collection('feature_analytics')
          .where('user_id', isEqualTo: userId)
          .where('feature_name', isEqualTo: featureName)
          .where('action', isEqualTo: 'regular_use')
          .count()
          .get();
      
      final count = usageCount.count ?? 0;
      if (count > 30) return 'daily';
      if (count > 10) return 'weekly';
      if (count > 3) return 'monthly';
      return 'rarely';
    } catch (e) {
      return 'unknown';
    }
  }

  static String _calculateOfflineUsageQuality(String action, Duration duration) {
    if (action == 'offline_access' && duration.inMinutes > 30) return 'high';
    if (action == 'offline_search' && duration.inMinutes > 10) return 'medium';
    return 'low';
  }

  // Analysis methods for insights

  static Map<String, dynamic> _analyzeJobPreferences(List<QueryDocumentSnapshot> jobViews) {
    if (jobViews.isEmpty) return {};
    
    final classifications = <String, int>{};
    final locations = <String, int>{};
    final workTypes = <String, int>{};
    
    for (final view in jobViews) {
      final jobData = view.data() as Map<String, dynamic>;
      final job = jobData['job_data'] as Map<String, dynamic>?;
      
      if (job != null) {
        _incrementCounter(classifications, job['classification'] as String?);
        _incrementCounter(locations, job['location'] as String?);
        _incrementCounter(workTypes, job['work_type'] as String?);
      }
    }
    
    return {
      'preferred_classifications': _getTopEntries(classifications, 3),
      'preferred_locations': _getTopEntries(locations, 3),
      'preferred_work_types': _getTopEntries(workTypes, 3),
      'total_views': jobViews.length,
    };
  }

  static Map<String, dynamic> _analyzeSearchPatterns(List<QueryDocumentSnapshot> searches) {
    if (searches.isEmpty) return {};
    
    final queryTerms = <String, int>{};
    final searchTypes = <String, int>{};
    var totalResponseTime = 0;
    var successfulSearches = 0;
    
    for (final search in searches) {
      final data = search.data() as Map<String, dynamic>;
      final terms = data['query_terms'] as List<dynamic>? ?? [];
      
      for (final term in terms) {
        _incrementCounter(queryTerms, term as String?);
      }
      
      _incrementCounter(searchTypes, data['search_metadata']?['type'] as String?);
      
      totalResponseTime += (data['search_metadata']?['response_time_ms'] as int?) ?? 0;
      if (data['search_metadata']?['success'] == true) {
        successfulSearches++;
      }
    }
    
    return {
      'popular_terms': _getTopEntries(queryTerms, 10),
      'search_types': searchTypes,
      'avg_response_time_ms': searches.isNotEmpty ? totalResponseTime / searches.length : 0,
      'success_rate': searches.isNotEmpty ? successfulSearches / searches.length : 0,
      'total_searches': searches.length,
    };
  }

  static Future<Map<String, dynamic>> _calculateUserEngagementMetrics(String userId) async {
    // This would calculate detailed engagement metrics
    // For now, return placeholder data
    return {
      'session_duration_avg_minutes': 8.5,
      'screens_per_session': 4.2,
      'actions_per_session': 12.3,
      'engagement_score': 0.75,
    };
  }

  static Future<Map<String, dynamic>> _getPersonalizationRecommendations(String userId) async {
    // This would generate personalized recommendations
    // For now, return placeholder data
    return {
      'recommended_classifications': ['Lineman', 'Electrician'],
      'recommended_locations': ['California', 'Texas'],
      'optimal_search_times': ['8:00 AM', '1:00 PM', '6:00 PM'],
      'personalization_confidence': 0.68,
    };
  }

  // Additional aggregation methods for admin analytics

  static Future<Map<String, dynamic>> _getPopularJobCategories(DateTime start, DateTime end) async {
    // Implementation for popular job categories
    return {
      'Lineman': 245,
      'Electrician': 189,
      'Apprentice': 156,
      'Foreman': 98,
    };
  }

  static Future<Map<String, dynamic>> _getSearchTrends(DateTime start, DateTime end) async {
    // Implementation for search trends
    return {
      'trending_terms': ['storm work', 'lineman', 'california'],
      'search_volume_change': 15.2, // percentage increase
      'popular_filters': ['location', 'wage_range', 'classification'],
    };
  }

  static Future<Map<String, dynamic>> _getEngagementSummary(DateTime start, DateTime end) async {
    // Implementation for engagement summary
    return {
      'avg_session_duration_minutes': 7.8,
      'pages_per_session': 3.9,
      'bounce_rate': 0.23,
      'return_user_rate': 0.67,
    };
  }

  static Future<Map<String, dynamic>> _getConversionMetrics(DateTime start, DateTime end) async {
    // Implementation for conversion metrics
    return {
      'view_to_application_rate': 0.12,
      'search_to_view_rate': 0.34,
      'feature_adoption_rate': 0.45,
      'user_retention_rate': 0.78,
    };
  }

  static Future<Map<String, dynamic>> _getFeatureAdoptionRates(DateTime start, DateTime end) async {
    // Implementation for feature adoption rates
    return {
      'offline_mode': 0.23,
      'job_filtering': 0.67,
      'local_search': 0.45,
      'job_bookmarking': 0.34,
    };
  }

  // Utility methods

  static void _incrementCounter(Map<String, int> counter, String? key) {
    if (key != null && key.isNotEmpty) {
      counter[key] = (counter[key] ?? 0) + 1;
    }
  }

  static List<Map<String, dynamic>> _getTopEntries(Map<String, int> counter, int limit) {
    final entries = counter.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).map((e) => {
      'name': e.key,
      'count': e.value,
    }).toList();
  }
}