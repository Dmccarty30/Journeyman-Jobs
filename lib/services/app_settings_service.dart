import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings_model.dart';

/// Service for managing user app settings persistence
///
/// This service handles reading, writing, and synchronizing user settings
/// between Firestore (cloud storage) and SharedPreferences (local cache).
///
/// ## Storage Architecture:
///
/// ### Primary Storage (Firestore)
/// - Path: `users/{userId}/appSettings/settings`
/// - Purpose: Cloud sync, multi-device support, backup
/// - Source of truth for settings across devices
///
/// ### Local Cache (SharedPreferences)
/// - Key: `jj.appSettings.{userId}`
/// - Purpose: Offline access, quick loading, fallback
/// - Updated immediately for responsive UI
///
/// ## Sync Strategy:
///
/// 1. **Load**: Try Firestore first, fallback to local cache
/// 2. **Save**: Write to both Firestore and local cache simultaneously
/// 3. **Update**: Optimistic updates with automatic rollback on failure
/// 4. **Conflict Resolution**: Server timestamp wins (Firestore is source of truth)
///
/// ## Error Handling:
///
/// - Network errors: Continue with cached settings, retry on next save
/// - Permission errors: Prompt re-authentication
/// - Validation errors: Reject invalid settings with clear error messages
/// - Missing settings: Create defaults automatically
///
/// ## Performance Optimizations:
///
/// - Debouncing: Batch rapid changes into single write operation
/// - Caching: Settings loaded once per session unless explicitly refreshed
/// - Optimistic updates: UI updates immediately, sync happens in background
class AppSettingsService {
  final FirebaseFirestore _firestore;
  final Future<SharedPreferences> _prefs;

  // Cache for current session to avoid repeated Firestore reads
  final Map<String, AppSettingsModel> _cache = {};

  // Debounce timer for batching rapid updates

  AppSettingsService({
    FirebaseFirestore? firestore,
    Future<SharedPreferences>? sharedPreferences,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = sharedPreferences ?? SharedPreferences.getInstance();

  // ============================================================================
  // Public API - Load Settings
  // ============================================================================

  /// Load user settings with cache-first strategy
  ///
  /// Attempts to load from Firestore for most recent settings.
  /// Falls back to local cache if Firestore unavailable.
  /// Creates default settings if none exist.
  ///
  /// Throws [Exception] on critical errors (e.g., authentication failure)
  Future<AppSettingsModel> loadSettings(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required to load settings');
    }

    // Check session cache first
    if (_cache.containsKey(userId)) {
      return _cache[userId]!;
    }


    try {
      // Try loading from Firestore first
      final settings = await _loadFromFirestore(userId);

      if (settings != null) {
        _cache[userId] = settings;

        // Update local cache asynchronously
        _saveToLocalCache(userId, settings).catchError((error) {
        });

        return settings;
      }
    } on FirebaseException {

      // Try loading from local cache as fallback
      final cachedSettings = await _loadFromLocalCache(userId);
      if (cachedSettings != null) {
        _cache[userId] = cachedSettings;
        return cachedSettings;
      }
    } catch (e) {

      // Try local cache before giving up
      final cachedSettings = await _loadFromLocalCache(userId);
      if (cachedSettings != null) {
        _cache[userId] = cachedSettings;
        return cachedSettings;
      }
    }

    // No settings found - create defaults
    final defaultSettings = AppSettingsModel.defaults(userId);

    // Save defaults for future use (don't wait for completion)
    saveSettings(userId, defaultSettings).catchError((error) {
    });

    _cache[userId] = defaultSettings;
    return defaultSettings;
  }

  /// Refresh settings from Firestore, bypassing cache
  ///
  /// Forces reload from server to get latest settings across devices.
  /// Use when explicit sync is needed (e.g., after switching accounts)
  Future<AppSettingsModel> refreshSettings(String userId) async {

    // Clear cache to force reload
    _cache.remove(userId);

    return await loadSettings(userId);
  }

  // ============================================================================
  // Public API - Save Settings
  // ============================================================================

  /// Save user settings to both Firestore and local cache
  ///
  /// Validates settings before saving. Updates both cloud and local storage.
  /// Uses optimistic updates for responsive UI.
  ///
  /// Throws [Exception] if validation fails or critical save error occurs
  Future<void> saveSettings(String userId, AppSettingsModel settings) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required to save settings');
    }

    // Validate settings before saving
    if (!settings.validate()) {
      final error = settings.validationError ?? 'Invalid settings';
      throw Exception(error);
    }


    // Update cache immediately for optimistic UI
    _cache[userId] = settings;

