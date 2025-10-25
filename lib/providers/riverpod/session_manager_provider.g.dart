// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton SessionManagerService instance.
///
/// This provider creates and manages the SessionManagerService lifecycle.
/// The service is initialized when first accessed and properly disposed
/// when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionManager = ref.watch(sessionManagerProvider);
/// sessionManager.recordActivity(); // Record user activity
///
/// // Check if in grace period
/// if (sessionManager.isInGracePeriod) {
///   final remaining = sessionManager.remainingGracePeriod;
///   // Show warning with countdown
/// }
/// ```

@ProviderFor(sessionManager)
const sessionManagerProvider = SessionManagerProvider._();

/// Provides the singleton SessionManagerService instance.
///
/// This provider creates and manages the SessionManagerService lifecycle.
/// The service is initialized when first accessed and properly disposed
/// when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionManager = ref.watch(sessionManagerProvider);
/// sessionManager.recordActivity(); // Record user activity
///
/// // Check if in grace period
/// if (sessionManager.isInGracePeriod) {
///   final remaining = sessionManager.remainingGracePeriod;
///   // Show warning with countdown
/// }
/// ```

final class SessionManagerProvider
    extends
        $FunctionalProvider<
          SessionManagerService,
          SessionManagerService,
          SessionManagerService
        >
    with $Provider<SessionManagerService> {
  /// Provides the singleton SessionManagerService instance.
  ///
  /// This provider creates and manages the SessionManagerService lifecycle.
  /// The service is initialized when first accessed and properly disposed
  /// when the provider is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// final sessionManager = ref.watch(sessionManagerProvider);
  /// sessionManager.recordActivity(); // Record user activity
  ///
  /// // Check if in grace period
  /// if (sessionManager.isInGracePeriod) {
  ///   final remaining = sessionManager.remainingGracePeriod;
  ///   // Show warning with countdown
  /// }
  /// ```
  const SessionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionManagerHash();

  @$internal
  @override
  $ProviderElement<SessionManagerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionManagerService create(Ref ref) {
    return sessionManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionManagerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionManagerService>(value),
    );
  }
}

String _$sessionManagerHash() => r'8e98893baad04e5dcfd5576c789fb5c2a3fec34e';
