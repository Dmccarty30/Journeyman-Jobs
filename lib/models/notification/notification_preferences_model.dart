/// Model for user notification preferences stored in Firestore
class NotificationPreferencesModel {
  /// User's FCM token for push notifications
  final String? fcmToken;
  
  /// When the FCM token was last updated
  final DateTime? tokenUpdatedAt;
  
  /// Notification category preferences
  final bool jobAlertsEnabled;
  final bool safetyAlertsEnabled;
  final bool unionUpdatesEnabled;
  final bool applicationUpdatesEnabled;
  final bool systemNotificationsEnabled;
  final bool stormWorkEnabled;
  
  /// Reminder preferences
  final bool jobRemindersEnabled;
  final bool unionRemindersEnabled;
  final bool safetyRemindersEnabled;
  
  /// Sound and vibration preferences
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  /// Quiet hours settings
  final bool quietHoursEnabled;
  final int quietHoursStart; // Hour (0-23)
  final int quietHoursEnd;   // Hour (0-23)
  
  /// User's IBEW classifications for job matching
  final List<String> classifications;
  
  /// Preferred job locations
  final List<String> preferredLocations;
  
  /// Union local number
  final String? unionLocal;
  
  /// Minimum hourly rate for job alerts
  final double? minHourlyRate;
  
  /// User's current location for storm work alerts
  final String? location;

  const NotificationPreferencesModel({
    this.fcmToken,
    this.tokenUpdatedAt,
    this.jobAlertsEnabled = true,
    this.safetyAlertsEnabled = true,
    this.unionUpdatesEnabled = true,
    this.applicationUpdatesEnabled = true,
    this.systemNotificationsEnabled = true,
    this.stormWorkEnabled = true,
    this.jobRemindersEnabled = true,
    this.unionRemindersEnabled = true,
    this.safetyRemindersEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
    this.classifications = const [],
    this.preferredLocations = const [],
    this.unionLocal,
    this.minHourlyRate,
    this.location,
  });

  /// Create from Firestore document
  factory NotificationPreferencesModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationPreferencesModel(
      fcmToken: data['fcmToken'] as String?,
      tokenUpdatedAt: data['tokenUpdatedAt']?.toDate(),
      jobAlertsEnabled: data['jobAlertsEnabled'] ?? true,
      safetyAlertsEnabled: data['safetyAlertsEnabled'] ?? true,
      unionUpdatesEnabled: data['unionUpdatesEnabled'] ?? true,
      applicationUpdatesEnabled: data['applicationUpdatesEnabled'] ?? true,
      systemNotificationsEnabled: data['systemNotificationsEnabled'] ?? true,
      stormWorkEnabled: data['stormWorkEnabled'] ?? true,
      jobRemindersEnabled: data['jobRemindersEnabled'] ?? true,
      unionRemindersEnabled: data['unionRemindersEnabled'] ?? true,
      safetyRemindersEnabled: data['safetyRemindersEnabled'] ?? true,
      soundEnabled: data['soundEnabled'] ?? true,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      quietHoursEnabled: data['quietHoursEnabled'] ?? false,
      quietHoursStart: data['quietHoursStart'] ?? 22,
      quietHoursEnd: data['quietHoursEnd'] ?? 7,
      classifications: List<String>.from(data['classifications'] ?? []),
      preferredLocations: List<String>.from(data['preferredLocations'] ?? []),
      unionLocal: data['unionLocal'] as String?,
      minHourlyRate: data['minHourlyRate']?.toDouble(),
      location: data['location'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (tokenUpdatedAt != null) 'tokenUpdatedAt': tokenUpdatedAt,
      'jobAlertsEnabled': jobAlertsEnabled,
      'safetyAlertsEnabled': safetyAlertsEnabled,
      'unionUpdatesEnabled': unionUpdatesEnabled,
      'applicationUpdatesEnabled': applicationUpdatesEnabled,
      'systemNotificationsEnabled': systemNotificationsEnabled,
      'stormWorkEnabled': stormWorkEnabled,
      'jobRemindersEnabled': jobRemindersEnabled,
      'unionRemindersEnabled': unionRemindersEnabled,
      'safetyRemindersEnabled': safetyRemindersEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'classifications': classifications,
      'preferredLocations': preferredLocations,
      if (unionLocal != null) 'unionLocal': unionLocal,
      if (minHourlyRate != null) 'minHourlyRate': minHourlyRate,
      if (location != null) 'location': location,
    };
  }

  /// Create a copy with updated values
  NotificationPreferencesModel copyWith({
    String? fcmToken,
    DateTime? tokenUpdatedAt,
    bool? jobAlertsEnabled,
    bool? safetyAlertsEnabled,
    bool? unionUpdatesEnabled,
    bool? applicationUpdatesEnabled,
    bool? systemNotificationsEnabled,
    bool? stormWorkEnabled,
    bool? jobRemindersEnabled,
    bool? unionRemindersEnabled,
    bool? safetyRemindersEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    List<String>? classifications,
    List<String>? preferredLocations,
    String? unionLocal,
    double? minHourlyRate,
    String? location,
  }) {
    return NotificationPreferencesModel(
      fcmToken: fcmToken ?? this.fcmToken,
      tokenUpdatedAt: tokenUpdatedAt ?? this.tokenUpdatedAt,
      jobAlertsEnabled: jobAlertsEnabled ?? this.jobAlertsEnabled,
      safetyAlertsEnabled: safetyAlertsEnabled ?? this.safetyAlertsEnabled,
      unionUpdatesEnabled: unionUpdatesEnabled ?? this.unionUpdatesEnabled,
      applicationUpdatesEnabled: applicationUpdatesEnabled ?? this.applicationUpdatesEnabled,
      systemNotificationsEnabled: systemNotificationsEnabled ?? this.systemNotificationsEnabled,
      stormWorkEnabled: stormWorkEnabled ?? this.stormWorkEnabled,
      jobRemindersEnabled: jobRemindersEnabled ?? this.jobRemindersEnabled,
      unionRemindersEnabled: unionRemindersEnabled ?? this.unionRemindersEnabled,
      safetyRemindersEnabled: safetyRemindersEnabled ?? this.safetyRemindersEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      classifications: classifications ?? this.classifications,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      unionLocal: unionLocal ?? this.unionLocal,
      minHourlyRate: minHourlyRate ?? this.minHourlyRate,
      location: location ?? this.location,
    );
  }
}