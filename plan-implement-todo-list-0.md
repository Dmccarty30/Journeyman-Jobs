# TODO PLAN

## Observations

I've thoroughly analyzed the Journeyman Jobs Flutter/Dart codebase and the TODO.md requirements. The project is a job-finding app for IBEW electricians with:

- **Established design system**: Electrical-themed components with circuit board backgrounds, custom toasts, and consistent styling
- **Existing patterns**: Rich text formatting for job cards, dialog standards, and Title Case utilities
- **Multiple screens**: Home, Jobs, Storm, Tailboard (Crews), Locals, Settings, and Onboarding
- **State management**: Riverpod providers for jobs, crews, auth, and other features
- **Firebase backend**: Firestore for data persistence

**Current Progress Update**: Phase 1 (App-Wide Standardization) toast/snackbar migration has been completed successfully. All toast implementations now use the electrical-themed components (`JJElectricalToast` and `JJSnackBar`) and are production-ready. The comprehensive migration guide provides patterns and examples for future development.

The TODO covers app-wide consistency improvements, UI refinements across multiple screens, and new features for storm work and crew management. The contractor card and model already exist but need integration into the Storm screen. The codebase has good structure but needs standardization of backgrounds, toasts, and formatting.

## Approach

The implementation will be organized into **7 major phases** addressing different areas of the app:

1. **App-Wide Standardization**: Background consistency, Title Case wrapper utility, toast/snackbar migration
2. **Onboarding Improvements**: Layout adjustments for better UX
3. **Home Screen Refinements**: Job card formatting, dialog consistency
4. **Jobs Screen Enhancement**: Font size increase
5. **Storm Screen Expansion**: Contractor card integration, new section
6. **Tailboard & Crews Features**: Dropdown with backend queries, preferences dialog, role assignment
7. **Social Features Foundation**: Message bubble styling, feed interactions (like/comment/share)

Each phase will be broken into specific file changes with clear instructions. The plan prioritizes consistency and reusability while minimizing code duplication.

## Reasoning

I started by reading the TODO.md file to understand all requirements. Then I explored the codebase structure by listing directories and reading key files:

- Examined electrical component standards (`jj_electrical_toast.dart`, `jj_electrical_theme.dart`)
- Reviewed dialog formatting standards (`job_details_dialog.dart`)
- Analyzed job card implementations (`rich_text_job_card.dart`, `condensed_job_card.dart`)
- Studied screen implementations (home, jobs, storm, onboarding, tailboard)
- Checked utility functions (`string_formatter.dart`)
- Reviewed data models (contractor, crew preferences, job)
- Examined the storm roster JSON data structure

This comprehensive exploration revealed existing patterns, identified gaps, and clarified integration points for the required changes.

## Mermaid Diagram

sequenceDiagram
    participant User
    participant UI
    participant Provider
    participant Service
    participant Firestore

    Note over User,Firestore: Phase 1: App-Wide Standardization
    UI->>UI: Apply ElectricalCircuitBackground (high density)
    UI->>UI: Replace SnackBar with JJElectricalToast
    UI->>UI: Apply toTitleCase to all job data

    Note over User,Firestore: Phase 2-4: UI Refinements
    User->>UI: View Onboarding
    UI->>UI: Render city/state/zip in separate rows
    User->>UI: View Home Screen
    UI->>UI: Display CondensedJobCard (2-column rich text)
    User->>UI: Tap job card
    UI->>UI: Show JobDetailsDialog (canonical format)
    User->>UI: View Jobs Screen
    UI->>UI: Render RichTextJobCard (10% larger fonts)

    Note over User,Firestore: Phase 5: Storm Contractors
    User->>UI: Open Storm Screen
    UI->>Provider: Request contractors
    Provider->>Service: getAllContractors()
    Service->>Firestore: Query contractors collection
    Firestore-->>Service: Return contractor data
    Service-->>Provider: Return List<Contractor>
    Provider-->>UI: Update UI state
    UI->>UI: Render ContractorCard list

    Note over User,Firestore: Phase 6: Crew Creation & Management
    User->>UI: Create new crew
    UI->>Service: createCrew(name, foremanId, preferences)
    Service->>Firestore: Write crew document
    Service->>Firestore: Assign foreman role
    Firestore-->>Service: Success
    Service-->>UI: Return crew ID
    UI->>UI: Show CrewPreferencesDialog
    User->>UI: Configure preferences
    UI->>Service: updateCrewPreferences(crewId, preferences)
    Service->>Firestore: Update crew preferences
    UI->>UI: Navigate to Tailboard
    
    Note over User,Firestore: Tailboard Crew Selection
    UI->>Provider: Request user crews
    Provider->>Service: getUserCrews(userId)
    Service->>Firestore: Query crews where user is member
    Firestore-->>Service: Return crew list
    Service-->>Provider: Return List<Crew>
    Provider-->>UI: Populate dropdown
    User->>UI: Select crew from dropdown
    UI->>Provider: Update selectedCrew
    Provider->>Provider: Notify all tabs
    UI->>UI: Refresh Feed/Jobs/Chat/Members tabs

    Note over User,Firestore: Phase 7: Social Features
    User->>UI: View Feed tab
    UI->>Provider: Watch crewPostsProvider
    Provider->>Service: getCrewPosts(crewId)
    Service->>Firestore: Stream posts collection
    Firestore-->>Service: Real-time post updates
    Service-->>Provider: Stream<List<Post>>
    Provider-->>UI: Render PostCard widgets
    
    User->>UI: Tap like button
    UI->>Service: toggleLike(postId)
    Service->>Firestore: Update likes subcollection
    Firestore-->>Service: Success
    Service-->>Provider: Update like count
    Provider-->>UI: Animate heart icon
    
    User->>UI: Tap comment button
    UI->>UI: Show comment bottom sheet
    User->>UI: Submit comment
    UI->>Service: addComment(postId, content)
    Service->>Firestore: Write to comments subcollection
    Firestore-->>Service: Success
    Service-->>Provider: Update comment count
    Provider-->>UI: Refresh comments
    
    User->>UI: Tap emoji button
    UI->>UI: Show emoji picker
    User->>UI: Select emoji
    UI->>Service: addReaction(postId, emoji)
    Service->>Firestore: Write to reactions subcollection
    Firestore-->>Service: Success
    Service-->>Provider: Update reaction counts
    Provider-->>UI: Display emoji with count

