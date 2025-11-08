// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_timeout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton session timeout service instance.
///
/// This provider creates and manages the ConsolidatedSessionService lifecycle.
/// The service is initialized when first accessed and disposed when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionTimeoutServiceProvider);
/// await sessionService.initialize(); // After successful login
/// sessionService.recordActivity(); // On user interaction
/// await sessionService.endSession(); // On logout
/// ```

@ProviderFor(sessionTimeoutService)
const sessionTimeoutServiceProvider = SessionTimeoutServiceProvider._();

/// Provides the singleton session timeout service instance.
///
/// This provider creates and manages the ConsolidatedSessionService lifecycle.
/// The service is initialized when first accessed and disposed when the provider is disposed.
///
/// Example usage:
/// ```dart
/// final sessionService = ref.watch(sessionTimeoutServiceProvider);
/// await sessionService.initialize(); // After successful login
/// sessionService.recordActivity(); // On user interaction
/// await sessionService.endSession(); // On logout
/// ```

final class SessionTimeoutServiceProvider
    extends
        $FunctionalProvider<
          ConsolidatedSessionService,
          ConsolidatedSessionService,
          ConsolidatedSessionService
        >
    with $Provider<ConsolidatedSessionService> {
  /// Provides the singleton session timeout service instance.
  ///
  /// This provider creates and manages the ConsolidatedSessionService lifecycle.
  /// The service is initialized when first accessed and disposed when the provider is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// final sessionService = ref.watch(sessionTimeoutServiceProvider);
  /// await sessionService.initialize(); // After successful login
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
  $ProviderElement<ConsolidatedSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConsolidatedSessionService create(Ref ref) {
    return sessionTimeoutService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsolidatedSessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsolidatedSessionService>(value),
    );
  }
}

String _$sessionTimeoutServiceHash() =>
    r'd03c03eabf203a1f9f745756334b646acc1a4ebc';

/// Provider for the consolidated session service that handles all session management.
///
/// This is the preferred way to access session management functionality.
/// It prevents conflicts between multiple session services.

@ProviderFor(consolidatedSessionService)
const consolidatedSessionServiceProvider =
    ConsolidatedSessionServiceProvider._();

/// Provider for the consolidated session service that handles all session management.
///
/// This is the preferred way to access session management functionality.
/// It prevents conflicts between multiple session services.

final class ConsolidatedSessionServiceProvider
    extends
        $FunctionalProvider<
          ConsolidatedSessionService,
          ConsolidatedSessionService,
          ConsolidatedSessionService
        >
    with $Provider<ConsolidatedSessionService> {
  /// Provider for the consolidated session service that handles all session management.
  ///
  /// This is the preferred way to access session management functionality.
  /// It prevents conflicts between multiple session services.
  const ConsolidatedSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consolidatedSessionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consolidatedSessionServiceHash();

  @$internal
  @override
  $ProviderElement<ConsolidatedSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConsolidatedSessionService create(Ref ref) {
    return consolidatedSessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsolidatedSessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsolidatedSessionService>(value),
    );
  }
}

String _$consolidatedSessionServiceHash() =>
    r'59bab860b9b415e5bc4295faaefd3a6ed2149596';

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
    r'fe356d123668471f8a9d9550a011837f3fcd45e2';

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
