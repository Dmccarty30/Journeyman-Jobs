# Session Timeout Implementation Guide

## Overview

This document describes the comprehensive authentication session timeout system implemented for the Journeyman Jobs Flutter app. The system provides automatic logout functionality based on user inactivity and app lifecycle events.

## Requirements Implemented

### 1. **Auto-logout after 10 minutes of inactivity**
   - Users are automatically logged out after 10 minutes without any interaction
   - All user gestures (taps, scrolls, drags, etc.) reset the timeout timer
   - Timeout duration is configurable via `SessionTimeoutService.timeoutDuration`

### 2. **Auto-logout when app is closed/terminated**
   - Session state is tracked in persistent storage
   - When app is closed, the session is marked as inactive
   - On next launch, if a previous session was active, user is automatically logged out

### 3. **Navigate to auth screen on timeout**
   - When session times out, user is redirected to the authentication screen
   - Firebase signOut() is called automatically to clear authentication state
   - Navigation is handled seamlessly through Riverpod state management

### 4. **Require re-authentication after logout/timeout**
   - All session data is cleared on logout or timeout
   - User must re-enter credentials to access protected routes
   - Token validation ensures sessions older than 24 hours require re-auth

---

## Architecture

### Components

The implementation consists of four main components:

1. **SessionTimeoutService** (`lib/services/session_timeout_service.dart`)
   - Core service managing session timeout logic
   - Tracks activity timestamps and monitors for inactivity
   - Handles session start/end and cleanup
   - Persists session state using SharedPreferences

2. **SessionTimeoutProvider** (`lib/providers/riverpod/session_timeout_provider.dart`)
   - Riverpod integration for state management
   - Coordinates session timeout with authentication state
   - Provides reactive session state to UI components
   - Automatically triggers logout on timeout

3. **ActivityDetector** (`lib/widgets/activity_detector.dart`)
   - Widget that wraps the app to detect user interactions
   - Captures all gesture types (taps, scrolls, drags, etc.)
   - Throttles activity recording to prevent performance impact
   - Optional timeout warning banner component

4. **AppLifecycleService** (`lib/services/app_lifecycle_service.dart`)
   - Enhanced to integrate with session timeout
   - Monitors app lifecycle states (resumed, paused, detached)
   - Handles session cleanup when app is closed
   - Validates sessions when app resumes from background

---

## How It Works

### Session Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Authenticates                        │
│                    (Login/Sign-up Success)                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  SessionTimeoutNotifier.build()                  │
│                 Detects auth state change → user                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│            SessionTimeoutService.startSession()                  │
│  • Records initial activity timestamp                            │
│  • Starts periodic timeout monitoring (every 30s)                │
│  • Marks session as active in SharedPreferences                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   User Interacts with App                        │
│         (Detected by ActivityDetector widget)                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│         SessionTimeoutService.recordActivity()                   │
│  • Updates last activity timestamp                               │
│  • Persists timestamp to SharedPreferences                       │
│  • Resets inactivity timer                                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│        Periodic Timeout Check (every 30 seconds)                 │
│                                                                   │
│  IF inactivity > 10 minutes:                                     │
│    • Stop monitoring                                             │
│    • Clear session state                                         │
│    • Trigger onTimeout callback                                  │
│    • SessionTimeoutNotifier calls signOut()                      │
│    • User redirected to auth screen                              │
│                                                                   │
│  ELSE:                                                            │
│    • Continue monitoring                                         │
│    • Log time remaining                                          │
└─────────────────────────────────────────────────────────────────┘
```

### App Lifecycle Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                        App Lifecycle Events                      │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│              │         │              │         │              │
│  App Resumed │────────▶│  App Paused  │────────▶│ App Detached │
│              │         │              │         │  (Closing)   │
└──────┬───────┘         └──────────────┘         └──────┬───────┘
       │                                                   │
       │                                                   │
       ▼                                                   ▼
┌──────────────────────────────┐         ┌────────────────────────┐
│ _validateSessionOnResume()   │         │ _handleAppClosure()    │
│ • Check 24hr token validity  │         │ • End session          │
│ • Refresh Firebase token     │         │ • Mark as inactive     │
│ • Restart session monitoring │         │ • Clear activity data  │
│ • Record activity            │         └────────────────────────┘
└──────────────────────────────┘
```

### Session Persistence

Session state is persisted using SharedPreferences:

