import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../electrical_components/circuit_board_background.dart' show ComponentDensity;
import 'theme_extensions.dart';
import 'app_theme_dark.dart';

/// Comprehensive electrical-themed design system for JJElectricalComponents
/// Provides consistent theming across all electrical circuit-inspired UI components
/// including toasts, snackbars, and interactive elements with copper accents
class AppTheme {
  // =================== COLORS ===================
  
  // Primary Colors
  static const Color primaryNavy = Color(0xFF1A202C);
  static const Color accentCopper = Color(0xFFB45309);
  
  // Secondary Colors
  static const Color secondaryNavy = Color(0xFF2D3748);
  static const Color secondaryCopper = Color(0xFFD69E2E);
  
  // Dark Mode Theme Colors (Phase 1.1)
  static const Color darkBackground = Color(0xFF1A202C);
  static const Color darkSurface = Color(0xFF2D3748);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  static const Color darkTextLight = Color(0xFF9CA3AF);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF4A5568);
  static const Color mediumGray = Color(0xFF718096);
  static const Color lightGray = Color(0xFFE2E8F0);
  static const Color offWhite = Color(0xFFF7FAFC);
  static const Color neutralGray300 = Color(0xFFD1D5DB);

  // Border Colors
  static const Color borderLight = lightGray;
  static const Color borderCopper = accentCopper;
  static const Color borderCopperLight = secondaryCopper;
  
  // =================== BORDER WIDTHS ===================

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthThick = 2.0;
  static const double borderWidthCopper = 2.5;
  static const double borderWidthCopperThin = 1.25;
  
  // Status Colors
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningYellow = Color(0xFFD69E2E);
  static const Color warningOrange = Color(0xFFED8936);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color error = Color(0xFFE53E3E); // Alias for errorRed
  static const Color infoBlue = Color(0xFF3182CE);

  // Electrical Colors
  static const Color groundBrown = Color(0xFF8B4513);
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF7FAFC);
  static const Color dividerColor = Color(0xFFD1D5DB);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textMuted = Color(0xFF9CA3AF); // Muted gray for secondary text elements
  static const Color textDark = Color(0xFF1A202C); // Same as textPrimary
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  // =================== GRADIENTS ===================
  
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB45309), // Copper
      Color(0xFF1A202C), // Navy
    ],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFB45309), // Copper
      Color(0xFFD69E2E), // Light Copper
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF7FAFC),
    ],
  );

  static const LinearGradient electricalGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFB45309), // Copper
      Color(0xFFD69E2E), // Light Copper
    ],
  );
  
  // =================== SPACING ===================
  
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingXxxl = 64.0;
  
  // =================== BORDER RADIUS ===================
  
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusRound = 50.0;
  
  // JJElectricalComponents Border Radius
  static const double radiusElectricalToast = 12.0;
  static const double radiusElectricalSnackBar = 8.0;
  static const double radiusElectricalTooltip = 8.0;
  
  // JJElectricalComponents Icon Sizes
  static const double iconElectricalToast = 16.0;
  static const double iconElectricalSnackBar = 14.0;
  static const double iconElectricalTooltip = 12.0;
  
  // JJElectricalComponents Opacity Values
  static const double opacityElectricalBackground = 0.95;
  static const double opacityElectricalCircuitTrace = 0.1;
  static const double opacityElectricalCircuitTraceLight = 0.2;
  static const double opacityElectricalGlow = 0.3;
  static const double opacityElectricalGlowMax = 0.8;
  
  // =================== JJElectricalComponents COLORS ===================
  
  // Electrical Component Backgrounds (high density circuit backgrounds)
  static const Color electricalBackground = Color(0xFF1A202C); // Dark navy with circuit pattern
  static const Color electricalSurface = Color(0xFF2D3748); // Secondary navy for components
  static const Color electricalCircuitTrace = Color(0xFFB45309); // Copper for circuit traces
  static const Color electricalCircuitTraceLight = Color(0xFFD69E2E); // Light copper for traces
  
  // JJElectricalComponents Notification Colors
  static const Color electricalSuccess = Color(0xFF10B981); // Green power indicator
  static const Color electricalWarning = Color(0xFFFFD700); // Yellow caution
  static const Color electricalError = Color(0xFFDC2626); // Red danger
  static const Color electricalInfo = Color(0xFF00D4FF); // Blue electrical flow
  
  // JJElectricalComponents Glow Effects
  static const Color electricalGlowSuccess = Color(0xFF10B981);
  static const Color electricalGlowWarning = Color(0xFFFFD700);
  static const Color electricalGlowError = Color(0xFFDC2626);
  static const Color electricalGlowInfo = Color(0xFF00D4FF);
  
  // =================== SHADOWS ===================

  static const BoxShadow shadowXs = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowSm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );
  
  static const BoxShadow shadowMd = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow shadowLg = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
  
  // JJElectricalComponents Shadows
  static const BoxShadow shadowElectricalSuccess = BoxShadow(
    color: Color(0x3F10B981),
    blurRadius: 15,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow shadowElectricalWarning = BoxShadow(
    color: Color(0x3FFFFD700),
    blurRadius: 15,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow shadowElectricalError = BoxShadow(
    color: Color(0x3FDC2626),
    blurRadius: 15,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow shadowElectricalInfo = BoxShadow(
    color: Color(0x3F00D4FF),
    blurRadius: 15,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );
  
  // =================== ICON SIZES ===================
  
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 28.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 40.0;
  
  // =================== JJElectricalComponents ANIMATION DURATIONS ===================
  
  static const Duration durationElectricalToast = Duration(seconds: 3);
  static const Duration durationElectricalSnackBar = Duration(seconds: 4);
  static const Duration durationElectricalGlow = Duration(seconds: 2);
  static const Duration durationElectricalSpark = Duration(milliseconds: 800);
  static const Duration durationElectricalSlide = Duration(milliseconds: 400);
  static const Duration durationElectricalLightning = Duration(milliseconds: 300);
  
  // JJElectricalComponents Animation Curves
  static const Curve curveElectricalSlide = Curves.elasticOut;
  static const Curve curveElectricalGlow = Curves.easeInOut;
  static const Curve curveElectricalSpark = Curves.easeOut;
  static const Curve curveElectricalLightning = Curves.easeOut;
  
  // JJElectricalComponents Specific Theme Configurations
  static const Map<String, dynamic> electricalSuccessTheme = {
    'backgroundColor': electricalBackground,
    'borderColor': electricalSuccess,
    'glowColor': electricalGlowSuccess,
    'shadow': shadowElectricalSuccess,
    'icon': Icons.check_circle,
    'borderRadius': radiusElectricalToast,
    'borderWidth': borderWidthCopper,
    'duration': durationElectricalToast,
    'enableLightning': true,
    'circuitTraceOpacity': opacityElectricalCircuitTrace,
  };
  
  static const Map<String, dynamic> electricalWarningTheme = {
    'backgroundColor': electricalBackground,
    'borderColor': electricalWarning,
    'glowColor': electricalGlowWarning,
    'shadow': shadowElectricalWarning,
    'icon': Icons.warning,
    'borderRadius': radiusElectricalToast,
    'borderWidth': borderWidthCopper,
    'duration': durationElectricalToast,
    'enableLightning': true,
    'circuitTraceOpacity': opacityElectricalCircuitTraceLight,
  };
  
  static const Map<String, dynamic> electricalErrorTheme = {
    'backgroundColor': electricalBackground,
    'borderColor': electricalError,
    'glowColor': electricalGlowError,
    'shadow': shadowElectricalError,
    'icon': Icons.error,
    'borderRadius': radiusElectricalToast,
    'borderWidth': borderWidthCopper,
    'duration': durationElectricalToast,
    'enableLightning': true,
    'circuitTraceOpacity': opacityElectricalCircuitTrace,
  };
  
  static const Map<String, dynamic> electricalInfoTheme = {
    'backgroundColor': electricalBackground,
    'borderColor': electricalInfo,
    'glowColor': electricalGlowInfo,
    'shadow': shadowElectricalInfo,
    'icon': Icons.info,
    'borderRadius': radiusElectricalSnackBar,
    'borderWidth': borderWidthMedium,
    'duration': durationElectricalSnackBar,
    'enableLightning': false,
    'circuitTraceOpacity': opacityElectricalCircuitTraceLight,
  };
  
  // JJElectricalComponents Circuit Board Configuration
  static const Map<String, dynamic> electricalCircuitConfig = {
    'backgroundColor': electricalBackground,
    'circuitTraceColor': electricalCircuitTrace,
    'circuitTraceLightColor': electricalCircuitTraceLight,
    'opacity': 0.12,
    'componentDensity': ComponentDensity.high,
    'enableCurrentFlow': true,
    'enableInteractiveComponents': true,
    'animationSpeed': 2.0,
  };
  
  // =================== TYPOGRAPHY ===================
  
  // Display Styles
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.25,
  );
  
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // Headline Styles
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Title Styles
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body Styles
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  // Label Styles
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  // Button Text Styles
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  
  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  
  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  
  // =================== JJElectricalComponents THEME PROPERTIES ===================
  
  /// Comprehensive theme configuration for JJElectricalComponents
  /// Includes toasts, snackbars, and interactive electrical elements
  static const Map<String, dynamic> electricalTheme = {
    // Background configuration
    'backgroundColor': electricalBackground,
    'surfaceColor': electricalSurface,
    'circuitTraceColor': electricalCircuitTrace,
    'circuitTraceLightColor': electricalCircuitTraceLight,
    
    // Notification colors
    'successColor': electricalSuccess,
    'warningColor': electricalWarning,
    'errorColor': electricalError,
    'infoColor': electricalInfo,
    
    // Glow effects
    'successGlowColor': electricalGlowSuccess,
    'warningGlowColor': electricalGlowWarning,
    'errorGlowColor': electricalGlowError,
    'infoGlowColor': electricalGlowInfo,
    
    // Border configuration
    'borderColor': borderCopper,
    'borderWidth': borderWidthCopper,
    'borderRadius': radiusElectricalToast,
    
    // Shadows
    'successShadow': shadowElectricalSuccess,
    'warningShadow': shadowElectricalWarning,
    'errorShadow': shadowElectricalError,
    'infoShadow': shadowElectricalInfo,
    
    // Animation durations
    'toastDuration': durationElectricalToast,
    'snackBarDuration': durationElectricalSnackBar,
    'glowDuration': durationElectricalGlow,
    'sparkDuration': durationElectricalSpark,
    'slideDuration': durationElectricalSlide,
    'lightningDuration': durationElectricalLightning,
    
    // Component density for circuit backgrounds
    'componentDensity': ComponentDensity.high,
    'enableCurrentFlow': true,
    'enableInteractiveComponents': true,
    'enableLightningEffects': true,
    
    // Opacity values
    'backgroundOpacity': opacityElectricalBackground,
    'circuitTraceOpacity': opacityElectricalCircuitTrace,
    'circuitTraceLightOpacity': opacityElectricalCircuitTraceLight,
    'glowOpacity': opacityElectricalGlow,
    'glowMaxOpacity': opacityElectricalGlowMax,
    
    // Icon sizes
    'toastIconSize': iconElectricalToast,
    'snackBarIconSize': iconElectricalSnackBar,
    'tooltipIconSize': iconElectricalTooltip,
    
    // Animation curves
    'slideCurve': curveElectricalSlide,
    'glowCurve': curveElectricalGlow,
    'sparkCurve': curveElectricalSpark,
    'lightningCurve': curveElectricalLightning,
  };
  
  // =================== THEME DATA ===================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: accentCopper,
        surface: white,
        error: errorRed,
        onPrimary: white,
        onSecondary: white,
        onSurface: textPrimary,
        onError: white,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMedium.copyWith(color: white),
        iconTheme: const IconThemeData(color: white),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCopper,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonMedium,
          elevation: 2,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: const BorderSide(color: primaryNavy, width: borderWidthMedium),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonMedium,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentCopper,
          padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
          textStyle: buttonMedium,
        ),
      ),
      
      // Input Decoration Theme (Phase 1.2: Fixed for light mode readability)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.all(spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentCopper, width: borderWidthThick),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed, width: borderWidthThick),
        ),
        labelStyle: bodyMedium.copyWith(color: textPrimary), // Dark navy for labels (14.8:1)
        hintStyle: bodyMedium.copyWith(color: textLight), // ENHANCED: Medium gray for hints (5.1:1) - better visual hierarchy
        floatingLabelStyle: bodyMedium.copyWith(color: textPrimary), // Ensure floating labels stay dark
        prefixStyle: bodyMedium.copyWith(color: textSecondary), // Prefix text color (7.5:1)
        errorStyle: bodySmall.copyWith(color: errorRed),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: accentCopper, width: borderWidthMedium),
        ),
        margin: const EdgeInsets.all(spacingSm),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        selectedColor: accentCopper,
        labelStyle: labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: accentCopper,
        unselectedItemColor: mediumGray,
        selectedLabelStyle: labelSmall,
        unselectedLabelStyle: labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Text Theme
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
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentCopper,
        linearTrackColor: lightGray,
        circularTrackColor: lightGray,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: darkGray,
        size: iconMd,
      ),

      // Register light-mode theme extensions for electrical components
      extensions: const <ThemeExtension<dynamic>>[
        ElectricalThemeExtension.light,
      ],
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentCopper,
        foregroundColor: white,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        brightness: Brightness.dark,
        primary: primaryNavy,
        secondary: accentCopper,
        surface: darkSurface, // Updated to use new dark mode constants
        error: errorRed,
        onPrimary: white,
        onSecondary: white,
        onSurface: darkTextPrimary, // Updated to use new dark mode constants
        onError: white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground, // Updated to use new dark mode constants
        foregroundColor: darkTextPrimary, // Updated to use new dark mode constants
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMedium.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),

      scaffoldBackgroundColor: darkBackground, // Updated to use new dark mode constants

      cardTheme: CardThemeData(
        color: darkSurface, // Updated to use new dark mode constants
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: accentCopper, width: borderWidthMedium),
        ),
        margin: const EdgeInsets.all(spacingSm),
      ),

      // Input Decoration Theme (Phase 1.2: Fixed for dark mode readability)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface, // Updated to use new dark mode constants
        contentPadding: const EdgeInsets.all(spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentCopper, width: borderWidthThick),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed, width: borderWidthThick),
        ),
        labelStyle: bodyMedium.copyWith(color: darkTextPrimary), // Fixed: Now white/readable in dark mode
        hintStyle: bodyMedium.copyWith(color: darkTextSecondary), // Fixed: Light gray for readability in dark mode
        errorStyle: bodySmall.copyWith(color: errorRed),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCopper,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonMedium,
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary, // Updated to use new dark mode constants
          side: const BorderSide(color: lightGray, width: borderWidthMedium),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: buttonMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentCopper,
          padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
          textStyle: buttonMedium,
        ),
      ),

      extensions: const <ThemeExtension<dynamic>>[
        ElectricalThemeExtension.dark,
      ],

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBackground, // Updated to use new dark mode constants
        selectedItemColor: accentCopper,
        unselectedItemColor: mediumGray,
        selectedLabelStyle: labelSmall,
        unselectedLabelStyle: labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      textTheme: TextTheme(
        displayLarge: displayLarge.copyWith(color: darkTextPrimary), // Updated to use new dark mode constants
        displayMedium: displayMedium.copyWith(color: darkTextPrimary),
        displaySmall: displaySmall.copyWith(color: darkTextPrimary),
        headlineLarge: headlineLarge.copyWith(color: darkTextPrimary),
        headlineMedium: headlineMedium.copyWith(color: darkTextPrimary),
        headlineSmall: headlineSmall.copyWith(color: darkTextPrimary),
        titleLarge: titleLarge.copyWith(color: darkTextPrimary),
        titleMedium: titleMedium.copyWith(color: darkTextPrimary),
        titleSmall: titleSmall.copyWith(color: const Color(0xFF1A202C)),
        bodyLarge: bodyLarge.copyWith(color: darkTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: darkTextPrimary),
        bodySmall: bodySmall.copyWith(color: darkTextPrimary),
        labelLarge: labelLarge.copyWith(color: darkTextSecondary), // Updated to use new dark mode constants
        labelMedium: labelMedium.copyWith(color: darkTextSecondary),
        labelSmall: labelSmall.copyWith(color: darkTextSecondary),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentCopper,
        foregroundColor: white,
        elevation: 4,
      ),
    );
  }

  // Factory-style accessors for parity with AppTheme.light()/AppTheme.dark()
  static ThemeData light() => lightTheme;
  static ThemeData dark() => AppThemeDark.getThemeData();
}