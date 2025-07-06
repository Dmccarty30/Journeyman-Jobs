import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../../electrical_components/electrical_components.dart';
import '../illustrations/electrical_illustrations.dart';

// =================== BUTTONS ===================

class JJPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const JJPrimaryButton({
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
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
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
}

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
        border: Border.all(color: AppTheme.primaryNavy, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: AppTheme.white,
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

// =================== TEXT FIELDS ===================

class JJTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const JJTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.textLight)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: AppTheme.textLight),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// =================== CARDS ===================

class JJCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const JJCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

// =================== LOADING INDICATORS ===================

class JJLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const JJLoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElectricalIllustrationWidget(
            illustration: ElectricalIllustration.circuitBoard,
            width: 60,
            height: 60,
            color: color ?? AppTheme.accentCopper,
            animate: true,
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Electrical Three-Phase Loading Indicator
/// Uses the three-phase sine wave loader with AppTheme colors
class JJElectricalLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final String? message;
  final Duration? duration;

  const JJElectricalLoader({
    super.key,
    this.width,
    this.height,
    this.message,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width ?? 200,
            height: height ?? 60,
            child: ThreePhaseSineWaveLoader(
              width: width ?? 200,
              height: height ?? 60,
              duration: duration ?? const Duration(seconds: 2),
              primaryColor: AppTheme.accentCopper,
              secondaryColor: AppTheme.primaryNavy,
              tertiaryColor: AppTheme.successGreen,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Electrical Power Line Loading Indicator
/// Uses the power line loader with AppTheme colors
class JJPowerLineLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final String? message;
  final Duration? duration;

  const JJPowerLineLoader({
    super.key,
    this.width,
    this.height,
    this.message,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width ?? 300,
            height: height ?? 80,
            child: PowerLineLoader(
              width: width ?? 300,
              height: height ?? 80,
              duration: duration ?? const Duration(seconds: 3),
              pulseColor: AppTheme.accentCopper,
              lineColor: AppTheme.primaryNavy,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// =================== PROGRESS INDICATOR ===================

class JJProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;

  const JJProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? AppTheme.spacingSm : 0,
            ),
            height: 4,
            decoration: BoxDecoration(
              color: isActive || isCurrent
                  ? activeColor ?? AppTheme.accentCopper
                  : inactiveColor ?? AppTheme.lightGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
          ),
        );
      }),
    );
  }
}

// =================== CHIPS ===================

class JJChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const JJChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor ?? AppTheme.accentCopper
                : unselectedColor ?? AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            border: isSelected
                ? null
                : Border.all(color: AppTheme.mediumGray, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppTheme.iconXs,
                  color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSm),
              ],
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== EMPTY STATE ===================

class JJEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final ElectricalIllustration? illustration;
  final String? context;
  final Widget? action;

  const JJEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.illustration,
    this.context,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which illustration to show
    final displayIllustration = illustration ??
        (this.context != null ? IllustrationHelper.getEmptyStateIllustration(this.context!) : null);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displayIllustration != null) ...[
              ElectricalIllustrationWidget(
                illustration: displayIllustration,
                width: 120,
                height: 120,
                animate: true,
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: AppTheme.iconXxl + 16,
                color: AppTheme.textLight,
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            Text(
              title,
              style: AppTheme.headlineSmall.copyWith(color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                subtitle!,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// =================== BOTTOM SHEET ===================

class JJBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? headerAction;
  final double? initialChildSize;
  final double? maxChildSize;
  final double? minChildSize;

  const JJBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.headerAction,
    this.initialChildSize,
    this.maxChildSize,
    this.minChildSize,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? headerAction,
    double? initialChildSize,
    double? maxChildSize,
    double? minChildSize,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JJBottomSheet(
        title: title,
        headerAction: headerAction,
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        minChildSize: minChildSize,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize ?? 0.5,
      maxChildSize: maxChildSize ?? 0.9,
      minChildSize: minChildSize ?? 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.headlineSmall,
                      ),
                    ),
                    if (headerAction != null) headerAction!,
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =================== SOCIAL SIGN IN BUTTON ===================

class JJSocialSignInButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const JJSocialSignInButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: AppTheme.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.textSecondary,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  icon,
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    text,
                    style: AppTheme.buttonMedium.copyWith(color: AppTheme.textPrimary),
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

// =================== SNACKBAR HELPER ===================

class JJSnackBar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: ElectricalIllustrationWidget(
                illustration: ElectricalIllustration.success,
                width: 24,
                height: 24,
                color: AppTheme.white,
                animate: false,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: AppTheme.white),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: AppTheme.white),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryNavy,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}

// =================== ELECTRICAL COMPONENTS EXPORTS ===================

/// Electrical Circuit Breaker Toggle
/// Themed toggle switch that looks like an electrical circuit breaker
class JJElectricalToggle extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;

  const JJElectricalToggle({
    super.key,
    required this.isOn,
    this.onChanged,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CircuitBreakerToggle(
      isOn: isOn,
      onChanged: onChanged,
      width: width ?? 80,
      height: height ?? 40,
      onColor: AppTheme.successGreen,
      offColor: AppTheme.mediumGray,
    );
  }
}

/// Electrical Industry Icons
/// Themed icons for electrical/industrial applications
class JJElectricalIcons {
  static Widget hardHat({
    double size = 24,
    Color? color,
  }) {
    return HardHatIcon(
      size: size,
      color: color ?? AppTheme.primaryNavy,
    );
  }

  static Widget transmissionTower({
    double size = 24,
    Color? color,
  }) {
    return TransmissionTowerIcon(
      size: size,
      color: color ?? AppTheme.primaryNavy,
    );
  }
}

// =================== ELECTRICAL DIALOGS ===================

class JJElectricalDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ElectricalIllustration illustration;
  final Color? illustrationColor;
  final Widget? content;
  final List<Widget>? actions;
  final bool dismissible;

  const JJElectricalDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.illustration,
    this.illustrationColor,
    this.content,
    this.actions,
    this.dismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required ElectricalIllustration illustration,
    Color? illustrationColor,
    Widget? content,
    List<Widget>? actions,
    bool dismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => JJElectricalDialog(
        title: title,
        subtitle: subtitle,
        illustration: illustration,
        illustrationColor: illustrationColor,
        content: content,
        actions: actions,
        dismissible: dismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      contentPadding: const EdgeInsets.all(AppTheme.spacingLg),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Electrical illustration
          ElectricalIllustrationWidget(
            illustration: illustration,
            width: 80,
            height: 80,
            color: illustrationColor ?? AppTheme.accentCopper,
            animate: true,
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Title
          Text(
            title,
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
            textAlign: TextAlign.center,
          ),

          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              subtitle!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Content
          if (content != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            content!,
          ],
        ],
      ),
      actions: actions,
    );
  }
}