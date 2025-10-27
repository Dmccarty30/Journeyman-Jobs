// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AuthService provider

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

/// AuthService provider

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// AuthService provider
  const AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'ed0872794ec8e4cb3f50cb37b9c0b9467eb51ddb';

/// Auth state stream provider

@ProviderFor(authStateStream)
const authStateStreamProvider = AuthStateStreamProvider._();

/// Auth state stream provider

final class AuthStateStreamProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Auth state stream provider
  const AuthStateStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateStreamHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authStateStream(ref);
  }
}

String _$authStateStreamHash() => r'945c7573a4c44c1e7821e357b4335dfab9831caf';

/// Provides the current authenticated user wrapped in AsyncValue.
///
/// Use this when you need to distinguish between loading state and unauthenticated state:
/// - AsyncValue.loading: Firebase Auth is still initializing
/// - AsyncValue.data(null): User is confirmed unauthenticated
/// - AsyncValue.data(User): User is authenticated
/// - AsyncValue.error: Auth initialization failed
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   data: (user) => user != null ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => ErrorScreen(error: err),
/// );
/// ```

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

/// Provides the current authenticated user wrapped in AsyncValue.
///
/// Use this when you need to distinguish between loading state and unauthenticated state:
/// - AsyncValue.loading: Firebase Auth is still initializing
/// - AsyncValue.data(null): User is confirmed unauthenticated
/// - AsyncValue.data(User): User is authenticated
/// - AsyncValue.error: Auth initialization failed
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   data: (user) => user != null ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => ErrorScreen(error: err),
/// );
/// ```

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<User?>,
          AsyncValue<User?>,
          AsyncValue<User?>
        >
    with $Provider<AsyncValue<User?>> {
  /// Provides the current authenticated user wrapped in AsyncValue.
  ///
  /// Use this when you need to distinguish between loading state and unauthenticated state:
  /// - AsyncValue.loading: Firebase Auth is still initializing
  /// - AsyncValue.data(null): User is confirmed unauthenticated
  /// - AsyncValue.data(User): User is authenticated
  /// - AsyncValue.error: Auth initialization failed
  ///
  /// Example usage:
  /// ```dart
  /// final authState = ref.watch(authStateProvider);
  /// authState.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   data: (user) => user != null ? HomeScreen() : LoginScreen(),
  ///   error: (err, stack) => ErrorScreen(error: err),
  /// );
  /// ```
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<User?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<User?> create(Ref ref) {
    return authState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<User?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<User?>>(value),
    );
  }
}

String _$authStateHash() => r'eca78ab53d4d10f44be53705bfb9d589e81f961f';

/// Simple provider that returns current user or null.
///
/// Returns null in two cases:
/// - Auth is still loading (Firebase initializing)
/// - User is confirmed unauthenticated
///
/// Use authState provider if you need to distinguish these states.
///
/// Example usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   // User is authenticated
/// }
/// ```

@ProviderFor(currentUser)
const currentUserProvider = CurrentUserProvider._();

/// Simple provider that returns current user or null.
///
/// Returns null in two cases:
/// - Auth is still loading (Firebase initializing)
/// - User is confirmed unauthenticated
///
/// Use authState provider if you need to distinguish these states.
///
/// Example usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   // User is authenticated
/// }
/// ```

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// Simple provider that returns current user or null.
  ///
  /// Returns null in two cases:
  /// - Auth is still loading (Firebase initializing)
  /// - User is confirmed unauthenticated
  ///
  /// Use authState provider if you need to distinguish these states.
  ///
  /// Example usage:
  /// ```dart
  /// final user = ref.watch(currentUserProvider);
  /// if (user != null) {
  ///   // User is authenticated
  /// }
  /// ```
  const CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'ae2c45fb2f8f20e35c87ebd7aad344c1d349bbca';

/// Tracks whether Firebase Auth has completed its initial state check.
///
/// Returns `AsyncValue<bool>`:
/// - `AsyncValue.loading`: Auth still initializing
/// - `AsyncValue.data(true)`: Auth initialized (user may be null or User object)
/// - `AsyncValue.error`: Auth initialization failed (but app continues)
///
/// Use this to show loading screens while auth initializes.
///
/// Example usage:
/// ```dart
/// final authInit = ref.watch(authInitializationProvider);
/// authInit.when(
///   loading: () => SplashScreen(),
///   data: (initialized) => initialized ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => HomeScreen(), // Continue on error
/// );
/// ```

@ProviderFor(AuthInitialization)
const authInitializationProvider = AuthInitializationProvider._();

