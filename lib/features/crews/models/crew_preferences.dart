import 'package:flutter/foundation.dart';

class CrewPreferences {
  final List<String> jobTypes;
  final double? minHourlyRate;
  final int? maxDistanceMiles;
  final List<String> preferredCompanies;
  final List<String> requiredSkills;
  final bool autoShareEnabled;
  final int matchThreshold;
  
  CrewPreferences({
    required this.jobTypes,
    this.minHourlyRate,
    this.maxDistanceMiles,
    this.preferredCompanies = const [],
    this.requiredSkills = const [],
    this.autoShareEnabled = false,
    this.matchThreshold = 50,
  });

  factory CrewPreferences.fromMap(Map<String, dynamic> map) {
    return CrewPreferences(
      jobTypes: List<String>.from(map['jobTypes'] ?? []),
      minHourlyRate: map['minHourlyRate']?.toDouble(),
      maxDistanceMiles: map['maxDistanceMiles'] as int?,
      preferredCompanies: List<String>.from(map['preferredCompanies'] ?? []),
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      autoShareEnabled: map['autoShareEnabled'] ?? false,
      matchThreshold: map['matchThreshold'] ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobTypes': jobTypes,
      'minHourlyRate': minHourlyRate,
      'maxDistanceMiles': maxDistanceMiles,
      'preferredCompanies': preferredCompanies,
      'requiredSkills': requiredSkills,
      'autoShareEnabled': autoShareEnabled,
      'matchThreshold': matchThreshold,
    };
  }

  factory CrewPreferences.empty() {
    return CrewPreferences(
      jobTypes: [],
      minHourlyRate: null,
      maxDistanceMiles: null,
      preferredCompanies: [],
      requiredSkills: [],
      autoShareEnabled: false,
      matchThreshold: 50,
    );
  }

  CrewPreferences copyWith({
    List<String>? jobTypes,
    double? minHourlyRate,
    int? maxDistanceMiles,
    List<String>? preferredCompanies,
    List<String>? requiredSkills,
    bool? autoShareEnabled,
    int? matchThreshold,
  }) {
    return CrewPreferences(
      jobTypes: jobTypes ?? this.jobTypes,
      minHourlyRate: minHourlyRate ?? this.minHourlyRate,
      maxDistanceMiles: maxDistanceMiles ?? this.maxDistanceMiles,
      preferredCompanies: preferredCompanies ?? this.preferredCompanies,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      autoShareEnabled: autoShareEnabled ?? this.autoShareEnabled,
      matchThreshold: matchThreshold ?? this.matchThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}