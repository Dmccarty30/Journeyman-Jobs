# Task Title: Create User Job Preferences Model and Update User Model

**Description:**
Create `UserJobPreferences` model to structure user's job search preferences and add `hasSetJobPreferences` flag to track first-time setup completion.

**Report Context:**

- Section: Implementation Strategy - 2. Create User Job Preferences System
- Requirements: "Create `UserJobPreferences` model to structure preference data" and "Add `hasSetPreferences` flag to UserModel to track first-time setup"
- Technical Details: "Define fields matching the preferences collected in onboarding step 3:
  - `List<String> classifications` - preferred job classifications
  - `List<String> constructionTypes` - types of construction work
  - `List<int> preferredLocals` - preferred IBEW local numbers
  - `String? hoursPerWeek` - desired hours (e.g., '40-50', '50-60')
  - `String? perDiemRequirement` - per diem range (e.g., '$100-$150')
  - `double? minWage` - minimum acceptable wage
  - `int? maxDistance` - maximum distance willing to travel"

**Technical Implementation:**

- Platform: Flutter/Dart with Firebase Firestore
- Key Components: New `lib/models/user_job_preferences.dart` file, modify `lib/models/user_model.dart`
- Dependencies: Reference `CrewPreferencesDialog` structure and onboarding step 3 collections

**Validation Criteria:**

- [ ] UserJobPreferences model with all required fields (classifications, constructionTypes, preferredLocals, hoursPerWeek, perDiemRequirement, minWage, maxDistance)
- [ ] UserJobPreferences includes fromJson(), toJson(), empty(), copyWith(), and toFilterCriteria() methods
- [ ] UserJobPreferences annotated with @immutable
- [ ] UserModel includes bool hasSetJobPreferences field (default: false)
- [ ] UserModel constructors and serialization methods updated to include hasSetJobPreferences

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Task Title: Create User Preferences Riverpod Provider

**Description:**
Create Riverpod provider to manage user job preferences state with Firestore integration for loading, saving, and updating preferences.

**Report Context:**

- Section: Proposed File Changes - lib\providers\riverpod\user_preferences_provider.dart(NEW)
- Requirements: "Create Riverpod provider to manage preferences state" with methods for build(), loadPreferences(), savePreferences(), updatePreferences(), clearError()
- Technical Details: "Store preferences as a nested map field `jobPreferences` in the user document. When saving for the first time, also set `hasSetJobPreferences: true` in the user document"

**Technical Implementation:**

- Platform: Flutter with Riverpod and Firebase Firestore
- Key Components: New `lib/providers/riverpod/user_preferences_provider.dart` with UserPreferencesState and UserPreferencesNotifier
- Dependencies: UserJobPreferences model, auth and jobs Riverpod provider patterns

**Validation Criteria:**

- [ ] UserPreferencesState class with preferences, isLoading, error fields and copyWith method
- [ ] UserPreferencesNotifier with build(), loadPreferences(), savePreferences(), updatePreferences(), clearError() methods
- [ ] Provider uses @riverpod annotation for code generation
- [ ] Preferences stored as 'jobPreferences' field in user document
- [ ] savePreferences() sets hasSetJobPreferences=true on first save

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

## Task Title: Create User Job Preferences Dialog

**Description:**
Create dialog widget for users to set/update job preferences with form fields for classifications, construction types, locals, hours, per diem, wage, and distance.

**Report Context:**

- Section: Proposed File Changes - lib\widgets\dialogs\user_job_preferences_dialog.dart(NEW)
- Requirements: "Create `UserJobPreferencesDialog` widget" with form sections for "Classifications, Construction Types, Preferred Locals, Hours Per Week, Per Diem, Minimum Wage, Maximum Distance"
- Technical Details: "Following the design pattern of c:/Users/david/Desktop/Journeyman-Jobs/lib/features/crews/widgets/crew_preferences_dialog.dart"

**Technical Implementation:**

- Platform: Flutter with Material Design
- Key Components: StatefulWidget with electrical theme styling, multi-select chips, dropdowns, text fields
- Dependencies: JJTextField, JJChip components, jobPreferencesProvider, electrical design system

**Validation Criteria:**

- [ ] StatefulWidget accepting initialPreferences, userId, isFirstTime parameters
- [ ] Electrical theme styling with gradient header and themed footer buttons
- [ ] Form sections for all preference types (classifications chips, construction types chips, locals text field, hours dropdown, per diem dropdown, wage text field, distance text field)
- [ ] Save logic validates forms, calls provider savePreferences/updatePreferences, shows success snackbar
- [ ] Dialog properly closes after successful save

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

## Task Title: Fix Missing Data Display in Job Cards [P]

**Description:**
Add fallback logic to CondensedJobCard to check jobDetails map when direct Job fields are null, ensuring all available data is displayed.

**Report Context:**

- Section: Implementation Strategy - 1. Fix Missing Data in Job Cards
- Requirements: "Add fallback logic in `CondensedJobCard` to check `jobDetails` map when direct fields are null"
- Technical Details: "In the wage display (line 91), add fallback: if `job.wage` is null, try `job.jobDetails['payRate']`. In the hours display (line 101), add fallback: if `job.hours` is null, try `job.jobDetails['hours']`. In the per diem display (line 110), add fallback: if `job.perDiem` is null, try `job.jobDetails['perDiem']`"

**Technical Implementation:**

- Platform: Flutter/Dart
- Key Components: Modify `lib/widgets/condensed_job_card.dart` lines 91, 101, 110
- Dependencies: Job model with jobDetails map structure, JobDataFormatter

**Validation Criteria:**

