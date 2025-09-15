# Crews Communication Hub - Data Models

## Core Entities

### Crew
Primary entity representing a group of IBEW electrical workers who travel and work together.

```dart
class Crew {
  final String id;                     // Firebase auto-generated ID
  final String name;                   // User-defined crew name (3-50 chars)
  final String? logoUrl;               // Optional crew logo from Firebase Storage
  final String leaderId;               // User ID of crew creator/leader
  final List<String> memberIds;        // All crew member user IDs (max 10)
  final DateTime createdAt;            // Crew creation timestamp
  final bool isActive;                 // Active status (needs 2+ members)
  final CrewPreferences? preferences;  // Shared work preferences
  final CrewStats stats;              // Performance and activity metrics
  final int memberLimit;               // Max members allowed (10)
  final int activityRetentionDays;     // History retention (30 days)

  // Computed properties
  int get memberCount => memberIds.length;
  bool get canOperate => memberCount >= 2; // Constitutional requirement
  bool get canAcceptMembers => memberCount < memberLimit;
}
```

### CrewMember
Junction entity representing a user's membership and role within a specific crew.

```dart
class CrewMember {
  final String userId;                 // Reference to User
  final String crewId;                 // Reference to Crew
  final CrewRole role;                 // Member's role in crew
  final DateTime joinedAt;             // When member joined crew
  final DateTime lastActive;           // Last app interaction
  final bool isAvailable;              // Current availability status
  final CrewMemberPreferences workPreferences; // Individual crew-specific preferences
  final NotificationSettings notifications; // Crew notification preferences
  final Map<String, dynamic> votingHistory; // Record of crew votes participated

  // Computed properties
  bool get isOnline => DateTime.now().difference(lastActive).inMinutes < 15;
  bool get hasVotingRights => role != CrewRole.invited;
}

enum CrewRole {
  leader,    // Crew creator, full management rights
  member,    // Standard crew member
  invited,   // Pending invitation acceptance
}

class CrewMemberPreferences {
  final List<JobType> preferredJobTypes; // Individual job preferences within crew context
  final double minAcceptableRate;         // Personal minimum rate
  final int maxTravelDistance;           // Personal travel limit
  final List<String> avoidCompanies;     // Companies to avoid
  final Map<String, bool> workSchedule;  // Weekly availability
  final bool autoApplyToCrewJobs;       // Auto-apply when crew shares jobs
}

class NotificationSettings {
  final bool jobShares;               // New job shares to crew
  final bool directMessages;          // Direct messages from crew members
  final bool memberActivity;          // Member joins/leaves
  final bool urgentJobs;              // Storm work and time-sensitive jobs
  final bool voteRequests;            // Crew decision votes
  final String quietHours;            // "22:00-06:00" format
}
```

### JobNotification
Represents jobs shared within a crew with member responses and coordination.

```dart
class JobNotification {
  final String id;                     // Firebase auto-generated ID
  final String jobId;                  // Reference to Job entity
  final String crewId;                 // Reference to Crew
  final String sharedByUserId;         // Who shared the job
  final String? message;               // Optional note from sharer
  final DateTime timestamp;            // When job was shared
  final Map<String, MemberResponse> memberResponses; // Member reactions
  final GroupBidStatus groupBidStatus; // Coordination status
  final bool isPriority;               // Urgent/storm work flag
  final DateTime? expiresAt;           // Job application deadline

  // Analytics
  final int viewCount;                 // How many members viewed
  final int responseCount;             // How many responded
  final List<String> appliedMembers;   // Who actually applied
}

class MemberResponse {
  final String userId;
  final ResponseType type;
  final DateTime timestamp;
  final String? note;                  // Optional response note

  MemberResponse({
    required this.userId,
    required this.type,
    required this.timestamp,
    this.note,
  });
}

enum ResponseType {
  interested,      // Wants to pursue this job
  notInterested,   // Not interested
  applied,         // Already applied individually
  needsMoreInfo,   // Wants additional details
  conditionalYes,  // Interested with conditions
}

enum GroupBidStatus {
  pending,         // Members still responding
  coordinating,    // Planning group application
  submitted,       // Group application sent
  accepted,        // Employer accepted group
  rejected,        // Employer rejected
  individual,      // Members applying individually
}
```

### GroupBid
Represents coordinated crew applications for jobs.

