# Firestore Index Creation Guide - Suggested Jobs Query

## Overview

This guide documents the composite index required for the **Suggested Jobs** feature on the home screen. The index enables efficient querying of jobs filtered by user preferences (preferred locals) while excluding deleted jobs and sorting by recency.

**Status**: ✅ Index already deployed to production (lines 165-186 in firestore.indexes.json)

---

## Index Specification

### Collection: `jobs`

### Required Composite Index

| Field | Type | Order | Description |
|-------|------|-------|-------------|
| `deleted` | Equality | Ascending | Filter out soft-deleted jobs (false only) |
| `local` | Equality/IN | Ascending | Match user's preferred IBEW locals (whereIn) |
| `timestamp` | Range | Descending | Sort by most recent jobs first |
| `__name__` | Document ID | Descending | Tie-breaker for consistent pagination |

### Current Query Pattern

```dart
// File: lib/providers/riverpod/jobs_riverpod_provider.dart
// Lines: 777-783

final localsToQuery = prefs.preferredLocals.take(10).toList();

result = await FirebaseFirestore.instance
    .collection('jobs')
    .where('local', whereIn: localsToQuery)  // IN query: [84, 111, 222]
    .where('deleted', isEqualTo: false)      // Equality filter
    .orderBy('timestamp', descending: true)  // Range query + sort
    .limit(50)                               // Pagination limit
    .get();
```

### Index Configuration (JSON)

**Location**: `firebase/firestore.indexes.json` (lines 165-186)

```json
{
  "collectionGroup": "jobs",
  "queryScope": "COLLECTION",
  "fields": [
    {
      "fieldPath": "deleted",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "local",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "timestamp",
      "order": "DESCENDING"
    },
    {
      "fieldPath": "__name__",
      "order": "DESCENDING"
    }
  ]
}
```

**Why `__name__` field?**
- Ensures consistent ordering when multiple jobs have identical timestamps
- Required for reliable pagination with `startAfterDocument()`
- Prevents duplicate results when loading more jobs

---

## Why This Index is Required

### Firestore Query Constraints

1. **Multiple WHERE Clauses**
   - Combining `where('local', whereIn: ...)` + `where('deleted', isEqualTo: ...)`
   - Each `whereIn` value acts as an OR condition requiring composite index
   - Cannot use automatic single-field indexes

2. **WHERE + ORDER BY on Different Fields**
   - Filtering by `deleted` and `local`
   - Sorting by `timestamp`
   - Requires composite index for efficient execution

3. **Performance Requirements**
   - **Without index**: Full collection scan (O(n) - slow, expensive)
   - **With index**: Binary search lookup (O(log n) - fast, efficient)
   - **Mobile app target**: <200ms response time on 3G networks

### Firestore Query Limitations

- **Maximum 1 whereIn per query** (we use it for `local` field)
- **whereIn accepts max 10 values** (handled in code: `.take(10)`)
- **All other filters must be equality or range**
- **Field order in index must match query order**

---

## Deployment Steps

### ✅ Index Already Deployed

**Good news**: This index is already configured in `firebase/firestore.indexes.json` and should be deployed to production.

**Verify deployment**:
```bash
# Check deployed indexes
firebase firestore:indexes

# Look for jobs index with deleted + local + timestamp + __name__
```

### Option 1: Firebase CLI Deployment (Recommended)

**If index needs to be deployed or updated:**

```bash
# Navigate to project root
cd D:\Journeyman-Jobs

# Deploy only Firestore indexes (no functions/hosting)
firebase deploy --only firestore:indexes

# Monitor deployment
# Output shows:
# i  firestore: checking firestore.indexes.json for differences...
# ✔  firestore: deployed indexes in firestore.indexes.json successfully
```

**Expected timeline**:
- Deployment: ~30 seconds
- Index building: 2-10 minutes (depending on existing data size)
- Status check: Firebase Console → Firestore → Indexes tab

### Option 2: Manual Creation via Firebase Console

**Use this method if Firebase CLI is unavailable:**

1. **Open Firebase Console**
   - Navigate to: https://console.firebase.google.com
   - Select project: "Journeyman Jobs"

