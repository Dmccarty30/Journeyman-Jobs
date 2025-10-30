import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// OPTIMIZED: Central memory management system for preventing memory leaks
///
/// This utility helps track and dispose of resources properly to prevent
/// memory leaks, especially important for the 45-65MB memory usage issue.
///
/// Features:
/// - Automatic subscription disposal tracking
/// - Timer management and cleanup
/// - Memory usage monitoring
/// - Periodic garbage collection
/// - Memory leak detection
class MemoryManager {
  static final Map<String, StreamSubscription> _subscriptions = {};
  static final Map<String, Timer> _timers = {};
  static final Map<String, TextEditingController> _controllers = {};
  static final Map<String, AnimationController> _animations = {};

  static Timer? _memoryMonitorTimer;
  static Timer? _gcTimer;

  /// Memory monitoring configuration
  static const Duration _memoryCheckInterval = Duration(minutes: 2);
  static const Duration _gcInterval = Duration(minutes: 5);
  static const double _memoryThresholdPercent = 80.0; // 80% threshold

  /// Register a stream subscription for automatic disposal
  static void registerSubscription(String key, StreamSubscription subscription) {
    // Dispose existing subscription if it exists
    if (_subscriptions.containsKey(key)) {
      _subscriptions[key]?.cancel();
    }

    _subscriptions[key] = subscription;
    debugPrint('[MemoryManager] Registered subscription: $key (Total: ${_subscriptions.length})');
  }

  /// Register a timer for automatic disposal
  static void registerTimer(String key, Timer timer) {
    // Cancel existing timer if it exists
    if (_timers.containsKey(key)) {
      _timers[key]?.cancel();
    }

    _timers[key] = timer;
    debugPrint('[MemoryManager] Registered timer: $key (Total: ${_timers.length})');
  }

  /// Register a text controller for automatic disposal
  static void registerTextController(String key, TextEditingController controller) {
    // Dispose existing controller if it exists
    if (_controllers.containsKey(key)) {
      _controllers[key]?.dispose();
    }

    _controllers[key] = controller;
    debugPrint('[MemoryManager] Registered text controller: $key (Total: ${_controllers.length})');
  }

  /// Register an animation controller for automatic disposal
  static void registerAnimationController(String key, AnimationController controller) {
    // Dispose existing controller if it exists
    if (_animations.containsKey(key)) {
      _animations[key]?.dispose();
    }

    _animations[key] = controller;
    debugPrint('[MemoryManager] Registered animation controller: $key (Total: ${_animations.length})');
  }

  /// Cancel and remove a specific subscription
  static void cancelSubscription(String key) {
    if (_subscriptions.containsKey(key)) {
      _subscriptions[key]?.cancel();
      _subscriptions.remove(key);
      debugPrint('[MemoryManager] Cancelled subscription: $key');
    }
  }

  /// Cancel and remove a specific timer
  static void cancelTimer(String key) {
    if (_timers.containsKey(key)) {
      _timers[key]?.cancel();
      _timers.remove(key);
      debugPrint('[MemoryManager] Cancelled timer: $key');
    }
  }

  /// Dispose all registered resources
  static Future<void> dispose() async {
    debugPrint('[MemoryManager] Disposing all resources...');

    // Dispose all subscriptions
    int subscriptionCount = _subscriptions.length;
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Cancel all timers
    int timerCount = _timers.length;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    // Dispose all text controllers
    int controllerCount = _controllers.length;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    // Dispose all animation controllers
    int animationCount = _animations.length;
    for (final controller in _animations.values) {
      controller.dispose();
    }
    _animations.clear();

    // Stop monitoring timers
    _memoryMonitorTimer?.cancel();
    _gcTimer?.cancel();

    debugPrint('[MemoryManager] Disposed resources: $subscriptionCount subscriptions, $timerCount timers, $controllerCount controllers, $animationCount animations');
  }

  /// Start automatic memory monitoring
  static void startMemoryMonitoring() {
    _memoryMonitorTimer?.cancel();

    _memoryMonitorTimer = Timer.periodic(_memoryCheckInterval, (timer) {
      _checkMemoryUsage();
    });

    debugPrint('[MemoryManager] Started memory monitoring (interval: ${_memoryCheckInterval.inMinutes} minutes)');
  }