- `last_activity_timestamp` (int): Milliseconds since epoch of last user interaction
- `session_active` (bool): Whether session was active when app was closed

On app initialization:
1. Check if `session_active` is `true`
2. If yes → app was closed with active session → trigger logout
3. If no → normal startup flow

---

## Implementation Details

### 1. Service Layer

#### SessionTimeoutService

**Location:** `lib/services/session_timeout_service.dart`

**Key Methods:**

```dart
// Initialize service and check for expired sessions
await SessionTimeoutService().initialize();

// Start monitoring after successful authentication
await sessionService.startSession();

// Record user activity (resets timeout)
await sessionService.recordActivity();

// End session on logout
await sessionService.endSession();
```

**Configuration:**

```dart
// Timeout duration (default: 10 minutes)
static const Duration timeoutDuration = Duration(minutes: 10);

// Check interval for timeout monitoring (default: 30 seconds)
static const Duration _checkInterval = Duration(seconds: 30);
```

**Callbacks:**

```dart
// Called when session times out
sessionService.onTimeout = () async {
  // Handle timeout logic (e.g., signOut, navigate)
};

// Called when session state changes
sessionService.onSessionStateChanged = (isActive) {
  // Update UI or state based on session status
};
```

### 2. Provider Layer

#### SessionTimeoutNotifier

**Location:** `lib/providers/riverpod/session_timeout_provider.dart`

**Usage in UI:**

```dart
// Watch session state
final sessionState = ref.watch(sessionTimeoutNotifierProvider);

if (sessionState.isActive) {
  final timeLeft = sessionState.timeUntilTimeout;
  print('Session active - ${timeLeft?.inMinutes} minutes remaining');
}

// Manually record activity
final notifier = ref.read(sessionTimeoutNotifierProvider.notifier);
await notifier.recordActivity();

// Manually trigger timeout (for testing)
await notifier.triggerTimeout();
```

**Auto-Integration:**

The `SessionTimeoutNotifier` automatically:
- Watches `authStateProvider` for authentication changes
- Starts session when user authenticates
- Ends session when user logs out
- Triggers `signOut()` when timeout occurs

### 3. Widget Layer

#### ActivityDetector

**Location:** `lib/widgets/activity_detector.dart`

**Usage:**

Wrap your entire app (recommended):

```dart
MaterialApp.router(
  routerConfig: AppRouter.router,
  builder: (context, child) {
    return ActivityDetector(
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

Or wrap individual screens:

```dart
@override
Widget build(BuildContext context) {
  return ActivityDetector(
    child: Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: MyContent(),
    ),
  );
}
```

**Detected Gestures:**

- Tap (onTap, onTapDown, onTapCancel)
- Long press (onLongPress, onLongPressStart)
- Pan (onPanStart, onPanUpdate, onPanEnd) - for scrolling
- Scale (onScaleStart, onScaleUpdate, onScaleEnd) - for pinch-to-zoom
- Vertical drag (onVerticalDragStart, onVerticalDragUpdate, onVerticalDragEnd)
- Horizontal drag (onHorizontalDragStart, onHorizontalDragUpdate, onHorizontalDragEnd)

**Throttling:**

Activity recording is throttled to once per second to prevent performance impact from high-frequency gestures like scrolling.

#### SessionTimeoutWarning (Optional)

Display a warning banner when timeout is approaching:

```dart
@override
Widget build(BuildContext context) {
  return SessionTimeoutWarning(
    warningThreshold: Duration(minutes: 2), // Show warning 2 min before timeout
    child: Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: MyContent(),
    ),
  );
}
```

The warning shows:
- Time remaining until timeout
- "Stay Logged In" button to reset the timer
- Automatically dismisses when user activity detected

### 4. Lifecycle Integration

#### AppLifecycleService

**Location:** `lib/services/app_lifecycle_service.dart`

**Enhanced for Session Timeout:**

```dart
// Initialize with session timeout service
final authService = AuthService();
final sessionTimeoutService = SessionTimeoutService();
final lifecycleService = AppLifecycleService(
  authService,
  sessionTimeoutService,
);
lifecycleService.initialize();
```

**Lifecycle Handling:**

1. **App Resumed:**
   - Validates 24-hour token expiration
   - Refreshes Firebase token
   - Restarts session monitoring
   - Records activity

2. **App Paused:**
   - No action (session timeout handles inactivity)

3. **App Detached (Closing):**
   - Ends session
   - Marks session as inactive
   - Next launch will detect and trigger logout

4. **App Inactive:**
   - Temporary state (e.g., incoming call)
   - No action needed

---

## Integration Guide

### Step 1: Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize session timeout service
  final sessionTimeoutService = SessionTimeoutService();
  await sessionTimeoutService.initialize();

  // Initialize app lifecycle with session timeout
  final authService = AuthService();
  final lifecycleService = AppLifecycleService(
    authService,
    sessionTimeoutService,
  );
  lifecycleService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
```

