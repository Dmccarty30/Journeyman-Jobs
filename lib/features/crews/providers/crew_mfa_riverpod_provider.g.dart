// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_mfa_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// CrewMFAService provider

@ProviderFor(crewMFAService)
const crewMFAServiceProvider = CrewMFAServiceProvider._();

/// CrewMFAService provider

final class CrewMFAServiceProvider
    extends $FunctionalProvider<CrewMFAService, CrewMFAService, CrewMFAService>
    with $Provider<CrewMFAService> {
  /// CrewMFAService provider
  const CrewMFAServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crewMFAServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crewMFAServiceHash();

  @$internal
  @override
  $ProviderElement<CrewMFAService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrewMFAService create(Ref ref) {
    return crewMFAService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrewMFAService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrewMFAService>(value),
    );
  }
}

String _$crewMFAServiceHash() => r'8ffff4a3caf3567c01b71f1e2e34b4e5c751b7db';

/// Provider for checking if user can enable MFA

@ProviderFor(canEnableMFA)
const canEnableMFAProvider = CanEnableMFAProvider._();

/// Provider for checking if user can enable MFA

final class CanEnableMFAProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if user can enable MFA
  const CanEnableMFAProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canEnableMFAProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canEnableMFAHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canEnableMFA(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canEnableMFAHash() => r'b31c9f638563b722cfba458cf068b93520637594';

/// Provider for getting MFA status for current user

@ProviderFor(userMFAStatus)
const userMFAStatusProvider = UserMFAStatusProvider._();

/// Provider for getting MFA status for current user

final class UserMFAStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<MFAStatus?>,
          AsyncValue<MFAStatus?>,
          AsyncValue<MFAStatus?>
        >
    with $Provider<AsyncValue<MFAStatus?>> {
  /// Provider for getting MFA status for current user
  const UserMFAStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userMFAStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userMFAStatusHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MFAStatus?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MFAStatus?> create(Ref ref) {
    return userMFAStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MFAStatus?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MFAStatus?>>(value),
    );
  }
}

String _$userMFAStatusHash() => r'076eae95870db92bebf3b797810bb5a1449c9a65';

/// Provider for checking if MFA is enabled for current user

@ProviderFor(isMFAEnabled)
const isMFAEnabledProvider = IsMFAEnabledProvider._();

/// Provider for checking if MFA is enabled for current user

final class IsMFAEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if MFA is enabled for current user
  const IsMFAEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMFAEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isMFAEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMFAEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMFAEnabledHash() => r'09a3a0cbadef4d0b2a04ed3d5c038a81f09add3e';

/// Provider for checking if MFA is required for operations

@ProviderFor(isMFARequired)
const isMFARequiredProvider = IsMFARequiredProvider._();

/// Provider for checking if MFA is required for operations

final class IsMFARequiredProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if MFA is required for operations
  const IsMFARequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMFARequiredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isMFARequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMFARequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMFARequiredHash() => r'871e6291daf5aa254870aa82b896c47cec96bfc3';

/// Provider for MFA setup notifier

@ProviderFor(mfaSetupNotifier)
const mfaSetupProvider = MfaSetupNotifierProvider._();

/// Provider for MFA setup notifier

final class MfaSetupNotifierProvider
    extends
        $FunctionalProvider<
          MFASetupNotifier,
          MFASetupNotifier,
          MFASetupNotifier
        >
    with $Provider<MFASetupNotifier> {
  /// Provider for MFA setup notifier
  const MfaSetupNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaSetupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaSetupNotifierHash();

  @$internal
  @override
  $ProviderElement<MFASetupNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MFASetupNotifier create(Ref ref) {
    return mfaSetupNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MFASetupNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MFASetupNotifier>(value),
    );
  }
}

String _$mfaSetupNotifierHash() => r'57a3740b472dd68ec2c831601813c2768bebde27';

/// Stream of MFA setup state

@ProviderFor(mfaSetupState)
const mfaSetupStateProvider = MfaSetupStateProvider._();

/// Stream of MFA setup state

final class MfaSetupStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<MFASetupResult?>,
          AsyncValue<MFASetupResult?>,
          AsyncValue<MFASetupResult?>
        >
    with $Provider<AsyncValue<MFASetupResult?>> {
  /// Stream of MFA setup state
  const MfaSetupStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaSetupStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaSetupStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MFASetupResult?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MFASetupResult?> create(Ref ref) {
    return mfaSetupState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MFASetupResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MFASetupResult?>>(value),
    );
  }
}

String _$mfaSetupStateHash() => r'87d2bef02f524154b41c60467b997fa36d5ed241';

/// Provider for MFA verification notifier

@ProviderFor(mfaVerificationNotifier)
const mfaVerificationProvider = MfaVerificationNotifierProvider._();

/// Provider for MFA verification notifier

final class MfaVerificationNotifierProvider
    extends
        $FunctionalProvider<
          MFAVerificationNotifier,
          MFAVerificationNotifier,
          MFAVerificationNotifier
        >
    with $Provider<MFAVerificationNotifier> {
  /// Provider for MFA verification notifier
  const MfaVerificationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaVerificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaVerificationNotifierHash();

  @$internal
  @override
  $ProviderElement<MFAVerificationNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MFAVerificationNotifier create(Ref ref) {
    return mfaVerificationNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MFAVerificationNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MFAVerificationNotifier>(value),
    );
  }
}

String _$mfaVerificationNotifierHash() =>
    r'6bd9dfd3817b6ceeba6e07ee446f3e7e13b45444';

/// Stream of MFA verification state

@ProviderFor(mfaVerificationState)
const mfaVerificationStateProvider = MfaVerificationStateProvider._();

/// Stream of MFA verification state

final class MfaVerificationStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<MFASession?>,
          AsyncValue<MFASession?>,
          AsyncValue<MFASession?>
        >
    with $Provider<AsyncValue<MFASession?>> {
  /// Stream of MFA verification state
  const MfaVerificationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaVerificationStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaVerificationStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MFASession?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MFASession?> create(Ref ref) {
    return mfaVerificationState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MFASession?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MFASession?>>(value),
    );
  }
}

String _$mfaVerificationStateHash() =>
    r'96b1aeb3926a73a1ee8c5ba00f3801ff329b89fb';

/// Provider for MFA session notifier

@ProviderFor(mfaSessionNotifier)
const mfaSessionProvider = MfaSessionNotifierProvider._();

/// Provider for MFA session notifier

final class MfaSessionNotifierProvider
    extends
        $FunctionalProvider<
          MFASessionNotifier,
          MFASessionNotifier,
          MFASessionNotifier
        >
    with $Provider<MFASessionNotifier> {
  /// Provider for MFA session notifier
  const MfaSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaSessionNotifierHash();

  @$internal
  @override
  $ProviderElement<MFASessionNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MFASessionNotifier create(Ref ref) {
    return mfaSessionNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MFASessionNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MFASessionNotifier>(value),
    );
  }
}

String _$mfaSessionNotifierHash() =>
    r'5287adb5e2bfc6448fba442ecbbdacd769a43964';

/// Stream of MFA session state

@ProviderFor(mfaSessionState)
const mfaSessionStateProvider = MfaSessionStateProvider._();

/// Stream of MFA session state

final class MfaSessionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<void>,
          AsyncValue<void>,
          AsyncValue<void>
        >
    with $Provider<AsyncValue<void>> {
  /// Stream of MFA session state
  const MfaSessionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaSessionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaSessionStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<void>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<void> create(Ref ref) {
    return mfaSessionState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$mfaSessionStateHash() => r'1d226974cb32a719e959ee127b7a2326a348732f';
