import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/riverpod/app_settings_riverpod_provider.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../design_system/components/reusable_components.dart';

/// Helper extension for integrating app settings with UI widgets
///
/// Provides convenience methods for saving settings with proper error handling,
/// loading indicators, and user feedback.
extension AppSettingsIntegration on WidgetRef {
  /// Get current authenticated user ID
  String get currentUserId {
    final user = read(currentUserProvider);
    return user?.uid ?? '';
  }

  /// Update a setting with error handling and feedback
  ///
  /// Shows success or error snackbar based on save result.
  /// Returns true if save succeeded, false otherwise.
  Future<bool> updateSettingWithFeedback(
    BuildContext context,
    Future<void> Function() updateFn,
    String successMessage,
  ) async {
    if (currentUserId.isEmpty) {
      if (context.mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Please sign in to save settings',
        );
      }
      return false;
    }

    try {
      await updateFn();

      if (context.mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: successMessage,
        );
      }

      return true;
    } catch (e) {

      if (context.mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Failed to save setting. Please try again.',
        );
      }

      return false;
    }
  }

  /// Update theme mode setting
  Future<void> updateThemeModeSetting(String themeMode) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateThemeMode(currentUserId, themeMode);
    }
  }

  /// Update high contrast mode
  Future<void> updateHighContrastModeSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateHighContrastMode(currentUserId, enabled);
    }
  }

  /// Update electrical effects
  Future<void> updateElectricalEffectsSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateElectricalEffects(currentUserId, enabled);
    }
  }

  /// Update font size
  Future<void> updateFontSizeSetting(String fontSize) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateFontSize(currentUserId, fontSize);
    }
  }

  /// Update search radius
  Future<void> updateSearchRadiusSetting(double radius) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateSearchRadius(currentUserId, radius);
    }
  }

  /// Update distance units
  Future<void> updateDistanceUnitsSetting(String units) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateDistanceUnits(currentUserId, units);
    }
  }

  /// Update auto-apply setting
  Future<void> updateAutoApplySetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateAutoApply(currentUserId, enabled);
    }
  }

  /// Update minimum hourly rate
  Future<void> updateMinimumHourlyRateSetting(double rate) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateMinimumHourlyRate(currentUserId, rate);
    }
  }

  /// Update offline mode
  Future<void> updateOfflineModeSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateOfflineMode(currentUserId, enabled);
    }
  }

  /// Update auto-download setting
  Future<void> updateAutoDownloadSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateAutoDownload(currentUserId, enabled);
    }
  }

  /// Update Wi-Fi only downloads
  Future<void> updateWifiOnlyDownloadsSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateWifiOnlyDownloads(currentUserId, enabled);
    }
  }

  /// Update profile visibility
  Future<void> updateProfileVisibilitySetting(String visibility) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateProfileVisibility(currentUserId, visibility);
    }
  }

  /// Update location services
  Future<void> updateLocationServicesSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateLocationServices(currentUserId, enabled);
    }
  }

  /// Update biometric login
  Future<void> updateBiometricLoginSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateBiometricLogin(currentUserId, enabled);
    }
  }

  /// Update two-factor authentication
  Future<void> updateTwoFactorSetting(bool enabled) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateTwoFactor(currentUserId, enabled);
    }
  }

  /// Update language preference
  Future<void> updateLanguageSetting(String language) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateLanguage(currentUserId, language);
    }
  }

  /// Update date format
  Future<void> updateDateFormatSetting(String dateFormat) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateDateFormat(currentUserId, dateFormat);
    }
  }

  /// Update time format
  Future<void> updateTimeFormatSetting(String timeFormat) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateTimeFormat(currentUserId, timeFormat);
    }
  }

  /// Update storm alert radius
  Future<void> updateStormAlertRadiusSetting(double radius) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateStormAlertRadius(currentUserId, radius);
    }
  }

  /// Update storm rate multiplier
  Future<void> updateStormRateMultiplierSetting(double multiplier) async {
    if (currentUserId.isNotEmpty) {
      await read(appSettingsProvider.notifier).updateStormRateMultiplier(currentUserId, multiplier);
    }
  }
}
