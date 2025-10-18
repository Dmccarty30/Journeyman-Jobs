# SECURITY QUICK FIXES - IMMEDIATE ACTION REQUIRED

## 🚨 CRITICAL VULNERABILITIES (Fix within 24-48 hours)

### 1. WEAK PASSWORD POLICY (CVSS 7.8)
**File**: `lib/screens/onboarding/auth_screen.dart:72-79`

**Current (INSECURE)**:
```dart
if (value.length < 6) {  // ❌ TOO WEAK
  return 'Password must be at least 6 characters';
}
```

**Fix Now**:
```dart
String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 12) return 'Password must be at least 12 characters';

  if (!value.contains(RegExp(r'[A-Z]'))) return 'Must include uppercase letter';
  if (!value.contains(RegExp(r'[a-z]'))) return 'Must include lowercase letter';
  if (!value.contains(RegExp(r'[0-9]'))) return 'Must include number';
  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Must include special character';

  return null;
}
```

---

### 2. PLAINTEXT PII IN LOGS (CVSS 8.2)
**Impact**: 525 instances of `debugPrint` exposing email, phone, addresses

**Fix Now**:
1. Create `lib/utils/secure_logger.dart`:
```dart
import 'package:flutter/foundation.dart';

class SecureLogger {
  static void log(String message) {
    final sanitized = _sanitize(message);
    if (kDebugMode) debugPrint(sanitized);
  }

  static String _sanitize(String text) {
    return text
      .replaceAll(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), '[EMAIL]')
      .replaceAll(RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), '[PHONE]')
      .replaceAll(RegExp(r'\b[a-zA-Z0-9]{32,}\b'), '[TOKEN]');
  }
}
```

2. Global find/replace:
```bash
# Find all debugPrint calls
grep -r "debugPrint" lib/

# Replace with SecureLogger.log
```

---

### 3. AUTHORIZATION BYPASS IN CREW UPDATES (CVSS 8.5)
**File**: `firebase/firestore.rules:86-90`

**Current (INSECURE)**:
```javascript
allow update: if canUserAccessCrew(crewId) && isValidCrewUpdate();  // ❌ TOO PERMISSIVE
```

**Fix Now**:
```javascript
match /crews/{crewId} {
  allow read: if canUserAccessCrew(crewId);
  allow create: if isAuthenticated() && request.auth.uid == request.data.foremanId;

  // ✅ STRICT ROLE-BASED UPDATES
  allow update: if isForeman(crewId);  // Only foreman can update
  allow update: if isCrewMember(crewId) &&
                   !request.data.diff(resource.data).affectedKeys()
                     .hasAny(['foremanId', 'memberIds', 'roles', 'isActive']);

  allow delete: if isForeman(crewId);
}
```

Deploy rules:
```bash
cd firebase
firebase deploy --only firestore:rules
```

---

### 4. SQL INJECTION IN SCRAPING SCRIPTS (CVSS 9.1)
**File**: `scraping_scripts/completed/*.js`

**Current (CRITICAL)**:
```javascript
const query = `INSERT INTO jobs VALUES ('${jobTitle}', '${location}')`;  // ❌ VULNERABLE
```

**Fix Now**:
```javascript
// ✅ USE PARAMETERIZED QUERIES
const query = 'INSERT INTO jobs (title, location) VALUES (?, ?)';
const params = [sanitize(jobTitle), sanitize(location)];
await db.execute(query, params);

function sanitize(input) {
  return input
    .replace(/[<>"'`;]/g, '')
    .trim()
    .substring(0, 500);
}
```

---

### 5. XSS IN MESSAGE DISPLAY (CVSS 6.9)
**File**: `lib/features/crews/widgets/message_bubble.dart`

**Fix Now**:
Add to `pubspec.yaml`:
```yaml
dependencies:
  html_unescape: ^2.0.0
```

Create sanitizer:
```dart
String sanitizeMessage(String message) {
  return message
    .replaceAll(RegExp(r'<[^>]*>'), '')  // Remove HTML
    .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')  // Remove JS
    .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');  // Remove event handlers
}

// Use everywhere messages are displayed
Text(sanitizeMessage(message.content))
```

---

## 🟠 HIGH PRIORITY (Fix within 1 week)

### 6. NO SESSION TIMEOUT
Add to `lib/providers/riverpod/auth_riverpod_provider.dart`:
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  Timer? _sessionTimer;
  DateTime _lastActivity = DateTime.now();
  static const _timeout = Duration(minutes: 30);

  void updateActivity() => _lastActivity = DateTime.now();

  void _startSessionMonitoring() {
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (_) {
      if (DateTime.now().difference(_lastActivity) > _timeout) {
        signOut();  // Auto logout
      }
    });
  }

  @override
  AuthState build() {
    _startSessionMonitoring();
    return const AuthState();
  }
}
```

---

