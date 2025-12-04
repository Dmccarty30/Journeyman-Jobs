import 'package:cloud_firestore/cloud_firestore.dart';

class UserFeedback {
  final String id;
  final String userId;
  final String subjectId; // e.g., Job ID, Company ID, Local ID
  final String subjectType; // e.g., 'job', 'company', 'local'
  final String feedbackText;
  final double rating; // e.g., 1-5 stars
  final Timestamp createdAt;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectType,
    required this.feedbackText,
    required this.rating,
    required this.createdAt,
  });

  factory UserFeedback.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFeedback(
      id: doc.id,
      userId: data['userId'] as String,
      subjectId: data['subjectId'] as String,
      subjectType: data['subjectType'] as String,
      feedbackText: data['feedbackText'] as String,
      rating: (data['rating'] as num).toDouble(),
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'subjectId': subjectId,
      'subjectType': subjectType,
      'feedbackText': feedbackText,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}
