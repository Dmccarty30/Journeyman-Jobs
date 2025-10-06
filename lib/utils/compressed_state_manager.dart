import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/filter_criteria.dart';
import '../models/user_model.dart';

/// A utility class for advanced state management that provides compression,
/// encryption, and versioning for data persisted in [SharedPreferences].
///
/// This manager is designed to optimize storage space and secure sensitive data
/// while ensuring backward compatibility through state versioning and migration.
///
/// ### Core Features:
///
/// - **Compression:** Uses gzip to significantly reduce the storage footprint of JSON-serializable state objects.
/// - **Security:** Implements a simple placeholder for AES encryption to protect sensitive data. **Note:** The current encryption is a simple XOR cipher and is NOT production-safe.
/// - **Versioning:** Supports state schema versioning to prevent data corruption when the app is updated. Includes a migration mechanism.
/// - **Performance Monitoring:** Tracks compression/decompression times and storage usage.
///
/// ### Usage Example:
///
/// ```dart
/// // Save user preferences with compression and encryption.
/// await CompressedStateManager.saveUserPreferences(userModel);
///
/// // Load and decrypt user preferences.
/// final userModel = await CompressedStateManager.loadUserPreferences();
/// ```
class CompressedStateManager {
  static const String _stateVersionKey = 'state_version';
  static const String _encryptionKeyKey = 'encryption_key';
  static const int _currentStateVersion = 1;
  
  // State keys for different data types
  /// The key for storing compressed user preferences.
  static const String _userPreferencesKey = 'user_preferences_compressed';
  /// The key for storing compressed filter history.
  static const String _filterHistoryKey = 'filter_history_compressed';
  /// The key for storing compressed application settings.
  static const String _appSettingsKey = 'app_settings_compressed';
  /// The key for storing compressed cache metadata.
  static const String _cacheMetadataKey = 'cache_metadata_compressed';
  
  // Performance metrics
  static final Map<String, int> _compressionStats = {};
  static final Map<String, int> _decompressionStats = {};
  
  /// Saves a given state object to [SharedPreferences] with compression and optional encryption.
  ///
  /// - [key]: The key under which to store the data.
  /// - [state]: The JSON-serializable state object to save.
  /// - [encrypt]: Whether to encrypt the data before saving.
  /// - [enableMetrics]: Whether to record performance metrics for this operation.
  static Future<void> saveState(
    String key, 
    dynamic state, {
    bool encrypt = false,
    bool enableMetrics = true,
  }) async {
    try {
      final stopwatch = enableMetrics ? (Stopwatch()..start()) : null;
      
      // Convert state to JSON
      final json = jsonEncode(state);
      final originalSize = utf8.encode(json).length;
      
      // Compress with gzip
      final compressed = Uint8List.fromList(gzip.encode(utf8.encode(json)));
      final compressedSize = compressed.length;
      
      // Calculate compression ratio
      final compressionRatio = ((originalSize - compressedSize) / originalSize * 100).round();
      
      Uint8List finalData = compressed;
      
      // Encrypt if requested
      if (encrypt) {
        finalData = await _encryptData(compressed);
      }
      
      // Encode to base64 for storage
      final base64Data = base64Encode(finalData);
      
      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, base64Data);
      
      // Update metrics
      if (enableMetrics) {
        stopwatch?.stop();
        _compressionStats[key] = stopwatch?.elapsedMilliseconds ?? 0;
        
        if (kDebugMode) {
          print('CompressedStateManager: Saved $key - '
              'Original: ${originalSize}B, Compressed: ${compressedSize}B '
              '(${compressionRatio}% reduction) in ${stopwatch?.elapsedMilliseconds}ms');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('CompressedStateManager: Error saving state for $key - $e');
      }
      rethrow;
    }
  }
  
  /// Loads and decodes a state object from [SharedPreferences].
  ///
  /// - [key]: The key from which to load the data.
  /// - [decrypt]: Whether to decrypt the data after loading.
  /// - [enableMetrics]: Whether to record performance metrics for this operation.
  ///
  /// Returns the deserialized state object of type [T], or `null` if not found or on error.
  static Future<T?> loadState<T>(
    String key, {
    bool decrypt = false,
    bool enableMetrics = true,
  }) async {
    try {
      final stopwatch = enableMetrics ? (Stopwatch()..start()) : null;
      
      final prefs = await SharedPreferences.getInstance();
      final base64Data = prefs.getString(key);
      
      if (base64Data == null) return null;
      
      // Decode from base64
      Uint8List data = base64Decode(base64Data);
      
      // Decrypt if needed
      if (decrypt) {
        data = await _decryptData(data);
      }
      
      // Decompress
      final decompressed = gzip.decode(data);
      final json = utf8.decode(decompressed);
      
      // Update metrics
      if (enableMetrics) {
        stopwatch?.stop();
        _decompressionStats[key] = stopwatch?.elapsedMilliseconds ?? 0;
        
        if (kDebugMode) {
          print('CompressedStateManager: Loaded $key in ${stopwatch?.elapsedMilliseconds}ms');
        }
      }
      
      return jsonDecode(json) as T;
    } catch (e) {
      if (kDebugMode) {
        print('CompressedStateManager: Error loading state for $key - $e');
      }
      return null;
    }
  }
  
