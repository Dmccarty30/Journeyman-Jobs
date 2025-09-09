# Production Deployment Guide

## Complete Launch Checklist & Monitoring Setup

---

## 🚀 Deployment Overview

This guide covers the complete production deployment process for the job sharing feature, including pre-launch checklist, deployment steps, monitoring setup, and rollback procedures.

---

## 📋 Pre-Deployment Checklist

### Code Quality

```dart
Code Review:
☐ All PRs reviewed by 2+ developers
☐ No unresolved comments
☐ Code follows style guide
☐ Documentation complete

Testing:
☐ All unit tests passing (90%+ coverage)
☐ Integration tests passing
☐ E2E tests passing
☐ Performance benchmarks met
☐ Manual QA completed

Security:
☐ Security audit completed
☐ No exposed API keys
☐ Authentication properly implemented
☐ Rate limiting configured
☐ Input validation in place
```

### Infrastructure

```dart
Firebase:
☐ Production project created
☐ Firestore indexes created
☐ Security rules tested
☐ Cloud Functions deployed
☐ Storage buckets configured

Third-Party Services:
☐ SendGrid account configured
☐ SendGrid templates created
☐ Twilio account setup (if using SMS)
☐ Analytics platforms connected
☐ Error tracking setup (Sentry/Crashlytics)

Environment:
☐ Production environment variables set
☐ API keys rotated
☐ SSL certificates valid
☐ Domain configured
☐ CDN setup
```

---

## 🔧 Environment Configuration

### Production Environment Variables

**File: `.env.production`**

```env
# Firebase Production Config
FIREBASE_API_KEY=AIzaSyD_PROD_KEY_HERE
FIREBASE_AUTH_DOMAIN=journeyman-jobs-prod.firebaseapp.com
FIREBASE_PROJECT_ID=journeyman-jobs-prod
FIREBASE_STORAGE_BUCKET=journeyman-jobs-prod.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdef123456
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# Email Service
SENDGRID_API_KEY=SG.PROD_KEY_HERE
EMAIL_FROM=noreply@journeymanjobs.com
EMAIL_REPLY_TO=support@journeymanjobs.com

# SMS Service (Optional)
TWILIO_ACCOUNT_SID=AC_PROD_SID_HERE
TWILIO_AUTH_TOKEN=PROD_TOKEN_HERE
TWILIO_FROM_NUMBER=+18001234567

# Deep Linking
APP_DOMAIN=https://journeymanjobs.com
IOS_BUNDLE_ID=com.journeymanjobs.app
ANDROID_PACKAGE=com.journeymanjobs.app
IOS_APP_STORE_ID=1234567890
ANDROID_PLAY_STORE_ID=com.journeymanjobs.app

# Analytics
GOOGLE_ANALYTICS_ID=UA-XXXXXXXXX-X
MIXPANEL_TOKEN=PROD_MIXPANEL_TOKEN
AMPLITUDE_API_KEY=PROD_AMPLITUDE_KEY

# Feature Flags
ENABLE_JOB_SHARING=true
ENABLE_QUICK_SIGNUP=true
ENABLE_CREW_MANAGEMENT=true
ENABLE_SMS_SHARING=false

# Rate Limiting
SHARE_RATE_LIMIT_PER_HOUR=10
SHARE_RATE_LIMIT_PER_DAY=50
EMAIL_RATE_LIMIT_PER_HOUR=20

# Monitoring
SENTRY_DSN=https://xxx@sentry.io/xxx
DATADOG_API_KEY=PROD_DATADOG_KEY
NEW_RELIC_LICENSE_KEY=PROD_NR_KEY
```

---

## 📦 Build & Deployment Process

### Flutter App Deployment

#### Android Production Build

