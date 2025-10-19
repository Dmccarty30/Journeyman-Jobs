import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/screens/onboarding/auth_screen.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import '../../test_helpers/firebase_mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('AuthScreen Widget Tests', () {
    testWidgets('AuthScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(),
        ),
      );

      // Verify header elements are visible
      expect(find.text('Join Journeyman Jobs'), findsOneWidget);
      expect(find.text('Connect with electrical opportunities'), findsOneWidget);
      expect(find.byIcon(Icons.electrical_services), findsOneWidget);

      // Verify tab bar is visible
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Sign Up form displays all required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(),
        ),
      );

      // Default tab should be Sign Up
      await tester.pumpAndSettle();

      // Verify Sign Up form fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('Sign In form displays when tab is switched', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(),
        ),
      );

      // Tap on Sign In tab
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify Sign In form fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In', skipOffstage: false), findsNWidgets(2)); // Tab and button
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('Password visibility toggles correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the password field visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_outlined).first;
      expect(visibilityIcon, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Verify icon changed
      expect(find.byIcon(Icons.visibility_off_outlined).first, findsOneWidget);
    });

    testWidgets('Tab animation works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthScreen(),
        ),
      );

      // Initially on Sign Up tab
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);

      // Switch to Sign In tab
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify Sign In form is displayed
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Switch back to Sign Up tab
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify Sign Up form is displayed
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}