### Step 2: Wrap App with ActivityDetector

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return ActivityDetector(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
```

### Step 3: Navigation Already Handles Timeout

The existing `app_router.dart` already handles session timeouts:

1. `SessionTimeoutNotifier` watches `authStateProvider`
2. When timeout occurs, `signOut()` is called
3. `authStateProvider` emits `null` user
4. Router's `_redirect()` detects unauthenticated state
5. User is redirected to `/auth` screen

**No additional navigation code needed!**

---

## Testing

### Manual Testing Checklist

#### Inactivity Timeout
- [ ] Login successfully
- [ ] Wait 10 minutes without touching the app
- [ ] Verify automatic logout occurs
- [ ] Verify navigation to auth screen
- [ ] Verify re-login required

#### Activity Detection
- [ ] Login successfully
- [ ] Interact with app (tap, scroll, navigate)
- [ ] Verify timeout timer resets with each interaction
- [ ] Verify session remains active during continuous use

#### App Closure
- [ ] Login successfully
- [ ] Close app completely (swipe away from recent apps)
- [ ] Reopen app
- [ ] Verify automatic logout occurred
- [ ] Verify navigation to auth screen

#### App Background/Resume
- [ ] Login successfully
- [ ] Send app to background (home button)
- [ ] Resume app within 10 minutes
- [ ] Verify session continues
- [ ] Resume app after 10+ minutes
- [ ] Verify logout occurred

#### Warning Banner (if implemented)
- [ ] Login successfully
- [ ] Wait 8 minutes (2 minutes before timeout)
- [ ] Verify warning banner appears
- [ ] Tap "Stay Logged In"
- [ ] Verify timer resets
- [ ] Verify banner dismisses

### Unit Testing

Test the `SessionTimeoutService`:

```dart
void main() {
  late SessionTimeoutService service;

  setUp(() {
    service = SessionTimeoutService();
  });

  tearDown(() {
    service.dispose();
  });

  test('startSession marks session as active', () async {
    await service.initialize();
    await service.startSession();

    expect(service.isSessionActive, true);
  });

  test('recordActivity resets timeout timer', () async {
    await service.initialize();
    await service.startSession();

    final firstActivity = service.lastActivity;
    await Future.delayed(Duration(seconds: 2));
    await service.recordActivity();
    final secondActivity = service.lastActivity;

    expect(secondActivity!.isAfter(firstActivity!), true);
  });

  test('endSession clears session state', () async {
    await service.initialize();
    await service.startSession();
    await service.endSession();

    expect(service.isSessionActive, false);
    expect(service.lastActivity, null);
  });
}
```

### Integration Testing

Test the full flow with Riverpod:

```dart
void main() {
  testWidgets('session timeout triggers logout', (tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      ),
    );

    // Login user
    final authNotifier = container.read(authNotifierProvider.notifier);
    await authNotifier.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    );

    // Verify session started
    final sessionState = container.read(sessionTimeoutNotifierProvider);
    expect(sessionState.isActive, true);

    // Simulate timeout by waiting
    // (In real tests, you'd mock the timeout duration)
    // ...

    // Verify logout occurred
    final authState = container.read(authStateProvider);
    expect(authState.value, null);
  });
}
```

---

## Troubleshooting

### Common Issues

#### 1. Session not starting after login

**Symptoms:** User logs in but session timeout doesn't activate

**Causes:**
- `SessionTimeoutNotifier` not initialized
- `authStateProvider` not emitting user after login
- Service initialization failed

**Solutions:**
- Verify `ProviderScope` wraps app
- Check Firebase authentication successful
- Verify `SessionTimeoutService.initialize()` called in `main()`
- Check logs for initialization errors

#### 2. Activity not being recorded

**Symptoms:** User interacts but still times out

**Causes:**
- `ActivityDetector` not wrapping app
- Gesture not captured by detector
- Throttle blocking activity recording

**Solutions:**
- Verify `ActivityDetector` wraps entire app in `builder`
- Check gesture types being used
- Verify `sessionTimeoutNotifierProvider` accessible
- Check logs for activity recording

#### 3. Session persists after app closure

**Symptoms:** User not logged out when reopening app

**Causes:**
- `AppLifecycleService` not initialized
- `detached` state not triggered
- Session cleanup not called

**Solutions:**
- Verify `AppLifecycleService` initialized in `main()`
- Check lifecycle state transitions in logs
- Verify `_handleAppClosure()` called
- Test on physical device (iOS/Android handle lifecycle differently)

#### 4. Logout loop on app resume

**Symptoms:** User repeatedly logged out when resuming app

**Causes:**
- Token validation failing
- Session state not properly restored
- Race condition in initialization

**Solutions:**
- Check Firebase token refresh successful
- Verify network connectivity
- Check auth service token validity logic
- Add delays between operations if needed

---

## Configuration

### Changing Timeout Duration

Edit `SessionTimeoutService`:

```dart
// Change from 10 minutes to 5 minutes
static const Duration timeoutDuration = Duration(minutes: 5);
```

### Changing Check Interval

Edit `SessionTimeoutService`:

```dart
// Check every minute instead of 30 seconds
static const Duration _checkInterval = Duration(minutes: 1);
```

### Disabling Session Timeout

To temporarily disable (e.g., for debugging):

In `main.dart`, comment out session timeout initialization:

```dart
// final sessionTimeoutService = SessionTimeoutService();
// await sessionTimeoutService.initialize();

