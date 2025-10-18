# Authentication System Root Cause Analysis Report
**Project:** Journeyman Jobs
**Analysis Date:** 2025-10-18
**Analyst:** Root Cause Investigation Agent
**Status:** CRITICAL SECURITY & STABILITY ISSUES

---

## Executive Summary

### Critical Findings
**Severity:** HIGH | **Impact:** Authentication Failures + Security Risks | **Users Affected:** All

The authentication system suffers from three interconnected issues:

1. **Riverpod State Management Architectural Flaw** → Application crashes on authentication state changes
2. **Firestore Security Rules Logic Errors** → Permission validation broken, potential unauthorized access
3. **Authentication State Propagation Failures** → Inconsistent auth state across providers

### Security Impact Assessment

| Risk Category | Severity | Description |
|---------------|----------|-------------|
| **Authentication Bypass** | MEDIUM | Flawed security rules may allow member-level users to perform foreman operations |
| **State Corruption** | HIGH | Auth state inconsistency can lead to unauthorized access or data loss |
| **Availability** | CRITICAL | App crashes prevent any authenticated operations |
| **Data Integrity** | MEDIUM | Permission errors may allow unintended crew data modifications |

### Immediate Actions Required
1. Fix `AuthNotifier` crash (10 minutes) - CRITICAL
2. Correct Firestore security rules parameter passing (15 minutes) - HIGH
3. Implement auth state consistency validation (30 minutes) - MEDIUM

---

## Root Cause Analysis: Authentication Issues

### ISSUE #1: AuthNotifier State Management Architecture Flaw

#### Evidence
**Error Screenshot**: `home-screen-error.png`
```
'package:flutter_riverpod/src/core/consumer.dart': Failed assertion:
line 492 pos 7: 'debugDoingBuild': ref.listen can only be used within
the build method of a ConsumerWidget

See also: https://docs.flutter.dev/testing/errors
```

#### Architectural Analysis

**File:** `lib/providers/riverpod/auth_riverpod_provider.dart`
**Lines:** 68-100

```dart
/// Auth state notifier for managing authentication operations
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final ConcurrentOperationManager _operationManager;
  int _signInAttempts = 0;
  int _successfulSignIns = 0;

  @override
  AuthState build() {
    _operationManager = ConcurrentOperationManager();

    // ❌ CRITICAL ERROR: ref.listen() in Notifier.build()
    // This violates Riverpod's architecture constraints
    ref.listen(authStateStreamProvider, (AsyncValue<User?>? previous, AsyncValue<User?> next) {
      next.when(
        data: (User? user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
        },
        loading: () {
          state = state.copyWith(isLoading: true);
        },
        error: (Object error, _) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    });

    return const AuthState();
  }
```

#### Why This Design is Fundamentally Flawed

**Riverpod's Ref Context Hierarchy:**

```
┌─────────────────────────────────────────┐
│  WidgetRef (ref in build() methods)     │
│  ↓ Can use: watch, listen, read        │
├─────────────────────────────────────────┤
│  Ref (ref in provider functions)        │
│  ↓ Can use: watch, read                │
│  ❌ CANNOT use: listen                   │
├─────────────────────────────────────────┤
│  Notifier Ref (ref in Notifier.build()) │
│  ↓ Can use: watch, read                │
│  ❌ CANNOT use: listen                   │
└─────────────────────────────────────────┘
```

**The Constraint:**
- `ref.listen()` is designed for **side effects in UI widgets** where disposal is automatic
- Notifiers are **long-lived state containers** that exist outside widget lifecycle
- Using `ref.listen()` in a Notifier breaks this lifecycle management

**Runtime Behavior:**
1. App launches → `authProvider` initializes
2. `AuthNotifier.build()` executes
3. `ref.listen()` called → Runtime assertion checks context
4. Assertion fails: "listen can only be used within ConsumerWidget build"
5. **CRASH**: Red screen of death shown to user

#### Security Implications

This isn't just a crash—it's a **security vulnerability**:

