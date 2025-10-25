# Firestore Composite Indexes Required

This document lists all composite indexes required for optimal query performance in the Journeyman Jobs app.

## Crew Messages - Feed Tab

### Index 1: Feed Messages by Timestamp (Descending)

```
Collection: crews/{crewId}/messages
Fields:
  - sentAt (Descending)
  - __name__ (Descending)
```

**CLI Command:**

```bash
firebase firestore:indexes:create \
  --collection-group messages \
  --field sentAt --order descending \
  --field __name__ --order descending
```

**Purpose:** Efficient pagination for crew feed messages (newest first)

**Query Pattern:**

```dart
crews.doc(crewId).collection('messages')
  .orderBy('sentAt', descending: true)
  .limit(50)
  .startAfterDocument(lastDoc)
```

---

## Crew Messages - Chat Tab

### Index 2: Chat Messages by Timestamp (Ascending)

```
Collection: crews/{crewId}/chat
Fields:
  - sentAt (Ascending)
  - __name__ (Ascending)
```

**CLI Command:**

```bash
firebase firestore:indexes:create \
  --collection-group chat \
  --field sentAt --order ascending \
  --field __name__ --order ascending
```

**Purpose:** Efficient pagination for crew chat messages (oldest first, like messaging apps)

**Query Pattern:**

```dart
crews.doc(crewId).collection('chat')
  .orderBy('sentAt', descending: false)
  .limit(50)
  .startAfterDocument(lastDoc)
```

---

## Locals Directory - State Filtering

### Index 3: Locals by State and Local Union Number

```
Collection: locals
Fields:
  - state (Ascending)
  - local_union (Ascending)
  - __name__ (Ascending)
```

**CLI Command:**

```bash
firebase firestore:indexes:create \
  --collection locals \
  --field state --order ascending \
  --field local_union --order ascending \
  --field __name__ --order ascending
```

**Purpose:** Filter locals by state with efficient pagination

**Query Pattern:**

```dart
localsCollection
  .where('state', isEqualTo: selectedState)
  .orderBy('local_union')
  .limit(20)
  .startAfterDocument(lastDoc)
```

---

## Locals Directory - Search Queries

### Index 4: Locals Search with State Filter

```
Collection: locals
Fields:
  - state (Ascending)
  - local_union (Ascending)
  - __name__ (Ascending)
```

**CLI Command:**

```bash
firebase firestore:indexes:create \
  --collection locals \
  --field state --order ascending \
  --field local_union --order ascending \
  --field __name__ --order ascending
```

**Purpose:** Search locals by name with state filtering

**Query Pattern:**

```dart
localsCollection
  .where('state', isEqualTo: selectedState)
  .where('local_union', isGreaterThanOrEqualTo: searchTerm)
  .where('local_union', isLessThanOrEqualTo: searchTerm + '\uf8ff')
  .limit(20)
```

---

## Jobs - Filtering and Sorting

### Index 5: Jobs by Local and Timestamp

```
Collection: jobs
Fields:
  - local (Ascending)
  - timestamp (Descending)
  - __name__ (Descending)
```

**CLI Command:**

```bash
firebase firestore:indexes:create \
  --collection jobs \
  --field local --order ascending \
  --field timestamp --order descending \
  --field __name__ --order descending
```

**Purpose:** Filter jobs by local union with timestamp ordering

**Query Pattern:**

```dart
jobsCollection
  .where('local', isEqualTo: localId)
  .orderBy('timestamp', descending: true)
  .limit(50)
```

---

### Index 6: Jobs by Classification and Timestamp

```
Collection: jobs
Fields:
  - classification (Ascending)
  - timestamp (Descending)
  - __name__ (Descending)
```

**CLI Command:**

```bash
firebase firestore:indexes:create \
  --collection jobs \
  --field classification --order ascending \
  --field timestamp --order descending \
  --field __name__ --order descending
```

**Purpose:** Filter jobs by classification type

---

## Deployment Commands

### Create All Indexes at Once

```bash
# Navigate to your Firebase project directory
cd path/to/your/project

# Create all indexes using Firebase CLI
firebase firestore:indexes:create --collection-group messages --field sentAt --order descending --field __name__ --order descending
firebase firestore:indexes:create --collection-group chat --field sentAt --order ascending --field __name__ --order ascending
firebase firestore:indexes:create --collection locals --field state --order ascending --field local_union --order ascending --field __name__ --order ascending
firebase firestore:indexes:create --collection jobs --field local --order ascending --field timestamp --order descending --field __name__ --order descending
firebase firestore:indexes:create --collection jobs --field classification --order ascending --field timestamp --order descending --field __name__ --order descending
```

---

## Performance Optimization Notes

### Query Optimization Best Practices

1. **Pagination Limits:**
   - Default page size: 20-50 documents
   - Maximum page size: 100 documents
   - Use DocumentSnapshot cursors for efficient pagination

2. **Offline Persistence:**
   - Firestore offline persistence is enabled by default
   - Cached data serves queries instantly
   - Real-time listeners work offline with local cache

3. **Composite Index Strategy:**
   - Create indexes before deploying queries to production
   - Monitor query performance in Firebase Console
   - Use `!=`, `in`, `not-in`, and `array-contains-any` sparingly (they don't scale well)

4. **Real-time Listener Optimization:**
   - Limit active listeners (max 100 concurrent per device recommended)
   - Unsubscribe from listeners when screens unmount
   - Use `StreamBuilder` in Flutter for automatic lifecycle management

5. **Security Rules Performance:**
   - Security rules can impact query performance
   - Avoid complex security rules on large collections
   - Index fields used in security rules

### Monitoring Query Performance

**Firebase Console:**

1. Go to Firestore > Usage tab
2. Monitor "Read Operations" and "Query Time"
3. Check "Index Usage" for missing indexes

**Flutter Debug Logs:**

```dart
// Enable Firestore debug logging
FirebaseFirestore.setLoggingEnabled(true);
```

---

## Index Creation Status Tracking

| Index | Collection | Status | Created Date | Notes |
|-------|------------|--------|--------------|-------|
| 1 | crews/{crewId}/messages | ⏳ Pending | - | Feed messages |
| 2 | crews/{crewId}/chat | ⏳ Pending | - | Chat messages |
| 3 | locals | ⏳ Pending | - | State filtering |
| 4 | locals | ⏳ Pending | - | Search queries |
| 5 | jobs | ⏳ Pending | - | Local filter |
| 6 | jobs | ⏳ Pending | - | Classification filter |

**Legend:**

- ⏳ Pending - Index needs to be created
- 🔄 Building - Index is being built by Firebase
- ✅ Active - Index is ready and serving queries
- ❌ Failed - Index creation failed

---

## Troubleshooting

### Index Build Failures

If an index fails to build:

1. Check Firebase Console for error messages
2. Verify field names match exactly (case-sensitive)
3. Ensure collection paths are correct
4. Check for existing duplicate indexes

### Query Performance Issues

If queries are slow despite indexes:

1. Verify index is in "Active" state (not "Building")
2. Check query uses exact fields in index
3. Monitor Firebase quota limits
4. Consider denormalizing data for read-heavy queries

### Missing Index Errors

Flutter will show errors like:

```
FAILED_PRECONDITION: The query requires an index
```

**Solution:**

1. Click the error link to auto-create index in Firebase Console
2. Or use CLI commands above to create manually
3. Wait 5-15 minutes for index to build
4. Re-run query
