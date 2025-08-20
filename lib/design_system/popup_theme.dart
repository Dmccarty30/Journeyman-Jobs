import 'package:flutter/material.dart';
import 'app_theme.dart';

/// PopupTheme widget provides consistent theming across all popup implementations
/// Based on the specification in docs/design_system/popup_theme_specification.md
class PopupTheme extends InheritedWidget {
  
  const PopupTheme({
    required this.data, required super.child, super.key,
  });
  final PopupThemeData data;
  
  /// Access the PopupThemeData from the widget tree
  static PopupThemeData of(BuildContext context) {
    final PopupTheme? theme = 
        context.dependOnInheritedWidgetOfExactType<PopupTheme>();
    return theme?.data ?? PopupThemeData.standard();
  }
  
  @override
  bool updateShouldNotify(PopupTheme oldWidget) => data != oldWidget.data;
}

/// PopupThemeData contains all styling configuration for popups
/// Uses exclusively AppTheme constants - no hardcoded values
class PopupThemeData {
  
  const PopupThemeData({
    required this.elevation,
    required this.borderRadius,
    required this.borderColor,
    required this.backgroundColor,
    required this.padding,
    this.borderWidth = AppTheme.borderWidthThin,
    this.shadows = const <BoxShadow>[],
    this.barrierColor,
    this.maxWidth,
    this.maxHeight,
  });

  /// Standard popup theme - fallback for when no theme is provided
  factory PopupThemeData.standard() => const PopupThemeData(
    elevation: 2,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );

  /// AlertDialog theme for critical user decisions and confirmations
  /// Elevation: 4, Copper border, Large padding
  factory PopupThemeData.alertDialog() => PopupThemeData(
    elevation: 4,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: const EdgeInsets.all(AppTheme.spacingLg),
    shadows: const <BoxShadow>[AppTheme.shadowMd],
    barrierColor: AppTheme.black.withOpacity(0.5),
  );

  /// BottomSheet theme for content selection, forms, and filters
  /// Elevation: 8, Top radius only, Extra top padding for drag handle
  factory PopupThemeData.bottomSheet() => const PopupThemeData(
    elevation: 8,
    borderRadius: AppTheme.radiusXl,
    borderColor: Colors.transparent,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.fromLTRB(
      AppTheme.spacingLg,    // left: 24.0
      AppTheme.spacingXl,    // top: 32.0 (includes drag handle space)
      AppTheme.spacingLg,    // right: 24.0
      AppTheme.spacingLg,    // bottom: 24.0
    ),
    shadows: <BoxShadow>[AppTheme.shadowLg],
    borderWidth: 0,
  );

  /// Custom popup theme for tooltips and contextual information
  /// Matches LocalCard styling exactly - Elevation: 2, Copper border
  factory PopupThemeData.customPopup() => const PopupThemeData(
    elevation: 2,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );

  /// SnackBar theme for transient messages and notifications
  /// Navy background, white text, minimal elevation
  factory PopupThemeData.snackBar() => const PopupThemeData(
    elevation: 1,
    borderRadius: AppTheme.radiusMd,
    borderColor: Colors.transparent,
    backgroundColor: AppTheme.primaryNavy,
    padding: EdgeInsets.symmetric(
      horizontal: AppTheme.spacingMd,
      vertical: AppTheme.spacingSm,
    ),
    shadows: <BoxShadow>[AppTheme.shadowXs],
    borderWidth: 0,
  );

