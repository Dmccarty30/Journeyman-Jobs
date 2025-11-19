import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'tailboard_theme.dart';

/// Stat card widget for displaying crew statistics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: TailboardTheme.statCardDecoration(color),
        padding: const EdgeInsets.symmetric(
          horizontal: TailboardTheme.spacingM,
          vertical: TailboardTheme.spacingL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TailboardTheme.headingLarge.copyWith(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingXS),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: TailboardTheme.spacingXS),
                Text(
                  label,
                  style: TailboardTheme.bodyMedium.copyWith(
                    color: TailboardTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms);
  }
}

/// Copper-accented loading indicator
class ElectricalLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const ElectricalLoadingIndicator({
    super.key,
    this.message,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                TailboardTheme.copper,
              ),
              strokeWidth: 4.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: TailboardTheme.spacingM),
            Text(
              message!,
              style: TailboardTheme.bodyMedium.copyWith(
                color: TailboardTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: 1500.ms,
      color: TailboardTheme.copper.withValues(alpha: 0.3),
    );
  }
}

/// Empty state widget for tabs with no content
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TailboardTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TailboardTheme.copper.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 60,
                color: TailboardTheme.copper,
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingL),
            Text(
              title,
              style: TailboardTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TailboardTheme.spacingS),
            Text(
              message,
              style: TailboardTheme.bodyMedium.copyWith(
                color: TailboardTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: TailboardTheme.spacingL),
              action!,
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(TailboardTheme.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TailboardTheme.headingSmall,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Badge widget for counts and notifications
class BadgeWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const BadgeWidget({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TailboardTheme.spacingS,
        vertical: TailboardTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? TailboardTheme.copper,
        borderRadius: BorderRadius.circular(TailboardTheme.radiusRound),
      ),
      child: Text(
        text,
        style: TailboardTheme.labelSmall.copyWith(
          color: textColor ?? TailboardTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Action chip widget
class ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? TailboardTheme.copper.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TailboardTheme.spacingM,
            vertical: TailboardTheme.spacingS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: foregroundColor ?? TailboardTheme.copper,
              ),
              const SizedBox(width: TailboardTheme.spacingS),
              Text(
                label,
                style: TailboardTheme.bodyMedium.copyWith(
                  color: foregroundColor ?? TailboardTheme.copper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divider with label
class LabeledDivider extends StatelessWidget {
  final String label;

  const LabeledDivider({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: TailboardTheme.divider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TailboardTheme.spacingM,
          ),
          child: Text(
            label,
            style: TailboardTheme.labelSmall,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: TailboardTheme.divider,
          ),
        ),
      ],
    );
  }
}
