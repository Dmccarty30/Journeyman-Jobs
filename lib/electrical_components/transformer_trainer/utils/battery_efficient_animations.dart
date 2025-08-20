import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../services/structured_logger.dart';
import 'mobile_performance_manager.dart';

/// Internal lifecycle observer used by BatteryEfficientAnimations
class _BatteryLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    BatteryEfficientAnimations.onAppLifecycleChanged(state);
  }
}

final _BatteryLifecycleObserver _batteryLifecycleObserver = _BatteryLifecycleObserver();

/// Battery-efficient animation system for transformer trainer
class BatteryEfficientAnimations {
  static const int _targetFrameRate60 = 60;
  static const int _targetFrameRate30 = 30;
  static const int _targetFrameRate15 = 15;
  
  static Timer? _frameRateMonitor;
  static int _currentFrameRate = 60;
  static bool _batterySaverMode = false;
  static final List<AnimationController> _activeControllers = <AnimationController>[];
  
  /// Initialize the battery-efficient animation system
  static void initialize() {
    _startFrameRateMonitoring();
    _registerAppLifecycleListener();
  }
  
  /// Dispose of resources
  static void dispose() {
    _frameRateMonitor?.cancel();
    _frameRateMonitor = null;
    _pauseAllAnimations();
    // Remove lifecycle observer if registered
    try {
      WidgetsBinding.instance.removeObserver(_batteryLifecycleObserver);
    } catch (_) {
      // ignore if not registered or on older Flutter versions
    }
  }
  
  /// Register an animation controller for management
  static void registerController(AnimationController controller) {
    _activeControllers.add(controller);
    _applyFrameRateLimit(controller);
  }
  
  /// Unregister an animation controller
  static void unregisterController(AnimationController controller) {
    _activeControllers.remove(controller);
  }
  
  /// Create a battery-efficient animation controller
  static AnimationController createController({
    required Duration duration,
    required TickerProvider vsync,
    double? value,
    Duration? reverseDuration,
    String? debugLabel,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
  }) {
    final AnimationController controller = AnimationController(
      duration: _adjustDurationForPerformance(duration),
      reverseDuration: reverseDuration != null 
          ? _adjustDurationForPerformance(reverseDuration) 
          : null,
      vsync: vsync,
      value: value,
      debugLabel: debugLabel,
      animationBehavior: animationBehavior,
    );
    
    registerController(controller);
    return controller;
  }
  
  /// Adjust animation duration based on performance settings
  static Duration _adjustDurationForPerformance(Duration duration) {
    if (_batterySaverMode) {
      // Slow down animations in battery saver mode
      return Duration(milliseconds: (duration.inMilliseconds * 1.5).round());
    }
    
    final PerformanceSettings performanceSettings = MobilePerformanceManager.getOptimizedSettings();
    if (performanceSettings.reducedAnimations) {
      // Reduce animation duration for low-performance devices
      return Duration(milliseconds: (duration.inMilliseconds * 0.7).round());
    }
    
    return duration;
  }
  
  /// Apply frame rate limiting to a controller
  static void _applyFrameRateLimit(AnimationController controller) {
    if (_batterySaverMode) {
      _limitFrameRate(controller, _targetFrameRate15);
    } else if (MobilePerformanceManager.isLowPerformanceDevice) {
      _limitFrameRate(controller, _targetFrameRate30);
    } else {
      _limitFrameRate(controller, _targetFrameRate60);
    }
  }
  
  /// Limit frame rate for a specific controller
  static void _limitFrameRate(AnimationController controller, int targetFrameRate) {
    // This is a simplified approach - real implementation would use
    // more sophisticated frame rate limiting
    if (targetFrameRate < _targetFrameRate60) {
      controller.duration = Duration(
        milliseconds: (controller.duration?.inMilliseconds ?? 1000) * 
            (_targetFrameRate60 / targetFrameRate).round(),
      );
    }
  }
  
