# Refactoring Plan: Barrel Files & JJ Components

## Phase 1: Preparation (Completed)

- [x] Analyze codebase for barrel file candidates.
- [x] Create `lib/widgets/widgets.dart`.
- [x] Create `lib/design_system/design_system.dart`.
- [x] Create `lib/features/crews/widgets/crews_widgets.dart`.
- [x] Update `lib/electrical_components/electrical_components.dart`.
- [x] Create standalone `JJTextField`, `JJButton`, `JJText`.
- [x] Create `ComponentDemoScreen`.
- [x] Git Commit: "feat: add barrel files and JJ component variants".

## Phase 2: Refactoring - Core Screens (High Priority)

**Goal:** Update the most visible screens to use the new components and barrel imports.

1. **Auth Screen (`lib/screens/onboarding/auth_screen.dart`)**
    - Replace `TextFormField` with `JJTextField`.
    - Replace `ElevatedButton`/`OutlinedButton` with `JJButton`.
    - Update imports to use `widgets.dart` and `design_system.dart`.
    - *Verification:* Check login/signup flow.

2. **Create Crew Screen (`lib/features/crews/screens/create_crew_screen.dart`)**
    - Replace the custom text fields (that inspired this task) with the reusable `JJTextField`.
    - Update imports.
    - *Verification:* Ensure the "floating label" behavior is identical.

3. **Home Screen (`lib/screens/home/home_screen.dart`)**
    - Update imports to use barrel files.
    - Replace any ad-hoc buttons or text with `JJButton` / `JJText`.

## Phase 3: Refactoring - Feature Modules (Medium Priority)

**Goal:** Clean up feature-specific code.

4. **Crews Feature (`lib/features/crews/`)**
    - Scan all files in `lib/features/crews/screens/`.
    - Update imports to use `crews_widgets.dart`.
    - Replace standard widgets with JJ variants where applicable.

5. **Storm Mode (`lib/screens/storm/`)**
    - Update imports to use `electrical_components.dart`.
    - Ensure consistent button styling.

## Phase 4: Global Cleanup (Low Priority / Maintenance)

**Goal:** Ensure consistency across the entire project.

6. **Global Search & Replace Imports**
    - Search for `import '.../app_theme.dart';` -> Replace with `design_system.dart`.
    - Search for `import '.../jj_button.dart';` (old path) -> Replace with `widgets.dart`.

7. **Final Verification**
    - Run `flutter analyze`.
    - Run `flutter test`.
    - Manual walkthrough of the app.

## Tracking

- **Current Status:** Phase 1 Complete. Starting Phase 2.
- **Next Step:** Refactor `AuthScreen`.
