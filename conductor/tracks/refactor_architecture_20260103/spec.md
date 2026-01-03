# Spec: Feature-First Architecture Refactor

## 1. Objective
Refactor the Journeyman Jobs codebase from a layer-based structure to a feature-based structure to improve developer experience, reduce import complexity, and enhance scalability.

## 2. Success Criteria
- **Feature-First Structure:** All feature-specific code (models, screens, widgets, providers, services) must reside within `lib/features/<feature_name>/`.
- **Barrel Files:** Every feature directory must contain a barrel file (e.g., `lib/features/jobs/jobs.dart`) that exports its public API.
- **Import Optimization:** Project-wide imports should prefer barrel files over individual file paths within a feature.
- **Zero Regressions:** The application must compile and all existing functionality must remain intact.
- **Testing:** Maintain >80% test coverage for refactored modules.

## 3. Architecture Pattern
```text
lib/
├── features/
│   ├── <feature_name>/
│   │   ├── models/           # Feature-specific data structures
│   │   ├── providers/        # Riverpod state management
│   │   ├── screens/          # Feature UI pages
│   │   ├── services/         # Feature business logic/APIs
│   │   ├── widgets/          # Feature-specific UI components
│   │   └── <feature_name>.dart # Barrel file exporting the above
├── core/                     # Shared utilities, global models/widgets (to be defined later)
└── main.dart
```

## 4. Features to Refactor
- Jobs
- Storm
- Unions
- Profile
- Crews (finalize)
- Onboarding (if applicable)
- Authentication
- Navigation
- Design System (shared)
