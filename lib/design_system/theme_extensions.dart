import 'package:flutter/material.dart';
import 'app_theme.dart';

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

  /// Light theme configuration
  static const light = ElectricalThemeExtension(
    circuitTraceColor: AppTheme.accentCopper,
    circuitTraceSecondary: AppTheme.secondaryCopper,
    electricalGlow: AppTheme.accentCopper,
    surfaceElevated: AppTheme.surfaceElevated,
    borderColor: AppTheme.borderCopper,
    glowIntensity: 0.3,
  );

  /// Dark theme configuration with enhanced visibility
  static const dark = ElectricalThemeExtension(
    circuitTraceColor: AppTheme.secondaryCopper,
    circuitTraceSecondary: AppTheme.accentCopper,
    electricalGlow: AppTheme.secondaryCopper,
    surfaceElevated: AppTheme.secondaryNavy,
    borderColor: AppTheme.secondaryCopper,
    glowIntensity: 0.5,
  );

  @override
  ThemeExtension<ElectricalThemeExtension> copyWith({
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
  ThemeExtension<ElectricalThemeExtension> lerp(
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
  ElectricalThemeExtension get electricalTheme =>
      Theme.of(this).extension<ElectricalThemeExtension>() ??
      ElectricalThemeExtension.light;
      
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