## Proposed File Changes

### lib\utils\text_formatting_wrapper.dart(NEW)

References:

- lib\utils\string_formatter.dart

Create a new utility file for consistent text formatting across the app.

**Purpose**: Provide a centralized wrapper to ensure all job-related text data (classifications, company names, locations, etc.) are consistently formatted in Title Case.

**Implementation**:

- Import `string_formatter.dart` for the `toTitleCase` function
- Create a `JobDataFormatter` class with static methods:
  - `formatClassification(String?)` - wraps toTitleCase for classifications
  - `formatCompany(String?)` - wraps toTitleCase for company names
  - `formatLocation(String?)` - wraps toTitleCase for locations
  - `formatTypeOfWork(String?)` - wraps toTitleCase for work types
  - `formatAnyJobField(String?)` - generic wrapper for any job field
- Each method should handle null/empty strings gracefully, returning 'N/A' or empty string as appropriate
- Add documentation explaining when to use each formatter

**Pattern**: This provides a single source of truth for formatting job data, making it easy to apply Title Case consistently throughout the app without scattered `toTitleCase` calls.

### lib\utils\background_wrapper.dart(NEW)

References:

- lib\electrical_components\circuit_board_background.dart

Create a utility widget for consistently applying the electrical circuit background across all screens.

**Purpose**: Provide a reusable wrapper widget that ensures all screens use the 'high' density electrical circuit background as specified in the TODO.

**Implementation**:

- Import `circuit_board_background.dart` from electrical_components
- Create a `JJElectricalScaffold` widget that extends StatelessWidget
- Accept parameters:
  - `appBar` (PreferredSizeWidget?)
  - `body` (Widget)
  - `floatingActionButton` (Widget?)
  - `bottomNavigationBar` (Widget?)
  - `backgroundColor` (Color?) - defaults to transparent
  - `backgroundOpacity` (double) - defaults to 0.35
  - Other common Scaffold properties as needed
- Build method returns a Scaffold with:
  - A Stack as the body containing:
    - Positioned.fill with ElectricalCircuitBackground (componentDensity: ComponentDensity.high, opacity: backgroundOpacity)
    - The provided body widget
  - All other Scaffold properties passed through

**Usage Pattern**: Replace `Scaffold` with `JJElectricalScaffold` throughout the app to ensure consistent backgrounds.

### lib\utils\toast_migration_guide.md(NEW)

References:

- lib\electrical_components\jj_electrical_toast.dart
- lib\electrical_components\jj_snack_bar.dart

Create a migration guide document for converting old toast/snackbar implementations to the electrical theme standard.

**Content**:

1. **Overview**: Explain that all toasts and snackbars must use the electrical-themed components from `lib/electrical_components/`

2. **Migration Patterns**:
   - **Old Pattern**: `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))`
   - **New Pattern**: `JJElectricalToast.showSuccess(context: context, message: '...')` or `JJSnackBar.showSuccess(context: context, message: '...')`

3. **Available Methods**:
   - `JJElectricalToast.showSuccess()` - for success messages
   - `JJElectricalToast.showError()` - for error messages
   - `JJElectricalToast.showWarning()` - for warnings
   - `JJElectricalToast.showInfo()` - for informational messages
   - `JJElectricalToast.showPower()` - for electrical-themed messages
   - Similar methods available on `JJSnackBar`

4. **Search Commands**: Provide regex patterns to find old implementations:
   - `ScaffoldMessenger\.of\(context\)\.showSnackBar`
   - `SnackBar\(`
   - `FlutterToast`

5. **Examples**: Show before/after code snippets for common scenarios

6. **Checklist**: List all files that need migration (to be populated during implementation)

### lib\screens\home\home_screen.dart(MODIFY)

References:

- lib\widgets\dialogs\job_details_dialog.dart
- lib\electrical_components\jj_electrical_toast.dart
- lib\widgets\condensed_job_card.dart(MODIFY)

Update the Home Screen to use consistent backgrounds, standardized dialogs, and proper formatting.

**Changes**:

1. **Background Consistency**:
   - The screen already uses `ElectricalCircuitBackground` but verify it uses `ComponentDensity.high` (currently uses `ComponentDensity.high` - ✓ correct)
   - Ensure opacity is set to 0.35 (currently 0.35 - ✓ correct)

2. **Job Details Dialog**:
   - Replace the inline `_showJobDetailsDialog` implementation (lines 431-560) with a call to the canonical `JobDetailsDialog` widget
   - Import `lib/widgets/dialogs/job_details_dialog.dart`
   - Simplify the method to:

     ```dart
     void _showJobDetailsDialog(BuildContext context, dynamic job) {
       final jobModel = job is JobsRecord ? _convertJobsRecordToJob(job) : job as Job;
       showDialog(
         context: context,
         builder: (context) => JobDetailsDialog(job: jobModel),
       );
     }
     ```

   - Remove the duplicate dialog UI code (lines 436-559)
   - Keep the `_convertJobsRecordToJob` helper method as it's needed for data conversion

3. **Toast/Snackbar Migration**:
   - Replace the `ScaffoldMessenger.of(context).showSnackBar` call in `_submitJobApplication` (lines 589-602) with `JJElectricalToast.showSuccess`
   - Import `lib/electrical_components/jj_electrical_toast.dart`
   - Update to: `JJElectricalToast.showSuccess(context: context, message: 'Application submitted for ${job.classification ?? 'the position'}!');`

