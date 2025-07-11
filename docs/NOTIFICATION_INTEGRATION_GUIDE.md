# Notification System Integration Guide

This guide explains how to integrate the complete notification system into your Journeyman Jobs Flutter app.

## 1. Main App Integration

### Update `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_manager.dart';
import 'services/fcm_service.dart';

// Add background message handler at top level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Journeyman Jobs',
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Initialize notification system after app context is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationManager.initialize(context);
        });
        
        return child!;
      },
    );
  }
}
```

### Update `pubspec.yaml` Dependencies

The required dependencies have already been added:

```yaml
dependencies:
  # Firebase & Notifications
  firebase_messaging: ^15.1.4
  flutter_local_notifications: ^18.0.1
  permission_handler: ^12.0.2
```

## 2. Authentication Integration

### Update User Sign-In Flow

```dart
// In your auth service or sign-in screen
import '../services/notification_manager.dart';

class AuthService {
  Future<void> signInUser() async {
    // ... existing sign-in logic
    
    // After successful sign-in, request notification permissions
    if (mounted) {
      await NotificationManager.requestPermissions(context);
    }
  }
}
```

### Update User Profile Setup

```dart
// When user completes profile setup
class ProfileSetupService {
  Future<void> completeProfileSetup({
    required List<String> classifications,
    required List<String> preferredLocations,
    required String unionLocal,
    double? minHourlyRate,
  }) async {
    // Save profile data to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'classifications': classifications,
      'preferredLocations': preferredLocations,
      'unionLocal': unionLocal,
      'minHourlyRate': minHourlyRate,
      'profileCompleted': true,
    });
    
    // Subscribe to relevant notification topics
    await NotificationManager.subscribeToTopics(
      jobAlerts: true,
      safetyAlerts: true,
      unionLocal: unionLocal,
    );
  }
}
```

## 3. Job Service Integration

### Sending Job Alerts

```dart
import '../services/enhanced_notification_service.dart';

class JobService {
  Future<void> createNewJob(JobModel job) async {
    // Save job to database
    await _saveJobToFirestore(job);
    
    // Send notifications to matching users
    await EnhancedNotificationService.sendJobAlert(
      job: job,
      isStormWork: job.isStormWork ?? false,
    );
    
    // If storm work, send priority alerts
    if (job.isStormWork == true) {
      await EnhancedNotificationService.sendStormWorkAlert(
        stormJob: job,
        affectedArea: job.location,
        priority: 'high',
      );
    }
  }
}
```

### Job Application Reminders

```dart
class JobApplicationService {
  Future<void> applyToJob({
    required String jobId,
    required String jobTitle,
    required String company,
    required DateTime applicationDeadline,
  }) async {
    // Save application
    await _saveApplicationToFirestore();
    
    // Schedule deadline reminder
    await NotificationManager.scheduleJobDeadlineReminder(
      jobId: jobId,
      jobTitle: jobTitle,
      company: company,
      deadline: applicationDeadline,
      hoursBeforeDeadline: 24,
    );
  }
  
