import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../services/cache_service.dart';
import '../../../services/performance_monitoring_service.dart';
import '../services/structured_logger.dart';
import 'mobile_performance_manager.dart';

/// Performance monitoring specifically for transformer trainer feature
class TransformerPerformanceMonitor {
  
  TransformerPerformanceMonitor._();
  static TransformerPerformanceMonitor? _instance;
  static TransformerPerformanceMonitor get instance {
    _instance ??= TransformerPerformanceMonitor._();
    return _instance!;
  }
  
  // Performance metrics
  final Map<String, List<int>> _frameTimings = <String, List<int>>{};
  final Map<String, DateTime> _operationStarts = <String, DateTime>{};
  int _totalFrames = 0;
  int _droppedFrames = 0;
  DateTime? _sessionStart;
  
  // Memory tracking
  int _peakMemoryUsage = 0;
  
  // Asset loading metrics
  final Map<String, Duration> _assetLoadTimes = <String, Duration>{};
  
  // Animation performance
  final Map<String, AnimationMetrics> _animationMetrics = <String, AnimationMetrics>{};
  
  /// Initialize monitoring for a training session
  void startSession() {
    _sessionStart = DateTime.now();
    _frameTimings.clear();
    _operationStarts.clear();
    _animationMetrics.clear();
    _totalFrames = 0;
    _droppedFrames = 0;
    
    // Start frame monitoring
    _startFrameMonitoring();
    
    // Record initial memory usage
    _recordMemoryUsage();
    
    // Initialize mobile performance manager
    MobilePerformanceManager.initialize();
  }
  
  /// End session and report metrics
  Future<void> endSession() async {
    if (_sessionStart == null) return;
    
    final Duration sessionDuration = DateTime.now().difference(_sessionStart!);
    
    // Calculate average frame rate
    final int avgFrameRate = _totalFrames > 0 
        ? (1000 * _totalFrames / sessionDuration.inMilliseconds).round()
        : 0;
    
    // Report to Firebase
    PerformanceMonitoringService.trackUserInteraction(
      action: 'transformer_training_session',
      responseTime: sessionDuration,
      screen: 'transformer_trainer',
      context: <String, dynamic>{
        'avg_frame_rate': avgFrameRate,
        'dropped_frames': _droppedFrames,
        'total_frames': _totalFrames,
        'peak_memory_mb': _peakMemoryUsage,
        'animations_played': _animationMetrics.length,
        'cache_hit_rate': CacheService().getStats()['hitRate'],
      },
    );
    
    // Clean up
    MobilePerformanceManager.dispose();
    _sessionStart = null;
  }
  
  /// Track operation start time
  void startOperation(String operationName) {
    _operationStarts[operationName] = DateTime.now();
  }
  
  /// Track operation completion
  void endOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final DateTime? startTime = _operationStarts.remove(operationName);
    if (startTime == null) return;
    
    final Duration duration = DateTime.now().difference(startTime);
    
