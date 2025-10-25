# Journeyman Jobs - Task List

**Generated:** 2025-10-24
**Source:** TODO.md analysis
**Organization:** By screen/feature area

---

## < APP WIDE CHANGES

### Task 1.1: Implement Session Grace Period System

**Description:** Update user authentication and session handling logic to implement a 5-minute grace period for automatic logouts. This prevents abrupt session terminations and allows users to resume activity without re-authenticating.

**Domain:** Authentication & Session Management

**Difficulty:** PPPP Complex

**Importance:** =4 Critical (User Experience Impact)

**Recommended Agent:** auth-expert

**Skills/Tools Required:**

- Firebase Authentication lifecycle management
- Flutter background/foreground state detection
- Timer management and state persistence
- Cross-platform session handling (iOS/Android)

**Technical Requirements:**

- Implement idle detection after 2 minutes of inactivity
- Start 5-minute grace period timer after inactivity confirmed
- Reset timer on user activity resumption
- Synchronize client-side and server-side timers
- Handle edge cases (multiple triggers, app closure, network disconnection)
- Add UI notification at 4-minute mark
- Comprehensive logging for debugging

**Acceptance Criteria:**

- [ ] No sign-out within 5 minutes of trigger conditions
- [ ] Sign-out occurs precisely at 5-minute mark if no resumption
- [ ] Timer resets seamlessly on user activity
- [ ] Works consistently across iOS and Android
- [ ] Warning notification displays at 4-minute mark
- [ ] All edge cases handled (multiple triggers, network issues)

**Dependencies:** None

**Estimated Effort:** 8-12 hours

---

## <� APP THEME

### Task 2.1: Implement Dark Mode Theme

**Description:** Create and implement a comprehensive dark mode theme for the entire application with proper theme switching functionality.

**Domain:** UI/UX Design & Theming

**Difficulty:** PPP Moderate

**Importance:** =� Medium (Enhancement)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter ThemeData configuration
- Dark mode color palette design
- State management for theme persistence
- Contrast ratio validation (WCAG compliance)

**Technical Requirements:**

- Design dark mode color palette maintaining electrical theme
- Implement theme switching mechanism
- Persist user theme preference
- Ensure WCAG AA contrast compliance
- Update all custom components for dark mode support

**Acceptance Criteria:**

- [ ] Complete dark mode color palette defined
- [ ] Theme switching works seamlessly
- [ ] Theme preference persists across sessions
- [ ] All screens render correctly in dark mode
- [ ] WCAG AA contrast ratios met
- [ ] Smooth theme transition animations

**Dependencies:** None

**Estimated Effort:** 6-8 hours

---

## =� ONBOARDING SCREENS

### Task 3.1: Remove Dark Mode from Onboarding Flow

**Description:** Remove dark mode theme from all onboarding screens (Welcome � Auth � Onboarding Steps � Home) and apply consistent light mode app-wide theme.

**Domain:** UI/UX Theming

**Difficulty:** PP Simple

**Importance:** =� Medium (Consistency)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter theme configuration
- Widget theming
- Design system consistency

**Affected Files:**

- `lib/screens/onboarding/welcome_screen.dart`
- `lib/screens/onboarding/auth_screen.dart`
- `lib/screens/onboarding/onboarding_steps_screen.dart`

**Technical Requirements:**

- Remove dark mode theme overrides from onboarding screens
- Apply AppTheme light mode consistently
- Verify electrical design theme elements maintained
- Test theme consistency across entire onboarding flow

**Acceptance Criteria:**

- [ ] All onboarding screens use light mode theme
- [ ] No dark mode theme overrides present
- [ ] AppTheme applied consistently
- [ ] Electrical design elements preserved
- [ ] Visual consistency validated

**Dependencies:** None

**Estimated Effort:** 2-3 hours

---

## <� HOME SCREEN

### Task 4.1: Fix User Name Display on Home Screen

**Description:** Change home screen greeting from "Welcome back [email]" to "Welcome back [First Name] [Last Name]" using proper user document data.

**Domain:** UI/Data Binding

**Difficulty:** PP Simple

**Importance:** =� High (User Experience)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Riverpod state management
- User model data access
- Firestore user document queries

**Affected Files:**

- `lib/screens/storm/home_screen.dart`

**Technical Requirements:**

- Access user document from Firestore
- Extract firstName and lastName fields
- Update greeting text widget
- Handle null/missing name fields gracefully
- Test with various user data states

