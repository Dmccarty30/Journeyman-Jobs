# QA/QC Methodology: Onboarding Step 1 - User Document Creation Workflow

This document outlines a conceptual methodology for Quality Assurance and Quality Control (QA/QC) of the user document creation workflow during the first step of the onboarding process.

## 1. Objectives

*   Verify successful creation of a new user document in Firestore upon completion of Onboarding Step 1.
*   Ensure all data entered in Step 1 fields is correctly mapped and persisted to the `UserModel`.
*   Validate the user experience, including proper form validation and confirmation feedback.
*   Test robustness against various scenarios, including valid inputs, invalid inputs, and network issues.

## 2. Test Scenarios

### 2.1. Successful User Document Creation

*   **Scenario**: User fills all required fields in Step 1 with valid data and taps "Next".
*   **Expected Behavior**:
    *   All form fields pass validation.
    *   `_saveStep1Data()` method is called without errors.
    *   A new document is created in the `users` Firestore collection with the `FirebaseAuth.currentUser.uid` as its ID.
    *   All data from the Step 1 fields (`firstName`, `lastName`, `phoneNumber`, `address1`, `address2`, `city`, `state`, `zipcode`) is accurately reflected in the corresponding fields of the created Firestore document.
    *   `onboardingStatus` in the Firestore document is set to `OnboardingStatus.incomplete`.
    *   A success message (`JJSnackBar.showSuccess`) is displayed to the user.
    *   The app navigates to Step 2 of the onboarding process.

### 2.2. Form Validation Failures

*   **Scenario**: User leaves required fields empty or enters invalid data (e.g., invalid phone number format, non-numeric zip code, invalid email for associated AuthScreen).
*   **Expected Behavior**:
    *   Form validation (`_validateEmail`, `_validatePassword` etc., though primarily UI validation for Step 1) prevents submission.
    *   Clear error messages are displayed next to the invalid input fields.
    *   The "Next" button remains disabled or unclickable until valid data is provided for all required fields.
    *   No Firestore document is created or modified.

### 2.3. Network/Backend Errors during Document Creation

*   **Scenario**: User taps "Next" with valid data, but a network issue or Firestore write error occurs during `firestoreService.createUser()`.
*   **Expected Behavior**:
    *   An error is caught in the `_saveStep1Data()` method.
    *   An error message (`JJSnackBar.showError`) is displayed to the user.
    *   The UI indicates that the save operation failed (e.g., loading indicator disappears).
    *   The user remains on Step 1, allowing them to retry.
    *   No partial or erroneous document is created in Firestore (or proper rollback occurs).

## 3. Verification Steps

*   **Firestore Data Inspection**: Manually or programmatically inspect the `users` collection in Firestore to confirm document creation, ID, and field values.
*   **UI Feedback**: Visually confirm the display of success/error snackbars and the behavior of the "Next" button.
*   **Navigation**: Confirm correct navigation to Step 2 on success, and no navigation on failure.
*   **State Management**: Verify that the `_isSaving` state is correctly managed (loading indicator appears/disappears).

## 4. Test Data Setup

*   **Firebase Authentication**: Ensure valid test user accounts are available for sign-in/sign-up.
*   **Clean Firestore State**: For each test run, ensure the Firestore `users` collection (or specific test user documents) is in a known, clean state.

## 5. Automation Strategy (Conceptual)

*   **Integration Tests**:
    *   Utilize Flutter's `integration_test` framework to simulate user interactions (filling fields, tapping buttons) across the UI.
    *   Verify UI behavior, including validation messages and snackbar displays.
    *   Interact with a mocked or dedicated test Firestore instance to verify document creation and data integrity.
*   **Unit Tests**:
    *   Test validation logic for individual input fields.
    *   Test `_saveStep1Data()` method in isolation, mocking `FirebaseAuth` and `FirestoreService` to ensure correct `UserModel` construction and service calls.
*   **Mocking**: Use `mockito` or `mocktail` to mock external dependencies like `FirebaseAuth`, `FirebaseFirestore`, and `OnboardingService` during unit and widget testing.
