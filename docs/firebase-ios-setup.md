# Firebase iOS Configuration Guide for Journeyman Jobs

## 🎯 Overview

This guide provides step-by-step instructions to configure Firebase for iOS in the Journeyman Jobs Flutter application. The Android configuration is already complete; this guide focuses exclusively on adding the missing iOS configuration.

**Current Status:**
- ✅ Android Firebase: Configured (`android/app/google-services.json`)
- ❌ iOS Firebase: **MISSING** (`ios/Runner/GoogleService-Info.plist`)
- 🚫 Blocker: App cannot run on iOS until this configuration is complete

---

## 📋 Prerequisites

Before starting, ensure you have:

1. **Firebase Console Access**
   - Access to the Firebase project: `journeyman-jobs`
   - Project ID: `journeyman-jobs`
   - Project Number: `1037879032120`

2. **Development Environment**
   - Flutter SDK installed
   - Xcode installed (latest stable version recommended)
   - FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
   - Firebase CLI installed: `npm install -g firebase-tools`

3. **Project Information**
   - iOS Bundle ID: `com.mccarty.journeymanjobs.journeymanJobs`
   - Note: This is different from the Android package name (`com.mccarty.journeymanjobs`)

---

## 🔥 Step 1: Download GoogleService-Info.plist

### Option A: Using Firebase Console (Recommended for First-Time Setup)

1. **Navigate to Firebase Console**
   ```
   https://console.firebase.google.com/project/journeyman-jobs
   ```

2. **Access Project Settings**
   - Click the gear icon ⚙️ next to "Project Overview"
   - Select "Project settings"

3. **Add or Select iOS App**
   - Scroll to "Your apps" section
   - If iOS app exists with bundle ID `com.mccarty.journeymanjobs.journeymanJobs`:
     - Click on the iOS app
     - Click "Download GoogleService-Info.plist"
   - If iOS app doesn't exist:
     - Click "Add app" button
     - Select iOS platform (Apple icon)
     - Enter Bundle ID: `com.mccarty.journeymanjobs.journeymanJobs`
     - (Optional) Enter App nickname: "Journeyman Jobs iOS"
     - Click "Register app"
     - Download `GoogleService-Info.plist` when prompted

4. **Save the File**
   - Save the downloaded `GoogleService-Info.plist` to a temporary location
   - **IMPORTANT**: Do not rename this file

### Option B: Using FlutterFire CLI (Automated)

```bash
# Navigate to project root
cd /mnt/d/worktrees/tailboard-modernization

# Login to Firebase
firebase login

# Run FlutterFire configure
flutterfire configure --project=journeyman-jobs
```

**Follow the prompts:**
- Select existing platforms (iOS, Android)
- Confirm bundle IDs
- The CLI will automatically download and place configuration files

---

## 📁 Step 2: Place GoogleService-Info.plist in iOS Directory

### Manual Placement

1. **Copy the file to the correct location:**
   ```bash
   cp /path/to/downloaded/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
   ```

2. **Verify file location:**
   ```bash
   ls -la ios/Runner/GoogleService-Info.plist
   ```

   **Expected output:**
   ```
   -rw-r--r-- 1 user user 1234 Nov 19 08:00 ios/Runner/GoogleService-Info.plist
   ```

---

## 🛠️ Step 3: Add to Xcode Project

**CRITICAL**: The file must be added to Xcode, not just copied to the directory.

### Using Xcode GUI

1. **Open Xcode Project**
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **Important**: Open `.xcworkspace`, NOT `.xcodeproj`

2. **Add GoogleService-Info.plist to Xcode**
   - In Xcode's Project Navigator (left sidebar), right-click on the `Runner` folder
   - Select "Add Files to 'Runner'..."
   - Navigate to `ios/Runner/` directory
   - Select `GoogleService-Info.plist`
   - **CRITICAL SETTINGS** in the dialog:
     - ✅ Check "Copy items if needed" (should already be in place, so may be grayed out)
     - ✅ Ensure "Create groups" is selected
     - ✅ Under "Add to targets", ensure "Runner" is checked
   - Click "Add"

3. **Verify in Xcode**
   - `GoogleService-Info.plist` should appear in the Runner folder in Project Navigator
   - Click on the file to verify it opens and shows Firebase configuration

### Using Command Line (Alternative)

```bash
# Navigate to iOS directory
cd ios

# Open Xcode workspace
open Runner.xcworkspace

# Manually add the file using Xcode's GUI (see steps above)
```

