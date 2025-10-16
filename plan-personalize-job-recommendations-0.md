# HOME SCREEN JOB CARD PREFERENCES

## Current State Analysis

**Missing Data Issue:**

- `CondensedJobCard` accesses Job fields directly (`job.wage`, `job.hours`, `job.perDiem`)
- `Job.fromJson()` has complex parsing logic with fallbacks, but can still result in null values
- Some data exists in the nested `jobDetails` map but isn't accessed by the card
- `JobDataFormatter` methods return 'N/A' for null/empty values, which is working correctly

**Personalization Gap:**

- No user-specific job preferences model or storage
- Jobs load without any filtering based on user preferences
- Onboarding step 3 collects preferences but they're stored as flat fields in UserModel
- No mechanism to track if user has set preferences for the first time
- Settings screen has no preferences management section

**Existing Infrastructure:**

- `JobFilterCriteria` model supports filtering by classifications, locals, construction types, per diem, etc.
- `jobsProvider.applyFilter()` can apply filters to job queries
- `CrewPreferencesDialog` provides a good template for building a user preferences dialog
- UserModel has some preference fields but they're not structured or used for filtering
- FirestoreService has a `preferencesCollection` reference but it's unused

### Approach

## Implementation Strategy

**1. Fix Missing Data in Job Cards**
Add fallback logic in `CondensedJobCard` to check `jobDetails` map when direct fields are null, ensuring all available data is displayed.

- **2. Create User Job Preferences System**

- Create `UserJobPreferences` model to structure preference data
- Create Riverpod provider to manage preferences state
- Add `hasSetPreferences` flag to UserModel to track first-time setup

- **3. Implement "Set Preferences" Dialog**

- Create `UserJobPreferencesDialog` widget (similar to `CrewPreferencesDialog`)
- Show "Set Preferences" button in home screen when `hasSetPreferences` is false
- Dialog collects: classifications, construction types, locals, hours, per diem, wage range
- After saving, set `hasSetPreferences` to true and hide button permanently

- **4. Integrate Preferences with Job Loading**

- Convert user preferences to `JobFilterCriteria` when loading suggested jobs
- Modify home screen to load filtered jobs based on preferences
- Maintain the existing 5-job display limit

- **5. Add Preferences Management to Settings**

- Add "Job Preferences" menu item in settings screen
- Allow users to view and update their preferences anytime
- Reuse the same preferences dialog

### Reasoning

Started by reading the Home-Analysis.md document which identified the missing data issue and lack of personalization. Explored the home screen, job model, condensed job card, user model, and jobs provider to understand current implementation. Examined the onboarding flow to see what preferences are collected. Reviewed the crew preferences dialog as a template for the user preferences dialog. Checked firestore service and existing preference-related code to understand storage patterns.

## Mermaid Diagram

