# User Auth and Onboarding

## Observations

The authentication and onboarding flow is broken due to several issues:

1. **Missing initial user document**: Sign-up creates Firebase Auth account but doesn't create Firestore user document, causing subsequent `update()` calls to fail
2. **Wrong Firestore operations**: Onboarding steps use `update()` which requires existing document; should use `set()` with merge
3. **No onboarding status check**: Sign-in doesn't check if user completed onboarding, always routes to onboarding screen
4. **Enum/string mismatch**: `createUser()` hardcodes string `'pending'` but enum only has `incomplete` and `complete`
5. **Overwrite issue**: `_completeOnboarding()` calls `createUser()` which would overwrite partial data from steps 1-2
6. **Social auth gaps**: Google and Apple sign-in have same issues as email sign-up

The fix requires: creating initial document on sign-up, adding merge method to FirestoreService, updating onboarding steps to use merge, adding status check on sign-in, and standardizing on enum values.

### Approach

- **Phase 1: Fix FirestoreService**

- Add `setUserWithMerge()` method that uses `set()` with `SetOptions(merge: true)`
- Standardize on `OnboardingStatus.incomplete` instead of string `'pending'`
- Update `createUser()` to use `'incomplete'` string (for backward compatibility with enum parsing)

- **Phase 2: Fix Authentication Flow**

- In `auth_screen.dart`, after successful sign-up (email/Google/Apple), create minimal Firestore document with uid, email, createdTime, and onboardingStatus: 'incomplete'
- In sign-in flow, fetch user document after authentication and check `onboardingStatus` field
- Route to onboarding if status is `'incomplete'` or null, otherwise route to home

- **Phase 3: Fix Onboarding Steps**

- Replace `updateUser()` calls in `_saveStep1Data()` and `_saveStep2Data()` with `setUserWithMerge()`
- Replace `createUser()` call in `_completeOnboarding()` with `setUserWithMerge()` and set onboardingStatus to `'complete'`
- Remove full UserModel construction in `_completeOnboarding()`, just merge final step data with status update

This approach uses merge semantics throughout, allowing incremental updates without document existence checks, and properly routes users based on their onboarding completion status.

### Reasoning

I explored the codebase by reading the key files mentioned by the user: `auth_screen.dart`, `onboarding_steps_screen.dart`, `firestore_service.dart`, `user_model.dart`, `onboarding_service.dart`, and `app_router.dart`. I then searched for all references to `onboardingStatus`, `createUser`, and `OnboardingStatus` enum usage to understand the complete picture. I discovered that the enum only has `incomplete` and `complete` values, but the code hardcodes string `'pending'`. I also found that `_completeOnboarding()` incorrectly uses `createUser()` which would overwrite data, and that sign-in doesn't check onboarding status. The searches revealed no other places creating user documents or checking status, confirming the scope of changes needed.

## Mermaid Diagram

sequenceDiagram
    actor User
    participant AuthScreen
    participant FirebaseAuth
    participant FirestoreService
    participant OnboardingSteps
    participant AppRouter

    Note over User,AppRouter: Sign-Up Flow (New User)
    User->>AuthScreen: Enter email/password, click Create
    AuthScreen->>FirebaseAuth: createUserWithEmailAndPassword()
    FirebaseAuth-->>AuthScreen: UserCredential
    AuthScreen->>FirestoreService: createUser(uid, {email})
    FirestoreService-->>AuthScreen: Document created with status='incomplete'
    AuthScreen->>AppRouter: Navigate to /onboarding
    
    Note over User,AppRouter: Onboarding Flow (3 Steps)
    User->>OnboardingSteps: Fill Step 1 (name, address, etc)
    OnboardingSteps->>FirestoreService: setUserWithMerge(uid, step1Data)
    FirestoreService-->>OnboardingSteps: Merged into document
    
    User->>OnboardingSteps: Fill Step 2 (professional details)
    OnboardingSteps->>FirestoreService: setUserWithMerge(uid, step2Data)
    FirestoreService-->>OnboardingSteps: Merged into document
    
    User->>OnboardingSteps: Fill Step 3 (preferences), click Complete
    OnboardingSteps->>FirestoreService: setUserWithMerge(uid, {step3Data, status='complete'})
    FirestoreService-->>OnboardingSteps: Final merge with complete status
    OnboardingSteps->>AppRouter: Navigate to /home
    
    Note over User,AppRouter: Sign-In Flow (Returning User)
    User->>AuthScreen: Enter credentials, click Sign In
    AuthScreen->>FirebaseAuth: signInWithEmailAndPassword()
    FirebaseAuth-->>AuthScreen: UserCredential
    AuthScreen->>FirestoreService: getUser(uid)
    FirestoreService-->>AuthScreen: User document
    
    alt Onboarding Incomplete
        AuthScreen->>AppRouter: Navigate to /onboarding
    else Onboarding Complete
        AuthScreen->>AppRouter: Navigate to /home
    end

