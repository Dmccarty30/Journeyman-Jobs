# Implementation Plan

This revised implementation plan incorporates actionable task lists at the end of each section, directly associated with the content above. Each task set is concise (3-6 items per section), focused on UI-only changes, and balanced for clarity without overcomplication or excessive granularity. Tasks are derived from the specific recommendations in the section and can be tracked via checkboxes. The overall structure remains the same, focusing exclusively on visual/layout/animation integration from `docs/tailboard/tailboard-design.dart` into `lib/features/crews/screens/tailboard_screen.dart`.

## Overview

This plan outlines the integration of the FlutterFlow-generated UI design from `docs/tailboard/tailboard-design.dart` into the existing `lib/features/crews/screens/tailboard_screen.dart`, focusing exclusively on UI elements, layouts, components, animations, and interactions. No backend logic, data fetching, or state management changes are included—only visual and structural updates to match the design while preserving the existing Riverpod watchers and conditional rendering for crew/no-crew states. The plan ensures compatibility with the project's theme (`AppTheme`), avoids introducing FlutterFlow-specific widgets (e.g., FFButtonWidget → ElevatedButton), and handles animations using `flutter_animate`. The goal is a pixel-accurate recreation of the four-tab interface with responsive elements.

The approach prioritizes modularity: extract reusable components from the design, integrate conditional headers, port tab views with placeholders for existing widgets (e.g., JobMatchCard), and apply animations conservatively to avoid performance issues. This fits the existing codebase by building on the scaffolded structure in `tailboard_screen.dart`, enhancing empty states, and maintaining accessibility via semantics.

**Actionable Tasks for Overview:**

- [ ] Review the full content of `docs/tailboard/tailboard-design.dart` and `lib/features/crews/screens/tailboard_screen.dart` side-by-side to confirm UI discrepancies (e.g., tab icons, header layouts).
- [ ] Verify no backend dependencies are altered by testing the screen with mock data (e.g., selectedCrewProvider with null/non-null values).
- [ ] Document any theme color mismatches (e.g., FlutterFlowTheme vs. AppTheme) in a comment block for quick reference during implementation.

## [Types]

No new type definitions are required, as the UI integration reuses existing models (e.g., Crew, Job) from the codebase. Minor extensions to local state management in `_TailboardScreenState` include adding a `TabController` (already present) and animation controllers for specific elements like fade/move effects on post cards, but no new interfaces, enums, or data structures are needed. Validation rules remain unchanged (e.g., text field constraints via existing form keys).

**Actionable Tasks for Types:**

- [ ] Inspect `_TailboardScreenState` for existing local state (e.g., controllers); add AnimationController references only if animations demand it (e.g., for TabBarView transitions).
- [ ] Confirm reuse of existing Job/Crew models in tab views without type extensions by tracing imports in tailboard_screen.dart.
- [ ] Add inline comments documenting any local UI-specific state (e.g., animation triggers) without creating new classes.

## [Files]

One existing file will be modified: `lib/features/crews/screens/tailboard_screen.dart`. No new files are created, and no deletions occur. Specific changes include:

- Update the Scaffold body to incorporate SafeArea wrapping and GestureDetector for unfocusing inputs (from tailboard-design.dart lines 92-95).
- Replace header sections (_buildNoCrewHeader,_buildHeader) with styled versions matching the design (welcome text, button styling).
- Enhance _buildTabBar with icons and labels from the design (feed, forest for Jobs, chat_bubble, people_alt).
- Update TabBarView children (FeedTab, JobsTab, ChatTab, MembersTab) to port ListView builders, containers, and rows for posts/jobs/messages/members.
- Integrate FloatingActionButton styling but keep existing onPressed handlers.
- Add animation imports and setup in initState/dispose if not present.

Configuration updates: Ensure `pubspec.yaml` includes `flutter_animate` (already present) for effects; no changes needed.

**Actionable Tasks for Files:**

- [ ] Open `lib/features/crews/screens/tailboard_screen.dart` and insert SafeArea/GestureDetector at the Scaffold body root, preserving existing Column structure.
- [ ] Locate and update header functions (_buildNoCrewHeader,_buildHeader) by copying layout patterns (e.g., Padding, Align from design lines 134-210) without altering Riverpod calls.
- [ ] Modify TabBarView children one-by-one: Start with FeedTab (port ListView.builder from design lines 338-595), then proceed to others, ensuring no data sources are touched.
- [ ] Add imports for animations (e.g., import 'package:flutter_animate/flutter_animate.dart';) at the top of tailboard_screen.dart.

## [Functions]

No new functions are added. Existing functions will be modified as follows:

- In `lib/features/crews/screens/tailboard_screen.dart`:
  - _buildNoCrewHeader(): Update to include welcome text, subtitle ("This is where you can, [custom text]"), and styled ElevatedButton with primary color and circular border (match design's FFButtonWidget at lines 178-210).
  - _buildHeader(): Enhance crew info row with avatar Container, name/member count Text, more_vert IconButton; add stats Row with three _buildStatItem calls (Jobs, Applications, Score) using Icons.work, assignment_turned_in, analytics (lines in design for stats row).
  - _buildTabBar(): Modify labels to 'Feed', 'Jobs', 'Chat', 'Members' with icons (Icons.feed, Icons.forest, Icons.chat_bubble_outline, Icons.people_alt); add labelColor as AppTheme.accentCopper.
  - TabBarView children (e.g., FeedTab build()): Port ListView.builder for social posts with Container (white bg, shadow, border), inner Row for avatar/username/time, content Text, divider, reaction Row (comment, favorite, bookmark, share icons).
  - JobsTab build(): Update ListView.builder to match job card structure: Row for local/classification, grid-like rows for posted time/location/hours/per diem with icons (access_time, location_pin, clock, dollar_sign); two buttons (View Details, Bid Now) with primary/secondary colors.
  - ChatTab build(): Port SingleChildScrollView with ListView for message bubbles (right-aligned gradient for sent, left for received); bottom Row with Autocomplete TextField, back/send IconButtons.
  - MembersTab build(): Update ListView.builder for member rows: Container with avatar ClipRRect, name/email Column, chevron Card; apply fade/move animation on page load.
  - _buildStatItem(): No change, but ensure it matches design's row spacing and icon sizes (16px).
  - initState/dispose: Add animationsMap and setupAnimations for containerOnPageLoadAnimation (Fade/Move effects, duration 400ms).

No functions are removed.

**Actionable Tasks for Functions:**

- [ ] Update _buildNoCrewHeader() by replacing Text widgets with design-equivalent (heading, subtitle) and convert FFButton to ElevatedButton with matching padding/borderRadius.
- [ ] Enhance _buildHeader() with Row for avatar/info/actions, then add stats Row calling_buildStatItem three times with specific icons and placeholders.
- [ ] Port FeedTab and JobsTab build() methods: Copy Container/Row structures for posts/jobs, replacing random_data with existing provider placeholders.
- [ ] Integrate animations in initState(): Define animationsMap with Fade/Move effects and call setupAnimations; apply .animateOnPageLoad in MembersTab ListView items.

## [Classes]

No new classes are added or removed. The existing `_TailboardScreenState` class in `lib/features/crews/screens/tailboard_screen.dart` will be extended with TickerProviderStateMixin (already present) for TabController and animations. Placeholder classes like FeedTab, JobsTab, etc., remain StatelessWidget/ConsumerWidget with build() methods updated to port design structures (e.g., integrate StreamBuilder<List<JobsRecord>> if present, but UI-only). No inheritance changes.

**Actionable Tasks for Classes:**

- [ ] Confirm `_TailboardScreenState` extends with TickerProviderStateMixin; add any missing fields like animationsMap if animations are introduced.
- [ ] Update FeedTab/JobsTab classes' build() to incorporate ported widgets (e.g., Container for post cards) while keeping ConsumerWidget for Riverpod.
- [ ] Ensure placeholder classes (ChatTab, MembersTab) handle UI ports without state changes; test class rendering with flutter test --update-goldens if golden tests exist.

## [Dependencies]

No new dependencies are required, as `flutter_animate` is already in pubspec.yaml for animations. Version compatibility: Ensure flutter_riverpod ^3.0.0-dev.17 and go_router ^16.0.0 handle tab navigation without conflicts. No package installations needed; use existing google_fonts for text styles and font_awesome_flutter for icons (e.g., clock, dollar_sign).

**Actionable Tasks for Dependencies:**

- [ ] Run `flutter pub get` to confirm no new packages needed; check pubspec.yaml for flutter_animate and font_awesome_flutter.
- [ ] Add import statements in tailboard_screen.dart for any existing deps used in ports (e.g., google_fonts for bodyLarge styles).

## [Testing]

Unit/integration tests will be added to `test/features/crews/screens/tailboard_screen_test.dart` (create if missing). Test cases:

- Render no-crew header with button tap simulation (pumpWidget, find.text('Welcome'), expect ElevatedButton).
- Render with-crew header: Verify stats row (find.text('Jobs'), find.byIcon(Icons.work)).
- Tab switching: Pump TabBarView, verify tab indices and ListView counts (e.g., expect ListView.builder itemCount == mock data length).
- UI interactions: Tap reactions, ensure no crashes; test animations with pumpAndSettle.
- Empty states: Mock selectedCrew == null, verify Center column with icon/text.
- Widget tests for ported components (e.g., social post Container, job card Row). Validation: Use golden tests for pixel matching if setup; run `flutter test` post-implementation.

**Actionable Tasks for Testing:**

- [ ] Create/update tailboard_screen_test.dart with widget tests for headers (e.g., pump _buildNoCrewHeader, assert find.text exists).
- [ ] Add tab interaction tests: Simulate TabController index changes and verify TabBarView child rendering.
- [ ] Test animations: Use pumpAndSettle on containers and assert opacity/position changes.

## [Implementation Order]

1. Update imports in tailboard_screen.dart to include flutter_animate and existing utils (e.g., animationsMap setup).
2. Enhance class state with animationsMap and integrate into initState/dispose.
3. Modify headers (_buildNoCrewHeader,_buildHeader) with design styling and components.
4. Update _buildTabBar with icons/labels and TabController listener.
5. Port FeedTab UI: Implement ListView.builder for posts with Container/Row structures and reactions.
6. Port JobsTab UI: Update card layout with grid rows and buttons.
7. Port ChatTab UI: Add SingleChildScrollView, message ListView, and input Row with TextField/Autocomplete.
8. Port MembersTab UI: Update member rows with avatar/name/email and animation.
9. Style FloatingActionButton and ensure tab-based visibility.
10. Add widget tests and run `flutter analyze` for linting.

**Actionable Tasks for Implementation Order:**

- [ ] Follow steps 1-3: Complete imports, state enhancements, and header updates; commit as "UI: Update Tailboard headers".
- [ ] Proceed to steps 4-6: Implement TabBar and first three tabs; verify with `flutter run --debug`.
- [ ] Complete steps 7-10: Finish Chat/Members tabs, FAB styling, tests, and linting; run full `flutter test`.
