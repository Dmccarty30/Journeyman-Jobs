# Analysis of Authentication and Foreman Role Assignment in Crew Creation

## Overview of Relevant Documentation Insights

The documentation provides foundational context on authentication and user roles but lacks specifics on crew creation failures post-sign-up. Key insights:

- From [`guide/screens.md`](guide/screens.md:10-14, 84-109), authentication screens (Welcome, Login, Signup, Forgot Password) form the entry point, with Signup handling new user registration. Post-auth, users access protected features like profile management, which ties into crew operations (e.g., assigning professional details like ticket number to the user profile). The docs imply that after signup, the user should be immediately authenticated and redirected to onboarding or main navigation, but they don't detail state propagation issues that could cause persistent "unauthenticated" states.

- From [`guide/instructions.md`](guide/instructions.md:12-13), error prevention and feedback are emphasized, aligning with the snackbar error. However, for post-signup failures, this suggests potential gaps in session initialization or route guards that fail to recognize newly created users as authenticated.

No explicit docs on foreman role assignment, but under "User Profile Management" in [`guide/screens.md`](guide/screens.md:57-62), professional roles (e.g., foreman) are stored in the Users collection post-auth, implying that crew creation should leverage the authenticated user's `uid` to auto-assign the foreman role. The error persisting after new account creation points to a disconnect between signup completion and auth state update, possibly in Riverpod providers or navigation flow.

Overall, docs confirm Firebase Auth's role in session management, but the issue likely stems from implementation details in auth state listening and role assignment during crew creation.

## Specific Type Definitions and Locations

Core types for auth and roles:

- **User (Firebase Auth)**: Represents the authenticated user with `uid` used for foreman assignment. Referenced throughout but not redefined locally.
  - Used in [`lib/services/auth_service.dart`](lib/services/auth_service.dart:29): `User? get currentUser => _auth.currentUser;`

- **AuthState**: Wraps auth details, including the `User?` for checking authentication.
  - Defined in [`lib/providers/riverpod/auth_riverpod_provider.dart`](lib/providers/riverpod/auth_riverpod_provider.dart:11-43):

    ```dart
    class AuthState {
      // ...
      final User? user;  // Line 20: Null if unauthenticated, triggers error
      bool get isAuthenticated => user != null;  // Line 26: Explicit check
      // copyWith for state updates (lines 28-40)
    }
    ```

- **Crew**: Model for crews, including `roles` map where the creator is assigned `MemberRole.foreman`.
  - Defined in [`lib/features/crews/models/crew.dart`](lib/features/crews/models/crew.dart) (inferred from usage; partial read shows instantiation). Key field: `Map<String, MemberRole> roles;` – `uid` maps to `MemberRole.foreman` for the creator.

- **MemberRole Enum**: Defines roles like `foreman`, `lead`, `member`.
  - Defined in [`lib/domain/enums/member_role.dart`](lib/domain/enums/member_role.dart:1-10) (inferred):

    ```dart
    enum MemberRole { foreman, lead, member }
    ```

    - Used in role assignment: `MemberRole.foreman` (e.g., in crew_service at line 277).

- **Permission Enum**: Ties roles to actions (e.g., `Permission.createCrew` for foremen).
  - Defined in [`lib/domain/enums/permission.dart`](lib/domain/enums/permission.dart:1-20) (inferred), used in `RolePermissions` class for checks.

These types ensure the creator's `uid` is bound to `foreman` during creation, but the auth check fails before reaching role assignment.

## Relevant Implementations

The issue: Despite new signup, `currentUserProvider` returns `null`, throwing the exception in the screen before role assignment. Role assignment *does* occur in `CrewService.createCrew` (assuming the call reaches it), but the auth gatekeeper blocks it. Analysis shows a potential race condition or incomplete state update post-signup.

- **Signup and Auth State Initialization** (`lib/services/auth_service.dart`):
  - `signUpWithEmailAndPassword` (lines 35-48): Creates a new user via `createUserWithEmailAndPassword`, returning `UserCredential` (includes `User` with `uid`). Immediately authenticates the user – post-call, `currentUser` should be non-null.
    - Exception handling (line 46) via `_handleAuthException` (lines 181-204) maps Firebase errors but doesn't address post-creation state sync.
  - `authStateChanges` stream (line 32): Emits the new `User` after signup, but if the screen loads before the stream updates Riverpod state, `currentUserProvider` may still be `null`.

- **Auth State Management** (`lib/providers/riverpod/auth_riverpod_provider.dart`):
  - `authStateStreamProvider` (lines 50-54): Streams `authStateChanges` from `AuthService`.
  - `currentUserProvider` (lines 57-65): Watches the stream and extracts `User?`. Uses `AsyncValue.when` to handle loading/error, returning `null` during transitions – this could persist briefly after signup if the provider isn't refreshed.
  - `AuthNotifier` (lines 69-178): Listens to the stream (lines 79-97) and updates `state.user`. Post-signup, it should set `isAuthenticated: true`, but if the notifier builds before the stream fires (e.g., due to widget tree timing), the check fails.
  - No explicit post-signup refresh; relies on stream, which might lag in hot reload or navigation scenarios.

