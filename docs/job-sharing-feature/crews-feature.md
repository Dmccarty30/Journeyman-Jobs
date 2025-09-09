# Crews Epic - Comprehensive Feature Specification

## Transforming Individual Journeymen into Collaborative Teams

---

## 🎯 Epic Overview

The **Crews Epic** transforms Journeyman Jobs from an individual job-finding platform into a collaborative network where skilled workers form crews, share opportunities, and advance their careers together.

---

## 📊 Epic Components

### 1. **Crew Formation & Management**

- Create and join multiple crews
- Invite members via contacts, email, or username
- Set crew preferences (location, job types, rates)
- Manage crew roles (Foreman, Lead, Member)
- Crew profiles with skills and certifications

### 2. **The Tailboard (Central Hub)**

- Crew dashboard showing all activity
- Suggested jobs based on crew preferences
- Member availability calendar
- Shared job applications status
- Crew announcements and pins
- Activity feed with real-time updates

### 3. **Advanced Job Sharing**

- Share jobs to specific crews
- Bulk share to multiple crews
- Auto-share jobs matching crew criteria
- Track crew application rates
- Coordinate group applications
- Share with personal recommendations

### 4. **Intelligent Job Matching**

- AI-powered job suggestions based on:
  - Individual onboarding preferences
  - Crew collective preferences
  - Historical application data
  - Success rates by job type
  - Location and travel preferences
- Custom filters per crew
- Saved search alerts

### 5. **Crew Messaging System**

- **Direct Messages**: 1-on-1 private conversations
- **Crew Chat**: Group messaging within crews
- **Tailboard Posts**: Public crew announcements
- Media sharing (photos, documents, certifications)
- Voice notes for field communication
- Read receipts and typing indicators

---

## 🏗️ Technical Architecture

```dart
┌─────────────────────────────────────┐
│         Tailboard Dashboard         │
│  ┌─────────────────────────────┐   │
│  │    Job Suggestions Feed     │   │
│  ├─────────────────────────────┤   │
│  │    Crew Activity Stream     │   │
│  ├─────────────────────────────┤   │
│  │    Messages & Notifications │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│  Jobs   │ │Messaging│ │  Crews  │
│ Service │ │ Service │ │ Service │
└─────────┘ └─────────┘ └─────────┘
```

---

## 📱 User Flows

### Creating a Crew

```dart
1. Tap "Create Crew" → Name crew
2. Set preferences (location, job types, min rates)
3. Invite members (contacts/email/username)
4. Members receive invitations
5. Crew becomes active with 2+ members
6. Tailboard automatically populated
```

### Job Sharing Within Crew

```dart
1. Find relevant job → Tap share
2. Select crew(s) to share with
3. Add recommendation note (optional)
4. Job appears on crew Tailboard
5. Members get push notification
6. Track views and applications
```

### Crew Messaging Flow

```dart
Direct Message:
User → Select member → Chat interface → Send

Crew Chat:
User → Crew Tailboard → Messages tab → Group chat

Tailboard Post:
User → Crew Tailboard → Create post → Visible to all
```

---

## 🎨 Tailboard Interface

### Main Sections

**1. **Header**

- Crew name & logo
- Member count & online status
- Quick actions (Share Job, Message, Invite)

**2. **Job Feed**

```dart
Card: Suggested Job
├── Job title & company
├── Match score (95% crew fit)
├── Pay rate & location
├── Members who viewed (3 avatars)
├── Quick apply / Share buttons
└── Why suggested (AI explanation)
```

**3. **Activity Stream**

```dart
Timeline Item:
├── [Avatar] Member name
├── Action (applied/shared/joined)
├── Job or crew details
├── Timestamp
└── React/Comment options
```

**4. **Message Center**

```dart
Message Preview:
├── Sender avatar & name
├── Message preview (truncated)
├── Unread indicator
├── Timestamp
└── Tap to open full chat
```

---

## 💾 Data Models

### Crew Model

```dart
class Crew {
  String id;
  String name;
  String? logo;
  String foremanId;
  List<String> memberIds;
  CrewPreferences preferences;
  DateTime createdAt;
  Map<String, MemberRole> roles;
  CrewStats stats;
}

class CrewPreferences {
  List<String> jobTypes;
  double minHourlyRate;
  int maxDistance;
  List<String> preferredCompanies;
  List<String> skills;
  WorkSchedule availability;
}
```

