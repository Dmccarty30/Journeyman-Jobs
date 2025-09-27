# Task: Correct Crew Creation Authentication and Foreman Assignment

## Analysis

The current implementation of the `CreateCrewScreen` suffers from a race condition. It uses `ref.read(currentUserProvider)` to synchronously fetch the user's authentication status inside the `_createCrew` method, which is only triggered upon a button press. If the asynchronous authentication state stream from Firebase has not yet updated the Riverpod provider by the time the user presses the button, the provider returns `null`, leading to a "User not authenticated" error.

This prevents the `crewService.createCrew` method from ever being called, which contains the correct logic to assign the creator's `uid` as the `foremanId`.

The analysis in `crew_auth_corrections.md` is correct.

## Plan

The fix is to make the UI reactive to the authentication state, ensuring the "Create Crew" button is only enabled when the application has confirmed that a user is logged in.

### Step 1: Implement Reactive UI in `create_crew_screen.dart`

1.  **Watch Auth State:** In the `build` method of `CreateCrewScreenState`, use `ref.watch(currentUserProvider)` to subscribe to authentication state changes.
2.  **Conditionally Disable Button:** Modify the `ElevatedButton.icon` widget. The `onPressed` callback will be set to `null` if the watched `currentUser` is `null`, effectively disabling the button. If `currentUser` is not `null`, `onPressed` will be assigned the `_createCrew` method.

This change guarantees that `_createCrew` can only be executed when a user is authenticated, resolving the race condition and allowing the existing foreman assignment logic to function correctly.

### Step 2: Verify Implementation

After applying the code changes, the task will be complete. The expected outcome is:
- When a logged-in user navigates to the "Create New Crew" screen, the "Create Crew" button is enabled.
- When the user clicks the button, the crew is created successfully.
- The user who created the crew is automatically assigned the `foreman` role.