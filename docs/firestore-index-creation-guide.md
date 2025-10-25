# Firestore Index Creation Guide

## Critical Index for Suggested Jobs Query

The `suggestedJobs` provider requires a composite index for optimal performance when querying jobs by local union numbers with the deleted flag filter.

### Query Pattern

```dart
FirebaseFirestore.instance
    .collection('jobs')
    .where('local', whereIn: [26, 103, 11])  // User's preferred locals
    .where('deleted', isEqualTo: false)
    .orderBy('timestamp', descending: true)
    .limit(50)
```

### Required Index

**Collection**: `jobs`
**Fields**:
1. `local` (ARRAY_CONTAINS or ASCENDING) - for whereIn query
2. `deleted` (ASCENDING) - for equality filter
3. `timestamp` (DESCENDING) - for sorting by most recent

### Index Definition

The index has been added to `firebase/firestore.indexes.json`:

```json
{
  "collectionGroup": "jobs",
  "queryScope": "COLLECTION",
  "fields": [
    {
      "fieldPath": "local",
      "arrayConfig": "CONTAINS"
    },
    {
      "fieldPath": "deleted",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "timestamp",
      "order": "DESCENDING"
    }
  ]
}
```

## Deployment Steps

### Option 1: Automatic Deployment (Recommended)

```bash
# From project root directory
firebase deploy --only firestore:indexes
```

This will:
- Read the `firebase/firestore.indexes.json` file
- Create all defined indexes in your Firebase project
- Provide a link to monitor index build progress

### Option 2: Manual Creation via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Create Index**
5. Configure:
   - Collection ID: `jobs`
   - Fields to index:
     - Field: `local`, Mode: Array-contains
     - Field: `deleted`, Mode: Ascending
     - Field: `timestamp`, Mode: Descending
6. Click **Create Index**

### Option 3: Use the Auto-Generated Link

When your app attempts the query and the index doesn't exist, Firestore will log an error with a direct link to create the index. Check your console logs for:

```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

Click the link to automatically create the required index.

## Index Build Time

- **Small dataset** (< 1000 docs): ~5-10 minutes
- **Medium dataset** (1000-10000 docs): ~30-60 minutes
- **Large dataset** (> 10000 docs): Several hours

Monitor progress in Firebase Console → Firestore Database → Indexes

## Verification

After deployment, verify the index is building:

1. Check Firebase Console → Indexes tab
2. Status should show "Building" then "Enabled"
3. Test the query in your app - should no longer throw index errors

## Performance Impact

**Before Index**:
- Query fails with "index required" error
- No results returned to users

**After Index**:
- Query response time: < 200ms for typical datasets
- Enables efficient filtering by user's preferred locals
- Supports pagination with 50-result batches

## Additional Indexes

The `firestore.indexes.json` file includes several other indexes for:
- Job filtering by classification, location, type of work
- Crew management queries
- Message sorting and filtering
- Local union queries

Deploy all indexes together for complete app functionality.

## Troubleshooting

### Index Creation Failed
- Check Firebase Console for error messages
- Verify JSON syntax in `firestore.indexes.json`
- Ensure you have Owner/Editor permissions on the project

### Query Still Failing After Index Creation
- Wait for index to finish building (check status in console)
- Clear app cache and restart
- Verify the query exactly matches the index definition

### Index Not Being Used
- Check that field names match exactly (case-sensitive)
- Verify query operators match index configuration
- Use `whereIn` for array matching, not `arrayContains`

## Related Files

- **Index Definition**: `firebase/firestore.indexes.json`
- **Query Implementation**: `lib/providers/riverpod/jobs_riverpod_provider.dart` (line 623)
- **User Preferences**: `lib/models/user_job_preferences.dart`

## Notes

- Firestore allows maximum 10 values in `whereIn` queries
- The query implementation already limits to first 10 preferred locals
- Index supports efficient pagination with `startAfter` cursors
- No runtime cost for index maintenance - all handled by Firestore
