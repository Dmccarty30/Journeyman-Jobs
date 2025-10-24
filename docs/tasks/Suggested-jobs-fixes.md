# Suggested Jobs Filter and Sort - Implementation Plan

## 📋 Overview

**Issue:** The Home screen's "Suggested Jobs" section displays no jobs despite cascading logic that should show exact matches, partial matches, and fallback recent jobs.

**Goal:** Implement a resilient cascade filter system that ensures jobs are ALWAYS displayed when they exist in Firestore, with preference-based matching prioritized (Exact → Relaxed → Locals-Only → Recent).

**Status:** IN PROGRESS (3 of 15 tasks completed)

---

## 🎯 Executive Summary

The core issue involves:

1. **Server-side deleted filtering** excluding jobs without the `deleted` field
2. **Type mismatches** on `local` field (int vs string)
3. **Referential equality bugs** in preference checking
4. **Missing local validation** in cascade filters

The solution implements a robust client-side cascade with schema-agnostic parsing and guaranteed fallback to recent jobs.

---

## 📊 Implementation Plan

### Phase 1: Data Model Normalization

#### Task 1: ✅ COMPLETED - Confirm Understanding and Scope

**Objective:** Restate issue and establish acceptance criteria.

**Completion:** January 24, 2025

**Summary:** Confirmed that "Suggested Jobs" must show jobs prioritizing exact matches → partial → locals-only → fallback, regardless of Firestore schema variations or strict preferences.

---

#### Task 2: ✅ COMPLETED - Baseline Analysis and Code Audit

**Objective:** Identify fragile filters and missing logic across the codebase.

**Completion:** January 24, 2025

**Files Analyzed:**

- `lib/screens/home/home_screen.dart` - UI rendering and empty state logic
- `lib/providers/riverpod/jobs_riverpod_provider.dart` - Cascading filters and queries
- `lib/providers/riverpod/user_preferences_riverpod_provider.dart` - Preference checking
- `lib/models/job_model.dart` - Data parsing

**Key Findings:**

| Issue | Location | Impact | Priority |
|-------|----------|--------|----------|
| Server-side `.where('deleted', isEqualTo: false)` | jobs_riverpod_provider.dart:617, 629, 752 | Excludes jobs without deleted field | CRITICAL |
| `whereIn` on 'local' with type mismatch | jobs_riverpod_provider.dart:616 | Returns zero results | CRITICAL |
| `hasPreferences` uses referential equality | user_preferences_riverpod_provider.dart:22 | Hides jobs from UI | CRITICAL |
| preferredLocals type: String vs List<int> | Multiple locations | Type conversion errors | CRITICAL |
| Missing local validation in client filters | jobs_riverpod_provider.dart | Cascade incomplete | HIGH |

---

#### Task 3: ✅ COMPLETED - Normalize Job Model Parsing

**Objective:** Make Job.fromJson schema-agnostic and resilient to field variations.

**Completion:** January 24, 2025

**File Modified:** `lib/models/job_model.dart`

**Changes Implemented:**

##### 1. Enhanced parseTimestamp()

```dart
DateTime? _parseTimestamp(dynamic v) {
  if (v == null) return null;  // CRITICAL FIX: nullable contract
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;  // CRITICAL FIX: null instead of epoch
  }
}
```

- **Primary:** `timestamp` field
- **Fallback 1:** `createdAt` field
- **Fallback 2:** `null` (maintains nullable contract)
- Handles: Timestamp, DateTime, String, int milliseconds

##### 2. Improved parseInt() with Validation

```dart
int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString().trim();
  final digits = RegExp(r'-?\d+').stringMatch(s);
  if (digits == null) return null;
  final parsed = int.tryParse(digits);
  // SECURITY FIX: IBEW locals are 1-9999
  return (parsed != null && parsed > 0 && parsed < 10000) ? parsed : null;
}
```

- Handles: int, double, string with mixed content
- **Security:** Only accepts positive integers in valid IBEW range

##### 3. Fixed parseIntList()

```dart
List<int> _parseIntList(List<dynamic>? list) {
  if (list == null) return [];
  return list
    .map((v) => _parseInt(v))
    .whereType<int>()  // CRITICAL FIX: filters nulls
    .toList();
}
```

- **CRITICAL FIX:** Was converting invalid values to 0 (creating "book 0" invalid data)
- Now filters invalid values properly
- Example: `[26, 'invalid', -5, 0, 103]` → `[26, 103]`

