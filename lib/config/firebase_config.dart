import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for different environments
class FirebaseConfig {
  
  /// Get Firebase options based on the current environment
  static FirebaseOptions get currentOptions {
    if (kReleaseMode) {
      return productionOptions;
    }
    return developmentOptions;
  }

  /// Production Firebase configuration
  static const FirebaseOptions productionOptions = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY',
           defaultValue: 'AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),
    appId: String.fromEnvironment('FIREBASE_APP_ID',
           defaultValue: '1:123456789012:web:abcdef123456'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID',
                       defaultValue: '123456789012'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID',
               defaultValue: 'journeyman-jobs-prod'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
                defaultValue: 'journeyman-jobs-prod.firebaseapp.com'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET',
                   defaultValue: 'journeyman-jobs-prod.appspot.com'),
    measurementId: String.fromEnvironment('FIREBASE_MEASUREMENT_ID',
                   defaultValue: 'G-XXXXXXXXXX'),
  );

  /// Development Firebase configuration
  static const FirebaseOptions developmentOptions = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_DEV_API_KEY',
           defaultValue: 'AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),
    appId: String.fromEnvironment('FIREBASE_DEV_APP_ID',
           defaultValue: '1:123456789012:web:abcdef123456'),
    messagingSenderId: String.fromEnvironment('FIREBASE_DEV_MESSAGING_SENDER_ID',
                       defaultValue: '123456789012'),
    projectId: String.fromEnvironment('FIREBASE_DEV_PROJECT_ID',
               defaultValue: 'journeyman-jobs-dev'),
    authDomain: String.fromEnvironment('FIREBASE_DEV_AUTH_DOMAIN',
                defaultValue: 'journeyman-jobs-dev.firebaseapp.com'),
    storageBucket: String.fromEnvironment('FIREBASE_DEV_STORAGE_BUCKET',
                   defaultValue: 'journeyman-jobs-dev.appspot.com'),
    measurementId: String.fromEnvironment('FIREBASE_DEV_MEASUREMENT_ID',
                   defaultValue: 'G-XXXXXXXXXX'),
  );

  /// Check if we're in production mode
  static bool get isProduction => kReleaseMode;

  /// Check if we're in development mode
  static bool get isDevelopment => !kReleaseMode;

  /// Get the current project ID
  static String get projectId => currentOptions.projectId;

  /// Get the current storage bucket
  static String get storageBucket => currentOptions.storageBucket ?? '';

  /// Get the current auth domain
  static String get authDomain => currentOptions.authDomain ?? '';

  /// Get deep linking configuration
  static DeepLinkConfig get deepLinkConfig => DeepLinkConfig(
    scheme: const String.fromEnvironment('DEEP_LINK_SCHEME', 
            defaultValue: 'journeymanjobs'),
    host: const String.fromEnvironment('DEEP_LINK_HOST', 
          defaultValue: 'share'),
    webUrl: isProduction 
        ? 'https://journeymanjobs.com' 
        : 'https://journeyman-jobs-dev.web.app',
  );

  /// Get analytics configuration
  static AnalyticsConfig get analyticsConfig => AnalyticsConfig(
    enabled: const bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: true),
    collectPersonalInfo: false, // Always false for IBEW data privacy
    sessionTimeout: const Duration(minutes: 30),
  );

  /// Get performance monitoring configuration
  static PerformanceConfig get performanceConfig => PerformanceConfig(
    enabled: isProduction,
    dataCollectionEnabled: isProduction,
    instrumentationEnabled: isProduction,
  );
}

/// Deep linking configuration
class DeepLinkConfig {
  final String scheme;
  final String host;
  final String webUrl;

  const DeepLinkConfig({
    required this.scheme,
    required this.host,
    required this.webUrl,
  });

  String buildShareUrl(String shareId) {
    return '$webUrl/share/$shareId';
  }

  String buildDeepLink(String shareId) {
    return '$scheme://$host/share/$shareId';
  }
}

/// Analytics configuration
class AnalyticsConfig {
  final bool enabled;
  final bool collectPersonalInfo;
  final Duration sessionTimeout;

  const AnalyticsConfig({
    required this.enabled,
    required this.collectPersonalInfo,
    required this.sessionTimeout,
  });
}

/// Performance monitoring configuration
class PerformanceConfig {
  final bool enabled;
  final bool dataCollectionEnabled;
  final bool instrumentationEnabled;

  const PerformanceConfig({
    required this.enabled,
    required this.dataCollectionEnabled,
    required this.instrumentationEnabled,
  });
}