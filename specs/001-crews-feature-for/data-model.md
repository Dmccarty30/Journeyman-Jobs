# Crews Feature - Data Models

## Core Entities

### Crew

Primary entity representing a group of journeymen working together.

```dart
class Crew {
  final String id;                    // Firebase auto-generated ID
  final String name;                   // User-defined crew name
  final String? logoUrl;               // Optional crew logo URL
  final String foremanId;              // User ID of crew creator/leader
  final List<String> memberIds;        // List of all member user IDs
  final CrewPreferences preferences;   // Crew-wide preferences
  final DateTime createdAt;            // Timestamp of creation
  final Map<String, MemberRole> roles; // Member ID to role mapping
  final CrewStats stats;               // Aggregated statistics
  final bool isActive;                 // Soft delete flag

  // Computed properties
  int get memberCount => memberIds.length;
  bool get canOperate => memberCount >= 2;
}

enum MemberRole {
  foreman,  // Full admin rights
  lead,     // Can invite members, share jobs
  member    // Basic member rights
}
```

### CrewPreferences

Collective preferences for job matching and filtering.

```dart
class CrewPreferences {
  final List<JobType> jobTypes;        // Accepted job classifications
  final double minHourlyRate;          // Minimum acceptable rate
  final int maxDistanceMiles;          // Maximum travel distance
  final List<String> preferredCompanies; // Preferred contractors
  final List<String> requiredSkills;   // Must-have certifications
  final WorkSchedule availability;     // Crew availability windows
  final bool autoShareEnabled;         // Auto-share matching jobs
  final int matchThreshold;            // Min match % for notifications (0-100)
}

enum JobType {
  insideWireman,
  journeymanLineman,
  treeTrimmer,
  equipmentOperator,
  insideJourneymanElectrician
}

class WorkSchedule {
  final List<DayAvailability> weeklySchedule;
  final DateTime? blackoutStart;       // Vacation/unavailable start
  final DateTime? blackoutEnd;         // Vacation/unavailable end
}
```

### CrewMember

Junction entity with member-specific crew data.

```dart
class CrewMember {
  final String userId;                 // Reference to User
  final String crewId;                 // Reference to Crew
  final MemberRole role;               // Member's role in crew
  final DateTime joinedAt;             // When member joined
  final MemberPermissions permissions; // Granular permissions
  final bool isAvailable;              // Current availability status
  final String? customTitle;           // Optional role title
  final DateTime lastActive;           // Last interaction timestamp
}

class MemberPermissions {
  final bool canInviteMembers;
  final bool canRemoveMembers;
  final bool canShareJobs;
  final bool canPostAnnouncements;
  final bool canEditCrewInfo;
  final bool canViewAnalytics;
}
```

### Tailboard

Central hub for crew activity and information.

```dart
class Tailboard {
  final String crewId;
  final List<SuggestedJob> jobFeed;    // AI-matched jobs
  final List<ActivityItem> activityStream; // Recent crew activities
  final List<TailboardPost> posts;     // Announcements and discussions
  final List<Message> recentMessages;  // Latest message previews
  final CrewCalendar calendar;         // Shared availability
  final TailboardAnalytics analytics;  // Performance metrics
  final DateTime lastUpdated;          // For sync optimization
}

class SuggestedJob {
  final String jobId;                  // Reference to Job entity
  final int matchScore;                // 0-100 match percentage
  final List<String> matchReasons;     // Why this job matches
  final List<String> viewedByMemberIds; // Who has seen it
  final List<String> appliedMemberIds; // Who has applied
  final DateTime suggestedAt;          // When suggested
  final JobSuggestionSource source;    // How it was found
}

enum JobSuggestionSource {
  aiMatch,        // AI algorithm suggestion
  memberShare,    // Shared by crew member
  autoShare,      // Auto-shared based on criteria
  savedSearch     // From saved search alert
}

class ActivityItem {
  final String id;
  final String actorId;                // User who performed action
  final ActivityType type;             // Type of activity
  final Map<String, dynamic> data;     // Activity-specific data
  final DateTime timestamp;             // When it happened
  final List<String> readByMemberIds;  // Who has seen it
}

enum ActivityType {
  memberJoined,
  memberLeft,
  jobShared,
  jobApplied,
  announcementPosted,
  milestoneReached
}

class TailboardPost {
  final String id;
  final String authorId;               // Who posted
  final String content;                // Post text
  final List<String> attachmentUrls;   // Images, documents
  final bool isPinned;                 // Sticky post
  final Map<String, ReactionType> reactions; // Member reactions
  final List<Comment> comments;        // Threaded comments
  final DateTime postedAt;
  final DateTime? editedAt;            // If edited
}
```