**Acceptance Criteria:**

- [ ] Greeting displays first and last name
- [ ] Handles missing name data gracefully
- [ ] No email address displayed
- [ ] Data loads efficiently on screen mount

**Dependencies:** User document must contain firstName/lastName fields

**Estimated Effort:** 1-2 hours

---

### Task 4.2: Fix Suggested Jobs Display and Firestore Index

**Description:** Resolve the Firestore index error preventing suggested jobs from displaying. Create required composite index and fix the jobs query logic.

**Domain:** Database Optimization & Query Performance

**Difficulty:** PPP Moderate

**Importance:** =4 Critical (Core Feature Broken)

**Recommended Agent:** database-optimizer

**Skills/Tools Required:**

- Firebase Firestore composite indexes
- Query optimization
- Flutter Riverpod providers
- Debug log analysis

**Technical Requirements:**

- Create composite index: `jobs` collection with fields `deleted`, `local`, `timestamp`, `__name__`
- Fix query in jobs provider to handle index requirements
- Implement proper error handling for index creation delay
- Optimize query for user preferences (locals: [84, 111, 222])
- Add loading states and error feedback

**Error Context:**

```
FAILED_PRECONDITION: The query requires an index.
Query: jobs where local in [84,111,222] and deleted==false
       order by -timestamp, -__name__
```

**Acceptance Criteria:**

- [ ] Composite index created in Firebase Console
- [ ] Query executes without FAILED_PRECONDITION error
- [ ] Suggested jobs display based on user preferences
- [ ] Loading states implemented
- [ ] Error handling for query failures
- [ ] Debug logs confirm successful job retrieval

**Dependencies:**

- User preferences (preferred locals) must be set
- Firebase Console access for index creation

**Estimated Effort:** 3-4 hours

**Reference Document:** `@docs\plans\MISSING_METHODS_IMPLEMENTATION.dart`

---

### Task 4.3: Implement Missing Methods for Suggested Jobs

**Description:** Implement the missing methods outlined in MISSING_METHODS_IMPLEMENTATION.dart to enable suggested jobs functionality based on user-defined preferences.

**Domain:** Business Logic & State Management

**Difficulty:** PPPP Complex

**Importance:** =4 Critical (Core Feature)

**Recommended Agent:** flutter-expert + database-optimizer

**Skills/Tools Required:**

- Riverpod state management
- Firestore query building
- Flutter StreamBuilder
- Job matching algorithms

**Technical Requirements:**

- Implement `loadSuggestedJobs()` method in JobsRiverpodProvider
- Implement preference-based filtering (locals, construction types, hours, per diem)
- Add proper error handling and loading states
- Optimize query performance for large datasets
- Cache results for offline access

**Acceptance Criteria:**

- [ ] All missing methods implemented
- [ ] Jobs filter by user preferences
- [ ] Results sorted by relevance
- [ ] Loading and error states handled
- [ ] Performance optimized (< 2s load time)
- [ ] Works offline with cached data

**Dependencies:**

- Task 4.2 (Firestore index) must be completed first
- User preferences must be saved in Firestore

**Estimated Effort:** 6-8 hours

---

## =� JOB SCREEN

### Task 5.1: Apply Title Case Formatting to Job Details Dialog

**Description:** Apply Title Case formatting to all text values in the job details dialog popup to match the formatting on job cards.

**Domain:** UI/Text Formatting

**Difficulty:** P Trivial

**Importance:** =� Medium (UI Consistency)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Dart string manipulation
- Flutter text widgets
- Text formatting utilities

**Affected Files:**

- `lib/screens/storm/jobs_screen.dart`

**Technical Requirements:**

- Create/use Title Case formatter utility
- Apply to all text fields in job details dialog
- Maintain consistency with job card formatting
- Test with various text inputs (all caps, lowercase, mixed)

**Acceptance Criteria:**

- [ ] All dialog text uses Title Case
- [ ] Formatting matches job cards
- [ ] Works with edge cases (acronyms, special characters)
- [ ] No performance impact

**Dependencies:** None

**Estimated Effort:** 1 hour

---

## � STORM SCREEN

### Task 6.1: Fix Contractor Cards Display

**Description:** Investigate and fix why contractor cards are not displaying in the contractor section of the Storm screen.

**Domain:** UI/Data Rendering

**Difficulty:** PPP Moderate

**Importance:** =4 Critical (Feature Not Working)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter widget debugging
- State management inspection
- Data flow analysis
- ListView/GridView rendering

