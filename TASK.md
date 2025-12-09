# WIDGET & THEME REFACTOR - COMPREHENSIVE TASK PLAN

## OVERVIEW

The purpose of this document is to thoroughly detail and plan the comprehensive **Widget & Design System Refactor** combined with **App Theme Modernization**. This addresses the current chaos of duplicate widgets across multiple files/barrels, inconsistent theming, and fragmented imports while delivering the visual enhancements (animations, gradients, electrical motifs, job card redesigns) specified in the original goals.

**Primary Objectives:**

1. **Eliminate widget duplication** and establish clear ownership (design_system vs electrical_components)
2. **Create structured widget hierarchy** with category-based directories and canonical barrels
3. **Centralize theming** to ensure consistent light/dark mode across all widgets
4. **Modernize visual design** with gradients, animations, enhanced job/locals cards, electrical motifs
5. **Normalize imports** across the entire codebase
6. **Comprehensive documentation** and showcase

## GOALS

### Widget System Goals

- ✅ Single source of truth for each widget type (no more duplicates)
- ✅ Clear hierarchy: `lib/design_system/widgets/` (core) vs `lib/electrical_components/` (themed)
- ✅ Single barrel imports: `design_system_widgets.dart` and `electrical_components.dart`
- ✅ Each widget in its own focused file under category directories
- ✅ Centralized `widget_themes.dart` eliminating inline theme duplication

### Visual/Theme Goals

- Maintain Navy Blue + Copper palette with enhanced gradients/opacity/shadows
- Lightning/hurricane animations for key interactions (notifications, navigation)
- Electrical circuit backgrounds (60-70% opacity) for snackbars/toasts by state
- Redesigned job cards and locals cards (data-first, visually engaging)
- Animated bottom nav icons and dialog popups
- Professional, less formal typography
- Optional sound design hooks

## CURRENT STATE (Widget Chaos)

**Duplicate Widgets:**

- `JJTextField`: Defined in `lib/widgets/jj_text_field.dart` AND `reusable_components.dart`
- `JJButton`: Defined in `lib/widgets/jj_button.dart` AND `reusable_components.dart`
- `JJPowerLineLoader`: Design system AND electrical_components versions
- `JJSnackBar`: Multiple implementations with diverging behavior

**Fragmented Structure:**

```dart
lib/widgets/                 ← Legacy + duplicates
lib/design_system/components/reusable_components.dart ← Monolith (40+ widgets)
lib/electrical_components/   ← Themed widgets (inconsistent exports)
```

**Import Hell:** Screens import from 5+ different widget barrels/files directly

## END STATE (Clean Architecture)

```swift
lib/design_system/
├── widgets/
│   ├── design_system_widgets.dart (BARREL)
│   ├── inputs/jj_text_field.dart
│   ├── buttons/jj_button.dart
│   ├── layout/ (cards, bottom sheets)
│   ├── indicators/ (chips, progress)
│   └── feedback/ (snackbars, empty states)
├── theme/
│   └── widget_themes.dart (CENTRALIZED)
└── app_theme.dart

lib/electrical_components/
├── electrical_components.dart (BARREL)
├── animated/ (JJElectricalButton, etc.)
└── specialized/ (JJCircuitBreakerSwitch, etc.)
```

## COMPREHENSIVE TASKS (Phased Execution)

### Phase 1: Audit & Planning [Docs Only]

- [x] **Task 1**: Comprehensive widget audit documenting all duplicates, APIs, usage
- [x] **Create WIDGET_AUDIT.md** with findings before any code changes
  *Note: WIDGET_AUDIT.md created ✅ - Phase 1 complete*

### Phase 2: Directory Structure & File Creation

- [x] **Task 2**: Create `lib/design_system/widgets/` hierarchy (buttons/, inputs/, layout/, etc.) - ✅ buttons/, inputs/ exist
- [x] **Task 3**: Create `lib/design_system/widgets/design_system_widgets.dart` barrel - ✅ Exists and exports widgets
- [x] **Task 4**: Organize electrical_components into animated/ + specialized/ - ✅ Barrel exists, organized files present

### Phase 3: Consolidate Duplicates & Stabilize Widget Usage (Critical Path)

- [x] **Task 5**: Merge `JJTextField` → `lib/design_system/widgets/inputs/jj_text_field.dart`
  - ✅ `jj_text_field.dart` exists and is the canonical text-field implementation.

- [x] **Task 6**: Merge `JJButton` variants → `lib/design_system/widgets/buttons/jj_button.dart`
  - ✅ `jj_button.dart` + primary/secondary variants exist and are the canonical button implementations.

