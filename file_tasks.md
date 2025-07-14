# File Structure Architecture Review – Task List

## Phase 1: Immediate Actions (Week 1)

- [x] Remove npm-cache from the project and add its path to `.gitignore`
- [x] Move all example code out of `lib/examples/` to a new `example/` directory
- [x] Consolidate duplicate `electrical_components` directories, keeping only the version in `lib/`
- [x] Move all `.md` documentation files out of code directories (e.g., `lib/`) into a dedicated `docs/` structure

## Phase 2: Core Refactoring & Service Layer Consolidation (Week 2)

- [x] Refactor `lib/backend/` (FlutterFlow legacy code) into a new `lib/legacy/flutterflow/` directory
- [x] Move all generated code out of mainline code paths
- [x] Refactor backend/schema duplication: move enums and schema utilities to `lib/domain/enums/` and `lib/domain/utils/`
- [x] Consolidate the service layer: reduce from 22 to 8 focused services with clear boundaries
- [x] Implement the repository pattern in the data layer
- [x] Add a use case layer in the domain structure
- [ ] Update all imports project-wide to match the new structure

## Phase 3: Test Structure Alignment (Week 3)

- [ ] Align the test directory structure to mirror the new architecture (core, data, domain, presentation, fixtures, helpers)
- [ ] Create missing tests for all repositories and services (unit tests)
- [ ] Add widget tests for all screens and custom widgets
- [ ] Add integration tests for critical user flows
- [ ] Add performance tests for job list scrolling and Firestore queries

## Phase 4: Performance & Code Quality Improvements (Week 4)

- [ ] Implement lazy loading for large screens/components
- [ ] Add barrel export files for widgets and other reusable modules
- [ ] Modularize features under `lib/features/` (jobs, unions, etc.)
- [ ] Refactor code to reduce cyclomatic complexity to <10 per method
- [ ] Decouple backend from UI using interfaces
- [ ] Increase module cohesion and reduce coupling
- [ ] Raise test coverage to >80%

## Phase 5: Security & CI/CD

- [ ] Remove sensitive files (e.g., `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `.env`) from version control and add to `.gitignore`
- [ ] Create `lib/core/config/secrets.dart` (git-ignored) and `secrets.example.dart` (template)
- [ ] Update CI/CD configuration to support the new structure

## Phase 6: Documentation

- [ ] Document the new architecture and migration steps in `docs/architecture/README.md`
- [ ] Ensure all new modules and services are documented

---

**Mermaid Diagram: High-Level Migration Workflow**

```mermaid
flowchart TD
    A[Remove npm-cache & add to gitignore]
    B[Move examples to example/]
    C[Consolidate electrical_components]
    D[Move docs to docs/]
    E[Refactor backend to legacy/]
    F[Service layer consolidation]
    G[Repository & use case pattern]
    H[Test structure alignment]
    I[Performance & code quality]
    J[Security & secrets management]
    K[Update CI/CD]
    L[Documentation]

    A --> B --> C --> D --> E --> F --> G --> H --> I --> J --> K --> L
