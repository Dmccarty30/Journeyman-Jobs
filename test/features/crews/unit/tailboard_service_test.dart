import 'package:test/test.dart';
import 'package:journeyman_jobs/features/crews/models/tailboard.dart';

void main() {
  group('Tailboard Model Tests', () {
    test('SuggestedJob should be created with correct properties', () {
      // Arrange
      final suggestedJob = _createTestSuggestedJob();

      // Act & Assert
      expect(suggestedJob.jobId, equals('job-123'));
      expect(suggestedJob.matchScore, equals(85));
      expect(suggestedJob.matchReasons, contains('Good location match'));
      expect(suggestedJob.viewedByMemberIds, isEmpty);
      expect(suggestedJob.appliedMemberIds, isEmpty);
      expect(suggestedJob.source, equals(JobSuggestionSource.aiMatch));
    });

    test('SuggestedJob markAsViewed should add member to viewed list', () {
      // Arrange
      final suggestedJob = _createTestSuggestedJob();
      const memberId = 'member-123';

      // Act
      final updatedJob = suggestedJob.markAsViewed(memberId);

      // Assert
      expect(updatedJob.viewedByMemberIds, contains(memberId));
      expect(updatedJob.viewedByMemberIds.length, equals(1));
    });

    test('SuggestedJob markAsViewed should not duplicate member', () {
      // Arrange
      final suggestedJob = _createTestSuggestedJob();
      const memberId = 'member-123';

      // Act - Mark as viewed twice
      final updatedJob1 = suggestedJob.markAsViewed(memberId);
      final updatedJob2 = updatedJob1.markAsViewed(memberId);

      // Assert
      expect(updatedJob2.viewedByMemberIds.length, equals(1));
      expect(updatedJob2.viewedByMemberIds, contains(memberId));
    });

    test('SuggestedJob markAsApplied should add member to applied list', () {
      // Arrange
      final suggestedJob = _createTestSuggestedJob();
      const memberId = 'member-123';

      // Act
      final updatedJob = suggestedJob.markAsApplied(memberId);

      // Assert
      expect(updatedJob.appliedMemberIds, contains(memberId));
      expect(updatedJob.appliedMemberIds.length, equals(1));
    });

    test('SuggestedJob toMap should convert to map correctly', () {
      // Arrange
      final suggestedJob = _createTestSuggestedJob();

      // Act
      final map = suggestedJob.toMap();

      // Assert
      expect(map, isA<Map<String, dynamic>>());
      expect(map['jobId'], equals('job-123'));
      expect(map['matchScore'], equals(85));
      expect(map['matchReasons'], isA<List>());
      expect(map['viewedByMemberIds'], isA<List>());
      expect(map['appliedMemberIds'], isA<List>());
      expect(map['suggestedAt'], isA<String>());
      expect(map['source'], equals('aiMatch'));
    });

    test('ActivityItem should be created with correct properties', () {
      // Arrange
      final activityItem = _createTestActivityItem();

      // Act & Assert
      expect(activityItem.id, equals('activity-123'));
      expect(activityItem.actorId, equals('actor-123'));
      expect(activityItem.type, equals(ActivityType.jobShared));
      expect(activityItem.data, isA<Map<String, dynamic>>());
      expect(activityItem.timestamp, isA<DateTime>());
      expect(activityItem.readByMemberIds, isEmpty);
    });

    test('ActivityItem markAsRead should add member to read list', () {
      // Arrange
      final activityItem = _createTestActivityItem();
      const memberId = 'member-123';

      // Act
      final updatedActivity = activityItem.markAsRead(memberId);

      // Assert
      expect(updatedActivity.readByMemberIds, contains(memberId));
      expect(updatedActivity.readByMemberIds.length, equals(1));
    });

    test('ActivityItem isReadBy should check if member has read', () {
      // Arrange
      final activityItem = _createTestActivityItem();
      const memberId = 'member-123';

      // Act
      final updatedActivity = activityItem.markAsRead(memberId);

      // Assert
      expect(updatedActivity.isReadBy(memberId), isTrue);
      expect(updatedActivity.isReadBy('other-member'), isFalse);
    });

    test('Comment should be created with correct properties', () {
      // Arrange
      final comment = _createTestComment();

      // Act & Assert
      expect(comment.id, equals('comment-123'));
      expect(comment.authorId, equals('author-123'));
      expect(comment.content, equals('Test comment content'));
      expect(comment.postedAt, isA<DateTime>());
      expect(comment.editedAt, isNull);
    });

    test('Comment copyWith should update properties correctly', () {
      // Arrange
      final comment = _createTestComment();
      const newContent = 'Updated comment content';

      // Act
      final updatedComment = comment.copyWith(
        content: newContent,
        editedAt: DateTime.now(),
      );

      // Assert
      expect(updatedComment.content, equals(newContent));
      expect(updatedComment.editedAt, isA<DateTime>());
      // Other properties should remain unchanged
      expect(updatedComment.id, equals(comment.id));
      expect(updatedComment.authorId, equals(comment.authorId));
    });

    test('TailboardPost should be created with correct properties', () {
      // Arrange
      final post = _createTestTailboardPost();

      // Act & Assert
      expect(post.id, equals('post-123'));
      expect(post.authorId, equals('author-123'));
      expect(post.content, equals('Test post content'));
      expect(post.attachmentUrls, isEmpty);
      expect(post.isPinned, isFalse);
      expect(post.reactions, isA<Map<String, ReactionType>>());
      expect(post.comments, isEmpty);
      expect(post.postedAt, isA<DateTime>());
      expect(post.editedAt, isNull);
    });

    test('TailboardPost addReaction should add member reaction', () {
      // Arrange
      final post = _createTestTailboardPost();
      const memberId = 'member-123';

      // Act
      final updatedPost = post.addReaction(memberId, ReactionType.like);

      // Assert
      expect(updatedPost.reactions.keys, contains(memberId));
      expect(updatedPost.reactions[memberId], equals(ReactionType.like));
    });

    test('TailboardPost removeReaction should remove member reaction', () {
      // Arrange
      final post = _createTestTailboardPost();
      const memberId = 'member-123';
      final postWithReaction = post.addReaction(memberId, ReactionType.like);

      // Act
      final updatedPost = postWithReaction.removeReaction(memberId);

      // Assert
      expect(updatedPost.reactions.keys, isNot(contains(memberId)));
    });

    test('TailboardPost addComment should add comment to post', () {
      // Arrange
      final post = _createTestTailboardPost();
      final comment = _createTestComment();

      // Act
      final updatedPost = post.addComment(comment);

      // Assert
      expect(updatedPost.comments.length, equals(1));
      expect(updatedPost.comments.first, equals(comment));
    });

    test('TailboardPost togglePin should toggle pin status', () {
      // Arrange
      final post = _createTestTailboardPost();

      // Act
      final pinnedPost = post.togglePin();
      final unpinnedPost = pinnedPost.togglePin();

      // Assert
      expect(pinnedPost.isPinned, isTrue);
      expect(unpinnedPost.isPinned, isFalse);
    });

    test('Tailboard should be created with correct properties', () {
      // Arrange
      final tailboard = _createTestTailboard();

      // Act & Assert
      expect(tailboard.crewId, equals('crew-123'));
      expect(tailboard.jobFeed, isA<List<SuggestedJob>>());
      expect(tailboard.activityStream, isA<List<ActivityItem>>());
      expect(tailboard.posts, isA<List<TailboardPost>>());
      expect(tailboard.recentMessages, isA<List<String>>());
      expect(tailboard.calendar, isA<CrewCalendar>());
      expect(tailboard.analytics, isA<TailboardAnalytics>());
      expect(tailboard.lastUpdated, isA<DateTime>());
    });

    test('TailboardAnalytics should calculate metrics correctly', () {
      // Arrange
      final analytics = TailboardAnalytics(
        totalPosts: 10,
        totalActivities: 25,
        totalSuggestedJobs: 15,
        engagementRate: 0.75,
        lastCalculated: DateTime.now(),
      );

      // Act
      final map = analytics.toMap();

      // Assert
      expect(analytics.totalPosts, equals(10));
      expect(analytics.totalActivities, equals(25));
      expect(analytics.totalSuggestedJobs, equals(15));
      expect(analytics.engagementRate, equals(0.75));
      expect(map['totalPosts'], equals(10));
      expect(map['engagementRate'], equals(0.75));
    });

    test('CrewCalendar should handle events correctly', () {
      // Arrange
      final events = {
        '2023-01-01': {'type': 'holiday', 'name': 'New Year'},
        '2023-12-25': {'type': 'holiday', 'name': 'Christmas'},
      };
      final calendar = CrewCalendar(
        events: events,
        lastUpdated: DateTime.now(),
      );

      // Act
      final map = calendar.toMap();

      // Assert
      expect(calendar.events, equals(events));
      expect(map['events'], equals(events));
      expect(map['lastUpdated'], isA<String>());
    });
  });

  group('Tailboard Activity Types Tests', () {
    test('Should handle different activity types correctly', () {
      // Test all activity types
      expect(ActivityType.memberJoined, isA<ActivityType>());
      expect(ActivityType.memberLeft, isA<ActivityType>());
      expect(ActivityType.jobShared, isA<ActivityType>());
      expect(ActivityType.jobApplied, isA<ActivityType>());
      expect(ActivityType.announcementPosted, isA<ActivityType>());
      expect(ActivityType.milestoneReached, isA<ActivityType>());
    });

    test('Should handle different job suggestion sources', () {
      // Test all suggestion sources
      expect(JobSuggestionSource.aiMatch, isA<JobSuggestionSource>());
      expect(JobSuggestionSource.memberShare, isA<JobSuggestionSource>());
      expect(JobSuggestionSource.autoShare, isA<JobSuggestionSource>());
      expect(JobSuggestionSource.savedSearch, isA<JobSuggestionSource>());
    });

    test('Should handle different reaction types', () {
      // Test all reaction types
      expect(ReactionType.like, isA<ReactionType>());
      expect(ReactionType.love, isA<ReactionType>());
      expect(ReactionType.celebrate, isA<ReactionType>());
      expect(ReactionType.thumbsUp, isA<ReactionType>());
      expect(ReactionType.thumbsDown, isA<ReactionType>());
    });
  });

  group('Tailboard Data Integrity Tests', () {
    test('Should maintain data consistency in suggested jobs', () {
      // Arrange
      final suggestedJob = _createTestSuggestedJob();
      const memberId = 'member-123';

      // Act - Mark as viewed and applied
      final viewedJob = suggestedJob.markAsViewed(memberId);
      final appliedJob = viewedJob.markAsApplied(memberId);

      // Assert
      expect(appliedJob.viewedByMemberIds, contains(memberId));
      expect(appliedJob.appliedMemberIds, contains(memberId));
      expect(appliedJob.viewedByMemberIds.length, equals(1));
      expect(appliedJob.appliedMemberIds.length, equals(1));
    });

    test('Should handle empty data gracefully', () {
      // Arrange
      final emptySuggestedJob = SuggestedJob(
        jobId: '',
        matchScore: 0,
        matchReasons: [],
        viewedByMemberIds: [],
        appliedMemberIds: [],
        suggestedAt: DateTime.now(),
        source: JobSuggestionSource.aiMatch,
      );

      final emptyActivityItem = ActivityItem(
        id: '',
        actorId: '',
        type: ActivityType.memberJoined,
        data: {},
        timestamp: DateTime.now(),
        readByMemberIds: [],
      );

      final emptyPost = TailboardPost(
        id: '',
        authorId: '',
        content: '',
        attachmentUrls: [],
        isPinned: false,
        reactions: {},
        comments: [],
        postedAt: DateTime.now(),
      );

      // Act & Assert
      expect(emptySuggestedJob.jobId, equals(''));
      expect(emptyActivityItem.actorId, equals(''));
      expect(emptyPost.content, equals(''));
    });
  });
}

