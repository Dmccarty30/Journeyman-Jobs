# Crews Communication Hub - Quick Start Guide

## Prerequisites

1. Flutter 3.x with Dart 3.0+
2. Firebase project configured with Firestore, Auth, and Cloud Functions
3. Firebase CLI installed and authenticated
4. Android Studio / Xcode for device testing
5. Firebase emulator suite for local testing

## Setup Instructions

### 1. Firebase Configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for the project
flutterfire configure --project=journeyman-jobs

# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Cloud Functions for crew notifications
cd functions
npm install
firebase deploy --only functions:onCrewJobShare,onMemberJoin,onVoteRequest
```

### 2. Install Dependencies

```bash
# Add crew-specific dependencies
flutter pub add riverpod flutter_riverpod
flutter pub add firebase_core cloud_firestore firebase_auth firebase_messaging
flutter pub add cached_network_image
flutter pub add file_picker # For attachments
flutter pub add image_picker # For crew logos and photos

flutter pub get
```

### 3. Firebase Emulator Setup (for testing)

```bash
# Start emulators for local development
firebase emulators:start --only firestore,functions,auth,storage

# In another terminal, run app with emulator configuration
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

### 4. Initial Firestore Collections Setup

```bash
# Import test data (run once)
firebase firestore:import test-data/ --project=journeyman-jobs
```

## Testing User Flows

### Flow 1: Create Your First Crew

**Objective**: Test crew creation and member invitation flow

1. **Launch the app**
   ```bash
   flutter run
   ```

2. **Navigate to Crews section**
   - Open bottom navigation
   - Tap "Crews" tab (new tab added)
   - Should show empty state: "No crews yet"

3. **Create a new crew**
   - Tap "Create a Crew" button
   - Fill out crew details:
     - Name: "Storm Chasers"
     - Upload crew logo (optional)
     - Set crew preferences:
       - Job types: Storm Work, Journeyman Lineman
       - Minimum rate: $55/hour
       - Max travel: 500 miles
   - Tap "Create Crew"

4. **Verify crew creation**
   - Should redirect to crew communication hub
   - User should be set as crew leader
   - Crew appears in user's crew list
   - Empty state shows "Invite members to get started"

5. **Invite crew members**
   - Tap "Invite Members" button
   - Test different invite methods:
     - **By Email**: Enter valid email address
     - **By Phone**: Enter phone number from contacts
     - **By Username**: Search for existing users
   - Add invitation message: "Join my storm work crew!"
   - Send invitations

6. **Verify invitations sent**
   - Check crew activity feed shows "Invitations sent to 3 members"
   - Invitees receive push notifications
   - Invitees can see pending invitation in their crews section

### Flow 2: Accept Crew Invitation and Join

**Objective**: Test invitation acceptance and member onboarding

1. **As invited user, open the app**
   - Should see push notification about crew invitation
   - Navigate to Crews tab

2. **View pending invitation**
   - Should see "Storm Chasers" invitation
   - View crew details: name, leader, current members
   - View crew preferences and job focus

3. **Accept invitation**
   - Tap "Accept" on crew invitation
   - Set personal crew preferences:
     - Individual minimum rate: $50/hour
     - Availability: Monday-Friday
     - Notification preferences: All enabled except quiet hours
   - Complete onboarding

4. **Verify membership**
   - Crew appears in user's active crews list
   - Can access crew communication hub
   - Other members receive notification: "John joined the crew"
   - Crew is now "Active" (2+ members)

### Flow 3: Share Job Opportunity with Crew

**Objective**: Test job sharing and coordination functionality

1. **Find a relevant job**
   - Navigate to Jobs tab
   - Find storm work or lineman job
   - Open job details

2. **Share job with crew**
   - Tap "Share with Crew" button
   - Select crew(s): Check "Storm Chasers"
   - Add message: "Perfect storm job in Florida! Who's interested?"
   - Mark as priority: Enable (storm work)
   - Tap "Share with Crew"

3. **Verify job sharing**
   - Job appears in crew's job board
   - All crew members receive push notification
   - Activity feed shows: "Mike shared a job: Storm Restoration Lineman"

4. **Members respond to job**
   - Other crew members open crew communication hub
   - View shared job with match details
   - Respond with interest level:
     - Member 1: "Interested" with note "I'm available next week"
     - Member 2: "Conditional Yes" with note "Need housing provided"
     - Member 3: "Not Interested" with note "Already committed elsewhere"

5. **Coordinate group response**
   - Leader sees member responses in job notification
   - Can coordinate group application if enough interest
   - Send crew message: "Let's apply as a group for the Florida storm job"

### Flow 4: Crew Communication and Messaging

**Objective**: Test real-time communication features

1. **Send crew message**
   - Open crew communication hub
   - Tap message input field
   - Type: "Heading to Florida tomorrow for storm work. Who's driving?"
   - Send message