### Tailboard Model

```dart
class Tailboard {
  String crewId;
  List<SuggestedJob> jobFeed;
  List<ActivityItem> activityStream;
  List<TailboardPost> posts;
  List<Message> recentMessages;
  CrewCalendar calendar;
  Map<String, dynamic> analytics;
}
```

### Message Model

```dart
class Message {
  String id;
  String senderId;
  String? recipientId; // null for crew messages
  String? crewId;
  String content;
  MessageType type;
  List<Attachment>? attachments;
  DateTime sentAt;
  Map<String, DateTime> readBy;
}
```

---

## 🔔 Notification Strategy

### Push Notifications

- New crew invitations
- Job matches above 90% threshold
- Direct messages
- Crew mentions (@username)
- Application status updates
- Daily Tailboard summary

### In-App Badges

- Unread messages count
- New job suggestions
- Pending invitations
- Activity updates

---

## 📊 Analytics & Metrics

### Crew Success Metrics

```javascript
{
  crewEngagement: {
    dailyActiveCrews: count,
    messagesPerDay: average,
    jobsSharedPerWeek: total,
    applicationRate: percentage
  },
  
  jobMatching: {
    suggestionAccuracy: "92%",
    clickThroughRate: "45%",
    applicationConversion: "28%",
    averageMatchScore: 87
  },
  
  viralGrowth: {
    invitesSent: total,
    inviteAcceptance: "67%",
    averageCrewSize: 4.3,
    monthlyGrowthRate: "34%"
  }
}
```

---

## 🚀 Implementation Phases

### Phase 1: Core Crews (Weeks 1-2)

- Crew creation and management
- Member invitations
- Basic Tailboard with job feed
- Crew preferences setup

### Phase 2: Job Intelligence (Weeks 3-4)

- AI job matching algorithm
- Advanced filtering system
- Collective preference optimization
- Success prediction models

### Phase 3: Messaging (Weeks 5-6)

- Direct messaging
- Crew group chat
- Tailboard posts
- File sharing

### Phase 4: Job Sharing (Weeks 7-8)

- Integrate existing job sharing feature
- Crew-specific sharing
- Application coordination
- Share tracking

### Phase 5: Polish & Scale (Weeks 9-10)

- Performance optimization
- Advanced analytics
- Premium crew features
- Enterprise integration

---

## 💡 Unique Features

### 1. **Collective Intelligence**

Jobs are scored based on the entire crew's preferences, not just individuals

### 2. **Availability Matching**

Only suggests jobs when enough crew members are available

### 3. **Reputation System**

Crews build collective reputation based on job completion rates

### 4. **Smart Notifications**

AI determines notification importance based on user behavior

### 5. **Skill Complementarity**

Suggests new members who fill skill gaps in the crew

---

## 🎯 Success Criteria

### User Adoption

- 50% of active users join at least one crew
- Average 2.3 crews per user
- 80% weekly crew engagement

### Business Impact

- 3x job application rate for crew members
- 45% reduction in time-to-hire
- 60% improvement in job completion rates
- 25% increase in user retention

### Technical Performance

- <100ms Tailboard load time
- Real-time message delivery
- 99.9% uptime
- <2% crash rate

---

## 🔐 Privacy & Security

### Data Protection

- End-to-end encryption for direct messages
- Crew data isolation
- Member permission levels
- GDPR compliance

### Safety Features

- Report inappropriate behavior
- Block members
- Leave crew instantly
- Data export/deletion

---

## 💰 Monetization Opportunities

### Premium Crew Features ($9.99/month)

- Unlimited crew size (free: max 10)
- Advanced analytics dashboard
- Priority job notifications
- Custom crew branding
- Video messaging
- Certification verification

### Enterprise Integration ($99/month)

- Direct contractor requests
- Bulk crew hiring
- Dedicated support
- API access
- Compliance tools

---

## 🎨 UI/UX Principles

### Design Philosophy

- **Mobile-first**: Optimized for field use
- **Offline-capable**: Essential features work without connection
- **Glanceable**: Key info visible immediately
- **Thumb-friendly**: One-handed operation
- **High contrast**: Readable in sunlight

### Visual Hierarchy

1. Jobs requiring immediate action
2. Unread messages
3. Crew activity
4. Suggestions
5. Historical data

