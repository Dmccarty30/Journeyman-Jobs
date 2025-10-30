// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_message_encryption_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// CrewMessageEncryptionService provider

@ProviderFor(crewMessageEncryptionService)
const crewMessageEncryptionServiceProvider =
    CrewMessageEncryptionServiceProvider._();

/// CrewMessageEncryptionService provider

final class CrewMessageEncryptionServiceProvider
    extends
        $FunctionalProvider<
          CrewMessageEncryptionService,
          CrewMessageEncryptionService,
          CrewMessageEncryptionService
        >
    with $Provider<CrewMessageEncryptionService> {
  /// CrewMessageEncryptionService provider
  const CrewMessageEncryptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crewMessageEncryptionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crewMessageEncryptionServiceHash();

  @$internal
  @override
  $ProviderElement<CrewMessageEncryptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrewMessageEncryptionService create(Ref ref) {
    return crewMessageEncryptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrewMessageEncryptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrewMessageEncryptionService>(value),
    );
  }
}

String _$crewMessageEncryptionServiceHash() =>
    r'87cc6c751ac76314a3ec944f83cdea16a5cc9999';

/// Provider for checking if user can use encryption

@ProviderFor(canUseEncryption)
const canUseEncryptionProvider = CanUseEncryptionProvider._();

/// Provider for checking if user can use encryption

final class CanUseEncryptionProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if user can use encryption
  const CanUseEncryptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canUseEncryptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canUseEncryptionHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canUseEncryption(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canUseEncryptionHash() => r'5ce5f94bf140190b7d7f7714c02dc6a5bba14acd';

/// Provider for getting encryption status for current user

@ProviderFor(userEncryptionStatus)
const userEncryptionStatusProvider = UserEncryptionStatusProvider._();

/// Provider for getting encryption status for current user

final class UserEncryptionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<EncryptionStatus?>,
          AsyncValue<EncryptionStatus?>,
          AsyncValue<EncryptionStatus?>
        >
    with $Provider<AsyncValue<EncryptionStatus?>> {
  /// Provider for getting encryption status for current user
  const UserEncryptionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userEncryptionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userEncryptionStatusHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<EncryptionStatus?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EncryptionStatus?> create(Ref ref) {
    return userEncryptionStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EncryptionStatus?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EncryptionStatus?>>(
        value,
      ),
    );
  }
}

String _$userEncryptionStatusHash() =>
    r'1e655d7509d7359cb2d3d3e7bae80b362f109452';

/// Provider for checking if encryption is enabled for current user

@ProviderFor(isEncryptionEnabled)
const isEncryptionEnabledProvider = IsEncryptionEnabledProvider._();

/// Provider for checking if encryption is enabled for current user

final class IsEncryptionEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if encryption is enabled for current user
  const IsEncryptionEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isEncryptionEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isEncryptionEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isEncryptionEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isEncryptionEnabledHash() =>
    r'502e5083865e3cbacf4314d115eb37e3bf2d45f0';

/// Provider for checking if encryption key rotation is required

@ProviderFor(isKeyRotationRequired)
const isKeyRotationRequiredProvider = IsKeyRotationRequiredProvider._();

/// Provider for checking if encryption key rotation is required

final class IsKeyRotationRequiredProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if encryption key rotation is required
  const IsKeyRotationRequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isKeyRotationRequiredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isKeyRotationRequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isKeyRotationRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isKeyRotationRequiredHash() =>
    r'52297c60f23ae334fbd80ee1097112ec46d8d72c';

/// Provider for encryption setup notifier

@ProviderFor(encryptionSetupNotifier)
const encryptionSetupProvider = EncryptionSetupNotifierProvider._();

/// Provider for encryption setup notifier

final class EncryptionSetupNotifierProvider
    extends
        $FunctionalProvider<
          EncryptionSetupNotifier,
          EncryptionSetupNotifier,
          EncryptionSetupNotifier
        >
    with $Provider<EncryptionSetupNotifier> {
  /// Provider for encryption setup notifier
  const EncryptionSetupNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'encryptionSetupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$encryptionSetupNotifierHash();

  @$internal
  @override
  $ProviderElement<EncryptionSetupNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EncryptionSetupNotifier create(Ref ref) {
    return encryptionSetupNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EncryptionSetupNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EncryptionSetupNotifier>(value),
    );
  }
}

