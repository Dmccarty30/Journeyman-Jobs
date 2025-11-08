import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user_job_preferences.dart';
import '../../utils/concurrent_operations.dart';
import '../../utils/error_handler.dart';

part 'user_preferences_riverpod_provider.g.dart';

/// Extension methods for UserJobPreferences to check if preferences have been set
extension UserJobPreferencesX on UserJobPreferences {
  /// Content-based check to determine if user has set any preferences
  ///
  /// Returns true if ANY of the following conditions are met:
  /// - At least one classification is selected
  /// - At least one construction type is selected
  /// - At least one preferred local is selected
  /// - Hours per week is specified
  /// - Per diem requirement is specified
  /// - Minimum wage is specified
  /// - Maximum distance is specified
  ///
  /// This replaces the broken referential equality check that would always
  /// return true since each UserJobPreferences.empty() call creates a new instance.
  bool get hasPreferences {
    return classifications.isNotEmpty
        || constructionTypes.isNotEmpty
        || preferredLocals.isNotEmpty
        || hoursPerWeek != null
        || perDiemRequirement != null
        || minWage != null
        || maxDistance != null;
  }
}

/// User preferences state model for Riverpod
class UserPreferencesState {
  UserPreferencesState({
    UserJobPreferences? preferences,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  }) : preferences = preferences ?? UserJobPreferences.empty();

  final UserJobPreferences preferences;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  /// Checks if user has set any job preferences
  ///
  /// Uses content-based checking via extension method to determine if
  /// any preference fields have been populated. This ensures accurate
  /// detection of whether a user has configured their job preferences.
  bool get hasPreferences => preferences.hasPreferences;

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

  UserPreferencesState clearError() => copyWith(error: null);
}

