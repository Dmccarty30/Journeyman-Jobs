import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'theme_extensions.dart';

/// Dark Theme Configuration for Journeyman Jobs
///
/// This class provides a complete dark mode theme that inverts the light theme
/// while maintaining all the subtle electrical design elements including:
/// - Copper gradient glows and borders
/// - Layered shadows for depth
/// - Animated electrical components
/// - Circuit board backgrounds
class AppThemeDark {
  // =================== BASE COLORS (INVERTED) ===================

  // Primary Dark Colors
  static const Color primaryBackground = Color(0xFF0F1419); // Very dark navy background
  static const Color primarySurface = Color(0xFF1A202C); // Dark navy surface (was light primaryNavy)
  static const Color secondaryBackground = Color(0xFF151B23); // Darker variant
  static const Color secondarySurface = Color(0xFF2D3748); // Elevated surfaces

  // Copper Accents (Brightened for dark mode)
  static const Color accentCopper = Color(0xFFD97706); // Brighter copper for visibility
  static const Color accentCopperLight = Color(0xFFFBBF24); // Light copper accent
  static const Color accentCopperGlow = Color(0xFFFF8C00); // Intense copper glow
  static const Color accentCopperDim = Color(0xFF92400E); // Dimmed copper for subtle effects

  // Navy Variants (Darker)
  static const Color navyDeep = Color(0xFF0A0E14); // Deepest navy
  static const Color navyDark = Color(0xFF1A202C); // Standard dark navy
  static const Color navyMedium = Color(0xFF2D3748); // Medium navy
  static const Color navyLight = Color(0xFF4A5568); // Light navy for contrasts

  // =================== TEXT COLORS (INVERTED) ===================

  static const Color textPrimary = Color(0xFFF7FAFC); // Almost white for primary text
  static const Color textSecondary = Color(0xFFCBD5E1); // Light gray for secondary
  static const Color textTertiary = Color(0xFF94A3B8); // Medium gray for hints
  static const Color textMuted = Color(0xFF64748B); // Muted for disabled
  static const Color textOnAccent = Color(0xFFFFFFFF); // Pure white on accent colors
  static const Color textOnDark = Color(0xFF0F1419); // Dark text for light surfaces

  // =================== BORDER COLORS ===================

  static const Color borderPrimary = Color(0xFF475569); // Medium gray border
  static const Color borderSecondary = Color(0xFF334155); // Subtle border
  static const Color borderCopper = accentCopper; // Copper accent border
  static const Color borderCopperDim = Color(0xFF92400E); // Dimmed copper border
  static const Color borderCopperGlow = accentCopperLight; // Glowing copper border

  // Border Widths (same as light theme)
  static const double borderWidthThin = AppTheme.borderWidthThin;
  static const double borderWidthMedium = AppTheme.borderWidthMedium;
  static const double borderWidthThick = AppTheme.borderWidthThick;
  static const double borderWidthCopper = AppTheme.borderWidthCopper;
  static const double borderWidthCopperThin = AppTheme.borderWidthCopperThin;

  // =================== STATUS COLORS (ADJUSTED) ===================

  static const Color successGreen = Color(0xFF10B981); // Emerald green
  static const Color warningYellow = Color(0xFFF59E0B); // Amber
  static const Color warningOrange = Color(0xFFEA580C); // Orange
  static const Color errorRed = Color(0xFFEF4444); // Bright red
  static const Color infoBlue = Color(0xFF06B6D4); // Cyan

  // =================== ELECTRICAL COLORS ===================

  static const Color electricalGlow = accentCopperGlow; // Main electrical glow
  static const Color electricalTrace = Color(0xFFD97706); // Circuit traces
  static const Color electricalTraceLight = Color(0xFFFBBF24); // Light traces
  static const Color electricalPulse = Color(0xFFFFD700); // Pulse animation color
  static const Color groundBrown = Color(0xFF7C2D12); // Ground wire brown

  // =================== GRADIENTS (DARK MODE) ===================