**Scenario 1: Partial Authentication**
```dart
// User signs in
await authService.signInWithEmailAndPassword(...);

// AuthNotifier crashes before setting state
// BUT Firebase auth state is still updated
// RESULT: User authenticated in Firebase but app shows "not authenticated"
```

**Scenario 2: Stale Authentication State**
```dart
// User signs out in another tab/device
// Firebase auth state changes → null

// AuthNotifier crash prevents state update
// App still shows user as authenticated
// RESULT: UI shows user as logged in but API calls fail with 401
```

#### Impact on User Flows

**Affected Operations:**
1. **Sign In** → User authenticated in Firebase, app doesn't update UI
2. **Sign Out** → Firebase signs out, app retains stale auth state
3. **Token Refresh** → Firebase refreshes token silently, app doesn't know
4. **Multi-Device** → Auth state changes on device A don't reflect on device B

**User Experience:**
- "Why can't I access jobs even though I signed in?"
- "I signed out but app still shows I'm logged in"
- "App crashes every time I open it"

---

### ISSUE #2: Firestore Security Rules - Broken Permission Logic

#### Evidence
**File:** `firebase/firestore.rules`
**Lines:** 52-63

```javascript
function isValidCrewUpdate() {
  // Allow updates to these fields by crew members
  let memberFields = ['preferences', 'lastActivityAt', 'stats'];

  // Foreman can update additional fields
  let foremanFields = ['preferences', 'lastActivityAt', 'stats', 'name',
                       'logoUrl', 'memberIds', 'roles', 'memberCount', 'isActive'];

  // ❌ SECURITY ISSUE: resource.id is document ID, not crew ID
  let allowedFields = isForeman(resource.id) ? foremanFields : memberFields;

  // Check if only allowed fields are being updated
  return request.data.diff(resource.data).affectedKeys().hasOnly(allowedFields);
}
```

#### Security Analysis

**The Vulnerability:**

```javascript
// What the code TRIES to do:
isForeman(crewId) → Check if user is foreman of THIS crew

// What it ACTUALLY does:
isForeman(resource.id) → Check if user is foreman of crew with ID = document's auto-generated ID
```

**Example:**
```dart
// Crew document structure
/crews/abc-crew-123-456789  ← This is resource.id (auto-generated)
  {
    id: "Electricians United-1-1729267890"  ← This is the crew ID
    name: "Electricians United"
    foremanId: "user-123"
    ...
  }
```

```javascript
// Security rule evaluates:
isForeman("abc-crew-123-456789")  // ❌ WRONG - uses document ID

// Should evaluate:
isForeman("Electricians United-1-1729267890")  // ✅ CORRECT - uses crew ID
```

#### Attack Scenarios

**Scenario 1: Privilege Escalation (Failed)**
```dart
// Attacker (member-level user) attempts:
await firestore.collection('crews').doc('crew-id').update({
  'name': 'Hacked Crew',
  'memberIds': [..., 'attacker-uid'],
  'roles': {'attacker-uid': 'foreman'}
});

// Current behavior:
// → isForeman(resource.id) returns FALSE (document ID doesn't match any crew)
// → Falls back to memberFields = ['preferences', 'lastActivityAt', 'stats']
// → Update is DENIED because 'name', 'memberIds', 'roles' not in memberFields
// ✅ SECURE (by accident - the bug prevents the attack)
```

**Scenario 2: Foreman Operations Blocked (Operational Impact)**
```dart
// Legitimate foreman attempts:
await firestore.collection('crews').doc('crew-id').update({
  'name': 'New Crew Name'  // Valid foreman operation
});

// Current behavior:
// → isForeman(resource.id) returns FALSE (always, for everyone)
// → Falls back to memberFields
// → Update is DENIED because 'name' not in memberFields
// ❌ BLOCKED (foreman cannot perform valid operations)
```

