// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/services/crew_invitation_service.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';

/// Enhanced crew service with invitation integration and real-time features
///
/// This service provides comprehensive crew management functionality including:
/// - Crew CRUD operations
/// - Member management with invitations
/// - Real-time crew updates
/// - Crew statistics and analytics
/// - Integration with invitation system
class EnhancedCrewService {
  static final EnhancedCrewService _instance = EnhancedCrewService._internal();
  factory EnhancedCrewService() => _instance;
  EnhancedCrewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final CrewInvitationService _invitationService = CrewInvitationService();
  final CollectionReference _crewsCollection = FirebaseFirestore.instance.collection('crews');

  /// Create a new crew
  ///
  /// [name] - Crew name
  /// [foreman] - User who will be the foreman
  /// [jobPreferences] - Optional job preferences for the crew
  ///
  /// Returns the created crew
  Future<Crew> createCrew({
    required String name,
    required UserModel foreman,
    Map<String, dynamic>? jobPreferences,
  }) async {
    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        throw ArgumentError('Crew name cannot be empty');
      }
      if (foreman.uid.isEmpty) {
        throw ArgumentError('Foreman ID cannot be empty');
      }

      // Create the crew
      final crew = Crew(
        id: '', // Will be set by Firestore
        name: name.trim(),
        foremanId: foreman.uid,
        memberIds: [foreman.uid], // Foreman is automatically a member
        jobPreferences: jobPreferences ?? {},
        stats: CrewStats(),
      );

      // Save to Firestore
      final docRef = await _crewsCollection.add(crew.toFirestore());
      final savedCrew = crew.copyWith(id: docRef.id);

      // Update foreman's crew list
      await _updateUserCrewList(foreman.uid, docRef.id);

