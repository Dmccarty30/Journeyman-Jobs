import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification/notification_preferences_model.dart';
import 'fcm_service.dart';

/// Service to manage notification preferences, bindings, and delivery
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's notification preferences from Firestore
  static Future<NotificationPreferencesModel?> getPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final notificationData = data['notificationPreferences'] as Map<String, dynamic>? ?? {};
      
      return NotificationPreferencesModel.fromFirestore(notificationData);
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      return null;
    }
  }

  /// Update notification preferences in Firestore
  static Future<bool> updatePreferences(NotificationPreferencesModel preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update({
        'notificationPreferences': preferences.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
      return false;
    }
  }

  /// Enable/disable a specific notification type
  static Future<bool> toggleNotificationType(String type, bool enabled) async {
    try {
      // Update SharedPreferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${type}_enabled', enabled);

      // Update FCM topic subscription
      final topicName = _getTopicName(type);
      if (topicName != null) {
        if (enabled) {
          await FCMService.subscribeToTopic(topicName);
        } else {
          await FCMService.unsubscribeFromTopic(topicName);
        }
      }

      // Update Firestore
      final user = _auth.currentUser;
      if (user != null) {
        final fieldName = _getPreferenceFieldName(type);
        await _firestore.collection('users').doc(user.uid).update({
          'notificationPreferences.$fieldName': enabled,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error toggling notification type $type: $e');
      return false;
    }
  }

  /// Get FCM topic name for notification type
  static String? _getTopicName(String type) {
    switch (type) {
      case 'job_alerts':
        return 'job_alerts';
      case 'storm_work':
        return 'storm_alerts';
      case 'union_updates':
        return 'union_updates';
      case 'union_reminders':
        return 'union_reminders';
      case 'system_notifications':
        return 'system_updates';
      default:
        return null;
    }
  }

  /// Get Firestore field name for notification type
  static String _getPreferenceFieldName(String type) {
    switch (type) {
      case 'job_alerts':
        return 'jobAlertsEnabled';
      case 'storm_work':
        return 'stormWorkEnabled';
      case 'union_updates':
        return 'unionUpdatesEnabled';
      case 'union_reminders':
        return 'unionRemindersEnabled';
      case 'system_notifications':
        return 'systemNotificationsEnabled';
      default:
        return type;
    }
  }

  /// Subscribe to all enabled notification topics
  static Future<void> subscribeToEnabledTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check each notification type and subscribe if enabled
      final types = [
        'job_alerts',
        'storm_work',
        'union_updates',
        'union_reminders',
        'system_notifications',
      ];

      for (final type in types) {
        final enabled = prefs.getBool('${type}_enabled') ?? true;
        final topicName = _getTopicName(type);
        
        if (enabled && topicName != null) {
          await FCMService.subscribeToTopic(topicName);
        }
      }

      // Subscribe to user-specific topics
      final user = _auth.currentUser;
      if (user != null) {
        // Subscribe to user's union local if set
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final unionLocal = userDoc.data()?['unionLocal'] as String?;
        if (unionLocal != null) {
          await FCMService.subscribeToTopic('local_$unionLocal');
        }
      }
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  /// Create an in-app notification
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': data ?? {},
      });
    } catch (e) {
      debugPrint('Failed to create notification: $e');
    }
  }

  /// Create a job alert notification
  static Future<void> createJobAlert({
    required String userId,
    required String jobId,
    required String jobTitle,
    required String company,
    required String location,
    double? hourlyRate,
  }) async {
    await createNotification(
      userId: userId,
      type: 'jobs',
      title: 'New Job Match',
      message: '$jobTitle at $company in $location${hourlyRate != null ? ' - \$${hourlyRate.toStringAsFixed(2)}/hr' : ''}',
      data: {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'company': company,
        'location': location,
        'hourlyRate': hourlyRate,
      },
    );
  }

  /// Create a storm work alert
  static Future<void> createStormAlert({
    required String userId,
    required String stormName,
    required String location,
    required String urgency,
  }) async {
    await createNotification(
      userId: userId,
      type: 'storm',
      title: '⚡ Storm Work Alert',
      message: '$urgency: $stormName restoration work needed in $location',
      data: {
        'stormName': stormName,
        'location': location,
        'urgency': urgency,
      },
    );
  }

  /// Create a union update notification
  static Future<void> createUnionUpdate({
    required String userId,
    required String localNumber,
    required String title,
    required String message,
  }) async {
    await createNotification(
      userId: userId,
      type: 'union',
      title: title,
      message: message,
      data: {
        'localNumber': localNumber,
      },
    );
  }

  /// Create a union meeting reminder
  static Future<void> createUnionReminder({
    required String userId,
    required String localNumber,
    required DateTime meetingDate,
    required String location,
  }) async {
    final formattedDate = '${meetingDate.month}/${meetingDate.day} at ${meetingDate.hour % 12 == 0 ? 12 : meetingDate.hour % 12}:${meetingDate.minute.toString().padLeft(2, '0')} ${meetingDate.hour >= 12 ? 'PM' : 'AM'}';
    
    await createNotification(
      userId: userId,
      type: 'union_reminders',
      title: 'Union Meeting Reminder',
      message: 'IBEW Local $localNumber meeting on $formattedDate at $location',
      data: {
        'localNumber': localNumber,
        'meetingDate': meetingDate.toIso8601String(),
        'location': location,
      },
    );
  }

  /// Create an application status update
  static Future<void> createApplicationUpdate({
    required String userId,
    required String jobId,
    required String jobTitle,
    required String status,
  }) async {
    final statusEmoji = _getStatusEmoji(status);
    
    await createNotification(
      userId: userId,
      type: 'applications',
      title: '$statusEmoji Application Update',
      message: 'Your application for $jobTitle has been $status',
      data: {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'status': status,
      },
    );
  }

  static String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return '✅';
      case 'rejected':
      case 'declined':
        return '❌';
      case 'pending':
      case 'under review':
        return '⏳';
      default:
        return '📋';
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for a user
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
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Get unread notification count for a user
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
      debugPrint('Deleted ${notifications.docs.length} old notifications');
    } catch (e) {
      debugPrint('Error deleting old notifications: $e');
    }
  }

  /// Check if quiet hours are active
  static Future<bool> isQuietHoursActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('quiet_hours_enabled') ?? false;
      
      if (!enabled) return false;

      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;
      
      final startHour = prefs.getInt('quiet_hours_start') ?? 22;
      final endHour = prefs.getInt('quiet_hours_end') ?? 7;
      
      final startMinutes = startHour * 60;
      final endMinutes = endHour * 60;
      
      // Handle overnight quiet hours
      if (startMinutes > endMinutes) {
        return currentMinutes >= startMinutes || currentMinutes < endMinutes;
      } else {
        return currentMinutes >= startMinutes && currentMinutes < endMinutes;
      }
    } catch (e) {
      debugPrint('Error checking quiet hours: $e');
      return false;
    }
  }
}