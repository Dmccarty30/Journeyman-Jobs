import 'package:cloud_firestore/cloud_firestore.dart';

/// A data class that holds statistical information about a [Crew]'s activity.
class CrewStats {
  /// The total number of jobs that have been shared with the crew.
  final int totalJobsShared;
  /// The total number of job applications submitted by the crew.
  final int totalApplications;
  /// The average match score of jobs shared with the crew, indicating relevance.
  final double averageMatchScore;

  /// Creates an instance of [CrewStats].
  CrewStats({
    this.totalJobsShared = 0,
    this.totalApplications = 0,
    this.averageMatchScore = 0.0,
  });

  /// Creates a [CrewStats] instance from a Firestore data map.
  factory CrewStats.fromFirestore(Map<String, dynamic> data) {
    return CrewStats(
      totalJobsShared: (data['totalJobsShared'] ?? 0) as int,
      totalApplications: (data['totalApplications'] ?? 0) as int,
      averageMatchScore: (data['averageMatchScore'] ?? 0.0) as double,
    );
  }

  /// Converts the [CrewStats] instance to a map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'totalJobsShared': totalJobsShared,
      'totalApplications': totalApplications,
      'averageMatchScore': averageMatchScore,
    };
  }
}

/// Represents a crew of electrical workers.
///
/// A crew is a group of users, led by a foreman, who can share job postings,
/// communicate, and manage job preferences collectively.
class Crew {
  /// The unique identifier for the crew.
  final String id;
  /// The name of the crew.
  final String name;
  /// The user ID of the crew's foreman.
  final String foremanId;
  /// A list of user IDs for all members of the crew.
  final List<String> memberIds;
  /// A map defining the crew's collective preferences for jobs (e.g., pay rate, location).
  final Map<String, dynamic> jobPreferences;
  /// Statistical data about the crew's activity.
  final CrewStats stats;

  /// Creates a [Crew] instance.
  Crew({
    required this.id,
    required this.name,
    required this.foremanId,
    this.memberIds = const [],
    this.jobPreferences = const {},
    CrewStats? stats,
  }) : stats = stats ?? CrewStats();

  /// Creates a [Crew] instance from a Firestore [DocumentSnapshot].
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

  /// Converts the [Crew] instance to a map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'foremanId': foremanId,
      'memberIds': memberIds,
      'jobPreferences': jobPreferences,
      'stats': stats.toFirestore(),
    };
  }

  /// Checks if the essential fields of the crew model are valid.
  ///
  /// Returns `true` if both [name] and [foremanId] are not empty.
  bool isValid() => name.isNotEmpty && foremanId.isNotEmpty;
}
