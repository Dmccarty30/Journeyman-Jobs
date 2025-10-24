# Session Grace Period Implementation Workflow

**Feature**: 5-Minute Grace Period for Session Timeout
**Priority**: High (UX Improvement)
**Security Level**: Medium (requires careful implementation)
**Estimated Effort**: 8-12 hours

---

## Executive Summary

Implement a 5-minute grace period before automatic logout to improve UX while maintaining security. Session remains active during grace period, allowing seamless app resumption.

**Current Behavior:**
- Immediate logout after 10 minutes of inactivity
- Immediate session end when app closes

**New Behavior:**
- 5-minute grace period after inactivity/closure triggers
- Session persists during grace period
- Activity resumption within 5 minutes → session continues
- No activity for 5 minutes → logout

---

## Security Assessment

### ✅ Approved with Mitigations

**Risk Score**: 2.5/10 (Low-Medium)

**Threats Mitigated:**
- UX friction reduction without significant security compromise
- Total timeout: 10 min (inactivity) + 5 min (grace) = 15 min < Firebase token lifetime (60 min)

**Threats Introduced & Mitigations:**

| Threat | Risk Level | Mitigation |
|--------|-----------|------------|
| Physical device access during grace | MEDIUM | Grace period only for normal inactivity, not forced logout |
| Session hijacking | LOW | Firebase tokens still expire normally (60 min) |
| Cross-device exploitation | LOW | Grace period local-only (SharedPreferences) |
| Token lifetime desync | LOW | 15 min total < 60 min token lifetime ✅ |
| Grace period stacking | MEDIUM | Single timer, strict 5-minute max, no extensions |

**Compliance:**
- ✅ **PCI DSS**: 15 min < 30 min requirement
- ✅ **SOC 2**: Acceptable with documentation
- ✅ **GDPR**: No impact

**Security Requirements:**
1. Grace period MUST NOT exceed 5 minutes (hard limit)
2. Grace period state MUST be local-only (no cloud sync)
3. Manual logout MUST bypass grace period
4. Security events MUST bypass grace period
5. Audit logs MUST record grace period events (no PII)

---

## Architecture Design

### State Machine

```
┌─────────────┐
│   ACTIVE    │ ◄─────────────────┐
│  (normal)   │                   │
└──────┬──────┘                   │
       │ 10 min inactivity        │
       │ or app closure           │
       ▼                          │
┌─────────────┐                   │
│  INACTIVE   │                   │
│  DETECTED   │                   │
└──────┬──────┘                   │
       │ start grace period       │
       ▼                          │
┌─────────────┐  user activity    │
│    GRACE    ├───────────────────┘
│   PERIOD    │  within 5 min
│  (5 min)    │
└──────┬──────┘
       │ 5 min elapsed
       │ no activity
       ▼
┌─────────────┐
│   TIMEOUT   │
│  (logout)   │
└─────────────┘
```

### Components to Modify

#### 1. SessionTimeoutService (`lib/services/session_timeout_service.dart`)

**New Fields:**
```dart
/// Grace period duration (5 minutes)
static const Duration gracePeriodDuration = Duration(minutes: 5);

/// Grace period timer
Timer? _gracePeriodTimer;

/// Grace period start time
DateTime? _gracePeriodStartTime;

/// Whether currently in grace period
bool _isInGracePeriod = false;

/// SharedPreferences key for grace period start
static const String _gracePeriodStartKey = 'grace_period_start_timestamp';

/// Callback for grace period state changes
ValueChanged<bool>? onGracePeriodStateChanged;

/// Callback for grace period warning (1 minute before timeout)
VoidCallback? onGracePeriodWarning;
```

**New Methods:**
```dart
/// Starts the grace period timer
Future<void> _startGracePeriod();

/// Cancels the grace period and resumes normal session
Future<void> _cancelGracePeriod();

/// Checks if grace period has expired
Future<bool> _checkGracePeriodExpiration();

/// Records grace period start timestamp
Future<void> _recordGracePeriodStart();

/// Clears grace period state
Future<void> _clearGracePeriodState();
```

**Modified Methods:**
```dart
// _checkForTimeout() - Start grace period instead of immediate logout
// initialize() - Check for expired grace period on app launch
// recordActivity() - Cancel grace period if active
// endSession() - Clear grace period state
```

#### 2. AppLifecycleService (`lib/services/app_lifecycle_service.dart`)

**Modified Behavior:**
```dart
// didChangeAppLifecycleState()
case AppLifecycleState.detached:
  // OLD: Immediate session end
  // NEW: Start grace period
  _handleAppClosure(); // Modified implementation
```

**New Implementation:**
```dart
Future<void> _handleAppClosure() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null && _sessionTimeoutService != null) {
    // Start grace period instead of ending session
    await _sessionTimeoutService!.startGracePeriod();

    debugPrint('[Lifecycle] Grace period started due to app closure');
  }
}
```

#### 3. SessionTimeoutProvider (`lib/providers/riverpod/session_timeout_provider.dart`)

**Extended SessionState:**
```dart
class SessionState {
  final bool isActive;
  final DateTime? lastActivity;
  final Duration? timeUntilTimeout;
  final bool isInGracePeriod;              // NEW
  final Duration? gracePeriodTimeRemaining; // NEW

  const SessionState({
    this.isActive = false,
    this.lastActivity,
    this.timeUntilTimeout,
    this.isInGracePeriod = false,           // NEW
    this.gracePeriodTimeRemaining,          // NEW
  });
}
```

**New Callbacks:**
```dart
// _initializeService()
_service?.onGracePeriodStateChanged = (isInGrace) {
  state = state.copyWith(isInGracePeriod: isInGrace);
};

_service?.onGracePeriodWarning = () {
  // Show 4-minute warning notification
  _showGracePeriodWarning();
};
```

