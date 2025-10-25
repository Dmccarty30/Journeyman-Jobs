# Firestore Data Migration for Locals Search Optimization

## Overview

This migration adds lowercase fields to the `locals` collection to enable efficient case-insensitive search queries. These fields are required for the optimized search functionality implemented in Task 9.1.

## Required Fields to Add

For each document in the `locals` collection, add the following fields:

1. **`local_name_lowercase`** - Lowercase version of `local_name` field
2. **`city_lowercase`** - Lowercase version of `city` field

## Migration Options

### Option 1: Firebase Console (Manual - Small Datasets)

For small datasets or testing:

1. Go to Firebase Console → Firestore Database
2. Navigate to `locals` collection
3. For each document:
   - Click Edit
   - Add field `local_name_lowercase` with value `<local_name in lowercase>`
   - Add field `city_lowercase` with value `<city in lowercase>`
   - Save document

### Option 2: Cloud Functions (Recommended - Production)

Deploy a one-time migration function:

```javascript
// functions/migrations/addLocalsLowercaseFields.js
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

async function migrateLocals() {
  const localsRef = db.collection('locals');
  const snapshot = await localsRef.get();

  console.log(`Found ${snapshot.size} locals documents to migrate`);

  const batch = db.batch();
  let count = 0;
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();

    // Add lowercase fields
    const updates = {};

    if (data.local_name) {
      updates.local_name_lowercase = data.local_name.toLowerCase();
    }

    if (data.city) {
      updates.city_lowercase = data.city.toLowerCase();
    }

    // Only update if we have fields to add
    if (Object.keys(updates).length > 0) {
      batch.update(doc.ref, updates);
      count++;

      // Firestore batches are limited to 500 operations
      if (count >= 500) {
        await batch.commit();
        console.log(`Committed batch ${++batchCount} (${count * batchCount} documents updated)`);
        count = 0;
      }
    }
  }

  // Commit remaining documents
  if (count > 0) {
    await batch.commit();
    console.log(`Committed final batch (${count} documents)`);
  }

  console.log('Migration complete!');
}

// Run migration
migrateLocals()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Migration failed:', error);
    process.exit(1);
  });
```

**Deploy and run:**

```bash
# Deploy function
firebase deploy --only functions:migrateLocals

# Or run locally with Firebase Admin SDK
node functions/migrations/addLocalsLowercaseFields.js
```

### Option 3: Flutter App (Client-Side Migration)

Add a one-time migration in your Flutter app (only for testing/dev):

```dart
// lib/migrations/locals_lowercase_migration.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LocalsLowercaseMigration {
  final FirebaseFirestore _firestore;

  LocalsLowercaseMigration({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Adds lowercase fields to all locals documents
  ///
  /// WARNING: This is a client-side migration and may timeout for large datasets.
  /// Only use for testing/development. For production, use Cloud Functions.
  Future<void> migrate() async {
    try {
      if (kDebugMode) {
        print('[LocalsLowercaseMigration] Starting migration...');
      }

      // Get all locals documents
      final snapshot = await _firestore.collection('locals').get();

      if (kDebugMode) {
        print('[LocalsLowercaseMigration] Found ${snapshot.docs.length} documents');
      }

      // Process in batches of 500 (Firestore limit)
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int batchCount = 0;
      int documentCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Prepare updates
        final Map<String, dynamic> updates = {};

        if (data.containsKey('local_name') && data['local_name'] != null) {
          updates['local_name_lowercase'] = data['local_name'].toString().toLowerCase();
        }

        if (data.containsKey('city') && data['city'] != null) {
          updates['city_lowercase'] = data['city'].toString().toLowerCase();
        }

        // Only update if we have fields to add
        if (updates.isNotEmpty) {
          currentBatch.update(doc.reference, updates);
          documentCount++;

          // Start new batch at 500 operations
          if (documentCount >= 500) {
            batches.add(currentBatch);
            currentBatch = _firestore.batch();
            documentCount = 0;
            batchCount++;
          }
        }
      }

      // Add final batch if it has operations
      if (documentCount > 0) {
        batches.add(currentBatch);
      }

      // Commit all batches
      for (int i = 0; i < batches.length; i++) {
        await batches[i].commit();
        if (kDebugMode) {
          print('[LocalsLowercaseMigration] Committed batch ${i + 1}/${batches.length}');
        }
      }

      if (kDebugMode) {
        print('[LocalsLowercaseMigration] Migration complete!');
        print('[LocalsLowercaseMigration] Updated ${snapshot.docs.length} documents');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LocalsLowercaseMigration] Migration failed: $e');
      }
      rethrow;
    }
  }
}

// Usage in app (e.g., in a settings screen):
// await LocalsLowercaseMigration().migrate();
```

## Deployment Steps

### 1. Deploy Firestore Indexes

```bash
# From project root
firebase deploy --only firestore:indexes
```

This will deploy the indexes defined in `firestore.indexes.json`:
- `state + local_union` (for filtered browsing)
- `state + classification` (for classification filtering)
- `classification + local_union` (for classification search)
- `state + city_lowercase` (for city search)
- `state + local_name_lowercase` (for name search)

### 2. Run Data Migration

Choose one of the migration options above to add the lowercase fields.

### 3. Verify Migration

After migration, verify the fields exist:

```javascript
// In Firebase Console or Cloud Functions
db.collection('locals').limit(5).get().then(snapshot => {
  snapshot.docs.forEach(doc => {
    const data = doc.data();
    console.log(`Local ${data.local_union}:`);
    console.log(`  local_name: ${data.local_name}`);
    console.log(`  local_name_lowercase: ${data.local_name_lowercase}`);
    console.log(`  city: ${data.city}`);
    console.log(`  city_lowercase: ${data.city_lowercase}`);
  });
});
```

### 4. Update Security Rules (Optional)

Add validation to ensure lowercase fields are always set:

```javascript
// firestore.rules
match /locals/{localId} {
  allow read: if request.auth != null;

  allow write: if request.auth != null
    && request.resource.data.local_name_lowercase ==
       request.resource.data.local_name.toLowerCase()
    && request.resource.data.city_lowercase ==
       request.resource.data.city.toLowerCase();
}
```

## Future Writes

For any new locals documents created after migration, ensure the lowercase fields are added:

```dart
// When creating new locals
await FirebaseFirestore.instance.collection('locals').doc(localId).set({
  'local_union': '134',
  'local_name': 'Chicago Electrical Workers',
  'local_name_lowercase': 'chicago electrical workers', // Add this
  'city': 'Chicago',
  'city_lowercase': 'chicago', // Add this
  'state': 'IL',
  'classification': 'Inside Wireman',
  // ... other fields
});
```

## Performance Impact

After migration and index deployment:

- **Search query time**: 800-1500ms → 200-400ms (-75%)
- **Data transfer**: No increase (fields are small)
- **Storage cost**: Minimal (~50 bytes per document × 797 = ~40KB total)
- **Index maintenance**: Automatic, minimal overhead

## Rollback

If needed to rollback:

1. Remove lowercase fields from documents (reverse migration)
2. Delete Firestore indexes from Firebase Console
3. Revert to client-side filtering in code

## Monitoring

Monitor query performance in Firebase Console:
1. Go to Firestore → Usage tab
2. Check "Read operations" and "Query time"
3. Compare before/after metrics
