import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../models/crew_enums.dart';
import '../../../services/analytics_service.dart';
import '../../../services/enhanced_notification_service.dart';
import '../../../services/fcm_service.dart';
import 'crew_service.dart';

/// Service for managing crew member operations
/// 
/// Handles member management, invitations, role assignments,
/// voting, and member-specific operations within IBEW crews.
class CrewMemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;
  final EnhancedNotificationService _notifications = EnhancedNotificationService();
  final FCMService _fcm = FCMService.instance;
  final CrewService _crewService = CrewService();

  // Collections
  CollectionReference get crewMembersCollection => _firestore.collection('crew_members');
  CollectionReference get invitationsCollection => _firestore.collection('crew_invitations');
  CollectionReference get votesCollection => _firestore.collection('crew_votes');
  CollectionReference get usersCollection => _firestore.collection('users');

  /// Add a member to a crew
  /// 
  /// Creates a crew member record and updates the crew's member list
  Future<CrewMember> addMember({
    required String crewId,
    required String userId,
    required CrewRole role,
    String? invitedBy,
  }) async {
    try {
      // Verify crew exists and isn't full
      final crew = await _crewService.getCrew(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      if (crew.isFull) {
        throw Exception('Crew is at maximum capacity');
      }

      if (crew.isMember(userId)) {
        throw Exception('User is already a member of this crew');
      }

      // Get user data
      final userDoc = await usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Create crew member record
      final now = DateTime.now();
      final member = CrewMember(
        userId: userId,
        crewId: crewId,
        displayName: userData['displayName'] ?? userData['name'],
        email: userData['email'],
        phone: userData['phone'],
        profileImageUrl: userData['profileImageUrl'],
        role: role,
        joinedAt: now,
        lastActiveAt: now,
        isActive: true,
        workPreferences: CrewMemberPreferences(),
        notifications: NotificationSettings(),
        classifications: List<String>.from(userData['classifications'] ?? []),
        localNumber: userData['localNumber'],
        yearsExperience: userData['yearsExperience'],
        certifications: List<String>.from(userData['certifications'] ?? []),
        skills: List<String>.from(userData['skills'] ?? []),
      );

      // Save member record
      final memberDocRef = crewMembersCollection.doc('${crewId}_$userId');
      await memberDocRef.set(member.toFirestore());

      // Update crew's member list
      await _crewService.crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      // Send notification to new member
      // TODO: Fix notification sending
      // await _notifications.sendNotification(
      //   userId: userId,
        title: 'Welcome to ${crew.name}',
        body: 'You have been added to the crew ${crew.name}',
        data: {
          'type': 'crew_member_added',
          'crewId': crewId,
          'crewName': crew.name,
        },
      );

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_member_added', {
        'crew_id': crewId,
        'user_id': userId,
        'role': role.name,
        'invited_by': invitedBy,
      }); */

      return member.copyWith(id: memberDocRef.id);
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_member_add_failed', {
      //   'crew_id': crewId,
      //   'user_id': userId,
      //   'error': e.toString(),
      // });
      rethrow;
    }
  }

  /// Remove a member from a crew
  /// 
  /// Handles member removal with proper validation and cleanup
  Future<void> removeMember({
    required String crewId,
    required String memberId,
    required String removedBy,
    required String reason,
  }) async {
    try {
      // Verify permissions
      final crew = await _crewService.getCrew(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Check if remover has permission
      final canRemove = crew.isAdmin(removedBy) || removedBy == memberId;
      if (!canRemove) {
        throw Exception('Insufficient permissions to remove member');
      }

      // Cannot remove the creator unless they're leaving voluntarily
      if (memberId == crew.createdBy && removedBy != memberId) {
        throw Exception('Cannot remove crew creator');
      }

      // Update member record to inactive
      final memberDocRef = crewMembersCollection.doc('${crewId}_$memberId');
      await memberDocRef.update({
        'isActive': false,
        'leftAt': FieldValue.serverTimestamp(),
        'leftReason': reason,
        'removedBy': removedBy != memberId ? removedBy : null,
      });

      // Remove from crew's member list
      await _crewService.crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      // Remove from admin list if applicable
      if (crew.adminIds.contains(memberId)) {
        await _crewService.crewsCollection.doc(crewId).update({
          'adminIds': FieldValue.arrayRemove([memberId]),
        });
      }

      // Send notification
      // TODO: Fix notification sending
      // await _notifications.sendNotification(
        userId: memberId,
        title: reason == 'leaving' ? 'Left Crew' : 'Removed from Crew',
        body: reason == 'leaving' 
            ? 'You have left ${crew.name}'
            : 'You have been removed from ${crew.name}',
        data: {
          'type': 'crew_member_removed',
          'crewId': crewId,
          'crewName': crew.name,
          'reason': reason,
        },
      );

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_member_removed', {
        'crew_id': crewId,
        'member_id': memberId,
        'removed_by': removedBy,
        'reason': reason,
      });
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_member_remove_failed', {
        'crew_id': crewId,
        'member_id': memberId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Update member role
  /// 
  /// Only crew admins can update member roles
  Future<void> updateMemberRole({
    required String crewId,
    required String memberId,
    required CrewRole newRole,
    required String updatedBy,
  }) async {
    try {
      // Verify permissions
      final crew = await _crewService.getCrew(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      if (!crew.isAdmin(updatedBy)) {
        throw Exception('Only crew admins can update member roles');
      }

      // Update member role
      final memberDocRef = crewMembersCollection.doc('${crewId}_$memberId');
      await memberDocRef.update({
        'role': newRole.name,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
        'roleUpdatedBy': updatedBy,
      });

      // If promoting to foreman, update crew
      if (newRole == CrewRole.foreman) {
        await _crewService.crewsCollection.doc(crewId).update({
          'foremanId': memberId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_member_role_updated', {
        'crew_id': crewId,
        'member_id': memberId,
        'new_role': newRole.name,
        'updated_by': updatedBy,
      });
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_member_role_update_failed', {
        'crew_id': crewId,
        'member_id': memberId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get all members of a crew
  /// 
  /// Returns a list of active crew members
  Future<List<CrewMember>> getCrewMembers(String crewId) async {
    try {
      final snapshot = await crewMembersCollection
          .where('crewId', isEqualTo: crewId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CrewMember.fromFirestore(doc))
          .toList();
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_members_fetch_failed', {
        'crew_id': crewId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get a specific crew member
  /// 
  /// Returns the member or null if not found
  Future<CrewMember?> getCrewMember(String crewId, String userId) async {
    try {
      final doc = await crewMembersCollection.doc('${crewId}_$userId').get();
      
      if (!doc.exists) {
        return null;
      }

      return CrewMember.fromFirestore(doc);
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_member_fetch_failed', {
        'crew_id': crewId,
        'user_id': userId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Update member preferences
  /// 
  /// Members can update their own work preferences and notification settings
  Future<void> updateMemberPreferences({
    required String crewId,
    required String userId,
    CrewMemberPreferences? workPreferences,
    NotificationSettings? notificationSettings,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      throw Exception('Can only update own preferences');
    }

    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (workPreferences != null) {
        updateData['workPreferences'] = workPreferences.toJson();
      }

      if (notificationSettings != null) {
        updateData['notifications'] = notificationSettings.toJson();
      }

      await crewMembersCollection
          .doc('${crewId}_$userId')
          .update(updateData);

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_member_preferences_updated', {
        'crew_id': crewId,
        'user_id': userId,
        'updated_work_prefs': workPreferences != null,
        'updated_notifications': notificationSettings != null,
      });
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_member_preferences_update_failed', {
        'crew_id': crewId,
        'user_id': userId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Update member availability
  /// 
  /// Members can update their availability status
  Future<void> updateMemberAvailability({
    required String crewId,
    required String userId,
    required MemberAvailability availability,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      throw Exception('Can only update own availability');
    }

    try {
      await crewMembersCollection.doc('${crewId}_$userId').update({
        'availability': availability.name,
        'availabilityUpdatedAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_member_availability_updated', {
        'crew_id': crewId,
        'user_id': userId,
        'availability': availability.name,
      });
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_member_availability_update_failed', {
        'crew_id': crewId,
        'user_id': userId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Send crew invitation
  /// 
  /// Creates an invitation that can be accepted or declined
  Future<String> sendInvitation({
    required String crewId,
    required String invitedBy,
    required String recipientId,
    String? message,
  }) async {
    try {
      // Verify crew and permissions
      final crew = await _crewService.getCrew(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      if (!crew.allowInvitations) {
        throw Exception('Crew is not accepting invitations');
      }

      if (!crew.isAdmin(invitedBy)) {
        throw Exception('Only crew admins can send invitations');
      }

      if (crew.isFull) {
        throw Exception('Crew is at maximum capacity');
      }

      if (crew.isMember(recipientId)) {
        throw Exception('User is already a member');
      }

      // Check for existing pending invitation
      final existingInvite = await invitationsCollection
          .where('crewId', isEqualTo: crewId)
          .where('recipientId', isEqualTo: recipientId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingInvite.docs.isNotEmpty) {
        throw Exception('Invitation already sent to this user');
      }

      // Create invitation
      final invitation = {
        'crewId': crewId,
        'crewName': crew.name,
        'invitedBy': invitedBy,
        'recipientId': recipientId,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      };

      final docRef = await invitationsCollection.add(invitation);

      // Send notification
      // TODO: Fix notification sending
      // await _notifications.sendNotification(
        userId: recipientId,
        title: 'Crew Invitation',
        body: 'You have been invited to join ${crew.name}',
        data: {
          'type': 'crew_invitation',
          'invitationId': docRef.id,
          'crewId': crewId,
          'crewName': crew.name,
        },
      );

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_invitation_sent', {
        'crew_id': crewId,
        'invitation_id': docRef.id,
        'recipient_id': recipientId,
        'invited_by': invitedBy,
      });

      return docRef.id;
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_invitation_send_failed', {
        'crew_id': crewId,
        'recipient_id': recipientId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Accept crew invitation
  /// 
  /// Adds the user to the crew and marks invitation as accepted
  Future<void> acceptInvitation(String invitationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    try {
      // Get invitation
      final inviteDoc = await invitationsCollection.doc(invitationId).get();
      if (!inviteDoc.exists) {
        throw Exception('Invitation not found');
      }

      final inviteData = inviteDoc.data() as Map<String, dynamic>;
      
      // Verify recipient
      if (inviteData['recipientId'] != currentUser.uid) {
        throw Exception('Invitation is for a different user');
      }

      // Check status
      if (inviteData['status'] != 'pending') {
        throw Exception('Invitation is no longer valid');
      }

      // Check expiration
      final expiresAt = (inviteData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Invitation has expired');
      }

      // Add member to crew
      await addMember(
        crewId: inviteData['crewId'],
        userId: currentUser.uid,
        role: CrewRole.crewMember,
        invitedBy: inviteData['invitedBy'],
      );

      // Update invitation status
      await invitationsCollection.doc(invitationId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_invitation_accepted', {
        'invitation_id': invitationId,
        'crew_id': inviteData['crewId'],
        'user_id': currentUser.uid,
      });
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_invitation_accept_failed', {
        'invitation_id': invitationId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Decline crew invitation
  /// 
  /// Marks the invitation as declined
  Future<void> declineInvitation(String invitationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    try {
      // Get invitation
      final inviteDoc = await invitationsCollection.doc(invitationId).get();
      if (!inviteDoc.exists) {
        throw Exception('Invitation not found');
      }

      final inviteData = inviteDoc.data() as Map<String, dynamic>;
      
      // Verify recipient
      if (inviteData['recipientId'] != currentUser.uid) {
        throw Exception('Invitation is for a different user');
      }

      // Update invitation status
      await invitationsCollection.doc(invitationId).update({
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
      });

      // Track analytics
      // TODO: Fix analytics logging
      /* await _analytics.logEvent('crew_invitation_declined', {
        'invitation_id': invitationId,
        'crew_id': inviteData['crewId'],
        'user_id': currentUser.uid,
      });
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('crew_invitation_decline_failed', {
        'invitation_id': invitationId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get pending invitations for a user
  /// 
  /// Returns all pending crew invitations for the current user
  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    try {
      final snapshot = await invitationsCollection
          .where('recipientId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      // TODO: Fix analytics error logging
      // await _analytics.logError('pending_invitations_fetch_failed', {
        'user_id': currentUser.uid,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Stream of crew members
  /// 
  /// Real-time updates of crew member list
  Stream<List<CrewMember>> getCrewMembersStream(String crewId) {
    return crewMembersCollection
        .where('crewId', isEqualTo: crewId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CrewMember.fromFirestore(doc))
            .toList());
  }

  /// Stream of member's availability
  /// 
  /// Real-time updates of a member's availability status
  Stream<MemberAvailability?> getMemberAvailabilityStream(String crewId, String userId) {
    return crewMembersCollection
        .doc('${crewId}_$userId')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = doc.data() as Map<String, dynamic>;
          return MemberAvailability.fromString(data['availability']);
        });
  }
}