**Affected Files:**

- `lib/screens/storm/storm_screen.dart`

**Technical Requirements:**

- Debug contractor data loading
- Verify Firestore query for contractors
- Check widget tree rendering
- Inspect state management updates
- Add error handling and loading states

**Investigation Steps:**

1. Check if contractor data is being fetched from Firestore
2. Verify contractor model mapping
3. Inspect widget build method
4. Check for null/empty data handling
5. Review console for errors

**Acceptance Criteria:**

- [ ] Root cause identified
- [ ] Contractor cards render correctly
- [ ] Data loads from Firestore
- [ ] Loading states implemented
- [ ] Error handling added
- [ ] No console errors

**Dependencies:** Contractor data must exist in Firestore

**Estimated Effort:** 3-5 hours

---

## =e TAILBOARD SCREEN

### Task 7.1: Fix Overflow Error in Tailboard Screen

**Description:** Fix the RenderFlex overflow error (25 pixels on the right) occurring in the Row widget at line 357 of tailboard_screen.dart.

**Domain:** UI Layout & Responsive Design

**Difficulty:** PP Simple

**Importance:** =� High (Bug Fix)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter layout debugging
- Flex widgets (Row, Column, Expanded)
- Responsive design
- DevTools inspector

**Affected Files:**

- `lib/features/crews/screens/tailboard_screen.dart` (line 357)

**Error Context:**

```
A RenderFlex overflowed by 25 pixels on the right.
Row at file:///C:/Users/david/Desktop/Journeyman-Jobs/lib/features/crews/screens/tailboard_screen.dart:357:14
constraints: BoxConstraints(0.0<=w<=93.3, 0.0<=h<=Infinity)
```

**Technical Requirements:**

- Wrap overflowing widget with Expanded or Flexible
- Adjust Row constraints
- Test on various screen sizes
- Ensure text doesn't truncate inappropriately
- Verify responsive behavior

**Acceptance Criteria:**

- [ ] No overflow error in console
- [ ] Layout displays correctly on all screen sizes
- [ ] Text remains readable
- [ ] No clipping or truncation issues

**Dependencies:** None

**Estimated Effort:** 1-2 hours

---

## =h

=i
=g
=f CREATE CREWS SCREEN

### Task 8.1: Fix Crew Preferences Save Error

**Description:** Fix the "error saving preferences, try again" notification when pressing the save preferences button in the user job preferences dialog.

**Domain:** Data Persistence & Error Handling

**Difficulty:** PPP Moderate

**Importance:** =4 Critical (Feature Broken)

**Recommended Agent:** database-optimizer + auth-expert

**Skills/Tools Required:**

- Firestore write operations
- Error debugging
- Flutter exception handling
- User document structure

**Affected Files:**

- `lib/widgets/dialogs/user_job_preferences_dialog.dart`

**Technical Requirements:**

- Debug Firestore write operation
- Check user document permissions
- Verify data model validation
- Add detailed error logging
- Implement proper error feedback
- Test with various preference combinations

**Investigation Steps:**

1. Check Firebase console for error logs
2. Verify Firestore security rules
3. Inspect data being sent to Firestore
4. Check user authentication state
5. Review preferences data model

**Acceptance Criteria:**

- [ ] Preferences save successfully to Firestore
- [ ] User document updated correctly
- [ ] Success notification displays
- [ ] Error logging implemented
- [ ] Handles edge cases (network failures, permission issues)

**Dependencies:** User must be authenticated

**Estimated Effort:** 3-4 hours

---

### Task 8.2: Implement Feed Tab Message Display

**Description:** Implement immediate message posting and display in the Feed tab when a user posts a message.

**Domain:** Real-time Data & UI Updates

**Difficulty:** PPP Moderate

**Importance:** =� High (User Experience)

**Recommended Agent:** database-optimizer + flutter-expert

**Skills/Tools Required:**

- Firestore real-time listeners
- StreamBuilder widgets
- Riverpod state management
- Message ordering and timestamps

**Reference:** `docs/tailboard/feed-tab.png`

**Technical Requirements:**

- Implement Firestore write for new messages
- Set up real-time listener for feed updates
- Add optimistic UI updates
- Handle message ordering by timestamp
- Implement proper error handling
- Add loading states during message posting

**Acceptance Criteria:**