// Helper functions for creating test data
SuggestedJob _createTestSuggestedJob() {
  return SuggestedJob(
    jobId: 'job-123',
    matchScore: 85,
    matchReasons: ['Good location match', 'Skills match'],
    viewedByMemberIds: [],
    appliedMemberIds: [],
    suggestedAt: DateTime.now(),
    source: JobSuggestionSource.aiMatch,
  );
}

ActivityItem _createTestActivityItem() {
  return ActivityItem(
    id: 'activity-123',
    actorId: 'actor-123',
    type: ActivityType.jobShared,
    data: {'jobId': 'job-123', 'jobTitle': 'Electrician Position'},
    timestamp: DateTime.now(),
    readByMemberIds: [],
  );
}

Comment _createTestComment() {
  return Comment(
    id: 'comment-123',
    authorId: 'author-123',
    content: 'Test comment content',
    postedAt: DateTime.now(),
  );
}

TailboardPost _createTestTailboardPost() {
  return TailboardPost(
    id: 'post-123',
    authorId: 'author-123',
    content: 'Test post content',
    attachmentUrls: [],
    isPinned: false,
    reactions: {},
    comments: [],
    postedAt: DateTime.now(),
  );
}

Tailboard _createTestTailboard() {
  return Tailboard(
    crewId: 'crew-123',
    jobFeed: [_createTestSuggestedJob()],
    activityStream: [_createTestActivityItem()],
    posts: [_createTestTailboardPost()],
    recentMessages: ['New message from John', 'Sarah shared a job'],
    calendar: CrewCalendar(
      events: {'2023-12-25': {'type': 'holiday', 'name': 'Christmas'}},
      lastUpdated: DateTime.now(),
    ),
    analytics: TailboardAnalytics(
      totalPosts: 10,
      totalActivities: 25,
      totalSuggestedJobs: 15,
      engagementRate: 0.75,
      lastCalculated: DateTime.now(),
    ),
    lastUpdated: DateTime.now(),
  );
}