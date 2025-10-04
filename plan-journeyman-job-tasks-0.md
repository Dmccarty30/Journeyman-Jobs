# I have created the following plan after thorough exploration and analysis of the codebase. Follow the below plan verbatim. Trust the files and references. Do not re-verify what's written in the plan. Explore only when absolutely necessary. First implement all the proposed file changes and then I'll review all the changes together at the end

## Observations

I've analyzed the TODO.md file and the codebase structure. The main issues are:

1. **Auth Screen**: Already has the enhanced tab bar implemented, but text fields need copper borders
2. **Onboarding Steps Screen**: Multiple issues across 3 steps including header alignment, copper borders, layout adjustments, and missing Next button functionality
3. **Background**: Need to add electrical circuit background to all onboarding screens
4. **Text Field Component**: The `JJTextField` component uses the default theme's InputDecoration which doesn't have copper borders

The app uses a comprehensive electrical theme with copper (`accentCopper`) and navy colors. The `ElectricalCircuitBackground` widget exists in two places - a simple wrapper in `lib/widgets/` and a more advanced version in `lib/electrical_components/`. The reusable_components.dart file contains the `JJTextField` that needs copper border styling.

## Approach

I'll create a comprehensive implementation plan to address all TODO items:

## Approach

### 1. **Update JJTextField Component for Copper Borders**

Modify `JJTextField` in `reusable_components.dart` to add copper borders to all text fields throughout the app, matching the electrical theme.

### 2. **Add Electrical Circuit Background to Onboarding Screens**

Wrap the auth screen and onboarding steps screen with the `ElectricalCircuitBackground` widget to match the rest of the app.

### 3. **Fix Auth Screen Issues**

The tab bar is already implemented, but ensure all text fields have copper borders (handled by step 1).

### 4. **Fix Onboarding Steps Screen - Step 1**

- Center the `_buildStepHeader` widget
- Adjust state dropdown and zip code layout (state dropdown to 1/2 width, zip code expanded)
- Implement Next button functionality to create/update user document in Firestore

### 5. **Fix Onboarding Steps Screen - Steps 2 & 3**

- Implement Next button functionality for Step 2 to save data and navigate to Step 3
- Implement Next button functionality for Step 3 to save data and navigate to home screen
- All text fields will automatically get copper borders from step 1

The implementation will maintain all existing functionality while adding the requested visual and functional improvements.

### Reasoning

I started by reading the TODO.md file which contained a comprehensive list of issues organized by screen. I then explored the codebase structure to understand the app architecture, finding it's a Flutter app for IBEW electrical workers. I examined the key files including the auth screen, onboarding steps screen, app theme, and reusable components to understand the current implementation. I also searched for electrical circuit background usage patterns throughout the app to understand how to apply them consistently to the onboarding screens.

## Mermaid Diagram

sequenceDiagram
    participant User
    participant AuthScreen
    participant OnboardingSteps
    participant JJTextField
    participant FirestoreService
    participant HomeScreen

    User->>AuthScreen: Sign Up/Sign In
    Note over AuthScreen: Enhanced tab bar with<br/>copper borders & circuit background
    AuthScreen->>OnboardingSteps: Navigate to onboarding
    
    Note over OnboardingSteps: Step 1: Basic Information<br/>(with circuit background)
    User->>OnboardingSteps: Fill in personal details
    Note over JJTextField: All text fields have<br/>copper borders
    User->>OnboardingSteps: Click Next
    OnboardingSteps->>FirestoreService: Save Step 1 data
    FirestoreService-->>OnboardingSteps: Success
    OnboardingSteps->>OnboardingSteps: Navigate to Step 2
    
    Note over OnboardingSteps: Step 2: Professional Details
    User->>OnboardingSteps: Fill in IBEW details
    User->>OnboardingSteps: Click Next
    OnboardingSteps->>FirestoreService: Save Step 2 data
    FirestoreService-->>OnboardingSteps: Success
    OnboardingSteps->>OnboardingSteps: Navigate to Step 3
    
    Note over OnboardingSteps: Step 3: Preferences & Feedback
    User->>OnboardingSteps: Fill in preferences
    User->>OnboardingSteps: Click Complete
    OnboardingSteps->>FirestoreService: Save all data & mark complete
    FirestoreService-->>OnboardingSteps: Success
    OnboardingSteps->>HomeScreen: Navigate to home

## Proposed File Changes

### lib\design_system\components\reusable_components.dart(MODIFY)

References:

- lib\design_system\app_theme.dart

## Add Copper Border to JJTextField Component

Update the `JJTextField` widget (lines 216-293) to include copper borders matching the electrical theme:

1. **Modify the TextFormField decoration** to add copper borders:
   - Change the `decoration` property in the `TextFormField` widget
   - Add explicit border styling with `AppTheme.accentCopper` color
   - Set border width to `AppTheme.borderWidthCopper` (2.5)
   - Apply copper border to all states: `enabledBorder`, `focusedBorder`, `errorBorder`, and `focusedErrorBorder`

2. **Implementation details**:
   - For `enabledBorder`: Use `OutlineInputBorder` with `AppTheme.accentCopper` color and `AppTheme.borderWidthMedium` width
   - For `focusedBorder`: Use `OutlineInputBorder` with `AppTheme.accentCopper` color and `AppTheme.borderWidthCopper` width (thicker when focused)
   - For `errorBorder`: Keep `AppTheme.errorRed` color with `AppTheme.borderWidthMedium` width
   - For `focusedErrorBorder`: Keep `AppTheme.errorRed` color with `AppTheme.borderWidthCopper` width
   - Maintain existing `borderRadius` of `AppTheme.radiusMd`
   - Keep all other properties (fillColor, contentPadding, prefixIcon, suffixIcon, etc.) unchanged

