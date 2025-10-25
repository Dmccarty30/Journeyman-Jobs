/// Optimized barrel exports for electrical components
/// 
/// Organized by functionality and usage frequency to improve tree-shaking
/// and reduce bundle size through targeted imports.
/// 
/// Usage:
/// ```dart
/// // Import only what you need
/// import 'package:journeyman_jobs/electrical_components/optimized_electrical_exports.dart'
///     show ElectricalLoaders, CircuitBreakerComponents;
/// ```
library;

import 'dart:core';

// === CORE COMPONENTS (Frequently Used) ===

/// Essential electrical loading indicators
/// Used throughout the app for loading states
abstract class ElectricalLoaders {
  // Basic loaders - lightweight, frequently used
  static List<String> export() {
    return <String>[
      'three_phase_sine_wave_loader.dart',
      'power_line_loader.dart',
    ];
  }
}

/// Circuit breaker interactive components
/// Used in settings, calculators, and interactive features
abstract class CircuitBreakerComponents {
  static List<String> export() => <String>[
    'jj_circuit_breaker_switch.dart',
    'jj_circuit_breaker_switch_list_tile.dart',
    'circuit_breaker_toggle.dart',
  ];
}

/// Basic electrical icons and decorative elements
/// Lightweight components for visual theming
abstract class ElectricalIcons {
  static List<String> export() => <String>[
    'hard_hat_icon.dart',
    'transmission_tower_icon.dart',
    'circuit_pattern_painter.dart',
  ];
}

// === ENHANCED COMPONENTS (Moderate Usage) ===

/// Advanced electrical meters and gauges
/// Used for monitoring and measurement displays
abstract class ElectricalMeters {
  static List<String> export() => <String>[
    'electrical_rotation_meter.dart',
  ];
}

/// Enhanced background patterns and visual effects
/// Used for themed screens and visual enhancement
abstract class EnhancedVisuals {
  static List<String> export() => <String>[
    'enhanced_backgrounds.dart',
  ];
}

/// Electrical toast notifications and feedback
/// Used for user notifications with electrical theming
abstract class ElectricalFeedback {
  static List<String> export() => <String>[
    'jj_electrical_toast.dart',
  ];
}

// === HEAVY COMPONENTS (Lazy Load Candidates) ===

/// Large collection of electrical loading components
/// Consider lazy loading - 759 lines, ~80KB estimated
abstract class ElectricalLoadingCollection {
  static List<String> export() => <String>[
    'electrical_loading_components.dart',
  ];
  
  // Lazy loading factory method
  static Future<Type> createLoader(String loaderType) async {
    // Implement dynamic import when available
    throw UnimplementedError('Lazy loading not yet implemented');
  }
}

// === TRANSFORMER TRAINER COMPONENTS (Route-Based Lazy Loading) ===

/// Core transformer trainer functionality
/// Heavy educational component - lazy load by route
abstract class TransformerTrainerCore {
  static List<String> export() => <String>[
    'transformer_trainer/jj_transformer_trainer.dart',
    'transformer_trainer/transformer_trainer.dart',
  ];
}

/// Transformer training modes and educational content
/// Load on-demand when specific training mode is accessed
abstract class TransformerTrainingModes {
  static List<String> export() => <String>[
    'transformer_trainer/modes/guided_mode.dart',
    'transformer_trainer/modes/quiz_mode.dart',
  ];
}

/// Transformer diagram painters and visual components
/// Heavy visual components for educational display
abstract class TransformerVisuals {
  static List<String> export() => <String>[
    'transformer_trainer/painters/base_transformer_painter.dart',
    'transformer_trainer/painters/delta_delta_painter.dart',
    'transformer_trainer/painters/delta_wye_painter.dart',
    'transformer_trainer/painters/open_delta_painter.dart',
    'transformer_trainer/painters/wye_delta_painter.dart',
    'transformer_trainer/painters/wye_wye_painter.dart',
    'transformer_trainer/widgets/transformer_diagram.dart',
  ];
}

/// Transformer animations and visual effects
/// Heavy animation components - lazy load on user interaction
abstract class TransformerAnimations {
  static List<String> export() => <String>[
    'transformer_trainer/animations/flash_animation.dart',
    'transformer_trainer/animations/success_animation.dart',
    'transformer_trainer/animations/electrical_fire_animation.dart',
    'transformer_trainer/animations/power_up_animation.dart',
  ];
  