- [ ] Message posts to Firestore immediately
- [ ] New message displays in feed instantly
- [ ] Messages ordered chronologically
- [ ] Optimistic UI updates working
- [ ] Error handling for failed posts
- [ ] No duplicate messages

**Dependencies:** Crew feed collection must exist in Firestore

**Estimated Effort:** 4-5 hours

---

### Task 8.3: Implement Chat Tab Message Display

**Description:** Implement immediate message posting and display in the Chat tab when a user sends a message to the crew.

**Domain:** Real-time Messaging

**Difficulty:** PPP Moderate

**Importance:** =� High (User Experience)

**Recommended Agent:** database-optimizer + flutter-expert

**Skills/Tools Required:**

- Firestore real-time listeners
- Chat UI patterns
- Message synchronization
- Timestamp handling

**Reference:** `docs/tailboard/chat-tab.png`

**Technical Requirements:**

- Implement Firestore write for chat messages
- Set up real-time listener for chat updates
- Add optimistic UI updates
- Handle message ordering and grouping
- Implement read receipts (if required)
- Add proper error handling

**Acceptance Criteria:**

- [ ] Message posts to Firestore immediately
- [ ] New message displays in chat instantly
- [ ] Messages ordered chronologically
- [ ] Chat scrolls to latest message
- [ ] Error handling for failed sends
- [ ] No duplicate messages

**Dependencies:** Crew chat collection must exist in Firestore

**Estimated Effort:** 4-5 hours

---

## =� LOCALS SCREEN

### Task 9.1: Review and Optimize Locals Screen Performance

**Description:** Review the locals screen implementation and optimize performance for displaying 797+ IBEW locals.

**Domain:** Performance Optimization

**Difficulty:** PPP Moderate

**Importance:** =� Medium (Performance)

**Recommended Agent:** database-optimizer + flutter-expert

**Skills/Tools Required:**

- ListView optimization
- Pagination implementation
- Search/filter performance
- Data caching strategies

**Affected Files:**

- `lib/screens/storm/locals_screen.dart`

**Technical Requirements:**

- Implement virtualized list rendering
- Add pagination or lazy loading
- Optimize search/filter operations
- Cache local data for offline access
- Profile and measure performance improvements

**Acceptance Criteria:**

- [ ] Smooth scrolling with 797+ items
- [ ] Search/filter operations < 300ms
- [ ] Memory usage optimized
- [ ] Works offline with cached data
- [ ] Performance metrics documented

**Dependencies:** None

**Estimated Effort:** 4-6 hours

---

## � SETTINGS SCREEN

### Task 10.1: Remove Welcome Message from Settings Screen

**Description:** Remove the "Welcome back brother" text from the settings screen header as it's not appropriate for a settings page.

**Domain:** UI/UX Refinement

**Difficulty:** P Trivial

**Importance:** =� Medium (UX)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter widget modification

**Affected Files:**

- `lib/screens/storm/settings_screen.dart`

**Technical Requirements:**

- Remove welcome text widget
- Update header layout
- Maintain proper spacing

**Acceptance Criteria:**

- [ ] Welcome text removed
- [ ] Header layout looks correct
- [ ] No layout issues

**Dependencies:** None

**Estimated Effort:** 15 minutes

---

### Task 10.2: Fix Job Preferences Dialog Overflow Error

**Description:** Fix the overflow error on the save preferences button in the job preferences dialog accessed from the settings screen.

**Domain:** UI Layout

**Difficulty:** PP Simple

**Importance:** =� High (Bug Fix)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter layout debugging
- Dialog sizing
- Responsive design

**Technical Requirements:**

- Adjust dialog constraints
- Wrap button in Flexible/Expanded if needed
- Test on various screen sizes
- Ensure all dialog content fits

**Acceptance Criteria:**

- [ ] No overflow error on save button
- [ ] Dialog displays correctly on all screen sizes
- [ ] All dialog content visible and accessible

**Dependencies:** None

**Estimated Effort:** 1 hour

---

### Task 10.3: Update Job Classification Options

**Description:** Update the classification options in the job preferences dialog to include only relevant electrical worker classifications.

**Domain:** Data Model & UI

**Difficulty:** P Trivial

**Importance:** =� Medium (Data Accuracy)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Dropdown/selector widget configuration
- Data model updates

**Technical Requirements:**

- Add "Journeyman Lineman" classification
- Remove "Apprentice Electrician"
- Remove "Master Electrician"
- Remove "Solar Systems Technician"
- Remove "Instrumentation Technician"
- Update data model/enum if needed

