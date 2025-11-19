import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a job posting
class Job {
  final String id;
  final String title;
  final String description;
  final String jobType;
  final double hourlyRate;
  final GeoPoint? location;
  final DateTime postedAt;
  final String postedByUserId;
  final bool isActive;
  final int estimatedDuration; // in hours
  final List<String> requiredSkills;
  final String? companyName;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.jobType,
    required this.hourlyRate,
    this.location,
    required this.postedAt,
    required this.postedByUserId,
    required this.isActive,
    this.estimatedDuration = 0,
    this.requiredSkills = const [],
    this.companyName,
  });

  /// Creates a Job instance from Firestore data
  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper to parse double from various types
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      }
      return 0.0;
    }

    // Helper to parse DateTime
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return Job(
      id: doc.id,
      title: data['title'] ?? data['job_title'] ?? '',
      description: data['description'] ?? data['job_description'] ?? '',
      jobType: data['jobType'] ?? data['typeOfWork'] ?? data['Type of Work'] ?? '',
      hourlyRate: parseDouble(data['hourlyRate'] ?? data['wage'] ?? data['hourlyWage']),
      location: data['location'] as GeoPoint?,
      postedAt: parseDateTime(data['postedAt'] ?? data['timestamp'] ?? data['date_posted']),
      postedByUserId: data['postedByUserId'] ?? '',
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 0,
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      companyName: data['companyName'] ?? data['company'] ?? data['employer'],
    );
  }

  /// Converts Job to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'jobType': jobType,
      'hourlyRate': hourlyRate,
      if (location != null) 'location': location,
      'postedAt': postedAt,
      'postedByUserId': postedByUserId,
      'isActive': isActive,
      'estimatedDuration': estimatedDuration,
      'requiredSkills': requiredSkills,
      if (companyName != null) 'companyName': companyName,
    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? jobType,
    double? hourlyRate,
    GeoPoint? location,
    DateTime? postedAt,
    String? postedByUserId,
    bool? isActive,
    int? estimatedDuration,
    List<String>? requiredSkills,
    String? companyName,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      jobType: jobType ?? this.jobType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      location: location ?? this.location,
      postedAt: postedAt ?? this.postedAt,
      postedByUserId: postedByUserId ?? this.postedByUserId,
      isActive: isActive ?? this.isActive,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      companyName: companyName ?? this.companyName,
    );
  }
}