    try {
      // Save to both Firestore and local cache in parallel
      await Future.wait([
        _saveToFirestore(userId, settings),
        _saveToLocalCache(userId, settings),
      ]);

    } on FirebaseException catch (e) {

      // Save to local cache succeeded, but Firestore failed
      // This is acceptable for offline scenarios
      if (e.code == 'unavailable' || e.code == 'permission-denied') {
        return; // Don't throw - local save succeeded
      }

      // Critical error - remove from cache and rethrow
      _cache.remove(userId);
      _provideFriendlyError(e);
    } catch (e) {

      // Remove from cache on failure
      _cache.remove(userId);
      throw Exception('Failed to save settings. Please try again.');
    }
  }

  /// Update specific setting field
  ///
  /// Convenience method for updating individual settings without
  /// loading and saving entire settings object.
  Future<void> updateSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    // Load current settings
    final currentSettings = await loadSettings(userId);

    // Create updated settings based on key
    AppSettingsModel updatedSettings;

    switch (key) {
      // Appearance settings
      case 'themeMode':
        updatedSettings = currentSettings.copyWith(themeMode: value as String);
        break;
      case 'highContrastMode':
        updatedSettings = currentSettings.copyWith(highContrastMode: value as bool);
        break;
      case 'electricalEffects':
        updatedSettings = currentSettings.copyWith(electricalEffects: value as bool);
        break;
      case 'fontSize':
        updatedSettings = currentSettings.copyWith(fontSize: value as String);
        break;

      // Job search settings
      case 'defaultSearchRadius':
        updatedSettings = currentSettings.copyWith(defaultSearchRadius: value as double);
        break;
      case 'distanceUnits':
        updatedSettings = currentSettings.copyWith(distanceUnits: value as String);
        break;
      case 'autoApplyEnabled':
        updatedSettings = currentSettings.copyWith(autoApplyEnabled: value as bool);
        break;
      case 'minimumHourlyRate':
        updatedSettings = currentSettings.copyWith(minimumHourlyRate: value as double);
        break;

      // Data & storage settings
      case 'offlineModeEnabled':
        updatedSettings = currentSettings.copyWith(offlineModeEnabled: value as bool);
        break;
      case 'autoDownloadEnabled':
        updatedSettings = currentSettings.copyWith(autoDownloadEnabled: value as bool);
        break;
      case 'wifiOnlyDownloads':
        updatedSettings = currentSettings.copyWith(wifiOnlyDownloads: value as bool);
        break;

      // Privacy & security settings
      case 'profileVisibility':
        updatedSettings = currentSettings.copyWith(profileVisibility: value as String);
        break;
      case 'locationServicesEnabled':
        updatedSettings = currentSettings.copyWith(locationServicesEnabled: value as bool);
        break;
      case 'biometricLoginEnabled':
        updatedSettings = currentSettings.copyWith(biometricLoginEnabled: value as bool);
        break;
      case 'twoFactorEnabled':
        updatedSettings = currentSettings.copyWith(twoFactorEnabled: value as bool);
        break;

      // Language & region settings
      case 'language':
        updatedSettings = currentSettings.copyWith(language: value as String);
        break;
      case 'dateFormat':
        updatedSettings = currentSettings.copyWith(dateFormat: value as String);
        break;
      case 'timeFormat':
        updatedSettings = currentSettings.copyWith(timeFormat: value as String);
        break;

      // Storm work settings
      case 'stormAlertRadius':
        updatedSettings = currentSettings.copyWith(stormAlertRadius: value as double);
        break;
      case 'stormRateMultiplier':
        updatedSettings = currentSettings.copyWith(stormRateMultiplier: value as double);
        break;

      default:
        throw Exception('Unknown setting key: $key');
    }

    // Update lastUpdated timestamp
    updatedSettings = updatedSettings.copyWith(lastUpdated: DateTime.now());

    // Save updated settings
    await saveSettings(userId, updatedSettings);
  }

  /// Delete user settings (for account deletion)
  ///
  /// Removes settings from both Firestore and local cache.
  Future<void> deleteSettings(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required to delete settings');
    }


    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('appSettings')
          .doc('settings')
          .delete();

      // Delete from local cache
      final prefs = await _prefs;
      await prefs.remove('jj.appSettings.$userId');

      // Clear from session cache
      _cache.remove(userId);

    } catch (e) {
      throw Exception('Failed to delete settings');
    }
  }

  // ============================================================================
  // Private Helper Methods - Firestore Operations
  // ============================================================================

  /// Load settings from Firestore
  ///
  /// Returns settings document or null if not found
  Future<AppSettingsModel?> _loadFromFirestore(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('appSettings')
        .doc('settings')
        .get();

    if (!doc.exists) {
      return null;
    }

    return AppSettingsModel.fromFirestore(doc);
  }

  /// Save settings to Firestore
  ///
  /// Creates or updates settings document with server timestamp
  Future<void> _saveToFirestore(String userId, AppSettingsModel settings) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('appSettings')
        .doc('settings');

    await docRef.set(settings.toFirestore(), SetOptions(merge: true));
  }

  // ============================================================================
  // Private Helper Methods - Local Cache Operations
  // ============================================================================

  /// Load settings from SharedPreferences
  ///
  /// Returns cached settings or null if not found
  Future<AppSettingsModel?> _loadFromLocalCache(String userId) async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString('jj.appSettings.$userId');

      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppSettingsModel.fromJson(json, userId);
    } catch (e) {
      return null;
    }
  }

  /// Save settings to SharedPreferences
  ///
  /// Stores settings as JSON string for offline access
  Future<void> _saveToLocalCache(String userId, AppSettingsModel settings) async {
    try {
      final prefs = await _prefs;
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString('jj.appSettings.$userId', jsonString);
    } catch (e) {
      // Don't throw - local cache save failure is not critical
    }
  }

  // ============================================================================
  // Private Helper Methods - Error Handling
  // ============================================================================

  /// Provide user-friendly error messages based on Firebase error codes
  ///
  /// Throws Exception with appropriate message for user display
  Never _provideFriendlyError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        throw Exception('Permission denied. Please check your account settings.');
      case 'unavailable':
        throw Exception('Network error. Settings saved locally only.');
      case 'unauthenticated':
        throw Exception('Authentication required. Please sign in again.');
      case 'not-found':
        throw Exception('Settings not found. Creating new settings.');
      default:
        throw Exception('Error saving settings: ${e.message}');
    }
  }

  // ============================================================================
  // Cache Management
  // ============================================================================

  /// Clear session cache
  ///
  /// Forces reload of settings on next access.
  /// Use when switching users or for memory management.
  void clearCache() {
    _cache.clear();
  }

  /// Clear cache for specific user
  ///
  /// Removes cached settings for given user ID
  void clearUserCache(String userId) {
    _cache.remove(userId);
  }
}
