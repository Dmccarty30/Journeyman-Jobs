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
    r'a09411cca76b432fefb5777930f0fea0699a6cfa';

/// User preferences notifier for managing user job preferences

abstract class _$UserPreferencesNotifier
    extends $Notifier<UserPreferencesState> {
  UserPreferencesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserPreferencesState, UserPreferencesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserPreferencesState, UserPreferencesState>,
        UserPreferencesState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Convenience provider for user preferences

@ProviderFor(userPreferences)
const userPreferencesFunctionalProvider = UserPreferencesProvider._();

/// Convenience provider for user preferences

final class UserPreferencesProvider extends $FunctionalProvider<
    UserJobPreferences,
    UserJobPreferences,
    UserJobPreferences> with $Provider<UserJobPreferences> {
  /// Convenience provider for user preferences
  const UserPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userPreferencesFunctionalProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesHash();

  @$internal
  @override
  $ProviderElement<UserJobPreferences> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserJobPreferences create(Ref ref) {
    return userPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserJobPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserJobPreferences>(value),
    );
  }
}

String _$userPreferencesHash() => r'ae9edce7eb90b6ed8cbe1ae42f9221e7f6389302';

/// Convenience provider for checking if user has preferences

@ProviderFor(hasUserPreferences)
const hasUserPreferencesProvider = HasUserPreferencesProvider._();

/// Convenience provider for checking if user has preferences

final class HasUserPreferencesProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
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
    r'eac7e1f05f32c381ca952e10656bd39db56ee1b3';

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
    r'63370bc5f1bfd068a8d2c40f32a49d2ed11fa180';
