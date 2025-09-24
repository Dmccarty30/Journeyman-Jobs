# Implementation Tasks: Crews Feature

**Estimated Tasks**: 35
**Ordering Strategy**: TDD (Tests before Implementation), Dependency Order (Models -> Services -> Providers -> UI), marked for Parallel execution [P].

## Phase 2: Task Planning (Execution of this phase is generating this file)

## Phase 3: Task Execution

---

### 1. Project Setup & Core Dependencies

1. [X]**Task**: Verify Flutter 3.x, Firebase CLI, Android Studio/Xcode installations.
    * **Description**: Ensure all development prerequisites are met as per `quickstart.md`.
    * **Dependencies**: None
    * **Est. Time**: 0.5h
    * **[P]**

2. [X]**Task**: Install `flutterfire_cli` and configure Firebase for the project.
    * **Description**: Run `dart pub global activate flutterfire_cli` and `flutterfire configure`.
    * **Dependencies**: #1
    * **Est. Time**: 1h

3. [X]**Task**: Install core Firebase and Riverpod Flutter dependencies.
    * **Description**: Add `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_messaging`, `riverpod`, `flutter_riverpod` via `flutter pub add` and run `flutter pub get`.
    * **Dependencies**: #2
    * **Est. Time**: 0.5h
    * **[P]**

4. [X]**Task**: Configure Firebase Firestore security rules for Crew and Member access.
    * **Description**: Implement security rules based on `research.md` to protect `/crews/{crewId}` and `/crews/{crewId}/members/{userId}`. Deploy using `firebase deploy --only firestore:rules`.
    * **Dependencies**: #2
    * **Est. Time**: 2h

### 2. Data Models (`lib/features/crews/models/`)

1. [X]***Task**: Create `Crew` and `CrewPreferences` data models.
    * **Description**: Implement `Crew` and `CrewPreferences` Dart classes as specified in `data-model.md`.
    * **Dependencies**: None
    * **Est. Time**: 1.5h
    * **[P]**

2. [X]***Task**: Create `CrewMember` and `MemberPermissions` data models.
    * **Description**: Implement `CrewMember` and `MemberPermissions` Dart classes as specified in `data-model.md`.
    * **Dependencies**: None
    * **Est. Time**: 1h
    * **[P]**

3. [X]***Task**: Create `Tailboard`, `SuggestedJob`, `ActivityItem`, `TailboardPost` data models.
    * **Description**: Implement `Tailboard` and its associated models as specified in `data-model.md`.
    * **Dependencies**: None
    * **Est. Time**: 2h
    * **[P]**

4. [X]***Task**: Create `Message`, `Attachment`, and `CrewStats` data models.
    * **Description**: Implement `Message`, `Attachment`, and `CrewStats` Dart classes as specified in `data-model.md`.
    * **Dependencies**: None
    * **Est. Time**: 1.5h
    * **[P]**

### 3. Firebase Services (`lib/features/crews/services/`)

9. [X]**Task**: Write unit tests for `CrewService` (create, get, update crew functions).

* **Description**: Create `test/features/crews/unit/crew_service_test.dart` to test `CrewService` methods, using mocks for Firebase interactions.
* **Dependencies**: #5, #6, #8
* **Est. Time**: 2.5h

10. [X]**Task**: Implement `CrewService` for basic crew management.

* **Description**: Implement methods to create, retrieve, update, and delete crews in Firestore, including handling `CrewPreferences` and `CrewStats`.
* **Dependencies**: #9 (Failing tests), #5
* **Est. Time**: 3h

11. [X]**Task**: Write unit tests for `CrewService` member management functions.

* **Description**: Create tests for `inviteMember`, `acceptInvitation`, `removeMember`, `updateMemberRole` methods.
* **Dependencies**: #6, #10
* **Est. Time**: 2.5h

12. [X]**Task**: Implement `CrewService` for member management.

* **Description**: Add methods for inviting members, handling invitations, removing members, and updating roles, ensuring Firestore updates.
* **Dependencies**: #11 (Failing tests), #6, #10
* **Est. Time**: 3h