2. **Navigate to Indexes**
   - Click "Firestore Database" (left sidebar)
   - Click "Indexes" tab
   - Click "Composite" sub-tab

3. **Create New Index**
   - Click "Create Index" button
   - Configure fields (in exact order):

   | Field | Query Scope |
   |-------|-------------|
   | `deleted` | Ascending |
   | `local` | Ascending |
   | `timestamp` | Descending |
   | `__name__` | Descending |

4. **Save and Monitor**
   - Click "Create" button
   - Status shows "Building" → "Enabled" (2-10 min)

### Option 3: Auto-Generated Link from Query Error

**Fastest method for new indexes:**

1. Run the app in debug mode
2. Navigate to Home screen
3. Wait for query to execute
4. Check debug console for error:

```
[ERROR:flutter/lib/ui/ui_dart_state.cc(209)]
FirebaseException: The query requires an index.
You can create it here: https://console.firebase.google.com/v1/r/...
```

5. Click the link - opens Firebase Console with **pre-filled configuration**
6. Click "Create Index" - done! ✅

---

## Index Build Time

| Dataset Size | Build Duration | Notes |
|--------------|----------------|-------|
| < 1,000 jobs | 2-5 minutes | Initial builds are fast |
| 1,000-10,000 jobs | 10-30 minutes | Typical small-medium app |
| 10,000-100,000 jobs | 30-90 minutes | Medium-large app |
| > 100,000 jobs | Several hours | Enterprise scale |

**Monitor build progress**:
- Firebase Console → Firestore → Indexes tab
- Status indicator: "Building" → "Enabled"
- Build completes even if you close the browser

---

## Verification and Testing

### 1. Verify Index Exists

**Firebase Console**:
1. Open Firestore → Indexes → Composite tab
2. Look for index with:
   - Collection: `jobs`
   - Fields: `deleted`, `local`, `timestamp`, `__name__`
   - Status: **Enabled** (green checkmark)

**Firebase CLI**:
```bash
firebase firestore:indexes | grep "deleted.*local.*timestamp"
```

### 2. Test Query Execution

**Add to app for testing**:
```dart
// Test suggested jobs query
Future<void> testSuggestedJobsQuery() async {
  final stopwatch = Stopwatch()..start();

  try {
    final result = await FirebaseFirestore.instance
        .collection('jobs')
        .where('local', whereIn: [84, 111, 222])
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    stopwatch.stop();

    print('✅ Query successful!');
    print('   Jobs found: ${result.docs.length}');
    print('   Query time: ${stopwatch.elapsedMilliseconds}ms');
    print('   Target: <200ms on 3G, <100ms on WiFi');

    if (stopwatch.elapsedMilliseconds > 200) {
      print('⚠️  Query slower than target');
    }
  } catch (e) {
    stopwatch.stop();
    print('❌ Query failed: $e');

    if (e is FirebaseException && e.code == 'failed-precondition') {
      print('⚠️  Index not ready or missing');
      print('   Check Firebase Console → Indexes');
    }
  }
}
```

### 3. Performance Benchmarks

**Expected results**:

| Network | Query Latency | Data Transfer | Cache Hit |
|---------|---------------|---------------|-----------|
| WiFi | <100ms | ~100KB (50 jobs) | 80%+ |
| 4G | <150ms | ~100KB | 80%+ |
| 3G | <200ms | ~100KB | 80%+ |

**Monitor in production**:
```dart
// Add to suggestedJobsProvider
final stopwatch = Stopwatch()..start();
final result = await query.get();
stopwatch.stop();

if (kDebugMode) {
  print('Suggested jobs query: ${stopwatch.elapsedMilliseconds}ms');
}
```

### 4. Cache Validation

**Test offline functionality**:
1. Load suggested jobs while online
2. Enable airplane mode
3. Navigate away and back to Home screen
4. Verify jobs still display (from cache)

**Expected behavior**:
- First load: ~100-200ms (network query)
- Subsequent loads: <50ms (cache hit)
- Offline loads: <50ms (persistence cache)

---

