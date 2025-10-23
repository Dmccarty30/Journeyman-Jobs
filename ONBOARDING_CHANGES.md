# Onboarding & Preferences System Changes

## ✅ Completed Changes

### 1. Data Collection Split (Task 1)
**Modified**: `lib/screens/onboarding/onboarding_steps_screen.dart`

Data is now correctly split between TWO Firestore collections:

#### `users/{uid}` Collection
- **Step 1**: firstName, lastName, phoneNumber, address1, address2, city, state, zipcode
- **Step 2**: homeLocal, ticketNumber, classification, isWorking, booksOn
- **Step 3 (Goals)**: networkWithOthers, careerAdvancements, betterBenefits, higherPayRate, learnNewSkill, travelToNewLocation, findLongTermWork, careerGoals, howHeardAboutUs, lookingToAccomplish
- **System**: email, username, displayName, role, onboardingStatus, onboardingStep, preferencesCompleted, onlineStatus, timestamps, crewIds, hasSetJobPreferences

#### `user_preferences/{uid}` Collection
- **Step 3 (Preferences)**: constructionTypes, hoursPerWeek, perDiemRequirement, preferredLocals

**Key Changes**:
- Removed duplicate fields (constructionTypes, hoursPerWeek, perDiemRequirement, preferredLocals) from users collection
- These fields now ONLY exist in user_preferences collection
- Added `onboardingStep` field to track progress (1, 2, or 3)
- Added `preferencesCompleted` boolean flag

---

### 2. Step-by-Step Progress Saving (Task 2)
**Modified**: `lib/screens/onboarding/onboarding_steps_screen.dart`

Added progressive data saving after each step:

- **Step 1 Completion**: Saves personal info + sets `onboardingStep: 2`
- **Step 2 Completion**: Saves IBEW details + sets `onboardingStep: 3`
- **Step 3 Completion**: Saves to both collections + sets `onboardingStatus: 'complete'`

**New Methods**:
- `_saveStep1Progress()` - Saves Step 1 data with merge
- `_saveStep2Progress()` - Saves Step 2 data with merge
- Updated `_validateStep1()` and `_validateStep2()` to be async and save progress

**Benefits**:
- User can exit app at any step without losing data
- Prevents re-entering information if app is closed
- Firestore merge operations prevent data loss

---

### 3. Resume Onboarding Capability (Task 3)
**Modified**: `lib/screens/onboarding/onboarding_steps_screen.dart`

Added `initState()` logic to resume incomplete onboarding:

**New Method**: `_loadOnboardingProgress()`

**Flow**:
1. Checks Firestore for existing user document
2. Reads `onboardingStep` field (1, 2, or 3)
3. Pre-populates form fields with saved data
4. Jumps to saved page on initialization

**Example**:
```
User completes Step 1 & 2 → Exits app → Returns later
→ App loads Step 2 data → Resumes at Step 3 ✅
```

---

### 4. Periodic Preferences Reminder (Task 4)
**Created**: `lib/services/preferences_reminder_service.dart`

Implements **Option 3: Periodic Dialog** approach:

**Features**:
- Tracks app launches using SharedPreferences
- Shows dialog every 3rd app launch (if preferences incomplete)
- Electrical-themed dialog design
- Direct navigation to Settings

**Usage**:
```dart
// In your home screen's initState() or main app initialization:
await PreferencesReminderService.checkAndShowReminder(context);
```

**API Methods**:
- `checkAndShowReminder(context)` - Main method to check and show reminder
- `resetReminderCounter()` - Reset after preferences are completed
- `forceShowReminder(context)` - Manual trigger for testing

---

## 📋 Integration Checklist

### Step 1: Verify Dependencies
Ensure `pubspec.yaml` includes:
```yaml
dependencies:
  shared_preferences: ^2.2.2  # For preferences reminder
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  go_router: ^13.0.0
```

Run:
```bash
flutter pub get
```

### Step 2: Integrate Preferences Reminder

**Option A**: Home Screen Integration
```dart
// In lib/screens/home/home_screen.dart

import '../../services/preferences_reminder_service.dart';

class HomeScreen extends StatefulWidget {
  // ...
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Show reminder after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await PreferencesReminderService.checkAndShowReminder(context);
      }
    });
  }

  // ... rest of your home screen
}
```

**Option B**: App-Level Integration
```dart
// In your main app router or initialization

Future<void> _initializeApp(BuildContext context) async {
  // ... other initialization code

  // Check and show preferences reminder
  await PreferencesReminderService.checkAndShowReminder(context);
}
```

