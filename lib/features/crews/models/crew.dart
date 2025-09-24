import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_preferences.dart';
import 'crew_stats.dart';

enum MemberRole {
  foreman,  // Full admin rights
  lead,     // Can invite members, share jobs
  member    // Basic member rights
}

class Crew {
  final String id;                    // Firebase auto-generated ID
  final String name;                   // User-defined crew name
  final String? logoUrl;               // Optional crew logo URL
  final String foremanId;              // User ID of crew creator/leader
  final List<String> memberIds;        // List of all member user IDs
  final CrewPreferences preferences;   // Crew-wide preferences
  final DateTime createdAt;            // Timestamp of creation
  final Map<String, MemberRole> roles; // Member ID to role mapping
  final CrewStats stats;               // Aggregated statistics
  final bool isActive;                 // Soft delete flag

  // Computed properties
  int get memberCount => memberIds.length;
  bool get canOperate => memberCount >= 2;

  Crew({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.foremanId,
    required this.memberIds,
    required this.preferences,
    required this.createdAt,
    required this.roles,
    required this.stats,
    required this.isActive,
  });

  factory Crew.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crew(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      foremanId: data['foremanId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      preferences: CrewPreferences.fromMap(data['preferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      roles: Map<String, MemberRole>.fromEntries(
        (data['roles'] as Map<String, dynamic>?)?.entries.map(
              (entry) => MapEntry(entry.key, MemberRole.values.firstWhere(
                (role) => role.toString().split('.').last == entry.value,
                orElse: () => MemberRole.member,
              )),
            ) ??
            {},
      ),
      stats: CrewStats.fromMap(data['stats'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'foremanId': foremanId,
      'memberIds': memberIds,
      'preferences': preferences.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'roles': roles.map((key, value) => MapEntry(key, value.toString().split('.').last)),
      'stats': stats.toMap(),
      'isActive': isActive,
    };
  }

  Crew copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? foremanId,
    List<String>? memberIds,
    CrewPreferences? preferences,
    DateTime? createdAt,
    Map<String, MemberRole>? roles,
    CrewStats? stats,
    bool? isActive,
  }) {
    return Crew(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      foremanId: foremanId ?? this.foremanId,
      memberIds: memberIds ?? this.memberIds,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      roles: roles ?? this.roles,
      stats: stats ?? this.stats,
      isActive: isActive ?? this.isActive,
    );
  }
}