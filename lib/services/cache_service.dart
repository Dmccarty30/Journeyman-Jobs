import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple cache service for offline data storage
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  Duration _defaultExpiration = const Duration(hours: 24);

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('Cache service initialized');
    } catch (e) {
      debugPrint('Failed to initialize cache service: $e');
    }
  }

  /// Store a string value with optional expiration
  Future<bool> setString(String key, String value, {Duration? expiration}) async {
    try {
      if (_prefs == null) return false;

      final expirationTime = expiration ?? _defaultExpiration;
      final expiryTimestamp = DateTime.now().add(expirationTime).millisecondsSinceEpoch;

      await _prefs!.setString('${key}_value', value);
      await _prefs!.setInt('${key}_expiry', expiryTimestamp);

      return true;
    } catch (e) {
      debugPrint('Failed to cache string for key $key: $e');
      return false;
    }
  }

  /// Get a cached string value
  String? getString(String key) {
    try {
      if (_prefs == null) return null;

      final expiryTimestamp = _prefs!.getInt('${key}_expiry') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // Check if cache has expired
      if (currentTime > expiryTimestamp) {
        remove(key);
        return null;
      }

      return _prefs!.getString('${key}_value');
    } catch (e) {
      debugPrint('Failed to get cached string for key $key: $e');
      return null;
    }
  }

  /// Store a JSON object with optional expiration
  Future<bool> setJson(String key, Map<String, dynamic> value, {Duration? expiration}) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString, expiration: expiration);
    } catch (e) {
      debugPrint('Failed to cache JSON for key $key: $e');
      return false;
    }
  }

  /// Get a cached JSON object
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to get cached JSON for key $key: $e');
      return null;
    }
  }

  /// Store a list with optional expiration
  Future<bool> setList(String key, List<String> value, {Duration? expiration}) async {
    try {
      return await setJson(key, {'items': value}, expiration: expiration);
    } catch (e) {
      debugPrint('Failed to cache list for key $key: $e');
      return false;
    }
  }

  /// Get a cached list
  List<String>? getList(String key) {
    try {
      final json = getJson(key);
      if (json == null || !json.containsKey('items')) return null;

      final items = json['items'] as List<dynamic>;
      return items.cast<String>();
    } catch (e) {
      debugPrint('Failed to get cached list for key $key: $e');
      return null;
    }
  }

  /// Remove a cached value
  Future<bool> remove(String key) async {
    try {
      if (_prefs == null) return false;

      await _prefs!.remove('${key}_value');
      await _prefs!.remove('${key}_expiry');

      return true;
    } catch (e) {
      debugPrint('Failed to remove cache for key $key: $e');
      return false;
    }
  }

  /// Clear all cached values
  Future<bool> clear() async {
    try {
      if (_prefs == null) return false;

      await _prefs!.clear();
      debugPrint('Cache cleared');
      return true;
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
      return false;
    }
  }

  /// Check if a key exists and is not expired
  bool containsKey(String key) {
    return getString(key) != null;
  }

  /// Get cache size estimate (in bytes)
  Future<int> getCacheSize() async {
    try {
      if (_prefs == null) return 0;

      int totalSize = 0;
      final keys = _prefs!.getKeys();

      for (final key in keys) {
        final value = _prefs!.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Failed to get cache size: $e');
      return 0;
    }
  }

  /// Clean up expired entries
  Future<int> cleanupExpired() async {
    try {
      if (_prefs == null) return 0;

      int cleanedCount = 0;
      final keys = _prefs!.getKeys();
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      for (final key in keys) {
        if (key.endsWith('_expiry')) {
          final expiryTimestamp = _prefs!.getInt(key) ?? 0;
          if (currentTime > expiryTimestamp) {
            final baseKey = key.replaceAll('_expiry', '');
            await remove(baseKey);
            cleanedCount++;
          }
        }
      }

      debugPrint('Cleaned up $cleanedCount expired cache entries');
      return cleanedCount;
    } catch (e) {
      debugPrint('Failed to cleanup expired cache: $e');
      return 0;
    }
  }

  /// Cache a file locally
  Future<String?> cacheFile(String url, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.replaceAll(RegExp(r'[^\w\-_.]'), '_');
      final file = File('${directory.path}/cache/$fileName');

      // Create cache directory if it doesn't exist
      await file.parent.create(recursive: true);

      await file.writeAsString(content);
      debugPrint('Cached file: ${file.path}');

      return file.path;
    } catch (e) {
      debugPrint('Failed to cache file for url $url: $e');
      return null;
    }
  }

  /// Get a cached file
  Future<String?> getCachedFile(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.replaceAll(RegExp(r'[^\w\-_.]'), '_');
      final file = File('${directory.path}/cache/$fileName');

      if (await file.exists()) {
        return await file.readAsString();
      }

      return null;
    } catch (e) {
      debugPrint('Failed to get cached file for url $url: $e');
      return null;
    }
  }

  /// Set default expiration time for cached items
  void setDefaultExpiration(Duration duration) {
    _defaultExpiration = duration;
  }

  /// Get all cache keys
  Future<Set<String>> getAllKeys() async {
    try {
      if (_prefs == null) return <String>{};

      final keys = _prefs!.getKeys();
      final valueKeys = keys.where((key) => key.endsWith('_value')).map((key) => key.replaceAll('_value', ''));

      return valueKeys.toSet();
    } catch (e) {
      debugPrint('Failed to get all cache keys: $e');
      return <String>{};
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final keys = await getAllKeys();
      final size = await getCacheSize();

      return {
        'totalEntries': keys.length,
        'estimatedSizeBytes': size,
        'defaultExpirationHours': _defaultExpiration.inHours,
        'lastCleanup': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Failed to get cache statistics: $e');
      return {};
    }
  }
}