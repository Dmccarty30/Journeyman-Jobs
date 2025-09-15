# Crews Communication Hub - Technical Research

## Firebase Firestore Design for Crew Communication

### Decision: Hierarchical Subcollection Architecture
**Rationale**: Optimizes for real-time crew communication, scales to multiple crews per user, supports complex queries for crew activity feeds
**Alternatives Considered**:
- Flat collection with crew references: Rejected due to query complexity and N+1 problems
- Document-per-conversation: Rejected due to Firestore's 1MB document limit
- Single messages collection: Rejected due to poor crew isolation and security

### Recommended Firestore Structure:
```
crews/
  {crewId}/
    - name, leaderId, createdAt, activeStatus
    - memberLimit: 10, activityRetention: 30days
    - preferences: { jobTypes[], locations[], rates }

    members/
      {userId}/
        - role: "leader" | "member"
        - joinedAt, lastActive, notificationPrefs
        - workPreferences: individual crew preferences
        - votingPower: for crew decisions

    jobNotifications/
      {notificationId}/
        - jobId, sharedByUserId, message, timestamp
        - memberResponses: { userId: "interested" | "not_interested" | "applied" }
        - groupBidStatus: "pending" | "submitted" | "accepted" | "rejected"

    communications/
      {messageId}/
        - senderId, content, timestamp, messageType
        - attachments: [{ url, type, filename }]
        - readBy: { userId: timestamp }
        - replyTo: messageId (for threading)

    activity/
      {activityId}/
        - type: "member_joined" | "job_shared" | "group_bid" | "member_left"
        - actorId, timestamp, data: JSON
        - visibility: "all" | "leaders" | specific userIds[]

users/
  {userId}/
    crewMemberships/
      {crewId}/
        - role, joinedAt, notificationToken
        - quickAccess: for user's crew list
```

## Riverpod State Management for Real-time Crew Data

### Decision: StreamProvider with Family for Crew-specific Data
**Rationale**: Automatic subscription management, built-in caching, error handling, and reactive UI updates
**Alternatives Considered**:
- StateNotifier with manual stream management: Too much boilerplate
- ChangeNotifier: Poor performance with real-time data streams
- Raw StreamBuilder: No caching or state management

### Provider Architecture:
```dart
// User's crew list
final userCrewsProvider = StreamProvider<List<Crew>>((ref) {
  final userId = ref.watch(currentUserProvider)?.uid;
  return CrewService.getUserCrews(userId);
});

// Selected crew for current screen
final selectedCrewProvider = StateProvider<String?>((ref) => null);

// Real-time crew data
final crewProvider = StreamProvider.family<Crew, String>((ref, crewId) {
  return CrewService.getCrewStream(crewId);
});

// Crew communications stream
final crewMessagesProvider = StreamProvider.family<List<CrewMessage>, String>((ref, crewId) {
  return CrewService.getCrewMessages(crewId, limit: 50);
});

// Job notifications for crew
final crewJobNotificationsProvider = StreamProvider.family<List<JobNotification>, String>((ref, crewId) {
  return CrewService.getCrewJobNotifications(crewId);
});

// Activity feed
final crewActivityProvider = StreamProvider.family<List<CrewActivity>, String>((ref, crewId) {
  return CrewService.getCrewActivity(crewId, days: 7);
});
```

## Integration with Existing Job Sharing Infrastructure

### Decision: Extend JobSharingService with Crew-specific Methods
**Rationale**: Reuses proven sharing logic, maintains consistency, leverages existing notification system
**Alternatives Considered**:
- Separate CrewJobSharingService: Code duplication and complexity
- Complete rewrite: Unnecessary when existing service works well
- Merge all functionality: Would violate single responsibility

### Integration Strategy:
```dart
// Extend existing service
class JobSharingService {
  // EXISTING methods remain unchanged
  Future<void> shareJob(String jobId, ShareMethod method) async {...}
  Future<void> shareViaEmail(String jobId, List<String> emails) async {...}

  // NEW crew-specific methods
  Future<void> shareJobToCrew(String jobId, String crewId, {String? message}) async {
    // Reuse existing sharing infrastructure
    final crew = await FirebaseFirestore.instance
        .collection('crews').doc(crewId).get();

    // Create crew job notification
    await FirebaseFirestore.instance
        .collection('crews/$crewId/jobNotifications')
        .add({
          'jobId': jobId,
          'sharedByUserId': getCurrentUserId(),
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'memberResponses': {},
        });

    // Notify crew members using existing notification system
    await _notifyCrewMembers(crewId, jobId);
  }

  Future<void> shareJobToMultipleCrews(String jobId, List<String> crewIds) async {
    // Batch operation for efficiency
    final batch = FirebaseFirestore.instance.batch();
    for (final crewId in crewIds) {
      // Add to each crew's job notifications
    }
    await batch.commit();
  }

  Stream<List<JobNotification>> getCrewSharedJobs(String crewId) {
    return FirebaseFirestore.instance
        .collection('crews/$crewId/jobNotifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) =>
            JobNotification.fromFirestore(doc)).toList());
  }
}
```

