# Crew Notifications Implementation - Firebase Cloud Functions

Firebase Cloud Functions implementation for enhanced crew notification triggers with FCM (Firebase Cloud Messaging) push notifications for the Journeyman Jobs IBEW platform.

## 🎯 Overview

This implementation provides comprehensive crew notification functionality with:
- Enhanced FCM push notifications for crew activities
- Reliable retry logic and error handling
- IBEW-specific storm work prioritization
- Crew invitation email integration
- Analytics and logging for notification delivery

## 🚀 Implemented Functions

### Core Crew Notification Triggers

#### 1. `onJobSharedToCrewEnhanced`
**Trigger**: Firestore document created at `crews/{crewId}/jobNotifications/{notificationId}`

**Features**:
- Enhanced FCM notifications with retry logic
- Storm work prioritization (high priority notifications)
- Rich notification data with job details
- Activity logging and analytics tracking
- Error handling with status updates

**Notification Data**:
```javascript
{
  type: 'crew_job_share',
  crewId: string,
  crewName: string,
  jobId: string,
  sharedByUserId: string,
  isStormWork: 'true' | 'false',
  isUrgent: 'true' | 'false'
}
```

#### 2. `onCrewMemberAddedEnhanced`
**Trigger**: Firestore document created at `crews/{crewId}/members/{userId}`

**Features**:
- Welcome notification to new member
- Notification to existing crew members
- Automatic FCM topic subscription for crew
- Crew member count tracking
- User membership list updates

**Notification Data**:
```javascript
{
  type: 'member_joined',
  crewId: string,
  crewName: string,
  newMemberId: string,
  newMemberRole: string
}
```

#### 3. `onCrewMessageSentEnhanced`
**Trigger**: Firestore document created at `crews/{crewId}/communications/{messageId}`

**Features**:
- Smart notification filtering (urgent/announcements only)
- User mention support
- Priority-based notification delivery
- Activity logging for important messages
- Crew last activity tracking

**Notification Data**:
```javascript
{
  type: 'crew_message' | 'crew_mention',
  crewId: string,
  messageId: string,
  senderId: string,
  messageType: 'urgent' | 'announcement' | 'mention'
}
```

### Enhanced Notification Infrastructure

#### 4. `sendCrewNotificationWithRetry`
**Purpose**: Robust FCM notification delivery with retry logic

**Features**:
- Multicast messaging for performance
- Exponential backoff retry strategy
- Invalid token cleanup
- Delivery statistics tracking
- Platform-specific notification customization

#### 5. `updateFCMToken`
**HTTP Callable Function**: Update user's FCM token and crew subscriptions

**Usage**:
```javascript
const updateFCMToken = functions.httpsCallable('updateFCMToken');
await updateFCMToken({ fcmToken: 'new_token' });
```

#### 6. `sendEmergencyStormAlert`
**HTTP Callable Function**: Send emergency storm work alerts

**Features**:
- IBEW-specific storm work targeting
- High-priority notification delivery
- Geographic targeting by affected states
- Classification-based filtering

### Supporting Functions

#### 7. `sendCrewInvitationEmail`
**Purpose**: Email invitations for crew membership

**Features**:
- Professional IBEW-themed email templates
- Existing user vs. new user handling
- Deep linking for invitation acceptance
- SendGrid integration

#### 8. `cleanupInvalidFCMTokens`
**Scheduled Function**: Weekly cleanup of invalid FCM tokens

**Features**:
- Dry-run token validation
- Automatic invalid token removal
- Batch processing for efficiency

## 📱 FCM Integration Details

### Notification Channels

Configure these channels in your Flutter app:

```dart
// Android notification channels
static const List<AndroidNotificationChannel> channels = [
  AndroidNotificationChannel(
    'crew_notifications',
    'Crew Notifications',
    description: 'Notifications from your IBEW crews',
    importance: Importance.high,
  ),
  AndroidNotificationChannel(
    'storm_alerts',
    'Storm Work Alerts',
    description: 'Emergency storm restoration work alerts',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('storm_alert'),
  ),
  AndroidNotificationChannel(
    'emergency_alerts',
    'Emergency Alerts',
    description: 'Critical emergency notifications',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('emergency_alert'),
  ),
];
```

### Topic Subscriptions

Users are automatically subscribed to:
- `crew_{crewId}` - Specific crew notifications
- `general_notifications` - App-wide notifications
- `storm_alerts` - Storm work alerts (if enabled)

### Notification Handling

