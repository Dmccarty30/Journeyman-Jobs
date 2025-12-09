import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'button_variants.dart';

/// Universal JJ Button Component
class JJButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final JJButtonVariant variant;
  final JJButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const JJButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.variant = JJButtonVariant.primary,
    this.size = JJButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getButtonDimensions();
    final colors = _getButtonColors();
    
    return Container(
      width: isFullWidth ? double.infinity : (width ?? dimensions.width),
      height: height ?? dimensions.height,
      decoration: _getButtonDecoration(colors),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: dimensions.horizontalPadding,
              vertical: dimensions.verticalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: dimensions.iconSize,
                    height: dimensions.iconSize,
                    child: CircularProgressIndicator(
                      color: colors.textColor,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: colors.textColor,
                      size: dimensions.iconSize,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                  ],
                  Text(
                    text,
                    style: dimensions.textStyle.copyWith(
                      color: colors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonDimensions _getButtonDimensions() {
    switch (size) {
      case JJButtonSize.small:
        return _ButtonDimensions(
          width: null,
          height: 40,
          horizontalPadding: AppTheme.spacingMd,
          verticalPadding: AppTheme.spacingSm,
          iconSize: 16,
          textStyle: AppTheme.labelSmall,
        );
      case JJButtonSize.medium:
        return _ButtonDimensions(
          width: null,
          height: 48,
          horizontalPadding: AppTheme.spacingLg,
          verticalPadding: AppTheme.spacingMd,
          iconSize: 20,
          textStyle: AppTheme.buttonMedium,
        );
      case JJButtonSize.large:
        return _ButtonDimensions(
          width: null,
          height: 56,
          horizontalPadding: AppTheme.spacingXl,
          verticalPadding: AppTheme.spacingLg,
          iconSize: 24,
          textStyle: AppTheme.buttonLarge,
        );
    }
  }

  _ButtonColors _getButtonColors() {
    switch (variant) {
      case JJButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: AppTheme.accentCopper,
          textColor: AppTheme.white,
          borderColor: null,
        );
      case JJButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: AppTheme.lightGray,
          textColor: AppTheme.textPrimary,
          borderColor: null,
        );
      case JJButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: AppTheme.accentCopper,
          borderColor: AppTheme.accentCopper,
        );
      case JJButtonVariant.danger:
        return _ButtonColors(
          backgroundColor: AppTheme.errorRed,
          textColor: AppTheme.white,
          borderColor: null,
        );
    }
  }

  BoxDecoration _getButtonDecoration(_ButtonColors colors) {
    if (variant == JJButtonVariant.primary) {
      return BoxDecoration(
        gradient: AppTheme.electricalGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      );
    }
    
    return BoxDecoration(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: colors.borderColor != null 
        ? Border.all(color: colors.borderColor!, width: 1.5)
        : null,
      boxShadow: variant == JJButtonVariant.outline ? null : [AppTheme.shadowXs],
    );
  }
}

class _ButtonDimensions {
  final double? width;
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final TextStyle textStyle;

  _ButtonDimensions({
    required this.width,
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
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
    required this.borderColor,
  });
}
