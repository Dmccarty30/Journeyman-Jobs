import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'filter_criteria.dart';

/// Model representing user's job search preferences
@immutable
class UserJobPreferences {
  /// Preferred job classifications (e.g., 'Journeyman Electrician', 'Apprentice')
  final List<String> classifications;

  /// Types of construction work (e.g., 'Commercial', 'Residential', 'Industrial')
  final List<String> constructionTypes;

  /// Preferred IBEW local numbers
  final List<int> preferredLocals;

  /// Desired hours per week (e.g., '40-50', '50-60')
  final String? hoursPerWeek;

  /// Per diem requirement range (e.g., '$100-$150')
  final String? perDiemRequirement;

  /// Minimum acceptable wage
  final double? minWage;

  /// Maximum distance willing to travel in miles
  final int? maxDistance;

  const UserJobPreferences({
    required this.classifications,
    required this.constructionTypes,
    required this.preferredLocals,
    this.hoursPerWeek,
    this.perDiemRequirement,
    this.minWage,
    this.maxDistance,
  });

  /// Create UserJobPreferences from JSON (Firestore)
  factory UserJobPreferences.fromJson(Map<String, dynamic> json) {
    return UserJobPreferences(
      classifications: List<String>.from(json['classifications'] ?? []),
      constructionTypes: List<String>.from(json['constructionTypes'] ?? []),
      preferredLocals: (json['preferredLocals'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList(),
      hoursPerWeek: json['hoursPerWeek']?.toString(),
      perDiemRequirement: json['perDiemRequirement']?.toString(),
      minWage: json['minWage']?.toDouble(),
      maxDistance: json['maxDistance'] is int 
          ? json['maxDistance'] 
          : int.tryParse(json['maxDistance']?.toString() ?? '') ?? null,
    );
  }

  /// Convert UserJobPreferences to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'classifications': classifications,
      'constructionTypes': constructionTypes,
      'preferredLocals': preferredLocals,
      'hoursPerWeek': hoursPerWeek,
      'perDiemRequirement': perDiemRequirement,
      'minWage': minWage,
      'maxDistance': maxDistance,
    };
  }

  /// Create an empty UserJobPreferences
  factory UserJobPreferences.empty() {
    return const UserJobPreferences(
      classifications: [],
      constructionTypes: [],
      preferredLocals: [],
      hoursPerWeek: null,
      perDiemRequirement: null,
      minWage: null,
      maxDistance: null,
    );
  }

  /// Create a copy of UserJobPreferences with updated fields
  UserJobPreferences copyWith({
    List<String>? classifications,
    List<String>? constructionTypes,
    List<int>? preferredLocals,
    String? hoursPerWeek,
    String? perDiemRequirement,
    double? minWage,
    int? maxDistance,
  }) {
    return UserJobPreferences(
      classifications: classifications ?? this.classifications,
      constructionTypes: constructionTypes ?? this.constructionTypes,
      preferredLocals: preferredLocals ?? this.preferredLocals,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      perDiemRequirement: perDiemRequirement ?? this.perDiemRequirement,
      minWage: minWage ?? this.minWage,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }

  /// Convert UserJobPreferences to JobFilterCriteria for job queries
  JobFilterCriteria toFilterCriteria() {
    // Convert per diem requirement to hasPerDiem boolean
    bool? hasPerDiem;
    if (perDiemRequirement != null && perDiemRequirement!.isNotEmpty) {
      hasPerDiem = true;
    }

    // Convert hours per week to duration preference
    String? durationPreference;
    if (hoursPerWeek != null) {
      if (hoursPerWeek == '>70') {
        durationPreference = 'long-term';
      } else {
        durationPreference = 'short-term';
      }
    }

    return JobFilterCriteria(
      classifications: classifications,
      constructionTypes: constructionTypes,
      localNumbers: preferredLocals,
      hasPerDiem: hasPerDiem,
      durationPreference: durationPreference,
      maxDistance: maxDistance?.toDouble(),
    );
  }

  /// Check if user has any job preferences set
  bool get hasPreferences {
    return classifications.isNotEmpty ||
        constructionTypes.isNotEmpty ||
        preferredLocals.isNotEmpty ||
        hoursPerWeek != null ||
        perDiemRequirement != null ||
        minWage != null ||
        maxDistance != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserJobPreferences &&
        other.classifications == classifications &&
        other.constructionTypes == constructionTypes &&
        other.preferredLocals == preferredLocals &&
        other.hoursPerWeek == hoursPerWeek &&
        other.perDiemRequirement == perDiemRequirement &&
        other.minWage == minWage &&
        other.maxDistance == maxDistance;
  }

  @override
  int get hashCode {
    return Object.hash(
      classifications,
      constructionTypes,
      preferredLocals,
      hoursPerWeek,
      perDiemRequirement,
      minWage,
      maxDistance,
    );
  }

  @override
  String toString() {
    return 'UserJobPreferences('
        'classifications: $classifications, '
        'constructionTypes: $constructionTypes, '
        'preferredLocals: $preferredLocals, '
        'hoursPerWeek: $hoursPerWeek, '
        'perDiemRequirement: $perDiemRequirement, '
        'minWage: $minWage, '
        'maxDistance: $maxDistance'
        ')';
  }
}