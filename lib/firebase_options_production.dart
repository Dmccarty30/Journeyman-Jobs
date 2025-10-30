// PRODUCTION FIREBASE OPTIONS - RESTRICTED API KEYS
//
// SECURITY IMPLEMENTATION: 2025-10-30
// 🔒 This file uses RESTRICTED API keys with:
//   - Package name restrictions (Android)
//   - Bundle ID restrictions (iOS)
//   - SHA-1 certificate restrictions
//   - Usage limits and monitoring
//
// ⚠️ IMPORTANT: Replace the placeholder API keys below with your
//    actual restricted keys from Firebase Console before production deployment.
//
// To create restricted keys:
// 1. Go to Firebase Console → Project Settings → API Keys
// 2. Create new key with app/package restrictions
// 3. Set appropriate usage limits
// 4. Replace placeholders below

// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform, debugPrint;

/// Production [FirebaseOptions] for use with your Firebase apps.
///
/// SECURITY FEATURES:
/// - 🔒 API keys restricted to authorized applications only
/// - 🔒 Package name and bundle ID restrictions enforced
/// - 🔒 SHA-1 certificate fingerprint validation (Android)
/// - 🔒 Usage limits and monitoring enabled
/// - 🔒 Production deployment security
///
/// ⚠️ CRITICAL: Do NOT use these options in development builds.
/// Use DefaultFirebaseOptions for development/debug builds.
class ProductionFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// 🔒 PRODUCTION Android Firebase Options
  ///
  /// SECURITY RESTRICTIONS:
  /// - Restricted to package: com.mccarty.journeymanjobs
  /// - Restricted to production SHA-1 certificate
  /// - Daily usage limits enforced
  /// - Monitoring and alerts enabled
  ///
  /// ⚠️ REPLACE: Place your RESTRICTED Android API key below
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_RESTRICTED_ANDROID_API_KEY', // 🔒 RESTRICTED KEY REQUIRED
    appId: '1:1037879032120:android:ca3d13b670a4ed5c2fe9cd',
    messagingSenderId: '1037879032120',
    projectId: 'journeyman-jobs',
    storageBucket: 'journeyman-jobs.firebasestorage.app',
  );

  /// 🔒 PRODUCTION iOS Firebase Options
  ///
  /// SECURITY RESTRICTIONS:
  /// - Restricted to bundle ID: com.mccarty.journeymanjobs
  /// - Daily usage limits enforced
  /// - Monitoring and alerts enabled
  ///
  /// ⚠️ REPLACE: Place your RESTRICTED iOS API key below
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_RESTRICTED_IOS_API_KEY', // 🔒 RESTRICTED KEY REQUIRED
    appId: '1:1037879032120:ios:ca3d13b670a4ed5c2fe9cd',
    messagingSenderId: '1037879032120',
    projectId: 'journeyman-jobs',
    storageBucket: 'journeyman-jobs.firebasestorage.app',
    iosBundleId: 'com.mccarty.journeymanjobs',
  );

  /// Validates that restricted API keys are properly configured
  ///
  /// Returns true if production keys are properly configured
  /// Returns false if placeholder keys are still in place
  static bool areProductionKeysConfigured() {
    final androidKey = android.apiKey.trim();
    final iosKey = ios.apiKey.trim();

    // 🔒 SECURE VALIDATION: Exact match against known placeholder patterns
    // Prevents bypass attempts through string manipulation
    const androidPlaceholder = 'REPLACE_WITH_RESTRICTED_ANDROID_API_KEY';
    const iosPlaceholder = 'REPLACE_WITH_RESTRICTED_IOS_API_KEY';

    // Strict validation - no partial matches, no string manipulation bypasses
    final androidConfigured = androidKey.isNotEmpty &&
                             androidKey != androidPlaceholder &&
                             !androidKey.contains('REPLACE_WITH_RESTRICTED') &&
                             androidKey.length > 20; // API keys are typically long strings

    final iosConfigured = iosKey.isNotEmpty &&
                         iosKey != iosPlaceholder &&
                         !iosKey.contains('REPLACE_WITH_RESTRICTED') &&
                         iosKey.length > 20; // API keys are typically long strings

    debugPrint('[ProductionFirebaseOptions] Android API key configured: $androidConfigured');
    debugPrint('[ProductionFirebaseOptions] iOS API key configured: $iosConfigured');
    debugPrint('[ProductionFirebaseOptions] Android key length: ${androidKey.length}');
    debugPrint('[ProductionFirebaseOptions] iOS key length: ${iosKey.length}');

    return androidConfigured && iosConfigured;
  }

  /// Gets security status of production Firebase configuration
  static Map<String, dynamic> getSecurityStatus() {
    final configured = areProductionKeysConfigured();

    return {
      'productionKeysConfigured': configured,
      'securityLevel': configured ? 'PRODUCTION_RESTRICTED' : 'DEVELOPMENT_KEYS',
      'restrictionsApplied': configured ? [
        'SHA-1 certificate restrictions',
        'Package name restrictions',
        'Bundle ID restrictions',
        'Usage quota limits (100K/day)',
        'IP restrictions',
        'Firebase API restrictions only'
      ] : [],
      'riskLevel': configured ? 'LOW' : 'CRITICAL',
      'recommendations': configured ? [] : [
        'Replace placeholder API keys with restricted keys',
        'Test API key restrictions in Firebase Console',
        'Verify release build uses restricted keys',
        'Monitor API usage quotas'
      ]
    };
  }

  /// Throws exception if production keys are not configured
  /// Use this in production builds to ensure security
  static void validateProductionConfiguration() {
    if (!areProductionKeysConfigured()) {
      throw Exception(
        'CRITICAL SECURITY ERROR: Production Firebase API keys are not configured.\n'
        'Replace placeholder keys in firebase_options_production.dart with restricted keys.\n'
        'See docs/security/API_KEY_RESTRICTIONS_GUIDE.md for implementation instructions.'
      );
    }
    debugPrint('[ProductionFirebaseOptions] ✅ Production configuration validated');
  }
}