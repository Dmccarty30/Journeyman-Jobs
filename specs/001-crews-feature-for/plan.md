# Implementation Plan: Crews

**Branch**: `001-crews-feature-for` | **Date**: 2025-01-15 | **Spec**: `/specs/001-crews-feature-for/spec.md`
**Input**: Feature specification from `/specs/001-crews-feature-for/spec.md`

## Summary

The Crews feature transforms Journeyman Jobs from an individual job-finding platform into a collaborative network where skilled workers form crews, share opportunities, and advance careers together. This implementation integrates with existing job_sharing infrastructure using Firebase Firestore for backend storage, Riverpod for state management, and real-time sync for crew updates.

## Technical Context

**Language/Version**: Flutter 3.x / Dart 3.0+
**Primary Dependencies**: Firebase (Firestore, Functions, FCM), Riverpod, existing job_sharing services
**Storage**: Firebase Firestore with subcollections for crew members, Tailboard data, and messages
**Testing**: Flutter test framework with widget tests and integration tests
**Target Platform**: iOS 13+ and Android 8+ (mobile-first)
**Project Type**: mobile - Flutter application with Firebase backend
**Performance Goals**: <100ms Tailboard load time, real-time message delivery, 60 fps UI
**Constraints**: Offline-capable for essential features, <2% crash rate, optimized for field use
**Scale/Scope**: 10k+ users, 50+ screens for full crew functionality

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:

- Projects: 2 (Flutter app, Firebase backend/functions)
- Using framework directly? YES - Direct Firebase SDK and Riverpod usage
- Single data model? YES - Unified Crew/Member/Tailboard models
- Avoiding patterns? YES - No unnecessary abstractions, using existing patterns

**Architecture**:

- EVERY feature as library? YES - Crew functionality as feature module
- Libraries listed:
  - `lib/features/crews/` - Core crew management functionality
  - `lib/features/crews/services/` - Crew business logic and Firebase integration
  - `lib/features/crews/providers/` - Riverpod state management
- CLI per library: N/A - Mobile app features exposed through UI
- Library docs: Will include comprehensive documentation in feature folder

**Testing (NON-NEGOTIABLE)**:

- RED-GREEN-Refactor cycle enforced? YES - Tests written first
- Git commits show tests before implementation? YES
- Order: Contract→Integration→E2E→Unit strictly followed? YES
- Real dependencies used? YES - Firebase emulator suite for testing
- Integration tests for: new libraries, contract changes, shared schemas? YES
- FORBIDDEN: Implementation before test, skipping RED phase ✓

**Observability**:

- Structured logging included? YES - Firebase Analytics and Crashlytics
- Frontend logs → backend? YES - Error reporting to Firebase
- Error context sufficient? YES - User context, crew context, action traces

**Versioning**:

- Version number assigned? YES - 2.0.0 (major feature addition)
- BUILD increments on every change? YES
- Breaking changes handled? NO breaking changes - additive feature

## Project Structure

### Documentation (this feature)

```dart
specs/001-crews-feature-for/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)

```dart
# Flutter Mobile Application Structure
lib/
├── features/
│   └── crews/                    # NEW: Crews feature module
│       ├── models/               # Crew, Member, Tailboard models
│       ├── providers/            # Riverpod state management
│       ├── services/             # Firebase integration
│       ├── screens/              # Tailboard, crew management screens
│       └── widgets/              # Reusable crew components
├── models/                       # EXISTING: Shared data models
├── services/                     # EXISTING: Including job_sharing_service
├── providers/                    # EXISTING: App-wide providers
└── screens/                      # EXISTING: Main app screens

test/
├── features/
│   └── crews/                    # Crew feature tests
│       ├── integration/          # Firebase integration tests
│       ├── unit/                 # Model and service tests
│       └── widgets/              # Widget tests
```

**Structure Decision**: Mobile app structure (Flutter) with feature-based organization

## Phase 0: Outline & Research

1. **Extract unknowns from Technical Context**:
   - Riverpod best practices for real-time crew state management
   - Firebase Firestore structure for optimal crew data organization
   - Integration patterns with existing job_sharing infrastructure
   - Push notification strategy for crew activities

2. **Generate and dispatch research agents**:

   ```
   Task: "Research Riverpod patterns for real-time collaborative features"
   Task: "Find best practices for Firestore subcollections in crew/member relationships"
   Task: "Research Firebase Cloud Messaging for crew notifications"
   Task: "Analyze existing job_sharing_service.dart for integration points"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: Firestore subcollection structure
   - Rationale: Optimal for crew member queries and real-time sync
   - Alternatives considered: Flat collection structure, separate collections

**Output**: research.md with all technical decisions documented

## Phase 1: Design & Contracts

*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Crew: id, name, logo, foremanId, memberIds, preferences, createdAt, roles, stats
   - CrewMember: userId, crewId, role, joinedAt, permissions
   - Tailboard: crewId, jobFeed, activityStream, posts, messages, calendar
   - CrewMessage: id, senderId, crewId, content, type, attachments, sentAt, readBy
   - CrewPreferences: jobTypes, minHourlyRate, maxDistance, skills

2. **Generate API contracts** from functional requirements:
   - Crew Management: create, join, leave, update, delete
   - Member Management: invite, accept, reject, remove, updateRole
   - Tailboard: getF

eed, postActivity, pinAnnouncement

- Messaging: sendMessage, getMessages, markAsRead
- Job Sharing: shareToCrews, trackApplications

3. **Generate contract tests** from contracts:
   - `test/features/crews/integration/crew_management_test.dart`
   - `test/features/crews/integration/tailboard_sync_test.dart`
   - `test/features/crews/integration/messaging_test.dart`

4. **Extract test scenarios** from user stories:
   - Create crew with 2+ members scenario
   - Share job to multiple crews scenario
   - Real-time message delivery scenario
   - Tailboard activity feed update scenario

5. **Update CLAUDE.md incrementally**:
   - Add Crews feature context
   - Document Firestore collection structure
   - Add Riverpod provider patterns
   - Include integration points with job_sharing

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, updated CLAUDE.md

## Phase 2: Task Planning Approach

*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:

- Generate ~30 tasks covering:
  - Firestore collection setup and rules
  - Data model implementation
  - Riverpod providers for crew state
  - Tailboard UI implementation
  - Messaging system integration
  - Job sharing integration
  - Push notification setup
  - Testing at all levels

**Ordering Strategy**:

- TDD order: Tests before implementation
- Dependency order:
  1. Data models
  2. Firebase services
  3. Riverpod providers
  4. UI screens and widgets
  5. Integration with existing features
- Mark [P] for parallel execution where possible

**Estimated Output**: 30-35 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation

*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional principles)
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking

*No violations - implementation follows all constitutional principles*

## Progress Tracking

*This checklist is updated during execution flow*

**Phase Status**:

- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:

- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none)

---
*Based on Journeyman Jobs Constitution v1.0.0 - See `.specify/memory/constitution.md`*