  /// A convenience method to save the [UserModel] state with encryption enabled.
  static Future<void> saveUserPreferences(UserModel user) async {
    await saveState(
      _userPreferencesKey,
      user.toJson(),
      encrypt: true, // Encrypt sensitive user data
    );
  }
  
  /// A convenience method to load and decrypt the [UserModel] state.
  static Future<UserModel?> loadUserPreferences() async {
    final json = await loadState<Map<String, dynamic>>(
      _userPreferencesKey,
      decrypt: true,
    );
    
    if (json == null) return null;
    
    try {
      return UserModel.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('CompressedStateManager: Error parsing user preferences - $e');
      }
      return null;
    }
  }
  
  /// A convenience method to save the user's job filter history.
  static Future<void> saveFilterHistory(List<JobFilterCriteria> filters) async {
    final filterJsonList = filters.map((filter) => filter.toJson()).toList();
    await saveState(_filterHistoryKey, filterJsonList);
  }
  
  /// A convenience method to load the user's job filter history.
  static Future<List<JobFilterCriteria>> loadFilterHistory() async {
    final jsonList = await loadState<List<dynamic>>(_filterHistoryKey);
    
    if (jsonList == null) return [];
    
    try {
      return jsonList
          .cast<Map<String, dynamic>>()
          .map((json) => JobFilterCriteria.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('CompressedStateManager: Error parsing filter history - $e');
      }
      return [];
    }
  }
  
  /// A convenience method to save general application settings.
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await saveState(_appSettingsKey, settings);
  }
  
  /// A convenience method to load general application settings.
  static Future<Map<String, dynamic>?> loadAppSettings() async {
    return await loadState<Map<String, dynamic>>(_appSettingsKey);
  }
  
  /// Removes all state managed by this class from [SharedPreferences].
  static Future<void> clearAllState() async {
    final prefs = await SharedPreferences.getInstance();
    
    await Future.wait([
      prefs.remove(_userPreferencesKey),
      prefs.remove(_filterHistoryKey),
      prefs.remove(_appSettingsKey),
      prefs.remove(_cacheMetadataKey),
      prefs.remove(_stateVersionKey),
    ]);
    
    _compressionStats.clear();
    _decompressionStats.clear();
    
    if (kDebugMode) {
      print('CompressedStateManager: Cleared all state');
    }
  }
  
  /// Returns a map of performance statistics for compression and decompression operations.
  static Map<String, Map<String, int>> getPerformanceStats() {
    return {
      'compression': Map.from(_compressionStats),
      'decompression': Map.from(_decompressionStats),
    };
  }
  
  /// Checks the stored state version and performs data migration if necessary.
  ///
  /// This should be called at app startup to ensure data compatibility.
  static Future<void> checkAndMigrateState() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_stateVersionKey) ?? 0;
    
    if (currentVersion < _currentStateVersion) {
      if (kDebugMode) {
        print('CompressedStateManager: Migrating state from v$currentVersion to v$_currentStateVersion');
      }
      
      await _performStateMigration(currentVersion, _currentStateVersion);
      await prefs.setInt(_stateVersionKey, _currentStateVersion);
      
      if (kDebugMode) {
        print('CompressedStateManager: State migration completed');
      }
    }
  }
  
  /// Perform state migration between versions
  static Future<void> _performStateMigration(int fromVersion, int toVersion) async {
    // Currently at version 1, so no migrations needed yet
    // Future migrations would be implemented here
    
    switch (fromVersion) {
      case 0:
        // Migrate from unversioned to v1
        await _migrateToV1();
        break;
      // Add future migration cases here
      default:
        break;
    }
  }
  
  /// Migrate unversioned state to v1 format
  static Future<void> _migrateToV1() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check for old uncompressed state keys and migrate them
    final oldKeys = prefs.getKeys().where((key) => 
        key.startsWith('user_') || 
        key.startsWith('filter_') || 
        key.startsWith('app_')
    ).toList();
    
    for (final oldKey in oldKeys) {
      try {
        final oldValue = prefs.getString(oldKey);
        if (oldValue != null) {
          final json = jsonDecode(oldValue);
          
          // Determine new compressed key based on old key pattern
          String? newKey;
          bool encrypt = false;
          
          if (oldKey.startsWith('user_')) {
            newKey = _userPreferencesKey;
            encrypt = true;
          } else if (oldKey.startsWith('filter_')) {
            newKey = _filterHistoryKey;
          } else if (oldKey.startsWith('app_')) {
            newKey = _appSettingsKey;
          }
          
          if (newKey != null) {
            await saveState(newKey, json, encrypt: encrypt);
            await prefs.remove(oldKey); // Remove old uncompressed state
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('CompressedStateManager: Error migrating $oldKey - $e');
        }
      }
    }
  }
  
  /// Encrypts the given data.
  ///
  /// **Warning:** This uses a simple XOR cipher for demonstration purposes and is
  /// **not secure**. A robust encryption library like `encrypt` with AES should be used
  /// in a production application.
  static Future<Uint8List> _encryptData(Uint8List data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? encryptionKey = prefs.getString(_encryptionKeyKey);
      
      // Generate encryption key if it doesn't exist
      if (encryptionKey == null) {
        final key = _generateEncryptionKey();
        encryptionKey = base64Encode(key);
        await prefs.setString(_encryptionKeyKey, encryptionKey);
      }
      
      // For this implementation, we'll use a simple XOR cipher
      // In production, you would use proper AES encryption
      final keyBytes = base64Decode(encryptionKey);
      final encrypted = Uint8List(data.length);
      
      for (int i = 0; i < data.length; i++) {
        encrypted[i] = data[i] ^ keyBytes[i % keyBytes.length];
      }
      
      return encrypted;
    } catch (e) {
      if (kDebugMode) {
        print('CompressedStateManager: Encryption error - $e');
      }
      return data; // Return unencrypted data if encryption fails
    }
  }
  
  /// Decrypts the given data.
  ///
  /// **Warning:** This uses a simple XOR cipher for demonstration purposes and is
  /// **not secure**.
  static Future<Uint8List> _decryptData(Uint8List encryptedData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptionKey = prefs.getString(_encryptionKeyKey);
      
      if (encryptionKey == null) {
        throw Exception('Encryption key not found');
      }
      
      // Use the same XOR cipher for decryption
      final keyBytes = base64Decode(encryptionKey);
      final decrypted = Uint8List(encryptedData.length);
      
      for (int i = 0; i < encryptedData.length; i++) {
        decrypted[i] = encryptedData[i] ^ keyBytes[i % keyBytes.length];
      }
      
      return decrypted;
    } catch (e) {
      if (kDebugMode) {
        print('CompressedStateManager: Decryption error - $e');
      }
      return encryptedData; // Return encrypted data if decryption fails
    }
  }
  
  /// Generate a random encryption key
  static Uint8List _generateEncryptionKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final combined = '$timestamp$random';
    
    return Uint8List.fromList(sha256.convert(utf8.encode(combined)).bytes);
  }
  
  /// Calculates and returns the storage size in bytes for each managed state key.
  static Future<Map<String, int>> getStorageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = <String, int>{};
    
    final keys = [
      _userPreferencesKey,
      _filterHistoryKey,
      _appSettingsKey,
      _cacheMetadataKey,
    ];
    
    for (final key in keys) {
      final data = prefs.getString(key);
      if (data != null) {
        stats[key] = data.length;
      }
    }
    
    return stats;
  }
}