/// Tracks whether Firebase Auth has completed its initial state check.
///
/// Returns `AsyncValue<bool>`:
/// - `AsyncValue.loading`: Auth still initializing
/// - `AsyncValue.data(true)`: Auth initialized (user may be null or User object)
/// - `AsyncValue.error`: Auth initialization failed (but app continues)
///
/// Use this to show loading screens while auth initializes.
///
/// Example usage:
/// ```dart
/// final authInit = ref.watch(authInitializationProvider);
/// authInit.when(
///   loading: () => SplashScreen(),
///   data: (initialized) => initialized ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => HomeScreen(), // Continue on error
/// );
/// ```
final class AuthInitializationProvider
    extends $AsyncNotifierProvider<AuthInitialization, bool> {
  /// Tracks whether Firebase Auth has completed its initial state check.
  ///
  /// Returns `AsyncValue<bool>`:
  /// - `AsyncValue.loading`: Auth still initializing
  /// - `AsyncValue.data(true)`: Auth initialized (user may be null or User object)
  /// - `AsyncValue.error`: Auth initialization failed (but app continues)
  ///
  /// Use this to show loading screens while auth initializes.
  ///
  /// Example usage:
  /// ```dart
  /// final authInit = ref.watch(authInitializationProvider);
  /// authInit.when(
  ///   loading: () => SplashScreen(),
  ///   data: (initialized) => initialized ? HomeScreen() : LoginScreen(),
  ///   error: (err, stack) => HomeScreen(), // Continue on error
  /// );
  /// ```
  const AuthInitializationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authInitializationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authInitializationHash();

  @$internal
  @override
  AuthInitialization create() => AuthInitialization();
}

String _$authInitializationHash() =>
    r'1d9c630c19f2b8d269db2560681a82f7d3a3330d';

/// Tracks whether Firebase Auth has completed its initial state check.
///
/// Returns `AsyncValue<bool>`:
/// - `AsyncValue.loading`: Auth still initializing
/// - `AsyncValue.data(true)`: Auth initialized (user may be null or User object)
/// - `AsyncValue.error`: Auth initialization failed (but app continues)
///
/// Use this to show loading screens while auth initializes.
///
/// Example usage:
/// ```dart
/// final authInit = ref.watch(authInitializationProvider);
/// authInit.when(
///   loading: () => SplashScreen(),
///   data: (initialized) => initialized ? HomeScreen() : LoginScreen(),
///   error: (err, stack) => HomeScreen(), // Continue on error
/// );
/// ```

abstract class _$AuthInitialization extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Auth state notifier for managing authentication operations

@ProviderFor(AuthNotifier)
const authProvider = AuthNotifierProvider._();

/// Auth state notifier for managing authentication operations
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  /// Auth state notifier for managing authentication operations
  const AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'e5373df5d0b99fb14216e487f206b7ea6f2ee9c7';

/// Auth state notifier for managing authentication operations

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Convenience provider for auth state

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Convenience provider for auth state

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Convenience provider for auth state
  const IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'ec341d95b490bda54e8278477e26f7b345844931';

/// Route guard provider

@ProviderFor(isRouteProtected)
const isRouteProtectedProvider = IsRouteProtectedFamily._();

/// Route guard provider

