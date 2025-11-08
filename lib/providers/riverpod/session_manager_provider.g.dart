// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton ConsolidatedSessionService instance.
///
/// This provider creates and manages the ConsolidatedSessionService lifecycle.
/// The service is initialized when first accessed and properly disposed
/// when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionManagerProvider);
/// sessionService.recordActivity(); // Record user activity
///
/// // Check if in grace period
/// if (sessionService.isInGracePeriod) {
///   final remaining = sessionService.remainingGracePeriod;
///   // Show warning with countdown
/// }
/// ```

@ProviderFor(sessionManager)
const sessionManagerProvider = SessionManagerProvider._();

/// Provides the singleton ConsolidatedSessionService instance.
///
/// This provider creates and manages the ConsolidatedSessionService lifecycle.
/// The service is initialized when first accessed and properly disposed
/// when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionManagerProvider);
/// sessionService.recordActivity(); // Record user activity
///
/// // Check if in grace period
/// if (sessionService.isInGracePeriod) {
///   final remaining = sessionService.remainingGracePeriod;
///   // Show warning with countdown
/// }
/// ```

final class SessionManagerProvider
    extends
        $FunctionalProvider<
          ConsolidatedSessionService,
          ConsolidatedSessionService,
          ConsolidatedSessionService
        >
    with $Provider<ConsolidatedSessionService> {
  /// Provides the singleton ConsolidatedSessionService instance.
  ///
  /// This provider creates and manages the ConsolidatedSessionService lifecycle.
  /// The service is initialized when first accessed and properly disposed
  /// when the provider is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// final sessionService = ref.watch(sessionManagerProvider);
  /// sessionService.recordActivity(); // Record user activity
  ///
  /// // Check if in grace period
  /// if (sessionService.isInGracePeriod) {
  ///   final remaining = sessionService.remainingGracePeriod;
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
  $ProviderElement<ConsolidatedSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConsolidatedSessionService create(Ref ref) {
    return sessionManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsolidatedSessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsolidatedSessionService>(value),
    );
  }
}

String _$sessionManagerHash() => r'8a33bb865f2afb14c48e231dd32f29d81c994b64';