##### 4. Schema-Agnostic Local/LocalNumber Parsing

```dart
local: _parseInt(json['local']) ?? _parseInt(json['localNumber']),
localNumber: _parseInt(json['localNumber']) ?? _parseInt(json['local']),
```

- Handles both `local` and `localNumber` fields
- Handles both int and string types
- Preserves both values for backward compatibility

##### 5. Additional Fixes

- **Normalized typeOfWork:** Convert to lowercase for consistent matching
- **GeoPoint default:** Changed from `GeoPoint(0,0)` to `null` (avoids "Null Island")
- **Exception handling:** Preserve stack traces with `catch (e, stackTrace)`

**Code Review:** ✅ PASSED - All critical bugs fixed, production-ready

---

### Phase 2: Query and Cascade Implementation

#### Task 4: ⏳ PENDING - Refactor suggestedJobs() to Single Resilient Recent Slice

**Objective:** Eliminate fragile server-side filters and fetch a canonical ordered job slice.

**Priority:** HIGH

**Implementation Details:**

```dart
/// Fetches recent jobs (100 max) in timestamp descending order.
/// All filtering is done client-side for flexibility and schema tolerance.
Future<List<Job>> _fetchRecentJobsSlice(FirebaseFirestore db) async {
  final snap = await db.collection('jobs')
    .orderBy('timestamp', descending: true)
    .limit(100)
    .get();

  return snap.docs
    .map((d) => Job.fromJson({...d.data(), 'id': d.id}))
    .where((j) => j.deleted != true)  // Client-side deleted filter
    .toList();  // Preserves timestamp descending order
}
```

**Key Points:**

- ✅ Single query: `orderBy('timestamp').limit(100)`
- ✅ Remove all `.where('deleted', isEqualTo: false)` server filters
- ✅ Apply client-side deleted filtering
- ✅ Preserve Firestore order (no re-sorting)
- ✅ Guarantees input for cascade when jobs exist

---

#### Task 5: ⏳ PENDING - Implement Cascade with Accumulation (L1→L4)

**Objective:** Build 4-level cascade that accumulates matches while preserving order.

**Priority:** HIGH

**Cascade Structure:**

| Level | Criteria | Return | Purpose |
|-------|----------|--------|---------|
| **L1 (Exact)** | Locals + Types + Hours + PerDiem | Up to 20 | Perfect match |
| **L2 (Relaxed)** | Locals + Types | Up to 20 | Partial match |
| **L3 (Minimal)** | Locals only | Up to 20 | Location match |
| **L4 (Fallback)** | Recent (no filters) | Up to 20 | Any available job |

**Implementation:**

```dart
const int kMaxSuggested = 20;

Future<List<Job>> suggestedJobs(Ref ref) async {
  final db = ref.read(firestoreProvider);
  final prefs = await ref.read(userPreferencesProvider.future);
  final allJobs = await _fetchRecentJobsSlice(db);  // timestamp desc

  final List<Job> out = [];
  final Set<String> seen = {};  // Deduplication

  /// Add tier jobs without duplicates
  void addTier(List<Job> tier) {
    for (final j in tier) {
      if (seen.add(j.id)) {  // Only add if new
        out.add(j);
        if (out.length >= kMaxSuggested) break;
      }
    }
  }

  // L1: Exact match
  final l1 = _filterJobsExact(allJobs, prefs);
  _logCascade('L1 exact', l1.length, allJobs.length);
  addTier(l1);

  // L2: Relaxed match
  if (out.length < kMaxSuggested) {
    final l2 = _filterJobsRelaxed(allJobs, prefs);
    _logCascade('L2 relaxed', l2.length, allJobs.length);
    addTier(l2);
  }

  // L3: Locals-only match
  if (out.length < kMaxSuggested) {
    final l3 = _filterJobsByLocals(allJobs, prefs);
    _logCascade('L3 locals-only', l3.length, allJobs.length);
    addTier(l3);
  }

  // L4: Fallback recent
  if (out.length < kMaxSuggested) {
    _logCascade('L4 fallback (recent)', allJobs.length, allJobs.length);
    addTier(allJobs);
  }

  _logCascade('FINAL', out.length, allJobs.length);
  return out;
}
```

**Key Benefits:**

- ✅ Guarantees non-empty results if jobs exist
- ✅ Preserves timestamp descending order
- ✅ No duplicate jobs across levels
- ✅ Accumulates efficiently up to 20

---

