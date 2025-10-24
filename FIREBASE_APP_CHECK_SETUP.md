# Firebase App Check Setup Guide

## Overview

Firebase App Check helps protect your app's backend resources from abuse by preventing unauthorized clients from accessing your Firebase services. Currently, the app shows warnings:

```
W/LocalRequestInterceptor: Error getting App Check token; using placeholder token instead.
Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.
```

This is **not critical for development** but should be configured before production deployment.

## App Check Benefits

- **Protects Firestore**: Prevents unauthorized access to your Firestore database
- **Prevents Quota Abuse**: Stops malicious clients from exhausting your Firebase quota
- **Reduces Costs**: Prevents API abuse that could lead to unexpected charges
- **Enhances Security**: Adds an additional layer of authentication verification

## Setup Steps

### 1. Enable App Check in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/project/journeyman-jobs/appcheck)
2. Click "Get Started" or "App Check" in the left sidebar
3. Select your Android app
4. Choose a provider:
   - **Play Integrity** (Recommended for production Android apps)
   - **SafetyNet** (Legacy, being deprecated)
   - **Debug Provider** (For development/testing only)

### 2. Configure Play Integrity (Production)

#### Enable Play Integrity API

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/library/playintegrity.googleapis.com)
2. Select your project: `journeyman-jobs`
3. Click "Enable" on the Play Integrity API

#### Link Your App

1. Return to Firebase Console > App Check
2. Select **Play Integrity** as the provider
3. Click "Save"

### 3. Add App Check Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_app_check: ^0.3.1+3  # Check for latest version
```

### 4. Initialize App Check in Flutter

Update `lib/main.dart`:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // For production
    // androidProvider: AndroidProvider.debug, // For development
    appleProvider: AppleProvider.appAttest,
  );

  runApp(const MyApp());
}
```

### 5. Configure Debug Provider (Development Only)

For development and testing without Play Store distribution:

```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.debug,
  appleProvider: AppleProvider.debug,
);
```

#### Get Debug Token

1. Run the app with debug provider enabled
2. Check the logs for the debug token:
   ```
   D/FirebaseAppCheck: Firebase App Check debug token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   ```
3. Add this token to Firebase Console:
   - Go to App Check settings
   - Click "Manage debug tokens"
   - Add the token from logs

### 6. Enforce App Check (Optional)

In Firebase Console, you can enforce App Check for specific services:

1. Go to App Check settings
2. For each service (Firestore, Storage, etc.):
   - Click the three-dot menu
   - Select "Enforce"
   - Choose enforcement mode:
     - **Monitor**: Logs violations without blocking
     - **Enforce**: Blocks requests without valid tokens

**Recommendation**: Use "Monitor" mode initially to ensure proper configuration.

## Testing

### Verify App Check is Working

1. Run the app with App Check configured
2. Check logs for successful initialization:
   ```
   I/FirebaseAppCheck: App Check initialized successfully
   ```
3. Verify no more "No AppCheckProvider installed" warnings

### Test Enforcement

If you enabled enforcement in Firebase Console:

1. Run app without App Check configuration
2. Firestore requests should fail with permission errors
3. Re-enable App Check configuration
4. Requests should succeed

## Production Checklist

- [ ] Play Integrity API enabled in Google Cloud Console
- [ ] Play Integrity provider configured in Firebase Console
- [ ] App Check initialized in Flutter app with `AndroidProvider.playIntegrity`
- [ ] App published to Play Store (Play Integrity requires official distribution)
- [ ] Test enforcement mode in staging environment
- [ ] Monitor App Check metrics in Firebase Console
- [ ] Remove any debug tokens from Firebase Console

## Development vs Production Configuration

### Development

```dart
// Use debug provider for local development
await FirebaseAppCheck.instance.activate(
  androidProvider: kDebugMode
    ? AndroidProvider.debug
    : AndroidProvider.playIntegrity,
);
```

### Production

```dart
// Always use Play Integrity in production
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.appAttest,
);
```

## Common Issues

### "Firebase App Check failed to retrieve attestation"

**Solution**: Ensure Play Integrity API is enabled and your app is distributed through Play Store.

### "Debug token not recognized"

**Solution**:
1. Verify token was copied correctly from logs
2. Check token was added to correct Firebase project
3. Wait a few minutes after adding token for propagation

### "Permission denied" after enabling enforcement

**Solution**:
1. Switch to "Monitor" mode temporarily
2. Check App Check metrics for failed validations
3. Verify app is properly configured with valid provider

## Resources

- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Play Integrity API](https://developer.android.com/google/play/integrity)
- [Flutter firebase_app_check Package](https://pub.dev/packages/firebase_app_check)

## Priority

**Priority**: Low for development, **High for production**

The current warnings do not affect app functionality in development. However, App Check should be configured before launching to production to protect your Firebase resources from abuse.