- [ ] **Task 7**: Consolidate `JJPowerLineLoader` & `JJSnackBar` (stabilize exports + imports)
  - **7.1 – Barrel ownership (DONE, verify only):**
    - Canonical definitions live under `lib/electrical_components/`.
    - `lib/electrical_components/electrical_components.dart` SHOULD export:
      - `jj_power_line_loader.dart`
      - `jj_snack_bar.dart`
    - `lib/design_system/widgets/design_system_widgets.dart` MUST **NOT** export these.
    - **Implementation guardrail:** Before changing anything else, re-open both barrels and visually confirm exports match this rule.
  
  - **7.2 – JJSnackBar/JJPowerLineLoader call-site inventory (PLANNING STEP ONLY):**
    - Build a checklist of *all* call sites using `JJSnackBar` or `JJPowerLineLoader`, grouped by area:
      - Onboarding/auth screens
      - Settings / support / tools screens
      - Legacy `lib/widgets/` helpers (e.g., `notification_popup.dart`, `firestore_query_popup.dart`)
    - This checklist should live either in `TASK.md` (as a sublist) or a new `docs/JJ_SNACKBAR_MIGRATION.md` so every file is explicit before touching code.
  
  - **7.3 – Standard import pattern (REFERENCE SNIPPET):**
    - For any file that uses `JJSnackBar` or `JJPowerLineLoader`, the canonical import pattern is:

      ```dart
      import 'package:journeyman_jobs/design_system/widgets/design_system_widgets.dart';
      import 'package:journeyman_jobs/electrical_components/electrical_components.dart';
      ```

    - **Rule:**
      - Keep existing relative imports for `app_theme.dart`, routers, utilities, etc. **unchanged** unless there is a clear reason.
      - Only add the electrical_components barrel import when a snackbar/loader is actually used.
  
  - **7.4 – Per-file normalization workflow (SMALL BATCH, NO MASS REPLACE):**
    - For each file in the call-site checklist:
      1. **Open the file and read the full import block first** (no blind `replace_in_file`).
      2. *If* the file uses `JJSnackBar` or `JJPowerLineLoader` and does **not** import `electrical_components.dart`, then:
         - Add:

           ```dart
           import 'package:journeyman_jobs/electrical_components/electrical_components.dart';
           ```

           near the other package imports.
         - Do **not** delete any existing imports unless the analyzer later reports them as unused and it's obviously safe.
      3. Save the file.
      4. Run `dart analyze` (or a focused analyze if you prefer) and confirm:
         - No new syntax errors were introduced.
         - Any new issues are clearly expected (e.g., pre-existing test warnings), not broken imports.
      5. Only then move to the next file in the checklist.
    - **Guardrail:** Never edit more than **3 snackbar/loader call-site files** in a single batch before running `dart analyze` and reviewing results.
  
  - **7.5 – Special handling for already-broken files (PLAN BEFORE TOUCHING):**
    - Known risky files (based on recent breakages):
      - `lib/screens/onboarding/auth_screen.dart`
      - `lib/screens/storm/widgets/storm_tracker_section.dart`
      - Any new file where imports were previously truncated or replaced incorrectly.
    - Plan for these files:
      - 7.5.1: Before editing, capture a **"desired imports"** snippet in comments or a scratch file (from git history, old snippets, or documentation).
      - 7.5.2: In ACT mode, **reconstruct the full import block manually**, not via `replace_in_file`.
      - 7.5.3: After fixing imports, run `dart analyze` immediately and do not touch any other file until this one is clean.

- [ ] **Task 8**: Plan and then migrate `reusable_components.dart` + `lib/widgets/` legacy widgets (NO BULK MOVES)
  - **8.1 – Classification pass (PLANNING ONLY, NO CODE MOVES YET):**
    - From `WIDGET_AUDIT.md` and the current codebase, classify each widget in:
      - `lib/design_system/components/reusable_components.dart`
      - `lib/widgets/`
    - For each widget, decide and document:
      - **Design system core** → Move under `lib/design_system/widgets/...`
      - **Feature-specific** → Move under the relevant feature (e.g., `lib/features/...` or `lib/screens/.../widgets/`), or leave in-place if that's the pattern.
      - **Deprecated/replaceable** → Mark for eventual removal.
    - Record this as a table (widget → new canonical location + barrel) in `TASK.md` or a dedicated `LEGACY_WIDGET_MIGRATION.md`.
  
  - **8.2 – Per-widget migration recipe (to follow later in ACT mode):**
    - The migration procedure for each widget should be:
      1. Create a new dedicated file (e.g., `lib/design_system/widgets/layout/jj_notification_popup.dart`).
      2. Move the widget class into that file **without changing the public API**.
      3. Update the appropriate barrel (`design_system_widgets.dart` or `electrical_components.dart`).
      4. Update imports in the small set of files that use this widget to point to the new barrel (not directly to the new file path where possible).
      5. Run `dart analyze`.
      6. If new issues appear in unrelated areas, stop and fix or roll back.
    - **Guardrail:** Only migrate **one widget at a time per commit**. No multi-widget bulk moves.
  
  - **8.3 – Explicit deferral of tricky widgets:**
    - Example: `GenericConnectionPointWidget` vs `ConnectionPointWidget`.
      - Note in the plan: "**Defer GenericConnectionPoint migration** until after core snackbar/loader and theme work is stable. Do not touch this widget again until a dedicated sub-plan is written for it."
    - This ensures we don't repeatedly destabilize the same area.

