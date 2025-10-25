import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive app settings model for user preferences persistence
///
/// This model stores all user-configurable settings for the Journeyman Jobs app,
/// including appearance, job search preferences, data management, privacy settings,
/// localization, and storm work configurations.
///
/// ## Storage Strategy:
/// - Primary storage: Firestore at `users/{userId}/appSettings/settings` for cloud sync
/// - Fallback storage: SharedPreferences for offline access and quick loading
/// - Sync strategy: Optimistic updates with Firestore as source of truth
///
/// ## Sections:
///
/// ### Appearance Settings
/// - Dark mode configuration (light/dark/system)
/// - High contrast mode for sunlight visibility
/// - Electrical effects animations toggle
/// - Font size adjustment for accessibility
///
/// ### Job Search Preferences
/// - Default search radius for job discovery
/// - Distance units (miles/kilometers)
/// - Auto-apply toggle for matching jobs
/// - Minimum hourly rate filter
///
/// ### Data & Storage Settings
/// - Offline mode for union directory access
/// - Auto-download for weather maps and updates
/// - Wi-Fi only downloads to preserve cellular data
///
/// ### Privacy & Security
/// - Profile visibility (public/union members/private)
/// - Location services toggle
/// - Biometric login (Face ID/Touch ID)
/// - Two-factor authentication
///
/// ### Language & Region
/// - Language selection (English/Spanish/French)
/// - Date format preference
/// - Time format (12-hour/24-hour)
///
/// ### Storm Work Settings
/// - Storm alert radius for weather notifications
/// - Minimum rate multiplier for storm work
///
/// ## Firebase Integration:
/// All fields map to Firestore document structure with automatic serialization
@immutable
class AppSettingsModel {
  // ============================================================================
  // Appearance & Display Settings
  // ============================================================================

  /// Theme mode selection: 'light', 'dark', or 'system'
  ///
  /// Controls the overall app appearance theme. System mode follows device settings.
  final String themeMode;

  /// High contrast mode for better visibility in bright sunlight
  ///
  /// Increases contrast ratios for outdoor use, particularly useful for
  /// electrical workers on job sites.
  final bool highContrastMode;

  /// Enable electrical-themed animations and visual effects
  ///
  /// Controls circuit pattern animations, lightning effects, and other
  /// IBEW-themed visual elements. Disable to improve performance on older devices.
  final bool electricalEffects;

  /// Font size preference: 'Small', 'Medium', 'Large', or 'Extra Large'
  ///
  /// Adjusts text size throughout the app for accessibility and personal preference.
  final String fontSize;

  // ============================================================================
  // Job Search Preferences
  // ============================================================================

  /// Default search radius for job discovery in selected units
  ///
  /// Range: 10-500 (miles or kilometers based on units setting)
  /// Determines how far from user's location to search for job postings.
  final double defaultSearchRadius;

  /// Distance units preference: 'Miles' or 'Kilometers'
  ///
  /// Applied to search radius, job distances, and storm alert radius.
  final String distanceUnits;

  /// Automatically apply to jobs matching user preferences
  ///
  /// When enabled, user's profile is automatically submitted to jobs that
  /// match their classification, construction types, and preferences.
  final bool autoApplyEnabled;

  /// Minimum acceptable hourly rate for job filtering
  ///
  /// Range: $20-$100/hour
  /// Jobs below this rate are filtered from search results.
  final double minimumHourlyRate;

  // ============================================================================
  // Data & Storage Settings
  // ============================================================================

  /// Enable offline mode for accessing union directory without internet
  ///
  /// Downloads complete IBEW local directory for offline access.
  /// Requires initial data download of ~50MB.
  final bool offlineModeEnabled;

  /// Automatically download weather maps and union updates
  ///
  /// When enabled, app pre-fetches weather data and union directory updates
  /// for faster access and offline availability.
  final bool autoDownloadEnabled;

  /// Restrict downloads to Wi-Fi connections only
  ///
  /// Prevents large data transfers over cellular networks to preserve data plans.
  /// Recommended for workers with limited cellular data.
  final bool wifiOnlyDownloads;

  // ============================================================================
  // Privacy & Security Settings
  // ============================================================================

