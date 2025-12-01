import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_service.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:journeyman_jobs/services/firestore_service.dart' as real_firestore;
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/tailboard.dart';
import 'package:journeyman_jobs/models/job_model.dart';

part 'core_providers.g.dart';


class FirestoreService {
  // Shim: mock Firestore operations
  Future<void> addJob(dynamic job) async {}
  Future<void> updateJob(dynamic job) async {}
}

class AuthService {
  // Shim for auth
  String? get currentUserId => 'mock_user';
}

/// Simple error reporter used by providers to surface/report errors.
class ErrorReporter {
  void report(String key, Object error, StackTrace? stack, [String? context]) {
    // Minimal implementation: in real app this would log/send to monitoring
    // Keep silent here to avoid noise during analysis.
  }
}

final coreErrorReporterProvider = Provider<ErrorReporter>((ref) => ErrorReporter());

// Legacy providers (keeping for backward compatibility)
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final realFirestoreServiceProvider = Provider<real_firestore.FirestoreService>((ref) => real_firestore.FirestoreService());

// Database Service Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Connectivity Service Provider
@riverpod
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService();
}

// Selected Crew Provider - Note: These are intentionally not using @riverpod
// to maintain compatibility with existing code that expects StateProvider
// StateProvider is still available in flutter_riverpod 3.x
final selectedCrewProvider = StateNotifierProvider<SelectedCrewNotifier, Crew?>((ref) => SelectedCrewNotifier());

class SelectedCrewNotifier extends StateNotifier<Crew?> {
  SelectedCrewNotifier() : super(null);
  void setCrew(Crew? crew) => state = crew;
}

// Current User Provider - Note: These are intentionally not using @riverpod
// to maintain compatibility with existing code that expects StateProvider
final currentUserProvider = Provider<UserModel?>((ref) => null);

// Feed Posts Notifier Provider
@riverpod
class FeedPostsNotifier extends _$FeedPostsNotifier {
  @override
  Future<List<TailboardPost>> build(String crewId) async {
    // Load initial posts
    return [];
  }

  Future<void> loadMore() async {
    // Load more posts
  }

  Future<void> refresh() async {
    // Refresh posts
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return [];
    });
  }
}

// Jobs Notifier Provider
@riverpod
class JobsNotifier extends _$JobsNotifier {
  bool isLoadingMore = false;

  @override
  Future<List<Job>> build(String crewId) async {
    // Load initial jobs
    return [];
  }

  Future<void> loadMore() async {
    if (isLoadingMore) return;
    isLoadingMore = true;
    // Load more jobs
    isLoadingMore = false;
  }

  Future<void> refresh() async {
    // Refresh posts
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return [];
    });
  }
}
