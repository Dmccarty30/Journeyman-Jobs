import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'button_variants.dart';

class JJPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final JJButtonVariant variant;

  const JJPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.variant = JJButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: _getButtonGradient(),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          // Modern shadcn-like shadow for primary action
          BoxShadow(
            color: AppTheme.accentCopper.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppTheme.white,
                      size: AppTheme.iconSm,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                  ],
                  Expanded(
                    child: Text(
                      text,
                      style: AppTheme.buttonMedium.copyWith(color: AppTheme.white),
                      textAlign: TextAlign.center, // Center the text
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get the appropriate gradient based on the button variant
  Gradient _getButtonGradient() {
    switch (variant) {
      case JJButtonVariant.primary:
        return AppTheme.buttonGradient;
      case JJButtonVariant.secondary:
        return LinearGradient(
          colors: [AppTheme.white, AppTheme.white],
        );
      case JJButtonVariant.danger:
        return LinearGradient(
          colors: [AppTheme.errorRed, AppTheme.errorRed.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case JJButtonVariant.outline:
        return LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
    }
  }
}
