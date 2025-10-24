// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_timeout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton session timeout service instance.
///
/// This provider creates and manages the SessionTimeoutService lifecycle.
/// The service is initialized when first accessed and disposed when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionTimeoutServiceProvider);
/// await sessionService.startSession(); // After successful login
/// sessionService.recordActivity(); // On user interaction
/// await sessionService.endSession(); // On logout
/// ```

@ProviderFor(sessionTimeoutService)
const sessionTimeoutServiceProvider = SessionTimeoutServiceProvider._();

/// Provides the singleton session timeout service instance.
///
/// This provider creates and manages the SessionTimeoutService lifecycle.
/// The service is initialized when first accessed and disposed when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionTimeoutServiceProvider);
/// await sessionService.startSession(); // After successful login
/// sessionService.recordActivity(); // On user interaction
/// await sessionService.endSession(); // On logout
/// ```

final class SessionTimeoutServiceProvider
    extends
        $FunctionalProvider<
          SessionTimeoutService,
          SessionTimeoutService,
          SessionTimeoutService
        >
    with $Provider<SessionTimeoutService> {
  /// Provides the singleton session timeout service instance.
  ///
  /// This provider creates and manages the SessionTimeoutService lifecycle.
  /// The service is initialized when first accessed and disposed when the provider is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// final sessionService = ref.watch(sessionTimeoutServiceProvider);
  /// await sessionService.startSession(); // After successful login
  /// sessionService.recordActivity(); // On user interaction
  /// await sessionService.endSession(); // On logout
  /// ```
  const SessionTimeoutServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionTimeoutServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionTimeoutServiceHash();

  @$internal
  @override
  $ProviderElement<SessionTimeoutService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionTimeoutService create(Ref ref) {
    return sessionTimeoutService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionTimeoutService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionTimeoutService>(value),
    );
  }
}

String _$sessionTimeoutServiceHash() =>
    r'7f294cd6b2166c6144c2860a5eef7794fc835182';

/// Manages session timeout state and coordinates with auth system.
///
/// This notifier:
/// - Monitors authentication state changes
/// - Starts/stops session timeout monitoring based on auth state
/// - Handles timeout events and triggers logout
/// - Updates session state for UI consumers
///
/// The notifier automatically:
/// - Starts session monitoring when user authenticates
/// - Stops session monitoring when user logs out
/// - Triggers logout when session times out
///
/// Example usage:
/// ```dart
/// final sessionState = ref.watch(sessionTimeoutNotifierProvider);
/// if (sessionState.isActive) {
///   final timeLeft = sessionState.timeUntilTimeout;
///   // Show timeout warning if needed
/// }
/// ```

@ProviderFor(SessionTimeoutNotifier)
const sessionTimeoutProvider = SessionTimeoutNotifierProvider._();

/// Manages session timeout state and coordinates with auth system.
///
/// This notifier:
/// - Monitors authentication state changes
/// - Starts/stops session timeout monitoring based on auth state
/// - Handles timeout events and triggers logout
/// - Updates session state for UI consumers
///
/// The notifier automatically:
/// - Starts session monitoring when user authenticates
/// - Stops session monitoring when user logs out
/// - Triggers logout when session times out
///
/// Example usage:
/// ```dart
/// final sessionState = ref.watch(sessionTimeoutNotifierProvider);
/// if (sessionState.isActive) {
///   final timeLeft = sessionState.timeUntilTimeout;
///   // Show timeout warning if needed
/// }
/// ```
final class SessionTimeoutNotifierProvider
    extends $NotifierProvider<SessionTimeoutNotifier, SessionState> {
  /// Manages session timeout state and coordinates with auth system.
  ///
  /// This notifier:
  /// - Monitors authentication state changes
  /// - Starts/stops session timeout monitoring based on auth state
  /// - Handles timeout events and triggers logout
  /// - Updates session state for UI consumers
  ///
  /// The notifier automatically:
  /// - Starts session monitoring when user authenticates
  /// - Stops session monitoring when user logs out
  /// - Triggers logout when session times out
  ///
  /// Example usage:
  /// ```dart
  /// final sessionState = ref.watch(sessionTimeoutNotifierProvider);
  /// if (sessionState.isActive) {
  ///   final timeLeft = sessionState.timeUntilTimeout;
  ///   // Show timeout warning if needed
  /// }
  /// ```
  const SessionTimeoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionTimeoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionTimeoutNotifierHash();

  @$internal
  @override
  SessionTimeoutNotifier create() => SessionTimeoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionTimeoutNotifierHash() =>
    r'd7716e61be4da32d5f81d656278974099e30f864';

/// Manages session timeout state and coordinates with auth system.
///
/// This notifier:
/// - Monitors authentication state changes
/// - Starts/stops session timeout monitoring based on auth state
/// - Handles timeout events and triggers logout
/// - Updates session state for UI consumers
///
/// The notifier automatically:
/// - Starts session monitoring when user authenticates
/// - Stops session monitoring when user logs out
/// - Triggers logout when session times out
///
/// Example usage:
/// ```dart
/// final sessionState = ref.watch(sessionTimeoutNotifierProvider);
/// if (sessionState.isActive) {
///   final timeLeft = sessionState.timeUntilTimeout;
///   // Show timeout warning if needed
/// }
/// ```

abstract class _$SessionTimeoutNotifier extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
