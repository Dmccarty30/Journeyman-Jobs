/// A data model representing a user's notification preferences.
///
/// This class encapsulates all settings related to push and local notifications,
/// including category toggles, job matching criteria, and quiet hours.
class NotificationPreferencesModel {
  /// The user's Firebase Cloud Messaging (FCM) token for receiving push notifications.
  final String? fcmToken;
  
  /// The timestamp when the FCM token was last updated in Firestore.
  final DateTime? tokenUpdatedAt;
  
  /// Whether the user wants to receive alerts for new job postings.
  final bool jobAlertsEnabled;
  /// Whether the user wants to receive updates from their union local.
  final bool unionUpdatesEnabled;
  /// Whether the user wants to receive system-level notifications.
  final bool systemNotificationsEnabled;
  /// Whether the user wants to receive high-priority storm work alerts.
  final bool stormWorkEnabled;
  
  /// Whether the user wants to receive local reminders for job deadlines.
  final bool jobRemindersEnabled;
  /// Whether the user wants to receive local reminders for union meetings.
  final bool unionRemindersEnabled;
  
  /// Whether notifications should play a sound.
  final bool soundEnabled;
  /// Whether notifications should cause the device to vibrate.
  final bool vibrationEnabled;
  
  /// Whether to suppress notifications during a specific time range.
  final bool quietHoursEnabled;
  /// The starting hour (0-23) for the quiet hours period.
  final int quietHoursStart;
  /// The ending hour (0-23) for the quiet hours period.
  final int quietHoursEnd;
  
  /// A list of the user's IBEW classifications for targeted job alerts.
  final List<String> classifications;
  
  /// A list of preferred job locations for targeted job alerts.
  final List<String> preferredLocations;
  
  /// The user's home IBEW local number.
  final String? unionLocal;
  
  /// The minimum hourly wage the user is interested in for job alerts.
  final double? minHourlyRate;
  
  /// The user's general location, used for targeted storm work alerts.
  final String? location;

  /// Creates an instance of [NotificationPreferencesModel].
  const NotificationPreferencesModel({
    this.fcmToken,
    this.tokenUpdatedAt,
    this.jobAlertsEnabled = true,
    this.unionUpdatesEnabled = true,
    this.systemNotificationsEnabled = true,
    this.stormWorkEnabled = true,
    this.jobRemindersEnabled = true,
    this.unionRemindersEnabled = true,
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

  /// Creates a [NotificationPreferencesModel] instance from a Firestore data map.
  factory NotificationPreferencesModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationPreferencesModel(
      fcmToken: data['fcmToken'] as String?,
      tokenUpdatedAt: data['tokenUpdatedAt']?.toDate(),
      jobAlertsEnabled: data['jobAlertsEnabled'] ?? true,
      unionUpdatesEnabled: data['unionUpdatesEnabled'] ?? true,
      systemNotificationsEnabled: data['systemNotificationsEnabled'] ?? true,
      stormWorkEnabled: data['stormWorkEnabled'] ?? true,
      jobRemindersEnabled: data['jobRemindersEnabled'] ?? true,
      unionRemindersEnabled: data['unionRemindersEnabled'] ?? true,
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

  /// Converts the [NotificationPreferencesModel] instance to a map suitable for Firestore.
  ///
  /// Null values for optional fields are omitted to keep the Firestore document clean.
  Map<String, dynamic> toFirestore() {
    return {
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (tokenUpdatedAt != null) 'tokenUpdatedAt': tokenUpdatedAt,
      'jobAlertsEnabled': jobAlertsEnabled,
      'unionUpdatesEnabled': unionUpdatesEnabled,
      'systemNotificationsEnabled': systemNotificationsEnabled,
      'stormWorkEnabled': stormWorkEnabled,
      'jobRemindersEnabled': jobRemindersEnabled,
      'unionRemindersEnabled': unionRemindersEnabled,
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

  /// Creates a new [NotificationPreferencesModel] instance with updated field values.
  NotificationPreferencesModel copyWith({
    String? fcmToken,
    DateTime? tokenUpdatedAt,
    bool? jobAlertsEnabled,
    bool? unionUpdatesEnabled,
    bool? systemNotificationsEnabled,
    bool? stormWorkEnabled,
    bool? jobRemindersEnabled,
    bool? unionRemindersEnabled,
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
      unionUpdatesEnabled: unionUpdatesEnabled ?? this.unionUpdatesEnabled,
      systemNotificationsEnabled: systemNotificationsEnabled ?? this.systemNotificationsEnabled,
      stormWorkEnabled: stormWorkEnabled ?? this.stormWorkEnabled,
      jobRemindersEnabled: jobRemindersEnabled ?? this.jobRemindersEnabled,
      unionRemindersEnabled: unionRemindersEnabled ?? this.unionRemindersEnabled,
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