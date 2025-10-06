import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import 'circuit_board_background.dart';

/// Simple, project-wide snack bar helper used by multiple screens.
/// Provides consistent styling and three convenience methods:
/// - showInfo
/// - showSuccess
/// - showError
///
/// These methods mirror existing call-sites that use named params:
/// `JJSnackBar.showSuccess(context: context, message: '...');`
class JJSnackBar {
  static void _show(
    BuildContext context, {
    required String message,
    required Color borderColor,
    required IconData icon,
    required String type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusElectricalSnackBar),
      ),
      content: Container(
        decoration: BoxDecoration(
          color: AppTheme.electricalBackground.withValues(alpha: AppTheme.opacityElectricalBackground),
          borderRadius: BorderRadius.circular(AppTheme.radiusElectricalSnackBar),
          border: Border.all(
            color: borderColor,
            width: AppTheme.borderWidthCopper,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: AppTheme.opacityElectricalGlow),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Circuit board background
            Positioned.fill(
              child: ElectricalCircuitBackground(
                opacity: 0.08,
                componentDensity: ComponentDensity.high,
                enableCurrentFlow: true,
                enableInteractiveComponents: true,
                traceColor: AppTheme.electricalBackground,
                currentColor: borderColor,
                copperColor: AppTheme.accentCopper,
              ),
            ),
            // Content
            Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppTheme.iconElectricalSnackBar,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textOnDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Use ScaffoldMessenger so it works in dialog contexts too.
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      borderColor: AppTheme.electricalSuccess,
      icon: Icons.check_circle,
      type: 'success',
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      borderColor: AppTheme.electricalError,
      icon: Icons.error_outline,
      type: 'error',
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      borderColor: AppTheme.electricalInfo,
      icon: Icons.info_outline,
      type: 'info',
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      borderColor: AppTheme.electricalWarning,
      icon: Icons.warning_amber,
      type: 'warning',
      duration: duration,
    );
  }
}