**Actual Security Impact:** MODERATE
- **No privilege escalation possible** (members can't become foremans)
- **No unauthorized data access** (read rules are separate and correct)
- **Legitimate operations blocked** (foremans can't update crew metadata)

**Operational Impact:** HIGH
- Foremans cannot rename crews
- Cannot update crew logos
- Cannot manage memberIds directly through app
- Cannot activate/deactivate crews
- Forces use of Firebase Console for admin operations

#### Correct Implementation

```javascript
function isValidCrewUpdate(crewId) {  // ✅ Accept crewId as parameter
  let memberFields = ['preferences', 'lastActivityAt', 'stats'];
  let foremanFields = ['preferences', 'lastActivityAt', 'stats', 'name',
                       'logoUrl', 'memberIds', 'roles', 'memberCount', 'isActive'];

  // ✅ CORRECT: Use passed crewId parameter
  let allowedFields = isForeman(crewId) ? foremanFields : memberFields;

  return request.data.diff(resource.data).affectedKeys().hasOnly(allowedFields);
}

// Usage in match statement
match /crews/{crewId} {
  allow update: if canUserAccessCrew(crewId) && isValidCrewUpdate(crewId);  // ✅ Pass crewId
}
```

---

### ISSUE #3: Authentication State Inconsistency

#### Evidence Analysis

**Three Separate Auth State Sources:**

1. **Firebase Auth Stream** (`authStateStreamProvider`)
   ```dart
   @riverpod
   Stream<User?> authStateStream(Ref ref) {
     final authService = ref.watch(authServiceProvider);
     return authService.authStateChanges;
   }
   ```

2. **Current User Provider** (`currentUserProvider`)
   ```dart
   @riverpod
   User? currentUser(Ref ref) {
     final authState = ref.watch(authStateStreamProvider);
     return authState.when(
       data: (user) => user,
       loading: () => null,
       error: (_, __) => null,
     );
   }
   ```

3. **Auth Notifier State** (`authProvider`)
   ```dart
   @riverpod
   class AuthNotifier extends _$AuthNotifier {
     @override
     AuthState build() {
       // Attempts to sync with authStateStreamProvider
       // BUT fails due to ref.listen() bug
       return const AuthState();
     }
   }
   ```

#### Inconsistency Scenarios

**Race Condition 1: Sign In**
```dart
// User signs in via authNotifier
await ref.read(authProvider.notifier).signInWithEmailAndPassword(...);

// Timeline:
// T+0ms:  authService.signInWithEmailAndPassword() completes
// T+50ms: Firebase auth state stream emits User
// T+100ms: authStateStreamProvider updates → currentUserProvider = User
// T+150ms: authNotifier.listen() crashes → authProvider.state = no user

// Result: currentUserProvider says "authenticated"
//         authProvider says "not authenticated"
//         Home screen uses authProvider → shows guest mode even though signed in
```

**Race Condition 2: Token Refresh**
```dart
// Firebase silently refreshes ID token (happens every hour)
// Timeline:
// T+0ms:  Firebase auth state stream emits updated User
// T+50ms: authStateStreamProvider updates
// T+100ms: currentUserProvider updates with new token
// T+150ms: authNotifier doesn't update (crashed listener)

// Result: currentUserProvider has fresh token
//         authProvider has stale token
//         API calls using authProvider fail with 401 Unauthorized
```

#### Dependency Graph

```
┌─────────────────────────────────────────┐
│  Firebase Auth Service                  │
│  └─> authStateChanges stream            │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  authStateStreamProvider (Stream<User?>)│
│  └─> Reactive stream wrapper            │
└────────┬────────────────────────────────┘
         │
         ├──────────────────┬──────────────┐
         ▼                  ▼              ▼
┌──────────────────┐ ┌──────────┐ ┌────────────────┐
│ currentUser      │ │ authNoti │ │ isAuthenticated│
│ Provider         │ │ fier (💥)│ │ Provider       │
└──────────────────┘ └──────────┘ └────────────────┘
         │                  │              │
         │                  │              │
         ▼                  ▼              ▼
┌────────────────────────────────────────┐
│  HOME SCREEN                           │
│  - Uses authProvider (broken)          │
│  - Shows stale auth state              │
└────────────────────────────────────────┘
```

**The Problem:**
- `authNotifier` tries to be the "source of truth"
- But `ref.listen()` crashes prevent synchronization
- Other providers (`currentUserProvider`) work correctly
- UI components use different providers → inconsistent state

---

## Remediation Plan

### Phase 1: Critical Authentication Fixes (30 minutes)

#### Fix 1: Correct AuthNotifier Architecture (10 minutes)

**Option A: Simplify to Direct Stream Mapping (Recommended)**

```dart
/// Remove AuthNotifier entirely - it's redundant
/// authStateStreamProvider already provides reactive auth state

/// Current user provider (already correct)
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Authentication status (derived state)
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

/// Auth loading state (derived)
@riverpod
bool isAuthLoading(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.isLoading;
}

/// Auth error (derived)
@riverpod
String? authError(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.whenOrNull(
    error: (error, _) => error.toString(),
  );
}
```

**Update home_screen.dart:**
```dart
// Change from:
final authState = ref.watch(authProvider);
if (!authState.isAuthenticated) {...}

// To:
final isAuthenticated = ref.watch(isAuthenticatedProvider);
if (!isAuthenticated) {...}
```

**Benefits:**
- Removes crash-causing `ref.listen()` usage
- Simplifies authentication state management
- Eliminates state synchronization issues
- Single source of truth: `authStateStreamProvider`

---

**Option B: Fix AuthNotifier with ref.watch() (Alternative)**

If you need to keep `AuthNotifier` for sign-in metrics tracking:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final ConcurrentOperationManager _operationManager;
  int _signInAttempts = 0;
  int _successfulSignIns = 0;

  @override
  AuthState build() {
    _operationManager = ConcurrentOperationManager();

    // ✅ CORRECT: Use ref.watch() to reactively rebuild
    final authStateAsync = ref.watch(authStateStreamProvider);

    return authStateAsync.when(
      data: (User? user) => AuthState(
        user: user,
        isLoading: false,
        signInSuccessRate: _signInAttempts > 0
            ? _successfulSignIns / _signInAttempts
            : 0.0,
      ),
      loading: () => const AuthState(isLoading: true),
      error: (Object error, _) => AuthState(
        isLoading: false,
        error: error.toString(),
        signInSuccessRate: _signInAttempts > 0
            ? _successfulSignIns / _signInAttempts
            : 0.0,
      ),
    );
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_operationManager.isOperationInProgress(OperationType.signIn)) {
      return;
    }

    _signInAttempts++;
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      await _operationManager.executeOperation(
        type: OperationType.signIn,
        operation: () => ref.read(authServiceProvider).signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

      stopwatch.stop();
      _successfulSignIns++;

      // State will automatically update via ref.watch() in build()
      // No manual state update needed here
    } catch (e) {
      stopwatch.stop();
      // Metrics tracked but state update handled by ref.watch()
      rethrow;
    }
  }

  // ... rest of methods
}
```

**Key Changes:**
- Replace `ref.listen()` with `ref.watch()`
- Let Riverpod automatically rebuild state when auth changes
- Remove manual `state.copyWith()` in listener
- Metrics (_signInAttempts, _successfulSignIns) still tracked

---

#### Fix 2: Correct Firestore Security Rules (15 minutes)

**File:** `firebase/firestore.rules`

**Change 1: Fix function signature**
```javascript
// Line 52-63
function isValidCrewUpdate(crewId) {  // ✅ Add crewId parameter
  let memberFields = ['preferences', 'lastActivityAt', 'stats'];
  let foremanFields = ['preferences', 'lastActivityAt', 'stats', 'name',
                       'logoUrl', 'memberIds', 'roles', 'memberCount', 'isActive'];

  // ✅ Use passed parameter instead of resource.id
  let allowedFields = isForeman(crewId) ? foremanFields : memberFields;

  return request.data.diff(resource.data).affectedKeys().hasOnly(allowedFields);
}
```

**Change 2: Update match rule**
```javascript
// Line 85-90
match /crews/{crewId} {
  allow read: if canUserAccessCrew(crewId);
  allow create: if isAuthenticated() && request.auth.uid == request.data.foremanId;
  allow update: if canUserAccessCrew(crewId) && isValidCrewUpdate(crewId);  // ✅ Pass crewId
  allow delete: if isForeman(crewId);
}
```

**Deploy:**
```bash
firebase deploy --only firestore:rules
```

**Validation:**
```javascript
// Test in Firebase emulator
describe('Crew update permissions', () => {
  it('allows foreman to update crew name', async () => {
    const db = testEnv.authenticatedContext('foreman-uid', {
      uid: 'foreman-uid'
    }).firestore();

    // Create crew with foreman
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('crews').doc('test-crew').set({
        id: 'test-crew-id',
        name: 'Original Name',
        foremanId: 'foreman-uid',
        memberIds: ['foreman-uid'],
        roles: {'foreman-uid': 'foreman'},
        isActive: true,
      });
    });

    // Test update
    await firebase.assertSucceeds(
      db.collection('crews').doc('test-crew').update({name: 'Updated Name'})
    );
  });

  it('denies member from updating crew name', async () => {
    // Similar test with member-uid
    await firebase.assertFails(
      db.collection('crews').doc('test-crew').update({name: 'Hacked'})
    );
  });
});
```

---

#### Fix 3: Authentication State Consistency Validation (30 minutes)

Create a test suite to validate auth state consistency:

**File:** `test/providers/auth_consistency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';

