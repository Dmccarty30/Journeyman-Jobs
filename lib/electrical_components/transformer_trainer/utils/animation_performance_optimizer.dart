import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'mobile_performance_manager.dart';
import 'transformer_performance_monitor.dart';

/// Optimizes animation performance for transformer trainer
class AnimationPerformanceOptimizer {
  
  AnimationPerformanceOptimizer._();
  static final AnimationPerformanceOptimizer _instance = AnimationPerformanceOptimizer._();
  static AnimationPerformanceOptimizer get instance => _instance;
  
  // Animation controllers registry
  final Map<String, AnimationController> _controllers = <String, AnimationController>{};
  final Map<String, Timer> _frameRateLimiters = <String, Timer>{};
  
  // Performance settings
  late PerformanceSettings _settings;
  bool _reducedMotion = false;
  
  /// Initialize with performance settings
  void initialize() {
    _settings = MobilePerformanceManager.getOptimizedSettings();
    _reducedMotion = _settings.reducedAnimations;
  }
  
  /// Create optimized animation controller
  AnimationController createOptimizedController({
    required TickerProvider vsync,
    required Duration duration,
    required String identifier,
    double? upperBound,
    double? lowerBound,
  }) {
    // Adjust duration based on performance settings
    final Duration optimizedDuration = _reducedMotion 
        ? Duration(milliseconds: duration.inMilliseconds ~/ 2)
        : duration;
    
    final AnimationController controller = AnimationController(
      vsync: vsync,
      duration: optimizedDuration,
      upperBound: upperBound ?? 1.0,
      lowerBound: lowerBound ?? 0.0,
    );
    
    // Register controller
    _controllers[identifier] = controller;
    
    // Apply frame rate limiting if needed
    if (_settings.maxAnimationFrameRate < 60) {
      _applyFrameRateLimit(identifier, controller);
    }
    
    // Monitor performance
    _monitorAnimation(identifier, controller);
    
    return controller;
  }
  
  /// Apply frame rate limiting to animation
  void _applyFrameRateLimit(String identifier, AnimationController controller) {
    final int frameInterval = 1000 ~/ _settings.maxAnimationFrameRate;
    DateTime lastFrame = DateTime.now();
    
    controller.addListener(() {
      final DateTime now = DateTime.now();
      if (now.difference(lastFrame).inMilliseconds >= frameInterval) {
        lastFrame = now;
        // Frame is allowed
      } else {
        // Skip this frame
        SchedulerBinding.instance.scheduleFrame();
      }
    });
  }
  
  /// Monitor animation performance
  void _monitorAnimation(String identifier, AnimationController controller) {
    final TransformerPerformanceMonitor monitor = TransformerPerformanceMonitor.instance;
    DateTime? animationStart;
    int frameCount = 0;
    
    void onFrame() {
      frameCount++;
    }
    
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        animationStart = DateTime.now();
        frameCount = 0;
        controller.addListener(onFrame);
      } else if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.removeListener(onFrame);
        
