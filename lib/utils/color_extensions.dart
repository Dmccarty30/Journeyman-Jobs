import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toCssString() {
    return 'rgba($red, $green, $blue, $opacity)';
  }
}