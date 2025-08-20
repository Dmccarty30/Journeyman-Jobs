import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../painters/base_transformer_painter.dart';
import '../services/structured_logger.dart';

/// Mobile performance optimization manager for transformer trainer
class MobilePerformanceManager {
  static const Duration _cacheCleanupInterval = Duration(minutes: 5);
  
  static Timer? _cleanupTimer;
  static int _connectionCount = 0;
  static bool _isLowMemory = false;
  
  /// Initialize performance monitoring
  static void initialize() {
    // Start periodic cache cleanup
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cacheCleanupInterval, (_) {
      _performCacheCleanup();
    });
    
    // Monitor memory warnings on supported platforms
    if (!kIsWeb) {
      _startMemoryMonitoring();
    }
  }
  
  /// Cleanup resources when disposing
  static void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _performCacheCleanup();
  }
  
  /// Check if device is considered low-performance
  static bool get isLowPerformanceDevice {
    // Simple heuristic based on device pixel ratio and memory warnings
    return _isLowMemory || (kDebugMode && false); // Can be enabled for testing
  }
  
  /// Get recommended connection limit based on device performance
  static int get maxRecommendedConnections => isLowPerformanceDevice ? 25 : 50;
  
  /// Notify manager of new connection creation
  static void onConnectionAdded() {
    _connectionCount++;
    
    // Trigger cleanup if approaching limits
    if (_connectionCount > maxRecommendedConnections) {
      _performCacheCleanup();
      _connectionCount = maxRecommendedConnections ~/ 2; // Reset counter
    }
  }
  
  /// Notify manager of connection removal
  static void onConnectionRemoved() {
    _connectionCount = (_connectionCount - 1).clamp(0, double.infinity).toInt();
  }
  
  /// Clear all connections
  static void onConnectionsCleared() {
    _connectionCount = 0;
    _performCacheCleanup();
  }
  
  /// Force cleanup of caches
  static void _performCacheCleanup() {
    // Clear painter caches
    BaseTransformerPainter.clearCache();
    
    // Force garbage collection hint on supported platforms
    if (!kIsWeb && kDebugMode) {
      StructuredLogger.debug('MobilePerformanceManager: Cache cleanup performed');
    }
  }
  
  /// Start monitoring memory warnings (iOS/Android specific)
  static void _startMemoryMonitoring() {
    // On real implementation, this would listen to platform-specific memory warnings
    // For now, we'll simulate with a simple heuristic
    Timer.periodic(const Duration(seconds: 30), (_) {
      _checkMemoryPressure();
    });
  }
  
  /// Check for memory pressure indicators
  static void _checkMemoryPressure() {
    // Simple heuristic - in real implementation this would check actual memory usage
    final bool highConnectionCount = _connectionCount > maxRecommendedConnections * 0.8;
    
    if (highConnectionCount && !_isLowMemory) {
      _isLowMemory = true;
      _performCacheCleanup();
      
      if (kDebugMode) {
        StructuredLogger.debug('MobilePerformanceManager: Low memory mode activated');
      }
    } else if (!highConnectionCount && _isLowMemory) {
      _isLowMemory = false;
      
      if (kDebugMode) {
        StructuredLogger.debug('MobilePerformanceManager: Low memory mode deactivated');
      }
    }
  }
  
  /// Get performance optimization settings
  static PerformanceSettings getOptimizedSettings() => PerformanceSettings(
      enableBackgroundCaching: !isLowPerformanceDevice,
      maxAnimationFrameRate: isLowPerformanceDevice ? 30 : 60,
      reducedAnimations: isLowPerformanceDevice,
      batchUpdates: true,
      enableHapticFeedback: !isLowPerformanceDevice,
    );
}

/// Performance settings configuration
class PerformanceSettings {
  
  const PerformanceSettings({
    required this.enableBackgroundCaching,
    required this.maxAnimationFrameRate,
    required this.reducedAnimations,
    required this.batchUpdates,
    required this.enableHapticFeedback,
  });
  final bool enableBackgroundCaching;
  final int maxAnimationFrameRate;
  final bool reducedAnimations;
  final bool batchUpdates;
  final bool enableHapticFeedback;
}

/// Extension for responsive device detection
extension DeviceDetection on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 768;
  bool get isTablet => MediaQuery.of(this).size.width >= 768 && MediaQuery.of(this).size.width < 1024;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;
  
  /// Get appropriate touch target size for current device
  double get recommendedTouchTargetSize {
    if (isMobile) return 44; // iOS/Android guidelines
    if (isTablet) return 48; // Larger tablets
    return 40; // Desktop/web
  }
  
  /// Get connection point visual size
  double get connectionPointSize {
    if (isMobile) return 32;
    if (isTablet) return 36;
    return 28;
  }
}