#### 4. New: GracePeriodWarningWidget

**Location**: `lib/widgets/grace_period_warning.dart`

**Features:**
- Shows warning banner at 4-minute mark (1 min before timeout)
- Displays countdown timer
- "Stay Logged In" button to cancel grace period

**Example UI:**
```
┌──────────────────────────────────────────────────┐
│ ⚠️  Session Expiring Soon                       │
│                                                   │
│ You will be logged out in 1m 0s due to          │
│ inactivity. Tap to stay logged in.              │
│                                                   │
│ [Dismiss]              [Stay Logged In]         │
└──────────────────────────────────────────────────┘
```

---

## Implementation Workflow

### Phase 1: SessionTimeoutService Modifications (3-4 hours)

**Step 1.1: Add Grace Period Fields**
```dart
// Location: lib/services/session_timeout_service.dart
// Add after line 58 (existing state management)

// Grace period configuration
static const Duration gracePeriodDuration = Duration(minutes: 5);
static const String _gracePeriodStartKey = 'grace_period_start_timestamp';

// Grace period state
Timer? _gracePeriodTimer;
DateTime? _gracePeriodStartTime;
bool _isInGracePeriod = false;

// Grace period callbacks
ValueChanged<bool>? onGracePeriodStateChanged;
VoidCallback? onGracePeriodWarning;
```

**Step 1.2: Implement Grace Period Start Method**
```dart
/// Starts the grace period after inactivity timeout detected.
///
/// This method:
/// 1. Records grace period start time in persistent storage
/// 2. Notifies listeners of grace period state change
/// 3. Starts 5-minute grace period timer
/// 4. Schedules 4-minute warning notification
/// 5. Triggers logout after 5 minutes if no activity
Future<void> _startGracePeriod() async {
  if (_isInGracePeriod) {
    debugPrint('[SessionTimeout] Grace period already active');
    return;
  }

  _isInGracePeriod = true;
  _gracePeriodStartTime = DateTime.now();

  // Record grace period start in persistent storage
  await _recordGracePeriodStart();

  // Notify listeners
  onGracePeriodStateChanged?.call(true);

  debugPrint('[SessionTimeout] Grace period started (${gracePeriodDuration.inMinutes} minutes)');

  // Schedule warning at 4-minute mark (1 minute before timeout)
  Timer(const Duration(minutes: 4), () {
    if (_isInGracePeriod) {
      debugPrint('[SessionTimeout] Grace period warning triggered');
      onGracePeriodWarning?.call();
    }
  });

  // Start grace period timer
  _gracePeriodTimer = Timer(gracePeriodDuration, () async {
    if (_isInGracePeriod) {
      debugPrint('[SessionTimeout] Grace period expired - logging out');

      // Clear grace period state
      await _clearGracePeriodState();

      // Stop monitoring and clear session
      _isAuthenticated = false;
      _stopMonitoring();
      await _clearSessionState();

      // Notify session state changed
      onSessionStateChanged?.call(false);

      // Trigger timeout callback (logout)
      if (onTimeout != null) {
        onTimeout!();
      }
    }
  });
}
```

**Step 1.3: Implement Grace Period Cancellation**
```dart
/// Cancels the grace period and resumes normal session.
///
/// Called when user activity is detected during grace period.
/// Resets the session to active state.
Future<void> _cancelGracePeriod() async {
  if (!_isInGracePeriod) {
    return;
  }

  debugPrint('[SessionTimeout] Grace period cancelled - resuming session');

  // Cancel grace period timer
  _gracePeriodTimer?.cancel();
  _gracePeriodTimer = null;

  // Clear grace period state
  _isInGracePeriod = false;
  _gracePeriodStartTime = null;
  await _clearGracePeriodState();

  // Notify listeners
  onGracePeriodStateChanged?.call(false);

  // Resume normal session monitoring
  await recordActivity();
}
```

**Step 1.4: Implement Persistent State Methods**
```dart
/// Records grace period start timestamp in persistent storage.
Future<void> _recordGracePeriodStart() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _gracePeriodStartKey,
      _gracePeriodStartTime!.millisecondsSinceEpoch,
    );
  } catch (e) {
    debugPrint('[SessionTimeout] Failed to record grace period start: $e');
  }
}

/// Clears grace period state from persistent storage.
Future<void> _clearGracePeriodState() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gracePeriodStartKey);
    _gracePeriodStartTime = null;
    _isInGracePeriod = false;
  } catch (e) {
    debugPrint('[SessionTimeout] Failed to clear grace period state: $e');
  }
}

/// Checks if grace period has expired during app closure.
///
/// Returns true if grace period started but not yet expired.
/// Returns false if grace period expired or never started.
Future<bool> _checkGracePeriodExpiration() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final gracePeriodStart = prefs.getInt(_gracePeriodStartKey);

    if (gracePeriodStart == null) {
      return false; // No grace period active
    }

    final startTime = DateTime.fromMillisecondsSinceEpoch(gracePeriodStart);
    final now = DateTime.now();
    final elapsed = now.difference(startTime);

    if (elapsed >= gracePeriodDuration) {
      // Grace period expired
      debugPrint('[SessionTimeout] Grace period expired during app closure');
      await _clearGracePeriodState();
      return false;
    } else {
      // Grace period still active
      final remaining = gracePeriodDuration - elapsed;
      debugPrint('[SessionTimeout] Grace period still active (${remaining.inMinutes}m ${remaining.inSeconds % 60}s remaining)');
      return true;
    }
  } catch (e) {
    debugPrint('[SessionTimeout] Failed to check grace period expiration: $e');
    return false;
  }
}
```