### Phase 4: Theme Centralization (Widget Themes First, Then Refactors)

- [ ] **Task 9**: Design and create `lib/design_system/theme/widget_themes.dart`
  - **9.1 – Theme discovery pass (READ-ONLY ANALYSIS):**
    - Scan `lib/design_system/app_theme.dart` and relevant widgets to identify:
      - Existing color constants / color schemes used repeatedly (especially for inputs and buttons).
      - Any existing `InputDecorationTheme`, `ButtonStyle` / `ButtonThemeData`, text styles, etc.
      - Places where inline `Color(...)` / `TextStyle(...)` settings should eventually move into centralized theme objects.
    - Document findings as a short list in `TASK.md` or a `THEME_AUDIT.md` so we know what we're centralizing.
  
  - **9.2 – Decide scope of v1 widget themes (keep it small):**
    - For the **first pass**, focus only on:
      - Text field theming (`InputDecorationTheme` for `JJTextField`).
      - Primary/secondary button theming (`ButtonStyle` or equivalent used by `JJButton` family).
    - Explicitly defer more complex themes (chips, dialogs, snackbars) to a later subtask.
  
  - **9.3 – Create `widget_themes.dart` skeleton:**
    - Add `lib/design_system/theme/widget_themes.dart` with:

      ```dart
      import 'package:flutter/material.dart';
      import '../app_theme.dart'; // or a shared colors/tokens file, if one exists

      class WidgetThemes {
        const WidgetThemes._();

        static InputDecorationTheme get jjTextFieldTheme => const InputDecorationTheme(
          // TODO: move current JJTextField decoration defaults here
        );

        static ButtonStyle get jjPrimaryButtonStyle => ElevatedButton.styleFrom(
          // TODO: move current JJPrimaryButton style here, using AppTheme colors
        );

        static ButtonStyle get jjSecondaryButtonStyle => OutlinedButton.styleFrom(
          // TODO: move current JJSecondaryButton style here
        );
      }
      ```

    - **Guardrail:** At this stage, don't change any existing widget logic; just introduce the new theme accessors.

- [ ] **Task 10**: Wire `widget_themes.dart` into `app_theme.dart` (light/dark)
  - **10.1 – Decide integration pattern:**
    - Either:
      - (A) Reference `WidgetThemes` directly inside `ThemeData` definitions in `app_theme.dart`, **or**
      - (B) Keep `WidgetThemes` as a separate helper used only by widgets (choose one and stick with it).
    - Document the chosen pattern in `TASK.md` under "Theme Integration Pattern" so future changes are consistent.
  
  - **10.2 – Minimal, safe wiring (inputs + primary button only):**
    - Update `app_theme.dart` to:
      - Use `WidgetThemes.jjTextFieldTheme` as the `inputDecorationTheme` for the app's `ThemeData`.
      - Optionally expose primary/secondary button styles if the current architecture benefits from it.
    - After wiring, run `dart analyze` and do a quick manual check on a **single screen** that uses `JJTextField` and `JJPrimaryButton` to ensure nothing visually breaks.

- [ ] **Task 11**: Refactor widgets to use centralized themes (incremental, widget-family by widget-family)
  - **11.1 – JJTextField refactor:**
    - Update `JJTextField` so that it:
      - Relies on `Theme.of(context).inputDecorationTheme` (or directly on `WidgetThemes.jjTextFieldTheme` if that pattern is chosen) instead of hard-coded colors/borders.
      - Keeps its public API identical (no breaking changes).
    - Run `dart analyze` and visually verify 1–2 screens that use text fields.
  
  - **11.2 – JJButton family refactor:**
    - Update `JJButton`, `JJPrimaryButton`, `JJSecondaryButton` to:
      - Use `WidgetThemes.jjPrimaryButtonStyle` / `WidgetThemes.jjSecondaryButtonStyle` (or a similar centralized approach) instead of inline styles.
    - Again, run `dart analyze` and visually verify primary button usage screens.
  
  - **11.3 – Plan (but defer) additional theme migrations:**
    - Once inputs and buttons are stable, create follow-up subtasks (not in this initial pass) for:
      - Snackbars/toasts visual theming (maybe coordinated with electrical motif work in Phase 6).
      - Dialogs and sheets.
      - Chips, tags, or any status indicators.
    - These should be added as **new tasks after Phase 6** so we don't overload the current refactor.

