# Wave 2 Code Reference - Exact Implementations

## Complete Code Snippets

### 1. Router Redirect Logic (app_router.dart)

#### Imports (Lines 1-7)
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
import '../providers/riverpod/auth_riverpod_provider.dart';

// Screens
```

#### Main Redirect Function (Lines 259-340)
```dart
/// Handles route redirection based on authentication state.
///
/// Uses Riverpod providers to check:
/// - Auth initialization status (authInitializationProvider)
/// - User authentication state (authStateProvider)
///
/// Redirect logic:
/// 1. During auth initialization -> allow navigation (screens show loading)
/// 2. Unauthenticated user on protected route -> redirect to /auth with return URL
/// 3. Authenticated user on /auth or /welcome -> redirect to intended destination or /home
/// 4. Public routes always accessible
///
/// Query parameters:
/// - `redirect`: Captures the original destination for post-login navigation
///
/// Example: `/locals` -> `/auth?redirect=%2Flocals` -> successful login -> `/locals`
static String? _redirect(BuildContext context, GoRouterState state) {
  // Access Riverpod container from context
  // Note: This assumes the router is wrapped in ProviderScope
  final container = ProviderScope.containerOf(context, listen: false);

  // Check auth initialization status
  final authInit = container.read(authInitializationProvider);
  final authState = container.read(authStateProvider);

  // Get current location
  final currentPath = state.matchedLocation;

  // Define public routes (accessible without authentication)
  const publicRoutes = [
    splash,
    welcome,
    auth,
    forgotPassword,
    onboarding,
  ];

  // If auth is still initializing, allow navigation
  // Screens will handle loading state with skeleton screens (Wave 3)
  if (authInit.isLoading) {
    return null;
  }

  // Determine if current route requires authentication
  final requiresAuth = !publicRoutes.contains(currentPath);

  // Get current user (null if not authenticated or still loading)
  // In Riverpod 3.x, we use pattern matching instead of valueOrNull
  final user = authState.whenOrNull(
    data: (user) => user,
  );
  final isAuthenticated = user != null;

  // Protected route accessed by unauthenticated user -> redirect to login
  if (requiresAuth && !isAuthenticated) {
    // Capture original destination for post-login redirect
    // Don't redirect if already on a public route to avoid loops
    if (currentPath != auth && currentPath != welcome) {
      return '$auth?redirect=${Uri.encodeComponent(currentPath)}';
    }
    return auth;
  }

  // Authenticated user trying to access login/welcome -> redirect
  if (isAuthenticated && (currentPath == auth || currentPath == welcome)) {
    // Check for redirect parameter (user was sent to login from protected route)
    final redirect = state.uri.queryParameters['redirect'];

    if (redirect != null && redirect.isNotEmpty) {
      // Decode and navigate to original destination
      final decodedRedirect = Uri.decodeComponent(redirect);

      // Validate redirect path to prevent open redirect vulnerabilities
      if (_isValidRedirectPath(decodedRedirect)) {
        return decodedRedirect;
      }
    }

    // Default: redirect authenticated users to home
    return home;
  }

  // Allow navigation
  return null;
}
```

#### Security Validation (Lines 342-362)
```dart
/// Validates redirect paths to prevent open redirect vulnerabilities.
///
/// Only allows internal app routes (must start with /).
/// Prevents redirects to external URLs or malicious paths.
///
/// Valid: /home, /locals, /jobs/123
/// Invalid: https://evil.com, //evil.com, javascript:alert(1)
static bool _isValidRedirectPath(String path) {
  // Must start with / and not be a protocol-relative URL
  if (!path.startsWith('/') || path.startsWith('//')) {
    return false;
  }

  // Must not contain protocol schemes
  if (path.contains('://')) {
    return false;
  }

  // Path is valid internal route
  return true;
}
```

### 2. Auth Screen Redirect Helpers (auth_screen.dart)

#### Redirect Destination Helper (Lines 93-113)
```dart
/// Gets the redirect destination from query parameters.
///
/// Returns the decoded redirect path if present and valid, otherwise null.
/// Used to navigate users back to their intended destination after login.
String? _getRedirectDestination() {
  final uri = GoRouterState.of(context).uri;
  final redirect = uri.queryParameters['redirect'];

  if (redirect != null && redirect.isNotEmpty) {
    final decodedRedirect = Uri.decodeComponent(redirect);

    // Validate redirect path for security
    if (decodedRedirect.startsWith('/') &&
        !decodedRedirect.startsWith('//') &&
        !decodedRedirect.contains('://')) {
      return decodedRedirect;
    }
  }

  return null;
}
```

#### Post-Login Navigation (Lines 115-128)
```dart
/// Navigates to the appropriate destination after successful authentication.
///
/// Priority:
/// 1. Redirect query parameter (if valid)
/// 2. Home screen (default)
void _navigateAfterAuth() {
  final redirect = _getRedirectDestination();

  if (redirect != null) {
    context.go(redirect);
  } else {
    context.go(AppRouter.home);
  }
}
```

#### Updated Sign-In Navigation (Line 226)
```dart
// Before (old code):
// context.go(AppRouter.home);

