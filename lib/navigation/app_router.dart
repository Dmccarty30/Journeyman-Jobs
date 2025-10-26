import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Providers
import '../providers/riverpod/auth_riverpod_provider.dart';
import '../utils/structured_logging.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/auth_screen.dart';
import '../screens/onboarding/onboarding_steps_screen.dart';
import '../screens/nav_bar_page.dart';
// import '../screens/crews/crews_screen.dart'; // Deprecated
import '../features/crews/screens/tailboard_screen.dart'; // New import for TailboardScreen
import '../features/crews/screens/create_crew_screen.dart'; // Import for CreateCrewScreen
import '../features/crews/screens/join_crew_screen.dart'; // Import for JoinCrewScreen
import '../features/crews/screens/crew_onboarding_screen.dart'; // Import for CrewOnboardingScreen
import '../features/crews/screens/crew_chat_screen.dart'; // Import for CrewChatScreen
import '../features/crews/screens/crew_invitations_screen.dart'; // Import for CrewInvitationsScreen

// Placeholder screens for Phase 2
import '../screens/home/home_screen.dart';
import '../screens/jobs/jobs_screen.dart';
import '../screens/storm/storm_screen.dart';
import '../screens/locals/locals_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/account/profile_screen.dart';
import '../screens/settings/support/help_support_screen.dart';
import '../screens/settings/support/resources_screen.dart';
import '../screens/settings/account/training_certificates_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/settings/feedback/feedback_screen.dart';
import '../screens/tools/electrical_calculators_screen.dart';
import '../screens/tools/transformer_reference_screen.dart';
import '../screens/tools/transformer_workbench_screen.dart';
import '../screens/tools/transformer_bank_screen.dart';
import '../screens/tools/electrical_components_showcase_screen.dart';
import '../models/transformer_models.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/app_settings_screen.dart';

part 'app_router.g.dart';

/// Notifier that triggers GoRouter refresh when auth state changes.
///
/// This class implements ChangeNotifier to work with GoRouter's refreshListenable.
/// It watches auth and onboarding state changes via Riverpod and notifies the
/// router to re-evaluate navigation guards when state changes.
///
/// Without this, the router would only check auth on initial navigation,
/// causing auth state to appear "lost" during bottom navigation.
class _RouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterRefreshNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen<AsyncValue<User?>>(
      authStateProvider,
      (previous, next) {
        // Notify router to refresh when auth state changes
        debugPrint('[RouterRefresh] Auth state changed - triggering router refresh');
        notifyListeners();
      },
    );

    // Listen to onboarding status changes
    _ref.listen<AsyncValue<bool>>(
      onboardingStatusProvider,
      (previous, next) {
        // Notify router to refresh when onboarding status changes
        debugPrint('[RouterRefresh] Onboarding status changed - triggering router refresh');
        notifyListeners();
      },
    );
  }
}