```dart
// Handle notification when app is in foreground
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final data = message.data;
  
  switch (data['type']) {
    case 'crew_job_share':
      _handleCrewJobShare(data);
      break;
    case 'crew_message':
      _handleCrewMessage(data);
      break;
    case 'member_joined':
      _handleMemberJoined(data);
      break;
  }
});

// Handle notification when app is opened from notification
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  _navigateFromNotification(message.data);
});
```

## 🔧 Configuration Required

### 1. Firebase Configuration

Ensure these environment variables are set:

```bash
firebase functions:config:set sendgrid.key="your_sendgrid_api_key"
firebase functions:config:set twilio.account_sid="your_twilio_sid"  # Optional
firebase functions:config:set twilio.auth_token="your_twilio_token"  # Optional
firebase functions:config:set twilio.phone_number="your_twilio_number"  # Optional
```

### 2. Firestore Security Rules

Add these rules for crew notifications:

```javascript
// Firestore security rules
match /crews/{crewId} {
  allow read, write: if request.auth != null && 
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
  
  match /jobNotifications/{notificationId} {
    allow create: if request.auth != null && 
      exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
    allow read: if request.auth != null && 
      exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
  }
  
  match /communications/{messageId} {
    allow create: if request.auth != null && 
      exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
    allow read: if request.auth != null && 
      exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
  }
}
```

### 3. FCM Service Account

Ensure your Firebase project has FCM enabled and the service account has proper permissions.

## 📊 Analytics & Monitoring

### Logging Collections

The functions create these Firestore collections for monitoring:

- `crews/{crewId}/notifications` - Notification delivery logs
- `notificationLogs` - Individual notification attempts
- `analytics/jobSharing/events` - Job sharing analytics
- `analytics/conversions/events` - User conversion tracking

### Dashboard Function

Use `getAnalyticsDashboard` to retrieve analytics:

```javascript
const getDashboard = functions.httpsCallable('getAnalyticsDashboard');
const dashboard = await getDashboard({ period: '7_days' });
```

## 🚨 Error Handling

### Automatic Error Recovery

1. **Invalid FCM Tokens**: Automatically removed from user documents
2. **Network Failures**: Exponential backoff retry (up to 3 attempts)
3. **Malformed Data**: Logged with error details for debugging
4. **Missing Documents**: Graceful handling with informative logging

### Monitoring Alerts

Set up Cloud Monitoring alerts for:
- High notification failure rates (>10%)
- Function execution errors
- FCM token cleanup frequency
- Emergency alert delivery success

## 🔄 Deployment

Use the provided deployment script:

```bash
cd functions
./deploy-crew-notifications.sh
```

Or deploy manually:

```bash
firebase deploy --only functions:onJobSharedToCrewEnhanced,functions:onCrewMemberAddedEnhanced,functions:onCrewMessageSentEnhanced,functions:updateFCMToken
```

## 🧪 Testing

### Test Crew Job Share

```javascript
// Create a test job notification
await db.collection('crews/test-crew/jobNotifications').add({
  jobId: 'test-job-id',
  sharedByUserId: 'test-user-id',
  message: 'Check out this storm work opportunity!',
  timestamp: admin.firestore.FieldValue.serverTimestamp()
});
```

### Test Member Addition

```javascript
// Add a test crew member
await db.collection('crews/test-crew/members').doc('new-user-id').set({
  role: 'member',
  joinedAt: admin.firestore.FieldValue.serverTimestamp(),
  notificationPrefs: { jobShares: true, directMessages: true }
});
```

### Test FCM Token Update

```javascript
const updateToken = functions.httpsCallable('updateFCMToken');
await updateToken({ fcmToken: 'test_fcm_token_here' });
```

## 📚 Related Documentation

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/rules-structure)
- [SendGrid Email API](https://docs.sendgrid.com/api-reference/mail-send/mail-send)
- [IBEW Classification Standards](./docs/ibew-classifications.md)

## 🐛 Troubleshooting

### Common Issues

1. **Notifications not received**:
   - Check FCM token is valid and updated
   - Verify user is subscribed to crew topic
   - Check notification channel configuration

2. **High failure rates**:
   - Monitor invalid token cleanup
   - Check network connectivity
   - Verify Firestore permissions

3. **Email invitations not sending**:
   - Verify SendGrid API key configuration
   - Check email template rendering
   - Monitor SendGrid delivery logs

### Debug Mode

Enable debug logging by setting environment variable:

```bash
firebase functions:config:set debug.enabled=true
```

This enables verbose logging for all notification functions.
