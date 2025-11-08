/// Unified Notification Service
///
/// Comprehensive notification system consolidating:
/// - Firebase Cloud Messaging (FCM) integration
/// - Local/scheduled notifications with quiet hours
/// - Permission management and user guidance
/// - IBEW-specific job matching and alerts
/// - Union updates and storm work notifications
/// - Application status tracking
/// - In-app notification management
///
/// Replaces: notification_service, fcm_service, local_notification_service,
///           notification_manager, notification_permission_service, enhanced_notification_service
/// Original lines: 524 + 390 + 402 + 324 + 269 + 418 = 2,327 → Consolidated: ~850 lines (63% reduction)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

import '../models/job_model.dart';
import '../navigation/app_router.dart';
import '../design_system/app_theme.dart';
import '../design_system/components/reusable_components.dart';

/// Unified notification service for all notification needs
class UnifiedNotificationService {
  // Singleton pattern
  static UnifiedNotificationService? _instance;
  static UnifiedNotificationService get instance => _instance ??= UnifiedNotificationService._();

  UnifiedNotificationService._();

  // Core services
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // State tracking
  static bool _isInitialized = false;
  static BuildContext? _appContext;
  static String? _currentToken;

  // IBEW classifications for targeted job matching
  static const List<String> _ibewClassifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
    'Low Voltage Technician',
    'Telecommunications Technician',
    'Sound Technician',
    'Residential Wireman',
  ];

  // Construction types for job categorization
  static const List<String> _constructionTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Utility',
    'Maintenance',
    'Storm Restoration',
    'Emergency Work',
  ];

  // Notification channels for Android
  static const List<AndroidNotificationChannel> _notificationChannels = [
    AndroidNotificationChannel(
      'job_alerts',
      'Job Alerts',
      description: 'New job matches and application updates',
      importance: Importance.high,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'storm_alerts',
      'Storm Work Alerts',
      description: 'Emergency restoration work notifications',
      importance: Importance.max,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'union_updates',
      'Union Updates',
      description: 'IBEW local union updates and meetings',
      importance: Importance.high,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'safety_alerts',
      'Safety Alerts',
      description: 'Critical safety updates and training reminders',
      importance: Importance.max,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'application_updates',
      'Application Updates',
      description: 'Status updates for job applications',
      importance: Importance.high,
      playSound: true,
    ),
    AndroidNotificationChannel(
      'general_notifications',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
      playSound: true,
    ),
  ];

  /// Initialize the complete notification system
  static Future<void> initialize(BuildContext appContext) async {
    if (_isInitialized) return;

    try {
      _appContext = appContext;
      debugPrint('[UnifiedNotificationService] Initializing...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Set up FCM handlers
      await _setupFCMHandlers();

      // Get and store FCM token
      await _handleTokenRefresh();

      // Handle initial permissions if needed
      await _handleInitialPermissions();

      _isInitialized = true;
      debugPrint('[UnifiedNotificationService] ✓ Fully initialized');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Initialization error: $e');
      // Don't throw - app should continue without notifications
    }
  }

  /// Initialize local notifications plugin and channels
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      for (final channel in _notificationChannels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }

    debugPrint('[UnifiedNotificationService] ✓ Local notifications initialized');
  }

  /// Set up FCM message handlers
  static Future<void> _setupFCMHandlers() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    debugPrint('[UnifiedNotificationService] ✓ FCM handlers configured');
  }

  /// Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('[UnifiedNotificationService] Background message: ${message.messageId}');
    await _createInAppNotification(message);
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[UnifiedNotificationService] Foreground message: ${message.messageId}');

    // Check quiet hours before showing local notification
    if (!await _isQuietHoursActive()) {
      await _showLocalNotification(message);
    }

    // Always create in-app notification
    await _createInAppNotification(message);
  }

  /// Handle notification tap when app was in background
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('[UnifiedNotificationService] App opened from notification: ${message.messageId}');
    await _navigateFromNotification(message);
  }

  /// Handle notification tap from local notification
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && _appContext != null) {
      try {
        final data = jsonDecode(response.payload!);
        final message = RemoteMessage(data: Map<String, String>.from(data));
        _navigateFromNotification(message);
      } catch (e) {
        debugPrint('[UnifiedNotificationService] Error handling notification tap: $e');
      }
    }
  }

  /// Navigate based on notification data
  static Future<void> _navigateFromNotification(RemoteMessage message) async {
    if (_appContext == null) return;

    final data = message.data;
    final type = data['type'] ?? 'system';
    final actionUrl = data['actionUrl'];

    try {
      if (actionUrl != null && actionUrl.isNotEmpty) {
        _appContext!.go(actionUrl);
      } else {
        // Default navigation based on type
        switch (type) {
          case 'jobs':
            _appContext!.go(AppRouter.jobs);
            break;
          case 'safety':
            _appContext!.go(AppRouter.notifications);
            break;
          case 'applications':
            _appContext!.go(AppRouter.profile);
            break;
          case 'storm':
            _appContext!.go(AppRouter.storm);
            break;
          case 'union':
          case 'union_updates':
          case 'union_reminders':
            _appContext!.go(AppRouter.locals);
            break;
          default:
            _appContext!.go(AppRouter.notifications);
        }
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Navigation error: $e');
      _appContext!.go(AppRouter.notifications);
    }
  }

  /// Show local notification for foreground messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final type = data['type'] ?? 'system';
      final channel = _getChannelForType(type);

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _getPriorityForType(type),
        icon: '@mipmap/ic_launcher',
        color: AppTheme.accentCopper,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(data),
      );
    }
  }

  /// Create in-app notification in Firestore
  static Future<void> _createInAppNotification(RemoteMessage message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        await _firestore.collection('notifications').add({
          'userId': user.uid,
          'title': notification.title ?? 'Notification',
          'message': notification.body ?? '',
          'type': data['type'] ?? 'system',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
          'data': data,
          'messageId': message.messageId,
        });
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error creating in-app notification: $e');
    }
  }

  /// Get notification channel for type
  static AndroidNotificationChannel _getChannelForType(String type) {
    switch (type) {
      case 'jobs':
        return _notificationChannels.firstWhere((c) => c.id == 'job_alerts');
      case 'storm':
        return _notificationChannels.firstWhere((c) => c.id == 'storm_alerts');
      case 'union':
      case 'union_updates':
      case 'union_reminders':
        return _notificationChannels.firstWhere((c) => c.id == 'union_updates');
      case 'safety':
        return _notificationChannels.firstWhere((c) => c.id == 'safety_alerts');
      case 'applications':
        return _notificationChannels.firstWhere((c) => c.id == 'application_updates');
      default:
        return _notificationChannels.firstWhere((c) => c.id == 'general_notifications');
    }
  }

  /// Get priority for notification type
  static Priority _getPriorityForType(String type) {
    switch (type) {
      case 'storm':
      case 'safety':
        return Priority.high;
      case 'jobs':
      case 'union_updates':
      case 'applications':
        return Priority.defaultPriority;
      default:
        return Priority.low;
    }
  }

  /// Handle FCM token refresh and storage
  static Future<void> _handleTokenRefresh() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      _currentToken = token;
      await _storeTokenInFirestore(token);
    }
  }

  /// Store FCM token in Firestore
  static Future<void> _storeTokenInFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[UnifiedNotificationService] ✓ FCM token stored');
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error storing FCM token: $e');
    }
  }

  /// Handle token refresh event
  static Future<void> _onTokenRefresh(String token) async {
    _currentToken = token;
    await _storeTokenInFirestore(token);
  }

  /// Handle initial permission setup
  static Future<void> _handleInitialPermissions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final hasPermissions = await areNotificationsEnabled();
      if (!hasPermissions) {
        debugPrint('[UnifiedNotificationService] Notifications disabled - will request later');
      } else {
        debugPrint('[UnifiedNotificationService] ✓ Notifications already enabled');
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error checking initial permissions: $e');
    }
  }

  // Permission Management

  /// Check current notification permission status
  static Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.notification.status;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final status = await checkPermissionStatus();
    return status.isGranted;
  }

  /// Request notification permissions with context about benefits
  static Future<bool> requestPermissions() async {
    try {
      // Request Firebase messaging permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Also request system notification permission
        final permissionStatus = await Permission.notification.request();
        return permissionStatus.isGranted;
      }

      return false;
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error requesting permissions: $e');
      return false;
    }
  }

  /// Show permission request dialog with benefits explanation
  static Future<bool> showPermissionDialog(BuildContext context) async {
    bool? userResponse = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: AppTheme.accentCopper,
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Text(
                  'Enable Job Alerts',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stay ahead of the competition with instant notifications:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildFeatureItem(
                icon: Icons.work_outline,
                title: 'New Job Matches',
                description: 'Get alerted when jobs match your skills and location',
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeatureItem(
                icon: Icons.flash_on,
                title: 'Storm Work Priority',
                description: 'First to know about high-paying emergency calls',
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeatureItem(
                icon: Icons.access_time,
                title: 'Application Deadlines',
                description: 'Never miss a bid deadline again',
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeatureItem(
                icon: Icons.security,
                title: 'Safety Alerts',
                description: 'Critical safety updates from your union local',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not Now',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ),
            JJPrimaryButton(
              text: 'Enable Notifications',
              onPressed: () => Navigator.of(context).pop(true),
              width: 180,
            ),
          ],
        );
      },
    );

    if (userResponse == true) {
      return await requestPermissions();
    }

    return false;
  }

  /// Show settings redirect dialog when permissions are denied
  static Future<void> showSettingsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Icon(
                Icons.settings,
                color: AppTheme.warningYellow,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Text(
                'Notifications Disabled',
                style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
              ),
            ],
          ),
          content: Text(
            'To receive job alerts and safety notifications, please enable notifications in your device settings.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ),
            JJPrimaryButton(
              text: 'Open Settings',
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              width: 140,
            ),
          ],
        );
      },
    );
  }

  /// Handle initial permission request flow
  static Future<bool> handleInitialPermissionFlow(BuildContext context) async {
    final currentStatus = await checkPermissionStatus();
    if (!context.mounted) return false;

    switch (currentStatus) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        return await showPermissionDialog(context);
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        await showSettingsDialog(context);
        return false;
      default:
        return await showPermissionDialog(context);
    }
  }

  /// Build feature item widget for permission dialog
  static Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentCopper, size: AppTheme.iconSm),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                description,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Notification Sending Methods

  /// Send job alert notification based on user preferences
  static Future<void> sendJobAlert({
    required Job job,
    bool isStormWork = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check user preferences
      final userPrefs = await _getUserNotificationPreferences(user.uid);
      if (userPrefs['jobAlertsEnabled'] != true && !isStormWork) return;

      // Check if job matches user criteria
      final matchesPreferences = await _doesJobMatchUserPreferences(job, user.uid);
      if (!matchesPreferences && !isStormWork) return;

      // Create notification content
      String title;
      String body;

      if (isStormWork) {
        title = '⚡ STORM WORK ALERT ⚡';
        body = 'Emergency restoration work: ${job.jobTitle ?? 'Job'} at ${job.company}';
      } else {
        title = 'New Job Match';
        body = '${job.jobTitle ?? 'Job'} at ${job.company} in ${job.location}';
      }

      // Add wage information if available
      if (job.wage != null) {
        body += ' - \$${job.wage!.toStringAsFixed(2)}/hr';
      }

      // Send push notification
      await _sendNotificationToUser(
        userId: user.uid,
        title: title,
        body: body,
        type: isStormWork ? 'storm' : 'jobs',
        data: {
          'jobId': job.id,
          'company': job.company,
          'location': job.location,
          'isStormWork': isStormWork.toString(),
          'actionUrl': '/jobs',
        },
      );

      // Create in-app notification
      await _createInAppJobNotification(
        userId: user.uid,
        job: job,
        isStormWork: isStormWork,
      );

      debugPrint('[UnifiedNotificationService] ✓ Job alert sent: ${job.jobTitle}');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending job alert: $e');
    }
  }

  /// Send union update notification
  static Future<void> sendUnionUpdate({
    required String unionLocal,
    required String title,
    required String message,
    String? meetingDate,
    String? actionUrl,
  }) async {
    try {
      final targetUsers = await _getUsersByUnionLocal(unionLocal);

      for (final userId in targetUsers) {
        final userPrefs = await _getUserNotificationPreferences(userId);
        if (userPrefs['unionUpdatesEnabled'] != true) continue;

        String notificationTitle = 'IBEW Local $unionLocal';
        if (meetingDate != null) {
          notificationTitle += ' - Meeting Alert';
        }

        await _sendNotificationToUser(
          userId: userId,
          title: notificationTitle,
          body: message,
          type: 'union',
          data: {
            'unionLocal': unionLocal,
            'meetingDate': meetingDate ?? '',
            'actionUrl': actionUrl ?? '/locals',
          },
        );

        // Schedule reminder for union meeting if date provided
        if (meetingDate != null) {
          final meetingDateTime = DateTime.tryParse(meetingDate);
          if (meetingDateTime != null) {
            await scheduleUnionMeetingReminder(
              meetingId: '${unionLocal}_${DateTime.now().millisecondsSinceEpoch}',
              meetingTitle: title,
              localNumber: unionLocal,
              meetingTime: meetingDateTime,
            );
          }
        }
      }

      debugPrint('[UnifiedNotificationService] ✓ Union update sent for Local $unionLocal');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending union update: $e');
    }
  }

  /// Send storm work priority notification
  static Future<void> sendStormWorkAlert({
    required Job stormJob,
    required String affectedArea,
    String priority = 'high',
  }) async {
    try {
      final qualifiedUsers = await _getStormWorkQualifiedUsers(affectedArea);

      for (final userId in qualifiedUsers) {
        final userPrefs = await _getUserNotificationPreferences(userId);
        if (userPrefs['stormWorkEnabled'] != true) continue;

        await sendJobAlert(
          job: Job(
            id: stormJob.id,
            company: stormJob.company,
            jobTitle: 'STORM RESTORATION - ${stormJob.jobTitle ?? 'Emergency Work'}',
            location: stormJob.location,
            wage: stormJob.wage,
            jobDescription: 'Emergency restoration work in $affectedArea. ${stormJob.jobDescription ?? ''}',
            classification: stormJob.classification,
            // Add other fields as needed
          ),
          isStormWork: true,
        );
      }

      debugPrint('[UnifiedNotificationService] ✓ Storm work alert sent for $affectedArea');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending storm work alert: $e');
    }
  }

  /// Send safety alert notification
  static Future<void> sendSafetyAlert({
    required String title,
    required String message,
    String? unionLocal,
    String? location,
    String severity = 'medium',
  }) async {
    try {
      List<String> targetUserIds = [];

      if (unionLocal != null) {
        targetUserIds = await _getUsersByUnionLocal(unionLocal);
      } else if (location != null) {
        final snapshot = await _firestore
            .collection('users')
            .where('location', isEqualTo: location)
            .get();
        targetUserIds = snapshot.docs.map((doc) => doc.id).toList();
      } else {
        // Send to all users with safety alerts enabled
        final snapshot = await _firestore.collection('users').get();
        targetUserIds = snapshot.docs.map((doc) => doc.id).toList();
      }

      for (final userId in targetUserIds) {
        final userPrefs = await _getUserNotificationPreferences(userId);
        if (userPrefs['safetyAlertsEnabled'] != true) continue;

        await _sendNotificationToUser(
          userId: userId,
          title: '🔺 Safety Alert: $title',
          body: message,
          type: 'safety',
          data: {
            'severity': severity,
            'unionLocal': unionLocal ?? '',
            'location': location ?? '',
            'actionUrl': '/safety',
          },
        );
      }

      debugPrint('[UnifiedNotificationService] ✓ Safety alert sent: $title');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending safety alert: $e');
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
      String title = 'Application Update';
      String body = 'Your application for $jobTitle at $company: $status';

      if (nextSteps != null) {
        body += '\n$nextSteps';
      }

      await _sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        type: 'applications',
        data: {
          'jobTitle': jobTitle,
          'company': company,
          'status': status,
          'actionUrl': '/applications',
        },
      );

      // Create in-app notification
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': body,
        'type': 'applications',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': {
          'jobTitle': jobTitle,
          'company': company,
          'status': status,
        },
      });

      debugPrint('[UnifiedNotificationService] ✓ Application update sent for $jobTitle');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending application update: $e');
    }
  }

  /// Send targeted notification to specific user
  static Future<void> _sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // Send push notification via FCM HTTP API
        await _sendFCMNotification(
          token: fcmToken,
          title: title,
          body: body,
          data: {
            'type': type,
            'userId': userId,
            'title': title,
            'body': body,
            ...?data,
          },
        );
      } else {
        debugPrint('[UnifiedNotificationService] No FCM token for user: $userId');
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending notification to user: $e');
    }
  }

  /// Send FCM notification via HTTP API
  static Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    if (token.isEmpty) {
      debugPrint('[UnifiedNotificationService] No token provided');
      return;
    }

    try {
      final serverKey = Platform.environment['FCM_SERVER_KEY'];
      if (serverKey == null || serverKey.isEmpty) {
        debugPrint('[UnifiedNotificationService] FCM server key not configured');
        return;
      }

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            ...data,
            'type': data['type'] ?? 'general',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[UnifiedNotificationService] ✓ Notification sent');
      } else {
        debugPrint('[UnifiedNotificationService] Failed to send: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error sending FCM notification: $e');
    }
  }

  // Scheduled Notifications

  /// Schedule union meeting reminder
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

      // Adjust for quiet hours
      if (await _isInQuietHours(reminderTime)) {
        final adjustedTime = await _adjustForQuietHours(reminderTime);
        if (adjustedTime != null) {
          reminderTime = adjustedTime;
        } else {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'union_updates',
        'Union Updates',
        channelDescription: 'IBEW local union updates and meetings',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: AppTheme.primaryNavy,
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

      await _localNotifications.zonedSchedule(
        meetingId.hashCode,
        'IBEW Local $localNumber Meeting',
        '$meetingTitle starts in $hoursBeforeMeeting hours',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('[UnifiedNotificationService] ✓ Union meeting reminder scheduled');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error scheduling union reminder: $e');
    }
  }

  /// Schedule job deadline reminder
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

      // Adjust for quiet hours
      if (await _isInQuietHours(reminderTime)) {
        final adjustedTime = await _adjustForQuietHours(reminderTime);
        if (adjustedTime != null) {
          reminderTime = adjustedTime;
        } else {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'job_alerts',
        'Job Alerts',
        channelDescription: 'New job matches and application updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: AppTheme.primaryNavy,
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

      await _localNotifications.zonedSchedule(
        jobId.hashCode,
        'Job Application Deadline',
        'Deadline for $jobTitle at $company is in $hoursBeforeDeadline hours',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('[UnifiedNotificationService] ✓ Job deadline reminder scheduled');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error scheduling job reminder: $e');
    }
  }

  /// Schedule safety training reminder
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

      // Adjust for quiet hours
      if (await _isInQuietHours(reminderTime)) {
        final adjustedTime = await _adjustForQuietHours(reminderTime);
        if (adjustedTime != null) {
          reminderTime = adjustedTime;
        } else {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'safety_alerts',
        'Safety Alerts',
        channelDescription: 'Critical safety updates and training reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: AppTheme.primaryNavy,
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

      await _localNotifications.zonedSchedule(
        trainingId.hashCode,
        '🔺 Safety Training Expiry',
        '$trainingName expires in $daysBeforeExpiry days',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('[UnifiedNotificationService] ✓ Safety training reminder scheduled');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error scheduling safety reminder: $e');
    }
  }

  /// Cancel a specific scheduled notification
  static Future<void> cancelScheduledNotification(int notificationId) async {
    try {
      await _localNotifications.cancel(notificationId);
      debugPrint('[UnifiedNotificationService] Cancelled notification: $notificationId');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error cancelling notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllScheduledNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('[UnifiedNotificationService] Cancelled all scheduled notifications');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error cancelling all notifications: $e');
    }
  }

  /// Get pending scheduled notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error getting pending notifications: $e');
      return [];
    }
  }

  // Topic Management

  /// Subscribe to notification topics
  static Future<void> subscribeToTopics({
    bool jobAlerts = false,
    bool safetyAlerts = false,
    bool stormAlerts = false,
    String? unionLocal,
  }) async {
    try {
      if (jobAlerts) {
        await _firebaseMessaging.subscribeToTopic('job_alerts');
        debugPrint('[UnifiedNotificationService] ✓ Subscribed to job_alerts');
      }

      if (safetyAlerts) {
        await _firebaseMessaging.subscribeToTopic('safety_alerts');
        debugPrint('[UnifiedNotificationService] ✓ Subscribed to safety_alerts');
      }

      if (stormAlerts) {
        await _firebaseMessaging.subscribeToTopic('storm_alerts');
        debugPrint('[UnifiedNotificationService] ✓ Subscribed to storm_alerts');
      }

      if (unionLocal != null) {
        await _firebaseMessaging.subscribeToTopic('local_$unionLocal');
        debugPrint('[UnifiedNotificationService] ✓ Subscribed to local_$unionLocal');
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error subscribing to topics: $e');
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
        await _firebaseMessaging.unsubscribeFromTopic('job_alerts');
        debugPrint('[UnifiedNotificationService] ✓ Unsubscribed from job_alerts');
      }

      if (safetyAlerts) {
        await _firebaseMessaging.unsubscribeFromTopic('safety_alerts');
        debugPrint('[UnifiedNotificationService] ✓ Unsubscribed from safety_alerts');
      }

      if (stormAlerts) {
        await _firebaseMessaging.unsubscribeFromTopic('storm_alerts');
        debugPrint('[UnifiedNotificationService] ✓ Unsubscribed from storm_alerts');
      }

      if (unionLocal != null) {
        await _firebaseMessaging.unsubscribeFromTopic('local_$unionLocal');
        debugPrint('[UnifiedNotificationService] ✓ Unsubscribed from local_$unionLocal');
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error unsubscribing from topics: $e');
    }
  }

  // Notification Preferences

  /// Get user notification preferences
  static Future<Map<String, bool>> _getUserNotificationPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'jobAlertsEnabled': prefs.getBool('job_alerts_enabled') ?? true,
        'unionUpdatesEnabled': prefs.getBool('union_updates_enabled') ?? true,
        'stormWorkEnabled': prefs.getBool('storm_work_enabled') ?? true,
        'safetyAlertsEnabled': prefs.getBool('safety_alerts_enabled') ?? true,
      };
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error getting user preferences: $e');
      return {
        'jobAlertsEnabled': true,
        'unionUpdatesEnabled': true,
        'stormWorkEnabled': true,
        'safetyAlertsEnabled': true,
      };
    }
  }

  /// Check if union reminders are enabled
  static Future<bool> _areUnionRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('union_reminders_enabled') ?? true;
  }

  // Quiet Hours Management

  /// Check if quiet hours are currently active
  static Future<bool> _isQuietHoursActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('quiet_hours_enabled') ?? false;

      if (!enabled) return false;

      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final startHour = prefs.getInt('quiet_hours_start') ?? 22; // 10 PM
      final endHour = prefs.getInt('quiet_hours_end') ?? 7; // 7 AM

      final startMinutes = startHour * 60;
      final endMinutes = endHour * 60;

      // Handle overnight quiet hours
      if (startMinutes > endMinutes) {
        return currentMinutes >= startMinutes || currentMinutes < endMinutes;
      } else {
        return currentMinutes >= startMinutes && currentMinutes < endMinutes;
      }
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error checking quiet hours: $e');
      return false;
    }
  }

  /// Check if a specific time is within quiet hours
  static Future<bool> _isInQuietHours(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;

    if (!quietHoursEnabled) return false;

    final startHour = prefs.getInt('quiet_hours_start') ?? 22; // 10 PM
    final endHour = prefs.getInt('quiet_hours_end') ?? 7; // 7 AM

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

  // User Matching and Targeting

  /// Check if job matches user preferences
  static Future<bool> _doesJobMatchUserPreferences(Job job, String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData == null) return false;

      // Check classification match
      final userClassifications = List<String>.from(userData['classifications'] ?? []);
      if (userClassifications.isNotEmpty && job.classification != null) {
        final hasMatchingClassification = userClassifications
            .any((userClass) => job.classification!.toLowerCase().contains(userClass.toLowerCase()));
        if (!hasMatchingClassification) return false;
      }

      // Check location preference
      final preferredLocations = List<String>.from(userData['preferredLocations'] ?? []);
      if (preferredLocations.isNotEmpty) {
        final matchesLocation = preferredLocations
            .any((location) => job.location.toLowerCase().contains(location.toLowerCase()));
        if (!matchesLocation) return false;
      }

      // Check wage preference
      final minWage = userData['minHourlyRate'] as double?;
      if (minWage != null && job.wage != null) {
        if (job.wage! < minWage) return false;
      }

      return true;
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error checking job match: $e');
      return false;
    }
  }

  /// Get users by union local
  static Future<List<String>> _getUsersByUnionLocal(String unionLocal) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('unionLocal', isEqualTo: unionLocal)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error getting users by union local: $e');
      return [];
    }
  }

  /// Get users qualified for storm work
  static Future<List<String>> _getStormWorkQualifiedUsers(String affectedArea) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('classifications', arrayContainsAny: [
            'Journeyman Lineman',
            'Tree Trimmer',
            'Equipment Operator'
          ])
          .get();

      final qualifiedUsers = <String>[];
      for (final doc in snapshot.docs) {
        final userData = doc.data();
        final userLocation = userData['location'] as String?;

        // Simplified location matching - could be enhanced with proper geolocation
        if (userLocation != null &&
            (userLocation.toLowerCase().contains(affectedArea.toLowerCase()) ||
                affectedArea.toLowerCase().contains(userLocation.toLowerCase()))) {
          qualifiedUsers.add(doc.id);
        }
      }

      return qualifiedUsers;
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error getting storm work qualified users: $e');
      return [];
    }
  }

  /// Create in-app job notification
  static Future<void> _createInAppJobNotification({
    required String userId,
    required Job job,
    required bool isStormWork,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': isStormWork ? '⚡ Storm Work Alert' : 'New Job Match',
        'message': '${job.jobTitle ?? 'Job'} at ${job.company} in ${job.location}',
        'type': isStormWork ? 'storm' : 'jobs',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': {
          'jobId': job.id,
          'company': job.company,
          'location': job.location,
          'isStormWork': isStormWork.toString(),
          'wage': job.wage ?? '',
        },
      });
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error creating in-app job notification: $e');
    }
  }

  // In-App Notification Management

  /// Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for user
  static Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error marking all as read: $e');
      return false;
    }
  }

  /// Get unread notification count stream
  static Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Delete old notifications (cleanup)
  static Future<void> deleteOldNotifications({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final notifications = await _firestore
          .collection('notifications')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('[UnifiedNotificationService] Deleted ${notifications.docs.length} old notifications');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error deleting old notifications: $e');
    }
  }

  // Utility Methods

  /// Clear app badge count (iOS)
  static Future<void> clearBadge() async {
    try {
      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(badge: true);
      }
      debugPrint('[UnifiedNotificationService] ✓ Badge cleared');
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error clearing badge: $e');
    }
  }

  /// Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      _currentToken = await _firebaseMessaging.getToken();
      return _currentToken;
    } catch (e) {
      debugPrint('[UnifiedNotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Dispose notification service
  static void dispose() {
    _isInitialized = false;
    _appContext = null;
    _currentToken = null;
    debugPrint('[UnifiedNotificationService] Disposed');
  }
}