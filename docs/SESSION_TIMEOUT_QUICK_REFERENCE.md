# Session Timeout - Quick Reference

## Quick Setup (Already Done)

The session timeout system is **already integrated** in your app. No additional setup needed!

### What's Already Configured

✅ **main.dart** - Session timeout service initialized
✅ **main.dart** - App lifecycle monitoring enabled
✅ **main.dart** - Activity detector wraps entire app
✅ **Providers** - Riverpod integration complete
✅ **Navigation** - Auto-redirect to auth on timeout

---

## How It Works (User Perspective)

### Scenario 1: Inactivity Timeout
```
1. User logs in ✓
2. User navigates around app (activity detected) ✓
3. User puts phone down for 10 minutes ⏰
4. App automatically logs user out 🔒
5. User picks up phone and sees login screen 📱
```

### Scenario 2: App Closure
```
1. User logs in ✓
2. User closes app (swipes away from recent apps) 📱
3. App detects closure and ends session 🔒
4. User reopens app later
5. User sees login screen (must re-authenticate) 📱
```

### Scenario 3: App Resume
```
1. User logs in ✓
2. User sends app to background (home button) 📱
3. User returns to app within 10 minutes
4. Session continues (activity recorded) ✓
5. User continues using app normally
```

---

## File Locations

### Core Services
- **Session Timeout Logic:** `lib/services/session_timeout_service.dart`
- **App Lifecycle:** `lib/services/app_lifecycle_service.dart`
- **Auth Service:** `lib/services/auth_service.dart`

### Providers
- **Session Provider:** `lib/providers/riverpod/session_timeout_provider.dart`
- **Auth Provider:** `lib/providers/riverpod/auth_riverpod_provider.dart`

### Widgets
- **Activity Detector:** `lib/widgets/activity_detector.dart`

### Configuration
- **Main App:** `lib/main.dart`
- **Router:** `lib/navigation/app_router.dart`

---

## Configuration Constants

### Timeout Duration (10 minutes)
```dart
// File: lib/services/session_timeout_service.dart
static const Duration timeoutDuration = Duration(minutes: 10);
```

### Check Interval (30 seconds)
```dart
// File: lib/services/session_timeout_service.dart
static const Duration _checkInterval = Duration(seconds: 30);
```

### Activity Throttle (1 second)
```dart
// File: lib/widgets/activity_detector.dart
static const _throttleDuration = Duration(seconds: 1);
```

---

## Common Tasks

### View Session State in UI

```dart
// In any widget
final sessionState = ref.watch(sessionTimeoutNotifierProvider);

print('Session active: ${sessionState.isActive}');
print('Last activity: ${sessionState.lastActivity}');
print('Time until timeout: ${sessionState.timeUntilTimeout}');
```

### Manually Record Activity

```dart
// If you need to manually trigger activity (usually not needed)
final notifier = ref.read(sessionTimeoutNotifierProvider.notifier);
await notifier.recordActivity();
```

### Manually Trigger Timeout (Testing)

```dart
// Force logout for testing
final notifier = ref.read(sessionTimeoutNotifierProvider.notifier);
await notifier.triggerTimeout();
```

### Add Custom Timeout Callback

```dart
// In main.dart or initialization code
_sessionTimeoutService.onTimeout = () {
  // Custom logic before logout
  print('Session timed out!');
  // Logout happens automatically via provider
};
```

---

## Testing Checklist

### Manual Testing

1. **Inactivity Test**
   - [ ] Login
   - [ ] Wait 10 minutes without touching device
   - [ ] Verify auto-logout and redirect to login

2. **Activity Test**
   - [ ] Login
   - [ ] Tap, scroll, navigate every few minutes
   - [ ] Wait 15+ minutes with continuous activity
   - [ ] Verify NO logout occurs

3. **App Closure Test**
   - [ ] Login
   - [ ] Close app completely (remove from recent apps)
   - [ ] Reopen app
   - [ ] Verify auto-logout occurred

4. **App Background Test**
   - [ ] Login
   - [ ] Send app to background (home button)
   - [ ] Resume app within 10 minutes
   - [ ] Verify session continues
   - [ ] Send app to background again
   - [ ] Wait 10+ minutes
   - [ ] Resume app
   - [ ] Verify logout occurred

---

## Debugging

### Enable Debug Logging

