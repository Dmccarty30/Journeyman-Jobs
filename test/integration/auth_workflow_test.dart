import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../lib/providers/riverpod/auth_riverpod_provider.dart';
import '../../lib/providers/riverpod/user_preferences_riverpod_provider.dart';
import '../../lib/providers/riverpod/session_manager_provider.dart';
import '../../lib/screens/onboarding/auth_screen.dart';
import '../../lib/screens/home/home_screen.dart';
import '../../lib/navigation/app_router.dart';
import '../../lib/utils/error_handler.dart';
import '../../lib/models/user_model.dart';
import '../fixtures/mock_data.dart';
import '../test_config.dart';

import 'auth_workflow_test.mocks.dart';

/// Generate mocks
@GenerateMocks([ErrorHandler])
void main() {
  group('Authentication Workflow Integration Tests', () {
    late ProviderContainer container;
    late MockErrorHandler mockErrorHandler;
    late MockUser mockFirebaseUser;
    late FakeFirebaseFirestore mockFirestore;

    setUp(() {
      mockErrorHandler = MockErrorHandler();
      mockFirebaseUser = MockData.createMockFirebaseUser();
      mockFirestore = FakeFirebaseFirestore();

      container = ProviderContainer(
        overrides: [
          errorHandlerProvider.overrideWithValue(mockErrorHandler),
          // Override other dependencies as needed
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('complete sign in flow', (WidgetTester tester) async {
      // Arrange
      const email = 'test@ibew123.org';
      const password = 'SecurePassword123';
      final testUser = MockData.createTestUser(email: email);

      when(mockErrorHandler.handleAsyncOperation<String>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => 'mock_auth_token');

      when(mockErrorHandler.handleAsyncOperation<UserModel>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => testUser);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Wait for initial render
      await tester.pumpAndSettle();

      // Find email field
      final emailField = find.byKey(const Key('email_field'));
      expect(emailField, findsOneWidget);

      // Find password field
      final passwordField = find.byKey(const Key('password_field'));
      expect(passwordField, findsOneWidget);

      // Find sign in button
      final signInButton = find.byKey(const Key('sign_in_button'));
      expect(signInButton, findsOneWidget);

      // Enter credentials
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Assert - Should navigate to home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Welcome, ${testUser.displayName}'), findsOneWidget);
    });

    testWidgets('sign in with invalid credentials shows error', (WidgetTester tester) async {
      // Arrange
      when(mockErrorHandler.handleAsyncOperation<String>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for this email.',
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Assert - Error message should be shown
      expect(find.text('No user found for this email.'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('registration flow with validation', (WidgetTester tester) async {
      // Arrange
      const email = 'newuser@ibew123.org';
      const password = 'NewPassword123';
      const displayName = 'New User';
      const local = '3';
      const classifications = ['Inside Wireman'];

      final newUser = MockData.createTestUser(
        email: email,
        displayName: displayName,
        local: local,
        classifications: classifications,
      );

      when(mockErrorHandler.handleAsyncOperation<String>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => 'new_user_token');

      when(mockErrorHandler.handleAsyncOperation<UserModel>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => newUser);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to registration tab
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill registration form
      await tester.enterText(find.byKey(const Key('reg_email_field')), email);
      await tester.enterText(find.byKey(const Key('reg_password_field')), password);
      await tester.enterText(find.byKey(const Key('reg_confirm_password_field')), password);
      await tester.enterText(find.byKey(const Key('reg_display_name_field')), displayName);
      await tester.pumpAndSettle();

      // Select local
      await tester.tap(find.byKey(const Key('local_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Local 3').last);
      await tester.pumpAndSettle();

      // Select classification
      await tester.tap(find.byKey(const Key('classification_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inside Wireman'));
      await tester.pumpAndSettle();

      // Agree to terms
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Assert - Should show success message and navigate
      expect(find.text('Account created successfully!'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('password reset flow', (WidgetTester tester) async {
      // Arrange
      const email = 'test@ibew123.org';

      when(mockErrorHandler.handleAsyncOperation<void>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byKey(const Key('reset_email_field')), email);
      await tester.pumpAndSettle();

      // Send reset email
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle();

      // Assert - Should show success message
      expect(find.text('Password reset email sent!'), findsOneWidget);
      expect(find.text('Check your email for instructions'), findsOneWidget);
    });

    testWidgets('session persistence after sign in', (WidgetTester tester) async {
      // Arrange
      final testUser = MockData.createTestUser();

      when(mockErrorHandler.handleAsyncOperation<String>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => 'persistent_token');

      when(mockErrorHandler.handleAsyncOperation<UserModel>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => testUser);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Sign in
      await tester.enterText(find.byKey(const Key('email_field')), testUser.email);
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Simulate app restart
      await tester.pumpWidget(Container()); // Clear widget tree
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Should still be signed in
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('sign out flow and cleanup', (WidgetTester tester) async {
      // Arrange
      final testUser = MockData.createTestUser();

      when(mockErrorHandler.handleAsyncOperation<String>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => 'session_token');

      when(mockErrorHandler.handleAsyncOperation<UserModel>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async => testUser);

      when(mockErrorHandler.handleAsyncOperation<void>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Sign in first
      await tester.enterText(find.byKey(const Key('email_field')), testUser.email);
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Now sign out from home screen
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Confirm sign out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Assert - Should return to auth screen
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('network error handling in auth flow', (WidgetTester tester) async {
      // Arrange
      when(mockErrorHandler.handleAsyncOperation<String>(
        operation: anyNamed('operation'),
        operationName: anyNamed('operationName'),
        errorMessage: anyNamed('errorMessage'),
        showToast: anyNamed('showToast'),
      )).thenThrow(ErrorTestUtils.createNetworkError());

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errorHandlerProvider.overrideWithValue(mockErrorHandler),
          ],
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Attempt sign in
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Assert - Should show network error dialog
      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Please check your internet connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    group('Form Validation', () {
      testWidgets('validates email format', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
        await tester.pumpAndSettle();

        // Try to sign in
        await tester.tap(find.byKey(const Key('sign_in_button')));
        await tester.pumpAndSettle();

        // Assert - Should show email validation error
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('validates password strength', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to registration
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        // Enter weak password
        await tester.enterText(find.byKey(const Key('reg_password_field')), '123');
        await tester.pumpAndSettle();

        // Should show password strength indicator
        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('validates required fields', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Try to sign in without entering credentials
        await tester.tap(find.byKey(const Key('sign_in_button')));
        await tester.pumpAndSettle();

        // Assert - Should show field validation errors
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles rapid successive sign in attempts', (WidgetTester tester) async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return 'success_token';
        });

        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              errorHandlerProvider.overrideWithValue(mockErrorHandler),
            ],
            child: MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Fill credentials
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');

        // Rapid tap sign in button multiple times
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byKey(const Key('sign_in_button')));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // Assert - Should only process one sign in
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('handles session timeout', (WidgetTester tester) async {
        // This test would require mocking session timeout behavior
        // Implementation depends on how session timeout is handled
      });
    });
  });
}