4. **Condensed Job Card**:
   - The `CondensedJobCard` widget is already being used correctly
   - Ensure it's displaying the dialog when tapped (currently passes `onTap: () => _showJobDetailsDialog(context, job)` - ✓ correct)

**Note**: The condensed job card formatting will be handled in a separate file change for `condensed_job_card.dart`.

### lib\widgets\condensed_job_card.dart(MODIFY)

References:

- lib\widgets\rich_text_job_card.dart(MODIFY)
- lib\utils\string_formatter.dart

Refactor the condensed job card to follow the rich text formatting pattern with proper two-column layout.

**Current Issues**:

- The card has a three-column header (local badge, classification, and implicitly wages in the bottom row)
- Doesn't use the RichText pattern consistently
- Needs better adherence to the formatting guidelines from `rich_text_job_card.dart`

**Changes**:

1. **Header Row (Local | Classification)**:
   - Keep the current header row with local badge and classification
   - Add a horizontal divider below in copper accent color (AppTheme.accentCopper) as specified in TODO
   - The divider should separate the header from the data rows

2. **Data Rows - Use RichText Two-Column Pattern**:
   - After the divider, create data rows using the same pattern as `rich_text_job_card.dart`
   - Row 1: **Contractor** | **Wages** (two columns)
   - Row 2: **Location** | **Hours** (two columns)
   - Row 3: **Start Date** | **Per Diem** (two columns) - if available

3. **RichText Implementation**:
   - Create a helper method `_buildTwoColumnRow` similar to the one in `rich_text_job_card.dart`:
     - Takes leftLabel, leftValue, rightLabel, rightValue
     - Returns a Row with two Expanded RichText widgets
     - Each RichText has two TextSpans: bold label + regular value
     - Use fontSize: 12 for consistency
     - Bold labels use fontWeight: FontWeight.bold, color: AppTheme.textDark
     - Values use color: AppTheme.textLight (or custom color for wages)

4. **Apply Title Case Formatting**:
   - Import `lib/utils/string_formatter.dart`
   - Apply `toTitleCase()` to: classification, location, company name
   - Ensure all text follows Title Case convention

5. **Layout Structure**:

   ```dart
   [Local Badge] [Classification]
   ─────────────────────────────── (copper divider)
   Contractor: ABC Company | Wages: $45.00/hr
   Location: City, State   | Hours: 40/week
   Start Date: 01/15/2024  | Per Diem: Yes
   ```

6. **Remove Icon-Based Layout**:
   - Remove the icon-based layout from the bottom section (lines 87-167)
   - Replace with the structured RichText two-column rows
   - Keep the arrow indicator at the end if desired

**Result**: The card will have a clean, consistent two-column layout matching the rich text job card pattern, with proper Title Case formatting and a copper divider separating the header from data.

### lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)

Adjust the onboarding Step 1 layout to give city, state, and zipcode fields more room for user input visibility.

**Current Issue** (lines 463-539):

- City, State, and Zip are in a single row with flex ratios (3:2:1)
- Users can't see their full input in the city field, making typo detection difficult

**Changes**:

1. **City Field - Full Width Row**:
   - Move the city text field to its own full-width row (lines 465-478)
   - Remove it from the current Row widget
   - Place it before the State/Zip row
   - Keep all existing properties (label, controller, focusNode, etc.)

2. **State and Zipcode - Shared Row**:
   - Create a new Row below the city field
   - Place State dropdown and Zipcode field in this row
   - Use Expanded widgets with equal flex (or 2:1 ratio to give state more room)
   - Keep all existing properties for both fields

3. **Updated Layout Structure**:

   ```dart
   [First Name] [Last Name]  (existing row)
   [Phone Number]            (existing full-width)
   [Address Line 1]          (existing full-width)
   [Address Line 2]          (existing full-width)
   [City]                    (NEW: full-width row)
   [State] [Zip Code]        (NEW: shared row)
   ```

4. **Spacing**:
   - Add `SizedBox(height: AppTheme.spacingMd)` between city and state/zip row
   - Maintain consistent spacing with other fields

5. **Focus Navigation**:
   - Update the city field's `onFieldSubmitted` to focus on the zipcode field (since state is a dropdown)
   - Keep zipcode's `onFieldSubmitted` to unfocus as the last field

**Result**: Users will be able to see their complete city name input, and the state/zipcode fields will have adequate space for their shorter content.

### lib\screens\jobs\jobs_screen.dart(MODIFY)

References:

- lib\widgets\rich_text_job_card.dart(MODIFY)
- lib\electrical_components\jj_electrical_toast.dart

Increase the font size of job cards by 10% as specified in the TODO.

**Current State**:

- The screen uses `RichTextJobCard` component (line 479)
- Font sizes are defined within the `RichTextJobCard` widget itself

**Changes**:

1. **Toast/Snackbar Migration**:
   - Replace the `ScaffoldMessenger.of(context).showSnackBar` call in `_handleBidAction` (lines 143-148) with `JJElectricalToast.showSuccess`
   - Import `lib/electrical_components/jj_electrical_toast.dart`
   - Update to: `JJElectricalToast.showSuccess(context: context, message: 'Bidding on job at ${job.company}');`

2. **Background Verification**:
   - Verify the background is using `ComponentDensity.high` (line 438 - ✓ correct)
   - Opacity is 0.35 (line 436 - ✓ correct)

**Note**: The actual font size increase will be implemented in `rich_text_job_card.dart` since that's where the card rendering happens. This screen just needs the toast migration.

### lib\widgets\rich_text_job_card.dart(MODIFY)

Increase all font sizes in the job card by 10% to improve readability.

**Current Font Sizes**:

- Label and value text: 12px (lines 193, 201, 219, 227, 249, 256)
- Button text: 14px (lines 113, 156)

**Changes**:

1. **Data Row Font Sizes** (increase by 10%):
   - Change fontSize from 12 to 13.2 (round to 13 for cleaner rendering) in:
     - `_buildTwoColumnRow` method: both label TextSpan (line 193) and value TextSpan (line 201)
     - Right column: label TextSpan (line 219) and value TextSpan (line 227)
   - Change fontSize in `_buildInfoRow` method:
     - Label TextSpan (line 249): 12 → 13
     - Value TextSpan (line 256): 12 → 13