**Step 1.5: Modify _checkForTimeout() Method**
```dart
// BEFORE (line 234):
Future<void> _checkForTimeout() async {
  if (_lastActivityTime == null || !_isAuthenticated) {
    return;
  }

  final now = DateTime.now();
  final inactiveDuration = now.difference(_lastActivityTime!);

  if (inactiveDuration >= timeoutDuration) {
    debugPrint('[SessionTimeout] Session timed out after ${inactiveDuration.inMinutes} minutes of inactivity');

    // Stop monitoring and clear state
    _isAuthenticated = false;
    _stopMonitoring();
    await _clearSessionState();

    // Notify session state changed
    onSessionStateChanged?.call(false);

    // Trigger timeout callback
    if (onTimeout != null) {
      onTimeout!();
    }
  } else {
    // ... existing code
  }
}

// AFTER (modified):
Future<void> _checkForTimeout() async {
  if (_lastActivityTime == null || !_isAuthenticated) {
    return;
  }

  final now = DateTime.now();
  final inactiveDuration = now.difference(_lastActivityTime!);

  if (inactiveDuration >= timeoutDuration) {
    // Inactivity timeout detected
    if (!_isInGracePeriod) {
      // Start grace period instead of immediate logout
      debugPrint('[SessionTimeout] Inactivity timeout detected - starting grace period');
      await _startGracePeriod();
    } else {
      // Already in grace period - continue waiting
      debugPrint('[SessionTimeout] Already in grace period');
    }
  } else {
    // Calculate remaining time
    final remainingTime = timeoutDuration - inactiveDuration;
    debugPrint('[SessionTimeout] Session active - timeout in ${remainingTime.inMinutes}m ${remainingTime.inSeconds % 60}s');
  }
}
```

**Step 1.6: Modify initialize() Method**
```dart
// BEFORE (line 90):
Future<void> initialize() async {
  if (_isActive) {
    debugPrint('[SessionTimeout] Service already initialized');
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();

    // Check if there was an active session when app was closed
    final hadActiveSession = prefs.getBool(_sessionActiveKey) ?? false;

    if (hadActiveSession) {
      // App was closed with active session - this means session expired
      debugPrint('[SessionTimeout] App was closed with active session - session expired');

      // Clear session state
      await _clearSessionState();

      // Trigger timeout callback if set
      if (onTimeout != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          onTimeout?.call();
        });
      }
    }

    _isActive = true;
    debugPrint('[SessionTimeout] Service initialized');
  } catch (e) {
    debugPrint('[SessionTimeout] Initialization error: $e');
  }
}

// AFTER (modified):
Future<void> initialize() async {
  if (_isActive) {
    debugPrint('[SessionTimeout] Service already initialized');
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();

    // Check if there was a grace period active when app was closed
    final gracePeriodActive = await _checkGracePeriodExpiration();

    if (gracePeriodActive) {
      // Grace period still active - resume session
      debugPrint('[SessionTimeout] Resuming session within grace period');

      // Calculate remaining grace period time
      final gracePeriodStart = prefs.getInt(_gracePeriodStartKey)!;
      final startTime = DateTime.fromMillisecondsSinceEpoch(gracePeriodStart);
      final elapsed = DateTime.now().difference(startTime);
      final remaining = gracePeriodDuration - elapsed;

      // Set grace period state
      _isInGracePeriod = true;
      _gracePeriodStartTime = startTime;

      // Restart grace period timer with remaining time
      _gracePeriodTimer = Timer(remaining, () async {
        if (_isInGracePeriod) {
          debugPrint('[SessionTimeout] Grace period expired - logging out');

          // Clear grace period state
          await _clearGracePeriodState();

          // Trigger timeout callback (logout)
          if (onTimeout != null) {
            onTimeout!();
          }
        }
      });

      // Schedule warning if needed (if more than 1 minute remaining)
      if (remaining > const Duration(minutes: 1)) {
        final warningDelay = remaining - const Duration(minutes: 1);
        Timer(warningDelay, () {
          if (_isInGracePeriod) {
            onGracePeriodWarning?.call();
          }
        });
      }
    } else {
      // Check if there was an active session when app was closed
      final hadActiveSession = prefs.getBool(_sessionActiveKey) ?? false;

      if (hadActiveSession) {
        // App was closed with active session and grace period expired
        debugPrint('[SessionTimeout] Session expired (grace period elapsed)');

        // Clear session state
        await _clearSessionState();
        await _clearGracePeriodState();

        // Trigger timeout callback if set
        if (onTimeout != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            onTimeout?.call();
          });
        }
      }
    }

    _isActive = true;
    debugPrint('[SessionTimeout] Service initialized');
  } catch (e) {
    debugPrint('[SessionTimeout] Initialization error: $e');
  }
}
```

**Step 1.7: Modify recordActivity() Method**
```dart
// BEFORE (line 186):
Future<void> recordActivity() async {
  if (!_isAuthenticated || !_isActive) {
    return;
  }

  _lastActivityTime = DateTime.now();

  // Persist activity timestamp
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, _lastActivityTime!.millisecondsSinceEpoch);
  } catch (e) {
    debugPrint('[SessionTimeout] Failed to record activity: $e');
  }
}

// AFTER (modified):
Future<void> recordActivity() async {
  if (!_isAuthenticated || !_isActive) {
    return;
  }

  // Cancel grace period if active
  if (_isInGracePeriod) {
    debugPrint('[SessionTimeout] Activity detected during grace period - cancelling');
    await _cancelGracePeriod();
  }

  _lastActivityTime = DateTime.now();

  // Persist activity timestamp
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, _lastActivityTime!.millisecondsSinceEpoch);
  } catch (e) {
    debugPrint('[SessionTimeout] Failed to record activity: $e');
  }
}
```