### 7. NO ACCOUNT LOCKOUT
Add to `lib/services/auth_service.dart`:
```dart
class AuthService {
  final _failedAttempts = <String, int>{};
  final _lockedUntil = <String, DateTime>{};
  static const _maxAttempts = 5;
  static const _lockDuration = Duration(minutes: 15);

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Check lockout
    if (_lockedUntil.containsKey(email) &&
        DateTime.now().isBefore(_lockedUntil[email]!)) {
      throw Exception('Account locked. Try again later.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _failedAttempts.remove(email);
      _lockedUntil.remove(email);
      return credential;
    } catch (e) {
      _failedAttempts[email] = (_failedAttempts[email] ?? 0) + 1;

      if (_failedAttempts[email]! >= _maxAttempts) {
        _lockedUntil[email] = DateTime.now().add(_lockDuration);
        throw Exception('Too many failed attempts. Locked for 15 minutes.');
      }
      rethrow;
    }
  }
}
```

---

### 8. GENERIC ERROR MESSAGES TO PREVENT ENUMERATION
Update `lib/services/auth_service.dart:181-203`:
```dart
String _handleAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
    case 'wrong-password':
      return 'Invalid email or password.';  // ✅ GENERIC

    case 'email-already-in-use':
      return 'If this email exists, we\'ve sent a reset link.';  // ✅ NO CONFIRMATION

    case 'too-many-requests':
      return 'Too many attempts. Try again later.';

    default:
      return 'Authentication error. Please try again.';
  }
}
```

---

### 9. RATE LIMITING FOR MESSAGES
Add to `firebase/firestore.rules`:
```javascript
function canSendMessage() {
  let counter = get(/databases/$(database)/documents/counters/messages/$(request.auth.uid)).data;
  let currentMinute = math.floor(request.time.toMillis() / 60000);

  return !exists(/databases/$(database)/documents/counters/messages/$(request.auth.uid)) ||
         counter.minute != currentMinute ||
         counter.count < 10;
}

match /conversations/{convId}/messages/{msgId} {
  allow create: if isConversationParticipant(convId) && canSendMessage();
}
```

---

### 10. SECURE DATA STORAGE
Replace `SharedPreferences` with `FlutterSecureStorage`:

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

Update `lib/services/onboarding_service.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingService {
  final _storage = const FlutterSecureStorage();

  Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: 'onboarding_complete');
    return value == 'true';
  }

  Future<void> markOnboardingComplete() async {
    await _storage.write(key: 'onboarding_complete', value: 'true');
  }
}
```

---

## 🟡 MEDIUM PRIORITY (Fix within 2-4 weeks)

### 11. IMPLEMENT MULTI-FACTOR AUTHENTICATION
Reference: See full implementation in main report Section 1

### 12. GDPR COMPLIANCE
- Add user data export functionality
- Add account deletion functionality
- Add consent tracking
- Link to privacy policy

### 13. SEPARATE PUBLIC/PRIVATE USER DATA
Split Firestore structure:
```
users/{userId}/public → {displayName, avatar, classification}
users/{userId}/private → {email, phone, address, ticketNumber}
```

Update rules:
```javascript
match /users/{userId}/public {
  allow read: if isAuthenticated();
  allow write: if request.auth.uid == userId;
}

match /users/{userId}/private {
  allow read, write: if request.auth.uid == userId;
}
```

---

## DEPLOYMENT CHECKLIST

### Before Deploying Fixes

- [ ] Review all code changes
- [ ] Test authentication flows
- [ ] Test Firestore rule changes in emulator
- [ ] Backup current Firestore rules
- [ ] Create rollback plan
- [ ] Notify users of security updates

### Deploy Order

1. **Backend First**: Firestore rules, Cloud Functions
2. **Server-side**: API changes, database updates
3. **Client-side**: Mobile app updates
4. **Monitoring**: Enable security logging

### After Deployment

- [ ] Monitor error rates
- [ ] Check auth success rates
- [ ] Verify rate limiting works
- [ ] Test all critical paths
- [ ] Monitor security logs

---

## TESTING COMMANDS

### Test Password Validation
```dart
void testPasswordValidation() {
  assert(_validatePassword('weak') != null);  // Should fail
  assert(_validatePassword('StrongP@ss123') == null);  // Should pass
}
```

### Test Firestore Rules
```bash
cd firebase
firebase emulators:start
npm run test:rules
```

### Test Rate Limiting
```dart
// Attempt 11 messages in 1 minute - should fail
for (var i = 0; i < 11; i++) {
  await sendMessage('Test $i');
}
```

---

## MONITORING SETUP

### Add Security Event Tracking
```dart
class SecurityMonitor {
  static void logEvent(String event, Map<String, dynamic> data) {
    FirebaseAnalytics.instance.logEvent(
      name: 'security_$event',
      parameters: data,
    );
  }
}

// Usage
SecurityMonitor.logEvent('failed_login', {'email': '[REDACTED]'});
SecurityMonitor.logEvent('account_locked', {'userId': userId});
```

### Alert Thresholds
- 5+ failed logins → Lock account
- 10+ messages/minute → Rate limit
- 3+ locations/day → Require re-auth

---

## RESOURCES

### Documentation
- Full Report: `SECURITY_AUDIT_REPORT.md`
- Firebase Security Rules: https://firebase.google.com/docs/rules
- OWASP Top 10: https://owasp.org/Top10/
- Flutter Security: https://docs.flutter.dev/security

### Tools
- Firebase Emulator Suite
- SonarQube for code analysis
- Snyk for dependency scanning

---

## QUESTIONS?

Contact security team or refer to full audit report for detailed explanations and additional vulnerabilities.

**Last Updated**: 2025-10-18
**Priority**: CRITICAL - Start fixes immediately
