# JJTEXTFIELD REFACTOR

- **PROMPT**

- So, I have an issue with the custom theme widgets in my app. There are so many, in so many different places, with so many different names, and used for so many different use cases. What has caught my attention is that i wanted to optimize my codebase, make it more efficient, better importing, etc. So i learned about barrel files or imports. Then I noticed how a certain text field functioned on one of my settings screens and decided that I want all of the text fields to function just like that one. So, i has Gemini 3 implement the barrel file/import technique as well as create a custom themed `JJ_text_field` that functioned like the one in the settings screen. This is a single file widget @lib\widgets\jj_text_field.dart that has a light and dark mode theme to it and so i had Gemini 3 refactor the entire app to implement the barrel technique and use the new `JJ_text_field`. well, unbeknownst to me, i had forgotten that i already have a custom `JJtextfield` widget defined in a file that defines several other custom widgets. @lib\design_system\components\reusable_components.dart. Now my codebase is confusing and all kinds of messed up.

What i need is for you to perform a comprehensive deep dive analysis of my codebase and tell me exactly what is going one with all of the custom widgets? What do i need to do to get it under control and make sense of it all? What is and will be the best way to define, use, import, all the above the custom widgets? Meaning, should they all be defined in a single file, or should each widget be its own single file? Also, not to complicate it any furthure but somewhere in this chaos, i need to also define the app theme, dark mode, light mode, animations, functions, etc. for each widget..

## Phase Breakdown

### Task 1: Audit Widget Duplicates and Make Architectural Decisions

Perform a comprehensive audit of all custom widgets in the codebase:
Document all duplicate widgets (`JJTextField`, `JJButton`, etc.) with their locations, APIs, and usage counts
Analyze which version of each duplicate is more feature-complete and widely used
Create a decision document recommending which widgets to keep/merge/delete
Map out the proposed widget hierarchy structure under `lib/design_system/widgets/`

Relevant Files:

- `d:\Journeyman-Jobs\lib\widgets\jj_text_field.dart`
- `d:\Journeyman-Jobs\lib\widgets\jj_button.dart`
- `d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart`
- `d:\Journeyman-Jobs\lib\widgets\widgets.dart`
- `d:\Journeyman-Jobs\lib\design_system\design_system.dart`
- `d:\Journeyman-Jobs\lib\electrical_components\jj_electrical_interactive_widgets.dart`

### Task 2: Resolve JJTextField Duplicate and Consolidate Implementation

Resolve the `JJTextField` conflict by:
Keeping the version from `reusable_components.dart` (used in 28+ files)
Enhancing it with the best features from `lib/widgets/jj_text_field.dart` (floating label, theme-aware colors)
Moving the consolidated widget to `lib/design_system/widgets/inputs/jj_text_field.dart`
Deleting the duplicate in `lib/widgets/jj_text_field.dart`
Updating the barrel file `lib/widgets/widgets.dart` to remove the export

Relevant Files:

- `d:\Journeyman-Jobs\lib\widgets\jj_text_field.dart`
- `d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart`
- `d:\Journeyman-Jobs\lib\widgets\widgets.dart`
- `d:\Journeyman-Jobs\lib\design_system\app_theme.dart`

### Task 3: Consolidate Button Widgets and Establish Button Hierarchy

Consolidate all button widget duplicates:
Merge `JJButton` from `lib/widgets/jj_button.dart` and `reusable_components.dart` into a single implementation
Keep `JJPrimaryButton` and `JJSecondaryButton` as specialized variants
Move consolidated buttons to `lib/design_system/widgets/buttons/` directory
Delete duplicate button files
Update barrel files to export from new locations

Relevant Files:

- `d:\Journeyman-Jobs\lib\widgets\jj_button.dart`
- `d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart`
- `d:\Journeyman-Jobs\lib\widgets\widgets.dart`
- `d:\Journeyman-Jobs\lib\design_system\app_theme.dart`

### Task 4: Reorganize Core Widgets into Design System Structure

Reorganize all remaining core widgets from `reusable_components.dart` into the new structure:
Create directory structure: `lib/design_system/widgets/{feedback,layout,indicators}/`
Move widgets to appropriate directories: `JJCard`, `JJBottomSheet`, `JJLoadingIndicator`, `JJProgressIndicator`, `JJChip`, `JJEmptyState`, `JJSnackBar`, `JJElectricalDialog`, etc.
Each widget gets its own file
Delete the monolithic `reusable_components.dart` file
Create comprehensive barrel file at `lib/design_system/widgets/design_system.dart`

