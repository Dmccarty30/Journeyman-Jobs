# Detailed Implementation Plans - Critical Tasks

**Generated:** 2025-10-24
**Scope:** Wave 1 & Wave 2 critical tasks with step-by-step implementation guides
**Purpose:** Provide agents with comprehensive technical roadmaps

---

## Table of Contents

1. [Task 4.2: Fix Firestore Index for Suggested Jobs](#task-42-fix-firestore-index-for-suggested-jobs)
2. [Task 10.7: Implement User Preferences Firestore Persistence](#task-107-implement-user-preferences-firestore-persistence)
3. [Task 1.1: Implement Session Grace Period System](#task-11-implement-session-grace-period-system)
4. [Task 6.1: Fix Contractor Cards Display](#task-61-fix-contractor-cards-display)
5. [Task 8.1: Fix Crew Preferences Save Error](#task-81-fix-crew-preferences-save-error)
6. [Task 4.3: Implement Missing Methods for Suggested Jobs](#task-43-implement-missing-methods-for-suggested-jobs)

---

## Task 4.2: Fix Firestore Index for Suggested Jobs

**Agent:** database-optimizer
**Priority:** 🔴 Critical
**Estimated Time:** 3-4 hours
**Blocking:** Task 4.3

### Problem Analysis

**Error Message:**

```
FAILED_PRECONDITION: The query requires an index.
Query: jobs where local in [84,111,222] and deleted==false order by -timestamp, -__name__
```

**Root Cause:**

- Firestore requires a composite index for queries with:
  - `in` operator on `local` field
  - Equality filter on `deleted` field
  - Descending order on `timestamp` and `__name__`

### Implementation Steps

#### Step 1: Create Composite Index in Firebase Console

**Action Items:**

1. Navigate to Firebase Console → Firestore Database → Indexes
2. Click "Create Index"
3. Configure index with these exact settings:
   - **Collection ID:** `jobs`
   - **Fields:**
     - `local` → Ascending
     - `deleted` → Ascending
     - `timestamp` → Descending
     - `__name__` → Descending
   - **Query Scope:** Collection

**Expected Result:** Index creation initiated (may take 2-15 minutes to build)

**Validation:**

```bash
# Check index status in Firebase Console
# Status should change from "Building" → "Enabled"
```

---

#### Step 2: Update Query Implementation

**File:** `lib/providers/jobs_riverpod_provider.dart`

**Current Query (Assumption):**

```dart
// This is the problematic query
Query<Map<String, dynamic>> query = firestore
    .collection('jobs')
    .where('local', whereIn: userPreferredLocals) // [84, 111, 222]
    .where('deleted', isEqualTo: false)
    .orderBy('timestamp', descending: true);
```

**Updated Query with Error Handling:**

```dart
/// Loads suggested jobs based on user's preferred locals
/// Requires composite index: jobs (local ASC, deleted ASC, timestamp DESC, __name__ DESC)
Future<List<JobModel>> loadSuggestedJobs() async {
  try {
    // Get user preferences
    final user = ref.read(userProvider);
    if (user == null || user.preferences?.preferredLocals.isEmpty == true) {
      print('[JobsProvider] No user preferences found');
      return [];
    }

    final preferredLocals = user.preferences!.preferredLocals;
    print('[JobsProvider] Loading suggested jobs for locals: $preferredLocals');

    // Build query with required index fields in correct order
    Query<Map<String, dynamic>> query = _firestore
        .collection('jobs')
        .where('local', whereIn: preferredLocals)
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(20); // Limit for performance

    // Execute query
    final snapshot = await query.get();

    print('[JobsProvider] Found ${snapshot.docs.length} suggested jobs');

    // Map to JobModel
    final jobs = snapshot.docs
        .map((doc) => JobModel.fromFirestore(doc))
        .toList();

    return jobs;

  } on FirebaseException catch (e) {
    if (e.code == 'failed-precondition') {
      print('[JobsProvider] ERROR: Missing Firestore index');
      print('[JobsProvider] Create index at: ${e.message}');
      print('[JobsProvider] Or check Firebase Console → Firestore → Indexes');

      // Show user-friendly error
      throw Exception('Database index required. Please contact support.');
    } else {
      print('[JobsProvider] Firebase error: ${e.code} - ${e.message}');
      throw Exception('Error loading jobs: ${e.message}');
    }
  } catch (e) {
    print('[JobsProvider] Unexpected error: $e');
    throw Exception('Error loading suggested jobs');
  }
}
```

---

#### Step 3: Add Loading and Error States

**File:** `lib/providers/jobs_riverpod_provider.dart`

**Provider State Management:**

```dart
/// State for suggested jobs
final suggestedJobsProvider = StateNotifierProvider<SuggestedJobsNotifier, AsyncValue<List<JobModel>>>((ref) {
  return SuggestedJobsNotifier(ref);
});

class SuggestedJobsNotifier extends StateNotifier<AsyncValue<List<JobModel>>> {
  final Ref ref;

  SuggestedJobsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadJobs();
  }

  Future<void> loadJobs() async {
    state = const AsyncValue.loading();

    try {
      final jobsRepo = ref.read(jobsRepositoryProvider);
      final jobs = await jobsRepo.loadSuggestedJobs();

      state = AsyncValue.data(jobs);
      print('[SuggestedJobsNotifier] Loaded ${jobs.length} jobs successfully');

    } catch (e, stack) {
      print('[SuggestedJobsNotifier] Error loading suggested jobs: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh suggested jobs
  Future<void> refresh() async {
    await loadJobs();
  }
}
```

---

#### Step 4: Update UI to Handle States

**File:** `lib/screens/home/home_screen.dart`

**Widget Implementation:**

```dart
// In the home screen build method
Widget _buildSuggestedJobs() {
  final suggestedJobsAsync = ref.watch(suggestedJobsProvider);

  return suggestedJobsAsync.when(
    data: (jobs) {
      if (jobs.isEmpty) {
        return _buildEmptyState();
      }
      return _buildJobsList(jobs);
    },
    loading: () => const Center(
      child: JJElectricalLoader(
        size: 60,
        color: AppTheme.accentCopper,
      ),
    ),
    error: (error, stack) {
      print('[HomeScreen] Error displaying suggested jobs: $error');

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading suggested jobs',
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodySmall.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(suggestedJobsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.work_outline, size: 64, color: AppTheme.primaryNavy.withValues(alpha:0.3)),
        const SizedBox(height: 16),
        Text(
          'No jobs found',
          style: AppTheme.headingMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Check your preferences or try again later',
          style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
        ),
      ],
    ),
  );
}
```

---

#### Step 5: Testing & Validation

**Test Cases:**

1. **Index Creation Validation:**

```bash
# Firebase Console checks:
# 1. Navigate to Firestore → Indexes
# 2. Verify index status is "Enabled"
# 3. Confirm fields match: local (ASC), deleted (ASC), timestamp (DESC), __name__ (DESC)
```

2. **Query Execution Test:**

```dart
// Test in Firebase Console → Firestore → Query Builder
// Run query:
jobs
  .where('local', 'in', [84, 111, 222])
  .where('deleted', '==', false)
  .orderBy('timestamp', 'desc')
  .limit(20)

// Expected: Results returned without error
```

3. **App Testing:**

```dart
// Manual test steps:
// 1. Launch app and navigate to home screen
// 2. Verify loading indicator displays
// 3. Verify jobs appear in suggested section
// 4. Check console for successful logs
// 5. Test with different user preferences
// 6. Test with no preferences set
// 7. Test with network disconnected (should show cached data)
```

---

#### Step 6: Monitoring & Debugging

**Add Debug Logging:**

```dart
/// Debug helper to log query details
void _logQueryDetails(Query query, List<int> locals) {
  print('═══════════════════════════════════════');
  print('[JobsProvider] Query Details:');
  print('  Collection: jobs');
  print('  Locals Filter: $locals');
  print('  Deleted Filter: false');
  print('  Order By: timestamp DESC, __name__ DESC');
  print('  Limit: 20');
  print('═══════════════════════════════════════');
}
```

**Performance Monitoring:**

```dart
Future<List<JobModel>> loadSuggestedJobs() async {
  final stopwatch = Stopwatch()..start();

  try {
    // ... query execution ...

    stopwatch.stop();
    print('[JobsProvider] Query completed in ${stopwatch.elapsedMilliseconds}ms');

    return jobs;
  } catch (e) {
    stopwatch.stop();
    print('[JobsProvider] Query failed after ${stopwatch.elapsedMilliseconds}ms');
    rethrow;
  }
}
```

---

### Acceptance Criteria Checklist

- [ ] Composite index created in Firebase Console
- [ ] Index status shows "Enabled"
- [ ] Query executes without FAILED_PRECONDITION error
- [ ] Suggested jobs display on home screen
- [ ] Loading state shows during query
- [ ] Error state handles failures gracefully
- [ ] Empty state displays when no jobs found
- [ ] Debug logs confirm successful execution
- [ ] Performance < 2 seconds for query execution
- [ ] Works with multiple user preference combinations

---

### Rollback Plan

If index creation fails or causes issues:

1. **Remove Index:**
   - Firebase Console → Firestore → Indexes
   - Find the created index
   - Click "Delete"

2. **Revert Query:**
   - Comment out whereIn filter
   - Use simpler query without ordering
   - Implement client-side filtering as temporary solution

3. **Alternative Approach:**

```dart
// Fallback: Fetch all jobs, filter client-side (less efficient)
final allJobs = await _firestore
    .collection('jobs')
    .where('deleted', isEqualTo: false)
    .limit(100)
    .get();

final filteredJobs = allJobs.docs
    .where((doc) => preferredLocals.contains(doc.data()['local']))
    .map((doc) => JobModel.fromFirestore(doc))
    .toList()
  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
```

---

## Task 10.7: Implement User Preferences Firestore Persistence

**Agent:** database-optimizer + auth-expert
**Priority:** 🔴 Critical
**Estimated Time:** 4-5 hours
**Blocking:** Settings functionality, Task 4.3

### Problem Analysis

**Current State:**

- User preferences dialog exists
- Save button shows "error saving preferences" notification
- No data persists to Firestore
- Users cannot save job search preferences

**Required State:**

- User preferences saved to Firestore user document
- Success notification on save
- Preferences persist across sessions
- Suggested jobs use saved preferences

---

### Implementation Steps

#### Step 1: Design User Document Schema

**Collection:** `users`
**Document ID:** User's Firebase Auth UID

**Schema Definition:**

```dart
/// User document structure in Firestore
/// Collection: users/{userId}
class UserPreferences {
  /// Selected job classifications
  final List<String> classifications;

  /// Selected construction types
  final List<String> constructionTypes;

  /// Preferred IBEW local numbers
  final List<int> preferredLocals;

  /// Hours per week preference
  final String? hoursPerWeek;

  /// Per diem preference
  final String? perDiem;

  /// Timestamp of last update
  final DateTime updatedAt;

  const UserPreferences({
    required this.classifications,
    required this.constructionTypes,
    required this.preferredLocals,
    this.hoursPerWeek,
    this.perDiem,
    required this.updatedAt,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'classifications': classifications,
      'constructionTypes': constructionTypes,
      'preferredLocals': preferredLocals,
      'hoursPerWeek': hoursPerWeek,
      'perDiem': perDiem,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore document
  factory UserPreferences.fromFirestore(Map<String, dynamic> data) {
    return UserPreferences(
      classifications: List<String>.from(data['classifications'] ?? []),
      constructionTypes: List<String>.from(data['constructionTypes'] ?? []),
      preferredLocals: List<int>.from(data['preferredLocals'] ?? []),
      hoursPerWeek: data['hoursPerWeek'] as String?,
      perDiem: data['perDiem'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Validate preferences before saving
  bool validate() {
    // At least one classification selected
    if (classifications.isEmpty) return false;

    // At least one construction type selected
    if (constructionTypes.isEmpty) return false;

    // At least one local selected
    if (preferredLocals.isEmpty) return false;

    return true;
  }
}
```

**Complete User Model:**

```dart
/// File: lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? ticketNumber;
  final UserPreferences? preferences;
  final DateTime createdAt;
  final DateTime lastLogin;

  const UserModel({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.ticketNumber,
    this.preferences,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Full Firestore document structure
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'ticketNumber': ticketNumber,
      'preferences': preferences?.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      ticketNumber: data['ticketNumber'] as String?,
      preferences: data['preferences'] != null
          ? UserPreferences.fromFirestore(data['preferences'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

---

#### Step 2: Create Firestore Service for User Preferences

**File:** `lib/services/user_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service for managing user data in Firestore
class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get current user's Firestore document reference
  DocumentReference<Map<String, dynamic>>? get _currentUserDoc {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    return _firestore.collection('users').doc(userId);
  }

  /// Save user preferences to Firestore
  /// Returns true if successful, throws exception on failure
  Future<bool> saveUserPreferences(UserPreferences preferences) async {
    try {
      // Validate user is authenticated
      final userDoc = _currentUserDoc;
      if (userDoc == null) {
        print('[UserService] Error: No authenticated user');
        throw Exception('User not authenticated');
      }

      // Validate preferences
      if (!preferences.validate()) {
        print('[UserService] Error: Invalid preferences');
        throw Exception('Invalid preferences: at least one option must be selected in each category');
      }

      print('[UserService] Saving preferences for user: ${_auth.currentUser!.uid}');
      print('[UserService] Classifications: ${preferences.classifications}');
      print('[UserService] Construction Types: ${preferences.constructionTypes}');
      print('[UserService] Preferred Locals: ${preferences.preferredLocals}');

      // Update Firestore document
      await userDoc.set(
        {
          'preferences': preferences.toFirestore(),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Merge to avoid overwriting other fields
      );

      print('[UserService] Preferences saved successfully');
      return true;

    } on FirebaseException catch (e) {
      print('[UserService] Firebase error saving preferences: ${e.code} - ${e.message}');

      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Please check your account settings.');
      } else if (e.code == 'unavailable') {
        throw Exception('Network error. Please check your connection.');
      } else {
        throw Exception('Error saving preferences: ${e.message}');
      }

    } catch (e) {
      print('[UserService] Unexpected error: $e');
      throw Exception('Failed to save preferences. Please try again.');
    }
  }

  /// Load user preferences from Firestore
  Future<UserPreferences?> loadUserPreferences() async {
    try {
      final userDoc = _currentUserDoc;
      if (userDoc == null) {
        print('[UserService] No authenticated user');
        return null;
      }

      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        print('[UserService] User document does not exist');
        return null;
      }

      final data = snapshot.data();
      if (data == null || data['preferences'] == null) {
        print('[UserService] No preferences found in user document');
        return null;
      }

      final preferences = UserPreferences.fromFirestore(
        data['preferences'] as Map<String, dynamic>,
      );

      print('[UserService] Loaded preferences successfully');
      return preferences;

    } catch (e) {
      print('[UserService] Error loading preferences: $e');
      return null;
    }
  }

  /// Stream user preferences for real-time updates
  Stream<UserPreferences?> watchUserPreferences() {
    final userDoc = _currentUserDoc;
    if (userDoc == null) {
      return Stream.value(null);
    }

    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final data = snapshot.data()!;
      if (data['preferences'] == null) {
        return null;
      }

      return UserPreferences.fromFirestore(
        data['preferences'] as Map<String, dynamic>,
      );
    });
  }
}
```

---

#### Step 3: Create Riverpod Provider for User Service

**File:** `lib/providers/user_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for user preferences stream
final userPreferencesProvider = StreamProvider<UserPreferences?>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.watchUserPreferences();
});