String _$encryptionSetupNotifierHash() =>
    r'001d4179ed67c1eafebac469d7b2126803f0423e';

/// Stream of encryption setup state

@ProviderFor(encryptionSetupState)
const encryptionSetupStateProvider = EncryptionSetupStateProvider._();

/// Stream of encryption setup state

final class EncryptionSetupStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<EncryptionKeyPair?>,
          AsyncValue<EncryptionKeyPair?>,
          AsyncValue<EncryptionKeyPair?>
        >
    with $Provider<AsyncValue<EncryptionKeyPair?>> {
  /// Stream of encryption setup state
  const EncryptionSetupStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'encryptionSetupStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$encryptionSetupStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<EncryptionKeyPair?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EncryptionKeyPair?> create(Ref ref) {
    return encryptionSetupState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EncryptionKeyPair?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EncryptionKeyPair?>>(
        value,
      ),
    );
  }
}

String _$encryptionSetupStateHash() =>
    r'962429a583634253bbac9bab5354e5a2f13a356c';

/// Provider for message encryption notifier

@ProviderFor(messageEncryptionNotifier)
const messageEncryptionProvider = MessageEncryptionNotifierProvider._();

/// Provider for message encryption notifier

final class MessageEncryptionNotifierProvider
    extends
        $FunctionalProvider<
          MessageEncryptionNotifier,
          MessageEncryptionNotifier,
          MessageEncryptionNotifier
        >
    with $Provider<MessageEncryptionNotifier> {
  /// Provider for message encryption notifier
  const MessageEncryptionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageEncryptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageEncryptionNotifierHash();

  @$internal
  @override
  $ProviderElement<MessageEncryptionNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MessageEncryptionNotifier create(Ref ref) {
    return messageEncryptionNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageEncryptionNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageEncryptionNotifier>(value),
    );
  }
}

String _$messageEncryptionNotifierHash() =>
    r'603a211615dfb292a236af949358f2831443a446';

/// Stream of message encryption state

@ProviderFor(messageEncryptionState)
const messageEncryptionStateProvider = MessageEncryptionStateProvider._();

/// Stream of message encryption state

final class MessageEncryptionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<EncryptedMessage?>,
          AsyncValue<EncryptedMessage?>,
          AsyncValue<EncryptedMessage?>
        >
    with $Provider<AsyncValue<EncryptedMessage?>> {
  /// Stream of message encryption state
  const MessageEncryptionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageEncryptionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageEncryptionStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<EncryptedMessage?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EncryptedMessage?> create(Ref ref) {
    return messageEncryptionState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EncryptedMessage?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EncryptedMessage?>>(
        value,
      ),
    );
  }
}

String _$messageEncryptionStateHash() =>
    r'5431506c79cc804b648e3ccc8383bdaee0e3cebb';

/// Provider for encryption statistics and monitoring

@ProviderFor(encryptionStatistics)
const encryptionStatisticsProvider = EncryptionStatisticsProvider._();

/// Provider for encryption statistics and monitoring

final class EncryptionStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EncryptionStatistics>,
          AsyncValue<EncryptionStatistics>,
          AsyncValue<EncryptionStatistics>
        >
    with $Provider<AsyncValue<EncryptionStatistics>> {
  /// Provider for encryption statistics and monitoring
  const EncryptionStatisticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'encryptionStatisticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$encryptionStatisticsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<EncryptionStatistics>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EncryptionStatistics> create(Ref ref) {
    return encryptionStatistics(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EncryptionStatistics> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<EncryptionStatistics>>(
        value,
      ),
    );
  }
}

String _$encryptionStatisticsHash() =>
    r'42afeaef9cb4cf0c1e993841ec22679c228fdbcb';