void main() {
  group('Auth State Consistency', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('currentUserProvider and isAuthenticatedProvider are in sync', () {
      final currentUser = container.read(currentUserProvider);
      final isAuthenticated = container.read(isAuthenticatedProvider);

      if (currentUser == null) {
        expect(isAuthenticated, isFalse,
            reason: 'If no user, isAuthenticated should be false');
      } else {
        expect(isAuthenticated, isTrue,
            reason: 'If user exists, isAuthenticated should be true');
      }
    });

    test('authStateStreamProvider updates propagate to all derived providers', () async {
      // Listen to all auth-related providers
      final listeners = [
        container.listen(authStateStreamProvider, (_, __) {}),
        container.listen(currentUserProvider, (_, __) {}),
        container.listen(isAuthenticatedProvider, (_, __) {}),
      ];

      // Trigger auth state change (sign in)
      // ... implementation depends on your test setup

      // All providers should reflect the change
      await Future.delayed(Duration(milliseconds: 100));

      // Validate consistency
      final user = container.read(currentUserProvider);
      final isAuth = container.read(isAuthenticatedProvider);

      expect(user != null, equals(isAuth),
          reason: 'User existence should match authentication status');

      // Cleanup
      for (final listener in listeners) {
        listener.close();
      }
    });
  });
}
```

---

### Phase 2: Additional Security Enhancements (2-3 hours)

#### Enhancement 1: Implement Auth Token Refresh Monitoring

**Issue:** Firebase auth tokens expire after 1 hour, potentially causing API failures

**Solution:**
```dart
@riverpod
Stream<String?> authToken(Ref ref) async* {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    yield null;
    return;
  }

  // Get initial token
  final initialToken = await user.getIdToken();
  yield initialToken;

  // Refresh token every 50 minutes (before 60-minute expiration)
  while (true) {
    await Future.delayed(Duration(minutes: 50));

    final refreshedUser = ref.read(currentUserProvider);
    if (refreshedUser == null) {
      yield null;
      break;
    }

    // Force token refresh
    final newToken = await refreshedUser.getIdToken(true);
    yield newToken;
  }
}
```

**Usage in API calls:**
```dart
Future<void> createCrew(...) async {
  final token = ref.read(authTokenProvider).valueOrNull;
  if (token == null) throw UnauthenticatedException();

  final response = await http.post(
    Uri.parse('https://api.example.com/crews'),
    headers: {'Authorization': 'Bearer $token'},
    body: {...},
  );
}
```

---

#### Enhancement 2: Add Auth State Logging for Debugging

```dart
@riverpod
class AuthObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (provider.name?.contains('auth') ?? false) {
      StructuredLogger.info(
        'Auth provider updated',
        category: LogCategory.authentication,
        context: {
          'provider': provider.name,
          'previous': previousValue?.toString(),
          'new': newValue?.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }
}

// In main.dart
void main() {
  runApp(
    ProviderScope(
      observers: [AuthObserver()],
      child: MyApp(),
    ),
  );
}
```

---

#### Enhancement 3: Implement Auth Error Recovery

**Issue:** Users get stuck in error states with no recovery path

**Solution:**
```dart
@riverpod
class AuthErrorRecovery extends _$AuthErrorRecovery {
  @override
  AuthRecoveryState build() {
    return const AuthRecoveryState();
  }