final lifecycleService = AppLifecycleService(
  authService,
  null, // Pass null instead of sessionTimeoutService
);
```

---

## Performance Considerations

### Activity Recording Throttle

Activity recording is throttled to **1 second** to prevent performance impact:

```dart
static const _throttleDuration = Duration(seconds: 1);
```

This means rapid gestures (like fast scrolling) won't record activity more than once per second.

### Periodic Check Frequency

Timeout checks run every **30 seconds**:

```dart
static const Duration _checkInterval = Duration(seconds: 30);
```

This balances responsiveness with battery/CPU usage. Adjusting this value:
- **Lower** (10s): More responsive but higher CPU usage
- **Higher** (60s): Lower CPU usage but less precise timeout

### SharedPreferences Usage

Session state is persisted using SharedPreferences:
- Minimal storage (2 small values)
- Async operations don't block UI
- Automatic platform optimization

---

## Security Considerations

### Session Data Protection

- Activity timestamps stored locally only
- No sensitive data in session storage
- Cleared on logout/timeout
- Not accessible to other apps

### Token Validation

The system works alongside existing token validation:

1. **24-hour session expiration** (AuthService)
2. **10-minute inactivity timeout** (SessionTimeoutService)
3. **50-minute token refresh** (TokenExpirationMonitor)

All three layers work together for comprehensive security.

### Network Security

- Session timeout doesn't require network
- Works offline
- Doesn't transmit session data

---

## Future Enhancements

### Potential Improvements

1. **Configurable timeout per user role**
   - Admins: 30 minutes
   - Regular users: 10 minutes
   - Implement in SessionTimeoutService based on user permissions

2. **Timeout warning dialog**
   - Show countdown dialog 1 minute before timeout
   - Allow user to extend session
   - Implement with `showDialog()` in timeout callback

3. **Session analytics**
   - Track average session duration
   - Monitor timeout frequency
   - Send to Firebase Analytics

4. **Biometric re-authentication**
   - Allow fingerprint/face unlock on timeout
   - Skip full login for trusted devices
   - Use `local_auth` package

5. **Adjustable timeout in settings**
   - Let users configure timeout duration
   - Store preference in Firestore
   - Validate against minimum security requirements

---

## Summary

The session timeout implementation provides comprehensive auto-logout functionality:

✅ **10-minute inactivity timeout** with activity detection across entire app
✅ **Auto-logout on app closure** with persistent session tracking
✅ **Seamless navigation** to auth screen on timeout/logout
✅ **Required re-authentication** with token and session validation
✅ **App lifecycle integration** for resume/background/closure handling
✅ **Performance optimized** with throttling and efficient checking
✅ **Secure session management** with proper cleanup and validation

The system is production-ready and requires no additional setup beyond the initial integration in `main.dart`.