```bash
# Clean build directory
flutter clean

# Get dependencies
flutter pub get

# Build production APK
flutter build apk --release --dart-define-from-file=.env.production

# Build production App Bundle
flutter build appbundle --release --dart-define-from-file=.env.production

# Sign the APK (if not using Play App Signing)
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore upload-keystore.jks \
  build/app/outputs/bundle/release/app-release.aab \
  upload

# Verify signing
jarsigner -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab
```

#### iOS Production Build

```bash
# Clean build directory
flutter clean

# Get dependencies
flutter pub get

# Build iOS release
flutter build ios --release --dart-define-from-file=.env.production

# Open in Xcode for archiving
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select 'Any iOS Device' as build target
# 2. Product > Archive
# 3. Distribute App > App Store Connect
# 4. Upload
```

### Firebase Deployment

```bash
# Deploy everything
firebase deploy --project journeyman-jobs-prod

# Deploy specific services
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only functions
firebase deploy --only hosting
firebase deploy --only storage

# Deploy specific function
firebase deploy --only functions:sendJobShareEmail

# Deploy with environment config
firebase functions:config:set \
  sendgrid.api_key="YOUR_KEY" \
  twilio.sid="YOUR_SID" \
  --project journeyman-jobs-prod
```

---

## 🔄 Rollout Strategy

### Phased Rollout Plan

```typescript
// Feature flag configuration
const ROLLOUT_CONFIG = {
  phase1: {
    startDate: '2024-02-01',
    percentage: 10,
    regions: ['US-East'],
    userGroups: ['beta_testers'],
  },
  phase2: {
    startDate: '2024-02-08',
    percentage: 25,
    regions: ['US-East', 'US-West'],
    userGroups: ['beta_testers', 'power_users'],
  },
  phase3: {
    startDate: '2024-02-15',
    percentage: 50,
    regions: ['US'],
    userGroups: ['all'],
  },
  phase4: {
    startDate: '2024-02-22',
    percentage: 100,
    regions: ['all'],
    userGroups: ['all'],
  },
};
```

### Feature Flag Implementation

```dart
// lib/core/services/feature_flag_service.dart
class FeatureFlagService {
  static bool isJobSharingEnabled() {
    // Check remote config
    final remoteConfig = FirebaseRemoteConfig.instance;
    final enabled = remoteConfig.getBool('enable_job_sharing');
    
    // Check user percentage
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userHash = userId.hashCode;
    final percentage = remoteConfig.getInt('job_sharing_rollout_percentage');
    
    return enabled && (userHash % 100) < percentage;
  }
  
  static bool isQuickSignupEnabled() {
    return FirebaseRemoteConfig.instance.getBool('enable_quick_signup');
  }
  
  static bool isCrewManagementEnabled() {
    return FirebaseRemoteConfig.instance.getBool('enable_crew_management');
  }
}

// Usage in UI
if (FeatureFlagService.isJobSharingEnabled()) {
  return ShareButton(job: job);
} else {
  return SizedBox.shrink();
}
```

---

## 📊 Monitoring & Analytics

### Key Metrics Dashboard

```javascript
// monitoring/dashboard.js
const SHARE_METRICS = {
  // Real-time metrics
  activeShares: {
    query: 'SELECT COUNT(*) FROM shares WHERE created_at > NOW() - INTERVAL 1 HOUR',
    threshold: { warning: 100, critical: 500 },
  },
  
  // Conversion funnel
  shareConversionFunnel: {
    steps: [
      { name: 'Share Initiated', event: 'share_initiated' },
      { name: 'Recipients Selected', event: 'recipients_selected' },
      { name: 'Share Sent', event: 'share_sent' },
      { name: 'Share Viewed', event: 'share_viewed' },
      { name: 'Signup Started', event: 'signup_started' },
      { name: 'Signup Completed', event: 'signup_completed' },
      { name: 'Job Applied', event: 'job_applied' },
    ],
  },
  
  // Performance metrics
  shareLatency: {
    p50: { threshold: 100, unit: 'ms' },
    p95: { threshold: 200, unit: 'ms' },
    p99: { threshold: 500, unit: 'ms' },
  },
  
  // Error rates
  errorRates: {
    emailFailure: { threshold: 0.01 }, // 1%
    notificationFailure: { threshold: 0.02 }, // 2%
    shareCreationFailure: { threshold: 0.005 }, // 0.5%
  },
};
```

