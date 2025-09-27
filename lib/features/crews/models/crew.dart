import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_location.dart';
import 'crew_preferences.dart';
import 'crew_stats.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';

class Crew {
  final String id;
  final String name;
  final String? logoUrl; // Added
  final String foremanId;
  final List<String> memberIds;
  final CrewLocation? location;
  final CrewPreferences preferences;
  final CrewStats stats;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, MemberRole> roles; // Added
  final int memberCount; // Added
  final DateTime lastActivityAt; // Added

  const Crew({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.foremanId,
    required this.memberIds,
    this.location,
    required this.preferences,
    required this.stats,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    required this.roles,
    this.memberCount = 0,
    required this.lastActivityAt,
  });

  factory Crew.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crew(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      foremanId: data['foremanId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      location: data['location'] != null
          ? CrewLocation.fromFirestore(data['location'] as Map<String, dynamic>)
          : null,
      preferences: CrewPreferences.fromMap(data['preferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      roles: (data['roles'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, MemberRole.values.firstWhere((r) => r.toString().split('.').last == value))) ?? {},
      stats: CrewStats.fromMap(data['stats'] ?? {}),
      isActive: data['isActive'] ?? true,
      memberCount: data['memberCount'] ?? 0,
      lastActivityAt: (data['lastActivityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'foremanId': foremanId,
      'memberIds': memberIds,
      'location': location?.toFirestore(),
      'preferences': preferences.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'roles': roles.map((key, value) => MapEntry(key, value.toString().split('.').last)),
      'stats': stats.toMap(),
      'isActive': isActive,
      'memberCount': memberCount,
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }

  // toMap alias for consistency
  Map<String, dynamic> toMap() => toFirestore();

  // fromMap alias
  factory Crew.fromMap(Map<String, dynamic> map) {
    return Crew(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      logoUrl: map['logoUrl'],
      foremanId: map['foremanId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      location: map['location'] != null
          ? CrewLocation.fromFirestore(map['location'])
          : null,
      preferences: CrewPreferences.fromMap(map['preferences'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      roles: (map['roles'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, MemberRole.values.firstWhere((r) => r.toString().split('.').last == value))) ?? {},
      stats: CrewStats.fromMap(map['stats'] ?? {}),
      isActive: map['isActive'] ?? true,
      memberCount: map['memberCount'] ?? 0,
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Crew copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? foremanId,
    List<String>? memberIds,
    CrewLocation? location,
    CrewPreferences? preferences,
    CrewStats? stats,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, MemberRole>? roles,
    int? memberCount,
    DateTime? lastActivityAt,
  }) {
    return Crew(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      foremanId: foremanId ?? this.foremanId,
      memberIds: memberIds ?? this.memberIds,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
      memberCount: memberCount ?? this.memberCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}