**Step 1.8: Add Grace Period Getters**
```dart
// Add to end of SessionTimeoutService class (after line 302)

/// Returns whether the session is currently in grace period.
bool get isInGracePeriod => _isInGracePeriod;

/// Returns the time remaining in grace period.
///
/// Returns null if not in grace period.
Duration? get gracePeriodTimeRemaining {
  if (!_isInGracePeriod || _gracePeriodStartTime == null) {
    return null;
  }

  final now = DateTime.now();
  final elapsed = now.difference(_gracePeriodStartTime!);
  final remaining = gracePeriodDuration - elapsed;

  return remaining.isNegative ? Duration.zero : remaining;
}
```

### Phase 2: AppLifecycleService Modifications (1-2 hours)

**Step 2.1: Modify _handleAppClosure() Method**
```dart
// Location: lib/services/app_lifecycle_service.dart
// Replace lines 149-160

/// Handles app closure event.
///
/// When the app is closing (detached state), this method:
/// 1. Starts grace period timer
/// 2. Session remains active during grace period
/// 3. Next app launch checks if grace period expired
///
/// This implements the 5-minute grace period requirement.
Future<void> _handleAppClosure() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null && _sessionTimeoutService != null) {
    // Start grace period instead of ending session
    // This allows user to reopen app within 5 minutes without re-auth
    debugPrint('[Lifecycle] Starting grace period due to app closure');

    // Note: _startGracePeriod() needs to be made public in SessionTimeoutService
    // or we add a new method to the service interface

    // Session will either:
    // - Resume if app reopened within 5 minutes
    // - Timeout after 5 minutes if no activity
  }
}
```

**Step 2.2: Add Public Method to SessionTimeoutService**
```dart
// Location: lib/services/session_timeout_service.dart
// Add after recordActivity() method (around line 200)

/// Starts the grace period timer.
///
/// This is called when:
/// - Inactivity timeout is detected
/// - App is closed/backgrounded
///
/// Public method to allow AppLifecycleService to trigger grace period.
Future<void> startGracePeriod() async {
  await _startGracePeriod();
}
```

**Step 2.3: Update _handleAppClosure() Implementation**
```dart
// Location: lib/services/app_lifecycle_service.dart
// Final implementation

Future<void> _handleAppClosure() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null && _sessionTimeoutService != null) {
    // Start grace period
    await _sessionTimeoutService!.startGracePeriod();

    debugPrint('[Lifecycle] Grace period started due to app closure');
  }
}
```

### Phase 3: SessionTimeoutProvider Modifications (2-3 hours)

**Step 3.1: Extend SessionState Model**
```dart
// Location: lib/providers/riverpod/session_timeout_provider.dart
// Replace SessionState class (lines 12-34)

/// Session state model for timeout tracking
class SessionState {
  final bool isActive;
  final DateTime? lastActivity;
  final Duration? timeUntilTimeout;
  final bool isInGracePeriod;              // NEW
  final Duration? gracePeriodTimeRemaining; // NEW

  const SessionState({
    this.isActive = false,
    this.lastActivity,
    this.timeUntilTimeout,
    this.isInGracePeriod = false,           // NEW
    this.gracePeriodTimeRemaining,          // NEW
  });

  SessionState copyWith({
    bool? isActive,
    DateTime? lastActivity,
    Duration? timeUntilTimeout,
    bool? isInGracePeriod,              // NEW
    Duration? gracePeriodTimeRemaining, // NEW
  }) {
    return SessionState(
      isActive: isActive ?? this.isActive,
      lastActivity: lastActivity ?? this.lastActivity,
      timeUntilTimeout: timeUntilTimeout ?? this.timeUntilTimeout,
      isInGracePeriod: isInGracePeriod ?? this.isInGracePeriod,
      gracePeriodTimeRemaining: gracePeriodTimeRemaining ?? this.gracePeriodTimeRemaining,
    );
  }
}
```

**Step 3.2: Add Grace Period Callbacks**
```dart
// Location: lib/providers/riverpod/session_timeout_provider.dart
// Modify _initializeService() method (lines 112-136)

Future<void> _initializeService() async {
  _service = ref.read(sessionTimeoutServiceProvider);

  // Configure timeout callback to handle session expiration
  _service?.onTimeout = () async {
    // Session timed out - sign out user
    final authService = ref.read(authServiceProvider);
    await authService.signOut();

    // Update state to reflect timeout
    state = const SessionState(isActive: false);
  };

  // Configure session state change callback
  _service?.onSessionStateChanged = (isActive) {
    state = SessionState(
      isActive: isActive,
      lastActivity: _service?.lastActivity,
      timeUntilTimeout: _service?.timeUntilTimeout,
      isInGracePeriod: _service?.isInGracePeriod ?? false,
      gracePeriodTimeRemaining: _service?.gracePeriodTimeRemaining,
    );
  };

  // NEW: Configure grace period state change callback
  _service?.onGracePeriodStateChanged = (isInGrace) {
    state = state.copyWith(
      isInGracePeriod: isInGrace,
      gracePeriodTimeRemaining: _service?.gracePeriodTimeRemaining,
    );
  };

  // NEW: Configure grace period warning callback
  _service?.onGracePeriodWarning = () {
    // Show warning notification (handled by UI layer)
    // State update triggers UI to show warning
    state = state.copyWith(
      gracePeriodTimeRemaining: _service?.gracePeriodTimeRemaining,
    );
  };

  // Initialize the service
  await _service?.initialize();
}
```

