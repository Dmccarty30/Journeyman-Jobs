import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../design_system/app_theme.dart';
import '../navigation/app_router.dart';

/// Service for managing periodic reminders to complete job preferences
///
/// Implements Option 3: Periodic Dialog approach
/// - Tracks app launch count using SharedPreferences
/// - Shows reminder dialog every 3rd app launch
/// - Only displays if user has incomplete preferences
/// - Provides direct navigation to Settings → Job Preferences
///
/// Usage:
/// ```dart
/// await PreferencesReminderService.checkAndShowReminder(context);
/// ```
class PreferencesReminderService {
  static const String _launchCountKey = 'app_launch_count';
  static const String _lastReminderLaunchKey = 'last_reminder_launch';
  static const int _reminderFrequency = 3; // Show every 3rd launch

  /// Checks if user has incomplete preferences and shows reminder dialog if needed
  ///
  /// Call this method from your home screen's initState() or main app initialization.
  ///
  /// Flow:
  /// 1. Increment app launch counter
  /// 2. Check if it's time to show reminder (every 3rd launch)
  /// 3. Verify user has incomplete preferences
  /// 4. Show dialog with link to settings
  ///
  /// Returns true if dialog was shown, false otherwise
  static Future<bool> checkAndShowReminder(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Increment and get launch count
      final launchCount = (prefs.getInt(_launchCountKey) ?? 0) + 1;
      await prefs.setInt(_launchCountKey, launchCount);

      // Check if it's time to show reminder
      final lastReminderLaunch = prefs.getInt(_lastReminderLaunchKey) ?? 0;
      final launchesSinceReminder = launchCount - lastReminderLaunch;

      if (launchesSinceReminder < _reminderFrequency) {
        debugPrint('📊 Launch #$launchCount - Next reminder at launch #${lastReminderLaunch + _reminderFrequency}');
        return false;
      }

      // Check if preferences are incomplete
      final hasIncompletePreferences = await _checkIncompletePreferences(user.uid);

      if (!hasIncompletePreferences) {
        debugPrint('✅ Preferences complete - No reminder needed');
        return false;
      }

      // Update last reminder launch
      await prefs.setInt(_lastReminderLaunchKey, launchCount);

      // Show reminder dialog
      if (context.mounted) {
        await _showPreferencesReminderDialog(context);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ Error in checkAndShowReminder: $e');
      return false;
    }
  }

  /// Checks if user has incomplete job preferences
  ///
  /// Returns true if preferences are incomplete, false otherwise
  static Future<bool> _checkIncompletePreferences(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) return true;

      final data = userDoc.data();
      if (data == null) return true;

      // Check if preferencesCompleted flag exists and is true
      final preferencesCompleted = data['preferencesCompleted'] as bool?;
      final hasSetJobPreferences = data['hasSetJobPreferences'] as bool?;

      // If either flag is false or missing, preferences are incomplete
      return !(preferencesCompleted == true && hasSetJobPreferences == true);
    } catch (e) {
      debugPrint('⚠️ Error checking preferences: $e');
      return false; // Don't show reminder if check fails
    }
  }

  /// Shows the preferences reminder dialog
  ///
  /// Dialog features:
  /// - Electrical-themed design matching app aesthetics
  /// - Clear call-to-action message
  /// - Direct navigation to Settings → Job Preferences
  /// - "Later" option to dismiss
  static Future<void> _showPreferencesReminderDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppTheme.primaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            side: BorderSide(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthCopper,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                AppTheme.shadowElectricalWarning,
                BoxShadow(
                  color: AppTheme.accentCopper.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with electrical theme
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentCopper,
                      width: AppTheme.borderWidthCopper,
                    ),
                    boxShadow: [
                      AppTheme.shadowElectricalWarning,
                    ],
                  ),
                  child: Icon(
                    Icons.tune_outlined,
                    size: 32,
                    color: AppTheme.white,
                    shadows: [
                      Shadow(
                        color: AppTheme.accentCopper.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Title
                Text(
                  'Complete Your Job Preferences',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingSm),

                // Message
                Text(
                  'Set your job preferences to get personalized job matches that fit your skills and location!',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.white,
                          side: BorderSide(
                            color: AppTheme.accentCopper,
                            width: AppTheme.borderWidthCopperThin,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMd,
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppTheme.spacingMd),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Navigate to settings (job preferences)
                          // Note: Update this route based on your actual settings route
                          context.go(AppRouter.settings);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCopper,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMd,
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Set Preferences',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Resets the reminder counter (useful for testing or after preferences are completed)
  ///
  /// Call this method when user successfully completes their preferences
  /// to reset the launch counter and prevent showing reminders until
  /// they become incomplete again.
  static Future<void> resetReminderCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_launchCountKey, 0);
      await prefs.setInt(_lastReminderLaunchKey, 0);
      debugPrint('✅ Preferences reminder counter reset');
    } catch (e) {
      debugPrint('⚠️ Error resetting reminder counter: $e');
    }
  }

  /// Manually triggers the reminder dialog (for testing purposes)
  ///
  /// Use this during development to test the reminder dialog appearance
  /// without waiting for 3 app launches.
  static Future<void> forceShowReminder(BuildContext context) async {
    await _showPreferencesReminderDialog(context);
  }
}
