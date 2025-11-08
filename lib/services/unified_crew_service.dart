/// Unified Crew Service
///
/// Consolidated crew management service combining:
/// - Crew CRUD operations
/// - Member management with invitations
/// - Real-time crew updates
/// - Comprehensive validation and error handling
/// - Crew statistics and analytics
/// - Search functionality
///
/// Replaces: CrewInvitationService, EnhancedCrewService, EnhancedCrewServiceWithValidation
/// Original lines: 494 + 537 + 639 = 1670 → Consolidated: ~800 lines (52% reduction)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/user_job_preferences.dart';
import 'package:journeyman_jobs/services/unified_firestore_service.dart';
import 'package:journeyman_jobs/services/notification_service.dart';
import 'package:journeyman_jobs/utils/crew_validation.dart';

// Crew invitation and exception types
class CrewInvitation {
  final String id;
  final String crewId;
  final String inviterId;
  final String inviteeId;
  final CrewInvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final String? message;
  final String crewName;
  final String inviterName;
  final String inviteeName;
  final Map<String, dynamic>? jobDetails;

  const CrewInvitation({
    required this.id,
    required this.crewId,
    required this.inviterId,
    required this.inviteeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.message,
    required this.crewName,
    required this.inviterName,
    required this.inviteeName,
    this.jobDetails,
  });

  factory CrewInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewInvitation(
      id: doc.id,
      crewId: data['crewId'] ?? '',
      inviterId: data['inviterId'] ?? '',
      inviteeId: data['inviteeId'] ?? '',
      status: CrewInvitationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CrewInvitationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
                  DateTime.now().add(const Duration(days: 7)),
      message: data['message'],
      crewName: data['crewName'] ?? '',
      inviterName: data['inviterName'] ?? '',
      inviteeName: data['inviteeName'] ?? '',
      jobDetails: data['jobDetails'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'crewId': crewId,
    'inviterId': inviterId,
    'inviteeId': inviteeId,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'expiresAt': Timestamp.fromDate(expiresAt),
    'message': message,
    'crewName': crewName,
    'inviterName': inviterName,
    'inviteeName': inviteeName,
    'jobDetails': jobDetails,
  };

  CrewInvitation copyWith({
    String? id,
    String? crewId,
    String? inviterId,
    String? inviteeId,
    CrewInvitationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? message,
    String? crewName,
    String? inviterName,
    String? inviteeName,
    Map<String, dynamic>? jobDetails,
  }) {
    return CrewInvitation(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      message: message ?? this.message,
      crewName: crewName ?? this.crewName,
      inviterName: inviterName ?? this.inviterName,
      inviteeName: inviteeName ?? this.inviteeName,
      jobDetails: jobDetails ?? this.jobDetails,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canRespond => status == CrewInvitationStatus.pending && !isExpired;
}

enum CrewInvitationStatus {
  pending,
  accepted,
  declined,
  cancelled,
  expired,
}

class CrewInvitationStats {
  final int totalInvitations;
  final int pendingInvitations;
  final int acceptedInvitations;
  final int declinedInvitations;
  final int expiredInvitations;

  const CrewInvitationStats({
    required this.totalInvitations,
    required this.pendingInvitations,
    required this.acceptedInvitations,
    required this.declinedInvitations,
    required this.expiredInvitations,
  });

  factory CrewInvitationStats.fromInvitations(List<CrewInvitation> invitations) {
    final total = invitations.length;
    final pending = invitations.where((i) => i.status == CrewInvitationStatus.pending).length;
    final accepted = invitations.where((i) => i.status == CrewInvitationStatus.accepted).length;
    final declined = invitations.where((i) => i.status == CrewInvitationStatus.declined).length;
    final expired = invitations.where((i) => i.status == CrewInvitationStatus.expired).length;

    return CrewInvitationStats(
      totalInvitations: total,
      pendingInvitations: pending,
      acceptedInvitations: accepted,
      declinedInvitations: declined,
      expiredInvitations: expired,
    );
  }
}

// Exception classes
class CrewException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;
  final dynamic originalError;

  CrewException(
    this.message, {
    this.code,
    this.context,
    this.originalError,
  });

  @override
  String toString() => 'CrewException: $message';
}

class CrewInvitationException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;
  final dynamic originalError;

  CrewInvitationException(
    this.message, {
    this.code,
    this.context,
    this.originalError,
  });

  @override
  String toString() => 'CrewInvitationException: $message';
}

class CrewValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? context;

