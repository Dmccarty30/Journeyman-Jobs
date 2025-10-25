import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_settings_model.dart';
import '../../services/app_settings_service.dart';
import '../../utils/concurrent_operations.dart';

part 'app_settings_riverpod_provider.g.dart';

/// State model for app settings with loading and error handling
///
/// Provides reactive state management for user app settings with
/// loading indicators, error messages, and last updated timestamps.
class AppSettingsState {
  /// Current settings (defaults if none loaded)
  final AppSettingsModel settings;

  /// Whether settings are currently being loaded or saved
  final bool isLoading;

  /// Error message if an operation failed
  final String? error;

  /// Last time settings were successfully loaded or saved
  final DateTime? lastUpdated;

  const AppSettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  /// Create initial state with default settings
  factory AppSettingsState.initial(String userId) {
    return AppSettingsState(
      settings: AppSettingsModel.defaults(userId),
      isLoading: false,
    );
  }

  /// Create copy with updated fields
  AppSettingsState copyWith({
    AppSettingsModel? settings,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return AppSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Clear error message
  AppSettingsState clearError() => copyWith(clearError: true);
}

// ============================================================================
// Service Provider
// ============================================================================

/// Provider for app settings service instance
///
/// Creates singleton service with Firestore and SharedPreferences dependencies
@riverpod
AppSettingsService appSettingsService(Ref ref) {
  return AppSettingsService(
    firestore: FirebaseFirestore.instance,
  );
}

// ============================================================================
// State Notifier Provider
// ============================================================================

/// Riverpod notifier for managing app settings state
///
/// Handles loading, saving, and updating user app settings with
/// Firestore persistence and local caching. Provides reactive state
/// updates for UI components.
///
/// ## Usage:
///
/// ```dart
/// // Watch settings state
/// final settingsState = ref.watch(appSettingsNotifierProvider);
///
/// // Load settings for user
/// ref.read(appSettingsNotifierProvider.notifier).loadSettings(userId);
///
/// // Update single setting
/// ref.read(appSettingsNotifierProvider.notifier).updateThemeMode('dark');
///
/// // Save all settings
/// ref.read(appSettingsNotifierProvider.notifier).saveSettings(userId, settings);
/// ```
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  late final ConcurrentOperationManager _operationManager;
  late final AppSettingsService _service;

  @override
  AppSettingsState build() {
    _operationManager = ConcurrentOperationManager();
    _service = ref.watch(appSettingsServiceProvider);

    // Return initial state - settings will be loaded when user ID is available
    return AppSettingsState(
      settings: AppSettingsModel.defaults(''),
      isLoading: false,
    );
  }

  // ============================================================================
  // Load Settings
  // ============================================================================

  /// Load user settings from Firestore with local cache fallback
  ///
  /// Attempts to load from cloud storage first, falls back to local cache
  /// if offline. Creates default settings if none exist.
  Future<void> loadSettings(String userId) async {
    if (userId.isEmpty) {
      state = state.copyWith(
        error: 'User ID is required to load settings',
        isLoading: false,
      );
      return;
    }

    // Prevent concurrent load operations
    if (_operationManager.isOperationInProgress(OperationType.loadUserProfile)) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _operationManager.executeOperation(
        type: OperationType.loadUserProfile,
        operation: () async {

          final settings = await _service.loadSettings(userId);

          state = state.copyWith(
            settings: settings,
            isLoading: false,
            lastUpdated: DateTime.now(),
            clearError: true,
          );

        },
      );
    } catch (e) {

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      rethrow;
    }
  }