This change will automatically apply copper borders to all text fields throughout the app, including the auth screen and all three onboarding steps.

### lib\screens\onboarding\auth_screen.dart(MODIFY)

References:

- lib\electrical_components\circuit_board_background.dart
- lib\screens\jobs\jobs_screen.dart
- lib\design_system\components\reusable_components.dart(MODIFY)

## Add Electrical Circuit Background to Auth Screen

Wrap the entire screen body with the `ElectricalCircuitBackground` widget to match the electrical theme used throughout the app:

1. **Import the background widget** at the top of the file:
   - Add: `import '../../electrical_components/circuit_board_background.dart';`

2. **Wrap the Scaffold body** (line 266):
   - Replace the current `SafeArea` widget with a `Stack` containing:
     - `ElectricalCircuitBackground` as the bottom layer with `opacity: 0.08` and `density: ComponentDensity.high`
     - The existing `SafeArea` widget with all its children as the top layer

3. **Update Scaffold backgroundColor** (line 265):
   - Change from `AppTheme.white` to `Colors.transparent` to allow the circuit background to show through

This matches the pattern used in other screens like `jobs_screen.dart` and `home_screen.dart`. The copper borders on text fields will be handled by the `JJTextField` component update in `reusable_components.dart`. The enhanced tab bar is already implemented (lines 313-728).

### lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)

References:

- lib\electrical_components\circuit_board_background.dart
- lib\services\firestore_service.dart
- lib\design_system\components\reusable_components.dart(MODIFY)
- lib\models\user_model.dart

## Add Electrical Circuit Background and Fix All Issues

### 1. Add Electrical Circuit Background

**Import the background widget** at the top of the file:

- Add: `import '../../electrical_components/circuit_board_background.dart';`

**Wrap the Scaffold body** (line 294):

- Replace the current `Column` with a `Stack` containing:
  - `ElectricalCircuitBackground` as the bottom layer with `opacity: 0.08` and `density: ComponentDensity.high`
  - The existing `Column` widget with all its children as the top layer

**Update Scaffold backgroundColor** (line 277):

- Change from `AppTheme.white` to `Colors.transparent`

### 2. Fix Step 1 Header Alignment

**Center the `_buildStepHeader` widget** (lines 386-390):

- Wrap the `_buildStepHeader` call in a `Center` widget
- Alternatively, modify the `_buildStepHeader` method (lines 972-1011) to wrap the entire `Column` in a `Center` widget or add `crossAxisAlignment: CrossAxisAlignment.center` to the Column

### 3. Fix Step 1 State Dropdown and Zip Code Layout

**Modify the Row containing State and Zip Code** (lines 475-536):

- Change the `Expanded` widget for the state dropdown (line 477) from `flex: 2` to `flex: 1` (this makes it half the width)
- Change the `Expanded` widget for the zip code field (line 521) from `flex: 1` to `flex: 2` (this expands it to take remaining space)

This will make the state dropdown half its current size and expand the zip code field to fill the remaining space.

### 4. Implement Next Button Functionality for Step 1

**Update the `_nextStep` method** (lines 152-161):

- Before calling `_pageController.nextPage()` for step 0, add logic to save Step 1 data to Firestore
- Create a new private method `_saveStep1Data()` that:
  - Gets the current user from `FirebaseAuth.instance.currentUser`
  - Creates a partial user document with Step 1 fields (firstName, lastName, phone, address1, address2, city, state, zipcode)
  - Uses `FirestoreService().updateUser()` or creates the document if it doesn't exist
  - Shows a loading indicator during save
  - Shows error message if save fails
  - Only proceeds to next step if save succeeds

**Modify `_canProceed()` method** (lines 253-272):

- The validation for Step 1 is already correct

### 5. Implement Next Button Functionality for Step 2

**Update the `_nextStep` method** (lines 152-161):

- Before calling `_pageController.nextPage()` for step 1, add logic to save Step 2 data
- Create a new private method `_saveStep2Data()` that:
  - Updates the user document with Step 2 fields (homeLocal, ticketNumber, classification, isWorking, booksOn)
  - Uses `FirestoreService().updateUser()` with the current user's UID
  - Shows loading indicator and error handling
  - Only proceeds to next step if save succeeds

### 6. Implement Next Button Functionality for Step 3

**Update the `_completeOnboarding` method** (lines 172-251):

- This method already saves all data and navigates to home
- Ensure it's being called correctly when `_currentStep == _totalSteps - 1`
- The method already:
  - Creates a complete `UserModel` with all fields from all 3 steps
  - Saves to Firestore using `FirestoreService().createUser()`
  - Marks onboarding as complete
  - Shows success message
  - Navigates to home screen

**Note**: The copper borders for all text fields will be automatically applied by the `JJTextField` component update in `reusable_components.dart`.

### Implementation Pattern

For the save functionality, follow this pattern:

```dart
Future<void> _saveStep1Data() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No authenticated user');
    
    final firestoreService = FirestoreService();
    await firestoreService.updateUser(
      uid: user.uid,
      userData: {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address1': _address1Controller.text.trim(),
        'address2': _address2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipcode': int.parse(_zipcodeController.text.trim()),
      },
    );
  } catch (e) {
    if (mounted) {
      JJSnackBar.showError(
        context: context,
        message: 'Error saving data. Please try again.',
      );
    }
    rethrow;
  }
}
```

Apply similar patterns for `_saveStep2Data()`.
