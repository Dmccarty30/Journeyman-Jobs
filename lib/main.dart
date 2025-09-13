import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'design_system/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if it hasn't been initialized yet
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Enable Firestore offline persistence for better user experience
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024, // 100MB cache
  );
  
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    const ProviderScope(
      child: JourneymanJobsApp(),
    ),
  );
}

/// Main application widget using ConsumerWidget for Riverpod integration.
/// This allows the root app to access Riverpod providers if needed.
class JourneymanJobsApp extends ConsumerWidget {
  const JourneymanJobsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Journeyman Jobs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      builder: (BuildContext context, Widget? child) {
        // Add any global error handling or loading overlays here
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