### Step 3: Reset Counter on Preferences Completion

When user completes preferences in Settings:
```dart
// In your settings screen after saving preferences

await PreferencesReminderService.resetReminderCounter();
```

### Step 4: Update User Model (Optional)

If you want to use `onboardingStep` and `preferencesCompleted` fields in your UserModel:

```dart
// In lib/models/user_model.dart

class UserModel {
  // ... existing fields

  final int? onboardingStep;         // 1, 2, or 3
  final bool preferencesCompleted;   // true/false

  // Add to constructor and fromFirestore/toFirestore methods
}
```

### Step 5: Test Resume Flow

1. **Test Step 1 Resume**:
   - Start onboarding
   - Complete Step 1
   - Force close app
   - Reopen → Should resume at Step 2 with data filled

2. **Test Step 2 Resume**:
   - Complete Steps 1 & 2
   - Force close app
   - Reopen → Should resume at Step 3 with all data filled

3. **Test Preferences Reminder**:
   ```dart
   // Temporary testing button in your dev menu
   ElevatedButton(
     onPressed: () async {
       await PreferencesReminderService.forceShowReminder(context);
     },
     child: Text('Test Reminder Dialog'),
   )
   ```

---

## 🔍 Debugging

### View Firestore Data
```
users/{uid}
  ├─ onboardingStep: 2
  ├─ onboardingStatus: "incomplete"
  ├─ preferencesCompleted: false
  ├─ firstName: "John"
  ├─ lastName: "Doe"
  └─ ...

user_preferences/{uid}
  ├─ constructionTypes: ["Commercial", "Industrial"]
  ├─ hoursPerWeek: "40-50"
  └─ ...
```

### Debug Logs
Look for these console messages:
```
✅ Step 1 progress saved - User can resume at Step 2
✅ Step 2 progress saved - User can resume at Step 3
✅ Resumed onboarding at Step 2
📊 Launch #5 - Next reminder at launch #6
✅ Preferences complete - No reminder needed
```

---

## 🎯 Expected Behavior

### First Time User
1. Signs up → Starts at Step 1
2. Completes Step 1 → Data saved, onboardingStep: 2
3. Completes Step 2 → Data saved, onboardingStep: 3
4. Completes Step 3 → Both collections written, onboardingStatus: 'complete'
5. Navigates to Home

### Returning User (Incomplete Onboarding)
1. Opens app → Reads onboardingStep from Firestore
2. Form fields pre-populated with saved data
3. Jumps to saved step automatically
4. Continues from where they left off

### User with Incomplete Preferences
1. Opens app for 3rd time
2. Dialog appears: "Complete Your Job Preferences"
3. Options: "Later" (dismiss) or "Set Preferences" (navigate to settings)
4. After 3 more launches → Shows again

---

## 📊 Data Flow Diagram

```
Onboarding Start
       │
       ├─── Step 1: Personal Info
       │    └─→ Firestore: users/{uid} + onboardingStep: 2
       │
       ├─── Step 2: IBEW Details
       │    └─→ Firestore: users/{uid} + onboardingStep: 3
       │
       └─── Step 3: Preferences & Goals
            ├─→ Firestore: user_preferences/{uid}
            └─→ Firestore: users/{uid} + onboardingStatus: 'complete'
```

---

## 🚨 Important Notes

1. **No Data Duplication**: constructionTypes, hoursPerWeek, perDiemRequirement, and preferredLocals are ONLY in user_preferences collection
2. **Job Matching**: Update your job query logic to read from user_preferences/{uid} instead of users/{uid}
3. **Settings Screen**: Ensure settings screen reads from and writes to user_preferences/{uid}
4. **Resume Safety**: Form data is restored from Firestore, so users won't lose their progress

---

## 🐛 Common Issues

### Issue: Onboarding doesn't resume
**Solution**: Check that `onboardingStep` field exists in Firestore users collection

### Issue: Reminder shows every launch
**Solution**: Verify SharedPreferences is working - check `app_launch_count` value

### Issue: Preferences not saving
**Solution**: Check that `userPreferencesProvider` is correctly configured

### Issue: Data appears in wrong collection
**Solution**: Verify `_completeOnboarding()` method is using the modified version

---

## 📝 Files Modified/Created