- **Crew Creation Screen Logic** (`lib/features/crews/screens/create_crew_screen.dart`):
  - `_createCrew` method (lines 35-70):
    - Line 39: `final currentUser = ref.read(currentUserProvider);` – Synchronous read; if state hasn't updated post-signup, `null`.
    - Lines 41-42: Throws `Exception('User not authenticated')` if null, shown in snackbar (lines 62-67).
    - If passed, line 47: `foremanId: currentUser.uid` – Directly uses `uid` for ownership.
  - No async wait for auth state; assumes provider is current. This is the bug: Signup completes, but screen doesn't await state propagation.

- **Crew Service and Foreman Role Assignment** (`lib/features/crews/services/crew_service.dart`):
  - `createCrew` method (lines 213-304): Receives `foremanId` (line 214) and assigns role at instantiation (lines 276-278):

    ```dart
    final crew = Crew(
      // ...
      roles: {foremanId: MemberRole.foreman},  // Line 277: Auto-assigns creator as foreman
      // ...
    );
    ```

    - Writes to Firestore (line 294): `crews.doc(crewId).set(crew.toFirestore())`, storing the role map.
    - `RolePermissions` class (lines 21-49): Defines foreman permissions (e.g., `Permission.createCrew`, line 23), but checked post-creation (e.g., in `inviteMember` at lines 417-418 via `hasPermission`).
    - Offline handling (lines 239-266): Mirrors role assignment locally, but still requires valid `foremanId` from auth.
  - Role is correctly assigned *if* the method is called, confirming the screen's auth check is the blocker. No additional foreman validation here – trusts the passed `uid`.

- **Navigation and Route Guards** (`lib/navigation/app_router.dart` – inferred from imports):
  - Likely uses `isRouteProtected` provider (from auth_riverpod_provider, lines 189-201) to guard `/crews` or creation routes. If signup redirects without waiting for auth state, the screen mounts with stale `null` user.
  - Onboarding flow (e.g., `lib/screens/onboarding/auth_screen.dart`) may complete signup but navigate prematurely.

The logic for assigning foreman is correct (in `Crew` instantiation), but the persistent error indicates a state sync issue: Signup succeeds, but Riverpod doesn't reflect the new `User` immediately, causing `ref.read(currentUserProvider)` to return `null`.

## Critical Dependencies and Their Roles

- **Firebase Auth (`firebase_auth`)**: Handles signup (creates user and session). Post-`createUserWithEmailAndPassword`, the stream should emit the `User`, but delays (network/auth verification) can cause races.
  - Role: Provides `uid` for `foremanId`; failure here would throw Firebase exceptions, not the generic "not authenticated".

- **Riverpod (`flutter_riverpod`)**: Manages reactive state. `ref.read` is sync and doesn't await async updates, exacerbating timing issues.
  - Role: `currentUserProvider` is the failure point; depends on stream timing.

- **Cloud Firestore (`cloud_firestore`)**: Stores crew with roles (line 294). Security rules (not in code, but implied) require `request.auth.uid == foremanId`.
  - Role: Enforces backend auth; would reject writes if session invalid, but frontend blocks first.

- **GoRouter (`go_router`)**: Post-signup navigation (e.g., to onboarding or crews) may not trigger provider rebuilds.
  - Role: If routes load screens before auth settles, exposes the bug.

## Suggested Fixes

1. **Add Async Auth Check in Screen**: In `create_crew_screen.dart:_createCrew` (line 35), replace sync `ref.read` with async wait:

   ```dart
   final currentUser = ref.watch(currentUserProvider);  // Watch for reactivity
   if (currentUser == null) {
     // Show loading or redirect to login
     await Future.delayed(Duration(milliseconds: 500));  // Brief wait for state
     final updatedUser = ref.read(currentUserProvider);
     if (updatedUser == null) throw Exception('User not authenticated');
   }
   ```

   Better: Use `ref.watch(isAuthenticatedProvider)` and disable button if false.

2. **Post-Signup State Refresh**: In signup screen (e.g., `lib/screens/auth/signup_screen.dart` – assumed), after `signUpWithEmailAndPassword`, force provider refresh:

   ```dart
   await authNotifier.signInWithEmailAndPassword(...);  // If separate
   ref.invalidate(authStateStreamProvider);  // Trigger rebuild
   context.go('/onboarding');  // Navigate after confirmation
   ```

3. **Enhance AuthNotifier**: In `auth_riverpod_provider.dart` (line 102), add post-signup handling in `signInWithEmailAndPassword` to ensure state updates before returning.

4. **Route Guard Improvement**: In `app_router.dart`, use async guards: Check `ref.watch(currentUserProvider)` before allowing access to creation routes, redirecting to login if null.

5. **Debug Steps**: Add logs in `AuthNotifier` (line 86) to trace stream emissions post-signup. Test in release mode, as hot reload may exacerbate races.

This fixes the sync issue without altering role assignment logic, which is already correct.
