import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

/// Production Firebase Cloud Messaging service
/// Handles push notifications, topic subscriptions, and message routing
class FCMService {
  static FCMService? _instance;
  static FCMService get instance => _instance ??= FCMService._internal();
  
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  StreamController<RemoteMessage>? _messageController;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundSubscription;

  /// Initialize FCM service with production configuration
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Configure FCM
      await _configureFCM();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Get and store FCM token
      await _initializeToken();
      
      // Subscribe to default topics
      await _subscribeToDefaultTopics();
      
      print('FCM Service initialized successfully');
    } catch (e) {
      print('Error initializing FCM Service: $e');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      // Request iOS permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('iOS permission granted: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // Request Android permissions (API 33+)
      final permission = await Permission.notification.request();
      print('Android notification permission: $permission');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Configure FCM settings
  Future<void> _configureFCM() async {
    // Set foreground notification presentation options for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Enable auto-init (production setting)
    await _messaging.setAutoInitEnabled(true);
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    _messageController = StreamController<RemoteMessage>.broadcast();

    // Handle messages when app is in foreground
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      print('Received foreground message: ${message.notification?.title}');
      _handleForegroundMessage(message);
      _messageController?.add(message);
    });

    // Handle messages when app is opened from background
    _backgroundSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('App opened from background message: ${message.notification?.title}');
      _handleMessageClick(message);
    });

    // Handle initial message if app was opened from terminated state
    _handleInitialMessage();
  }

  /// Handle messages when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    
    if (notification != null) {
      // Show local notification
      await _showLocalNotification(
        title: notification.title ?? 'Journeyman Jobs',
        body: notification.body ?? '',
        data: data,
      );
    }

    // Track analytics
    await _trackNotificationReceived(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Parse payload and navigate to appropriate screen
    _handleNotificationNavigation(response.payload);
  }

  /// Handle message click (from background/terminated)
  void _handleMessageClick(RemoteMessage message) {
    final data = message.data;
    _handleNotificationNavigation(data.toString());
  }

  /// Handle initial message (app opened from terminated state)
  void _handleInitialMessage() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        _handleMessageClick(message);
      }
    });
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(String? payload) {
    if (payload == null) return;
    
    try {
      // Parse payload and extract navigation data
      // This would integrate with your app's routing system
      print('Navigating based on payload: $payload');
    } catch (e) {
      print('Error handling notification navigation: $e');
    }
  }

  /// Initialize and store FCM token
  Future<void> _initializeToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      print('FCM Token: $_fcmToken');
      
      if (_fcmToken != null) {
        await _storeFCMToken(_fcmToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _storeFCMToken(newToken);
      });
    } catch (e) {
      print('Error initializing FCM token: $e');
    }
  }

  /// Store FCM token in Firestore for the current user
  Future<void> _storeFCMToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmTokens': FieldValue.arrayUnion([{
            'token': token,
            'platform': Platform.operatingSystem,
            'lastUpdated': FieldValue.serverTimestamp(),
          }])
        });
      }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  /// Subscribe to default topics
  Future<void> _subscribeToDefaultTopics() async {
    try {
      // Subscribe to general notifications
      await _messaging.subscribeToTopic('general_notifications');
      
      // Subscribe to platform-specific topics
      await _messaging.subscribeToTopic('${Platform.operatingSystem}_users');
      
      print('Subscribed to default FCM topics');
    } catch (e) {
      print('Error subscribing to FCM topics: $e');
    }
  }

  /// Subscribe to IBEW local-specific topics
  Future<void> subscribeToLocalTopic(String localNumber) async {
    try {
      final topic = 'local_$localNumber';
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to local topic: $e');
    }
  }

  /// Track notification analytics
  Future<void> _trackNotificationReceived(RemoteMessage message) async {
    try {
      if (!FirebaseConfig.analyticsConfig.enabled) return;

      await FirebaseFirestore.instance
          .collection('analytics')
          .add({
        'event': 'notification_received',
        'messageId': message.messageId,
        'messageType': message.data['type'],
        'platform': Platform.operatingSystem,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error tracking notification analytics: $e');
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Get message stream for listening to incoming messages
  Stream<RemoteMessage>? get messageStream => _messageController?.stream;

  /// Dispose resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();
    _messageController?.close();
  }
}