2. **Button Font Sizes** (increase by 10%):
   - Details button text (line 113): 14 → 15.4 (round to 15)
   - Bid Now button text (line 156): 14 → 15.4 (round to 15)

3. **Consistency Check**:
   - Ensure all text within the card uses the updated sizes
   - Verify padding and spacing still look balanced with larger text
   - Test that the card doesn't overflow on smaller screens

**Result**: All text in the job cards will be 10% larger, improving readability while maintaining the card's layout and design.

### lib\services\contractor_service.dart(NEW)

References:

- lib\models\contractor_model.dart

Create a service layer for managing contractor data from Firestore.

**Purpose**: Provide a clean interface for fetching and managing storm contractor data.

**Implementation**:

1. **Imports**:
   - Import `cloud_firestore/cloud_firestore.dart`
   - Import `lib/models/contractor_model.dart`

2. **ContractorService Class**:
   - Create a class with a private FirebaseFirestore instance
   - Collection name: 'contractors'

3. **Methods**:
   - `Future<List<Contractor>> getAllContractors()`: Fetch all contractors from Firestore, ordered by company name
   - `Future<List<Contractor>> searchContractors(String query)`: Search contractors by company name
   - `Future<Contractor?> getContractorById(String id)`: Get a specific contractor
   - `Stream<List<Contractor>> contractorsStream()`: Real-time stream of contractors

4. **Error Handling**:
   - Wrap Firestore calls in try-catch blocks
   - Log errors using debugPrint
   - Return empty lists or null on errors

5. **Data Conversion**:
   - Use `Contractor.fromJson()` to convert Firestore documents to Contractor objects
   - Handle missing or malformed data gracefully

**Note**: The Firestore collection doesn't exist yet. The service should handle empty collections gracefully. A separate script will populate the data from `docs/storm_roster.json`.

### lib\providers\riverpod\contractor_provider.dart(NEW)

References:

- lib\services\contractor_service.dart(NEW)
- lib\models\contractor_model.dart

Create Riverpod providers for contractor data management.

**Purpose**: Expose contractor data through Riverpod for reactive UI updates.

**Implementation**:

1. **Imports**:
   - Import `flutter_riverpod/flutter_riverpod.dart`
   - Import `lib/services/contractor_service.dart`
   - Import `lib/models/contractor_model.dart`

2. **Service Provider**:
   - Create a provider for ContractorService instance:

     ```dart
     final contractorServiceProvider = Provider<ContractorService>((ref) {
       return ContractorService();
     });
     ```

3. **Contractors List Provider**:
   - Create a FutureProvider that fetches all contractors:

     ```dart
     final contractorsProvider = FutureProvider<List<Contractor>>((ref) async {
       final service = ref.watch(contractorServiceProvider);
       return await service.getAllContractors();
     });
     ```

4. **Contractors Stream Provider** (optional for real-time updates):
   - Create a StreamProvider for real-time contractor updates:

     ```dart
     final contractorsStreamProvider = StreamProvider<List<Contractor>>((ref) {
       final service = ref.watch(contractorServiceProvider);
       return service.contractorsStream();
     });
     ```

5. **Search Provider** (optional):
   - Create a provider family for searching contractors by query

**Usage**: Screens can watch these providers to reactively display contractor data.

### lib\screens\storm\storm_screen.dart(MODIFY)

References:

- lib\widgets\contractor_card.dart
- lib\providers\riverpod\contractor_provider.dart(NEW)
- lib\models\contractor_model.dart

Add a Contractors section to the Storm Screen with a list of contractor cards.

**Location**: After the storm events list, before the end of the SingleChildScrollView (around line 450)

**Changes**:

1. **Import Statements**:
   - Add import for `lib/widgets/contractor_card.dart`
   - Add import for `lib/providers/riverpod/contractor_provider.dart`
   - Add import for `lib/models/contractor_model.dart`

2. **Contractors Section Header**:
   - Add a section header similar to the "Active Storm Events" header
   - Title: "Storm Contractors"
   - Subtitle: "Sign up for storm work opportunities"
   - Use the same styling as other section headers (primaryNavy color, bold font)

3. **Contractors List**:
   - Use `Consumer` widget to watch the `contractorsProvider`
   - Handle three states:
     - **Loading**: Show a loading indicator (CircularProgressIndicator with copper color)
     - **Error**: Show an error message with retry button
     - **Data**: Display the list of contractors