final class IsRouteProtectedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Route guard provider
  const IsRouteProtectedProvider._({
    required IsRouteProtectedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isRouteProtectedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isRouteProtectedHash();

  @override
  String toString() {
    return r'isRouteProtectedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isRouteProtected(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsRouteProtectedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isRouteProtectedHash() => r'dbeddd3719f65e93f561fe1263b1ff94a0ded4ab';

/// Route guard provider

final class IsRouteProtectedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsRouteProtectedFamily._()
    : super(
        retry: null,
        name: r'isRouteProtectedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Route guard provider

  IsRouteProtectedProvider call(String routePath) =>
      IsRouteProtectedProvider._(argument: routePath, from: this);

  @override
  String toString() => r'isRouteProtectedProvider';
}

/// Monitors session validity and triggers re-auth when session expires.
///
/// Checks session age every 5 minutes and invalidates sessions >24 hours old.
/// This ensures compliance with the 24-hour session requirement.
///
/// The monitor:
/// - Runs periodic checks every 5 minutes
/// - Validates session timestamp against 24-hour limit
/// - Automatically signs out expired sessions
/// - Cleans up timer on provider disposal
///
/// Example usage:
/// ```dart
/// final sessionValid = ref.watch(sessionMonitorProvider);
/// if (!sessionValid) {
///   // Session expired - user will be redirected to login
/// }
/// ```

@ProviderFor(SessionMonitor)
const sessionMonitorProvider = SessionMonitorProvider._();

/// Monitors session validity and triggers re-auth when session expires.
///
/// Checks session age every 5 minutes and invalidates sessions >24 hours old.
/// This ensures compliance with the 24-hour session requirement.
///
/// The monitor:
/// - Runs periodic checks every 5 minutes
/// - Validates session timestamp against 24-hour limit
/// - Automatically signs out expired sessions
/// - Cleans up timer on provider disposal
///
/// Example usage:
/// ```dart
/// final sessionValid = ref.watch(sessionMonitorProvider);
/// if (!sessionValid) {
///   // Session expired - user will be redirected to login
/// }
/// ```
final class SessionMonitorProvider
    extends $NotifierProvider<SessionMonitor, bool> {
  /// Monitors session validity and triggers re-auth when session expires.
  ///
  /// Checks session age every 5 minutes and invalidates sessions >24 hours old.
  /// This ensures compliance with the 24-hour session requirement.
  ///
  /// The monitor:
  /// - Runs periodic checks every 5 minutes
  /// - Validates session timestamp against 24-hour limit
  /// - Automatically signs out expired sessions
  /// - Cleans up timer on provider disposal
  ///
  /// Example usage:
  /// ```dart
  /// final sessionValid = ref.watch(sessionMonitorProvider);
  /// if (!sessionValid) {
  ///   // Session expired - user will be redirected to login
  /// }
  /// ```
  const SessionMonitorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionMonitorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionMonitorHash();

  @$internal
  @override
  SessionMonitor create() => SessionMonitor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sessionMonitorHash() => r'afaec5e1e00cdabce5ddddebd2ab9b948591d6cf';

/// Monitors session validity and triggers re-auth when session expires.
///
/// Checks session age every 5 minutes and invalidates sessions >24 hours old.
/// This ensures compliance with the 24-hour session requirement.
///
/// The monitor:
/// - Runs periodic checks every 5 minutes
/// - Validates session timestamp against 24-hour limit
/// - Automatically signs out expired sessions
/// - Cleans up timer on provider disposal
///
/// Example usage:
/// ```dart
/// final sessionValid = ref.watch(sessionMonitorProvider);
/// if (!sessionValid) {
///   // Session expired - user will be redirected to login
/// }
/// ```

abstract class _$SessionMonitor extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provides the current user's onboarding completion status from Firestore.
///
/// Returns `AsyncValue<bool>`:
/// - `AsyncValue.loading`: Checking onboarding status
/// - `AsyncValue.data(true)`: Onboarding is complete
/// - `AsyncValue.data(false)`: Onboarding is incomplete or user document doesn't exist
/// - `AsyncValue.error`: Error checking status
///
/// This is the source of truth for onboarding status (Firestore, not SharedPreferences).
/// Used by the router to redirect users to onboarding if incomplete.
///
/// Example usage:
/// ```dart
/// final onboardingStatus = ref.watch(onboardingStatusProvider);
/// onboardingStatus.when(
///   loading: () => CircularProgressIndicator(),
///   data: (isComplete) => isComplete ? HomeScreen() : OnboardingScreen(),
///   error: (err, stack) => ErrorScreen(error: err),
/// );
/// ```

@ProviderFor(onboardingStatus)
const onboardingStatusProvider = OnboardingStatusProvider._();

/// Provides the current user's onboarding completion status from Firestore.
///
/// Returns `AsyncValue<bool>`:
/// - `AsyncValue.loading`: Checking onboarding status
/// - `AsyncValue.data(true)`: Onboarding is complete
/// - `AsyncValue.data(false)`: Onboarding is incomplete or user document doesn't exist
/// - `AsyncValue.error`: Error checking status
///
/// This is the source of truth for onboarding status (Firestore, not SharedPreferences).
/// Used by the router to redirect users to onboarding if incomplete.
///
/// Example usage:
/// ```dart
/// final onboardingStatus = ref.watch(onboardingStatusProvider);
/// onboardingStatus.when(
///   loading: () => CircularProgressIndicator(),
///   data: (isComplete) => isComplete ? HomeScreen() : OnboardingScreen(),
///   error: (err, stack) => ErrorScreen(error: err),
/// );
/// ```

final class OnboardingStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Provides the current user's onboarding completion status from Firestore.
  ///
  /// Returns `AsyncValue<bool>`:
  /// - `AsyncValue.loading`: Checking onboarding status
  /// - `AsyncValue.data(true)`: Onboarding is complete
  /// - `AsyncValue.data(false)`: Onboarding is incomplete or user document doesn't exist
  /// - `AsyncValue.error`: Error checking status
  ///
  /// This is the source of truth for onboarding status (Firestore, not SharedPreferences).
  /// Used by the router to redirect users to onboarding if incomplete.
  ///
  /// Example usage:
  /// ```dart
  /// final onboardingStatus = ref.watch(onboardingStatusProvider);
  /// onboardingStatus.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   data: (isComplete) => isComplete ? HomeScreen() : OnboardingScreen(),
  ///   error: (err, stack) => ErrorScreen(error: err),
  /// );
  /// ```
  const OnboardingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStatusHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return onboardingStatus(ref);
  }
}

String _$onboardingStatusHash() => r'3df842eb0d17d677c8dbe0a127056b78473fedc7';