/// State notifier for managing user preferences
final userPreferencesNotifierProvider =
    StateNotifierProvider<UserPreferencesNotifier, AsyncValue<UserPreferences?>>((ref) {
  return UserPreferencesNotifier(ref);
});

class UserPreferencesNotifier extends StateNotifier<AsyncValue<UserPreferences?>> {
  final Ref ref;

  UserPreferencesNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    state = const AsyncValue.loading();

    try {
      final userService = ref.read(userServiceProvider);
      final preferences = await userService.loadUserPreferences();
      state = AsyncValue.data(preferences);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Save user preferences
  Future<bool> savePreferences(UserPreferences preferences) async {
    try {
      final userService = ref.read(userServiceProvider);
      await userService.saveUserPreferences(preferences);

      // Update local state
      state = AsyncValue.data(preferences);

      return true;
    } catch (e, stack) {
      print('[UserPreferencesNotifier] Error saving: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Refresh preferences from Firestore
  Future<void> refresh() async {
    await _loadPreferences();
  }
}
```

---

#### Step 4: Update User Job Preferences Dialog

**File:** `lib/widgets/dialogs/user_job_preferences_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../design_system/app_theme.dart';

class UserJobPreferencesDialog extends ConsumerStatefulWidget {
  const UserJobPreferencesDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<UserJobPreferencesDialog> createState() => _UserJobPreferencesDialogState();
}

class _UserJobPreferencesDialogState extends ConsumerState<UserJobPreferencesDialog> {
  // Form state
  final List<String> _selectedClassifications = [];
  final List<String> _selectedConstructionTypes = [];
  final List<int> _selectedLocals = [];
  String? _hoursPerWeek;
  String? _perDiem;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  /// Load existing preferences into form state
  void _loadExistingPreferences() {
    final preferencesAsync = ref.read(userPreferencesNotifierProvider);

    preferencesAsync.whenData((preferences) {
      if (preferences != null) {
        setState(() {
          _selectedClassifications.addAll(preferences.classifications);
          _selectedConstructionTypes.addAll(preferences.constructionTypes);
          _selectedLocals.addAll(preferences.preferredLocals);
          _hoursPerWeek = preferences.hoursPerWeek;
          _perDiem = preferences.perDiem;
        });
      }
    });
  }

  /// Validate form before saving
  bool _validateForm() {
    if (_selectedClassifications.isEmpty) {
      _showError('Please select at least one classification');
      return false;
    }

    if (_selectedConstructionTypes.isEmpty) {
      _showError('Please select at least one construction type');
      return false;
    }

    if (_selectedLocals.isEmpty) {
      _showError('Please select at least one preferred local');
      return false;
    }

    return true;
  }

  /// Save preferences to Firestore
  Future<void> _savePreferences() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Create preferences object
      final preferences = UserPreferences(
        classifications: _selectedClassifications,
        constructionTypes: _selectedConstructionTypes,
        preferredLocals: _selectedLocals,
        hoursPerWeek: _hoursPerWeek,
        perDiem: _perDiem,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await ref.read(userPreferencesNotifierProvider.notifier).savePreferences(preferences);

      // Show success notification with electrical theme
      if (mounted) {
        _showSuccess('Preferences saved successfully');

        // Close dialog after brief delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }

    } catch (e) {
      print('[UserJobPreferencesDialog] Error saving: $e');
      _showError(e.toString().replaceAll('Exception: ', ''));

    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Show success notification with electrical theme
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentCopper,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error notification with electrical theme
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Job Preferences',
        style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryNavy),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classifications section
            _buildClassificationsSection(),
            const SizedBox(height: 24),

            // Construction types section
            _buildConstructionTypesSection(),
            const SizedBox(height: 24),

            // Preferred locals section
            _buildPreferredLocalsSection(),
            const SizedBox(height: 24),

            // Hours per week (optional)
            _buildHoursPerWeekSection(),
            const SizedBox(height: 24),

            // Per diem (optional)
            _buildPerDiemSection(),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),

        // Save button
        ElevatedButton(
          onPressed: _isSaving ? null : _savePreferences,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentCopper,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save Preferences'),
        ),
      ],
    );
  }

  // Widget builders for each section...
  // (Classification checkboxes, construction type checkboxes, locals multi-select, etc.)
  // Implementation details omitted for brevity - follow existing dialog pattern
}
```

---

#### Step 5: Update Firestore Security Rules

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      // Users can read their own document
      allow read: if isOwner(userId);

      // Users can create their own document
      allow create: if isOwner(userId);

      // Users can update their own document
      // Ensure they can't change their UID
      allow update: if isOwner(userId)
        && request.resource.data.uid == userId;

      // Prevent deletion
      allow delete: if false;
    }

    // Jobs collection (read-only for now)
    match /jobs/{jobId} {
      allow read: if isAuthenticated();
      allow write: if false; // Jobs managed by admin/backend
    }
  }
}
```

---

#### Step 6: Testing & Validation

**Unit Tests:**

```dart
// test/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('UserService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late UserService userService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
      userService = UserService(
        firestore: fakeFirestore,
        auth: mockAuth,
      );
    });

    test('saveUserPreferences saves to Firestore', () async {
      final preferences = UserPreferences(
        classifications: ['Inside Wireman'],
        constructionTypes: ['Commercial'],
        preferredLocals: [84, 111],
        updatedAt: DateTime.now(),
      );

      final result = await userService.saveUserPreferences(preferences);

      expect(result, true);

      // Verify data in Firestore
      final doc = await fakeFirestore
          .collection('users')
          .doc(mockAuth.currentUser!.uid)
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['preferences']['classifications'], ['Inside Wireman']);
      expect(doc.data()?['preferences']['preferredLocals'], [84, 111]);
    });

    test('saveUserPreferences validates preferences', () async {
      final invalidPreferences = UserPreferences(
        classifications: [], // Empty - should fail
        constructionTypes: ['Commercial'],
        preferredLocals: [84],
        updatedAt: DateTime.now(),
      );

      expect(
        () => userService.saveUserPreferences(invalidPreferences),
        throwsA(isA<Exception>()),
      );
    });

    test('loadUserPreferences retrieves saved preferences', () async {
      // Save preferences first
      final preferences = UserPreferences(
        classifications: ['Inside Wireman'],
        constructionTypes: ['Commercial', 'Industrial'],
        preferredLocals: [84, 111, 222],
        updatedAt: DateTime.now(),
      );

      await userService.saveUserPreferences(preferences);

      // Load preferences
      final loaded = await userService.loadUserPreferences();

      expect(loaded, isNotNull);
      expect(loaded!.classifications, ['Inside Wireman']);
      expect(loaded.constructionTypes, ['Commercial', 'Industrial']);
      expect(loaded.preferredLocals, [84, 111, 222]);
    });
  });
}
```

**Integration Tests:**

```dart
// Manual testing checklist
// 1. Open settings screen
// 2. Tap "Job Preferences"
// 3. Select classifications, construction types, locals
// 4. Tap "Save Preferences"
// 5. Verify success notification appears
// 6. Close and reopen dialog
// 7. Verify selections persist
// 8. Check Firebase Console for saved data
// 9. Test with no auth (should show error)
// 10. Test with network disconnected (should show error)
```

---

### Acceptance Criteria Checklist

- [ ] UserPreferences model created with validation
- [ ] UserService implements save/load methods
- [ ] Riverpod providers configured
- [ ] Dialog saves preferences to Firestore
- [ ] Success notification displays with electrical theme
- [ ] Error handling for all failure cases
- [ ] Firestore security rules updated
- [ ] Preferences persist across app restarts
- [ ] Firebase Console shows saved data
- [ ] Unit tests passing
- [ ] Integration tests passing

---

## Task 1.1: Implement Session Grace Period System

**Agent:** auth-expert
**Priority:** 🔴 Critical
**Estimated Time:** 8-12 hours
**Blocking:** None

### Problem Analysis

**Current State:**

- Users are signed out immediately after 2 minutes of inactivity
- No grace period for resuming activity
- Abrupt session terminations negatively impact UX

**Required State:**

- Idle detection after 2 minutes of inactivity
- 5-minute grace period before automatic sign-out
- Timer resets on activity resumption
- Warning notification at 4-minute mark
- Works across iOS and Android

---

### Implementation Steps

#### Step 1: Create Session Manager Service

**File:** `lib/services/session_manager_service.dart`

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages user session with inactivity detection and grace period
class SessionManagerService extends ChangeNotifier {
  final FirebaseAuth _auth;