sequenceDiagram
    participant User
    participant HomeScreen
    participant PreferencesDialog
    participant PreferencesProvider
    participant Firestore
    participant JobsProvider

    Note over User,JobsProvider: First-Time User Flow
    
    User->>HomeScreen: Opens app after onboarding
    HomeScreen->>Firestore: Check hasSetJobPreferences flag
    Firestore-->>HomeScreen: false (not set)
    HomeScreen->>User: Show "Set Preferences" button
    User->>HomeScreen: Clicks "Set Preferences"
    HomeScreen->>PreferencesDialog: Open dialog (isFirstTime: true)
    User->>PreferencesDialog: Selects preferences (classifications, types, etc.)
    User->>PreferencesDialog: Clicks "Save"
    PreferencesDialog->>PreferencesProvider: savePreferences(userId, preferences)
    PreferencesProvider->>Firestore: Save preferences + set hasSetJobPreferences=true
    Firestore-->>PreferencesProvider: Success
    PreferencesProvider->>PreferencesDialog: Preferences saved
    PreferencesDialog->>HomeScreen: Close dialog (success)
    HomeScreen->>PreferencesProvider: Get saved preferences
    PreferencesProvider->>HomeScreen: Return UserJobPreferences
    HomeScreen->>HomeScreen: Convert to JobFilterCriteria
    HomeScreen->>JobsProvider: loadJobs(filter: criteria)
    JobsProvider->>Firestore: Query jobs with filters
    Firestore-->>JobsProvider: Filtered jobs
    JobsProvider-->>HomeScreen: Display 5 personalized jobs
    HomeScreen->>User: Show jobs (button hidden)

    Note over User,JobsProvider: Returning User Flow
    
    User->>HomeScreen: Opens app again
    HomeScreen->>Firestore: Check hasSetJobPreferences flag
    Firestore-->>HomeScreen: true (already set)
    HomeScreen->>PreferencesProvider: Load preferences
    PreferencesProvider->>Firestore: Fetch jobPreferences
    Firestore-->>PreferencesProvider: Return preferences
    PreferencesProvider-->>HomeScreen: UserJobPreferences
    HomeScreen->>JobsProvider: loadJobs(filter: criteria)
    JobsProvider-->>HomeScreen: Personalized jobs
    HomeScreen->>User: Show jobs (no button)

    Note over User,JobsProvider: Update Preferences from Settings
    
    User->>HomeScreen: Navigate to Settings
    HomeScreen->>User: Show settings menu
    User->>PreferencesDialog: Click "Job Preferences"
    PreferencesDialog->>PreferencesProvider: Load current preferences
    PreferencesProvider-->>PreferencesDialog: Show existing preferences
    User->>PreferencesDialog: Update preferences
    PreferencesDialog->>PreferencesProvider: updatePreferences(userId, newPreferences)
    PreferencesProvider->>Firestore: Update jobPreferences
    Firestore-->>PreferencesProvider: Success
    PreferencesProvider->>HomeScreen: Trigger refresh
    HomeScreen->>JobsProvider: loadJobs(filter: newCriteria)
    JobsProvider-->>HomeScreen: Updated personalized jobs

## Proposed File Changes

### lib\widgets\condensed_job_card.dart(MODIFY)

References:

- lib\models\job_model.dart
- docs\Home-Analysis.md

- **Fix Missing Data Display**

Add fallback logic to access data from the `jobDetails` map when direct Job fields are null:

1. In the wage display (line 91), add fallback: if `job.wage` is null, try `job.jobDetails['payRate']`
2. In the hours display (line 101), add fallback: if `job.hours` is null, try `job.jobDetails['hours']`
3. In the per diem display (line 110), add fallback: if `job.perDiem` is null, try `job.jobDetails['perDiem']`

This ensures that data stored in the nested `jobDetails` map is displayed when the direct fields are null, addressing the missing data issue identified in `c:/Users/david/Desktop/Journeyman-Jobs/docs/Home-Analysis.md`.

- **Implementation Tasks**

- [ ] **Fix Missing Data in Job Cards:**
  - [ ] Update the wage display to fall back to `job.jobDetails['payRate']` if `job.wage` is null.
  - [ ] Update the hours display to fall back to `job.jobDetails['hours']` if `job.hours` is null.
  - [ ] Update the per diem display to fall back to `job.jobDetails['perDiem']` if `job.perDiem` is null.

### lib\models\user_job_preferences.dart(NEW)

References:

- lib\features\crews\models\crew_preferences.dart
- lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)
- lib\models\filter_criteria.dart

- **Create User Job Preferences Model**

Create a new model class `UserJobPreferences` to structure user's job search preferences:

1. Define fields matching the preferences collected in onboarding step 3:
   - `List<String> classifications` - preferred job classifications
   - `List<String> constructionTypes` - types of construction work
   - `List<int> preferredLocals` - preferred IBEW local numbers
   - `String? hoursPerWeek` - desired hours (e.g., '40-50', '50-60')
   - `String? perDiemRequirement` - per diem range (e.g., '$100-$150')
   - `double? minWage` - minimum acceptable wage
   - `int? maxDistance` - maximum distance willing to travel

2. Include methods:
   - `factory UserJobPreferences.fromJson(Map<String, dynamic> json)` - parse from Firestore
   - `Map<String, dynamic> toJson()` - convert to Firestore format
   - `factory UserJobPreferences.empty()` - create empty preferences
   - `copyWith()` - create modified copy
   - `JobFilterCriteria toFilterCriteria()` - convert to filter criteria for job queries

3. Make the class immutable using `@immutable` annotation

Reference the structure used in `c:/Users/david/Desktop/Journeyman-Jobs/lib/features/crews/models/crew_preferences.dart` and the preferences collected in `c:/Users/david/Desktop/Journeyman-Jobs/lib/screens/onboarding/onboarding_steps_screen.dart` (lines 893-1168).

