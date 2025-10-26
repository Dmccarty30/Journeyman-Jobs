import 'package:flutter/material.dart';

/// TailboardScreen enhanced color theme with modern depth and visual hierarchy
class TailboardTheme {
  TailboardTheme._(); // Private constructor for singleton-like behavior

  // Core Navy Palette (5 variants for depth)
  static const Color navy900 = Color(0xFF0F1419);  // Deepest background
  static const Color navy800 = Color(0xFF1A202C);  // Primary background
  static const Color navy700 = Color(0xFF2D3748);  // Elevated surfaces
  static const Color navy600 = Color(0xFF4A5568);  // Borders/dividers
  static const Color navy500 = Color(0xFF718096);  // Disabled text

  // Enhanced Copper Palette (6 variants)
  static const Color copper900 = Color(0xFF7C2D12);  // Deep accent
  static const Color copper800 = Color(0xFF92400E);  // Primary accent
  static const Color copper700 = Color(0xFFB45309);  // Standard accent
  static const Color copper600 = Color(0xFFD97706);  // Light accent
  static const Color copper500 = Color(0xFFF59E0B);  // Bright accent
  static const Color copper400 = Color(0xFFFCD34D);  // Highlight accent

  // Semantic Colors
  static const Color success900 = Color(0xFF064E3B);  // Deep success
  static const Color success700 = Color(0xFF047857);  // Primary success
  static const Color success500 = Color(0xFF10B981);  // Bright success
  static const Color success100 = Color(0xFFD1FAE5);  // Success background

  static const Color warning900 = Color(0xFF78350F);  // Deep warning
  static const Color warning700 = Color(0xFFB45309);  // Primary warning
  static const Color warning500 = Color(0xFFF59E0B);  // Bright warning
  static const Color warning100 = Color(0xFFFEF3C7);  // Warning background

  static const Color error900 = Color(0xFF7F1D1D);    // Deep error
  static const Color error700 = Color(0xFFB91C1C);    // Primary error
  static const Color error500 = Color(0xFFEF4444);    // Bright error
  static const Color error100 = Color(0xFFFEE2E2);    // Error background

  static const Color info900 = Color(0xFF1E3A8A);     // Deep info
  static const Color info700 = Color(0xFF2563EB);     // Primary info
  static const Color info500 = Color(0xFF3B82F6);     // Bright info
  static const Color info100 = Color(0xFFDBEAFE);     // Info background

  // Surface Colors
  static const Color background = Color(0xFF0F1419);      // Deepest layer
  static const Color surfaceLow = Color(0xFF1A202C);      // Low elevation
  static const Color surfaceMid = Color(0xFF2D3748);      // Medium elevation
  static const Color surfaceHigh = Color(0xFF374151);     // High elevation

  // Glass Morphism Effects
  static const Color glassSurface = Color(0x1A2D3748);    // Semi-transparent
  static const Color glassBorder = Color(0x334A5568);     // Border overlay

  // Circuit Pattern Overlay
  static const Color circuitBase = Color(0x0D1A202C);     // Circuit base
  static const Color circuitAccent = Color(0x1AB45309);   // Circuit accent
  static const Color circuitGlow = Color(0x33F59E0B);     // Circuit glow

  // Gradient Definitions
  static const LinearGradient primaryBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy900, navy800, navy900],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient surfaceElevation = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy700, navy800],
  );

  static const LinearGradient copperAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [copper800, copper600, copper700],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient interactiveHover = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [copper700, copper600, copper700],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success700, success500],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning700, warning500],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error700, error500],
  );

  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [info700, info500],
  );

  // Special Effect Gradients
  static const RadialGradient electricalGlow = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [copper400, copper600, Color(0x007C2D12)],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient circuitOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [circuitBase, circuitAccent, circuitBase],
    tileMode: TileMode.repeated,
  );

  static const LinearGradient glassMorphism = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassSurface, Color(0x262D3748)],
  );

  // Shadow System
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x4D000000),
      offset: Offset(0, 8),
      blurRadius: 12,
    ),
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> interactive = [
    BoxShadow(
      color: Color(0x33B45309), // Copper tinted shadow
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> electricalGlowShadow = [
    BoxShadow(
      color: Color(0x66F59E0B), // Copper glow
      offset: Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: navy500,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: navy600,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: navy600,
    height: 1.4,
  );

  static const TextStyle accentText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: copper400,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Component Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    gradient: surfaceElevation,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: navy600),
    boxShadow: elevation2,
  );

  static BoxDecoration cardHoverDecoration = BoxDecoration(
    gradient: surfaceElevation,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: copper600),
    boxShadow: elevation3,
  );

  static BoxDecoration primaryButtonDecoration = BoxDecoration(
    gradient: copperAccent,
    borderRadius: BorderRadius.circular(8),
    boxShadow: elevation2,
  );

  static BoxDecoration secondaryButtonDecoration = BoxDecoration(
    color: navy700,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: copper600),
    boxShadow: elevation1,
  );

  static BoxDecoration glassDecoration = BoxDecoration(
    gradient: glassMorphism,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: glassBorder),
    boxShadow: elevation1,
  );

  // Status Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'open':
        return success500;
      case 'pending':
      case 'review':
        return warning500;
      case 'filled':
      case 'closed':
        return info500;
      case 'cancelled':
        return error500;
      default:
        return navy500;
    }
  }

  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'open':
        return successGradient;
      case 'pending':
      case 'review':
        return warningGradient;
      case 'filled':
      case 'closed':
        return infoGradient;
      case 'cancelled':
        return errorGradient;
      default:
        return surfaceElevation;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return error500;
      case 'medium':
      case 'normal':
        return warning500;
      case 'low':
        return info500;
      default:
        return navy500;
    }
  }

  // Interactive States
  static BoxDecoration getButtonDecoration(bool isPrimary, bool isPressed, bool isHovered) {
    if (isPressed) {
      return BoxDecoration(
        color: isPrimary ? copper800 : navy900,
        borderRadius: BorderRadius.circular(8),
        boxShadow: elevation1,
      );
    }

    if (isHovered) {
      return BoxDecoration(
        gradient: isPrimary ? interactiveHover : null,
        color: isPrimary ? null : navy700,
        borderRadius: BorderRadius.circular(8),
        border: isPrimary ? null : Border.all(color: copper600),
        boxShadow: interactive,
      );
    }

    return isPrimary ? primaryButtonDecoration : secondaryButtonDecoration;
  }

  static TextStyle getButtonTextStyle(bool isPrimary, bool isEnabled) {
    return buttonText.copyWith(
      color: isEnabled ? Colors.white : navy600,
    );
  }

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(16));
}