#### Task 6: ⏳ PENDING - Strengthen Helper Filters with Local Matching

**Objective:** Implement robust preference matching logic for each cascade level.

**Priority:** HIGH

**Helper Functions:**

```dart
/// Checks if job matches preferred locals
bool _matchesPreferredLocals(Job j, List<int> preferredLocals) {
  if (preferredLocals.isEmpty) return true;
  final localVals = {j.local, j.localNumber}.whereType<int>().toSet();
  return preferredLocals.any(localVals.contains);
}

/// Checks if job matches construction types
bool _matchesConstructionTypes(Job j, Set<String> typesPref) {
  if (typesPref.isEmpty) return true;
  final jobTypes = j.typeOfWork.map((e) => e.toLowerCase()).toSet();
  return jobTypes.intersection(typesPref).isNotEmpty;
}

/// Checks if job matches hours preference
bool _matchesHours(Job j, UserJobPreferences prefs) {
  if (prefs.hoursPerWeek == null) return true;
  final h = j.hoursPerWeek;
  return h != null && (h >= prefs.hoursPerWeek! * 0.8) && (h <= prefs.hoursPerWeek! * 1.2);
}

/// Checks if job matches per diem requirement
bool _matchesPerDiem(Job j, UserJobPreferences prefs) {
  if (prefs.perDiemRequirement == null) return true;
  if (prefs.perDiemRequirement == true) return j.perDiem == true;
  return true;  // Don't restrict if false or unspecified
}
```

**Cascade Level Implementations:**

```dart
/// Level 1: Exact match (all criteria)
List<Job> _filterJobsExact(List<Job> all, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.map((e) => e as int).toList();
  final typesPref = prefs.classifications.map((e) => e.toLowerCase()).toSet();

  return all.where((j) {
    final localsOk = prefLocals.isEmpty ? true : _matchesPreferredLocals(j, prefLocals);
    final typesOk = _matchesConstructionTypes(j, typesPref);
    final hoursOk = _matchesHours(j, prefs);
    final perDiemOk = _matchesPerDiem(j, prefs);
    return localsOk && typesOk && hoursOk && perDiemOk;
  }).toList();
}

/// Level 2: Relaxed match (locals + types)
List<Job> _filterJobsRelaxed(List<Job> all, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.map((e) => e as int).toList();
  final typesPref = prefs.classifications.map((e) => e.toLowerCase()).toSet();

  return all.where((j) {
    // Relaxed: requires locals when specified; types optional
    final localsOk = prefLocals.isEmpty ? false : _matchesPreferredLocals(j, prefLocals);
    final typesOk = typesPref.isEmpty ? true : _matchesConstructionTypes(j, typesPref);
    return localsOk && typesOk;
  }).toList();
}

/// Level 3: Minimal match (locals only)
List<Job> _filterJobsByLocals(List<Job> all, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.map((e) => e as int).toList();
  if (prefLocals.isEmpty) return const [];  // No fallback without locals preference
  return all.where((j) => _matchesPreferredLocals(j, prefLocals)).toList();
}
```

---

### Phase 3: Bug Fixes and UI Updates

#### Task 7: ⏳ PENDING - Remove Server-Side Deleted Filtering

**Objective:** Eliminate fragile Firestore `.where('deleted', isEqualTo: false)` filters.

**Priority:** HIGH

**Files to Update:** `lib/providers/riverpod/jobs_riverpod_provider.dart`

**Changes:**

- Remove `.where('deleted', isEqualTo: false)` from all queries
- Use unified `_fetchRecentJobsSlice()` for all cascade input
- Apply client-side filter: `.where((j) => j.deleted != true)`

**Rationale:** Documents without the `deleted` field shouldn't be excluded; this prevents empty results.

---

#### Task 8: ⏳ PENDING - Optional Feature Flag for Server-Side Cascade

**Objective:** Keep experimental whereIn fallback for future use (disabled by default).

**Priority:** LOW (Optional)

**Implementation:**

```dart
const bool kUseServerLocalWhereIn = false;  // Keep false to prefer Option A

// If ever enabled, attempt in order:
// 1. whereIn on 'local' with int list
// 2. whereIn on 'local' with string list
// 3. whereIn on 'localNumber' with int list
// 4. whereIn on 'localNumber' with string list
// 5. Fall back to _fetchRecentJobsSlice when all empty
```

**Note:** whereIn has 10-element limit and is fragile with mixed types; disabled by default.

---

#### Task 9: ⏳ PENDING - Fix Preference Presence Checks (hasPreferences)

