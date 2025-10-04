# Summary (quick)

GOD — I reviewed the three files you uploaded. Current behavior:

- The user Firestore document is created only once: in OnboardingStepsScreen._completeOnboarding (when the user taps "Complete").
- AuthScreen only authenticates the user (email/password, Google, Apple) and then always navigates to onboarding (`context.go(AppRouter.onboarding)`).
- Onboarding collects all fields across 3 steps, builds a complete UserModel, and calls `FirestoreService.createUser(uid, userModel.toJson())`.
- On successful save the app marks onboarding complete via `OnboardingService.markOnboardingComplete()` and navigates to the home screen.

This means: creation happens at the expected moment (end of onboarding) and all form inputs are written at that time — provided `FirestoreService.createUser` actually writes all fields and does so safely (merge vs overwrite). I cannot see `FirestoreService` or `UserModel` internals from the files you provided, so a few important caveats and recommended fixes follow.

---

## Potential issues I found (priority-ordered)

1. Firestore overwrite vs merge
   - If `FirestoreService.createUser` uses `set(docRef, data)` without merge, it will overwrite any existing doc (good or bad). If the doc already exists (e.g., social sign-in created a minimal doc), you may unintentionally wipe fields. You need to confirm whether createUser uses `SetOptions(merge: true)` or `update()` if exists.

2. No pre-check / pre-fill of existing user doc
   - You always send the user to onboarding after sign-in. If the user already has a document (or partially completed onboarding), onboarding will not pre-fill values — they’ll start blank and overwrite. Also the user can be forced to repeat onboarding even if already completed unless `OnboardingService` prevents this earlier in the flow. You should check user doc / onboarding-complete flag upon auth and route appropriately or prefill the form.

3. Parsing integer fields without safeguards
   - You parse zipcode and homeLocal using `int.parse(...)`. While you restrict input with `FilteringTextInputFormatter.digitsOnly`, defensive code should still use `int.tryParse(...)` to avoid runtime exceptions in edge cases.

4. Classification saved as empty string when null
   - You set `classification: _selectedClassification ?? ''`. It might be cleaner to save `null` if not provided, so the doc better reflects missing data.

5. No incremental saves / crash risk
   - All user data is sent in one call at the end. If something fails (network, crash) the user could lose all input. Consider saving per-step (partial updates) or autosave.

6. Race / duplication of onboarding
   - AuthScreen always navigates to onboarding, even if the user already completed onboarding. Need to check `OnboardingService` usage and guard routing.

7. Apple sign-in edge-cases
   - Apple may not provide an email (or it might be transient). Ensure you handle null email cases (used for username/email defaulting).

8. Missing submit-state / dedupe protection
   - No `_isSaving` flag in OnboardingStepsScreen._completeOnboarding to prevent double taps. Add it to avoid duplicated writes.

9. No user-doc permission/security check shown
   - Ensure Firestore rules only allow users to write to their own doc and validate fields server-side where necessary.

---

### Concrete fixes / recommendations (with code examples)

1) Ensure createUser uses set(..., SetOptions(merge: true)) or update-if-exists

- If you control FirestoreService, implement createUser as an upsert:

```dart
// Example: FirestoreService.createUser upsert implementation
Future<void> createUser({required String uid, required Map<String, dynamic> userData}) {
  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  // Use set with merge to avoid wiping other fields
  return docRef.set(userData, SetOptions(merge: true));
}
```

If you already call update() when doc exists, that is fine — just confirm.

2) Prefill onboarding if doc exists (fetch on init)

- In OnboardingStepsScreen.initState (or early), load user document and populate fields to avoid overwriting and to allow editing.

Example snippet to fetch and prefill:

```dart
@override
void initState() {
  super.initState();
  _loadExistingUser();
}

Future<void> _loadExistingUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return;
  final data = doc.data()!;
  setState(() {
    _firstNameController.text = data['firstName'] ?? '';
    _lastNameController.text = data['lastName'] ?? '';
    _phoneController.text = data['phoneNumber'] ?? '';
    _address1Controller.text = data['address1'] ?? '';
    _address2Controller.text = data['address2'] ?? '';
    _cityController.text = data['city'] ?? '';
    _stateController.text = data['state'] ?? '';
    _zipcodeController.text = data['zipcode']?.toString() ?? '';
    _homeLocalController.text = data['homeLocal']?.toString() ?? '';
    _ticketNumberController.text = data['ticketNumber'] ?? '';
    _selectedClassification = data['classification'];
    _isWorking = data['isWorking'] ?? false;
    _booksOnController.text = data['booksOn'] ?? '';
    _selectedConstructionTypes.clear();
    if (data['constructionTypes'] is List) {
      _selectedConstructionTypes.addAll(List<String>.from(data['constructionTypes']));
    }
    _selectedHoursPerWeek = data['hoursPerWeek'];
    _selectedPerDiem = data['perDiemRequirement'];
    _preferredLocalsController.text = data['preferredLocals'] ?? '';
    _careerGoalsController.text = data['careerGoals'] ?? '';
    _howHeardAboutUsController.text = data['howHeardAboutUs'] ?? '';
    _lookingToAccomplishController.text = data['lookingToAccomplish'] ?? '';
    // ... any other fields
  });
}
```

