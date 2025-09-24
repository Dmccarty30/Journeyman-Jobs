import 'crew_preferences.dart';

class CrewStats {
  final int totalJobsShared;           // All-time jobs shared
  final int totalApplications;         // All-time applications
  final double applicationRate;        // Applications per shared job
  final double averageMatchScore;      // Average AI match score
  final int successfulPlacements;      // Jobs won by crew
  final double responseTime;           // Avg time to apply (in hours)
  final Map<String, int> jobTypeBreakdown; // Applications by type
  final DateTime lastActivityAt;       // Last crew activity

  CrewStats({
    required this.totalJobsShared,
    required this.totalApplications,
    required this.applicationRate,
    required this.averageMatchScore,
    required this.successfulPlacements,
    required this.responseTime,
    required this.jobTypeBreakdown,
    required this.lastActivityAt,
  });

  factory CrewStats.fromMap(Map<String, dynamic> map) {
    return CrewStats(
      totalJobsShared: map['totalJobsShared'] ?? 0,
      totalApplications: map['totalApplications'] ?? 0,
      applicationRate: (map['applicationRate'] ?? 0.0).toDouble(),
      averageMatchScore: (map['averageMatchScore'] ?? 0.0).toDouble(),
      successfulPlacements: map['successfulPlacements'] ?? 0,
      responseTime: (map['responseTime'] ?? 0.0).toDouble(),
      jobTypeBreakdown: Map<String, int>.from(
        (map['jobTypeBreakdown'] as Map<String, dynamic>?) ?? {},
      ),
      lastActivityAt: map['lastActivityAt'] != null
          ? DateTime.parse(map['lastActivityAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalJobsShared': totalJobsShared,
      'totalApplications': totalApplications,
      'applicationRate': applicationRate,
      'averageMatchScore': averageMatchScore,
      'successfulPlacements': successfulPlacements,
      'responseTime': responseTime,
      'jobTypeBreakdown': jobTypeBreakdown.map(
        (key, value) => MapEntry(key.toString().split('.').last, value),
      ),
      'lastActivityAt': lastActivityAt.toIso8601String(),
    };
  }

  CrewStats copyWith({
    int? totalJobsShared,
    int? totalApplications,
    double? applicationRate,
    double? averageMatchScore,
    int? successfulPlacements,
    double? responseTime,
    Map<String, int>? jobTypeBreakdown,
    DateTime? lastActivityAt,
  }) {
    return CrewStats(
      totalJobsShared: totalJobsShared ?? this.totalJobsShared,
      totalApplications: totalApplications ?? this.totalApplications,
      applicationRate: applicationRate ?? this.applicationRate,
      averageMatchScore: averageMatchScore ?? this.averageMatchScore,
      successfulPlacements: successfulPlacements ?? this.successfulPlacements,
      responseTime: responseTime ?? this.responseTime,
      jobTypeBreakdown: jobTypeBreakdown ?? this.jobTypeBreakdown,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  // Helper method to calculate application rate
  double calculateApplicationRate() {
    return totalJobsShared > 0 ? totalApplications / totalJobsShared : 0.0;
  }

  // Helper method to update stats when a job is shared
  CrewStats incrementJobShared() {
    return copyWith(
      totalJobsShared: totalJobsShared + 1,
      applicationRate: calculateApplicationRate(),
      lastActivityAt: DateTime.now(),
    );
  }

  // Helper method to update stats when an application is made
  CrewStats incrementApplication() {
    return copyWith(
      totalApplications: totalApplications + 1,
      applicationRate: calculateApplicationRate(),
      lastActivityAt: DateTime.now(),
    );
  }

  // Helper method to update successful placement
  CrewStats incrementSuccessfulPlacement() {
    return copyWith(
      successfulPlacements: successfulPlacements + 1,
      lastActivityAt: DateTime.now(),
    );
  }

  // Helper method to update average match score
  CrewStats updateAverageMatchScore(double newScore) {
    final newAverage = averageMatchScore == 0
        ? newScore
        : ((averageMatchScore * (totalApplications - 1)) + newScore) / totalApplications;
    
    return copyWith(
      averageMatchScore: newAverage,
    );
  }

  // Helper method to update job type breakdown
  CrewStats updateJobTypeBreakdown(String jobType) {
    final updatedBreakdown = Map<String, int>.from(jobTypeBreakdown);
    updatedBreakdown[jobType] = (updatedBreakdown[jobType] ?? 0) + 1;
    
    return copyWith(
      jobTypeBreakdown: updatedBreakdown,
    );
  }

  factory CrewStats.empty() {
    return CrewStats(
      totalJobsShared: 0,
      totalApplications: 0,
      applicationRate: 0.0,
      averageMatchScore: 0.0,
      successfulPlacements: 0,
      responseTime: 0.0,
      jobTypeBreakdown: {},
      lastActivityAt: DateTime.now(),
    );
  }
}