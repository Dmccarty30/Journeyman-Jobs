import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_location.dart';
import 'crew_preferences.dart';
import 'crew_stats.dart';
import 'package:journeyman_jobs/domain/enums/crew_visibility.dart';
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
  final CrewVisibility visibility;
  final int maxMembers;
  final String? activeInviteCode;
  final int inviteCodeCounter;

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
    required this.visibility,
    required this.maxMembers,
    this.activeInviteCode,
    required this.inviteCodeCounter,
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
      visibility: (data['visibility'] as String?)?.toCrewVisibility() ?? CrewVisibility.private,
      maxMembers: data['maxMembers'] ?? 50,
      activeInviteCode: data['activeInviteCode'],
      inviteCodeCounter: data['inviteCodeCounter'] ?? 0,
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
      'visibility': visibility.name,
      'maxMembers': maxMembers,
      'activeInviteCode': activeInviteCode,
      'inviteCodeCounter': inviteCodeCounter,
    };
  }

  // toMap alias for consistency
  Map<String, dynamic> toMap() => toFirestore();

  // fromMap alias with flexible date handling
  factory Crew.fromMap(Map<String, dynamic> map) {
    // Helper function to parse dates from various formats
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;

      // Handle Timestamp objects from Firestore
      if (value is Timestamp) {
        return value.toDate();
      }

      // Handle DateTime objects (already converted)
      if (value is DateTime) {
        return value;
      }

      // Handle String representations (ISO8601)
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return fallback;
        }
      }

      // Handle Map representations from Firestore (with seconds and nanoseconds)
      if (value is Map<String, dynamic>) {
        if (value.containsKey('_seconds')) {
          final seconds = value['_seconds'] as int?;
          final nanoseconds = value['_nanoseconds'] as int? ?? 0;
          if (seconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + (nanoseconds ~/ 1000000)
            );
          }
        }
      }

      return fallback;
    }

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
      createdAt: parseDate(map['createdAt'], DateTime.now()),
      roles: (map['roles'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, MemberRole.values.firstWhere((r) => r.toString().split('.').last == value))) ?? {},
      stats: CrewStats.fromMap(map['stats'] ?? {}),
      isActive: map['isActive'] ?? true,
      memberCount: map['memberCount'] ?? 0,
      lastActivityAt: parseDate(map['lastActivityAt'], DateTime.now()),
      visibility: (map['visibility'] as String?)?.toCrewVisibility() ?? CrewVisibility.private,
      maxMembers: map['maxMembers'] ?? 50,
      activeInviteCode: map['activeInviteCode'],
      inviteCodeCounter: map['inviteCodeCounter'] ?? 0,
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
    CrewVisibility? visibility,
    int? maxMembers,
    String? activeInviteCode,
    int? inviteCodeCounter,
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
      visibility: visibility ?? this.visibility,
      maxMembers: maxMembers ?? this.maxMembers,
      activeInviteCode: activeInviteCode ?? this.activeInviteCode,
      inviteCodeCounter: inviteCodeCounter ?? this.inviteCodeCounter,
    );
  }
}

extension CrewVisibilityExtension on String {
  CrewVisibility toCrewVisibility() {
    return CrewVisibility.values.firstWhere((e) => e.name == this, orElse: () => CrewVisibility.private);
  }
}
