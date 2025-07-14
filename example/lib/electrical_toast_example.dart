import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import '../design_system/components/jj_electrical_toast.dart';
import '../design_system/components/reusable_components.dart';

/// Example screen demonstrating the JJElectricalToast component
class ElectricalToastExample extends StatelessWidget {
  const ElectricalToastExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrical Toast Examples'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'JJ Electrical Toast Component',
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.primaryNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Tap the buttons below to see different toast styles with electrical theming',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Success Toast
            JJPrimaryButton(
              text: 'Show Success Toast',
              icon: Icons.check_circle,
              onPressed: () {
                JJElectricalToast.showSuccess(
                  context: context,
                  message: 'Job application submitted successfully!',
                  actionLabel: 'View Jobs',
                  onActionPressed: () {
                    debugPrint('View Jobs tapped');
                  },
                );
              },
              isFullWidth: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Error Toast
            JJSecondaryButton(
              text: 'Show Error Toast',
              icon: Icons.error,
              onPressed: () {
                JJElectricalToast.showError(
                  context: context,
                  message: 'Connection to job board failed. Please check your network.',
                  actionLabel: 'Retry',
                  onActionPressed: () {
                    debugPrint('Retry tapped');
                  },
                );
              },
              isFullWidth: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Warning Toast
            JJPrimaryButton(
              text: 'Show Warning Toast',
              icon: Icons.warning,
              onPressed: () {
                JJElectricalToast.showWarning(
                  context: context,
                  message: 'Storm work alert: High voltage conditions detected',
                  duration: const Duration(seconds: 6),
                );
              },
              isFullWidth: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Info Toast
            JJSecondaryButton(
              text: 'Show Info Toast',
              icon: Icons.info,
              onPressed: () {
                JJElectricalToast.showInfo(
                  context: context,
                  message: 'New jobs available in your area',
                  actionLabel: 'Browse',
                  onActionPressed: () {
                    debugPrint('Browse tapped');
                  },
                );
              },
              isFullWidth: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Power Toast (Custom electrical theme)
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [AppTheme.shadowSm],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    JJElectricalToast.showPower(
                      context: context,
                      message: 'Power grid status: All systems operational',
                      duration: const Duration(seconds: 5),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: AppTheme.white,
                        size: AppTheme.iconSm,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Show Power Toast',
                        style: AppTheme.buttonMedium.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Custom Toast with Custom Icon
            JJSecondaryButton(
              text: 'Show Custom Toast',
              icon: Icons.build,
              onPressed: () {
                JJElectricalToast.showCustom(
                  context: context,
                  message: 'Maintenance scheduled for tonight at 11 PM',
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.warningYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.build_circle,
                      size: AppTheme.iconSm,
                      color: AppTheme.warningYellow,
                    ),
                  ),
                  type: JJToastType.warning,
                  actionLabel: 'Schedule',
                  onActionPressed: () {
                    debugPrint('Schedule tapped');
                  },
                );
              },
              isFullWidth: true,
            ),

            const Spacer(),

            // Tips section
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.lightGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toast Features:',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    '• Electrical-themed animations and styling\n'
                    '• Progress indicator showing remaining time\n'
                    '• Swipe up to dismiss early\n'
                    '• Tap to dismiss\n'
                    '• Optional action buttons\n'
                    '• Custom icons and electrical illustrations',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}