  // Timers
  Timer? _inactivityTimer;
  Timer? _gracePeriodTimer;

  // Configuration
  static const Duration _inactivityDuration = Duration(minutes: 2);
  static const Duration _gracePeriodDuration = Duration(minutes: 5);
  static const Duration _warningDuration = Duration(minutes: 4);

  // State
  bool _isInGracePeriod = false;
  bool _hasShownWarning = false;
  DateTime? _lastActivityTime;
  DateTime? _gracePeriodStartTime;

  // Getters
  bool get isInGracePeriod => _isInGracePeriod;
  DateTime? get lastActivityTime => _lastActivityTime;
  DateTime? get gracePeriodStartTime => _gracePeriodStartTime;

  /// Calculate remaining grace period time
  Duration? get remainingGracePeriod {
    if (!_isInGracePeriod || _gracePeriodStartTime == null) {
      return null;
    }

    final elapsed = DateTime.now().difference(_gracePeriodStartTime!);
    final remaining = _gracePeriodDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  SessionManagerService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance {
    _initialize();
  }

  /// Initialize session manager
  void _initialize() {
    print('[SessionManager] Initializing...');

    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        print('[SessionManager] User authenticated, starting activity monitoring');
        recordActivity();
      } else {
        print('[SessionManager] User signed out, stopping monitoring');
        _stopAllTimers();
      }
    });
  }

  /// Record user activity - resets timers
  void recordActivity() {
    final now = DateTime.now();

    print('[SessionManager] Activity recorded at $now');

    // Update last activity time
    _lastActivityTime = now;

    // If in grace period, exit it
    if (_isInGracePeriod) {
      print('[SessionManager] Activity resumed during grace period - exiting grace period');
      _exitGracePeriod();
    }

    // Reset inactivity timer
    _resetInactivityTimer();

    notifyListeners();
  }

  /// Start/reset inactivity detection timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _hasShownWarning = false;

    _inactivityTimer = Timer(_inactivityDuration, () {
      print('[SessionManager] Inactivity detected - starting grace period');
      _startGracePeriod();
    });

    print('[SessionManager] Inactivity timer reset - will trigger in ${_inactivityDuration.inMinutes} minutes');
  }

  /// Start grace period countdown
  void _startGracePeriod() {
    if (_isInGracePeriod) {
      print('[SessionManager] Grace period already active');
      return;
    }

    final now = DateTime.now();

    print('[SessionManager] ═══════════════════════════════════════');
    print('[SessionManager] GRACE PERIOD STARTED at $now');
    print('[SessionManager] Duration: ${_gracePeriodDuration.inMinutes} minutes');
    print('[SessionManager] Warning at: ${_warningDuration.inMinutes} minutes');
    print('[SessionManager] ═══════════════════════════════════════');

    _isInGracePeriod = true;
    _gracePeriodStartTime = now;
    _hasShownWarning = false;

    notifyListeners();

    // Schedule warning notification
    Timer(_warningDuration, () {
      if (_isInGracePeriod && !_hasShownWarning) {
        print('[SessionManager] ⚠️ WARNING: 1 minute until automatic sign-out');
        _hasShownWarning = true;
        notifyListeners();
      }
    });

    // Schedule automatic sign-out
    _gracePeriodTimer = Timer(_gracePeriodDuration, () {
      if (_isInGracePeriod) {
        print('[SessionManager] Grace period expired - signing out user');
        _performAutomaticSignOut();
      }
    });
  }

  /// Exit grace period (activity resumed)
  void _exitGracePeriod() {
    print('[SessionManager] Exiting grace period - activity resumed');

    _isInGracePeriod = false;
    _gracePeriodStartTime = null;
    _hasShownWarning = false;
    _gracePeriodTimer?.cancel();

    notifyListeners();
  }

  /// Perform automatic sign-out
  Future<void> _performAutomaticSignOut() async {
    try {
      print('[SessionManager] ═══════════════════════════════════════');
      print('[SessionManager] AUTOMATIC SIGN-OUT TRIGGERED');
      print('[SessionManager] Last activity: $_lastActivityTime');
      print('[SessionManager] Grace period start: $_gracePeriodStartTime');
      print('[SessionManager] ═══════════════════════════════════════');

      await _auth.signOut();

      _stopAllTimers();
      _isInGracePeriod = false;
      _gracePeriodStartTime = null;
      _lastActivityTime = null;

      notifyListeners();

      print('[SessionManager] Sign-out completed successfully');

    } catch (e) {
      print('[SessionManager] ERROR during sign-out: $e');
    }
  }

  /// Stop all active timers
  void _stopAllTimers() {
    _inactivityTimer?.cancel();
    _gracePeriodTimer?.cancel();

    _inactivityTimer = null;
    _gracePeriodTimer = null;

    print('[SessionManager] All timers stopped');
  }

  @override
  void dispose() {
    print('[SessionManager] Disposing...');
    _stopAllTimers();
    super.dispose();
  }
}
```

---

#### Step 2: Create Activity Detector Widget

**File:** `lib/widgets/activity_detector.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';