## Push Notification Strategy for Crew Communication

### Decision: Firebase Cloud Messaging with Crew Topic Subscriptions
**Rationale**: Scalable, reliable, integrates with existing FCM setup, supports both crew and individual notifications
**Alternatives Considered**:
- Individual device token management: Complex membership sync issues
- Third-party service (Pusher, etc.): Unnecessary additional dependency
- In-app only notifications: Poor for field workers who may not have app open

### Notification Implementation:
```dart
// Subscribe to crew topic when joining
class CrewNotificationService {
  Future<void> joinCrewNotifications(String crewId) async {
    await FirebaseMessaging.instance.subscribeToTopic('crew_$crewId');
    await FirebaseMessaging.instance.subscribeToTopic('crew_${crewId}_urgent');
  }

  Future<void> leaveCrewNotifications(String crewId) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('crew_$crewId');
    await FirebaseMessaging.instance.unsubscribeFromTopic('crew_${crewId}_urgent');
  }
}

// Cloud Function triggers
exports.onCrewJobShare = functions.firestore
  .document('crews/{crewId}/jobNotifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const { crewId } = context.params;
    const notification = snap.data();

    // Send to crew topic
    await admin.messaging().sendToTopic(`crew_${crewId}`, {
      notification: {
        title: 'New Job Opportunity',
        body: `${notification.sharedByName} shared a job with the crew`,
        icon: 'job_share_icon',
      },
      data: {
        type: 'crew_job_share',
        crewId,
        jobId: notification.jobId,
        notificationId: snap.id,
      },
    });
  });

// Notification types and priorities
enum CrewNotificationType {
  jobShared,        // Normal priority - new job shared to crew
  directMessage,    // High priority - direct message from crew member
  urgentJob,        // High priority - storm work or time-sensitive job
  memberJoined,     // Low priority - new member joined crew
  memberLeft,       // Normal priority - member left crew
  groupBidUpdate,   // Normal priority - bid status changed
  voteRequest,      // High priority - crew decision vote needed
}
```

## Offline-First Design for Field Workers

### Decision: Firestore Offline Persistence with Selective Caching
**Rationale**: Essential for field workers with poor connectivity, reduces data usage, improves performance
**Alternatives Considered**:
- Full online-only: Poor UX for field workers
- Manual offline storage: Complex sync logic and data consistency issues
- SQLite with manual sync: Too much complexity for benefit gained

### Offline Strategy:
```dart
// Enable Firestore offline persistence
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // For crew communication history
);

// Selective data loading for offline
class OfflineCrewService {
  Future<void> preloadCrewDataForOffline(String crewId) async {
    // Cache essential crew data
    await FirebaseFirestore.instance
        .collection('crews/$crewId/members')
        .get(GetOptions(source: Source.server));

    // Cache recent communications (last 50 messages)
    await FirebaseFirestore.instance
        .collection('crews/$crewId/communications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get(GetOptions(source: Source.server));

    // Cache active job notifications
    await FirebaseFirestore.instance
        .collection('crews/$crewId/jobNotifications')
        .where('timestamp', isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
        .get(GetOptions(source: Source.server));
  }

  // Offline-aware UI states
  Widget buildOfflineAwareCrewList() {
    return StreamBuilder<List<Crew>>(
      stream: crewProvider,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Check if it's a network error
          if (snapshot.error.toString().contains('network')) {
            return OfflineCrewListWidget(); // Show cached data
          }
        }
        return CrewListWidget(crews: snapshot.data);
      },
    );
  }
}
```

## Security and Privacy for Crew Communications

### Decision: Firestore Security Rules with Role-Based Access
**Rationale**: Server-side enforcement, no client bypasses, fine-grained permissions, audit trail
**Alternatives Considered**:
- Client-side only validation: Insecure and easily bypassed
- Cloud Functions for all operations: Unnecessary latency for simple operations
- End-to-end encryption: Overkill for crew coordination, adds complexity

### Security Rules:
```javascript
// Firestore Security Rules
match /crews/{crewId} {
  // Only crew members can read crew data
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));

  // Only crew leader can update main crew document
  allow update: if request.auth != null &&
    get(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)).data.role == 'leader';

  // Members can join if invited (handled by Cloud Function)
  allow create: if request.auth != null;
}

match /crews/{crewId}/members/{userId} {
  // Users can read all crew members
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));

  // Users can only write their own membership
  allow write: if request.auth.uid == userId ||
    get(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)).data.role == 'leader';
}

match /crews/{crewId}/communications/{messageId} {
  // All crew members can read messages
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));

  // All crew members can send messages
  allow create: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)) &&
    request.resource.data.senderId == request.auth.uid;

  // Only sender can update their own messages (for editing)
  allow update: if request.auth != null &&
    resource.data.senderId == request.auth.uid;
}

match /crews/{crewId}/jobNotifications/{notificationId} {
  // All crew members can read job notifications
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));

  // All crew members can create job notifications
  allow create: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)) &&
    request.resource.data.sharedByUserId == request.auth.uid;

  // Members can update to add their responses
  allow update: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
}
```