3) Use safe integer parsing
Replace:

```dart
zipcode: int.parse(_zipcodeController.text.trim()),
homeLocal: int.parse(_homeLocalController.text.trim()),
```

with:

```dart
zipcode: int.tryParse(_zipcodeController.text.trim()) ?? 0, // or null
homeLocal: int.tryParse(_homeLocalController.text.trim()) ?? 0,
```

Decide whether `0` or `null` makes sense for your model.

4) Protect from duplicate submits and show loading state
Add an `_isSaving` flag in OnboardingStepsScreen:

```dart
bool _isSaving = false;

void _completeOnboarding() async {
  if (_isSaving) return;
  setState(() => _isSaving = true);
  try {
    // existing save logic...
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}
```

Wire `_isSaving` to disable the Complete button UI.

5) Consider incremental saves (per step)

- For resilience, call `createUser` with partial data after each step using set(merge: true). This avoids losing everything if something fails at the last step.

Example pattern at step change:

```dart
Future<void> _saveStep(int step) async {
  final user = FirebaseAuth.instance.currentUser!;
  final Map<String, dynamic> partial = {/* only fields from this step */};
  await FirestoreService().createUser(uid: user.uid, userData: partial); // upsert
}
```

Call `_saveStep(_currentStep)` when user taps Next.

6) Route guard after auth (prevent re-onboarding)

- In AuthScreen (or the app start), check if user has completed onboarding; route accordingly:

Pseudo:

```dart
void _navigateAfterSignIn() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final onboardingCompleteFromDoc = doc.exists && doc.data()?['onboardingStatus'] == 'complete';
  final onboardingLocalFlag = await OnboardingService().isOnboardingComplete();
  if (onboardingCompleteFromDoc || onboardingLocalFlag) {
    context.go(AppRouter.home);
  } else {
    context.go(AppRouter.onboarding);
  }
}
```

7) Save correct types for optional fields

- For optional fields don't store empty string to represent "missing". Use null:

```dart
classification: _selectedClassification, // allow null
booksOn: _booksOnController.text.trim().isEmpty ? null : _booksOnController.text.trim(),
```

8) Confirm OnboardingService.markOnboardingComplete semantics

- Ensure it persists in a reliable place the app checks on startup (SharedPreferences/local storage) and that that combined with Firestore doc state prevents re-showing onboarding.

9) Apple sign-in: ensure email exists or request it

- Apple sometimes returns null email; if so, you must prompt user for an email before creating/updating the user doc. Otherwise `user.email` may be null and username fallback might be odd.

---

### Quick checklist for you to confirm (I can check code if you upload these files)

- [ ] Inspect FirestoreService.createUser: does it use set(doc, merge: true) or update when doc exists?
- [ ] Inspect UserModel.toJson: are all fields mapped correctly and with correct keys/types?
- [ ] Inspect OnboardingService: does markOnboardingComplete persist a value that is read at app start to suppress onboarding?
- [ ] Verify Firestore security rules prevent a user from creating/updating other users’ docs.
- [ ] Add `_isSaving` flag to OnboardingStepsScreen and disable the Complete button while saving.
- [ ] Add prefetch/prefill logic (example above) to avoid overwriting existing data.
- [ ] Add safe int parsing (use tryParse) and better null handling.
- [ ] Add route guard in AuthScreen or app startup to send already-onboarded users direct to home.

---

### If you want, next steps I can do for you

- Inspect FirestoreService and UserModel (upload those files) and verify the mapping and whether createUser uses merge/update.
- Provide a precise patch (diff) to:
  - pre-fill controllers from Firestore,
  - add _isSaving protection,
  - change parsing to tryParse,
  - modify createUser to merge.
- Add routing guard to AuthScreen to skip onboarding for already-completed users.

Tell me which of the above you want me to implement or inspect next and I’ll produce the exact code changes.
