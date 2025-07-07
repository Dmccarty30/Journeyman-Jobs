import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toCssString() {
    return 'rgba(${(r * 255.0).round()}, ${(g * 255.0).round()}, ${(b * 255.0).round()}, $a)';
  }
}