  Future<void> recoverFromError() async {
    state = state.copyWith(isRecovering: true);

    try {
      // Strategy 1: Clear local auth cache
      await ref.read(authServiceProvider).clearLocalCache();

      // Strategy 2: Force Firebase auth state refresh
      await FirebaseAuth.instance.currentUser?.reload();

      // Strategy 3: Re-initialize auth state
      ref.invalidate(authStateStreamProvider);

      state = state.copyWith(
        isRecovering: false,
        recoverySuccessful: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRecovering: false,
        recoveryError: e.toString(),
      );
    }
  }

  void clearRecoveryState() {
    state = const AuthRecoveryState();
  }
}

// UI usage
ElevatedButton(
  onPressed: () => ref.read(authErrorRecoveryProvider.notifier).recoverFromError(),
  child: Text('Retry Authentication'),
)
```

---

## Security Best Practices Implementation

### 1. Principle of Least Privilege

**Current State:** Security rules have broad permission checks
**Recommendation:** Implement granular permission validation

```javascript
// Enhanced permission checking
function hasSpecificPermission(crewId, action) {
  let role = getMemberRole(crewId);

  switch (action) {
    case 'update_name':
      return role == 'foreman';
    case 'invite_member':
      return role == 'foreman' || role == 'lead';
    case 'share_job':
      return role == 'foreman' || role == 'lead' || role == 'member';
    case 'update_preferences':
      return role == 'foreman';
    case 'view_analytics':
      return role == 'foreman' || role == 'lead';
    default:
      return false;
  }
}

// Use in rules
match /crews/{crewId} {
  allow update: if hasSpecificPermission(crewId, 'update_' + request.data.diff(resource.data).affectedKeys()[0]);
}
```

---

### 2. Audit Logging for Security Events

```dart
void _logSecurityEvent({
  required String eventType,
  required String userId,
  required String resource,
  required bool allowed,
  Map<String, dynamic>? context,
}) {
  StructuredLogger.security(
    eventType,
    category: LogCategory.security,
    context: {
      'userId': userId,
      'resource': resource,
      'allowed': allowed,
      'timestamp': DateTime.now().toIso8601String(),
      'ipAddress': _getClientIp(),
      ...?context,
    },
  );
}

// Usage
Future<void> updateCrew(...) async {
  final allowed = await hasPermission(
    crewId: crewId,
    userId: userId,
    permission: Permission.updateCrew,
  );

  _logSecurityEvent(
    eventType: 'crew_update_attempt',
    userId: userId,
    resource: 'crews/$crewId',
    allowed: allowed,
    context: {'operation': 'update_name'},
  );

  if (!allowed) throw PermissionDeniedException();

  // Proceed with update
}
```

---

### 3. Session Management

**Issue:** No session timeout or concurrent session handling

**Solution:**
```dart
@riverpod
class SessionManager extends _$SessionManager {
  static const sessionTimeout = Duration(hours: 8);
  Timer? _sessionTimer;