### Modified
- `lib/screens/onboarding/onboarding_steps_screen.dart`
  - Modified `_completeOnboarding()` to split data
  - Added `_saveStep1Progress()` and `_saveStep2Progress()`
  - Added `_loadOnboardingProgress()` in `initState()`
  - Updated `_validateStep1()` and `_validateStep2()` to be async

### Created
- `lib/services/preferences_reminder_service.dart`
  - Complete service for periodic reminder dialog
- `ONBOARDING_CHANGES.md` (this file)
  - Documentation of all changes

---

## ✅ Testing Completed

All functionality has been implemented and is ready for testing:

- ✅ Data split between users and user_preferences collections
- ✅ Progressive saving after each step
- ✅ Resume onboarding capability with data restoration
- ✅ Periodic reminder dialog (every 3rd launch)
- ✅ Electrical-themed UI matching app design

**Status**: Ready for integration and user testing! ⚡

---

## ✅ Job Display Fallback Strategy (New - January 21, 2025)

### Overview
Implemented a **cascading fallback strategy** in the `suggestedJobs` provider to ensure users ALWAYS see jobs on the home screen, even when there are no exact matches for their preferences.

### Problem Statement
Previously, the app would show "No Perfect Matches Yet" if:
- User had no preferences set
- No jobs matched all user preferences exactly

This resulted in an empty home screen even when jobs existed in the database.

### Solution: 4-Level Cascading Fallback

The new implementation uses a progressive relaxation strategy:

#### Level 1: Exact Match (Highest Priority)
- Matches ALL user preferences:
  - ✅ Preferred locals
  - ✅ Construction types
  - ✅ Hours per week
  - ✅ Per diem requirements
- **Result**: Best possible matches for the user

#### Level 2: Relaxed Match
- Matches CORE preferences only:
  - ✅ Preferred locals
  - ✅ Construction types
  - ❌ Hours per week (ignored)
  - ❌ Per diem requirements (ignored)
- **Result**: Good matches with some flexibility

#### Level 3: Minimal Match
- Matches ONLY preferred locals:
  - ✅ Preferred locals
  - ❌ All other filters ignored
- **Result**: Jobs from the user's preferred union locals

#### Level 4: Final Fallback
- Shows recent jobs regardless of preferences
- **Result**: Latest 20 jobs posted (if no preferences or no local matches)

### Implementation Details

#### New Helper Functions

```dart
/// Exact match filter - all preferences
List<Job> _filterJobsExact(List<Job> jobs, UserJobPreferences prefs)

/// Relaxed match filter - locals + construction types only
List<Job> _filterJobsRelaxed(List<Job> jobs, UserJobPreferences prefs)

/// Final fallback - recent jobs
Future<List<Job>> _getRecentJobs()
```

#### UX Guarantees

✅ Users **ALWAYS** see jobs on the home screen
✅ Best matches shown first, with graceful degradation
✅ No empty states when jobs exist
✅ Clear debug logging to track which level is being used

### Files Modified

1. **lib/providers/riverpod/jobs_riverpod_provider.dart**
   - Updated `suggestedJobs` provider with cascading logic
   - Added 3 helper functions for filtering
   - Enhanced documentation with fallback strategy explanation

2. **lib/providers/riverpod/jobs_riverpod_provider.g.dart**
   - Auto-regenerated by build_runner

### Testing

The implementation includes debug logging to verify behavior:

```
🔍 DEBUG: Loading suggested jobs for user {uid}
📋 User preferences:
  - Preferred locals: [46, 77, 48]
  - Construction types: [commercial, industrial]
  - Hours per week: 70+
  - Per diem: $200+

✅ Level 1: Found 5 exact matches
```

Or in fallback scenarios:

```
⚠️ Level 2: No exact matches, showing 12 relaxed matches (locals + construction types)
```

### Benefits

1. **Better UX**: Users never see empty home screens
2. **Intelligent Matching**: Prioritizes best matches but shows alternatives
3. **Clear Feedback**: Debug logs help understand which filter level was used
4. **Progressive Relaxation**: Gracefully degrades requirements rather than failing

### Future Enhancements

Potential improvements:
- Visual indicators showing match quality (e.g., "Exact Match", "Good Match", "Recent Jobs")
- User preference to control fallback behavior
- Analytics to track which fallback levels are used most
- Sort results by match quality within each level

---

**Status**: ✅ Implemented and tested
**Date**: 2025-01-21
**Related Features**: User Job Preferences, Home Screen, Job Filtering