  /// Modal theme for full-screen or large content displays
  /// Highest elevation, optional max dimensions
  factory PopupThemeData.modal() => const PopupThemeData(
    elevation: 8,
    borderRadius: AppTheme.radiusXl,
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingXl),
    shadows: <BoxShadow>[AppTheme.shadowLg],
    maxWidth: 600,
    maxHeight: 800,
  );

  /// Toast theme for brief, non-intrusive notifications
  /// Copper accent, rounded corners, auto-dismiss behavior
  factory PopupThemeData.toast() => PopupThemeData(
    elevation: 2,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingMd,
      vertical: AppTheme.spacingSm,
    ),
    shadows: const <BoxShadow>[AppTheme.shadowSm],
    barrierColor: Colors.transparent,
  );

  /// Dropdown theme for menu selections and options
  /// Minimal elevation, compact padding
  factory PopupThemeData.dropdown() => const PopupThemeData(
    elevation: 1,
    borderRadius: AppTheme.radiusMd,
    borderColor: AppTheme.neutralGray300,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.symmetric(
      horizontal: AppTheme.spacingSm,
      vertical: AppTheme.spacingXs,
    ),
    shadows: <BoxShadow>[AppTheme.shadowXs],
  );

  /// Tooltip theme for contextual help and information
  /// Dark background for contrast, small padding
  factory PopupThemeData.tooltip() => const PopupThemeData(
    elevation: 1,
    borderRadius: AppTheme.radiusSm,
    borderColor: Colors.transparent,
    backgroundColor: AppTheme.secondaryNavy,
    padding: EdgeInsets.all(AppTheme.spacingXs),
    shadows: <BoxShadow>[AppTheme.shadowXs],
    borderWidth: 0,
  );

  /// Primary color popup variant - Navy theme
  factory PopupThemeData.primary() => const PopupThemeData(
    elevation: 3,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.primaryNavy,
    backgroundColor: AppTheme.primaryNavy,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowMd],
  );

  /// Success state popup - Green accent
  factory PopupThemeData.success() => const PopupThemeData(
    elevation: 2,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.successGreen,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );

  /// Warning state popup - Orange accent
  factory PopupThemeData.warning() => const PopupThemeData(
    elevation: 2,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.warningOrange,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );

  /// Error state popup - Red accent
  factory PopupThemeData.error() => const PopupThemeData(
    elevation: 2,
    borderRadius: AppTheme.radiusLg,
    borderColor: AppTheme.errorRed,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );

  /// Memoization-friendly equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PopupThemeData &&
          runtimeType == other.runtimeType &&
          elevation == other.elevation &&
          borderRadius == other.borderRadius &&
          borderColor == other.borderColor &&
          backgroundColor == other.backgroundColor &&
          padding == other.padding &&
          borderWidth == other.borderWidth &&
          barrierColor == other.barrierColor &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight;

  @override
  int get hashCode => Object.hash(
        elevation,
        borderRadius,
        borderColor,
        backgroundColor,
        padding,
        borderWidth,
        barrierColor,
        maxWidth,
        maxHeight,
      );

  /// Creates a copy with optional overrides
  PopupThemeData copyWith({
    double? elevation,
    BorderRadius? borderRadius,
    Color? borderColor,
    Color? backgroundColor,
    EdgeInsets? padding,
    double? borderWidth,
    List<BoxShadow>? shadows,
    Color? barrierColor,
    double? maxWidth,
    double? maxHeight,
  }) => PopupThemeData(
    elevation: elevation ?? this.elevation,
    borderRadius: borderRadius ?? this.borderRadius,
    borderColor: borderColor ?? this.borderColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    padding: padding ?? this.padding,
    borderWidth: borderWidth ?? this.borderWidth,
    shadows: shadows ?? this.shadows,
    barrierColor: barrierColor ?? this.barrierColor,
    maxWidth: maxWidth ?? this.maxWidth,
    maxHeight: maxHeight ?? this.maxHeight,
  );

  final double elevation;
  final BorderRadius borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final Color? barrierColor;
  final double? maxWidth;
  final double? maxHeight;
}

/// Extension for easier popup theming application
extension PopupThemeExtension on BuildContext {
  /// Quick access to popup theme data
  PopupThemeData get popupTheme => PopupTheme.of(this);
  
  /// Show styled dialog with popup theme
  Future<T?> showThemedDialog<T>({
    required Widget Function(BuildContext) builder,
    PopupThemeData? theme,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: this,
    barrierDismissible: barrierDismissible,
    barrierColor: (theme ?? popupTheme).barrierColor,
    builder: (BuildContext context) => Dialog(
      elevation: (theme ?? popupTheme).elevation,
      shape: RoundedRectangleBorder(
        borderRadius: (theme ?? popupTheme).borderRadius,
        side: BorderSide(
          color: (theme ?? popupTheme).borderColor,
          width: (theme ?? popupTheme).borderWidth,
        ),
      ),
      backgroundColor: (theme ?? popupTheme).backgroundColor,
      child: Padding(
        padding: (theme ?? popupTheme).padding,
        child: builder(context),
      ),
    ),
  );
}