### Monitoring Setup

#### Sentry Configuration

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.environment = const String.fromEnvironment('ENVIRONMENT');
      options.tracesSampleRate = 0.1; // 10% of transactions
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
      
      // Custom tags
      options.beforeSend = (event, hint) {
        event.tags?.addAll({
          'feature': 'job_sharing',
          'version': '1.0.0',
        });
        return event;
      };
    },
    appRunner: () => runApp(MyApp()),
  );
}

// Track custom events
void trackShareError(dynamic error, StackTrace? stackTrace) {
  Sentry.captureException(
    error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('error_type', 'share_failure');
      scope.setLevel(SentryLevel.error);
      scope.setContext('share_data', {
        'recipients_count': recipientCount,
        'job_id': jobId,
      });
    },
  );
}
```

#### Firebase Performance Monitoring

```dart
// lib/core/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Future<T> trackOperation<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    
    try {
      final result = await operation();
      
      // Add metrics
      trace.putAttribute('success', 'true');
      trace.incrementMetric('completed', 1);
      
      return result;
    } catch (e) {
      trace.putAttribute('success', 'false');
      trace.putAttribute('error', e.toString());
      trace.incrementMetric('failed', 1);
      rethrow;
    } finally {
      await trace.stop();
    }
  }
  
  // Track share operation
  static Future<void> trackShare(int recipientCount) async {
    await trackOperation('share_job', () async {
      final trace = _performance.newTrace('share_job_detailed');
      trace.putAttribute('recipient_count', recipientCount.toString());
      trace.start();
      
      // Your share logic here
      
      trace.stop();
    });
  }
}
```

#### Custom Analytics Events

```dart
// lib/core/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AnalyticsService {
  static final FirebaseAnalytics _firebase = FirebaseAnalytics.instance;
  static Mixpanel? _mixpanel;
  
  static Future<void> initialize() async {
    _mixpanel = await Mixpanel.init(
      const String.fromEnvironment('MIXPANEL_TOKEN'),
      trackAutomaticEvents: true,
    );
  }
  
  static Future<void> trackShareMetrics({
    required String event,
    required Map<String, dynamic> properties,
  }) async {
    // Firebase Analytics
    await _firebase.logEvent(
      name: event,
      parameters: properties,
    );
    
    // Mixpanel
    _mixpanel?.track(event, properties: properties);
    
    // Custom backend analytics
    await _sendToBackend(event, properties);
  }
  
  static Future<void> _sendToBackend(
    String event,
    Map<String, dynamic> properties,
  ) async {
    try {
      await http.post(
        Uri.parse('https://api.journeymanjobs.com/analytics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': event,
          'properties': properties,
          'timestamp': DateTime.now().toIso8601String(),
          'userId': FirebaseAuth.instance.currentUser?.uid,
        }),
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }
}
```

---

## 🔴 Rollback Plan

### Automatic Rollback Triggers

```yaml
# monitoring/rollback-config.yaml
rollback_triggers:
  - metric: error_rate
    threshold: 5%
    duration: 5m
    action: immediate_rollback
    
  - metric: crash_rate
    threshold: 2%
    duration: 10m
    action: immediate_rollback
    
  - metric: share_success_rate
    threshold: 80%
    duration: 15m
    action: alert_then_rollback
    
  - metric: api_latency_p99
    threshold: 2000ms
    duration: 10m
    action: alert_then_rollback
```

### Manual Rollback Procedure

```bash
#!/bin/bash
# scripts/rollback.sh

echo "🔴 Starting Rollback Procedure"
echo "==============================="

