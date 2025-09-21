// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../features/job_sharing/models/share_notification_model.dart';
import '../features/crews/models/job_notification.dart';
import '../features/crews/models/group_bid.dart';
import '../features/crews/models/crew_enums.dart';
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
  final AnalyticsService _analytics = AnalyticsService.instance;
  final EnhancedNotificationService _notifications = EnhancedNotificationService();
  final FCMService _fcm = FCMService.instance;

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
        {
          'job_id': job.id,
          'recipient_count': recipients.length,
          'share_method': shareMethod,
          'has_message': message != null,
        },
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
          crewMembers.add(UserModel.fromJson(memberDoc.data()!));
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
      await EnhancedNotificationService.createNotification(
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

      await EnhancedNotificationService.createNotification(
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

  // ============================================================================
  // CREW JOB SHARING METHODS
  // ============================================================================

  /// Share a job to a specific crew with enhanced tracking
  ///
  /// Optimized for electrical workers in the field - supports offline mode
  /// and provides immediate feedback for storm work coordination.
  Future<String> shareJobToCrew(
    String jobId,
    String crewId,
    String message, {
    bool isPriority = false,
    DateTime? expiresAt,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to share jobs to crew');
    }

    try {
      // Check if user is a member of the crew
      final crewDoc = await _firestore
          .collection('crews')
          .doc(crewId)
          .get();

      if (!crewDoc.exists) {
        throw Exception('Crew not found');
      }

      final memberIds = List<String>.from(crewDoc.data()?['memberIds'] ?? []);
      if (!memberIds.contains(currentUser.uid)) {
        throw Exception('User is not a member of this crew');
      }

      // Check for duplicate shares within 24 hours
      final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));
      final duplicateQuery = await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('jobNotifications')
          .where('jobId', isEqualTo: jobId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(oneDayAgo))
          .limit(1)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        throw Exception('Job already shared to this crew within 24 hours');
      }

      // Create job notification
      final notificationId = _firestore
          .collection('crews')
          .doc(crewId)
          .collection('jobNotifications')
          .doc().id;

      final jobNotification = JobNotification(
        id: notificationId,
        jobId: jobId,
        crewId: crewId,
        sharedByUserId: currentUser.uid,
        message: message,
        timestamp: DateTime.now(),
        memberResponses: {},
        groupBidStatus: GroupBidStatus.draft,
        isPriority: isPriority,
        expiresAt: expiresAt,
        viewCount: 0,
        responseCount: 0,
        appliedMembers: [],
      );

      // Save job notification to crew subcollection
      await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('jobNotifications')
          .doc(notificationId)
          .set(jobNotification.toMap());

      // Send notifications to crew members
      await _sendCrewJobNotifications(jobNotification, memberIds);

      // Track analytics
      await _analytics.logEvent('crew_job_shared', {
        'job_id': jobId,
        'crew_id': crewId,
        'is_priority': isPriority,
        'member_count': memberIds.length,
        'shared_by': currentUser.uid,
      });

      return notificationId;
    } catch (e) {
      await _analytics.logError('share_job_to_crew_failed', {
        'job_id': jobId,
        'crew_id': crewId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Respond to a job notification with offline support
  ///
  /// Handles responses when electrical workers may have limited connectivity
  Future<void> respondToJobNotification(
    String notificationId,
    String userId,
    ResponseType response, {
    String? note,
  }) async {
    try {
      // Get the job notification
      final notificationQuery = await _firestore
          .collectionGroup('jobNotifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (notificationQuery.docs.isEmpty) {
        throw Exception('Job notification not found');
      }

      final notificationDoc = notificationQuery.docs.first;
      final notification = JobNotification.fromMap(notificationDoc.data());

      // Create member response
      final memberResponse = MemberResponse(
        userId: userId,
        type: response,
        timestamp: DateTime.now(),
        note: note,
      );

      // Update the notification with the response
      final updatedResponses = Map<String, MemberResponse>.from(notification.memberResponses);
      updatedResponses[userId] = memberResponse;

      final updatedNotification = notification.copyWith(
        memberResponses: updatedResponses,
        responseCount: updatedResponses.length,
      );

      // Update in Firestore
      await notificationDoc.reference.update(updatedNotification.toMap());

      // Track analytics
      await _analytics.logEvent('job_notification_response', {
        'notification_id': notificationId,
        'user_id': userId,
        'response_type': response.name,
        'crew_id': notification.crewId,
        'has_note': note != null,
      });

      // If this is a storm work response, send high-priority notification to foreman
      if (notification.isPriority && response == ResponseType.accepted) {
        await _notifyForemanOfStormResponse(notification, userId);
      }
    } catch (e) {
      await _analytics.logError('respond_to_job_notification_failed', {
        'notification_id': notificationId,
        'user_id': userId,
        'response_type': response.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Create a group bid for coordinated crew applications
  ///
  /// Optimized for IBEW electrical work - supports role assignments and certifications
  Future<String> createGroupBid(GroupBid bid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to create group bids');
    }

    try {
      // Validate bid data
      if (bid.participatingMembers.isEmpty) {
        throw Exception('Group bid must have at least one participating member');
      }

      if (bid.terms.proposedRate <= 0) {
        throw Exception('Proposed rate must be greater than 0');
      }

      // Create group bid document
      final bidId = _firestore
          .collection('crews')
          .doc(bid.crewId)
          .collection('groupBids')
          .doc().id;

      final groupBid = bid.copyWith(
        id: bidId,
        createdByUserId: currentUser.uid,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('crews')
          .doc(bid.crewId)
          .collection('groupBids')
          .doc(bidId)
          .set(groupBid.toMap());

      // Update corresponding job notification status
      await _updateJobNotificationStatus(
        bid.jobNotificationId,
        GroupBidStatus.underReview,
      );

      // Track analytics
      await _analytics.logEvent('group_bid_created', {
        'bid_id': bidId,
        'crew_id': bid.crewId,
        'job_id': bid.jobId,
        'member_count': bid.participatingMembers.length,
        'proposed_rate': bid.terms.proposedRate,
        'created_by': currentUser.uid,
      });

      return bidId;
    } catch (e) {
      await _analytics.logError('create_group_bid_failed', {
        'crew_id': bid.crewId,
        'job_id': bid.jobId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Submit a group bid to the employer
  ///
  /// Handles the formal submission process for electrical work opportunities
  Future<void> submitGroupBid(String bidId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to submit group bids');
    }

    try {
      // Get the group bid
      final bidQuery = await _firestore
          .collectionGroup('groupBids')
          .where('id', isEqualTo: bidId)
          .limit(1)
          .get();

      if (bidQuery.docs.isEmpty) {
        throw Exception('Group bid not found');
      }

      final bidDoc = bidQuery.docs.first;
      final bid = GroupBid.fromMap(bidDoc.data());

      // Validate bid can be submitted
      if (!bid.canModify) {
        throw Exception('Group bid cannot be modified in its current status');
      }

      // Update bid status
      final updatedBid = bid.copyWith(
        status: GroupBidStatus.submitted,
        submittedAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await bidDoc.reference.update(updatedBid.toMap());

      // Update job notification status
      await _updateJobNotificationStatus(
        bid.jobNotificationId,
        GroupBidStatus.submitted,
      );

      // Notify all participating members
      await _notifyMembersOfBidSubmission(bid);

      // Track analytics
      await _analytics.logEvent('group_bid_submitted', {
        'bid_id': bidId,
        'crew_id': bid.crewId,
        'job_id': bid.jobId,
        'member_count': bid.participatingMembers.length,
        'submitted_by': currentUser.uid,
      });
    } catch (e) {
      await _analytics.logError('submit_group_bid_failed', {
        'bid_id': bidId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Update bid status (typically called by admin/employer)
  ///
  /// Handles status changes throughout the bid lifecycle
  Future<void> updateBidStatus(
    String bidId,
    GroupBidStatus status, {
    String? employerResponse,
  }) async {
    try {
      // Get the group bid
      final bidQuery = await _firestore
          .collectionGroup('groupBids')
          .where('id', isEqualTo: bidId)
          .limit(1)
          .get();

      if (bidQuery.docs.isEmpty) {
        throw Exception('Group bid not found');
      }

      final bidDoc = bidQuery.docs.first;
      final bid = GroupBid.fromMap(bidDoc.data());

      // Update bid with new status
      final updatedBid = bid.copyWith(
        status: status,
        employerResponse: employerResponse,
        responseDate: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await bidDoc.reference.update(updatedBid.toMap());

      // Update job notification status
      await _updateJobNotificationStatus(bid.jobNotificationId, status);

      // Notify crew members of status change
      await _notifyMembersOfStatusChange(bid, status, employerResponse);

      // Track analytics
      await _analytics.logEvent('group_bid_status_updated', {
        'bid_id': bidId,
        'crew_id': bid.crewId,
        'old_status': bid.status.name,
        'new_status': status.name,
        'has_employer_response': employerResponse != null,
      });
    } catch (e) {
      await _analytics.logError('update_bid_status_failed', {
        'bid_id': bidId,
        'status': status.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get job notifications for a specific crew
  ///
  /// Supports offline caching and priority sorting for electrical workers
  Stream<List<JobNotification>> getCrewJobNotifications(String crewId) {
    return _firestore
        .collection('crews')
        .doc(crewId)
        .collection('jobNotifications')
        .orderBy('isPriority', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobNotification.fromMap(doc.data()))
            .toList());
  }

  /// Get responses for a specific job notification
  ///
  /// Used by crew leaders to track member responses
  Future<Map<String, MemberResponse>> getJobNotificationResponses(
    String notificationId,
  ) async {
    try {
      final notificationQuery = await _firestore
          .collectionGroup('jobNotifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (notificationQuery.docs.isEmpty) {
        throw Exception('Job notification not found');
      }

      final notification = JobNotification.fromMap(
        notificationQuery.docs.first.data(),
      );

      return notification.memberResponses;
    } catch (e) {
      await _analytics.logError('get_job_notification_responses_failed', {
        'notification_id': notificationId,
        'error': e.toString(),
      });
      return {};
    }
  }

  /// Calculate crew match score for a job
  ///
  /// Uses IBEW-specific criteria for job matching
  Future<double> calculateCrewMatchScore(String jobId, String crewId) async {
    try {
      // Get job details
      final jobDoc = await _firestore
          .collection('jobs')
          .doc(jobId)
          .get();

      if (!jobDoc.exists) {
        return 0.0;
      }

      final jobData = jobDoc.data()!;

      // Get crew preferences
      final crewDoc = await _firestore
          .collection('crews')
          .doc(crewId)
          .get();

      if (!crewDoc.exists) {
        return 0.0;
      }

      final crewData = crewDoc.data()!;
      final preferences = crewData['preferences'] as Map<String, dynamic>?;

      if (preferences == null) {
        return 0.5; // Default match if no preferences set
      }

      double score = 0.0;
      int factors = 0;

      // Job type match (40% weight)
      final jobType = jobData['type'] as String?;
      final acceptedTypes = List<String>.from(preferences['acceptedJobTypes'] ?? []);
      if (jobType != null && acceptedTypes.contains(jobType)) {
        score += 0.4;
      }
      factors++;

      // Pay rate match (30% weight)
      final jobRate = (jobData['payRate'] as num?)?.toDouble() ?? 0.0;
      final minRate = (preferences['minimumCrewRate'] as num?)?.toDouble() ?? 0.0;
      if (jobRate >= minRate) {
        score += 0.3;
      }
      factors++;

      // Location preference match (20% weight)
      final jobState = jobData['state'] as String?;
      final preferredStates = List<String>.from(preferences['preferredStates'] ?? []);
      final avoidedStates = List<String>.from(preferences['avoidedStates'] ?? []);

      if (jobState != null) {
        if (avoidedStates.contains(jobState)) {
          // Penalty for avoided states
          score -= 0.1;
        } else if (preferredStates.isEmpty || preferredStates.contains(jobState)) {
          score += 0.2;
        }
      }
      factors++;

      // Company preference match (10% weight)
      final company = jobData['company'] as String?;
      final preferredCompanies = List<String>.from(preferences['preferredCompanies'] ?? []);
      final blacklistedCompanies = List<String>.from(preferences['blacklistedCompanies'] ?? []);

      if (company != null) {
        if (blacklistedCompanies.contains(company)) {
          score -= 0.2; // Heavy penalty for blacklisted companies
        } else if (preferredCompanies.isEmpty || preferredCompanies.contains(company)) {
          score += 0.1;
        }
      }
      factors++;

      // Normalize score to 0-1 range
      final normalizedScore = (score / factors).clamp(0.0, 1.0);

      await _analytics.logEvent('crew_match_score_calculated', {
        'job_id': jobId,
        'crew_id': crewId,
        'match_score': normalizedScore,
        'job_type': jobType,
        'job_rate': jobRate,
        'job_state': jobState,
        'company': company,
      });

      return normalizedScore;
    } catch (e) {
      await _analytics.logError('calculate_crew_match_score_failed', {
        'job_id': jobId,
        'crew_id': crewId,
        'error': e.toString(),
      });
      return 0.0;
    }
  }

  /// Auto-share matching jobs to crew based on preferences
  ///
  /// Background service for intelligent job matching
  Future<List<String>> autoShareMatchingJobs(String crewId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to auto-share jobs');
    }

    try {
      final sharedJobIds = <String>[];

      // Get crew preferences
      final crewDoc = await _firestore
          .collection('crews')
          .doc(crewId)
          .get();

      if (!crewDoc.exists) {
        throw Exception('Crew not found');
      }

      final crewData = crewDoc.data()!;
      final preferences = crewData['preferences'] as Map<String, dynamic>?;

      if (preferences == null ||
          !(preferences['autoShareMatchingJobs'] ?? false)) {
        return sharedJobIds; // Auto-sharing disabled
      }

      final matchThreshold = (preferences['matchThreshold'] ?? 80) / 100.0;

      // Get recent jobs (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final jobsQuery = await _firestore
          .collection('jobs')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .where('isActive', isEqualTo: true)
          .limit(50)
          .get();

      for (final jobDoc in jobsQuery.docs) {
        final jobId = jobDoc.id;

        // Check if already shared
        final existingShareQuery = await _firestore
            .collection('crews')
            .doc(crewId)
            .collection('jobNotifications')
            .where('jobId', isEqualTo: jobId)
            .limit(1)
            .get();

        if (existingShareQuery.docs.isNotEmpty) {
          continue; // Already shared
        }

        // Calculate match score
        final matchScore = await calculateCrewMatchScore(jobId, crewId);

        if (matchScore >= matchThreshold) {
          try {
            final notificationId = await shareJobToCrew(
              jobId,
              crewId,
              'Auto-matched job opportunity (${(matchScore * 100).toStringAsFixed(0)}% match)',
              isPriority: matchScore >= 0.9, // High matches are priority
            );

            sharedJobIds.add(jobId);

            await _analytics.logEvent('auto_share_job_matched', {
              'job_id': jobId,
              'crew_id': crewId,
              'match_score': matchScore,
              'notification_id': notificationId,
            });
          } catch (e) {
            // Log but continue with other jobs
            await _analytics.logError('auto_share_individual_job_failed', {
              'job_id': jobId,
              'crew_id': crewId,
              'match_score': matchScore,
              'error': e.toString(),
            });
          }
        }
      }

      await _analytics.logEvent('auto_share_jobs_completed', {
        'crew_id': crewId,
        'jobs_shared': sharedJobIds.length,
        'jobs_evaluated': jobsQuery.size,
        'match_threshold': matchThreshold,
      });

      return sharedJobIds;
    } catch (e) {
      await _analytics.logError('auto_share_matching_jobs_failed', {
        'crew_id': crewId,
        'error': e.toString(),
      });
      return [];
    }
  }

  /// Get crew job history with analytics
  ///
  /// Provides historical data for performance analysis
  Future<Map<String, dynamic>> getCrewJobHistory(String crewId) async {
    try {
      // Get job notifications
      final notificationsQuery = await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('jobNotifications')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      // Get group bids
      final bidsQuery = await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('groupBids')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final notifications = notificationsQuery.docs
          .map((doc) => JobNotification.fromMap(doc.data()))
          .toList();

      final bids = bidsQuery.docs
          .map((doc) => GroupBid.fromMap(doc.data()))
          .toList();

      // Calculate statistics
      final totalShares = notifications.length;
      final totalBids = bids.length;
      final acceptedBids = bids.where((bid) => bid.status == GroupBidStatus.accepted).length;
      final successRate = totalBids > 0 ? (acceptedBids / totalBids) * 100 : 0.0;

      final responseRates = notifications
          .where((n) => n.memberResponses.isNotEmpty)
          .map((n) => n.responseRate)
          .toList();

      final avgResponseRate = responseRates.isNotEmpty
          ? responseRates.reduce((a, b) => a + b) / responseRates.length
          : 0.0;

      return {
        'total_job_shares': totalShares,
        'total_group_bids': totalBids,
        'accepted_bids': acceptedBids,
        'success_rate': successRate,
        'average_response_rate': avgResponseRate,
        'recent_notifications': notifications.take(20).map((n) => n.toMap()).toList(),
        'recent_bids': bids.take(10).map((b) => b.toMap()).toList(),
      };
    } catch (e) {
      await _analytics.logError('get_crew_job_history_failed', {
        'crew_id': crewId,
        'error': e.toString(),
      });
      return {};
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS FOR CREW FUNCTIONALITY
  // ============================================================================

  /// Send notifications to crew members about new job shares
  Future<void> _sendCrewJobNotifications(
    JobNotification notification,
    List<String> memberIds,
  ) async {
    for (final memberId in memberIds) {
      // Skip the user who shared the job
      if (memberId == notification.sharedByUserId) continue;

      final title = notification.isPriority
          ? '⚡ URGENT: Storm Work Available'
          : '🔌 New Crew Job Share';

      final body = notification.message ??
          'A new electrical job opportunity has been shared to your crew';

      await _fcm.sendNotificationToUser(
        userId: memberId,
        title: title,
        body: body,
        data: {
          'type': 'crew_job_notification',
          'notification_id': notification.id,
          'job_id': notification.jobId,
          'crew_id': notification.crewId,
          'is_priority': notification.isPriority.toString(),
        },
      );

      await EnhancedNotificationService.createNotification(
        userId: memberId,
        title: title,
        body: body,
        type: 'crew_job_notification',
        data: {
          'notification_id': notification.id,
          'job_id': notification.jobId,
          'crew_id': notification.crewId,
        },
        priority: notification.isPriority ? 'high' : 'normal',
      );
    }
  }

  /// Update job notification status
  Future<void> _updateJobNotificationStatus(
    String notificationId,
    GroupBidStatus status,
  ) async {
    try {
      final notificationQuery = await _firestore
          .collectionGroup('jobNotifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (notificationQuery.docs.isNotEmpty) {
        await notificationQuery.docs.first.reference.update({
          'groupBidStatus': status.name,
        });
      }
    } catch (e) {
      await _analytics.logError('update_job_notification_status_failed', {
        'notification_id': notificationId,
        'status': status.name,
        'error': e.toString(),
      });
    }
  }

  /// Notify foreman of storm work response
  Future<void> _notifyForemanOfStormResponse(
    JobNotification notification,
    String userId,
  ) async {
    try {
      // Get crew to find foreman
      final crewDoc = await _firestore
          .collection('crews')
          .doc(notification.crewId)
          .get();

      if (!crewDoc.exists) return;

      final leaderId = crewDoc.data()?['leaderId'] as String?;
      if (leaderId == null || leaderId == userId) return;

      await _fcm.sendNotificationToUser(
        userId: leaderId,
        title: '⚡ Storm Response Received',
        body: 'A crew member has accepted the storm work assignment',
        data: {
          'type': 'storm_response_notification',
          'notification_id': notification.id,
          'responding_user': userId,
          'crew_id': notification.crewId,
        },
      );
    } catch (e) {
      await _analytics.logError('notify_foreman_storm_response_failed', {
        'notification_id': notification.id,
        'user_id': userId,
        'error': e.toString(),
      });
    }
  }

  /// Notify members of bid submission
  Future<void> _notifyMembersOfBidSubmission(GroupBid bid) async {
    for (final memberId in bid.participatingMembers) {
      await _fcm.sendNotificationToUser(
        userId: memberId,
        title: '📋 Group Bid Submitted',
        body: 'Your crew\'s group bid has been submitted to the employer',
        data: {
          'type': 'group_bid_submitted',
          'bid_id': bid.id,
          'crew_id': bid.crewId,
          'job_id': bid.jobId,
        },
      );

      await EnhancedNotificationService.createNotification(
        userId: memberId,
        title: 'Group Bid Submitted',
        body: 'Your crew\'s group bid has been submitted for review',
        type: 'group_bid_submitted',
        data: {
          'bid_id': bid.id,
          'crew_id': bid.crewId,
          'job_id': bid.jobId,
        },
      );
    }
  }

  /// Notify members of bid status changes
  Future<void> _notifyMembersOfStatusChange(
    GroupBid bid,
    GroupBidStatus newStatus,
    String? employerResponse,
  ) async {
    String title;
    String body;

    switch (newStatus) {
      case GroupBidStatus.accepted:
        title = '🎉 Bid Accepted!';
        body = 'Your crew\'s group bid has been accepted by the employer';
        break;
      case GroupBidStatus.rejected:
        title = '❌ Bid Rejected';
        body = 'Your crew\'s group bid was not selected for this job';
        break;
      case GroupBidStatus.inProgress:
        title = '🚀 Work Started';
        body = 'Your crew\'s job has officially started';
        break;
      case GroupBidStatus.completed:
        title = '✅ Job Completed';
        body = 'Your crew has successfully completed the job';
        break;
      default:
        title = '📋 Bid Status Update';
        body = 'Your crew\'s bid status has been updated to ${newStatus.displayName}';
    }

    for (final memberId in bid.participatingMembers) {
      await _fcm.sendNotificationToUser(
        userId: memberId,
        title: title,
        body: body,
        data: {
          'type': 'group_bid_status_update',
          'bid_id': bid.id,
          'crew_id': bid.crewId,
          'job_id': bid.jobId,
          'new_status': newStatus.name,
        },
      );

      await EnhancedNotificationService.createNotification(
        userId: memberId,
        title: title,
        body: employerResponse ?? body,
        type: 'group_bid_status_update',
        data: {
          'bid_id': bid.id,
          'crew_id': bid.crewId,
          'job_id': bid.jobId,
          'new_status': newStatus.name,
        },
        priority: newStatus == GroupBidStatus.accepted ? 'high' : 'normal',
      );
    }
  }
}