  /// Profile visibility level: 'Public', 'Union Members Only', or 'Private'
  ///
  /// - Public: Visible to all app users and contractors
  /// - Union Members Only: Visible only to verified IBEW members
  /// - Private: Visible only to user and their crews
  final String profileVisibility;

  /// Enable location services for job matching and weather alerts
  ///
  /// Required for accurate job distance calculations and severe weather
  /// notifications. Location data is never shared without user consent.
  final bool locationServicesEnabled;

  /// Enable biometric authentication (Face ID, Touch ID, fingerprint)
  ///
  /// Provides quick and secure app access using device biometrics.
  /// Falls back to password if biometric authentication fails.
  final bool biometricLoginEnabled;

  /// Two-factor authentication enabled for account security
  ///
  /// Requires second factor (SMS code, authenticator app) for sign-in.
  /// Strongly recommended for protecting sensitive IBEW membership data.
  final bool twoFactorEnabled;

  // ============================================================================
  // Language & Region Settings
  // ============================================================================

  /// Language preference: 'English', 'Spanish', or 'French'
  ///
  /// Controls app UI language and localized content.
  final String language;

  /// Date format preference: 'MM/DD/YYYY', 'DD/MM/YYYY', or 'YYYY-MM-DD'
  ///
  /// Formats all dates throughout the app according to regional preference.
  final String dateFormat;

  /// Time format preference: '12-hour' or '24-hour'
  ///
  /// Controls display of times (job shifts, dispatch times, etc.)
  final String timeFormat;

  // ============================================================================
  // Storm Work Settings
  // ============================================================================

  /// Radius for storm work alerts in selected distance units
  ///
  /// Range: 50-500 (miles or kilometers)
  /// Determines area for severe weather alerts and storm work notifications.
  final double stormAlertRadius;

  /// Minimum rate multiplier for storm work
  ///
  /// Range: 1.0-3.0x regular rate
  /// Jobs below this multiplier are filtered from storm work listings.
  final double stormRateMultiplier;

  // ============================================================================
  // Metadata
  // ============================================================================

  /// Last time settings were updated
  ///
  /// Used for conflict resolution during sync and determining cache freshness.
  final DateTime lastUpdated;

  /// User ID this settings document belongs to
  ///
  /// Ensures settings are properly associated with user account.
  final String userId;

  // ============================================================================
  // Constructor
  // ============================================================================

  const AppSettingsModel({
    // Appearance
    this.themeMode = 'system',
    this.highContrastMode = false,
    this.electricalEffects = true,
    this.fontSize = 'Medium',

    // Job Search
    this.defaultSearchRadius = 50.0,
    this.distanceUnits = 'Miles',
    this.autoApplyEnabled = false,
    this.minimumHourlyRate = 35.0,

    // Data & Storage
    this.offlineModeEnabled = false,
    this.autoDownloadEnabled = true,
    this.wifiOnlyDownloads = true,

    // Privacy & Security
    this.profileVisibility = 'Union Members Only',
    this.locationServicesEnabled = true,
    this.biometricLoginEnabled = false,
    this.twoFactorEnabled = false,

    // Language & Region
    this.language = 'English',
    this.dateFormat = 'MM/DD/YYYY',
    this.timeFormat = '12-hour',

    // Storm Work
    this.stormAlertRadius = 100.0,
    this.stormRateMultiplier = 1.5,

    // Metadata
    required this.lastUpdated,
    required this.userId,
  });

  // ============================================================================
  // Factory Constructors
  // ============================================================================

  /// Create empty/default settings for a new user
  ///
  /// Returns settings with sensible defaults for IBEW electrical workers.
  factory AppSettingsModel.defaults(String userId) {
    return AppSettingsModel(
      userId: userId,
      lastUpdated: DateTime.now(),
      // All other fields use constructor defaults
    );
  }