**Acceptance Criteria:**

- [ ] Only relevant classifications available
- [ ] Existing user preferences migrated if needed
- [ ] UI displays correctly

**Dependencies:** None

**Estimated Effort:** 30 minutes

---

### Task 10.4: Update Construction Type Options

**Description:** Update the construction type options in the job preferences dialog to remove non-electrical categories.

**Domain:** Data Model & UI

**Difficulty:** P Trivial

**Importance:** =� Medium (Data Accuracy)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Dropdown/selector widget configuration

**Technical Requirements:**

- Remove "Renewable Energy"
- Remove "Education"
- Remove "Healthcare"
- Remove "Transportation"
- Remove "Manufacturing"
- Update data model if needed

**Acceptance Criteria:**

- [ ] Only electrical construction types available
- [ ] Existing preferences handled gracefully
- [ ] UI displays correctly

**Dependencies:** None

**Estimated Effort:** 30 minutes

---

### Task 10.5: Remove Hourly Wage and Travel Distance Fields

**Description:** Remove minimum hourly wage and maximum travel distance fields from the job preferences dialog.

**Domain:** UI & Data Model

**Difficulty:** P Trivial

**Importance:** =� Medium (UX Simplification)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Widget removal
- Form validation updates

**Technical Requirements:**

- Remove hourly wage input field
- Remove travel distance input field
- Update form validation logic
- Update data model if fields are persisted
- Clean up related UI components

**Acceptance Criteria:**

- [ ] Fields removed from dialog
- [ ] Form validates correctly without fields
- [ ] Data model updated if needed
- [ ] No layout issues

**Dependencies:** None

**Estimated Effort:** 1 hour

---

### Task 10.6: Apply Electrical Theme to Preferences Toast/Snackbar

**Description:** Apply the electrical circuit toast/snackbar theme to the save preferences notification.

**Domain:** UI Theming

**Difficulty:** P Trivial

**Importance:** =� Medium (Theme Consistency)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Custom snackbar/toast design
- AppTheme integration

**Technical Requirements:**

- Use electrical-themed toast component
- Apply AppTheme colors (Navy/Copper)
- Add electrical design elements
- Ensure readability and accessibility

**Acceptance Criteria:**

- [ ] Electrical theme applied to notifications
- [ ] Consistent with app design system
- [ ] Toast/snackbar displays correctly
- [ ] Accessible and readable

**Dependencies:** None

**Estimated Effort:** 1 hour

---

### Task 10.7: Implement User Preferences Firestore Persistence

**Description:** Implement proper Firestore document update for user preferences when the save preferences button is pressed. Currently, preferences are not being saved to Firebase.

**Domain:** Data Persistence

**Difficulty:** PPP Moderate

**Importance:** =4 Critical (Core Feature Broken)

**Recommended Agent:** database-optimizer + auth-expert

**Skills/Tools Required:**

- Firestore document updates
- User document schema design
- Error handling
- Data validation

**Technical Requirements:**

- Design/update user document schema for preferences
- Implement Firestore update operation
- Add data validation before saving
- Handle Firestore errors gracefully
- Add logging for debugging
- Verify data persists correctly

**Firestore Schema Example:**

```json
{
  "userId": "string",
  "preferences": {
    "classifications": ["string"],
    "constructionTypes": ["string"],
    "preferredLocals": [int],
    "hoursPerWeek": "string",
    "perDiem": "string"
  },
  "updatedAt": "timestamp"
}
```

**Acceptance Criteria:**

- [ ] Preferences save to Firestore successfully
- [ ] User document schema implemented
- [ ] Data validation working
- [ ] Error handling implemented
- [ ] Success notification displays
- [ ] Preferences persist across sessions
- [ ] Firebase Console shows updated data

**Dependencies:** User must be authenticated

**Estimated Effort:** 4-5 hours

---

## = RESOURCES SCREEN - LINKS TAB

### Task 11.1: Add Union Pay Scales External Link

**Description:** Add a container for "Union Pay Scales" that opens the external link to unionpayscales.com in the device browser.

**Domain:** UI & Navigation

**Difficulty:** P Trivial

**Importance:** =� Medium (Feature Addition)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter url_launcher package
- External link handling

**Technical Requirements:**

- Create container widget for the link
- Add link icon
- Implement url_launcher to open <https://unionpayscales.com/trades/ibew-linemen/>
- Handle URL launch errors
- Test on iOS and Android

