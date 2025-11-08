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

  /// Validates user job preferences before saving to Firestore
  ///
  /// Returns true if preferences are valid and can be saved.
  /// At minimum, user must select at least one classification,
  /// one construction type, and one preferred local.
  bool validate() {
    // At least one classification selected
    if (classifications.isEmpty) return false;

    // At least one construction type selected
    if (constructionTypes.isEmpty) return false;

    // At least one local selected
    if (preferredLocals.isEmpty) return false;

    return true;
  }

  /// Returns a user-friendly validation error message
  ///
  /// Returns null if preferences are valid.
  String? get validationError {
    if (classifications.isEmpty) {
      return 'Please select at least one job classification';
    }

    if (constructionTypes.isEmpty) {
      return 'Please select at least one construction type';
    }

    if (preferredLocals.isEmpty) {
      return 'Please select at least one preferred local';
    }

    return null;
  }

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

  dynamic get preferences => null;

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
    final Map<String, dynamic> json = {
      'classifications': classifications,
      'constructionTypes': constructionTypes,
      'preferredLocals': preferredLocals,
    };

    // Only include optional fields if they have values
    if (hoursPerWeek != null) json['hoursPerWeek'] = hoursPerWeek;
    if (perDiemRequirement != null) json['perDiemRequirement'] = perDiemRequirement;
    if (minWage != null) json['minWage'] = minWage;
    if (maxDistance != null) json['maxDistance'] = maxDistance;

    return json;
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
