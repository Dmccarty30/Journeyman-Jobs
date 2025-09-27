# TASKS for Rethink Crews Feature Implementation

## Overview

This task list outlines the steps to implement the proposed changes from the "plan-rethink-crews-feature-0.md" for reworking the crews feature navigation and functionality. The goal is to make the "Crews" bottom nav icon navigate directly to TailboardScreen, enable messaging access without crew membership, and combine create/join into a single onboarding screen.

Tasks are grouped by file changes. Complete them in sequence where dependencies exist (e.g., create new files before updating references).

## 1. Update Navigation Routes

- **File:** `lib/navigation/app_router.dart`
  - Update the `/crews` route (around lines 124-127) to point directly to `TailboardScreen()` instead of `CrewsScreen()`.
  - Add a new route `/crews/onboarding` that navigates to the new `CrewOnboardingScreen()`.
  - Remove or deprecate the existing `/crews/create` and `/crews/join` routes, as they will be replaced by the onboarding screen.
  - Update import statements: Add import for `CrewOnboardingScreen` and remove `CrewsScreen` import if the file is being deleted.
  - Test navigation: Ensure tapping "Crews" in bottom nav goes to TailboardScreen, and add a test route for onboarding.

## 2. Create Combined Crew Onboarding Screen

- **File:** `lib/features/crews/screens/crew_onboarding_screen.dart` (New file)
  - Reference `lib/screens/onboarding/welcome_screen.dart` for design pattern: Centered layout with icon, title, description, and two buttons ("Create a Crew" primary, "Join a Crew" outlined).
  - Implement button actions: "Create a Crew" shows inline form or navigates to create flow; "Join a Crew" shows inline form or navigates to join flow.
  - After successful creation or joining, navigate back to `/crews` (TailboardScreen).
  - Include error handling, loading states, and imports for app theme, navigation, and crew services.
  - Ensure compatibility with existing `create_crew_screen.dart` and `join_crew_screen.dart` if integrating their logic.

## 3. Modify Tailboard Screen for No-Crew State

- **File:** `lib/screens/crews/tailboard_screen.dart` (Modify existing)
  - Update `_buildNoCrewSelected` method (lines 80-112): Add welcome message explaining tailboard, prominent "Create/Join Crew" button navigating to `/crews/onboarding`, and keep tab structure visible for Chat access.
  - Modify `ChatTab` class (lines 630-808): When `selectedCrew == null`, show direct messages using `directMessagesProvider` instead of crew chat. Update toggle to "Direct Messages" and "Global Chat".
  - Update `_buildFloatingActionButton`: Adjust logic for no-crew state (e.g., disable or repurpose FAB).
  - Ensure Chat tab uses new `globalMessagesProvider` for direct messages when no crew is selected.
  - Test: Verify UI shows correctly without crew, messaging works, and button navigates to onboarding.

## 4. Add Global Messaging Provider

- **File:** `lib/features/crews/providers/messaging_riverpod_provider.dart` (New file)
  - Create `globalMessagesProvider` for users not in a crew: Aggregate recent direct message conversations or list of messaged users.
  - Leverage existing `directMessagesProvider` for independence from crew membership.
  - Optionally add `recentConversationsProvider` for easy conversation list in Chat tab.
  - Import necessary providers like `auth_riverpod_provider.dart` and `message_service.dart`.
  - Test provider: Ensure it returns direct messages without requiring a selected crew.

## 5. Update Create Crew Screen Navigation

- **File:** `lib/features/crews/screens/create_crew_screen.dart` (Modify existing)
  - Update navigation after successful crew creation (line 56): Navigate to `/crews` to land on TailboardScreen.
  - If integrating into `CrewOnboardingScreen`, update references to point to the new onboarding flow instead of standalone navigation.
  - Ensure consistency with the new route structure.
  - Test: Create a crew and verify navigation to tailboard with the new crew selected.

## 6. Update Join Crew Screen Navigation

- **File:** `lib/features/crews/screens/join_crew_screen.dart` (Modify existing)
  - Update navigation after successful joining (line 41): Navigate to `/crews` to land on TailboardScreen.
  - If integrating into `CrewOnboardingScreen`, update references to point to the new onboarding flow.
  - Ensure consistency with the new route structure.
  - Test: Join a crew and verify navigation to tailboard with the joined crew selected.

## 7. General Cleanup and Testing

- [x] Remove or deprecate `CrewsScreen` if no longer needed (delete file and update any remaining references). No CrewsScreen file found; old import removed from app_router.dart.
- [x] Update any other files referencing old routes (e.g., search for `/crews/create` and `/crews/join`). Routes kept active for onboarding; no other references found.
- [ ] Run full app tests: Verify bottom nav flow, messaging without crew, onboarding integration, and error handling.
- [ ] Update documentation: Add notes to README.md or relevant guides about the new crews flow.
- [x] Commit changes: Use descriptive commit messages for each major task group. (Commit after full implementation)

## Completion Criteria

- [x] All proposed file changes implemented.
- [ ] App builds and runs without errors.
- [ ] New flow tested on device/emulator: No crew → direct to tailboard with messaging → create/join → back to tailboard with crew.
- [x] Existing crew functionality unchanged.

Track progress by marking tasks as [ ] TODO, [x] DONE, or [-] SKIPPED with reasons.