  @override
  SessionState build() {
    _startSessionTimer();
    return SessionState(
      startTime: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, () async {
      // Session expired - sign user out
      StructuredLogger.warning(
        'Session expired',
        category: LogCategory.authentication,
        context: {
          'userId': ref.read(currentUserProvider)?.uid,
          'sessionDuration': sessionTimeout.inHours,
        },
      );

      await ref.read(authServiceProvider).signOut();
    });
  }

  void recordActivity() {
    state = state.copyWith(lastActivity: DateTime.now());
    _startSessionTimer(); // Reset timer
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
```

---

## Testing Strategy

### Unit Tests

```dart
// test/providers/auth_provider_test.dart
group('Authentication State Management', () {
  test('auth state updates when user signs in', () async {
    final container = ProviderContainer();

    // Sign in
    await container.read(authServiceProvider).signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    );

    // Wait for state propagation
    await Future.delayed(Duration(milliseconds: 100));

    final isAuthenticated = container.read(isAuthenticatedProvider);
    expect(isAuthenticated, isTrue);
  });

  test('auth state clears when user signs out', () async {
    // ... similar test for sign out
  });
});
```

### Integration Tests

```dart
// test/integration/auth_flow_test.dart
testWidgets('complete authentication flow works', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: AuthScreen()),
    ),
  );

  // Enter credentials
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.enterText(find.byType(TextField).last, 'password123');

  // Tap sign in
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();

  // Verify navigation to home screen
  expect(find.byType(HomeScreen), findsOneWidget);

  // Verify auth state
  final container = ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
  expect(container.read(isAuthenticatedProvider), isTrue);
});
```

### Security Rules Tests

```javascript
// firebase.json
{
  "emulators": {
    "firestore": {
      "port": 8080
    }
  }
}