```dart
class GroupBid {
  final String id;                     // Firebase auto-generated ID
  final String crewId;                 // Reference to Crew
  final String jobId;                  // Reference to Job
  final String jobNotificationId;      // Reference to JobNotification
  final List<String> participatingMembers; // Members in group bid
  final Map<String, String> memberRoles; // Proposed roles for each member
  final DateTime submittedAt;          // When bid was submitted
  final GroupBidStatus status;         // Current bid status
  final String? employerResponse;      // Response from employer
  final DateTime? responseDate;        // When employer responded
  final BidTerms terms;                // Negotiated terms
}

class BidTerms {
  final double proposedRate;           // Group rate negotiated
  final DateTime startDate;           // Proposed start date
  final int estimatedDuration;        // Weeks estimated
  final List<String> certificationsCovered; // Required certs crew has
  final String? additionalTerms;       // Special conditions
  final bool housingRequested;         // Need employer housing
  final bool transportationRequested;  // Need travel reimbursement
}
```

### CrewCommunication
Real-time messaging and communication within crews.

```dart
class CrewCommunication {
  final String id;                     // Firebase auto-generated ID
  final String crewId;                 // Reference to Crew
  final String senderId;               // Who sent the message
  final String content;                // Message text content
  final MessageType type;              // Type of message
  final DateTime timestamp;            // When message was sent
  final List<MessageAttachment>? attachments; // Files, images, etc.
  final Map<String, DateTime> readBy;  // Read receipts
  final String? replyToMessageId;      // For threaded conversations
  final bool isPinned;                 // Pinned by crew leader
  final bool isEdited;                 // Message was edited
  final DateTime? editedAt;            // When message was edited

  // Computed properties
  List<String> get unreadByMembers; // Members who haven't read
  bool get hasAttachments => attachments?.isNotEmpty ?? false;
}

enum MessageType {
  text,              // Standard text message
  jobShare,          // Job sharing with details
  announcement,      // Crew leader announcement
  poll,              // Crew vote/poll
  systemNotification, // System-generated message
  coordinationRequest, // Planning group application
  workUpdate,        // Work status updates
}

class MessageAttachment {
  final String id;
  final String fileName;
  final String url;                    // Firebase Storage URL
  final AttachmentType type;
  final int sizeBytes;
  final String? thumbnailUrl;          // For images/videos
  final Map<String, dynamic>? metadata; // File-specific metadata

  MessageAttachment({
    required this.id,
    required this.fileName,
    required this.url,
    required this.type,
    required this.sizeBytes,
    this.thumbnailUrl,
    this.metadata,
  });
}

enum AttachmentType {
  image,
  document,      // PDFs, contracts
  certification, // Cert photos/PDFs
  voiceNote,
  location,      // GPS coordinates
  contact,       // Contact information
}
```

### CrewPreferences
Shared crew-wide preferences for job matching and coordination.

```dart
class CrewPreferences {
  final List<JobType> acceptedJobTypes;    // Types of work crew accepts
  final double minimumCrewRate;            // Crew minimum rate requirement
  final int maxTravelDistanceMiles;        // How far crew will travel
  final List<String> preferredStates;     // Preferred work locations
  final List<String> avoidedStates;       // States to avoid
  final List<String> preferredCompanies;  // Preferred contractors
  final List<String> blacklistedCompanies; // Companies to avoid
  final List<String> requiredCertifications; // Crew must have these certs
  final WorkArrangements workArrangements; // Housing, transportation, etc.
  final SeasonalPreferences seasonalPrefs; // Time-based preferences
  final bool autoShareMatchingJobs;       // Auto-share jobs that match
  final int matchThreshold;               // Minimum match % for auto-share (0-100)

  CrewPreferences({
    required this.acceptedJobTypes,
    required this.minimumCrewRate,
    required this.maxTravelDistanceMiles,
    this.preferredStates = const [],
    this.avoidedStates = const [],
    this.preferredCompanies = const [],
    this.blacklistedCompanies = const [],
    this.requiredCertifications = const [],
    required this.workArrangements,
    required this.seasonalPrefs,
    this.autoShareMatchingJobs = false,
    this.matchThreshold = 80,
  });
}

class WorkArrangements {
  final bool needsHousing;             // Crew needs housing provided
  final bool needsTransportation;      // Crew needs travel paid
  final bool acceptsPerDiem;           // Accepts per diem vs. higher rate
  final int minimumJobDurationWeeks;   // Minimum job length
  final int maximumJobDurationWeeks;   // Maximum job length
  final bool acceptsWeekendWork;       // Available weekends
  final bool acceptsShiftWork;         // Available for shift/night work
}

class SeasonalPreferences {
  final List<String> stormChaseMonths;  // Months available for storm work
  final List<String> avoidWinterStates; // States to avoid in winter
  final bool prefersSummerWork;         // Prefers summer assignments
  final bool availableForHurricaneSeason; // Available May-November
}

enum JobType {
  insideWireman,
  journeymanLineman,
  treeTrimmer,
  equipmentOperator,
  insideJourneymanElectrician,
  stormWork,                          // Emergency restoration
  maintenanceLineman,
  testingTechnician,
}
```

