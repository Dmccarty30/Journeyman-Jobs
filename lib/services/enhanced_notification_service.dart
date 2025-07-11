import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';
import 'fcm_service.dart';
import 'local_notification_service.dart';

/// Enhanced notification service specifically designed for IBEW electrical workers
class EnhancedNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// IBEW Classifications for job matching
  static const List<String> ibewClassifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
    'Low Voltage Technician',
    'Telecommunications Technician',
    'Sound Technician',
    'Residential Wireman',
  ];

  /// Construction types for job categorization
  static const List<String> constructionTypes = [
    'Commercial',
    'Industrial', 
    'Residential',
    'Utility',
    'Maintenance',
    'Storm Restoration',
    'Emergency Work',
  ];

  /// Send job alert notification based on user preferences
  static Future<void> sendJobAlert({
    required JobModel job,
    bool isStormWork = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user preferences
      final userPrefs = await _getUserNotificationPreferences(user.uid);
      if (!userPrefs['jobAlertsEnabled']) return;

      // Check if user matches job criteria
      final matchesPreferences = await _doesJobMatchUserPreferences(job, user.uid);
      if (!matchesPreferences && !isStormWork) return;

      // Create notification title based on job type
      String title;
      String body;
      
      if (isStormWork) {
        title = '⚡ STORM WORK ALERT ⚡';
        body = 'Emergency restoration work: ${job.title} at ${job.company}';
      } else {
        title = 'New Job Match';
        body = '${job.title} at ${job.company} in ${job.location}';
      }

      // Add wage information if available
      if (job.hourlyRate != null && job.hourlyRate! > 0) {
        body += ' - \$${job.hourlyRate!.toStringAsFixed(2)}/hr';
      }

      // Send push notification
      await FCMService.sendNotificationToUser(
        userId: user.uid,
        title: title,
        body: body,
        type: isStormWork ? 'storm' : 'jobs',
        additionalData: {
          'jobId': job.id ?? '',
          'company': job.company,
          'location': job.location,
          'isStormWork': isStormWork.toString(),
          'actionUrl': '/jobs',
        },
      );

      // Also create in-app notification
      await _createInAppJobNotification(
        userId: user.uid,
        job: job,
        isStormWork: isStormWork,
      );

      debugPrint('Job alert sent for ${job.title}');
    } catch (e) {
      debugPrint('Error sending job alert: $e');
    }
  }

  /// Send safety alert to users based on location or union local
  static Future<void> sendSafetyAlert({
    required String title,
    required String message,
    String? unionLocal,
    String? location,
    String severity = 'medium', // low, medium, high, critical
  }) async {
    try {
      // Get users who should receive this alert
      final targetUsers = await _getTargetUsersForSafetyAlert(
        unionLocal: unionLocal,
        location: location,
      );

      for (final userId in targetUsers) {
        final userPrefs = await _getUserNotificationPreferences(userId);
        if (!userPrefs['safetyAlertsEnabled']) continue;

        // Determine notification priority based on severity
        String notificationTitle;
        switch (severity) {
          case 'critical':
            notificationTitle = '🚨 CRITICAL SAFETY ALERT';
            break;
          case 'high':
            notificationTitle = '⚠️ HIGH PRIORITY SAFETY';
            break;
          case 'medium':
            notificationTitle = '⚠️ Safety Alert';
            break;
          default:
            notificationTitle = 'Safety Notice';
        }

        await FCMService.sendNotificationToUser(
          userId: userId,
          title: notificationTitle,
          body: message,
          type: 'safety',
          additionalData: {
            'severity': severity,
            'unionLocal': unionLocal ?? '',
            'location': location ?? '',
            'actionUrl': '/notifications',
          },
        );
      }

      debugPrint('Safety alert sent to ${targetUsers.length} users');
    } catch (e) {
      debugPrint('Error sending safety alert: $e');
    }
  }

  /// Send union local update notification
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
        if (!userPrefs['unionUpdatesEnabled']) continue;

        String notificationTitle = 'IBEW Local $unionLocal';
        if (meetingDate != null) {
          notificationTitle += ' - Meeting Alert';
        }

        await FCMService.sendNotificationToUser(
          userId: userId,
          title: notificationTitle,
          body: message,
          type: 'union',
          additionalData: {
            'unionLocal': unionLocal,
            'meetingDate': meetingDate ?? '',
            'actionUrl': actionUrl ?? '/locals',
          },
        );

        // Schedule reminder for union meeting if date provided
        if (meetingDate != null) {
          final meetingDateTime = DateTime.tryParse(meetingDate);
          if (meetingDateTime != null) {
            await LocalNotificationService.scheduleUnionMeetingReminder(
              meetingId: '${unionLocal}_${DateTime.now().millisecondsSinceEpoch}',
              meetingTitle: title,
              localNumber: unionLocal,
              meetingTime: meetingDateTime,
            );
          }
        }
      }

      debugPrint('Union update sent for Local $unionLocal');
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
      final userPrefs = await _getUserNotificationPreferences(userId);
      if (!userPrefs['applicationUpdatesEnabled']) return;

      String title;
      String body;
      
      switch (status.toLowerCase()) {
        case 'accepted':
        case 'hired':
          title = '✅ Application Accepted!';
          body = 'Congratulations! You\'ve been selected for $jobTitle at $company';
          break;
        case 'interview':
          title = '📞 Interview Scheduled';
          body = 'Interview scheduled for $jobTitle at $company';
          break;
        case 'rejected':
        case 'declined':
          title = 'Application Update';
          body = 'Your application for $jobTitle at $company was not selected';
          break;
        default:
          title = 'Application Update';
          body = 'Your application for $jobTitle at $company: $status';
      }

      if (nextSteps != null) {
        body += '. $nextSteps';
      }

      await FCMService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        type: 'applications',
        additionalData: {
          'jobTitle': jobTitle,
          'company': company,
          'status': status,
          'actionUrl': '/notifications',
        },
      );

      debugPrint('Application update sent for $jobTitle');
    } catch (e) {
      debugPrint('Error sending application update: $e');
    }
  }

  /// Send storm work priority notification to qualified users
  static Future<void> sendStormWorkAlert({
    required JobModel stormJob,
    required String affectedArea,
    String priority = 'high',
  }) async {
    try {
      // Get users qualified for storm work (linemen primarily)
      final qualifiedUsers = await _getStormWorkQualifiedUsers(affectedArea);

      for (final userId in qualifiedUsers) {
        final userPrefs = await _getUserNotificationPreferences(userId);
        if (!userPrefs['stormWorkEnabled']) continue;

        await sendJobAlert(
          job: stormJob.copyWith(
            title: 'STORM RESTORATION - ${stormJob.title}',
            description: 'Emergency restoration work in $affectedArea. ${stormJob.description}',
          ),
          isStormWork: true,
        );
      }

      debugPrint('Storm work alert sent for $affectedArea');
    } catch (e) {
      debugPrint('Error sending storm work alert: $e');
    }
  }

  /// Check if job matches user preferences
  static Future<bool> _doesJobMatchUserPreferences(JobModel job, String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      
      if (userData == null) return false;

      // Check classification match
      final userClassifications = List<String>.from(userData['classifications'] ?? []);
      if (userClassifications.isNotEmpty) {
        final jobClassifications = List<String>.from(job.classifications ?? []);
        final hasMatchingClassification = userClassifications
            .any((userClass) => jobClassifications.contains(userClass));
        if (!hasMatchingClassification) return false;
      }

      // Check location preference (simplified - could be enhanced with radius)
      final preferredLocations = List<String>.from(userData['preferredLocations'] ?? []);
      if (preferredLocations.isNotEmpty) {
        final matchesLocation = preferredLocations
            .any((location) => job.location.toLowerCase().contains(location.toLowerCase()));
        if (!matchesLocation) return false;
      }

      // Check wage preference
      final minWage = userData['minHourlyRate'] as double?;
      if (minWage != null && job.hourlyRate != null && job.hourlyRate! < minWage) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking job match: $e');
      return false;
    }
  }

  /// Get user notification preferences
  static Future<Map<String, bool>> _getUserNotificationPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'jobAlertsEnabled': prefs.getBool('job_alerts_enabled') ?? true,
        'safetyAlertsEnabled': prefs.getBool('safety_alerts_enabled') ?? true,
        'unionUpdatesEnabled': prefs.getBool('union_updates_enabled') ?? true,
        'applicationUpdatesEnabled': prefs.getBool('application_updates_enabled') ?? true,
        'stormWorkEnabled': prefs.getBool('storm_work_enabled') ?? true,
      };
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return {
        'jobAlertsEnabled': true,
        'safetyAlertsEnabled': true,
        'unionUpdatesEnabled': true,
        'applicationUpdatesEnabled': true,
        'stormWorkEnabled': true,
      };
    }
  }

  /// Get target users for safety alerts
  static Future<List<String>> _getTargetUsersForSafetyAlert({
    String? unionLocal,
    String? location,
  }) async {
    try {
      Query query = _firestore.collection('users');
      
      if (unionLocal != null) {
        query = query.where('unionLocal', isEqualTo: unionLocal);
      }
      
      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting target users for safety alert: $e');
      return [];
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
      debugPrint('Error getting users by union local: $e');
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
      
      // Filter by location proximity (simplified)
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
      debugPrint('Error getting storm work qualified users: $e');
      return [];
    }
  }

  /// Create in-app job notification
  static Future<void> _createInAppJobNotification({
    required String userId,
    required JobModel job,
    required bool isStormWork,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': isStormWork ? '⚡ Storm Work Alert' : 'New Job Match',
        'message': '${job.title} at ${job.company} in ${job.location}',
        'type': isStormWork ? 'storm' : 'jobs',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': {
          'jobId': job.id ?? '',
          'company': job.company,
          'location': job.location,
          'isStormWork': isStormWork.toString(),
          'hourlyRate': job.hourlyRate?.toString() ?? '',
        },
      });
    } catch (e) {
      debugPrint('Error creating in-app job notification: $e');
    }
  }
}