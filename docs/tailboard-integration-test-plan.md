# Tailboard Tab Widgets - Integration Test Plan

## Document Overview
**File Analyzed**: `lib/features/crews/widgets/tab_widgets.dart`
**Date**: 2025-11-19
**Purpose**: Comprehensive integration testing strategy for Tailboard tab widgets
**Components**: 4 tabs (Feed, Jobs, Chat, Members) with 16 dialog integrations

---

## Executive Summary

The Tailboard application contains 4 primary tab widgets that manage crew interactions, job listings, messaging, and member management. These tabs integrate with 16 distinct dialog widgets, multiple Riverpod providers, and the MessageService. Currently, **no end-to-end integration tests exist** for these complex user flows.

### Critical Integration Points
- **16 Dialog Widgets** requiring coordination testing
- **13+ Riverpod Providers** managing state across tabs
- **MessageService** for real-time chat functionality
- **Cross-tab state synchronization**
- **Empty/Error state handling**
- **Pull-to-refresh flows**

---

## Tab Components Analysis

### 1. FeedTab - Universal Public Feed

#### Functionality
- Displays global/public crew posts for all users
- Supports filtering (my posts only, sort by recent/oldest/popular)
- Handles post interactions (like, comment, share, reactions)
- Real-time updates via Riverpod streams
- Pull-to-refresh functionality

#### Provider Dependencies
```dart
- currentUserProvider (authentication state)
- feedFilterProvider (filter settings)
- crewPostsStreamProvider('global') (post data stream)
- postCommentsProvider(postId) (comment data per post)
```

#### Dialog Integrations
- **FeedSortOptionsDialog** - Sort options selection
- **FeedHistoryDialog** - Historical feed view
- Post edit/delete dialogs (referenced in PostCard callbacks)

#### Test Scenarios

##### TS-F1: Anonymous User Access
```
GIVEN: User is not authenticated (currentUser == null)
WHEN: FeedTab is loaded
THEN: Display EmptyStateWidget with "Sign In Required" message
AND: No posts should be visible
AND: Login icon should be shown
```

##### TS-F2: Empty Feed State
```
GIVEN: User is authenticated
AND: No posts exist in global feed
WHEN: FeedTab is loaded
THEN: Display EmptyStateWidget with "Feed is Empty"
AND: Message should encourage first post
```

##### TS-F3: Filter - My Posts Only
```
GIVEN: User is authenticated
AND: Multiple posts exist (some from user, some from others)
WHEN: User enables "showMyPostsOnly" filter
THEN: Only posts where authorId == currentUser.uid should display
AND: Other posts should be hidden
```

##### TS-F4: Sort - Popular Posts
```
GIVEN: Feed contains posts with varying reaction counts
WHEN: User selects "popular" sort option
THEN: Posts should be ordered by reaction count (descending)
AND: Post with most reactions appears first
```

##### TS-F5: Post Interactions
```
GIVEN: User views a post
WHEN: User clicks like/comment/share/reaction
THEN: Appropriate SnackBar should display
AND: Callback functions should be invoked correctly
AND: UI should update immediately (optimistic update)
```

##### TS-F6: Pull-to-Refresh
```
GIVEN: User is viewing feed
WHEN: User pulls down to refresh
THEN: crewPostsStreamProvider('global') should be invalidated
AND: Loading indicator should display
AND: Feed should reload with latest data
```

##### TS-F7: Error State Handling
```
GIVEN: Firebase/backend connection fails
WHEN: crewPostsStreamProvider returns error
THEN: Display EmptyStateWidget with error message
AND: Error details should be shown
```

##### TS-F8: Comments Loading
```
GIVEN: Post exists with comments
WHEN: PostCard renders
THEN: postCommentsProvider should fetch comments
AND: Loading state should display during fetch
AND: Comments should render when loaded
AND: Error should gracefully handle comment fetch failure
```

---

### 2. JobsTab - Filtered Job Listings

#### Functionality
- Displays job listings with search and filtering
- Shows job preferences banner for selected crew
- Supports job details dialog and application flow
- Search functionality with clear button
- Pull-to-refresh support

#### Provider Dependencies
```dart
- selectedCrewProvider (current crew context)
- jobsProvider (job listings state)
- currentUserProvider (authentication)
```

