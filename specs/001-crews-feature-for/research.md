# Crews Feature - Technical Research

## Firebase Firestore Structure

### Decision: Subcollection Architecture
**Rationale**: Optimal for crew member queries, real-time sync, and scalability
**Alternatives Considered**:
- Flat collection structure: Rejected due to query complexity
- Separate collections with references: Rejected due to multiple read operations

### Recommended Structure:
```
crews/
  {crewId}/
    - metadata (name, logo, foremanId, preferences)
    - stats (memberCount, jobsShared, applicationRate)

    members/
      {userId}/
        - role (Foreman|Lead|Member)
        - joinedAt
        - permissions
        - availability

    tailboard/
      activity/
        {activityId}/
          - type (job_shared|member_joined|application)
          - timestamp
          - data

      posts/
        {postId}/
          - content
          - authorId
          - isPinned
          - reactions

messages/
  {messageId}/
    - crewId (null for DMs)
    - senderId
    - recipientId (for DMs)
    - content
    - sentAt
    - readBy[]
```

## Riverpod State Management

### Decision: StreamProvider for Real-time Data
**Rationale**: Automatic subscription management, caching, and error handling
**Alternatives Considered**:
- StateNotifier: Manual subscription management required
- ChangeNotifier: Less efficient for streaming data

### Provider Architecture:
```dart
// Crew list provider
final userCrewsProvider = StreamProvider<List<Crew>>((ref) {
  final userId = ref.watch(currentUserProvider)?.uid;
  return CrewService.getUserCrews(userId);
});

// Selected crew provider
final selectedCrewProvider = StateProvider<Crew?>((ref) => null);

// Tailboard feed provider
final tailboardProvider = StreamProvider.family<Tailboard, String>((ref, crewId) {
  return CrewService.getTailboardStream(crewId);
});

// Crew messages provider
final crewMessagesProvider = StreamProvider.family<List<Message>, String>((ref, crewId) {
  return MessageService.getCrewMessages(crewId);
});
```

## Integration with Job Sharing

### Decision: Extend Existing JobSharingService
**Rationale**: Reuse proven sharing infrastructure, maintain consistency
**Alternatives Considered**:
- Separate crew sharing service: Rejected due to code duplication
- Complete rewrite: Rejected as existing service works well

### Integration Points:
```dart
class JobSharingService {
  // Existing methods remain unchanged

  // New crew-specific methods
  Future<void> shareToCrews(String jobId, List<String> crewIds) async {
    // Reuse existing share logic
    // Add crew-specific tracking
  }

  Stream<List<SharedJob>> getCrewSharedJobs(String crewId) {
    // Filter shared jobs by crew
  }
}
```

## Push Notification Strategy

### Decision: Firebase Cloud Messaging with Topic Subscriptions
**Rationale**: Scalable, automatic crew member management, reliable delivery
**Alternatives Considered**:
- Individual token management: Complex to maintain
- Third-party service: Unnecessary additional dependency

### Implementation Approach:
```dart
// Subscribe to crew topics
await FirebaseMessaging.instance.subscribeToTopic('crew_$crewId');

// Notification types
enum CrewNotificationType {
  jobMatch,        // 90%+ match score
  directMessage,   // DM received
  crewMention,     // @username in crew
  invitation,      // Crew invitation
  dailySummary     // Daily Tailboard digest
}

// Cloud Function triggers
exports.onCrewJobShare = functions.firestore
  .document('crews/{crewId}/tailboard/activity/{activityId}')
  .onCreate(async (snap, context) => {
    // Send notification to crew members
  });
```

## Performance Optimizations

### Decision: Pagination and Lazy Loading
**Rationale**: Essential for <100ms Tailboard load time goal
**Alternatives Considered**:
- Load everything: Poor performance with large crews
- Fixed limits: Not flexible enough

### Optimization Strategies:
1. **Tailboard Feed**: Load 20 items initially, infinite scroll
2. **Message History**: Load last 50 messages, load more on scroll
3. **Member List**: Virtual scrolling for large crews
4. **Image Loading**: Lazy load with placeholders
5. **Offline Cache**: Store last Tailboard state locally

## Security Considerations

### Decision: Firestore Security Rules with Role-Based Access
**Rationale**: Server-side enforcement, no client-side bypasses
**Alternatives Considered**:
- Client-side checks only: Insecure
- Cloud Functions for all operations: Unnecessary latency

### Security Rules:
```javascript
match /crews/{crewId} {
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));

  allow update: if request.auth != null &&
    get(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)).data.role == 'Foreman';
}

match /crews/{crewId}/members/{userId} {
  allow write: if request.auth.uid == userId ||
    get(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid)).data.role == 'Foreman';
}
```

## UI/UX Patterns

### Decision: Bottom Sheet for Quick Actions
**Rationale**: Thumb-friendly, doesn't obscure content, familiar pattern
**Alternatives Considered**:
- Floating action button: Limited to one action
- Top app bar actions: Hard to reach one-handed

### UI Components:
- **CrewSelector**: Dropdown in app bar for quick crew switching
- **TailboardTabs**: Swipeable tabs for Feed/Jobs/Chat/Members
- **JobMatchCard**: Expandable card with match score visualization
- **MessageBubble**: Standard chat UI with read receipts

## Testing Strategy

### Decision: Firebase Emulator Suite for Integration Tests
**Rationale**: Realistic testing environment, no production data risk
**Alternatives Considered**:
- Mock services: Don't catch Firebase-specific issues
- Production testing: Risky and affects real data

### Test Coverage Goals:
- Unit tests: 80% coverage for models and services
- Widget tests: All screens and major components
- Integration tests: Critical user flows
- E2E tests: Crew creation, job sharing, messaging flows