  /// Refresh settings from Firestore, bypassing cache
  ///
  /// Forces reload from server to sync latest settings across devices.
  Future<void> refreshSettings(String userId) async {
    if (userId.isEmpty) {
      state = state.copyWith(
        error: 'User ID is required to refresh settings',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {

      final settings = await _service.refreshSettings(userId);

      state = state.copyWith(
        settings: settings,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );

    } catch (e) {

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      rethrow;
    }
  }

  // ============================================================================
  // Save Settings
  // ============================================================================

  /// Save complete settings to Firestore and local cache
  ///
  /// Validates settings before saving. Updates both cloud and local storage.
  /// Uses optimistic updates for responsive UI.
  Future<void> saveSettings(String userId, AppSettingsModel settings) async {
    if (userId.isEmpty) {
      state = state.copyWith(
        error: 'User ID is required to save settings',
      );
      throw Exception('User ID is required to save settings');
    }

    // Prevent concurrent save operations
    if (_operationManager.isOperationInProgress(OperationType.updateUserProfile)) {
      throw Exception('A save operation is already in progress');
    }

    // Optimistic update - update UI immediately
    final previousSettings = state.settings;
    state = state.copyWith(settings: settings, isLoading: true, clearError: true);

    try {
      await _operationManager.executeOperation(
        type: OperationType.updateUserProfile,
        operation: () async {

          await _service.saveSettings(userId, settings);

          state = state.copyWith(
            isLoading: false,
            lastUpdated: DateTime.now(),
            clearError: true,
          );

        },
      );
    } catch (e) {

      // Rollback optimistic update
      state = state.copyWith(
        settings: previousSettings,
        isLoading: false,
        error: e.toString(),
      );

      rethrow;
    }
  }

  // ============================================================================
  // Convenience Methods - Update Individual Settings
  // ============================================================================

  /// Update theme mode (light/dark/system)
  Future<void> updateThemeMode(String userId, String themeMode) async {
    final updatedSettings = state.settings.copyWith(
      themeMode: themeMode,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update high contrast mode
  Future<void> updateHighContrastMode(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      highContrastMode: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update electrical effects
  Future<void> updateElectricalEffects(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      electricalEffects: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update font size
  Future<void> updateFontSize(String userId, String fontSize) async {
    final updatedSettings = state.settings.copyWith(
      fontSize: fontSize,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update default search radius
  Future<void> updateSearchRadius(String userId, double radius) async {
    final updatedSettings = state.settings.copyWith(
      defaultSearchRadius: radius,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update distance units
  Future<void> updateDistanceUnits(String userId, String units) async {
    final updatedSettings = state.settings.copyWith(
      distanceUnits: units,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update auto-apply setting
  Future<void> updateAutoApply(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      autoApplyEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update minimum hourly rate
  Future<void> updateMinimumHourlyRate(String userId, double rate) async {
    final updatedSettings = state.settings.copyWith(
      minimumHourlyRate: rate,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update offline mode
  Future<void> updateOfflineMode(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      offlineModeEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update auto-download setting
  Future<void> updateAutoDownload(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      autoDownloadEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update Wi-Fi only downloads
  Future<void> updateWifiOnlyDownloads(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      wifiOnlyDownloads: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update profile visibility
  Future<void> updateProfileVisibility(String userId, String visibility) async {
    final updatedSettings = state.settings.copyWith(
      profileVisibility: visibility,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update location services
  Future<void> updateLocationServices(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      locationServicesEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update biometric login
  Future<void> updateBiometricLogin(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      biometricLoginEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update two-factor authentication
  Future<void> updateTwoFactor(String userId, bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      twoFactorEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update language preference
  Future<void> updateLanguage(String userId, String language) async {
    final updatedSettings = state.settings.copyWith(
      language: language,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update date format
  Future<void> updateDateFormat(String userId, String dateFormat) async {
    final updatedSettings = state.settings.copyWith(
      dateFormat: dateFormat,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update time format
  Future<void> updateTimeFormat(String userId, String timeFormat) async {
    final updatedSettings = state.settings.copyWith(
      timeFormat: timeFormat,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update storm alert radius
  Future<void> updateStormAlertRadius(String userId, double radius) async {
    final updatedSettings = state.settings.copyWith(
      stormAlertRadius: radius,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  /// Update storm rate multiplier
  Future<void> updateStormRateMultiplier(String userId, double multiplier) async {
    final updatedSettings = state.settings.copyWith(
      stormRateMultiplier: multiplier,
      lastUpdated: DateTime.now(),
    );
    await saveSettings(userId, updatedSettings);
  }

  // ============================================================================
  // Error Handling
  // ============================================================================

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }

  // ============================================================================
  // Cleanup
  // ============================================================================

  /// Dispose resources
  void dispose() {
    _operationManager.dispose();
  }
}

// ============================================================================
// Convenience Providers
// ============================================================================

/// Provider for current app settings
@riverpod
AppSettingsModel currentAppSettings(Ref ref) {
  final state = ref.watch(appSettingsProvider);
  return state.settings;
}

/// Provider for checking if settings are loading
@riverpod
bool appSettingsLoading(Ref ref) {
  final state = ref.watch(appSettingsProvider);
  return state.isLoading;
}

/// Provider for settings error message
@riverpod
String? appSettingsError(Ref ref) {
  final state = ref.watch(appSettingsProvider);
  return state.error;
}

/// Provider for last updated timestamp
@riverpod
DateTime? appSettingsLastUpdated(Ref ref) {
  final state = ref.watch(appSettingsProvider);
  return state.lastUpdated;
}

/// Provider for theme mode from settings
@riverpod
String appThemeMode(Ref ref) {
  final settings = ref.watch(currentAppSettingsProvider);
  return settings.themeMode;
}

/// Provider for electrical effects enabled state
@riverpod
bool electricalEffectsEnabled(Ref ref) {
  final settings = ref.watch(currentAppSettingsProvider);
  return settings.electricalEffects;
}

/// Provider for location services enabled state
@riverpod
bool locationServicesEnabled(Ref ref) {
  final settings = ref.watch(currentAppSettingsProvider);
  return settings.locationServicesEnabled;
}
