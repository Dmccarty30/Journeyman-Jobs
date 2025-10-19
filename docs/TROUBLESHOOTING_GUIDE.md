# Troubleshooting Guide - Journeyman Jobs App

## Overview

This guide provides solutions to common issues encountered during development, testing, and production use of the Journeyman Jobs Flutter application.

**Quick Reference:**
- [Authentication Issues](#authentication-issues)
- [Onboarding Problems](#onboarding-problems)
- [Job Preferences Issues](#job-preferences-issues)
- [UI/Layout Problems](#uilayout-problems)
- [Firebase/Firestore Errors](#firebasefirestore-errors)
- [Build and Deployment](#build-and-deployment)
- [Accessibility Issues](#accessibility-issues)

---

## Authentication Issues

### Issue 1: "Guest User" Appears After Successful Login

**Symptom:**
```
Home screen shows "Welcome back! Guest User"
even after successful email/Google/Apple sign-in
```

**Root Cause:**
Race condition between Firebase Auth initialization and UI render. The authentication state hasn't propagated to Riverpod provider before the home screen builds.

**Solution (Implemented in Phase 1):**
```dart
// In home_screen.dart

// Watch auth initialization status BEFORE accessing auth state
final authInit = ref.watch(authInitializationProvider);

// Show skeleton screen while auth initializes
if (authInit.isLoading) {
  return const HomeSkeletonScreen();
}

// Now safe to check auth state
final authState = ref.watch(authProvider);
if (!authState.isAuthenticated || authState.user == null) {
  return GuestUserUI();
}

// User authenticated - extract display name with fallbacks
final displayName = authState.user?.displayName
    ?? authState.user?.email?.split('@')[0]
    ?? 'Brother';
```

**Verification:**
```bash
# 1. Sign out completely
# 2. Close app
# 3. Reopen app
# 4. Sign in with Google
# 5. Verify "Welcome Back, [Your Name]!" appears immediately
```

**Debug Commands:**
```dart
// Add to home_screen.dart for debugging
debugPrint('Auth state: ${authState.isAuthenticated}');
debugPrint('User: ${authState.user?.displayName}');
debugPrint('Email: ${authState.user?.email}');
```

---

### Issue 2: "Permission Denied" Error on Home Screen Load

**Symptom:**
```
[cloud_firestore/permission-denied]
The caller does not have permission to execute the specified operation.
```

**Root Cause:**
Attempting to access Firestore before Firebase Auth has initialized. Firestore security rules deny access to unauthenticated requests.

**Solution:**
```dart
// In home_screen.dart
final authInit = ref.watch(authInitializationProvider);

if (authInit.isLoading) {
  // Critical: Show skeleton, do NOT access Firestore yet
  return const HomeSkeletonScreen();
}

// Now auth is initialized, safe to load Firestore data
ref.read(jobsProvider.notifier).loadJobs();
```

**Firebase Security Rules Check:**
```javascript
// firestore.rules
match /users/{userId} {
  // Ensure this rule exists
  allow read: if request.auth != null && request.auth.uid == userId;
}

match /jobs/{jobId} {
  // Jobs should be readable by authenticated users
  allow read: if request.auth != null;
}
```

**Verification:**
```bash
# 1. Clear app data
# 2. Restart app
# 3. Sign in
# 4. Check console for NO permission denied errors
# 5. Verify home screen loads without errors
```

---

### Issue 3: Sign-Out Doesn't Redirect to Welcome Screen

**Symptom:**
```
Clicking Sign Out in Settings screen does nothing
or stays on Settings screen after sign-out
```

**Root Cause:**
Navigation not properly calling `AppRouter.goToWelcome(context)` after Firebase sign-out.

**Solution:**
```dart
// In settings_screen.dart
Future<void> _signOut() async {
  try {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      // Use AppRouter helper method for proper navigation
      AppRouter.goToWelcome(context);
    }
  } catch (e) {
    if (mounted) {
      JJSnackBar.showError(
        context: context,
        message: 'Error signing out. Please try again.',
      );
    }
  }
}
```

**AppRouter Navigation Helper:**
```dart
// In app_router.dart
static void goToWelcome(BuildContext context) {
  context.go(AppRouter.welcome);  // Use go() not push()
}
```

**Verification:**
```bash
# 1. Sign in to app
# 2. Navigate to Settings
# 3. Tap Sign Out
# 4. Verify redirect to Welcome screen
# 5. Verify Back button doesn't return to Settings
```

---

## Onboarding Problems

### Issue 4: Duplicate Fields in Firestore User Document

**Symptom:**
```json
// Firestore users/{uid} document shows duplicate fields:
{
  "ticketNumber": "A123456",
  "ticket_number": "A123456",   // Duplicate!
  "homeLocal": 46,
  "home_local": 369,             // Duplicate with different value!
}
```

**Root Cause:**
Multiple Firestore writes during onboarding (Step 1, Step 2, Step 3 completion) with inconsistent field naming.

**Solution (Implemented in Phase 1):**
```dart
// In onboarding_steps_screen.dart

void _nextStep() async {
  if (_currentStep == 0) {
    _validateStep1();  // ✅ Validation only, NO Firebase write
    _pageController.nextPage(...);
  } else if (_currentStep == 1) {
    _validateStep2();  // ✅ Validation only, NO Firebase write
    _pageController.nextPage(...);
  } else {
    // ✅ SINGLE consolidated write with ALL data
    await _completeOnboarding();
  }
}

void _completeOnboarding() async {
  // Build complete data structure with consistent naming
  final completeUserData = {
    'firstName': _firstNameController.text.trim(),
    'lastName': _lastNameController.text.trim(),
    'homeLocal': int.parse(_homeLocalController.text.trim()),
    'ticketNumber': _ticketNumberController.text.trim(),
    // ... all 30+ fields with camelCase naming
  };

  // SINGLE FIRESTORE WRITE - prevents duplicates
  await FirestoreService().setUserWithMerge(
    uid: user.uid,
    data: completeUserData,
  );
}
```

**Data Cleanup Script (if needed):**
```javascript
// Run in Firebase Console
const admin = require('firebase-admin');
const db = admin.firestore();

async function cleanupDuplicates() {
  const users = await db.collection('users').get();

  for (const doc of users.docs) {
    const data = doc.data();
    const updates = {};

    // Remove snake_case duplicates
    if (data.ticket_number) {
      updates.ticket_number = admin.firestore.FieldValue.delete();
    }
    if (data.home_local) {
      updates.home_local = admin.firestore.FieldValue.delete();
    }

    if (Object.keys(updates).length > 0) {
      await doc.ref.update(updates);
      console.log(`Cleaned: ${doc.id}`);
    }
  }
}

cleanupDuplicates();
```

**Verification:**
```bash
# 1. Clear existing user data
# 2. Create new test user
# 3. Complete all 3 onboarding steps
# 4. Check Firestore document in Firebase Console
# 5. Verify NO duplicate fields (no snake_case variants)
# 6. Verify only camelCase field names present
```

---

### Issue 5: Onboarding Validation Errors Not Displayed

**Symptom:**
```
Tapping "Next" on onboarding step with empty fields
does nothing - no error message shown to user
```

**Root Cause:**
Exception thrown during validation but not caught and displayed to user.

**Solution:**
```dart
void _nextStep() async {
  if (_isSaving) return;

  try {
    if (_currentStep == 0) {
      _validateStep1();  // May throw exception
      _pageController.nextPage(...);
    }
  } catch (e) {
    // CRITICAL: Catch validation errors and show to user
    debugPrint('Validation error: $e');

    if (mounted) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ElectricalNotificationType.error,
      );
    }
  }
}
```

**Enhanced Validation with Specific Messages:**
```dart
void _validateStep1() {
  if (_firstNameController.text.trim().isEmpty) {
    throw Exception('First name is required');
  }
  if (_lastNameController.text.trim().isEmpty) {
    throw Exception('Last name is required');
  }
  if (_phoneController.text.trim().isEmpty) {
    throw Exception('Phone number is required');
  }
  // ... additional validations
}
```

**Verification:**
```bash
# 1. Navigate to onboarding Step 1
# 2. Leave all fields empty
# 3. Tap "Next" button
# 4. Verify electrical-themed error toast appears
# 5. Verify specific error message (e.g., "First name is required")
```

---

### Issue 6: Classification Names Display as camelCase

**Symptom:**
```
Classification chips show:
"journeymanLineman" instead of "Journeyman Lineman"
```

**Root Cause:**
Enum values stored in camelCase not formatted for display.

**Solution (Implemented in Phase 2):**
```dart
String _formatClassification(String classification) {
  // Convert camelCase to Title Case
  // "journeymanLineman" → "Journeyman Lineman"
  return classification
    .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
    .trim()
    .split(' ')
    .map((word) => word[0].toUpperCase() + word.substring(1))
    .join(' ');
}

// Apply formatting in UI
Text(_formatClassification(classification))
```

**Verification:**
```bash
# 1. Navigate to onboarding Step 2
# 2. View classification chips
# 3. Verify all display as "Journeyman Lineman", "Inside Wireman", etc.
# 4. NOT "journeymanLineman", "insideWireman"
```

---

## Job Preferences Issues

### Issue 7: Job Preferences Not Persisting to Firebase

**Symptom:**
```
1. Open Settings → Job Preferences
2. Select classifications and construction types
3. Tap "Save Preferences"
4. Success toast appears
5. Close app
6. Reopen app
7. Preferences are lost (empty)
```

**Root Cause:**
`_savePreferences()` method not actually writing to Firestore, or not reading from correct Firestore path on reload.

**Solution (Implemented in Phase 1):**
```dart
// In user_job_preferences_dialog.dart

Future<void> _savePreferences() async {
  setState(() => _isSaving = true);

  try {
    final preferences = UserJobPreferences(
      classifications: _selectedClassifications.toList(),
      constructionTypes: _selectedConstructionTypes.toList(),
      preferredLocals: _parsePreferredLocals(_preferredLocalsController.text),
      hoursPerWeek: _selectedHoursPerWeek,
      perDiemRequirement: _selectedPerDiem,
      minWage: null,
      maxDistance: null,
    );

    // CRITICAL: Save via Riverpod provider
    await ref.read(userPreferencesProvider.notifier).savePreferences(
      widget.userId,
      preferences,
    );

    // CRITICAL: Also update main user document
    await FirestoreService().setUserWithMerge(
      uid: widget.userId,
      data: {
        'hasSetJobPreferences': true,
        'jobPreferences': preferences.toJson(),
        'lastActive': FieldValue.serverTimestamp(),
      },
    );

    if (mounted) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Preferences saved successfully',
        type: ElectricalNotificationType.success,
      );
      Navigator.of(context).pop(true);
    }
  } catch (e) {
    debugPrint('Error saving preferences: $e');
    if (mounted) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to save preferences: ${e.toString()}',
        type: ElectricalNotificationType.error,
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
```

**Firestore Document Structure:**
```json
{
  "users": {
    "{userId}": {
      "hasSetJobPreferences": true,
      "jobPreferences": {
        "classifications": ["Journeyman Lineman"],
        "constructionTypes": ["Industrial", "Utility"],
        "hoursPerWeek": "40-50",
        "perDiemRequirement": "150-200",
        "preferredLocals": [46, 191, 76]
      }
    }
  }
}
```

**Verification:**
```bash
# 1. Sign in to app
# 2. Navigate to Settings → Job Preferences
# 3. Select preferences (classifications, construction types, etc.)
# 4. Tap "Save Preferences"
# 5. Verify success toast
# 6. Close dialog
# 7. Force quit app
# 8. Reopen app
# 9. Navigate to Settings → Job Preferences
# 10. Verify all previously saved preferences are pre-selected
# 11. Check Firebase Console → Firestore → users/{uid} → jobPreferences
```

---

### Issue 8: Job Preferences Dialog "Save Preferences" Button Overflow

**Symptom:**
```
RenderFlex overflowed by XX pixels on the right.
(Overflow error when Save Preferences button text is long)
```

**Root Cause:**
Button text too long for small screen widths, fixed width constraints causing overflow.

**Solution (Implemented in Phase 3):**
```dart
// In user_job_preferences_dialog.dart - _buildFooter()

Widget _buildFooter() {
  return Container(
    padding: const EdgeInsets.all(AppTheme.spacingMd),
    decoration: BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(AppTheme.radiusLg),
      ),
      border: Border(
        top: BorderSide(color: AppTheme.borderLight),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ✅ Wrapped in Flexible to prevent overflow
        Flexible(
          child: TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // ✅ Wrapped in Flexible with ellipsis for long text
        Flexible(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
            ),
            child: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : Text(
                  'Save Preferences',
                  overflow: TextOverflow.ellipsis,  // ✅ Handle overflow gracefully
                ),
          ),
        ),
      ],
    ),
  );
}
```

**Verification:**
```bash
# Test on multiple screen sizes:
# 1. iPhone SE (320px width) - smallest
# 2. iPhone 8 (375px width) - standard
# 3. iPhone 14 Pro Max (414px width) - large
# 4. Verify NO overflow errors in console
# 5. Verify buttons remain fully tappable
```

---

## UI/Layout Problems

### Issue 9: "Continue with Google" Button Overflow on Auth Screen

**Symptom:**
```
RenderFlex overflowed by 12 pixels on the right.
(Social sign-in buttons overflow on small screens)
```

**Root Cause:**
Fixed-width social sign-in buttons don't adapt to narrow screen widths (e.g., iPhone SE 320px).

**Solution (Implemented in Phase 2):**
```dart
// In auth_screen.dart - _buildSocialSignInButtons()

Column(
  children: [
    // ✅ Wrapped in Flexible
    Flexible(
      child: JJSocialSignInButton(
        text: 'Continue with Google',
        icon: const Icon(Icons.g_mobiledata, size: 24),
        onPressed: _signInWithGoogle,
        isLoading: _isGoogleLoading,
      ),
    ),
    const SizedBox(height: AppTheme.spacingMd),
    // ✅ Wrapped in Flexible
    Flexible(
      child: JJSocialSignInButton(
        text: 'Continue with Apple',
        icon: const Icon(Icons.apple, size: 24),
        onPressed: _signInWithApple,
        isLoading: _isAppleLoading,
      ),
    ),
  ],
),
```

**Responsive Button Component:**
```dart
// In jj_social_sign_in_button.dart
class JJSocialSignInButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,  // Full width
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon,
        label: Text(
          text,
          overflow: TextOverflow.ellipsis,  // ✅ Handle overflow
        ),
      ),
    );
  }
}
```

**Verification:**
```bash
# Test on iPhone SE (320px width):
# 1. Navigate to Auth Screen
# 2. Tap "Sign Up" tab
# 3. Scroll to social sign-in buttons
# 4. Verify NO overflow errors
# 5. Verify buttons are fully visible
# 6. Verify button text is readable (not truncated)
```

---

### Issue 10: State Dropdown Not Themed Correctly

**Symptom:**
```
State dropdown in onboarding Step 1 uses default Flutter styling
(gray borders, white background, no copper accent)
```

**Root Cause:**
Dropdown container not using AppTheme constants and electrical design system.

**Solution (Implemented in Phase 2):**
```dart
// In onboarding_steps_screen.dart - Step 1

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: AppTheme.spacingMd,
    vertical: AppTheme.spacingSm,
  ),
  decoration: BoxDecoration(
    color: AppTheme.white.withValues(alpha: 0.05),  // ✅ Themed background
    border: Border.all(
      color: AppTheme.accentCopper,                  // ✅ Copper border
      width: AppTheme.borderWidthCopperThin,
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    boxShadow: [AppTheme.shadowElectricalInfo],      // ✅ Electrical shadow
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: _stateController.text.isEmpty ? null : _stateController.text,
      hint: Text(
        'Select State',
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.white.withValues(alpha: 0.7),  // ✅ Themed hint
        ),
      ),
      dropdownColor: AppTheme.primaryNavy,  // ✅ Themed dropdown
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.white,               // ✅ Themed text
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: AppTheme.accentCopper,        // ✅ Copper icon
      ),
      items: _usStates.map((state) {
        return DropdownMenuItem(
          value: state,
          child: Text(state),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _stateController.text = value ?? '';
        });
      },
    ),
  ),
)
```

**Verification:**
```bash
# 1. Navigate to onboarding Step 1
# 2. Scroll to State dropdown
# 3. Verify copper border around dropdown
# 4. Tap dropdown to open
# 5. Verify navy background for dropdown menu
# 6. Verify white text for state options
# 7. Verify copper arrow icon
```

---

## Firebase/Firestore Errors

### Issue 11: Firestore Security Rules Blocking Reads

**Symptom:**
```
[cloud_firestore/permission-denied]
Missing or insufficient permissions.
```

**Root Cause:**
Security rules too restrictive or not matching document structure.

**Solution:**
```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User documents - users can read/write own document
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Job documents - authenticated users can read all jobs
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if false;  // Jobs created via admin/scraper only
    }

    // Union documents - public read access
    match /unions/{unionId} {
      allow read: if true;
      allow write: if false;  // Union data is static
    }
  }
}
```

**Deploy Security Rules:**
```bash
# Deploy updated rules
firebase deploy --only firestore:rules

# Test rules in Firebase Console
# Navigate to Firestore → Rules → Playground
# Test read/write operations with auth context
```

**Verification:**
```bash
# 1. Sign in to app
# 2. Navigate to Home screen
# 3. Verify jobs load without permission errors
# 4. Navigate to Unions screen
# 5. Verify union list loads
# 6. Check Flutter console for NO permission denied errors
```

---

### Issue 12: Firestore Timestamp Conversion Error

**Symptom:**
```
type '_JsonMap' is not a subtype of type 'Timestamp' in type cast
```

**Root Cause:**
Firestore timestamps stored as maps in some documents, Timestamp objects in others.

**Solution:**
```dart
// Safe timestamp parsing helper
DateTime? parseTimestamp(dynamic timestamp) {
  if (timestamp == null) return null;

  if (timestamp is Timestamp) {
    return timestamp.toDate();
  }

  if (timestamp is Map) {
    // Handle server timestamp that hasn't been written yet
    if (timestamp['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        timestamp['_seconds'] * 1000,
      );
    }
  }

  return null;
}

// Usage in model
class JobModel {
  final DateTime? postedDate;

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JobModel(
      postedDate: parseTimestamp(data['postedDate']),
      // ... other fields
    );
  }
}
```

**Verification:**
```bash
# 1. Query jobs from Firestore
# 2. Verify NO timestamp conversion errors
# 3. Verify dates display correctly in UI
# 4. Test with both new and old job documents
```

---

## Build and Deployment

### Issue 13: Android Build Fails with Multidex Error

**Symptom:**
```
Cannot fit requested classes in a single dex file
```

**Root Cause:**
Too many methods in dependencies (>64K limit for single dex).

**Solution:**
```gradle
// android/app/build.gradle

android {
    defaultConfig {
        // ... other settings
        multiDexEnabled true  // ✅ Enable multidex
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

**Verification:**
```bash
flutter clean
flutter pub get
flutter build apk --release
# Verify build succeeds
```

---

### Issue 14: iOS Build Fails - CocoaPods Error

**Symptom:**
```
[!] CocoaPods could not find compatible versions for pod "Firebase/Auth"
```

**Root Cause:**
Outdated CocoaPods dependencies or cache issues.

**Solution:**
```bash
# Navigate to iOS directory
cd ios

# Clean CocoaPods cache
pod cache clean --all
rm -rf Pods
rm Podfile.lock

# Update repository
pod repo update

# Reinstall pods
pod install

# Return to root
cd ..

# Clean and rebuild
flutter clean
flutter pub get
flutter build ios --release
```

**Verification:**
```bash
# Build should complete without errors
# Test on iOS simulator and physical device
```

---

## Accessibility Issues

### Issue 15: Screen Reader Not Announcing Form Errors

**Symptom:**
```
VoiceOver/TalkBack doesn't announce validation errors
when user attempts to proceed with invalid data
```

**Root Cause:**
Error toasts not using live regions for screen reader announcements.

**Solution (Implemented in Phase 3):**
```dart
// In jj_electrical_notifications.dart

static void showElectricalToast({
  required BuildContext context,
  required String message,
  required ElectricalNotificationType type,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Semantics(
        liveRegion: true,  // ✅ Announces to screen readers
        child: Text(message),
      ),
      backgroundColor: _getBackgroundColor(type),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}
```

**Verification:**
```bash
# iOS VoiceOver:
# 1. Settings → Accessibility → VoiceOver → Enable
# 2. Navigate to onboarding Step 1
# 3. Leave fields empty, tap Next
# 4. Verify VoiceOver announces "First name is required"

# Android TalkBack:
# 1. Settings → Accessibility → TalkBack → Enable
# 2. Repeat same test
# 3. Verify TalkBack announces error message
```

---

### Issue 16: Touch Targets Too Small for Interactive Elements

**Symptom:**
```
Small buttons and checkboxes difficult to tap
Accessibility scanner warns about touch target size
```

**Root Cause:**
Interactive elements smaller than 48x48dp minimum accessibility requirement.

**Solution (Implemented in Phase 3):**
```dart
// Wrap small interactive elements with minimum size container
InkWell(
  onTap: onPressed,
  child: Container(
    constraints: BoxConstraints(
      minWidth: 48,   // ✅ Minimum 48dp
      minHeight: 48,  // ✅ Minimum 48dp
    ),
    alignment: Alignment.center,
    child: Icon(Icons.close, size: 24),
  ),
)
```

**Verification:**
```bash
# Use Accessibility Scanner (Android):
# 1. Install Accessibility Scanner from Play Store
# 2. Enable scanner
# 3. Navigate through all app screens
# 4. Tap floating action button to scan
# 5. Verify NO touch target size warnings
```

---

## Performance Issues

### Issue 17: Job List Scrolling Lags with 100+ Jobs

**Symptom:**
```
Scrolling through job list feels sluggish
Frame drops visible during scroll
```

**Root Cause:**
Rendering all jobs at once without virtualization.

**Solution:**
```dart
// Use ListView.builder for virtualization
ListView.builder(
  itemCount: jobs.length,
  itemBuilder: (context, index) {
    return CondensedJobCard(job: jobs[index]);
  },
)

// NOT ListView(children: jobs.map((job) => CondensedJobCard(job: job)).toList())
```

**Verification:**
```bash
# 1. Load 100+ jobs in job list
# 2. Scroll rapidly up and down
# 3. Enable performance overlay:
#    flutter run --profile
# 4. Verify frame times stay < 16ms (60 FPS)
```

---

## Debugging Tools

### Enable Debug Logging

```dart
// In main.dart
void main() {
  // Enable Firestore debug logging
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Enable debug prints
  debugPrintEnabled = true;

  runApp(MyApp());
}
```

### Firestore Data Inspection

```bash
# Export Firestore data for inspection
firebase firestore:export gs://your-bucket/backups

# Query specific user document
firebase firestore:get /users/{userId}

# Watch real-time changes
firebase firestore:watch /users/{userId}
```

### Flutter DevTools

```bash
# Open DevTools
flutter pub global run devtools

# In terminal running app
flutter run --observatory-port=9200

# Open browser to http://localhost:9200
# Use Debugging, Performance, Memory, Network tabs
```

---

## Getting Help

### Filing a Bug Report

**Include:**
1. **Steps to reproduce** (numbered list)
2. **Expected behavior** vs **Actual behavior**
3. **Screenshots or screen recordings**
4. **Flutter doctor output:** `flutter doctor -v`
5. **Error logs** from console
6. **Firestore UID** (if data-related issue)
7. **Device/Platform:** iOS 17.1, Android 14, etc.

**Example:**
```markdown
## Bug: Job preferences not saving

### Steps to Reproduce
1. Sign in to app
2. Navigate to Settings → Job Preferences
3. Select "Journeyman Lineman" classification
4. Tap "Save Preferences"
5. Close app
6. Reopen app
7. Navigate to Settings → Job Preferences

### Expected Behavior
Previously selected "Journeyman Lineman" should be pre-selected

### Actual Behavior
No classifications are selected (empty state)

### Environment
- Flutter 3.16.5
- iOS 17.1 (iPhone 14 Pro)
- Firebase Auth 4.15.3

### Error Logs
No errors in console

### Firestore UID
abc123xyz456
```

---

## Common Error Messages Reference

| Error Message | Likely Cause | Quick Fix |
|---------------|--------------|-----------|
| `permission-denied` | Firestore security rules | Check authentication state, review firestore.rules |
| `RenderFlex overflowed` | UI layout constraints | Wrap with Flexible/Expanded widgets |
| `type cast error` | Data type mismatch | Use safe type casting, check Firestore schema |
| `Guest User` after login | Auth state race condition | Use authInitializationProvider |
| Duplicate Firestore fields | Multiple writes during onboarding | Use single consolidated write |
| Build failed (CocoaPods) | Outdated iOS dependencies | Run `pod install`, `pod update` |
| Multidex error | Too many Android methods | Enable multidex in build.gradle |
| Touch target too small | Accessibility issue | Ensure 48x48dp minimum size |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-10-19 | Initial comprehensive troubleshooting guide | AI Assistant |

---

## Related Documentation

- [Onboarding Flow Architecture](./ONBOARDING_FLOW_ARCHITECTURE.md)
- [Accessibility Improvements](../ACCESSIBILITY_IMPROVEMENTS.md)
- [Phase 1-3 Implementation Report](../COMPREHENSIVE_CODEBASE_REPORT.md)

---

**Need More Help?**
- Review [Flutter documentation](https://docs.flutter.dev)
- Check [Firebase documentation](https://firebase.google.com/docs)
- Search [GitHub issues](https://github.com/your-repo/issues)
- Contact the development team