# 1. Disable feature flags
echo "Disabling feature flags..."
firebase remoteconfig:set enable_job_sharing false --project prod
firebase remoteconfig:publish --project prod

# 2. Revert Cloud Functions
echo "Rolling back Cloud Functions..."
firebase functions:delete sendJobShareEmail --project prod
gcloud functions deploy sendJobShareEmail \
  --source=./functions-backup \
  --project=journeyman-jobs-prod

# 3. Restore previous app version
echo "Triggering app store rollback..."
# iOS
fastlane ios rollback_to_previous_version
# Android
./gradlew promoteReleaseRollback

# 4. Clear problematic data
echo "Cleaning up data..."
node scripts/cleanup-shares.js --after="2024-02-01"

# 5. Notify team
echo "Sending notifications..."
curl -X POST https://hooks.slack.com/services/XXX \
  -H 'Content-Type: application/json' \
  -d '{"text":"⚠️ Job Sharing feature rolled back. Check logs for details."}'

echo "✅ Rollback completed"
```

---

## 📱 App Store Deployment

### Google Play Console

```dart
Preparation:
☐ App signing configured
☐ Store listing updated
☐ Screenshots prepared (6.5", 5.5", tablet)
☐ Feature graphic created (1024x500)
☐ Privacy policy updated
☐ Content rating questionnaire completed

Release:
☐ Upload signed AAB file
☐ Add release notes
☐ Select rollout percentage (10% → 50% → 100%)
☐ Set up staged rollout
☐ Configure release testing
☐ Submit for review

Post-Release:
☐ Monitor crash reports
☐ Check user reviews
☐ Respond to feedback
☐ Track install metrics
```

### Apple App Store Connect

```dart
Preparation:
☐ Certificates & provisioning profiles valid
☐ App Store listing updated
☐ Screenshots prepared (6.5", 5.5", iPad)
☐ App preview video (optional)
☐ Privacy policy URL
☐ Age rating set

TestFlight:
☐ Upload build via Xcode
☐ Add external testers
☐ Send beta invitations
☐ Collect feedback (2 weeks)
☐ Fix critical issues

Release:
☐ Submit for App Review
☐ Provide review notes
☐ Demo account credentials
☐ Explain feature usage
☐ Wait for approval (24-48h)
☐ Release manually or automatically

Post-Release:
☐ Monitor App Analytics
☐ Check crash reports
☐ Respond to reviews
☐ Track conversion rates
```

---

## 🎯 Success Criteria

### Launch Day Metrics

```javascript
const LAUNCH_SUCCESS_CRITERIA = {
  technical: {
    crashRate: '< 0.5%',
    errorRate: '< 1%',
    apiLatency: '< 200ms p95',
    uptime: '> 99.9%',
  },
  
  business: {
    shareAdoption: '> 10% DAU',
    conversionRate: '> 30%',
    viralCoefficient: '> 1.2',
    userSatisfaction: '> 4.0/5.0',
  },
  
  operational: {
    supportTickets: '< 50/day',
    rollbacksNeeded: 0,
    hotfixesRequired: '< 2',
    teamAlerts: '< 5/day',
  },
};
```

### Week 1 Targets

```dart
Adoption:
☐ 1,000+ shares created
☐ 500+ unique sharers
☐ 2,000+ recipients reached
☐ 300+ new signups from shares

Quality:
☐ < 1% error rate maintained
☐ < 200ms p95 latency
☐ 0 critical bugs
☐ 4.5+ app store rating maintained