// After (new code):
_navigateAfterAuth();
```

### 3. Complete Sign-In Method Context (Lines 154-229)

```dart
Future<void> _signInWithEmail() async {
  if (!_signInFormKey.currentState!.validate()) return;

  setState(() => _isSignInLoading = true);

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _signInEmailController.text.trim(),
      password: _signInPasswordController.text,
    );

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final FirestoreService firestoreService = FirestoreService();
        final DocumentSnapshot userDoc = await firestoreService.getUser(user.uid);

        if (!userDoc.exists) {
          await firestoreService.createUser(
            uid: user.uid,
            userData: {
              'email': user.email,
            },
          );
          if (mounted) {
            _navigateToOnboarding();
          }
        } else {
          final String? onboardingStatus = userDoc.get('onboardingStatus');
          if (onboardingStatus == 'incomplete' || onboardingStatus == null) {
            if (mounted) {
              _navigateToOnboarding();
            }
          } else if (onboardingStatus == 'complete') {
            if (mounted) {
              _navigateAfterAuth(); // <-- CHANGED: Now respects redirect param
            }
          }
        }
      } catch (firestoreError) {
        if (mounted) {
          JJSnackBar.showError(
            context: context,
            message: 'Sign in successful but profile check failed. Please complete onboarding.',
          );
          _navigateToOnboarding();
        }
      }
    }
  } on FirebaseAuthException catch (e) {
    if (mounted) {
      String message = 'Invalid email or password';
      if (e.code == 'user-not-found') {
        message = 'No account found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      }
      JJSnackBar.showError(context: context, message: message);
    }
  } catch (e) {
    if (mounted) {
      JJSnackBar.showError(
        context: context,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSignInLoading = false);
    }
  }
}
```

## Usage Examples

### Example 1: Basic Protected Route Navigation

```dart
// User tries to access /locals without auth
context.go('/locals');

// Router intercepts:
_redirect() detects:
- requiresAuth = true
- isAuthenticated = false

// Redirects to:
'/auth?redirect=%2Flocals'

// After successful login:
_navigateAfterAuth() extracts redirect param
context.go('/locals') // User lands on intended destination
```

### Example 2: Authenticated User on Login Page

```dart
// Authenticated user navigates to login
context.go('/auth');

// Router intercepts:
_redirect() detects:
- isAuthenticated = true
- currentPath = '/auth'

// Redirects to:
'/home' // Default destination
```

### Example 3: Deep Link with Redirect

```dart
// User receives deep link
context.go('/auth?redirect=%2Fjobs%2F123');

// After successful login:
_navigateAfterAuth() extracts redirect
_getRedirectDestination() returns '/jobs/123'
context.go('/jobs/123') // User lands on specific job
```

### Example 4: Malicious Redirect Attempt

```dart
// Attacker tries malicious redirect
context.go('/auth?redirect=https://evil.com');

// After login:
_getRedirectDestination() validates path
'https://evil.com'.startsWith('/') → false
Returns null (invalid)

_navigateAfterAuth() uses default
context.go('/home') // Safe fallback
```

## Testing Code Snippets

### Manual Test Script

```dart
// Test 1: Unauthenticated access to protected route
void testUnauthenticatedAccess() async {
  // Sign out first
  await FirebaseAuth.instance.signOut();

  // Try to navigate to protected route
  context.go('/locals');

  // Expected: Redirected to /auth?redirect=%2Flocals
  print('Current route: ${GoRouter.of(context).location}');
  assert(GoRouter.of(context).location.startsWith('/auth?redirect='));
}

