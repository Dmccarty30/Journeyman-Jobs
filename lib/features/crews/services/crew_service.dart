import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../models/crew_enums.dart';

/// Service for crew management operations
/// Handles all CRUD operations for crews, members, and invitations
class CrewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Performance optimization constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Collections
  CollectionReference get crewsCollection => _firestore.collection('crews');
  CollectionReference get usersCollection => _firestore.collection('users');

  // Crew CRUD Operations

  /// Create a new crew
  Future<Crew> createCrew({
    required String creatorId,
    required String name,
    String? description,
    String? imageUrl,
    List<String>? classifications,
    List<JobType>? jobTypes,
    int maxMembers = 10,
    bool isPublic = false,
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        throw Exception('Crew name cannot be empty');
      }
      if (name.length > 50) {
        throw Exception('Crew name cannot exceed 50 characters');
      }

      // Check if user already has 5 crews (limit from API spec)
      final userCrews = await getUserCrews(creatorId);
      if (userCrews.length >= 5) {
        throw Exception('User cannot create more than 5 crews');
      }

      final crewData = {
        'name': name.trim(),
        'description': description?.trim(),
        'imageUrl': imageUrl,
        'createdBy': creatorId,
        'memberIds': [creatorId], // Creator is automatically a member
        'maxMembers': maxMembers,
        'isPublic': isPublic,
        'classifications': classifications ?? [],
        'jobTypes': jobTypes?.map((type) => type.name).toList() ?? [],
        'travelRadius': 50, // Default travel radius
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'allowJobSharing': true,
        'allowInvitations': true,
        'communicationChannels': ['in_app', 'email'],
        'totalJobs': 0,
        'averageRating': 0.0,
        'completedJobs': 0,
      };

      final docRef = await crewsCollection.add(crewData);

      if (kDebugMode) {
        print('✅ Crew created: ${docRef.id}');
      }

      // Return the created crew
      final doc = await docRef.get();
      return Crew.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating crew: $e');
      }
      throw Exception('Failed to create crew: $e');
    }
  }

  /// Get all crews for a user
  Future<List<Crew>> getUserCrews(String userId) async {
    try {
      final query = crewsCollection.where('memberIds', arrayContains: userId);
      final snapshot = await query.get();

      final crews = snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .where((crew) => crew.isActive) // Only return active crews
          .toList();

      if (kDebugMode) {
        print('📋 Found ${crews.length} crews for user $userId');
      }

      return crews;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user crews: $e');
      }
      throw Exception('Failed to get user crews: $e');
    }
  }

  /// Get a specific crew by ID
  Future<Crew> getCrew(String crewId) async {
    try {
      final doc = await crewsCollection.doc(crewId).get();

      if (!doc.exists) {
        throw Exception('Crew not found');
      }

      final crew = Crew.fromFirestore(doc);

      if (!crew.isActive) {
        throw Exception('Crew is no longer active');
      }

      return crew;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting crew $crewId: $e');
      }
      throw Exception('Failed to get crew: $e');
    }
  }

  /// Update crew settings (leader only)
  Future<Crew> updateCrew({
    required String crewId,
    required String userId,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? classifications,
    List<JobType>? jobTypes,
    int? maxMembers,
    bool? isPublic,
    int? travelRadius,
    bool? allowJobSharing,
    bool? allowInvitations,
    List<String>? communicationChannels,
  }) async {
    try {
      // Get current crew to validate permissions
      final crew = await getCrew(crewId);

      // Check if user is the creator (leader)
      if (crew.createdBy != userId) {
        throw Exception('Only crew leader can update crew settings');
      }

      // Validate input
      if (name != null && name.trim().isEmpty) {
        throw Exception('Crew name cannot be empty');
      }
      if (name != null && name.length > 50) {
        throw Exception('Crew name cannot exceed 50 characters');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add non-null fields to update
      if (name != null) updateData['name'] = name.trim();
      if (description != null) updateData['description'] = description.trim();
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (classifications != null) updateData['classifications'] = classifications;
      if (jobTypes != null) updateData['jobTypes'] = jobTypes.map((type) => type.name).toList();
      if (maxMembers != null) updateData['maxMembers'] = maxMembers;
      if (isPublic != null) updateData['isPublic'] = isPublic;
      if (travelRadius != null) updateData['travelRadius'] = travelRadius;
      if (allowJobSharing != null) updateData['allowJobSharing'] = allowJobSharing;
      if (allowInvitations != null) updateData['allowInvitations'] = allowInvitations;
      if (communicationChannels != null) updateData['communicationChannels'] = communicationChannels;

      await crewsCollection.doc(crewId).update(updateData);

      if (kDebugMode) {
        print('✅ Crew $crewId updated');
      }

      // Return updated crew
      return await getCrew(crewId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating crew $crewId: $e');
      }
      throw Exception('Failed to update crew: $e');
    }
  }

  /// Delete crew (leader only)
  Future<void> deleteCrew({
    required String crewId,
    required String userId,
  }) async {
    try {
      // Get current crew to validate permissions
      final crew = await getCrew(crewId);

      // Check if user is the creator (leader)
      if (crew.createdBy != userId) {
        throw Exception('Only crew leader can delete crew');
      }

      // Soft delete by marking as inactive
      await crewsCollection.doc(crewId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Crew $crewId deleted (soft delete)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting crew $crewId: $e');
      }
      throw Exception('Failed to delete crew: $e');
    }
  }

  // Member Management Operations

  /// Get all members of a crew
  Future<List<CrewMember>> getCrewMembers(String crewId) async {
    try {
      final crew = await getCrew(crewId);

      if (crew.memberIds.isEmpty) {
        return [];
      }

      // Get user documents for all member IDs
      final memberDocs = await Future.wait(
        crew.memberIds.map((userId) => usersCollection.doc(userId).get()),
      );

      final members = <CrewMember>[];

      for (final doc in memberDocs) {
        if (doc.exists) {
          // Create CrewMember from user data
          // Note: This is a simplified implementation
          // In a real app, you'd have a dedicated crew_members collection
          final userData = doc.data() as Map<String, dynamic>;

          members.add(CrewMember(
            userId: doc.id,
            crewId: crewId,
            role: doc.id == crew.createdBy ? CrewRole.leader : CrewRole.member,
            joinedAt: crew.createdAt,
            isActive: true,
            workPreferences: CrewMemberPreferences(),
            notifications: NotificationSettings(),
          ));
        }
      }

      if (kDebugMode) {
        print('👥 Found ${members.length} members in crew $crewId');
      }

      return members;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting crew members for $crewId: $e');
      }
      throw Exception('Failed to get crew members: $e');
    }
  }

  /// Invite a member to the crew
  Future<void> inviteMember({
    required String crewId,
    required String inviterId,
    required String inviteMethod, // 'email', 'phone', 'userId'
    required String inviteValue, // email, phone, or userId
  }) async {
    try {
      final crew = await getCrew(crewId);

      // Check permissions
      if (!crew.isAdmin(inviterId)) {
        throw Exception('Insufficient permissions to invite members');
      }

      // Check if crew is full
      if (crew.isFull) {
        throw Exception('Crew is full');
      }

      // Check if user is already a member
      if (crew.isMember(inviteValue)) {
        throw Exception('User is already a member of this crew');
      }

      // Create invitation document
      final invitationData = {
        'crewId': crewId,
        'inviterId': inviterId,
        'inviteMethod': inviteMethod,
        'inviteValue': inviteValue,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      };

      await _firestore.collection('crew_invitations').add(invitationData);

      if (kDebugMode) {
        print('📨 Invitation sent to $inviteValue for crew $crewId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inviting member to crew $crewId: $e');
      }
      throw Exception('Failed to invite member: $e');
    }
  }

  /// Accept crew invitation
  Future<void> acceptInvitation({
    required String crewId,
    required String invitationId,
    required String userId,
  }) async {
    try {
      // Get invitation
      final invitationDoc = await _firestore
          .collection('crew_invitations')
          .doc(invitationId)
          .get();

      if (!invitationDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitationData = invitationDoc.data() as Map<String, dynamic>;

      // Validate invitation
      if (invitationData['crewId'] != crewId) {
        throw Exception('Invitation does not match crew');
      }

      if (invitationData['status'] != 'pending') {
        throw Exception('Invitation is no longer valid');
      }

      // Check expiration
      final expiresAt = (invitationData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Invitation has expired');
      }

      // Get crew and check if still available
      final crew = await getCrew(crewId);

      if (crew.isFull) {
        throw Exception('Crew is now full');
      }

      if (crew.isMember(userId)) {
        throw Exception('User is already a member');
      }

      // Add user to crew
      await crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mark invitation as accepted
      await invitationDoc.reference.update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedBy': userId,
      });

      if (kDebugMode) {
        print('✅ User $userId joined crew $crewId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error accepting invitation $invitationId: $e');
      }
      throw Exception('Failed to accept invitation: $e');
    }
  }

  /// Decline crew invitation
  Future<void> declineInvitation({
    required String crewId,
    required String invitationId,
    required String userId,
  }) async {
    try {
      // Get invitation
      final invitationDoc = await _firestore
          .collection('crew_invitations')
          .doc(invitationId)
          .get();

      if (!invitationDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitationData = invitationDoc.data() as Map<String, dynamic>;

      // Validate invitation
      if (invitationData['crewId'] != crewId) {
        throw Exception('Invitation does not match crew');
      }

      // Mark invitation as declined
      await invitationDoc.reference.update({
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
        'declinedBy': userId,
      });

      if (kDebugMode) {
        print('❌ User $userId declined invitation to crew $crewId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error declining invitation $invitationId: $e');
      }
      throw Exception('Failed to decline invitation: $e');
    }
  }

  /// Remove member from crew
  Future<void> removeMember({
    required String crewId,
    required String removerId,
    required String memberId,
    required String reason, // 'leaving', 'voted_out', 'inactive'
    String? voteId,
  }) async {
    try {
      final crew = await getCrew(crewId);

      // Check permissions
      final canRemove = removerId == crew.createdBy || // Leader can remove anyone
          (removerId == memberId && reason == 'leaving'); // Members can leave themselves

      if (!canRemove) {
        throw Exception('Insufficient permissions to remove member');
      }

      // Cannot remove leader unless transferring leadership
      if (memberId == crew.createdBy && reason != 'leaving') {
        throw Exception('Cannot remove crew leader without transferring leadership');
      }

      // Remove member from crew
      await crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the removal
      final removalData = {
        'crewId': crewId,
        'memberId': memberId,
        'removedBy': removerId,
        'reason': reason,
        'voteId': voteId,
        'removedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('crew_member_removals').add(removalData);

      if (kDebugMode) {
        print('👤 Member $memberId removed from crew $crewId (reason: $reason)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing member $memberId from crew $crewId: $e');
      }
      throw Exception('Failed to remove member: $e');
    }
  }

  /// Update member preferences
  Future<void> updateMemberPreferences({
    required String crewId,
    required String userId,
    required String targetUserId,
    CrewMemberPreferences? workPreferences,
    NotificationSettings? notifications,
  }) async {
    try {
      // Users can only update their own preferences
      if (userId != targetUserId) {
        throw Exception('Can only update own preferences');
      }

      // Get crew to validate membership
      final crew = await getCrew(crewId);
      if (!crew.isMember(userId)) {
        throw Exception('User is not a member of this crew');
      }

      // Update member preferences in crew_members collection
      final memberDoc = _firestore.collection('crew_members').doc('${crewId}_$userId');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (workPreferences != null) {
        updateData['workPreferences'] = workPreferences.toJson();
      }

      if (notifications != null) {
        updateData['notifications'] = notifications.toJson();
      }

      await memberDoc.set(updateData, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Updated preferences for member $userId in crew $crewId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating member preferences: $e');
      }
      throw Exception('Failed to update member preferences: $e');
    }
  }

  // Stream Operations

  /// Stream of user's crews
  Stream<List<Crew>> getUserCrewsStream(String userId) {
    return crewsCollection
        .where('memberIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Crew.fromFirestore(doc)).toList());
  }

  /// Stream of specific crew
  Stream<Crew?> getCrewStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .snapshots()
        .map((doc) => doc.exists ? Crew.fromFirestore(doc) : null);
  }

  /// Stream of crew members
  Stream<List<CrewMember>> getCrewMembersStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) return [];

          final crew = Crew.fromFirestore(doc);
          if (crew.memberIds.isEmpty) return [];

          final memberDocs = await Future.wait(
            crew.memberIds.map((userId) => usersCollection.doc(userId).get()),
          );

          return memberDocs
              .where((doc) => doc.exists)
              .map((doc) => CrewMember(
                    userId: doc.id,
                    crewId: crewId,
                    role: doc.id == crew.createdBy ? CrewRole.leader : CrewRole.member,
                    joinedAt: crew.createdAt,
                    isActive: true,
                    workPreferences: CrewMemberPreferences(),
                    notifications: NotificationSettings(),
                  ))
              .toList();
        });
  }
}