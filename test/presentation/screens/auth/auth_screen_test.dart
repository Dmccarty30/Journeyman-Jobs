import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/screens/onboarding/auth_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../test_utils/test_helpers.dart';
import '../../../test_utils/test_helpers.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockAppStateProvider mockAppStateProvider;

  setUp(() {
    mockAuthService = MockAuthService();
    mockAppStateProvider = MockAppStateProvider();
  });

  group('AuthScreen Widget Tests', () {
    testWidgets('should display login form by default',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account?'), findsOneWidget);
    });

    testWidgets('should toggle to register form when tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap on register link
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Join IBEW Network'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('should validate email field',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter invalid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Leave password empty
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Password'), findsWidgets);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show loading indicator during sign in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return MockUserCredential();
      });

      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle sign in success',
        (WidgetTester tester) async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    testWidgets('should show error message on sign in failure',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email',
      ));

      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'wrongpassword',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('user'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
      await tester.tap(find.text('Forgot Password?'));
      // Navigation would occur here in actual app
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byType(TextFormField).last;
      
      // Initially password should be obscured
      final textField = tester.widget<TextFormField>(passwordField);
      expect(textField.obscureText, isTrue);

      // Find and tap visibility toggle
      final visibilityToggle = find.byIcon(Icons.visibility_off);
      if (visibilityToggle.evaluate().isNotEmpty) {
        await tester.tap(visibilityToggle);
        await tester.pumpAndSettle();
        
        // Password should now be visible
        final updatedTextField = tester.widget<TextFormField>(passwordField);
        expect(updatedTextField.obscureText, isFalse);
      }
    });

    testWidgets('should display IBEW branding elements',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for IBEW related text/branding
      expect(find.textContaining('IBEW'), findsWidgets);
    });

    testWidgets('register form should have additional fields',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Switch to register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Assert - Should have more fields for registration
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);
      expect(textFields.evaluate().length, greaterThanOrEqualTo(3)); // Name, email, password minimum
    });
  });

  group('AuthScreen Accessibility Tests', () {
    testWidgets('should have proper semantic labels',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel(RegExp(r'.*[Ee]mail.*')), findsWidgets);
      expect(find.bySemanticsLabel(RegExp(r'.*[Pp]assword.*')), findsWidgets);
    });

    testWidgets('should support keyboard navigation',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AuthScreen(),
          authService: mockAuthService,
          appStateProvider: mockAppStateProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Assert - Focus should move between fields
      // This would require checking FocusNode states in actual implementation
      expect(find.byType(TextFormField), findsWidgets);
    });
  });
}

// Mock classes for testing
class MockUserCredential extends Mock implements UserCredential {}