import 'package:flutter/material.dart';

/// Provides convenient extension methods for the [Color] class.
extension ColorExtension on Color {
  /// Converts the color to a CSS-compatible `rgba()` string.
  ///
  /// Example: `Colors.red.withOpacity(0.5)` would produce `'rgba(244, 67, 54, 0.5)'`.
  String toCssString() {
    return 'rgba($red, $green, $blue, $opacity)';
  }
}