#### Dialog Integrations
- **JobPreferencesDialog** - Crew job preference management
- **JobDetailsDialog** - Detailed job information
- **ApplyJobDialog** - Job application submission
- **ClassificationFilterDialog** - Job classification filters
- **ConstructionTypeFilterDialog** - Construction type filters
- **LocalFilterDialog** - Local union filters

#### Test Scenarios

##### TS-J1: No Crew Selected
```
GIVEN: selectedCrewProvider returns null
WHEN: JobsTab is loaded
THEN: Preferences banner should NOT display
AND: Job listings should still be available
```

##### TS-J2: Crew with Preferences
```
GIVEN: selectedCrew has jobTypes preferences set
WHEN: JobsTab is loaded
THEN: Preferences banner should display
AND: Banner should show crew name
AND: Banner should show selected job types (comma-separated)
AND: Preferences count should be accurate
```

##### TS-J3: Job Preferences Dialog
```
GIVEN: User clicks preferences button in banner
WHEN: Dialog opens
THEN: JobPreferencesDialog should display
AND: Dialog should show current preferences
AND: User can modify job types (FilterChips)
AND: User can set min hourly rate
AND: User can set max distance
AND: User can select required skills
AND: User can toggle auto-share
AND: User can adjust match threshold (0-100%)
```

##### TS-J4: Save Preferences Flow
```
GIVEN: User modifies preferences in dialog
WHEN: User clicks "Save"
THEN: crewService.updateCrewPreferences should be called
AND: Dialog should close on success
AND: Success SnackBar should display
AND: Error SnackBar should display on failure
AND: Preferences banner should update with new values
```

##### TS-J5: Search Functionality
```
GIVEN: Multiple jobs are listed
WHEN: User types in search field
THEN: _searchQuery state should update
AND: Clear button (X) should appear
WHEN: User clicks clear button
THEN: Search field should empty
AND: _searchQuery should reset to ''
AND: Clear button should disappear
```

##### TS-J6: Empty Jobs State
```
GIVEN: jobsProvider returns empty jobs list
WHEN: JobsTab renders
THEN: EmptyStateWidget should display
AND: Message should suggest adjusting filters
```

##### TS-J7: Job Details Dialog
```
GIVEN: User clicks "Details" on job card
WHEN: Dialog opens
THEN: JobDetailsDialog should display
AND: All job fields should render (location, wage, hours, etc.)
AND: Clickable fields should have underline (location, local)
AND: Location click should launch maps
AND: Local click should navigate to local details
```

##### TS-J8: Apply to Job Flow
```
GIVEN: User clicks "Apply" on job card
WHEN: ApplyJobDialog opens
THEN: Job title should display in header
AND: User can enter optional message
AND: Submit button should be enabled
WHEN: User clicks "Submit Application"
THEN: Loading state should display (_isSubmitting = true)
AND: 1-second simulated delay should occur
AND: Dialog should close on success
AND: Success SnackBar should display
```

##### TS-J9: Job Card Display
```
GIVEN: Job data includes all fields
WHEN: Job card renders
THEN: Job title should display (or company as fallback)
AND: Classification badge should show
AND: Company, location, local, wage, hours should display
AND: Details and Apply buttons should be present
AND: Card should animate on render (fadeIn)
```

##### TS-J10: Pull-to-Refresh
```
GIVEN: User is viewing job listings
WHEN: User pulls down to refresh
THEN: jobsProvider should be invalidated
AND: Loading indicator should display
AND: Jobs should reload
```

---

### 3. ChatTab - Group Chat

#### Functionality
- Real-time crew messaging via MessageService
- Auto-scrolls to bottom on new messages
- Displays messages in reverse chronological order
- Handles empty chat state
- Message sending with error handling

#### Service Dependencies
```dart
- MessageService (getCrewMessagesStream, sendCrewMessage)
```

#### Provider Dependencies
```dart
- selectedCrewProvider (current crew context)
- currentUserProvider (authentication)
```

#### Dialog Integrations
- **ChatHistoryDialog** - Historical chat messages
- **DirectMessagesDialog** - Private messaging
- **ChannelsListDialog** - Channel selection

#### Test Scenarios

##### TS-C1: No Crew Selected
```
GIVEN: selectedCrewProvider returns null
OR: currentUserProvider returns null
WHEN: ChatTab is loaded
THEN: EmptyStateWidget should display
AND: Message should say "No Crew Selected"
AND: Instruction to select crew should appear
```