  /// Start monitoring frame rate performance
  static void _startFrameRateMonitoring() {
    _frameRateMonitor = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkFrameRatePerformance();
    });
  }
  
  /// Check current frame rate performance
  static void _checkFrameRatePerformance() {
    // In a real implementation, this would measure actual frame rate
    // For now, we'll simulate based on device characteristics
    final PerformanceSettings performanceSettings = MobilePerformanceManager.getOptimizedSettings();
    
    if (performanceSettings.reducedAnimations) {
      _currentFrameRate = _targetFrameRate30;
    } else {
      _currentFrameRate = _targetFrameRate60;
    }
    
    // Adjust all active controllers if needed
    _adjustActiveControllers();
  }
  
  /// Adjust all active controllers based on current performance
  static void _adjustActiveControllers() {
    for (final AnimationController controller in _activeControllers) {
      _applyFrameRateLimit(controller);
    }
  }
  
  /// Register app lifecycle listener for battery optimization
  static void _registerAppLifecycleListener() {
    try {
      WidgetsBinding.instance.addObserver(_batteryLifecycleObserver);
    } catch (_) {
      // ignore if already added or on older Flutter versions
    }
  }
  
  /// Handle app lifecycle changes
  static void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pauseAllAnimations();
        break;
      case AppLifecycleState.resumed:
        _resumeAllAnimations();
        break;
      case AppLifecycleState.inactive:
        // Reduce animation intensity
        _setBatterySaverMode(true);
        break;
      case AppLifecycleState.hidden:
        _pauseAllAnimations();
        break;
    }
  }
  
  /// Enable or disable battery saver mode
  static void _setBatterySaverMode(bool enabled) {
    if (_batterySaverMode != enabled) {
      _batterySaverMode = enabled;
      _adjustActiveControllers();
      
      if (kDebugMode) {
        StructuredLogger.debug('BatteryEfficientAnimations: Battery saver mode ${enabled ? 'enabled' : 'disabled'}');
      }
    }
  }
  
  /// Pause all active animations
  static void _pauseAllAnimations() {
    for (final AnimationController controller in _activeControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
  }
  
  /// Resume all paused animations
  static void _resumeAllAnimations() {
    // ignore: unused_local_variable
    for (final AnimationController controller in _activeControllers) {
      // Only resume if it was previously animating
      // In a real implementation, we'd track the previous state
    }
    _setBatterySaverMode(false);
  }
  
  /// Get current frame rate target
  static int get currentFrameRateTarget => _currentFrameRate;
  
  /// Check if in battery saver mode
  static bool get isBatterySaverMode => _batterySaverMode;
}

/// Battery-efficient connection point animation mixin
mixin BatteryEfficientConnectionPointAnimation<T extends StatefulWidget> on State<T> 
    implements TickerProvider {
  
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _pulseController = BatteryEfficientAnimations.createController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
      debugLabel: 'ConnectionPoint_Pulse',
    );
    
    _glowController = BatteryEfficientAnimations.createController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
      debugLabel: 'ConnectionPoint_Glow',
    );
    
    _scaleController = BatteryEfficientAnimations.createController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      debugLabel: 'ConnectionPoint_Scale',
    );
  }
  
  @override
  void dispose() {
    BatteryEfficientAnimations.unregisterController(_pulseController);
    BatteryEfficientAnimations.unregisterController(_glowController);
    BatteryEfficientAnimations.unregisterController(_scaleController);
    
    _pulseController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    
    super.dispose();
  }
  
  // Provide access to controllers for subclasses
  AnimationController get pulseController => _pulseController;
  AnimationController get glowController => _glowController;
  AnimationController get scaleController => _scaleController;
}

/// Extension for creating battery-efficient animations
extension BatteryEfficientAnimationBuilder on Widget {
  /// Wrap widget with battery-efficient animation container
  Widget withBatteryEfficientAnimation({
    required AnimationController controller,
    required Animation<double> animation,
  }) => AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // Check if animations should be reduced
        final PerformanceSettings performanceSettings = MobilePerformanceManager.getOptimizedSettings();
        
        if (performanceSettings.reducedAnimations) {
          // Return static widget for low-performance devices
          return child ?? this;
        }
        
        return this;
      },
      child: this,
    );
}

/// Smart animation widget that adapts to device performance
class AdaptiveAnimatedWidget extends StatefulWidget {
  
  const AdaptiveAnimatedWidget({
    required this.child, required this.animation, required this.builder, super.key,
  });
  final Widget child;
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget child, double value) builder;
  
  @override
  State<AdaptiveAnimatedWidget> createState() => _AdaptiveAnimatedWidgetState();
}

class _AdaptiveAnimatedWidgetState extends State<AdaptiveAnimatedWidget> {
  @override
  Widget build(BuildContext context) {
    final PerformanceSettings performanceSettings = MobilePerformanceManager.getOptimizedSettings();
    
    if (performanceSettings.reducedAnimations) {
      // Skip animation on low-performance devices
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget? child) => widget.builder(context, widget.child, widget.animation.value),
    );
  }
}
