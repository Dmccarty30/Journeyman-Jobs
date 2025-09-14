# Job Sharing Feature - Developer Setup Guide

## Overview

This guide provides complete setup instructions for the job sharing feature implementation, including Firebase configuration, third-party service integration, and deployment procedures.

## 📋 Prerequisites

### Required Services

- Firebase project with Firestore, Authentication, and Cloud Functions enabled
- SendGrid account and API key (required for email sharing)
- Twilio account and credentials (optional for SMS sharing)
- Apple Developer account (for iOS deep linking)
- Google Play Console access (for Android deep linking)

### Development Environment

- Flutter SDK 3.6.0+
- Firebase CLI installed and configured
- Node.js 16+ (for Cloud Functions)
- Xcode 14+ (for iOS development)
- Android Studio (for Android development)

## 🚀 Quick Setup (30 minutes)

### 1. Firebase Project Configuration

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init

# Select:
# - Firestore
# - Functions
# - Hosting (optional)
```

### 2. Enable Required Firebase Services

In Firebase Console:

1. **Authentication**: Enable Email/Password provider
2. **Firestore**: Create database in production mode
3. **Cloud Functions**: Enable billing (required for external API calls)
4. **Cloud Messaging**: Generate server key for push notifications

### 3. Environment Configuration

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your actual values
nano .env
```

Required environment variables:

```bash
# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key

# SendGrid (Required)
SENDGRID_API_KEY=SG.your-sendgrid-api-key
SENDGRID_FROM_EMAIL=no-reply@yourdomain.com

# Twilio (Optional)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token

# App Configuration
DEEP_LINK_SCHEME=journeymanjobs
APP_STORE_ID=your-app-store-id
GOOGLE_PLAY_ID=com.yourdomain.journeymanjobs
```

## 🔧 Detailed Setup Instructions

### Firebase Firestore Setup

#### 1. Database Structure

Create the following collections in Firestore:

```javascript
// Collection: job_shares
{
  id: "auto-generated-id",
  jobId: "job-123",
  sharerId: "user-456",
  recipients: ["email1@example.com", "phone1"],
  sharedAt: Timestamp,
  message: "Custom message",
  shareMethod: "email|sms|in-app",
  status: "sent|delivered|viewed|applied",
  metadata: {
    viralCoefficient: 1.2,
    conversionRate: 0.4
  }
}

// Collection: crews
{
  id: "crew-789",
  name: "Lightning Crew",
  createdBy: "user-456",
  members: ["user-456", "user-789"],
  invitedMembers: ["email@example.com"],
  settings: {
    autoShare: true,
    notificationLevel: "all"
  },
  stats: {
    totalShares: 45,
    successfulApplications: 12
  }
}

// Collection: quick_signups
{
  id: "signup-101",
  email: "newuser@example.com",
  jobId: "job-123",
  sharerId: "user-456",
  token: "secure-token",
  expiresAt: Timestamp,
  completed: false,
  userData: {
    name: "John Doe",
    phone: "+1234567890"
  }
}
```

#### 2. Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Job shares - only sharer can read/write their shares
    match /job_shares/{shareId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.sharerId ||
         request.auth.uid in resource.data.recipientUserIds);
    }
    
    // Crews - members can read, creator can write
    match /crews/{crewId} {
      allow read: if request.auth != null && 
        (request.auth.uid in resource.data.members ||
         request.auth.uid == resource.data.createdBy);
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.createdBy;
    }
    
    // Quick signups - public read with token, system write
    match /quick_signups/{signupId} {
      allow read: if resource.data.token == request.query.token;
      allow write: if request.auth != null;
    }
  }
}
```

### Cloud Functions Setup

#### 1. Install Dependencies

```bash
cd functions
npm install firebase-functions firebase-admin @sendgrid/mail twilio
```

#### 2. Function Environment Variables

```bash
# Set Firebase Function environment variables
firebase functions:config:set sendgrid.api_key="your-sendgrid-key"
firebase functions:config:set sendgrid.from_email="no-reply@yourdomain.com"
firebase functions:config:set twilio.account_sid="your-twilio-sid"
firebase functions:config:set twilio.auth_token="your-twilio-token"
firebase functions:config:set app.deep_link_scheme="journeymanjobs"
firebase functions:config:set app.store_id="your-app-store-id"
```

#### 3. Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:sendJobShare
```

### Flutter App Configuration

#### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  # Existing dependencies...
  
  # Job sharing dependencies
  cloud_firestore: ^4.13.6
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.2
  permission_handler: ^11.2.0
  contacts_service: ^0.6.3
  share_plus: ^7.2.2
  uni_links: ^0.5.1
  rxdart: ^0.27.7
```

#### 2. Platform Configuration

##### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<!-- Contact permissions -->
<key>NSContactsUsageDescription</key>
<string>Access contacts to share jobs with crew members</string>

<!-- Notification permissions -->
<key>aps-environment</key>
<string>development</string>

<!-- Deep linking -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>journeymanjobs.deeplink</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>journeymanjobs</string>
    </array>
  </dict>
</array>
```

##### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Deep linking intent filter -->
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Existing configuration... -->
    
    <!-- Deep linking -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="journeymanjobs" />
    </intent-filter>
</activity>
```

### SendGrid Setup

#### 1. Create SendGrid Account

1. Sign up at <https://sendgrid.com>
2. Verify your sender email address
3. Create an API key with Mail Send permissions
4. Add API key to environment variables

#### 2. Email Templates

Create dynamic templates in SendGrid dashboard:

**Job Share Template ID**: `d-1234567890abcdef`

```html
<!-- job-share-template.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Job Opportunity Shared</title>
    <style>
        .container { max-width: 600px; margin: 0 auto; font-family: Arial, sans-serif; }
        .header { background: #1A202C; color: #B45309; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .job-card { border: 1px solid #ddd; padding: 15px; margin: 10px 0; }
        .cta-button { background: #B45309; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚡ Job Opportunity</h1>
        </div>
        <div class="content">
            <p>Hello!</p>
            <p>{{sharer_name}} has shared a job opportunity with you:</p>
            
            <div class="job-card">
                <h2>{{job_title}}</h2>
                <p><strong>Location:</strong> {{job_location}}</p>
                <p><strong>Wage:</strong> {{job_wage}}</p>
                <p><strong>Type:</strong> {{job_type}}</p>
                <p>{{job_description}}</p>
            </div>
            
            {{#if custom_message}}
            <p><em>"{{custom_message}}"</em> - {{sharer_name}}</p>
            {{/if}}
            
            <p>
                <a href="{{job_link}}" class="cta-button">View Job Details</a>
            </p>
            
            {{#unless is_existing_user}}
            <p>New to Journeyman Jobs? <a href="{{quick_signup_link}}">Quick signup in under 2 minutes!</a></p>
            {{/unless}}
        </div>
    </div>
</body>
</html>
```

### Twilio Setup (Optional)

#### 1. Create Twilio Account

1. Sign up at <https://twilio.com>
2. Get your Account SID and Auth Token
3. Purchase a phone number for SMS sending
4. Add credentials to environment variables

#### 2. SMS Templates

```javascript
// SMS message template
const smsTemplate = `
🔌 Job Alert from ${sharerName}!

${jobTitle}
📍 ${jobLocation}
💰 ${jobWage}

View details: ${jobLink}

{{#unless isExistingUser}}
New user? Quick signup: ${quickSignupLink}
{{/unless}}

- Journeyman Jobs
`;
```

## 🧪 Testing Setup

### 1. Test Data

Create test data in Firestore:

```javascript
// Test job
{
  id: "test-job-123",
  title: "Journeyman Electrician - Storm Work",
  location: "Houston, TX",
  wage: "$45/hour + overtime",
  type: "Storm Restoration",
  description: "Immediate openings for storm restoration work...",
  contractorId: "test-contractor-456"
}

// Test user
{
  id: "test-user-789",
  email: "test@example.com",
  name: "Test User",
  phone: "+15551234567",
  crews: ["test-crew-101"]
}
```

### 2. Test Scenarios

Create test cases for:

```dart
// Test sharing workflow
testWidgets('Share job via email', (tester) async {
  // Setup mock services
  final mockJobSharingService = MockJobSharingService();
  
  // Test share button tap
  await tester.pumpWidget(MaterialApp(
    home: JobDetailsScreen(jobId: 'test-job-123'),
  ));
  
  await tester.tap(find.byIcon(Icons.share));
  await tester.pumpAndSettle();
  
  // Verify share modal opened
  expect(find.text('Share Job'), findsOneWidget);
  
  // Enter recipient email
  await tester.enterText(find.byType(TextFormField), 'recipient@example.com');
  await tester.tap(find.text('Send Share'));
  
  // Verify sharing service called
  verify(mockJobSharingService.shareJob(any, any)).called(1);
});
```

### 3. Integration Testing

```bash
# Run integration tests
flutter test integration_test/job_sharing_test.dart

# Run specific test group
flutter test integration_test/job_sharing_test.dart -t "email-sharing"
```

## 📊 Monitoring & Analytics

### 1. Firebase Analytics Events

Track key metrics:

```dart
// Track sharing events
FirebaseAnalytics.instance.logEvent(
  name: 'job_shared',
  parameters: {
    'job_id': jobId,
    'share_method': shareMethod,
    'recipient_count': recipients.length,
  },
);

// Track conversion events
FirebaseAnalytics.instance.logEvent(
  name: 'share_converted',
  parameters: {
    'job_id': jobId,
    'sharer_id': sharerId,
    'signup_time_seconds': signupDuration,
  },
);
```

### 2. Performance Monitoring

Set up performance tracking:

```dart
// Monitor sharing performance
final trace = FirebasePerformance.instance.newTrace('job_share_flow');
trace.start();

try {
  await jobSharingService.shareJob(jobId, recipients);
  trace.setMetric('success', 1);
} catch (e) {
  trace.setMetric('error', 1);
} finally {
  trace.stop();
}
```

### 3. Crashlytics Integration

```dart
// Report sharing errors
try {
  await shareJob();
} catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(
    e,
    stackTrace,
    reason: 'Job sharing failed',
    information: [
      DiagnosticsProperty('jobId', jobId),
      DiagnosticsProperty('shareMethod', shareMethod),
    ],
  );
}
```

## 🚀 Deployment

### 1. Pre-deployment Checklist

- [ ] All environment variables configured
- [ ] Firebase services enabled and configured
- [ ] SendGrid templates created and tested
- [ ] Twilio credentials verified (if using SMS)
- [ ] Deep linking tested on both platforms
- [ ] Push notifications configured
- [ ] Security rules deployed
- [ ] Cloud Functions deployed and tested

### 2. Deployment Commands

```bash
# Deploy Firebase configuration
firebase deploy --only firestore:rules
firebase deploy --only functions

# Build and deploy Flutter app
flutter build ios --release
flutter build appbundle --release

# Test deployment
flutter test --coverage
flutter analyze
```

### 3. Post-deployment Verification

```bash
# Check Cloud Functions logs
firebase functions:log

# Monitor Firestore operations
# Check Firebase Console > Firestore > Usage tab

# Verify email delivery
# Check SendGrid dashboard > Activity Feed

# Test deep linking
# Use device browser to test sharing links
```

## 🔧 Troubleshooting

### Common Issues

#### Cloud Functions Not Working

```bash
# Check function logs
firebase functions:log --only sendJobShare

# Verify environment variables
firebase functions:config:get

# Test function locally
firebase functions:shell
```

#### Email Delivery Issues

- Verify SendGrid API key permissions
- Check sender email verification
- Monitor SendGrid activity feed
- Test with different email providers

#### Deep Linking Problems

- Verify URL scheme configuration
- Test with both debug and release builds
- Check platform-specific setup
- Use link tester tools

#### Permission Denied Errors

- Review Firestore security rules
- Check user authentication status
- Verify function authentication

## 📚 Additional Resources

### Documentation Links

- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [SendGrid API Documentation](https://sendgrid.com/docs/api-reference/)
- [Twilio SMS API](https://www.twilio.com/docs/sms)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)

### Support Channels

- Technical Issues: Create GitHub issue
- Firebase Support: Firebase Console support
- SendGrid Support: SendGrid help center
- General Questions: <development@journeymanjobs.com>

---

## Quick Reference

### Essential Commands

```bash
# Setup
firebase init
cp .env.example .env
flutter pub get

# Deploy
firebase deploy --only functions
flutter build appbundle --release

# Test
flutter test
firebase functions:shell

# Monitor
firebase functions:log
```

### Key Files

- `functions/index.js` - Cloud Functions
- `lib/services/job_sharing_service.dart` - Main service
- `lib/screens/job_sharing/` - UI screens
- `.env` - Environment configuration
- `firestore.rules` - Database security

---

- **The job sharing feature setup is now complete! Start sharing jobs and grow your network. ⚡**
