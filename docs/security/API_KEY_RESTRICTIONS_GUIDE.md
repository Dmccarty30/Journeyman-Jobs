# Firebase API Key Restrictions Implementation Guide

**CRITICAL SECURITY FIX - 2025-10-30**
**Priority**: 🔴 PRODUCTION BLOCKER
**Risk Score**: 8.5/10 (CRITICAL)

## Problem

The current Firebase API keys are exposed in plaintext in `lib/firebase_options.dart` and have no restrictions, allowing:
- Unlimited usage from any source
- Potential API abuse and cost escalation
- Security vulnerability from key extraction

## Solution: API Key Restrictions Implementation

### Step 1: Create Separate API Keys

1. **Go to Firebase Console** → Project Settings → API Keys
2. **Create 3 restricted API keys**:

#### Development Key
```json
{
  "name": "Development API Key",
  "restrictions": {
    "applications": ["com.mccarty.journeymanjobs.debug"],
    "apis": ["All Firebase APIs"],
    "usage_limits": {
      "requests_per_day": 10000
    }
  }
}
```

#### Production Key (Android)
```json
{
  "name": "Production Android API Key",
  "restrictions": {
    "applications": ["com.mccarty.journeymanjobs"],
    "package_names": ["com.mccarty.journeymanjobs"],
    "sha_1_certificates": ["PRODUCTION_SHA1"],
    "apis": ["All Firebase APIs"],
    "usage_limits": {
      "requests_per_day": 100000
    }
  }
}
```

#### Production Key (iOS)
```json
{
  "name": "Production iOS API Key",
  "restrictions": {
    "bundle_ids": ["com.mccarty.journeymanjobs"],
    "apis": ["All Firebase APIs"],
    "usage_limits": {
      "requests_per_day": 100000
    }
  }
}
```

### Step 2: Get SHA-1 Certificate Fingerprints

**Android Debug SHA-1** (Already in project):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Android Production SHA-1** (Required):
```bash
# Get from your production keystore
keytool -list -v -keystore path/to/production.keystore -alias your-alias
```

### Step 3: Update Firebase Options

Create environment-specific Firebase options:

```dart
// lib/firebase_options_production.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured for production');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'RESTRICTED_ANDROID_API_KEY', // 🔒 RESTRICTED KEY
    appId: '1:1037879032120:android:ca3d13b670a4ed5c2fe9cd',
    messagingSenderId: '1037879032120',
    projectId: 'journeyman-jobs',
    storageBucket: 'journeyman-jobs.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'RESTRICTED_IOS_API_KEY', // 🔒 RESTRICTED KEY
    appId: '1:1037879032120:ios:ca3d13b670a4ed5c2fe9cd',
    messagingSenderId: '1037879032120',
    projectId: 'journeyman-jobs',
    storageBucket: 'journeyman-jobs.firebasestorage.app',
    iosBundleId: 'com.mccarty.journeymanjobs',
  );
}
```

### Step 4: Environment-Specific Configuration

```dart
// lib/main.dart
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'firebase_options_production.dart' if (dart.library.io) 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use appropriate options based on build mode
  final options = kDebugMode
    ? DefaultFirebaseOptions.currentPlatform  // Development keys
    : ProductionFirebaseOptions.currentPlatform; // Restricted keys

  await Firebase.initializeApp(options: options);
  runApp(MyApp());
}
```

### Step 5: Firebase Security Rules Enhancement

Add additional restrictions in Firestore rules:

```javascript
// firebase/firestore.rules - Enhanced security
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Add application-specific validation
    function isValidApp() {
      return request.resource != null &&
             request.resource.appId == 'com.mccarty.journeymanjobs';
    }

    // All operations must come from valid app
    match /{document=**} {
      allow read, write: if isAuthenticated() && isValidApp();
    }
  }
}
```

### Step 6: Monitoring and Alerts

1. **Set up API key monitoring** in Google Cloud Console
2. **Create budget alerts** for unexpected usage spikes
3. **Implement client-side error handling** for quota exceeded scenarios

```dart
// lib/services/api_monitoring_service.dart
class ApiMonitoringService {
  static void logApiUsage(String operation, bool success) {
    // Log usage for monitoring
    debugPrint('API Operation: $operation, Success: $success');

    // Implement usage tracking
    if (!success) {
      _handleApiError(operation);
    }
  }

  static void _handleApiError(String operation) {
    // Handle quota exceeded, rate limiting, etc.
  }
}
```

## Implementation Checklist

### Firebase Console Actions
- [ ] Create Development API key with debug SHA-1 restriction
- [ ] Create Production Android API key with production SHA-1 restriction
- [ ] Create Production iOS API key with bundle ID restriction
- [ ] Set usage limits (10K/day dev, 100K/day prod)
- [ ] Enable API key monitoring
- [ ] Set up budget alerts

### Code Changes
- [ ] Create `firebase_options_production.dart` with restricted keys
- [ ] Update `main.dart` for environment-specific options
- [ ] Add API monitoring service
- [ ] Update error handling for restricted keys
- [ ] Test both development and production configurations

### Testing
- [ ] Verify development key works with debug build
- [ ] Verify production key works with release build
- [ ] Test API key restrictions (try using wrong SHA-1)
- [ ] Test quota limits and error handling
- [ ] Verify monitoring and alerts work

### Security Validation
- [ ] Confirm API keys are not hardcoded in release builds
- [ ] Verify SHA-1 certificate restrictions work
- [ ] Test that unauthorized apps cannot access Firebase
- [ ] Validate rate limiting prevents abuse

## Risk Mitigation

**Before Implementation**:
- 🔴 CRITICAL: Any app can use your unlimited API keys
- 🔴 CRITICAL: Potential for unlimited cost escalation
- 🔴 CRITICAL: Data exposure through unrestricted access

**After Implementation**:
- ✅ SECURE: Only authorized app builds can use Firebase
- ✅ SECURE: Usage limits prevent cost escalation
- ✅ SECURE: SHA-1/bundle ID restrictions prevent unauthorized access
- ✅ SECURE: Monitoring detects unusual usage patterns

## Rollback Plan

If issues occur with restricted keys:
1. Temporarily revert to unrestricted keys (emergency only)
2. Identify and fix restriction configuration issues
3. Re-apply restrictions with corrected settings
4. Monitor for proper functionality

## Next Steps

1. **Execute this guide immediately** - This is a production security blocker
2. **Test thoroughly** before deploying to production
3. **Monitor API usage** after implementation
4. **Document the restricted keys** securely for team access

---

**IMMEDIATE ACTION REQUIRED**: This security vulnerability must be resolved before production deployment.