- **Implementation Tasks**

- [ ] **Create User Job Preferences Model:**
  - [ ] Define the `UserJobPreferences` class with fields for `classifications`, `constructionTypes`, `preferredLocals`, `hoursPerWeek`, `perDiemRequirement`, `minWage`, and `maxDistance`.
  - [ ] Add `fromJson`, `toJson`, `empty`, `copyWith`, and `toFilterCriteria` methods to the class.
  - [ ] Annotate the class with `@immutable`.

### lib\models\user_model.dart(MODIFY)

- **Add Preferences Tracking Flag**

Add a new field to track whether the user has set their job preferences:

1. Add field `bool hasSetJobPreferences` (default: false) to the UserModel class
2. Update the constructor to include this field
3. Update `fromFirestore()` factory to parse this field from Firestore data
4. Update `fromJson()` factory to parse this field from JSON
5. Update `toJson()` method to include this field
6. Update `toFirestore()` method to include this field

This flag will be used to determine whether to show the "Set Preferences" button on the home screen. Once set to true, the button will never appear again.

- **Implementation Tasks**

- [ ] **Update User Model:**
  - [ ] Add a `hasSetJobPreferences` boolean field (defaulting to `false`).
  - [ ] Update the constructor, `fromFirestore`, `fromJson`, `toJson`, and `toFirestore` methods to include the new flag.

### lib\providers\riverpod\user_preferences_provider.dart(NEW)

References:

- lib\providers\riverpod\jobs_riverpod_provider.dart
- lib\providers\riverpod\auth_riverpod_provider.dart
- lib\models\user_job_preferences.dart(NEW)

- **Create User Preferences Riverpod Provider**

Create a Riverpod provider to manage user job preferences state:

1. Create `UserPreferencesState` class with:
   - `UserJobPreferences? preferences` - current preferences
   - `bool isLoading` - loading state
   - `String? error` - error message
   - `copyWith()` method

2. Create `UserPreferencesNotifier` extending `_$UserPreferencesNotifier`:
   - `build()` - initialize state and load preferences from Firestore
   - `loadPreferences(String userId)` - fetch preferences from Firestore users/{userId} document
   - `savePreferences(String userId, UserJobPreferences preferences)` - save to Firestore and update `hasSetJobPreferences` flag
   - `updatePreferences(String userId, UserJobPreferences preferences)` - update existing preferences
   - `clearError()` - clear error state

3. Use `@riverpod` annotation for code generation
4. Access FirebaseFirestore via `FirebaseFirestore.instance`
5. Store preferences as a nested map field `jobPreferences` in the user document
6. When saving for the first time, also set `hasSetJobPreferences: true` in the user document

Reference the pattern used in `c:/Users/david/Desktop/Journeyman-Jobs/lib/providers/riverpod/jobs_riverpod_provider.dart` and `c:/Users/david/Desktop/Journeyman-Jobs/lib/providers/riverpod/auth_riverpod_provider.dart`.

- **Implementation Tasks**

- [ ] **Create Preferences State Provider:**
  - [ ] Define `UserPreferencesState` to manage `preferences`, `isLoading`, and `error`.
  - [ ] Create `UserPreferencesNotifier` to handle loading, saving, and updating preferences in Firestore.
  - [ ] Ensure the provider updates the `hasSetJobPreferences` flag in the user document when preferences are saved for the first time.

### lib\widgets\dialogs\user_job_preferences_dialog.dart(NEW)

References:

- lib\features\crews\widgets\crew_preferences_dialog.dart
- lib\widgets\dialogs\job_details_dialog.dart
- lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)
- lib\design_system\components\reusable_components.dart
- lib\design_system\app_theme.dart

- **Create User Job Preferences Dialog**

Create a dialog widget for users to set/update their job preferences, following the design pattern of `c:/Users/david/Desktop/Journeyman-Jobs/lib/features/crews/widgets/crew_preferences_dialog.dart`:

1. Create `UserJobPreferencesDialog` StatefulWidget accepting:
   - `UserJobPreferences? initialPreferences` - existing preferences or null for first-time
   - `String userId` - current user ID
   - `bool isFirstTime` - whether this is initial setup (default: false)