---

## 📱 Platform Support

### Mobile (Priority)

- iOS 13+
- Android 8+
- React Native / Flutter
- Offline sync
- Push notifications

### Web (Secondary)

- Progressive Web App
- Desktop notifications
- Responsive design
- Keyboard shortcuts

---

## 🚧 Risk Mitigation

### Technical Risks

- **Scale**: Microservices architecture
- **Real-time**: WebSocket fallbacks
- **Offline**: Local data caching
- **Performance**: CDN and edge computing

### Business Risks

- **Adoption**: Gradual rollout with feedback
- **Complexity**: Progressive disclosure
- **Competition**: Unique crew features
- **Retention**: Gamification elements

---

## 📈 Roadmap

### Q1 2024: Foundation

- Core crew functionality
- Basic Tailboard
- Job sharing integration

### Q2 2024: Intelligence

- AI matching
- Advanced filtering
- Messaging system

### Q3 2024: Growth

- Marketing push
- Premium features
- Enterprise pilots

### Q4 2024: Scale

- International expansion
- API platform
- Third-party integrations

---

## ✅ Definition of Done

### Feature Complete When

- All user stories implemented
- 90% test coverage
- Performance benchmarks met
- Accessibility standards passed
- Documentation complete
- Analytics tracking active
- A/B tests configured
- Rollback plan tested

---

This Crews Epic transforms job sharing from a standalone feature into part of a comprehensive collaboration platform that fundamentally changes how journeymen work together. The integration creates powerful network effects that will drive both user growth and engagement.

---

## Crews Integration & Wireframe Design

## Navigation Architecture & Screen Layouts

---

## 🎯 Architecture Recommendation

### **Recommended Approach: Dedicated Crews Tab with Tailboard as Main Screen**

The Crews feature should have **its own dedicated tab** in the bottom navigation, with the Tailboard serving as the main entry point. This gives it the prominence it deserves while maintaining clean integration with existing features.

---

## 📱 Navigation Structure

```dart
Bottom Navigation Bar (Updated)
┌────────────────────────────────────────┐
│  🏠      ⚡     👥     💬      🔔    │
│ Home    Jobs   Crews  Messages  More   │
└────────────────────────────────────────┘
         ↓        ↓NEW↓      ↓
    [Existing] [Tailboard] [Updated]
```

### Why Separate Tab?

- **Prominence**: Crews is a major feature requiring dedicated space
- **Context**: Users need to mentally switch to "crew mode"
- **Complexity**: Too much for a home screen widget
- **Engagement**: Dedicated tab increases feature discovery

---

## 🎨 Tailboard Wireframe (Main Crews Screen)

