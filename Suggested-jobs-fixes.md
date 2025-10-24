# SUGGESTED JOBS FILTER AND SORT

---

## PLAN

1. Confirm understanding of the task and scope
You reported that the Home screen's "Suggested Jobs" is not displaying any jobs, even though a cascading logic should show exact matches first, then partial matches, and ultimately fall back to recent jobs when nothing matches. You want a robust fix that ensures jobs are always displayed (prioritizing matches first, then partial, then fallback), by hardening the Riverpod provider and related logic, removing fragile Firestore filters such as where('deleted', isEqualTo: false), fixing preference checks, and adjusting filters to include local matching. We will analyze home_screen.dart and all related providers and filters that influence "Suggested Jobs," implement the resilient cascade, and validate with manual scenarios and tests.
2. Baseline analysis and code audit
Review and document current logic paths and dependencies that influence "Suggested Jobs":

- Files to inspect:
  - lib/screens/home/home_screen.dart (UI and how it renders suggested jobs, any empty state logic)
  - lib/providers/riverpod/jobs_riverpod_provider.dart (suggestedJobs provider, _getRecentJobs, filtering helpers, server query filters)
  - lib/providers/riverpod/user_preferences_riverpod_provider.dart (preferences fetching and hasPreferences logic)
  - Job model parsing (Job.fromJson) in lib/models/... (verify local/localNumber, deleted, timestamp, hours, perDiem, constructionTypes fields)
- Capture the exact code paths where:
  - Server-side filters are used (especially .where('deleted', isEqualTo: false) and whereIn with locals)
  - Client filters omit local matching
  - UI logic determines whether to show "No Perfect Matches Yet"
- Run the app to reproduce: confirm "Suggested Jobs" is empty while jobs exist; add temporary logs around provider execution to confirm counts and cascade behavior. Document findings to guide refactor.

3. Normalize Job model parsing to be schema-agnostic for local and deleted
Purpose: Ensure client-side filtering works even when Firestore documents vary in schema (local as string or int, sometimes named localNumber; deleted missing or mis-typed).

Actions:

- In Job.fromJson (lib/models/job.dart or equivalent):
  - Parse local and localNumber as ints regardless of source type.
  - Parse deleted robustly; treat missing deleted as not deleted.
  - Parse timestamp; tolerate missing by falling back to createdAt or epoch.
  - Normalize constructionTypes to lowercase set.
  - Parse hoursPerWeek, perDiem, with reasonable key aliases.

Example (illustrative):

```dart
int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString().trim();
  final digits = RegExp(r'-?\d+').stringMatch(s);
  return digits == null ? null : int.tryParse(digits);
}

DateTime _parseTimestamp(dynamic v) {
  if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

factory Job.fromJson(Map<String, dynamic> json) {
  final localA = _parseInt(json['local']);
  final localB = _parseInt(json['localNumber']);
  final perDiem = (json['perDiem'] == true) || (json['perDiemAvailable'] == true);
  final hours = _parseInt(json['hoursPerWeek']) ?? _parseInt(json['hours']);
  final types = (json['constructionTypes'] as List?)
      ?.map((e) => e.toString().toLowerCase())
      .toSet()
      .toList() ?? const [];

  return Job(
    // keep both if your model has both; otherwise choose one canonical local field
    local: localA ?? localB,
    localNumber: localB ?? localA,
    deleted: json['deleted'] == true, // missing => false
    timestamp: _parseTimestamp(json['timestamp'] ?? json['createdAt']),
    perDiem: perDiem,
    hoursPerWeek: hours,
    constructionTypes: types,
    // ... other fields unchanged
  );
}
```

Relationship to later steps: This normalization allows us to remove server-side schema-specific filters and apply correct client-side matching (especially on preferredLocals) across cascade levels.
4. Refactor suggestedJobs() to a single resilient recent slice (Option A, preferred)
Purpose: Eliminate fragile Firestore filters and local type mismatches by fetching a recent slice once, then applying all preference logic on the client while preserving stable sort.

Actions (lib/providers/riverpod/jobs_riverpod_provider.dart):

- In suggestedJobs() and _getRecentJobs():
  - Remove all .where('deleted', isEqualTo: false) from queries.
  - Do NOT use whereIn on local/localNumber (avoid type mismatch and 10-item limit).
  - Query a single recent slice:
    - orderBy('timestamp', descending: true).limit(100)
  - Map documents to Job via the normalized Job.fromJson.
  - Filter out deleted client-side with job.deleted != true.
  - Preserve the Firestore order (timestamp desc) by not re-sorting the list.

Pseudo-code:

```dart
Future<List<Job>> _fetchRecentJobsSlice(FirebaseFirestore db) async {
  final snap = await db.collection('jobs')
    .orderBy('timestamp', descending: true)
    .limit(100)
    .get();

  final jobs = snap.docs
    .map((d) => Job.fromJson({...d.data(), 'id': d.id}))
    .where((j) => j.deleted != true)
    .toList(); // maintains order-of-insertion => timestamp desc

  return jobs;
}
```

Relationship to cascade: This slice is the canonical ordered input for all tiers (Levels 1–4). It guarantees we always have something to show if the collection has any non-deleted jobs.
5. Implement cascade with accumulation across levels (L1→L4) preserving stable order
Purpose: Prioritize exact matches first, then partial, then locals-only, and finally fallback to recent, while always returning up to N (20) in timestamp-desc order within each tier.

- Levels:
  - Level 1 (exact): locals + construction types + hours + per diem.
  - Level 2 (relaxed): locals + construction types only.
  - Level 3 (minimal): locals only.
  - Level 4 (fallback): recent slice (no other filters except deleted client-side).

- Accumulate results across tiers to fill up to N, without duplicates, preserving the original order within each tier.

Pseudo-code:

```dart
const int kMaxSuggested = 20;

Future<List<Job>> suggestedJobs(Ref ref) async {
  final db = ref.read(firestoreProvider);
  final prefs = await ref.read(userPreferencesProvider.future);
  final allJobs = await _fetchRecentJobsSlice(db); // timestamp desc

  final List<Job> out = [];
  final Set<String> seen = {};

  List<Job> addTier(List<Job> tier) {
    for (final j in tier) {
      if (seen.add(j.id)) out.add(j);
      if (out.length >= kMaxSuggested) break;
    }
    return out;
  }

  final l1 = _filterJobsExact(allJobs, prefs);
  _logCascade('L1 exact', l1.length, allJobs.length);
  addTier(l1);

  if (out.length < kMaxSuggested) {
    final l2 = _filterJobsRelaxed(allJobs, prefs);
    _logCascade('L2 relaxed', l2.length, allJobs.length);
    addTier(l2);
  }

  if (out.length < kMaxSuggested) {
    final l3 = _filterJobsByLocals(allJobs, prefs);
    _logCascade('L3 locals-only', l3.length, allJobs.length);
    addTier(l3);
  }

  if (out.length < kMaxSuggested) {
    _logCascade('L4 fallback (recent)', allJobs.length, allJobs.length);
    addTier(allJobs);
  }

  _logCascade('FINAL', out.length, allJobs.length);
  return out;
}
```

Notes:

- This approach guarantees non-empty results if the collection contains any non-deleted jobs.
- Stable ordering: each tier uses allJobs' order (timestamp desc) and we don’t re-sort after filtering.

6. Strengthen helper filters and include preferred locals in exact/relaxed/minimal tiers
Purpose: Align tier definitions with requirements and make matching consistent.

Implement helpers in jobs_riverpod_provider.dart:

```dart
bool _matchesPreferredLocals(Job j, List<int> preferredLocals) {
  if (preferredLocals.isEmpty) return true; // L1 special-case handled below
  final localVals = {j.local, j.localNumber}.whereType<int>().toSet();
  return preferredLocals.any(localVals.contains);
}

bool _matchesConstructionTypes(Job j, Set<String> typesPref) {
  if (typesPref.isEmpty) return true;
  final jobTypes = j.constructionTypes.map((e) => e.toLowerCase()).toSet();
  return jobTypes.intersection(typesPref).isNotEmpty;
}

bool _matchesHours(Job j, UserJobPreferences prefs) {
  // Define your business rule; a simple example:
  if (prefs.hoursPerWeek == null) return true;
  final h = j.hoursPerWeek;
  return h != null && (h >= prefs.hoursPerWeek! * 0.8) && (h <= prefs.hoursPerWeek! * 1.2);
}

bool _matchesPerDiem(Job j, UserJobPreferences prefs) {
  if (prefs.perDiemRequirement == null) return true;
  if (prefs.perDiemRequirement == true) return j.perDiem == true;
  return true; // if false or unspecified, don't restrict
}

List<Job> _filterJobsExact(List<Job> all, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.map((e) => e as int).toList();
  final typesPref = prefs.constructionTypes.map((e) => e.toLowerCase()).toSet();

  // Exact requires locals match when preferredLocals is not empty
  return all.where((j) {
    final localsOk = prefLocals.isEmpty ? true : _matchesPreferredLocals(j, prefLocals);
    final typesOk = _matchesConstructionTypes(j, typesPref);
    final hoursOk = _matchesHours(j, prefs);
    final perDiemOk = _matchesPerDiem(j, prefs);
    return localsOk && typesOk && hoursOk && perDiemOk;
  }).toList(); // preserves order
}

List<Job> _filterJobsRelaxed(List<Job> all, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.map((e) => e as int).toList();
  final typesPref = prefs.constructionTypes.map((e) => e.toLowerCase()).toSet();

  // Relaxed requires locals match; types optional if empty
  return all.where((j) {
    final localsOk = prefLocals.isEmpty ? false : _matchesPreferredLocals(j, prefLocals);
    final typesOk = typesPref.isEmpty ? true : _matchesConstructionTypes(j, typesPref);
    return localsOk && typesOk;
  }).toList();
}

List<Job> _filterJobsByLocals(List<Job> all, UserJobPreferences prefs) {
  final prefLocals = prefs.preferredLocals.map((e) => e as int).toList();
  if (prefLocals.isEmpty) return const []; // Explicit locals-only tier
  return all.where((j) => _matchesPreferredLocals(j, prefLocals)).toList();
}
```