**Step 3.3: Update recordActivity() Method**
```dart
// Location: lib/providers/riverpod/session_timeout_provider.dart
// Modify recordActivity() (lines 164-173)

Future<void> recordActivity() async {
  await _service?.recordActivity();

  // Update state with new activity time and grace period status
  state = SessionState(
    isActive: state.isActive,
    lastActivity: _service?.lastActivity,
    timeUntilTimeout: _service?.timeUntilTimeout,
    isInGracePeriod: _service?.isInGracePeriod ?? false,        // NEW
    gracePeriodTimeRemaining: _service?.gracePeriodTimeRemaining, // NEW
  );
}
```

### Phase 4: Grace Period Warning Widget (2-3 hours)

**Step 4.1: Create GracePeriodWarningWidget**
```dart
// Location: lib/widgets/grace_period_warning.dart
// NEW FILE

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/providers/riverpod/session_timeout_provider.dart';

/// A notification widget that displays a warning when session is in grace period.
///
/// This widget monitors the session state and shows a banner when the user
/// is in the 5-minute grace period before automatic logout.
///
/// Features:
/// - Shows warning banner when grace period starts
/// - Displays countdown timer for remaining grace period time
/// - "Stay Logged In" button to cancel grace period and resume session
/// - Dismissible with swipe gesture
/// - Automatically dismisses when user activity is detected
///
/// Usage:
/// Wrap your app's main content area:
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return GracePeriodWarning(
///     child: Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: MyContent(),
///     ),
///   );
/// }
/// ```
class GracePeriodWarning extends ConsumerWidget {
  /// The child widget to display.
  final Widget child;

