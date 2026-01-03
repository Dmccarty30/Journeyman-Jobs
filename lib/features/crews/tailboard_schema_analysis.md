# Crews Feature Analysis & Firestore Schema Design

## 1. Executive Summary

This report details the database schema and architecture for the **Crews** feature in *Journeyman Jobs*. It focuses specifically on the `TailboardScreen` and its four primary tabs: **Feed, Jobs, Chat, and Members**.

The design utilizes a **subcollection-based architecture** within the `crews` top-level collection to ensure scalability, security, and efficient data querying.

---

## 2. Core Schema Structure

### Top-Level Collection: `crews`

The root document for a crew.

* **Path:** `crews/{crewId}`
* **Model:** `Crew`
* **Key Fields:**
* `name`: String
* `foremanId`: String (User ID)
* `memberIds`: Array (For quick membership checks)
* `logoUrl`: String?
* `preferences`: Map (Settings)
* `stats`: Map (Aggregated metrics)
* `isActive`: Boolean

---

## 3. Tab-Specific Schemas

### A. Feed Tab

**Purpose:** Display announcements, discussions, and updates.
**Collection Path:** `crews/{crewId}/posts/{postId}`
**Model:** `TailboardPost`

```json
{
  "authorId": "string (userId)",
  "content": "string",
  "attachmentUrls": ["string"],
  "isPinned": "boolean",
  "postedAt": "timestamp",
  "editedAt": "timestamp?",
  "reactions": {
    "userId1": "reactionType (e.g., 'like')",
    "userId2": "reactionType"
  },
  "comments": [
    {
      "id": "string",
      "authorId": "string",
      "content": "string",
      "postedAt": "timestamp"
    }
  ]
}

```

> **Analysis:**
>
> * **Comments:** Currently stored as an array.
> * *Pros:* Faster read (one read gets post + comments).
> * *Cons:* 1MB document limit. If threads become massive, this should move to a `posts/{postId}/comments` subcollection.
>
>
> * **Reactions:** Map of `userId: type` allows  checks for "Did I react?" and prevents duplicate reactions.
>
>

---

### B. Jobs Tab

**Purpose:** Display AI-suggested jobs and jobs shared by members.

#### Suggested Jobs (AI)

* **Path:** `crews/{crewId}/job_feed/{jobId}`
* **Model:** `SuggestedJob`
* **Schema:**

```json
{
  "jobId": "string",
  "matchScore": "number",
  "suggestedAt": "timestamp",
  "viewedByMemberIds": ["userId"],
  "appliedMemberIds": ["userId"],
  "savedByMemberIds": ["userId"]
}

```

#### Shared Jobs (Manual)

* **Path:** `crews/{crewId}/shared_jobs/{shareId}`
* **Model:** `SharedJob`
* **Schema:**

```json
{
  "jobId": "string",
  "sharedByUserId": "string",
  "comment": "string",
  "sharedAt": "timestamp",
  "shareType": "manual | auto"
}

```

> **Analysis:** Separating `job_feed` and `shared_jobs` is clean but requires merging streams on the client side. `TailboardService` handles the feed, while `JobSharingService` handles shared jobs.

---

### C. Chat Tab

**Purpose:** Real-time communication (Crew Channel + Direct Messages).

* **Crew Channel Path:** `crews/{crewId}/messages/{messageId}`
* **Direct Messages Path:** `messages/{conversationId}/messages/{messageId}`
* **Conversation ID:** `userIdA_userIdB` (lexicographically sorted)
* **Model:** `Message`

```json
{
  "senderId": "string",
  "content": "string",
  "type": "text | image | etc",
  "sentAt": "timestamp",
  "readBy": { "userId": "timestamp" }
}

```

> **Analysis:** Read receipts are stored in a `readBy` map. This is efficient for small crew sizes. Queries should order by `sentAt` descending with a limit (e.g., 50).

---

### D. Members Tab

**Purpose:** Roster management, roles, and status.
**Collection Path:** `crews/{crewId}/members/{userId}`
**Model:** `CrewMember`

```json
{
  "role": "string (foreman | member)",
  "permissions": {
    "canInvite": "boolean",
    "canShareJobs": "boolean"
  },
  "joinedAt": "timestamp",
  "isAvailable": "boolean",
  "lastActive": "timestamp",
  "displayName": "string (cached)",
  "avatarUrl": "string (cached)"
}

```

> **Analysis:**
>
> * **User ID as Doc ID:** Essential for direct lookups without querying.
> * **Data Duplication:** `displayName` and `avatarUrl` are cached to prevent  reads. Requires a Cloud Function for profile sync.
>
>

---

## 4. Ancillary Collections

* **Activity Feed:** `crews/{crewId}/activity/{activityId}`
* Immutable "news ticker" (e.g., "Member Joined").

* **Invitations:** `crews/{crewId}/invitations/{invitationId}`
* Also denormalized to `users/{userId}/invitations` for user-side visibility.

* **Metadata (Singleton):** `crews/{crewId}/tailboard_metadata/main`
* Keeps the main `Crew` doc light by storing heavy stats/calendar events separately.

---

## 5. Summary of Reads & Writes (Optimization)

| Action | Writes | Reads | Notes |
| --- | --- | --- | --- |
| **Load Tailboard** | 0 | 5* | Reads Crew, Metadata, Posts, JobFeed, and Messages. |
| **Post Message** | 1 | 0 | Direct write to messages subcollection. |
| **React to Post** | 1 | 0 | Update `posts/{id}` document. |
| **Share Job** | 2 | 0 | Write to `shared_jobs` + `activity`. |

---

### Conclusion

The proposed schema is well-normalized for Firestore's document-oriented structure, effectively balancing read costs with data accessibility and scalability.
