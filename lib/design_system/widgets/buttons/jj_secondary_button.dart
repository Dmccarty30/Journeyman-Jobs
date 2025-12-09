import 'package:flutter/material.dart';
import '../../app_theme.dart';

class JJSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const JJSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 56,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2), width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: AppTheme.white,
        boxShadow: [
          // Subtle shadow for secondary action
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                      color: AppTheme.primaryNavy,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppTheme.primaryNavy,
                      size: AppTheme.iconSm,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                  ],
                  Expanded(
                    child: Text(
                      text,
                      style: AppTheme.buttonMedium.copyWith(color: AppTheme.primaryNavy),
                      textAlign: TextAlign.center,
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
}