Session timeout already includes debug logging:

```
[SessionTimeout] Service initialized
[SessionTimeout] Session started
[SessionTimeout] Session active - timeout in 9m 30s
[SessionTimeout] Session timed out after 10 minutes of inactivity
[SessionTimeout] Session ended
```

Look for these logs in your console when running the app.

### Check Session State

Add this to any screen for debugging:

```dart
final sessionState = ref.watch(sessionTimeoutNotifierProvider);
print('DEBUG - Session: ${sessionState.isActive}, '
      'Time left: ${sessionState.timeUntilTimeout?.inMinutes}m');
```

### Verify Activity Detection

```dart
ActivityDetector(
  onActivity: () {
    print('DEBUG - Activity detected!'); // Add this for debugging
  },
  child: YourAppWidget(),
)
```

---

## Troubleshooting

### Issue: Session not starting after login

**Fix:** Verify ProviderScope wraps your app in main.dart

```dart
runApp(const ProviderScope(child: MyApp()));
```

### Issue: Activity not detected

**Fix:** Ensure ActivityDetector wraps your MaterialApp.router

```dart
MaterialApp.router(
  builder: (context, child) {
    return ActivityDetector(child: child ?? const SizedBox.shrink());
  },
)
```

### Issue: User not logged out on app closure

**Fix:** Verify AppLifecycleService is initialized with SessionTimeoutService

```dart
final lifecycleService = AppLifecycleService(authService, sessionTimeoutService);
lifecycleService.initialize();
```

---

## Optional Enhancements

### Add Timeout Warning Banner

Wrap screens with `SessionTimeoutWarning`:

```dart
@override
Widget build(BuildContext context) {
  return SessionTimeoutWarning(
    warningThreshold: Duration(minutes: 2), // Warn 2 min before timeout
    child: Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: MyContent(),
    ),
  );
}
```

### Customize Timeout Duration

Change in `SessionTimeoutService`:

```dart
// 5 minute timeout instead of 10
static const Duration timeoutDuration = Duration(minutes: 5);
```

### Track Session Analytics

Add to session callbacks:

```dart
_sessionTimeoutService.onTimeout = () async {
  // Track timeout event
  await FirebaseAnalytics.instance.logEvent(
    name: 'session_timeout',
    parameters: {'reason': 'inactivity'},
  );
};
```

---

## API Reference

### SessionTimeoutService

```dart
// Initialize (call in main.dart)
await SessionTimeoutService().initialize();

// Start session (automatic via provider)
await service.startSession();

// Record activity (automatic via ActivityDetector)
await service.recordActivity();

// End session (automatic on logout)
await service.endSession();

// Query session state
bool isActive = service.isSessionActive;
DateTime? lastActivity = service.lastActivity;
Duration? timeLeft = service.timeUntilTimeout;

// Callbacks
service.onTimeout = () async { /* ... */ };
service.onSessionStateChanged = (isActive) { /* ... */ };
```

### SessionTimeoutNotifier (Riverpod)

```dart
// Watch session state
final sessionState = ref.watch(sessionTimeoutNotifierProvider);

// Read notifier
final notifier = ref.read(sessionTimeoutNotifierProvider.notifier);

// Methods
await notifier.recordActivity();
await notifier.triggerTimeout();
SessionState state = notifier.getState();
```

### ActivityDetector

```dart
ActivityDetector(
  child: Widget, // Required
  onActivity: VoidCallback?, // Optional debug callback
)
```

### SessionTimeoutWarning

```dart
SessionTimeoutWarning(
  child: Widget, // Required
  warningThreshold: Duration, // Default: 2 minutes
)
```

---

## Important Notes

1. **Network Not Required:** Session timeout works offline
2. **Battery Impact:** Minimal - checks every 30 seconds
3. **Security:** Three-layer protection (session, token, expiration)
4. **Platform Support:** iOS, Android, Web (with proper testing)
5. **State Persistence:** Uses SharedPreferences (platform-optimized)

---

## Need Help?

See full documentation: `docs/SESSION_TIMEOUT_IMPLEMENTATION.md`

Or search codebase for:
- "SessionTimeoutService" - Core logic
- "SessionTimeoutNotifier" - State management
- "ActivityDetector" - User interaction tracking
- "[SessionTimeout]" - Debug logs