##### TS-C2: Message Stream Loading
```
GIVEN: User has selected crew
WHEN: MessageService.getCrewMessagesStream is loading
THEN: ElectricalLoadingIndicator should display
AND: Message should say "Loading messages..."
```

##### TS-C3: Message Stream Error
```
GIVEN: MessageService.getCrewMessagesStream throws error
WHEN: Error occurs
THEN: EmptyStateWidget should display with error
AND: Error message should be shown to user
```

##### TS-C4: Empty Chat State
```
GIVEN: Messages stream returns empty list
WHEN: ChatTab renders
THEN: EmptyStateWidget should display "No Messages Yet"
AND: ChatInput should still be available at bottom
AND: User can send first message
```

##### TS-C5: Message Display
```
GIVEN: Messages exist for crew
WHEN: ChatTab renders
THEN: Messages should display in reverse order (newest at bottom)
AND: Each message should show content, sender, timestamp
AND: Current user messages should have isCurrentUser = true
AND: Other user messages should have isCurrentUser = false
```

##### TS-C6: Auto-Scroll Behavior
```
GIVEN: Messages are loading or new message arrives
WHEN: Messages render
THEN: _scrollToBottom should be called
AND: Scroll should animate to bottom
AND: 100ms delay should prevent race conditions
AND: ScrollController.hasClients should be checked
```

##### TS-C7: Send Message Flow
```
GIVEN: User types message in ChatInput
WHEN: User submits message
THEN: _sendMessage should be called
AND: MessageService.sendCrewMessage should be invoked
AND: Parameters should include crewId, senderId, content
AND: Auto-scroll should trigger after send
```

##### TS-C8: Send Message Error
```
GIVEN: MessageService.sendCrewMessage fails
WHEN: Error occurs during send
THEN: Error SnackBar should display
AND: Error message should include exception details
AND: SnackBar background should be TailboardTheme.error
```

##### TS-C9: Sender Name Display
```
GIVEN: Messages exist with sender IDs
WHEN: MessageBubble renders
THEN: _getSenderName should be called
AND: Sender name should display (currently shows senderId as placeholder)
NOTE: Future enhancement needed to fetch from user profiles
```

---

### 4. MembersTab - Crew Member List

#### Functionality
- Displays crew members with status indicators
- Shows member availability and role badges
- Pull-to-refresh support
- Message member action (coming soon)
- Member card animations

#### Provider Dependencies
```dart
- selectedCrewProvider (current crew context)
- crewMembersStreamProvider(crewId) (member data stream)
- crewMembersProvider(crewId) (for refresh invalidation)
```

#### Dialog Integrations
- **MemberAvailabilityDialog** - Set member availability
- **MemberRolesDialog** - Manage member roles
- **MemberRosterDialog** - Full member roster view

#### Test Scenarios

##### TS-M1: No Crew Selected
```
GIVEN: selectedCrewProvider returns null
WHEN: MembersTab is loaded
THEN: EmptyStateWidget should display
AND: Message should say "No Crew Selected"
AND: Instruction to select crew should appear
```

##### TS-M2: Members Loading
```
GIVEN: crewMembersStreamProvider is fetching data
WHEN: MembersTab renders
THEN: ElectricalLoadingIndicator should display
AND: Message should say "Loading members..."
```

##### TS-M3: Members Load Error
```
GIVEN: crewMembersStreamProvider throws error
WHEN: Error occurs
THEN: EmptyStateWidget should display with error details
AND: Error message should be visible
```

##### TS-M4: Empty Members List
```
GIVEN: crewMembersStreamProvider returns empty list
WHEN: MembersTab renders
THEN: EmptyStateWidget should display "No Members Yet"
AND: Message should say "Invite people to join your crew"
```

##### TS-M5: Member Card Display
```
GIVEN: Members exist for crew
WHEN: Member card renders
THEN: CircleAvatar should show first letter of userId
AND: Active status indicator should show (green if active, gray if inactive)
AND: User ID substring (first 8 chars) should display
AND: Joined date should display in yMMMd format
AND: Role badge should display if role != member
AND: Availability badge should show (Available/Away)
AND: Message button should be present
```

