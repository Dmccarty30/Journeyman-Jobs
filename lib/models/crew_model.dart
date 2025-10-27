import 'package:cloud_firestore/cloud_firestore.dart';

class CrewStats {
  final int totalJobsShared;
  final int totalApplications;
  final double averageMatchScore;

  CrewStats({
    this.totalJobsShared = 0,
    this.totalApplications = 0,
    this.averageMatchScore = 0.0,
  });

  factory CrewStats.fromFirestore(Map<String, dynamic> data) {
    return CrewStats(
      totalJobsShared: (data['totalJobsShared'] ?? 0) as int,
      totalApplications: (data['totalApplications'] ?? 0) as int,
      averageMatchScore: (data['averageMatchScore'] ?? 0.0) as double,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalJobsShared': totalJobsShared,
      'totalApplications': totalApplications,
      'averageMatchScore': averageMatchScore,
    };
  }
}

class Crew {
  final String id;
  final String name;
  final String foremanId;
  final List<String> memberIds;
  final Map<String, dynamic> jobPreferences;
  final CrewStats stats;

  Crew({
    required this.id,
    required this.name,
    required this.foremanId,
    this.memberIds = const [],
    this.jobPreferences = const {},
    CrewStats? stats,
  }) : stats = stats ?? CrewStats();

  factory Crew.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crew(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      foremanId: (data['foremanId'] ?? '') as String,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      jobPreferences: Map<String, dynamic>.from(data['jobPreferences'] ?? {}),
      stats: data['stats'] != null
          ? CrewStats.fromFirestore(data['stats'] as Map<String, dynamic>)
          : CrewStats(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'foremanId': foremanId,
      'memberIds': memberIds,
      'jobPreferences': jobPreferences,
      'stats': stats.toFirestore(),
    };
  }

  Crew copyWith({
    String? id,
    String? name,
    String? foremanId,
    List<String>? memberIds,
    Map<String, dynamic>? jobPreferences,
    CrewStats? stats,
  }) {
    return Crew(
      id: id ?? this.id,
      name: name ?? this.name,
      foremanId: foremanId ?? this.foremanId,
      memberIds: memberIds ?? List<String>.from(this.memberIds),
      jobPreferences: jobPreferences ?? Map<String, dynamic>.from(this.jobPreferences),
      stats: stats ?? this.stats,
    );
  }

  bool isValid() => name.isNotEmpty && foremanId.isNotEmpty;
}
