import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/fcm_service.dart';
import 'package:journeyman_jobs/services/notification_service.dart';

/// Service for managing crew invitations
///
/// This service handles all crew invitation operations including:
/// - Creating and sending invitations
/// - Accepting and declining invitations
/// - Managing invitation lifecycle
/// - Sending notifications
/// - Cleanup of expired invitations
class CrewInvitationService {
  static final CrewInvitationService _instance = CrewInvitationService._internal();
  factory CrewInvitationService() => _instance;
  CrewInvitationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final CollectionReference _invitationsCollection =
      FirebaseFirestore.instance.collection('crewInvitations');

  /// Invite a user to join a crew
  ///
  /// [crew] - The crew to invite the user to
  /// [invitee] - The user being invited
  /// [inviter] - The user sending the invitation (foreman)
  /// [message] - Optional message from the inviter
  ///
  /// Returns the created invitation
  Future<CrewInvitation> inviteUserToCrew({
    required Crew crew,
    required UserModel invitee,
    required UserModel inviter,
    String? message,
  }) async {
    try {
      // Validate inputs
      if (crew.id.isEmpty) {
        throw ArgumentError('Crew ID cannot be empty');
      }
      if (invitee.uid.isEmpty) {
        throw ArgumentError('Invitee ID cannot be empty');
      }
      if (inviter.uid.isEmpty) {
        throw ArgumentError('Inviter ID cannot be empty');
      }

      // Check if user is already a member of the crew
      if (crew.memberIds.contains(invitee.uid)) {
        throw Exception('User is already a member of this crew');
      }

      // Check if there's already a pending invitation
      final existingInvitations = await getPendingInvitationsForUser(invitee.uid);
      final hasPendingInvitation = existingInvitations.any(
        (invitation) => invitation.crewId == crew.id,
      );
      if (hasPendingInvitation) {
        throw Exception('User already has a pending invitation to this crew');
      }

      // Create the invitation
      final now = Timestamp.now();
      final expiresAt = Timestamp.fromDate(
        now.toDate().add(const Duration(days: 7)),
      );

      final invitation = CrewInvitation(
        id: '', // Will be set by Firestore
        crewId: crew.id,
        inviterId: inviter.uid,
        inviteeId: invitee.uid,
        status: CrewInvitationStatus.pending,
        createdAt: now,
        updatedAt: now,
        expiresAt: expiresAt,
        message: message,
        crewName: crew.name,
        inviterName: inviter.displayNameStr,
        inviteeName: invitee.displayNameStr,
        jobDetails: crew.jobPreferences,
      );

      // Save to Firestore
      final docRef = await _invitationsCollection.add(invitation.toFirestore());
      final savedInvitation = invitation.copyWith(id: docRef.id);

      // Send notification to invitee
      await _sendInvitationNotification(savedInvitation, inviter, invitee);

      return savedInvitation;
    } catch (e) {
      throw Exception('Failed to send crew invitation: $e');
    }
  }

