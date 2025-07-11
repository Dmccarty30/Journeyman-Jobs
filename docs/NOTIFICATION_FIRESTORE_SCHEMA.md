# Notification System Firestore Schema

This document outlines the Firestore collections and document structures required for the complete notification system in the Journeyman Jobs app.

## Collections

### 1. `users` Collection
User documents with notification preferences and targeting data.

```typescript
{
  // Existing user fields...
  
  // FCM Token Management
  fcmToken: string,                    // Current FCM token
  tokenUpdatedAt: timestamp,           // When token was last updated
  
  // Notification Preferences
  jobAlertsEnabled: boolean,           // Job alert notifications
  safetyAlertsEnabled: boolean,        // Safety notifications
  unionUpdatesEnabled: boolean,        // Union local updates
  applicationUpdatesEnabled: boolean,  // Job application status
  systemNotificationsEnabled: boolean, // App updates/announcements
  stormWorkEnabled: boolean,           // Storm work alerts
  
  // Reminder Preferences
  jobRemindersEnabled: boolean,        // Application deadline reminders
  unionRemindersEnabled: boolean,      // Union meeting reminders
  safetyRemindersEnabled: boolean,     // Safety training reminders
  
  // Sound & Vibration
  soundEnabled: boolean,               // Notification sounds
  vibrationEnabled: boolean,           // Notification vibration
  
  // Quiet Hours
  quietHoursEnabled: boolean,          // Enable quiet hours
  quietHoursStart: number,             // Start hour (0-23)
  quietHoursEnd: number,               // End hour (0-23)
  
  // Targeting Data for Job Matching
  classifications: string[],           // IBEW classifications
  preferredLocations: string[],        // Preferred work locations
  unionLocal: string,                  // Union local number
  minHourlyRate: number,              // Minimum acceptable wage
  location: string,                    // Current location for storm work
}
```

### 2. `notifications` Collection
In-app notifications displayed in the notifications screen.

```typescript
{
  userId: string,                      // Target user ID
  title: string,                       // Notification title
  message: string,                     // Notification message
  type: string,                        // 'jobs', 'safety', 'union', 'applications', 'system', 'storm'
  isRead: boolean,                     // Read status
  timestamp: timestamp,                // When notification was created
  data: {                             // Additional data for navigation/context
    jobId?: string,
    company?: string,
    location?: string,
    isStormWork?: string,
    severity?: string,                 // For safety alerts: 'low', 'medium', 'high', 'critical'
    unionLocal?: string,
    meetingDate?: string,
    actionUrl?: string,                // Deep link for notification tap
  },
  messageId?: string,                  // FCM message ID (if from push notification)
}
```

### 3. `job_alerts` Collection
Tracks job alert history and prevents duplicate notifications.

```typescript
{
  jobId: string,                       // Reference to job
  userId: string,                      // User who received alert
  sentAt: timestamp,                   // When alert was sent
  type: string,                        // 'regular' or 'storm'
  notificationId?: string,             // Reference to notification document
}
```

### 4. `safety_alerts` Collection
Safety alerts that can be targeted by union local or location.

```typescript
{
  title: string,                       // Alert title
  message: string,                     // Alert message
  severity: string,                    // 'low', 'medium', 'high', 'critical'
  createdAt: timestamp,                // When alert was created
  expiresAt?: timestamp,               // When alert expires (optional)
  targetUnionLocals: string[],         // Target union locals (empty = all)
  targetLocations: string[],           // Target locations (empty = all)
  createdBy: string,                   // Admin user who created alert
  isActive: boolean,                   // Whether alert is active
}
```

### 5. `union_updates` Collection
Updates and announcements from union locals.

```typescript
{
  unionLocal: string,                  // Union local number
  title: string,                       // Update title
  message: string,                     // Update message
  createdAt: timestamp,                // When update was created
  meetingDate?: timestamp,             // If this is a meeting notification
  meetingLocation?: string,            // Meeting location
  priority: string,                    // 'low', 'medium', 'high'
  createdBy: string,                   // Admin user who created update
  isActive: boolean,                   // Whether update is active
}
```

