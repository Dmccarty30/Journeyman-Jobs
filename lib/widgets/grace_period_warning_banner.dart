import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riverpod/session_manager_provider.dart';

/// A banner that displays a warning when the user is in the grace period.
///
/// This widget:
/// - Shows a dismissible warning banner at the top of the screen
/// - Displays countdown timer showing remaining time
/// - Automatically appears when grace period starts
/// - Disappears when user activity is detected or session expires
/// - Updates every second to show real-time countdown
///
/// The banner is shown after 2 minutes of inactivity and provides
/// a 5-minute grace period before automatic sign-out.
///
/// Usage:
/// Wrap your app's content at the MaterialApp level:
///
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) => Column(
///     children: [
///       const GracePeriodWarningBanner(),
///       Expanded(child: child ?? const SizedBox()),
///     ],
///   ),
///   routerConfig: router,
/// );
/// ```
class GracePeriodWarningBanner extends ConsumerWidget {
  const GracePeriodWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the session manager service for state changes
    final sessionManager = ref.watch(sessionManagerProvider);

    // Only show banner if in grace period
    if (!sessionManager.isInGracePeriod) {
      return const SizedBox.shrink();
    }

    // Get remaining time
    final remainingTime = sessionManager.remainingGracePeriod;
    if (remainingTime == null) {
      return const SizedBox.shrink();
    }

    // Format remaining time as MM:SS
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds.remainder(60);
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Determine severity color based on remaining time
    final Color backgroundColor;
    final Color textColor;

    if (remainingTime.inMinutes >= 3) {
      // More than 3 minutes - low urgency (yellow)
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
    } else if (remainingTime.inMinutes >= 1) {
      // 1-3 minutes - medium urgency (orange)
      backgroundColor = Colors.deepOrange.shade100;
      textColor = Colors.deepOrange.shade900;
    } else {
      // Less than 1 minute - high urgency (red)
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
    }

    return Material(
      color: backgroundColor,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Session Timeout Warning',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You\'ll be signed out in $timeString due to inactivity',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Record activity to reset timer
                  sessionManager.recordActivity();
                },
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: textColor),
                  ),
                ),
                child: const Text(
                  'Stay Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
