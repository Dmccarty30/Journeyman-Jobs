import 'package:flutter/material.dart';
import 'filter_criteria.dart';

/// Model representing a saved filter preset
class FilterPreset {
  final String id;
  final String name;
  final String? description;
  final JobFilterCriteria criteria;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final int useCount;
  final bool isPinned;
  final IconData? icon;

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

  /// Create a new preset
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

  /// Copy with updated values
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

  /// Mark preset as used
  FilterPreset markAsUsed() {
    return copyWith(
      lastUsedAt: DateTime.now(),
      useCount: useCount + 1,
    );
  }

  /// Toggle pinned status
  FilterPreset togglePinned() {
    return copyWith(isPinned: !isPinned);
  }

  /// Convert to JSON for storage
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

  /// Create from JSON
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

/// Default filter presets
class DefaultFilterPresets {
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