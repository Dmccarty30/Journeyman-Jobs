import "package:flutter/material.dart";

/// Simple adaptive theme for TailboardScreen
class AdaptiveTailboardTheme {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Light mode colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightSecondaryText = Color(0xFF94A3B8);
  static const Color lightCopper = Color(0xFFF59E0B);

  // Dark mode colors  
  static const Color darkBg = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A202C);
  static const Color darkBorder = Color(0xFF4A5568);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Color(0xFF718096);
  static const Color darkCopper = Color(0xFFFCD34D);

  // Adaptive getters
  static Color getBackground(BuildContext context) => 
      isDarkMode(context) ? darkBg : lightBg;
      
  static Color getSurface(BuildContext context) => 
      isDarkMode(context) ? darkSurface : lightSurface;
      
  static Color getBorder(BuildContext context) => 
      isDarkMode(context) ? darkBorder : lightBorder;
      
  static Color getText(BuildContext context) => 
      isDarkMode(context) ? darkText : lightText;
      
  static Color getSecondaryText(BuildContext context) => 
      isDarkMode(context) ? darkSecondaryText : lightSecondaryText;
      
  static Color getCopper(BuildContext context) => 
      isDarkMode(context) ? darkCopper : lightCopper;

  // Adaptive gradient
  static LinearGradient getBackgroundGradient(BuildContext context) {
    if (isDarkMode(context)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F1419), Color(0xFF1A202C), Color(0xFF0F1419)],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFF8FAFC)],
      );
    }
  }

  // Adaptive decoration
  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: getSurface(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: getBorder(context)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode(context) ? 0.3 : 0.1),
          offset: const Offset(0, 4),
          blurRadius: 6,
        ),
      ],
    );
  }

  // Adaptive text styles
  static TextStyle getHeadingStyle(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: getText(context),
      height: 1.3,
    );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: getSecondaryText(context),
      height: 1.4,
    );
  }

  static TextStyle getAccentStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: getCopper(context),
      height: 1.4,
    );
  }
}