Relationships:

- _filterJobsExact and_filterJobsRelaxed enforce local matching when preferredLocals is present, as required.
- Level 3 explicitly filters by locals only.

7. Remove server-side 'deleted' filtering and unify recent jobs helper
Purpose: Avoid zero-result queries caused by missing or mis-typed deleted fields.

Actions:

- In suggestedJobs() and any _getRecentJobs():
  - Remove .where('deleted', isEqualTo: false).
  - Use the unified _fetchRecentJobsSlice that orders by timestamp and limits to 100.
  - Apply client-side filtering job.deleted != true.
Rationale: Documents without deleted field should not be excluded; this is critical to avoid empty result sets.

8. Optional: Keep a feature-flagged server-side whereIn cascade (Option B) for future selectivity
Purpose: If you want to experiment with more selective querying later (with schema/type fallbacks), add but disable by default.

- Add a flag:

```dart
const bool kUseServerLocalWhereIn = false; // keep false to prefer Option A
```

- If enabled, attempt in order until results > 0:
  a) whereIn on 'local' with int list
  b) 'local' with string list
  c) 'localNumber' with int list
  d) 'localNumber' with string list
- Always fall back to _fetchRecentJobsSlice when results are empty.
Note: whereIn has a 10-element limit and is fragile with mixed types; hence disabled by default.

9. Fix preference presence checks (hasPreferences) to be content-based
Purpose: Prevent UI gating or provider branching on incorrect referential equality checks that can hide jobs.

File: lib/providers/riverpod/user_preferences_riverpod_provider.dart

- Replace the current hasPreferences getter with:

```dart
extension UserJobPreferencesX on UserJobPreferences {
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

Relationship: The Home screen should reference prefsState.hasPreferences rather than comparing to an empty sentinel instance.
10. Update Home screen to use hasPreferences and ensure fallback display
Purpose: Ensure "Suggested Jobs" always renders jobs from the provider and only shows the "No Perfect Matches Yet" card when the entire jobs collection is empty.

File: lib/screens/home/home_screen.dart

- Replace any comparisons like prefs == UserJobPreferences.empty() or prefs.identical(...) with prefsState.hasPreferences.
- Consume suggestedJobsProvider (or equivalent) and render up to 5 items using the returned list, which is guaranteed to be non-empty when the jobs collection has data.
- If there is logic that shows an empty-state card when hasPreferences is true but results are empty, remove it—provider will now return fallback recent jobs when no matching jobs exist.
- UI nit: If any color opacity changes are needed, replace .withOpacity(x) with .withValues(alpha: x) to avoid deprecation warnings.

Example:

```dart
final suggested = ref.watch(suggestedJobsProvider);
// in builder:
if (suggested.hasValue) {
  final items = suggested.value!.take(5).toList();
  // Render CondensedJobCard for items; no empty state here unless items.isEmpty AND a separate provider confirms jobs collection truly empty
}
```

Relationship: With the provider cascade fix, the UI should not need to handle preference-based emptiness; it just displays what it receives.
11. Add concise, level-tagged debug logs
Purpose: Aid future debugging of cascade behavior without noisy logs.

Implementation:

```dart
void _logCascade(String stage, int returnedCount, int total) {
  assert(() {
    debugPrint('[SuggestedJobs] $stage -> $returnedCount (of $total)');
    return true;
  }());
}
```

- Wrap in assert to ensure logs only run in debug/profile.
- Log at each level and final result, including counts and cascade stage used.
Relationship: Provides quick visibility into which level(s) supplied the results and how many were found.

12. Manual validation across critical scenarios
Purpose: Confirm acceptance criteria and prevent regressions.

Scenarios:

1) No user document: Suggested Jobs shows recent jobs (Level 4).
2) User doc exists but no jobPreferences: Suggested Jobs shows recent jobs (Level 4).
3) Preferences present; job documents have local as string or under localNumber: Matches appear via client-side locals filter (Levels 1–3).
4) Preferences overly strict (no matches): Recent jobs still appear (Level 4).

Validation steps:

- Seed Firestore with:
  - Docs with and without 'deleted' field
  - local as "123" and 123; also localNumber variants
  - Mixed constructionTypes
  - Proper timestamps
- Observe debug logs to confirm cascade levels and counts.
- Confirm Home shows up to 5 items and never empty when jobs exist.

13. Unit tests for suggestedJobs() (optional but recommended)
Purpose: Guard against future regressions in cascade logic and schema normalization.

Setup:

- test/providers/jobs_riverpod_provider_test.dart
- Use fake/mock FirebaseFirestore (e.g., fake_cloud_firestore) with sample docs that cover:
  - Missing 'deleted' field
  - local as int/string and localNumber
  - Mixed timestamps and fields

Tests:

- test_no_user_doc_shows_recent_level4()
- test_user_without_prefs_shows_recent_level4()
- test_prefs_with_mixed_local_schemas_return_matches_levels1to3()
- test_overly_strict_prefs_still_returns_recent_level4()
- Assert ordering by timestamp desc and cap to 20.
- Assert logs (optional by injecting a logger callback).

14. Performance and safety checks
Purpose: Ensure the new approach is efficient and stable.

- Query caps to limit(100) prevent large reads on Home.
- All filters are client-side on a small slice; sorting is implicit via Firestore order.
- Avoid duplication with a seen set when accumulating tiers.
- Degrade gracefully when some fields are missing by using tolerant parsers.
- No breaking changes for other providers: scope changes to suggestedJobs() and recent slice helper; do not alter shared queries used elsewhere.

15. Code review, documentation, and rollout
Purpose: Ensure maintainability and clear rationale.

- Add inline comments documenting:
  - Why server-side 'deleted' filter was removed.
  - Why Option A is preferred over whereIn queries.
  - The definition and purpose of each cascade level.
  - The normalization in Job.fromJson and how it relates to preferredLocals checks.
- Update README or a short ADR describing the new cascade and fallback behavior.
- Request review focusing on:
  - Stability of sort and accumulation order
  - Correctness of locals matching across schemas
  - UI behavior on Home: non-empty display with up to 5 items
- Roll out and monitor logs in debug builds during QA.

---

## TASKS

[ ] Confirm understanding of the task and scope
[ ] Baseline analysis and code audit
[ ] Normalize Job model parsing to be schema-agnostic for local and deleted
[ ] Refactor suggestedJobs() to a single resilient recent slice (Option A, preferred)
[ ] Implement cascade with accumulation across levels (L1→L4) preserving stable order
[ ] Strengthen helper filters and include preferred locals in exact/relaxed/minimal tiers
[ ] Remove server-side 'deleted' filtering and unify recent jobs helper
[ ] Optional: Keep a feature-flagged server-side whereIn cascade (Option B) for future selectivity
[ ] Fix preference presence checks (hasPreferences) to be content-based
[ ] Update Home screen to use hasPreferences and ensure fallback display
[ ] Add concise, level-tagged debug logs
[ ] Manual validation across critical scenarios
[ ] Unit tests for suggestedJobs() (optional but recommended)
[ ] Performance and safety checks
[ ] Code review, documentation, and rollout

---

You said: Analyze lib/screens/home/home_screen.dart and all related code that drives “Suggested Jobs,” find why nothing is shown despite cascading logic (exact → partial → minimal → fallback), and fix it so jobs are always displayed with matches prioritized first.

Plan:

1) Confirm understanding and scope
•  Restate the issue and goal: ensure “Suggested Jobs” always shows jobs, prioritizing exact matches, then partial, then fallback, regardless of strict or missing fields.

2) Baseline analysis and audit
•  Review these files and flows:
◦  lib/screens/home/home_screen.dart
◦  lib/providers/riverpod/jobs_riverpod_provider.dart (suggestedJobs,_getRecentJobs, filters)
◦  lib/providers/riverpod/user_preferences_riverpod_provider.dart (hasPreferences and loading)
◦  lib/models/job_model.dart (Job.fromJson parsing)
•  Identify fragile Firestore filters (.where('deleted', isEqualTo: false) and whereIn on locals), missing local filtering in helpers, and UI empty-state gates.

3) Normalize Job model parsing (schema-agnostic)
•  Purpose: robust client-side filtering independent of Firestore schema variance.
•  In Job.fromJson:
◦  Parse local/localNumber as ints regardless of type or naming.
◦  Treat missing deleted as false.
◦  Parse timestamp from Timestamp/DateTime/string with fallback; keep order stable.
◦  Normalize constructionTypes (lowercase set).
◦  Parse hours/perDiem with safe helpers.
•  Relationship: Enables client-side locals matching and safe deleted filtering.

4) Refactor suggestedJobs to single resilient recent slice (Option A, preferred)
•  Purpose: avoid fragile server filters and type-mismatch on locals.
•  Replace current server filters with one query:
◦  orderBy('timestamp', descending: true).limit(100)
◦  Remove .where('deleted', isEqualTo: false); filter deleted client-side (job.deleted != true).
◦  Preserve Firestore order by not re-sorting.
•  This guarantees something to show whenever jobs exist.

5) Implement accumulating cascade (L1→L4) with stable order
•  Purpose: prioritize matches, then partial, then locals-only, then fallback, filling up to N without duplicates.
•  Accumulate across tiers in original timestamp-desc order; cap to 20 for provider (UI takes 5).
•  Log counts per tier and final result.

6) Strengthen helper filters and include preferred locals in tiers
•  Purpose: make tiers independent of server filtering.
•  Implement:
◦  _matchesPreferredLocals(Job, List<int>)
◦_matchesConstructionTypes(Job, Set<String>)
◦  _matchesHours(Job, UserJobPreferences)
◦_matchesPerDiem(Job, UserJobPreferences)
•  Update:
◦  _filterJobsExact: locals + types + hours + per diem
◦_filterJobsRelaxed: locals + types (hours/per diem ignored)
◦  _filterJobsByLocals: locals only

7) Remove server-side deleted filters and unify recent jobs helper
•  Purpose: prevent zero results due to missing deleted field.
•  Remove .where('deleted', isEqualTo: false) from suggestedJobs and any _getRecentJobs.
•  Use unified_fetchRecentJobsSlice; filter deleted client-side.

8) Optional: feature-flag a server-side whereIn fallback (Option B)
•  Add kUseServerLocalWhereIn = false by default.
•  If ever enabled, try local/localNumber with ints and strings, respecting 10-value whereIn limit; fall back to Option A if empty.

9) Fix preference presence checks (content-based)
•  Purpose: avoid referential equality traps that hide UI/actions.
•  Implement hasPreferences as a semantic check (any list non-empty or any optional field set).
•  Use this in providers/UI instead of comparing to UserJobPreferences.empty().

10) Update Home screen consumption
•  Purpose: ensure UI always displays provider output.
•  Use prefsState.hasPreferences instead of equality comparisons.
•  Rely on suggestedJobsProvider’s guaranteed non-empty output (when jobs exist).
•  Only show empty-state if provider returns empty and a separate check confirms jobs collection truly empty.
•  Replace any .withOpacity() with .withValues(alpha: ...) where needed.

11) Add concise, level-tagged debug logs
•  Purpose: quick insight into cascade behavior.
•  _logCascade('L1 exact', count, total), etc., guarded by assert.

12) Manual validation scenarios
•  No user doc → Level 4 recent jobs.
•  User doc with no prefs → Level 4 recent jobs.
•  Mixed schema locals (string/int, local/localNumber) → Levels 1–3 produce matches.
•  Overly strict prefs → Level 4 recent jobs.
•  Confirm Home shows up to 5 items and never empty when jobs exist.

13) Unit tests (optional but recommended)
•  Using fake_cloud_firestore:
◦  No user doc → Level 4
◦  No prefs → Level 4
◦  Mixed local schemas → Levels 1–3
◦  Overly strict → Level 4
◦  Assert stable ordering and 20-cap; optional log assertions.

14) Performance and safety checks
•  Query limit(100) only; client filters on small slice.
•  No duplication via seen set.
•  Tolerant parsing avoids crashes on missing fields.
•  Scope changes to suggestedJobs and helper; no regressions to other providers.

15) Code review, docs, rollout
•  Document why server deleted filter was removed and why Option A is preferred.
•  Explain cascade tiers and parsing normalization.
•  Ensure reviewers verify ordering, locals matching, and UI behavior.
•  Monitor debug logs in QA.

Summary:
Harden suggestedJobs to fetch a single recent slice (no server-side deleted or locals filters), implement an accumulating multi-tier cascade with robust client-side matching (including locals), fix preference checks, update Home to rely on the provider’s non-empty results, and validate with targeted scenarios and tests.
