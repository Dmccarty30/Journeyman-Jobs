import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../popup_theme.dart';

/// JJ Dialog - Standardized dialog component following TODO.md requirements
/// - Consistent font sizing (increased by 2 from base)
/// - Copper border styling from PopupTheme
/// - No colored text except icons
/// - Electrical theme consistency
class JJDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final PopupThemeData? theme;
  final IconData? titleIcon;
  final bool barrierDismissible;

  const JJDialog({
    Key? key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.theme,
    this.titleIcon,
    this.barrierDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popupTheme = theme ?? PopupThemeData.alertDialog();

    return Dialog(
      elevation: popupTheme.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: popupTheme.borderRadius,
        side: BorderSide(
          color: popupTheme.borderColor,
          width: popupTheme.borderWidth,
        ),
      ),
      backgroundColor: popupTheme.backgroundColor,
      child: Padding(
        padding: popupTheme.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section with optional icon
            Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(
                    titleIcon,
                    color: AppTheme.accentCopper,
                    size: AppTheme.iconMd,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: AppTheme.titleLarge.fontSize! + 2, // Font size +2 as required
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary, // No colored text
                    ),
                  ),
                ),
              ],
            ),

            if (message != null || content != null) ...[
              const SizedBox(height: AppTheme.spacingMd),

              // Message or custom content
              if (content != null)
                content!
              else if (message != null)
                Text(
                  message!,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: AppTheme.bodyMedium.fontSize! + 2, // Font size +2 as required
                    color: AppTheme.textSecondary, // No colored text
                  ),
                ),
            ],

            // Actions section
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show JJ Dialog with consistent theming
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    PopupThemeData? theme,
    IconData? titleIcon,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: (theme ?? PopupThemeData.alertDialog()).barrierColor,
      builder: (BuildContext context) => JJDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        theme: theme,
        titleIcon: titleIcon,
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}

/// JJ Dialog Actions - Pre-styled action buttons for dialogs
class JJDialogActions {
  /// Standard Cancel button
  static Widget cancel(BuildContext context, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textSecondary, // No colored text
      ),
      child: Text(
        'Cancel',
        style: AppTheme.buttonMedium.copyWith(
          fontSize: AppTheme.buttonMedium.fontSize! + 2, // Font size +2
        ),
      ),
    );
  }

  /// Standard Confirm button
  static Widget confirm(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentCopper,
        foregroundColor: AppTheme.white,
      ),
      child: Text(
        text,
        style: AppTheme.buttonMedium.copyWith(
          fontSize: AppTheme.buttonMedium.fontSize! + 2, // Font size +2
        ),
      ),
    );
  }

  /// Danger/Warning action button
  static Widget danger(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.errorRed,
        foregroundColor: AppTheme.white,
      ),
      child: Text(
        text,
        style: AppTheme.buttonMedium.copyWith(
          fontSize: AppTheme.buttonMedium.fontSize! + 2, // Font size +2
        ),
      ),
    );
  }
}

/// JJ Bottom Sheet - Standardized bottom sheet component
class JJBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final PopupThemeData? theme;

  const JJBottomSheet({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popupTheme = theme ?? PopupThemeData.bottomSheet();

    return Container(
      decoration: BoxDecoration(
        color: popupTheme.backgroundColor,
        borderRadius: popupTheme.borderRadius,
        border: Border.all(
          color: popupTheme.borderColor,
          width: popupTheme.borderWidth,
        ),
      ),
      child: Padding(
        padding: popupTheme.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Title
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                fontSize: AppTheme.titleLarge.fontSize! + 2, // Font size +2
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary, // No colored text
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Content
            content,

            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// Show JJ Bottom Sheet with consistent theming
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    PopupThemeData? theme,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) => JJBottomSheet(
        title: title,
        content: content,
        actions: actions,
        theme: theme,
      ),
    );
  }
}