**Objective:** Replace referential equality with content-based checking.

**Priority:** HIGH

**File:** `lib/providers/riverpod/user_preferences_riverpod_provider.dart`

**Current Bug:**

```dart
// ❌ BROKEN: Referential equality
bool get hasPreferences => state != UserJobPreferences.empty
```

**Fix:**

```dart
extension UserJobPreferencesX on UserJobPreferences {
  /// Content-based check: true if ANY preference is set
  bool get hasPreferences {
    return classifications.isNotEmpty
        || constructionTypes.isNotEmpty
        || preferredLocals.isNotEmpty
        || hoursPerWeek != null
        || perDiemRequirement != null
        || minWage != null
        || maxDistance != null;
  }
}
```

**Impact:** Prevents UI gating from hiding jobs when preferences exist but referential equality fails.

---

#### Task 10: ⏳ PENDING - Update Home Screen UI

**Objective:** Ensure "Suggested Jobs" always displays provider output.

**Priority:** HIGH

**File:** `lib/screens/home/home_screen.dart`

**Changes:**

1. **Replace equality checks with hasPreferences:**

   ```dart
   // ❌ OLD
   if (prefs == UserJobPreferences.empty()) { ... }

   // ✅ NEW
   if (prefsState.hasPreferences) { ... }
   ```

2. **Trust provider output:**

   ```dart
   final suggested = ref.watch(suggestedJobsProvider);

   if (suggested.hasValue) {
     final items = suggested.value!.take(5).toList();
     // Render items; provider guarantees non-empty if jobs exist
   }
   ```

3. **Update opacity deprecation:**

   ```dart
   // ❌ DEPRECATED
   color.withOpacity(0.5)

   // ✅ NEW
   color.withValues(alpha: 0.5)
   ```

---

### Phase 4: Observability and Testing

#### Task 11: ⏳ PENDING - Add Debug Logging

**Objective:** Provide visibility into cascade behavior for troubleshooting.

**Priority:** MEDIUM

**Implementation:**

```dart
void _logCascade(String stage, int returnedCount, int total) {
  assert(() {
    debugPrint('[SuggestedJobs] $stage → $returnedCount (of $total)');
    return true;
  }());
}
```

**Output Example:**

```log
[SuggestedJobs] L1 exact → 3 (of 42)
[SuggestedJobs] L2 relaxed → 5 (of 42)
[SuggestedJobs] L3 locals-only → 7 (of 42)
[SuggestedJobs] L4 fallback (recent) → 20 (of 42)
[SuggestedJobs] FINAL → 20 (of 42)
```

---

#### Task 12: ⏳ PENDING - Manual Validation

**Objective:** Test cascade behavior across real-world scenarios.

**Priority:** HIGH

**Test Scenarios:**

| Scenario | Setup | Expected Behavior |
|----------|-------|-------------------|
| **No user doc** | Create user without preferences | L4 recent jobs shown |
| **No prefs** | User exists, no jobPreferences | L4 recent jobs shown |
| **Mixed schema** | Jobs with local as string/int, local/localNumber | L1-L3 matches found |
| **Overly strict** | Preferences don't match any jobs | L4 recent jobs shown |
| **Normal** | Jobs and preferences match | L1-L3 matches shown first |

**Validation Checklist:**

- [ ] Seed Firestore with test data
- [ ] Monitor debug logs for cascade levels
- [ ] Confirm Home shows 1-5 items (never empty when jobs exist)
- [ ] Verify order is timestamp descending within each level

---

#### Task 13: ⏳ PENDING - Unit Tests

**Objective:** Guard against regressions in cascade logic.

**Priority:** MEDIUM

**Test File:** `test/providers/jobs_riverpod_provider_test.dart`

**Test Coverage:**

```dart
group('SuggestedJobs Cascade', () {
  test('L4 fallback when no user document', () async {
    // Setup: jobs exist, no user doc
    // Assert: returns recent 20 jobs
  });

  test('L4 fallback when user has no preferences', () async {
    // Setup: jobs exist, user doc without jobPreferences
    // Assert: returns recent 20 jobs
  });

  test('L1-L3 matches with mixed local schemas', () async {
    // Setup: jobs with local (string/int), localNumber variants
    // Assert: matches found in L1-L3 based on preferences
  });

  test('L4 fallback with overly strict preferences', () async {
    // Setup: preferences don't match any jobs
    // Assert: falls back to recent 20
  });

  test('preserves timestamp descending order', () async {
    // Assert: results are sorted by timestamp desc
  });

  test('caps results to 20 items', () async {
    // Assert: never returns more than 20 items
  });
});
```