  CrewValidationException(this.message, {this.context});

  @override
  String toString() => 'CrewValidationException: $message';
}

class CrewErrorCodes {
  static const String crewNotFound = 'crew_not_found';
  static const String invalidCrewId = 'invalid_crew_id';
  static const String invalidUserId = 'invalid_user_id';
  static const String permissionDenied = 'permission_denied';
  static const String notCrewMember = 'not_crew_member';
  static const String notCrewForeman = 'not_crew_foreman';
  static const String cannotRemoveForeman = 'cannot_remove_foreman';
  static const String crewNameTooLong = 'crew_name_too_long';
  static const String unknownError = 'unknown_error';
}

/// Unified crew service with comprehensive functionality
class UnifiedCrewService {
  static final UnifiedCrewService _instance = UnifiedCrewService._internal();
  factory UnifiedCrewService() => _instance;
  UnifiedCrewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UnifiedFirestoreService _firestoreService = UnifiedFirestoreService();
  final CollectionReference _crewsCollection = FirebaseFirestore.instance.collection('crews');

  /// Create a new crew with validation
  Future<Crew> createCrew({
    required String name,
    required String foremanId,
    Map<String, dynamic>? jobPreferences,
  }) async {
    try {
      // Validate input
      final validationResults = CrewValidation.validateCrewCreation(
        name: name,
        foremanId: foremanId,
        jobPreferences: jobPreferences,
      );

      if (!CrewValidation.isValid(validationResults)) {
        final errorMessages = CrewValidation.getErrorMessages(validationResults);
        throw CrewValidationException(
          'Validation failed: ${errorMessages.join(', ')}',
          context: {'validation_errors': errorMessages},
        );
      }

      // Check if foreman already has too many crews (business rule)
      final existingCrews = await getForemanCrews(foremanId);
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
        foremanId: foremanId,
        memberIds: [foremanId], // Foreman is automatically a member
        jobPreferences: jobPreferences ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await _crewsCollection.add(crew.toFirestore());
      final savedCrew = crew.copyWith(id: docRef.id);

      // Update foreman's crew list
      await _updateUserCrewList(foremanId, docRef.id);

      debugPrint('[UnifiedCrewService] Created crew: ${savedCrew.id}');
      return savedCrew;
    } catch (e) {
      if (e is CrewException || e is CrewValidationException) {
        rethrow;
      }
      throw CrewException(
        'Failed to create crew: ${e.toString()}',
        code: CrewErrorCodes.unknownError,
        originalError: e,
      );
    }
  }

  /// Get crew by ID
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

  /// Get all crews for a user
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

  /// Get crews where user is the foreman
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

