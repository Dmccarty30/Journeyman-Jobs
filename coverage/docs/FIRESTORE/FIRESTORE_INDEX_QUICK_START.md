# Firestore Index Quick Start Guide

**Last Updated**: January 25, 2025

---

## 🚀 Quick Deploy (30 seconds)

### Deploy Index Now

```bash
# 1. Navigate to project
cd D:\Journeyman-Jobs

# 2. Deploy indexes
firebase deploy --only firestore:indexes

# 3. Wait 2-10 minutes for build to complete
# Check status: https://console.firebase.google.com → Firestore → Indexes
```

**That's it!** The index configuration already exists in `firebase/firestore.indexes.json`.

---

## ✅ Verify Deployment

### Check Index Status

```bash
firebase firestore:indexes
```

**Look for**:
```
jobs (Collection)
  - deleted (ASCENDING)
  - local (ASCENDING)
  - timestamp (DESCENDING)
  - __name__ (DESCENDING)
Status: Enabled ✅
```

### Firebase Console Check

1. Open: https://console.firebase.google.com
2. Select project: "Journeyman Jobs"
3. Navigate: Firestore Database → Indexes → Composite
4. Find: jobs index with 4 fields
5. Verify: Status shows "Enabled" (green checkmark)

---

## 🧪 Test in App

### Run Quick Test

1. **Start app** in debug mode
   ```bash
   flutter run
   ```

2. **Navigate** to Home screen

3. **Check** debug console for:
   ```
   ✅ Loaded X suggested jobs
   ```

4. **Verify** "Suggested Jobs" section displays

### Expected Behavior

✅ Jobs load within 200ms
✅ 5 jobs displayed on home screen
✅ Loading state shows electrical theme
✅ No "index required" errors in console

---

## 🔧 Troubleshooting

### Error: "The query requires an index"

**Solution 1: Deploy Index**
```bash
firebase deploy --only firestore:indexes
```

**Solution 2: Use Auto-Generated Link**
1. Copy link from error message
2. Click link (opens Firebase Console)
3. Click "Create Index" button

**Solution 3: Wait for Build**
- Index may still be building (2-10 min)
- Check Firebase Console → Indexes for status

### No Jobs Displayed

**Check 1: User Preferences**
- Ensure user has set preferred locals
- Settings → Job Preferences

**Check 2: Firebase Console**
- Verify jobs exist in Firestore
- Check `deleted` field is `false`

**Check 3: Authentication**
- Ensure user is logged in
- Check debug console for auth errors

---

## 📊 Performance Monitoring

### Check Query Performance

**Add to code** (temporary):
```dart
final stopwatch = Stopwatch()..start();
final jobs = await ref.read(suggestedJobsProvider.future);
stopwatch.stop();

print('Query time: ${stopwatch.elapsedMilliseconds}ms');
print('Jobs found: ${jobs.length}');
```

**Target**:
- WiFi: <100ms ✅
- 4G: <150ms ✅
- 3G: <200ms ✅

### Firebase Console Metrics

1. Navigate: Firestore → Usage
2. Monitor: Document Reads graph
3. Check: Steady reads with high cache hit rate

---

## 📖 Full Documentation

For detailed troubleshooting and optimization:
- **Comprehensive Guide**: `docs/firestore-index-creation-guide.md`
- **Validation Report**: `docs/TASK_4.2_VALIDATION_REPORT.md`
- **Summary**: `docs/TASK_4.2_SUMMARY.md`

---

## ⚡ Quick Reference

### Index Location
`firebase/firestore.indexes.json` (lines 165-186)

### Query Location
`lib/providers/riverpod/jobs_riverpod_provider.dart` (lines 777-783)

### UI Location
`lib/screens/home/home_screen.dart` (lines 408-623)

### Deploy Command
```bash
firebase deploy --only firestore:indexes
```

### Verify Command
```bash
firebase firestore:indexes
```

---

**Need Help?** See full documentation in `docs/firestore-index-creation-guide.md`
