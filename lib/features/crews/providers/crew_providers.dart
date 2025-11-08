import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock crew model for basic functionality
class CrewModel {
  final String id;
  final String name;
  final String? description;
  final List<String> memberIds;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  CrewModel({
    required this.id,
    required this.name,
    this.description,
    this.memberIds = const [],
    required this.createdAt,
    this.metadata,
  });

  factory CrewModel.fromJson(Map<String, dynamic> json) {
    return CrewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

// Mock crew member model
class CrewMember {
  final String id;
  final String name;
  final String email;
  final String? role;
  final bool isOnline;
  final DateTime? lastSeen;

  CrewMember({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.isOnline = false,
    this.lastSeen,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? (json['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
}

// Providers
final crewListProvider = Provider<List<CrewModel>>((ref) {
  return [
    CrewModel(
      id: 'crew1',
      name: 'IBEW Local 123',
      description: 'Electrical workers union local',
      memberIds: ['member1', 'member2'],
      createdAt: DateTime.now(),
    ),
    CrewModel(
      id: 'crew2',
      name: 'IBEW Local 456',
      description: 'Linemen and wiremen crew',
      memberIds: ['member3', 'member4'],
      createdAt: DateTime.now(),
    ),
  ];
});

final selectedCrewProvider = Provider<CrewModel?>((ref) {
  return null;
});

final crewMembersProvider = Provider<List<CrewMember>>((ref) {
  return [
    CrewMember(
      id: 'member1',
      name: 'John Smith',
      email: 'john@example.com',
      role: 'Journeyman',
      isOnline: true,
    ),
    CrewMember(
      id: 'member2',
      name: 'Jane Doe',
      email: 'jane@example.com',
      role: 'Apprentice',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
});

final crewProvider = Provider<CrewService>((ref) {
  return CrewService();
});

class CrewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CrewModel>> getUserCrews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('crews')
          .where('memberIds', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => CrewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Return mock data for now
      return [
        CrewModel(
          id: 'crew1',
          name: 'IBEW Local 123',
          description: 'Electrical workers union local',
          memberIds: [userId],
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  Future<CrewModel?> getCrewById(String crewId) async {
    try {
      final doc = await _firestore.collection('crews').doc(crewId).get();
      if (doc.exists) {
        return CrewModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<CrewMember>> getCrewMembers(String crewId) async {
    try {
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) return [];

      final crew = CrewModel.fromJson(crewDoc.data()!);
      final members = <CrewMember>[];

      for (final memberId in crew.memberIds) {
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          members.add(CrewMember(
            id: memberId,
            name: userData['displayName'] ?? 'Unknown',
            email: userData['email'] ?? '',
            role: userData['role'],
            isOnline: userData['isOnline'] ?? false,
            lastSeen: userData['lastSeen'] != null
                ? (userData['lastSeen'] as Timestamp).toDate()
                : null,
          ));
        }
      }

      return members;
    } catch (e) {
      // Return mock data
      return [
        CrewMember(
          id: 'member1',
          name: 'John Smith',
          email: 'john@example.com',
          role: 'Journeyman',
          isOnline: true,
        ),
      ];
    }
  }

  Future<void> joinCrew(String userId, String crewId) async {
    try {
      await _firestore.collection('crews').doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> leaveCrew(String userId, String crewId) async {
    try {
      await _firestore.collection('crews').doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      // Handle error
    }
  }
}