// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(currentUserModel)
const currentUserModelProvider = CurrentUserModelProvider._();

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

final class CurrentUserModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
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
  const CurrentUserModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserModelHash();

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    return currentUserModel(ref);
  }
}

String _$currentUserModelHash() => r'5151f19c5b5ed8ccff38f6431c6deb0e75f22828';

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

@ProviderFor(currentUserModelSync)
const currentUserModelSyncProvider = CurrentUserModelSyncProvider._();

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

final class CurrentUserModelSyncProvider
    extends $FunctionalProvider<UserModel?, UserModel?, UserModel?>
    with $Provider<UserModel?> {
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
  const CurrentUserModelSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserModelSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserModelSyncHash();

  @$internal
  @override
  $ProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserModel? create(Ref ref) {
    return currentUserModelSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserModel?>(value),
    );
  }
}

String _$currentUserModelSyncHash() =>
    r'1c1948af8ff0a806a870c4e6daeacbbb1b566641';
