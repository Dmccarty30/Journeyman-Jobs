# Firestore Database Schema Analysis - Tailboard/Crews Feature

## Executive Summary

This document provides a comprehensive analysis of the Tailboard screen's data requirements for Firestore implementation. The analysis covers all four tabs (Feed, Jobs, Chat, Members) with detailed schema design, query patterns, and event listener requirements.

---

## Table of Contents

1. [Entity Relationship Diagram](#entity-relationship-diagram)
2. [Collection Architecture](#collection-architecture)
3. [Tab-by-Tab Analysis](#tab-by-tab-analysis)
4. [Index Requirements](#index-requirements)
5. [Security Rules](#security-rules)
6. [Event Listeners & Real-time Updates](#event-listeners--real-time-updates)

---

## Entity Relationship Diagram

```dart
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ROOT COLLECTIONS                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐              │
│  │    crews     │     │    users     │     │   counters   │              │
│  └──────┬───────┘     └──────┬───────┘     └──────┬───────┘              │
│         │                     │                     │                       │
│         ▼                     ▼                     ▼                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         SUBCOLLECTIONS                               │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │  crews/{crewId}                                                      │   │
│  │    ├── members/              (CrewMember documents)                 │   │
│  │    ├── invitations/          (Invitation documents)                 │   │
│  │    ├── posts/                (TailboardPost documents)              │   │
│  │    │    └── {postId}/comments/ (Comment documents)                  │   │
│  │    ├── job_feed/             (SuggestedJob documents)              │   │
│  │    ├── activity/             (ActivityItem documents)              │   │
│  │    ├── channels/             (Channel documents)                   │   │
│  │    │    └── {channelId}/messages/ (Message documents)              │   │
│  │    ├── messages/             (Legacy: Message documents)           │   │
│  │    ├── tailboard_metadata/   (Analytics, calendar data)            │   │
│  │    └── applications/         (Job application tracking)            │   │
│  │                                                                     │   │
│  │  users/{userId}                                                       │   │
│  │    ├── invitations/          (Invitation copies)                   │   │
│  │    ├── crews/                (Crew membership references)          │   │
│  │    └── preferences/          (User preferences)                    │   │
│  │                                                                     │   │
│  │  counters/                                                            │   │
│  │    ├── crews/user_crews/{userId}   (Crew creation limits)          │   │
│  │    ├── invitations/daily/{userId}   (Daily invite limits)          │   │
│  │    ├── invitations/lifetime/{userId} (Lifetime invite limits)      │   │
│  │    └── messages/minute/{userId}_{crewId} (Rate limiting)           │   │
│  │                                                                     │   │
│  │  LEGACY COLLECTIONS (being migrated)                                │   │
│  │  ├── posts/                (Global posts - migrating to crews)     │   │
│  │  ├── messages/             (DM conversations)                     │   │
│  │  └── global_messages/      (Global chat)                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Collection Architecture

### Root Collections

| Collection | Purpose | Access Pattern |
| ------------ | --------- | ---------------- |
| `crews` | Crew/organization documents | Query by memberIds, get by ID |
| `users` | User profile data | Get by ID |
| `counters` | Rate limiting and quotas | Atomic increments |
| `posts` | Legacy feed posts (being migrated) | Query by crewId |
| `messages` | Direct message conversations | Query by participants |
| `abuse_reports` | Content moderation reports | Admin access |
| `global_messages` | Global chat messages | Public stream |

---

## Tab-by-Tab Analysis

### TAB 1: FEED

**Purpose**: Social feed for crew posts, announcements, and discussions.

#### Data Models

- **TailboardPost**

```dart
{
  id: string                    // Auto-generated document ID
  authorId: string              // Reference to users/{userId}
  content: string               // Post text content
  attachmentUrls: string[]      // Firebase Storage URLs
  isPinned: boolean             // Sticky post flag
  reactions: map<userId, reactionType>  // Member reactions
  comments: Comment[]           // Embedded comments (or subcollection)
  postedAt: Timestamp           // Creation timestamp
  editedAt: Timestamp?          // Last edit timestamp
}
```

- **Comment**

```dart
{
  id: string                    // Auto-generated
  authorId: string              // Reference to users/{userId}
  content: string               // Comment text
  postedAt: Timestamp           // Creation time
  editedAt: Timestamp?          // Edit time
}
```

- **PostModel** (Legacy - being migrated)

```dart
{
  crewId: string                // Reference to crews/{crewId}
  authorId: string
  content: string
  mediaUrls: string[]
  likes: string[]               // User IDs who liked
  reactions: map<emoji, count>  // Reaction counts
  userReactions: map<userId, emoji>  // Per-user reactions
  commentCount: number
  isPinned: boolean
  isDeleted: boolean
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

#### Firestore Schema

```dart

Collection: crews/{crewId}/posts
Document ID: Auto-generated

Fields:
  - authorId: string (indexed)
  - content: string
  - attachmentUrls: array<string>
  - isPinned: boolean (indexed for pinned posts query)
  - reactions: map<string, string>  // memberId -> reactionType
  - postedAt: timestamp (indexed, descending)
  - editedAt: timestamp?

Subcollection: posts/{postId}/comments
Document ID: Auto-generated

Fields:
  - authorId: string
  - content: string
  - isDeleted: boolean
  - createdAt: timestamp (indexed, ascending for thread order)
  - updatedAt: timestamp
```

#### Queries

| Operation | Query Pattern | Index Required |
| ----------- | --------------- | ---------------- |
| Get crew posts | `crews/{crewId}/posts.where('postedAt', '>', last).orderBy('postedAt', 'desc').limit(20)` | postedAt (desc) |
| Get pinned posts | `crews/{crewId}/posts.where('isPinned', '==', true)` | isPinned, postedAt |
| Get user's posts | `crews/{crewId}/posts.where('authorId', '==', userId)` | authorId, postedAt |
| Get post comments | `posts/{postId}/comments.orderBy('createdAt', 'asc').limit(50)` | createdAt (asc) |
| Search posts | Uses client-side filtering or Algolia | N/A |

#### Event Listeners

| Event | Trigger | Action |
| ------- | --------- | -------- |
| `onSnapshot(posts)` | New post, reaction, comment | Update UI |
| `onSnapshot(comments/{postId})` | New comment | Update thread |
| `onSnapshot(post/{postId})` | Edit, pin change | Update single post |

#### Write Operations

| Operation | Transaction | Description |
| ----------- | ------------- | ------------- |
| `createPost()` | No | Add document to posts subcollection |
| `updatePost()` | No | Update content, editedAt |
| `togglePinPost()` | No | Update isPinned flag |
| `addReaction()` | **Yes** | Update reactions map, update reaction counts |
| `removeReaction()` | **Yes** | Update reactions map, decrement counts |
| `addComment()` | **Yes** | Add comment + increment commentCount on post |
| `deleteComment()` | **Yes** | Soft delete + decrement commentCount |
| `deletePost()` | No | Soft delete (set isDeleted: true) |

---

### TAB 2: JOBS

**Purpose**: AI-matched job suggestions, job sharing, and application tracking.

#### Data Models2

**Job** (Root entity from jobs feature)

```dart
{
  id: string                    // Auto-generated
  title: string
  description: string
  jobType: string               // Classification
  hourlyRate: number
  location: GeoPoint            // For geolocation queries
  postedAt: Timestamp
  postedByUserId: string
  isActive: boolean
  estimatedDuration: number     // Hours
  requiredSkills: string[]
  companyName: string?
}
```

**SuggestedJob** (Crew-specific job suggestion)

```dart
{
  jobId: string                 // Reference to jobs collection
  matchScore: number            // 0-100, indexed for filtering
  matchReasons: string[]        // Why this job matches
  viewedByMemberIds: string[]   // Track who has seen it
  appliedMemberIds: string[]    // Track who applied
  savedByMemberIds: string[]    // Track who saved
  suggestedAt: Timestamp        // indexed for sorting
  source: enum                  // aiMatch, memberShare, autoShare, savedSearch
}
```

- **SharedJob**

```dart
{
  id: string
  job: Job                      // Embedded job reference
  sharedByUserId: string
  sharedAt: Timestamp
  comment: string?
  matchScore: number
  source: string
}
```

- **ActivityItem**

```dart
{
  id: string                    // Auto-generated
  actorId: string               // Who performed the action
  type: enum                    // memberJoined, jobShared, jobApplied, etc.
  data: map<string, dynamic>    // Activity-specific data
  timestamp: Timestamp          // indexed
  readByMemberIds: string[]     // Track who has seen this activity
}
```

#### Firestore Schema2

```dart
Collection: jobs (root level - shared across app)
Document ID: Auto-generated

Fields:
  - title: string
  - description: string
  - jobType: string (indexed for filtering)
  - hourlyRate: number (indexed for range queries)
  - location: GeoPoint (for geo queries)
  - postedAt: timestamp
  - postedByUserId: string
  - isActive: boolean (indexed)
  - estimatedDuration: number
  - requiredSkills: string[]
  - companyName: string

Collection: crews/{crewId}/job_feed
Document ID: Auto-generated

Fields:
  - jobId: string (indexed - references jobs collection)
  - matchScore: number (indexed - for filtering/sorting)
  - matchReasons: string[]
  - viewedByMemberIds: string[]
  - appliedMemberIds: string[]
  - savedByMemberIds: string[]
  - suggestedAt: timestamp (indexed, descending)
  - source: string (indexed - aiMatch, memberShare, autoShare, savedSearch)

Collection: crews/{crewId}/activity
Document ID: Auto-generated

Fields:
  - actorId: string (indexed)
  - type: string (indexed)
  - data: map
  - timestamp: timestamp (indexed, descending)
  - readByMemberIds: string[]
```

#### Queries2

| Operation | Query Pattern | Index Required |
| ----------- | --------------- | ---------------- |
| Get job feed | `crews/{crewId}/job_feed.orderBy('suggestedAt', 'desc').limit(50)` | suggestedAt (desc) |
| Filter by score | `job_feed.where('matchScore', '>=', threshold)` | matchScore |
| Filter by source | `job_feed.where('source', '==', 'memberShare')` | source |
| Get user activity | `crews/{crewId}/activity.orderBy('timestamp', 'desc').limit(50)` | timestamp (desc) |
| Unread activity | Client filter: `!readByMemberIds.contains(userId)` | N/A |
| Job search | Uses external search service (Algolia) | N/A |
| Geo location | `jobs.where('location', 'near', point)` | location (geo) |

#### Event Listeners2

| Event | Trigger | Action |
| ------- | --------- | -------- |
| `onSnapshot(job_feed)` | New job suggestion, status change | Update job list |
| `onSnapshot(activity)` | New crew activity | Update activity feed |
| `onSnapshot(job/{jobId})` | Job details change | Update job details view |

#### Write Operations2

| Operation | Transaction | Description |
| ----------- | ------------- | ------------- |
| `addSuggestedJob()` | No | Add to job_feed |
| `markJobAsViewed()` | No | Update viewedByMemberIds array |
| `markJobAsApplied()` | No | Update appliedMemberIds array + add activity |
| `markJobAsSaved()` | No | Update savedByMemberIds array |
| `addActivityItem()` | No | Add to activity collection |
| `markActivityAsRead()` | No | Update readByMemberIds |
| `cleanupOldJobs()` | **Yes (batch)** | Delete jobs older than 30 days |

---

### TAB 3: CHAT

**Purpose**: Real-time messaging with channels, direct messages, and read receipts.

#### Data Models3

- **Message**

```dart
{
  id: string                    // Auto-generated
  senderId: string              // Who sent
  recipientId: string?          // For DMs
  crewId: string?               // For crew messages
  content: string               // Message text
  type: enum                    // text, image, voice, document, jobShare, systemNotification
  attachments: Attachment[]     // File metadata
  sentAt: Timestamp             // indexed for sorting
  readBy: map<userId, timestamp> // Individual read receipts
  status: enum                  // sending, sent, delivered, read, failed
  isEdited: boolean
  editedAt: Timestamp?
  deliveredAt: Timestamp?
  readAt: Timestamp?
  deliveredTo: map<userId, timestamp>  // Individual delivery times
  readStatus: map<userId, timestamp>   // Alias for readBy
  readByList: string[]          // List of user IDs who read
}
```

- **Attachment**

```dart
{
  url: string                   // Firebase Storage URL
  filename: string
  type: enum                    // image, document, voiceNote, video, certification, file, audio
  sizeBytes: number
  thumbnailUrl: string?
}
```

- **Channel** (Crew chat channels)

```dart
{
  id: string                    // Document ID = channelId
  name: string                  // Display name
  description: string?
  isDefault: boolean            // Is this the main/general channel
  createdAt: Timestamp
  memberCount: number
}
```

#### Firestore Schema3

```dart
Collection: crews/{crewId}/channels
Document ID: {channelId} (e.g., 'general', 'jobs', 'random')

Fields:
  - name: string
  - description: string
  - isDefault: boolean
  - createdAt: timestamp
  - memberCount: number

Subcollection: channels/{channelId}/messages
Document ID: Auto-generated

Fields:
  - senderId: string (indexed)
  - content: string
  - type: string (indexed - text, image, voice, etc.)
  - attachments: array<object>
  - sentAt: timestamp (indexed, descending)
  - readBy: map<userId, timestamp>
  - status: string (sending, sent, delivered, read, failed)
  - isEdited: boolean
  - editedAt: timestamp?
  - deliveredAt: timestamp?
  - readAt: timestamp?
  - deliveredTo: map<userId, timestamp>
  - readStatus: map<userId, timestamp>
  - readByList: array<string>

Collection: messages (root - for DMs)
Document ID: {conversationId} = sorted(userId1, userId2).join('_')

Fields:
  - participants: array<string> (indexed - [userId1, userId2])
  - lastMessage: map
  - updatedAt: timestamp (indexed)

Subcollection: messages/{conversationId}/messages
Document ID: Auto-generated

Fields: (same as crew channel messages above)

Collection: global_messages (legacy)
Fields: (same as messages above)
```

#### Queries3

| Operation | Query Pattern | Index Required |
| ----------- | --------------- | ---------------- |
| Get channels | `crews/{crewId}/channels.orderBy('createdAt', 'desc')` | createdAt |
| Get channel messages | `channels/{channelId}/messages.orderBy('sentAt', 'desc').limit(50)` | sentAt (desc) |
| Get DM conversations | `messages.where('participants', 'array-contains', userId)` | participants |
| Get DM messages | `messages/{convId}/messages.orderBy('sentAt', 'desc').limit(50)` | sentAt (desc) |
| Pending deliveries | `messages.where('deliveredTo.{userId}', '==', null)` | deliveredTo |
| Unread count | Client filter: `!readBy.containsKey(userId)` | N/A |

#### Event Listeners3

| Event | Trigger | Action |
| ------- | --------- | -------- |
| `onSnapshot(channels/{channelId}/messages)` | New message, status change | Update chat UI |
| `onSnapshot(messages/{convId}/messages)` | New DM | Update DM UI |
| `onSnapshot(message/{messageId})` | Read status change | Update indicators |
| `onSnapshot(messages)` | New conversation | Update conversation list |

#### Write Operations3

| Operation | Transaction | Description |
| ----------- | ------------- | ------------- |
| `sendMessageToChannel()` | **Yes** | Create message + mark as sent |
| `markAsSent()` | No | Update status to sent |
| `markAsDelivered()` | No | Update deliveredTo map |
| `markAsRead()` | **Yes** | Update readBy + check if all read for status |
| `editMessage()` | No | Update content, isEdited, editedAt |
| `deleteMessage()` | No | Soft delete (replace with system notification) |
| `batchDeliverMessages()` | **Yes (batch)** | Mark multiple messages as delivered |
| `batchReadMessages()` | **Yes (batch)** | Mark multiple messages as read |

---

### TAB 4: MEMBERS

**Purpose**: Member roster, roles, permissions, invitations, availability.

#### Data Models4

**Crew** (root crew document)

```dart
{
  id: string                    // Auto-generated or custom
  name: string                  // indexed for search
  logoUrl: string?
  foremanId: string             // Primary admin
  memberIds: string[]           // Array of all member IDs (indexed)
  location: CrewLocation        // GeoPoint + address
  preferences: CrewPreferences  // Job matching settings
  stats: CrewStats              // Performance metrics
  isActive: boolean             // Soft delete flag (indexed)
  createdAt: Timestamp
  updatedAt: Timestamp?
  roles: map<userId, role>      // MemberRole enum (foreman, member)
  memberCount: number           // Denormalized for quick access
  lastActivityAt: Timestamp     // indexed for sorting
}
```

- **CrewMember**

```dart
{
  userId: string                // Document ID = userId
  crewId: string                // Reference to parent crew
  role: enum                    // foreman, member
  joinedAt: Timestamp
  permissions: MemberPermissions // Granular permissions object
  isAvailable: boolean          // Current availability status
  customTitle: string?          // Optional display title
  lastActive: Timestamp         // Last interaction time
  isActive: boolean             // Active member flag
  displayName: string?
  avatarUrl: string?
  classification: string?       // Trade classification
}
```

- **MemberPermissions**

```dart
{
  canInviteMembers: boolean
  canRemoveMembers: boolean
  canShareJobs: boolean
  canPostAnnouncements: boolean
  canEditCrewInfo: boolean
  canViewAnalytics: boolean
}
```

- **Invitation**

```dart
{
  id: string                    // Auto-generated (crewId_userId_timestamp)
  crewId: string
  inviterId: string
  inviteeId: string             // Target user ID (indexed)
  role: enum                    // Role to assign on accept
  message: string?
  status: enum                  // pending, accepted, rejected, cancelled, expired (indexed)
  createdAt: Timestamp
  expiresAt: Timestamp          // indexed for cleanup
  acceptedAt: Timestamp?
  rejectedAt: Timestamp?
}
```

- **CrewLocation**

```dart
{
  geopoint: GeoPoint            // {latitude, longitude}
  address: string?
  city: string?
  state: string?
  zipCode: string?
}
```

- **CrewPreferences**

```dart
{
  jobTypes: string[]            // Preferred job categories
  minHourlyRate: number?
  maxDistanceMiles: number?
  preferredCompanies: string[]
  requiredSkills: string[]
  autoShareEnabled: boolean
  matchThreshold: number        // 0-100 for AI matching
}
```

- **CrewStats**

```dart
{
  totalJobsShared: number
  totalApplications: number
  applicationRate: number
  averageMatchScore: number
  successfulPlacements: number
  responseTime: number          // Average time to apply (hours)
  jobTypeBreakdown: map<type, count>
  lastActivityAt: Timestamp
  matchScores: number[]         // Last 50 scores for rolling avg
  successRate: number
}
```

#### Firestore Schema4

```dart
Collection: crews (root level)
Document ID: {crewId} (custom format: {name}-{count}-{timestamp})

Fields:
  - name: string (indexed)
  - logoUrl: string?
  - foremanId: string
  - memberIds: array<string> (indexed for array-contains queries)
  - location: object {geopoint, address, city, state, zipCode}
  - preferences: object {jobTypes, minHourlyRate, maxDistanceMiles, ...}
  - stats: object {totalJobsShared, totalApplications, ...}
  - isActive: boolean (indexed)
  - createdAt: timestamp
  - updatedAt: timestamp?
  - roles: map<userId, string>  // "foreman" | "member"
  - memberCount: number
  - lastActivityAt: timestamp (indexed, descending)

Subcollection: crews/{crewId}/members
Document ID: {userId}

Fields:
  - crewId: string
  - role: string  // "foreman" | "member"
  - joinedAt: timestamp
  - permissions: object {canInviteMembers, canRemoveMembers, ...}
  - isAvailable: boolean
  - customTitle: string?
  - lastActive: timestamp
  - isActive: boolean
  - displayName: string?
  - avatarUrl: string?
  - classification: string?

Subcollection: crews/{crewId}/invitations
Document ID: {invitationId}

Fields:
  - crewId: string
  - inviterId: string
  - inviteeId: string (indexed)
  - role: string
  - message: string?
  - status: string (indexed - pending, accepted, rejected, cancelled, expired)
  - createdAt: timestamp
  - expiresAt: timestamp (indexed)
  - acceptedAt: timestamp?
  - rejectedAt: timestamp?

Collection: users/{userId}/invitations
Document ID: {invitationId} (mirror of crew invitation)

Fields: (same as crew invitation)

Collection: counters (rate limiting)
Subcollections:
  - crews/user_crews/{userId}: {count: number, lastCreated: timestamp}
  - invitations/daily/{userId}: {count: number, date: string}
  - invitations/lifetime/{userId}: {total: number}
  - messages/minute/{userId}_{crewId}: {count: number, minute: string}
```

#### Queries4

| Operation | Query Pattern | Index Required |
| ----------- | --------------- | ---------------- |
| Get user crews | `crews.where('memberIds', 'array-contains', userId).where('isActive', '==', true)` | memberIds, isActive |
| Get crew members | `crews/{crewId}/members.get()` | N/A (collection fetch) |
| Get member by ID | `crews/{crewId}/members/{userId}.get()` | N/A (direct get) |
| Get pending invitations | `crews/{crewId}/invitations.where('status', '==', 'pending')` | status |
| Get user invitations | `users/{userId}/invitations.where('status', '==', 'pending')` | status |
| Search crews | `crews.where('name', '>=', query).where('name', '<=', query + '\uf8ff')` | name |
| Nearby crews | `crews.where('location.geopoint', 'near', point)` | location (geo) |

#### Event Listeners4

| Event | Trigger | Action |
| ------- | --------- | -------- |
| `onSnapshot(crews)` | Crew list changes | Update crew selector |
| `onSnapshot(members/{crewId})` | Member changes | Update roster |
| `onSnapshot(invitations/{userId})` | New/updated invitations | Update notifications |
| `onSnapshot(crew/{crewId})` | Crew metadata changes | Update crew info |

#### Write Operations4

| Operation | Transaction | Description |
| ----------- | ------------- | ------------- |
| `createCrew()` | **Yes** | Create crew doc + init counters + add foreman as member |
| `updateCrew()` | No | Update crew fields |
| `deleteCrew()` | No | Soft delete (set isActive: false) |
| `inviteMember()` | No | Create invitation in both crew and users collections |
| `acceptInvitation()` | **Yes** | Add to members + update crew arrays + update invitation status |
| `rejectInvitation()` | No | Update invitation status |
| `cancelInvitation()` | No | Update invitation status |
| `removeMember()` | **Yes** | Delete member + update crew arrays |
| `updateMemberRole()` | **Yes** | Update member + update crew roles map |
| `updateCrewStats()` | **Yes** | Update stats atomically |
| `reportAbuse()` | No | Add to abuse_reports collection |

---

## Index Requirements

### Composite Indexes

Create these composite indexes in Firestore:

```dart
// Crew queries
crews
  - memberIds (array-contains), isActive (equals)
  - memberIds (array-contains), lastActivityAt (descending)
  - isActive (equals), name (ascending)

// Posts
crews/{crewId}/posts
  - isPinned (equals), postedAt (descending)
  - authorId (equals), postedAt (descending)

// Job feed
crews/{crewId}/job_feed
  - matchScore (descending), suggestedAt (descending)
  - source (equals), suggestedAt (descending)

// Messages
crews/{crewId}/channels/{channelId}/messages
  - sentAt (descending), senderId (equals)
  - sentAt (descending), type (equals)

// Activity
crews/{crewId}/activity
  - actorId (equals), timestamp (descending)
  - type (equals), timestamp (descending)

// Invitations
crews/{crewId}/invitations
  - inviteeId (equals), status (equals), expiresAt (descending)
users/{userId}/invitations
  - status (equals), expiresAt (descending)

// Messages (DMs)
messages
  - participants (array-contains), updatedAt (descending)

// Jobs
jobs
  - isActive (equals), postedAt (descending)
  - jobType (equals), hourlyRate (descending)
```

### Single Field Indexes

These are auto-created but important to note:

```dart
// Crews
- memberIds (array-contains)
- isActive
- lastActivityAt
- name (for autocomplete)

// All timestamp fields (for sorting)
```

### Geo Queries

```dart
// Crews and Jobs with location
- location: Geopoint fields support 'near' queries with optional radius
```

---

## Security Rules

### Crew Access Rules

```dart
// Helper functions
function isCrewMember(crewId) {
  return exists(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
}

function isCrewForeman(crewId) {
  return get(/databases/$(database)/documents/crews/$(crewId)).data.roles[request.auth.uid] == 'foreman';
}

function hasPermission(crewId, permission) {
  const member = get(/databases/$(database)/documents/crews/$(crewId)/members/$(request.auth.uid));
  return member.data.permissions[permission] == true;
}

// Crew document rules
match /crews/{crewId} {
  allow read: if isCrewMember(crewId);
  allow create: if request.auth != null;
  allow update: if isCrewMember(crewId) && hasPermission(crewId, 'canEditCrewInfo');
  allow delete: if isCrewForeman(crewId);

  // Members subcollection
  match /members/{userId} {
    allow read: if isCrewMember(crewId);
    allow create: if isCrewForeman(crewId);
    allow update: if isCrewForeman(crewId) || request.auth.uid == userId;
    allow delete: if isCrewForeman(crewId);
  }

  // Invitations subcollection
  match /invitations/{inviteId} {
    allow read: if isCrewMember(crewId) || request.auth.uid == resource.data.inviteeId;
    allow create: if isCrewMember(crewId) && hasPermission(crewId, 'canInviteMembers');
    allow update: if request.auth.uid == resource.data.inviteeId || isCrewForeman(crewId);
  }

  // Posts subcollection
  match /posts/{postId} {
    allow read: if isCrewMember(crewId);
    allow create: if isCrewMember(crewId);
    allow update, delete: if request.auth.uid == resource.data.authorId || isCrewForeman(crewId);

    // Comments
    match /comments/{commentId} {
      allow read: if isCrewMember(crewId);
      allow create: if isCrewMember(crewId);
      allow update, delete: if request.auth.uid == resource.data.authorId;
    }
  }

  // Channels and messages
  match /channels/{channelId} {
    allow read: if isCrewMember(crewId);
    allow create: if isCrewForeman(crewId);

    match /messages/{messageId} {
      allow read: if isCrewMember(crewId);
      allow create: if isCrewMember(crewId);
      allow update: if request.auth.uid == resource.data.senderId;
    }
  }

  // Job feed
  match /job_feed/{jobId} {
    allow read: if isCrewMember(crewId);
    allow create: if isCrewMember(crewId) && hasPermission(crewId, 'canShareJobs');
    allow update: if isCrewMember(crewId); // For viewed/saved/applied status
  }

  // Activity
  match /activity/{activityId} {
    allow read: if isCrewMember(crewId);
    allow create: if request.auth != null; // System can create
    allow update: if request.auth.uid == resource.data.actorId;
  }
}

// User-specific collections
match /users/{userId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId;

  match /invitations/{inviteId} {
    allow read, write: if request.auth.uid == userId;
  }

  match /crews/{crewId} {
    allow read: if request.auth.uid == userId;
  }
}

// Counters (service account only)
match /counters/{document=**} {
  allow read, write: if false; // Access via Cloud Functions only
}

// Abuse reports (admin only)
match /abuse_reports/{reportId} {
  allow create: if request.auth != null;
  allow read, update: if exists(/databases/$(database)/documents/admins/$(request.auth.uid));
}
```

---

## Event Listeners & Real-time Updates

### Summary of Real-time Streams

| Feature | Collection | Listener Type | Update Frequency |
| --------- | ------------ | --------------- | ----------------- |
| Crew list | `crews` | `onSnapshot` | Medium (on join/leave) |
| Crew posts | `crews/{crewId}/posts` | `onSnapshot` | High (user activity) |
| Post comments | `posts/{postId}/comments` | `onSnapshot` | High (user activity) |
| Job feed | `crews/{crewId}/job_feed` | `onSnapshot` | Medium (periodic updates) |
| Activity | `crews/{crewId}/activity` | `onSnapshot` | High (various actions) |
| Channels | `crews/{crewId}/channels` | `onSnapshot` | Low (rarely changes) |
| Messages | `channels/{id}/messages` | `onSnapshot` | Very High (chat) |
| Members | `crews/{crewId}/members` | `onSnapshot` | Medium (on join/leave) |
| Invitations | `users/{userId}/invitations` | `onSnapshot` | Low (on invite) |

### Listener Lifecycle

**Feed Tab:**

1. On tab enter: Listen to `posts` with limit 20
2. On scroll: Update query with `startAfter` last document
3. On post detail: Listen to specific `comments` subcollection
4. On tab exit: Cancel listeners

**Jobs Tab:**

1. On tab enter: Listen to `job_feed` with limit 50
2. On filter change: Update query with new where clauses
3. On job select: Listen to specific job document
4. Periodic: Cloud Functions add new AI-matched jobs

**Chat Tab:**

1. On tab enter: Listen to `channels` then active channel's `messages`
2. On message send: Optimistic UI + wait for server confirmation
3. On message read: Batch update read status for unread messages
4. On tab exit: Cancel message listeners, keep channel list

**Members Tab:**

1. On tab enter: Listen to `members` collection
2. On member select: Listen to specific member document
3. On invitation: Listen to user's `invitations` subcollection
4. On tab exit: Cancel listeners

### Offline Support

All collections should be cached locally using:

- `enablePersistence()` for automatic caching
- Offline queue for writes when connection lost
- `pendingWrites` status indicator in UI

---

## Data Migration Notes

### Legacy Collections to Migrate

| Old Collection | New Location | Migration Strategy |
 | ---------------- | -------------- | ------------------- |
| `posts` (root) | `crews/{crewId}/posts` | Copy + verify + delete old |
| `messages` (root) | `crews/{crewId}/messages` or `channels/{id}/messages` | Create channels + migrate |
| `user_reactions` | Embedded in posts | Merge into post documents |

---

## Performance Optimization Recommendations

1. **Pagination**: Always use cursor-based pagination with `startAfter`
2. **Limit results**: Default to 20-50 items per query
3. **Denormalize counts**: Store commentCount, memberCount, etc.
4. **Batch writes**: Use batched writes for bulk operations
5. **Cloud Functions**: Move complex aggregations to server-side
6. **CDN caching**: Cache static crew data (logo, name)
7. **Partial loading**: Load heavy data (attachments) on demand

---

## Appendix: Enum Definitions

```dart
// Member roles
enum MemberRole { foreman, member }

// Message types
enum MessageType { text, image, voice, document, jobShare, systemNotification }

// Message status
enum MessageStatus { sending, sent, delivered, read, failed }

// Attachment types
enum AttachmentType { image, document, voiceNote, video, certification, file, audio }

// Reaction types
enum ReactionType { like, love, celebrate, thumbsUp, thumbsDown }

// Job suggestion source
enum JobSuggestionSource { aiMatch, memberShare, autoShare, savedSearch }

// Activity types
enum ActivityType { memberJoined, memberLeft, jobShared, jobApplied, announcementPosted, milestoneReached }

// Invitation status
enum InvitationStatus { pending, accepted, rejected, cancelled, expired }

// Permissions
enum Permission {
  createCrew, updateCrew, deleteCrew,
  inviteMember, removeMember, updateRole,
  shareJob, moderateContent, viewStats, manageSettings
}
```

---

*Generated: 2025*
*Analysis Scope: Tailboard Screen - Crews Feature*
*Document Version: 1.0*