/// Provider for the GoRouter instance with auth state reactivity.
///
/// This provider creates a router that automatically refreshes when
/// auth state or onboarding status changes, ensuring navigation guards
/// always have up-to-date authentication information.
@riverpod
GoRouter router(Ref ref) {
  return AppRouter.createRouter(ref);
}

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String storm = '/storm';
  static const String locals = '/locals';
  static const String crews = '/crews'; // Route for TailboardScreen
  static const String createCrew = '/crews/create'; // Kept for onboarding
  static const String joinCrew = '/crews/join'; // Kept for onboarding
  static const String crewOnboarding = '/crews/onboarding'; // New route for Crew Onboarding
  static const String crewInvitations = '/crews/invitations'; // Route for CrewInvitationsScreen
  static const String crewChat = '/crews/chat'; // Route for CrewChatScreen
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String resources = '/resources';
  static const String training = '/training';
  static const String feedback = '/feedback';
  static const String electricalCalculators = '/electrical-calculators';
  static const String transformerReference = '/tools/transformer-reference';
  static const String transformerWorkbench = '/tools/transformer-workbench';
  static const String transformerBank = '/tools/transformer-bank';
  static const String electricalShowcase = '/tools/electrical-showcase';
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notification-settings';
  static const String appSettings = '/settings/app';

  /// Creates a router instance configured with Riverpod integration.
  ///
  /// The [ref] parameter allows the router to watch auth state changes
  /// and automatically refresh when the user signs in/out.
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) => _redirect(context, state, ref),
      // Listen to auth state changes to trigger router refresh
      // This ensures navigation guards re-evaluate when auth state changes
      refreshListenable: _RouterRefreshNotifier(ref),
      routes: _buildRoutes(),
      errorBuilder: _buildErrorScreen,
    );
  }

  /// Legacy router getter for backward compatibility.
  ///
  /// Note: This version doesn't support auth state reactivity.
  /// Use createRouter(ref) instead for proper auth integration.
  @Deprecated('Use createRouter(ref) instead for proper auth state reactivity')
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: (context, state) {
      // This version can't access Riverpod properly - will be removed
      debugPrint('[Router] WARNING: Using deprecated router without Riverpod integration');
      return null;
    },
    routes: _buildRoutes(),
    errorBuilder: _buildErrorScreen,
  );

  /// Builds the route configuration.
  ///
  /// Extracted to allow reuse between legacy and provider-aware routers.
  static List<RouteBase> _buildRoutes() => [
      // Public routes (no authentication required)
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingStepsScreen(),
      ),

      // Protected routes (authentication required)
      // Main navigation shell
      ShellRoute(
        builder: (context, state, child) {
          return NavBarPage(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: jobs,
            name: 'jobs',
            builder: (context, state) => const JobsScreen(),
          ),
          GoRoute(
            path: storm,
            name: 'storm',
            builder: (context, state) => const StormScreen(),
          ),
          GoRoute(
            path: locals,
            name: 'locals',
            builder: (context, state) => const LocalsScreen(),
          ),
          GoRoute(
            path: crews,
            name: 'crews',
            builder: (context, state) => const TailboardScreen(),
          ),
          GoRoute(
            path: createCrew,
            name: 'create-crew',
            builder: (context, state) => const CreateCrewScreen(),
          ),
          GoRoute(
            path: joinCrew,
            name: 'join-crew',
            builder: (context, state) => const JoinCrewScreen(),
          ),
          GoRoute(
            path: crewOnboarding,
            name: 'crew-onboarding',
            builder: (context, state) => const CrewOnboardingScreen(),
          ),
          GoRoute(
            path: crewInvitations,
            name: 'crew-invitations',
            builder: (context, state) => const CrewInvitationsScreen(),
          ),
          GoRoute(
            path: '$crewChat/:crewId',
            name: 'crew-chat',
            builder: (context, state) {
              final crewId = state.pathParameters['crewId']!;
              final args = state.extra as Map<String, String>? ?? {};
              final crewName = args['crewName'] ?? 'Crew Chat';
              final directMessageTo = args['directMessageTo'];
              final memberName = args['memberName'];

              return CrewChatScreen(
                crewId: crewId,
                crewName: crewName,
                directMessageTo: directMessageTo,
                memberName: memberName,
              );
            },
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Additional protected routes (outside main navigation)
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: help,
        name: 'help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: resources,
        name: 'resources',
        builder: (context, state) => const ResourcesScreen(),
      ),
      GoRoute(
        path: training,
        name: 'training',
        builder: (context, state) => const TrainingCertificatesScreen(),
      ), 
      GoRoute(
        path: feedback,
        name: 'feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: electricalCalculators,
        name: 'electrical-calculators',
        builder: (context, state) => const ElectricalCalculatorsScreen(),
      ),
      GoRoute(
        path: transformerReference,
        name: 'transformer-reference',
        builder: (context, state) => const TransformerReferenceScreen(),
      ),
      GoRoute(
        path: transformerWorkbench,
        name: 'transformer-workbench',
        builder: (context, state) => const TransformerWorkbenchScreen(
          bankType: TransformerBankType.wyeToWye,
          mode: TrainingMode.guided,
          difficulty: DifficultyLevel.beginner,
        ),
      ),
      GoRoute(
        path: transformerBank,
        name: 'transformer-bank',
        builder: (context, state) => const TransformerBankScreen(),
      ),
      GoRoute(
        path: electricalShowcase,
        name: 'electrical-showcase',
        builder: (context, state) => const ElectricalComponentsShowcaseScreen(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: notificationSettings,
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: appSettings,
        name: 'app-settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),
    ];

  /// Builds the error screen for 404/invalid routes.
  static Widget _buildErrorScreen(BuildContext context, GoRouterState state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles route redirection based on authentication state and onboarding status.
  ///
  /// Uses Riverpod providers to check:
  /// - Auth initialization status (authInitializationProvider)
  /// - User authentication state (authStateProvider)
  /// - Onboarding completion status (onboardingStatusProvider) - from Firestore
  ///
  /// Redirect logic:
  /// 1. During auth initialization -> allow navigation (screens show loading)
  /// 2. Unauthenticated user on protected route -> redirect to /auth with return URL
  /// 3. Authenticated user with incomplete onboarding -> redirect to /onboarding
  /// 4. Authenticated user on /auth or /welcome -> redirect to intended destination or /home
  /// 5. Public routes always accessible
  ///
  /// Query parameters:
  /// - `redirect`: Captures the original destination for post-login navigation
  ///
  /// Example: `/locals` -> `/auth?redirect=%2Flocals` -> successful login -> `/locals`
  ///
  /// Parameters:
  /// - context: BuildContext for accessing theme and navigation
  /// - state: GoRouterState containing current location and query parameters
  /// - ref: Ref for accessing Riverpod providers (reactive auth state)
  static String? _redirect(BuildContext context, GoRouterState state, Ref ref) {
    // Read auth state from Riverpod providers
    // Using ref.read instead of container ensures reactivity when auth changes
    final authInit = ref.read(authInitializationProvider);
    final authState = ref.read(authStateProvider);

    // Get current location
    final currentPath = state.matchedLocation;

    // Define public routes (accessible without authentication)
    // DEV MODE: Added 'crews' for development testing
    // TODO: Remove 'crews' from publicRoutes before production deployment
    const publicRoutes = [
      splash,
      welcome,
      auth,
      forgotPassword,
      onboarding,
    ];

    // If auth is still initializing, allow navigation
    // Screens will handle loading state with skeleton screens (Wave 3)
    if (authInit.isLoading) {
      return null;
    }

    // Determine if current route requires authentication
    final requiresAuth = !publicRoutes.contains(currentPath);

    // Get current user (null if not authenticated or still loading)
    // In Riverpod 3.x, we use pattern matching instead of valueOrNull
    final user = authState.whenOrNull(
      data: (user) => user,
    );
    final isAuthenticated = user != null;
    StructuredLogger.info(
      'DEBUG Router._redirect',
      category: LogCategory.authentication,
      context: {
        'currentPath': currentPath,
        'authInitializing': authInit.isLoading,
        'isAuthenticated': isAuthenticated,
      },
    );

    // Protected route accessed by unauthenticated user -> redirect to login
    if (requiresAuth && !isAuthenticated) {
      // Capture original destination for post-login redirect
      // Don't redirect if already on a public route to avoid loops
      if (currentPath != auth && currentPath != welcome) {
        return '$auth?redirect=${Uri.encodeComponent(currentPath)}';
      }
      return auth;
    }

    // Authenticated user trying to access login/welcome -> redirect first
    // This prevents onboarding check from interfering with welcome screen flow
    if (isAuthenticated && (currentPath == auth || currentPath == welcome)) {
      // Check for redirect parameter (user was sent to login from protected route)
      final redirect = state.uri.queryParameters['redirect'];

      if (redirect != null && redirect.isNotEmpty) {
        // Decode and navigate to original destination
        final decodedRedirect = Uri.decodeComponent(redirect);

        // Validate redirect path to prevent open redirect vulnerabilities
        if (_isValidRedirectPath(decodedRedirect)) {
          return decodedRedirect;
        }
      }

      // Default: redirect authenticated users to home
      return home;
    }

    // Check onboarding status for authenticated users (except on public routes)
    // This runs AFTER welcome/auth redirect to avoid interfering with those flows
    if (isAuthenticated && currentPath != onboarding && currentPath != auth && currentPath != welcome && currentPath != splash) {
      // Get onboarding status from Firestore
      final onboardingStatusAsync = ref.read(onboardingStatusProvider);
      final onboardingComplete = onboardingStatusAsync.whenOrNull(
        data: (isComplete) => isComplete,
      ) ?? false;

      // Redirect to onboarding if incomplete
      if (!onboardingComplete) {
        return onboarding;
      }
    }

    // Allow navigation
    return null;
  }

  /// Validates redirect paths to prevent open redirect vulnerabilities.
  ///
  /// Only allows internal app routes (must start with /).
  /// Prevents redirects to external URLs or malicious paths.
  ///
  /// Valid: /home, /locals, /jobs/123
  /// Invalid: https://evil.com, //evil.com, javascript:alert(1)
  static bool _isValidRedirectPath(String path) {
    // Must start with / and not be a protocol-relative URL
    if (!path.startsWith('/') || path.startsWith('//')) {
      return false;
    }

    // Must not contain protocol schemes
    if (path.contains('://')) {
      return false;
    }

    // Path is valid internal route
    return true;
  }

  /// Navigate to a specific route and clear the navigation stack
  static void goAndClearStack(BuildContext context, String location) {
    while (context.canPop()) {
      context.pop();
    }
    context.go(location);
  }

  /// Navigate to home and clear navigation stack
  static void goHome(BuildContext context) {
    goAndClearStack(context, home);
  }

  /// Navigate to welcome screen (for logout)
  static void goToWelcome(BuildContext context) {
    goAndClearStack(context, welcome);
  }

  /// Navigate to auth screen
  static void goToAuth(BuildContext context) {
    context.go(auth);
  }

  /// Navigate to onboarding
  static void goToOnboarding(BuildContext context) {
    context.go(onboarding);
  }

  /// Check if current route is in main navigation
  static bool isMainNavigationRoute(String location) {
    return [home, jobs, storm, locals, crews, settings].contains(location);
  }

  /// Get the index of the current tab for bottom navigation
  static int getTabIndex(String location) {
    switch (location) {
      case home:
        return 0;
      case jobs:
        return 1;
      case storm:
        return 2;
      case locals:
        return 3;
      case crews: // New case for Crews
        return 4;
      case settings:
        return 5;
      default:
        return 0;
    }
  }

  /// Get the route path for a given tab index
  static String getRouteForTab(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return jobs;
      case 2:
        return storm;
      case 3:
        return locals;
      case 4:
        return crews; // New case for Crews
      case 5:
        return settings;
      default:
        return home;
    }
  }
}