### CrewStats
Analytics and performance metrics for crews.

```dart
class CrewStats {
  final String crewId;
  final int totalJobsShared;           // All-time jobs shared to crew
  final int totalGroupApplications;    // Group applications submitted
  final int successfulGroupHires;      // Jobs won as group
  final double groupSuccessRate;       // % of group applications successful
  final int individualApplications;    // Individual applications by members
  final double averageResponseTime;    // Avg hours to respond to job shares
  final Map<JobType, int> jobTypeBreakdown; // Applications by job type
  final Map<String, int> locationBreakdown; // Applications by state
  final DateTime lastGroupApplication; // Most recent group bid
  final int currentActiveMembers;      // Currently active member count
  final double memberRetentionRate;    // % of members staying >30 days
  final Map<String, dynamic> monthlyMetrics; // Month-over-month trends

  // Performance indicators
  final double communicationScore;     // How active crew communication is
  final double coordinationScore;      // How well crew coordinates applications
  final double jobMatchScore;         // How well shared jobs match preferences
}
```

## Relationships and Constraints

### Entity Relationships
```
User (existing)
  ↓ 1:N (max 5 crews per user)
CrewMember
  ↓ N:1
Crew (max 10 members per crew)
  ↓ 1:N
[JobNotifications, Communications, GroupBids]

Job (existing)
  ↓ N:N (through JobNotification)
Crew

CrewCommunication
  ↓ N:1
Crew

GroupBid
  ↓ N:1
Crew AND Job
```

### Business Rules and Constraints

#### Crew Management
- **Member Limits**: 5 crews per user, 10 members per crew (constitutional requirement)
- **Leadership**: Crew must have exactly 1 leader at all times
- **Minimum Viable Crew**: 2 members required for crew to be active
- **Activity Retention**: Communications and activity history kept for 30 days
- **Inactivity Cleanup**: Members inactive for 45+ days automatically removed

#### Communication Rules
- **Message Retention**: 30 days for standard messages, indefinite for pinned announcements
- **File Sharing**: Max 25MB per attachment, 10 attachments per message
- **Read Receipts**: Required for job-related communications, optional for general chat
- **Moderation**: Crew leader can pin messages, remove inappropriate content

#### Job Sharing and Coordination
- **Response Deadline**: Job notifications expire based on job application deadline
- **Group Bid Requirements**: Minimum 50% of crew members must indicate interest
- **Individual Override**: Members can always apply individually (not regulated by app)
- **Duplicate Jobs**: System prevents sharing same job multiple times to same crew

#### Voting and Decision Making
- **Voting Rights**: All members except "invited" status have voting rights
- **Vote Duration**: 48 hours for standard crew decisions
- **Quorum**: 50% of active members must participate for valid vote
- **Tie Breaker**: Crew leader decides on tied votes
- **Vote Types**: Member removal, preference changes, leadership transfer

### Data Validation Rules

#### Crew Creation
- Name: 3-50 characters, unique within user's crews
- Leader: Must be authenticated user
- Initial member: Creator automatically becomes leader

#### Member Invitations
- Invite methods: email, phone, or username
- Duplicate prevention: Can't invite existing members
- Invitation expiry: 7 days to accept invitation

#### Message Validation
- Content: 1-5000 characters for text messages
- Attachments: Validated file types, scanned for malware
- Frequency: Rate limiting to prevent spam (10 messages/minute)

#### Job Sharing
- Job existence: Must reference valid Job entity
- Duplicate prevention: Same job to same crew within 24 hours
- Access rights: Only crew members can share to crew

### Firebase Collection Structure

```
/crews/{crewId}
  - Main crew document with metadata

/crews/{crewId}/members/{userId}
  - Member-specific crew data and preferences

/crews/{crewId}/jobNotifications/{notificationId}
  - Jobs shared to this crew with responses

/crews/{crewId}/communications/{messageId}
  - Crew messages and announcements

/crews/{crewId}/groupBids/{bidId}
  - Coordinated group applications

/crews/{crewId}/activity/{activityId}
  - Crew activity feed items

/users/{userId}/crewMemberships/{crewId}
  - Denormalized user crew list for quick access

/crewStats/{crewId}
  - Aggregated analytics and performance data
```

### Indexes for Performance

```
// Compound indexes for Firestore queries
crews/{crewId}/jobNotifications:
  - (timestamp, isPriority) // Recent priority jobs first
  - (groupBidStatus, timestamp) // Active bids

crews/{crewId}/communications:
  - (timestamp) // Chronological order
  - (type, timestamp) // Filter by message type
  - (isPinned, timestamp) // Pinned messages first

users/{userId}/crewMemberships:
  - (lastActive) // Active crews first
  - (role, joinedAt) // Leadership roles first
```