// Test 2: Redirect after login
void testRedirectAfterLogin() async {
  // Navigate with redirect param
  context.go('/auth?redirect=%2Flocals');

  // Perform login (simulate)
  await signInWithEmailAndPassword(
    email: 'test@example.com',
    password: 'password',
  );

  // Expected: Redirected to /locals
  await Future.delayed(Duration(milliseconds: 500));
  print('Current route: ${GoRouter.of(context).location}');
  assert(GoRouter.of(context).location == '/locals');
}

// Test 3: Security validation
void testSecurityValidation() {
  final validPaths = ['/home', '/locals', '/jobs/123'];
  final invalidPaths = [
    'https://evil.com',
    '//evil.com',
    'javascript:alert(1)',
    'evil.com',
  ];

  for (final path in validPaths) {
    assert(AppRouter._isValidRedirectPath(path) == true);
  }

  for (final path in invalidPaths) {
    assert(AppRouter._isValidRedirectPath(path) == false);
  }

  print('Security validation: PASSED');
}
```

## Debugging Helpers

### Debug Redirect Flow

```dart
static String? _redirect(BuildContext context, GoRouterState state) {
  // ... existing code ...

  // Add debug logging
  print('🔍 Redirect Debug:');
  print('  Current Path: $currentPath');
  print('  Auth Init Loading: ${authInit.isLoading}');
  print('  User: $user');
  print('  Is Authenticated: $isAuthenticated');
  print('  Requires Auth: $requiresAuth');

  if (requiresAuth && !isAuthenticated) {
    final redirectPath = '$auth?redirect=${Uri.encodeComponent(currentPath)}';
    print('  ➡️  Redirecting to: $redirectPath');
    return redirectPath;
  }

  if (isAuthenticated && (currentPath == auth || currentPath == welcome)) {
    final redirect = state.uri.queryParameters['redirect'];
    print('  Redirect Param: $redirect');
    if (redirect != null && _isValidRedirectPath(Uri.decodeComponent(redirect))) {
      print('  ➡️  Redirecting to: ${Uri.decodeComponent(redirect)}');
      return Uri.decodeComponent(redirect);
    }
    print('  ➡️  Redirecting to: $home');
    return home;
  }

  print('  ✅ Allowing navigation');
  return null;
}
```

### Debug Auth Navigation

```dart
void _navigateAfterAuth() {
  final redirect = _getRedirectDestination();

  print('🔐 Post-Login Navigation:');
  print('  Redirect Param: $redirect');
  print('  Destination: ${redirect ?? AppRouter.home}');

  if (redirect != null) {
    context.go(redirect);
  } else {
    context.go(AppRouter.home);
  }
}
```

## Configuration Reference

### Public Routes List

```dart
const publicRoutes = [
  splash,        // '/'
  welcome,       // '/welcome'
  auth,          // '/auth'
  forgotPassword,// '/forgot-password'
  onboarding,    // '/onboarding'
];
```

### Protected Routes (Examples)

```dart
// All routes NOT in publicRoutes require authentication:
final protectedRoutes = [
  home,          // '/home'
  jobs,          // '/jobs'
  storm,         // '/storm'
  locals,        // '/locals'
  crews,         // '/crews'
  settings,      // '/settings'
  // ... and 15+ more
];
```

## Quick Reference

**Key Functions**:
- `_redirect()` - Main navigation guard
- `_isValidRedirectPath()` - Security validator
- `_getRedirectDestination()` - Extract redirect param
- `_navigateAfterAuth()` - Post-login navigation

**Key Providers** (from Wave 1):
- `authInitializationProvider` - Auth ready status
- `authStateProvider` - Current user state

**Key Routes**:
- Public: `/`, `/welcome`, `/auth`, `/forgot-password`, `/onboarding`
- Protected: Everything else

**Security Rules**:
- Must start with `/`
- Must not start with `//`
- Must not contain `://`

**Redirect Flow**:
1. Unauthenticated → protected route → `/auth?redirect=encodedPath`
2. Login success → extract redirect → validate → navigate
3. Invalid redirect → default to `/home`
