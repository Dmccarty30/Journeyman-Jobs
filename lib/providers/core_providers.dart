import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_service.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/tailboard.dart';
import 'package:journeyman_jobs/models/job_model.dart';

part 'core_providers.g.dart';

/// A shim class mocking Firestore operations for legacy provider compatibility.
class FirestoreService {
  // Shim: mock Firestore operations
  /// Mock method to add a job.
  Future<void> addJob(dynamic job) async {}
  /// Mock method to update a job.
  Future<void> updateJob(dynamic job) async {}
}

/// A shim class mocking Authentication operations for legacy provider compatibility.
class AuthService {
  // Shim for auth
  /// Returns a mock user ID.
  String? get currentUserId => 'mock_user';
}

/// A simple error reporter used by providers to surface errors.
///
/// In a production application, this would log errors to a monitoring service.
class ErrorReporter {
  /// Reports an error.
  ///
  /// - [key]: A unique key identifying the source of the error.
  /// - [error]: The error object.
  /// - [stack]: The stack trace associated with the error.
  /// - [context]: Optional additional context about the error.
  void report(String key, Object error, StackTrace? stack, [String? context]) {
    // Minimal implementation: in real app this would log/send to monitoring
    // Keep silent here to avoid noise during analysis.
  }
}

/// A provider that exposes an instance of [ErrorReporter].
final coreErrorReporterProvider = Provider<ErrorReporter>((ref) => ErrorReporter());

// Legacy providers (keeping for backward compatibility)
/// A legacy provider for the [FirestoreService] shim.
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
/// A legacy provider for the [AuthService] shim.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provides an app-wide instance of [DatabaseService].
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// A Riverpod provider that creates and exposes the [ConnectivityService].
@riverpod
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService();
}

// Selected Crew Provider - Note: These are intentionally not using @riverpod
// to maintain compatibility with existing code that expects StateProvider
// StateProvider is still available in flutter_riverpod 3.x
/// A provider that holds the currently selected [Crew] object for the user session.
final selectedCrewProvider = StateNotifierProvider<SelectedCrewNotifier, Crew?>((ref) => SelectedCrewNotifier());

/// The [StateNotifier] responsible for managing the state of the selected crew.
class SelectedCrewNotifier extends StateNotifier<Crew?> {
  /// Initializes the state with no crew selected.
  SelectedCrewNotifier() : super(null);
  /// Sets the currently selected crew.
  void setCrew(Crew? crew) => state = crew;
}

// Current User Provider - Note: These are intentionally not using @riverpod
// to maintain compatibility with existing code that expects StateProvider
/// A provider intended to hold the currently logged-in [UserModel].
/// Note: This is currently a placeholder and returns null.
final currentUserProvider = Provider<UserModel?>((ref) => null);

/// An asynchronous notifier for managing and providing a list of feed posts for a specific crew.
@riverpod
class FeedPostsNotifier extends _$FeedPostsNotifier {
  @override
  Future<List<TailboardPost>> build(String crewId) async {
    // In a real implementation, this would fetch the initial list of posts.
    return [];
  }

  /// Fetches the next page of posts and appends them to the current state.
  Future<void> loadMore() async {
    // Logic to load more posts would go here.
  }

  /// Refreshes the list of posts, re-fetching from the source.
  Future<void> refresh() async {
    // Refresh posts
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return [];
    });
  }
}

/// An asynchronous notifier for managing and providing a list of jobs for a specific crew.
@riverpod
class JobsNotifier extends _$JobsNotifier {
  /// A flag to prevent concurrent `loadMore` calls.
  bool isLoadingMore = false;

  @override
  Future<List<Job>> build(String crewId) async {
    // In a real implementation, this would fetch the initial list of jobs.
    return [];
  }

  /// Fetches the next page of jobs and appends them to the current state.
  Future<void> loadMore() async {
    if (isLoadingMore) return;
    isLoadingMore = true;
    // Logic to load more jobs would go here.
    isLoadingMore = false;
  }

  /// Refreshes the list of jobs, re-fetching from the source.
  Future<void> refresh() async {
    // Refresh jobs
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return [];
    });
  }
}
