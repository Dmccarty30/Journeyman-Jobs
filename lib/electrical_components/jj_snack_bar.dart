import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

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
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Row(
        children: <Widget>[
          Icon(icon, color: AppTheme.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
            ),
          ),
        ],
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
      backgroundColor: AppTheme.successGreen,
      icon: Icons.check_circle,
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
      backgroundColor: AppTheme.errorRed,
      icon: Icons.error_outline,
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
      backgroundColor: AppTheme.primaryNavy,
      icon: Icons.info_outline,
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
      backgroundColor: Colors.amber,
      icon: Icons.warning_amber,
      duration: duration,
    );
  }
}
