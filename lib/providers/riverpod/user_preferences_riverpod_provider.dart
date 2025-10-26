import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user_job_preferences.dart';
import '../../utils/concurrent_operations.dart';

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

    try {
      await _operationManager.executeOperation(
        type: OperationType.updateUserProfile,
        operation: () async {
          final firestore = FirebaseFirestore.instance;
          final userDocRef = firestore.collection('users').doc(userId);

          print('[UserPreferencesProvider] 🔄 Starting save operation for user: $userId');
          print('[UserPreferencesProvider] 📋 Preferences data:');
          print('  - Classifications: ${preferences.classifications}');
          print('  - Construction Types: ${preferences.constructionTypes}');
          print('  - Preferred Locals: ${preferences.preferredLocals}');
          print('  - Hours per week: ${preferences.hoursPerWeek}');
          print('  - Per diem: ${preferences.perDiemRequirement}');

          // Convert preferences to JSON
          final prefsJson = preferences.toJson();
          print('[UserPreferencesProvider] 📦 JSON payload: $prefsJson');

          await firestore.runTransaction((transaction) async {
            final userDoc = await transaction.get(userDocRef);

            if (!userDoc.exists) {
              // Create user document if it doesn't exist (edge case for new users)
              print('[UserPreferencesProvider] ⚠️ User document does not exist - creating new document');
              transaction.set(userDocRef, {
                'jobPreferences': prefsJson,
                'hasSetJobPreferences': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            } else {
              // Update existing user document
              print('[UserPreferencesProvider] ✏️ Updating existing user document');
              print('[UserPreferencesProvider] 📄 Current data keys: ${userDoc.data()?.keys.toList()}');
              transaction.update(userDocRef, {
                'jobPreferences': prefsJson,
                'hasSetJobPreferences': true,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          });

          print('[UserPreferencesProvider] ✅ Transaction completed successfully');
          print('[UserPreferencesProvider] 🔍 Verifying save by reading back document...');

          // Verify the save by reading back the document
          final verifyDoc = await userDocRef.get();
          if (verifyDoc.exists && verifyDoc.data()!.containsKey('jobPreferences')) {
            print('[UserPreferencesProvider] ✅ Save verified - jobPreferences field exists');
            final savedPrefs = verifyDoc.data()!['jobPreferences'];
            print('[UserPreferencesProvider] 📋 Saved data: $savedPrefs');
          } else {
            print('[UserPreferencesProvider] ❌ WARNING: Save verification failed - jobPreferences field not found');
          }

          state = state.copyWith(
            preferences: preferences,
            isLoading: false,
            lastUpdated: DateTime.now(),
            error: null, // Clear any previous errors
          );
        },
      );
    } on FirebaseException catch (e) {
      print('[UserPreferencesProvider] ❌ Firebase error during save:');
      print('  - Error code: ${e.code}');
      print('  - Error message: ${e.message}');
      print('  - Plugin: ${e.plugin}');
      print('  - Stack trace: ${e.stackTrace}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      // Provide user-friendly error messages based on Firebase error codes
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Please check your account settings.');
      } else if (e.code == 'unavailable') {
        throw Exception('Network error. Please check your connection.');
      } else if (e.code == 'unauthenticated') {
        throw Exception('Authentication required. Please sign in again.');
      } else if (e.code == 'not-found') {
        throw Exception('User document not found. Please try signing out and back in.');
      } else {
        throw Exception('Error saving preferences: ${e.message}');
      }
    } catch (e) {
      print('[UserPreferencesProvider] ❌ Unexpected error during save: $e');
      print('[UserPreferencesProvider] 📚 Error type: ${e.runtimeType}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      throw Exception('Failed to save preferences. Please try again.');
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

    try {
      await _operationManager.executeOperation(
        type: OperationType.updateUserProfile,
        operation: () async {
          final firestore = FirebaseFirestore.instance;
          final userDocRef = firestore.collection('users').doc(userId);

          print('[UserPreferencesProvider] 🔄 Starting update operation for user: $userId');
          print('[UserPreferencesProvider] 📋 Updated preferences:');
          print('  - Classifications: ${updatedPreferences.classifications}');
          print('  - Construction Types: ${updatedPreferences.constructionTypes}');
          print('  - Preferred Locals: ${updatedPreferences.preferredLocals}');
          print('  - Hours per week: ${updatedPreferences.hoursPerWeek}');
          print('  - Per diem: ${updatedPreferences.perDiemRequirement}');

          // Convert preferences to JSON
          final prefsJson = updatedPreferences.toJson();
          print('[UserPreferencesProvider] 📦 JSON payload: $prefsJson');

          await firestore.runTransaction((transaction) async {
            final userDoc = await transaction.get(userDocRef);

            if (!userDoc.exists) {
              // Create user document if it doesn't exist (edge case for new users)
              print('[UserPreferencesProvider] ⚠️ User document does not exist - creating during update');
              transaction.set(userDocRef, {
                'jobPreferences': prefsJson,
                'hasSetJobPreferences': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            } else {
              // Update existing user document
              print('[UserPreferencesProvider] ✏️ Updating existing user document');
              print('[UserPreferencesProvider] 📄 Current data keys: ${userDoc.data()?.keys.toList()}');
              transaction.update(userDocRef, {
                'jobPreferences': prefsJson,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          });

          print('[UserPreferencesProvider] ✅ Transaction completed successfully');
          print('[UserPreferencesProvider] 🔍 Verifying update by reading back document...');

          // Verify the update by reading back the document
          final verifyDoc = await userDocRef.get();
          if (verifyDoc.exists && verifyDoc.data()!.containsKey('jobPreferences')) {
            print('[UserPreferencesProvider] ✅ Update verified - jobPreferences field exists');
            final savedPrefs = verifyDoc.data()!['jobPreferences'];
            print('[UserPreferencesProvider] 📋 Updated data: $savedPrefs');
          } else {
            print('[UserPreferencesProvider] ❌ WARNING: Update verification failed - jobPreferences field not found');
          }

          state = state.copyWith(
            preferences: updatedPreferences,
            isLoading: false,
            lastUpdated: DateTime.now(),
            error: null, // Clear any previous errors
          );
        },
      );
    } on FirebaseException catch (e) {
      print('[UserPreferencesProvider] ❌ Firebase error during update:');
      print('  - Error code: ${e.code}');
      print('  - Error message: ${e.message}');
      print('  - Plugin: ${e.plugin}');
      print('  - Stack trace: ${e.stackTrace}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      // Provide user-friendly error messages based on Firebase error codes
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Please check your account settings.');
      } else if (e.code == 'unavailable') {
        throw Exception('Network error. Please check your connection.');
      } else if (e.code == 'unauthenticated') {
        throw Exception('Authentication required. Please sign in again.');
      } else if (e.code == 'not-found') {
        throw Exception('User document not found. Please try signing out and back in.');
      } else {
        throw Exception('Error updating preferences: ${e.message}');
      }
    } catch (e) {
      print('[UserPreferencesProvider] ❌ Unexpected error during update: $e');
      print('[UserPreferencesProvider] 📚 Error type: ${e.runtimeType}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      throw Exception('Failed to update preferences. Please try again.');
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
