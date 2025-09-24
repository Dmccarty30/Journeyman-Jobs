import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/models/crew_stats.dart';

class CrewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get crewsCollection => _firestore.collection('crews');

  // Basic Crew Operations
  Future<void> createCrew({
    required String id,
    required String name,
    required String foremanId,
    required CrewPreferences preferences,
    String? logoUrl,
  }) async {
    try {
      final crew = Crew(
        id: id,
        name: name,
        logoUrl: logoUrl,
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
        ),
        isActive: true,
      );

      await crewsCollection.doc(id).set(crew.toFirestore());
    } catch (e) {
      throw Exception('Error creating crew: $e');
    }
  }

  Future<Crew?> getCrew(String crewId) async {
    try {
      final doc = await crewsCollection.doc(crewId).get();
      if (doc.exists) {
        return Crew.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting crew: $e');
    }
  }

  Future<void> updateCrew({
    required String crewId,
    String? name,
    String? logoUrl,
    CrewPreferences? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (name != null) updates['name'] = name;
      if (logoUrl != null) updates['logoUrl'] = logoUrl;
      if (preferences != null) updates['preferences'] = preferences.toJson();
      
      if (updates.isNotEmpty) {
        await crewsCollection.doc(crewId).update(updates);
      }
    } catch (e) {
      throw Exception('Error updating crew: $e');
    }
  }

  Future<void> deleteCrew(String crewId) async {
    try {
      await crewsCollection.doc(crewId).update({'isActive': false});
    } catch (e) {
      throw Exception('Error deleting crew: $e');
    }
  }

  // Member Management
  Future<void> inviteMember({
    required String crewId,
    required String userId,
    required MemberRole role,
  }) async {
    try {
      final member = CrewMember(
        userId: userId,
        crewId: crewId,
        role: role,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(role),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      await crewsCollection
          .doc(crewId)
          .collection('members')
          .doc(userId)
          .set(member.toFirestore());

      // Update crew's memberIds array
      await crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'roles.$userId': role.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Error inviting member: $e');
    }
  }

  Future<void> removeMember({
    required String crewId,
    required String userId,
  }) async {
    try {
      // Remove member document
      await crewsCollection
          .doc(crewId)
          .collection('members')
          .doc(userId)
          .delete();

      // Update crew's memberIds array and roles
      await crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'roles.$userId': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Error removing member: $e');
    }
  }

  Future<void> updateMemberRole({
    required String crewId,
    required String userId,
    required MemberRole role,
  }) async {
    try {
      final permissions = MemberPermissions.fromRole(role);
      
      await crewsCollection
          .doc(crewId)
          .collection('members')
          .doc(userId)
          .update({
        'role': role.toString().split('.').last,
        'permissions': permissions.toMap(),
      });

      // Update crew's roles mapping
      await crewsCollection.doc(crewId).update({
        'roles.$userId': role.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Error updating member role: $e');
    }
  }

  Future<void> acceptInvitation({
    required String crewId,
    required String userId,
  }) async {
    try {
      await crewsCollection
          .doc(crewId)
          .collection('members')
          .doc(userId)
          .update({
        'joinedAt': Timestamp.fromDate(DateTime.now()),
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Error accepting invitation: $e');
    }
  }

  // Stream Operations
  Stream<QuerySnapshot> getUserCrewsStream(String userId) {
    return crewsCollection
        .where('memberIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getCrewMembersStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .collection('members')
        .snapshots();
  }

  Stream<QuerySnapshot> getUserCrewMembersStream(String crewId, String userId) {
    return crewsCollection
        .doc(crewId)
        .collection('members')
        .where(FieldPath.documentId, isEqualTo: userId)
        .snapshots();
  }

  // Utility Methods
  Future<List<Crew>> getUserCrews(String userId) async {
    try {
      final snapshot = await crewsCollection
          .where('memberIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Crew.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting user crews: $e');
    }
  }

  Future<List<CrewMember>> getCrewMembers(String crewId) async {
    try {
      final snapshot = await crewsCollection
          .doc(crewId)
          .collection('members')
          .get();

      return snapshot.docs.map((doc) => CrewMember.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting crew members: $e');
    }
  }

  Future<CrewMember?> getCrewMember(String crewId, String userId) async {
    try {
      final doc = await crewsCollection
          .doc(crewId)
          .collection('members')
          .doc(userId)
          .get();

      if (doc.exists) {
        return CrewMember.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting crew member: $e');
    }
  }

  Future<bool> isUserInCrew(String crewId, String userId) async {
    try {
      final member = await getCrewMember(crewId, userId);
      return member != null;
    } catch (e) {
      return false;
    }
  }

  Future<MemberRole?> getUserRoleInCrew(String crewId, String userId) async {
    try {
      final crew = await getCrew(crewId);
      return crew?.roles[userId];
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasPermission({
    required String crewId,
    required String userId,
    required String permission,
  }) async {
    try {
      final member = await getCrewMember(crewId, userId);
      return member?.hasPermission(permission) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Statistics and Analytics
  Future<void> updateCrewStats({
    required String crewId,
    required CrewStats stats,
  }) async {
    try {
      await crewsCollection.doc(crewId).update({
        'stats': stats.toMap(),
      });
    } catch (e) {
      throw Exception('Error updating crew stats: $e');
    }
  }

  Future<void> incrementJobShared(String crewId) async {
    try {
      final crew = await getCrew(crewId);
      if (crew != null) {
        final updatedStats = crew.stats.incrementJobShared();
        await updateCrewStats(crewId: crewId, stats: updatedStats);
      }
    } catch (e) {
      throw Exception('Error incrementing job shared count: $e');
    }
  }

  Future<void> incrementApplication(String crewId) async {
    try {
      final crew = await getCrew(crewId);
      if (crew != null) {
        final updatedStats = crew.stats.incrementApplication();
        await updateCrewStats(crewId: crewId, stats: updatedStats);
      }
    } catch (e) {
      throw Exception('Error incrementing application count: $e');
    }
  }

  Future<void> incrementSuccessfulPlacement(String crewId) async {
    try {
      final crew = await getCrew(crewId);
      if (crew != null) {
        final updatedStats = crew.stats.incrementSuccessfulPlacement();
        await updateCrewStats(crewId: crewId, stats: updatedStats);
      }
    } catch (e) {
      throw Exception('Error incrementing successful placement count: $e');
    }
  }
}