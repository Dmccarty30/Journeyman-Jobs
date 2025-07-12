import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fcm_service.dart';
import 'local_notification_service.dart';
import 'notification_permission_service.dart';
import 'enhanced_notification_service.dart';

/// Main notification manager that coordinates all notification services
/// This serves as the single entry point for notification functionality
class NotificationManager {
  static bool _isInitialized = false;
  static BuildContext? _appContext;

  /// Initialize the complete notification system
  /// Should be called in main.dart after Firebase initialization
  static Future<void> initialize(BuildContext appContext) async {
    if (_isInitialized) return;
    
    _appContext = appContext;
    
    try {
      debugPrint('Initializing Notification Manager...');
      
      // Initialize local notifications first
      await LocalNotificationService.initialize();
      debugPrint('✓ Local Notification Service initialized');
      
      // Initialize FCM service
      await FCMService.initialize(appContext);
      debugPrint('✓ FCM Service initialized');

      // Check and request permissions if needed
      if (appContext.mounted) {
        await _handleInitialPermissions(appContext);
      }
      
      _isInitialized = true;
      debugPrint('✓ Notification Manager fully initialized');
      
    } catch (e) {
      debugPrint('Error initializing Notification Manager: $e');
      // Don't throw - app should continue to work without notifications
    }
  }