2. **Test message features**
   - Attach photo: Tap attachment, select image from gallery
   - Reply to message: Long press message, tap "Reply"
   - Pin important message: Long press, tap "Pin" (leader only)

3. **Verify real-time delivery**
   - Other crew members see message immediately
   - Read receipts appear as members view messages
   - Typing indicators show when someone is composing

4. **Test different message types**
   - **Announcement**: Leader posts pinned announcement
   - **Poll/Vote**: Create crew vote for equipment purchase
   - **Coordination**: Plan meeting time and location
   - **Work Update**: Share progress from job site

### Flow 5: Group Job Application Coordination

**Objective**: Test coordinated group bidding functionality

1. **Initiate group application**
   - From shared job notification with positive responses
   - Tap "Coordinate Group Application"
   - Select participating members (must have 50%+ interested)

2. **Plan group bid**
   - Set group rate: $58/hour (higher than individual)
   - Assign roles:
     - Mike: Lead Journeyman
     - John: Journeyman Lineman
     - Sarah: Equipment Operator
   - Set start date and duration estimate
   - Request housing and transportation

3. **Submit group bid**
   - Review bid details with crew
   - Get final confirmation from all participating members
   - Submit coordinated application to employer

4. **Track application status**
   - Bid appears in crew's active applications
   - Status updates shared with all crew members
   - Employer response communicated to entire group

### Flow 6: Member Management and Voting

**Objective**: Test crew governance and member management

1. **Inactive member scenario**
   - Simulate member being inactive for 30+ days
   - System should flag for potential removal

2. **Initiate member vote**
   - Leader initiates vote to remove inactive member
   - Set vote duration: 48 hours
   - Voting question: "Remove John due to 45-day inactivity?"

3. **Crew voting process**
   - All active members receive vote notification
   - Members cast votes: Yes/No with optional comments
   - Vote progress tracked in crew activity

4. **Vote resolution**
   - After 48 hours or when all members vote
   - Result determined (majority wins)
   - If passed, member removed from crew
   - If failed, member remains in crew

## Test Data Generation

### Create Test Crews and Members

```dart
// Run in debug console or test file
class CrewTestDataGenerator {
  static Future<void> generateTestData() async {
    // Create multiple test crews
    final crews = [
      {
        'name': 'Storm Chasers',
        'preferences': {
          'jobTypes': ['storm_work', 'journeyman_lineman'],
          'minimumRate': 55.0,
          'maxTravelDistance': 500,
        },
        'memberCount': 6,
      },
      {
        'name': 'Local 58 Crew',
        'preferences': {
          'jobTypes': ['inside_wireman'],
          'minimumRate': 45.0,
          'maxTravelDistance': 100,
        },
        'memberCount': 4,
      },
      {
        'name': 'Maintenance Masters',
        'preferences': {
          'jobTypes': ['maintenance_lineman', 'tree_trimmer'],
          'minimumRate': 40.0,
          'maxTravelDistance': 200,
        },
        'memberCount': 8,
      },
    ];

    for (final crewData in crews) {
      await _createTestCrew(crewData);
    }
  }

  static Future<void> _createTestCrew(Map<String, dynamic> crewData) async {
    // Create crew with test leader
    final crew = await CrewService.createCrew(
      name: crewData['name'],
      preferences: CrewPreferences.fromMap(crewData['preferences']),
    );

    // Add test members
    for (int i = 0; i < crewData['memberCount'] - 1; i++) {
      await CrewService.addTestMember(crew.id);
    }

    // Generate test activity
    await _generateTestActivity(crew.id);
  }

  static Future<void> _generateTestActivity(String crewId) async {
    // Generate sample messages
    final messages = [
      'Anyone available for storm work in Texas?',
      'Great job everyone on the last project!',
      'New safety requirements for high voltage work attached',
      'Planning to head south for hurricane season',
    ];

    for (final message in messages) {
      await CrewService.sendMessage(crewId, message, MessageType.text);
      await Future.delayed(Duration(seconds: 2));
    }

    // Generate sample job shares
    await CrewService.shareTestJob(crewId, isPriority: true);
    await CrewService.shareTestJob(crewId, isPriority: false);
  }
}
```

### Sample Job Sharing Test

```dart
// Test job sharing with realistic electrical work jobs
final testJobs = [
  {
    'title': 'Storm Restoration Lineman - Hurricane Recovery',
    'company': 'Duke Energy',
    'location': 'Florida',
    'rate': 60.0,
    'duration': '6-8 weeks',
    'priority': true,
    'requirements': ['CDL', 'Overhead experience', 'Storm experience preferred']
  },
  {
    'title': 'Journeyman Lineman - Substation Construction',
    'company': 'Southern Company',
    'location': 'Georgia',
    'rate': 52.0,
    'duration': '4 months',
    'priority': false,
    'requirements': ['Substation experience', '69kV-500kV experience']
  },
];
```

## Verification Checklist

