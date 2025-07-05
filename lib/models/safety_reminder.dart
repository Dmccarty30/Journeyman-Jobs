import 'package:flutter/foundation.dart';

/// Enumeration for different categories of safety reminders
enum SafetyCategory {
  electrical('Electrical Safety'),
  ppe('Personal Protective Equipment'),
  lockout('Lockout/Tagout'),
  arcFlash('Arc Flash Protection'),
  emergency('Emergency Procedures'),
  tools('Tool Safety'),
  environment('Environmental Safety'),
  general('General Safety');

  const SafetyCategory(this.displayName);
  final String displayName;
}

/// Enumeration for reminder priority levels
enum ReminderPriority {
  low('Low', 'General awareness'),
  medium('Medium', 'Important safety tip'),
  high('High', 'Critical safety reminder'),
  urgent('Urgent', 'Immediate attention required');

  const ReminderPriority(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Model class representing a safety reminder
@immutable
class SafetyReminder {
  final String id;
  final String title;
  final String message;
  final SafetyCategory category;
  final ReminderPriority priority;
  final String? imageUrl;
  final String? actionText;
  final String? actionUrl;
  final DateTime createdDate;
  final DateTime? expiryDate;
  final bool isActive;
  final List<String> tags;
  final String? source; // NEC code, OSHA standard, etc.
  final int displayOrder;

  const SafetyReminder({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    this.priority = ReminderPriority.medium,
    this.imageUrl,
    this.actionText,
    this.actionUrl,
    required this.createdDate,
    this.expiryDate,
    this.isActive = true,
    this.tags = const [],
    this.source,
    this.displayOrder = 0,
  });

  /// Creates a copy of this SafetyReminder with the given fields replaced
  SafetyReminder copyWith({
    String? id,
    String? title,
    String? message,
    SafetyCategory? category,
    ReminderPriority? priority,
    String? imageUrl,
    String? actionText,
    String? actionUrl,
    DateTime? createdDate,
    DateTime? expiryDate,
    bool? isActive,
    List<String>? tags,
    String? source,
    int? displayOrder,
  }) {
    return SafetyReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      actionText: actionText ?? this.actionText,
      actionUrl: actionUrl ?? this.actionUrl,
      createdDate: createdDate ?? this.createdDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  /// Gets the appropriate icon for this reminder based on category
  String get iconData {
    switch (category) {
      case SafetyCategory.electrical:
        return 'electrical_services';
      case SafetyCategory.ppe:
        return 'shield';
      case SafetyCategory.lockout:
        return 'lock';
      case SafetyCategory.arcFlash:
        return 'flash_on';
      case SafetyCategory.emergency:
        return 'emergency';
      case SafetyCategory.tools:
        return 'build';
      case SafetyCategory.environment:
        return 'eco';
      case SafetyCategory.general:
        return 'security';
    }
  }

  /// Gets the color associated with this reminder's priority
  String get priorityColor {
    switch (priority) {
      case ReminderPriority.low:
        return 'successGreen';
      case ReminderPriority.medium:
        return 'infoBlue';
      case ReminderPriority.high:
        return 'warningYellow';
      case ReminderPriority.urgent:
        return 'errorRed';
    }
  }

  /// Checks if this reminder is currently valid (not expired)
  bool get isValid {
    if (!isActive) return false;
    if (expiryDate == null) return true;
    return DateTime.now().isBefore(expiryDate!);
  }

  @override
  String toString() {
    return 'SafetyReminder('
        'id: $id, '
        'title: $title, '
        'category: ${category.displayName}, '
        'priority: ${priority.displayName}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SafetyReminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Pre-defined safety reminders for electrical workers
class ElectricalSafetyReminders {
  static final List<SafetyReminder> dailyReminders = [
    SafetyReminder(
      id: 'sr_001',
      title: 'Test Before Touch',
      message: 'Always test circuits before working - never assume they are de-energized. Use a properly rated voltage tester and verify it\'s working on a known live source.',
      category: SafetyCategory.electrical,
      priority: ReminderPriority.high,
      tags: ['testing', 'voltage', 'verification'],
      source: 'NFPA 70E',
      createdDate: DateTime.now(),
      displayOrder: 1,
    ),
    SafetyReminder(
      id: 'sr_002',
      title: 'PPE Inspection',
      message: 'Inspect all PPE before each use including safety glasses, hard hat, and arc-rated clothing. Look for cracks, damage, or contamination.',
      category: SafetyCategory.ppe,
      priority: ReminderPriority.high,
      tags: ['ppe', 'inspection', 'arc-rated'],
      source: 'OSHA 1910.132',
      createdDate: DateTime.now(),
      displayOrder: 2,
    ),
    SafetyReminder(
      id: 'sr_003',
      title: 'Lockout/Tagout Procedures',
      message: 'Use proper LOTO procedures before electrical work. Verify the lockout with your voltage tester and keep the key with you.',
      category: SafetyCategory.lockout,
      priority: ReminderPriority.high,
      tags: ['loto', 'lockout', 'tagout', 'procedures'],
      source: 'OSHA 1910.147',
      createdDate: DateTime.now(),
      displayOrder: 3,
    ),
    SafetyReminder(
      id: 'sr_004',
      title: 'Overhead Line Clearance',
      message: 'Maintain at least 10-foot clearance from overhead power lines. Use a spotter when operating equipment near power lines.',
      category: SafetyCategory.electrical,
      priority: ReminderPriority.urgent,
      tags: ['overhead', 'clearance', 'power-lines'],
      source: 'OSHA 1926.95',
      createdDate: DateTime.now(),
      displayOrder: 4,
    ),
    SafetyReminder(
      id: 'sr_005',
      title: 'Tool Inspection',
      message: 'Inspect tools and equipment before each use. Check for damaged insulation, loose connections, or signs of wear.',
      category: SafetyCategory.tools,
      priority: ReminderPriority.medium,
      tags: ['tools', 'inspection', 'equipment'],
      source: 'NFPA 70E',
      createdDate: DateTime.now(),
      displayOrder: 5,
    ),
    SafetyReminder(
      id: 'sr_006',
      title: 'Buddy System',
      message: 'Never work alone on electrical systems. Use the buddy system and maintain communication with your partner.',
      category: SafetyCategory.general,
      priority: ReminderPriority.high,
      tags: ['buddy-system', 'communication', 'teamwork'],
      source: 'Best Practice',
      createdDate: DateTime.now(),
      displayOrder: 6,
    ),
    SafetyReminder(
      id: 'sr_007',
      title: 'Arc Flash Boundaries',
      message: 'Know your electrical hazards: shock, arc flash, blast, and fire. Respect arc flash boundaries and wear appropriate PPE.',
      category: SafetyCategory.arcFlash,
      priority: ReminderPriority.urgent,
      tags: ['arc-flash', 'boundaries', 'hazards'],
      source: 'NFPA 70E',
      createdDate: DateTime.now(),
      displayOrder: 7,
    ),
    SafetyReminder(
      id: 'sr_008',
      title: 'Weather Awareness',
      message: 'Monitor weather conditions. Do not work on electrical equipment during storms or high winds.',
      category: SafetyCategory.environment,
      priority: ReminderPriority.high,
      tags: ['weather', 'storms', 'environmental'],
      source: 'Best Practice',
      createdDate: DateTime.now(),
      displayOrder: 8,
    ),
    SafetyReminder(
      id: 'sr_009',
      title: 'Emergency Procedures',
      message: 'Know the location of emergency shut-offs and first aid equipment. Have emergency contact numbers readily available.',
      category: SafetyCategory.emergency,
      priority: ReminderPriority.medium,
      tags: ['emergency', 'first-aid', 'procedures'],
      source: 'OSHA General',
      createdDate: DateTime.now(),
      displayOrder: 9,
    ),
    SafetyReminder(
      id: 'sr_010',
      title: 'Proper Grounding',
      message: 'Ensure all equipment is properly grounded. Use GFCI protection where required and verify ground connections.',
      category: SafetyCategory.electrical,
      priority: ReminderPriority.high,
      tags: ['grounding', 'gfci', 'connections'],
      source: 'NEC Article 250',
      createdDate: DateTime.now(),
      displayOrder: 10,
    ),
  ];

  /// Get a random daily safety reminder
  static SafetyReminder getDailyReminder() {
    final validReminders = dailyReminders.where((r) => r.isValid).toList();
    if (validReminders.isEmpty) return dailyReminders.first;
    
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return validReminders[dayOfYear % validReminders.length];
  }

  /// Get reminders by category
  static List<SafetyReminder> getRemindersByCategory(SafetyCategory category) {
    return dailyReminders
        .where((r) => r.category == category && r.isValid)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Get reminders by priority
  static List<SafetyReminder> getRemindersByPriority(ReminderPriority priority) {
    return dailyReminders
        .where((r) => r.priority == priority && r.isValid)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Get all active reminders sorted by priority and order
  static List<SafetyReminder> getAllActiveReminders() {
    return dailyReminders
        .where((r) => r.isValid)
        .toList()
      ..sort((a, b) {
        // Sort by priority first (urgent -> low), then by display order
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        return a.displayOrder.compareTo(b.displayOrder);
      });
  }
}
