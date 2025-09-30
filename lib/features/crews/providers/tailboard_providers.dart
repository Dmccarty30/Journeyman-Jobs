import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../services/database_service.dart';
import '../../../models/user_model.dart';
import '../../../models/crew_model.dart';
import '../../posts/models/post.dart';
import '../../../models/job_model.dart';
import '../../../models/message_model.dart';
import '../../../models/conversation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

// Current user provider - fetches the current authenticated user
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final dbService = ref.watch(databaseServiceProvider);
    return await dbService.getUser(user.uid);
  } catch (e, stackTrace) {
    throw AsyncValue.error(e, stackTrace).error as Object; // Re-throw as Object to match FutureProvider's expected error type
  }
});

// Selected crew provider - state provider for UI selection
final selectedCrewProvider = StateProvider<Crew?>((ref) => null);

// Crew notifier for managing crew operations
class CrewNotifier extends StateNotifier<AsyncValue<Crew?>> {
  final DatabaseService _dbService;

  CrewNotifier(this._dbService) : super(const AsyncValue.loading());

  Future<void> createCrew(Crew crew) async {
    try {
      state = const AsyncValue.loading();
      final crewId = await _dbService.createCrew(crew);
      state = AsyncValue.data(await _dbService.getCrew(crewId));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> joinCrew(String crewId) async {
    try {
      state = const AsyncValue.loading();
      await _dbService.joinCrew(crewId);
      state = AsyncValue.data(await _dbService.getCrew(crewId));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Add other methods like leaveCrew, updateCrew, etc., as needed
}

final crewNotifierProvider = StateNotifierProvider<CrewNotifier, AsyncValue<Crew?>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return CrewNotifier(dbService);
});

// Stream providers using family for crew-specific data
final feedPostsProvider = StreamProvider.family<List<Post>, ({String crewId, int limit, DocumentSnapshot? startAfter})>((ref, params) {
  final dbService = ref.watch(databaseServiceProvider);
  try {
    return dbService.streamFeedPosts(params.crewId, limit: params.limit, startAfter: params.startAfter);
  } catch (e, stackTrace) {
    ref.keepAlive();
    return Stream.error(e, stackTrace);
  }
});
final jobsProvider = StreamProvider.family<List<Job>, ({String crewId, int limit, DocumentSnapshot? startAfter})>((ref, params) {
  final dbService = ref.watch(databaseServiceProvider);
  try {
    return dbService.streamJobs(params.crewId, limit: params.limit, startAfter: params.startAfter);
  } catch (e, stackTrace) {
    ref.keepAlive();
    return Stream.error(e, stackTrace);
  }
});
});
final messagesProvider = StreamProvider.family<List<Message>, ({String crewId, String conversationId, int limit, DocumentSnapshot? startAfter})>((ref, params) {
  final dbService = ref.watch(databaseServiceProvider);
  try {
    return dbService.streamMessages(params.crewId, params.conversationId, limit: params.limit, startAfter: params.startAfter);
  } catch (e, stackTrace) {
    ref.keepAlive();
    return Stream.error(e, stackTrace);
  }
});
});

// Additional providers for members, etc.
final membersProvider = StreamProvider.family<List<UserModel>, ({String crewId, int limit, DocumentSnapshot? startAfter})>((ref, params) {
  final dbService = ref.watch(databaseServiceProvider);
  try {
    return dbService.streamMembers(params.crewId, limit: params.limit, startAfter: params.startAfter);
  } catch (e, stackTrace) {
    ref.keepAlive();
    return Stream.error(e, stackTrace);
  }
});

final conversationsProvider = StreamProvider.family<List<Conversation>, String>((ref, crewId) {
  final dbService = ref.watch(databaseServiceProvider);
  try {
    return dbService.streamConversations(crewId);
  } catch (e, stackTrace) {
    ref.keepAlive();
    return Stream.error(e, stackTrace);
  }
});

// Feed Posts Notifier for pagination and load more
final feedPostsNotifierProvider = StateNotifierProvider.family<FeedPostsNotifier, AsyncValue<List<Post>>, String>((ref, crewId) => FeedPostsNotifier(ref, crewId));

class FeedPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  FeedPostsNotifier(this.ref, this.crewId) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  final Ref ref;
  final String crewId;
  List<Post> _allPosts = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    _allPosts = [];
    _lastDoc = null;
    _hasMore = true;
    _isLoadingMore = false;

    try {
      final initialProvider = feedPostsProvider(({crewId: crewId, limit: 20, startAfter: null}));
      final initialStream = ref.watch(initialProvider);
      await for (final snapshot in initialStream) {
        _allPosts = snapshot;
        if (snapshot.isNotEmpty) {
          _lastDoc = snapshot.last;
        }
        if (snapshot.length < 20) {
          _hasMore = false;
        }
        state = AsyncValue.data(_allPosts);
        break; // Take first snapshot
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _lastDoc == null) return;

    _isLoadingMore = true;
    final currentPosts = List<Post>.from(_allPosts);

    try {
      final moreProvider = feedPostsProvider(({crewId: crewId, limit: 20, startAfter: _lastDoc}));
      final moreStream = ref.watch(moreProvider);
      await for (final morePosts in moreStream) {
        _allPosts = [...currentPosts, ...morePosts];
        if (morePosts.isNotEmpty) {
          _lastDoc = morePosts.last;
        }
        if (morePosts.length < 20) {
          _hasMore = false;
        }
        state = AsyncValue.data(_allPosts);
        break;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _allPosts = currentPosts; // Revert on error
    } finally {
      _isLoadingMore = false;
    }
  }
}

// Jobs Notifier for pagination
final jobsNotifierProvider = StateNotifierProvider.family<JobsNotifier, AsyncValue<List<Job>>, String>((ref, crewId) => JobsNotifier(ref, crewId));

class JobsNotifier extends StateNotifier<AsyncValue<List<Job>>> {
  JobsNotifier(this.ref, this.crewId) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  final Ref ref;
  final String crewId;
  List<Job> _allJobs = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    _allJobs = [];
    _lastDoc = null;
    _hasMore = true;
    _isLoadingMore = false;

    try {
      final initialProvider = jobsProvider(({crewId: crewId, limit: 20, startAfter: null}));
      final initialStream = ref.watch(initialProvider);
      await for (final snapshot in initialStream) {
        _allJobs = snapshot;
        if (snapshot.isNotEmpty) {
          _lastDoc = snapshot.last;
        }
        if (snapshot.length < 20) {
          _hasMore = false;
        }
        state = AsyncValue.data(_allJobs);
        break;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _lastDoc == null) return;

    _isLoadingMore = true;
    final currentJobs = List<Job>.from(_allJobs);

    try {
      final moreProvider = jobsProvider(({crewId: crewId, limit: 20, startAfter: _lastDoc}));
      final moreStream = ref.watch(moreProvider);
      await for (final moreJobs in moreStream) {
        _allJobs = [...currentJobs, ...moreJobs];
        if (moreJobs.isNotEmpty) {
          _lastDoc = moreJobs.last;
        }
        if (moreJobs.length < 20) {
          _hasMore = false;
        }
        state = AsyncValue.data(_allJobs);
        break;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _allJobs = currentJobs;
    } finally {
      _isLoadingMore = false;
    }
  }
}

// Similar notifiers can be added for messages and members as needed