  Future<void> updateApplicationStatus({
    required String userId,
    required String jobTitle,
    required String company,
    required String status,
  }) async {
    // Update status in database
    await _updateApplicationStatus();
    
    // Send notification to user
    await NotificationManager.sendApplicationUpdate(
      userId: userId,
      jobTitle: jobTitle,
      company: company,
      status: status,
    );
  }
}
```

## 4. Union Service Integration

### Union Meeting Notifications

```dart
class UnionService {
  Future<void> scheduleUnionMeeting({
    required String unionLocal,
    required String meetingTitle,
    required DateTime meetingDateTime,
    required String location,
  }) async {
    // Save meeting to database
    await _saveMeetingToFirestore();
    
    // Send notification to union members
    await NotificationManager.sendUnionUpdate(
      unionLocal: unionLocal,
      title: 'Upcoming Meeting',
      message: '$meetingTitle at $location',
      meetingDate: meetingDateTime.toIso8601String(),
      actionUrl: '/locals',
    );
    
    // Schedule reminder for all members
    final members = await _getUnionMembers(unionLocal);
    for (final member in members) {
      await NotificationManager.scheduleUnionMeetingReminder(
        meetingId: '${unionLocal}_${meetingDateTime.millisecondsSinceEpoch}',
        meetingTitle: meetingTitle,
        localNumber: unionLocal,
        meetingTime: meetingDateTime,
      );
    }
  }
}
```

### Safety Alerts

```dart
class SafetyService {
  Future<void> sendSafetyAlert({
    required String title,
    required String message,
    required String severity,
    String? targetUnionLocal,
    String? targetLocation,
  }) async {
    // Save alert to database
    await _saveSafetyAlert();
    
    // Send notification
    await NotificationManager.sendSafetyAlert(
      title: title,
      message: message,
      severity: severity,
      unionLocal: targetUnionLocal,
      location: targetLocation,
    );
  }
}
```

## 5. Settings Integration

The notification settings screen is already integrated into the settings navigation. Users can access it via:

**Settings → App → Notifications**

## 6. Background Processing

### Set up Cloud Functions (Optional)

For production apps, consider setting up Firebase Cloud Functions to handle:

1. **Job Matching & Notifications**: When new jobs are added, automatically match and notify users
2. **Bulk Notifications**: Send notifications to large groups efficiently
3. **Cleanup**: Remove old notifications and manage data retention

Example Cloud Function:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.sendJobNotifications = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snap, context) => {
    const job = snap.data();
    
    // Find matching users
    const users = await findMatchingUsers(job);
    
    // Send notifications
    const notifications = users.map(user => ({
      token: user.fcmToken,
      notification: {
        title: 'New Job Match',
        body: `${job.title} at ${job.company}`,
      },
      data: {
        type: 'jobs',
        jobId: context.params.jobId,
      },
    }));
    
    await admin.messaging().sendAll(notifications);
  });
```

## 7. Testing

### Run Widget Tests

```bash
flutter test test/screens/settings/notification_settings_screen_test.dart
flutter test test/services/notification_permission_service_test.dart
```

### Manual Testing Checklist

1. **Permission Flow**:
   - [ ] New user sees permission request at appropriate time
   - [ ] Denied permissions show settings redirect dialog
   - [ ] Granted permissions enable all notification features

2. **Notification Settings**:
   - [ ] All toggles work correctly
   - [ ] Quiet hours time pickers function
   - [ ] Settings persist across app restarts

3. **Notifications**:
   - [ ] In-app notifications appear in notifications screen
   - [ ] Push notifications work when app is closed
   - [ ] Notification taps navigate to correct screens
   - [ ] Local notifications respect quiet hours

4. **Job Matching**:
   - [ ] Job alerts only sent to matching users
   - [ ] Storm work bypasses normal matching
   - [ ] Application reminders schedule correctly

## 8. Deployment Considerations

### Android

1. **Ensure Google Services**: The `google-services.json` file is properly configured
2. **Test on Real Device**: Notifications behave differently on emulators
3. **Battery Optimization**: Some devices may restrict background notifications

### iOS

1. **APNs Configuration**: Ensure Apple Push Notification service is configured in Firebase
2. **Test on Real Device**: iOS simulator doesn't support push notifications
3. **Background App Refresh**: Users may need to enable this for the app

### Production

1. **Rate Limiting**: Implement rate limiting to prevent notification spam
2. **User Feedback**: Monitor user feedback and unsubscribe rates
3. **Analytics**: Track notification delivery and engagement rates

## 9. Troubleshooting

### Common Issues

1. **Notifications Not Received**:
   - Check FCM token is being saved to Firestore
   - Verify Firebase project configuration
   - Ensure app has notification permissions

2. **Permission Denied**:
   - Guide users to device settings
   - Provide clear instructions for re-enabling

3. **Local Notifications Not Showing**:
   - Check quiet hours settings
   - Verify notification channels (Android)
   - Ensure app has notification permissions

### Debug Tools

```dart
// Add debug logging
void debugNotificationStatus() async {
  final hasPermissions = await NotificationPermissionService.areNotificationsEnabled();
  final pendingCount = await NotificationManager.getPendingNotificationCount();
  final fcmToken = await FCMService.getToken();
  
  debugPrint('Notifications enabled: $hasPermissions');
  debugPrint('Pending notifications: $pendingCount');
  debugPrint('FCM Token: ${fcmToken?.substring(0, 20)}...');
}
```

## 10. Future Enhancements

Consider these features for future versions:

1. **Rich Notifications**: Images, actions, and interactive elements
2. **Geofencing**: Location-based job alerts
3. **Machine Learning**: Improved job matching algorithms
4. **Analytics**: Detailed notification performance metrics
5. **A/B Testing**: Test different notification strategies

This completes the integration of the comprehensive notification system for your Journeyman Jobs app!