import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';

class StormTheme {
  // =================== COLORS ===================
  
  // Storm specific palette
  static const Color stormCloud = Color(0xFF2C3E50);
  static const Color deepStorm = Color(0xFF1F2937);
  static const Color lightningYellow = Color(0xFFFFD700);
  static const Color electricBlue = Color(0xFF00BFFF);
  static const Color rainGrey = Color(0xFF7F8C8D);
  static const Color dangerRed = Color(0xFFE74C3C);
  static const Color safeGreen = Color(0xFF2ECC71);

  // =================== GRADIENTS ===================

  static const LinearGradient stormSurgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepStorm,
      stormCloud,
    ],
  );

  static const LinearGradient electricChargeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      lightningYellow,
      Color(0xFFFFA500), // Orange
    ],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFC0392B),
      dangerRed,
    ],
  );

  // =================== SHADOWS ===================

  static BoxShadow lightningGlow = BoxShadow(
    color: lightningYellow.withOpacity(0.4),
    blurRadius: 10,
    spreadRadius: 1,
  );

  static BoxShadow electricGlow = BoxShadow(
    color: electricBlue.withOpacity(0.4),
    blurRadius: 10,
    spreadRadius: 1,
  );

  // =================== STYLES ===================

  static BoxDecoration stormCardDecoration = BoxDecoration(
    gradient: stormSurgeGradient,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: electricBlue.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration activeStormCardDecoration = BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: lightningYellow,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: lightningYellow.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
