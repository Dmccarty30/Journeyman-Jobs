class JobSummary {
  final String jobId;
  final String summary;
  final List<String> keyPoints;
  final double sentimentScore;

  JobSummary({
    required this.jobId,
    required this.summary,
    required this.keyPoints,
    required this.sentimentScore,
  });

  factory JobSummary.fromJson(Map<String, dynamic> json) {
    return JobSummary(
      jobId: json['jobId'] as String,
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      sentimentScore: (json['sentimentScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'summary': summary,
      'keyPoints': keyPoints,
      'sentimentScore': sentimentScore,
    };
  }
}