---

## ✅ Step 4: Verify Configuration

### Verify File Contents

```bash
# View the plist file
cat ios/Runner/GoogleService-Info.plist
```

**Expected content structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>BUNDLE_ID</key>
    <string>com.mccarty.journeymanjobs.journeymanJobs</string>
    <key>PROJECT_ID</key>
    <string>journeyman-jobs</string>
    <key>STORAGE_BUCKET</key>
    <string>journeyman-jobs.firebasestorage.app</string>
    <!-- ... more Firebase configuration keys ... -->
</dict>
</plist>
```

### Verify Bundle ID Match

```bash
# Check Info.plist for bundle identifier
grep -A1 "CFBundleIdentifier" ios/Runner/Info.plist
```

**Expected output:**
```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

**Then check project.pbxproj:**
```bash
grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -n 1
```

**Expected output:**
```
PRODUCT_BUNDLE_IDENTIFIER = com.mccarty.journeymanjobs.journeymanJobs;
```

### Verify Xcode Integration

1. Open Xcode: `open ios/Runner.xcworkspace`
2. In Project Navigator, confirm `GoogleService-Info.plist` is visible under `Runner`
3. Click on `GoogleService-Info.plist` and verify:
   - File appears in "Target Membership" on the right (Runner should be checked)
   - File shows Firebase configuration when opened

---

## 🚀 Step 5: Test the Configuration

### Clean and Rebuild

```bash
# Clean Flutter build cache
flutter clean

# Get dependencies
flutter pub get

# Clean iOS build
cd ios
pod deintegrate
pod install
cd ..

# Run on iOS simulator
flutter run -d ios
```

### Expected Results

- ✅ App builds without Firebase configuration errors
- ✅ No warnings about missing `GoogleService-Info.plist`
- ✅ Firebase services initialize successfully (check logs)

### Check Firebase Initialization Logs

When running the app, look for logs similar to:
```
[Firebase/Core][I-COR000003] The default Firebase app has not yet been configured
[Firebase/Core][I-COR000005] Firebase SDK initialized successfully
```

---

## 🔒 Security & Git Configuration

### ⚠️ CRITICAL: Git Ignore Settings

**DO NOT commit `GoogleService-Info.plist` to version control** unless it's a public/demo Firebase project.

### Verify .gitignore

Check that your `.gitignore` includes:

```bash
# Verify gitignore
grep -n "GoogleService-Info.plist" .gitignore
```

If not present, add it:

```bash
echo "" >> .gitignore
echo "# Firebase iOS configuration (contains sensitive keys)" >> .gitignore
echo "ios/Runner/GoogleService-Info.plist" >> .gitignore
```

### Check Git Status

```bash
# Ensure file is ignored
git status

# GoogleService-Info.plist should NOT appear in untracked files
```

### For Team Collaboration

**Option 1: Use FlutterFire CLI**
- Each developer runs `flutterfire configure` on their machine
- Configuration files generated automatically

**Option 2: Secure Sharing**
- Store in secure credential management (e.g., 1Password, LastPass)
- Share via encrypted channels only
- Document the process in team wiki

**Option 3: CI/CD Secrets**
- Store as base64-encoded secret in CI/CD pipeline
- Decode during build process
- Example for GitHub Actions:
  ```yaml
  - name: Decode Firebase config
    run: echo "${{ secrets.FIREBASE_IOS_CONFIG }}" | base64 -d > ios/Runner/GoogleService-Info.plist
  ```

---

## 🐛 Troubleshooting

### Issue 1: "GoogleService-Info.plist not found" Error

**Symptoms:**
```
Error: GoogleService-Info.plist file not found
```

**Solutions:**
1. Verify file location: `ls ios/Runner/GoogleService-Info.plist`
2. Ensure file is added to Xcode project (see Step 3)
3. Check file name is exact (case-sensitive)
4. Run `flutter clean` and rebuild

### Issue 2: Bundle ID Mismatch

**Symptoms:**
```
Error: The BUNDLE_ID in GoogleService-Info.plist doesn't match your app's bundle identifier
```

**Solutions:**
1. Check bundle ID in `GoogleService-Info.plist`:
   ```bash
   grep -A1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist
   ```
2. Compare with Xcode project settings:
   - Open `ios/Runner.xcworkspace`
   - Select Runner project → Runner target → General tab
   - Verify "Bundle Identifier" is `com.mccarty.journeymanjobs.journeymanJobs`