##### TS-M6: Role Badge Display
```
GIVEN: Member has role other than MemberRole.member
WHEN: Member card renders
THEN: Role badge should display
AND: Badge should show role name in uppercase
AND: Badge should have success color theme
```

##### TS-M7: Availability States
```
GIVEN: Member has isAvailable = true
WHEN: Member card renders
THEN: Availability badge should show "Available"
AND: Badge should have success/green theme
GIVEN: Member has isAvailable = false
THEN: Availability badge should show "Away"
AND: Badge should have gray theme
```

##### TS-M8: Message Member Action
```
GIVEN: User clicks message button on member card
WHEN: Button is pressed
THEN: SnackBar should display
AND: Message should say "Start chat with User [userId] (Coming Soon)"
AND: SnackBar should have info background color
```

##### TS-M9: Pull-to-Refresh
```
GIVEN: User is viewing members list
WHEN: User pulls down to refresh
THEN: crewMembersProvider should be invalidated
AND: Members list should reload
AND: Loading indicator should display
```

##### TS-M10: Member Card Animation
```
GIVEN: Members are loaded
WHEN: Member cards render
THEN: Each card should animate (fadeIn + slideX)
AND: Animation duration should be 300ms
AND: Slide should be from right (begin: 0.1, end: 0)
```

---

## Dialog Integration Matrix

### Complete Dialog Inventory (16 Dialogs)

| Dialog Name | File Location | Used By Tab | Purpose |
|------------|---------------|-------------|---------|
| **FeedSortOptionsDialog** | tailboard/feed_sort_options_dialog.dart | FeedTab | Sort feed posts (recent/oldest/popular) |
| **FeedHistoryDialog** | tailboard/feed_history_dialog.dart | FeedTab | View historical feed entries |
| **JobPreferencesDialog** | tailboard/job_preferences_dialog.dart | JobsTab | Configure crew job preferences |
| **JobDetailsDialog** | widgets/dialogs/job_details_dialog.dart | JobsTab | Display detailed job information |
| **ApplyJobDialog** | tailboard/apply_job_dialog.dart | JobsTab | Submit job application |
| **ClassificationFilterDialog** | tailboard/classification_filter_dialog.dart | JobsTab | Filter jobs by classification |
| **ConstructionTypeFilterDialog** | tailboard/construction_type_filter_dialog.dart | JobsTab | Filter jobs by construction type |
| **LocalFilterDialog** | tailboard/local_filter_dialog.dart | JobsTab | Filter jobs by local union |
| **ChatHistoryDialog** | tailboard/chat_history_dialog.dart | ChatTab | View historical chat messages |
| **DirectMessagesDialog** | tailboard/direct_messages_dialog.dart | ChatTab | Private messaging interface |
| **ChannelsListDialog** | tailboard/channels_list_dialog.dart | ChatTab | Select chat channels |
| **MemberAvailabilityDialog** | tailboard/member_availability_dialog.dart | MembersTab | Set member availability status |
| **MemberRolesDialog** | tailboard/member_roles_dialog.dart | MembersTab | Manage member roles |
| **MemberRosterDialog** | tailboard/member_roster_dialog.dart | MembersTab | View full member roster |
| **CrewPreferencesDialog** | crew_preferences_dialog.dart | Multiple | Crew-level preferences (general) |
| **Post Edit/Delete Dialogs** | PostCard callbacks | FeedTab | Edit/delete post actions |

### Dialog Testing Priority

#### P0 - Critical Path (Must Test)
1. **JobPreferencesDialog** - Complex form with multiple input types
2. **ApplyJobDialog** - Job application submission flow
3. **JobDetailsDialog** - Navigation and external app integration

#### P1 - High Priority
4. **ChatHistoryDialog** - Historical data access
5. **MemberAvailabilityDialog** - Status management
6. **FeedSortOptionsDialog** - Feed filtering logic

#### P2 - Medium Priority
7. **ClassificationFilterDialog** - Job filtering
8. **ConstructionTypeFilterDialog** - Job filtering
9. **LocalFilterDialog** - Job filtering
10. **MemberRolesDialog** - Role management

#### P3 - Lower Priority
11. **FeedHistoryDialog** - Historical feed view
12. **DirectMessagesDialog** - Private messaging
13. **ChannelsListDialog** - Channel selection
14. **MemberRosterDialog** - Roster view
15. **CrewPreferencesDialog** - General preferences
16. **Post Edit/Delete Dialogs** - CRUD operations

