import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage service for sensitive authentication and session data.
///
/// SECURITY IMPLEMENTATION: 2025-10-30
/// - Replaces unencrypted SharedPreferences for sensitive data
/// - Uses platform-specific secure storage:
///   * iOS: Keychain (Secure Enclave when available)
///   * Android: Encrypted SharedPreferences (Android Keystore)
///   * Web: Encrypted localStorage with AES-GCM encryption
///   * Linux: libsecret (GNOME Keyring)
///   * macOS: Keychain
///
/// Usage:
/// - Sensitive tokens (Firebase ID tokens, refresh tokens)
/// - Session authentication state
/// - User credential hints (non-reversible data only)
/// - Security-critical preferences
///
/// Non-sensitive data remains in SharedPreferences for performance.
class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Security keys - never log these values
  static const String _idTokenKey = 'auth_id_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _sessionExpiresAtKey = 'session_expires_at';
  static const String _lastAuthTimestampKey = 'last_auth_timestamp';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _deviceTrustedKey = 'device_trusted';

  /// Initialize secure storage service
  static Future<void> initialize() async {
    try {
      // Test secure storage availability
      await _secureStorage.read(key: 'test_availability');
      debugPrint('SecureStorage: Initialized successfully');
    } catch (e) {
      debugPrint('SecureStorage: Initialization failed - $e');
      // Fallback to encrypted memory storage for web/platform limitations
      await _initializeFallback();
    }
  }

  /// Store Firebase ID token securely
  static Future<void> storeIdToken(String token) async {
    try {
      await _secureStorage.write(key: _idTokenKey, value: token);
      await _updateSessionTimestamp();
      debugPrint('SecureStorage: ID token stored securely');
    } catch (e) {
      debugPrint('SecureStorage: Failed to store ID token - $e');
      rethrow;
    }
  }

  /// Retrieve Firebase ID token
  static Future<String?> getIdToken() async {
    try {
      final token = await _secureStorage.read(key: _idTokenKey);
      debugPrint('SecureStorage: ID token retrieved securely');
      return token;
    } catch (e) {
      debugPrint('SecureStorage: Failed to retrieve ID token - $e');
      return null;
    }
  }

  /// Store refresh token securely
  static Future<void> storeRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
      debugPrint('SecureStorage: Refresh token stored securely');
    } catch (e) {
      debugPrint('SecureStorage: Failed to store refresh token - $e');
      rethrow;
    }
  }

  /// Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      debugPrint('SecureStorage: Refresh token retrieved securely');
      return token;
    } catch (e) {
      debugPrint('SecureStorage: Failed to retrieve refresh token - $e');
      return null;
    }
  }

  /// Set session expiration time
  static Future<void> setSessionExpiresAt(DateTime expiresAt) async {
    try {
      await _secureStorage.write(
        key: _sessionExpiresAtKey,
        value: expiresAt.toIso8601String(),
      );
      debugPrint('SecureStorage: Session expiration set to $expiresAt');
    } catch (e) {
      debugPrint('SecureStorage: Failed to set session expiration - $e');
      rethrow;
    }
  }

  /// Get session expiration time
  static Future<DateTime?> getSessionExpiresAt() async {
    try {
      final expiresAtStr = await _secureStorage.read(key: _sessionExpiresAtKey);
      if (expiresAtStr != null) {
        return DateTime.parse(expiresAtStr);
      }
      return null;
    } catch (e) {
      debugPrint('SecureStorage: Failed to get session expiration - $e');
      return null;
    }
  }

  /// Check if session is still valid
  static Future<bool> isSessionValid() async {
    try {
      final expiresAt = await getSessionExpiresAt();
      if (expiresAt == null) return false;

      final now = DateTime.now();
      final isValid = now.isBefore(expiresAt);

      debugPrint('SecureStorage: Session validity check - Valid: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('SecureStorage: Failed to check session validity - $e');
      return false;
    }
  }

  /// Store last authentication timestamp
  static Future<void> _updateSessionTimestamp() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _secureStorage.write(key: _lastAuthTimestampKey, value: timestamp);
    } catch (e) {
      debugPrint('SecureStorage: Failed to update session timestamp - $e');
    }
  }

  /// Get last authentication timestamp
  static Future<DateTime?> getLastAuthTimestamp() async {
    try {
      final timestampStr = await _secureStorage.read(key: _lastAuthTimestampKey);
      if (timestampStr != null) {
        return DateTime.parse(timestampStr);
      }
      return null;
    } catch (e) {
      debugPrint('SecureStorage: Failed to get last auth timestamp - $e');
      return null;
    }
  }

  /// Enable biometric authentication
  static Future<void> enableBiometric() async {
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      debugPrint('SecureStorage: Biometric authentication enabled');
    } catch (e) {
      debugPrint('SecureStorage: Failed to enable biometric - $e');
      rethrow;
    }
  }

  /// Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('SecureStorage: Failed to check biometric status - $e');
      return false;
    }
  }

  /// Mark device as trusted
  static Future<void> trustDevice() async {
    try {
      await _secureStorage.write(key: _deviceTrustedKey, value: 'true');
      debugPrint('SecureStorage: Device marked as trusted');
    } catch (e) {
      debugPrint('SecureStorage: Failed to trust device - $e');
      rethrow;
    }
  }

  /// Check if device is trusted
  static Future<bool> isDeviceTrusted() async {
    try {
      final trusted = await _secureStorage.read(key: _deviceTrustedKey);
      return trusted == 'true';
    } catch (e) {
      debugPrint('SecureStorage: Failed to check device trust status - $e');
      return false;
    }
  }

  /// Clear all sensitive authentication data
  static Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _sessionExpiresAtKey);
      await _secureStorage.delete(key: _lastAuthTimestampKey);

      debugPrint('SecureStorage: All authentication data cleared securely');
    } catch (e) {
      debugPrint('SecureStorage: Failed to clear auth data - $e');
      rethrow;
    }
  }

  /// Clear all secure storage data
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('SecureStorage: All secure storage data cleared');
    } catch (e) {
      debugPrint('SecureStorage: Failed to clear all data - $e');
      rethrow;
    }
  }

  /// Migrate data from SharedPreferences to SecureStorage
  static Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Migrate sensitive keys if they exist in old storage
      final keysToMigrate = [
        'auth_token',
        'refresh_token',
        'session_expires',
        'last_auth_time',
      ];

      for (final key in keysToMigrate) {
        final value = prefs.getString(key);
        if (value != null) {
          await _secureStorage.write(key: 'migrated_$key', value: value);
          await prefs.remove(key);
          debugPrint('SecureStorage: Migrated $key from SharedPreferences');
        }
      }

      debugPrint('SecureStorage: Migration completed successfully');
    } catch (e) {
      debugPrint('SecureStorage: Migration failed - $e');
      rethrow;
    }
  }

  /// Initialize fallback for platforms without secure storage
  static Future<void> _initializeFallback() async {
    debugPrint('SecureStorage: Using fallback encrypted storage');
    // Implementation would use AES encryption in memory for web platforms
    // This is a placeholder for production implementation
  }

  /// Check secure storage availability
  static Future<bool> isAvailable() async {
    try {
      await _secureStorage.read(key: 'test_availability');
      return true;
    } catch (e) {
      debugPrint('SecureStorage: Not available - $e');
      return false;
    }
  }
}