3. If mismatch, download correct config file from Firebase Console for the correct bundle ID

### Issue 3: App Crashes on Launch

**Symptoms:**
```
App crashes immediately on iOS simulator/device
Console shows Firebase initialization errors
```

**Solutions:**
1. Check Xcode console for specific error messages
2. Verify `GoogleService-Info.plist` is in Target Membership:
   - Open file in Xcode
   - Check right sidebar → Target Membership → Runner (should be checked)
3. Verify Firebase packages in `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^latest_version
     # other firebase packages...
   ```
4. Ensure Firebase initialization in `main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }
   ```

### Issue 4: File Not Visible in Xcode

**Symptoms:**
- File exists in `ios/Runner/` directory
- File doesn't appear in Xcode Project Navigator

**Solutions:**
1. Close Xcode completely
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Reopen Xcode workspace: `open ios/Runner.xcworkspace`
4. Manually add file again (Step 3)

### Issue 5: CocoaPods Integration Issues

**Symptoms:**
```
Error: Firebase/Core module not found
```

**Solutions:**
```bash
cd ios

# Remove Pods
rm -rf Pods
rm Podfile.lock

# Reinstall
pod install --repo-update

cd ..
flutter clean
flutter pub get
```

---

## 📚 Additional Resources

### Firebase Documentation
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

### Project-Specific Information
- Firebase Project ID: `journeyman-jobs`
- Firebase Project Number: `1037879032120`
- iOS Bundle ID: `com.mccarty.journeymanjobs.journeymanJobs`
- Android Package Name: `com.mccarty.journeymanjobs`
- Storage Bucket: `journeyman-jobs.firebasestorage.app`

### Quick Reference Commands

```bash
# FlutterFire configure (automated setup)
flutterfire configure --project=journeyman-jobs

# Clean and rebuild
flutter clean && flutter pub get && cd ios && pod install && cd ..

# Run on iOS
flutter run -d ios

# Open Xcode workspace
open ios/Runner.xcworkspace

# Check bundle ID
grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -n 1

# Verify gitignore
git status | grep GoogleService-Info.plist
```

---

## ✅ Success Checklist

Before considering the setup complete, verify:

- [ ] `GoogleService-Info.plist` exists at `ios/Runner/GoogleService-Info.plist`
- [ ] File is added to Xcode project with Runner target membership
- [ ] Bundle ID in plist matches app bundle ID: `com.mccarty.journeymanjobs.journeymanJobs`
- [ ] File is in `.gitignore` (if using private Firebase project)
- [ ] App builds successfully on iOS: `flutter run -d ios`
- [ ] No Firebase initialization errors in console
- [ ] Firebase services (if used) work correctly in app

---

## 🎯 Next Steps After Configuration

Once iOS Firebase is configured:

1. **Test Firebase Features**
   - Authentication (if implemented)
   - Firestore database (if implemented)
   - Cloud Storage (if implemented)
   - Analytics (if implemented)

2. **Update CI/CD Pipeline**
   - Add Firebase config to CI/CD secrets
   - Update build scripts to include Firebase setup

3. **Document for Team**
   - Share setup process with team members
   - Document any project-specific Firebase configurations

4. **Enable Required Firebase Services**
   - Navigate to Firebase Console
   - Enable services your app requires (Authentication, Firestore, etc.)
   - Configure security rules

---

## 🆘 Getting Help

If you encounter issues not covered in this guide:

1. **Check Flutter Doctor**
   ```bash
   flutter doctor -v
   ```

2. **Check Firebase Project Status**
   - Visit [Firebase Console](https://console.firebase.google.com/project/journeyman-jobs)
   - Verify iOS app is registered
   - Check service enablement

3. **Review Logs**
   ```bash
   # iOS system logs
   flutter run -d ios --verbose

   # Xcode console
   # Open Xcode → Window → Devices and Simulators → View Device Logs
   ```

4. **Community Resources**
   - [FlutterFire GitHub Issues](https://github.com/firebase/flutterfire/issues)
   - [Stack Overflow - FlutterFire](https://stackoverflow.com/questions/tagged/flutterfire)
   - [Firebase Support](https://firebase.google.com/support)

---

**Document Version:** 1.0
**Last Updated:** 2025-11-19
**Maintained By:** Backend Development Team
**Project:** Journeyman Jobs - Tailboard Modernization