```dart
┌─────────────────────────────────────┐
│        Status Bar (System)          │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │      CREW SELECTOR HEADER       │ │
│ │  ┌───┐ Highway Heroes  ▼   ⚙️  │ │
│ │  │Logo│ 12 members • 3 online   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │      QUICK ACTIONS BAR          │ │
│ │ [📢 Post] [👥 Invite] [🔍 Find] │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │        TAB SELECTOR             │ │
│ │ Feed | Jobs | Chat | Members    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ╔═══════════════════════════════════╗
│ ║     CONTENT AREA (Scrollable)     ║ │
│ ║                                   ║ │
│ ║  [Tab Content - See Below]        ║ │
│ ║                                   ║ │
│ ║                                   ║ │
│ ║                                   ║ │
│ ║                                   ║ │
│ ╚═══════════════════════════════════╝
│                                     │
│ ┌─────────────────────────────────┐ │
│ │      BOTTOM NAVIGATION          │ │
│ │  Home  Jobs  Crews  Msgs  More  │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 📊 Tailboard Tab Contents

### Tab 1: Feed (Default View)

```dart
┌─────────────────────────────────────┐
│ ┌─── Activity Card ───────────────┐ │
│ │ 👤 Mike shared a job • 2m ago   │ │
│ │ "Perfect for our crew!"         │ │
│ │ ┌─────────────────────────┐    │ │
│ │ │ Journeyman Lineman      │    │ │
│ │ │ Duke Energy • $48/hr     │    │ │
│ │ │ [View] [Share] [Apply]   │    │ │
│ │ └─────────────────────────┘    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─── Announcement Card ──────────┐ │
│ │ 📢 Crew Announcement           │ │
│ │ "Storm work in FL next week.   │ │
│ │  Who's available?"              │ │
│ │ 👍 5  💬 3  • John (Foreman)   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─── Status Update ──────────────┐ │
│ │ ✅ 3 members applied to         │ │
│ │    Charlotte substation job     │ │
│ │ [See Details]                   │ │
│ └─────────────────────────────────┘ │
```

### Tab 2: Jobs (Smart Suggestions)

```dart
┌─────────────────────────────────────┐
│ ┌─── Filter Bar ─────────────────┐ │
│ │ 📍 Within 50mi  💰 $45+/hr  ▼ │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─── Match Score Card ───────────┐ │
│ │        95% CREW MATCH          │ │
│ │ ⚡ Journeyman Lineman          │ │
│ │ 🏢 Duke Energy                 │ │
│ │ 📍 Charlotte, NC (32 mi)       │ │
│ │ 💰 $52/hr + $150 per diem      │ │
│ │ ⏱️ 3-6 months                  │ │
│ │                                │ │
│ │ Why this matches:              │ │
│ │ • 4 crew members qualified     │ │
│ │ • Near John & Mikes location  │ │
│ │ • Matches crew rate minimum    │ │
│ │                                │ │
│ │ [Share to Crew] [Quick Apply]  │ │
│ └─────────────────────────────────┘ │
```

### Tab 3: Chat (Crew Messaging)

```dart
┌─────────────────────────────────────┐
│ ┌─── Message Thread ─────────────┐ │
│ │ 👥 Crew Chat (12 members)      │ │
│ │ ────────────────────────────   │ │
│ │ Mike: Anyone available for     │ │
│ │       the storm work?          │ │
│ │                                │ │
│ │ John: Im in. When do we       │ │
│ │       roll out?                │ │
│ │                                │ │
│ │ Sarah: Count me in too 💪      │ │
│ │                                │ │
│ │ [Type message...]      [Send]  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─── Direct Messages ────────────┐ │
│ │ 💬 Recent Conversations        │ │
│ │ ─────────────────────────     │ │
│ │ 👤 John (Foreman) • 2m        │ │
│ │    "Check out that job..."     │ │
│ │ 👤 Mike • 1h                   │ │
│ │    "Thanks for the referral"   │ │
│ └─────────────────────────────────┘ │
```

### Tab 4: Members

```dart
┌─────────────────────────────────────┐
│ ┌─── Crew Stats ─────────────────┐ │
│ │ 12 Total Members               │ │
│ │ 3 Online Now • 8 Available     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─── Member List ────────────────┐ │
│ │ 👤 John Smith          Foreman │ │
│ │    ⚡ Journeyman • 15 yrs exp  │ │
│ │    📍 Charlotte • 🟢 Available │ │
│ │    [Message] [View Profile]    │ │
│ │ ─────────────────────────────  │ │
│ │ 👤 Mike Johnson          Lead  │ │
│ │    ⚡ Journeyman • 10 yrs exp  │ │
│ │    📍 Raleigh • 🟢 Available   │ │
│ │    [Message] [View Profile]    │ │
│ └─────────────────────────────────┘ │
```

---

## 🔗 Integration Points with Existing Features

### 1. **Home Screen Integration**

```dart
Home Screen Modifications:
┌─────────────────────────────────────┐
│ Welcome back, User!                 │
│                                     │
│ ┌─── NEW: Active Crews Widget ───┐ │
│ │ Your Crews (3)                 │ │
│ │ • Highway Heroes - 2 new jobs  │ │
│ │ • Storm Chasers - 5 messages   │ │
│ │ • Local 58 Crew - Meeting 3pm  │ │
│ │ [Go to Crews →]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Rest of existing home content...]  │
```

### 2. **Jobs Screen Integration**

```dart
Job Details Screen Addition:
┌─────────────────────────────────────┐
│ [Existing job details...]           │
│                                     │
│ ┌─── NEW: Share to Crews ────────┐ │
│ │ Share this job with your crews: │ │
│ │ ☑️ Highway Heroes (12 members)  │ │
│ │ ☑️ Storm Chasers (8 members)    │ │
│ │ ☐ Local 58 Crew (15 members)   │ │
│ │ [Share to Selected Crews]       │ │
│ └─────────────────────────────────┘ │
```

### 3. **Messages Integration**

```dart
Messages Screen Update:
┌─────────────────────────────────────┐
│ Messages                            │
│ ┌─── Tab Bar ────────────────────┐ │
│ │  All  |  Direct  |  Crews      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Existing messages + crew chats]    │
```

### 4. **Notifications Integration**

```dart
Notification Types:
• "Mike invited you to join Highway Heroes"
• "New job matches your crew preferences"
• "3 crew members applied to your shared job"
• "@John mentioned you in crew chat"
```

---

## 📲 User Flow: First Time Experience

```dart
1. Home Screen
   ↓
   "Join or Create a Crew" banner
   ↓