## Performance Optimizations for Crew Features

### Decision: Pagination, Lazy Loading, and Intelligent Caching
**Rationale**: Essential for field workers on slower networks, keeps app responsive even with large crew activity
**Alternatives Considered**:
- Load everything upfront: Poor performance and data usage
- Fixed small limits: User frustration with incomplete data
- Infinite loading without pagination: Memory usage issues

### Performance Strategies:
```dart
class PerformantCrewService {
  // Paginated message loading
  Stream<List<CrewMessage>> getCrewMessagesPageinated(
    String crewId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = FirebaseFirestore.instance
        .collection('crews/$crewId/communications')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CrewMessage.fromFirestore(doc)).toList());
  }

  // Intelligent crew activity aggregation
  Stream<CrewActivitySummary> getCrewActivitySummary(String crewId) {
    return FirebaseFirestore.instance
        .collection('crews/$crewId/activity')
        .where('timestamp', isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
        .orderBy('timestamp', descending: true)
        .limit(10) // Only most recent
        .snapshots()
        .map((snapshot) => CrewActivitySummary.fromActivities(
            snapshot.docs.map((doc) => CrewActivity.fromFirestore(doc)).toList()));
  }

  // Optimized member presence
  Stream<Map<String, bool>> getCrewMemberPresence(String crewId) {
    return FirebaseFirestore.instance
        .collection('crews/$crewId/members')
        .snapshots()
        .map((snapshot) {
          final presence = <String, bool>{};
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
            presence[doc.id] = lastActive != null &&
                DateTime.now().difference(lastActive).inMinutes < 15;
          }
          return presence;
        });
  }
}

// UI Optimizations
class OptimizedCrewUI {
  // Virtual scrolling for large crew lists
  Widget buildVirtualCrewList(List<Crew> crews) {
    return ListView.builder(
      itemCount: crews.length,
      cacheExtent: 500, // Cache 500px worth of items
      itemBuilder: (context, index) {
        if (index >= crews.length) return SizedBox.shrink();
        return CrewListItem(crew: crews[index]);
      },
    );
  }

  // Optimized message list with read status
  Widget buildMessageList(List<CrewMessage> messages) {
    return ListView.separated(
      reverse: true, // Start from bottom like chat
      itemCount: messages.length,
      physics: ClampingScrollPhysics(), // Better performance on Android
      separatorBuilder: (_, __) => SizedBox(height: 4),
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          isOwnMessage: message.senderId == getCurrentUserId(),
        );
      },
    );
  }
}
```

## Testing Strategy for Crew Features

### Decision: Firebase Emulator Suite with Comprehensive Test Coverage
**Rationale**: Realistic testing environment, no production data risk, supports complex crew interaction scenarios
**Alternatives Considered**:
- Mock Firestore: Doesn't catch Firebase-specific issues or security rule problems
- Production testing: Risky and affects real user data
- Unit tests only: Missing integration and real-world usage patterns

### Test Strategy:
```dart
// Integration test setup
class CrewTestEnvironment {
  static Future<void> setupEmulators() async {
    await Firebase.initializeApp();

    // Use Firebase emulators for testing
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  static Future<Map<String, dynamic>> createTestCrewEnvironment() async {
    // Create test users
    final leader = await createTestUser('leader@test.com');
    final member1 = await createTestUser('member1@test.com');
    final member2 = await createTestUser('member2@test.com');

    // Create test crew
    final crew = await CrewService.createCrew(
      name: 'Test Crew',
      leaderId: leader.uid,
    );

    // Add members
    await CrewService.inviteMembers(crew.id, [member1.email, member2.email]);
    await CrewService.acceptInvitation(crew.id, member1.uid);
    await CrewService.acceptInvitation(crew.id, member2.uid);

    return {
      'crew': crew,
      'leader': leader,
      'members': [member1, member2],
    };
  }
}

// Test coverage goals
class CrewTestSuite {
  // Unit Tests (80% coverage goal)
  void testCrewModels() {
    test('Crew model validation', () { ... });
    test('CrewMember role permissions', () { ... });
    test('JobNotification response tracking', () { ... });
  }

  // Integration Tests (Critical flows)
  void testCrewWorkflows() {
    testWidgets('Complete crew creation flow', (tester) async {
      // Test full flow: create -> invite -> accept -> communicate
    });

    testWidgets('Job sharing within crew flow', (tester) async {
      // Test: share job -> notify members -> coordinate responses
    });
  }

  // E2E Tests (User journeys)
  void testCompleteUserJourneys() {
    testWidgets('New user creates crew and shares first job', (tester) async {
      // Complete user journey from onboarding to job sharing
    });
  }
}
```