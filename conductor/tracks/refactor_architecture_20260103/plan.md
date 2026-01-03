# Plan: Feature-First Architecture Refactor

## Phase 1: Audit and Infrastructure
- [ ] Task: Audit `lib/` to map all existing files to their respective features.
- [ ] Task: Create `lib/features/` directory structure.
- [ ] Task: Conductor - User Manual Verification 'Audit and Infrastructure' (Protocol in workflow.md)

## Phase 2: Core Features Migration
- [ ] Task: Move `Jobs` feature components and create `lib/features/jobs/jobs.dart`.
- [ ] Task: Move `Storm` feature components and create `lib/features/storm/storm.dart`.
- [ ] Task: Move `Unions` feature components and create `lib/features/unions/unions.dart`.
- [ ] Task: Move `Profile` feature components and create `lib/features/profile/profile.dart`.
- [ ] Task: Conductor - User Manual Verification 'Core Features Migration' (Protocol in workflow.md)

## Phase 3: Auth and Navigation Migration
- [ ] Task: Move `Authentication` components and create `lib/features/auth/auth.dart`.
- [ ] Task: Move `Navigation` (go_router setup) to `lib/features/navigation/`.
- [ ] Task: Conductor - User Manual Verification 'Auth and Navigation Migration' (Protocol in workflow.md)

## Phase 4: Final Cleanup and Global Verification
- [ ] Task: Update all project imports to use barrel files.
- [ ] Task: Remove empty legacy directories (`lib/screens`, `lib/models`, `lib/widgets`, `lib/services`, `lib/providers`).
- [ ] Task: Execute full test suite and verify >80% coverage.
- [ ] Task: Conductor - User Manual Verification 'Final Cleanup and Global Verification' (Protocol in workflow.md)