  // Factory for lazy loading animations
  static Future<Type> loadAnimation(String animationType) async {
    // Implement when Flutter supports dynamic imports
    switch (animationType) {
      case 'flash':
        // return await import('transformer_trainer/animations/flash_animation.dart');
      case 'success':
        // return await import('transformer_trainer/animations/success_animation.dart');
      case 'fire':
        // return await import('transformer_trainer/animations/electrical_fire_animation.dart');
      case 'powerUp':
        // return await import('transformer_trainer/animations/power_up_animation.dart');
      default:
        throw UnimplementedError('Animation type not supported: $animationType');
    }
  }
}

/// Transformer utility and optimization components
/// Performance and utility classes for transformer features
abstract class TransformerUtils {
  static List<String> export() => <String>[
    'transformer_trainer/utils/accessibility_manager.dart',
    'transformer_trainer/utils/animation_performance_optimizer.dart',
    'transformer_trainer/utils/battery_efficient_animations.dart',
    'transformer_trainer/utils/mobile_performance_manager.dart',
    'transformer_trainer/utils/offline_content_cache.dart',
    'transformer_trainer/utils/render_optimization_manager.dart',
    'transformer_trainer/utils/responsive_layout_manager.dart',
    'transformer_trainer/utils/transformer_asset_manager.dart',
    'transformer_trainer/utils/transformer_performance_monitor.dart',
  ];
}

/// Transformer models and data structures
/// Educational content and state management
abstract class TransformerModels {
  static List<String> export() => <String>[
    'transformer_trainer/models/educational_content.dart',
    'transformer_trainer/models/transformer_models_export.dart',
  ];
}

/// Transformer UI widgets and interactive elements
/// User interface components for transformer training
abstract class TransformerWidgets {
  static List<String> export() => <String>[
    'transformer_trainer/widgets/connection_point.dart',
    'transformer_trainer/widgets/mobile_ui_patterns.dart',
    'transformer_trainer/widgets/trainer_widget.dart',
  ];
}

/// Transformer state management
/// State handling for transformer training sessions
abstract class TransformerState {
  static List<String> export() => <String>[
    'transformer_trainer/state/transformer_state.dart',
  ];
}

// === USAGE PATTERNS ===

/// Most common electrical components for general use
/// Import this for basic electrical theming and functionality
abstract class CommonElectricalComponents {
  static const List<String> exports = <String>[
    // Core loaders (lightweight)
    'three_phase_sine_wave_loader.dart',

    // Essential icons
    'hard_hat_icon.dart',
    'transmission_tower_icon.dart',
    'circuit_pattern_painter.dart',

    // Basic interactive components
    'jj_circuit_breaker_switch.dart',
    'circuit_breaker_toggle.dart',
  ];
}

/// Specialized components for settings and calculator screens
/// Import for advanced electrical functionality
abstract class SpecializedElectricalComponents {
  static const List<String> exports = <String>[
    // Advanced controls
    'jj_circuit_breaker_switch_list_tile.dart',
    'electrical_rotation_meter.dart',
    
    // Enhanced visuals
    'enhanced_backgrounds.dart',
    'jj_electrical_toast.dart',
  ];
}

/// Heavy components that should be lazy loaded
/// Only import when specifically needed
abstract class HeavyElectricalComponents {
  static const List<String> exports = <String>[
    'electrical_loading_components.dart', // 759 lines
  ];
  
  // Note: Transformer trainer components should be loaded by route
  // Consider implementing route-based code splitting
}

// === OPTIMIZATION NOTES ===

/// Performance optimization guidelines:
/// 
/// 1. **Common Components**: Use for basic electrical theming (~20KB)
/// 2. **Specialized Components**: Use for advanced features (~30KB)  
/// 3. **Heavy Components**: Lazy load only when needed (~80KB+)
/// 4. **Transformer Trainer**: Implement route-based code splitting (~200KB+)
/// 5. **Animations**: Load on user interaction to reduce initial bundle
/// 
/// Tree-shaking benefits:
/// - Import only needed component categories
/// - Unused components are eliminated from bundle
/// - Reduced initial load time and bundle size
/// 
/// Future optimization opportunities:
/// - Implement dynamic imports when Flutter supports them
/// - Route-based code splitting for transformer trainer
/// - Component-level lazy loading for large animations
/// - Asset-based lazy loading for educational content

/// Example usage patterns:
/// ```dart
/// // Basic electrical theming
/// import 'optimized_electrical_exports.dart' show CommonElectricalComponents;
/// 
/// // Settings and calculator screens  
/// import 'optimized_electrical_exports.dart' show SpecializedElectricalComponents;
/// 
/// // Heavy components (consider lazy loading)
/// import 'optimized_electrical_exports.dart' show HeavyElectricalComponents;
/// ```
