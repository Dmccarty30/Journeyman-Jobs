# QA/QC Methodology: Home Screen Personalized Greeting Testing

This document outlines a conceptual methodology for Quality Assurance and Quality Control (QA/QC) of the personalized greeting on the Home Screen, covering various user profile states and dynamic name display.

## 1. Objectives

*   Verify that the personalized greeting correctly displays the user's first and last name.
*   Ensure that fallback greetings are appropriately used when name data is missing.
*   Validate the styling and responsiveness of the greeting across different name lengths and UI states (loading, error).

## 2. Test Scenarios

### 2.1. User with Complete Name

*   **Scenario**: User has both `firstName` and `lastName` populated in their `UserModel`.
*   **Expected Behavior**: The greeting displays "Welcome back, [FirstName] [LastName]!".

### 2.2. User with Only First Name

*   **Scenario**: User has only `firstName` populated, `lastName` is empty.
*   **Expected Behavior**: The greeting displays "Welcome back, [FirstName]!". (Assuming `trim()` handles the extra space).

### 2.3. User with Only Last Name

*   **Scenario**: User has only `lastName` populated, `firstName` is empty.
*   **Expected Behavior**: The greeting displays "Welcome back, [LastName]!". (Assuming `trim()` handles the extra space).

### 2.4. User with No Name Data

*   **Scenario**: User has both `firstName` and `lastName` empty or null.
*   **Expected Behavior**: The greeting displays the fallback "Welcome back, IBEW Member!".

### 2.5. User with Very Long Name

*   **Scenario**: User has an exceptionally long `firstName` and `lastName`.
*   **Expected Behavior**: The greeting handles the long text gracefully (e.g., ellipses, text wrapping, does not overflow layout).

### 2.6. Loading State of User Data

*   **Scenario**: While the `userModelStreamProvider` is in a loading state.
*   **Expected Behavior**: A loading indicator (e.g., `CircularProgressIndicator`) is displayed.

### 2.7. Error State of User Data Retrieval

*   **Scenario**: An error occurs when fetching the `UserModel` (e.g., network error, Firestore permissions).
*   **Expected Behavior**: A graceful error message or a generic fallback greeting is displayed instead of a crash.

## 3. Verification Steps

*   **UI Display**: Visually inspect the Home Screen to ensure the greeting text is correct, properly formatted, and styled according to `AppTheme`.
*   **Data Accuracy**: Compare the displayed name with the actual `firstName` and `lastName` from the test `UserModel` data.
*   **Conditional Rendering**: Verify that the correct greeting (personalized vs. fallback) is shown based on the user's data.
*   **Responsiveness**: Check how the greeting appears on different device sizes and orientations.

## 4. Test Data Setup

*   **Mock `UserModel` Objects**: Create `UserModel` instances with various combinations of `firstName` and `lastName` (empty, partial, full, long).
*   **Mock Providers**: Use Riverpod's `overrideWith` or `ProviderScope` to inject these mock `UserModel` states into `userModelStreamProvider` for testing.

## 5. Automation Strategy (Conceptual)

*   **Integration Tests**:
    *   Utilize Flutter's `integration_test` framework to simulate app startup and verify the greeting on the Home Screen for different authenticated user states.
    *   Inject mock user data to control test scenarios.
*   **Widget Tests**:
    *   Create widget tests specifically for the Home Screen's greeting section.
    *   Use `ProviderScope` to provide different `AsyncValue` states for `userModelStreamProvider` (data, loading, error) and verify UI rendering.
*   **Unit Tests**:
    *   If any helper functions are created for `displayName` logic, unit test them in isolation.
*   **Mocking**: Use `mockito` or `mocktail` to mock `FirebaseAuth` and `FirebaseFirestore` dependencies for isolating parts of the authentication and data retrieval logic during testing.