Relevant Files:

- `d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart`
- `d:\Journeyman-Jobs\lib\design_system\design_system.dart`
- `d:\Journeyman-Jobs\lib\design_system\app_theme.dart`

### Task 5: Update All Import Statements Across the Codebase

Update all import statements throughout the codebase:
Replace imports from `reusable_components.dart` with new barrel file imports
Update imports from `lib/widgets/widgets.dart` to use `lib/design_system/widgets/design_system.dart`
Ensure all 28+ files using `JJTextField` import from the correct location
Update all files using buttons, cards, and other reorganized widgets
Run tests to verify no import errors

Relevant Files:

- `d:\Journeyman-Jobs\lib\screens\settings\support\feedback_screen.dart`
- `d:\Journeyman-Jobs\lib\screens\settings\account\profile_screen.dart`
- `d:\Journeyman-Jobs\lib\screens\onboarding\auth_screen.dart`
- `d:\Journeyman-Jobs\lib\screens\storm\widgets\storm_track_form.dart`
- `d:\Journeyman-Jobs\lib\screens\tools\electrical_calculators_screen.dart`
- `d:\Journeyman-Jobs\lib\widgets\notification_popup.dart`
- `d:\Journeyman-Jobs\lib\services\notification_permission_service.dart`

### Task 6: Create Centralized Widget Theme System

Centralize widget theming to eliminate duplicate theme logic:
Create `lib/design_system/theme/widget_themes.dart` with centralized theme definitions
Define `InputDecorationTheme`, `ButtonThemeData`, `CardTheme`, etc.
Refactor all widgets to use centralized themes instead of inline theme logic
Update `app_theme.dart` to integrate widget themes
Ensure light/dark mode support is consistent across all widgets

Relevant Files:

- `d:\Journeyman-Jobs\lib\design_system\app_theme.dart`
- `d:\Journeyman-Jobs\lib\design_system\theme_light.dart`
- `d:\Journeyman-Jobs\lib\design_system\theme_dark.dart`
- `d:\Journeyman-Jobs\lib\design_system\widgets\inputs\jj_text_field.dart`
- `d:\Journeyman-Jobs\lib\design_system\widgets\buttons\jj_button.dart`

### Task 7: Organize Electrical Components and Establish Naming Conventions

Organize electrical components into a clear hierarchy:
Create subdirectories: `lib/electrical_components/{animated,specialized}/`
Move animated widgets (`JJElectricalButton`, `JJElectricalTextField`, `JJElectricalDropdown`) to `animated/`
Move specialized widgets (`JJCircuitBreakerSwitch`, `JJTransformerTrainer`) to `specialized/`
Update `electrical_components.dart` barrel file
Document when to use base widgets vs. electrical variants

Relevant Files:

- `d:\Journeyman-Jobs\lib\electrical_components\jj_electrical_interactive_widgets.dart`
- `d:\Journeyman-Jobs\lib\electrical_components\jj_circuit_breaker_switch.dart`
- `d:\Journeyman-Jobs\lib\electrical_components\jj_transformer_trainer.dart`
- `d:\Journeyman-Jobs\lib\electrical_components\electrical_components.dart`
- `d:\Journeyman-Jobs\lib\electrical_components\jj_electrical_theme.dart`

### Task 8: Create Comprehensive Widget Documentation and Showcase

Create comprehensive documentation for the widget system:
Expand `component_demo_screen.dart` into a complete widget showcase with all widgets
Create a `WIDGETS.md` documentation file explaining the widget hierarchy
Add dartdoc comments to all widget classes with usage examples
Document naming conventions (JJ vs. JJElectrical vs. specialized variants)
Create import guidelines and best practices document

Relevant Files:

- `d:\Journeyman-Jobs\lib\screens\component_demo_screen.dart`
- `d:\Journeyman-Jobs\lib\design_system\widgets\design_system.dart`
- `d:\Journeyman-Jobs\lib\electrical_components\electrical_components.dart`

---

