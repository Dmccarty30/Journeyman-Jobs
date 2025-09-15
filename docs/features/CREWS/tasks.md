# Tasks: Crews Communication Hub

**Input**: Design documents from `docs/features/Crews/`
**Prerequisites**: plan.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

## Execution Flow (main)

```dart
1. Load plan.md from feature directory ✓
   → Tech stack: Flutter 3.x/Dart 3.0+, Firebase (Firestore, FCM), Riverpod
   → Structure: lib/features/crews/ with models/, providers/, services/, screens/, widgets/
2. Load design documents ✓:
   → data-model.md: 13 entities extracted → model tasks
   → contracts/: 11 API endpoints → service and integration tests
   → quickstart.md: 6 user flows → integration tests
3. Generate tasks by category:
   → Setup: Firebase rules, dependencies, project structure
   → Tests: Contract tests, integration tests, widget tests
   → Core: Models, services, providers, screens
   → Integration: Navigation, existing service integration
   → Polish: Unit tests, performance, documentation
4. Apply TDD rules:
   → Tests before implementation (constitutional requirement)
   → [P] for different files with no dependencies
   → Sequential for same file modifications
5. Number tasks T001-T047 with dependency tracking
```

## Format: `[ID] [P?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- File paths follow Flutter feature-based structure

## Phase 3.1: Setup & Configuration ✅ **COMPLETE**

- [x] **T001** Create lib/features/crews/ directory structure (models/, providers/, services/, screens/, widgets/) ✅
- [x] **T002** Update pubspec.yaml with crew-specific dependencies (riverpod, firebase packages) ✅
- [x] **T003** [P] Create firestore.rules for crew collections security ✅
- [x] **T004** [P] Create functions/src/crews.js for Firebase Cloud Functions ✅
- [x] **T005** [P] Update lib/navigation/app_router.dart to include crew routes ✅

## Phase 3.2: Tests First (TDD) ✅ **COMPLETE**

- **CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation** ✅ ALL TESTS WRITTEN AND FAILING

### Contract Tests (API Integration) ✅ **COMPLETE**

- [x] **T006** [P] Contract test POST /crews in test/features/crews/integration/crew_management_test.dart ✅
- [x] **T007** [P] Contract test GET /crews in test/features/crews/integration/crew_management_test.dart ✅
- [x] **T008** [P] Contract test POST /crews/{crewId}/members in test/features/crews/integration/crew_member_test.dart ✅
- [x] **T009** [P] Contract test POST /crews/{crewId}/jobs in test/features/crews/integration/job_sharing_test.dart ✅
- [x] **T010** [P] Contract test POST /crews/{crewId}/messages in test/features/crews/integration/crew_communication_test.dart ✅

### Integration Tests (User Flows) ✅ **COMPLETE**

- [x] **T011** [P] Integration test: Create crew and invite members flow in test/features/crews/integration/crew_creation_flow_test.dart ✅
- [x] **T012** [P] Integration test: Accept crew invitation flow in test/features/crews/integration/crew_invitation_flow_test.dart ✅
- [x] **T013** [P] Integration test: Share job to crew flow in test/features/crews/integration/job_sharing_flow_test.dart ✅
- [x] **T014** [P] Integration test: Crew communication flow in test/features/crews/integration/crew_messaging_flow_test.dart ✅
- [x] **T015** [P] Integration test: Group job application coordination in test/features/crews/integration/group_bid_flow_test.dart ✅
- [x] **T016** [P] Integration test: Member management and voting in test/features/crews/integration/member_management_flow_test.dart ✅

### Widget Tests ✅ **COMPLETE**

- [x] **T017** [P] Widget test for CrewCard in test/features/crews/widgets/crew_card_test.dart ✅
- [x] **T018** [P] Widget test for CrewListScreen in test/features/crews/screens/crew_list_screen_test.dart ✅
- [x] **T019** [P] Widget test for CreateCrewScreen in test/features/crews/screens/create_crew_screen_test.dart ✅

## Phase 3.3: Core Models ✅ **COMPLETE**

### Data Models ✅ **COMPLETE**

- [x] **T020** [P] Crew model in lib/features/crews/models/crew.dart ✅
- [x] **T021** [P] CrewMember model in lib/features/crews/models/crew_member.dart ✅
- [x] **T022** [P] JobNotification model in lib/features/crews/models/job_notification.dart ✅
- [x] **T023** [P] GroupBid model in lib/features/crews/models/group_bid.dart ✅
- [x] **T024** [P] CrewCommunication model in lib/features/crews/models/crew_communication.dart ✅
- [x] **T025** [P] CrewPreferences model in lib/features/crews/models/crew_preferences.dart ✅
- [x] **T026** [P] CrewStats model in lib/features/crews/models/crew_stats.dart ✅

### Enums and Supporting Classes ✅ **COMPLETE**

- [x] **T027** [P] CrewRole, ResponseType, GroupBidStatus enums in lib/features/crews/models/crew_enums.dart ✅
- [x] **T028** [P] MessageType, AttachmentType, JobType enums in lib/features/crews/models/crew_enums.dart ✅

## Phase 3.4: Services & Business Logic ✅ **COMPLETE**

- [x] **T029** CrewService core CRUD operations in lib/features/crews/services/crew_service.dart ✅
- [x] **T030** CrewMemberService for member management in lib/features/crews/services/crew_member_service.dart ✅
- [x] **T031** CrewCommunicationService for messaging in lib/features/crews/services/crew_communication_service.dart ✅
- [x] **T032** Extend JobSharingService for crew job sharing in lib/services/job_sharing_service.dart ✅

## Phase 3.5: State Management (Riverpod Providers) ✅ **COMPLETE**