### 6. `storm_events` Collection
Active storm events for targeting storm work notifications.

```typescript
{
  name: string,                        // Storm name/identifier
  affectedAreas: string[],             // Affected locations
  startDate: timestamp,                // When storm started
  estimatedEndDate?: timestamp,        // Estimated restoration completion
  priority: string,                    // 'medium', 'high', 'critical'
  description: string,                 // Storm description
  isActive: boolean,                   // Whether storm is active
  createdBy: string,                   // Admin user who created event
}
```

### 7. `notification_templates` Collection
Reusable notification templates for common scenarios.

```typescript
{
  name: string,                        // Template name
  type: string,                        // Notification type
  title: string,                       // Template title (supports variables)
  message: string,                     // Template message (supports variables)
  variables: string[],                 // Available variables for substitution
  isActive: boolean,                   // Whether template is active
  createdBy: string,                   // Admin user who created template
  createdAt: timestamp,                // When template was created
}
```

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own notification preferences
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read their own notifications
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
                  request.auth.uid == resource.data.userId;
      allow write: if request.auth != null && 
                   request.auth.uid == resource.data.userId &&
                   // Only allow updating isRead field
                   request.resource.data.diff(resource.data).affectedKeys()
                   .hasOnly(['isRead']);
    }
    
    // Job alerts are read-only for users
    match /job_alerts/{alertId} {
      allow read: if request.auth != null && 
                  request.auth.uid == resource.data.userId;
    }
    
    // Safety alerts are read-only for users
    match /safety_alerts/{alertId} {
      allow read: if request.auth != null;
    }
    
    // Union updates are read-only for users
    match /union_updates/{updateId} {
      allow read: if request.auth != null;
    }
    
    // Storm events are read-only for users
    match /storm_events/{eventId} {
      allow read: if request.auth != null;
    }
    
    // Notification templates are read-only for users
    match /notification_templates/{templateId} {
      allow read: if request.auth != null;
    }
  }
}
```

## Indexes

The following composite indexes should be created in Firestore:

### notifications
- Collection: `notifications`
- Fields: `userId` Ascending, `timestamp` Descending
- Query scope: Collection

- Collection: `notifications`  
- Fields: `userId` Ascending, `type` Ascending, `timestamp` Descending
- Query scope: Collection

- Collection: `notifications`
- Fields: `userId` Ascending, `isRead` Ascending, `timestamp` Descending  
- Query scope: Collection

### job_alerts
- Collection: `job_alerts`
- Fields: `userId` Ascending, `sentAt` Descending
- Query scope: Collection

- Collection: `job_alerts`
- Fields: `jobId` Ascending, `userId` Ascending
- Query scope: Collection

### safety_alerts
- Collection: `safety_alerts`
- Fields: `isActive` Ascending, `createdAt` Descending
- Query scope: Collection

- Collection: `safety_alerts`
- Fields: `targetUnionLocals` Array, `isActive` Ascending
- Query scope: Collection

### union_updates
- Collection: `union_updates`
- Fields: `unionLocal` Ascending, `createdAt` Descending
- Query scope: Collection

- Collection: `union_updates`
- Fields: `isActive` Ascending, `createdAt` Descending
- Query scope: Collection

## Implementation Notes

1. **FCM Token Management**: Tokens should be updated whenever the app starts and when the token refreshes.

2. **Notification Deduplication**: Use `job_alerts` collection to prevent sending duplicate job notifications to the same user.

3. **Quiet Hours**: Local notifications should check user preferences before scheduling.

4. **Storm Work Priority**: Storm work notifications should bypass normal job matching criteria and target qualified users based on classification and location.

5. **Safety Alert Severity**: Critical safety alerts should use the highest priority notification settings and bypass quiet hours.

6. **Batch Operations**: When sending notifications to multiple users, use Firestore batch operations for efficiency.

7. **Cleanup**: Implement periodic cleanup of old notifications and expired alerts to maintain performance.