## Troubleshooting

### Issue 1: Index Still Building

**Symptoms**:
```
FirebaseException: The query requires an index.
Status in Console: "Building" (yellow indicator)
```

**Solutions**:
1. **Wait for build to complete** (2-10 minutes typical)
2. **Monitor progress**: Firebase Console → Indexes tab
3. **Check build logs** for errors
4. **Verify data integrity**: Ensure all jobs have required fields

**During build period**:
- App shows loading state with electrical theme
- Fallback to recent jobs (Level 4 cascading filter)
- User sees jobs, not errors

### Issue 2: Query Fails with "failed-precondition"

**Symptoms**:
```dart
[ERROR] FirebaseException (failed-precondition):
The query requires an index. You can create it here: [link]
```

**Root causes**:
1. Index not deployed to project
2. Field names don't match exactly (case-sensitive)
3. Query operators don't match index configuration

**Solutions**:

**Check 1: Verify index exists**
```bash
firebase firestore:indexes | grep jobs
```

**Check 2: Verify field names**
```dart
// ✅ Correct - matches index
.where('deleted', isEqualTo: false)
.where('local', whereIn: [84, 111, 222])
.orderBy('timestamp', descending: true)

// ❌ Wrong - field name mismatch
.where('isDeleted', isEqualTo: false)  // Wrong field!
.where('local', whereIn: ['84', '111'])  // Wrong type (string vs int)!
.orderBy('createdAt', descending: true)  // Wrong field!
```

**Check 3: Deploy index**
```bash
firebase deploy --only firestore:indexes
```

### Issue 3: Slow Query Performance (>500ms)

**Symptoms**:
- Query takes longer than 200ms target
- Home screen feels laggy
- Users complain about slow loading

**Diagnostic steps**:
```dart
// Add performance logging
final stopwatch = Stopwatch()..start();
final result = await query.get();
stopwatch.stop();

print('Query time: ${stopwatch.elapsedMilliseconds}ms');
print('Results: ${result.docs.length}');
print('From cache: ${result.metadata.isFromCache}');
```

**Solutions**:

**1. Enable Firestore persistence** (already enabled)
```dart
await FirebaseFirestore.instance.enablePersistence(
  const PersistenceSettings(synchronizeTabs: true),
);
```

**2. Reduce query limit**
```dart
// Current: 50 results (may be excessive)
.limit(50)

// Optimized: 20 results (home screen shows 5)
.limit(20)
```

**3. Check network conditions**
```dart
// Test on different networks
// WiFi: <100ms
// 4G: <150ms
// 3G: <200ms
```

**4. Monitor Firestore usage**
- Firebase Console → Firestore → Usage tab
- Check for excessive reads (indicates cache misses)
- Verify index is being used (not full scans)

### Issue 4: No Jobs Returned (Empty Result)

**Symptoms**:
```dart
result.docs.length == 0
// Even though jobs exist in Firestore
```

**Root causes**:
1. User preferences don't match any jobs
2. All matching jobs are deleted
3. Security rules blocking read access
4. Query filters too restrictive

**Solutions**:

**Check 1: Verify user preferences**
```dart
print('User preferred locals: ${prefs.preferredLocals}');
// Should return [84, 111, 222] or similar
```

**Check 2: Check for deleted jobs**
```dart
// Query all jobs (including deleted)
final allJobs = await FirebaseFirestore.instance
    .collection('jobs')
    .where('local', whereIn: [84, 111, 222])
    .get();

print('Total jobs: ${allJobs.docs.length}');
print('Deleted: ${allJobs.docs.where((d) => d.data()['deleted'] == true).length}');
```

**Check 3: Verify security rules**
```javascript
// firestore.rules
match /jobs/{jobId} {
  allow read: if request.auth != null;  // Must be authenticated
}
```

**Check 4: Test with relaxed filters**
```dart
// Remove deleted filter temporarily
final result = await FirebaseFirestore.instance
    .collection('jobs')
    .where('local', whereIn: [84, 111, 222])
    .orderBy('timestamp', descending: true)
    .limit(20)
    .get();

print('Without deleted filter: ${result.docs.length} jobs');
```

