import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/design_system/widgets/design_system_widgets.dart';
import '../design_system/app_theme.dart';
import '../electrical_components/circuit_pattern_painter.dart';
import '../navigation/app_router.dart';

/// A themed popup widget for quick notification access
/// Displays a electrical-themed popup with notification options
class NotificationPopup extends StatefulWidget {
  final VoidCallback? onClose;
  
  const NotificationPopup({
    super.key,
    this.onClose,
  });

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closePopup() async {
    await _animationController.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthMedium,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Stack(
              children: [
                // Circuit pattern background
                Positioned.fill(
                  child: CustomPaint(
                    painter: CircuitPatternPainter(
                      primaryColor: AppTheme.accentCopper.withValues(alpha: 0.05),
                      secondaryColor: AppTheme.primaryNavy.withValues(alpha: 0.03),
                      animate: true,
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryNavy,
                            AppTheme.primaryNavy.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingSm),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCopper.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: AppTheme.accentCopper,
                              size: AppTheme.iconMd,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Text(
                              'Quick Notifications',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _closePopup,
                            icon: const Icon(
                              Icons.close,
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Options
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        children: [
                          _buildOption(
                            icon: Icons.notifications_outlined,
                            title: 'View All Notifications',
                            subtitle: 'See your notification history',
                            color: AppTheme.accentCopper,
                            onTap: () {
                              _closePopup();
                              context.go(AppRouter.notifications);
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _buildOption(
                            icon: Icons.settings_outlined,
                            title: 'Notification Settings',
                            subtitle: 'Manage your preferences',
                            color: AppTheme.primaryNavy,
                            onTap: () {
                              _closePopup();
                              // Navigate to notifications screen with settings tab selected
                              context.go('${AppRouter.notifications}?tab=settings');
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _buildOption(
                            icon: Icons.do_not_disturb,
                            title: 'Enable Quiet Hours',
                            subtitle: 'Silence notifications temporarily',
                            color: AppTheme.warningYellow,
                            onTap: () {
                              _closePopup();
                              // Show quiet hours dialog
                              _showQuietHoursDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.borderLight,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textLight,
                size: AppTheme.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuietHoursDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.bedtime,
              color: AppTheme.warningYellow,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              'Enable Quiet Hours',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Silence all notifications for:',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Wrap(
              spacing: AppTheme.spacingSm,
              children: [
                _buildTimeChip('1 hour'),
                _buildTimeChip('2 hours'),
                _buildTimeChip('4 hours'),
                _buildTimeChip('Until tomorrow'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        Navigator.of(context).pop();
        JJSnackBar.showInfo(
          context: context,
          message: 'Quiet hours enabled for $label',
        );
      },
      backgroundColor: AppTheme.lightGray,
      labelStyle: AppTheme.bodyMedium.copyWith(
        color: AppTheme.primaryNavy,
      ),
    );
  }
}

/// Helper function to show the notification popup
void showNotificationPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: NotificationPopup(
        onClose: () => Navigator.of(context).pop(),
      ),
    ),
  );
}