## Proposed File Changes

### lib\services\firestore_service.dart(MODIFY)

## Add setUserWithMerge Method

Add a new method `setUserWithMerge()` after the existing `updateUser()` method (around line 89):

**Purpose**: Provide a way to update user documents using merge semantics, allowing updates to non-existent documents and incremental field updates without overwriting existing data.

**Implementation**:

- Accept parameters: `required String uid` and `required Map<String, dynamic> data`
- Use `usersCollection.doc(uid).set(data, SetOptions(merge: true))`
- Wrap in try-catch and throw descriptive exception on error
- Follow same error handling pattern as existing methods

## Update createUser Method

Modify the `createUser()` method (lines 20-33) to use `'incomplete'` instead of `'pending'`:

**Change**: Replace the hardcoded string `'onboardingStatus': 'pending'` with `'onboardingStatus': 'incomplete'`

**Reason**: This aligns with the `OnboardingStatus` enum which has `incomplete` and `complete` values, ensuring proper parsing in `UserModel.fromFirestore()`

### lib\screens\onboarding\auth_screen.dart(MODIFY)

References:

- lib\services\firestore_service.dart(MODIFY)
- lib\navigation\app_router.dart

## Fix Sign-Up Flow - Create Initial User Document

Modify `_signUpWithEmail()` method (lines 91-131):

**After line 100** (after `createUserWithEmailAndPassword` succeeds):

- Get the created user from the UserCredential result
- Import and instantiate `FirestoreService`
- Call `createUser()` with minimal data:
  - `uid`: user.uid
  - `userData`: Map containing `email` (user.email), no other fields needed since createUser adds createdTime and onboardingStatus automatically
- Wrap in try-catch to handle Firestore errors separately from auth errors
- If Firestore creation fails, show error but still navigate to onboarding (user can complete profile there)
- Keep existing navigation to onboarding

**Import needed**: Add `import '../../services/firestore_service.dart';` at top of file

## Fix Sign-Up Flow - Google Sign-In

Modify `_signInWithGoogle()` method (lines 175-222):

**After line 190** (after `signInWithCredential` succeeds):

- Get the signed-in user from Firebase Auth
- Check if user document exists in Firestore using `FirestoreService().userProfileExists(user.uid)`
- If document doesn't exist (new user), create it with `createUser()` using uid and email
- Wrap in try-catch for error handling
- Then proceed with existing navigation logic

## Fix Sign-Up Flow - Apple Sign-In

Modify `_signInWithApple()` method (lines 224-257):

**After line 240** (after `signInWithCredential` succeeds):

- Same logic as Google sign-in: check if document exists, create if new user
- Use `FirestoreService().userProfileExists()` and `createUser()`

## Fix Sign-In Flow - Check Onboarding Status

Modify `_signInWithEmail()` method (lines 133-173):

**Replace the navigation logic** (lines 144-146):

- After successful sign-in, get the current user from Firebase Auth
- Fetch user document from Firestore using `FirestoreService().getUser(user.uid)`
- Check if document exists:
  - If doesn't exist: create minimal document and navigate to onboarding
  - If exists: check `onboardingStatus` field from document data
    - If status is `'incomplete'` or null: navigate to onboarding
    - If status is `'complete'`: navigate to home using `context.go(AppRouter.home)`
- Wrap in try-catch, on error default to navigating to onboarding (safe fallback)

## Update Google Sign-In Navigation

Modify `_signInWithGoogle()` method navigation (line 193):

**Replace `_navigateToOnboarding()` call** with same onboarding status check logic as email sign-in:

- Fetch user document and check onboardingStatus
- Route to onboarding or home based on status