  /// Get all invitations for a user (both sent and received)
  Future<List<CrewInvitation>> getInvitationsForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _invitationsCollection
          .where('inviteeId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CrewInvitation.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invitations for user: $e');
    }
  }

  /// Get pending invitations for a user
  Future<List<CrewInvitation>> getPendingInvitationsForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _invitationsCollection
          .where('inviteeId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CrewInvitation.fromFirestore(doc))
          .where((invitation) => !invitation.isExpired)
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending invitations for user: $e');
    }
  }

  /// Get invitations sent by a user (foreman)
  Future<List<CrewInvitation>> getSentInvitations(String inviterId) async {
    try {
      final QuerySnapshot snapshot = await _invitationsCollection
          .where('inviterId', isEqualTo: inviterId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CrewInvitation.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sent invitations: $e');
    }
  }

  /// Get all invitations for a crew
  Future<List<CrewInvitation>> getInvitationsForCrew(String crewId) async {
    try {
      final QuerySnapshot snapshot = await _invitationsCollection
          .where('crewId', isEqualTo: crewId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CrewInvitation.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invitations for crew: $e');
    }
  }

  /// Accept a crew invitation
  ///
  /// [invitationId] - ID of the invitation to accept
  /// [userId] - ID of the user accepting the invitation
  ///
  /// Returns true if successful
  Future<bool> acceptInvitation(String invitationId, String userId) async {
    try {
      // Get the invitation
      final DocumentSnapshot doc = await _invitationsCollection.doc(invitationId).get();
      if (!doc.exists) {
        throw Exception('Invitation not found');
      }

      final invitation = CrewInvitation.fromFirestore(doc);

      // Validate that the user can accept this invitation
      if (invitation.inviteeId != userId) {
        throw Exception('User cannot accept this invitation');
      }

      if (!invitation.canRespond) {
        throw Exception('Invitation cannot be accepted');
      }

      // Update invitation status
      final now = Timestamp.now();
      await _invitationsCollection.doc(invitationId).update({
        'status': 'accepted',
        'updatedAt': now,
      });

      // Add user to crew
      await _addUserToCrew(invitation.crewId, userId);

      // Send notification to inviter
      await _sendInvitationResponseNotification(
        invitation,
        'accepted',
        userId,
      );

      return true;
    } catch (e) {
      throw Exception('Failed to accept invitation: $e');
    }
  }

  /// Decline a crew invitation
  ///
  /// [invitationId] - ID of the invitation to decline
  /// [userId] - ID of the user declining the invitation
  ///
  /// Returns true if successful
  Future<bool> declineInvitation(String invitationId, String userId) async {
    try {
      // Get the invitation
      final DocumentSnapshot doc = await _invitationsCollection.doc(invitationId).get();
      if (!doc.exists) {
        throw Exception('Invitation not found');
      }

      final invitation = CrewInvitation.fromFirestore(doc);

      // Validate that the user can decline this invitation
      if (invitation.inviteeId != userId) {
        throw Exception('User cannot decline this invitation');
      }

      if (!invitation.canRespond) {
        throw Exception('Invitation cannot be declined');
      }

      // Update invitation status
      final now = Timestamp.now();
      await _invitationsCollection.doc(invitationId).update({
        'status': 'declined',
        'updatedAt': now,
      });

      // Send notification to inviter
      await _sendInvitationResponseNotification(
        invitation,
        'declined',
        userId,
      );

      return true;
    } catch (e) {
      throw Exception('Failed to decline invitation: $e');
    }
  }

  /// Cancel a crew invitation (only by inviter)
  ///
  /// [invitationId] - ID of the invitation to cancel
  /// [inviterId] - ID of the user canceling the invitation
  ///
  /// Returns true if successful
  Future<bool> cancelInvitation(String invitationId, String inviterId) async {
    try {
      // Get the invitation
      final DocumentSnapshot doc = await _invitationsCollection.doc(invitationId).get();
      if (!doc.exists) {
        throw Exception('Invitation not found');
      }

      final invitation = CrewInvitation.fromFirestore(doc);

      // Validate that the user can cancel this invitation
      if (invitation.inviterId != inviterId) {
        throw Exception('User cannot cancel this invitation');
      }

      if (invitation.status != CrewInvitationStatus.pending) {
        throw Exception('Invitation cannot be cancelled');
      }

      // Update invitation status
      final now = Timestamp.now();
      await _invitationsCollection.doc(invitationId).update({
        'status': 'cancelled',
        'updatedAt': now,
      });

      return true;
    } catch (e) {
      throw Exception('Failed to cancel invitation: $e');
    }
  }

  /// Get invitation statistics for a crew
  Future<CrewInvitationStats> getInvitationStatsForCrew(String crewId) async {
    try {
      final invitations = await getInvitationsForCrew(crewId);
      return CrewInvitationStats.fromInvitations(invitations);
    } catch (e) {
      throw Exception('Failed to get invitation stats: $e');
    }
  }

  /// Clean up expired invitations (background task)
  Future<void> cleanupExpiredInvitations() async {
    try {
      final now = Timestamp.now();

      final QuerySnapshot snapshot = await _invitationsCollection
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isLessThan: now)
          .get();

      // Update all expired invitations
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': now,
        });
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      // Log error but don't throw - this is a background task
      print('Failed to cleanup expired invitations: $e');
    }
  }

  /// Stream of invitations for a user (real-time updates)
  Stream<List<CrewInvitation>> streamInvitationsForUser(String userId) {
    return _invitationsCollection
        .where('inviteeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CrewInvitation.fromFirestore(doc))
            .toList());
  }

  /// Stream of pending invitations for a user (real-time updates)
  Stream<List<CrewInvitation>> streamPendingInvitationsForUser(String userId) {
    return _invitationsCollection
        .where('inviteeId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CrewInvitation.fromFirestore(doc))
            .where((invitation) => !invitation.isExpired)
            .toList());
  }

  /// Stream of invitations sent by a user (real-time updates)
  Stream<List<CrewInvitation>> streamSentInvitations(String inviterId) {
    return _invitationsCollection
        .where('inviterId', isEqualTo: inviterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CrewInvitation.fromFirestore(doc))
            .toList());
  }

  /// Private method to add user to crew
  Future<void> _addUserToCrew(String crewId, String userId) async {
    try {
      await _firestore.collection('crews').doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });

      // Also update user model to include crew ID
      await _firestore.collection('users').doc(userId).update({
        'crewIds': FieldValue.arrayUnion([crewId]),
      });
    } catch (e) {
      throw Exception('Failed to add user to crew: $e');
    }
  }

  /// Private method to send invitation notification
  Future<void> _sendInvitationNotification(
    CrewInvitation invitation,
    UserModel inviter,
    UserModel invitee,
  ) async {
    try {
      // Only send if invitee has FCM token
      if (invitee.fcmToken == null || invitee.fcmToken!.isEmpty) {
        return;
      }

      final title = 'Crew Invitation';
      final body = '${inviter.displayNameStr} invited you to join ${invitation.crewName}';

      await NotificationService.sendPushNotification(
        recipientId: invitation.inviteeId,
        title: title,
        body: body,
        data: {
          'type': 'crew_invitation',
          'invitationId': invitation.id,
          'crewId': invitation.crewId,
          'inviterId': invitation.inviterId,
        },
      );
    } catch (e) {
      // Log error but don't fail the invitation
      print('Failed to send invitation notification: $e');
    }
  }

  /// Private method to send invitation response notification
  Future<void> _sendInvitationResponseNotification(
    CrewInvitation invitation,
    String response, // 'accepted' or 'declined'
    String userId,
  ) async {
    try {
      // Get inviter's FCM token
      final inviterDoc = await _firestore.collection('users').doc(invitation.inviterId).get();
      if (!inviterDoc.exists) return;

      final inviterData = inviterDoc.data() as Map<String, dynamic>;
      final inviterFcmToken = inviterData['fcmToken'] as String?;

      if (inviterFcmToken == null || inviterFcmToken.isEmpty) {
        return;
      }

      // Get user's display name
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['displayName'] as String? ??
                     '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();

      final title = 'Invitation $response';
      final body = '$userName has ${response} your invitation to join ${invitation.crewName}';

      await NotificationService.sendPushNotification(
        recipientId: invitation.inviterId,
        title: title,
        body: body,
        data: {
          'type': 'crew_invitation_response',
          'invitationId': invitation.id,
          'crewId': invitation.crewId,
          'response': response,
          'userId': userId,
        },
      );
    } catch (e) {
      // Log error but don't fail the operation
      print('Failed to send invitation response notification: $e');
    }
  }
}