4. **Contractor Cards Display**:
   - Use a `Column` to display contractor cards (not ListView since it's inside a ScrollView)
   - Map over the contractors list and create a `ContractorCard` for each
   - The `ContractorCard` widget already exists and handles all the display logic
   - Add spacing between cards using `SizedBox(height: AppTheme.spacingMd)`

5. **Empty State**:
   - If the contractors list is empty, show a message:
     - Icon: Icons.business_outlined
     - Text: "No contractors available"
     - Subtext: "Check back later for storm work opportunities"

6. **Section Spacing**:
   - Add `SizedBox(height: AppTheme.spacingXl)` before the contractors section
   - Add `SizedBox(height: AppTheme.spacingXxl)` after the contractors section

**Layout Structure**:

```dart
[Existing Storm Events Section]

[Contractors Section Header]
[Contractor Card 1]
[Contractor Card 2]
[Contractor Card 3]
...
```

**Note**: The contractor cards already follow the rich text pattern and have proper formatting, so no additional styling is needed.

### scripts\populate_contractors.dart(NEW)

References:

- docs\storm_roster.json
- lib\models\contractor_model.dart

Create a script to populate the Firestore contractors collection from the storm_roster.json file.

**Purpose**: One-time script to import contractor data from JSON into Firestore.

**Implementation**:

1. **Imports**:
   - Import `dart:io` for file reading
   - Import `dart:convert` for JSON parsing
   - Import `cloud_firestore/cloud_firestore.dart`
   - Import `lib/models/contractor_model.dart`

2. **Main Function**:
   - Read the `docs/storm_roster.json` file
   - Parse the JSON array
   - Initialize Firestore instance

3. **Data Processing**:
   - Loop through each contractor object in the JSON
   - Create a Contractor model instance:
     - Generate a unique ID (use Firestore auto-ID or company name slug)
     - Map JSON fields to Contractor model fields:
       - COMPANY → company
       - HOW TO SIGNUP → howToSignup
       - PHONE NUMBER → phoneNumber (optional)
       - EMAIL → email (optional)
       - WEBSITE → website (optional)
     - Set createdAt to current timestamp

4. **Firestore Upload**:
   - Use batch writes for efficiency (max 500 per batch)
   - Write each contractor to the 'contractors' collection
   - Use `contractor.toFirestore()` method for proper formatting

5. **Error Handling**:
   - Wrap in try-catch blocks
   - Log progress (e.g., "Uploaded 10/60 contractors")
   - Log any errors with contractor details

6. **Completion**:
   - Print success message with total count
   - Exit cleanly

**Usage**: Run this script once to populate the database: `dart run scripts/populate_contractors.dart`

**Note**: This script should be run with proper Firebase credentials configured.

### lib\features\crews\widgets\crew_preferences_dialog.dart(NEW)

References:

- lib\features\crews\models\crew_preferences.dart
- lib\electrical_components\jj_electrical_toast.dart

Create a dialog for setting crew job preferences after crew creation.

**Purpose**: Allow the foreman to configure job matching preferences immediately after creating a crew.

**Implementation**:

1. **Widget Structure**:
   - Create a StatefulWidget named `CrewPreferencesDialog`
   - Accept parameters:
     - `crewId` (String) - the newly created crew's ID
     - `onComplete` (VoidCallback) - callback when preferences are saved

2. **Dialog Layout**:
   - Use a Dialog widget with rounded corners and copper border (matching app theme)
   - Title: "Set Crew Preferences"
   - Subtitle: "Configure job matching for your crew"

3. **Preference Fields** (based on CrewPreferences model):
   - **Job Types** (multi-select chips):
     - Options: Inside Wireman, Journeyman Lineman, Apprentice, Foreman, etc.
     - Use `JJChip` widgets similar to onboarding
     - Allow multiple selections

   - **Minimum Hourly Rate** (slider or stepper):
     - Range: $15 - $100
     - Increment: $5
     - Display current value

   - **Maximum Distance** (optional slider):
     - Range: 0 - 500 miles
     - Increment: 25 miles
     - Allow "Any Distance" option

   - **Preferred Companies** (text field):
     - Multi-line text input
     - Placeholder: "Enter company names, separated by commas"

   - **Auto-Share Enabled** (switch):
     - Toggle for automatic job sharing
     - Explanation text: "Automatically share matching jobs with crew members"

4. **Actions**:
   - **Skip Button**: Save with default preferences and close
   - **Save Button**: Validate and save preferences, then close

5. **Save Logic**:
   - Create a CrewPreferences object from form data
   - Call crew service to update preferences
   - Show success toast using `JJElectricalToast.showSuccess`
   - Call `onComplete` callback
   - Close dialog

6. **Styling**:
   - Use AppTheme colors throughout
   - Match the electrical theme aesthetic
   - Ensure scrollable content for smaller screens

**Integration**: This dialog will be shown immediately after crew creation in the create crew flow.

### lib\features\crews\screens\create_crew_screen.dart(MODIFY)

References:

- lib\features\crews\widgets\crew_preferences_dialog.dart(NEW)
- lib\electrical_components\jj_electrical_toast.dart
- lib\features\crews\services\crew_service.dart

Update the create crew flow to assign foreman role, show preferences dialog, and use electrical-themed toasts.

**Changes**:

1. **Toast/Snackbar Migration** (lines 62-67):
   - Replace the error `ScaffoldMessenger.of(context).showSnackBar` with `JJElectricalToast.showError`
   - Import `lib/electrical_components/jj_electrical_toast.dart`
   - Update to: `JJElectricalToast.showError(context: context, message: 'Failed to create crew: $e');`

2. **Foreman Role Assignment**:
   - After successful crew creation (line 38-53), the user is already set as foremanId
   - Verify that the crew service properly assigns the foreman role in the crew members collection
   - If not handled by the service, add a call to update the user's role:

     ```dart
     await crewService.assignMemberRole(
       crewId: newCrewId,
       userId: currentUser.uid,
       role: MemberRole.foreman,
     );
     ```

3. **Preferences Dialog Flow**:
   - Import the new `CrewPreferencesDialog` widget
   - After successful crew creation, instead of immediately navigating to crews screen:
     - Show the preferences dialog
     - Pass the new crew ID and a callback
     - In the callback, navigate to the tailboard screen
   - Update the flow:

     ```dart
     // After crew creation succeeds
     if (mounted) {
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context) => CrewPreferencesDialog(
           crewId: newCrewId,
           onComplete: () {
             Navigator.of(context).pop(); // Close dialog
             context.go(AppRouter.crews); // Navigate to tailboard
           },
         ),
       );
     }
     ```

4. **Success Toast**:
   - Show a success toast when crew is created (before showing preferences dialog)
   - Use: `JJElectricalToast.showSuccess(context: context, message: 'Crew created successfully! You are now the foreman.');`

**Result**: After creating a crew, the user will be assigned as foreman, see a success message, configure preferences in a dialog, and then be taken to the tailboard screen.

### lib\features\crews\screens\tailboard_screen.dart(MODIFY)

References:

- lib\features\crews\widgets\crew_selection_dropdown.dart
- lib\features\crews\providers\crews_riverpod_provider.dart(MODIFY)
- lib\features\crews\providers\crew_selection_provider.dart
- lib\features\crews\widgets\post_card.dart(NEW)
- lib\features\crews\providers\feed_provider.dart(NEW)

Update the Tailboard Screen to add crew selection dropdown with backend queries.

**Current State**:

- The screen has a crew selection dropdown widget (`CrewSelectionDropdown`) that's already implemented
- The dropdown is shown in the crew header (around line 146-230)

**Changes**:

1. **Verify Crew Membership Query**:
   - Check if the `userCrewsProvider` (used in the screen) properly queries crews where the current user is a member
   - The provider should query both the `crews` collection and `users` collection to find:
     - Crews where user is the foreman (foremanId == userId)
     - Crews where user is in the members subcollection
   - If not implemented, this needs to be added to the crews provider

2. **Dropdown Data Source**:
   - The `CrewSelectionDropdown` widget should receive the list of crews from `userCrewsProvider`
   - Verify it's properly filtering to show only crews the user is a member of
   - The dropdown should display crew name and member count

3. **Selected Crew State**:
   - Verify that `selectedCrewProvider` properly tracks which crew is selected
   - When a crew is selected from the dropdown, all tabs (Feed, Jobs, Chat, Members) should update to show data for that crew

4. **Feed Tab Data Filtering**:
   - The Feed tab should query posts filtered by the selected crew ID
   - Update the feed provider to accept a crew ID parameter

5. **Jobs Tab Data Filtering**:
   - The Jobs tab should show jobs matched to the selected crew's preferences
   - Verify the job matching service uses the selected crew's preferences

6. **Chat Tab Data Filtering**:
   - The Chat tab should show messages for the selected crew
   - Verify the messaging provider filters by crew ID

7. **Members Tab Data Filtering**:
   - The Members tab should show members of the selected crew
   - Verify the members query filters by crew ID

8. **Permanent Feed Tab**:
   - Ensure the Feed tab is always visible regardless of selected crew (as specified in TODO)
   - The feed should show posts from the selected crew, or a global feed if no crew is selected

**Note**: Most of the UI structure is already in place. This change focuses on ensuring the backend queries properly filter data based on crew membership and selection.
Update the Feed tab to use the new PostCard widget and feed providers.

**Location**: The FeedTab widget (lines 505-569)

**Changes**:

1. **Import Statements**:
   - Add import for `lib/features/crews/widgets/post_card.dart`
   - Add import for `lib/features/crews/providers/feed_provider.dart`

2. **Replace Mock Data**:
   - Remove the mock posts list (if any)
   - Use the `crewPostsProvider` to fetch real posts

3. **Feed Tab Implementation**:
   - Wrap the content in a Consumer widget
   - Watch the `crewPostsProvider` with the selected crew ID
   - Handle three states:
     - **Loading**: Show loading indicator
     - **Error**: Show error message
     - **Data**: Display list of posts

4. **Posts List**:
   - Use ListView.builder to display posts
   - Map each post to a PostCard widget
   - Pass interaction callbacks:
     - `onLike`: Call feed service to toggle like
     - `onComment`: Open comment bottom sheet
     - `onShare`: Open share dialog
     - `onEmoji`: Open emoji picker

5. **Empty State**:
   - If no posts exist, show:
     - Icon: Icons.feed_outlined
     - Text: "No posts yet"
     - Subtext: "Be the first to share something with your crew!"
     - Button: "Create Post" (opens create post dialog)

6. **Create Post FAB**:
   - The FAB already exists in the parent TailboardScreen
   - Ensure it opens a create post dialog when tapped on the Feed tab

7. **Pull to Refresh**:
   - Wrap the ListView in a RefreshIndicator
   - On refresh, invalidate the posts provider

8. **Real-time Updates**:
   - Since using StreamProvider, posts will update in real-time
   - No additional polling needed

**Result**: The Feed tab will display real posts with full social interaction capabilities.

### lib\features\crews\providers\crews_riverpod_provider.dart(MODIFY)

References:

- lib\features\crews\services\crew_service.dart
- lib\features\crews\models\crew.dart

Enhance the crews provider to properly query crews based on user membership.

**Current State**:

- The provider likely queries all crews or crews where user is foreman
- Need to expand to include crews where user is a member

**Changes**:

1. **User Crews Query Enhancement**:
   - Update the `userCrewsProvider` to query crews where:
     - User is the foreman (foremanId == currentUserId), OR
     - User exists in the crew's members subcollection
   - This requires two separate queries that are then merged

2. **Query Implementation**:
   - Query 1: `crews.where('foremanId', isEqualTo: currentUserId)`
   - Query 2: For each crew, check if `crews/{crewId}/members/{userId}` exists
   - Alternative: Maintain a `memberIds` array field on the crew document for easier querying

3. **Efficient Querying**:
   - If using subcollections, consider adding a `crewIds` array field to the user document
   - This allows a single query: `crews.where('memberIds', arrayContains: currentUserId)`
   - Update crew service to maintain this array when members join/leave

4. **Provider Structure**:
   - Ensure the provider returns a `List<Crew>` of all crews the user belongs to
   - Sort by most recently active or alphabetically
   - Handle loading and error states

5. **Real-time Updates**:
   - Use StreamProvider instead of FutureProvider for real-time crew updates
   - When a user is added/removed from a crew, the dropdown should update automatically

**Result**: The crew dropdown will show all crews where the user is either foreman or member, with real-time updates.

### lib\features\crews\widgets\message_bubble.dart(MODIFY)

References:

- lib\design_system\app_theme.dart

Update the message bubble styling to match the electrical theme and ensure consistency.

**Current State**:

- A message bubble widget exists for displaying chat messages
- Needs styling updates to match the app's electrical theme

**Changes**:

1. **Color Scheme**:
   - **Sent messages** (user's own messages):
     - Background: AppTheme.accentCopper with slight transparency (0.9 alpha)
     - Text color: AppTheme.white
     - Border: 1px solid AppTheme.accentCopper

   - **Received messages** (other users' messages):
     - Background: AppTheme.offWhite
     - Text color: AppTheme.textDark
     - Border: 1px solid AppTheme.lightGray

2. **Bubble Shape**:
   - Rounded corners using AppTheme.radiusMd
   - Add a small tail/pointer on the appropriate side:
     - Left side for received messages
     - Right side for sent messages
   - Use CustomPainter or ClipPath for the tail shape

3. **Layout**:
   - Sent messages: Align to the right
   - Received messages: Align to the left
   - Max width: 70% of screen width
   - Padding: AppTheme.spacingMd inside the bubble

4. **Message Content**:
   - Display sender name (for received messages only)
   - Message text with proper line breaks
   - Timestamp in small, light text at the bottom
   - Read receipts (optional): small checkmark icons

5. **Electrical Theme Touches**:
   - Add a subtle glow effect to sent messages (copper glow)
   - Use AppTheme.shadowSm for elevation
   - Consider adding a subtle circuit pattern overlay (very faint)

6. **Animations**:
   - Fade in animation when message appears
   - Slight scale animation on tap (for future interactions)

**Result**: Message bubbles will have a consistent, professional look that matches the app's electrical theme, with clear visual distinction between sent and received messages.

### lib\widgets\message_bubble.dart(MODIFY)

References:

- lib\features\crews\widgets\message_bubble.dart(MODIFY)
- lib\design_system\app_theme.dart

Update the root-level message bubble widget to match the electrical theme (same changes as the crews message bubble).

**Note**: This is likely a duplicate or older version of the message bubble widget. Apply the same styling changes as described for `lib/features/crews/widgets/message_bubble.dart`:

1. **Color Scheme**: Copper for sent, off-white for received
2. **Bubble Shape**: Rounded with tail/pointer
3. **Layout**: Proper alignment and max width
4. **Electrical Theme**: Subtle glow and shadows
5. **Content**: Sender name, message text, timestamp

**Consistency**: Ensure both message bubble widgets (this one and the crews version) have identical styling so messages look the same throughout the app.

**Consider**: Evaluate if both widgets are needed, or if one should be deprecated in favor of the other to reduce code duplication.

### lib\features\crews\widgets\post_card.dart(NEW)

References:

- lib\models\post_model.dart
- lib\design_system\app_theme.dart

Create a post card widget for the Feed tab with social interaction features.

**Purpose**: Display feed posts with like, comment, share, and emoji reaction capabilities.

**Implementation**:

1. **Widget Structure**:
   - Create a StatefulWidget named `PostCard`
   - Accept a `Post` model parameter (from `lib/models/post_model.dart`)
   - Accept callback functions for interactions

2. **Card Layout**:
   - Container with white background, rounded corners, copper border
   - Shadow for elevation (AppTheme.shadowMd)
   - Padding: AppTheme.spacingMd

3. **Header Section**:
   - User avatar (circular, 40px diameter)
   - User name (bold, primaryNavy color)
   - Post timestamp (small, light text)
   - Three-dot menu button (for post options)

4. **Content Section**:
   - Post text content (multi-line, proper line breaks)
   - Optional image/media (if post has attachments)
   - Proper text formatting and link detection

5. **Interaction Bar**:
   - Row of action buttons at the bottom:
     - **Like button**: Heart icon, shows count, toggles filled/outlined
     - **Comment button**: Comment icon, shows count, opens comment sheet
     - **Share button**: Share icon, opens share options
     - **Emoji button**: Emoji icon, shows emoji picker
   - Use IconButton widgets with AppTheme colors
   - Active state: accentCopper color
   - Inactive state: textSecondary color

6. **Interaction Counts**:
   - Display counts next to each button
   - Format large numbers (e.g., "1.2K" for 1200)
   - Update counts in real-time when user interacts

7. **Like Animation**:
   - When user taps like, animate the heart icon
   - Scale animation with copper glow effect
   - Use flutter_animate package

8. **Comment Preview**:
   - Show first 2-3 comments below the interaction bar
   - "View all X comments" link to open full comment sheet
   - Each comment shows: avatar, name, text, timestamp

9. **Emoji Reactions**:
   - Display emoji reactions below the post (if any)
   - Show emoji with count (e.g., "👍 5  ❤️ 3")
   - Tappable to add/remove user's reaction

10. **Callbacks**:
    - `onLike`: Called when like button is tapped
    - `onComment`: Called when comment button is tapped
    - `onShare`: Called when share button is tapped
    - `onEmoji`: Called when emoji button is tapped
    - `onUserTap`: Called when user avatar/name is tapped

**Styling**: Match the electrical theme with copper accents, navy text, and subtle circuit patterns in the background.

### lib\features\crews\services\feed_service.dart(NEW)

References:

- lib\models\post_model.dart

Create a service layer for managing feed posts and interactions.

**Purpose**: Handle CRUD operations for posts and social interactions (likes, comments, shares, emojis).

**Implementation**:

1. **Imports**:
   - Import `cloud_firestore/cloud_firestore.dart`
   - Import `lib/models/post_model.dart`
   - Import Firebase Auth for current user

2. **FeedService Class**:
   - Private FirebaseFirestore instance
   - Collection name: 'posts'
   - Subcollections: 'comments', 'likes', 'reactions'

3. **Post Methods**:
   - `Future<void> createPost({required String crewId, required String content, String? mediaUrl})`: Create a new post
   - `Future<void> deletePost(String postId)`: Delete a post (only by author)
   - `Future<void> updatePost(String postId, String content)`: Edit a post
   - `Stream<List<Post>> getCrewPosts(String crewId)`: Stream of posts for a crew, ordered by timestamp
   - `Stream<List<Post>> getGlobalPosts()`: Stream of all posts (for global feed)

4. **Like Methods**:
   - `Future<void> toggleLike(String postId)`: Add or remove like from current user
   - `Future<int> getLikeCount(String postId)`: Get total like count
   - `Future<bool> isLikedByUser(String postId)`: Check if current user liked the post

5. **Comment Methods**:
   - `Future<void> addComment(String postId, String content)`: Add a comment to a post
   - `Future<void> deleteComment(String postId, String commentId)`: Delete a comment
   - `Stream<List<Comment>> getComments(String postId)`: Stream of comments for a post
   - `Future<int> getCommentCount(String postId)`: Get total comment count

6. **Share Methods**:
   - `Future<void> sharePost(String postId, String targetCrewId)`: Share a post to another crew
   - `Future<int> getShareCount(String postId)`: Get total share count

7. **Emoji Reaction Methods**:
   - `Future<void> addReaction(String postId, String emoji)`: Add emoji reaction
   - `Future<void> removeReaction(String postId, String emoji)`: Remove emoji reaction
   - `Future<Map<String, int>> getReactions(String postId)`: Get all reactions with counts

8. **Data Structure**:
   - Posts collection: `posts/{postId}`
   - Likes subcollection: `posts/{postId}/likes/{userId}`
   - Comments subcollection: `posts/{postId}/comments/{commentId}`
   - Reactions subcollection: `posts/{postId}/reactions/{userId}`

9. **Error Handling**:
   - Wrap all Firestore operations in try-catch
   - Log errors and throw custom exceptions
   - Handle permission errors gracefully

**Result**: A complete service layer for feed functionality that can be used by the UI through Riverpod providers.

### lib\features\crews\providers\feed_provider.dart(NEW)

References:

- lib\features\crews\services\feed_service.dart(NEW)
- lib\models\post_model.dart

Create Riverpod providers for feed data and interactions.

**Purpose**: Expose feed service functionality through Riverpod for reactive UI updates.

**Implementation**:

1. **Service Provider**:
   - Create a provider for FeedService instance

2. **Posts Stream Provider**:
   - Create a StreamProvider.family that accepts a crew ID
   - Returns a stream of posts for that crew
   - Use: `final crewPostsProvider = StreamProvider.family<List<Post>, String>((ref, crewId) {...});`

3. **Global Posts Provider**:
   - Create a StreamProvider for global feed posts
   - Returns all posts across all crews

4. **Post Interactions State**:
   - Create StateNotifierProviders for managing interaction states:
     - Like state (is post liked by current user)
     - Comment count
     - Share count
     - Reaction counts

5. **Action Providers**:
   - Create providers for actions that modify data:
     - `toggleLikeProvider`: Provider for toggling likes
     - `addCommentProvider`: Provider for adding comments
     - `sharePostProvider`: Provider for sharing posts
     - `addReactionProvider`: Provider for adding emoji reactions

6. **Selected Post Provider**:
   - Track which post is currently selected (for comment sheet, etc.)
   - Use StateProvider

7. **Provider Dependencies**:
   - Ensure providers properly depend on auth provider for current user
   - Invalidate/refresh when user changes

**Usage**: The Feed tab will watch these providers to display posts and handle interactions reactively.

### IMPLEMENTATION_CHECKLIST.md(NEW)

Create a comprehensive checklist document to track implementation progress.

**Content Structure**:

## Phase 1: App-Wide Standardization

- [x] Create text formatting wrapper utility
- [x] Create background wrapper utility
- [x] Create toast migration guide
- [x] Audit all screens for background consistency
- [x] Audit all toast/snackbar usages
- [x] Migrate home screen toasts
- [x] Migrate jobs screen toasts
- [x] Migrate create crew screen toasts
- [x] Migrate other screens (list all)
- [x] Complete comprehensive toast/snackbar migration across entire codebase
- [x] Verify all electrical-themed toast implementations are production-ready
- [x] Document migration patterns and examples for future development
- [x] Complete comprehensive toast/snackbar migration across entire codebase
- [x] Verify all electrical-themed toast implementations are production-ready

## Phase 2: Onboarding Improvements

- [x] Adjust Step 1 layout (city/state/zip)
- [x] Test on various screen sizes
- [x] Verify focus navigation works correctly

## Phase 3: Home Screen Refinements

- [x] Update condensed job card formatting
- [x] Implement rich text two-column layout
- [x] Add copper divider to condensed card
- [x] Replace inline job details dialog
- [x] Test dialog consistency

## Phase 4: Jobs Screen Enhancement

- [x] Increase font sizes by 10%
- [x] Test readability on various devices
- [x] Verify no layout overflow issues

## Phase 5: Storm Screen Expansion

- [ ] Create contractor service
- [ ] Create contractor provider
- [ ] Add contractors section to storm screen
- [ ] Create populate contractors script
- [ ] Run script to populate Firestore
- [ ] Test contractor card display
- [ ] Verify contractor card follows rich text pattern

## Phase 6: Tailboard & Crews Features

- [ ] Create crew preferences dialog
- [ ] Update create crew flow
- [ ] Implement foreman role assignment
- [ ] Show preferences dialog after crew creation
- [ ] Enhance crews provider for membership queries
- [ ] Update tailboard crew dropdown
- [ ] Verify crew selection filters all tabs
- [ ] Test crew membership queries

## Phase 7: Social Features Foundation

- [ ] Update message bubble styling (crews)
- [ ] Update message bubble styling (root)
- [ ] Create post card widget
- [ ] Create feed service
- [ ] Create feed providers
- [ ] Update Feed tab implementation
- [ ] Implement like functionality
- [ ] Implement comment functionality
- [ ] Implement share functionality
- [ ] Implement emoji reactions
- [ ] Test all social interactions

## Testing & Validation

- [ ] Test all screens on iOS
- [ ] Test all screens on Android
- [ ] Verify electrical theme consistency
- [ ] Test with real Firestore data
- [ ] Performance testing
- [ ] Accessibility testing
- [ ] User acceptance testing

## Documentation

- [ ] Update README with new features
- [ ] Document new utilities and patterns
- [ ] Create developer guide for electrical theme
- [ ] Update API documentation

**Usage**: Check off items as they are completed. Add notes for any blockers or issues encountered.