**Acceptance Criteria:**

- [ ] Container displays correctly
- [ ] Link icon visible
- [ ] Tapping opens browser with correct URL
- [ ] Error handling for failed launches
- [ ] Works on both platforms

**Dependencies:** url_launcher package

**Estimated Effort:** 1 hour

---

### Task 11.2: Add Union Pay Scales In-App Display

**Description:** Add another container for "Union Pay Scales" that displays the pay_scale_card widget in-app instead of navigating to the browser.

**Domain:** UI & Widget Integration

**Difficulty:** PP Simple

**Importance:** =� Medium (Feature Addition)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- Flutter navigation
- Custom widget integration
- Screen transitions

**Technical Requirements:**

- Create container widget
- Implement navigation to pay scale card screen
- Integrate `@lib/widgets/pay_scale_card.dart`
- Add proper back navigation
- Test widget rendering

**Acceptance Criteria:**

- [ ] Container displays correctly
- [ ] Tapping navigates to pay scale card
- [ ] pay_scale_card.dart renders correctly
- [ ] Back navigation works
- [ ] No performance issues

**Dependencies:** `lib/widgets/pay_scale_card.dart` must exist

**Estimated Effort:** 2 hours

---

### Task 11.3: Connect NFPA Link

**Description:** Connect the NFPA resource link to the official NFPA codes and standards page.

**Domain:** UI & Navigation

**Difficulty:** P Trivial

**Importance:** =� Medium (Feature Completion)

**Recommended Agent:** flutter-expert

**Skills/Tools Required:**

- url_launcher package

**Technical Requirements:**

- Implement url_launcher for NFPA link
- Open <https://www.nfpa.org/en/for-professionals/codes-and-standards/list-of-codes-and-standards>
- Handle URL launch errors
- Test on both platforms

**Acceptance Criteria:**

- [ ] NFPA link opens correct URL
- [ ] Works on iOS and Android
- [ ] Error handling implemented

**Dependencies:** url_launcher package

**Estimated Effort:** 30 minutes

---

## =� SUMMARY STATISTICS

**Total Tasks:** 23

**By Difficulty:**

- P Trivial: 8 tasks
- PP Simple: 4 tasks
- PPP Moderate: 8 tasks
- PPPP Complex: 3 tasks

**By Importance:**

- =4 Critical: 6 tasks
- =� High: 5 tasks
- =� Medium: 12 tasks

**By Agent:**

- flutter-expert: 15 tasks
- database-optimizer: 6 tasks (3 primary, 3 collaborative)
- auth-expert: 3 tasks (1 primary, 2 collaborative)
- backend-architect: 0 tasks (none directly applicable)

**Total Estimated Effort:** 72-99 hours

**Critical Path Tasks (Must Complete First):**

1. Task 4.2: Fix Firestore index for suggested jobs
2. Task 10.7: Implement preferences Firestore persistence
3. Task 1.1: Implement session grace period
4. Task 6.1: Fix contractor cards display
5. Task 8.1: Fix crew preferences save error

---

## <� RECOMMENDED EXECUTION ORDER

### Phase 1: Critical Fixes (Week 1)

- Task 4.2: Fix Firestore index (blocking suggested jobs)
- Task 10.7: Implement preferences persistence (core feature)
- Task 6.1: Fix contractor cards (critical feature broken)
- Task 8.1: Fix crew preferences save (critical feature broken)

### Phase 2: High Priority Features (Week 2)

- Task 4.1: Fix home screen user name display
- Task 4.3: Implement suggested jobs methods
- Task 7.1: Fix tailboard overflow error
- Task 5.1: Apply title case to job details

### Phase 3: User Experience Improvements (Week 3)

- Task 1.1: Implement session grace period
- Task 8.2: Implement feed message display
- Task 8.3: Implement chat message display
- Task 2.1: Implement dark mode theme

### Phase 4: UI Polish & Enhancements (Week 4)

- Task 3.1: Remove dark mode from onboarding
- Task 10.1-10.6: Settings screen improvements
- Task 11.1-11.3: Resources screen links
- Task 9.1: Optimize locals screen performance

---

**Notes:**

- All Firebase-related tasks require Firebase Console access
- Tasks involving Firestore indexes may have propagation delays (up to 15 minutes)
- Collaborative tasks benefit from parallel agent execution
- Testing should be performed on both iOS and Android platforms
- User authentication state must be maintained for all user-specific features
