import 'package:cloud_firestore/cloud_firestore.dart';

class JobSuggestion {
  final String id;
  final String originalJobId;
  final String suggestedJobId;
  final String reason;
  final double relevanceScore;
  final Timestamp createdAt;

  JobSuggestion({
    required this.id,
    required this.originalJobId,
    required this.suggestedJobId,
    required this.reason,
    required this.relevanceScore,
    required this.createdAt,
  });

  factory JobSuggestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobSuggestion(
      id: doc.id,
      originalJobId: data['originalJobId'] as String,
      suggestedJobId: data['suggestedJobId'] as String,
      reason: data['reason'] as String,
      relevanceScore: (data['relevanceScore'] as num).toDouble(),
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'originalJobId': originalJobId,
      'suggestedJobId': suggestedJobId,
      'reason': reason,
      'relevanceScore': relevanceScore,
      'createdAt': createdAt,
    };
  }
}
