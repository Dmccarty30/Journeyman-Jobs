import 'package:flutter/foundation.dart';
import 'filter_criteria.dart';

@immutable
class UserJobPreferences {
  final List<String> classifications;
  final List<String> constructionTypes;
  final List<int> preferredLocals;
  final String? hoursPerWeek;
  final String? perDiemRequirement;
  final double? minWage;
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

  factory UserJobPreferences.empty() {
    return UserJobPreferences(
      classifications: [],
      constructionTypes: [],
      preferredLocals: [],
      hoursPerWeek: null,
      perDiemRequirement: null,
      minWage: null,
      maxDistance: null,
    );
  }

  get preferences => null;

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

  static UserJobPreferences fromJson(Map<String, dynamic> json) {
    return UserJobPreferences(
      classifications: List<String>.from(json['classifications'] ?? []),
      constructionTypes: List<String>.from(json['constructionTypes'] ?? []),
      preferredLocals: List<int>.from(json['preferredLocals'] ?? []),
      hoursPerWeek: json['hoursPerWeek'],
      perDiemRequirement: json['perDiemRequirement'],
      minWage: json['minWage'],
      maxDistance: json['maxDistance'],
    );
  }

  JobFilterCriteria toFilterCriteria() {
    return JobFilterCriteria(
      classifications: classifications,
      localNumbers: preferredLocals,
      constructionTypes: constructionTypes,
      // Note: hoursPerWeek, perDiemRequirement, minWage, and maxDistance may require
      // client-side filtering as they are not directly supported in Firestore queries
      // based on the current JobFilterCriteria.applyToQuery implementation
      maxDistance: maxDistance?.toDouble(),
    );
  }
}