I have the following comments after thorough review of file. Implement the comments by following the instructions verbatim.

---

## Comment 1: `JJTextField` is defined twice with different APIs and behavior, creating naming collisions and inconsistent usage across screens

- In `lib/design_system/components/reusable_components.dart`, keep `JJTextField` as the canonical implementation and extend it with any behavior you want from `lib/widgets/jj_text_field.dart` (e.g., floating labels and brightness-based border colors), preserving the existing `label`/`hintText`/prefix/suffix API so current call sites remain valid.
- **Delete** or deprecate the duplicate `JJTextField` class from `lib/widgets/jj_text_field.dart`, replacing it with either a wrapper that simply re-exports or delegates to `lib/design_system/components/reusable_components.dart`'s `JJTextField`, or with a typedef pointing to the canonical class.
- **Move** the canonical `JJTextField` into a new file `lib/design_system/widgets/inputs/jj_text_field.dart`, update internal imports to use this new path (via a new `lib/design_system/widgets/design_system_widgets.dart` barrel), and remove the `export 'jj_text_field.dart';` line from `lib/widgets/widgets.dart` so the widgets barrel no longer exposes its own conflicting `JJTextField`.

### Relevant Files

- d:\Journeyman-Jobs\lib\widgets\jj_text_field.dart
- d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart
- d:\Journeyman-Jobs\lib\widgets\widgets.dart

---

## Comment 2: `JJButton` exists in both `widgets` and design system with diverging styles, enums, and usage, fragmenting the button API

- **Designate** the button definitions in `lib/design_system/components/reusable_components.dart` (`JJButton`, `JJPrimaryButton`, `JJSecondaryButton`, `JJButtonVariant`, `JJButtonSize`) as the single source of truth and, if necessary, copy or adapt any desirable styling logic from `lib/widgets/jj_button.dart` into this implementation.
- **Delete** or deprecate the `JJButton` class and its associated enums from `lib/widgets/jj_button.dart`, and update any screens currently importing `package:journeyman_jobs/widgets/jj_button.dart` or relying on `../widgets/widgets.dart` exports (such as `HomeScreen` and `ComponentDemoScreen`) to import and use the design-system `JJButton` or `JJPrimaryButton` from a new file `lib/design_system/widgets/buttons/jj_button.dart` instead.
- **Create** a new `lib/design_system/widgets/buttons/` directory, move the canonical button widgets into separate files there, add them to a new `lib/design_system/widgets/design_system_widgets.dart` barrel, and ensure all call sites throughout the app import buttons from this barrel rather than from `reusable_components.dart` or `lib/widgets/jj_button.dart`.

### Relevant Files

- d:\Journeyman-Jobs\lib\widgets\jj_button.dart
- d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart
- d:\Journeyman-Jobs\lib\widgets\widgets.dart
- d:\Journeyman-Jobs\lib\screens\home\home_screen.dart
- d:\Journeyman-Jobs\lib\screens\component_demo_screen.dart

---

## Comment 3: `JJPowerLineLoader` and `JJSnackBar` are each implemented twice, splitting responsibility between design system and electrical components

- **Compare** the two `JJPowerLineLoader` implementations in `lib/design_system/components/reusable_components.dart` and `lib/electrical_components/jj_power_line_loader.dart`, choose the more complete electrical implementation as canonical, and expose it from a single location (for example, `lib/electrical_components/jj_power_line_loader.dart`) while changing the design-system reference to be a simple re-export or wrapper that forwards to the canonical class.
- Similarly, consolidate the two `JJSnackBar` helper classes by either promoting the electrical implementation in `lib/electrical_components/jj_snack_bar.dart` into the design system (and deleting the class in `lib/design_system/components/reusable_components.dart`), or by renaming one of them (for example, to `JJAppSnackBar`) so that there is no shared class name with diverging behavior.
- **Update** all call sites across the app that reference `JJPowerLineLoader` and `JJSnackBar` to import them from the chosen canonical module or design-system barrel, and remove any direct imports that reference the now-deprecated duplicate definitions.

### Relevant Files

- d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart
- d:\Journeyman-Jobs\lib\electrical_components\jj_power_line_loader.dart
- d:\Journeyman-Jobs\lib\electrical_components\jj_snack_bar.dart

---

