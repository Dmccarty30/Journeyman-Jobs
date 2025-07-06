import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/auth_screen.dart';
import '../screens/onboarding/onboarding_steps_screen.dart';
import '../screens/nav_bar_page.dart';

// Placeholder screens for Phase 2
import '../screens/home/home_screen.dart';
import '../screens/jobs/jobs_screen.dart';
import '../screens/storm/storm_screen.dart';
import '../screens/locals/locals_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/more/account/profile_screen.dart';
import '../screens/more/support/help_support_screen.dart';
import '../screens/more/support/resources_screen.dart';
import '../screens/more/account/training_certificates_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/more/feedback/feedback_screen.dart';
import '../screens/tools/electrical_calculators_screen.dart';
import '../screens/notifications/notifications_screen.dart';

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
  static const String more = '/more';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String resources = '/resources';
  static const String training = '/training';
  static const String feedback = '/feedback';
  static const String electricalCalculators = '/electrical-calculators';
  static const String notifications = '/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: _redirect,
    routes: [
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
            builder: (context, state) => const UnionsWidget(),
          ),
          GoRoute(
            path: more,
            name: 'more',
            builder: (context, state) => const MoreScreen(),
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
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
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
    ),
  );

  /// Handles route redirection based on authentication state
  static String? _redirect(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;
    
    // Get the current location
    final location = state.matchedLocation;
    
    // Define public routes that don't require authentication
    final publicRoutes = [
      splash,
      welcome,
      auth,
      forgotPassword,
    ];
    
    // If user is not authenticated and trying to access protected route
    if (!isAuthenticated && !publicRoutes.contains(location)) {
      return welcome;
    }
    
    // If user is authenticated, we need to check onboarding status
    // Since redirect is synchronous, we'll handle this at the screen level
    // For now, just allow navigation and let screens handle onboarding checks
    
    // No redirection needed - let screens handle onboarding logic
    return null;
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
    return [home, jobs, storm, locals, more].contains(location);
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
      case more:
        return 4;
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
        return more;
      default:
        return home;
    }
  }
}