import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/app_theme.dart';
import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'providers/riverpod/theme_riverpod_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (safe for hot reload or multiple calls)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // 🔐 Ensure FirebaseAuth user before Firestore access
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    await FirebaseAuth.instance.signInAnonymously();
    debugPrint('✅ Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}');
  } else {
    debugPrint('✅ User already authenticated: ${user.uid}');
  }

  // 💾 Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024, // 100MB cache
  );

  // 🧠 Diagnostic Firestore connectivity test (optional, remove in prod)
  try {
    await FirebaseFirestore.instance.collection('diagnostics').add({
      'status': 'connected',
      'timestamp': DateTime.now(),
    });
    debugPrint('✅ Firestore connectivity verified.');
  } catch (e) {
    debugPrint('❌ Firestore connectivity failed: $e');
  }

  runApp(
    const ProviderScope(
      child: JourneymanJobsApp(),
    ),
  );
}

class JourneymanJobsApp extends ConsumerWidget {
  const JourneymanJobsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Journeyman Jobs',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeNotifierProvider),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        // Global error handler or overlays
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
