import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';

/// Session timeout warning dialog with electrical circuit theme.
///
/// Displays a warning when the user's session is about to expire due to inactivity.
/// Shows a countdown timer and provides a "Stay Logged In" button to extend the session.
///
/// Features:
/// - Electrical circuit-themed design (Navy/Copper color scheme)
/// - Real-time countdown timer showing time until automatic logout
/// - "Stay Logged In" button that records activity and dismisses dialog
/// - Circuit pattern background for electrical worker aesthetic
/// - Auto-dismiss if user becomes active elsewhere in the app
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false, // Prevent accidental dismissal
///   builder: (context) => SessionTimeoutDialog(
///     remainingTime: Duration(minutes: 5),
///     onStayLoggedIn: () {
///       // Record activity to reset timeout
///       sessionService.recordActivity();
///       Navigator.of(context).pop();
///     },
///   ),
/// );
/// ```
class SessionTimeoutDialog extends StatefulWidget {
  /// Duration remaining until automatic logout
  final Duration remainingTime;

  /// Callback when user clicks "Stay Logged In" button
  final VoidCallback onStayLoggedIn;

  const SessionTimeoutDialog({
    super.key,
    required this.remainingTime,
    required this.onStayLoggedIn,
  });

  @override
  State<SessionTimeoutDialog> createState() => _SessionTimeoutDialogState();
}

class _SessionTimeoutDialogState extends State<SessionTimeoutDialog> {
  @override
  Widget build(BuildContext context) {
    // Format remaining time as MM:SS
    final minutes = widget.remainingTime.inMinutes;
    final seconds = widget.remainingTime.inSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthCopper,
        ),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3FB45309), // Copper glow
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Circuit pattern background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Opacity(
                  opacity: 0.08,
                  child: CustomPaint(
                    painter: _CircuitPatternPainter(),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning icon with glow effect
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentCopper.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentCopper.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: AppTheme.accentCopper,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Title
                  Text(
                    'Session Timeout Warning',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Description
                  Text(
                    'You\'ve been inactive for a while. Your session will expire soon for security.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.lightGray,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Countdown timer with electrical theme
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXl,
                      vertical: AppTheme.spacingLg,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryNavy,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthMedium,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentCopper.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: AppTheme.accentCopper,
                          size: 28,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Text(
                          timeString,
                          style: AppTheme.displayMedium.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [
                              const FontFeature.tabularFigures(), // Monospace numbers
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Subtitle under timer
                  Text(
                    'until automatic logout',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Action button with electrical gradient
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onStayLoggedIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCopper,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMd,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.accentCopper.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 20),
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            'Stay Logged In',
                            style: AppTheme.buttonMedium.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
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

/// Custom painter for electrical circuit pattern background.
///
/// Draws a subtle circuit board pattern with copper-colored traces
/// to maintain the electrical worker theme throughout the app.
class _CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCopper
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw simple circuit traces (horizontal and vertical lines)
    const spacing = 40.0;

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw small circles at intersections (circuit nodes)
    final circlePaint = Paint()
      ..color = AppTheme.accentCopper
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
