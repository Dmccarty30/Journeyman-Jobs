# Wave 2: Navigation Redirect Flow Diagram

## Complete Redirect Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      User Navigation Request                     │
│                     context.go('/some-route')                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GoRouter._redirect()                          │
│  Access Riverpod: ProviderScope.containerOf(context)            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              Read authInitializationProvider                     │
│                    (Wave 1 Provider)                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │  isLoading?     │
                    └────────┬────────┘
                             │
                 ┌───────────┴───────────┐
                 │ YES                   │ NO
                 ▼                       ▼
        ┌────────────────┐      ┌────────────────────┐
        │ Allow          │      │ Check authState    │
        │ Navigation     │      │ Provider           │
        │ return null    │      └─────────┬──────────┘
        └────────────────┘                │
                                          ▼
                              ┌───────────────────────┐
                              │ Read authStateProvider│
                              │    (Wave 1 Provider)  │
                              └───────────┬───────────┘
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │ Extract user with     │
                              │ whenOrNull(data: ...) │
                              └───────────┬───────────┘
                                          │
                              ┌───────────┴───────────┐
                              │ isAuthenticated?      │
                              │ (user != null)        │
                              └───────────┬───────────┘
                                          │
                    ┌─────────────────────┴─────────────────────┐
                    │ YES                                       │ NO
                    ▼                                           ▼
        ┌──────────────────────┐                  ┌──────────────────────┐
        │ Is on /auth or       │                  │ Is route protected?  │
        │ /welcome?            │                  │ (!publicRoutes)      │
        └──────────┬───────────┘                  └──────────┬───────────┘
                   │                                          │
          ┌────────┴────────┐                     ┌──────────┴──────────┐
          │ YES             │ NO                  │ YES                 │ NO
          ▼                 ▼                     ▼                     ▼
  ┌───────────────┐  ┌─────────────┐   ┌──────────────────┐  ┌─────────────┐
  │ Get redirect  │  │ Allow       │   │ Redirect to      │  │ Allow       │
  │ query param   │  │ Navigation  │   │ /auth with       │  │ Navigation  │
  └───────┬───────┘  │ return null │   │ redirect param   │  │ return null │
          │          └─────────────┘   └────────┬─────────┘  └─────────────┘
          ▼                                     │
  ┌───────────────────┐                        │
  │ Is redirect valid?│                        │
  │ _isValidRedirect  │                        │
  │ Path()            │                        │
  └─────────┬─────────┘                        │
            │                                  │
    ┌───────┴───────┐                         │
    │ YES           │ NO                      │
    ▼               ▼                         ▼
┌──────────┐  ┌──────────┐          ┌─────────────────────┐
│ Return   │  │ Return   │          │ Return:             │
│ decoded  │  │ /home    │          │ /auth?redirect=     │
│ redirect │  │ (default)│          │ encodedPath         │
└──────────┘  └──────────┘          └─────────────────────┘
```

## Scenario Breakdowns

### Scenario 1: Unauthenticated User → Protected Route

```
User navigates to: /locals
           ↓
authInit.isLoading = false
           ↓
authState.user = null (unauthenticated)
           ↓
requiresAuth = true (/locals not in publicRoutes)
           ↓
isAuthenticated = false
           ↓
Redirect to: /auth?redirect=%2Flocals
           ↓
[User completes sign-in]
           ↓
AuthScreen._navigateAfterAuth()
           ↓
_getRedirectDestination() → /locals
           ↓
context.go(/locals)
           ↓
User lands on: /locals ✅
```

### Scenario 2: Authenticated User → Login Page

```
User navigates to: /auth
           ↓
authInit.isLoading = false
           ↓
authState.user = User{...} (authenticated)
           ↓
isAuthenticated = true
           ↓
currentPath = /auth
           ↓
Check query param 'redirect'
           ↓
   ┌──────┴──────┐
   │ Has redirect?│
   └──────┬───────┘
          │
  ┌───────┴────────┐
  │ YES            │ NO
  ▼                ▼
Validate      Return
redirect      /home
  │
  ▼
Valid?
  │
┌─┴──┐
│YES │NO
▼    ▼
Use  /home
param
```

### Scenario 3: Auth Initialization (App Start)

```
App starts: /
           ↓
Router._redirect()
           ↓
authInitializationProvider
           ↓
   ┌───────────┐
   │isLoading? │
   └─────┬─────┘
         │
    ┌────┴────┐
    │  YES    │
    ▼         │
Allow    ┌────┘
Navigation│
return null
    │
    ▼
[Screen renders]
    │
    ▼
Screen checks authInit.when()
    │
    ▼
Shows: SplashScreen/Skeleton
    │
    ▼
[Auth completes within 5 seconds]
    │
    ▼
authInit.data = true
    │
    ▼
Screen updates to actual content
```

### Scenario 4: Public Route Access

```
User navigates to: /welcome
           ↓
authInit.isLoading = false
           ↓
currentPath = /welcome
           ↓
requiresAuth = false (/welcome in publicRoutes)
           ↓
Allow navigation
return null
           ↓
User lands on: /welcome ✅
(No auth check needed)
```

### Scenario 5: Malicious Redirect Attempt

```
User navigates to: /auth?redirect=https://evil.com
           ↓
[User signs in successfully]
           ↓
AuthScreen._navigateAfterAuth()
           ↓