13. [X]**Task**: Write unit tests for `TailboardService` (feed, post, activity functions).

* **Description**: Create `test/features/crews/unit/tailboard_service_test.dart` to test `getTailboardStream`, `postAnnouncement`, `addActivityItem`.
* **Dependencies**: #7
* **Est. Time**: 2.5h

14. [X]**Task**: Implement `TailboardService` for managing crew activity and posts.

* **Description**: Create a service to interact with `/crews/{crewId}/tailboard/activity` and `/crews/{crewId}/tailboard/posts` collections.
* **Dependencies**: #13 (Failing tests), #7, #10
* **Est. Time**: 3h

15. [X]**Task**: Write unit tests for `MessageService`.

* **Description**: Create `test/features/crews/unit/message_service_test.dart` to test `sendMessage`, `getCrewMessages`, `markAsRead` methods.
* **Dependencies**: #8
* **Est. Time**: 2.5h

16. [X]**Task**: Implement `MessageService` for crew and direct messaging.

* **Description**: Create a service to handle message creation, retrieval (stream), and read receipt updates for both crew and direct messages.
* **Dependencies**: #15 (Failing tests), #8, #10
* **Est. Time**: 3h

17. [X]**Task**: Extend `JobSharingService` for crew-specific sharing.

* **Description**: Add `shareToCrews(jobId, crewIds)` and `getCrewSharedJobs(crewId)` methods to the existing `JobSharingService`.
* **Dependencies**: #7, #10
* **Est. Time**: 2h

### 4. Cloud Functions (`functions/`)

18. [X]**Task**: Deploy Cloud Functions for `onCrewJobShare` and notification triggers.
    * **Description**: Implement Firebase Cloud Functions (Node.js/TypeScript) that trigger push notifications on new job shares, new messages, and invitations as described in `research.md`.
    * **Dependencies**: #10, #14, #16, #17
    * **Est. Time**: 4h

### 5. Riverpod State Management (`lib/features/crews/providers/`)

19. [X]**Task**: Create `userCrewsProvider` (StreamProvider) and `selectedCrewProvider` (StateProvider).
    * **Description**: Implement Riverpod providers to listen for the current user's crews and manage the currently selected crew.
    * **Dependencies**: #10
    * **Est. Time**: 2h
    * **[P]**

20. [X]**Task**: Create `tailboardProvider` (StreamProvider.family) and other Tailboard-related providers.
    * **Description**: Implement Riverpod providers to stream `Tailboard` data, `SuggestedJob` lists, `ActivityItem` streams, and `TailboardPost` lists based on the `selectedCrewProvider`.
    * **Dependencies**: #14, #19
    * **Est. Time**: 3h
    * **[P]**

21. [X]**Task**: Create `crewMessagesProvider` (StreamProvider.family) and other messaging providers.
    * **Description**: Implement Riverpod providers to stream crew messages and direct messages, managing read receipts.
    * **Dependencies**: #16, #19
    * **Est. Time**: 2h
    * **[P]**

### 6. UI - Navigation & Entry Points

22. [X]**Task**: Update `BottomNavigationBar` to include the "Crews" tab.
    * **Description**: Modify the main app `BottomNavigationBar` widget to add the new `Crews` icon and label, including the unread activity badge as per `crews-feature.md`.
    * **Dependencies**: #19
    * **Est. Time**: 1.5h

23. [X]**Task**: Implement "Create Crew" and "Join Crew" initial empty state screen.
    * **Description**: Develop the UI for the initial state of the Crews tab when a user has no crews, including buttons for "Create a Crew" and "Browse Public Crews/Enter Invite Code".
    * **Dependencies**: #22
    * **Est. Time**: 2h

24. [X]**Task**: Add "Active Crews Widget" to the Home Screen.
    * **Description**: Implement a widget on the existing Home screen that displays a summary of the user's active crews and provides a link to the Crews tab.
    * **Dependencies**: #19, #22
    * **Est. Time**: 1.5h
    * **[P]**