---

## Provider Integration Testing

### Critical Provider Chains

#### Feed Flow
```
currentUserProvider
  → feedFilterProvider
    → crewPostsStreamProvider('global')
      → postCommentsProvider(postId)
```

#### Jobs Flow
```
selectedCrewProvider
  → jobsProvider
    → (filters applied)
```

#### Chat Flow
```
selectedCrewProvider + currentUserProvider
  → MessageService.getCrewMessagesStream(crewId, userId)
    → Real-time message updates
```

#### Members Flow
```
selectedCrewProvider
  → crewMembersStreamProvider(crewId)
    → Member list updates
```

### Provider Test Scenarios

##### PT-1: Provider Invalidation
```
GIVEN: Data is cached in provider
WHEN: User performs pull-to-refresh
THEN: Appropriate provider should be invalidated
AND: Fresh data should be fetched
AND: UI should update with new data
```

##### PT-2: Provider Error Propagation
```
GIVEN: Backend service fails
WHEN: Provider attempts to fetch data
THEN: Error should propagate to widget
AND: Error widget should display
AND: Error details should be accessible
```

##### PT-3: Cross-Provider Synchronization
```
GIVEN: selectedCrewProvider changes
WHEN: New crew is selected
THEN: All dependent providers should update
AND: JobsTab should show new crew's jobs
AND: ChatTab should show new crew's messages
AND: MembersTab should show new crew's members
```

---

## Manual Testing Checklist

### Pre-Test Setup
- [ ] Firebase/backend services are running
- [ ] Test user accounts are created
- [ ] Test crews are populated with data
- [ ] Test jobs are available in database
- [ ] Test messages exist in crew chats
- [ ] Test crew members are assigned

### FeedTab Manual Tests
- [ ] Anonymous user sees "Sign In Required" state
- [ ] Authenticated user sees global feed
- [ ] Empty feed shows appropriate message
- [ ] "My Posts Only" filter works correctly
- [ ] Sort by recent/oldest/popular functions
- [ ] Post like shows SnackBar
- [ ] Post comment interaction works
- [ ] Post share shows SnackBar
- [ ] Post reaction adds emoji and shows SnackBar
- [ ] Pull-to-refresh reloads feed
- [ ] Error state displays on backend failure
- [ ] Comments load for each post
- [ ] PostCard animations render smoothly

### JobsTab Manual Tests
- [ ] Jobs list displays when no crew selected
- [ ] Preferences banner appears with selected crew
- [ ] Banner shows correct crew name and job types
- [ ] Clicking preferences count opens dialog
- [ ] JobPreferencesDialog displays current settings
- [ ] Job types can be selected/deselected
- [ ] Hourly rate input accepts numeric values
- [ ] Distance input accepts numeric values
- [ ] Skills can be selected/deselected
- [ ] Auto-share toggle works
- [ ] Match threshold slider updates value
- [ ] Save button persists changes
- [ ] Cancel button closes dialog without saving
- [ ] Search field filters jobs (if implemented)
- [ ] Clear button resets search
- [ ] Job card displays all details
- [ ] Details button opens JobDetailsDialog
- [ ] JobDetailsDialog shows all fields
- [ ] Location click launches maps app
- [ ] Local click navigates to local details
- [ ] Apply button opens ApplyJobDialog
- [ ] ApplyJobDialog shows job title
- [ ] Application message input works
- [ ] Submit shows loading state
- [ ] Success SnackBar appears after submit
- [ ] Pull-to-refresh reloads jobs

### ChatTab Manual Tests
- [ ] "No Crew Selected" shows when crew is null
- [ ] "No Crew Selected" shows when user is null
- [ ] Loading indicator displays during fetch
- [ ] Error state shows when stream fails
- [ ] Empty chat shows "No Messages Yet"
- [ ] ChatInput displays in empty state
- [ ] Messages display in reverse order
- [ ] Current user messages have correct styling
- [ ] Other user messages have correct styling
- [ ] Auto-scroll happens on load
- [ ] Auto-scroll happens on new message
- [ ] Sending message calls service
- [ ] Message appears after send
- [ ] Send error shows SnackBar
- [ ] Sender names display correctly

