import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/services/notification_service.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/services/app_lifecycle_service.dart';
import 'package:journeyman_jobs/services/session_timeout_service.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_initialization_service.dart';
import 'package:journeyman_jobs/widgets/activity_detector.dart';
import 'package:journeyman_jobs/widgets/session_activity_detector.dart';
import 'package:journeyman_jobs/widgets/grace_period_warning_banner.dart';
import 'firebase_options.dart';
import 'design_system/app_theme.dart';
import 'navigation/app_router.dart'; // For route constants
import 'navigation/app_router.dart' show routerProvider; // For the router provider
import 'providers/riverpod/hierarchical_riverpod_provider.dart';
// import 'providers/riverpod/theme_riverpod_provider.dart'; // DISABLED: Not needed while forcing light mode

// Global app lifecycle service for token validation on app resume
late AppLifecycleService _appLifecycleService;

// Global session timeout service for inactivity tracking
late SessionTimeoutService _sessionTimeoutService;

// Global hierarchical initialization service
late HierarchicalInitializationService _hierarchicalInitializationService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if it hasn't been initialized yet
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firebase Performance Monitoring
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

    // Initialize Firebase Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Configure Firebase Auth persistence to maintain user session across app restarts
  // Note: setPersistence() is only supported on web platforms
  // On mobile (Android/iOS), auth state is automatically persisted by default
  // Token validity will be validated by AuthService for limited offline support
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Enable Firestore offline persistence for better user experience
  // Note: Cache limited to 100MB to prevent excessive local storage usage; monitor for eviction issues in production
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024, // 100MB
  );

  // Initialize session timeout service for inactivity tracking
  // This handles auto-logout after 10 minutes of inactivity
  _sessionTimeoutService = SessionTimeoutService();
  await _sessionTimeoutService.initialize();

  // Initialize app lifecycle monitoring for token validation on app resume
  // This ensures tokens are refreshed when app returns from background
  // and handles auto-logout when app is closed
  final authService = AuthService();
  _appLifecycleService = AppLifecycleService(authService, _sessionTimeoutService);
  _appLifecycleService.initialize();

  // Initialize hierarchical data service for IBEW Union → Local → Member → Job hierarchy
  // This provides efficient loading and caching of hierarchical data
  _hierarchicalInitializationService = HierarchicalInitializationService();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notifications after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.init(context);
    });

    // Watch the router provider to get reactive auth state integration
    final router = ref.watch(routerProvider);
    // TEMPORARY FIX: Disabled theme mode provider to force light mode globally
    // This prevents the app from switching to dark mode based on device settings
    // TODO: Re-enable after fixing JJTextField component to respect theme colors
    // final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Journeyman Jobs',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light, // FIXED: Force light mode to ensure text visibility in TextFields
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // Wrap the entire app with activity detectors and grace period warning
      // This monitors all gestures and shows warnings when session is about to expire
      builder: (context, child) {
        return SessionActivityDetector(
          child: Column(
            children: [
              // Grace period warning banner (only shows when in grace period)
              const GracePeriodWarningBanner(),
              // Main app content
              Expanded(
                child: ActivityDetector(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
