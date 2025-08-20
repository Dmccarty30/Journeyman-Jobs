import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/educational_content.dart';
import '../models/transformer_models_export.dart';
import '../services/structured_logger.dart';

/// Offline content caching system for transformer trainer
class OfflineContentCache {
  static const String _keyPrefix = 'transformer_trainer_cache_';
  static const String _versionKey = '${_keyPrefix}version';
  static const String _timestampKey = '${_keyPrefix}timestamp';
  static const String _contentKey = '${_keyPrefix}content_';
  static const String _diagramKey = '${_keyPrefix}diagram_';
  static const String _stepKey = '${_keyPrefix}step_';
  
  static const int _cacheVersion = 1;
  static const Duration _cacheExpiration = Duration(days: 7);
  
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  
  /// Initialize the cache system
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      
      // Check if cache needs to be cleared due to version changes
      await _checkCacheVersion();
      
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to initialize: $e');
      }
    }
  }
  
  /// Cache educational content for a specific bank type
  static Future<bool> cacheEducationalContent(
    TransformerBankType bankType,
    List<TrainingStep> steps,
  ) async {
    await _ensureInitialized();
    
    try {
      final String key = '$_contentKey${bankType.name}';
      final Map<String, Object> data = <String, Object>{
        'bankType': bankType.name,
        'steps': steps.map((TrainingStep step) => step.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final String jsonString = jsonEncode(data);
      await _prefs?.setString(key, jsonString);
      
      // Update global timestamp
      await _updateTimestamp();
      
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Cached content for ${bankType.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to cache content: $e');
      }
      return false;
    }
  }
  
  /// Retrieve cached educational content
  static Future<List<TrainingStep>?> getCachedEducationalContent(
    TransformerBankType bankType,
  ) async {
    await _ensureInitialized();
    
    try {
      final String key = '$_contentKey${bankType.name}';
      final String? jsonString = _prefs?.getString(key);
      
      if (jsonString == null) {
        return null;
      }
      
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
      
      // Check if content has expired
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await _removeCachedContent(key);
        return null;
      }
      
      final List stepsList = data['steps'] as List<dynamic>;
      final List<TrainingStep> steps = stepsList
          .map((stepJson) => TrainingStep.fromJson(stepJson as Map<String, dynamic>))
          .toList();
      
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Retrieved cached content for ${bankType.name}');
      }
      
      return steps;
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to retrieve cached content: $e');
      }
      return null;
    }
  }
  
  /// Cache diagram configuration data
  static Future<bool> cacheDiagramConfiguration(
    TransformerBankType bankType,
    List<ConnectionPoint> connectionPoints,
    List<WireConnection> requiredConnections,
  ) async {
    await _ensureInitialized();
    
    try {
      final String key = '$_diagramKey${bankType.name}';
      final Map<String, Object> data = <String, Object>{
        'bankType': bankType.name,
        'connectionPoints': connectionPoints.map((ConnectionPoint point) => point.toJson()).toList(),
        'requiredConnections': requiredConnections.map((WireConnection conn) => conn.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final String jsonString = jsonEncode(data);
      await _prefs?.setString(key, jsonString);
      
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Cached diagram for ${bankType.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to cache diagram: $e');
      }
      return false;
    }
  }
  
  /// Retrieve cached diagram configuration
  static Future<DiagramConfiguration?> getCachedDiagramConfiguration(
    TransformerBankType bankType,
  ) async {
    await _ensureInitialized();
    
    try {
      final String key = '$_diagramKey${bankType.name}';
      final String? jsonString = _prefs?.getString(key);
      
      if (jsonString == null) {
        return null;
      }
      
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
      
      // Check if content has expired
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await _removeCachedContent(key);
        return null;
      }
      
      final List connectionPointsList = data['connectionPoints'] as List<dynamic>;
      final List<ConnectionPoint> connectionPoints = connectionPointsList
          .map((pointJson) => ConnectionPoint.fromJson(pointJson as Map<String, dynamic>))
          .toList();
      
      final List requiredConnectionsList = data['requiredConnections'] as List<dynamic>;
      final List<WireConnection> requiredConnections = requiredConnectionsList
          .map((connJson) => WireConnection.fromJson(connJson as Map<String, dynamic>))
          .toList();
      
      return DiagramConfiguration(
        bankType: bankType,
        connectionPoints: connectionPoints,
        requiredConnections: requiredConnections,
      );
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to retrieve cached diagram: $e');
      }
      return null;
    }
  }
  
  /// Cache user progress for a specific bank type
  static Future<bool> cacheUserProgress(
    TransformerBankType bankType,
    TrainingState trainingState,
  ) async {
    await _ensureInitialized();
    
    try {
      final String key = '$_stepKey${bankType.name}';
      final Map<String, Object> data = <String, Object>{
        'bankType': bankType.name,
        'trainingState': trainingState.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final String jsonString = jsonEncode(data);
      await _prefs?.setString(key, jsonString);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to cache progress: $e');
      }
      return false;
    }
  }
  
  /// Retrieve cached user progress
  static Future<TrainingState?> getCachedUserProgress(
    TransformerBankType bankType,
  ) async {
    await _ensureInitialized();
    
    try {
      final String key = '$_stepKey${bankType.name}';
      final String? jsonString = _prefs?.getString(key);
      
      if (jsonString == null) {
        return null;
      }
      
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
      final Map<String, dynamic> trainingStateJson = data['trainingState'] as Map<String, dynamic>;
      
      return TrainingState.fromJson(trainingStateJson);
    } catch (e) {
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Failed to retrieve cached progress: $e');
      }
      return null;
    }
  }
  
  /// Preload all educational content for offline use
  static Future<bool> preloadAllContent() async {
    await _ensureInitialized();
    
    bool allSuccessful = true;
    
    for (final TransformerBankType bankType in TransformerBankType.values) {
      try {
        // Get content from educational content provider
        final List<TrainingStep> steps = EducationalContent.getTrainingSteps(bankType);
        final bool success = await cacheEducationalContent(bankType, steps);
        
        if (!success) {
          allSuccessful = false;
        }
        
        // Small delay to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        if (kDebugMode) {
          StructuredLogger.debug('OfflineContentCache: Failed to preload content for ${bankType.name}: $e');
        }
        allSuccessful = false;
      }
    }
    
    if (kDebugMode) {
      StructuredLogger.debug('OfflineContentCache: Preload ${allSuccessful ? 'completed' : 'completed with errors'}');
    }
    
    return allSuccessful;
  }
  
  /// Clear all cached content
  static Future<void> clearCache() async {
    await _ensureInitialized();
    
    final Iterable<String> keys = _prefs?.getKeys().where((String key) => key.startsWith(_keyPrefix)) ?? <String>[];
    
    for (final String key in keys) {
      await _prefs?.remove(key);
    }
    
    if (kDebugMode) {
      StructuredLogger.debug('OfflineContentCache: Cache cleared');
    }
  }
  
  /// Get cache statistics
  static Future<CacheStatistics> getCacheStatistics() async {
    await _ensureInitialized();
    
    final Iterable<String> keys = _prefs?.getKeys().where((String key) => key.startsWith(_keyPrefix)) ?? <String>[];
    
    int totalItems = 0;
    int totalSize = 0;
    DateTime? oldestTimestamp;
    DateTime? newestTimestamp;
    
    for (final String key in keys) {
      if (key == _versionKey || key == _timestampKey) continue;
      
      final String? value = _prefs?.getString(key);
      if (value != null) {
        totalItems++;
        totalSize += value.length;
        
        try {
          final Map<String, dynamic> data = jsonDecode(value) as Map<String, dynamic>;
          final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
          
          if (oldestTimestamp == null || timestamp.isBefore(oldestTimestamp)) {
            oldestTimestamp = timestamp;
          }
          
          if (newestTimestamp == null || timestamp.isAfter(newestTimestamp)) {
            newestTimestamp = timestamp;
          }
        } catch (e) {
          // Ignore parsing errors
        }
      }
    }
    
    return CacheStatistics(
      totalItems: totalItems,
      totalSizeBytes: totalSize,
      oldestItem: oldestTimestamp,
      newestItem: newestTimestamp,
    );
  }
  
  /// Check if content is available offline
  static Future<bool> isContentAvailableOffline(TransformerBankType bankType) async {
    final List<TrainingStep>? educationalContent = await getCachedEducationalContent(bankType);
    final DiagramConfiguration? diagramConfig = await getCachedDiagramConfiguration(bankType);
    
    return educationalContent != null && diagramConfig != null;
  }
  
  // Private helper methods
  
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
  
  static Future<void> _checkCacheVersion() async {
    final int cachedVersion = _prefs?.getInt(_versionKey) ?? 0;
    
    if (cachedVersion < _cacheVersion) {
      await clearCache();
      await _prefs?.setInt(_versionKey, _cacheVersion);
      
      if (kDebugMode) {
        StructuredLogger.debug('OfflineContentCache: Cache cleared due to version upgrade');
      }
    }
  }
  
  static Future<void> _updateTimestamp() async {
    await _prefs?.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<void> _removeCachedContent(String key) async {
    await _prefs?.remove(key);
  }
}

/// Cache statistics data class
class CacheStatistics {
  
  const CacheStatistics({
    required this.totalItems,
    required this.totalSizeBytes,
    this.oldestItem,
    this.newestItem,
  });
  final int totalItems;
  final int totalSizeBytes;
  final DateTime? oldestItem;
  final DateTime? newestItem;
  
  /// Get human-readable size
  String get readableSize {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Diagram configuration data class
class DiagramConfiguration {
  
  const DiagramConfiguration({
    required this.bankType,
    required this.connectionPoints,
    required this.requiredConnections,
  });
  final TransformerBankType bankType;
  final List<ConnectionPoint> connectionPoints;
  final List<WireConnection> requiredConnections;
}