// test/security/firestore_rules_test.js
const firebase = require('@firebase/rules-unit-testing');

describe('Authentication Security Rules', () => {
  let testEnv;

  beforeAll(async () => {
    testEnv = await firebase.initializeTestEnvironment({
      projectId: 'journeyman-jobs-test',
      firestore: {
        rules: fs.readFileSync('firebase/firestore.rules', 'utf8'),
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  test('foreman can update crew name', async () => {
    const db = testEnv.authenticatedContext('foreman-uid').firestore();
    await firebase.assertSucceeds(
      db.collection('crews').doc('test-crew').update({name: 'New Name'})
    );
  });

  test('member cannot update crew name', async () => {
    const db = testEnv.authenticatedContext('member-uid').firestore();
    await firebase.assertFails(
      db.collection('crews').doc('test-crew').update({name: 'Hacked'})
    );
  });

  test('unauthenticated user cannot read crews', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await firebase.assertFails(
      db.collection('crews').doc('test-crew').get()
    );
  });
});
```

---

## Monitoring & Alerting

### Recommended Metrics

#### 1. Authentication Metrics
```dart
// Firebase Analytics events
FirebaseAnalytics.instance.logEvent(
  name: 'auth_state_change',
  parameters: {
    'auth_method': 'email',
    'success': true,
    'duration_ms': 250,
    'user_id': userId,
  },
);

FirebaseAnalytics.instance.logEvent(
  name: 'auth_error',
  parameters: {
    'error_code': e.code,
    'error_message': e.message,
    'auth_method': 'email',
    'recovery_attempted': true,
  },
);
```

#### 2. Security Event Monitoring
```dart
// Crashlytics for security events
FirebaseCrashlytics.instance.log('Permission denied: User ${userId} attempted to update crew ${crewId}');
FirebaseCrashlytics.instance.recordError(
  PermissionDeniedException(),
  StackTrace.current,
  fatal: false,
);
```

#### 3. Performance Monitoring
```dart
// Track auth operation performance
final trace = FirebasePerformance.instance.newTrace('auth_sign_in');
await trace.start();
try {
  await signInWithEmailAndPassword(...);
  trace.putAttribute('success', 'true');
} catch (e) {
  trace.putAttribute('success', 'false');
  trace.putAttribute('error', e.toString());
} finally {
  await trace.stop();
}
```

---

## Appendix

### A. Authentication Error Code Reference

| Code | Meaning | User-Friendly Message | Recovery Action |
|------|---------|----------------------|-----------------|
| `user-not-found` | Email not registered | "No account found with this email. Please sign up." | Redirect to sign up |
| `wrong-password` | Incorrect password | "Incorrect password. Please try again." | Allow retry |
| `too-many-requests` | Rate limit exceeded | "Too many login attempts. Please try again in 5 minutes." | Show countdown timer |
| `network-request-failed` | No internet connection | "No internet connection. Please check your network." | Show offline mode |
| `invalid-email` | Malformed email | "Please enter a valid email address." | Highlight email field |
| `user-disabled` | Account disabled | "Your account has been disabled. Contact support." | Show support link |
| `operation-not-allowed` | Auth method disabled | "This sign-in method is not available." | Show alternative methods |

### B. Firestore Security Rules Best Practices

1. **Always validate request.auth**
   ```javascript
   // ✅ GOOD
   allow read: if request.auth != null && request.auth.uid == userId;

   // ❌ BAD
   allow read: if true;
   ```

2. **Use helper functions for complex logic**
   ```javascript
   function isOwner(userId) {
     return request.auth != null && request.auth.uid == userId;
   }

   allow read, write: if isOwner(resource.data.userId);
   ```

3. **Validate data structure**
   ```javascript
   allow create: if request.data.keys().hasAll(['name', 'foremanId', 'createdAt']) &&
                    request.data.foremanId == request.auth.uid;
   ```

4. **Rate limiting**
   ```javascript
   // Limit to 100 crew creations per user
   allow create: if request.auth != null &&
                    get(/databases/$(database)/documents/counters/crews/user_crews/$(request.auth.uid)).data.count < 100;
   ```

### C. Riverpod State Management Patterns

#### Pattern 1: Stream Provider
```dart
// For real-time Firebase data
@riverpod
Stream<List<Crew>> userCrews(Ref ref) {
  final userId = ref.watch(currentUserProvider)?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('crews')
      .where('memberIds', arrayContains: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Crew.fromFirestore(doc)).toList());
}
```

#### Pattern 2: Future Provider with Auto-Refresh
```dart
// For one-time data fetching with caching
@riverpod
Future<UserProfile> userProfile(Ref ref, String userId) async {
  // Auto-refresh every 5 minutes
  ref.cacheFor(const Duration(minutes: 5));

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  return UserProfile.fromFirestore(doc);
}
```

#### Pattern 3: Notifier for Complex State
```dart
// For operations with side effects
@riverpod
class CrewOperations extends _$CrewOperations {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createCrew({required String name}) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(currentUserProvider)?.uid;
      if (userId == null) throw UnauthenticatedException();

      await ref.read(crewServiceProvider).createCrew(
        name: name,
        foremanId: userId,
        preferences: CrewPreferences.empty(),
      );

      state = const AsyncValue.data(null);

      // Refresh crews list
      ref.invalidate(userCrewsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

---

## Conclusion

The authentication system suffers from three critical issues that create a cascade of failures:

1. **Architectural Flaw**: `AuthNotifier` using `ref.listen()` incorrectly → App crashes
2. **Security Rules Bug**: Permission validation logic error → Legitimate operations blocked
3. **State Inconsistency**: Multiple auth state sources → Data synchronization failures

### Fix Priority

**IMMEDIATE (30 minutes):**
1. Fix `AuthNotifier` crash (Option A: Remove notifier, use direct stream)
2. Correct Firestore security rules parameter passing
3. Deploy fixes to production

**HIGH (2-3 hours):**
1. Implement auth state consistency tests
2. Add security event logging
3. Deploy monitoring and alerting

**MEDIUM (1 week):**
1. Implement session management
2. Add auth error recovery mechanisms
3. Complete security rules testing suite

### Success Criteria

- ✅ No assertion errors on app launch
- ✅ Auth state consistent across all providers
- ✅ Foreman can update crew metadata
- ✅ Security rules properly enforce permissions
- ✅ All security tests pass

---

**Report Generated:** 2025-10-18
**Agent:** Root Cause Investigation Specialist
**Framework:** SuperClaude + Sequential MCP + Security Analysis

**Next Steps:**
1. Implement Phase 1 fixes immediately
2. Validate with integration tests
3. Monitor production metrics for 48 hours
4. Schedule Phase 2 enhancements for next sprint