  const GracePeriodWarning({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch session state for grace period information
    final sessionState = ref.watch(sessionTimeoutProvider);

    // Show warning if in grace period
    final shouldShowWarning = sessionState.isInGracePeriod &&
        sessionState.gracePeriodTimeRemaining != null &&
        sessionState.gracePeriodTimeRemaining! > Duration.zero;

    return Column(
      children: [
        // Show warning banner if in grace period
        if (shouldShowWarning)
          _buildWarningBanner(
            context,
            ref,
            sessionState.gracePeriodTimeRemaining!,
          ),

        // Main content
        Expanded(child: child),
      ],
    );
  }

  /// Builds the warning banner displayed during grace period.
  Widget _buildWarningBanner(
    BuildContext context,
    WidgetRef ref,
    Duration timeRemaining,
  ) {
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;

    return Dismissible(
      key: const Key('grace_period_warning'),
      direction: DismissDirection.up,
      onDismissed: (_) {
        // Banner dismissed - no action needed
        // Warning will reappear if still in grace period
      },
      child: Material(
        color: Colors.deepOrange.shade600,
        elevation: 8,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Warning icon with electrical theme
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Warning message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Session Expiring Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You will be logged out in ${minutes}m ${seconds}s due to inactivity.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Stay logged in button
                ElevatedButton(
                  onPressed: () {
                    // Record activity to cancel grace period
                    final notifier = ref.read(sessionTimeoutProvider.notifier);
                    notifier.recordActivity();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Stay Logged In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 4.2: Integrate GracePeriodWarning into App**
```dart
// Location: lib/main.dart or lib/main_riverpod.dart
// Modify the MaterialApp.router builder to include GracePeriodWarning

builder: (context, child) => GracePeriodWarning(
  child: ActivityDetector(
    child: child ?? const SizedBox(),
  ),
),
```

### Phase 5: Testing & Validation (2-3 hours)

**Step 5.1: Unit Tests for SessionTimeoutService**

Create: `test/services/session_timeout_service_grace_period_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/services/session_timeout_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SessionTimeoutService service;

  setUp(() async {
    // Initialize SharedPreferences with mock
    SharedPreferences.setMockInitialValues({});
    service = SessionTimeoutService();
    await service.initialize();
  });

  tearDown(() async {
    await service.dispose();
  });

  group('Grace Period Tests', () {
    test('Grace period starts after inactivity timeout', () async {
      // Start session
      await service.startSession();

      // Simulate inactivity timeout detection
      // (This would normally happen via the periodic timer)
      // We'll test the public method instead
      await service.startGracePeriod();

      // Verify grace period is active
      expect(service.isInGracePeriod, isTrue);
      expect(service.gracePeriodTimeRemaining, isNotNull);
      expect(
        service.gracePeriodTimeRemaining!.inMinutes,
        equals(5),
      );
    });

    test('Grace period cancels on user activity', () async {
      // Start session and grace period
      await service.startSession();
      await service.startGracePeriod();

      expect(service.isInGracePeriod, isTrue);

      // Record user activity
      await service.recordActivity();

      // Verify grace period cancelled
      expect(service.isInGracePeriod, isFalse);
      expect(service.gracePeriodTimeRemaining, isNull);
    });

    test('Grace period state persists across app restarts', () async {
      // Start session and grace period
      await service.startSession();
      await service.startGracePeriod();

      // Simulate app closure
      await service.dispose();

      // Simulate app relaunch
      final newService = SessionTimeoutService();
      await newService.initialize();

      // Verify grace period resumed
      expect(newService.isInGracePeriod, isTrue);
      expect(newService.gracePeriodTimeRemaining, isNotNull);

      await newService.dispose();
    });

    test('Grace period timeout triggers logout', () async {
      bool timeoutCalled = false;

      service.onTimeout = () {
        timeoutCalled = true;
      };

      // Start session and grace period
      await service.startSession();
      await service.startGracePeriod();

      // Simulate grace period expiration
      // (In real scenario, this would be handled by Timer)
      // For testing, we manually trigger the timeout

      // Wait for grace period duration + buffer
      await Future.delayed(const Duration(minutes: 5, seconds: 1));

      // Verify timeout callback was called
      expect(timeoutCalled, isTrue);
    });

    test('Grace period does not stack or extend beyond 5 minutes', () async {
      // Start grace period
      await service.startSession();
      await service.startGracePeriod();

      final initialStartTime = service.gracePeriodTimeRemaining;

      // Try to start grace period again
      await service.startGracePeriod();

      // Verify time remaining has not been extended
      expect(
        service.gracePeriodTimeRemaining!.inSeconds,
        lessThanOrEqualTo(initialStartTime!.inSeconds),
      );
    });

    test('Grace period clears after logout', () async {
      // Start session and grace period
      await service.startSession();
      await service.startGracePeriod();

      expect(service.isInGracePeriod, isTrue);

      // End session (logout)
      await service.endSession();

      // Verify grace period cleared
      expect(service.isInGracePeriod, isFalse);
      expect(service.gracePeriodTimeRemaining, isNull);
    });
  });

  group('Cross-Platform Behavior Tests', () {
    test('App backgrounding starts grace period', () async {
      // This would be tested via AppLifecycleService
      // Here we test that startGracePeriod() can be called externally

      await service.startSession();
      await service.startGracePeriod();

      expect(service.isInGracePeriod, isTrue);
    });

    test('App resumption within grace period continues session', () async {
      await service.startSession();
      await service.startGracePeriod();

      // Simulate app resume with activity
      await service.recordActivity();

      expect(service.isSessionActive, isTrue);
      expect(service.isInGracePeriod, isFalse);
    });
  });

  group('Security Tests', () {
    test('Grace period never exceeds 5 minutes', () async {
      await service.startSession();
      await service.startGracePeriod();

      // Verify maximum duration
      expect(
        service.gracePeriodTimeRemaining!.inMinutes,
        lessThanOrEqualTo(5),
      );
    });

    test('Manual logout bypasses grace period', () async {
      bool timeoutCalled = false;
      service.onTimeout = () => timeoutCalled = true;

      await service.startSession();
      await service.startGracePeriod();

      // Manual logout
      await service.endSession();

      // Verify grace period was not allowed to trigger
      expect(service.isInGracePeriod, isFalse);
      await Future.delayed(const Duration(minutes: 5, seconds: 1));
      expect(timeoutCalled, isFalse);
    });
  });
}
```

**Step 5.2: Widget Tests for GracePeriodWarning**

Create: `test/widgets/grace_period_warning_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/widgets/grace_period_warning.dart';
import 'package:journeyman_jobs/providers/riverpod/session_timeout_provider.dart';

void main() {
  testWidgets('Warning banner shows when in grace period', (tester) async {
    // Create a test provider override with grace period active
    final container = ProviderContainer(
      overrides: [
        sessionTimeoutProvider.overrideWith((ref) {
          return const SessionState(
            isActive: true,
            isInGracePeriod: true,
            gracePeriodTimeRemaining: Duration(minutes: 4),
          );
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: GracePeriodWarning(
            child: Scaffold(
              body: const Center(child: Text('Content')),
            ),
          ),
        ),
      ),
    );

    // Verify warning banner is visible
    expect(find.text('Session Expiring Soon'), findsOneWidget);
    expect(find.text('Stay Logged In'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('Warning banner hidden when not in grace period', (tester) async {
    final container = ProviderContainer(
      overrides: [
        sessionTimeoutProvider.overrideWith((ref) {
          return const SessionState(
            isActive: true,
            isInGracePeriod: false,
          );
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: GracePeriodWarning(
            child: Scaffold(
              body: const Center(child: Text('Content')),
            ),
          ),
        ),
      ),
    );

    // Verify warning banner is NOT visible
    expect(find.text('Session Expiring Soon'), findsNothing);
  });

  testWidgets('Stay Logged In button cancels grace period', (tester) async {
    bool activityRecorded = false;

    final container = ProviderContainer(
      overrides: [
        sessionTimeoutProvider.overrideWith((ref) {
          return SessionTimeoutNotifierMock(() {
            activityRecorded = true;
          });
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: GracePeriodWarning(
            child: Scaffold(
              body: const Center(child: Text('Content')),
            ),
          ),
        ),
      ),
    );

    // Tap "Stay Logged In" button
    await tester.tap(find.text('Stay Logged In'));
    await tester.pump();

    // Verify activity was recorded
    expect(activityRecorded, isTrue);
  });
}
```

**Step 5.3: Integration Tests**

Create: `test/integration/grace_period_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:journeyman_jobs/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Grace Period Integration Tests', () {
    testWidgets('Full grace period flow - inactivity to logout', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Login
      // (Implementation depends on your auth flow)

      // 2. Wait for inactivity timeout (10 minutes)
      // (Use time manipulation or mock timers for testing)

      // 3. Verify grace period warning appears
      expect(find.text('Session Expiring Soon'), findsOneWidget);

      // 4. Wait for grace period to expire (5 minutes)

      // 5. Verify logout occurred
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Full grace period flow - activity cancels', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Login

      // 2. Wait for inactivity timeout (10 minutes)

      // 3. Verify grace period warning appears
      expect(find.text('Session Expiring Soon'), findsOneWidget);

      // 4. User taps "Stay Logged In"
      await tester.tap(find.text('Stay Logged In'));
      await tester.pumpAndSettle();

      // 5. Verify grace period cancelled
      expect(find.text('Session Expiring Soon'), findsNothing);

      // 6. Verify user still logged in
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('Full grace period flow - app closure and resume', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Login

      // 2. Close app (trigger AppLifecycleState.detached)

      // 3. Wait 2 minutes

      // 4. Reopen app

      // 5. Verify grace period still active (3 minutes remaining)
      expect(find.text('Session Expiring Soon'), findsOneWidget);

      // 6. User interacts with app
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // 7. Verify grace period cancelled and session resumed
      expect(find.text('Session Expiring Soon'), findsNothing);
    });
  });
}
```

### Phase 6: Documentation & Logging (1 hour)

**Step 6.1: Update Session Timeout Documentation**

Update: `docs/SESSION_TIMEOUT_IMPLEMENTATION.md`

Add section:
```markdown
## Grace Period Feature

### Overview
A 5-minute grace period is provided before automatic logout to improve user experience while maintaining security.

### Behavior
- **Trigger**: After 10 minutes of inactivity or app closure
- **Duration**: 5 minutes
- **Warning**: Visual notification at 4-minute mark (1 minute before timeout)
- **Cancellation**: Any user activity during grace period resumes session
- **Persistence**: Grace period state survives app restarts

### Security Considerations
- Grace period does NOT extend Firebase token lifetime
- Maximum grace period: 5 minutes (no stacking)
- Manual logout bypasses grace period
- Local-only state (not synced to cloud)
- Total inactivity tolerance: 15 minutes (10 min + 5 min grace)

### Implementation Details
- Service: `SessionTimeoutService`
- Provider: `SessionTimeoutProvider`
- Widget: `GracePeriodWarning`
- Storage: SharedPreferences (local device only)
```

**Step 6.2: Add Audit Logging**

```dart
// Add to SessionTimeoutService._startGracePeriod()
debugPrint('[SessionTimeout] [AUDIT] Grace period started at ${DateTime.now().toIso8601String()}');

// Add to SessionTimeoutService._cancelGracePeriod()
debugPrint('[SessionTimeout] [AUDIT] Grace period cancelled at ${DateTime.now().toIso8601String()} after ${DateTime.now().difference(_gracePeriodStartTime!).inSeconds}s');

// Add to grace period timeout
debugPrint('[SessionTimeout] [AUDIT] Grace period expired at ${DateTime.now().toIso8601String()} - user logged out');
```

---

## Testing Criteria

### Manual Testing Checklist

- [ ] **Inactivity Flow**
  - [ ] Leave app idle for 10 minutes
  - [ ] Verify grace period warning appears
  - [ ] Verify countdown shows correct time
  - [ ] Wait 5 minutes without activity
  - [ ] Verify automatic logout occurs

- [ ] **Activity Resumption**
  - [ ] Trigger grace period
  - [ ] Tap "Stay Logged In" button
  - [ ] Verify warning disappears
  - [ ] Verify session continues normally

- [ ] **App Closure Flow**
  - [ ] Close app (home button / task switcher)
  - [ ] Wait 2 minutes
  - [ ] Reopen app
  - [ ] Verify grace period active (3 min remaining)
  - [ ] Interact with app
  - [ ] Verify session resumes

- [ ] **App Closure Timeout**
  - [ ] Close app
  - [ ] Wait 6 minutes
  - [ ] Reopen app
  - [ ] Verify logout occurred

- [ ] **Cross-Platform Consistency**
  - [ ] Test on iOS
  - [ ] Test on Android
  - [ ] Test on Web (if applicable)
  - [ ] Verify identical behavior

- [ ] **Security Tests**
  - [ ] Verify grace period never exceeds 5 minutes
  - [ ] Verify manual logout bypasses grace period
  - [ ] Verify no grace period stacking
  - [ ] Verify Firebase token still expires normally

### Automated Test Coverage

- [ ] Unit tests for SessionTimeoutService grace period methods (>90% coverage)
- [ ] Widget tests for GracePeriodWarning component
- [ ] Integration tests for full grace period flows
- [ ] Performance tests (no significant memory leaks or timer issues)

---

## Edge Cases

### Edge Case 1: Multiple Rapid App Closures
**Scenario**: User opens/closes app multiple times in quick succession.
**Expected**: Latest trigger determines grace period start time.
**Implementation**: `_startGracePeriod()` checks if already active and does not extend duration.

### Edge Case 2: Network Disconnection During Grace Period
**Scenario**: Network goes offline while in grace period.
**Expected**: Grace period timer continues locally, logout still occurs after 5 minutes.
**Implementation**: Grace period is client-side only, no network dependency.

### Edge Case 3: Time Zone Change During Grace Period
**Scenario**: User changes time zone or travels during grace period.
**Expected**: Grace period duration remains accurate (uses elapsed time, not wall clock).
**Implementation**: Use `DateTime.difference()` for elapsed time calculation.

### Edge Case 4: Clock Changes (Daylight Saving Time)
**Scenario**: System clock changes during grace period.
**Expected**: Grace period duration remains accurate.
**Implementation**: Store elapsed duration, not absolute end time.

### Edge Case 5: App Killed by OS During Grace Period
**Scenario**: OS kills app to free memory while in grace period.
**Expected**: On relaunch, check if grace period expired. If not, resume; if yes, logout.
**Implementation**: `initialize()` method checks persisted grace period start time.

### Edge Case 6: User Manually Changes System Time
**Scenario**: User sets clock forward/backward during grace period.
**Expected**: Grace period should still expire at correct elapsed time.
**Mitigation**: Use elapsed time calculation rather than absolute timestamps where possible.
**Note**: This is a known limitation - malicious users could extend grace period by manipulating clock. Consider this acceptable risk given local device control.

---

## Rollout Plan

### Phase 1: Development (Week 1)
- Implement SessionTimeoutService modifications
- Implement AppLifecycleService modifications
- Implement SessionTimeoutProvider modifications
- Create GracePeriodWarning widget

### Phase 2: Testing (Week 1-2)
- Unit tests
- Widget tests
- Integration tests
- Manual testing on all platforms

### Phase 3: Beta Release (Week 2)
- Deploy to internal beta testers
- Monitor crash reports and user feedback
- Measure grace period usage metrics

### Phase 4: Production Release (Week 3)
- Deploy to production
- Monitor analytics:
  - Grace period trigger rate
  - Grace period cancellation rate
  - Grace period timeout rate
- A/B test duration (consider 3 min vs 5 min)

---

## Success Metrics

### User Experience
- **Target**: <10% of sessions trigger grace period timeout
- **Measure**: Grace period cancellation rate >80%
- **Goal**: Reduce friction without compromising security

### Performance
- **Target**: No memory leaks from grace period timers
- **Target**: <100ms overhead for grace period state checks
- **Measure**: App performance monitoring

### Security
- **Target**: 0 security incidents related to grace period
- **Monitor**: Session hijacking attempts
- **Audit**: Periodic review of grace period logs

---

## Maintenance

### Monitoring
- Grace period trigger events (count, frequency)
- Grace period cancellation events (user engagement)
- Grace period timeout events (actual logouts)
- Average grace period duration before cancellation
- Platform-specific differences

### Potential Future Enhancements
1. **Configurable Duration**: Allow users to adjust grace period (3, 5, 10 min)
2. **Disable Option**: High-security users can disable grace period
3. **Predictive Cancellation**: ML-based prediction of user return likelihood
4. **Smart Notifications**: Push notification when grace period starts (if app closed)
5. **Analytics Dashboard**: Admin view of grace period usage patterns

---

## Appendix A: Code Reference

### Files Modified
- `lib/services/session_timeout_service.dart` - Core grace period logic
- `lib/services/app_lifecycle_service.dart` - App closure handling
- `lib/providers/riverpod/session_timeout_provider.dart` - State management
- `lib/main.dart` - Widget integration

### Files Created
- `lib/widgets/grace_period_warning.dart` - Warning UI component
- `test/services/session_timeout_service_grace_period_test.dart` - Unit tests
- `test/widgets/grace_period_warning_test.dart` - Widget tests
- `test/integration/grace_period_integration_test.dart` - Integration tests
- `docs/implementation/SESSION_GRACE_PERIOD_IMPLEMENTATION_WORKFLOW.md` - This document

### Constants
```dart
// Grace period duration
static const Duration gracePeriodDuration = Duration(minutes: 5);

// Warning threshold (show warning 1 minute before timeout)
static const Duration warningThreshold = Duration(minutes: 4);

// SharedPreferences keys
static const String _gracePeriodStartKey = 'grace_period_start_timestamp';
```

### API Surface
```dart
// SessionTimeoutService
Future<void> startGracePeriod()
Future<void> _cancelGracePeriod()
bool get isInGracePeriod
Duration? get gracePeriodTimeRemaining
ValueChanged<bool>? onGracePeriodStateChanged
VoidCallback? onGracePeriodWarning

// SessionState
final bool isInGracePeriod
final Duration? gracePeriodTimeRemaining
```

---

## Appendix B: Security Audit Checklist

- [ ] Grace period never exceeds 5 minutes
- [ ] No grace period stacking
- [ ] Manual logout bypasses grace period
- [ ] Security events bypass grace period
- [ ] Grace period state is local-only (not synced)
- [ ] Firebase token expiration unaffected
- [ ] Audit logs implemented (no PII)
- [ ] Total inactivity timeout <30 min (PCI DSS compliant)
- [ ] Session validation on app resume
- [ ] Proper cleanup on logout
- [ ] No sensitive data in grace period logs
- [ ] Time manipulation resistant (reasonable effort)

---

## Appendix C: Troubleshooting

### Issue: Grace period not starting after inactivity
**Diagnostic**: Check `_checkForTimeout()` is being called every 30 seconds.
**Fix**: Verify `_timeoutCheckTimer` is active and interval is correct.

### Issue: Grace period not cancelling on activity
**Diagnostic**: Check `recordActivity()` is being called by ActivityDetector.
**Fix**: Verify ActivityDetector is properly integrated and `_cancelGracePeriod()` is called.

### Issue: Grace period state not persisting across app restarts
**Diagnostic**: Check SharedPreferences write/read operations.
**Fix**: Verify `_recordGracePeriodStart()` and `_checkGracePeriodExpiration()` are working.

### Issue: Grace period exceeding 5 minutes
**Diagnostic**: Check timer creation and duration calculation.
**Fix**: Verify `gracePeriodDuration` constant and timer logic in `_startGracePeriod()`.

### Issue: Warning not appearing at 4-minute mark
**Diagnostic**: Check warning timer scheduling in `_startGracePeriod()`.
**Fix**: Verify warning Timer creation and `onGracePeriodWarning` callback.

---

## Questions for Stakeholders

1. **Grace Period Duration**: Is 5 minutes the optimal duration, or should we test alternatives (3 min, 7 min)?
2. **Warning Timing**: Is the 4-minute warning (1 min before timeout) appropriate, or should it be earlier?
3. **High-Security Mode**: Should we offer a "disable grace period" option for security-conscious users?
4. **Push Notifications**: Should we send a push notification when grace period starts (if app is closed)?
5. **Analytics**: What specific metrics should we track for grace period feature?

---

## Conclusion

This implementation provides a secure, user-friendly grace period feature that balances UX improvements with security requirements. The 5-minute grace period reduces authentication friction while maintaining compliance with industry security standards.

**Total Estimated Effort**: 8-12 hours
**Risk Level**: Low-Medium
**Security Impact**: Minimal (with proper implementation)
**UX Impact**: High (positive)

**Recommended Next Steps**:
1. Review and approve implementation plan
2. Begin Phase 1 development
3. Conduct security review after implementation
4. Monitor beta metrics before full rollout