### MembersTab Manual Tests
- [ ] "No Crew Selected" shows when crew is null
- [ ] Loading indicator displays during fetch
- [ ] Error state shows when stream fails
- [ ] Empty members shows "No Members Yet"
- [ ] Member avatar shows first letter
- [ ] Active status indicator is green when active
- [ ] Active status indicator is gray when inactive
- [ ] User ID displays (first 8 characters)
- [ ] Joined date displays correctly
- [ ] Role badge appears for non-member roles
- [ ] Role name displays in uppercase
- [ ] Available badge shows "Available" in green
- [ ] Away badge shows "Away" in gray
- [ ] Message button displays
- [ ] Message button shows "Coming Soon" SnackBar
- [ ] Pull-to-refresh reloads members
- [ ] Member cards animate on render

---

## Automated Test Recommendations

### Unit Tests (Widget Tests)

```dart
// Example: FeedTab Empty State
testWidgets('FeedTab shows empty state when no posts exist', (tester) async {
  // Arrange
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((_) => mockUser),
        crewPostsStreamProvider('global').overrideWith(
          (_) => Stream.value([]), // Empty posts
        ),
      ],
      child: MaterialApp(home: FeedTab()),
    ),
  );

  // Act
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(EmptyStateWidget), findsOneWidget);
  expect(find.text('Feed is Empty'), findsOneWidget);
});
```

### Integration Tests

```dart
// Example: Job Application Flow
testWidgets('User can apply to job through full flow', (tester) async {
  // 1. Navigate to JobsTab
  // 2. Tap on "Apply" button
  // 3. Verify ApplyJobDialog opens
  // 4. Enter application message
  // 5. Tap "Submit Application"
  // 6. Verify loading state
  // 7. Verify success SnackBar
  // 8. Verify dialog closes
});
```

### Provider Tests

```dart
// Example: Provider invalidation
test('Pull-to-refresh invalidates jobsProvider', () async {
  final container = ProviderContainer();

  // Initial load
  final initialJobs = await container.read(jobsProvider.future);

  // Invalidate
  container.invalidate(jobsProvider);

  // Verify refetch
  final refreshedJobs = await container.read(jobsProvider.future);

  expect(refreshedJobs, isNot(same(initialJobs)));
});
```

### Service Tests

```dart
// Example: MessageService
test('MessageService sends crew message', () async {
  final service = MessageService();

  await service.sendCrewMessage(
    crewId: 'crew123',
    senderId: 'user456',
    content: 'Test message',
  );

  // Verify message was sent to backend
  verify(mockFirestore.collection('messages').add(any)).called(1);
});
```

---

## Error State Testing

### Error Scenarios to Test

#### ES-1: Network Timeout
```
GIVEN: Network request exceeds timeout
WHEN: Provider attempts to fetch data
THEN: Timeout error should be caught
AND: Error state should display
AND: Retry mechanism should be available
```

#### ES-2: Authentication Expired
```
GIVEN: User token expires during session
WHEN: Provider makes authenticated request
THEN: 401/403 error should be handled
AND: User should be prompted to re-authenticate
AND: Current state should be preserved
```

#### ES-3: Malformed Data
```
GIVEN: Backend returns unexpected data structure
WHEN: Provider attempts to parse response
THEN: Parsing error should be caught
AND: Error state should display
AND: Error should be logged for debugging
```

#### ES-4: Concurrent Modifications
```
GIVEN: Multiple users modify same data
WHEN: Conflict occurs
THEN: Conflict resolution strategy should apply
AND: User should be notified
AND: Data consistency should be maintained
```

---

## Empty State Testing

### Empty State Scenarios

#### EMP-1: Fresh User Experience
```
GIVEN: New user joins crew
WHEN: User views MembersTab
THEN: Only the new user should appear
WHEN: User views ChatTab
THEN: "No Messages Yet" should display
WHEN: User views FeedTab
THEN: "Feed is Empty" should display
```

#### EMP-2: Filtered to Empty
```
GIVEN: Jobs exist but don't match filters
WHEN: User applies strict filters
THEN: "No Jobs Found" should display
AND: Message should suggest adjusting filters
```

#### EMP-3: Temporary Empty State
```
GIVEN: Data is loading
WHEN: Provider fetches data
THEN: Loading indicator should display
WHEN: Data arrives (empty list)
THEN: Empty state should replace loading state
```

---

## Performance Testing

