import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../models/crew_preferences.dart';
import '../models/crew_stats.dart';
import 'job_matching_service_impl.dart';
import 'job_sharing_service_impl.dart';
import 'package:journeyman_jobs/utils/validation.dart';
import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';
import 'package:journeyman_jobs/domain/exceptions/crew_exception.dart';
import 'package:journeyman_jobs/domain/exceptions/member_exception.dart';
import 'package:journeyman_jobs/domain/exceptions/messaging_exception.dart';
import '../../../services/offline_data_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../utils/structured_logging.dart';

import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/enums/permission.dart';
import 'package:journeyman_jobs/domain/enums/invitation_status.dart';

// ============================================================================
// DEV MODE: Permission matrix disabled for development testing
// ============================================================================
// TODO: Re-enable RolePermissions class before production deployment
//
// Original RolePermissions class provided role-based access control:
// - Foreman: Full permissions (create, update, delete, invite, remove, etc.)
// - Lead: Limited permissions (invite, share, moderate, view stats)
// - Member: Basic permissions (share jobs, view stats)
//
// Commented out to allow unrestricted crew operations during development.
// ============================================================================

/*
// Permission matrix
class RolePermissions {
  static const Map<MemberRole, Set<Permission>> permissions = {
    MemberRole.foreman: {
      Permission.createCrew,
      Permission.updateCrew,
      Permission.deleteCrew,
      Permission.inviteMember,
      Permission.removeMember,
      Permission.updateRole,
      Permission.shareJob,
      Permission.moderateContent,
      Permission.viewStats,
      Permission.manageSettings,
    },
    MemberRole.lead: {
      Permission.inviteMember,
      Permission.shareJob,
      Permission.moderateContent,
      Permission.viewStats,
    },
    MemberRole.member: {
      Permission.shareJob,
      Permission.viewStats,
    },
  };

  static bool hasPermission(MemberRole role, Permission permission) {
    return permissions[role]?.contains(permission) ?? false;
  }
}
*/

class CrewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JobSharingService jobSharingService;
  final OfflineDataService _offlineDataService;
  final ConnectivityService _connectivityService;
  final JobMatchingService? _jobMatchingService;

  // Collections
  CollectionReference get crewsCollection => _firestore.collection('crews');

  CrewService({
    required this.jobSharingService,
    required OfflineDataService offlineDataService,
    required ConnectivityService connectivityService,
    JobMatchingService? jobMatchingService,
  }) : _offlineDataService = offlineDataService,
       _connectivityService = connectivityService,
       _jobMatchingService = jobMatchingService {
    startJobMatching();
  }

  // Start/Stop job matching
  void startJobMatching() {
    _jobMatchingService?.startJobMatchingListener();
  }

  void stopJobMatching() {
    _jobMatchingService?.stopJobMatchingListener();
  }

  // Crew ID generation
  Future<String> _getNextCrewId(String crewName) async {
    final counterRef = _firestore.collection('counters').doc('crews');
    
    final result = await _firestore.runTransaction<int>((transaction) async {
      final counterDoc = await transaction.get(counterRef);
      final currentCount = (counterDoc.data()?['count'] as int?) ?? 0;
      final newCount = currentCount + 1;
      
      transaction.set(counterRef, {'count': newCount}, SetOptions(merge: true));
      return newCount;
    });
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$crewName-$result-$timestamp';
  }

  // Rate limiting helpers
  Future<bool> _checkCrewCreationLimit(String userId) async {
    final counterRef = _firestore.collection('counters').doc('crews').collection('user_crews').doc(userId);
    final doc = await counterRef.get();
    final count = (doc.data()?['count'] as int?) ?? 0;
    return count < 3;
  }

  Future<void> _incrementCrewCreationCount(String userId) async {
    final counterRef = _firestore.collection('counters').doc('crews').collection('user_crews').doc(userId);
    await counterRef.set({
      'count': FieldValue.increment(1),
      'lastCreated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> _checkInvitationLimit(String userId) async {
    final counterRef = _firestore.collection('counters').doc('invitations').collection('daily').doc(userId);
    final today = DateTime.now().toIso8601String().split('T')[0];

    final doc = await counterRef.get();
    if (!doc.exists || doc.data()?['date'] != today) {
      await counterRef.set({'count': 1, 'date': today});
      return true;
    }

    final count = doc.data()!['count'] as int;
    return count < 5;
  }

  Future<bool> _checkOverallInvitationLimit(String userId) async {
    final counterRef = _firestore.collection('counters').doc('invitations').collection('lifetime').doc(userId);
    final doc = await counterRef.get();
    final count = (doc.data()?['total'] as int?) ?? 0;
    return count < 100;
  }

  Future<void> _incrementInvitationCount(String userId) async {
    final counterRef = _firestore.collection('counters').doc('invitations').collection('daily').doc(userId);
    final today = DateTime.now().toIso8601String().split('T')[0];

    await counterRef.update({
      'count': FieldValue.increment(1),
      'date': today,
    }).catchError((_) {
      counterRef.set({'count': 1, 'date': today});
    });

    final lifetimeCounterRef = _firestore.collection('counters').doc('invitations').collection('lifetime').doc(userId);
    await lifetimeCounterRef.set({
      'total': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<bool> canSendMessage(String userId, String crewId) async {
    final counterRef = _firestore.collection('counters').doc('messages').collection('minute').doc('${userId}_$crewId');
    final now = DateTime.now();
    final minuteKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour}-${now.minute}';

    final doc = await counterRef.get();
    if (!doc.exists || doc.data()?['minute'] != minuteKey) {
      await counterRef.set({'count': 1, 'minute': minuteKey});
      return true;
    }

    final count = doc.data()!['count'] as int;
    return count < 10;
  }

  // Retry utility
  Future<T> _retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration baseDelay = const Duration(milliseconds: 100),
  }) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        await GeneralValidation.exponentialBackoff(
          attempt: attempt,
          baseDelay: baseDelay,
          maxAttempts: maxAttempts,
        );
      }
    }
    throw AppException('Operation failed after multiple retries', code: 'retry-failed');
  }

  // Abuse reporting
  Future<void> reportAbuse({
    required String crewId,
    required String reporterId,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    final report = {
      'crewId': crewId,
      'reporterId': reporterId,
      'targetId': targetId,
      'reason': reason,
      'details': details ?? '',
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    await _firestore.collection('abuse_reports').add(report);
  }

  // Create crew with validation
  Future<void> createCrew({
    required String name,
    required String foremanId,
    required CrewPreferences preferences,
    String? logoUrl,
  }) async {
    try {
      final nameError = CrewValidation.validateCrewName(name);
      if (nameError != null) throw CrewException(nameError, code: 'invalid-crew-name');

      final isUnique = await CrewValidation.isCrewNameUnique(name, _firestore);
      if (!isUnique) throw CrewException('Crew name already exists', code: 'crew-name-exists');

      // Assuming foremanId is a valid user ID, not necessarily an email.
      // If it's an email, then GeneralValidation.isValidEmail(foremanId) is appropriate.
      // For now, I'll assume it's a user ID string and skip email validation here.
      // if (!GeneralValidation.isValidEmail(foremanId)) {
      //   throw CrewException('Invalid foreman ID format', code: 'invalid-foreman-id');
      // }

      // DEV MODE: Crew creation limit check bypassed for development testing
      // TODO: Re-enable crew creation limit before production deployment
      /* PRODUCTION CODE:
      if (!await _checkCrewCreationLimit(foremanId)) {
        throw CrewException('Maximum crew limit reached (3 crews per user)', code: 'crew-limit-reached');
      }
      */

      if (!_connectivityService.isOnline) {
        // Offline: Store crew locally and mark as dirty
        final crewId = 'offline_${DateTime.now().millisecondsSinceEpoch}'; // Generate a temporary ID for offline
        final crew = Crew(
          id: crewId,
          name: name,
          foremanId: foremanId,
          memberIds: [foremanId],
          preferences: preferences,
          createdAt: DateTime.now(),
          roles: {foremanId: MemberRole.foreman},
          stats: CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: DateTime.now(),
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          lastActivityAt: DateTime.now(),
        );
        await _offlineDataService.storeCrewsOffline([crew]);
        await _offlineDataService.markDataDirty('crew_$crewId', crew.toFirestore());
        return; // Operation completed offline
      }

      await _retryWithBackoff(operation: () async {
        final crewId = await _getNextCrewId(name);
        final crew = Crew(
          id: crewId,
          name: name,
          foremanId: foremanId,
          memberIds: [foremanId],
          preferences: preferences,
          createdAt: DateTime.now(),
          roles: {foremanId: MemberRole.foreman},
          stats: CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: DateTime.now(),
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          lastActivityAt: DateTime.now(),
        );

        // Ensure foreman is added to members subcollection with correct role
        final member = CrewMember(
          userId: foremanId,
          crewId: crewId,
          role: MemberRole.foreman,
          joinedAt: DateTime.now(),
          permissions: MemberPermissions.fromRole(MemberRole.foreman),
          isAvailable: true,
          lastActive: DateTime.now(),
          isActive: true,
        );

        // Use transaction to ensure both crew creation and member addition succeed together
        await _firestore.runTransaction((transaction) async {
          transaction.set(_firestore.collection('crews').doc(crewId), crew.toFirestore());
          transaction.set(
            _firestore.collection('crews').doc(crewId).collection('members').doc(foremanId),
            member.toFirestore()
          );
        });

        await _incrementCrewCreationCount(foremanId);
      });
    } on CrewException {
      rethrow; // Rethrow custom exceptions directly
    } on FirebaseException catch (e) {
      // Provide more specific error messages for common Firestore errors
      if (e.code == 'permission-denied') {
        throw CrewException(
          'Permission denied. You may not have the required privileges to create a crew. '
          'Please ensure you are authenticated and try again. '
          'If the problem persists, contact support.',
          code: 'permission-denied'
        );
      } else if (e.code == 'unauthenticated') {
        throw CrewException(
          'Authentication required. Please sign in to create a crew.',
          code: 'unauthenticated'
        );
      } else if (e.code == 'not-found') {
        throw CrewException(
          'Database collection not found. Please try again later.',
          code: 'collection-not-found'
        );
      } else if (e.code == 'already-exists') {
        throw CrewException(
          'A crew with this ID already exists. Please try again.',
          code: 'crew-already-exists'
        );
      } else {
        throw CrewException('Firestore error creating crew: ${e.message}', code: e.code);
      }
    } catch (e) {
      throw CrewException('An unexpected error occurred while creating crew: $e', code: 'unknown-error');
    }
  }

  // Get crew
  Future<Crew?> getCrew(String crewId) async {
    try {
      if (_connectivityService.isOnline) {
        final doc = await _retryWithBackoff(operation: () => _firestore.collection('crews').doc(crewId).get());
        if (doc.exists) {
          final crew = Crew.fromFirestore(doc);
          await _offlineDataService.storeCrewsOffline([crew]); // Cache the fetched crew
          return crew;
        }
      } else {
        // Attempt to get from offline cache
        final offlineCrews = await _offlineDataService.getOfflineCrews();
        return offlineCrews.firstWhere((crew) => crew.id == crewId, orElse: () => throw CrewException('Crew not found in offline cache', code: 'crew-not-found-offline'));
      }
      return null;
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error getting crew: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while getting crew: $e', code: 'unknown-error');
    }
  }

  // Update crew
  Future<void> updateCrew({
    required String crewId,
    String? name,
    String? logoUrl,
    CrewPreferences? preferences,
  }) async {
    try {
      if (name != null) {
        final nameError = CrewValidation.validateCrewName(name);
        if (nameError != null) throw CrewException(nameError, code: 'invalid-crew-name');

        final isUnique = await CrewValidation.isCrewNameUnique(name, _firestore);
        if (!isUnique) throw CrewException('Crew name already in use', code: 'crew-name-exists');
      }

      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (logoUrl != null) updates['logoUrl'] = logoUrl;
      if (preferences != null) updates['preferences'] = preferences.toMap();

      if (updates.isNotEmpty) {
        if (!_connectivityService.isOnline) {
          // Offline: Update local crew data and mark as dirty
          final existingCrews = await _offlineDataService.getOfflineCrews();
          final crewIndex = existingCrews.indexWhere((c) => c.id == crewId);
          if (crewIndex != -1) {
            final updatedCrew = existingCrews[crewIndex].copyWith(
              name: name ?? existingCrews[crewIndex].name,
              logoUrl: logoUrl ?? existingCrews[crewIndex].logoUrl,
              preferences: preferences ?? existingCrews[crewIndex].preferences,
            );
            existingCrews[crewIndex] = updatedCrew;
            await _offlineDataService.storeCrewsOffline(existingCrews);
            await _offlineDataService.markDataDirty('crew_$crewId', updatedCrew.toFirestore());
          } else {
            throw CrewException('Crew not found in offline cache', code: 'crew-not-found-offline');
          }
        } else {
          await _firestore.collection('crews').doc(crewId).update(updates);
        }
      }
    } on CrewException {
      rethrow;
    } on FirebaseException catch (e) {
      // Provide specific error messages for common permission issues
      if (e.code == 'permission-denied') {
        throw CrewException(
          'Permission denied. You do not have the required permissions to update this crew. '
          'Please ensure you are a member of the crew and try again. '
          'If you believe this is an error, contact your crew foreman or support.',
          code: 'permission-denied'
        );
      } else if (e.code == 'unauthenticated') {
        throw CrewException(
          'Authentication required. Please sign in to update crew preferences.',
          code: 'unauthenticated'
        );
      } else if (e.code == 'not-found') {
        throw CrewException(
          'Crew not found. The crew may have been deleted or you may not have access.',
          code: 'crew-not-found'
        );
      } else if (e.code == 'failed-precondition') {
        throw CrewException(
          'Update failed due to a validation error. Please check your crew membership status.',
          code: 'validation-failed'
        );
      } else {
        throw CrewException('Firestore error updating crew: ${e.message}', code: e.code);
      }
    } catch (e) {
      throw CrewException('An unexpected error occurred while updating crew: $e', code: 'unknown-error');
    }
  }

  // Delete crew (soft delete)
  Future<void> deleteCrew(String crewId) async {
    try {
      if (!_connectivityService.isOnline) {
        // Offline: Update local crew data to inactive and mark as dirty
        final existingCrews = await _offlineDataService.getOfflineCrews();
        final crewIndex = existingCrews.indexWhere((c) => c.id == crewId);
        if (crewIndex != -1) {
          final updatedCrew = existingCrews[crewIndex].copyWith(isActive: false);
          existingCrews[crewIndex] = updatedCrew;
          await _offlineDataService.storeCrewsOffline(existingCrews);
          await _offlineDataService.markDataDirty('crew_$crewId', {'isActive': false});
        } else {
          throw CrewException('Crew not found in offline cache', code: 'crew-not-found-offline');
        }
      }
      else {
        await _firestore.collection('crews').doc(crewId).update({'isActive': false});
      }
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error deleting crew: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while deleting crew: $e', code: 'unknown-error');
    }
  }

  // Enhanced invite member with validation and permissions
  Future<String> inviteMember({
    required String crewId,
    required String inviterId,
    required String inviteeId,
    required MemberRole role,
    String? message,
  }) async {
    try {
      // DEV MODE: Permission check bypassed for development testing
      // TODO: Re-enable permission check before production deployment
      /* PRODUCTION CODE:
      if (!await hasPermission(crewId: crewId, userId: inviterId, permission: Permission.inviteMember)) {
        throw CrewException('Insufficient permissions to invite members', code: 'permission-denied');
      }
      */

      final crew = await getCrew(crewId);
      if (crew == null) {
        throw CrewException('Crew not found', code: 'crew-not-found');
      }
      if (!CrewValidation.isUnderMemberLimit(crew.memberIds.length)) {
        throw CrewException('Crew has reached maximum member limit (50)', code: 'member-limit-reached');
      }

      if (message != null) {
        final msgError = MessageValidation.validateMessageContent(message);
        if (msgError != null) throw MessagingException(msgError, code: 'invalid-message-content');
      }

      // DEV MODE: Invitation limit checks bypassed for development testing
      // TODO: Re-enable invitation limits before production deployment
      /* PRODUCTION CODE:
      if (!await _checkOverallInvitationLimit(inviterId)) {
        throw CrewException('Maximum lifetime invitation limit reached (100 invitations)', code: 'lifetime-invite-limit-reached');
      }

      if (!await _checkInvitationLimit(inviterId)) {
        throw CrewException('Daily invitation limit reached (max 5 per day)', code: 'daily-invite-limit-reached');
      }
      */

      final existingMember = await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('members')
          .doc(inviteeId)
          .get();
      if (existingMember.exists) {
        throw MemberException('User is already a member of this crew', code: 'already-member');
      }

      final existingInvite = await _getInvitation(crewId, inviteeId);
      if (existingInvite != null && existingInvite['status'] == 'pending') {
        throw MemberException('Invitation already pending for this user', code: 'invitation-pending');
      }

      final invitationId = _generateInvitationId(crewId, inviteeId);
      final expirationDate = DateTime.now().add(const Duration(days: 7));
      final invitation = {
        'id': invitationId,
        'crewId': crewId,
        'inviterId': inviterId,
        'inviteeId': inviteeId,
        'role': role.toString().split('.').last,
        'message': message ?? '',
        'status': InvitationStatus.pending.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expirationDate),
        'acceptedAt': null,
        'rejectedAt': null,
      };

      if (!_connectivityService.isOnline) {
        // Offline: Store invitation locally and mark as dirty
        await _offlineDataService.markDataDirty(
            'invite_$invitationId',
            {...
              invitation,
              '_operation': 'createInvitation',
            });
        return invitationId;
      }

      await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('invitations')
          .doc(invitationId)
          .set(invitation);

      await _firestore
          .collection('users')
          .doc(inviteeId)
          .collection('invitations')
          .doc(invitationId)
          .set(invitation);

      await _incrementInvitationCount(inviterId);

      return invitationId;
    } on AppException {
      rethrow; // Rethrow custom exceptions directly
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error inviting member: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while inviting member: $e', code: 'unknown-error');
    }
  }

  // Remove member with permission check
  Future<void> removeMember({
    required String crewId,
    required String userId,
    required String inviterId, // Add this parameter
  }) async {
    try {
      // DEV MODE: Permission check bypassed for development testing
      // TODO: Re-enable permission check before production deployment
      /* PRODUCTION CODE:
      if (!await hasPermission(crewId: crewId, userId: inviterId, permission: Permission.removeMember)) {
        throw CrewException('Insufficient permissions to remove members', code: 'permission-denied');
      }
      */

      final crew = await getCrew(crewId);
      if (crew == null) {
        throw CrewException('Crew not found', code: 'crew-not-found');
      }
      if (!crew.memberIds.contains(userId)) {
        throw MemberException('User is not a member of this crew', code: 'not-a-member');
      }

      if (!_connectivityService.isOnline) {
        // Offline: Update local crew data and mark as dirty
        final existingCrews = await _offlineDataService.getOfflineCrews();
        final crewIndex = existingCrews.indexWhere((c) => c.id == crewId);
        if (crewIndex != -1) {
          final updatedMemberIds = List<String>.from(existingCrews[crewIndex].memberIds)..remove(userId);
          final updatedRoles = Map<String, MemberRole>.from(existingCrews[crewIndex].roles)..remove(userId);
          final updatedCrew = existingCrews[crewIndex].copyWith(
            memberIds: updatedMemberIds,
            roles: updatedRoles,
          );
          existingCrews[crewIndex] = updatedCrew;
          await _offlineDataService.storeCrewsOffline(existingCrews);
          await _offlineDataService.markDataDirty('crew_$crewId', {
            'memberIds': updatedMemberIds,
            'roles.$userId': FieldValue.delete(),
            '_operation': 'removeMember',
            'userId': userId,
          });

          // Also remove from local crew members cache
          final existingMembers = await _offlineDataService.getOfflineCrewMembers();
          existingMembers.removeWhere((m) => m.crewId == crewId && m.userId == userId);
          await _offlineDataService.storeCrewMembersOffline(existingMembers);
        } else {
          throw CrewException('Crew not found in offline cache', code: 'crew-not-found-offline');
        }
        return;
      }

      await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('members')
          .doc(userId)
          .delete();

      await _firestore.collection('crews').doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'roles.$userId': FieldValue.delete(),
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error removing member: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while removing member: $e', code: 'unknown-error');
    }
  }

  // Update member role with permission
  Future<void> updateMemberRole({
    required String crewId,
    required String userId,
    required MemberRole role,
    required String updaterId, // Add updater
  }) async {
    try {
      // DEV MODE: Permission check bypassed for development testing
      // TODO: Re-enable permission check before production deployment
      /* PRODUCTION CODE:
      if (!await hasPermission(crewId: crewId, userId: updaterId, permission: Permission.updateRole)) {
        throw CrewException('Insufficient permissions to update roles', code: 'permission-denied');
      }
      */

      final permissions = MemberPermissions.fromRole(role);

      if (!_connectivityService.isOnline) {
        // Offline: Update local member data and mark as dirty
        final existingMembers = await _offlineDataService.getOfflineCrewMembers();
        final memberIndex = existingMembers.indexWhere((m) => m.crewId == crewId && m.userId == userId);
        if (memberIndex != -1) {
          final updatedMember = existingMembers[memberIndex].copyWith(
            role: role,
            permissions: permissions,
          );
          existingMembers[memberIndex] = updatedMember;
          await _offlineDataService.storeCrewMembersOffline(existingMembers);
          await _offlineDataService.markDataDirty('member_${userId}_$crewId', {
            'role': role.toString().split('.').last,
            'permissions': permissions.toMap(),
            '_operation': 'updateMemberRole',
          });

          // Also update local crew roles map
          final existingCrews = await _offlineDataService.getOfflineCrews();
          final crewIndex = existingCrews.indexWhere((c) => c.id == crewId);
          if (crewIndex != -1) {
            final updatedRoles = Map<String, MemberRole>.from(existingCrews[crewIndex].roles);
            updatedRoles[userId] = role;
            final updatedCrew = existingCrews[crewIndex].copyWith(roles: updatedRoles);
            existingCrews[crewIndex] = updatedCrew;
            await _offlineDataService.storeCrewsOffline(existingCrews);
            await _offlineDataService.markDataDirty('crew_$crewId', {
              'roles.$userId': role.toString().split('.').last,
              '_operation': 'updateCrewRoleMap',
            });
          }
        } else {
          throw MemberException('Member not found in offline cache', code: 'member-not-found-offline');
        }
        return;
      }

      await _firestore.runTransaction<void>((transaction) async {
        final memberRef = _firestore
            .collection('crews')
            .doc(crewId)
            .collection('members')
            .doc(userId);
        transaction.update(memberRef, {
          'role': role.toString().split('.').last,
          'permissions': permissions.toMap(),
        });

        final crewRef = _firestore.collection('crews').doc(crewId);
        transaction.update(crewRef, {
          'memberIds': FieldValue.arrayUnion([userId]),
          'roles.$userId': role.toString().split('.').last,
        });
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error updating member role: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while updating member role: $e', code: 'unknown-error');
    }
  }

  // Accept invitation
  Future<void> acceptInvitation({
    required String invitationId,
    required String crewId,
    required String userId,
  }) async {
    try {
      if (!_connectivityService.isOnline) {
        // Offline: Update local data and mark as dirty
        final existingCrews = await _offlineDataService.getOfflineCrews();
        final crewIndex = existingCrews.indexWhere((c) => c.id == crewId);
        if (crewIndex == -1) {
          throw CrewException('Crew not found in offline cache', code: 'crew-not-found-offline');
        }

        // Simulate invitation acceptance locally
        final inviteData = {
          'status': 'accepted',
          'acceptedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await _offlineDataService.markDataDirty('invite_$invitationId', {
          ...inviteData,
          '_operation': 'acceptInvitation',
          'crewId': crewId,
          'userId': userId,
        });

        // Add member to local crew
        final roleStr = (await _offlineDataService.getOfflineUserPreferences())?['invitations']?['role'] ?? 'member'; // Placeholder for role
        final role = MemberRole.values.firstWhere((r) => r.toString().split('.').last == roleStr);
        final member = CrewMember(
          userId: userId,
          crewId: crewId,
          role: role,
          joinedAt: DateTime.now(),
          permissions: MemberPermissions.fromRole(role),
          isAvailable: true,
          lastActive: DateTime.now(),
          isActive: true,
        );
        await _offlineDataService.storeCrewMembersOffline([member]);
        await _offlineDataService.markDataDirty('member_${userId}_$crewId', {
          ...member.toFirestore(),
          '_operation': 'addMember',
        });

        // Update crew's memberIds and roles locally
        final updatedMemberIds = List<String>.from(existingCrews[crewIndex].memberIds)..add(userId);
        final updatedRoles = Map<String, MemberRole>.from(existingCrews[crewIndex].roles);
        updatedRoles[userId] = role;
        final updatedCrew = existingCrews[crewIndex].copyWith(
          memberIds: updatedMemberIds,
          roles: updatedRoles,
          memberCount: (existingCrews[crewIndex].memberCount) + 1,
        );
        existingCrews[crewIndex] = updatedCrew;
        await _offlineDataService.storeCrewsOffline(existingCrews);
        await _offlineDataService.markDataDirty('crew_$crewId', {
          'memberIds': FieldValue.arrayUnion([userId]),
          'roles.$userId': role.toString().split('.').last,
          'memberCount': FieldValue.increment(1),
          '_operation': 'updateCrewOnAccept',
        });
        return;
      }

      await _firestore.runTransaction<void>((transaction) async {
        final inviteRef = _firestore.collection('crews').doc(crewId).collection('invitations').doc(invitationId);
        final inviteDoc = await transaction.get(inviteRef);
        if (!inviteDoc.exists) throw MemberException('Invitation not found', code: 'invitation-not-found');

        final inviteData = inviteDoc.data() as Map<String, dynamic>;
        final status = inviteData['status'] as String;
        final expiresAt = (inviteData['expiresAt'] as Timestamp?)?.toDate();
        final inviteeId = inviteData['inviteeId'] as String;

        if (status != 'pending') throw MemberException('Invitation is no longer pending', code: 'invitation-not-pending');
        if (userId != inviteeId) throw MemberException('Unauthorized to accept this invitation', code: 'unauthorized-accept');
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          transaction.update(inviteRef, {
            'status': 'expired',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          throw MemberException('Invitation has expired', code: 'invitation-expired');
        }

        final roleStr = inviteData['role'] as String;
        final role = MemberRole.values.firstWhere((r) => r.toString().split('.').last == roleStr);

        final member = CrewMember(
          userId: userId,
          crewId: crewId,
          role: role,
          joinedAt: DateTime.now(),
          permissions: MemberPermissions.fromRole(role),
          isAvailable: true,
          lastActive: DateTime.now(),
          isActive: true,
        );
        final memberRef = _firestore.collection('crews').doc(crewId).collection('members').doc(userId);
        transaction.set(memberRef, member.toFirestore());

        final crewRef = _firestore.collection('crews').doc(crewId);
        transaction.update(crewRef, {
          'memberIds': FieldValue.arrayUnion([userId]),
          'roles.$userId': role.toString().split('.').last,
          'memberCount': FieldValue.increment(1),
        });

        transaction.update(inviteRef, {
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final userInviteRef = _firestore.collection('users').doc(userId).collection('invitations').doc(invitationId);
        transaction.update(userInviteRef, {
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error accepting invitation: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while accepting invitation: $e', code: 'unknown-error');
    }
  }

  // Reject invitation
  Future<void> rejectInvitation({
    required String invitationId,
    required String crewId,
    required String userId,
  }) async {
    try {
      if (!_connectivityService.isOnline) {
        // Offline: Update local invitation status and mark as dirty
        final inviteData = {
          'status': 'rejected',
          'rejectedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await _offlineDataService.markDataDirty('invite_$invitationId', {
          ...inviteData,
          '_operation': 'rejectInvitation',
          'crewId': crewId,
          'userId': userId,
        });
        return;
      }

      final inviteRef = _firestore.collection('crews').doc(crewId).collection('invitations').doc(invitationId);
      await inviteRef.update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userInviteRef = _firestore.collection('users').doc(userId).collection('invitations').doc(invitationId);
      await userInviteRef.update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw MemberException('Firestore error rejecting invitation: ${e.message}', code: e.code);
    } catch (e) {
      throw MemberException('An unexpected error occurred while rejecting invitation: $e', code: 'unknown-error');
    }
  }

  // Cancel invitation
  Future<void> cancelInvitation({
    required String invitationId,
    required String crewId,
    required String inviterId,
  }) async {
    try {
      final inviteRef = _firestore.collection('crews').doc(crewId).collection('invitations').doc(invitationId);
      final inviteDoc = await inviteRef.get();
      if (!inviteDoc.exists) throw MemberException('Invitation not found', code: 'invitation-not-found');

      final data = inviteDoc.data() as Map<String, dynamic>;
      if (data['inviterId'] != inviterId) throw MemberException('Only inviter can cancel this invitation', code: 'unauthorized-cancel');

      if (data['status'] == 'accepted') throw MemberException('Cannot cancel an accepted invitation', code: 'invitation-accepted');

      if (!_connectivityService.isOnline) {
        // Offline: Update local invitation status and mark as dirty
        final inviteData = {
          'status': 'cancelled',
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await _offlineDataService.markDataDirty('invite_$invitationId', {
          ...inviteData,
          '_operation': 'cancelInvitation',
          'crewId': crewId,
          'inviterId': inviterId,
        });

        // For offline, we might also need to remove the invitation from the user's local cache
        // This is a simplification for now.
        return;
      }

      await inviteRef.update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userId = data['inviteeId'] as String;
      final userInviteRef = _firestore.collection('users').doc(userId).collection('invitations').doc(invitationId);
      await userInviteRef.delete().catchError((_) {}); // Catch error for delete if doc doesn't exist
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw MemberException('Firestore error cancelling invitation: ${e.message}', code: e.code);
    } catch (e) {
      throw MemberException('An unexpected error occurred while cancelling invitation: $e', code: 'unknown-error');
    }
  }

  // Get pending invitations
  Future<List<Map<String, dynamic>>> getPendingInvitations(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collectionGroup('invitations')
          .where('inviteeId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .get();

      final invitations = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['crewId'] = doc.reference.parent.parent!.id;
        invitations.add(data);
      }
      return invitations;
    } on FirebaseException catch (e) {
      throw MemberException('Firestore error getting pending invitations: ${e.message}', code: e.code);
    } catch (e) {
      throw MemberException('An unexpected error occurred while getting pending invitations: $e', code: 'unknown-error');
    }
  }

  // Cleanup expired invitations
  Future<void> cleanupExpiredInvitations(String crewId) async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final batch = _firestore.batch();

      final snapshot = await _firestore
          .collection('crews')
          .doc(crewId)
          .collection('invitations')
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isLessThanOrEqualTo: now)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw MemberException('Firestore error cleaning up expired invitations: ${e.message}', code: e.code);
    } catch (e) {
      throw MemberException('An unexpected error occurred while cleaning up expired invitations: $e', code: 'unknown-error');
    }
  }

  // Invitation helpers
  Future<Map<String, dynamic>?> _getInvitation(String crewId, String inviteeId) async {
    final snapshot = await _firestore
        .collection('crews')
        .doc(crewId)
        .collection('invitations')
        .where('inviteeId', isEqualTo: inviteeId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  String _generateInvitationId(String crewId, String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${crewId}_${userId}_$timestamp';
  }

  // Statistics methods (as previously fixed)
  Future<void> updateCrewStats(String crewId) async {
    try {
      final crewRef = _firestore.collection('crews').doc(crewId);
      final crewDoc = await crewRef.get();
      if (!crewDoc.exists) return;

      final data = crewDoc.data() as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>? ?? {};
      final currentStats = CrewStats.fromMap(statsData);

      // Calculate derived statistics
      final totalApplications = currentStats.totalApplications;
      final totalJobsShared = currentStats.totalJobsShared;
      final successfulPlacements = currentStats.successfulPlacements;
      final matchScores = currentStats.matchScores;

      // Application rate
      final applicationRate = totalJobsShared > 0 
          ? (totalApplications / totalJobsShared).toDouble() 
          : 0.0;

      // Average match score (rolling average)
      final avgMatchScore = matchScores.isNotEmpty 
          ? matchScores.reduce((a, b) => a + b) / matchScores.length 
          : 0.0;

      // Response time (await the future)
      final avgResponseTime = await _calculateAverageResponseTime(crewId);

      // Job type breakdown
      final jobTypeBreakdown = await _calculateJobTypeBreakdown(crewId);

      // Success rate
      final successRate = totalApplications > 0 
          ? (successfulPlacements / totalApplications).toDouble() 
          : 0.0;

      // Update last activity
      final updatedStats = currentStats.copyWith(
        applicationRate: applicationRate,
        averageMatchScore: avgMatchScore,
        responseTime: avgResponseTime,
        jobTypeBreakdown: jobTypeBreakdown,
        successRate: successRate,
        lastActivityAt: DateTime.now(),
      );

      await crewRef.update({
        'stats': updatedStats.toMap(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      // Background aggregation
      _scheduleBackgroundAggregation(crewId);
    } catch (e) {
      throw Exception('Failed to update crew statistics: $e');
    }
  }

  Future<void> incrementApplication(String crewId, {double? matchScore}) async {
    await _firestore.runTransaction<void>((transaction) async {
      final crewRef = _firestore.collection('crews').doc(crewId);
      final crewDoc = await transaction.get(crewRef);
      if (!crewDoc.exists) throw Exception('Crew not found');

      final data = crewDoc.data() as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>? ?? {};
      final currentStats = CrewStats.fromMap(statsData);

      // Add match score to recent scores (keep last 50)
      List<double> newScores = List<double>.from(currentStats.matchScores);
      if (matchScore != null) {
        newScores.add(matchScore);
        if (newScores.length > 50) newScores = newScores.sublist(newScores.length - 50);
      }

      final updatedStats = currentStats.copyWith(
        totalApplications: currentStats.totalApplications + 1,
        matchScores: newScores,
      );

      transaction.update(crewRef, {
        'stats.totalApplications': updatedStats.totalApplications,
        'stats.matchScores': updatedStats.matchScores,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    });

    await updateCrewStats(crewId);
  }

  Future<void> incrementSuccessfulPlacement(String crewId) async {
    await _firestore.runTransaction<void>((transaction) async {
      final crewRef = _firestore.collection('crews').doc(crewId);
      final crewDoc = await transaction.get(crewRef);
      if (!crewDoc.exists) throw Exception('Crew not found');

      final data = crewDoc.data() as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>? ?? {};
      final currentStats = CrewStats.fromMap(statsData);

      final updatedStats = currentStats.copyWith(
        successfulPlacements: currentStats.successfulPlacements + 1,
      );

      transaction.update(crewRef, {
        'stats.successfulPlacements': updatedStats.successfulPlacements,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    });

    await updateCrewStats(crewId);
  }

  Future<void> incrementJobShared(String crewId) async {
    await _firestore.runTransaction<void>((transaction) async {
      final crewRef = _firestore.collection('crews').doc(crewId);
      final crewDoc = await transaction.get(crewRef);
      if (!crewDoc.exists) throw Exception('Crew not found');

      final data = crewDoc.data() as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>? ?? {};
      final currentStats = CrewStats.fromMap(statsData);

      final updatedStats = currentStats.copyWith(
        totalJobsShared: currentStats.totalJobsShared + 1,
      );

      transaction.update(crewRef, {
        'stats.totalJobsShared': updatedStats.totalJobsShared,
        'stats.matchScores': updatedStats.matchScores,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    });

    await updateCrewStats(crewId);
  }

  Future<double> _calculateAverageResponseTime(String crewId) async {
    final applicationsSnapshot = await _firestore
        .collection('crews')
        .doc(crewId)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .limit(50)
        .get();

    if (applicationsSnapshot.docs.isEmpty) return 0.0;

    double totalTime = 0.0;
    int count = 0;

    for (final doc in applicationsSnapshot.docs) {
      final data = doc.data();
      final suggestedAt = (data['suggestedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final appliedAt = (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final responseMinutes = appliedAt.difference(suggestedAt).inMinutes.toDouble();
      if (responseMinutes >= 0) {
        totalTime += responseMinutes;
        count++;
      }
    }

    return count > 0 ? totalTime / count : 0.0;
  }

  Future<Map<String, int>> _calculateJobTypeBreakdown(String crewId) async {
    final applicationsSnapshot = await _firestore
        .collection('crews')
        .doc(crewId)
        .collection('applications')
        .limit(100)
        .get();

    final breakdown = <String, int>{};
    for (final doc in applicationsSnapshot.docs) {
      final jobType = doc.data()['jobType'] as String? ?? 'unknown';
      breakdown[jobType] = (breakdown[jobType] ?? 0) + 1;
    }
    return breakdown;
  }

  void _scheduleBackgroundAggregation(String crewId) {
    // TODO: Implement Cloud Function trigger
  }

  Future<bool> validateCrewStats(String crewId) async {
    try {
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) return false;

      final data = crewDoc.data() as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>? ?? {};
      final currentStats = CrewStats.fromMap(statsData);

      final totalApps = currentStats.totalApplications;
      final successful = currentStats.successfulPlacements;
      final shared = currentStats.totalJobsShared;

      if (successful > totalApps) return false;
      if (currentStats.applicationRate > totalApps / (shared > 0 ? shared : 1)) return false;
      if (currentStats.averageMatchScore < 0 || currentStats.averageMatchScore > 100) return false;
      if (currentStats.responseTime < 0) return false;
      if (currentStats.successRate < 0 || currentStats.successRate > 1) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Stream and utility methods (fix to use _firestore)
  Stream<QuerySnapshot> getUserCrewsStream(String userId) {
    return _firestore
        .collection('crews')
        .where('memberIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getCrewMembersStream(String crewId) {
    return _firestore
        .collection('crews')
        .doc(crewId)
        .collection('members')
        .snapshots();
  }

  Stream<QuerySnapshot> getUserCrewMembersStream(String crewId, String userId) {
    return _firestore
        .collection('crews')
        .doc(crewId)
        .collection('members')
        .where(FieldPath.documentId, isEqualTo: userId)
        .snapshots();
  }

  Future<List<Crew>> getUserCrews(String userId) async {
    try {
      if (_connectivityService.isOnline) {
        final snapshot = await _retryWithBackoff(operation: () => _firestore
            .collection('crews')
            .where('memberIds', arrayContains: userId)
            .where('isActive', isEqualTo: true)
            .orderBy('lastActivityAt', descending: true)
            .limit(10)
            .get());

        final crews = snapshot.docs.map((doc) => Crew.fromFirestore(doc)).toList();
        await _offlineDataService.storeCrewsOffline(crews); // Cache the fetched crews
        return crews;
      } else {
        // Attempt to get from offline cache
        final offlineCrews = await _offlineDataService.getOfflineCrews();
        return offlineCrews.where((crew) => crew.memberIds.contains(userId) && crew.isActive).toList();
      }
    } on FirebaseException catch (e) {
      throw CrewException('Firestore error getting user crews: ${e.message}', code: e.code);
    } catch (e) {
      throw CrewException('An unexpected error occurred while getting user crews: $e', code: 'unknown-error');
    }
  }

  Future<List<CrewMember>> getCrewMembers(String crewId) async {
    try {
      if (_connectivityService.isOnline) {
        final snapshot = await _retryWithBackoff(operation: () => _firestore
            .collection('crews')
            .doc(crewId)
            .collection('members')
            .get());

        final members = snapshot.docs.map((doc) => CrewMember.fromFirestore(doc)).toList();
        await _offlineDataService.storeCrewMembersOffline(members); // Cache the fetched members
        return members;
      } else {
        // Attempt to get from offline cache
        final offlineMembers = await _offlineDataService.getOfflineCrewMembers();
        return offlineMembers.where((member) => member.crewId == crewId).toList();
      }
    } on FirebaseException catch (e) {
      throw MemberException('Firestore error getting crew members: ${e.message}', code: e.code);
    } catch (e) {
      throw MemberException('An unexpected error occurred while getting crew members: $e', code: 'unknown-error');
    }
  }

  Future<CrewMember?> getCrewMember(String crewId, String userId) async {
    try {
      if (_connectivityService.isOnline) {
        final doc = await _retryWithBackoff(operation: () => _firestore
            .collection('crews')
            .doc(crewId)
            .collection('members')
            .doc(userId)
            .get());

        if (doc.exists) {
          final member = CrewMember.fromFirestore(doc);
          await _offlineDataService.storeCrewMembersOffline([member]); // Cache the fetched member
          return member;
        }
      } else {
        // Attempt to get from offline cache
        final offlineMembers = await _offlineDataService.getOfflineCrewMembers();
        return offlineMembers.firstWhere(
            (member) => member.crewId == crewId && member.userId == userId,
            orElse: () => throw MemberException('Crew member not found in offline cache', code: 'member-not-found-offline'));
      }
      return null;
    } on FirebaseException catch (e) {
      throw MemberException('Firestore error getting crew member: ${e.message}', code: e.code);
    } catch (e) {
      throw MemberException('An unexpected error occurred while getting crew member: $e', code: 'unknown-error');
    }
  }

  Future<bool> isUserInCrew(String crewId, String userId) async {
    try {
      final member = await getCrewMember(crewId, userId);
      return member != null;
    } on AppException {
      rethrow; // Rethrow custom exceptions
    } catch (e) {
      // Log unexpected errors but return false for existence check
      return false;
    }
  }

  Future<MemberRole?> getUserRoleInCrew(String crewId, String userId) async {
    try {
      final crew = await getCrew(crewId);
      return crew?.roles[userId];
    } on AppException {
      rethrow; // Rethrow custom exceptions
    } catch (e) {
      // Log unexpected errors but return null for role
      return null;
    }
  }

  Future<bool> hasPermission({
    required String crewId,
    required String userId,
    required Permission permission,
  }) async {
    // ========================================================================
    // DEV MODE: All permission checks bypassed for development testing
    // ========================================================================
    // TODO: Re-enable full permission logic before production deployment
    //
    // Original function performed:
    // - Foreman role verification
    // - Crew member lookup
    // - Role-based permission checking via RolePermissions class
    // - Comprehensive logging
    //
    // Currently returns true for ALL authenticated users to allow
    // unrestricted crew operations during development.
    // ========================================================================

    try {
      StructuredLogger.info(
        'DEV MODE: Permission check bypassed - granting access',
        category: LogCategory.business,
        context: {
          'crewId': crewId,
          'userId': userId,
          'permission': permission.toString(),
          'granted': true,
          'mode': 'development',
        },
      );

      // DEV MODE: Always return true to bypass all permission checks
      return true;

      /* PRODUCTION CODE - RE-ENABLE BEFORE DEPLOYMENT:

      // First check if user is the foreman (they should always have permissions)
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      if (crewDoc.exists) {
        final crew = Crew.fromFirestore(crewDoc);
        if (crew.foremanId == userId) {
          StructuredLogger.info(
            'User is foreman, granting permission',
            category: LogCategory.business,
            context: {
              'crewId': crewId,
              'userId': userId,
              'permission': permission.toString(),
              'granted': true,
            },
          );
          return RolePermissions.hasPermission(MemberRole.foreman, permission);
        }
      }

      final member = await getCrewMember(crewId, userId);
      if (member == null) {
        StructuredLogger.warning(
          'User not found in crew members',
          category: LogCategory.business,
          context: {
            'crewId': crewId,
            'userId': userId,
            'permission': permission.toString(),
          },
        );
        return false;
      }

      final role = member.role;
      final hasPermission = RolePermissions.hasPermission(role, permission);

      StructuredLogger.info(
        'Permission check result',
        category: LogCategory.business,
        context: {
          'crewId': crewId,
          'userId': userId,
          'permission': permission.toString(),
          'role': role.toString(),
          'granted': hasPermission,
        },
      );

      return hasPermission;
      */
    } on AppException {
      StructuredLogger.error(
        'AppException during permission check',
        category: LogCategory.business,
        context: {
          'crewId': crewId,
          'userId': userId,
          'permission': permission.toString(),
          'error': 'AppException',
        },
      );
      rethrow; // Rethrow custom exceptions
    } on FirebaseException catch (e) {
      StructuredLogger.error(
        'FirebaseException during permission check',
        category: LogCategory.business,
        context: {
          'crewId': crewId,
          'userId': userId,
          'permission': permission.toString(),
          'error': e.toString(),
        },
      );
      // DEV MODE: Return true even on errors
      return true;
    } catch (e) {
      StructuredLogger.error(
        'Unexpected error during permission check',
        category: LogCategory.business,
        context: {
          'crewId': crewId,
          'userId': userId,
          'permission': permission.toString(),
          'error': e.toString(),
        },
      );
      // DEV MODE: Return true even on errors
      return true;
    }
  }

  // Generate permission rule for Firestore
  String generatePermissionRule(Permission permission) {
    switch (permission) {
      case Permission.inviteMember:
        return 'request.auth != null && resource.data.inviterId == request.auth.uid && hasRole("foreman", resource.data)';
      default:
        return 'false';
    }
  }

  // End of class
}
