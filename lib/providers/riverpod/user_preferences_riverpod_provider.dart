import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user_job_preferences.dart';
import '../../utils/concurrent_operations.dart';

part 'user_preferences_riverpod_provider.g.dart';

/// User preferences state model for Riverpod
class UserPreferencesState {
  const UserPreferencesState({
    this.preferences = UserJobPreferences.empty(),
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  final UserJobPreferences preferences;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  UserPreferencesState copyWith({
    UserJobPreferences? preferences,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) => UserPreferencesState(
    preferences: preferences ?? this.preferences,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );

  UserPreferencesState clearError() => copyWith();
}

/// User preferences notifier for managing user job preferences
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  late final ConcurrentOperationManager _operationManager;

  @override
  UserPreferencesState build() {
    _operationManager = ConcurrentOperationManager();
    return const UserPreferencesState();
  }

  /// Load user preferences from Firestore
  Future<void> loadPreferences(String userId) async {
    if (_operationManager.isOperationInProgress(OperationType.loadUserProfile)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _operationManager.executeOperation(
        type: OperationType.loadUserProfile,
        operation: () async {
          final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
          
          if (doc.exists && doc.data()!.containsKey('jobPreferences')) {
            final preferences = UserJobPreferences.fromJson((doc.data()!['jobPreferences'] as Map<String, dynamic>));
            state = state.copyWith(
              preferences: preferences,
              isLoading: false,
              lastUpdated: DateTime.now(),
            );
          } else {
            // No preferences found, use empty preferences
            state = state.copyWith(
              preferences: UserJobPreferences.empty(),
              isLoading: false,
              lastUpdated: DateTime.now(),
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Save user preferences to Firestore
  Future<void> savePreferences(String userId, UserJobPreferences preferences) async {
    if (_operationManager.isOperationInProgress(OperationType.updateUserProfile)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _operationManager.executeOperation(
        type: OperationType.updateUserProfile,
        operation: () async {
          final firestore = FirebaseFirestore.instance;
          final userDocRef = firestore.collection('users').doc(userId);
          
          await firestore.runTransaction((transaction) async {
            final userDoc = await transaction.get(userDocRef);
            
            if (!userDoc.exists) {
              throw Exception('User document not found');
            }
            
            // Update job preferences
            transaction.update(userDocRef, {
              'jobPreferences': preferences.toJson(),
              'hasSetJobPreferences': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          });
          
          state = state.copyWith(
            preferences: preferences,
            isLoading: false,
            lastUpdated: DateTime.now(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update existing user preferences
  Future<void> updatePreferences(String userId, UserJobPreferences updatedPreferences) async {
    if (_operationManager.isOperationInProgress(OperationType.updateUserProfile)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _operationManager.executeOperation(
        type: OperationType.updateUserProfile,
        operation: () async {
          final firestore = FirebaseFirestore.instance;
          final userDocRef = firestore.collection('users').doc(userId);
          
          await firestore.runTransaction((transaction) async {
            final userDoc = await transaction.get(userDocRef);
            
            if (!userDoc.exists) {
              throw Exception('User document not found');
            }
            
            // Update job preferences
            transaction.update(userDocRef, {
              'jobPreferences': updatedPreferences.toJson(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          });
          
          state = state.copyWith(
            preferences: updatedPreferences,
            isLoading: false,
            lastUpdated: DateTime.now(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Dispose resources
  void dispose() {
    _operationManager.dispose();
  }
}

/// Convenience provider for user preferences
@riverpod
UserJobPreferences userPreferences(Ref ref) {
  final state = ref.watch(userPreferencesNotifierProvider);
  return state.preferences;
}

/// Convenience provider for checking if user has preferences
@riverpod
bool hasUserPreferences(Ref ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.hasPreferences;
}

/// Convenience provider for last updated timestamp
@riverpod
DateTime? userPreferencesLastUpdated(Ref ref) {
  final state = ref.watch(userPreferencesNotifierProvider);
  return state.lastUpdated;
}