  /// Handle initial permission setup
  static Future<void> _handleInitialPermissions(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check if user has granted permissions before
      final hasPermissions = await NotificationPermissionService.areNotificationsEnabled();
      
      if (!hasPermissions) {
        // Show permission request on next app launch or appropriate time
        // Don't show immediately to avoid overwhelming new users
        debugPrint('Notifications not enabled - will request when appropriate');
      } else {
        debugPrint('Notifications already enabled');
      }
    } catch (e) {
      debugPrint('Error handling initial permissions: $e');
    }
  }

  /// Request notification permissions with context about benefits
  static Future<bool> requestPermissions(BuildContext context) async {
    try {
      return await NotificationPermissionService.handleInitialPermissionFlow(context);
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Send a job alert notification
  static Future<void> sendJobAlert({
    required String jobId,
    required String jobTitle,
    required String company,
    required String location,
    double? hourlyRate,
    List<String>? classifications,
    bool isStormWork = false,
  }) async {
    try {
      // This would typically be called from a job service when new jobs are posted
      debugPrint('Job alert requested for: $jobTitle at $company');
      
      // In a real implementation, you'd create a JobModel and call:
      // await EnhancedNotificationService.sendJobAlert(job: jobModel, isStormWork: isStormWork);
      
    } catch (e) {
      debugPrint('Error sending job alert: $e');
    }
  }

  /// Send a safety alert to targeted users
  static Future<void> sendSafetyAlert({
    required String title,
    required String message,
    String? unionLocal,
    String? location,
    String severity = 'medium',
  }) async {
    try {
      await EnhancedNotificationService.sendSafetyAlert(
        title: title,
        message: message,
        unionLocal: unionLocal,
        location: location,
        severity: severity,
      );
    } catch (e) {
      debugPrint('Error sending safety alert: $e');
    }
  }

  /// Send a union update notification
  static Future<void> sendUnionUpdate({
    required String unionLocal,
    required String title,
    required String message,
    String? meetingDate,
    String? actionUrl,
  }) async {
    try {
      await EnhancedNotificationService.sendUnionUpdate(
        unionLocal: unionLocal,
        title: title,
        message: message,
        meetingDate: meetingDate,
        actionUrl: actionUrl,
      );
    } catch (e) {
      debugPrint('Error sending union update: $e');
    }
  }

  /// Send application status update
  static Future<void> sendApplicationUpdate({
    required String userId,
    required String jobTitle,
    required String company,
    required String status,
    String? nextSteps,
  }) async {
    try {
      await EnhancedNotificationService.sendApplicationUpdate(
        userId: userId,
        jobTitle: jobTitle,
        company: company,
        status: status,
        nextSteps: nextSteps,
      );
    } catch (e) {
      debugPrint('Error sending application update: $e');
    }
  }

  /// Schedule a job application deadline reminder
  static Future<void> scheduleJobDeadlineReminder({
    required String jobId,
    required String jobTitle,
    required String company,
    required DateTime deadline,
    int hoursBeforeDeadline = 24,
  }) async {
    try {
      await LocalNotificationService.scheduleJobDeadlineReminder(
        jobId: jobId,
        jobTitle: jobTitle,
        company: company,
        deadline: deadline,
        hoursBeforeDeadline: hoursBeforeDeadline,
      );
    } catch (e) {
      debugPrint('Error scheduling job deadline reminder: $e');
    }
  }

  /// Schedule a union meeting reminder
  static Future<void> scheduleUnionMeetingReminder({
    required String meetingId,
    required String meetingTitle,
    required String localNumber,
    required DateTime meetingTime,
    int hoursBeforeMeeting = 2,
  }) async {
    try {
      await LocalNotificationService.scheduleUnionMeetingReminder(
        meetingId: meetingId,
        meetingTitle: meetingTitle,
        localNumber: localNumber,
        meetingTime: meetingTime,
        hoursBeforeMeeting: hoursBeforeMeeting,
      );
    } catch (e) {
      debugPrint('Error scheduling union meeting reminder: $e');
    }
  }

  /// Schedule a safety training reminder
  static Future<void> scheduleSafetyTrainingReminder({
    required String trainingId,
    required String trainingName,
    required DateTime expiryDate,
    int daysBeforeExpiry = 30,
  }) async {
    try {
      await LocalNotificationService.scheduleSafetyTrainingReminder(
        trainingId: trainingId,
        trainingName: trainingName,
        expiryDate: expiryDate,
        daysBeforeExpiry: daysBeforeExpiry,
      );
    } catch (e) {
      debugPrint('Error scheduling safety training reminder: $e');
    }
  }

  /// Subscribe to notification topics
  static Future<void> subscribeToTopics({
    bool jobAlerts = false,
    bool safetyAlerts = false,
    bool stormAlerts = false,
    String? unionLocal,
  }) async {
    try {
      if (jobAlerts) {
        await FCMService.subscribeToTopic('job_alerts');
      }
      
      if (safetyAlerts) {
        await FCMService.subscribeToTopic('safety_alerts');
      }
      
      if (stormAlerts) {
        await FCMService.subscribeToTopic('storm_alerts');
      }
      
      if (unionLocal != null) {
        await FCMService.subscribeToTopic('union_$unionLocal');
      }
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  /// Unsubscribe from notification topics
  static Future<void> unsubscribeFromTopics({
    bool jobAlerts = false,
    bool safetyAlerts = false,
    bool stormAlerts = false,
    String? unionLocal,
  }) async {
    try {
      if (jobAlerts) {
        await FCMService.unsubscribeFromTopic('job_alerts');
      }
      
      if (safetyAlerts) {
        await FCMService.unsubscribeFromTopic('safety_alerts');
      }
      
      if (stormAlerts) {
        await FCMService.unsubscribeFromTopic('storm_alerts');
      }
      
      if (unionLocal != null) {
        await FCMService.unsubscribeFromTopic('union_$unionLocal');
      }
    } catch (e) {
      debugPrint('Error unsubscribing from topics: $e');
    }
  }

  /// Cancel a specific scheduled notification
  static Future<void> cancelScheduledNotification(int notificationId) async {
    try {
      await LocalNotificationService.cancelNotification(notificationId);
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllScheduledNotifications() async {
    try {
      await LocalNotificationService.cancelAllNotifications();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Get pending scheduled notifications
  static Future<int> getPendingNotificationCount() async {
    try {
      final pending = await LocalNotificationService.getPendingNotifications();
      return pending.length;
    } catch (e) {
      debugPrint('Error getting pending notification count: $e');
      return 0;
    }
  }

  /// Clear app badge count (iOS)
  static Future<void> clearBadge() async {
    try {
      await FCMService.clearBadge();
    } catch (e) {
      debugPrint('Error clearing badge: $e');
    }
  }

  /// Check if notifications are properly initialized
  static bool get isInitialized => _isInitialized;

  /// Get app context (for testing or debugging)
  static BuildContext? get appContext => _appContext;
}