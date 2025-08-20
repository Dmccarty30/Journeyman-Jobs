import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/app_theme.dart';
import 'firebase_options.dart';
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

class JourneymanJobsApp extends ConsumerWidget {
  const JourneymanJobsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
      title: 'Journeyman Jobs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        // Add any global error handling or loading overlays here
        return child ?? const SizedBox.shrink();
      },
    );
}