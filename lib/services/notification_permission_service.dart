import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../design_system/app_theme.dart';
import '../design_system/components/reusable_components.dart';

/// Service to handle notification permissions and guide users through setup
class NotificationPermissionService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Check current notification permission status
  static Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.notification.status;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final status = await checkPermissionStatus();
    return status.isGranted;
  }

  /// Request notification permissions from the user
  static Future<bool> requestPermissions() async {
    try {
      // Request Firebase messaging permissions first
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Also request system notification permission
        final permissionStatus = await Permission.notification.request();
        return permissionStatus.isGranted;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Show permission request dialog with context about why notifications are needed
  static Future<bool> showPermissionDialog(BuildContext context) async {
    bool? userResponse = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withValues(alpha: 0.1),
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
                  'Enable Job Alerts',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stay ahead of the competition with instant notifications:',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildFeatureItem(
                icon: Icons.work_outline,
                title: 'New Job Matches',
                description: 'Get alerted when jobs match your skills and location',
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeatureItem(
                icon: Icons.flash_on,
                title: 'Storm Work Priority',
                description: 'First to know about high-paying emergency calls',
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeatureItem(
                icon: Icons.access_time,
                title: 'Application Deadlines',
                description: 'Never miss a bid deadline again',
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeatureItem(
                icon: Icons.security,
                title: 'Safety Alerts',
                description: 'Critical safety updates from your union local',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not Now',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            JJPrimaryButton(
              text: 'Enable Notifications',
              onPressed: () => Navigator.of(context).pop(true),
              width: 180,
            ),
          ],
        );
      },
    );

    if (userResponse == true) {
      return await requestPermissions();
    }

    return false;
  }

  /// Show settings redirect dialog when permissions are denied
  static Future<void> showSettingsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Icon(
                Icons.settings,
                color: AppTheme.warningYellow,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Text(
                'Notifications Disabled',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
          content: Text(
            'To receive job alerts and safety notifications, please enable notifications in your device settings.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
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
            JJPrimaryButton(
              text: 'Open Settings',
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              width: 140,
            ),
          ],
        );
      },
    );
  }

  /// Handle initial permission request flow
  static Future<bool> handleInitialPermissionFlow(BuildContext context) async {
    final currentStatus = await checkPermissionStatus();
    if (!context.mounted) return false;

    switch (currentStatus) {
      case PermissionStatus.granted:
        return true;

      case PermissionStatus.denied:
        return await showPermissionDialog(context);

      case PermissionStatus.permanentlyDenied:
        await showSettingsDialog(context);
        return false;

      case PermissionStatus.restricted:
        await showSettingsDialog(context);
        return false;

      default:
        return await showPermissionDialog(context);
    }
  }

  /// Build feature item widget for permission dialog
  static Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.accentCopper,
          size: AppTheme.iconSm,
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                description,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}