import 'package:cloud_firestore/cloud_firestore.dart';

enum JobSuggestionSource {
  aiMatch,        // AI algorithm suggestion
  memberShare,    // Shared by crew member
  autoShare,      // Auto-shared based on criteria
  savedSearch     // From saved search alert
}

enum ActivityType {
  memberJoined,
  memberLeft,
  jobShared,
  jobApplied,
  announcementPosted,
  milestoneReached
}

enum ReactionType {
  like,
  love,
  celebrate,
  thumbsUp,
  thumbsDown
}

class SuggestedJob {
  final String jobId;                  // Reference to Job entity
  final int matchScore;                // 0-100 match percentage
  final List<String> matchReasons;     // Why this job matches
  final List<String> viewedByMemberIds; // Who has seen it
  final List<String> appliedMemberIds; // Who has applied
  final List<String> savedByMemberIds; // Who has saved it
  final DateTime suggestedAt;          // When suggested
  final JobSuggestionSource source;    // How it was found

  SuggestedJob({
    required this.jobId,
    required this.matchScore,
    required this.matchReasons,
    required this.viewedByMemberIds,
    required this.appliedMemberIds,
    required this.savedByMemberIds,
    required this.suggestedAt,
    required this.source,
  });

  factory SuggestedJob.fromMap(Map<String, dynamic> map) {
    return SuggestedJob(
      jobId: map['jobId'] ?? '',
      matchScore: map['matchScore'] ?? 0,
      matchReasons: List<String>.from(map['matchReasons'] ?? []),
      viewedByMemberIds: List<String>.from(map['viewedByMemberIds'] ?? []),
      appliedMemberIds: List<String>.from(map['appliedMemberIds'] ?? []),
      savedByMemberIds: List<String>.from(map['savedByMemberIds'] ?? []),
      suggestedAt: map['suggestedAt'] != null
          ? DateTime.parse(map['suggestedAt'] as String)
          : DateTime.now(),
      source: JobSuggestionSource.values.firstWhere(
        (s) => s.toString().split('.').last == (map['source'] ?? 'aiMatch'),
        orElse: () => JobSuggestionSource.aiMatch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'matchScore': matchScore,
      'matchReasons': matchReasons,
      'viewedByMemberIds': viewedByMemberIds,
      'appliedMemberIds': appliedMemberIds,
      'savedByMemberIds': savedByMemberIds,
      'suggestedAt': suggestedAt.toIso8601String(),
      'source': source.toString().split('.').last,
    };
  }

  SuggestedJob copyWith({
    String? jobId,
    int? matchScore,
    List<String>? matchReasons,
    List<String>? viewedByMemberIds,
    List<String>? appliedMemberIds,
    List<String>? savedByMemberIds,
    DateTime? suggestedAt,
    JobSuggestionSource? source,
  }) {
    return SuggestedJob(
      jobId: jobId ?? this.jobId,
      matchScore: matchScore ?? this.matchScore,
      matchReasons: matchReasons ?? this.matchReasons,
      viewedByMemberIds: viewedByMemberIds ?? this.viewedByMemberIds,
      appliedMemberIds: appliedMemberIds ?? this.appliedMemberIds,
      savedByMemberIds: savedByMemberIds ?? this.savedByMemberIds,
      suggestedAt: suggestedAt ?? this.suggestedAt,
      source: source ?? this.source,
    );
  }

  // Helper method to mark job as viewed by member
  SuggestedJob markAsViewed(String memberId) {
    if (viewedByMemberIds.contains(memberId)) return this;
    
    return copyWith(
      viewedByMemberIds: [...viewedByMemberIds, memberId],
    );
  }

  // Helper method to mark job as applied by member
  SuggestedJob markAsApplied(String memberId) {
    if (appliedMemberIds.contains(memberId)) return this;
    
    return copyWith(
      appliedMemberIds: [...appliedMemberIds, memberId],
    );
  }

  // Helper method to mark job as saved by member
  SuggestedJob markAsSaved(String memberId) {
    if (savedByMemberIds.contains(memberId)) return this;
    
    return copyWith(
      savedByMemberIds: [...savedByMemberIds, memberId],
    );
  }
}

class ActivityItem {
  final String id;
  final String actorId;                // User who performed action
  final ActivityType type;             // Type of activity
  final Map<String, dynamic> data;     // Activity-specific data
  final DateTime timestamp;             // When it happened
  final List<String> readByMemberIds;  // Who has seen it

  ActivityItem({
    required this.id,
    required this.actorId,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.readByMemberIds,
  });

