# QUICK SETUP - Firestore Composite Index for Suggested Jobs

## What You Need to Do RIGHT NOW

### 1. Open Firebase Console

**URL**: <https://console.firebase.google.com/>

### 2. Navigate to Indexes

1. Select **Journeyman Jobs** project
2. Click **Firestore Database** in left sidebar
3. Click **Indexes** tab

### 3. Create Index - EXACT Configuration Required

Click **Create Index** button and enter:

**Collection ID**: `jobs`

**Add these 4 fields in this EXACT order**:

| Field Path | Index Mode |
|------------|------------|
| `local` | **Ascending** |
| `deleted` | **Ascending** |
| `timestamp` | **Descending** |
| `__name__` | **Descending** |

**Query Scope**: Collection

Click **Create**

### 4. Wait for Index to Build

- Status will show **"Building"** (yellow indicator)
- Wait 2-15 minutes depending on data size
- Refresh page to check status
- When status shows **"Enabled"** (green checkmark), you're done!

### 5. Test in App

Run your Flutter app:

```bash
flutter run
```

Navigate to home screen and verify:

- ✅ Loading indicator appears
- ✅ Suggested jobs display (up to 5 cards)
- ✅ No error messages
- ✅ Console shows successful query logs

---

## If You See the Error Message in Console

Look for a Firebase Console URL in the error message like:

```
https://console.firebase.google.com/project/...
```

Click that URL - it will pre-fill the index configuration for you!

---

## Expected Console Output (Success)

```
🔍 DEBUG: Loading suggested jobs for user [uid]
📋 User preferences:
  - Preferred locals: [84, 111, 222]
  - Construction types: [...]
🔄 Querying jobs where local in: [84, 111, 222]
📊 Server query returned 10 jobs
✅ Level 1: Found 5 exact matches
```

---

## Quick Verification Checklist

After creating the index:

- [ ] Firebase Console shows index status = **"Enabled"**
- [ ] Home screen displays suggested jobs
- [ ] No "FAILED_PRECONDITION" errors in console
- [ ] Query completes in < 2 seconds

---

**See full guide**: `docs/firestore-index-creation-guide.md`