### Phase 5: Import Normalization (Big Bang)

- [ ] **Task 12**: Update ALL imports across codebase to use new barrels - ⚠️ Needs verification, lib/widgets/ still active
- [ ] **Task 13**: Remove conflicting exports from `lib/widgets/widgets.dart` - ⚠️ lib/widgets/ still has files
- [ ] **Task 14**: Retire `reusable_components.dart` (compatibility layer or delete) - ⚠️ Legacy files remain

### Phase 6: Visual Enhancements

- [ ] **Task 15**: Redesign job cards + locals cards (gradients, animations, data-first)
- [ ] **Task 16**: Electrical snackbar/toast backgrounds (circuit 60-70% opacity)
- [ ] **Task 17**: Animated bottom nav icons + dialog popups
- [ ] **Task 18**: Typography evaluation/update (professional, less formal)
- [ ] **Task 19**: Lightning/hurricane animations (notifications, storm nav)

### Phase 7: Documentation & Showcase

- [ ] **Task 20**: Expand `component_demo_screen.dart` → full widget gallery
- [ ] **Task 21**: Create `WIDGETS.md` (hierarchy, imports, conventions)
- [ ] **Task 22**: Dartdoc on all public widgets

### Phase 8: Validation & Polish

- [ ] **Task 23**: `flutter analyze` + `flutter test` → clean
- [ ] **Task 24**: Manual visual verification (all screens, light/dark)
- [x] **Task 25**: Update TASK.md with completion status - ✅ Completed by analysis

## EXECUTION NOTES

**Order Critical**: Phases 1-3 first (structure + duplicates), then imports (Phase 5), then visuals (Phase 6).

**Batch Size**: Do 1-2 tasks per session, test after each batch.

**Rollback**: Git commits after each phase. Barrel forwards maintain compatibility.

**Validation**: After Phase 5 imports, app must run without errors in light/dark mode.

### Safety & Process Guardrails (Do Not Skip)

1. **Always read before you write**
   - Before editing any Dart file, **open it and read the entire import block and surrounding context**.
   - Never assume the current state matches an earlier snippet or your mental model.

2. **Avoid large, blind `replace_in_file` operations**
   - Use `replace_in_file` only for **very small, surgical changes** where the exact existing text has been recently copied from the file.
   - For anything involving multiple imports or structural changes, prefer:
     - Reading the file
     - Drafting the full new content in a scratch buffer
     - Then using `write_to_file` (in ACT mode) with a fully reviewed version.

3. **Small batches + frequent `dart analyze`**
   - Limit yourself to **1–3 files** per batch of changes.
   - After each batch:
     - Run `dart analyze`.
     - Inspect new errors/warnings and ensure they're confined to the files you just touched.
   - If analyzer errors appear in unrelated areas, **stop and investigate or roll back** before continuing.

4. **Respect feature boundaries and ownership**
   - Design system widgets live under `lib/design_system/widgets/` and are exported by `design_system_widgets.dart`.
   - Electrical/visual effect widgets live under `lib/electrical_components/` and are exported by `electrical_components.dart`.
   - Legacy `lib/widgets/` content should only be touched following the per-widget migration plan in Phase 3 Task 8.

5. **One widget or concept at a time**
   - When migrating or refactoring widgets (buttons, text fields, snackbars, etc.), handle **one widget family at a time**:
     - Plan → move → fix imports → analyze → visually verify.
   - Avoid mixing unrelated changes (e.g., snackbars and job cards) in the same batch.

6. **Honor `.clinerules`**
   - `.clinerules/consider_everything.mdc`: when fixing an error in one file, consider related barrels, shared widgets, and common import patterns.
   - `.clinerules/follow-through.mdc`: after **any** Dart file modifications in ACT mode, run `dart analyze` repeatedly until all new issues in the touched area are resolved.

7. **Explicit deferral of risky areas**
   - Keep a short list of **"do not touch until planned"** items (e.g., `GenericConnectionPointWidget` migration) and honor it.
   - Add a concrete sub-plan before revisiting those areas.

## SUCCESS CRITERIA

- [ ] No duplicate widget definitions
- [ ] Single barrel import per screen (`design_system_widgets.dart` + `electrical_components.dart`)
- [ ] `flutter analyze` clean
- [ ] All screens visually consistent (light/dark)
- [ ] Job cards/locals cards enhanced
- [ ] Electrical snackbars working
- [ ] Full widget showcase in component_demo_screen

---

- *Generated from REFACTOR_PLAN.md - Execute phases sequentially*
