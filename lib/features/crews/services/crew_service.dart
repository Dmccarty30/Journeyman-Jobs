import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

import '../models/crew.dart';
import '../../../models/user_model.dart';
import '../../../services/analytics_service.dart';
import '../../../services/enhanced_notification_service.dart';

/// Service for managing IBEW electrical worker crews
/// 
/// Provides comprehensive CRUD operations for crew management including:
/// - Creating and managing crews with IBEW context
/// - Storm work and emergency crew coordination
/// - Member invitation and management
/// - Job sharing and coordination
/// - Analytics and performance tracking
class CrewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final http.Client _httpClient;
  final AnalyticsService _analytics;
  final EnhancedNotificationService _notifications;

  // Collection references
  static const String _crewsCollection = 'crews';
  static const String _usersCollection = 'users';
  static const String _crewMembersSubcollection = 'members';
  
  // Performance constants
  static const int _defaultLimit = 20;
  static const int _maxLimit = 100;
  
  CrewService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    http.Client? httpClient,
    AnalyticsService? analytics,
    EnhancedNotificationService? notifications,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _httpClient = httpClient ?? http.Client(),
       _analytics = analytics ?? AnalyticsService(),
       _notifications = notifications ?? EnhancedNotificationService();

  /// Create a new crew for IBEW electrical workers
  /// 
  /// Validates crew data, creates Firestore document, and sets up initial
  /// crew structure with proper member management.
  /// 
  /// Returns the created crew ID on success.
  /// Throws [Exception] if validation fails or creation errors occur.
  Future<String> createCrew(Crew crew) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'User must be authenticated to create crews');
    }

    try {
      // Validate crew data
      if (!_validateCrewData(crew)) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Invalid crew data provided');
      }

      // Ensure creator is added as member and admin
      final updatedCrew = crew.copyWith(
        createdBy: currentUser.uid,
        memberIds: [...crew.memberIds, currentUser.uid].toSet().toList(),
        adminIds: [...crew.adminIds, currentUser.uid].toSet().toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create crew document
      final docRef = _firestore.collection(_crewsCollection).doc();
      final crewWithId = updatedCrew.copyWith(id: docRef.id);
      
      await docRef.set(crewWithId.toFirestore());

      // Track analytics
      await _analytics.trackEvent('crew_created', {
        'crew_id': docRef.id,
        'crew_name': crew.name,
        'member_count': updatedCrew.memberIds.length,
        'job_types': crew.jobTypes.map((type) => type.name).toList(),
        'classifications': crew.classifications,
        'storm_work': crew.availableForStormWork,
        'emergency_work': crew.availableForEmergencyWork,
      });

      developer.log(
        'Crew created successfully',
        name: 'CrewService',
        error: null,
        stackTrace: null,
      );

      return docRef.id;
    } catch (e) {
      developer.log(
        'Failed to create crew',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      await _analytics.trackEvent('crew_creation_failed', {
        'error': e.toString(),
        'crew_name': crew.name,
      });
      
      rethrow;
    }
  }

  /// Get a specific crew by ID
  /// 
  /// Returns crew data if found and user has permission to view.
  /// Returns null if crew doesn't exist or user lacks permission.
  Future<Crew?> getCrew(String crewId) async {
    try {
      final doc = await _firestore
          .collection(_crewsCollection)
          .doc(crewId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final crew = Crew.fromFirestore(doc);
      
      // Check if user can view this crew (member or public)
      final currentUser = _auth.currentUser;
      if (currentUser != null && 
          (!crew.isPublic && !crew.isMember(currentUser.uid))) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Access denied: You are not a member of this crew');
      }

      return crew;
    } catch (e) {
      developer.log(
        'Failed to get crew',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      if (e.toString().contains('Access denied')) {
        rethrow;
      }
      
      return null;
    }
  }

  /// Update an existing crew
  /// 
  /// Only crew admins can update crew information.
  /// Updates timestamp and tracks changes in analytics.
  Future<void> updateCrew(Crew crew) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'User must be authenticated to update crews');
    }

    try {
      // Validate crew data
      if (!_validateCrewData(crew)) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Invalid crew data provided');
      }

      // Check if user is admin
      if (!crew.isAdmin(currentUser.uid)) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Access denied: Only crew admins can update crew information');
      }

      // Update crew with new timestamp
      final updatedCrew = crew.copyWith(updatedAt: DateTime.now());
      
      await _firestore
          .collection(_crewsCollection)
          .doc(crew.id)
          .update(updatedCrew.toFirestore());

      // Track analytics
      await _analytics.trackEvent('crew_updated', {
        'crew_id': crew.id,
        'crew_name': crew.name,
        'updated_by': currentUser.uid,
      });

      developer.log(
        'Crew updated successfully',
        name: 'CrewService',
        error: null,
        stackTrace: null,
      );
    } catch (e) {
      developer.log(
        'Failed to update crew',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      await _analytics.trackEvent('crew_update_failed', {
        'error': e.toString(),
        'crew_id': crew.id,
      });
      
      rethrow;
    }
  }

  /// Delete a crew
  /// 
  /// Only crew creator can delete. Removes all subcollections and notifies members.
  Future<void> deleteCrew(String crewId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'User must be authenticated to delete crews');
    }

    try {
      // Get crew to validate permissions
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Crew not found');
      }

      // Only creator can delete
      if (crew.createdBy != currentUser.uid) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Access denied: Only crew creator can delete crew');
      }

      // Check if crew has active jobs
      if (crew.hasActiveJobs) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Cannot delete crew with active jobs');
      }

      // Notify all members about crew deletion
      for (final memberId in crew.memberIds) {
        if (memberId != currentUser.uid) {
          await _notifications.sendNotification(
            userId: memberId,
            title: 'Crew Deleted',
            body: 'The crew "${crew.name}" has been deleted by the creator.',
            data: {
              'type': 'crew_deleted',
              'crew_id': crewId,
              'crew_name': crew.name,
            },
          );
        }
      }

      // Delete crew document
      await _firestore.collection(_crewsCollection).doc(crewId).delete();

      // Track analytics
      await _analytics.trackEvent('crew_deleted', {
        'crew_id': crewId,
        'crew_name': crew.name,
        'deleted_by': currentUser.uid,
        'member_count': crew.memberIds.length,
      });

      developer.log(
        'Crew deleted successfully',
        name: 'CrewService',
        error: null,
        stackTrace: null,
      );
    } catch (e) {
      developer.log(
        'Failed to delete crew',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      await _analytics.trackEvent('crew_deletion_failed', {
        'error': e.toString(),
        'crew_id': crewId,
      });
      
      rethrow;
    }
  }

  /// Get crews where user is a member
  /// 
  /// Returns paginated list of crews the current user belongs to.
  Future<List<Crew>> getCrewsByUser(String userId, {
    int limit = _defaultLimit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      limit = limit.clamp(1, _maxLimit);
      
      Query query = _firestore
          .collection(_crewsCollection)
          .where('memberIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log(
        'Failed to get crews by user',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      return [];
    }
  }

  /// Get all crews for a user (alternative method name for compatibility)
  /// 
  /// Returns all crews where the user is a member, including stats.
  Future<List<Crew>> getUserCrews(String userId) async {
    try {
      final crews = await getCrewsByUser(userId, limit: _maxLimit);
      
      // Track analytics
      await _analytics.trackEvent('user_crews_retrieved', {
        'user_id': userId,
        'crew_count': crews.length,
      });
      
      return crews;
    } catch (e) {
      developer.log(
        'Failed to get user crews',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      return [];
    }
  }

  /// Search crews by various criteria
  /// 
  /// Supports searching by name, location, job types, and classifications.
  Future<List<Crew>> searchCrews({
    String? query,
    List<String>? jobTypes,
    List<String>? classifications,
    String? location,
    double? maxDistance,
    bool? availableForStormWork,
    bool? availableForEmergencyWork,
    bool publicOnly = false,
    int limit = _defaultLimit,
  }) async {
    try {
      limit = limit.clamp(1, _maxLimit);
      
      Query firestoreQuery = _firestore
          .collection(_crewsCollection)
          .where('isActive', isEqualTo: true);

      if (publicOnly) {
        firestoreQuery = firestoreQuery.where('isPublic', isEqualTo: true);
      }

      if (availableForStormWork != null) {
        firestoreQuery = firestoreQuery.where(
          'availableForStormWork', 
          isEqualTo: availableForStormWork,
        );
      }

      if (availableForEmergencyWork != null) {
        firestoreQuery = firestoreQuery.where(
          'availableForEmergencyWork', 
          isEqualTo: availableForEmergencyWork,
        );
      }

      firestoreQuery = firestoreQuery
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      final snapshot = await firestoreQuery.get();
      List<Crew> crews = snapshot.docs
          .map((doc) => Crew.fromFirestore(doc))
          .toList();

      // Apply client-side filtering for complex queries
      if (query != null && query.isNotEmpty) {
        crews = crews.where((crew) =>
          crew.name.toLowerCase().contains(query.toLowerCase()) ||
          (crew.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }

      if (jobTypes != null && jobTypes.isNotEmpty) {
        crews = crews.where((crew) =>
          crew.jobTypes.any((jobType) => jobTypes.contains(jobType.name))
        ).toList();
      }

      if (classifications != null && classifications.isNotEmpty) {
        crews = crews.where((crew) =>
          crew.classifications.any((classification) => 
            classifications.contains(classification))
        ).toList();
      }

      // Track search analytics
      await _analytics.trackEvent('crews_searched', {
        'query': query,
        'job_types': jobTypes,
        'classifications': classifications,
        'results_count': crews.length,
        'storm_work': availableForStormWork,
        'emergency_work': availableForEmergencyWork,
      });

      return crews;
    } catch (e) {
      developer.log(
        'Failed to search crews',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      return [];
    }
  }

  /// Add member to crew
  /// 
  /// Handles crew member invitations and direct additions for admins.
  Future<void> addMemberToCrew(String crewId, String userId, {
    bool sendInvitation = true,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'User must be authenticated to add members');
    }

    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Crew not found');
      }

      // Check permissions
      if (!crew.isAdmin(currentUser.uid)) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Access denied: Only crew admins can add members');
      }

      // Check if crew is full
      if (crew.isFull) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Crew is full (${crew.memberIds.length}/${crew.maxMembers})');
      }

      // Check if user is already a member
      if (crew.isMember(userId)) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'User is already a member of this crew');
      }

      List<String> updatedMemberIds = List.from(crew.memberIds);
      List<String> updatedInvitedIds = List.from(crew.invitedMemberIds);

      if (sendInvitation) {
        // Add to invited list
        if (!updatedInvitedIds.contains(userId)) {
          updatedInvitedIds.add(userId);
        }
        
        // Send invitation notification
        await _notifications.sendNotification(
          userId: userId,
          title: 'Crew Invitation',
          body: 'You\'ve been invited to join "${crew.name}"',
          data: {
            'type': 'crew_invitation',
            'crew_id': crewId,
            'crew_name': crew.name,
            'invited_by': currentUser.uid,
          },
        );
      } else {
        // Direct addition (admin privilege)
        updatedMemberIds.add(userId);
        updatedInvitedIds.remove(userId);
      }

      // Update crew
      final updatedCrew = crew.copyWith(
        memberIds: updatedMemberIds,
        invitedMemberIds: updatedInvitedIds,
        updatedAt: DateTime.now(),
      );

      await updateCrew(updatedCrew);

      // Track analytics
      await _analytics.trackEvent(
        sendInvitation ? 'crew_member_invited' : 'crew_member_added',
        {
          'crew_id': crewId,
          'member_id': userId,
          'added_by': currentUser.uid,
          'crew_size': updatedCrew.memberIds.length,
        },
      );

      developer.log(
        sendInvitation ? 'Member invited to crew' : 'Member added to crew',
        name: 'CrewService',
        error: null,
        stackTrace: null,
      );
    } catch (e) {
      developer.log(
        'Failed to add member to crew',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      rethrow;
    }
  }

  /// Remove member from crew
  /// 
  /// Handles member removal with proper notifications and validation.
  Future<void> removeMemberFromCrew(String crewId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'User must be authenticated to remove members');
    }

    try {
      final crew = await getCrew(crewId);
      if (crew == null) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Crew not found');
      }

      // Check permissions - admins can remove others, members can remove themselves
      if (!crew.isAdmin(currentUser.uid) && currentUser.uid != userId) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Access denied: You can only remove yourself or you must be an admin');
      }

      // Cannot remove crew creator
      if (userId == crew.createdBy) {
        throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Cannot remove crew creator');
      }

      // Update member lists
      final updatedMemberIds = crew.memberIds.where((id) => id != userId).toList();
      final updatedInvitedIds = crew.invitedMemberIds.where((id) => id != userId).toList();
      final updatedAdminIds = crew.adminIds.where((id) => id != userId).toList();

      // Clear foreman if being removed
      final updatedForemanId = crew.foremanId == userId ? null : crew.foremanId;

      final updatedCrew = crew.copyWith(
        memberIds: updatedMemberIds,
        invitedMemberIds: updatedInvitedIds,
        adminIds: updatedAdminIds,
        foremanId: updatedForemanId,
        updatedAt: DateTime.now(),
      );

      await updateCrew(updatedCrew);

      // Notify the removed user (unless they removed themselves)
      if (currentUser.uid != userId) {
        await _notifications.sendNotification(
          userId: userId,
          title: 'Removed from Crew',
          body: 'You have been removed from "${crew.name}"',
          data: {
            'type': 'crew_member_removed',
            'crew_id': crewId,
            'crew_name': crew.name,
            'removed_by': currentUser.uid,
          },
        );
      }

      // Track analytics
      await _analytics.trackEvent('crew_member_removed', {
        'crew_id': crewId,
        'member_id': userId,
        'removed_by': currentUser.uid,
        'self_removal': currentUser.uid == userId,
        'new_crew_size': updatedCrew.memberIds.length,
      });

      developer.log(
        'Member removed from crew',
        name: 'CrewService',
        error: null,
        stackTrace: null,
      );
    } catch (e) {
      developer.log(
        'Failed to remove member from crew',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      rethrow;
    }
  }

  /// Validate crew data before operations
  /// 
  /// Ensures all required fields are present and valid for IBEW context.
  bool _validateCrewData(Crew crew) {
    try {
      // Basic validation
      if (crew.name.trim().isEmpty) {
        return false;
      }

      if (crew.maxMembers < 1 || crew.maxMembers > 50) {
        return false;
      }

      if (crew.travelRadius < 0 || crew.travelRadius > 2000) {
        return false;
      }

      // IBEW-specific validation
      if (crew.classifications.isEmpty) {
        return false;
      }

      // Validate classifications against IBEW standards
      final validClassifications = [
        'Inside Wireman',
        'Journeyman Lineman', 
        'Tree Trimmer',
        'Equipment Operator',
        'Inside Journeyman Electrician',
      ];

      final hasValidClassification = crew.classifications
          .any((classification) => validClassifications.contains(classification));

      if (!hasValidClassification) {
        return false;
      }

      // Validate job types
      if (crew.jobTypes.isEmpty) {
        return false;
      }

      // Location validation if provided
      if (crew.hasLocation) {
        if (crew.latitude! < -90 || crew.latitude! > 90 ||
            crew.longitude! < -180 || crew.longitude! > 180) {
          return false;
        }
      }

      // Rate validation if provided
      if (crew.hourlyRate != null && crew.hourlyRate! <= 0) {
        return false;
      }

      return true;
    } catch (e) {
      developer.log(
        'Crew validation error',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      return false;
    }
  }

  /// Stream of crews for real-time updates
  /// 
  /// Provides real-time updates for crew lists and individual crews.
  Stream<List<Crew>> getCrewsStream({
    String? userId,
    bool publicOnly = false,
    int limit = _defaultLimit,
  }) {
    try {
      Query query = _firestore
          .collection(_crewsCollection)
          .where('isActive', isEqualTo: true);

      if (userId != null) {
        query = query.where('memberIds', arrayContains: userId);
      }

      if (publicOnly) {
        query = query.where('isPublic', isEqualTo: true);
      }

      query = query
          .orderBy('updatedAt', descending: true)
          .limit(limit.clamp(1, _maxLimit));

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => Crew.fromFirestore(doc)).toList());
    } catch (e) {
      developer.log(
        'Failed to create crews stream',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      return Stream.value([]);
    }
  }

  /// Stream of a specific crew for real-time updates
  Stream<Crew?> getCrewStream(String crewId) {
    try {
      return _firestore
          .collection(_crewsCollection)
          .doc(crewId)
          .snapshots()
          .map((doc) => doc.exists ? Crew.fromFirestore(doc) : null);
    } catch (e) {
      developer.log(
        'Failed to create crew stream',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      return Stream.value(null);
    }
  }

  /// Update crew activity timestamp
  /// 
  /// Called when crew has activity (messages, job updates, etc.)
  Future<void> updateCrewActivity(String crewId) async {
    try {
      await _firestore
          .collection(_crewsCollection)
          .doc(crewId)
          .update({
        'lastActivityAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(
        'Failed to update crew activity',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Batch operations for crew management
  /// 
  /// Allows efficient batch updates for multiple crews.
  Future<void> batchUpdateCrews(List<Crew> crews) async {
    if (crews.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final crew in crews) {
        if (!_validateCrewData(crew)) {
          throw CrewServiceException(CrewServiceExceptionCodes.unauthorized, 'Invalid crew data for crew: ${crew.id}');
        }

        final docRef = _firestore.collection(_crewsCollection).doc(crew.id);
        batch.update(docRef, crew.toFirestore());
      }

      await batch.commit();

      developer.log(
        'Batch updated ${crews.length} crews',
        name: 'CrewService',
        error: null,
        stackTrace: null,
      );
    } catch (e) {
      developer.log(
        'Failed to batch update crews',
        name: 'CrewService',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      rethrow;
    }
  }

  /// Dispose resources when service is no longer needed
  void dispose() {
    // Clean up any resources if needed
    // HTTP client and other services handle their own disposal
  }
}

/// Exception thrown by CrewService operations
class CrewServiceException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const CrewServiceException(this.code, this.message, [this.details]);

  @override
  String toString() => 'CrewServiceException($code): $message';
}

/// Exception codes for crew service operations
class CrewServiceExceptionCodes {
  static const String invalidInput = 'invalid-input';
  static const String unauthorized = 'unauthorized';
  static const String notFound = 'not-found';
  static const String accessDenied = 'access-denied';
  static const String crewFull = 'crew-full';
  static const String alreadyMember = 'already-member';
  static const String activeJobs = 'active-jobs';
  static const String networkError = 'network-error';
  static const String unknownError = 'unknown-error';
}
