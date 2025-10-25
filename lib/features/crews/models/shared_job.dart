import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/job_model.dart';

/// Represents a job that has been shared with a crew
///
/// IMPORTANT: Uses the canonical Job model from lib/models/job_model.dart
/// (NOT the CrewJob model from features/jobs/models/crew_job.dart)
///
/// This is because Firestore data uses the canonical Job schema:
/// - `company` field (not `companyName`)
/// - `wage` field (not `hourlyRate`)
/// - 30+ fields with full job details
class SharedJob {
  final String id;
  final Job job; // Canonical Job from models/job_model.dart
  final String sharedByUserId;
  final DateTime sharedAt;
  final String? comment;
  final double matchScore;
  final String source; // 'shared', 'auto', etc.

  const SharedJob({
    required this.id,
    required this.job,
    required this.sharedByUserId,
    required this.sharedAt,
    this.comment,
    required this.matchScore,
    required this.source,
  });

  /// Create from Firestore document
  ///
  /// Parses the nested 'job' field using canonical Job.fromJson
  /// because Firestore stores jobs with the full canonical schema
  factory SharedJob.fromFirestore(Map<String, dynamic> data, String id) {
    return SharedJob(
      id: id,
      job: Job.fromJson(data['job'] as Map<String, dynamic>),
      sharedByUserId: data['sharedByUserId'],
      sharedAt: (data['sharedAt'] as Timestamp).toDate(),
      comment: data['comment'],
      matchScore: (data['matchScore'] ?? 0.0).toDouble(),
      source: data['source'] ?? 'shared',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'job': job.toFirestore(),
      'sharedByUserId': sharedByUserId,
      'sharedAt': sharedAt,
      'comment': comment,
      'matchScore': matchScore,
      'source': source,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedJob &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SharedJob{id: $id, job: ${job.jobTitle ?? job.company}, sharedBy: $sharedByUserId, source: $source}';
  }
}