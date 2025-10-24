# Firestore Index Creation Guide

## Missing Composite Index

The app requires a composite index for the jobs query that filters by preferred locals. Follow these steps to create it:

### Option 1: Auto-Create via Console Link (Recommended)

When you run the app and encounter the FAILED_PRECONDITION error, Firebase provides a direct link to create the index. Look for this error in your logs:

```
W/Firestore: Listen for Query failed: Status{code=FAILED_PRECONDITION,
description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=...
```

**Click the URL** to automatically create the required index.

### Option 2: Manual Creation via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/project/journeyman-jobs/firestore/indexes)
2. Click "Create Index"
3. Select collection: `jobs`
4. Add the following fields in order:

| Field | Index Type | Order |
|-------|-----------|-------|
| deleted | Ascending | - |
| local | Ascending | - |
| timestamp | Descending | - |
| __name__ | Descending | - |

5. Set Query Scope: **Collection**
6. Click "Create Index"

### Index Build Time

- Small datasets (<1000 docs): ~1-2 minutes
- Medium datasets (1000-10000 docs): ~5-10 minutes
- Large datasets (>10000 docs): ~30+ minutes

## Verification

After creating the index:

1. Wait for index build to complete (check Firebase Console)
2. Restart your Flutter app
3. Navigate to the home screen (suggested jobs)
4. Verify that jobs load without errors

## Current Index Configuration

The index has been added to `firebase/firestore.indexes.json` for future deployments.

To deploy all indexes:

```bash
cd firebase
firebase deploy --only firestore:indexes
```

**Note**: This may fail if indexes already exist. In that case, use the `--force` flag to remove orphaned indexes:

```bash
firebase deploy --only firestore:indexes --force
```

## Troubleshooting

### Error: "index already exists"

This means the index is already being built or exists. Check the Firebase Console indexes page to verify status.

### Error: "PERMISSION_DENIED"

This has been fixed by updating Firestore security rules to allow notifications collection access.

### Provider Disposed Error

This has been fixed by adding `ref.mounted` checks after async operations in the jobs provider.