      return savedCrew;
    } catch (e) {
      throw Exception('Failed to create crew: $e');
    }
  }

  /// Get crew by ID
  Future<Crew?> getCrewById(String crewId) async {
    try {
      final DocumentSnapshot doc = await _crewsCollection.doc(crewId).get();
      if (!doc.exists) return null;

      return Crew.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get crew: $e');
    }
  }

  /// Get all crews for a user (as member or foreman)
  Future<List<Crew>> getCrewsForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _crewsCollection
          .where('memberIds', arrayContains: userId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get crews for user: $e');
    }
  }

  /// Get crews where user is the foreman
  Future<List<Crew>> getForemanCrews(String userId) async {
    try {
      final QuerySnapshot snapshot = await _crewsCollection
          .where('foremanId', isEqualTo: userId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get foreman crews: $e');
    }
  }

  /// Update crew information
  Future<bool> updateCrew({
    required String crewId,
    required String userId, // Must be foreman
    String? name,
    Map<String, dynamic>? jobPreferences,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Verify user is foreman
      if (crew.foremanId != userId) {
        throw Exception('Only foreman can update crew information');
      }

      // Prepare update data
      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (jobPreferences != null) {
        updateData['jobPreferences'] = jobPreferences;
      }

      if (updateData.isEmpty) {
        return true; // No updates needed
      }

      // Update crew
      await _crewsCollection.doc(crewId).update(updateData);

      // Update related invitations if name changed
      if (name != null) {
        await _updateInvitationsForCrewNameChange(crewId, name.trim());
      }

      return true;
    } catch (e) {
      throw Exception('Failed to update crew: $e');
    }
  }

  /// Add member to crew via invitation system
  ///
  /// This is the preferred way to add members to a crew
  /// Uses the invitation service to send an invitation
  Future<CrewInvitation> inviteMemberToCrew({
    required String crewId,
    required UserModel foreman,
    required UserModel invitee,
    String? message,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Verify user is foreman
      if (crew.foremanId != foreman.uid) {
        throw Exception('Only foreman can invite members');
      }

      // Send invitation
      return await _invitationService.inviteUserToCrew(
        crew: crew,
        invitee: invitee,
        inviter: foreman,
        message: message,
      );
    } catch (e) {
      throw Exception('Failed to invite member: $e');
    }
  }

  /// Remove member from crew (foreman only)
  Future<bool> removeMemberFromCrew({
    required String crewId,
    required String foremanId,
    required String memberId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Verify user is foreman
      if (crew.foremanId != foremanId) {
        throw Exception('Only foreman can remove members');
      }

      // Cannot remove foreman
      if (memberId == crew.foremanId) {
        throw Exception('Cannot remove foreman from crew');
      }

      // Check if user is actually a member
      if (!crew.memberIds.contains(memberId)) {
        throw Exception('User is not a member of this crew');
      }

      // Remove member from crew
      await _crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
      });

      // Update user's crew list
      await _updateUserCrewList(memberId, crewId, remove: true);

      // Cancel any pending invitations for this user and crew
      await _cancelPendingInvitations(crewId, memberId);

      return true;
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  /// Leave a crew (member action)
  Future<bool> leaveCrew({
    required String crewId,
    required String userId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Cannot leave if you're the foreman
      if (crew.foremanId == userId) {
        throw Exception('Foreman cannot leave crew. Transfer or delete crew first.');
      }

      // Check if user is actually a member
      if (!crew.memberIds.contains(userId)) {
        throw Exception('User is not a member of this crew');
      }

      // Remove member from crew
      await _crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      // Update user's crew list
      await _updateUserCrewList(userId, crewId, remove: true);

      return true;
    } catch (e) {
      throw Exception('Failed to leave crew: $e');
    }
  }

  /// Transfer foreman role to another member
  Future<bool> transferForemanRole({
    required String crewId,
    required String currentForemanId,
    required String newForemanId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Verify current user is foreman
      if (crew.foremanId != currentForemanId) {
        throw Exception('Only current foreman can transfer role');
      }

      // Verify new foreman is a member
      if (!crew.memberIds.contains(newForemanId)) {
        throw Exception('New foreman must be a member of the crew');
      }

      // Update crew foreman
      await _crewsCollection.doc(crewId).update({
        'foremanId': newForemanId,
      });

      return true;
    } catch (e) {
      throw Exception('Failed to transfer foreman role: $e');
    }
  }

  /// Delete a crew (foreman only, crew must be empty except foreman)
  Future<bool> deleteCrew({
    required String crewId,
    required String foremanId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      // Verify user is foreman
      if (crew.foremanId != foremanId) {
        throw Exception('Only foreman can delete crew');
      }

      // Check if crew has other members
      if (crew.memberIds.length > 1) {
        throw Exception('Cannot delete crew with other members. Remove all members first.');
      }

      // Cancel all invitations for this crew
      final invitations = await _invitationService.getInvitationsForCrew(crewId);
      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending) {
          try {
            await _invitationService.cancelInvitation(invitation.id, foremanId);
          } catch (e) {
            // Log but continue
          }
        }
      }

      // Delete the crew
      await _crewsCollection.doc(crewId).delete();

      // Update foreman's crew list
      await _updateUserCrewList(foremanId, crewId, remove: true);

      return true;
    } catch (e) {
      throw Exception('Failed to delete crew: $e');
    }
  }

  /// Get crew statistics
  Future<CrewStats?> getCrewStats(String crewId) async {
    try {
      final crew = await getCrewById(crewId);
      return crew?.stats;
    } catch (e) {
      throw Exception('Failed to get crew stats: $e');
    }
  }

  /// Update crew statistics
  Future<bool> updateCrewStats({
    required String crewId,
    int? totalJobsShared,
    int? totalApplications,
    double? averageMatchScore,
  }) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw Exception('Crew not found');
      }

      final updatedStats = CrewStats(
        totalJobsShared: totalJobsShared ?? crew.stats.totalJobsShared,
        totalApplications: totalApplications ?? crew.stats.totalApplications,
        averageMatchScore: averageMatchScore ?? crew.stats.averageMatchScore,
      );

      await _crewsCollection.doc(crewId).update({
        'stats': updatedStats.toFirestore(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to update crew stats: $e');
    }
  }

  /// Get members of a crew with user details
  Future<List<UserModel>> getCrewMembers(String crewId) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        return [];
      }

      final members = <UserModel>[];
      for (final memberId in crew.memberIds) {
        try {
          final userDoc = await _firestore.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            members.add(UserModel.fromFirestore(userDoc));
          }
        } catch (e) {
          // Log but continue with other members
        }
      }

      return members;
    } catch (e) {
      throw Exception('Failed to get crew members: $e');
    }
  }

  /// Search crews by name
  Future<List<Crew>> searchCrews(String query, {int limit = 20}) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final QuerySnapshot snapshot = await _crewsCollection
          .where('name', isGreaterThanOrEqualTo: query.trim())
          .where('name', isLessThanOrEqualTo: query.trim() + '\uf8ff')
          .orderBy('name')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search crews: $e');
    }
  }

  /// Stream of crew updates (real-time)
  Stream<Crew?> streamCrew(String crewId) {
    return _crewsCollection.doc(crewId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Crew.fromFirestore(doc);
    });
  }

  /// Stream of crews for a user (real-time)
  Stream<List<Crew>> streamCrewsForUser(String userId) {
    return _crewsCollection
        .where('memberIds', arrayContains: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Crew.fromFirestore(doc))
            .toList());
  }

  /// Stream of crew members (real-time)
  Stream<List<UserModel>> streamCrewMembers(String crewId) {
    return _crewsCollection.doc(crewId).snapshots().asyncMap((crewDoc) async {
      if (!crewDoc.exists) return [];

      final crew = Crew.fromFirestore(crewDoc);
      final members = <UserModel>[];

      for (final memberId in crew.memberIds) {
        try {
          final userDoc = await _firestore.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            members.add(UserModel.fromFirestore(userDoc));
          }
        } catch (e) {
          // Log but continue with other members
        }
      }

      return members;
    });
  }

  /// Private method to update user's crew list
  Future<void> _updateUserCrewList(String userId, String crewId, {bool remove = false}) async {
    try {
      final fieldUpdate = remove
          ? FieldValue.arrayRemove([crewId])
          : FieldValue.arrayUnion([crewId]);

      await _firestore.collection('users').doc(userId).update({
        'crewIds': fieldUpdate,
      });
    } catch (e) {
      // Log error but don't fail the main operation
    }
  }

  /// Private method to update invitations when crew name changes
  Future<void> _updateInvitationsForCrewNameChange(String crewId, String newName) async {
    try {
      final invitations = await _invitationService.getInvitationsForCrew(crewId);

      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending) {
          await _firestore
              .collection('crews')
              .doc(crewId)
              .collection('invitations')
              .doc(invitation.id)
              .update({'crewName': newName});
        }
      }
    } catch (e) {
      // Log error but don't fail the main operation
    }
  }

  /// Private method to cancel pending invitations when member is removed
  Future<void> _cancelPendingInvitations(String crewId, String memberId) async {
    try {
      final invitations = await _invitationService.getInvitationsForCrew(crewId);

      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending &&
            invitation.inviteeId == memberId) {
          await _invitationService.cancelInvitation(invitation.id, invitation.inviterId);
        }
      }
    } catch (e) {
      // Log error but don't fail the main operation
    }
  }
}