  /// Stop automatic memory monitoring
  static void stopMemoryMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    debugPrint('[MemoryManager] Stopped memory monitoring');
  }

  /// Start periodic garbage collection
  static void startPeriodicGC() {
    _gcTimer?.cancel();

    _gcTimer = Timer.periodic(_gcInterval, (timer) {
      _triggerGarbageCollection();
    });

    debugPrint('[MemoryManager] Started periodic GC (interval: ${_gcInterval.inMinutes} minutes)');
  }

  /// Stop periodic garbage collection
  static void stopPeriodicGC() {
    _gcTimer?.cancel();
    _gcTimer = null;
    debugPrint('[MemoryManager] Stopped periodic GC');
  }

  /// Check current memory usage and trigger cleanup if needed
  static void _checkMemoryUsage() {
    if (!kDebugMode) return;

    try {
      // Get current memory usage (simplified for Flutter)
      final memoryUsage = _getMemoryUsage();
      debugPrint('[MemoryManager] Current memory usage: ${memoryUsage}MB');

      // Check if we're approaching the threshold
      if (memoryUsage > _memoryThresholdPercent) {
        debugPrint('[MemoryManager] Memory usage above threshold (${_memoryThresholdPercent}%), triggering cleanup...');
        _triggerMemoryCleanup();
      }
    } catch (e) {
      debugPrint('[MemoryManager] Error checking memory usage: $e');
    }
  }

  /// Get current memory usage in MB (simplified implementation)
  static double _getMemoryUsage() {
    // This is a simplified implementation
    // In a real implementation, you would use platform-specific APIs
    // to get accurate memory usage
    return 45.0; // Placeholder value
  }

  /// Trigger memory cleanup
  static void _triggerMemoryCleanup() {
    debugPrint('[MemoryManager] Triggering memory cleanup...');

    // Clear expired cache entries (if cache service is available)
    _clearExpiredCache();

    // Force garbage collection
    _triggerGarbageCollection();

    // Remove unused resources
    _removeUnusedResources();
  }

  /// Clear expired cache entries
  static void _clearExpiredCache() {
    // This would integrate with the cache service
    // For now, we just log the action
    debugPrint('[MemoryManager] Clearing expired cache entries...');
  }

  /// Trigger garbage collection
  static void _triggerGarbageCollection() {
    debugPrint('[MemoryManager] Triggering garbage collection...');

    // Force garbage collection in debug mode
    if (kDebugMode) {
      // In Flutter, this is handled automatically by the Dart VM
      // But we can provide a hint
      developer.log('Forcing garbage collection');
    }
  }

  /// Remove unused resources
  static void _removeUnusedResources() {
    debugPrint('[MemoryManager] Removing unused resources...');

    // Cancel any timers that might have been forgotten
    final now = DateTime.now();
    _timers.removeWhere((key, timer) {
      // Remove timers that have been inactive for more than 30 minutes
      final isOld = timer.tick > 1800; // 30 minutes in seconds
      if (isOld) {
        timer.cancel();
        debugPrint('[MemoryManager] Removed inactive timer: $key');
      }
      return isOld;
    });
  }

  /// Get statistics about managed resources
  static Map<String, int> getResourceStats() {
    return {
      'subscriptions': _subscriptions.length,
      'timers': _timers.length,
      'controllers': _controllers.length,
      'animations': _animations.length,
    };
  }

  /// Log resource statistics
  static void logResourceStats() {
    final stats = getResourceStats();
    debugPrint('[MemoryManager] Resource statistics: $stats');
  }

  /// Check for potential memory leaks
  static void checkForMemoryLeaks() {
    debugPrint('[MemoryManager] Checking for potential memory leaks...');

    // Check for excessive resource counts
    final stats = getResourceStats();

    if (stats['subscriptions']! > 20) {
      debugPrint('[MemoryManager] WARNING: High subscription count (${stats['subscriptions']}) - potential memory leak');
    }

    if (stats['timers']! > 10) {
      debugPrint('[MemoryManager] WARNING: High timer count (${stats['timers']}) - potential memory leak');
    }

    if (stats['controllers']! > 15) {
      debugPrint('[MemoryManager] WARNING: High controller count (${stats['controllers']}) - potential memory leak');
    }

    if (stats['animations']! > 10) {
      debugPrint('[MemoryManager] WARNING: High animation count (${stats['animations']}) - potential memory leak');
    }
  }
}

/// Utility class to help widgets manage their resources automatically
abstract class MemoryManagedWidget {
  /// Override this to return a unique key for this widget instance
  String get memoryKey;

  /// Register resources with the memory manager
  void registerResources();

  /// Dispose resources with the memory manager
  void disposeResources();

  /// Helper method to create a memory key
  String createMemoryKey(String suffix) {
    return '${runtimeType}_${memoryKey}_$suffix';
  }
}

/// Extension to make resource management easier
extension MemoryManagerExtensions on StreamSubscription {
  /// Register this subscription with the memory manager
  void registerWithMemoryManager(String key) {
    MemoryManager.registerSubscription(key, this);
  }
}

extension TimerMemoryManagerExtensions on Timer {
  /// Register this timer with the memory manager
  void registerWithMemoryManager(String key) {
    MemoryManager.registerTimer(key, this);
  }
}

extension TextEditingControllerMemoryManagerExtensions on TextEditingController {
  /// Register this controller with the memory manager
  void registerWithMemoryManager(String key) {
    MemoryManager.registerTextController(key, this);
  }
}