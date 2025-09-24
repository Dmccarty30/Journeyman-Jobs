# Crews Feature - Quick Start Guide

## Prerequisites

1. Flutter 3.x installed
2. Firebase project configured
3. Firebase CLI installed
4. Android Studio / Xcode for device testing

## Setup Instructions

### 1. Firebase Configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for the project
flutterfire configure

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Cloud Functions
cd functions
npm install
firebase deploy --only functions
```

### 2. Install Dependencies

```bash
# In project root
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth
flutter pub add firebase_messaging
flutter pub add riverpod
flutter pub add flutter_riverpod

flutter pub get
```

### 3. Run Firebase Emulators (for testing)

```bash
# Start emulators
firebase emulators:start --only firestore,functions,auth

# In another terminal, run the app with emulators
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

## Testing User Flows

### Flow 1: Create Your First Crew

1. **Launch the app**
   ```bash
   flutter run
   ```

2. **Navigate to Crews tab**
   - Tap the Crews icon in bottom navigation
   - You'll see an empty state screen

3. **Create a crew**
   - Tap "Create a Crew" button
   - Enter crew name: "Highway Heroes"
   - Set preferences:
     - Job types: Journeyman Lineman
     - Min rate: $45/hr
     - Max distance: 100 miles
   - Tap "Create"

4. **Verify crew creation**
   - Crew should appear in your crews list
   - Tailboard should open automatically
   - You should be set as Foreman

### Flow 2: Invite Members

1. **Open crew Tailboard**
   - Select your crew from the dropdown

2. **Invite members**
   - Tap the "Invite" button in quick actions
   - Choose invite method:
     - Contacts: Select from phone contacts
     - Email: Enter email address
     - Username: Enter Journeyman Jobs username
   - Send invitations

3. **Verify invitations**
   - Check activity feed for "Invitation sent" items
   - Invitees receive push notifications

### Flow 3: Share Jobs to Crew

1. **Find a job**
   - Go to Jobs tab
   - Find a relevant job listing

2. **Share to crew**
   - Tap the share button on job card
   - Select your crew(s)
   - Add optional note: "Perfect for our crew!"
   - Tap "Share"

3. **Verify sharing**
   - Return to Crews tab
   - Check Tailboard activity feed
   - Job should appear with your share note

### Flow 4: Crew Messaging

1. **Send crew message**
   - Open Tailboard
   - Go to Chat tab
   - Type message: "Who's available for storm work?"
   - Send

2. **Send direct message**
   - Go to Members tab
   - Tap on a member
   - Tap "Message"
   - Send a DM

3. **Verify messages**
   - Check message delivery
   - Verify read receipts
   - Test typing indicators

### Flow 5: AI Job Matching

1. **Check suggested jobs**
   - Open Tailboard
   - Go to Jobs tab
   - View AI-matched jobs with scores

2. **Understand match reasons**
   - Each job shows why it matches
   - Example: "4 crew members qualified, Near crew location"

3. **Apply as crew**
   - Tap "Quick Apply" on matched job
   - Verify application in activity feed

## Test Data Setup

### Create Test Crews

```dart
// Run in debug console or test file
final testCrews = [
  {
    'name': 'Storm Chasers',
    'memberCount': 8,
    'jobTypes': ['journeymanLineman'],
    'minRate': 50.0,
  },
  {
    'name': 'Local 58 Crew',
    'memberCount': 15,
    'jobTypes': ['insideWireman'],
    'minRate': 40.0,
  },
];

for (final crew in testCrews) {
  await CrewService.createTestCrew(crew);
}
```

### Generate Test Activity

```dart
// Generate sample Tailboard activity
await CrewService.generateSampleActivity(crewId, {
  'jobShares': 5,
  'memberJoins': 3,
  'applications': 8,
  'announcements': 2,
});
```

## Verification Checklist

### Core Functionality
- [ ] Create crew with 1 member
- [ ] Crew becomes active with 2+ members
- [ ] Invite members via email/contacts
- [ ] Members can accept invitations
- [ ] Foreman can manage crew settings
- [ ] Members can leave crew

### Tailboard
- [ ] Activity feed updates in real-time
- [ ] Job suggestions appear with match scores
- [ ] Members can post announcements
- [ ] Posts can be pinned by foreman

### Job Sharing
- [ ] Share jobs to one or more crews
- [ ] Shared jobs appear in Tailboard
- [ ] Track which members viewed/applied
- [ ] Auto-share works for matching jobs

### Messaging
- [ ] Send crew messages
- [ ] Send direct messages
- [ ] Receive push notifications
- [ ] Read receipts work
- [ ] Attachments upload successfully

### Performance
- [ ] Tailboard loads in <100ms
- [ ] Messages deliver instantly
- [ ] Smooth scrolling in all lists
- [ ] Images lazy load properly

## Troubleshooting

### Issue: Crew not syncing
```bash
# Check Firestore connection
firebase emulators:start --inspect-functions

# Verify user authentication
print(FirebaseAuth.instance.currentUser?.uid);
```

### Issue: Push notifications not working
```bash
# Check FCM token
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

# Verify topic subscription
await FirebaseMessaging.instance.subscribeToTopic('crew_$crewId');
```

### Issue: Slow Tailboard loading
```dart
// Enable Firestore offline persistence
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## Next Steps

1. Run full test suite: `flutter test`
2. Check integration tests: `flutter test integration_test`
3. Monitor Firebase Analytics for usage patterns
4. Gather user feedback through in-app surveys
5. Iterate based on metrics and feedback