### Core Crew Management
- [ ] Create crew with leader automatically assigned
- [ ] Crew becomes active with 2+ members
- [ ] Maximum 5 crews per user enforced
- [ ] Maximum 10 members per crew enforced
- [ ] Invite members via email, phone, username
- [ ] Members can accept/decline invitations
- [ ] Crew leader can update crew settings
- [ ] Members can leave crew independently

### Job Sharing and Coordination
- [ ] Share jobs to specific crews
- [ ] Job notifications appear immediately
- [ ] Members can respond with interest level
- [ ] Group bid coordination works with 50%+ interest
- [ ] Individual applications still allowed
- [ ] Priority jobs flagged and highlighted
- [ ] Job sharing prevents duplicates within 24 hours

### Real-time Communication
- [ ] Messages deliver instantly to all members
- [ ] Read receipts show message status
- [ ] Typing indicators work in group chat
- [ ] Attachments upload and display correctly
- [ ] Message editing works (sender only)
- [ ] Message pinning works (leader only)
- [ ] Push notifications trigger for important messages

### Member Management & Governance
- [ ] Vote initiation works (leader or member request)
- [ ] All eligible members can participate in votes
- [ ] Vote results calculated correctly (majority wins)
- [ ] Inactive members flagged after 45 days
- [ ] Member removal enforced based on vote results
- [ ] Leadership transfer works when leader leaves

### Performance & Reliability
- [ ] Crew communication hub loads in <100ms
- [ ] Message history pagination works smoothly
- [ ] Offline mode shows cached crew data
- [ ] Real-time updates work on poor network
- [ ] Push notifications delivered reliably
- [ ] App maintains responsiveness with large crews

### Data Privacy & Security
- [ ] Firestore security rules prevent unauthorized access
- [ ] Users can only see crews they belong to
- [ ] Message editing only by original sender
- [ ] Crew management only by leaders
- [ ] Invitation acceptance only by invited user
- [ ] User data properly isolated between crews

## Troubleshooting Common Issues

### Issue: Crew not syncing between devices
```bash
# Check Firestore offline persistence
await FirebaseFirestore.instance.enableNetwork();
await FirebaseFirestore.instance.clearPersistence();

# Verify user authentication
final user = FirebaseAuth.instance.currentUser;
print('User: ${user?.uid}');
```

### Issue: Push notifications not working
```bash
# Check FCM token generation
final fcmToken = await FirebaseMessaging.instance.getToken();
print('FCM Token: $fcmToken');

# Verify topic subscription
await FirebaseMessaging.instance.subscribeToTopic('crew_$crewId');

# Test with Firebase console message
```

### Issue: Messages not delivering in real-time
```dart
// Check Firestore connection status
FirebaseFirestore.instance.snapshotsInSync().listen((_) {
  print('Firestore in sync');
});

// Verify stream subscription
final messagesStream = FirebaseFirestore.instance
    .collection('crews/$crewId/communications')
    .orderBy('timestamp')
    .snapshots();

messagesStream.listen(
  (snapshot) => print('Messages updated: ${snapshot.docs.length}'),
  onError: (error) => print('Stream error: $error'),
);
```

### Issue: Slow crew communication hub loading
```dart
// Enable Firestore aggressive caching
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Preload crew data for offline access
await CrewService.preloadCrewData(crewId);
```

## Performance Monitoring

### Key Metrics to Track

```dart
// Measure crew communication hub load time
final stopwatch = Stopwatch()..start();
await loadCrewData(crewId);
stopwatch.stop();
print('Load time: ${stopwatch.elapsedMilliseconds}ms'); // Target: <100ms

// Track message delivery time
final messageTimestamp = DateTime.now();
await sendMessage(crewId, content);
// Measure time until other members receive notification

// Monitor crew engagement
final metrics = await CrewAnalytics.getEngagementMetrics(crewId);
print('Messages per day: ${metrics.messagesPerDay}');
print('Job sharing rate: ${metrics.jobSharingRate}');
```

## Next Steps

1. **Run comprehensive test suite**: `flutter test`
2. **Execute integration tests**: `flutter test integration_test/crews_test.dart`
3. **Load test with multiple crews**: Simulate 50+ concurrent users
4. **Monitor Firebase usage**: Check Firestore read/write costs
5. **Collect user feedback**: Use in-app feedback for crew UX
6. **Performance optimization**: Profile crew communication hub loading
7. **Security audit**: Review Firestore security rules with test scenarios

## Production Deployment Checklist

- [ ] Firebase security rules tested and deployed
- [ ] Cloud Functions for notifications deployed and tested
- [ ] Push notification certificates installed (iOS)
- [ ] Analytics tracking configured for crew features
- [ ] Crashlytics configured for error monitoring
- [ ] Performance monitoring enabled (Firebase Performance)
- [ ] A/B testing configured for crew onboarding flow
- [ ] Backup and recovery procedures tested
- [ ] User support documentation updated with crew features