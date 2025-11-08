import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';

/// Electrical-themed loading state widget
///
/// Displays a themed loading indicator with circuit pattern background
/// and progress message for electrical workers.
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy.withValues(alpha:0.08),
            AppTheme.primaryNavy.withValues(alpha:0.03),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Electrical loader with circuit pattern
            JJElectricalLoader(
              width: 200,
              height: 60,
              message: message ?? 'Loading...',
            ),

            const SizedBox(height: 20),

            // Optional status text
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 300),
              ),
          ],
        ),
      ),
    );
  }
}

/// Electrical-themed error state widget with retry functionality
///
/// Displays an electrical-themed error message when data loading fails.
/// Shows a lightning bolt icon with error details and a retry button
/// that matches the app's electrical industrial aesthetic.
class ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryNavy.withValues(alpha:0.05),
            AppTheme.primaryNavy.withValues(alpha:0.02),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Electrical error icon with animation
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentCopper.withValues(alpha:0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.electrical_services_rounded,
                  size: 64,
                  color: AppTheme.accentCopper,
                ),
              ).animate().shake(
                duration: const Duration(milliseconds: 500),
                hz: 2,
              ),

              const SizedBox(height: 24),

              // Error title
              Text(
                'Connection Error',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Error message
              Text(
                'Unable to load crew data. Please check your connection and try again.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),

              const SizedBox(height: 8),

              // Technical error details (optional, shown in smaller text)
              if (error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: ${error.length > 100 ? '${error.substring(0, 100)}...' : error}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),

              // Retry button with electrical theme
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    'RETRY CONNECTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCopper,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppTheme.accentCopper.withValues(alpha:0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              ),

              const SizedBox(height: 16),

              // Secondary help option
              TextButton(
                onPressed: () {
                  // Could open help dialog or contact support
                },
                child: Text(
                  'Need Help? Contact Support',
                  style: TextStyle(
                    color: AppTheme.accentCopper,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
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

/// Empty state widget for when no data is available
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.mediumGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Utility functions for common operations
class UtilityMethods {
  /// Format timestamp for display in chat/messages
  static String formatLastMessageTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  /// Get display name for a channel
  static String getChannelDisplayName(String channelName) {
    // Remove # prefix if present
    if (channelName.startsWith('#')) {
      return channelName.substring(1);
    }
    return channelName;
  }

  /// Truncate message text for preview
  static String truncateMessage(String message, {int maxLength = 50}) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  /// Build an electrical-themed button
  static Widget buildElectricalButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    IconData? icon,
  }) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentCopper,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentCopper,
          side: const BorderSide(color: AppTheme.accentCopper),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// Build a themed icon with electrical styling
  static Widget buildThemedIcon(
    IconData icon, {
    Color? color,
    double size = 24,
  }) {
    return Icon(
      icon,
      size: size,
      color: color ?? AppTheme.accentCopper,
    );
  }
}