    // Track specific operations
    switch (operationName) {
      case 'diagram_render':
        _trackDiagramRender(duration, metadata);
        break;
      case 'connection_animation':
        _trackConnectionAnimation(duration, metadata);
        break;
      case 'asset_load':
        _trackAssetLoad(duration, metadata);
        break;
      case 'state_update':
        _trackStateUpdate(duration, metadata);
        break;
      default:
        _trackGenericOperation(operationName, duration, metadata);
    }
  }
  
  /// Track animation performance
  void trackAnimation(String animationName, {
    required int frameCount,
    required Duration duration,
    required double averageFps,
  }) {
    _animationMetrics[animationName] = AnimationMetrics(
      frameCount: frameCount,
      duration: duration,
      averageFps: averageFps,
      timestamp: DateTime.now(),
    );
    
    // Warn if animation performance is poor
    if (averageFps < 30) {
      StructuredLogger.debug('⚠️ Low FPS in animation $animationName: ${averageFps.toStringAsFixed(1)}');
    }
  }
  
  /// Monitor frame rendering performance
  void _startFrameMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }
  
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final FrameTiming timing in timings) {
      _totalFrames++;
      
      final int frameDuration = timing.totalSpan.inMilliseconds;
      
      // Track frame if it took longer than 16ms (60 FPS threshold)
      if (frameDuration > 16) {
        _droppedFrames++;
        
        if (kDebugMode && frameDuration > 33) { // Below 30 FPS
          StructuredLogger.debug('⚠️ Slow frame detected: ${frameDuration}ms');
        }
      }
      
      // Store frame timing for analysis
      final String bucket = _getFrameBucket(frameDuration);
      _frameTimings.putIfAbsent(bucket, () => <int>[]).add(frameDuration);
    }
  }
  
  String _getFrameBucket(int milliseconds) {
    if (milliseconds <= 16) return 'excellent'; // 60+ FPS
    if (milliseconds <= 33) return 'good';      // 30-60 FPS
    if (milliseconds <= 50) return 'acceptable'; // 20-30 FPS
    return 'poor'; // Below 20 FPS
  }
  
  /// Track diagram rendering performance
  void _trackDiagramRender(Duration duration, Map<String, dynamic>? metadata) {
    final bankType = metadata?['bank_type'] ?? 'unknown';
    final connectionCount = metadata?['connection_count'] ?? 0;
    
    PerformanceMonitoringService.trackUserInteraction(
      action: 'transformer_diagram_render',
      responseTime: duration,
      screen: 'transformer_trainer',
      context: <String, dynamic>{
        'bank_type': bankType,
        'connection_count': connectionCount,
        'render_time_ms': duration.inMilliseconds,
        'performance_level': _getPerformanceLevel(duration),
      },
    );
  }
  
  /// Track connection animation performance
  void _trackConnectionAnimation(Duration duration, Map<String, dynamic>? metadata) {
    
    if (duration.inMilliseconds > 300) {
      StructuredLogger.debug('⚠️ Slow connection animation: ${duration.inMilliseconds}ms');
    }
  }
  
  /// Track asset loading performance
  void _trackAssetLoad(Duration duration, Map<String, dynamic>? metadata) {
    final assetName = metadata?['asset_name'] ?? 'unknown';
    
    _assetLoadTimes[assetName] = duration;
    
    // Cache asset if load time was significant
    if (duration.inMilliseconds > 100) {
      _cacheAssetForFuture(assetName, metadata);
    }
  }
  
  /// Track state update performance
  void _trackStateUpdate(Duration duration, Map<String, dynamic>? metadata) {
    final updateType = metadata?['update_type'] ?? 'unknown';
    
    if (duration.inMilliseconds > 50) {
      StructuredLogger.debug('⚠️ Slow state update: $updateType took ${duration.inMilliseconds}ms');
    }
  }
  
  /// Generic operation tracking
  void _trackGenericOperation(String operation, Duration duration, Map<String, dynamic>? metadata) {
    PerformanceMonitoringService.trackUserInteraction(
      action: 'transformer_$operation',
      responseTime: duration,
      screen: 'transformer_trainer',
      context: metadata ?? <String, dynamic>{},
    );
  }
  
  /// Get performance level based on duration
  String _getPerformanceLevel(Duration duration) {
    final int ms = duration.inMilliseconds;
    if (ms < 16) return 'excellent';
    if (ms < 50) return 'good';
    if (ms < 100) return 'acceptable';
    if (ms < 200) return 'poor';
    return 'critical';
  }
  
  /// Record memory usage
  void _recordMemoryUsage() {
    // In production, this would use platform channels to get actual memory usage.
    // For now, attempt a safe probe of the widget tree; fall back to 0 if unavailable.
    try {
      final int widgetCount = WidgetsBinding.instance.rootElement == null ? 0 : 1;
      if (widgetCount > _peakMemoryUsage) {
        _peakMemoryUsage = widgetCount;
      }
    } catch (_) {
      // Not critical — ignore in environments where this isn't accessible.
    }
  }
  
  /// Cache asset for future use
  void _cacheAssetForFuture(String assetName, Map<String, dynamic>? metadata) {
    // Implement asset caching strategy
    CacheService().set(
      'transformer_asset_$assetName',
      metadata ?? <String, dynamic>{},
      ttl: const Duration(days: 7),
    );
  }
  
  /// Get current performance metrics
  Map<String, dynamic> getCurrentMetrics() {
    final int avgFrameRate = _totalFrames > 0 
        ? (1000 * _totalFrames / (_sessionStart != null 
            ? DateTime.now().difference(_sessionStart!).inMilliseconds 
            : 1)).round()
        : 0;
    
    return <String, dynamic>{
      'avg_frame_rate': avgFrameRate,
      'dropped_frames': _droppedFrames,
      'total_frames': _totalFrames,
      'frame_drop_rate': _totalFrames > 0 ? (_droppedFrames / _totalFrames * 100).toStringAsFixed(1) : '0',
      'peak_memory': _peakMemoryUsage,
      'animations': _animationMetrics.length,
      'cached_assets': _assetLoadTimes.length,
      'performance_settings': MobilePerformanceManager.getOptimizedSettings(),
    };
  }
  
  /// Check if performance is acceptable
  bool isPerformanceAcceptable() {
    final Map<String, dynamic> metrics = getCurrentMetrics();
    final double frameDropRate = double.tryParse(metrics['frame_drop_rate'].toString().replaceAll('%', '')) ?? 0;
    
    return frameDropRate < 10; // Less than 10% frame drops
  }
}

/// Animation performance metrics
class AnimationMetrics {
  
  AnimationMetrics({
    required this.frameCount,
    required this.duration,
    required this.averageFps,
    required this.timestamp,
  });
  final int frameCount;
  final Duration duration;
  final double averageFps;
  final DateTime timestamp;
}
