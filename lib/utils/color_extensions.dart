import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toCssString() {
    return 'rgba(${(r * 255.0).round()}, ${(g * 255.0).round()}, ${(b * 255.0).round()}, $a)';
  }
  
  /// Creates a new color with the same RGB but different opacity.
  /// 
  /// The [alpha] parameter should be between 0.0 (transparent) and 1.0 (opaque).
  /// This is a convenience wrapper around [Color.withValues].
  Color withOpacity(double alpha) {
    return withValues(alpha: alpha);
  }
}
