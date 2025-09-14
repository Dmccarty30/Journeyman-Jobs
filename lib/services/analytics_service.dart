import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

/// Production analytics service for tracking user behavior and app performance
/// Complies with IBEW data privacy requirements
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._internal();
  
  AnalyticsService._internal();

  late final FirebaseAnalytics _analytics;
  late final FirebasePerformance _performance;
  
  bool _isInitialized = false;
  String? _userId;

  /// Initialize analytics services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _performance = FirebasePerformance.instance;

      // Configure analytics based on environment and privacy settings
      await _configureAnalytics();
      
      // Set up performance monitoring
      await _configurePerformance();
      
      // Set user properties if authenticated
      await _setUserProperties();

      _isInitialized = true;
      print('Analytics service initialized successfully');
    } catch (e) {
      print('Error initializing Analytics service: $e');
      rethrow;
    }
  }

  /// Configure Firebase Analytics with privacy-compliant settings
  Future<void> _configureAnalytics() async {
    final config = FirebaseConfig.analyticsConfig;
    
    // Enable/disable analytics collection
    await _analytics.setAnalyticsCollectionEnabled(config.enabled);
    
    // Configure session timeout
    await _analytics.setSessionTimeoutDuration(config.sessionTimeout);
    
    // Disable collection of personal info (IBEW privacy requirement)
    await _analytics.setDefaultEventParameters({
      'collect_personal_info': false,
      'app_version': '1.0.0',
      'environment': FirebaseConfig.isProduction ? 'production' : 'development',
    });

    print('Analytics configured with privacy settings');
  }

  /// Configure Firebase Performance Monitoring
  Future<void> _configurePerformance() async {
    final config = FirebaseConfig.performanceConfig;
    
    // Enable/disable performance data collection
    await _performance.setPerformanceCollectionEnabled(config.enabled);
    
    // Enable/disable automatic data collection
    await _performance.setDataCollectionEnabled(config.dataCollectionEnabled);

    print('Performance monitoring configured');
  }

  /// Set user properties while respecting privacy
  Future<void> _setUserProperties() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      
      // Only set non-PII properties
      await _analytics.setUserId(id: user.uid);
      await _analytics.setUserProperty(
        name: 'user_verified',
        value: user.emailVerified.toString(),
      );
    }
  }

  /// Track job sharing events
  Future<void> trackJobShare({
    required String shareId,
    required String jobId,
    required String shareType,
    required int recipientCount,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized || !FirebaseConfig.analyticsConfig.enabled) return;

    try {
      await _analytics.logEvent(
        name: 'job_share',
        parameters: {
          'share_id': shareId,
          'job_id': jobId,
          'share_type': shareType,
          'recipient_count': recipientCount,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?additionalData,
        },
      );

      // Also log to Firestore for detailed analysis
      await _logToFirestore('job_share', {
        'shareId': shareId,
        'jobId': jobId,
        'shareType': shareType,
        'recipientCount': recipientCount,
        'userId': _userId,
        'timestamp': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
    } catch (e) {
      print('Error tracking job share: $e');
    }
  }

  /// Track share response events
  Future<void> trackShareResponse({
    required String shareId,
    required String responseType,
    bool wasSuccessful = true,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized || !FirebaseConfig.analyticsConfig.enabled) return;

    try {
      await _analytics.logEvent(
        name: 'share_response',
        parameters: {
          'share_id': shareId,
          'response_type': responseType,
          'was_successful': wasSuccessful,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?additionalData,
        },
      );
    } catch (e) {
      print('Error tracking share response: $e');
    }
  }

  /// Track app usage events
  Future<void> trackAppEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !FirebaseConfig.analyticsConfig.enabled) return;

    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?parameters,
        },
      );
    } catch (e) {
      print('Error tracking app event: $e');
    }
  }

  /// Track screen views
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized || !FirebaseConfig.analyticsConfig.enabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      print('Error tracking screen view: $e');
    }
  }

  /// Track errors for debugging
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    String? screenName,
    bool isCritical = false,
  }) async {
    if (!_isInitialized) return;

    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage.length > 100 
              ? errorMessage.substring(0, 100) + '...' 
              : errorMessage,
          if (screenName != null) 'screen_name': screenName,
          'is_critical': isCritical,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      print('Error tracking error: $e');
    }
  }

  /// Start a performance trace
  HttpMetric startHttpTrace(String url, HttpMethod method) {
    return _performance.newHttpMetric(url, method);
  }

  /// Start a custom performance trace
  Trace startTrace(String name) {
    return _performance.newTrace(name);
  }

  /// Log events to Firestore for detailed analysis
  Future<void> _logToFirestore(String event, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('analytics')
          .add({
        'event': event,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging to Firestore: $e');
    }
  }

  /// Set current user ID
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized) return;
    
    _userId = userId;
    await _analytics.setUserId(id: userId);
  }

  /// Reset analytics data (for logout)
  Future<void> resetAnalyticsData() async {
    if (!_isInitialized) return;

    _userId = null;
    await _analytics.resetAnalyticsData();
  }

  /// Get analytics instance for direct access if needed
  FirebaseAnalytics get analytics => _analytics;

  /// Get performance instance for direct access if needed
  FirebasePerformance get performance => _performance;
}