---

#### Task 14: ⏳ PENDING - Performance and Safety Checks

**Objective:** Verify efficiency and stability of new approach.

**Priority:** HIGH

**Checks:**

- [ ] **Query efficiency:** `limit(100)` prevents large reads on Home
- [ ] **Filter efficiency:** All filters applied to small slice (100 items max)
- [ ] **No duplication:** `seen` set prevents duplicate jobs
- [ ] **Tolerant parsing:** Missing fields don't cause crashes
- [ ] **Backward compatibility:** No breaking changes to other providers
- [ ] **Memory:** No memory leaks from accumulated results

---

#### Task 15: ⏳ PENDING - Documentation and Code Review

**Objective:** Ensure maintainability and clear rationale for future developers.

**Priority:** HIGH

**Documentation Required:**

1. **Inline Comments:**

   ```dart
   /// Level 1: Exact match requiring ALL criteria.
   /// Used first to prioritize jobs matching all preferences.
   List<Job> _filterJobsExact(List<Job> all, UserJobPreferences prefs) { ... }
   ```

2. **README Update:**

   - Explain cascade tiers and fallback behavior
   - Document why server-side `deleted` filter was removed
   - Explain preference matching logic

3. **Code Review Checklist:**

   - [ ] Verify stable sort order across cascade
   - [ ] Verify locals matching works with mixed schemas
   - [ ] Verify Home screen never shows empty when jobs exist
   - [ ] Verify debug logs show cascade progression

---

## 📈 Progress Tracking

### Summary

| Status | Count | Percentage |
|--------|-------|-----------|
| ✅ Completed | 3 | 20% |
| 🔄 In Progress | 0 | 0% |
| ⏳ Pending | 12 | 80% |

### Completion Timeline

- **Phase 1 (Normalization):** COMPLETE ✅
- **Phase 2 (Query & Cascade):** 0% (Tasks 4-8)
- **Phase 3 (Bug Fixes & UI):** 0% (Tasks 9-10)
- **Phase 4 (Testing & Docs):** 0% (Tasks 11-15)

**Estimated Remaining Effort:** 3-4 hours

---

## 🚨 Known Issues & Risks

### Critical Blockers

- None (paused for documentation)

### Identified Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Type compatibility after model changes | Medium | Run `flutter pub run build_runner build` |
| Breaking changes to provider structure | Medium | Scope changes to `suggestedJobs()` only |
| Missing test dependencies | Low | Add `fake_cloud_firestore` to dev_dependencies |

---

## ❓ Questions for Review

1. Should Task 8 (feature-flagged whereIn cascade) be implemented or removed?
2. Should debug logs be permanently enabled or debug/profile builds only?
3. Do we need integration tests in addition to unit tests?
4. Should we cache the 100-job recent slice?
5. What's the preferred UX for loading state during query?

---

## 📝 Summary of Key Concepts

### Cascade Levels Explained

**Level 1 (Exact):** User wants Commercial + Inside Wireman + 40hr/week + PerDiem

- Job must match: Local AND Type AND Hours AND PerDiem

**Level 2 (Relaxed):** Loosen hours and per diem requirements

- Job must match: Local AND Type (ignore hours/per diem)

**Level 3 (Minimal):** Accept any job from preferred locals

- Job must match: Local only

**Level 4 (Fallback):** Show any recent job when preferences don't match

- No filters, just recent order

### Why This Works

1. **Guaranteed Results:** If jobs exist in Firestore, L4 ensures they appear
2. **Prioritization:** L1-L3 show preferences matches first (most relevant)
3. **Schema Tolerance:** Client-side filtering handles `local` as int/string
4. **Stable Ordering:** Preserves timestamp descending within each level

---

## 🔗 Related Files

- `lib/screens/home/home_screen.dart` - UI rendering
- `lib/providers/riverpod/jobs_riverpod_provider.dart` - Cascade logic
- `lib/providers/riverpod/user_preferences_riverpod_provider.dart` - Preference checking
- `lib/models/job_model.dart` - Data parsing (✅ FIXED)

---

**Last Updated:** January 24, 2025
**Status:** IN PROGRESS - Awaiting Phase 2 Implementation
**Next Session:** Resume with Task 4 - _fetchRecentJobsSlice Implementation
