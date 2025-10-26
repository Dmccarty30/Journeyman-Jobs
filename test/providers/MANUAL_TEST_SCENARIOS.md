# Manual Test Scenarios for Cascading Job Suggestions

This document outlines manual validation test scenarios for the 4-level cascading fallback system in `suggestedJobs` provider.

## Test Environment Setup

**Prerequisites:**
- Flutter app running in debug mode
- Access to Firestore console for data manipulation
- User authentication configured
- Debug console visible to see cascade logging

## Scenario 1: No User Document (L4 Fallback)

**Purpose:** Verify fallback when user document doesn't exist in Firestore

**Setup:**
1. Delete the user's document from `users/{uid}` collection in Firestore
2. Ensure user is still authenticated (Firebase Auth session active)

**Expected Behavior:**
- ✅ App loads without crashing
- ✅ Home screen shows 20 recent jobs
- ✅ Debug log shows: `🔴 CASCADE L4: 20/20 jobs - No user document found`
- ✅ Jobs are sorted by timestamp (most recent first)

**Validation:**
```dart
// Expected debug output:
// 🔴 CASCADE L4: 20/20 jobs - No user document found

// Verify in debug console:
assert(jobs.length <= 20);
assert(jobs.first.timestamp >= jobs.last.timestamp); // Descending order
```

---

## Scenario 2: No Preferences Set (L4 Fallback)

**Purpose:** Verify fallback when user exists but has no jobPreferences

**Setup:**
1. Ensure user document exists in `users/{uid}`
2. Remove `jobPreferences` field from user document (or set to null)
3. User document structure:
   ```json
   {
     "uid": "test-user-123",
     "email": "test@example.com",
     "displayName": "Test User"
     // No jobPreferences field
   }
   ```

**Expected Behavior:**
- ✅ App loads without crashing
- ✅ Home screen shows 20 recent jobs
- ✅ Debug log shows: `🔴 CASCADE L4: 20/20 jobs - No jobPreferences key in user data`
- ✅ Jobs are sorted by timestamp

**Validation:**
```dart
// Expected debug output:
// 🔴 CASCADE L4: 20/20 jobs - No jobPreferences key in user data

assert(jobs.length <= 20);
assert(jobs.every((job) => !job.deleted));
```

---

## Scenario 3: Mixed Schema - Local as Int vs String

**Purpose:** Test schema-agnostic parsing of local field (int vs string)

**Setup:**
1. Create test jobs with mixed local field types:
   ```json
   {
     "id": "job-1",
     "local": 123,           // Integer
     "company": "ABC Electric",
     "location": "New York"
   },
   {
     "id": "job-2",
     "local": "456",         // String
     "company": "XYZ Power",
     "location": "Boston"
   },
   {
     "id": "job-3",
     "local": "789-Local",   // String with suffix
     "company": "DEF Contractors",
     "location": "Chicago"
   }
   ```

2. Set user preferences:
   ```json
   {
     "jobPreferences": {
       "preferredLocals": [123, 456, 789],
       "constructionTypes": ["commercial"],
       "hoursPerWeek": "40",
       "perDiemRequirement": null
     }
   }
   ```

**Expected Behavior:**
- ✅ All three jobs are correctly parsed
- ✅ Integer 123 matches preference
- ✅ String "456" is parsed to int and matches
- ✅ String "789-Local" is parsed to int 789 and matches
- ✅ Jobs appear in suggested list (L1, L2, or L3 depending on other criteria)

**Validation:**
```dart
final job1 = jobs.firstWhere((j) => j.id == 'job-1');
assert(job1.local == 123);

final job2 = jobs.firstWhere((j) => j.id == 'job-2');
assert(job2.local == 456);

final job3 = jobs.firstWhere((j) => j.id == 'job-3');
assert(job3.local == 789);
```

---

## Scenario 4: Overly Strict Preferences (L4 Fallback)

**Purpose:** Verify cascade to L4 when user preferences are too strict

**Setup:**
1. Set unrealistic user preferences:
   ```json
   {
     "jobPreferences": {
       "preferredLocals": [9999],        // Non-existent local
       "constructionTypes": ["underwater_basket_weaving"],
       "hoursPerWeek": "100+",           // Unrealistic hours
       "perDiemRequirement": "$500+/day" // Unrealistic per diem
     }
   }
   ```

2. Ensure jobs collection has typical jobs (none matching these criteria)

