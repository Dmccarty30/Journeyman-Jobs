import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

enum JJButtonVariant { primary, secondary, outline, danger }

enum JJButtonSize { small, medium, large }

class JJButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final JJButtonVariant variant;
  final JJButtonSize size;

  const JJButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = JJButtonVariant.primary,
    this.size = JJButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      width: isFullWidth ? double.infinity : null,
      height: dimensions.height,
      decoration: _getDecoration(colors),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.padding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: dimensions.iconSize,
                    height: dimensions.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon,
                      size: dimensions.iconSize, color: colors.textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: dimensions.textStyle.copyWith(color: colors.textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case JJButtonSize.small:
        return _ButtonDimensions(
          height: 36,
          padding: 12,
          iconSize: 16,
          textStyle: AppTheme.labelSmall,
        );
      case JJButtonSize.medium:
        return _ButtonDimensions(
          height: 48,
          padding: 20,
          iconSize: 20,
          textStyle: AppTheme.buttonMedium,
        );
      case JJButtonSize.large:
        return _ButtonDimensions(
          height: 56,
          padding: 24,
          iconSize: 24,
          textStyle: AppTheme.buttonLarge,
        );
    }
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case JJButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: AppTheme.primaryNavy,
          textColor: Colors.white,
        );
      case JJButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: AppTheme.white,
          textColor: AppTheme.textPrimary,
          borderColor: AppTheme.lightGray,
        );
      case JJButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: AppTheme.primaryNavy,
          borderColor: AppTheme.primaryNavy,
        );
      case JJButtonVariant.danger:
        return _ButtonColors(
          backgroundColor: AppTheme.errorRed,
          textColor: Colors.white,
        );
    }
  }

  BoxDecoration _getDecoration(_ButtonColors colors) {
    return BoxDecoration(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: colors.borderColor != null
          ? Border.all(color: colors.borderColor!, width: 1.5)
          : null,
      boxShadow: variant == JJButtonVariant.primary
          ? [
              BoxShadow(
                color: AppTheme.primaryNavy.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
          : null,
    );
  }
}

class _ButtonDimensions {
  final double height;
  final double padding;
  final double iconSize;
  final TextStyle textStyle;

  _ButtonDimensions({
    required this.height,
    required this.padding,
    required this.iconSize,
    required this.textStyle,
  });
}

class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
}
