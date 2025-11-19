import 'package:flutter/material.dart';

/// Tailboard-specific theme colors and styles
class TailboardTheme {
  // Background colors
  static const Color backgroundDark = Color(0xFF1A202C);
  static const Color backgroundCard = Color(0xFF2D3748);
  static const Color backgroundLight = Color(0xFF4A5568);

  // Accent colors
  static const Color copper = Color(0xFFB87333);
  static const Color copperLight = Color(0xFFD4A574);
  static const Color copperDark = Color(0xFF8B5A2B);

  // Stat card colors
  static const Color statActive = Color(0xFF4CAF50);
  static const Color statPending = Color(0xFFB87333);
  static const Color statApplied = Color(0xFF2196F3);

  // Text colors
  static const Color textPrimary = Color(0xFFF7FAFC);
  static const Color textSecondary = Color(0xFFA0AEC0);
  static const Color textTertiary = Color(0xFF718096);

  // Border and divider colors
  static const Color border = Color(0xFF4A5568);
  static const Color divider = Color(0xFF2D3748);

  // Status colors
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFF56565);
  static const Color warning = Color(0xFFED8936);
  static const Color info = Color(0xFF4299E1);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 999.0;

  // Shadows
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Text styles
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get labelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get labelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    fontFamily: 'Plus Jakarta Sans',
  );

  static TextStyle get labelSmall => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: textTertiary,
    fontFamily: 'Plus Jakarta Sans',
  );

  // Button styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: copper,
    foregroundColor: textPrimary,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusL),
    ),
    elevation: 2,
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: copper,
    side: const BorderSide(color: copper, width: 2),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusL),
    ),
  );

  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: copper,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingM,
      vertical: spacingS,
    ),
  );

  // Input decoration
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundCard,
      hintStyle: bodyMedium.copyWith(color: textTertiary),
      labelStyle: bodyMedium.copyWith(color: textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: TailboardTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: TailboardTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: copper, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? backgroundCard,
      borderRadius: BorderRadius.circular(radiusL),
      boxShadow: shadows ?? shadowMedium,
      border: border,
    );
  }

  // Stat card decoration
  static BoxDecoration statCardDecoration(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(radiusL),
      border: Border.all(
        color: color.withValues(alpha: 0.3),
        width: 2,
      ),
    );
  }
}
