import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';

/// Enhanced page indicator with electrical theming and smooth animations
class WelcomePageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color? activeColor;
  final Color? inactiveColor;

  const WelcomePageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final active = activeColor ?? AppTheme.accentCopper;
    final inactive = inactiveColor ?? 
        (isDarkMode 
            ? AppTheme.lightGray.withValues(alpha: 0.3)
            : AppTheme.lightGray.withValues(alpha: 0.5));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index ? active : inactive,
            borderRadius: BorderRadius.circular(4),
            border: currentPage == index
                ? Border.all(
                    color: active,
                    width: AppTheme.borderWidthCopperThin,
                  )
                : null,
            boxShadow: currentPage == index
                ? [
                    BoxShadow(
                      color: active.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ).animate().scale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut,
        ),
      ),
    );
  }
}
