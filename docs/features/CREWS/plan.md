# Implementation Plan: Crews Communication Hub

**Branch**: `001-crews-feature-for` | **Date**: 2025-09-15 | **Spec**: `/docs/features/Crews/specs/001-new-feature/spec.md`
**Input**: Feature specification for traveling electrical workers crew communication system

## Summary
The Crews Communication Hub enables IBEW electrical workers ("Tramps") who travel together to form crews, coordinate job applications, and communicate about work opportunities. This implementation leverages existing job_sharing infrastructure with Firebase Firestore backend, Riverpod for state management, and real-time sync for crew coordination.

## Technical Context
**Language/Version**: Flutter 3.x / Dart 3.0+
**Primary Dependencies**: Firebase (Firestore, Functions, FCM), Riverpod, existing job_sharing services
**Storage**: Firebase Firestore with subcollections for crew management and communication
**Testing**: Flutter test framework with widget tests, integration tests, and Firebase emulator suite
**Target Platform**: iOS 13+ and Android 8+ (mobile-first for field workers)
**Project Type**: mobile - Flutter application with Firebase backend integration
**Performance Goals**: <100ms crew board load time, real-time notifications, 60 fps UI
**Constraints**: Offline-capable for essential features, field-optimized UI, <2% crash rate
**Scale/Scope**: 10k+ users, up to 5 crews per user, max 10 members per crew, 1-month activity history

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 2 (Flutter app, Firebase backend/functions)
- Using framework directly? YES - Direct Firebase SDK and Riverpod usage
- Single data model? YES - Unified Crew/Member/JobNotification models
- Avoiding patterns? YES - No unnecessary abstractions, reusing existing patterns

**Architecture**:
- EVERY feature as library? YES - Crew functionality as feature module
- Libraries listed:
  - `lib/features/crews/` - Core crew communication functionality
  - `lib/features/crews/services/` - Crew business logic and Firebase integration
  - `lib/features/crews/providers/` - Riverpod state management for real-time crew data
- CLI per library: N/A - Mobile app features exposed through UI
- Library docs: Comprehensive documentation in feature folder

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor cycle enforced? YES - Tests written first, must fail before implementation
- Git commits show tests before implementation? YES
- Order: Contract→Integration→E2E→Unit strictly followed? YES
- Real dependencies used? YES - Firebase emulator suite for realistic testing
- Integration tests for: new libraries, contract changes, shared schemas? YES
- FORBIDDEN: Implementation before test, skipping RED phase ✓

**Observability**:
- Structured logging included? YES - Firebase Analytics and Crashlytics
- Frontend logs → backend? YES - Error reporting to Firebase with crew context
- Error context sufficient? YES - User context, crew context, action traces

**Versioning**:
- Version number assigned? YES - 2.0.0 (major feature addition)
- BUILD increments on every change? YES
- Breaking changes handled? NO breaking changes - additive feature

## Project Structure

### Documentation (this feature)
```
docs/features/Crews/
├── plan.md              # This file - implementation plan
├── research.md          # Technical research and decisions
├── data-model.md        # Data models and relationships
├── quickstart.md        # Testing guide and user flows
├── contracts/           # API specifications
└── specs/
    └── 001-new-feature/
        └── spec.md      # Original feature specification
```

### Source Code (repository root)
```
# Flutter Mobile Application Structure
lib/
├── features/
│   ├── job_sharing/             # EXISTING: Job sharing infrastructure
│   └── crews/                   # NEW: Crew communication feature
│       ├── models/              # Crew, CrewMember, JobNotification models
│       ├── providers/           # Riverpod state management
│       ├── services/            # Firebase integration & crew logic
│       ├── screens/             # Crew board, member management screens
│       └── widgets/             # Reusable crew components
├── models/                      # EXISTING: Shared data models
├── services/                    # EXISTING: Including job_sharing_service
├── providers/                   # EXISTING: App-wide providers
└── screens/                     # EXISTING: Main app screens with crews tab

test/
├── features/
│   └── crews/                   # Crew feature tests
│       ├── integration/         # Firebase integration tests
│       ├── unit/               # Model and service tests
│       └── widgets/            # Widget tests
```

**Structure Decision**: Mobile app structure (Flutter) with feature-based organization, integrating with existing job_sharing infrastructure

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context**:
   - Optimal Firebase Firestore structure for crew communication at scale
   - Riverpod patterns for real-time crew state with offline capability
   - Integration approach with existing job_sharing_service for crew job sharing
   - Push notification strategy for crew communication and job alerts
   - UI/UX patterns optimized for field workers using the app outdoors

2. **Research Areas**:
   ```
   Task: "Research Firestore subcollection design for crew communication scalability"
   Task: "Analyze Riverpod StreamProvider patterns for real-time collaborative features"
   Task: "Study existing job_sharing_service.dart integration points for crew functionality"
   Task: "Research Firebase Cloud Messaging topic subscription patterns for crew notifications"
   Task: "Investigate offline-first patterns for crew communication in poor network conditions"
   ```

3. **Consolidate findings** in `research.md`:
   - Decision: Technical approach selected
   - Rationale: Why chosen over alternatives
   - Alternatives considered: What else was evaluated
   - Integration strategy: How to leverage existing infrastructure

**Output**: research.md with all technical decisions documented

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Crew: Group identifier, name, leader, members, preferences, activity
   - CrewMember: User relationship, role, preferences, availability
   - JobNotification: Shared jobs within crew with member responses
   - GroupBid: Coordinated crew applications for jobs
   - CrewCommunication: Real-time messaging and coordination

2. **Generate API contracts** from functional requirements:
   - Crew Management: create, join, leave, manage members, set preferences
   - Job Sharing: share jobs to crew, coordinate group applications
   - Communication: crew messaging, notifications, activity feeds
   - Member Management: invite, accept/decline, vote to remove, role management

3. **Generate contract tests** from contracts:
   - `test/features/crews/integration/crew_management_test.dart`
   - `test/features/crews/integration/job_sharing_integration_test.dart`
   - `test/features/crews/integration/crew_communication_test.dart`

4. **Extract test scenarios** from user stories:
   - Create crew and invite members scenario
   - Share job opportunity to crew scenario
   - Coordinate group job application scenario
   - Crew communication and preference sharing scenario
   - Member removal and crew dissolution scenarios

5. **Update CLAUDE.md incrementally**:
   - Add Crews feature context and requirements
   - Document Firestore collection structure for crew data
   - Include Riverpod provider patterns for real-time crew state
   - Detail integration points with existing job_sharing infrastructure

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, updated CLAUDE.md

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Generate ~35-40 tasks covering:
  - Firebase collections and security rules setup
  - Data model implementation with validation
  - Riverpod providers for crew state management
  - Service layer for crew operations and job sharing integration
  - UI screens for crew management and communication
  - Real-time messaging and notification system
  - Integration with existing job_sharing functionality
  - Comprehensive testing at all levels

**Ordering Strategy**:
- TDD order: Tests before implementation (constitutional requirement)
- Dependency order:
  1. Data models and validation
  2. Firebase services and security rules
  3. Riverpod providers and state management
  4. Service integration with job_sharing
  5. UI screens and crew communication interface
  6. Push notifications and real-time updates
- Mark [P] for parallel execution where dependencies allow

**Estimated Output**: 35-40 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional TDD principles)
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