### Messaging

Real-time communication within crews.

```dart
class Message {
  final String id;
  final String senderId;               // Who sent the message
  final String? recipientId;           // For DMs, null for crew messages
  final String? crewId;                // For crew messages
  final String content;                // Message text
  final MessageType type;              // Type of message
  final List<Attachment>? attachments; // Files, images, voice notes
  final DateTime sentAt;                // Timestamp
  final Map<String, DateTime> readBy;  // Read receipts
  final bool isEdited;                 // If message was edited
  final DateTime? editedAt;            // When edited
}

enum MessageType {
  text,
  image,
  voice,
  document,
  jobShare,
  systemNotification
}

class Attachment {
  final String url;                    // Firebase Storage URL
  final String filename;               // Original filename
  final AttachmentType type;           // Type of attachment
  final int sizeBytes;                 // File size
  final String? thumbnailUrl;          // For images/videos
}

enum AttachmentType {
  image,
  document,
  voiceNote,
  video,
  certification
}
```

### CrewStats

Aggregated metrics for crew performance.

```dart
class CrewStats {
  final int totalJobsShared;           // All-time jobs shared
  final int totalApplications;         // All-time applications
  final double applicationRate;        // Applications per shared job
  final double averageMatchScore;      // Average AI match score
  final int successfulPlacements;      // Jobs won by crew
  final double responseTime;           // Avg time to apply
  final Map<JobType, int> jobTypeBreakdown; // Applications by type
  final DateTime lastActivityAt;       // Last crew activity
}
```

## Relationships

### Entity Relationships

```db
User (existing)
  ↓ 1:N
CrewMember
  ↓ N:1
Crew
  ↓ 1:1
Tailboard
  ↓ 1:N
[SuggestedJobs, ActivityItems, Posts]

Job (existing)
  ↓ N:N (through SuggestedJob)
Crew

Message
  ↓ N:1
Crew (for group messages)
  OR
  ↓ 1:1
User (for direct messages)
```

## Validation Rules

### Crew Creation

- Name: Required, 3-50 characters
- At least 1 member (foreman) to create
- At least 2 members to become active
- Maximum 50 members per crew (free tier)

### Member Management

- Foreman cannot leave unless role transferred
- Last member leaving deletes crew
- Duplicate members not allowed

### Messaging

- Content: Required, max 5000 characters
- Attachments: Max 10 per message, 25MB each
- Voice notes: Max 5 minutes duration

### Job Matching

- Match score: Calculated from:
  - Location fit (30%)
  - Rate match (25%)
  - Skills match (25%)
  - Availability (20%)

## State Transitions

### Crew Lifecycle

```
Created → Active (2+ members) → Inactive (< 2 members) → Deleted
```

### Member Status

```
Invited → Pending → Active → Inactive → Removed
```

### Message Status

```
Composing → Sent → Delivered → Read
```

## Firebase Collection Structure

```
/crews/{crewId}
  - Core crew document

/crews/{crewId}/members/{userId}
  - Member-specific data

/crews/{crewId}/tailboard/activity/{activityId}
  - Activity feed items

/crews/{crewId}/tailboard/posts/{postId}
  - Tailboard announcements

/messages/{messageId}
  - All messages (crew and DM)
  - Indexed by crewId and participants

/users/{userId}/crews/{crewId}
  - User's crew memberships (denormalized)
```
