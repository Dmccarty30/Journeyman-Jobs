import 'dart:ui';

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
import 'firebase_options.dart';
import 'design_system/app_theme.dart';
import 'navigation/app_router.dart';

// Global app lifecycle service for token validation on app resume
late AppLifecycleService _appLifecycleService;

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

  // Initialize app lifecycle monitoring for token validation on app resume
  // This ensures tokens are refreshed when app returns from background
  final authService = AuthService();
  _appLifecycleService = AppLifecycleService(authService);
  _appLifecycleService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize notifications after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.init(context);
    });

    return MaterialApp.router(
      title: 'Journeyman Jobs',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
