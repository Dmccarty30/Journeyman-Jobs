# QA/QC Methodology: Onboarding Step 2 - Field Persistence and Navigation Flow

This document outlines a conceptual methodology for Quality Assurance and Quality Control (QA/QC) of the professional details step (Step 2) in the onboarding process, focusing on field persistence and navigation flow.

## 1. Objectives

*   Verify that all data entered in Step 2 fields is correctly saved to the existing user document in Firestore.
*   Ensure that form validation provides appropriate feedback to the user.
*   Validate the navigation flow from Step 2 to Step 3, ensuring it occurs only upon successful data persistence.
*   Test robustness against various scenarios, including valid inputs, invalid inputs, and backend errors.

## 2. Test Scenarios

### 2.1. Successful Data Persistence and Navigation

*   **Scenario**: User fills all required fields in Step 2 with valid data and taps "Next".
*   **Expected Behavior**:
    *   All form fields pass validation (especially "Ticket Number" and "Home Local Number").
    *   `_saveStep2Data()` method is called without errors.
    *   The existing user document in the `users` Firestore collection (identified by `FirebaseAuth.currentUser.uid`) is updated with the new data (`homeLocal`, `ticketNumber`, `classification`, `isWorking`, `booksOn`).
    *   A success message (`JJSnackBar.showSuccess`) is displayed to the user.
    *   The app navigates smoothly to Step 3 of the onboarding process.

### 2.2. Form Validation Failures

*   **Scenario**: User leaves required fields empty or enters invalid data (e.g., non-numeric home local/ticket number).
*   **Expected Behavior**:
    *   Form validation, triggered by `_step2FormKey.currentState!.validate()`, prevents submission.
    *   Clear error messages are displayed next to the invalid input fields (`JJTextField`'s validator messages).
    *   The "Next" button remains clickable but `_saveStep2Data()` returns early, and no data is saved.
    *   No navigation occurs to Step 3.

### 2.3. Backend Errors during Data Persistence

*   **Scenario**: User taps "Next" with valid data, but a network issue or Firestore update error occurs during `firestoreService.updateUser()`.
*   **Expected Behavior**:
    *   An error is caught in the `_saveStep2Data()` method.
    *   An error message (`JJSnackBar.showError`) is displayed to the user.
    *   The UI indicates that the save operation failed (e.g., loading indicator disappears).
    *   The user remains on Step 2, allowing them to retry.
    *   The user document in Firestore remains unchanged.

### 2.4. Classification Selection Logic

*   **Scenario**: User selects and deselects different classifications via `JJChip` widgets.
*   **Expected Behavior**:
    *   `_selectedClassification` state variable updates correctly.
    *   The visual state of `JJChip` (selected/unselected) updates accordingly.

## 3. Verification Steps

*   **Firestore Data Inspection**: Manually or programmatically inspect the `users` collection in Firestore to confirm that the user document is updated correctly with Step 2 data.
*   **UI Feedback**: Visually confirm the display of success/error snackbars and the behavior of validation messages next to text fields.
*   **Navigation**: Confirm correct navigation to Step 3 on success, and no navigation on validation or backend failure.
*   **State Management**: Verify that the `_isSaving` state is correctly managed (loading indicator appears/disappears).

## 4. Test Data Setup

*   **Firebase Authentication**: Ensure a valid test user account exists, preferably one that has completed Step 1.
*   **Clean Firestore State**: For each test run, ensure the test user's document in Firestore is in a known state for updating.
*   **Mock Data**: Use mock classifications and other professional details to test various inputs.

## 5. Automation Strategy (Conceptual)

*   **Integration Tests**:
    *   Utilize Flutter's `integration_test` framework to simulate user interactions (filling fields, selecting chips, tapping buttons) for Step 2.
    *   Verify UI behavior, including validation messages and snackbar displays.
    *   Interact with a mocked or dedicated test Firestore instance to verify document updates.
*   **Unit Tests**:
    *   Test validation logic for individual input fields.
    *   Test `_saveStep2Data()` method in isolation, mocking `FirebaseAuth` and `FirestoreService` to ensure correct user document updates.
*   **Mocking**: Use `mockito` or `mocktail` to mock external dependencies like `FirebaseAuth`, `FirebaseFirestore`, and `OnboardingService` during unit and widget testing.