  /// Main splash gradient - inverted copper to navy
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentCopper,
      navyDeep,
    ],
  );

  /// Button gradient with copper glow
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      accentCopper,
      accentCopperLight,
    ],
  );

  /// Card surface gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primarySurface,
      secondarySurface,
    ],
  );

  /// Tab bar gradients (animated between states)
  static const LinearGradient tabSelectedGradient = LinearGradient(
    colors: [
      accentCopper,
      accentCopperLight,
      navyMedium,
    ],
  );

  static const LinearGradient tabUnselectedGradient = LinearGradient(
    colors: [
      navyMedium,
      navyDark,
      navyDeep,
    ],
  );

  /// Form container gradient with subtle transparency
  static LinearGradient formContainerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primarySurface.withValues(alpha:0.7),
      secondarySurface.withValues(alpha:0.5),
    ],
  );

  // =================== SHADOWS (DARK MODE) ===================

  /// Electrical success shadow with copper glow
  static BoxShadow shadowElectricalSuccess = BoxShadow(
    color: accentCopperGlow.withValues(alpha:0.4),
    blurRadius: 25,
    spreadRadius: 3,
    offset: const Offset(0, 6),
  );

  /// Electrical info shadow with cyan glow
  static BoxShadow shadowElectricalInfo = BoxShadow(
    color: infoBlue.withValues(alpha:0.3),
    blurRadius: 20,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );

  /// Electrical warning shadow with amber glow
  static BoxShadow shadowElectricalWarning = BoxShadow(
    color: warningYellow.withValues(alpha:0.3),
    blurRadius: 18,
    spreadRadius: 1,
    offset: const Offset(0, 3),
  );

  /// Electrical error shadow with red glow
  static BoxShadow shadowElectricalError = BoxShadow(
    color: errorRed.withValues(alpha:0.4),
    blurRadius: 20,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );

  /// Copper glow effect (the special effect mentioned)
  static List<BoxShadow> copperGlowShadows = [
    // Inner glow
    BoxShadow(
      color: accentCopperGlow.withValues(alpha:0.2),
      blurRadius: 8,
      spreadRadius: -2,
    ),
    // Outer copper radiant glow
    BoxShadow(
      color: accentCopper.withValues(alpha:0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    // Deep shadow for depth
    BoxShadow(
      color: Colors.black.withValues(alpha:0.5),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Subtle elevation shadows
  static List<BoxShadow> elevationShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha:0.3),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: accentCopper.withValues(alpha:0.05),
      blurRadius: 12,
      spreadRadius: -4,
    ),
  ];

  // =================== TYPOGRAPHY (DARK MODE) ===================

  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnAccent,
  );

  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textOnAccent,
  );

  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textOnAccent,
  );

  // =================== COMPONENT SPECIFIC STYLES ===================

  /// Back button container decoration (with the copper gradient glow)
  static BoxDecoration backButtonDecoration = BoxDecoration(
    gradient: RadialGradient(
      colors: [
        primarySurface,
        primarySurface.withValues(alpha:0.8),
      ],
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: accentCopper,
      width: borderWidthCopperThin,
    ),
    boxShadow: copperGlowShadows,
  );

  /// Tab bar container decoration
  static BoxDecoration tabBarDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        primarySurface.withValues(alpha:0.6),
        primarySurface.withValues(alpha:0.3),
      ],
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: accentCopper,
      width: borderWidthCopper,
    ),
    boxShadow: [
      shadowElectricalInfo,
      BoxShadow(
        color: accentCopper.withValues(alpha:0.2),
        blurRadius: 15,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Form container decoration
  static BoxDecoration formContainerDecoration = BoxDecoration(
    color: textOnAccent.withValues(alpha:0.05),
    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
    border: Border.all(
      color: accentCopper,
      width: borderWidthCopperThin,
    ),
    boxShadow: [
      shadowElectricalInfo,
      BoxShadow(
        color: navyDeep.withValues(alpha:0.3),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );

  /// Primary button decoration
  static BoxDecoration primaryButtonDecoration = BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: accentCopper,
      width: borderWidthCopper,
    ),
    boxShadow: [shadowElectricalSuccess],
  );

  /// Text field decoration
  static BoxDecoration textFieldDecoration = BoxDecoration(
    color: primarySurface.withValues(alpha:0.5),
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: accentCopper.withValues(alpha:0.5),
      width: borderWidthThin,
    ),
    boxShadow: [
      BoxShadow(
        color: accentCopperGlow.withValues(alpha:0.1),
        blurRadius: 8,
        spreadRadius: -2,
      ),
    ],
  );

  // =================== SPACING (SAME AS LIGHT) ===================

  static const double spacingXs = AppTheme.spacingXs;
  static const double spacingSm = AppTheme.spacingSm;
  static const double spacingMd = AppTheme.spacingMd;
  static const double spacingLg = AppTheme.spacingLg;
  static const double spacingXl = AppTheme.spacingXl;
  static const double spacingXxl = AppTheme.spacingXxl;

  // =================== THEME DATA GENERATOR ===================

  /// Generates a complete dark ThemeData for the app
  static ThemeData getThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: accentCopper,
      colorScheme: const ColorScheme.dark(
        primary: accentCopper,
        secondary: accentCopperLight,
        surface: primarySurface,
        error: errorRed,
        onPrimary: textOnAccent,
        onSecondary: textOnAccent,
        onSurface: textPrimary,
        onError: textOnAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBackground.withValues(alpha:0.9),
        foregroundColor: textPrimary,
        elevation: 0,
        titleTextStyle: headlineMedium,
        iconTheme: const IconThemeData(
          color: textPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),

      // Register dark-mode theme extensions for electrical components
      extensions: const <ThemeExtension<dynamic>>[
        ElectricalThemeExtension.dark,
      ],

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCopper,
          foregroundColor: textOnAccent,
          textStyle: buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: primarySurface.withValues(alpha:0.5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: accentCopper.withValues(alpha:0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: accentCopper.withValues(alpha:0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(
            color: accentCopper,
            width: 2,
          ),
        ),
        labelStyle: labelMedium.copyWith(color: textPrimary), // Updated: Primary text color for labels
        hintStyle: bodyMedium.copyWith(color: textPrimary), // Updated: Primary text color for hints
      ),
      cardTheme: CardThemeData(
        color: primarySurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(
            color: borderSecondary,
            width: borderWidthThin,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderSecondary,
        thickness: borderWidthThin,
      ),
    );
  }
}