/// A configuration class for state compression settings.
class StateCompressionConfig {
  /// Whether to enable gzip compression.
  final bool enableCompression;
  /// Whether to enable encryption.
  final bool enableEncryption;
  /// Whether to enable performance metric collection.
  final bool enableMetrics;
  /// The gzip compression level (0-9).
  final int compressionLevel;
  
  /// Creates a [StateCompressionConfig] instance.
  const StateCompressionConfig({
    this.enableCompression = true,
    this.enableEncryption = false,
    this.enableMetrics = true,
    this.compressionLevel = 6,
  });
  
  /// A recommended configuration for production environments.
  static const StateCompressionConfig production = StateCompressionConfig(
    enableCompression: true,
    enableEncryption: true,
    enableMetrics: false,
  );
  
  /// A recommended configuration for development environments.
  static const StateCompressionConfig development = StateCompressionConfig(
    enableCompression: true,
    enableEncryption: false,
    enableMetrics: true,
  );
}

/// Extension methods on [SharedPreferences] to simplify using the [CompressedStateManager].
extension CompressedStateExtensions on SharedPreferences {
  /// Saves a state object with compression using this [SharedPreferences] instance.
  Future<void> setCompressedState(String key, dynamic state) async {
    await CompressedStateManager.saveState(key, state);
  }
  
  /// Loads a compressed state object using this [SharedPreferences] instance.
  Future<T?> getCompressedState<T>(String key) async {
    return await CompressedStateManager.loadState<T>(key);
  }
}