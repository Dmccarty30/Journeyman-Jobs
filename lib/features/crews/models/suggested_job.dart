import 'package:journeyman_jobs/features/jobs/models/job.dart';

/// Model representing a suggested job for a crew
class SuggestedJob {
  final String id;
  final Job job;
  final double matchScore;
  final String source; // 'matched', 'shared', 'manual'
  final String? sharedByUserId;
  final DateTime? sharedAt;
  final String? comment;

  const SuggestedJob({
    required this.id,
    required this.job,
    required this.matchScore,
    required this.source,
    this.sharedByUserId,
    this.sharedAt,
    this.comment,
  });

  SuggestedJob copyWith({
    String? id,
    Job? job,
    double? matchScore,
    String? source,
    String? sharedByUserId,
    DateTime? sharedAt,
    String? comment,
  }) {
    return SuggestedJob(
      id: id ?? this.id,
      job: job ?? this.job,
      matchScore: matchScore ?? this.matchScore,
      source: source ?? this.source,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      sharedAt: sharedAt ?? this.sharedAt,
      comment: comment ?? this.comment,
    );
  }
}