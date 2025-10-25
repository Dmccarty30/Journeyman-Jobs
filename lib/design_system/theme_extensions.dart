import 'package:flutter/material.dart';

/// Custom theme extension for electrical-themed components
/// Provides enhanced dark mode support and theme-aware color schemes
@immutable
class ElectricalThemeExtension extends ThemeExtension<ElectricalThemeExtension> {
  final Color circuitTraceColor;
  final Color circuitTraceSecondary;
  final Color electricalGlow;
  final Color surfaceElevated;
  final Color borderColor;
  final double glowIntensity;

  const ElectricalThemeExtension({
    required this.circuitTraceColor,
    required this.circuitTraceSecondary,
    required this.electricalGlow,
    required this.surfaceElevated,
    required this.borderColor,
    required this.glowIntensity,
  });

  /// Light theme configuration (explicit values to avoid circular imports)
  static const light = ElectricalThemeExtension(
    circuitTraceColor: Color(0xFFB45309), // Copper
    circuitTraceSecondary: Color(0xFFD69E2E), // Light Copper
    electricalGlow: Color(0xFFB45309), // Copper glow
    surfaceElevated: Color(0xFFF7FAFC), // Light elevated
    borderColor: Color(0xFFB45309), // Copper border
    glowIntensity: 0.3,
  );

  /// Dark theme configuration with enhanced visibility (explicit values)
  static const dark = ElectricalThemeExtension(
    circuitTraceColor: Color(0xFFD69E2E), // Light Copper
    circuitTraceSecondary: Color(0xFFB45309), // Copper
    electricalGlow: Color(0xFFD69E2E), // Brighter for dark mode
    surfaceElevated: Color(0xFF2D3748), // Navy elevated
    borderColor: Color(0xFFD69E2E), // Light Copper border
    glowIntensity: 0.5,
  );

  /// Resolve to the correct variant based on brightness
  static ElectricalThemeExtension fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  ElectricalThemeExtension copyWith({
    Color? circuitTraceColor,
    Color? circuitTraceSecondary,
    Color? electricalGlow,
    Color? surfaceElevated,
    Color? borderColor,
    double? glowIntensity,
  }) {
    return ElectricalThemeExtension(
      circuitTraceColor: circuitTraceColor ?? this.circuitTraceColor,
      circuitTraceSecondary: circuitTraceSecondary ?? this.circuitTraceSecondary,
      electricalGlow: electricalGlow ?? this.electricalGlow,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      borderColor: borderColor ?? this.borderColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
    );
  }

  @override
  ElectricalThemeExtension lerp(
    ThemeExtension<ElectricalThemeExtension>? other,
    double t,
  ) {
    if (other is! ElectricalThemeExtension) {
      return this;
    }

    return ElectricalThemeExtension(
      circuitTraceColor: Color.lerp(circuitTraceColor, other.circuitTraceColor, t)!,
      circuitTraceSecondary: Color.lerp(circuitTraceSecondary, other.circuitTraceSecondary, t)!,
      electricalGlow: Color.lerp(electricalGlow, other.electricalGlow, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      glowIntensity: glowIntensity + (other.glowIntensity - glowIntensity) * t,
    );
  }
}

/// Helper extension to easily access electrical theme from BuildContext
extension ElectricalThemeContext on BuildContext {
  ElectricalThemeExtension get electricalTheme {
    final theme = Theme.of(this);
    final ext = theme.extension<ElectricalThemeExtension>();
    if (ext != null) return ext;
    // Fallback if not registered on ThemeData: resolve from brightness
    return ElectricalThemeExtension.fromBrightness(theme.brightness);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
