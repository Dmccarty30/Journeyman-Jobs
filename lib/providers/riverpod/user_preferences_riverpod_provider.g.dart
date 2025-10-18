// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User preferences notifier for managing user job preferences

@ProviderFor(UserPreferencesNotifier)
const userPreferencesProvider = UserPreferencesNotifierProvider._();

/// User preferences notifier for managing user job preferences
final class UserPreferencesNotifierProvider
    extends $NotifierProvider<UserPreferencesNotifier, UserPreferencesState> {
  /// User preferences notifier for managing user job preferences
  const UserPreferencesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesNotifierHash();

  @$internal
  @override
  UserPreferencesNotifier create() => UserPreferencesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPreferencesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPreferencesState>(value),
    );
  }
}

String _$userPreferencesNotifierHash() =>
    r'bf3f568a3704f4fcaf743db6e4aa3ac8e25f507d';

/// User preferences notifier for managing user job preferences

abstract class _$UserPreferencesNotifier
    extends $Notifier<UserPreferencesState> {
  UserPreferencesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserPreferencesState, UserPreferencesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserPreferencesState, UserPreferencesState>,
              UserPreferencesState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Convenience provider for current user job preferences

@ProviderFor(currentUserJobPreferences)
const currentUserJobPreferencesProvider = CurrentUserJobPreferencesProvider._();

/// Convenience provider for current user job preferences

final class CurrentUserJobPreferencesProvider
    extends
        $FunctionalProvider<
          UserJobPreferences,
          UserJobPreferences,
          UserJobPreferences
        >
    with $Provider<UserJobPreferences> {
  /// Convenience provider for current user job preferences
  const CurrentUserJobPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserJobPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserJobPreferencesHash();

  @$internal
  @override
  $ProviderElement<UserJobPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserJobPreferences create(Ref ref) {
    return currentUserJobPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserJobPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserJobPreferences>(value),
    );
  }
}

String _$currentUserJobPreferencesHash() =>
    r'3abbb9040ff584286830387a85e0a8c2249dbf30';

/// Convenience provider for checking if user has preferences

@ProviderFor(hasUserPreferences)
const hasUserPreferencesProvider = HasUserPreferencesProvider._();

/// Convenience provider for checking if user has preferences

final class HasUserPreferencesProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Convenience provider for checking if user has preferences
  const HasUserPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasUserPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasUserPreferencesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasUserPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasUserPreferencesHash() =>
    r'56c7cf9a68616767e8d4850c9f81d12aff543fb1';

/// Convenience provider for last updated timestamp

@ProviderFor(userPreferencesLastUpdated)
const userPreferencesLastUpdatedProvider =
    UserPreferencesLastUpdatedProvider._();

/// Convenience provider for last updated timestamp

final class UserPreferencesLastUpdatedProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// Convenience provider for last updated timestamp
  const UserPreferencesLastUpdatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesLastUpdatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesLastUpdatedHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return userPreferencesLastUpdated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$userPreferencesLastUpdatedHash() =>
    r'6fa2b33dd0b4c6fbcf9154ca42086370341f7b14';