## Comment 4: `reusable_components.dart` mixes many unrelated widgets into one monolithic file, hurting discoverability, cohesion, and refactorability

Create a new `lib/design_system/widgets/` directory and split the contents of `lib/design_system/components/reusable_components.dart` into smaller, focused files grouped by widget category (for example, move `JJButton`/`JJPrimaryButton`/`JJSecondaryButton` into `lib/design_system/widgets/buttons/jj_button.dart`, `JJTextField` into `lib/design_system/widgets/inputs/jj_text_field.dart`, cards and bottom sheets into `lib/design_system/widgets/layout/`, chips and progress indicators into `lib/design_system/widgets/indicators/`, and empty states and snackbars into `lib/design_system/widgets/feedback/`).
For any electrical-themed widgets currently defined in `reusable_components.dart` (such as `JJElectricalLoader`, `JJPowerLineLoader` wrapper, `JJElectricalToggle`, `JJElectricalIcons`, `JJElectricalDialog`), either move them fully into the existing `lib/electrical_components/` hierarchy or into a dedicated `lib/design_system/widgets/electrical/` subdirectory with names and documentation that make their purpose explicit.
Once the components are migrated, replace most direct imports of `lib/design_system/components/reusable_components.dart` with imports from a new barrel file (for example, `lib/design_system/widgets/design_system_widgets.dart`) that re-exports the category-specific widget files, and gradually retire `reusable_components.dart` or leave it as a thin compatibility layer that forwards to the new structure.

### Relevant Files

- d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart

---

## Comment 5: Widget imports are inconsistent across modules, using multiple barrels and direct paths, obscuring which widget source is authoritative

Create a new design-system widgets barrel file (for example, `lib/design_system/widgets/design_system_widgets.dart`) that re-exports all canonical core UI widgets from their new locations under `lib/design_system/widgets/` (buttons, text fields, cards, chips, bottom sheets, progress indicators, empty states, and so on).
Create or standardize an electrical-components barrel (you already have `lib/electrical_components/electrical_components.dart`) and ensure all electrical-themed widgets, loaders, and toasts are exported from this single entrypoint rather than being imported directly by file path from various screens.
Update screen and service files to stop importing core widgets directly from `lib/widgets/` or from `lib/design_system/components/reusable_components.dart`, and instead import exclusively from the design-system and electrical barrels; as part of this change, remove any redundant or conflicting exports from `lib/widgets/widgets.dart` that duplicate design-system primitives (such as `JJTextField` and `JJButton`).

### Relevant Files

- d:\Journeyman-Jobs\lib\widgets\widgets.dart
- d:\Journeyman-Jobs\lib\design_system\design_system.dart
- d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart
- d:\Journeyman-Jobs\lib\electrical_components\electrical_components.dart
- d:\Journeyman-Jobs\lib\screens\component_demo_screen.dart
- d:\Journeyman-Jobs\lib\screens\home\home_screen.dart

---

## Comment 6: Design system lacks an explicit `lib/design_system/widgets/` hierarchy; proposing a structured tree will stabilize widget ownership and evolution

Create the directory structure `lib/design_system/widgets/buttons`, `lib/design_system/widgets/inputs`, `lib/design_system/widgets/layout`, `lib/design_system/widgets/indicators`, and `lib/design_system/widgets/feedback`, and move each corresponding widget from `lib/design_system/components/reusable_components.dart` into its own appropriately named file under these directories, preserving all public APIs.
Add a new barrel file (for example, `lib/design_system/widgets/design_system_widgets.dart`) that exports each of these category files so application code can import a single module for all core UI widgets; at the same time, ensure electrical-themed widgets remain under `lib/electrical_components/` and are exported via `lib/electrical_components/electrical_components.dart` only.
Update all existing imports across the app that previously pointed to `lib/design_system/components/reusable_components.dart` to instead point to the new `lib/design_system/widgets/design_system_widgets.dart` barrel (or, in special cases, to the specific new widget file), and remove any lingering references to the old monolithic file once migration is complete.

### Relevant Files

- d:\Journeyman-Jobs\lib\design_system\components\reusable_components.dart
- d:\Journeyman-Jobs\lib\design_system\design_system.dart
- d:\Journeyman-Jobs\lib\electrical_components\electrical_components.dart

---
