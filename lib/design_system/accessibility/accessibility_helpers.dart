import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Accessibility utilities for improved app usability
///
/// Provides utilities for:
/// - Screen reader announcements via SemanticsService
/// - Semantic label generation for interactive elements
/// - Haptic feedback for user interactions
/// - High contrast detection and text scaling
class AccessibilityHelpers {
  /// Announce message to screen readers
  ///
  /// Uses SemanticsService to announce text to screen readers.
  /// This is useful for providing feedback on actions or state changes.
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create semantic label for buttons with state
  static String createButtonSemanticLabel({
    required String baseLabel,
    bool isLoading = false,
    bool isEnabled = true,
    String? additionalInfo,
  }) {
    var label = baseLabel;
    
    if (!isEnabled) {
      label += ', disabled';
    } else if (isLoading) {
      label += ', loading';
    }
    
    if (additionalInfo != null) {
      label += ', $additionalInfo';
    }
    
    return label;
  }

  /// Provide haptic feedback for user interactions
  static void provideTactileFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Check if high contrast is enabled
  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get accessible text scale factor
  ///
  /// Returns the text scale factor from MediaQuery, clamped to prevent
  /// layout issues with extremely large or small text.
  static double getAccessibleTextScale(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final textScaleFactor = textScaler.scale(1.0);
    // Ensure text doesn't become too large for layout
    return textScaleFactor.clamp(0.8, 2.0);
  }
}

/// Wrapper widget for enhanced accessibility
class AccessibleWrapper extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? hint;
  final bool excludeSemantics;
  final VoidCallback? onTap;

  const AccessibleWrapper({
    super.key,
    required this.child,
    this.semanticLabel,
    this.hint,
    this.excludeSemantics = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

/// Haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}
