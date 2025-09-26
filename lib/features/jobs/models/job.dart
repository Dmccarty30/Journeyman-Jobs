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
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      jobType: data['jobType'] ?? '',
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      location: data['location'] as GeoPoint?,
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postedByUserId: data['postedByUserId'] ?? '',
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 0,
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      companyName: data['companyName'],
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