**Expected Behavior:**
- ✅ No matches at L1 (exact match)
- ✅ No matches at L2 (relaxed match)
- ✅ No matches at L3 (local 9999 doesn't exist)
- ✅ Falls back to L4 with recent jobs
- ✅ Debug log shows progression through all levels:
  ```
  🔄 Querying jobs where local in: [9999]
  📊 Server query returned 0 jobs
  🔴 CASCADE L4: 20/20 jobs - No matches found - recent jobs fallback
  ```

**Validation:**
```dart
// Verify fallback occurred
assert(jobs.length <= 20);
assert(jobs.every((job) => job.local != 9999));
```

---

## Scenario 5: Normal Matching (L1-L3 Cascade)

**Purpose:** Test all cascade levels with realistic data

### 5A: Level 1 - Exact Match

**Setup:**
1. User preferences:
   ```json
   {
     "preferredLocals": [123, 456],
     "constructionTypes": ["commercial", "industrial"],
     "hoursPerWeek": "40",
     "perDiemRequirement": "$100+/day"
   }
   ```

2. Create jobs matching ALL criteria:
   ```json
   {
     "local": 123,
     "typeOfWork": "commercial",
     "hours": 40,
     "perDiem": "$150/day",
     "timestamp": "2025-10-25T12:00:00Z"
   }
   ```

**Expected Behavior:**
- ✅ Debug log: `✅ CASCADE L1: X/Y jobs - Exact match on all preferences`
- ✅ Only shows jobs matching ALL criteria
- ✅ Limited to 20 jobs max

### 5B: Level 2 - Relaxed Match

**Setup:**
1. Same preferences as 5A
2. Jobs match locals + construction types, but NOT hours or per diem:
   ```json
   {
     "local": 123,
     "typeOfWork": "commercial",
     "hours": 60,              // Different hours
     "perDiem": "$50/day",     // Different per diem
     "timestamp": "2025-10-25T12:00:00Z"
   }
   ```

**Expected Behavior:**
- ✅ Debug log: `⚠️ CASCADE L2: X/Y jobs - Relaxed match (locals + construction types)`
- ✅ Shows jobs matching locals and construction types
- ✅ Ignores hours and per diem mismatches

### 5C: Level 3 - Minimal Match

**Setup:**
1. Same preferences as 5A
2. Jobs match locals only (no construction type match):
   ```json
   {
     "local": 123,
     "typeOfWork": "residential", // Different type
     "hours": 50,
     "perDiem": "$75/day",
     "timestamp": "2025-10-25T12:00:00Z"
   }
   ```

**Expected Behavior:**
- ✅ Debug log: `🔵 CASCADE L3: X/Y jobs - Minimal match (preferred locals only)`
- ✅ Shows ANY jobs from preferred locals
- ✅ Ignores all other criteria

---

## Additional Edge Cases

### Edge Case 1: Empty Results at Each Level

**Test Progression:**
1. Set preferences with local 123
2. Create 10 jobs with local 123, wrong construction type
3. Verify L1 returns 0 (no exact match)
4. Verify L2 returns 0 (no construction type match)
5. Verify L3 returns 10 (local match)

**Expected Log Sequence:**
```
🔄 Querying jobs where local in: [123]
📊 Server query returned 10 jobs
🔵 CASCADE L3: 10/10 jobs - Minimal match (preferred locals only)
```

### Edge Case 2: Exactly 20 Jobs at Each Level

**Test Data Limits:**
- Create 50 jobs matching L1 criteria
- Verify only 20 are returned
- Verify `.take(20)` is applied correctly

**Validation:**
```dart
assert(jobs.length == 20);
assert(matchedJobs.length >= 20); // More available but limited
```

### Edge Case 3: Timestamp Ordering

**Setup:**
1. Create jobs with varying timestamps
2. Verify results are ordered by `timestamp DESC`

**Validation:**
```dart
for (int i = 0; i < jobs.length - 1; i++) {
  assert(
    jobs[i].timestamp!.isAfter(jobs[i + 1].timestamp!) ||
    jobs[i].timestamp!.isAtSameMomentAs(jobs[i + 1].timestamp!)
  );
}
```

---

## Test Execution Checklist

- [ ] Scenario 1: No user document (L4)
- [ ] Scenario 2: No preferences (L4)
- [ ] Scenario 3: Mixed schema (local as int/string)
- [ ] Scenario 4: Overly strict preferences (L4)
- [ ] Scenario 5A: Normal match - L1
- [ ] Scenario 5B: Normal match - L2
- [ ] Scenario 5C: Normal match - L3
- [ ] Edge Case 1: Empty results progression
- [ ] Edge Case 2: 20-item limit
- [ ] Edge Case 3: Timestamp ordering

---

## Debug Log Reference

**Cascade Level Indicators:**
- ✅ L1: Exact match on all preferences
- ⚠️ L2: Relaxed match (locals + construction types)
- 🔵 L3: Minimal match (preferred locals only)
- 🔴 L4: Fallback to recent jobs

**Log Format:**
```
[EMOJI] CASCADE [LEVEL]: [MATCHED]/[TOTAL] jobs - [EXTRA_INFO]
```

**Example Logs:**
```
✅ CASCADE L1: 15/50 jobs - Exact match on all preferences
⚠️ CASCADE L2: 8/50 jobs - Relaxed match (locals + construction types)
🔵 CASCADE L3: 20/35 jobs - Minimal match (preferred locals only)
🔴 CASCADE L4: 20/20 jobs - No matches found - recent jobs fallback
```

---

## Success Criteria

All scenarios must:
1. ✅ Never crash or throw unhandled exceptions
2. ✅ Always return jobs (never empty list)
3. ✅ Respect 20-item limit
4. ✅ Maintain timestamp ordering (DESC)
5. ✅ Show correct cascade level in debug logs
6. ✅ Filter deleted jobs (deleted=false)
7. ✅ Handle mixed schemas gracefully
8. ✅ Provide fallback to recent jobs when needed
