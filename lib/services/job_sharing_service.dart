import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../features/job_sharing/models/share_notification_model.dart';
import 'analytics_service.dart';
import 'enhanced_notification_service.dart';
import 'fcm_service.dart';

/// Service for handling job sharing functionality
/// 
/// Provides methods for:
/// - Sharing jobs with other users
/// - Managing share notifications
/// - Tracking share analytics
/// - Handling crew sharing
class JobSharingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analytics = AnalyticsService();
  final EnhancedNotificationService _notifications = EnhancedNotificationService();
  final FCMService _fcm = FCMService();

  /// Share a job with specified recipients
  /// 
  /// Parameters:
  /// - [job]: The job to share
  /// - [recipients]: List of users to share with
  /// - [message]: Optional personal message
  /// - [shareMethod]: Method of sharing (email, sms, in_app)
  /// 
  /// Returns the share notification ID
  Future<String> shareJob({
    required Job job,
    required List<UserModel> recipients,
    String? message,
    String shareMethod = 'in_app',
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to share jobs');
    }

    try {
      // Create share notification
      final shareNotification = ShareNotificationModel(
        id: _firestore.collection('shares').doc().id,
        jobId: job.id,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Unknown User',
        recipientIds: recipients.map((r) => r.id).toList(),
        message: message,
        shareMethod: shareMethod,
        timestamp: DateTime.now(),
        status: ShareStatus.pending,
        jobTitle: job.title,
        jobLocal: job.local.toString(),
        jobLocation: job.location,
        jobPayRate: job.payRate,
      );

      // Save to Firestore
      await _firestore
          .collection('shares')
          .doc(shareNotification.id)
          .set(shareNotification.toMap());

      // Send notifications based on share method
      await _sendNotifications(shareNotification, recipients);

      // Track analytics
      await _analytics.logJobShare(
        jobId: job.id,
        recipientCount: recipients.length,
        shareMethod: shareMethod,
        hasMessage: message != null,
      );

      return shareNotification.id;
    } catch (e) {
      await _analytics.logError('job_sharing_failed', {
        'job_id': job.id,
        'recipient_count': recipients.length,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Share a job with the user's crew
  /// 
  /// Automatically finds and shares with all active crew members
  Future<String> shareWithCrew({
    required Job job,
    String? message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to share with crew');
    }

    try {
      // Find user's crew
      final crewQuery = await _firestore
          .collection('crews')
          .where('memberIds', arrayContains: currentUser.uid)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (crewQuery.docs.isEmpty) {
        throw Exception('No active crew found for user');
      }

      final crewDoc = crewQuery.docs.first;
      final memberIds = List<String>.from(crewDoc.data()['memberIds'] ?? []);
      
      // Remove current user from recipients
      memberIds.remove(currentUser.uid);

      if (memberIds.isEmpty) {
        throw Exception('No other crew members found');
      }

      // Get crew member details
      final crewMembers = <UserModel>[];
      for (final memberId in memberIds) {
        final memberDoc = await _firestore
            .collection('users')
            .doc(memberId)
            .get();
        
        if (memberDoc.exists) {
          crewMembers.add(UserModel.fromMap(memberDoc.data()!));
        }
      }

      // Share with crew
      return await shareJob(
        job: job,
        recipients: crewMembers,
        message: message ?? 'Check out this job opportunity!',
        shareMethod: 'crew',
      );
    } catch (e) {
      await _analytics.logError('crew_sharing_failed', {
        'job_id': job.id,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get share notifications for the current user
  Stream<List<ShareNotificationModel>> getUserShares() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('shares')
        .where('recipientIds', arrayContains: currentUser.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShareNotificationModel.fromMap(doc.data()))
            .toList());
  }

  /// Mark a share notification as viewed
  Future<void> markShareAsViewed(String shareId) async {
    try {
      await _firestore
          .collection('shares')
          .doc(shareId)
          .update({
        'status': ShareStatus.viewed.toString(),
        'viewedAt': FieldValue.serverTimestamp(),
      });

      await _analytics.logEvent('share_viewed', {
        'share_id': shareId,
      });
    } catch (e) {
      await _analytics.logError('mark_share_viewed_failed', {
        'share_id': shareId,
        'error': e.toString(),
      });
    }
  }

  /// Delete a share notification
  Future<void> deleteShare(String shareId) async {
    try {
      await _firestore
          .collection('shares')
          .doc(shareId)
          .delete();

      await _analytics.logEvent('share_deleted', {
        'share_id': shareId,
      });
    } catch (e) {
      await _analytics.logError('delete_share_failed', {
        'share_id': shareId,
        'error': e.toString(),
      });
    }
  }

  /// Send notifications to recipients based on share method
  Future<void> _sendNotifications(
    ShareNotificationModel shareNotification,
    List<UserModel> recipients,
  ) async {
    switch (shareNotification.shareMethod) {
      case 'in_app':
        await _sendInAppNotifications(shareNotification, recipients);
        break;
      case 'email':
        await _sendEmailNotifications(shareNotification, recipients);
        break;
      case 'sms':
        await _sendSMSNotifications(shareNotification, recipients);
        break;
      case 'crew':
        await _sendCrewNotifications(shareNotification, recipients);
        break;
    }
  }

  Future<void> _sendInAppNotifications(
    ShareNotificationModel shareNotification,
    List<UserModel> recipients,
  ) async {
    for (final recipient in recipients) {
      // Send FCM notification
      await _fcm.sendNotificationToUser(
        userId: recipient.id,
        title: 'Job Shared: ${shareNotification.jobTitle}',
        body: shareNotification.message ?? 
               '${shareNotification.senderName} shared a job with you',
        data: {
          'type': 'job_share',
          'job_id': shareNotification.jobId,
          'share_id': shareNotification.id,
        },
      );

      // Create in-app notification
      await _notifications.createNotification(
        userId: recipient.id,
        title: 'New Job Share',
        body: '${shareNotification.senderName} shared: ${shareNotification.jobTitle}',
        type: 'job_share',
        data: {
          'job_id': shareNotification.jobId,
          'share_id': shareNotification.id,
        },
      );
    }
  }

  Future<void> _sendEmailNotifications(
    ShareNotificationModel shareNotification,
    List<UserModel> recipients,
  ) async {
    // TODO: Implement email notifications
    // This would integrate with a service like SendGrid or Firebase Functions
    for (final recipient in recipients) {
      // Log for now - implement actual email sending
      await _analytics.logEvent('email_notification_sent', {
        'recipient_id': recipient.id,
        'share_id': shareNotification.id,
      });
    }
  }

  Future<void> _sendSMSNotifications(
    ShareNotificationModel shareNotification,
    List<UserModel> recipients,
  ) async {
    // TODO: Implement SMS notifications
    // This would integrate with a service like Twilio
    for (final recipient in recipients) {
      // Log for now - implement actual SMS sending
      await _analytics.logEvent('sms_notification_sent', {
        'recipient_id': recipient.id,
        'share_id': shareNotification.id,
      });
    }
  }

  Future<void> _sendCrewNotifications(
    ShareNotificationModel shareNotification,
    List<UserModel> recipients,
  ) async {
    // Enhanced crew notifications with special formatting
    for (final recipient in recipients) {
      await _fcm.sendNotificationToUser(
        userId: recipient.id,
        title: '🔌 Crew Job Alert: ${shareNotification.jobTitle}',
        body: shareNotification.message ?? 
               'Your foreman ${shareNotification.senderName} shared a crew opportunity',
        data: {
          'type': 'crew_job_share',
          'job_id': shareNotification.jobId,
          'share_id': shareNotification.id,
          'crew_share': 'true',
        },
      );

      await _notifications.createNotification(
        userId: recipient.id,
        title: '⚡ Crew Job Share',
        body: '${shareNotification.senderName} shared: ${shareNotification.jobTitle}',
        type: 'crew_job_share',
        data: {
          'job_id': shareNotification.jobId,
          'share_id': shareNotification.id,
          'crew_share': 'true',
        },
        priority: 'high', // Crew notifications are high priority
      );
    }
  }

  /// Get sharing statistics for analytics
  Future<Map<String, dynamic>> getSharingStats() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return {};

    try {
      // Get shares sent by user
      final sentQuery = await _firestore
          .collection('shares')
          .where('senderId', isEqualTo: currentUser.uid)
          .get();

      // Get shares received by user
      final receivedQuery = await _firestore
          .collection('shares')
          .where('recipientIds', arrayContains: currentUser.uid)
          .get();

      return {
        'shares_sent': sentQuery.size,
        'shares_received': receivedQuery.size,
        'total_shares': sentQuery.size + receivedQuery.size,
      };
    } catch (e) {
      await _analytics.logError('get_sharing_stats_failed', {
        'error': e.toString(),
      });
      return {};
    }
  }
}