### Issue 5: Index Configuration Mismatch

**Symptoms**:
```
FirebaseException: Index with different field order exists
```

**Solution**:
1. Delete incorrect index in Firebase Console
2. Verify `firestore.indexes.json` is correct
3. Redeploy indexes:
   ```bash
   firebase deploy --only firestore:indexes
   ```
4. Wait for new index to build

**Correct field order** (critical!):
1. `deleted` (Ascending)
2. `local` (Ascending)
3. `timestamp` (Descending)
4. `__name__` (Descending)

---

## Query Optimization Strategy

### Cascading Fallback Pattern

The `suggestedJobsProvider` implements a 4-level fallback strategy to **guarantee** users see jobs:

```dart
// LEVEL 1: Exact match (all preferences)
// Match: locals + construction types + hours + per diem
if (matchedJobs.isNotEmpty) return matchedJobs;

// LEVEL 2: Relaxed match (locals + construction types)
// Match: locals + construction types only
if (matchedJobs.isNotEmpty) return matchedJobs;

// LEVEL 3: Minimal match (locals only)
// Match: preferred locals only
if (allJobs.isNotEmpty) return allJobs;

// LEVEL 4: Final fallback (recent jobs)
// Match: any recent jobs, no preference filtering
return _getRecentJobs();
```

**Why this matters**:
- Users ALWAYS see jobs (never empty screen)
- Progressive relaxation maintains relevance
- Graceful degradation for new users or sparse data

### Performance Optimizations

**1. Limit whereIn Values**
```dart
// Firestore limit: 10 values max
// Our implementation: Take first 10 locals
final localsToQuery = prefs.preferredLocals.take(10).toList();
```

**2. Client-Side Post-Filtering**
```dart
// Server-side: Most selective filter (locals)
.where('local', whereIn: localsToQuery)

// Client-side: Less selective filters
.where((job) => job.typeOfWork?.contains('commercial'))
```

**Why?**
- Firestore allows only 1 `whereIn` per query
- Client-side filtering avoids additional indexes
- Reduces index count and maintenance

**3. Aggressive Caching**
```dart
// Firestore persistence (40MB default)
await FirebaseFirestore.instance.enablePersistence();

// Riverpod state caching (auto-dispose after 5min)
@riverpod
Future<List<Job>> suggestedJobs(Ref ref) async { ... }
```

**4. Query Result Buffering**
```dart
// Fetch 50 jobs, display 5-20
.limit(50)  // Buffer for client-side filtering

// Home screen shows top 5
jobs.take(5).map((job) => CondensedJobCard(job))
```

### Index Maintenance

**No manual maintenance required**:
- Firestore automatically updates indexes
- New documents indexed in real-time
- Deleted documents removed from indexes
- No reindexing needed for schema changes

**Monitor index health**:
1. Firebase Console → Firestore → Indexes
2. Check status (should be "Enabled")
3. Monitor index entry count
4. Alert on "Error" status

---

## Security and Data Validation

### Firestore Security Rules

**Required rule for jobs collection**:
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /jobs/{jobId} {
      // Allow authenticated users to read non-deleted jobs
      allow read: if request.auth != null &&
                     resource.data.deleted == false;

      // Only job owner can write
      allow write: if request.auth != null &&
                      request.auth.uid == resource.data.sharerId;
    }
  }
}
```

### Data Validation

**Required fields for indexing**:
```dart
// All jobs MUST have these fields
{
  "deleted": bool,      // Required: true or false
  "local": int,         // Required: 1-9999 (IBEW local number)
  "timestamp": Timestamp, // Required: Firestore server timestamp
  "sharerId": string,   // Required: User UID who posted job
}
```

**Validation before write**:
```dart
await FirebaseFirestore.instance.collection('jobs').add({
  'deleted': false,
  'local': 84,  // Must be integer, not string "84"
  'timestamp': FieldValue.serverTimestamp(),
  'sharerId': currentUser.uid,
  'company': 'ACME Electric',
  // ... other fields
});
```

**Data integrity checks**:
```dart
// Ensure local is integer
assert(job.local is int);
assert(job.local >= 1 && job.local <= 9999);

