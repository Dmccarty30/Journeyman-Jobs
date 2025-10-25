// Required imports
import 'package:flutter/material.dart';
import 'circuit_board_background.dart';
import 'jj_electrical_notifications.dart';

/// Journeyman Jobs Electrical Theme - Complete Integration Package
///
/// This file exports all electrical-themed components and utilities
/// for easy integration throughout the app.

// Background Components
export 'circuit_board_background.dart';

// Interactive Widgets
export 'jj_electrical_interactive_widgets.dart';

// Notifications & Feedback
export 'jj_electrical_notifications.dart';

// Page Transitions
export 'jj_electrical_page_transitions.dart';

// Loading & Animation Components
export 'electrical_rotation_meter.dart';
export 'power_line_loader.dart';
export 'three_phase_sine_wave_loader.dart';

// Electrical Controls
export 'jj_circuit_breaker_switch.dart';
export 'jj_circuit_breaker_switch_list_tile.dart';

// Toast & Feedback Components
export 'jj_electrical_toast.dart';
export 'jj_snack_bar.dart';

// Utility Components
export 'circuit_breaker_toggle.dart';
export 'circuit_pattern_painter.dart';
export 'hard_hat_icon.dart';
export 'transmission_tower_icon.dart';

// Enhanced Backgrounds - CircuitPatternPainter conflict resolved
// Note: enhanced_backgrounds.dart contains an internal CircuitPatternPainter
// that conflicts with the one in circuit_pattern_painter.dart
// export 'enhanced_backgrounds.dart'; // Commented out to resolve naming conflict

// Electrical Illustrations & Examples
export 'electrical_illustrations_example.dart';

// Optimized Exports
export 'optimized_electrical_exports.dart';

// Transformer Components
export 'transformer_trainer/transformer_trainer.dart';
export 'transformer_trainer/jj_transformer_trainer.dart';

/// Utility class for common electrical theme operations
class JJElectricalTheme {
  
  /// Primary electrical colors
  static const electricBlue = Color(0xFF00D4FF);
  static const copperOrange = Color(0xFFB45309);
  static const darkNavy = Color(0xFF1A202C);
  static const warningYellow = Color(0xFFFFD700);
  static const dangerRed = Color(0xFFDC2626);
  static const successGreen = Color(0xFF10B981);
  
  /// Quick background wrapper
  static Widget withElectricalBackground({
    required Widget child,
    double opacity = 0.12,
    ComponentDensity density = ComponentDensity.medium,
    double animationSpeed = 1.5,
    bool enableCurrentFlow = true,
    bool enableInteractiveComponents = true,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ElectricalCircuitBackground(
            opacity: opacity,
            componentDensity: density,
            animationSpeed: animationSpeed,
            enableCurrentFlow: enableCurrentFlow,
            enableInteractiveComponents: enableInteractiveComponents,
          ),
        ),
        child,
      ],
    );
  }
  
  /// Quick notification helpers
  static void showSuccess(BuildContext context, String message) {
    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: message,
      type: ElectricalNotificationType.success,
      showLightning: true,
    );
  }
  
  static void showWarning(BuildContext context, String message) {
    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: message,
      type: ElectricalNotificationType.warning,
      showLightning: true,
    );
  }
  
  static void showError(BuildContext context, String message) {
    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: message,
      type: ElectricalNotificationType.error,
      showLightning: true,
    );
  }
  
  static void showInfo(BuildContext context, String message) {
    JJElectricalNotifications.showElectricalSnackBar(
      context: context,
      message: message,
      type: ElectricalNotificationType.info,
    );
  }
}

/// Extension methods for easier electrical theme integration
extension ElectricalThemeExtensions on Widget {
  
  /// Wrap with electrical background
  Widget electricalBackground({
    double opacity = 0.12,
    ComponentDensity density = ComponentDensity.medium,
  }) {
    return JJElectricalTheme.withElectricalBackground(
      child: this,
      opacity: opacity,
      density: density,
    );
  }
  
  /// Wrap with electrical tooltip
  Widget electricalTooltip(String message) {
    return JJElectricalNotifications.electricalTooltip(
      message: message,
      child: this,
    );
  }
}