  /// Update crew information
  Future<bool> updateCrew({
    required String crewId,
    required String userId, // Must be foreman
    String? name,
    Map<String, dynamic>? jobPreferences,
  }) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException(
          'Crew not found',
          code: CrewErrorCodes.crewNotFound,
        );
      }

      if (crew.foremanId != userId) {
        throw CrewException(
          'Only foreman can update crew information',
          code: CrewErrorCodes.notCrewForeman,
        );
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (jobPreferences != null) {
        updateData['jobPreferences'] = jobPreferences;
      }

      if (updateData.length > 1) { // More than just updatedAt
        await _crewsCollection.doc(crewId).update(updateData);

        // Update related invitations if name changed
        if (name != null) {
          await _updateInvitationsForCrewNameChange(crewId, name.trim());
        }
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

  /// Invite a user to join a crew
  Future<CrewInvitation> inviteUserToCrew({
    required String crewId,
    required String inviterId,
    required String inviteeId,
    String? message,
  }) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException('Crew not found', code: CrewErrorCodes.crewNotFound);
      }

      if (crew.foremanId != inviterId) {
        throw CrewException('Only foreman can invite members', code: CrewErrorCodes.permissionDenied);
      }

      if (crew.memberIds.contains(inviteeId)) {
        throw Exception('User is already a member of this crew');
      }

      // Check for existing pending invitation
      final existingInvitations = await getInvitationsForCrew(crewId);
      if (existingInvitations.any((inv) =>
          inv.inviteeId == inviteeId && inv.status == CrewInvitationStatus.pending)) {
        throw Exception('User already has a pending invitation to this crew');
      }

      // Get user details
      final inviterDoc = await _firestore.collection('users').doc(inviterId).get();
      final inviteeDoc = await _firestore.collection('users').doc(inviteeId).get();

      if (!inviterDoc.exists || !inviteeDoc.exists) {
        throw Exception('User not found');
      }

      final inviterData = inviterDoc.data() as Map<String, dynamic>;
      final inviteeData = inviteeDoc.data() as Map<String, dynamic>;

      // Create invitation
      final now = Timestamp.now();
      final expiresAt = Timestamp.fromDate(
        now.toDate().add(const Duration(days: 7)),
      );

      final invitation = CrewInvitation(
        id: '', // Will be set by Firestore
        crewId: crewId,
        inviterId: inviterId,
        inviteeId: inviteeId,
        status: CrewInvitationStatus.pending,
        createdAt: now.toDate(),
        updatedAt: now.toDate(),
        expiresAt: expiresAt.toDate(),
        message: message,
        crewName: crew.name,
        inviterName: inviterData['displayName'] ??
                     '${inviterData['firstName'] ?? ''} ${inviterData['lastName'] ?? ''}'.trim(),
        inviteeName: inviteeData['displayName'] ??
                     '${inviteeData['firstName'] ?? ''} ${inviteeData['lastName'] ?? ''}'.trim(),
        jobDetails: crew.jobPreferences,
      );

      // Save to Firestore
      final docRef = await _crewsCollection
          .doc(crewId)
          .collection('invitations')
          .add(invitation.toFirestore());

      final savedInvitation = invitation.copyWith(id: docRef.id);

      // Send notification
      await _sendInvitationNotification(savedInvitation, inviterData, inviteeData);

      return savedInvitation;
    } catch (e) {
      if (e is CrewException) {
        rethrow;
      }
      throw CrewInvitationException(
        'Failed to send crew invitation: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Accept a crew invitation
  Future<bool> acceptInvitation(String invitationId, String userId) async {
    try {
      final invitation = await _getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }

      if (invitation.inviteeId != userId) {
        throw Exception('User cannot accept this invitation');
      }

      if (!invitation.canRespond) {
        throw Exception('Invitation cannot be accepted');
      }

      // Update invitation status
      await _crewsCollection
          .doc(invitation.crewId)
          .collection('invitations')
          .doc(invitationId)
          .update({
        'status': 'accepted',
        'updatedAt': Timestamp.now(),
      });

      // Add user to crew
      await _addUserToCrew(invitation.crewId, userId);

      // Send notification to inviter
      await _sendInvitationResponseNotification(invitation, 'accepted', userId);

      return true;
    } catch (e) {
      throw CrewInvitationException(
        'Failed to accept invitation: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Decline a crew invitation
  Future<bool> declineInvitation(String invitationId, String userId) async {
    try {
      final invitation = await _getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }

      if (invitation.inviteeId != userId) {
        throw Exception('User cannot decline this invitation');
      }

      if (!invitation.canRespond) {
        throw Exception('Invitation cannot be declined');
      }

      // Update invitation status
      await _crewsCollection
          .doc(invitation.crewId)
          .collection('invitations')
          .doc(invitationId)
          .update({
        'status': 'declined',
        'updatedAt': Timestamp.now(),
      });

      // Send notification to inviter
      await _sendInvitationResponseNotification(invitation, 'declined', userId);

      return true;
    } catch (e) {
      throw CrewInvitationException(
        'Failed to decline invitation: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Cancel a crew invitation
  Future<bool> cancelInvitation(String invitationId, String inviterId) async {
    try {
      final invitation = await _getInvitationById(invitationId);
      if (invitation == null) {
        throw Exception('Invitation not found');
      }

      if (invitation.inviterId != inviterId) {
        throw Exception('User cannot cancel this invitation');
      }

      if (invitation.status != CrewInvitationStatus.pending) {
        throw Exception('Invitation cannot be cancelled');
      }

      // Update invitation status
      await _crewsCollection
          .doc(invitation.crewId)
          .collection('invitations')
          .doc(invitationId)
          .update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      throw CrewInvitationException(
        'Failed to cancel invitation: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Remove member from crew
  Future<bool> removeMemberFromCrew({
    required String crewId,
    required String foremanId,
    required String memberId,
  }) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException('Crew not found', code: CrewErrorCodes.crewNotFound);
      }

      if (crew.foremanId != foremanId) {
        throw CrewException('Only foreman can remove members', code: CrewErrorCodes.permissionDenied);
      }

      if (memberId == crew.foremanId) {
        throw CrewException('Cannot remove foreman from crew', code: CrewErrorCodes.cannotRemoveForeman);
      }

      if (!crew.memberIds.contains(memberId)) {
        throw CrewException('User is not a member of this crew', code: CrewErrorCodes.notCrewMember);
      }

      // Remove member from crew
      await _crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': Timestamp.now(),
      });

      // Update user's crew list
      await _updateUserCrewList(memberId, crewId, remove: true);

      // Cancel pending invitations
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

  /// Leave a crew
  Future<bool> leaveCrew({
    required String crewId,
    required String userId,
  }) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException('Crew not found', code: CrewErrorCodes.crewNotFound);
      }

      if (crew.foremanId == userId) {
        throw CrewException(
          'Foreman cannot leave crew. Transfer or delete crew first.',
          code: CrewErrorCodes.cannotRemoveForeman,
        );
      }

      if (!crew.memberIds.contains(userId)) {
        throw CrewException('User is not a member of this crew', code: CrewErrorCodes.notCrewMember);
      }

      // Remove member from crew
      await _crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
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

  /// Delete a crew
  Future<bool> deleteCrew({
    required String crewId,
    required String foremanId,
  }) async {
    try {
      final crew = await getCrewById(crewId);
      if (crew == null) {
        throw CrewException('Crew not found', code: CrewErrorCodes.crewNotFound);
      }

      if (crew.foremanId != foremanId) {
        throw CrewException('Only foreman can delete crew', code: CrewErrorCodes.notCrewForeman);
      }

      if (crew.memberIds.length > 1) {
        throw CrewException(
          'Cannot delete crew with other members. Remove all members first.',
          code: CrewErrorCodes.cannotRemoveForeman,
        );
      }

      // Cancel all invitations
      final invitations = await getInvitationsForCrew(crewId);
      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending) {
          try {
            await cancelInvitation(invitation.id, foremanId);
          } catch (e) {
            debugPrint('[UnifiedCrewService] Failed to cancel invitation: $e');
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

  /// Get invitations for a user
  Future<List<CrewInvitation>> getInvitationsForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collectionGroup('invitations')
          .where('inviteeId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _mapInvitationFromDoc(doc))
          .where((invitation) => !invitation.isExpired)
          .toList();
    } catch (e) {
      throw CrewInvitationException(
        'Failed to get invitations for user: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get invitations for a crew
  Future<List<CrewInvitation>> getInvitationsForCrew(String crewId) async {
    try {
      final QuerySnapshot snapshot = await _crewsCollection
          .doc(crewId)
          .collection('invitations')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _mapInvitationFromDoc(doc))
          .toList();
    } catch (e) {
      throw CrewInvitationException(
        'Failed to get invitations for crew: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get pending invitations for a user
  Future<List<CrewInvitation>> getPendingInvitationsForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collectionGroup('invitations')
          .where('inviteeId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _mapInvitationFromDoc(doc))
          .where((invitation) => !invitation.isExpired)
          .toList();
    } catch (e) {
      throw CrewInvitationException(
        'Failed to get pending invitations: ${e.toString()}',
        originalError: e,
      );
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
          .where('name', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
          .orderBy('name')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw CrewException(
        'Failed to search crews: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Stream of crew updates
  Stream<Crew?> streamCrew(String crewId) {
    return _crewsCollection.doc(crewId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Crew.fromFirestore(doc);
    });
  }

  /// Stream of crews for a user
  Stream<List<Crew>> streamCrewsForUser(String userId) {
    return _crewsCollection
        .where('memberIds', arrayContains: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Crew.fromFirestore(doc))
            .toList());
  }

  /// Stream of invitations for a user
  Stream<List<CrewInvitation>> streamInvitationsForUser(String userId) {
    return _firestore
        .collectionGroup('invitations')
        .where('inviteeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _mapInvitationFromDoc(doc))
            .where((invitation) => !invitation.isExpired)
            .toList());
  }

  /// Clean up expired invitations (background task)
  Future<void> cleanupExpiredInvitations() async {
    try {
      final now = Timestamp.now();

      final QuerySnapshot snapshot = await _firestore
          .collectionGroup('invitations')
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isLessThan: now)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': now,
        });
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        debugPrint('[UnifiedCrewService] Cleaned up ${snapshot.docs.length} expired invitations');
      }
    } catch (e) {
      debugPrint('[UnifiedCrewService] Failed to cleanup expired invitations: $e');
    }
  }

  // Private helper methods

  Future<CrewInvitation?> _getInvitationById(String invitationId) async {
    final QuerySnapshot snapshot = await _firestore
        .collectionGroup('invitations')
        .where(FieldPath.documentId, isEqualTo: invitationId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return _mapInvitationFromDoc(snapshot.docs.first);
  }

  CrewInvitation _mapInvitationFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrewInvitation(
      id: doc.id,
      crewId: data['crewId'] ?? '',
      inviterId: data['inviterId'] ?? '',
      inviteeId: data['inviteeId'] ?? '',
      status: CrewInvitationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CrewInvitationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
                  DateTime.now().add(const Duration(days: 7)),
      message: data['message'],
      crewName: data['crewName'] ?? '',
      inviterName: data['inviterName'] ?? '',
      inviteeName: data['inviteeName'] ?? '',
      jobDetails: data['jobDetails'],
    );
  }

  Future<void> _addUserToCrew(String crewId, String userId) async {
    await _crewsCollection.doc(crewId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'updatedAt': Timestamp.now(),
    });

    await _firestore.collection('users').doc(userId).update({
      'crewIds': FieldValue.arrayUnion([crewId]),
    });
  }

  Future<void> _updateUserCrewList(String userId, String crewId, {bool remove = false}) async {
    try {
      final fieldUpdate = remove
          ? FieldValue.arrayRemove([crewId])
          : FieldValue.arrayUnion([crewId]);

      await _firestore.collection('users').doc(userId).update({
        'crewIds': fieldUpdate,
      });
    } catch (e) {
      debugPrint('[UnifiedCrewService] Failed to update user crew list: $e');
    }
  }

  Future<void> _updateInvitationsForCrewNameChange(String crewId, String newName) async {
    try {
      final invitations = await getInvitationsForCrew(crewId);

      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending) {
          await _crewsCollection
              .doc(crewId)
              .collection('invitations')
              .doc(invitation.id)
              .update({'crewName': newName});
        }
      }
    } catch (e) {
      debugPrint('[UnifiedCrewService] Failed to update invitations: $e');
    }
  }

  Future<void> _cancelPendingInvitations(String crewId, String memberId) async {
    try {
      final invitations = await getInvitationsForCrew(crewId);

      for (final invitation in invitations) {
        if (invitation.status == CrewInvitationStatus.pending &&
            invitation.inviteeId == memberId) {
          await cancelInvitation(invitation.id, invitation.inviterId);
        }
      }
    } catch (e) {
      debugPrint('[UnifiedCrewService] Failed to cancel pending invitations: $e');
    }
  }

  Future<void> _sendInvitationNotification(
    CrewInvitation invitation,
    Map<String, dynamic> inviterData,
    Map<String, dynamic> inviteeData,
  ) async {
    try {
      final fcmToken = inviteeData['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      final title = 'Crew Invitation';
      final body = '${invitation.inviterName} invited you to join ${invitation.crewName}';

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
      debugPrint('[UnifiedCrewService] Failed to send invitation notification: $e');
    }
  }

  Future<void> _sendInvitationResponseNotification(
    CrewInvitation invitation,
    String response,
    String userId,
  ) async {
    try {
      final inviterDoc = await _firestore.collection('users').doc(invitation.inviterId).get();
      if (!inviterDoc.exists) return;

      final inviterData = inviterDoc.data() as Map<String, dynamic>;
      final inviterFcmToken = inviterData['fcmToken'] as String?;

      if (inviterFcmToken == null || inviterFcmToken.isEmpty) {
        return;
      }

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
      debugPrint('[UnifiedCrewService] Failed to send response notification: $e');
    }
  }
}