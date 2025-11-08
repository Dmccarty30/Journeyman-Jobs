import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../models/tailboard.dart';
import '../services/tailboard_service.dart';

part 'tailboard_riverpod_provider.g.dart';

/// TailboardService provider
@riverpod
TailboardService tailboardService(Ref ref) => TailboardService();

/// Stream of tailboard data for a specific crew
@riverpod
Stream<Tailboard?> tailboardStream(Ref ref, String crewId) {
  final tailboardService = ref.watch(tailboardServiceProvider);
  return tailboardService.getTailboardStream(crewId);
}

/// Tailboard data for a specific crew
@riverpod
Tailboard? tailboard(Ref ref, String crewId) {
  final tailboardAsync = ref.watch(tailboardStreamProvider(crewId));
  
  return tailboardAsync.when(
    data: (tailboard) => tailboard,
    loading: () => null,
    error: (_, _) => null,
  );
}

/// Stream of suggested jobs for a specific crew
@riverpod
Stream<List<SuggestedJob>> suggestedJobsStream(Ref ref, String crewId) {
  final tailboardService = ref.watch(tailboardServiceProvider);
  return tailboardService.getJobFeedStream(crewId);
}

/// Suggested jobs for a specific crew
@riverpod
List<SuggestedJob> suggestedJobs(Ref ref, String crewId) {
  final jobsAsync = ref.watch(suggestedJobsStreamProvider(crewId));
  
  return jobsAsync.when(
    data: (jobs) => jobs,
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Stream of activity items for a specific crew
@riverpod
Stream<List<ActivityItem>> activityItemsStream(Ref ref, String crewId) {
  final tailboardService = ref.watch(tailboardServiceProvider);
  return tailboardService.getActivityStream(crewId);
}

/// Activity items for a specific crew
@riverpod
List<ActivityItem> activityItems(Ref ref, String crewId) {
  final activitiesAsync = ref.watch(activityItemsStreamProvider(crewId));
  
  return activitiesAsync.when(
    data: (activities) => activities,
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Stream of tailboard posts for a specific crew
@riverpod
Stream<List<TailboardPost>> tailboardPostsStream(Ref ref, String crewId) {
  final tailboardService = ref.watch(tailboardServiceProvider);
  return tailboardService.getPostsStream(crewId);
}

/// Tailboard posts for a specific crew
@riverpod
List<TailboardPost> tailboardPosts(Ref ref, String crewId) {
  final postsAsync = ref.watch(tailboardPostsStreamProvider(crewId));
  
  return postsAsync.when(
    data: (posts) => posts,
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider to get unread activity items count for current user
@riverpod
int unreadActivityCount(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final activities = ref.watch(activityItemsProvider(crewId));
  
  if (currentUser == null) return 0;
  
  return activities.where((activity) {
    return !activity.isReadBy(currentUser.uid);
  }).length;
}

/// Provider to get pinned posts for a specific crew
@riverpod
List<TailboardPost> pinnedPosts(Ref ref, String crewId) {
  final posts = ref.watch(tailboardPostsProvider(crewId));
  return posts.where((post) => post.isPinned).toList();
}

/// Provider to get recent posts (non-pinned) for a specific crew
@riverpod
List<TailboardPost> recentPosts(Ref ref, String crewId) {
  final posts = ref.watch(tailboardPostsProvider(crewId));
  return posts.where((post) => !post.isPinned).toList();
}

/// Provider to get posts by a specific author
@riverpod
List<TailboardPost> postsByAuthor(Ref ref, String crewId, String authorId) {
  final posts = ref.watch(tailboardPostsProvider(crewId));
  return posts.where((post) => post.authorId == authorId).toList();
}

/// Provider to get suggested jobs with high match score (>70)
@riverpod
List<SuggestedJob> highMatchJobs(Ref ref, String crewId) {
  final jobs = ref.watch(suggestedJobsProvider(crewId));
  return jobs.where((job) => job.matchScore > 70).toList();
}

/// Provider to get jobs not yet viewed by current user
@riverpod
List<SuggestedJob> unviewedJobs(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final jobs = ref.watch(suggestedJobsProvider(crewId));
  
  if (currentUser == null) return [];
  
  return jobs.where((job) {
    return !job.viewedByMemberIds.contains(currentUser.uid);
  }).toList();
}

/// Provider to get jobs applied by crew members
@riverpod
List<SuggestedJob> appliedJobs(Ref ref, String crewId) {
  final jobs = ref.watch(suggestedJobsProvider(crewId));
  return jobs.where((job) => job.appliedMemberIds.isNotEmpty).toList();
}

/// Provider to get tailboard analytics
@riverpod
TailboardAnalytics? tailboardAnalytics(Ref ref, String crewId) {
  final tailboard = ref.watch(tailboardProvider(crewId));
  return tailboard?.analytics;
}

/// Provider to get tailboard engagement rate
@riverpod
double engagementRate(Ref ref, String crewId) {
  final analytics = ref.watch(tailboardAnalyticsProvider(crewId));
  return analytics?.engagementRate ?? 0.0;
}

/// Provider to get total posts count
@riverpod
int totalPostsCount(Ref ref, String crewId) {
  final analytics = ref.watch(tailboardAnalyticsProvider(crewId));
  return analytics?.totalPosts ?? 0;
}

/// Provider to get total activities count
@riverpod
int totalActivitiesCount(Ref ref, String crewId) {
  final analytics = ref.watch(tailboardAnalyticsProvider(crewId));
  return analytics?.totalActivities ?? 0;
}

/// Provider to get total suggested jobs count
@riverpod
int totalSuggestedJobsCount(Ref ref, String crewId) {
  final analytics = ref.watch(tailboardAnalyticsProvider(crewId));
  return analytics?.totalSuggestedJobs ?? 0;
}

/// Provider to check if tailboard is loaded
@riverpod
bool isTailboardLoaded(Ref ref, String crewId) {
  final tailboard = ref.watch(tailboardProvider(crewId));
  return tailboard != null;
}

/// Provider to get last updated timestamp
@riverpod
DateTime? tailboardLastUpdated(Ref ref, String crewId) {
  final tailboard = ref.watch(tailboardProvider(crewId));
  return tailboard?.lastUpdated;
}

/// Provider to get crew calendar
@riverpod
CrewCalendar? crewCalendar(Ref ref, String crewId) {
  final tailboard = ref.watch(tailboardProvider(crewId));
  return tailboard?.calendar;
}

/// Provider to get recent messages
@riverpod
List<String> recentMessages(Ref ref, String crewId) {
  final tailboard = ref.watch(tailboardProvider(crewId));
  return tailboard?.recentMessages ?? [];
}

/// Provider to get activity by type
@riverpod
List<ActivityItem> activitiesByType(Ref ref, String crewId, ActivityType type) {
  final activities = ref.watch(activityItemsProvider(crewId));
  return activities.where((activity) => activity.type == type).toList();
}

/// Provider to get recent activities (last 7 days)
@riverpod
List<ActivityItem> recentActivities(Ref ref, String crewId) {
  final activities = ref.watch(activityItemsProvider(crewId));
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  
  return activities.where((activity) {
    return activity.timestamp.isAfter(sevenDaysAgo);
  }).toList();
}

/// Provider to get activities by actor
@riverpod
List<ActivityItem> activitiesByActor(Ref ref, String crewId, String actorId) {
  final activities = ref.watch(activityItemsProvider(crewId));
  return activities.where((activity) => activity.actorId == actorId).toList();
}