/// User preferences notifier for managing user job preferences
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  late final ConcurrentOperationManager _operationManager;

  @override
  UserPreferencesState build() {
    _operationManager = ConcurrentOperationManager();
    return UserPreferencesState();
  }

  /// Load user preferences from Firestore
  Future<void> loadPreferences(String userId) async {
    if (_operationManager.isOperationInProgress(OperationType.loadUserProfile)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await ErrorHandler.handleAsyncOperation(
      () async {
        return await _operationManager.executeOperation(
          type: OperationType.loadUserProfile,
          operation: () async {
            final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

            if (doc.exists && doc.data()!.containsKey('jobPreferences')) {
              return UserJobPreferences.fromJson((doc.data()!['jobPreferences'] as Map<String, dynamic>));
            } else {
              // No preferences found, use empty preferences
              return UserJobPreferences.empty();
            }
          },
        );
      },
      operationName: 'loadPreferences',
      errorMessage: 'Failed to load preferences',
      context: {
        'userId': userId,
      },
    );

    if (result != null) {
      state = state.copyWith(
        preferences: result,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } else {
      // Error already handled by ErrorHandler
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load preferences',
      );
    }
  }

  /// Save user preferences to Firestore
  ///
  /// Validates preferences before saving and provides comprehensive error handling.
  /// Throws Exception with user-friendly error messages on validation or save failures.
  Future<void> savePreferences(String userId, UserJobPreferences preferences) async {
    if (_operationManager.isOperationInProgress(OperationType.updateUserProfile)) {
      throw Exception('A save operation is already in progress');
    }

    // Validate user ID
    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    // Validate preferences before attempting to save
    if (!preferences.validate()) {
      final validationError = preferences.validationError ?? 'Invalid preferences';
      throw Exception(validationError);
    }

    state = state.copyWith(isLoading: true);

    final success = await ErrorHandler.handleAsyncOperation(
      () async {
        return await _operationManager.executeOperation(
          type: OperationType.updateUserProfile,
          operation: () async {
            final firestore = FirebaseFirestore.instance;
            final userDocRef = firestore.collection('users').doc(userId);

            // Convert preferences to JSON
            final prefsJson = preferences.toJson();

            await firestore.runTransaction((transaction) async {
              final userDoc = await transaction.get(userDocRef);

              if (!userDoc.exists) {
                // Create user document if it doesn't exist (edge case for new users)
                transaction.set(userDocRef, {
                  'jobPreferences': prefsJson,
                  'hasSetJobPreferences': true,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              } else {
                // Update existing user document
                transaction.update(userDocRef, {
                  'jobPreferences': prefsJson,
                  'hasSetJobPreferences': true,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
            });

            // Verify the save by reading back the document
            final verifyDoc = await userDocRef.get();
            if (!verifyDoc.exists || !verifyDoc.data()!.containsKey('jobPreferences')) {
              throw Exception('Save verification failed');
            }

            state = state.copyWith(
              preferences: preferences,
              isLoading: false,
              lastUpdated: DateTime.now(),
              error: null, // Clear any previous errors
            );

            return true;
          },
        );
      },
      operationName: 'savePreferences',
      errorMessage: 'Failed to save preferences',
      context: {
        'userId': userId,
        'hasPreferences': preferences.hasPreferences,
      },
    );

    if (success == null) {
      // Error already handled by ErrorHandler
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save preferences',
      );
    }
  }

  /// Update existing user preferences
  ///
  /// Validates preferences before updating and provides comprehensive error handling.
  /// Throws Exception with user-friendly error messages on validation or update failures.
  Future<void> updatePreferences(String userId, UserJobPreferences updatedPreferences) async {
    if (_operationManager.isOperationInProgress(OperationType.updateUserProfile)) {
      throw Exception('An update operation is already in progress');
    }

    // Validate user ID
    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    // Validate preferences before attempting to update
    if (!updatedPreferences.validate()) {
      final validationError = updatedPreferences.validationError ?? 'Invalid preferences';
      throw Exception(validationError);
    }

    state = state.copyWith(isLoading: true);

    final success = await ErrorHandler.handleAsyncOperation(
      () async {
        return await _operationManager.executeOperation(
          type: OperationType.updateUserProfile,
          operation: () async {
            final firestore = FirebaseFirestore.instance;
            final userDocRef = firestore.collection('users').doc(userId);

            // Convert preferences to JSON
            final prefsJson = updatedPreferences.toJson();

            await firestore.runTransaction((transaction) async {
              final userDoc = await transaction.get(userDocRef);

              if (!userDoc.exists) {
                // Create user document if it doesn't exist (edge case for new users)
                transaction.set(userDocRef, {
                  'jobPreferences': prefsJson,
                  'hasSetJobPreferences': true,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              } else {
                // Update existing user document
                transaction.update(userDocRef, {
                  'jobPreferences': prefsJson,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
            });

            // Verify the update by reading back the document
            final verifyDoc = await userDocRef.get();
            if (!verifyDoc.exists || !verifyDoc.data()!.containsKey('jobPreferences')) {
              throw Exception('Update verification failed');
            }

            state = state.copyWith(
              preferences: updatedPreferences,
              isLoading: false,
              lastUpdated: DateTime.now(),
              error: null, // Clear any previous errors
            );

            return true;
          },
        );
      },
      operationName: 'updatePreferences',
      errorMessage: 'Failed to update preferences',
      context: {
        'userId': userId,
        'hasPreferences': updatedPreferences.hasPreferences,
      },
    );

    if (success == null) {
      // Error already handled by ErrorHandler
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update preferences',
      );
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

/// Convenience provider for current user job preferences
@riverpod
UserJobPreferences currentUserJobPreferences(Ref ref) {
  final state = ref.watch(userPreferencesProvider);
  return state.preferences;
}

/// Convenience provider for checking if user has preferences
@riverpod
bool hasUserPreferences(Ref ref) {
  final state = ref.watch(userPreferencesProvider);
  return state.hasPreferences;
}

/// Convenience provider for last updated timestamp
@riverpod
DateTime? userPreferencesLastUpdated(Ref ref) {
  final state = ref.watch(userPreferencesProvider);
  return state.lastUpdated;
}
