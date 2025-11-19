# Onboarding Flow - Comprehensive Test Plan

## Document Information
**Version:** 1.0
**Last Updated:** 2025-11-19
**Status:** Active
**Priority:** Critical

## Executive Summary

This test plan covers comprehensive testing of the three-step onboarding flow for the Journeyman Jobs application. The onboarding process includes per-step data persistence to Firestore, which is currently **UNTESTED** with real Firestore integration. User data loss during signup represents a critical risk that must be addressed.

---

## Table of Contents
1. [Data Flow Analysis](#data-flow-analysis)
2. [Critical Risk Areas](#critical-risk-areas)
3. [Test Scenarios](#test-scenarios)
4. [Manual Testing Procedures](#manual-testing-procedures)
5. [Automated Test Recommendations](#automated-test-recommendations)
6. [Test Coverage Gaps](#test-coverage-gaps)

---

## Data Flow Analysis

### Step 1: Basic Information
**File:** `/lib/screens/onboarding/onboarding_steps_screen.dart` (lines 191-233)
**Function:** `_saveStep1Data()`

#### Data Saved to Firestore
```dart
{
  'firstName': String,        // REQUIRED
  'lastName': String,         // REQUIRED
  'phoneNumber': String,      // REQUIRED
  'address1': String,         // REQUIRED
  'address2': String?,        // OPTIONAL
  'city': String,             // REQUIRED
  'state': String,            // REQUIRED (dropdown selection from 50 US states)
  'zipcode': int,             // REQUIRED (parsed from text, digits only)
}
```

#### Validation Logic
- All required fields checked for non-empty values (line 360-366)
- Zipcode validated as numeric input only (line 644)
- No server-side validation yet implemented

---

### Step 2: Professional Details
**File:** `/lib/screens/onboarding/onboarding_steps_screen.dart` (lines 235-274)
**Function:** `_saveStep2Data()`

#### Data Saved to Firestore
```dart
{
  'homeLocal': int,                   // REQUIRED (parsed from text)
  'ticketNumber': String,             // REQUIRED
  'classification': String,           // REQUIRED (from predefined list)
  'isWorking': bool,                  // Required (defaults to false)
  'booksOn': String?,                 // OPTIONAL but CRITICAL for book management
}
```

#### Validation Logic
- Required fields: homeLocal, ticketNumber, classification (line 368-370)
- `booksOn` is optional but critical for monthly resignation management
- Classification selected from enum: `Classification.all`

---

### Step 3: Preferences & Feedback
**File:** `/lib/screens/onboarding/onboarding_steps_screen.dart` (lines 276-355)
**Function:** `_completeOnboarding()`

#### Data Saved to Firestore
```dart
{
  'constructionTypes': List<String>,      // REQUIRED (multi-select)
  'hoursPerWeek': String?,                // OPTIONAL
  'perDiemRequirement': String?,          // OPTIONAL
  'preferredLocals': String?,             // OPTIONAL
  'networkWithOthers': bool,              // Defaults to false
  'careerAdvancements': bool,             // Defaults to false
  'betterBenefits': bool,                 // Defaults to false
  'higherPayRate': bool,                  // Defaults to false
  'learnNewSkill': bool,                  // Defaults to false
  'travelToNewLocation': bool,            // Defaults to false
  'findLongTermWork': bool,               // Defaults to false
  'careerGoals': String?,                 // OPTIONAL (max 3 lines)
  'howHeardAboutUs': String?,             // OPTIONAL
  'lookingToAccomplish': String?,         // OPTIONAL
  'onboardingStatus': OnboardingStatus.complete,
}
```

#### Additional Data Created
- All data from Steps 1 and 2 included in final UserModel
- `createdTime`: Set to current DateTime
- `username`: Derived from email (before @ symbol)
- `role`: Set to 'electrician'
- `lastActive`: Set to current Timestamp

#### Validation Logic
- Only `constructionTypes` required (must have at least one selection)
- All other fields optional

---

## Critical Risk Areas

### 🔴 Critical Risks

1. **Network Failure During Step Transitions**
   - **Risk:** User completes Step 1, network fails, proceeds to Step 2
   - **Impact:** Step 1 data lost, partial profile created
   - **Current Handling:** Exception caught but rethrown (line 227), blocks progression
   - **Test Priority:** HIGH

2. **Data Type Conversion Failures**
   - **Risk:** Non-numeric input in zipcode or homeLocal fields
   - **Impact:** `FormatException` when parsing to int
   - **Current Handling:** Input formatters prevent invalid input, but no try-catch on parse
   - **Test Priority:** HIGH

3. **Firebase Auth Session Expiration**
   - **Risk:** User starts onboarding, auth token expires mid-flow
   - **Impact:** All save operations fail with "No authenticated user"
   - **Current Handling:** Exception thrown (line 196, 240)
   - **Test Priority:** CRITICAL

4. **Partial Data Persistence**
   - **Risk:** Steps 1 & 2 saved, Step 3 fails
   - **Impact:** User profile incomplete, onboarding status not updated
   - **Current Handling:** No rollback mechanism
   - **Test Priority:** HIGH

### ⚠️ High Risks

5. **Optional Field Edge Cases**
   - **Risk:** `address2`, `booksOn`, `careerGoals` etc. with unexpected characters
   - **Impact:** Firestore validation errors or data corruption
   - **Current Handling:** `.trim()` only, no sanitization
   - **Test Priority:** MEDIUM

6. **State Dropdown Not Selected**
   - **Risk:** User proceeds without selecting state
   - **Impact:** Empty string saved to Firestore
   - **Current Handling:** Validation checks `_stateController.text.isNotEmpty`
   - **Test Priority:** MEDIUM

7. **Concurrent Save Operations**
   - **Risk:** User rapidly clicks "Next" multiple times
   - **Impact:** Duplicate Firestore writes, race conditions
   - **Current Handling:** `_isSaving` flag prevents duplicate calls
   - **Test Priority:** LOW

---

## Test Scenarios

### Happy Path Scenarios

#### HP-01: Complete Onboarding Flow - All Required Fields
**Objective:** Verify successful onboarding with all required data

**Prerequisites:**
- Valid Firebase Auth session
- Stable network connection
- Clean Firestore environment

**Steps:**
1. Start onboarding flow
2. Step 1: Enter all required fields (first name, last name, phone, address1, city, state, zipcode)
3. Click "Next"
4. Verify Step 1 data saved to Firestore
5. Step 2: Enter all required fields (ticketNumber, homeLocal, classification)
6. Toggle "Currently Working" switch
7. Click "Next"
8. Verify Step 2 data saved to Firestore
9. Step 3: Select at least one construction type
10. Click "Complete"
11. Verify all data saved to Firestore
12. Verify `onboardingStatus` = "complete"
13. Verify redirect to home screen

**Expected Results:**
- All data persisted correctly
- Success snackbar shows after each step
- User redirected to home after 2 seconds
- Firestore document contains complete UserModel

**Test Data:**
```dart
Step 1:
- firstName: "John"
- lastName: "Electrician"
- phoneNumber: "555-123-4567"
- address1: "123 Main St"
- city: "Boston"
- state: "MA"
- zipcode: "02108"

Step 2:
- ticketNumber: "12345678"
- homeLocal: "103"
- classification: "Journeyman Wireman"
- isWorking: true

Step 3:
- constructionTypes: ["Commercial", "Industrial"]
```

---

#### HP-02: Complete Onboarding Flow - With All Optional Fields
**Objective:** Verify optional fields saved correctly

**Steps:**
1. Follow HP-01 steps
2. Additionally fill:
   - Step 1: address2 = "Apt 4B"
   - Step 2: booksOn = "Book 1, Local 103 Book 2"
   - Step 3: All optional fields populated

**Expected Results:**
- Optional fields saved to Firestore with correct values
- Null-safe handling works for optional fields

---

#### HP-03: Multi-Step Navigation - Back and Forth
**Objective:** Verify data persists when navigating between steps

**Steps:**
1. Complete Step 1, click "Next"
2. Click "Back" button
3. Verify Step 1 data still populated in form
4. Modify one field
5. Click "Next" again
6. Verify updated data saved to Firestore

**Expected Results:**
- Form state maintained when navigating back
- Modified data correctly updated in Firestore

---

### Error Scenarios

#### ERR-01: Network Offline - Step 1 Save
**Objective:** Verify error handling when network unavailable during Step 1 save

**Prerequisites:**
- Valid Firebase Auth session
- Network disabled before clicking "Next"

**Steps:**
1. Fill all Step 1 required fields
2. Disable network connection
3. Click "Next"
4. Observe error handling

**Expected Results:**
- Error snackbar displayed: "Error saving data. Please try again."
- User remains on Step 1
- No progression to Step 2
- No data saved to Firestore
- Form data preserved in controllers

**Current Gap:** No specific timeout handling, generic error message

---

#### ERR-02: Network Offline - Step 2 Save
**Objective:** Verify error handling when network unavailable during Step 2 save

**Prerequisites:**
- Step 1 already completed successfully
- Network disabled before Step 2 save

**Steps:**
1. Complete Step 1 (network online)
2. Disable network
3. Fill Step 2 fields
4. Click "Next"

**Expected Results:**
- Same as ERR-01
- Step 1 data remains saved in Firestore
- User can retry Step 2 save when network restored

---

#### ERR-03: Network Offline - Complete Onboarding
**Objective:** Verify error handling during final onboarding completion

**Prerequisites:**
- Steps 1 & 2 completed
- Network disabled before completing Step 3

**Steps:**
1. Complete Steps 1 and 2
2. Disable network
3. Fill Step 3 fields
4. Click "Complete"

**Expected Results:**
- Error snackbar displayed
- User remains on Step 3
- `onboardingStatus` not updated to "complete"
- User not redirected to home

**Critical Risk:** Steps 1 & 2 data saved, but onboarding incomplete. User may be in limbo state.

---

#### ERR-04: Firebase Auth Session Expired
**Objective:** Verify behavior when auth token expires during onboarding

**Prerequisites:**
- Simulate auth token expiration

**Steps:**
1. Start onboarding
2. Simulate Firebase Auth session expiration
3. Attempt to save any step

**Expected Results:**
- Exception thrown: "No authenticated user"
- Error snackbar displayed
- User redirected to login screen (ideal)

**Current Gap:** No automatic redirect to login on auth failure

---

#### ERR-05: Invalid Data Type - Zipcode
**Objective:** Verify handling of non-numeric zipcode input

**Prerequisites:**
- User attempts to bypass input formatters

**Steps:**
1. Attempt to paste "ABCDE" into zipcode field
2. Attempt to type special characters

**Expected Results:**
- Input formatter prevents non-numeric input
- Only digits 0-9 accepted

**Note:** Input formatter on line 644 prevents this, but parse on line 209 has no try-catch

---

#### ERR-06: Invalid Data Type - Home Local
**Objective:** Verify handling of non-numeric homeLocal input

**Steps:**
1. Attempt to enter non-numeric homeLocal
2. Click "Next" on Step 2

**Expected Results:**
- Input formatter prevents non-numeric input
- Parse succeeds with numeric-only input

**Note:** Input formatter on line 696 prevents invalid input

---

#### ERR-07: Firestore Permission Denied
**Objective:** Verify behavior when user lacks write permissions

**Prerequisites:**
- Firestore rules configured to deny write for test user

**Steps:**
1. Fill Step 1 fields
2. Click "Next"

**Expected Results:**
- Firestore throws permission denied exception
- Error snackbar displayed
- User remains on Step 1

**Current Gap:** Generic error message, doesn't distinguish permission errors

---

#### ERR-08: Rapid Button Clicks - Duplicate Saves
**Objective:** Verify protection against rapid "Next" button clicks

**Steps:**
1. Fill Step 1 fields
2. Rapidly click "Next" button 5 times

**Expected Results:**
- `_isSaving` flag prevents duplicate saves
- Only one Firestore write operation
- User progresses to Step 2 only once

**Verification:** Check Firestore logs for duplicate writes

---

### Edge Case Scenarios

#### EDGE-01: Empty Optional Fields
**Objective:** Verify null-safe handling of optional fields

**Steps:**
1. Complete onboarding
2. Leave all optional fields empty:
   - address2
   - booksOn
   - hoursPerWeek
   - perDiemRequirement
   - preferredLocals
   - careerGoals
   - howHeardAboutUs
   - lookingToAccomplish

**Expected Results:**
- Firestore saves `null` for optional string fields
- No errors thrown
- UserModel correctly deserializes with null values

**Test Data Verification:**
```dart
'address2': null,
'booksOn': null,
'hoursPerWeek': null,
// etc.
```

---

#### EDGE-02: Maximum Length Input
**Objective:** Verify handling of very long text inputs

**Steps:**
1. Enter maximum length strings in all text fields
2. Attempt to save

**Expected Results:**
- No character limit enforced (potential issue)
- Firestore accepts up to 1MB per field

**Current Gap:** No `maxLength` property on text fields except line limits (e.g., line 1047 maxLines: 3)

---

#### EDGE-03: Special Characters in Text Fields
**Objective:** Verify handling of special characters and emojis

**Test Data:**
```dart
firstName: "José"
lastName: "O'Brien-Smith"
address1: "123 St. Mary's Ave, Apt #5B"
phoneNumber: "(555) 123-4567"
booksOn: "Book 1 & 2 @ Local 103"
careerGoals: "I want to 🚀 advance my career!"
```

**Expected Results:**
- All characters accepted (no sanitization)
- Firestore saves correctly
- Data retrieved without corruption

**Note:** Current implementation uses `.trim()` only, no character validation

---

#### EDGE-04: State Dropdown - Initial Value
**Objective:** Verify state dropdown behavior when not selected

**Steps:**
1. Leave state dropdown unselected
2. Attempt to proceed to Step 2

**Expected Results:**
- Validation fails: `_stateController.text.isEmpty`
- "Next" button disabled
- Cannot proceed

**Note:** Dropdown value is null until selected (line 611)

---

#### EDGE-05: Construction Types - Select All
**Objective:** Verify behavior when all construction types selected

**Steps:**
1. Select all 9 construction types in Step 3

**Expected Results:**
- All types saved to `constructionTypes` list
- List contains 9 elements
- No limit enforced

**Test Data:**
```dart
constructionTypes: [
  "Distribution",
  "Transmission",
  "SubStation",
  "Residential",
  "Industrial",
  "Data Center",
  "Commercial",
  "Underground",
  // Plus one more if exists
]
```

---

#### EDGE-06: Books On Field - Critical for Book Management
**Objective:** Verify `booksOn` field handling (critical for monthly resignations)

**Steps:**
1. Test with various book formats:
   - "Book 1"
   - "Book 1, Book 2"
   - "Local 103 Book 1, Local 26 Book 2"
   - Empty (null)

**Expected Results:**
- All formats accepted
- Saved as-is to Firestore
- Null saved when empty

**Critical Note:** This field is essential for book management feature (line 792-793 info message)

---

#### EDGE-07: Phone Number Formats
**Objective:** Verify various phone number formats

**Test Data:**
```
"5551234567"
"(555) 123-4567"
"555-123-4567"
"1-555-123-4567"
"+1 (555) 123-4567"
```

**Expected Results:**
- All formats accepted (no input formatter)
- Saved as entered

**Current Gap:** No phone number validation or formatting

---

#### EDGE-08: Job Search Goals - None Selected
**Objective:** Verify behavior when no job goals selected

**Steps:**
1. Complete Steps 1 and 2
2. Select construction types
3. Leave all job goal checkboxes unchecked
4. Click "Complete"

**Expected Results:**
- All boolean fields default to `false`
- Onboarding completes successfully

---

### Data Integrity Scenarios

#### DATA-01: Step 1 Data Persists Through Step 2 Failure
**Objective:** Verify Step 1 data not corrupted if Step 2 fails

**Steps:**
1. Complete Step 1 successfully
2. Verify Step 1 data in Firestore
3. Cause Step 2 save to fail (network error)
4. Verify Step 1 data unchanged in Firestore

**Expected Results:**
- Step 1 data intact
- No rollback of Step 1
- User can retry Step 2

---

#### DATA-02: Partial Data Scenario
**Objective:** Verify handling when user has Step 1 & 2 data but incomplete onboarding

**Steps:**
1. Complete Steps 1 and 2
2. Force-close app before completing Step 3
3. Reopen app
4. Check user state

**Expected Results:**
- User profile exists in Firestore
- `onboardingStatus` = "incomplete" or missing
- User redirected back to onboarding
- Step 1 & 2 data pre-populated

**Current Gap:** No mechanism to resume partial onboarding

---

#### DATA-03: Concurrent Updates From Multiple Devices
**Objective:** Verify behavior if user starts onboarding on multiple devices

**Steps:**
1. Device A: Complete Step 1
2. Device B: Complete Step 1 with different data
3. Verify Firestore state

**Expected Results:**
- Last write wins (standard Firestore behavior)
- Potential data loss on Device A

**Current Gap:** No conflict resolution

---

### Performance Scenarios

#### PERF-01: Large Text Input Performance
**Objective:** Verify performance with very large text inputs

**Steps:**
1. Enter 10,000 characters in `careerGoals` field
2. Save Step 3

**Expected Results:**
- No UI lag
- Firestore write succeeds (under 1MB limit)
- Data retrieved efficiently

---

#### PERF-02: Slow Network - Save Timeout
**Objective:** Verify behavior on slow network

**Prerequisites:**
- Network throttled to 2G speeds

**Steps:**
1. Fill Step 1
2. Click "Next"
3. Observe save operation

**Expected Results:**
- Loading state displayed (`_isSaving = true`)
- Save completes eventually
- Timeout after reasonable duration (not specified)

**Current Gap:** No explicit timeout handling

---

### Security Scenarios

#### SEC-01: XSS in Text Fields
**Objective:** Verify protection against XSS attacks

**Test Data:**
```dart
firstName: "<script>alert('XSS')</script>"
address1: "'; DROP TABLE users; --"
careerGoals: "{{ malicious_template }}"
```

**Expected Results:**
- Data saved as plain text
- No code execution
- Data retrieved safely

**Note:** Firestore stores as plain text, safe by default. Frontend must sanitize on display.

---

#### SEC-02: SQL Injection (Not Applicable)
**Note:** Firestore is NoSQL, not vulnerable to SQL injection. Test included for completeness.

---

## Manual Testing Procedures

### Test Environment Setup

#### Prerequisites
1. Flutter development environment configured
2. Firebase project with Firestore enabled
3. Test user accounts created
4. Network simulation tools (for offline testing)

#### Test Data Preparation
```dart
// Create test users in Firebase Auth
testUser1: test+onboarding1@example.com
testUser2: test+onboarding2@example.com

// Firestore test collection
Collection: users_test (use for testing, not production)
```

---

### Manual Test Execution

#### Test Case Template
```markdown
**Test ID:** [TEST-ID]
**Test Name:** [Descriptive name]
**Tester:** [Name]
**Date:** [YYYY-MM-DD]
**Build Version:** [Version number]

**Pre-conditions:**
- [List prerequisites]

**Test Steps:**
1. [Step 1]
2. [Step 2]
...

**Expected Results:**
- [Expected outcome]

**Actual Results:**
- [What actually happened]

**Status:** PASS / FAIL / BLOCKED
**Defects:** [Link to bug report if failed]
**Notes:** [Additional observations]
```

---

### Critical Manual Test Checklist

- [ ] **HP-01:** Complete onboarding with all required fields
- [ ] **HP-02:** Complete onboarding with all optional fields
- [ ] **HP-03:** Navigate back and forth between steps
- [ ] **ERR-01:** Network offline during Step 1 save
- [ ] **ERR-02:** Network offline during Step 2 save
- [ ] **ERR-03:** Network offline during complete onboarding
- [ ] **ERR-04:** Firebase Auth session expired
- [ ] **ERR-08:** Rapid button clicks
- [ ] **EDGE-01:** All optional fields empty
- [ ] **EDGE-04:** State dropdown not selected
- [ ] **EDGE-06:** Books On field variations
- [ ] **DATA-01:** Step 1 data persists through Step 2 failure
- [ ] **DATA-02:** Partial data scenario (app closed mid-flow)

---

### Manual Test Environment Configurations

#### Configuration 1: Ideal Conditions
- Device: Physical Android/iOS device
- Network: WiFi, high speed
- Firebase: Production-like environment
- Auth: Valid session, not expired

#### Configuration 2: Poor Network
- Network: Throttled to 2G/3G speeds
- Simulated packet loss: 10%

#### Configuration 3: Offline First
- Start offline
- Complete onboarding form
- Enable network
- Attempt save

---

## Automated Test Recommendations

### Unit Tests

#### 1. Validation Logic Tests
**File:** `test/screens/onboarding/onboarding_validation_test.dart`

```dart
group('Onboarding Validation', () {
  test('Step 1 - All required fields filled returns true', () {
    // Test _canProceed() for step 0
  });

  test('Step 1 - Missing required field returns false', () {
    // Test with firstName empty
  });

  test('Step 2 - Classification not selected returns false', () {
    // Test _canProceed() for step 1
  });

  test('Step 3 - No construction types selected returns false', () {
    // Test _canProceed() for step 2
  });
});
```

---

#### 2. Data Transformation Tests
**File:** `test/screens/onboarding/onboarding_data_test.dart`

```dart
group('Onboarding Data Transformation', () {
  test('Zipcode string correctly parsed to int', () {
    expect(int.parse('02108'), equals(2108));
  });

  test('Home local string correctly parsed to int', () {
    expect(int.parse('103'), equals(103));
  });

  test('Invalid zipcode throws FormatException', () {
    expect(() => int.parse('ABCDE'), throwsFormatException);
  });

  test('Optional fields set to null when empty', () {
    final address2 = ''.trim().isEmpty ? null : ''.trim();
    expect(address2, isNull);
  });
});
```

---

### Integration Tests

#### 3. Firestore Save Operations
**File:** `test/screens/onboarding/onboarding_firestore_test.dart`

```dart
group('Onboarding Firestore Integration', () {
  late FirestoreService firestoreService;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    firestoreService = FirestoreService();
    mockAuth = MockFirebaseAuth();
  });

  test('_saveStep1Data saves correct fields to Firestore', () async {
    // Arrange
    final testData = {
      'firstName': 'John',
      'lastName': 'Doe',
      'phoneNumber': '555-1234',
      'address1': '123 Main St',
      'city': 'Boston',
      'state': 'MA',
      'zipcode': 2108,
    };

    // Act
    await firestoreService.updateUser(
      uid: 'test-uid',
      data: testData,
    );

    // Assert
    final userDoc = await firestoreService.getUser('test-uid');
    expect(userDoc.data(), containsPair('firstName', 'John'));
    expect(userDoc.data(), containsPair('zipcode', 2108));
  });

  test('_saveStep1Data handles network error gracefully', () async {
    // Mock network failure
    when(mockFirestore.collection('users').doc(any).update(any))
      .thenThrow(Exception('Network error'));

    // Act & Assert
    expect(
      () => firestoreService.updateUser(uid: 'test-uid', data: {}),
      throwsException,
    );
  });

  test('_saveStep2Data saves professional details', () async {
    final testData = {
      'homeLocal': 103,
      'ticketNumber': '12345678',
      'classification': 'Journeyman Wireman',
      'isWorking': true,
      'booksOn': 'Book 1, Book 2',
    };

    await firestoreService.updateUser(uid: 'test-uid', data: testData);

    final userDoc = await firestoreService.getUser('test-uid');
    expect(userDoc.data(), containsPair('homeLocal', 103));
    expect(userDoc.data(), containsPair('booksOn', 'Book 1, Book 2'));
  });

  test('_completeOnboarding creates full user profile', () async {
    // Test full UserModel creation and save
  });
});
```

---

#### 4. Multi-Step Flow Tests
**File:** `test/screens/onboarding/onboarding_flow_test.dart`

```dart
testWidgets('Complete onboarding flow saves all data', (tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to onboarding
  await tester.tap(find.byKey(Key('start_onboarding')));
  await tester.pumpAndSettle();

  // Step 1
  await tester.enterText(find.byKey(Key('firstName')), 'John');
  await tester.enterText(find.byKey(Key('lastName')), 'Doe');
  // ... enter all required fields
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  // Verify Step 1 saved
  final step1Data = await getFirestoreUserData('test-uid');
  expect(step1Data['firstName'], equals('John'));

  // Step 2
  await tester.enterText(find.byKey(Key('ticketNumber')), '12345678');
  // ... enter all required fields
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  // Verify Step 2 saved
  final step2Data = await getFirestoreUserData('test-uid');
  expect(step2Data['ticketNumber'], equals('12345678'));

  // Step 3
  await tester.tap(find.text('Commercial'));
  await tester.tap(find.text('Complete'));
  await tester.pumpAndSettle();

  // Verify complete profile
  final finalData = await getFirestoreUserData('test-uid');
  expect(finalData['onboardingStatus'], equals('complete'));
  expect(finalData['constructionTypes'], contains('Commercial'));
});
```

---

#### 5. Error Handling Tests
**File:** `test/screens/onboarding/onboarding_error_test.dart`

```dart
testWidgets('Shows error snackbar on save failure', (tester) async {
  // Mock Firestore to throw exception
  when(mockFirestore.updateUser(any, any)).thenThrow(Exception());

  await tester.pumpWidget(MyApp());

  // Fill Step 1
  // ...
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  // Verify error snackbar
  expect(find.text('Error saving data. Please try again.'), findsOneWidget);

  // Verify user still on Step 1
  expect(find.text('Basic Information'), findsOneWidget);
});

testWidgets('Prevents duplicate saves with loading state', (tester) async {
  // Simulate slow network
  when(mockFirestore.updateUser(any, any))
    .thenAnswer((_) => Future.delayed(Duration(seconds: 2)));

  await tester.pumpWidget(MyApp());

  // Fill and click Next twice rapidly
  await tester.tap(find.text('Next'));
  await tester.tap(find.text('Next'));
  await tester.pump();

  // Verify loading state shown
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Verify only one save operation
  verify(mockFirestore.updateUser(any, any)).called(1);
});
```

---

### Widget Tests

#### 6. UI Component Tests
**File:** `test/screens/onboarding/onboarding_widget_test.dart`

```dart
testWidgets('State dropdown shows all 50 US states', (tester) async {
  await tester.pumpWidget(MyApp());

  await tester.tap(find.byType(DropdownButton<String>).first);
  await tester.pumpAndSettle();

  // Verify all states present
  expect(find.text('MA'), findsOneWidget);
  expect(find.text('CA'), findsOneWidget);
  // ... verify key states
});

testWidgets('Classification chips display correctly', (tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to Step 2
  // ...

  // Verify classification chips
  expect(find.text('Journeyman Wireman'), findsOneWidget);
  expect(find.text('Apprentice'), findsOneWidget);
});

testWidgets('Next button disabled when form invalid', (tester) async {
  await tester.pumpWidget(MyApp());

  // Leave required fields empty
  final nextButton = find.text('Next');
  final button = tester.widget<JJPrimaryButton>(find.byType(JJPrimaryButton).first);

  expect(button.onPressed, isNull); // Button disabled
});
```

---

### Mock Data for Testing

```dart
// test/fixtures/onboarding_test_data.dart

class OnboardingTestData {
  static const validStep1Data = {
    'firstName': 'John',
    'lastName': 'Electrician',
    'phoneNumber': '555-123-4567',
    'address1': '123 Main St',
    'address2': 'Apt 4B',
    'city': 'Boston',
    'state': 'MA',
    'zipcode': '02108',
  };

  static const validStep2Data = {
    'ticketNumber': '12345678',
    'homeLocal': '103',
    'classification': 'Journeyman Wireman',
    'isWorking': true,
    'booksOn': 'Book 1, Local 103 Book 2',
  };

  static const validStep3Data = {
    'constructionTypes': ['Commercial', 'Industrial'],
    'hoursPerWeek': '40-50',
    'perDiemRequirement': '150-200',
    'networkWithOthers': true,
    'higherPayRate': true,
  };

  static const edgeCaseData = {
    'firstName': 'José',
    'lastName': "O'Brien-Smith",
    'phoneNumber': '(555) 123-4567',
    'address1': "123 St. Mary's Ave, Apt #5B",
    'booksOn': 'Book 1 & 2 @ Local 103',
    'careerGoals': 'I want to 🚀 advance!',
  };
}
```

---

## Test Coverage Gaps

### Current Test Coverage Analysis

Based on review of `/test/data/services/firestore_service_test.dart`:

#### ✅ Existing Coverage
- FirestoreService basic operations (createUser, updateUser, getUser)
- User profile existence checks
- Collection access (users, jobs, locals)
- Error handling for network errors and permission denied
- IBEW-specific data handling

#### ❌ Missing Coverage (Critical Gaps)

1. **Onboarding-Specific Integration Tests**
   - No tests for `_saveStep1Data()` function
   - No tests for `_saveStep2Data()` function
   - No tests for `_completeOnboarding()` function
   - No tests for multi-step flow with real Firestore

2. **Widget Tests**
   - No tests for `OnboardingStepsScreen` widget
   - No tests for step validation logic (`_canProceed()`)
   - No tests for navigation between steps
   - No tests for form state preservation

3. **Error Recovery Tests**
   - No tests for auth session expiration during onboarding
   - No tests for partial data recovery
   - No tests for retry logic after failures

4. **Data Integrity Tests**
   - No tests for data consistency across steps
   - No tests for concurrent saves from multiple devices
   - No tests for rollback scenarios

5. **Performance Tests**
   - No tests for large input handling
   - No tests for slow network conditions
   - No load testing for Firestore writes

---

### Recommended Test File Structure

```
test/
├── screens/
│   └── onboarding/
│       ├── onboarding_steps_screen_test.dart       (Widget tests)
│       ├── onboarding_validation_test.dart         (Unit tests)
│       ├── onboarding_data_test.dart               (Unit tests)
│       ├── onboarding_firestore_test.dart          (Integration)
│       ├── onboarding_flow_test.dart               (Integration)
│       ├── onboarding_error_test.dart              (Integration)
│       └── fixtures/
│           └── onboarding_test_data.dart           (Test data)
```

---

### Test Prioritization

#### Priority 1 (Immediate - Before Production)
1. Integration test for complete onboarding flow (HP-01)
2. Error handling test for network failures (ERR-01, ERR-02, ERR-03)
3. Auth session expiration test (ERR-04)
4. Data persistence verification across steps (DATA-01)

#### Priority 2 (Next Sprint)
5. Edge case tests (EDGE-01 through EDGE-08)
6. Widget tests for all three steps
7. Performance tests for large inputs (PERF-01, PERF-02)

#### Priority 3 (Future Enhancements)
8. Concurrent update handling (DATA-03)
9. Security tests (SEC-01)
10. Comprehensive manual test suite execution

---

## Test Execution Schedule

### Phase 1: Manual Testing (Week 1)
- Execute critical manual test cases (Priority 1)
- Document defects in issue tracker
- Verify error handling works as expected

### Phase 2: Automated Unit Tests (Week 2)
- Implement validation logic tests
- Implement data transformation tests
- Achieve >80% unit test coverage

### Phase 3: Automated Integration Tests (Week 3)
- Implement Firestore save operation tests
- Implement multi-step flow tests
- Test error recovery scenarios

### Phase 4: Automated Widget Tests (Week 4)
- Implement UI component tests
- Test navigation and state management
- Test form validation in UI

### Phase 5: Regression Testing (Week 5)
- Execute full test suite
- Performance and load testing
- Security testing

---

## Defect Management

### Defect Severity Levels

**Critical (P0):**
- Data loss during onboarding
- Auth session failures blocking progress
- Firestore save failures with no error handling

**High (P1):**
- Network errors causing poor UX
- Validation logic failures allowing invalid data
- Missing error messages

**Medium (P2):**
- UI glitches during step transitions
- Optional field edge cases
- Performance degradation on slow networks

**Low (P3):**
- UI polish issues
- Non-critical error message improvements

---

## Success Metrics

### Test Coverage Goals
- **Unit Tests:** >80% coverage for validation and data logic
- **Integration Tests:** 100% coverage for save operations
- **Widget Tests:** >70% coverage for UI components
- **Manual Tests:** 100% execution of Priority 1 scenarios

### Quality Gates
- All P0 defects resolved before production
- All P1 defects resolved or documented workarounds
- Zero data loss scenarios in testing
- <2% failure rate in integration tests

---

## Recommendations

### Immediate Actions Required

1. **Add Try-Catch to Parse Operations**
   - Wrap `int.parse()` calls in try-catch (lines 209, 246, 298, 299)
   - Provide user-friendly error messages for parse failures

2. **Implement Auth Session Monitoring**
   - Check `FirebaseAuth.instance.currentUser` is not null before each save
   - Redirect to login if session expired

3. **Add Explicit Timeout Handling**
   - Set timeout for Firestore operations (e.g., 30 seconds)
   - Show timeout-specific error messages

4. **Improve Error Messages**
   - Distinguish between network, auth, permission, and validation errors
   - Provide actionable guidance (e.g., "Check your internet connection")

5. **Implement Partial Onboarding Resume**
   - Detect incomplete onboarding on app start
   - Pre-populate forms with saved data
   - Allow user to resume from last completed step

6. **Add Input Validation**
   - Phone number format validation
   - Email format validation (if email input added)
   - Maximum length constraints on text fields

7. **Implement Rollback Mechanism**
   - Consider using Firestore transactions for multi-step saves
   - Or implement a "draft" status separate from final save

---

## Appendix

### A. Related Files
- `/lib/screens/onboarding/onboarding_steps_screen.dart` - Main onboarding UI
- `/lib/services/onboarding_service.dart` - Onboarding state management
- `/lib/services/firestore_service.dart` - Firestore operations
- `/lib/models/user_model.dart` - User data model
- `/lib/domain/enums/onboarding_status.dart` - Onboarding status enum

### B. External Dependencies
- `firebase_auth` - User authentication
- `cloud_firestore` - Database operations
- `shared_preferences` - Local storage for onboarding completion status

### C. Test Environment Setup
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## Document Version History

| Version | Date       | Author | Changes                      |
|---------|------------|--------|------------------------------|
| 1.0     | 2025-11-19 | QA Agent | Initial comprehensive test plan |

---

**End of Document**