- [ ] Wage display checks jobDetails['payRate'] fallback when job.wage is null
- [ ] Hours display checks jobDetails['hours'] fallback when job.hours is null
- [ ] Per diem display checks jobDetails['perDiem'] fallback when job.perDiem is null
- [ ] Job cards display available data from jobDetails when direct fields are null

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Task Title: Integrate Preferences into Home Screen

**Description:**
Modify home screen to show "Set Preferences" button for new users and load personalized jobs based on user preferences.

**Report Context:**

- Section: Proposed File Changes - lib\screens\home\home_screen.dart(MODIFY)
- Requirements: "Show "Set Preferences" button in home screen when `hasSetPreferences` is false" and "Load Personalized Jobs" using JobFilterCriteria from user preferences
- Technical Details: "After saving, set `hasSetPreferences` to true and hide button permanently", "Call `jobsProvider.loadJobs(filter: filterCriteria)` instead of `jobsProvider.loadJobs()`"

**Technical Implementation:**

- Platform: Flutter with Riverpod state management
- Key Components: Modify home_screen.dart to watch userPreferencesProvider and authProvider, add preferences button, modify job loading logic
- Dependencies: UserJobPreferencesDialog, userPreferencesProvider, jobsProvider, JobFilterCriteria conversion

**Validation Criteria:**

- [ ] "Set Preferences" button shows when hasSetJobPreferences is false
- [ ] Button opens UserJobPreferencesDialog with isFirstTime=true
- [ ] Job loading uses JobFilterCriteria from user preferences when available
- [ ] Button hides permanently after successful preference setting
- [ ] Jobs refresh with new filters when preferences change

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

## Task Title: Add Job Preferences to Settings Screen

**Description:**
Add "Job Preferences" menu item to settings screen allowing users to view and update their preferences anytime.

**Report Context:**

- Section: Implementation Strategy - 5. Add Preferences Management to Settings
- Requirements: "Add "Job Preferences" menu item in settings screen" and "Allow users to view and update their preferences anytime"
- Technical Details: "Add a new `_MenuOption` after "Training & Certificates" with Icon: `Icons.tune_outlined`, Title: 'Job Preferences'"

**Technical Implementation:**

- Platform: Flutter with Riverpod providers
- Key Components: Modify settings_screen.dart to add menu item and handle dialog opening, convert to ConsumerStatefulWidget
- Dependencies: UserJobPreferencesDialog, userPreferencesProvider, FirebaseAuth currentUser

**Validation Criteria:**

- [ ] New menu item "Job Preferences" added to settings screen
- [ ] Menu item opens UserJobPreferencesDialog with existing preferences pre-filled
- [ ] Dialog opens with isFirstTime=false
- [ ] Settings screen converted to ConsumerStatefulWidget to access providers
- [ ] Success message shown after preference updates

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

## Task Title: Initialize Preferences from Onboarding

**Description:**
Update onboarding completion to initialize user job preferences from collected onboarding data and set hasSetJobPreferences flag.

**Report Context:**

- Section: Proposed File Changes - lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)
- Requirements: "Initialize Job Preferences from Onboarding" by mapping onboarding step 3 data to UserJobPreferences
- Technical Details: "Map `_selectedConstructionTypes` to `constructionTypes`, Map `_selectedHoursPerWeek` to `hoursPerWeek`, Map `_selectedPerDiem` to `perDiemRequirement`, Parse `_preferredLocalsController.text` to extract local numbers"

**Technical Implementation:**

- Platform: Flutter with Riverpod and Firebase
- Key Components: Modify onboarding_steps_screen.dart _completeOnboarding method to save UserJobPreferences
- Dependencies: UserJobPreferences model, userPreferencesProvider, onboarding data structures

**Validation Criteria:**

- [ ] Onboarding preference data (_selectedConstructionTypes,_selectedHoursPerWeek, _selectedPerDiem,_preferredLocalsController) mapped to UserJobPreferences
- [ ] UserJobPreferences saved using userPreferencesProvider.savePreferences()
- [ ] hasSetJobPreferences automatically set to true during onboarding
- [ ] Error handling for preference saving (doesn't block onboarding completion)
- [ ] Users completing onboarding won't see "Set Preferences" button

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Moderate

## Task Title: Generate Riverpod Provider Code

**Description:**
Run build_runner to generate the auto-generated Riverpod code for the user preferences provider.

**Report Context:**

- Section: Proposed File Changes - lib\providers\riverpod\user_preferences_provider.g.dart(NEW)
- Requirements: "Generated Riverpod Code" created by running "flutter pub run build_runner build"
- Technical Details: "This file will be auto-generated by running `flutter pub run build_runner build` after creating user_preferences_provider.dart"

**Technical Implementation:**

- Platform: Flutter with build_runner code generation
- Key Components: Generate user_preferences_provider.g.dart with Riverpod annotations
- Dependencies: user_preferences_provider.dart must exist first

**Validation Criteria:**

- [ ] build_runner build command executed successfully
- [ ] user_preferences_provider.g.dart file generated in lib/providers/riverpod/
- [ ] No compilation errors in generated code
- [ ] Riverpod provider functions properly with generated code

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple

**Report Context:**

- Section: Proposed File Changes - lib\providers\riverpod\user_preferences_provider.g.dart(NEW)
- Requirements: "Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `user_preferences_provider.g.dart`."

**Technical Implementation:**

- Platform: Flutter build system
- Key Components: build_runner code generation for Riverpod provider
- Dependencies: user_preferences_provider.dart file

**Validation Criteria:**

- [ ] build_runner command executed without errors
- [ ] _UserPreferencesNotifier generated correctly
- [ ] Provider works with auto-generated code

**Assigned Agent:** flutter-expert

**Estimated Complexity:** Simple
