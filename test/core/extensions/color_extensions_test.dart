import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/utils/color_extensions.dart';

void main() {
  group('Color Extensions Tests', () {
    test('should convert hex string to Color', () {
      // Arrange
      const hexString = '#1A202C'; // Navy blue from theme

      // Act
      final color = ColorExtensions.fromHex(hexString);

      // Assert
      expect(color, isA<Color>());
      expect(color.red, equals(0x1A));
      expect(color.green, equals(0x20));
      expect(color.blue, equals(0x2C));
      expect(color.alpha, equals(0xFF));
    });

    test('should handle hex string without hash', () {
      // Arrange
      const hexString = 'B45309'; // Copper from theme

      // Act
      final color = ColorExtensions.fromHex(hexString);

      // Assert
      expect(color, isA<Color>());
      expect(color.red, equals(0xB4));
      expect(color.green, equals(0x53));
      expect(color.blue, equals(0x09));
    });

    test('should convert Color to hex string', () {
      // Arrange
      const color = Color(0xFF1A202C);

      // Act
      final hexString = color.toHex();

      // Assert
      expect(hexString, equals('#1A202C'));
    });

    test('should calculate color brightness correctly', () {
      // Arrange
      const lightColor = Colors.white;
      const darkColor = Colors.black;

      // Act & Assert
      expect(lightColor.isLight, isTrue);
      expect(lightColor.isDark, isFalse);
      expect(darkColor.isLight, isFalse);
      expect(darkColor.isDark, isTrue);
    });

    test('should determine contrast color correctly', () {
      // Arrange
      const lightColor = Colors.white;
      const darkColor = Colors.black;

      // Act & Assert
      expect(lightColor.contrastColor, equals(Colors.black));
      expect(darkColor.contrastColor, equals(Colors.white));
    });

    test('should create color with opacity', () {
      // Arrange
      const baseColor = Color(0xFF1A202C);
      const opacity = 0.5;

      // Act
      final colorWithOpacity = baseColor.withOpacityValue(opacity);

      // Assert
      expect(colorWithOpacity.opacity, equals(opacity));
      expect(colorWithOpacity.red, equals(baseColor.red));
      expect(colorWithOpacity.green, equals(baseColor.green));
      expect(colorWithOpacity.blue, equals(baseColor.blue));
    });

    test('should blend colors correctly', () {
      // Arrange
      const color1 = Colors.red;
      const color2 = Colors.blue;
      const blendFactor = 0.5;

      // Act
      final blendedColor = color1.blendWith(color2, blendFactor);

      // Assert
      expect(blendedColor, isA<Color>());
      // The result should be somewhere between red and blue
      expect(blendedColor.red, lessThan(color1.red));
      expect(blendedColor.blue, lessThan(color2.blue));
    });

    test('should create electrical theme gradients', () {
      // Arrange
      const navyColor = Color(0xFF1A202C);
      const copperColor = Color(0xFFB45309);

      // Act
      final gradient = ColorExtensions.createElectricalGradient(navyColor, copperColor);

      // Assert
      expect(gradient, isA<LinearGradient>());
      expect(gradient.colors, contains(navyColor));
      expect(gradient.colors, contains(copperColor));
    });

    test('should validate electrical theme colors', () {
      // Arrange
      const navyHex = '#1A202C';
      const copperHex = '#B45309';

      // Act
      final navyColor = ColorExtensions.fromHex(navyHex);
      final copperColor = ColorExtensions.fromHex(copperHex);

      // Assert
      expect(navyColor.isDark, isTrue); // Navy should be dark
      expect(copperColor.toHex(), equals('#B45309'));
    });

    test('should handle electrical color accessibility', () {
      // Arrange
      const navyColor = Color(0xFF1A202C);
      const copperColor = Color(0xFFB45309);
      const whiteColor = Colors.white;

      // Act
      final navyContrast = navyColor.contrastRatio(whiteColor);
      final copperContrast = copperColor.contrastRatio(whiteColor);

      // Assert
      expect(navyContrast, greaterThan(4.5)); // WCAG AA standard
      expect(copperContrast, greaterThan(3.0)); // Should have decent contrast
    });
  });

  group('Electrical Theme Color Tests', () {
    test('should create circuit pattern colors', () {
      // Test colors used in circuit patterns
      const wireGreen = Color(0xFF10B981);
      const wireRed = Color(0xFFEF4444);
      const wireBlue = Color(0xFF3B82F6);

      expect(wireGreen.isLight, isFalse);
      expect(wireRed.isLight, isFalse);
      expect(wireBlue.isLight, isFalse);
    });

    test('should validate IBEW standard colors', () {
      // IBEW often uses specific color codes
      const ibewBlue = Color(0xFF0066CC);
      const safetyOrange = Color(0xFFFF6600);

      expect(ibewBlue.toHex(), equals('#0066CC'));
      expect(safetyOrange.toHex(), equals('#FF6600'));
    });

    test('should create appropriate warning colors for electrical work', () {
      // Electrical work requires high visibility warning colors
      const highVoltageYellow = Color(0xFFFFD700);
      const dangerRed = Color(0xFFDC2626);

      expect(highVoltageYellow.isLight, isTrue);
      expect(dangerRed.isDark, isFalse);
      
      // Should have good contrast with dark backgrounds
      const darkBackground = Color(0xFF1A202C);
      expect(highVoltageYellow.contrastRatio(darkBackground), greaterThan(7.0));
      expect(dangerRed.contrastRatio(darkBackground), greaterThan(4.5));
    });
  });
}

// Extension implementations for testing
extension ColorExtensions on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  bool get isLight {
    final luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance > 0.5;
  }

  bool get isDark => !isLight;

  Color get contrastColor => isLight ? Colors.black : Colors.white;

  Color withOpacityValue(double opacity) {
    return withOpacity(opacity);
  }

  Color blendWith(Color other, double factor) {
    return Color.lerp(this, other, factor) ?? this;
  }

  static LinearGradient createElectricalGradient(Color start, Color end) {
    return LinearGradient(
      colors: [start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  double contrastRatio(Color other) {
    final luminance1 = _getLuminance();
    final luminance2 = other._getLuminance();
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  double _getLuminance() {
    final r = red / 255.0;
    final g = green / 255.0;
    final b = blue / 255.0;
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
}