25. [X]**Task**: Integrate "Share to Crews" button on Job Details Screen.
    * **Description**: Modify the existing Job Details screen to include a "Share to Crews" button and a modal/sheet for selecting target crews.
    * **Dependencies**: #17, #19
    * **Est. Time**: 2h

26. [X]**Task**: Update existing Messages Screen to include Crew Chats.
    * **Description**: Modify the main Messages screen to add a tab or filter for "Crews" to show crew-specific chat conversations.
    * **Dependencies**: #21, #22
    * **Est. Time**: 1.5h

### 7. UI - Crew Formation & Management Screens

27. [X]**Task**: Implement "Create a Crew" screen.
    * **Description**: Develop the UI and logic for the crew creation flow (name, preferences, initial foreman setup).
    * **Dependencies**: #10, #12
    * **Est. Time**: 3h

28. [X]**Task**: Implement Crew Invitation UI (Contacts, Email, Username).
    * **Description**: Develop the UI for inviting members using different methods and integrating with `CrewService` for sending invitations.
    * **Dependencies**: #12
    * **Est. Time**: 2.5h

29. [X]**Task**: Implement Crew Settings / Management Screen.
    * **Description**: Develop a screen for foreman/lead users to manage crew preferences, logo, and general settings.
    * **Dependencies**: #10
    * **Est. Time**: 3h

### 8. UI - The Tailboard (`lib/features/crews/screens/`, `widgets/`)

30. [X]**Task**: Implement the main `TailboardScreen` layout with Header and Tab Selector.
    * **Description**: Create the `TailboardScreen` with the `CrewSelector` header, quick actions bar, and the tab bar (Feed, Jobs, Chat, Members) as per `crews-feature.md`.
    * **Dependencies**: #19, #20, #22
    * **Est. Time**: 3.5h

31. [X]**Task**: Implement `Feed` tab content with `ActivityCard` and `AnnouncementCard`.
    * **Description**: Develop the UI for the "Feed" tab, displaying `ActivityItem`s and `TailboardPost`s from `tailboardProvider`.
    * **Dependencies**: #20, #30
    * **Est. Time**: 3.5h

32. [X]**Task**: Implement `Jobs` tab content with `JobMatchCard` and filters.
    * **Description**: Develop the UI for the "Jobs" tab, displaying AI-matched jobs using `JobMatchCard` components and basic filtering.
    * **Dependencies**: #20, #30
    * **Est. Time**: 4h

33. [X]**Task**: Implement `Chat` tab content for crew messaging and DM previews.
    * **Description**: Develop the UI for the "Chat" tab, including the crew group chat interface and previews for direct messages.
    * **Dependencies**: #21, #30
    * **Est. Time**: 4h

34. [X]**Task**: Implement `Members` tab content with `CrewMemberAvatar` and member list.
    * **Description**: Develop the UI for the "Members" tab, displaying crew statistics and a list of members with their roles and online status.
    * **Dependencies**: #19, #30
    * **Est. Time**: 3h

### 9. Testing & Validation

35. [ ]**Task**: Write integration tests for core user flows (Create Crew, Share Job, Send Message).
    * **Description**: Create `test/features/crews/integration/crew_integration_test.dart` to test end-to-end flows using Firebase Emulator Suite as per `quickstart.md`.
    * **Dependencies**: All implemented features (especially services and UI)
    * **Est. Time**: 6h

36. [ ]**Task**: Implement performance optimizations for Tailboard loading and message delivery.
    * **Description**: Apply pagination, lazy loading, and Firestore offline persistence as detailed in `research.md` to meet performance goals.
    * **Dependencies**: #20, #21, #31, #32, #33
    * **Est. Time**: 3h

37. [ ]**Task**: Integrate Firebase Analytics for crew success metrics.
    * **Description**: Implement tracking for `crewEngagement`, `jobMatching`, and `viralGrowth` metrics as defined in `crews-feature.md`.
    * **Dependencies**: All features
    * **Est. Time**: 2h

---