- [x] **T033** [P] CrewProvider for crew state management in lib/features/crews/providers/crew_provider.dart ✅
- [x] **T034** [P] CrewMemberProvider for member state in lib/features/crews/providers/crew_member_provider.dart ✅
- [x] **T035** [P] CrewCommunicationProvider for messaging state in lib/features/crews/providers/crew_communication_provider.dart ✅

## Phase 3.6: UI Implementation ✅ **COMPLETE**

### Core Widgets ✅ **COMPLETE**

- [x] **T036** [P] CrewCard widget in lib/features/crews/widgets/crew_card.dart ✅
- [x] **T037** [P] CrewMemberCard widget in lib/features/crews/widgets/crew_member_card.dart ✅
- [x] **T038** [P] JobNotificationCard widget in lib/features/crews/widgets/job_notification_card.dart ✅
- [x] **T039** [P] MessageBubble widget in lib/features/crews/widgets/message_bubble.dart ✅

### Screens ✅ **COMPLETE**

- [x] **T040** CrewListScreen in lib/features/crews/screens/crew_list_screen.dart ✅
- [x] **T041** CreateCrewScreen in lib/features/crews/screens/create_crew_screen.dart ✅
- [x] **T042** CrewDetailScreen in lib/features/crews/screens/crew_detail_screen.dart ✅
- [x] **T043** CrewCommunicationScreen in lib/features/crews/screens/crew_communication_screen.dart ✅

## Phase 3.7: Integration & Navigation 🔄 **IN PROGRESS**

- [ ] **T044** Update main navigation to include Crews tab in lib/navigation/app_router.dart
- [ ] **T045** Connect crew job sharing with existing job sharing flow in lib/services/job_sharing_service.dart
- [ ] **T046** Firebase Cloud Functions deployment and crew notification triggers

## Phase 3.8: Polish & Validation

- [ ] **T047** [P] Run quickstart.md validation flows and fix any issues

## Dependencies

```dart
Setup (T001-T005) → Tests (T006-T019) → Models (T020-T028) → Services (T029-T032) → Providers (T033-T035) → Widgets (T036-T039) → Screens (T040-T043) → Integration (T044-T046) → Polish (T047)

Critical Blocking Dependencies:
- T029 (CrewService) blocks T033 (CrewProvider)
- T033 (CrewProvider) blocks T040 (CrewListScreen)
- T020-T028 (Models) block all Services T029-T032
- T006-T019 (Tests) must complete before any implementation
```

## Parallel Execution Examples

### Phase 3.2 - Contract Tests (Can run simultaneously)

```bash
# Launch T006-T010 together:
Task: "Contract test POST /crews in test/features/crews/integration/crew_management_test.dart"
Task: "Contract test GET /crews in test/features/crews/integration/crew_management_test.dart"
Task: "Contract test POST /crews/{crewId}/members in test/features/crews/integration/crew_member_test.dart"
Task: "Contract test POST /crews/{crewId}/jobs in test/features/crews/integration/job_sharing_test.dart"
Task: "Contract test POST /crews/{crewId}/messages in test/features/crews/integration/crew_communication_test.dart"
```

### Phase 3.3 - Data Models (Can run simultaneously)

```bash
# Launch T020-T028 together:
Task: "Crew model in lib/features/crews/models/crew.dart"
Task: "CrewMember model in lib/features/crews/models/crew_member.dart"
Task: "JobNotification model in lib/features/crews/models/job_notification.dart"
Task: "GroupBid model in lib/features/crews/models/group_bid.dart"
Task: "CrewCommunication model in lib/features/crews/models/crew_communication.dart"
```

### Phase 3.5 - Riverpod Providers (Can run simultaneously)

```bash
# Launch T033-T035 together:
Task: "CrewProvider for crew state management in lib/features/crews/providers/crew_provider.dart"
Task: "CrewMemberProvider for member state in lib/features/crews/providers/crew_member_provider.dart"
Task: "CrewCommunicationProvider for messaging state in lib/features/crews/providers/crew_communication_provider.dart"
```

## Validation Checklist

- *GATE: Must be checked before implementation complete*

- [x] All API contracts have corresponding tests (T006-T010)
- [x] All entities have model tasks (T020-T028)
- [x] All user flows have integration tests (T011-T016)
- [x] All tests come before implementation (T006-T019 before T020+)
- [x] Parallel tasks are truly independent (different files)
- [x] Each task specifies exact file path
- [x] TDD order enforced: Tests → Models → Services → Providers → UI
- [x] No task modifies same file as another [P] task
- [x] All quickstart.md flows have validation tasks

## Notes

- [P] tasks target different files with no shared dependencies
- Verify ALL tests fail before implementing (T006-T019)
- Commit after each completed task
- Follow existing electrical theme patterns from design_system/
- Maintain consistency with existing job_sharing feature patterns
- Firebase emulator suite required for realistic testing
- Real-time Firestore listeners essential for crew communication
- Offline capabilities required for field worker use cases

## Task Generation Rules Applied

- *Rules applied during task generation*

1. **From Contracts** ✓:
   - 11 API endpoints → 5 contract test tasks (T006-T010)
   - Each endpoint group → dedicated service implementation

2. **From Data Model** ✓:
   - 13 entities → 9 model creation tasks (T020-T028)
   - Related entities grouped for dependency management

3. **From Quickstart User Stories** ✓:
   - 6 user flows → 6 integration test tasks (T011-T016)
   - Each flow mapped to specific test scenarios

4. **TDD Ordering** ✓:
   - Setup → Contract Tests → Integration Tests → Models → Services → UI
   - Constitutional requirement: All tests before implementation
