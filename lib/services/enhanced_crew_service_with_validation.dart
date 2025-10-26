import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/services/crew_invitation_service.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/utils/crew_error_handling.dart';
import 'package:journeyman_jobs/utils/crew_validation.dart';

/// Enhanced crew service with comprehensive error handling and validation
///
/// This service extends the base crew service with:
/// - Comprehensive input validation
/// - Detailed error reporting
/// - Graceful error recovery
/// - Consistent error patterns
class EnhancedCrewServiceWithValidation {
  static final EnhancedCrewServiceWithValidation _instance = EnhancedCrewServiceWithValidation._internal();
  factory EnhancedCrewServiceWithValidation() => _instance;
  EnhancedCrewServiceWithValidation._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final CrewInvitationService _invitationService = CrewInvitationService();
  final CollectionReference _crewsCollection = FirebaseFirestore.instance.collection('crews');

  /// Create a new crew with comprehensive validation
  ///
  /// Returns [Crew] if successful, throws [CrewException] on validation or operation failure
  Future<Crew> createCrew({
    required String name,
    required UserModel foreman,
    Map<String, dynamic>? jobPreferences,
  }) async {
    // Validate input
    final validationResults = CrewValidation.validateCrewCreation(
      name: name,
      foremanId: foreman.uid,
      jobPreferences: jobPreferences,
    );

    if (!CrewValidation.isValid(validationResults)) {
      final errorMessages = CrewValidation.getErrorMessages(validationResults);
      throw CrewValidationException(
        'Validation failed: ${errorMessages.join(', ')}',
        context: {'validation_errors': errorMessages},
      );
    }

    // Validate foreman is valid user
    final userValidation = CrewValidation.validateUser(user: foreman);
    if (!CrewValidation.isValid(userValidation)) {
      final errorMessages = CrewValidation.getErrorMessages(userValidation);
      throw CrewValidationException(
        'Invalid foreman data: ${errorMessages.join(', ')}',
        context: {'user_validation_errors': errorMessages},
      );
    }

    try {
      // Check if foreman already has too many crews (business rule)
      final existingCrews = await getForemanCrews(foreman.uid);
      if (existingCrews.length >= 5) {
        throw CrewException(
          'Cannot create more than 5 crews',
          code: CrewErrorCodes.crewNameTooLong,
        );
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
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to create crew: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Invite a member to crew with validation
  ///
  /// Returns [CrewInvitation] if successful, throws [CrewException] on validation or operation failure
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
        throw CrewException(
          'Crew not found',
          code: CrewErrorCodes.crewNotFound,
        );
      }

      // Validate operation
      final validationError = CrewValidation.validateCrewMemberOperation(
        crewId: crewId,
        foremanId: foreman.uid,
        memberId: invitee.uid,
        currentMemberIds: crew.memberIds,
        operation: 'add',
      );

      if (validationError != null) {
        throw CrewException(
          validationError,
          code: CrewErrorCodes.permissionDenied,
        );
      }

      // Get existing invitations to check for duplicates
      final existingInvitations = await _invitationService.getInvitationsForCrew(crewId);

      // Validate invitation data
      final invitationValidation = CrewValidation.validateInvitationCreation(
        crew: crew,
        invitee: invitee,
        inviter: foreman,
        message: message,
        existingInvitations: existingInvitations,
      );

      if (!CrewValidation.isValid(invitationValidation)) {
        final errorMessages = CrewValidation.getErrorMessages(invitationValidation);
        throw CrewInvitationException(
          'Validation failed: ${errorMessages.join(', ')}',
          context: {'validation_errors': errorMessages},
        );
      }

      // Validate user data
      final inviteeValidation = CrewValidation.validateUser(user: invitee);
      if (!CrewValidation.isValid(inviteeValidation)) {
        final errorMessages = CrewValidation.getErrorMessages(inviteeValidation);
        throw CrewInvitationException(
          'Invalid invitee data: ${errorMessages.join(', ')}',
          context: {'user_validation_errors': errorMessages},
        );
      }

      final inviterValidation = CrewValidation.validateUser(user: foreman);
      if (!CrewValidation.isValid(inviterValidation)) {
        final errorMessages = CrewValidation.getErrorMessages(inviterValidation);
        throw CrewInvitationException(
          'Invalid inviter data: ${errorMessages.join(', ')}',
          context: {'user_validation_errors': errorMessages},
        );
      }

      // Send invitation
      return await _invitationService.inviteUserToCrew(
        crew: crew,
        invitee: invitee,
        inviter: foreman,
        message: message,
      );
    } catch (e) {
      if (e is CrewInvitationException) {
        rethrow;
      }
      throw CrewInvitationException(
        'Failed to invite member: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Remove member from crew with validation
  ///
  /// Returns true if successful, throws [CrewException] on validation or operation failure
  Future<bool> removeMemberFromCrew({
    required String crewId,
    required String foremanId,
    required String memberId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException(
          'Crew not found',
          code: CrewErrorCodes.crewNotFound,
        );
      }

      // Validate operation
      final validationError = CrewValidation.validateCrewMemberOperation(
        crewId: crewId,
        foremanId: foremanId,
        memberId: memberId,
        currentMemberIds: crew.memberIds,
        operation: 'remove',
      );

      if (validationError != null) {
        throw CrewException(
          validationError,
          code: CrewErrorCodes.permissionDenied,
        );
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
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to remove member: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Leave a crew with validation
  ///
  /// Returns true if successful, throws [CrewException] on validation or operation failure
  Future<bool> leaveCrew({
    required String crewId,
    required String userId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException(
          'Crew not found',
          code: CrewErrorCodes.crewNotFound,
        );
      }

      // Validate operation
      final validationError = CrewValidation.validateCrewMemberOperation(
        crewId: crewId,
        foremanId: crew.foremanId,
        memberId: userId,
        currentMemberIds: crew.memberIds,
        operation: 'remove',
      );

      if (validationError != null) {
        throw CrewException(
          validationError,
          code: CrewErrorCodes.permissionDenied,
        );
      }

      // Additional validation for leaving
      if (crew.foremanId == userId) {
        throw CrewException(
          'Foreman cannot leave crew. Transfer or delete crew first.',
          code: CrewErrorCodes.cannotRemoveForeman,
        );
      }

      // Check if user is actually a member
      if (!crew.memberIds.contains(userId)) {
        throw CrewException(
          'User is not a member of this crew',
          code: CrewErrorCodes.notCrewMember,
        );
      }

      // Remove member from crew
      await _crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      // Update user's crew list
      await _updateUserCrewList(userId, crewId, remove: true);

      return true;
    } catch (e) {
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to leave crew: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Update crew information with validation
  ///
  /// Returns true if successful, throws [CrewException] on validation or operation failure
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
        throw CrewException(
          'Crew not found',
          code: CrewErrorCodes.crewNotFound,
        );
      }

      // Validate permission
      if (crew.foremanId != userId) {
        throw CrewException(
          'Only foreman can update crew information',
          code: CrewErrorCodes.notCrewForeman,
        );
      }

      // Validate update data
      final validationResults = CrewValidation.validateCrewUpdate(
        name: name,
        jobPreferences: jobPreferences,
      );

      if (!CrewValidation.isValid(validationResults)) {
        final errorMessages = CrewValidation.getErrorMessages(validationResults);
        throw CrewException(
          'Validation failed: ${errorMessages.join(', ')}',
          context: {'validation_errors': errorMessages},
        );
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
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to update crew: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Delete a crew with validation
  ///
  /// Returns true if successful, throws [CrewException] on validation or operation failure
  Future<bool> deleteCrew({
    required String crewId,
    required String foremanId,
  }) async {
    try {
      // Get the crew
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException(
          'Crew not found',
          code: CrewErrorCodes.crewNotFound,
        );
      }

      // Validate permission
      if (crew.foremanId != foremanId) {
        throw CrewException(
          'Only foreman can delete crew',
          code: CrewErrorCodes.notCrewForeman,
        );
      }

      // Validate crew can be deleted (only foreman)
      if (crew.memberIds.length > 1) {
        throw CrewException(
          'Cannot delete crew with other members. Remove all members first.',
          code: CrewErrorCodes.cannotRemoveForeman,
        );
      }

      // Cancel all invitations for this crew
      final invitations = await _invitationService.getInvitationsForCrew(crewId);
      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending) {
          try {
            await _invitationService.cancelInvitation(invitation.id, foremanId);
          } catch (e) {
            // Log but continue
            print('Failed to cancel invitation ${invitation.id}: $e');
          }
        }
      }

      // Delete the crew
      await _crewsCollection.doc(crewId).delete();

      // Update foreman's crew list
      await _updateUserCrewList(foremanId, crewId, remove: true);

      return true;
    } catch (e) {
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to delete crew: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Get crew by ID with error handling
  ///
  /// Returns [Crew] if found, null if not found, throws [CrewException] on operation failure
  Future<Crew?> getCrewById(String crewId) async {
    try {
      final validationError = CrewValidation.validateCrewId(crewId);
      if (validationError != null) {
        throw CrewException(
          validationError,
          code: CrewErrorCodes.invalidCrewId,
        );
      }

      final DocumentSnapshot doc = await _crewsCollection.doc(crewId).get();
      if (!doc.exists) {
        return null; // Crew not found, not an error
      }

      return Crew.fromFirestore(doc);
    } catch (e) {
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to get crew: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Get all crews for a user with error handling
  ///
  /// Returns list of crews, throws [CrewException] on operation failure
  Future<List<Crew>> getCrewsForUser(String userId) async {
    try {
      final validationError = CrewValidation.validateUserId(userId);
      if (validationError != null) {
        throw CrewException(
          validationError,
          code: CrewErrorCodes.invalidUserId,
        );
      }

      final QuerySnapshot snapshot = await _crewsCollection
          .where('memberIds', arrayContains: userId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to get crews for user: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Get crews where user is the foreman with error handling
  ///
  /// Returns list of crews, throws [CrewException] on operation failure
  Future<List<Crew>> getForemanCrews(String userId) async {
    try {
      final validationError = CrewValidation.validateUserId(userId);
      if (validationError != null) {
        throw CrewException(
          validationError,
          code: CrewErrorCodes.invalidUserId,
        );
      }

      final QuerySnapshot snapshot = await _crewsCollection
          .where('foremanId', isEqualTo: userId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to get foreman crews: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Search crews by name with validation
  ///
  /// Returns list of matching crews, throws [CrewException] on operation failure
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
      if (e is CrewException) {
        rethrow;
      }
      throw CrewException(
        'Failed to search crews: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
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
      print('Failed to update user crew list: $e');
    }
  }

  /// Private method to update invitations when crew name changes
  Future<void> _updateInvitationsForCrewNameChange(String crewId, String newName) async {
    try {
      final invitations = await _invitationService.getInvitationsForCrew(crewId);

      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending) {
          await _crewsCollection
              .collection('crewInvitations')
              .doc(invitation.id)
              .update({'crewName': newName});
        }
      }
    } catch (e) {
      // Log error but don't fail the main operation
      print('Failed to update invitations for crew name change: $e');
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
      print('Failed to cancel pending invitations: $e');
    }
  }
}