## Update Apple Sign-In Navigation

Modify `_signInWithApple()` method navigation (line 243):

**Replace `_navigateToOnboarding()` call** with same onboarding status check logic as email sign-in:

- Fetch user document and check onboardingStatus
- Route to onboarding or home based on status

### lib\screens\onboarding\onboarding_steps_screen.dart(MODIFY)

References:

- lib\services\firestore_service.dart(MODIFY)

## Fix Step 1 Data Saving

Modify `_saveStep1Data()` method (lines 191-233):

**Replace the `updateUser()` call** (lines 199-211) with `setUserWithMerge()`:

- Change method name from `updateUser` to `setUserWithMerge`
- Keep same parameters: `uid` and `data` map
- Keep all the same field mappings (firstName, lastName, phoneNumber, address1, address2, city, state, zipcode)
- This allows the method to work whether the document exists or not, and merges new fields without overwriting existing ones

## Fix Step 2 Data Saving

Modify `_saveStep2Data()` method (lines 235-274):

**Replace the `updateUser()` call** (lines 243-252) with `setUserWithMerge()`:

- Change method name from `updateUser` to `setUserWithMerge`
- Keep same parameters: `uid` and `data` map
- Keep all the same field mappings (homeLocal, ticketNumber, classification, isWorking, booksOn)

## Fix Onboarding Completion

Modify `_completeOnboarding()` method (lines 276-355):

**Replace the entire UserModel construction and createUser call** (lines 285-327) with a simpler approach:

1. **Remove** the full UserModel construction (lines 285-320)
2. **Replace** the `createUser()` call (lines 324-327) with `setUserWithMerge()`
3. **Build a data map** containing only Step 3 fields plus onboardingStatus:
   - `constructionTypes`: _selectedConstructionTypes.toList()
   - `hoursPerWeek`: _selectedHoursPerWeek
   - `perDiemRequirement`: _selectedPerDiem
   - `preferredLocals`: _preferredLocalsController.text.trim() (null if empty)
   - `networkWithOthers`: _networkWithOthers
   - `careerAdvancements`: _careerAdvancements
   - `betterBenefits`: _betterBenefits
   - `higherPayRate`: _higherPayRate
   - `learnNewSkill`: _learnNewSkill
   - `travelToNewLocation`: _travelToNewLocation
   - `findLongTermWork`: _findLongTermWork
   - `careerGoals`: _careerGoalsController.text.trim() (null if empty)
   - `howHeardAboutUs`: _howHeardAboutUsController.text.trim() (null if empty)
   - `lookingToAccomplish`: _lookingToAccomplishController.text.trim() (null if empty)
   - `onboardingStatus`: `'complete'` (as string, not enum)
   - `username`: Generate from email if not already set (user.email?.split['@'](0) ?? 'user')
   - `role`: `'electrician'`
   - `displayName`: Construct from firstName and lastName if available, or empty string
   - `lastActive`: `FieldValue.serverTimestamp()`

4. **Call** `firestoreService.setUserWithMerge(uid: user.uid, data: dataMap)`
5. **Keep** the OnboardingService.markOnboardingComplete() call (line 331)
6. **Keep** the success message and navigation logic (lines 333-345)

**Reason**: This approach merges the final step data with existing data from steps 1 and 2, rather than overwriting everything. The merge operation ensures all previously saved fields are preserved.

**Note**: Add `import 'package:cloud_firestore/cloud_firestore.dart';` at top if not already present (needed for FieldValue.serverTimestamp())

### lib\services\resilient_firestore_service.dart(MODIFY)

References:

- lib\services\firestore_service.dart(MODIFY)

## Add setUserWithMerge Wrapper

Add a new method after the existing `createUser()` wrapper (around line 93):

**Purpose**: Wrap the new `setUserWithMerge()` method with retry logic for resilience

**Implementation**:

- Override the `setUserWithMerge()` method from parent `FirestoreService`
- Use `_executeWithRetryFuture<void>()` wrapper
- Call `super.setUserWithMerge(uid: uid, data: data)`
- Set operationName to `'setUserWithMerge'`
- Follow same pattern as existing `createUser()` wrapper (lines 85-93)

This ensures the new merge method has the same retry and error handling capabilities as other Firestore operations.
