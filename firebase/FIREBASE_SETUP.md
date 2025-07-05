# Firebase Setup Instructions

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com
2. Name it something like "journeyman-jobs" or "journeyman-jobs-prod"

## Android Setup
1. In Firebase Console, add an Android app
2. Package name: `com.mccarty.journeymanjobs.journeyman_jobs`
3. Download `google-services.json`
4. Place it in `android/app/` directory

## iOS Setup
1. In Firebase Console, add an iOS app
2. Bundle ID: `com.mccarty.journeymanjobs.journeymanJobs`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click on Runner folder and "Add Files to Runner"
7. Select the `GoogleService-Info.plist` file

## Enable Firebase Services
In Firebase Console, enable:
1. Authentication
   - Enable Email/Password
   - Enable Google Sign-In
   - Enable Apple Sign-In (requires Apple Developer account configuration)
2. Cloud Firestore
   - Create database in production mode
   - Choose a location (e.g., us-central1)
3. Firebase Storage (if needed)

## FlutterFire Configuration
After placing the configuration files, run:
```bash
flutterfire configure
```

This will generate the `firebase_options.dart` file needed for initialization.

## Security Rules
After setup, configure Firestore security rules as specified in the project documentation.