2. Build dialog with electrical theme styling matching `c:/Users/david/Desktop/Journeyman-Jobs/lib/widgets/dialogs/job_details_dialog.dart`:
   - Header with gradient background, title, and close button
   - Scrollable content area with form sections
   - Footer with Cancel and Save buttons

3. Include form sections (similar to onboarding step 3 in `c:/Users/david/Desktop/Journeyman-Jobs/lib/screens/onboarding/onboarding_steps_screen.dart`):
   - **Classifications**: Multi-select chips for job classifications (Journeyman, Foreman, General Foreman, etc.)
   - **Construction Types**: Multi-select chips using the same list from onboarding (Commercial, Industrial, Residential, etc.)
   - **Preferred Locals**: Text field for comma-separated local numbers
   - **Hours Per Week**: Dropdown with options ('40-50', '50-60', '60-70', '>70')
   - **Per Diem**: Dropdown with ranges ('$100-$150', '$150-$200', '$200-$250', '$250-$300', 'Not Required')
   - **Minimum Wage**: Text field with number input and dollar sign prefix
   - **Maximum Distance**: Text field for miles willing to travel

4. On save:
   - Validate form inputs
   - Create `UserJobPreferences` object from form data
   - Call `userPreferencesProvider.savePreferences()` or `updatePreferences()`
   - Show success snackbar using `JJSnackBar.showSuccess()` from `c:/Users/david/Desktop/Journeyman-Jobs/lib/design_system/components/reusable_components.dart`
   - Close dialog and return true to indicate success

5. Use `JJTextField`, `JJChip`, and other components from `c:/Users/david/Desktop/Journeyman-Jobs/lib/design_system/components/reusable_components.dart` for consistency

- **Implementation Tasks**

- [ ] **Create Preferences Dialog:**
  - [ ] Build the `UserJobPreferencesDialog` widget, accepting `initialPreferences`, `userId`, and `isFirstTime`.
  - [ ] Design the UI with a themed header, scrollable form, and footer buttons.
  - [ ] Add form fields for all preferences (classifications, construction types, locals, etc.).
  - [ ] Implement the save logic to call the `userPreferencesProvider` and show a success message.

### lib\screens\home\home_screen.dart(MODIFY)

References:

- lib\providers\riverpod\user_preferences_provider.dart(NEW)
- lib\widgets\dialogs\user_job_preferences_dialog.dart(NEW)
- lib\models\user_job_preferences.dart(NEW)
- lib\providers\riverpod\jobs_riverpod_provider.dart

- **Integrate Preferences into Home Screen**

Modify the home screen to show the "Set Preferences" button and load personalized jobs:

1. **Add Providers**: Import and watch `userPreferencesProvider` and get current user from `authProvider`

2. **Add "Set Preferences" Button** (around line 232, after "Suggested Jobs" header):
   - Watch `authProvider` to get current user
   - Fetch user document to check `hasSetJobPreferences` flag
   - If `hasSetJobPreferences` is false, show a prominent button:
     - Text: "Set Preferences"
     - Icon: `Icons.tune` or `Icons.settings`
     - Styled with electrical theme (copper accent, gradient)
     - On tap: show `UserJobPreferencesDialog` with `isFirstTime: true`
   - After dialog closes successfully, refresh the page to hide button and load filtered jobs

3. **Load Personalized Jobs** (modify around line 29 in initState):
   - Check if user has preferences set
   - If yes, load preferences and convert to `JobFilterCriteria` using `preferences.toFilterCriteria()`
   - Call `jobsProvider.loadJobs(filter: filterCriteria)` instead of `jobsProvider.loadJobs()`
   - If no preferences, load jobs without filter (current behavior)

4. **Update Job Display Section** (around line 235-448):
   - Keep existing loading, error, and empty states
   - Keep the existing logic to display first 5 jobs using `CondensedJobCard`
   - Add a small indicator text below the jobs if preferences are active (e.g., "Showing jobs matching your preferences")

5. **Handle Preference Updates**:
   - Listen to `userPreferencesProvider` changes
   - When preferences change, automatically refresh jobs with new filter

Reference the existing structure and styling patterns in the current home screen implementation.

- **Implementation Tasks**