Growth:
☐ 20% of job views include share action
☐ 40% of recipients open share
☐ 30% of non-users sign up
☐ 50% of signups apply to job
```

---

## 🔔 Alert Configuration

### PagerDuty Alerts

```yaml
# monitoring/pagerduty.yaml
services:
  - name: job-sharing-critical
    escalation_policy: oncall-primary
    alerts:
      - name: share-api-down
        condition: "uptime < 95% for 5 minutes"
        severity: critical
        
      - name: high-error-rate
        condition: "error_rate > 5% for 10 minutes"
        severity: critical
        
      - name: database-connection-failure
        condition: "firestore_errors > 10 per minute"
        severity: critical

  - name: job-sharing-warning
    escalation_policy: oncall-secondary
    alerts:
      - name: slow-api-response
        condition: "p95_latency > 500ms for 15 minutes"
        severity: warning
        
      - name: low-conversion-rate
        condition: "signup_rate < 20% for 1 hour"
        severity: warning
```

### Slack Notifications

```javascript
// monitoring/slack-alerts.js
const alerts = {
  channels: {
    critical: '#alerts-critical',
    warnings: '#alerts-warning',
    metrics: '#metrics-daily',
  },
  
  templates: {
    shareSuccess: {
      text: '✅ Job Sharing Milestone',
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*${count}* jobs shared today!\n*Conversion:* ${rate}%`,
          },
        },
      ],
    },
    
    errorAlert: {
      text: '🚨 Job Sharing Error Spike',
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `Error rate: *${rate}%*\nAffected users: *${count}*`,
          },
        },
        {
          type: 'actions',
          elements: [
            {
              type: 'button',
              text: { type: 'plain_text', text: 'View Logs' },
              url: 'https://console.firebase.google.com/logs',
            },
            {
              type: 'button',
              text: { type: 'plain_text', text: 'Rollback' },
              style: 'danger',
              action_id: 'rollback_feature',
            },
          ],
        },
      ],
    },
  },
};
```

---

## 📈 Post-Launch Optimization

### A/B Testing Framework

```dart
// lib/core/services/ab_testing_service.dart
class ABTestingService {
  static String getShareButtonVariant() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final testGroup = userId.hashCode % 3;
    
    switch (testGroup) {
      case 0:
        return 'control'; // Original design
      case 1:
        return 'variant_a'; // Prominent button
      case 2:
        return 'variant_b'; // Floating action button
      default:
        return 'control';
    }
  }
  
  static void trackVariantPerformance(String variant, String event) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_event',
      parameters: {
        'test_name': 'share_button_placement',
        'variant': variant,
        'event': event,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

---

## ✅ Final Launch Checklist

```dart
T-7 Days:
☐ Final code freeze
☐ Complete QA testing
☐ Load testing completed
☐ Security audit passed
☐ Documentation updated

T-3 Days:
☐ Production environment ready
☐ Monitoring configured
☐ Team training completed
☐ Support docs prepared
☐ Rollback plan tested

T-1 Day:
☐ Final deployment to production
☐ Feature flags set to 0%
☐ Alerts configured
☐ Team on standby
☐ Communication sent

Launch Day:
☐ Enable feature flag (10%)
☐ Monitor metrics closely
☐ Check error rates
☐ Verify email delivery
☐ Test share flow

T+1 Day:
☐ Review metrics
☐ Address any issues
☐ Increase rollout (25%)
☐ Gather feedback
☐ Plan improvements

T+7 Days:
☐ Full rollout (100%)
☐ Success metrics review
☐ Team retrospective
☐ Plan next features
☐ Celebrate! 🎉
```

---

## 🎉 Launch Communication

### Internal Announcement

```dart
Subject: 🚀 Job Sharing Feature - Launch Today!

Team,

We're excited to announce the launch of our Job Sharing feature!

**What's New:**
- Users can share jobs via email, SMS, and in-app
- Non-users get quick 2-minute signup
- Crew management for group applications
- Real-time notifications

**Rollout Plan:**
- 10% of users (today)
- 25% of users (Day 3)
- 50% of users (Week 1)
- 100% of users (Week 2)

**Monitoring:**
- Dashboard: [link]
- Alerts: #job-sharing-alerts
- Support: #job-sharing-support

Let's make this launch a success!
```

---

*This completes the comprehensive production deployment guide for the job sharing feature.*
