import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'design_system/app_theme.dart';
import 'navigation/app_router.dart';
import 'providers/app_state_provider.dart';
import 'providers/job_filter_provider.dart';
import 'services/auth_service.dart';
import 'services/resilient_firestore_service.dart';
import 'services/connectivity_service.dart';

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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ResilientFirestoreService>(create: (_) => ResilientFirestoreService()),
        ChangeNotifierProvider<ConnectivityService>(create: (_) => ConnectivityService()),
        
        // Filter provider (separate from main app state for performance)
        ChangeNotifierProvider<JobFilterProvider>(create: (_) => JobFilterProvider()),
        
        // Consolidated app state provider
        ChangeNotifierProxyProvider3<AuthService, ResilientFirestoreService, ConnectivityService, AppStateProvider>(
          create: (context) => AppStateProvider(
            context.read<AuthService>(),
            context.read<ResilientFirestoreService>(),
          ),
          update: (context, authService, firestoreService, connectivityService, previous) =>
              previous ?? AppStateProvider(authService, firestoreService),
        ),
      ],
      child: MaterialApp.router(
        title: 'Journeyman Jobs',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

