import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riverpod/session_timeout_provider.dart';
import 'dialogs/session_timeout_dialog.dart';

/// Widget that listens to session state and shows warning dialog when timeout approaches.
///
/// This widget monitors the session timeout state through Riverpod and automatically
/// displays the electrical-themed warning dialog when the user enters the warning period
/// (5 minutes before automatic logout).
///
/// Features:
/// - Automatically shows dialog at 40-minute mark (5 min before logout)
/// - Updates countdown timer in real-time
/// - Auto-dismisses if user becomes active elsewhere
/// - Prevents multiple dialogs from appearing simultaneously
/// - Uses electrical circuit theme consistent with app design
///
/// **Usage:**
/// Wrap the MaterialApp.router with this listener to enable global session monitoring:
///
/// ```dart
/// class JourneymanJobsApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return SessionTimeoutListener(
///       child: MaterialApp.router(
///         title: 'Journeyman Jobs',
///         theme: AppTheme.light(),
///         darkTheme: AppTheme.dark(),
///         routerConfig: AppRouter.router,
///       ),
///     );
///   }
/// }
/// ```
///
/// The listener automatically handles:
/// - Showing the warning dialog when `warningShown` becomes true
/// - Updating the countdown every second
/// - Dismissing the dialog if grace period ends or activity resumes
/// - Preventing duplicate dialogs
class SessionTimeoutListener extends ConsumerStatefulWidget {
  /// The child widget (typically MaterialApp.router)
  final Widget child;

  const SessionTimeoutListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SessionTimeoutListener> createState() =>
      _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState
    extends ConsumerState<SessionTimeoutListener> {
  /// Whether the warning dialog is currently being displayed
  bool _dialogShown = false;

  /// Timer for updating the dialog countdown every second
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Shows the session timeout warning dialog.
  ///
  /// The dialog displays:
  /// - Warning message about impending logout
  /// - Real-time countdown timer
  /// - "Stay Logged In" button to reset session
  ///
  /// The dialog is barrierDismissible: false to prevent accidental dismissal,
  /// but will auto-dismiss if:
  /// - User clicks "Stay Logged In"
  /// - User becomes active elsewhere (activity detector)
  /// - Grace period expires (user gets logged out)
  void _showWarningDialog() {
    if (_dialogShown || !mounted) return;

    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent tap-outside dismissal
      builder: (dialogContext) => _SessionTimeoutDialogWrapper(
        onDismissed: () {
          _dialogShown = false;
          _countdownTimer?.cancel();
        },
      ),
    );
  }

  /// Dismisses the warning dialog if it's currently shown.
  ///
  /// Called when:
  /// - User resumes activity (grace period exited)
  /// - Session ends (user logged out)
  void _dismissDialog() {
    if (_dialogShown && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogShown = false;
      _countdownTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to session state changes
    ref.listen<SessionState>(
      sessionTimeoutProvider,
      (previous, next) {
        // Show dialog when warning flag is set
        if (next.warningShown && !_dialogShown && next.isInGracePeriod) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showWarningDialog();
          });
        }

        // Dismiss dialog if user resumed activity or session ended
        if (_dialogShown && (!next.isInGracePeriod || !next.isActive)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _dismissDialog();
          });
        }
      },
    );

    return widget.child;
  }
}

/// Internal wrapper that rebuilds the dialog every second to update countdown.
///
/// This widget watches the session state and provides real-time countdown updates
/// to the SessionTimeoutDialog. It's separated from the main listener to isolate
/// the rebuild scope to just the dialog content.
class _SessionTimeoutDialogWrapper extends ConsumerStatefulWidget {
  final VoidCallback onDismissed;

  const _SessionTimeoutDialogWrapper({
    required this.onDismissed,
  });

  @override
  ConsumerState<_SessionTimeoutDialogWrapper> createState() =>
      _SessionTimeoutDialogWrapperState();
}

class _SessionTimeoutDialogWrapperState
    extends ConsumerState<_SessionTimeoutDialogWrapper> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();

    // Start timer to trigger rebuilds every second for countdown animation
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to update countdown
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionTimeoutProvider);

    // Calculate remaining time in grace period
    final timeUntilTimeout = sessionState.timeUntilTimeout ?? Duration.zero;

    // Auto-dismiss if time expires or grace period ends
    if (timeUntilTimeout <= Duration.zero || !sessionState.isInGracePeriod) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onDismissed();
          Navigator.of(context).pop();
        }
      });
    }

    return SessionTimeoutDialog(
      remainingTime: timeUntilTimeout,
      onStayLoggedIn: () {
        // Record activity to reset timeout and exit grace period
        ref.read(sessionTimeoutProvider.notifier).recordActivity();

        // Dismiss dialog
        widget.onDismissed();
        Navigator.of(context).pop();
      },
    );
  }
}
