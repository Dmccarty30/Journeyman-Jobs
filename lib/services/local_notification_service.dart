import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// A service for managing local and scheduled notifications on the device.
///
/// This service uses the `flutter_local_notifications` plugin to schedule
/// time-based alerts for various events like union meetings, job application
/// deadlines, and safety training expirations. It also handles notification
/// channels for Android and respects user-defined quiet hours.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static bool _isInitialized = false;

  /// Initializes the local notification service.
  ///
  /// This method sets up the notification plugin, creates Android notification
  /// channels, and configures handlers for notification taps. It should be
  /// called once at app startup.
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channels for Android
    await _createNotificationChannels();
    
    _isInitialized = true;
    debugPrint('Local Notification Service initialized');
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'job_reminders',
        'Job Application Reminders',
        description: 'Reminders for job application deadlines',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'union_meetings',
        'Union Meetings',
        description: 'Union meeting reminders and updates',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'safety_reminders',
        'Safety Reminders',
        description: 'Safety training and certification reminders',
        importance: Importance.max,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'general_reminders',
        'General Reminders',
        description: 'General app reminders',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    ];

    for (final channel in channels) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }


  /// Schedules a local notification to remind a user about an upcoming union meeting.
  ///
  /// The reminder is scheduled a specified number of hours before the meeting.
  /// It respects the user's quiet hour settings.
  ///
  /// - [meetingId]: A unique identifier for the meeting to use as the notification ID.
  /// - [meetingTitle]: The title or topic of the meeting.
  /// - [localNumber]: The IBEW local number (e.g., "124").
  /// - [meetingTime]: The `DateTime` of the meeting.
  /// - [hoursBeforeMeeting]: How many hours before the meeting to send the reminder.
  static Future<void> scheduleUnionMeetingReminder({
    required String meetingId,
    required String meetingTitle,
    required String localNumber,
    required DateTime meetingTime,
    int hoursBeforeMeeting = 2,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (!await _areUnionRemindersEnabled()) return;

      DateTime reminderTime = meetingTime.subtract(Duration(hours: hoursBeforeMeeting));
      
      if (reminderTime.isBefore(DateTime.now())) return;

      // Check quiet hours
      if (await _isInQuietHours(reminderTime)) {
        final adjustedTime = await _adjustForQuietHours(reminderTime);
        if (adjustedTime != null) {
          reminderTime = adjustedTime;
        } else {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'union_meetings',
        'Union Meetings',
        channelDescription: 'Union meeting reminders and updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1A202C), // AppTheme.primaryNavy
        ticker: 'Union meeting reminder',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'UNION_REMINDER',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payload = jsonEncode({
        'type': 'union_meeting',
        'meetingId': meetingId,
        'actionUrl': '/locals',
      });

      await _notifications.zonedSchedule(
        meetingId.hashCode,
        'IBEW Local $localNumber Meeting',
        '$meetingTitle starts in $hoursBeforeMeeting hours',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('Union meeting reminder scheduled');
    } catch (e) {
      debugPrint('Error scheduling union meeting reminder: $e');
    }
  }


  /// Cancels a single scheduled notification by its ID.
  ///
  /// - [id]: The integer ID of the notification to cancel.
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('Cancelled notification with id: $id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancels all pending scheduled notifications for the app.
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('Cancelled all scheduled notifications');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Retrieves a list of all notifications that are currently scheduled and pending.
  ///
  /// Returns a `Future<List<PendingNotificationRequest>>`.
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        // Handle navigation based on notification type
        _handleNotificationAction(data);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Handle notification action
  static void _handleNotificationAction(Map<String, dynamic> data) {
    // This would typically use a navigation service or router
    // For now, we'll just log the action
    debugPrint('Notification action: ${data['type']}');
  }

  /// Check if union reminders are enabled
  static Future<bool> _areUnionRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('union_reminders_enabled') ?? true;
  }

  /// Check if time is within quiet hours
  static Future<bool> _isInQuietHours(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
    
    if (!quietHoursEnabled) return false;
    
    final startHour = prefs.getInt('quiet_hours_start') ?? 22; // 10 PM
    final endHour = prefs.getInt('quiet_hours_end') ?? 7;     // 7 AM
    
    final hour = time.hour;
    
    if (startHour < endHour) {
      // Quiet hours within same day (e.g., 1 PM to 5 PM)
      return hour >= startHour && hour < endHour;
    } else {
      // Quiet hours across midnight (e.g., 10 PM to 7 AM)
      return hour >= startHour || hour < endHour;
    }
  }

  /// Adjust notification time to avoid quiet hours
  static Future<DateTime?> _adjustForQuietHours(DateTime originalTime) async {
    final prefs = await SharedPreferences.getInstance();
    final endHour = prefs.getInt('quiet_hours_end') ?? 7; // 7 AM
    
    // Schedule for the end of quiet hours
    final adjustedTime = DateTime(
      originalTime.year,
      originalTime.month,
      originalTime.day,
      endHour,
      0,
    );
    
    // If the adjusted time is still in the past, schedule for next day
    if (adjustedTime.isBefore(DateTime.now())) {
      return adjustedTime.add(const Duration(days: 1));
    }
    
    return adjustedTime;
  }
  
  /// Schedules a local reminder for a job application deadline.
  ///
  /// The reminder is scheduled a specified number of hours before the deadline.
  ///
  /// - [jobId]: A unique identifier for the job.
  /// - [jobTitle]: The title of the job.
  /// - [company]: The company offering the job.
  /// - [deadline]: The `DateTime` of the application deadline.
  /// - [hoursBeforeDeadline]: How many hours before the deadline to send the reminder.
  static Future<void> scheduleJobDeadlineReminder({
    required String jobId,
    required String jobTitle,
    required String company,
    required DateTime deadline,
    int hoursBeforeDeadline = 24,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      DateTime reminderTime = deadline.subtract(Duration(hours: hoursBeforeDeadline));
      
      if (reminderTime.isBefore(DateTime.now())) return;

      // Check quiet hours
      if (await _isInQuietHours(reminderTime)) {
        final adjustedTime = await _adjustForQuietHours(reminderTime);
        if (adjustedTime != null) {
          reminderTime = adjustedTime;
        } else {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'job_reminders',
        'Job Application Reminders',
        channelDescription: 'Reminders for job application deadlines',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1A202C),
        ticker: 'Job deadline reminder',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'JOB_REMINDER',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payload = jsonEncode({
        'type': 'job_deadline',
        'jobId': jobId,
        'actionUrl': '/jobs',
      });

      await _notifications.zonedSchedule(
        jobId.hashCode,
        'Job Application Deadline',
        'Deadline for $jobTitle at $company is in $hoursBeforeDeadline hours',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('Job deadline reminder scheduled');
    } catch (e) {
      debugPrint('Error scheduling job deadline reminder: $e');
    }
  }
  
  /// Schedules a reminder for an expiring safety training or certification.
  ///
  /// - [trainingId]: A unique identifier for the training.
  /// - [trainingName]: The name of the training or certification.
  /// - [expiryDate]: The `DateTime` when the training expires.
  /// - [daysBeforeExpiry]: How many days before expiry to send the reminder.
  static Future<void> scheduleSafetyTrainingReminder({
    required String trainingId,
    required String trainingName,
    required DateTime expiryDate,
    int daysBeforeExpiry = 30,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      DateTime reminderTime = expiryDate.subtract(Duration(days: daysBeforeExpiry));
      
      if (reminderTime.isBefore(DateTime.now())) return;

      // Check quiet hours
      if (await _isInQuietHours(reminderTime)) {
        final adjustedTime = await _adjustForQuietHours(reminderTime);
        if (adjustedTime != null) {
          reminderTime = adjustedTime;
        } else {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'safety_reminders',
        'Safety Reminders',
        channelDescription: 'Safety training and certification reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1A202C),
        ticker: 'Safety training reminder',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'SAFETY_REMINDER',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payload = jsonEncode({
        'type': 'safety_training',
        'trainingId': trainingId,
        'actionUrl': '/profile',
      });

      await _notifications.zonedSchedule(
        trainingId.hashCode,
        '🔺 Safety Training Expiry',
        '$trainingName expires in $daysBeforeExpiry days',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('Safety training reminder scheduled');
    } catch (e) {
      debugPrint('Error scheduling safety training reminder: $e');
    }
  }
}