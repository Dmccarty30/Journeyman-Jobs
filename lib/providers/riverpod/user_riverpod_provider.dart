import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/user_model.dart';
import 'auth_riverpod_provider.dart';

part 'user_riverpod_provider.g.dart';

/// Provides the current authenticated user's UserModel from Firestore.
///
/// Returns `AsyncValue<UserModel?>`:
/// - `AsyncValue.loading`: Fetching user data from Firestore
/// - `AsyncValue.data(UserModel)`: User data successfully loaded
/// - `AsyncValue.data(null)`: User is not authenticated or document doesn't exist
/// - `AsyncValue.error`: Error fetching user data
///
/// This provider watches the authenticated user's Firestore document in real-time,
/// automatically updating whenever the user data changes.
///
/// Example usage:
/// ```dart
/// final userAsync = ref.watch(currentUserModelProvider);
/// userAsync.when(
///   loading: () => CircularProgressIndicator(),
///   data: (userModel) {
///     if (userModel != null) {
///       return Text('Welcome ${userModel.firstName} ${userModel.lastName}!');
///     }
///     return Text('Welcome!');
///   },
///   error: (err, stack) => Text('Error loading user data'),
/// );
/// ```
@riverpod
Stream<UserModel?> currentUserModel(Ref ref) async* {
  final user = ref.watch(currentUserProvider);

  // If no user is authenticated, return null
  if (user == null) {
    yield null;
    return;
  }

  // Watch the user's Firestore document for real-time updates
  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          return null; // User document doesn't exist yet
        }

        try {
          return UserModel.fromFirestore(snapshot);
        } catch (e) {
          // If there's an error parsing the user model, return null
          // This prevents the app from crashing due to data inconsistencies
          return null;
        }
      });
}

/// Provides a synchronous version of the current user model.
///
/// Returns `UserModel?` or null if:
/// - User is not authenticated
/// - User data is still loading
/// - User document doesn't exist
/// - Error occurred while fetching
///
/// Use this when you need immediate access to user data and can handle null cases.
/// For reactive updates, use `currentUserModelProvider` instead.
///
/// Example usage:
/// ```dart
/// final userModel = ref.watch(currentUserModelSyncProvider);
/// if (userModel != null) {
///   Text('${userModel.firstName} ${userModel.lastName}');
/// }
/// ```
@riverpod
UserModel? currentUserModelSync(Ref ref) {
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.whenOrNull(data: (userModel) => userModel);
}