        if (animationStart != null) {
          final Duration duration = DateTime.now().difference(animationStart!);
          final double fps = frameCount / duration.inSeconds;
          
          monitor.trackAnimation(
            identifier,
            frameCount: frameCount,
            duration: duration,
            averageFps: fps,
          );
        }
      }
    });
  }
  
  /// Create optimized curve animation
  Animation<T> createCurvedAnimation<T>({
    required Animation<double> parent,
    required Curve curve,
    required Tween<T> tween,
    bool enableOptimizations = true,
  }) {
    // Use simpler curves for low-performance devices
    final Curve optimizedCurve = enableOptimizations && _reducedMotion
        ? Curves.linear
        : curve;
    
    return tween.animate(
      CurvedAnimation(
        parent: parent,
        curve: optimizedCurve,
      ),
    );
  }
  
  /// Create staggered animation group with performance optimization
  List<Animation<double>> createStaggeredAnimations({
    required AnimationController controller,
    required int count,
    required double totalDuration,
    double overlap = 0.5,
  }) {
    // Reduce animation count for low-performance devices
    final int optimizedCount = _reducedMotion ? (count / 2).ceil() : count;
    
    final List<Animation<double>> animations = <Animation<double>>[];
    final double interval = totalDuration / optimizedCount;
    
    for (int i = 0; i < optimizedCount; i++) {
      final double start = (i * interval * (1 - overlap)) / totalDuration;
      final double end = start + (interval / totalDuration);
      
      animations.add(
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }
    
    return animations;
  }
  
  /// Batch multiple animations for better performance
  Future<void> runBatchedAnimations(
    List<VoidCallback> animations, {
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) async {
    if (!_settings.batchUpdates) {
      // Run all at once if batching is disabled
      for (final VoidCallback animation in animations) {
        animation();
      }
      return;
    }
    
    // Batch animations to reduce frame pressure
    for (int i = 0; i < animations.length; i++) {
      animations[i]();
      
      // Only delay if not reduced motion and multiple animations
      if (!_reducedMotion && i < animations.length - 1) {
        await Future.delayed(staggerDelay);
      }
    }
  }
  
  /// Optimize paint operations for animations
  void optimizePaintOperations(VoidCallback paintCallback) {
    if (_reducedMotion) {
      // Skip complex paint operations
      return;
    }
    
    // Use picture recording for complex paint operations
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    
    // Execute paint operations
    paintCallback();
    
    // Cache the picture for reuse
    recorder.endRecording();
    // Picture can be reused in subsequent frames
  }
  
  /// Check if animation should be simplified
  bool shouldSimplifyAnimation(String animationType) {
    if (_reducedMotion) return true;
    
    // Check current performance metrics
    final TransformerPerformanceMonitor monitor = TransformerPerformanceMonitor.instance;
    if (!monitor.isPerformanceAcceptable()) {
      return true;
    }
    
    // Specific animation simplifications
    switch (animationType) {
      case 'wire_connection':
        return _controllers.length > 5; // Simplify if many animations running
      case 'energize_effect':
        return _settings.maxAnimationFrameRate < 60;
      case 'success_celebration':
        return false; // Always show success animations
      default:
        return _reducedMotion;
    }
  }
  
  /// Get animation duration based on performance
  Duration getOptimizedDuration(Duration baseDuration, String animationType) {
    if (_reducedMotion) {
      return Duration(milliseconds: baseDuration.inMilliseconds ~/ 2);
    }
    
    // Adjust based on animation type and current performance
    final double multiplier = _getAnimationSpeedMultiplier(animationType);
    return Duration(milliseconds: (baseDuration.inMilliseconds * multiplier).round());
  }
  
  double _getAnimationSpeedMultiplier(String animationType) {
    if (_reducedMotion) return 0.5;
    
    switch (animationType) {
      case 'wire_connection':
        return 0.8; // Slightly faster for responsiveness
      case 'energize_effect':
        return 1; // Normal speed for safety visualization
      case 'success_celebration':
        return 1.2; // Slightly slower for emphasis
      default:
        return 1;
    }
  }
  
  /// Dispose of a specific animation controller
  void disposeController(String identifier) {
    _controllers[identifier]?.dispose();
    _controllers.remove(identifier);
    _frameRateLimiters[identifier]?.cancel();
    _frameRateLimiters.remove(identifier);
  }
  
  /// Dispose all resources
  void dispose() {
    for (final AnimationController controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    
    for (final Timer timer in _frameRateLimiters.values) {
      timer.cancel();
    }
    _frameRateLimiters.clear();
  }
  
  /// Update performance settings dynamically
  void updatePerformanceSettings() {
    _settings = MobilePerformanceManager.getOptimizedSettings();
    _reducedMotion = _settings.reducedAnimations;
  }
}