  factory ActivityItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityItem(
      id: doc.id,
      actorId: data['actorId'] ?? '',
      type: ActivityType.values.firstWhere(
        (t) => t.toString().split('.').last == (data['type'] ?? 'memberJoined'),
        orElse: () => ActivityType.memberJoined,
      ),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readByMemberIds: List<String>.from(data['readByMemberIds'] ?? []),
    );
  }

  factory ActivityItem.fromMap(Map<String, dynamic> map) {
    return ActivityItem(
      id: map['id'] ?? '',
      actorId: map['actorId'] ?? '',
      type: ActivityType.values.firstWhere(
        (t) => t.toString().split('.').last == (map['type'] ?? 'memberJoined'),
        orElse: () => ActivityType.memberJoined,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      readByMemberIds: List<String>.from(map['readByMemberIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'actorId': actorId,
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'readByMemberIds': readByMemberIds,
    };
  }

  ActivityItem copyWith({
    String? id,
    String? actorId,
    ActivityType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    List<String>? readByMemberIds,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      readByMemberIds: readByMemberIds ?? this.readByMemberIds,
    );
  }

  // Helper method to mark as read by member
  ActivityItem markAsRead(String memberId) {
    if (readByMemberIds.contains(memberId)) return this;
    
    return copyWith(
      readByMemberIds: [...readByMemberIds, memberId],
    );
  }

  // Helper method to check if member has read this activity
  bool isReadBy(String memberId) {
    return readByMemberIds.contains(memberId);
  }
}

class Comment {
  final String id;
  final String authorId;
  final String content;
  final DateTime postedAt;
  final DateTime? editedAt;

  Comment({
    required this.id,
    required this.authorId,
    required this.content,
    required this.postedAt,
    this.editedAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      content: map['content'] ?? '',
      postedAt: map['postedAt'] != null
          ? DateTime.parse(map['postedAt'] as String)
          : DateTime.now(),
      editedAt: map['editedAt'] != null
          ? DateTime.parse(map['editedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'content': content,
      'postedAt': postedAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? authorId,
    String? content,
    DateTime? postedAt,
    DateTime? editedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      postedAt: postedAt ?? this.postedAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
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

  TailboardPost({
    required this.id,
    required this.authorId,
    required this.content,
    required this.attachmentUrls,
    required this.isPinned,
    required this.reactions,
    required this.comments,
    required this.postedAt,
    this.editedAt,
  });

  factory TailboardPost.fromMap(Map<String, dynamic> map) {
    return TailboardPost(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      content: map['content'] ?? '',
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
      isPinned: map['isPinned'] ?? false,
      reactions: Map<String, ReactionType>.fromEntries(
        (map['reactions'] as Map<String, dynamic>?)?.entries.map(
              (entry) => MapEntry(
                entry.key,
                ReactionType.values.firstWhere(
                  (r) => r.toString().split('.').last == entry.value,
                  orElse: () => ReactionType.like,
                ),
              ),
            ) ??
            {},
      ),
      comments: List<Comment>.from(
        (map['comments'] as List<dynamic>? ?? [])
            .map((item) => Comment.fromMap(item as Map<String, dynamic>)),
      ),
      postedAt: map['postedAt'] != null
          ? DateTime.parse(map['postedAt'] as String)
          : DateTime.now(),
      editedAt: map['editedAt'] != null
          ? DateTime.parse(map['editedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'isPinned': isPinned,
      'reactions': reactions.map(
        (key, value) => MapEntry(key, value.toString().split('.').last),
      ),
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'postedAt': postedAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  TailboardPost copyWith({
    String? id,
    String? authorId,
    String? content,
    List<String>? attachmentUrls,
    bool? isPinned,
    Map<String, ReactionType>? reactions,
    List<Comment>? comments,
    DateTime? postedAt,
    DateTime? editedAt,
  }) {
    return TailboardPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      isPinned: isPinned ?? this.isPinned,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      postedAt: postedAt ?? this.postedAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  // Helper method to add a reaction
  TailboardPost addReaction(String memberId, ReactionType reaction) {
    final updatedReactions = Map<String, ReactionType>.from(reactions);
    updatedReactions[memberId] = reaction;
    
    return copyWith(reactions: updatedReactions);
  }

  // Helper method to remove a reaction
  TailboardPost removeReaction(String memberId) {
    final updatedReactions = Map<String, ReactionType>.from(reactions);
    updatedReactions.remove(memberId);
    
    return copyWith(reactions: updatedReactions);
  }

  // Helper method to add a comment
  TailboardPost addComment(Comment comment) {
    return copyWith(
      comments: [...comments, comment],
    );
  }

  // Helper method to pin/unpin post
  TailboardPost togglePin() {
    return copyWith(isPinned: !isPinned);
  }
}

class CrewCalendar {
  final Map<String, dynamic> events; // Calendar events data
  final DateTime lastUpdated;

  CrewCalendar({
    required this.events,
    required this.lastUpdated,
  });

  factory CrewCalendar.fromMap(Map<String, dynamic> map) {
    return CrewCalendar(
      events: Map<String, dynamic>.from(map['events'] ?? {}),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'events': events,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class TailboardAnalytics {
  final int totalPosts;
  final int totalActivities;
  final int totalSuggestedJobs;
  final double engagementRate;
  final DateTime lastCalculated;

  TailboardAnalytics({
    required this.totalPosts,
    required this.totalActivities,
    required this.totalSuggestedJobs,
    required this.engagementRate,
    required this.lastCalculated,
  });

  factory TailboardAnalytics.fromMap(Map<String, dynamic> map) {
    return TailboardAnalytics(
      totalPosts: map['totalPosts'] ?? 0,
      totalActivities: map['totalActivities'] ?? 0,
      totalSuggestedJobs: map['totalSuggestedJobs'] ?? 0,
      engagementRate: (map['engagementRate'] ?? 0.0).toDouble(),
      lastCalculated: map['lastCalculated'] != null
          ? DateTime.parse(map['lastCalculated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPosts': totalPosts,
      'totalActivities': totalActivities,
      'totalSuggestedJobs': totalSuggestedJobs,
      'engagementRate': engagementRate,
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }
}

class Tailboard {
  final String crewId;
  final List<SuggestedJob> jobFeed;    // AI-matched jobs
  final List<ActivityItem> activityStream; // Recent crew activities
  final List<TailboardPost> posts;     // Announcements and discussions
  final List<String> recentMessages;  // Latest message previews
  final CrewCalendar calendar;         // Shared availability
  final TailboardAnalytics analytics;  // Performance metrics
  final DateTime lastUpdated;          // For sync optimization

  Tailboard({
    required this.crewId,
    required this.jobFeed,
    required this.activityStream,
    required this.posts,
    required this.recentMessages,
    required this.calendar,
    required this.analytics,
    required this.lastUpdated,
  });

  factory Tailboard.fromMap(Map<String, dynamic> map) {
    return Tailboard(
      crewId: map['crewId'] ?? '',
      jobFeed: List<SuggestedJob>.from(
        (map['jobFeed'] as List<dynamic>? ?? [])
            .map((item) => SuggestedJob.fromMap(item as Map<String, dynamic>)),
      ),
      activityStream: List<ActivityItem>.from(
        (map['activityStream'] as List<dynamic>? ?? [])
            .map((item) => ActivityItem.fromMap(item as Map<String, dynamic>)),
      ),
      posts: List<TailboardPost>.from(
        (map['posts'] as List<dynamic>? ?? [])
            .map((item) => TailboardPost.fromMap(item as Map<String, dynamic>)),
      ),
      recentMessages: List<String>.from(map['recentMessages'] ?? []),
      calendar: CrewCalendar.fromMap(map['calendar'] ?? {}),
      analytics: TailboardAnalytics.fromMap(map['analytics'] ?? {}),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'crewId': crewId,
      'jobFeed': jobFeed.map((job) => job.toMap()).toList(),
      'activityStream': activityStream.map((activity) => activity.toFirestore()).toList(),
      'posts': posts.map((post) => post.toMap()).toList(),
      'recentMessages': recentMessages,
      'calendar': calendar.toMap(),
      'analytics': analytics.toMap(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Tailboard copyWith({
    String? crewId,
    List<SuggestedJob>? jobFeed,
    List<ActivityItem>? activityStream,
    List<TailboardPost>? posts,
    List<String>? recentMessages,
    CrewCalendar? calendar,
    TailboardAnalytics? analytics,
    DateTime? lastUpdated,
  }) {
    return Tailboard(
      crewId: crewId ?? this.crewId,
      jobFeed: jobFeed ?? this.jobFeed,
      activityStream: activityStream ?? this.activityStream,
      posts: posts ?? this.posts,
      recentMessages: recentMessages ?? this.recentMessages,
      calendar: calendar ?? this.calendar,
      analytics: analytics ?? this.analytics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