/// Wraps the app to detect user activity
class ActivityDetector extends ConsumerWidget {
  final Widget child;

  const ActivityDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionManager = ref.watch(sessionManagerProvider);

    return Listener(
      // Detect any pointer events (taps, scrolls, gestures)
      onPointerDown: (_) => sessionManager.recordActivity(),
      onPointerMove: (_) => sessionManager.recordActivity(),
      onPointerUp: (_) => sessionManager.recordActivity(),

      // Detect keyboard events
      child: Focus(
        onKeyEvent: (node, event) {
          sessionManager.recordActivity();
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
```

---

#### Step 3: Create Grace Period Warning Widget

**File:** `lib/widgets/grace_period_warning.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../design_system/app_theme.dart';

/// Displays warning notification during grace period
class GracePeriodWarning extends ConsumerWidget {
  const GracePeriodWarning({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionManager = ref.watch(sessionManagerProvider);

    // Only show if in grace period and warning threshold reached
    if (!sessionManager.isInGracePeriod ||
        sessionManager.remainingGracePeriod == null ||
        sessionManager.remainingGracePeriod!.inMinutes > 1) {
      return const SizedBox.shrink();
    }

    final remaining = sessionManager.remainingGracePeriod!;

    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[700]!, Colors.orange[900]!],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha:0.3), width: 2),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Timeout Warning',
                      style: AppTheme.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You will be signed out in ${remaining.inSeconds} seconds due to inactivity',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha:0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap anywhere to stay signed in',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

#### Step 4: Create Riverpod Providers

**File:** `lib/providers/session_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_manager_service.dart';

/// Provider for session manager
final sessionManagerProvider = ChangeNotifierProvider<SessionManagerService>((ref) {
  return SessionManagerService();
});

/// Provider for grace period state
final isInGracePeriodProvider = Provider<bool>((ref) {
  return ref.watch(sessionManagerProvider).isInGracePeriod;
});

/// Provider for remaining grace period time
final remainingGracePeriodProvider = Provider<Duration?>((ref) {
  return ref.watch(sessionManagerProvider).remainingGracePeriod;
});
```

---

#### Step 5: Integrate into Main App

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/activity_detector.dart';
import 'widgets/grace_period_warning.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: JourneymanJobsApp(),
    ),
  );
}

class JourneymanJobsApp extends StatelessWidget {
  const JourneymanJobsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journeyman Jobs',
      theme: AppTheme.lightTheme,
      home: ActivityDetector(
        child: Stack(
          children: [
            // Main app content
            const AppNavigator(),

            // Grace period warning overlay
            const GracePeriodWarning(),
          ],
        ),
      ),
    );
  }
}
```

---

#### Step 6: Handle Background/Foreground State

**File:** `lib/services/session_manager_service.dart` (additions)

```dart
import 'package:flutter/widgets.dart';