### Performance Metrics to Track

#### PM-1: Initial Load Time
- **Target**: < 2 seconds for tab to render with data
- **Measure**: Time from navigation to first paint with data

#### PM-2: Message Send Latency
- **Target**: < 500ms from tap to SnackBar
- **Measure**: Time from submit tap to success notification

#### PM-3: Refresh Latency
- **Target**: < 3 seconds for pull-to-refresh completion
- **Measure**: Time from pull gesture to updated data display

#### PM-4: Dialog Open Animation
- **Target**: 60 FPS during dialog animation
- **Measure**: Frame rate during dialog open/close

#### PM-5: List Scroll Performance
- **Target**: 60 FPS during scroll with 100+ items
- **Measure**: Frame rate during rapid scrolling

---

## Security Testing

### Security Considerations

#### SEC-1: Authorization Checks
```
GIVEN: User attempts to access crew data
WHEN: Request is made to backend
THEN: User's crew membership should be verified
AND: Unauthorized access should be blocked
```

#### SEC-2: Input Validation
```
GIVEN: User enters data in JobPreferencesDialog
WHEN: Data is submitted
THEN: Input should be sanitized
AND: SQL injection attempts should be prevented
AND: XSS attacks should be blocked
```

#### SEC-3: Message Content Filtering
```
GIVEN: User sends message in ChatTab
WHEN: Message content is processed
THEN: Malicious content should be filtered
AND: Links should be validated
AND: File uploads should be scanned
```

---

## Accessibility Testing

### Accessibility Requirements

#### ACC-1: Screen Reader Support
- [ ] All interactive elements have semantic labels
- [ ] Form fields have proper descriptions
- [ ] Error messages are announced
- [ ] Loading states are announced

#### ACC-2: Keyboard Navigation
- [ ] All dialogs are keyboard accessible
- [ ] Tab order is logical
- [ ] Enter/Escape keys work as expected

#### ACC-3: Visual Accessibility
- [ ] Color contrast meets WCAG AA standards
- [ ] Text is resizable without breaking layout
- [ ] Icons have text alternatives

---

## Regression Testing

### Regression Test Suite

#### REG-1: Post-Deployment Smoke Tests
1. Launch app and authenticate
2. Navigate to each tab (Feed, Jobs, Chat, Members)
3. Verify no crashes or blank screens
4. Open one dialog from each tab
5. Perform one critical action per tab

#### REG-2: Critical Path Tests
1. **Feed**: Like a post and verify SnackBar
2. **Jobs**: Open JobDetailsDialog and verify data
3. **Chat**: Send a message and verify delivery
4. **Members**: View member list and verify data

---

## Test Data Requirements

### Required Test Data

#### Users
- **User A**: Authenticated, member of Crew 1
- **User B**: Authenticated, member of Crew 1 and Crew 2
- **User C**: Authenticated, no crew membership
- **User D**: Not authenticated (anonymous)

#### Crews
- **Crew 1**: 5 members, 10 posts, active chat
- **Crew 2**: 1 member, 0 posts, empty chat
- **Crew 3**: 0 members (invalid state for testing)

#### Jobs
- **Job 1**: Full details (wage, hours, location, etc.)
- **Job 2**: Minimal details (company and classification only)
- **Job 3**: High wage ($100/hr) for sorting tests
- **Job 4**: Popular job (many reactions)

#### Messages
- **Crew 1 Chat**: 50+ messages from multiple users
- **Crew 2 Chat**: 0 messages

#### Members
- **Crew 1**: Mix of roles (admin, moderator, member)
- **Crew 1**: Mix of availability (available/away)
- **Crew 1**: Mix of active status (active/inactive)

---

## Continuous Integration

### CI/CD Test Strategy

#### Build Pipeline
1. **Unit Tests**: Run all widget tests
2. **Integration Tests**: Run critical path tests
3. **Performance Tests**: Measure load times
4. **Code Coverage**: Ensure > 80% coverage
5. **Accessibility Scan**: Run automated accessibility checks

#### Automated Checks
- [ ] All tests pass before merge
- [ ] No new accessibility violations
- [ ] Performance metrics within acceptable range
- [ ] Code coverage doesn't decrease

---

## Known Issues and Limitations

### Current Implementation Gaps

