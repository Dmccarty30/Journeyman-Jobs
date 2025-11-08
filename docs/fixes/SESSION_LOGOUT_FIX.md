# Fix for Automatic Logout Issue in Crews/Tailboard Screens

## Problem Description
Users were experiencing automatic logout approximately every 5 seconds when navigating to the crews feature or tailboard screen. This was caused by conflicting session management services triggering rapid logout cascades.

## Root Cause Analysis

### Multiple Conflicting Session Services

1. **SessionTimeoutService** (`lib/services/session_timeout_service.dart`)
   - Checks for timeout every 15 seconds
   - Long timeouts (20 min idle + 15 min grace = 35 min total)
   - Verbose debug logging every check

2. **SessionMonitor Provider** (`lib/providers/riverpod/auth_riverpod_provider.dart`)
   - Checks session validity every 5 minutes
   - Calls `authService.isTokenValid()`
   - Forces sign out if token is invalid

3. **Stream Chat Initialization**
   - When navigating to crews/tailboard, Stream Chat client initializes
   - Triggers Firebase Auth token checks
   - Can cause auth state changes that trigger logout

4. **App Lifecycle Service**
   - Monitors app lifecycle changes
   - Can trigger logout when app state changes

### The Conflict Cascade

1. User navigates to crews/tailboard screen
2. Stream Chat initializes and requests a token
3. This triggers an auth state change
4. SessionMonitor detects an "invalid" state
5. Immediate logout is triggered (appears as 5-second logout)

## Solution Implemented

### 1. Created UnifiedSessionService
**File**: `lib/services/unified_session_service.dart`

This new service consolidates all session management logic:
- Single source of truth for session state
- Debounced auth checks (2-second delay) to prevent rapid logout cascades
- Coordinated timeout handling
- Safe Stream Chat integration with temporary debounce increase
- Prevents conflicts between multiple services

### 2. Updated Main App Initialization
**File**: `lib/main.dart`

- Replaced separate SessionTimeoutService and AppLifecycleService with UnifiedSessionService
- Simplified initialization to prevent service conflicts

### 3. Updated Stream Chat Service
**File**: `lib/services/stream_chat_service.dart`

- Stream Chat initialization now wrapped in `initializeStreamChatSafely()`
- Temporarily increases debounce delay during initialization
- Prevents auth conflicts when requesting tokens

### 4. Disabled SessionMonitor
**File**: `lib/providers/riverpod/auth_riverpod_provider.dart`

- Commented out SessionMonitor provider that was causing conflicts
- Session monitoring now handled by UnifiedSessionService

### 5. Updated Activity Detection
**File**: `lib/widgets/activity_detector.dart`

- Activity detector now uses UnifiedSessionService
- Maintains backward compatibility with existing provider

## Key Features of the Fix

### Debounced Logout
- 2-second delay before executing logout
- Prevents rapid sign-out cascades
- Can be cancelled if auth state restores

### Safe Stream Chat Integration
- `initializeStreamChatSafely()` wrapper prevents conflicts
- Temporarily increases debounce during sensitive operations
- Graceful error handling without triggering logout

### Single Source of Truth
- All session state managed in one service
- No conflicting timers or auth checks
- Coordinated lifecycle management

## Testing the Fix

1. Navigate to crews feature
2. Navigate to tailboard screen
3. Verify no automatic logout occurs
4. Test Stream Chat functionality
5. Verify session timeout still works after actual inactivity

## Files Modified

1. **Created**: `lib/services/unified_session_service.dart`
2. **Modified**: `lib/main.dart`
3. **Modified**: `lib/services/stream_chat_service.dart`
4. **Modified**: `lib/providers/riverpod/auth_riverpod_provider.dart`
5. **Modified**: `lib/providers/riverpod/session_timeout_provider.dart`
6. **Modified**: `lib/widgets/activity_detector.dart`
7. **Created**: `docs/fixes/SESSION_LOGOUT_FIX.md`

## Future Considerations

1. Consider removing SessionTimeoutService completely once UnifiedSessionService is fully tested
2. Implement proper unit tests for UnifiedSessionService
3. Add more comprehensive error logging for debugging session issues
4. Consider making the debounce delay configurable via app settings