  /// Create settings from Firestore document
  ///
  /// Deserializes Firestore document data into AppSettingsModel.
  /// Handles missing fields gracefully with defaults.
  factory AppSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AppSettingsModel(
      // Appearance
      themeMode: data['themeMode'] ?? 'system',
      highContrastMode: data['highContrastMode'] ?? false,
      electricalEffects: data['electricalEffects'] ?? true,
      fontSize: data['fontSize'] ?? 'Medium',

      // Job Search
      defaultSearchRadius: (data['defaultSearchRadius'] ?? 50.0).toDouble(),
      distanceUnits: data['distanceUnits'] ?? 'Miles',
      autoApplyEnabled: data['autoApplyEnabled'] ?? false,
      minimumHourlyRate: (data['minimumHourlyRate'] ?? 35.0).toDouble(),

      // Data & Storage
      offlineModeEnabled: data['offlineModeEnabled'] ?? false,
      autoDownloadEnabled: data['autoDownloadEnabled'] ?? true,
      wifiOnlyDownloads: data['wifiOnlyDownloads'] ?? true,

      // Privacy & Security
      profileVisibility: data['profileVisibility'] ?? 'Union Members Only',
      locationServicesEnabled: data['locationServicesEnabled'] ?? true,
      biometricLoginEnabled: data['biometricLoginEnabled'] ?? false,
      twoFactorEnabled: data['twoFactorEnabled'] ?? false,

      // Language & Region
      language: data['language'] ?? 'English',
      dateFormat: data['dateFormat'] ?? 'MM/DD/YYYY',
      timeFormat: data['timeFormat'] ?? '12-hour',

      // Storm Work
      stormAlertRadius: (data['stormAlertRadius'] ?? 100.0).toDouble(),
      stormRateMultiplier: (data['stormRateMultiplier'] ?? 1.5).toDouble(),

      // Metadata
      lastUpdated: data['lastUpdated'] is Timestamp
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      userId: doc.id,
    );
  }

  /// Create settings from JSON map
  ///
  /// Used for SharedPreferences deserialization and testing.
  factory AppSettingsModel.fromJson(Map<String, dynamic> json, String userId) {
    return AppSettingsModel(
      // Appearance
      themeMode: json['themeMode'] ?? 'system',
      highContrastMode: json['highContrastMode'] ?? false,
      electricalEffects: json['electricalEffects'] ?? true,
      fontSize: json['fontSize'] ?? 'Medium',

      // Job Search
      defaultSearchRadius: (json['defaultSearchRadius'] ?? 50.0).toDouble(),
      distanceUnits: json['distanceUnits'] ?? 'Miles',
      autoApplyEnabled: json['autoApplyEnabled'] ?? false,
      minimumHourlyRate: (json['minimumHourlyRate'] ?? 35.0).toDouble(),

      // Data & Storage
      offlineModeEnabled: json['offlineModeEnabled'] ?? false,
      autoDownloadEnabled: json['autoDownloadEnabled'] ?? true,
      wifiOnlyDownloads: json['wifiOnlyDownloads'] ?? true,

      // Privacy & Security
      profileVisibility: json['profileVisibility'] ?? 'Union Members Only',
      locationServicesEnabled: json['locationServicesEnabled'] ?? true,
      biometricLoginEnabled: json['biometricLoginEnabled'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,

      // Language & Region
      language: json['language'] ?? 'English',
      dateFormat: json['dateFormat'] ?? 'MM/DD/YYYY',
      timeFormat: json['timeFormat'] ?? '12-hour',

      // Storm Work
      stormAlertRadius: (json['stormAlertRadius'] ?? 100.0).toDouble(),
      stormRateMultiplier: (json['stormRateMultiplier'] ?? 1.5).toDouble(),

      // Metadata
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      userId: userId,
    );
  }

  // ============================================================================
  // Serialization Methods
  // ============================================================================

  /// Convert settings to JSON map for SharedPreferences storage
  ///
  /// Serializes all fields to JSON-compatible format for local caching.
  Map<String, dynamic> toJson() {
    return {
      // Appearance
      'themeMode': themeMode,
      'highContrastMode': highContrastMode,
      'electricalEffects': electricalEffects,
      'fontSize': fontSize,

      // Job Search
      'defaultSearchRadius': defaultSearchRadius,
      'distanceUnits': distanceUnits,
      'autoApplyEnabled': autoApplyEnabled,
      'minimumHourlyRate': minimumHourlyRate,

      // Data & Storage
      'offlineModeEnabled': offlineModeEnabled,
      'autoDownloadEnabled': autoDownloadEnabled,
      'wifiOnlyDownloads': wifiOnlyDownloads,

      // Privacy & Security
      'profileVisibility': profileVisibility,
      'locationServicesEnabled': locationServicesEnabled,
      'biometricLoginEnabled': biometricLoginEnabled,
      'twoFactorEnabled': twoFactorEnabled,

      // Language & Region
      'language': language,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,

      // Storm Work
      'stormAlertRadius': stormAlertRadius,
      'stormRateMultiplier': stormRateMultiplier,

      // Metadata
      'lastUpdated': lastUpdated.toIso8601String(),
      'userId': userId,
    };
  }

  /// Convert settings to Firestore document format
  ///
  /// Serializes fields for Firestore storage with server timestamp.
  Map<String, dynamic> toFirestore() {
    return {
      // Appearance
      'themeMode': themeMode,
      'highContrastMode': highContrastMode,
      'electricalEffects': electricalEffects,
      'fontSize': fontSize,

      // Job Search
      'defaultSearchRadius': defaultSearchRadius,
      'distanceUnits': distanceUnits,
      'autoApplyEnabled': autoApplyEnabled,
      'minimumHourlyRate': minimumHourlyRate,

      // Data & Storage
      'offlineModeEnabled': offlineModeEnabled,
      'autoDownloadEnabled': autoDownloadEnabled,
      'wifiOnlyDownloads': wifiOnlyDownloads,

      // Privacy & Security
      'profileVisibility': profileVisibility,
      'locationServicesEnabled': locationServicesEnabled,
      'biometricLoginEnabled': biometricLoginEnabled,
      'twoFactorEnabled': twoFactorEnabled,

      // Language & Region
      'language': language,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,

      // Storm Work
      'stormAlertRadius': stormAlertRadius,
      'stormRateMultiplier': stormRateMultiplier,

      // Metadata
      'lastUpdated': FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Create a copy of settings with specified fields updated
  ///
  /// Immutable update pattern for state management.
  AppSettingsModel copyWith({
    String? themeMode,
    bool? highContrastMode,
    bool? electricalEffects,
    String? fontSize,
    double? defaultSearchRadius,
    String? distanceUnits,
    bool? autoApplyEnabled,
    double? minimumHourlyRate,
    bool? offlineModeEnabled,
    bool? autoDownloadEnabled,
    bool? wifiOnlyDownloads,
    String? profileVisibility,
    bool? locationServicesEnabled,
    bool? biometricLoginEnabled,
    bool? twoFactorEnabled,
    String? language,
    String? dateFormat,
    String? timeFormat,
    double? stormAlertRadius,
    double? stormRateMultiplier,
    DateTime? lastUpdated,
    String? userId,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      electricalEffects: electricalEffects ?? this.electricalEffects,
      fontSize: fontSize ?? this.fontSize,
      defaultSearchRadius: defaultSearchRadius ?? this.defaultSearchRadius,
      distanceUnits: distanceUnits ?? this.distanceUnits,
      autoApplyEnabled: autoApplyEnabled ?? this.autoApplyEnabled,
      minimumHourlyRate: minimumHourlyRate ?? this.minimumHourlyRate,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
      autoDownloadEnabled: autoDownloadEnabled ?? this.autoDownloadEnabled,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
      biometricLoginEnabled: biometricLoginEnabled ?? this.biometricLoginEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      stormAlertRadius: stormAlertRadius ?? this.stormAlertRadius,
      stormRateMultiplier: stormRateMultiplier ?? this.stormRateMultiplier,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
    );
  }

  /// Validate settings before saving
  ///
  /// Ensures all values are within acceptable ranges and constraints.
  /// Returns true if settings are valid, false otherwise.
  bool validate() {
    // Theme mode validation
    if (!['light', 'dark', 'system'].contains(themeMode)) return false;

    // Font size validation
    if (!['Small', 'Medium', 'Large', 'Extra Large'].contains(fontSize)) return false;

    // Search radius validation (10-500)
    if (defaultSearchRadius < 10 || defaultSearchRadius > 500) return false;

    // Distance units validation
    if (!['Miles', 'Kilometers'].contains(distanceUnits)) return false;

    // Hourly rate validation ($20-$100)
    if (minimumHourlyRate < 20 || minimumHourlyRate > 100) return false;

    // Profile visibility validation
    if (!['Public', 'Union Members Only', 'Private'].contains(profileVisibility)) return false;

    // Language validation
    if (!['English', 'Spanish', 'French'].contains(language)) return false;

    // Date format validation
    if (!['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'].contains(dateFormat)) return false;

    // Time format validation
    if (!['12-hour', '24-hour'].contains(timeFormat)) return false;

    // Storm alert radius validation (50-500)
    if (stormAlertRadius < 50 || stormAlertRadius > 500) return false;

    // Storm rate multiplier validation (1.0-3.0)
    if (stormRateMultiplier < 1.0 || stormRateMultiplier > 3.0) return false;

    return true;
  }

  /// Get validation error message if settings are invalid
  ///
  /// Returns null if settings are valid, otherwise returns descriptive error message.
  String? get validationError {
    if (!['light', 'dark', 'system'].contains(themeMode)) {
      return 'Invalid theme mode. Must be light, dark, or system.';
    }

    if (!['Small', 'Medium', 'Large', 'Extra Large'].contains(fontSize)) {
      return 'Invalid font size. Must be Small, Medium, Large, or Extra Large.';
    }

    if (defaultSearchRadius < 10 || defaultSearchRadius > 500) {
      return 'Search radius must be between 10 and 500.';
    }

    if (!['Miles', 'Kilometers'].contains(distanceUnits)) {
      return 'Distance units must be Miles or Kilometers.';
    }

    if (minimumHourlyRate < 20 || minimumHourlyRate > 100) {
      return 'Minimum hourly rate must be between \$20 and \$100.';
    }

    if (!['Public', 'Union Members Only', 'Private'].contains(profileVisibility)) {
      return 'Invalid profile visibility setting.';
    }

    if (!['English', 'Spanish', 'French'].contains(language)) {
      return 'Unsupported language. Must be English, Spanish, or French.';
    }

    if (!['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'].contains(dateFormat)) {
      return 'Invalid date format.';
    }

    if (!['12-hour', '24-hour'].contains(timeFormat)) {
      return 'Time format must be 12-hour or 24-hour.';
    }

    if (stormAlertRadius < 50 || stormAlertRadius > 500) {
      return 'Storm alert radius must be between 50 and 500.';
    }

    if (stormRateMultiplier < 1.0 || stormRateMultiplier > 3.0) {
      return 'Storm rate multiplier must be between 1.0x and 3.0x.';
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModel &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          highContrastMode == other.highContrastMode &&
          electricalEffects == other.electricalEffects &&
          fontSize == other.fontSize &&
          defaultSearchRadius == other.defaultSearchRadius &&
          distanceUnits == other.distanceUnits &&
          autoApplyEnabled == other.autoApplyEnabled &&
          minimumHourlyRate == other.minimumHourlyRate &&
          offlineModeEnabled == other.offlineModeEnabled &&
          autoDownloadEnabled == other.autoDownloadEnabled &&
          wifiOnlyDownloads == other.wifiOnlyDownloads &&
          profileVisibility == other.profileVisibility &&
          locationServicesEnabled == other.locationServicesEnabled &&
          biometricLoginEnabled == other.biometricLoginEnabled &&
          twoFactorEnabled == other.twoFactorEnabled &&
          language == other.language &&
          dateFormat == other.dateFormat &&
          timeFormat == other.timeFormat &&
          stormAlertRadius == other.stormAlertRadius &&
          stormRateMultiplier == other.stormRateMultiplier &&
          userId == other.userId;

  @override
  int get hashCode => Object.hashAll([
        themeMode,
        highContrastMode,
        electricalEffects,
        fontSize,
        defaultSearchRadius,
        distanceUnits,
        autoApplyEnabled,
        minimumHourlyRate,
        offlineModeEnabled,
        autoDownloadEnabled,
        wifiOnlyDownloads,
        profileVisibility,
        locationServicesEnabled,
        biometricLoginEnabled,
        twoFactorEnabled,
        language,
        dateFormat,
        timeFormat,
        stormAlertRadius,
        stormRateMultiplier,
        userId,
      ]);
}