- [ ] **Integrate with Home Screen:**
  - [ ] Add a "Set Preferences" button that is visible only if `hasSetJobPreferences` is `false`.
  - [ ] When the button is pressed, open the `UserJobPreferencesDialog`.
  - [ ] Modify the job loading logic to use `userPreferencesProvider` to get preferences and apply them as a filter.
  - [ ] Ensure jobs automatically refresh when preferences change.

### lib\screens\settings\settings_screen.dart(MODIFY)

References:

- lib\widgets\dialogs\user_job_preferences_dialog.dart(NEW)
- lib\providers\riverpod\user_preferences_provider.dart(NEW)

- **Add Job Preferences to Settings**

Add a menu item for managing job preferences in the settings screen:

1. **Add to Account Section** (around line 148-164):
   - Add a new `_MenuOption` after "Training & Certificates":
     - Icon: `Icons.tune_outlined`
     - Title: 'Job Preferences'
     - Subtitle: 'Manage your job search preferences'
     - onTap: Navigate to preferences management

2. **Create Navigation Handler**:
   - On tap, show `UserJobPreferencesDialog` with current user's preferences
   - Get current user ID from `FirebaseAuth.instance.currentUser?.uid`
   - Load existing preferences from `userPreferencesProvider`
   - Pass `isFirstTime: false` to the dialog
   - After dialog closes, show success message if preferences were updated

3. **Import Required Dependencies**:
   - Import `UserJobPreferencesDialog` from `c:/Users/david/Desktop/Journeyman-Jobs/lib/widgets/dialogs/user_job_preferences_dialog.dart`
   - Import `userPreferencesProvider` from `c:/Users/david/Desktop/Journeyman-Jobs/lib/providers/riverpod/user_preferences_provider.dart`
   - Convert to ConsumerStatefulWidget to access Riverpod providers

Follow the existing menu structure and styling patterns in the settings screen.

- **Implementation Tasks**

- [ ] **Integrate with Settings Screen:**
  - [ ] Add a "Job Preferences" menu option.
  - [ ] When tapped, open the `UserJobPreferencesDialog` pre-filled with the user's current preferences.
  - [ ] Ensure the screen is a `ConsumerStatefulWidget` to access the necessary providers.

### lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)

References:

- lib\models\user_job_preferences.dart(NEW)
- lib\providers\riverpod\user_preferences_provider.dart(NEW)

- **Initialize Job Preferences from Onboarding**

Update the onboarding completion to initialize user job preferences:

1. **In `_completeOnboarding()` method** (around line 157-365):
   - After saving user data to Firestore, create initial `UserJobPreferences` from the collected data:
     - Map `_selectedConstructionTypes` to `constructionTypes`
     - Map `_selectedHoursPerWeek` to `hoursPerWeek`
     - Map `_selectedPerDiem` to `perDiemRequirement`
     - Parse `_preferredLocalsController.text` to extract local numbers
   - Save these preferences using `userPreferencesProvider.savePreferences()`
   - This will automatically set `hasSetJobPreferences: true`

2. **Import Required Dependencies**:
   - Import `UserJobPreferences` model
   - Import `userPreferencesProvider`

3. **Handle Errors**:
   - Wrap preference saving in try-catch
   - If preference saving fails, log error but don't block onboarding completion
   - User can set preferences later from home screen or settings

This ensures users who complete onboarding have their initial preferences set and won't see the "Set Preferences" button on first home screen visit.

- **Implementation Tasks**

- [ ] **Integrate with Onboarding:**
  - [ ] In the `_completeOnboarding` method, create a `UserJobPreferences` object from the collected data.
  - [ ] Use the `userPreferencesProvider` to save these initial preferences.

### lib\providers\riverpod\user_preferences_provider.g.dart(NEW)

References:

- lib\providers\riverpod\user_preferences_provider.dart(NEW)

- **Generated Riverpod Code**

This file will be auto-generated by running `flutter pub run build_runner build` after creating `c:/Users/david/Desktop/Journeyman-Jobs/lib/providers/riverpod/user_preferences_provider.dart`.

The build_runner will generate the necessary provider code based on the `@riverpod` annotations in the user_preferences_provider.dart file.

No manual changes needed - this file is created automatically by the Riverpod code generator.

- **Implementation Tasks**

- [ ] **Generate Riverpod Code:**
  - [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `user_preferences_provider.g.dart`.