class SessionManagerService extends ChangeNotifier with WidgetsBindingObserver {
  // ... existing code ...

  void _initialize() {
    // ... existing initialization ...

    // Register as lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('[SessionManager] App resumed - recording activity');
        recordActivity();
        break;

      case AppLifecycleState.paused:
        print('[SessionManager] App paused - continuing timers');
        // Timers continue running in background
        break;

      case AppLifecycleState.inactive:
        print('[SessionManager] App inactive');
        break;

      case AppLifecycleState.detached:
        print('[SessionManager] App detached');
        break;

      case AppLifecycleState.hidden:
        print('[SessionManager] App hidden');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

---

#### Step 7: Testing & Validation

**Unit Tests:**

```dart
// test/services/session_manager_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionManagerService', () {
    late SessionManagerService sessionManager;

    setUp(() {
      sessionManager = SessionManagerService();
    });

    tearDown(() {
      sessionManager.dispose();
    });

    test('recordActivity updates last activity time', () {
      final beforeActivity = sessionManager.lastActivityTime;

      sessionManager.recordActivity();

      expect(sessionManager.lastActivityTime, isNot(beforeActivity));
    });

    test('grace period starts after 2 minutes of inactivity', () async {
      sessionManager.recordActivity();
      expect(sessionManager.isInGracePeriod, false);

      // Fast-forward 2 minutes (use fake_async package)
      await Future.delayed(const Duration(minutes: 2, seconds: 1));

      expect(sessionManager.isInGracePeriod, true);
    });

    test('activity during grace period exits grace period', () async {
      // Start grace period
      sessionManager.recordActivity();
      await Future.delayed(const Duration(minutes: 2, seconds: 1));
      expect(sessionManager.isInGracePeriod, true);

      // Record activity
      sessionManager.recordActivity();

      expect(sessionManager.isInGracePeriod, false);
    });

    test('sign-out occurs after 5-minute grace period', () async {
      bool signedOut = false;

      // Mock auth sign-out
      // ... test implementation ...

      // Start grace period
      sessionManager.recordActivity();
      await Future.delayed(const Duration(minutes: 2, seconds: 1));

      // Wait for grace period to expire
      await Future.delayed(const Duration(minutes: 5, seconds: 1));

      expect(signedOut, true);
    });
  });
}
```

**Manual Testing Checklist:**

```
[ ] Launch app and authenticate
[ ] Use app normally - verify no sign-out occurs
[ ] Leave app inactive for 2 minutes - verify no immediate sign-out
[ ] Verify grace period starts after 2 minutes
[ ] Resume activity within grace period - verify grace period exits
[ ] Leave app inactive through entire grace period - verify sign-out at 5 minutes
[ ] Verify warning notification appears at 4-minute mark
[ ] Test on iOS device
[ ] Test on Android device
[ ] Test with app in background
[ ] Test with app in foreground
[ ] Verify logs show correct timing
```

---

### Acceptance Criteria Checklist

- [ ] Idle detection implemented (2 minutes)
- [ ] Grace period system working (5 minutes)
- [ ] Activity detection resets timers
- [ ] Warning notification at 4-minute mark
- [ ] Automatic sign-out at 5 minutes
- [ ] Cross-platform compatibility (iOS/Android)
- [ ] Background/foreground state handling
- [ ] Comprehensive logging
- [ ] Unit tests passing
- [ ] Manual tests passing on both platforms

---

## Next Tasks

For brevity, I've provided detailed implementation plans for the most critical tasks. The remaining tasks (6.1, 8.1, 4.3) follow similar patterns:

- **Task 6.1** (Contractor Cards): Debug widget tree, verify Firestore query, add loading/error states
- **Task 8.1** (Crew Preferences): Similar to Task 10.7 but for crew-specific preferences
- **Task 4.3** (Suggested Jobs Methods): Implement filtering logic using the Firestore index from Task 4.2

Would you like me to create detailed plans for any of these remaining tasks?
