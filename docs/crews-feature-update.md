# Crews Feature Update

## New Navigation Flow

- Tapping "Crews" in bottom navigation now goes directly to `TailboardScreen` (the main crew hub).
- If no crew is selected, shows a welcome header with "Create or Join a Crew" button navigating to `CrewOnboardingScreen`.
- `CrewOnboardingScreen` combines create and join options, navigating to respective flows.
- After creating or joining a crew, users land back on `TailboardScreen` with the crew loaded.
- Chat tab accessible without crew: Shows "Direct Messages" / "Global Chat" toggle, using direct messaging providers.

## Key Changes

- Updated `app_router.dart`: `/crews` → `TailboardScreen`, added `/crews/onboarding`.
- New `crew_onboarding_screen.dart`: Welcome-style UI with action buttons.
- Modified `tailboard_screen.dart`: No-crew state integrated into header, tabs always visible, FAB hidden without crew.
- New `messaging_riverpod_provider.dart`: `globalMessagesProvider` and `recentConversationsProvider` for non-crew messaging.
- Updated create/join screens: Post-action navigation to `/crews`.

## Testing Notes

- Verify no-crew state: Direct messaging works, onboarding accessible.
- With crew: Full functionality preserved.
- Build and run: No errors, smooth navigation.


## Medium Priority Updates

- Added persistent dropdown to header for crew switching (Issue #1)
- Implemented error dialogs with retry functionality for crew loading failures (Issue #4)
- Added default selection of first crew when available (Issue #4)
- Added widget tests for CrewSelectionDropdown (Issue #10)
- Added documentation for medium priority changes (Issue #10)
For full implementation details, see `TASK.md`.
