import 'package:flutter/material.dart';
import 'filter_criteria.dart';

/// A data model representing a user-saved set of job search filters.
///
/// This allows users to save complex filter combinations for quick reuse.
class FilterPreset {
  /// A unique identifier for the preset.
  final String id;
  /// The user-defined name for the preset.
  final String name;
  /// An optional, more detailed description of the preset.
  final String? description;
  /// The set of [JobFilterCriteria] that this preset represents.
  final JobFilterCriteria criteria;
  /// The timestamp when the preset was first created.
  final DateTime createdAt;
  /// The timestamp when the preset was last used.
  final DateTime lastUsedAt;
  /// The number of times this preset has been used.
  final int useCount;
  /// A flag indicating if the preset is pinned for quick access.
  final bool isPinned;
  /// An optional icon to visually represent the preset.
  final IconData? icon;

  /// Creates an instance of [FilterPreset].
  const FilterPreset({
    required this.id,
    required this.name,
    this.description,
    required this.criteria,
    required this.createdAt,
    required this.lastUsedAt,
    this.useCount = 0,
    this.isPinned = false,
    this.icon,
  });

  /// A factory constructor to create a new [FilterPreset] with default metadata.
  ///
  /// - [name]: The name for the new preset.
  /// - [description]: An optional description.
  /// - [criteria]: The [JobFilterCriteria] to save.
  /// - [icon]: An optional icon.
  factory FilterPreset.create({
    required String name,
    String? description,
    required JobFilterCriteria criteria,
    IconData? icon,
  }) {
    final now = DateTime.now();
    return FilterPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      criteria: criteria,
      createdAt: now,
      lastUsedAt: now,
      useCount: 0,
      isPinned: false,
      icon: icon,
    );
  }

  /// Creates a new [FilterPreset] instance with updated field values.
  FilterPreset copyWith({
    String? id,
    String? name,
    String? description,
    JobFilterCriteria? criteria,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? useCount,
    bool? isPinned,
    IconData? icon,
  }) {
    return FilterPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      criteria: criteria ?? this.criteria,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
      isPinned: isPinned ?? this.isPinned,
      icon: icon ?? this.icon,
    );
  }

  /// Returns a new [FilterPreset] instance with an updated `lastUsedAt` timestamp
  /// and an incremented `useCount`.
  FilterPreset markAsUsed() {
    return copyWith(
      lastUsedAt: DateTime.now(),
      useCount: useCount + 1,
    );
  }

  /// Returns a new [FilterPreset] instance with the `isPinned` status toggled.
  FilterPreset togglePinned() {
    return copyWith(isPinned: !isPinned);
  }

  /// Serializes the [FilterPreset] instance to a JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'criteria': criteria.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'useCount': useCount,
      'isPinned': isPinned,
      'iconCodePoint': icon?.codePoint,
    };
  }

  /// Creates a [FilterPreset] instance from a JSON map.
  factory FilterPreset.fromJson(Map<String, dynamic> json) {
    return FilterPreset(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      criteria: JobFilterCriteria.fromJson(json['criteria']),
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: DateTime.parse(json['lastUsedAt']),
      useCount: json['useCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      icon: json['iconCodePoint'] != null
          ? IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons')
          : null,
    );
  }
}

/// A utility class that provides a list of pre-configured default filter presets.
class DefaultFilterPresets {
  /// A static list of default [FilterPreset] objects to offer to new users.
  static List<FilterPreset> get defaults => [
        FilterPreset.create(
          name: 'Local Jobs',
          description: 'Jobs within 25 miles',
          criteria: const JobFilterCriteria(
            maxDistance: 25.0,
            sortBy: JobSortOption.distance,
            sortDescending: false,
          ),
          icon: Icons.location_on,
        ),
        FilterPreset.create(
          name: 'Recent Postings',
          description: 'Jobs posted in the last 7 days',
          criteria: JobFilterCriteria(
            postedAfter: DateTime.now().subtract(const Duration(days: 7)),
            sortBy: JobSortOption.datePosted,
            sortDescending: true,
          ),
          icon: Icons.new_releases,
        ),
        FilterPreset.create(
          name: 'Travel Jobs',
          description: 'Jobs with per diem benefits',
          criteria: const JobFilterCriteria(
            hasPerDiem: true,
            sortBy: JobSortOption.wage,
            sortDescending: true,
          ),
          icon: Icons.flight,
        ),
        FilterPreset.create(
          name: 'Transmission Work',
          description: 'High voltage transmission jobs',
          criteria: const JobFilterCriteria(
            constructionTypes: ['Transmission'],
            sortBy: JobSortOption.wage,
            sortDescending: true,
          ),
          icon: Icons.electrical_services,
        ),
      ];
}