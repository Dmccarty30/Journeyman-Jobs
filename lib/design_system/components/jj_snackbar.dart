import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../popup_theme.dart';

/// JJ SnackBar - Standardized snackbar/toast component following JJ theme
/// - Navy background with white text (PopupTheme.snackBar)
/// - Copper accent elements where appropriate
/// - No colored text except for icons
/// - Electrical theme consistency
/// - Font size +2 as per TODO requirements
class JJSnackBar {
  /// Show success snackbar with JJ theme
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = PopupThemeData.success();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppTheme.successGreen,
              size: AppTheme.iconSm,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2
                  color: AppTheme.textPrimary, // No colored text except icon
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.backgroundColor,
        elevation: theme.elevation,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: theme.borderRadius,
          side: BorderSide(
            color: theme.borderColor,
            width: theme.borderWidth,
          ),
        ),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show error snackbar with JJ theme
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final theme = PopupThemeData.error();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: AppTheme.iconSm,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2
                  color: AppTheme.textPrimary, // No colored text except icon
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.backgroundColor,
        elevation: theme.elevation,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: theme.borderRadius,
          side: BorderSide(
            color: theme.borderColor,
            width: theme.borderWidth,
          ),
        ),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show warning snackbar with JJ theme
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final theme = PopupThemeData.warning();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: AppTheme.warningOrange,
              size: AppTheme.iconSm,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2
                  color: AppTheme.textPrimary, // No colored text except icon
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.backgroundColor,
        elevation: theme.elevation,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: theme.borderRadius,
          side: BorderSide(
            color: theme.borderColor,
            width: theme.borderWidth,
          ),
        ),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show info snackbar with JJ theme
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final theme = PopupThemeData.snackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.accentCopper, // Copper for info icon
              size: AppTheme.iconSm,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2
                  color: AppTheme.white, // White text on navy background
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.backgroundColor, // Navy background
        elevation: theme.elevation,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: theme.borderRadius,
        ),
        duration: duration,
        action: action != null ? SnackBarAction(
          label: action.label,
          onPressed: action.onPressed,
          textColor: AppTheme.accentCopper, // Copper accent for action
        ) : null,
      ),
    );
  }

  /// Show standard snackbar with JJ theme (navy background, white text)
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    final theme = PopupThemeData.snackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppTheme.accentCopper,
                size: AppTheme.iconSm,
              ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2
                  color: AppTheme.white, // White text on navy background
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.backgroundColor, // Navy background
        elevation: theme.elevation,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: theme.borderRadius,
        ),
        duration: duration,
        action: action != null ? SnackBarAction(
          label: action.label,
          onPressed: action.onPressed,
          textColor: AppTheme.accentCopper, // Copper accent for action
        ) : null,
      ),
    );
  }

  /// Show bid now action snackbar (for job bidding functionality)
  static void showBidAction(
    BuildContext context, {
    required String jobTitle,
    required VoidCallback onBidPressed,
    Duration duration = const Duration(seconds: 5),
  }) {
    JJSnackBar.showSuccess(
      context,
      message: 'Ready to bid on: $jobTitle',
      duration: duration,
      action: SnackBarAction(
        label: 'BID NOW',
        onPressed: onBidPressed,
        textColor: AppTheme.accentCopper,
      ),
    );
  }

  /// Show link action snackbar (for local union links, etc.)
  static void showLinkAction(
    BuildContext context, {
    required String linkText,
    required VoidCallback onLinkPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    JJSnackBar.showInfo(
      context,
      message: 'Opening: $linkText',
      duration: duration,
      action: SnackBarAction(
        label: 'OPEN',
        onPressed: onLinkPressed,
        textColor: AppTheme.accentCopper,
      ),
    );
  }
}

/// JJ Toast - Simple toast notifications for brief messages
class JJToast {
  /// Show toast with electrical theme
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
  }) {
    final theme = PopupThemeData.toast();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: theme.padding,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: theme.borderRadius,
              border: Border.all(
                color: theme.borderColor,
                width: theme.borderWidth,
              ),
              boxShadow: theme.shadows,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AppTheme.accentCopper,
                    size: AppTheme.iconSm,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                ],
                Flexible(
                  child: Text(
                    message,
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after duration
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}