2. Crews Tab (Empty State)
   ┌─────────────────────────────────┐
   │      👥 No Crews Yet            │
   │                                 │
   │   Join a crew to collaborate   │
   │   with other journeymen        │
   │                                 │
   │   [Create a Crew]               │
   │   [Browse Public Crews]         │
   │   [Enter Invite Code]           │
   └─────────────────────────────────┘
   ↓
3. Create/Join Flow
   ↓
4. Tailboard (Active)
```

---

## 🎨 Component Library

### Reusable Components

```dart
// 1. CrewSelector (Header)
CrewSelector(
  currentCrew: selectedCrew,
  crews: userCrews,
  onCrewChange: (crew) => switchCrew(crew),
  onSettings: () => navigateToSettings(),
)

// 2. CrewMemberAvatar
CrewMemberAvatar(
  member: member,
  showOnlineStatus: true,
  size: AvatarSize.small,
  onTap: () => openProfile(member),
)

// 3. JobMatchCard
JobMatchCard(
  job: job,
  matchScore: 95,
  matchReasons: ['4 members qualified', 'Near crew location'],
  onShare: () => shareToCrews(job),
  onApply: () => quickApply(job),
)

// 4. CrewActivityItem
CrewActivityItem(
  actor: member,
  action: ActivityType.sharedJob,
  target: job,
  timestamp: DateTime.now(),
  onReact: () => addReaction(),
)

// 5. TailboardPost
TailboardPost(
  author: member,
  content: 'Storm work available!',
  attachments: [],
  reactions: reactions,
  comments: comments,
  isPinned: true,
)
```

---

## 🏗️ Technical Implementation

### Navigation Changes

```dart
// Bottom Navigation Update
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icons.home, label: 'Home'),
    BottomNavigationBarItem(icon: Icons.bolt, label: 'Jobs'),
    BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(Icons.groups),
          if (hasUnreadActivity)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text('3', style: TextStyle(fontSize: 10)),
              ),
            ),
        ],
      ),
      label: 'Crews',
    ),
    BottomNavigationBarItem(icon: Icons.message, label: 'Messages'),
    BottomNavigationBarItem(icon: Icons.more, label: 'More'),
  ],
)
```

### State Management

```dart
// Crews Provider
class CrewsProvider extends ChangeNotifier {
  Crew? selectedCrew;
  List<Crew> userCrews = [];
  TailboardData? currentTailboard;
  
  void switchCrew(Crew crew) {
    selectedCrew = crew;
    loadTailboard(crew.id);
    notifyListeners();
  }
  
  Stream<TailboardData> getTailboardStream() {
    return FirebaseFirestore.instance
      .collection('tailboards')
      .doc(selectedCrew?.id)
      .snapshots()
      .map((doc) => TailboardData.fromFirestore(doc));
  }
}
```

---

## 📱 Responsive Design Breakpoints

### Phone (Primary)

- Tailboard: Single column
- Member list: Full width cards
- Job cards: Stack vertically

### Tablet (Secondary)

- Tailboard: Two column grid
- Member list: Grid view
- Job cards: Side by side

### Landscape Orientation

- Hide crew selector
- Maximize content area
- Side navigation drawer

---

## 🎯 Entry Points Summary

1. **Primary**: Dedicated Crews tab → Tailboard
2. **Home Widget**: Quick access to active crews
3. **Job Sharing**: Share from job details
4. **Notifications**: Deep link to specific crew/content
5. **Messages**: Crew chats in messages tab

This architecture provides clear separation while maintaining seamless integration with existing features. The Tailboard becomes the command center for all crew activities, making it the natural home for the Crews epic.