1. **Search Functionality**: Search field exists but filtering logic not implemented in JobsTab
2. **Sender Name Resolution**: ChatTab displays sender IDs instead of names (needs user profile lookup)
3. **Message Member**: MembersTab message button shows "Coming Soon" placeholder
4. **Post Edit/Delete**: Callbacks exist but implementation is placeholder
5. **Comment Interactions**: onAddComment, onLikeComment, etc. have empty implementations

### Testing Blockers

1. **No existing widget tests**: Test directory `test/features/crews/widgets/` is empty
2. **Mock providers needed**: Need to create mock implementations of all Riverpod providers
3. **MessageService mocking**: Real-time stream testing requires mock MessageService
4. **Firebase dependencies**: Integration tests need Firebase emulator setup

---

## Test Execution Plan

### Phase 1: Unit Tests (Week 1-2)
- [ ] Create mock providers for all dependencies
- [ ] Write widget tests for each tab's empty states
- [ ] Write widget tests for each tab's error states
- [ ] Write widget tests for each tab's loaded states

### Phase 2: Dialog Tests (Week 3-4)
- [ ] Test P0 dialogs (JobPreferences, ApplyJob, JobDetails)
- [ ] Test P1 dialogs (ChatHistory, MemberAvailability, FeedSort)
- [ ] Test P2-P3 dialogs (remaining filters and management dialogs)

### Phase 3: Integration Tests (Week 5-6)
- [ ] Test cross-provider synchronization
- [ ] Test pull-to-refresh flows
- [ ] Test complete user journeys (apply to job, send message, etc.)

### Phase 4: Manual Testing (Week 7)
- [ ] Execute full manual testing checklist
- [ ] Document any bugs found
- [ ] Create regression test suite from manual tests

### Phase 5: Performance & Accessibility (Week 8)
- [ ] Run performance benchmarks
- [ ] Run accessibility audits
- [ ] Optimize based on findings

---

## Success Metrics

### Test Coverage Goals
- **Unit Test Coverage**: > 80% line coverage
- **Widget Test Coverage**: 100% of tabs and dialogs
- **Integration Test Coverage**: All critical paths tested
- **Manual Test Pass Rate**: > 95% on first run

### Quality Gates
- **Zero Critical Bugs**: No P0 bugs in production
- **Performance Targets Met**: All PM metrics within targets
- **Accessibility Compliance**: WCAG AA compliance
- **User Experience**: No user-reported navigation issues

---

## Appendix A: Provider Reference

### Complete Provider List

```dart
// Authentication
currentUserProvider

// Feed
feedFilterProvider
crewPostsStreamProvider(String crewId)
postCommentsProvider(String postId)

// Jobs
selectedCrewProvider
jobsProvider

// Chat
(MessageService - not a provider)

// Members
crewMembersStreamProvider(String crewId)
crewMembersProvider(String crewId)

// Core
crewServiceProvider
```

---

## Appendix B: Dialog Component Details

### JobPreferencesDialog Fields

**Input Types:**
- FilterChips: Job types (8 options)
- TextField: Min hourly rate (numeric)
- TextField: Max distance miles (numeric)
- FilterChips: Required skills (10 options)
- Switch: Auto-share enabled
- Slider: Match threshold (0-100%)

**Validation:**
- Hourly rate: Must be numeric, can be null
- Distance: Must be integer, can be null
- Other fields: No validation (can be empty)

**Save Flow:**
1. Collect all input values
2. Create CrewPreferences object
3. Call crewService.updateCrewPreferences
4. Handle success/error
5. Close dialog and show SnackBar

### ApplyJobDialog Flow

**States:**
- Initial: Button enabled, no loading
- Submitting: Button disabled, loading indicator
- Success: Dialog closed, SnackBar shown
- Error: (Not currently handled, assumes success)

**Future Enhancements:**
- Error handling for submission failures
- Form validation for message content
- File attachment support

---

## Document Metadata

**Author**: QA Testing Agent (Claude Code)
**Last Updated**: 2025-11-19
**Version**: 1.0
**Next Review**: After Phase 1 completion

**Related Documents:**
- `lib/features/crews/widgets/tab_widgets.dart` (source)
- `test/features/crews/widgets/` (test location - currently empty)
- Architecture documentation (if exists)

**Coordination Hooks:**
- Pre-task hook executed
- Findings stored in swarm memory
- Post-task hook pending completion