_getRedirectDestination()
           ↓
redirect = "https://evil.com"
           ↓
Validate: decodedRedirect.startsWith('/')? ❌
           ↓
Validate: !decodedRedirect.contains('://')? ❌
           ↓
Return null (invalid)
           ↓
_navigateAfterAuth() → default
           ↓
context.go(/home)
           ↓
User lands on: /home ✅ (Attack prevented)
```

## Security Validation Flow

```
┌─────────────────────────────────────┐
│   _isValidRedirectPath(path)       │
└────────────────┬────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │ Starts with /? │
        └────────┬───────┘
                 │
         ┌───────┴────────┐
         │ YES            │ NO
         ▼                ▼
  ┌──────────────┐   ┌─────────┐
  │ Starts with  │   │ BLOCK   │
  │ // ?         │   │ return  │
  └──────┬───────┘   │ false   │
         │           └─────────┘
 ┌───────┴────────┐
 │ YES            │ NO
 ▼                ▼
┌──────┐   ┌──────────────┐
│BLOCK │   │ Contains     │
│return│   │ :// ?        │
│false │   └──────┬───────┘
└──────┘          │
          ┌───────┴────────┐
          │ YES            │ NO
          ▼                ▼
      ┌──────┐        ┌──────┐
      │BLOCK │        │ALLOW │
      │return│        │return│
      │false │        │true  │
      └──────┘        └──────┘
```

## Provider Data Flow

```
┌──────────────────────────────────────────────┐
│         Firebase Auth (Backend)              │
│  ┌──────────────────────────────────────┐   │
│  │  User Authentication State           │   │
│  │  - currentUser: User?                │   │
│  │  - authStateChanges: Stream<User?>   │   │
│  └──────────────┬───────────────────────┘   │
└─────────────────┼───────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│        AuthService (services/)               │
│  ┌──────────────────────────────────────┐   │
│  │  Wraps Firebase Auth                 │   │
│  │  - authStateChanges stream           │   │
│  │  - signIn/signOut methods            │   │
│  └──────────────┬───────────────────────┘   │
└─────────────────┼───────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│    Auth Providers (Wave 1)                   │
│  ┌──────────────────────────────────────┐   │
│  │ authServiceProvider                  │   │
│  │   └─> AuthService instance           │   │
│  │                                       │   │
│  │ authStateStreamProvider              │   │
│  │   └─> Stream<User?>                  │   │
│  │                                       │   │
│  │ authStateProvider                    │   │
│  │   └─> AsyncValue<User?>              │   │
│  │                                       │   │
│  │ authInitializationProvider           │   │
│  │   └─> AsyncValue<bool>               │   │
│  └──────────────┬───────────────────────┘   │
└─────────────────┼───────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│       AppRouter (Wave 2)                     │
│  ┌──────────────────────────────────────┐   │
│  │ _redirect(context, state)            │   │
│  │   │                                  │   │
│  │   ├─> Read authInitializationProvider│   │
│  │   ├─> Read authStateProvider         │   │
│  │   ├─> Determine if route protected   │   │
│  │   ├─> Check authentication status    │   │
│  │   └─> Return redirect path or null   │   │
│  └──────────────┬───────────────────────┘   │
└─────────────────┼───────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│         Navigation Outcome                   │
│                                              │
│  • Allow navigation (return null)            │
│  • Redirect to /auth with query param        │
│  • Redirect to /home (authenticated)         │
│  • Redirect to intended destination          │
└──────────────────────────────────────────────┘
```

## Route Types Diagram

```
┌─────────────────────────────────────────────────┐
│              All Routes                         │
│                                                 │
│  ┌───────────────────┐  ┌──────────────────┐  │
│  │  Public Routes    │  │ Protected Routes │  │
│  │  (No Auth)        │  │ (Auth Required)  │  │
│  │                   │  │                  │  │
│  │  • /              │  │  • /home         │  │
│  │  • /welcome       │  │  • /jobs         │  │
│  │  • /auth          │  │  • /storm        │  │
│  │  • /forgot-       │  │  • /locals       │  │
│  │    password       │  │  • /crews/*      │  │
│  │  • /onboarding    │  │  • /settings     │  │
│  │                   │  │  • /profile      │  │
│  │                   │  │  • /tools/*      │  │
│  │                   │  │  • /notifications│  │
│  │                   │  │  • ... (15+ more)│  │
│  └───────────────────┘  └──────────────────┘  │
│                                                 │
│  Public: Always accessible                     │
│  Protected: Redirect if not authenticated      │
└─────────────────────────────────────────────────┘
```

## Summary Legend

**Symbols Used**:
- `▼` - Flow continues downward
- `┌─┴─┐` - Decision point (branching)
- `✅` - Successful outcome
- `❌` - Blocked/Invalid
- `[...]` - User action or async operation

**Key Components**:
- **authInitializationProvider** - Tracks if Firebase Auth is ready
- **authStateProvider** - Provides current user or null
- **_redirect()** - Main navigation guard logic
- **_isValidRedirectPath()** - Security validation
- **_navigateAfterAuth()** - Post-login navigation helper

**States**:
- **Loading** - Auth initializing, allow navigation
- **Authenticated** - User signed in, check destination
- **Unauthenticated** - No user, redirect to /auth
- **Protected** - Route requires authentication
- **Public** - Route always accessible