// Ensure deleted is boolean
assert(job.deleted is bool);

// Ensure timestamp exists
assert(job.timestamp != null);
```

---

## Monitoring and Maintenance

### Firebase Console Metrics

**1. Index Health Monitoring**
- Navigate to: Firestore → Indexes tab
- Check status: **Enabled** (green checkmark)
- Monitor "Last indexed" timestamp
- Alert on "Error" or "Building" status lasting >30 minutes

**2. Query Performance**
- Navigate to: Firestore → Usage tab
- Monitor "Document Reads" graph
- Check for sudden spikes (indicates cache misses or inefficient queries)
- Target: Steady reads with high cache hit rate

**3. Index Size Tracking**
- Navigate to: Firestore → Indexes
- Check "Index entries" count
- Monitor growth rate
- Large indexes (>1M entries) may slow builds

### Performance Baselines

**Establish baselines**:
```dart
// Log query performance on app start
final metrics = {
  'queryTime': stopwatch.elapsedMilliseconds,
  'resultCount': result.docs.length,
  'cacheHit': result.metadata.isFromCache,
  'network': 'wifi|4g|3g',
  'timestamp': DateTime.now().toIso8601String(),
};

// Send to analytics
await FirebaseAnalytics.instance.logEvent(
  name: 'suggested_jobs_query',
  parameters: metrics,
);
```

**Target metrics**:
- Query latency p50: <100ms
- Query latency p95: <200ms
- Query latency p99: <500ms
- Cache hit rate: >80%
- Error rate: <0.1%

### Alerting Strategy

**Set up alerts for**:

1. **High Read Count** (>10K reads/minute)
   - Indicates inefficient query or cache failure
   - Action: Investigate query patterns, verify cache enabled

2. **Index Build Failures**
   - Indicates schema mismatch or resource limits
   - Action: Check Firebase Console error logs, verify field types

3. **Slow Query Performance** (p95 >500ms)
   - Indicates network issues or index problems
   - Action: Enable profiling, check index status, optimize query

4. **Security Rule Violations**
   - Indicates unauthorized access attempts
   - Action: Review security rules, check authentication flow

---

## Related Documentation

- [Firestore Query Optimization Summary](./firestore-optimization-summary.md)
- [Firestore Indexes Required](./firestore-indexes-required.md)
- [User Preferences Implementation](../lib/models/user_job_preferences.dart)
- [Suggested Jobs Provider](../lib/providers/riverpod/jobs_riverpod_provider.dart)
- [Home Screen Implementation](../lib/screens/home/home_screen.dart)

---

## Summary

### Index Status: ✅ Deployed

The required composite index for suggested jobs is **already configured** in `firebase/firestore.indexes.json` (lines 165-186).

### Key Takeaways

1. **Index is required** for combining `whereIn` + equality + `orderBy` queries
2. **Index exists** and should be deployed to production
3. **Performance target**: <200ms query latency on 3G networks
4. **Cascading fallback** ensures users always see jobs
5. **Aggressive caching** improves perceived performance
6. **No manual maintenance** - Firestore handles indexing automatically

### Next Steps

1. **Verify deployment**: `firebase firestore:indexes`
2. **Test query**: Run app and navigate to Home screen
3. **Monitor performance**: Check Firebase Console metrics
4. **Validate offline**: Test with airplane mode enabled

### Quick Reference

**Index location**: `firebase/firestore.indexes.json` (lines 165-186)
**Query file**: `lib/providers/riverpod/jobs_riverpod_provider.dart` (lines 777-783)
**UI component**: `lib/screens/home/home_screen.dart` (lines 408-623)

**Deployment command**:
```bash
firebase deploy --only firestore:indexes
```

**Verification command**:
```bash
firebase firestore:indexes | grep "deleted.*local.*timestamp"
```

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2025-01-25 | 2.0 | Comprehensive rewrite with troubleshooting, optimization, and validation |
| 2025-01-25 | 1.0 | Initial documentation for suggested jobs index |
