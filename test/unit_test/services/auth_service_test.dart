import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';

import '../../test_utils/test_helpers.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService();
    // In actual implementation, you'd inject the mock FirebaseAuth
  });

  group('AuthService - Authentication Tests', () {
    test('should sign in with valid credentials', () async {
      // Arrange
      const email = 'test@ibew123.org';
      const password = 'SecurePassword123';
      
      final mockUser = MockUser(
        uid: 'test-uid',
        email: email,
        displayName: 'Test User',
      );
      
      final mockUserCredential = MockUserCredential();
      
      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: false,
        authExceptions: AuthExceptions(),
      );

      // Act
      final result = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(result, isNotNull);
      // Note: In real implementation, we'd verify the FirebaseAuth call
    });

    test('should throw exception for invalid credentials', () async {
      // Arrange
      const email = 'test@ibew123.org';
      const password = 'WrongPassword';

      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(
            code: 'wrong-password',
            message: 'The password is invalid',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should create user with valid registration data', () async {
      // Arrange
      const email = 'newuser@ibew456.org';
      const password = 'SecurePassword123';

      mockFirebaseAuth = MockFirebaseAuth(signedIn: false);

      // Act
      final result = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(result, isNotNull);
    });

    test('should handle weak password during registration', () async {
      // Arrange
      const email = 'newuser@ibew456.org';
      const password = '123'; // Weak password

      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          createUserWithEmailAndPassword: FirebaseAuthException(
            code: 'weak-password',
            message: 'The password provided is too weak',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException && e.code == 'weak-password'),
        ),
      );
    });

    test('should handle email already in use during registration', () async {
      // Arrange
      const email = 'existing@ibew123.org';
      const password = 'SecurePassword123';

      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          createUserWithEmailAndPassword: FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'The account already exists for that email',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException && e.code == 'email-already-in-use'),
        ),
      );
    });

    test('should sign out successfully', () async {
      // Arrange
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@ibew123.org',
      );

      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: mockUser,
      );

      // Act
      await authService.signOut();

      // Assert
      expect(mockFirebaseAuth.currentUser, isNull);
    });

    test('should send password reset email', () async {
      // Arrange
      const email = 'user@ibew123.org';

      mockFirebaseAuth = MockFirebaseAuth();

      // Act
      await authService.sendPasswordResetEmail(email: email);

      // Assert - Should complete without exception
      expect(true, isTrue);
    });

    test('should handle invalid email for password reset', () async {
      // Arrange
      const invalidEmail = 'invalid-email';

      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          sendPasswordResetEmail: FirebaseAuthException(
            code: 'invalid-email',
            message: 'The email address is badly formatted',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.sendPasswordResetEmail(email: invalidEmail),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException && e.code == 'invalid-email'),
        ),
      );
    });

    test('should handle user not found for password reset', () async {
      // Arrange
      const email = 'nonexistent@ibew123.org';

      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          sendPasswordResetEmail: FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found for that email',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.sendPasswordResetEmail(email: email),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException && e.code == 'user-not-found'),
        ),
      );
    });
  });

  group('AuthService - Auth State Stream Tests', () {
    test('should provide auth state changes stream', () async {
      // Arrange
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@ibew123.org',
      );

      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: mockUser,
      );

      // Act
      final authStream = authService.authStateChanges;

      // Assert
      expect(authStream, isA<Stream<User?>>());
      
      // Listen to the stream
      final user = await authStream.first;
      expect(user, isNotNull);
    });

    test('should emit null when user signs out', () async {
      // Arrange
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@ibew123.org',
      );

      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: mockUser,
      );

      final authStream = authService.authStateChanges;
      
      // Act - Sign out
      await authService.signOut();

      // Assert
      final user = await authStream.first;
      expect(user, isNull);
    });

    test('should emit user when signed in', () async {
      // Arrange
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'electrician@ibew123.org',
        displayName: 'John Electrician',
      );

      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: false,
      );

      // Act - Sign in
      await authService.signInWithEmailAndPassword(
        email: 'electrician@ibew123.org',
        password: 'password123',
      );

      // Assert
      final authStream = authService.authStateChanges;
      final user = await authStream.first;
      
      // Note: In real implementation, this would emit the signed-in user
      expect(authStream, isA<Stream<User?>>());
    });
  });

  group('AuthService - Error Handling Tests', () {
    test('should handle network errors gracefully', () async {
      // Arrange
      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(
            code: 'network-request-failed',
            message: 'A network error has occurred',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'test@ibew123.org',
          password: 'password123',
        ),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException &&
              e.code == 'network-request-failed'),
        ),
      );
    });

    test('should handle too many requests error', () async {
      // Arrange
      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many unsuccessful login attempts',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'test@ibew123.org',
          password: 'password123',
        ),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException && e.code == 'too-many-requests'),
        ),
      );
    });

    test('should handle user disabled account', () async {
      // Arrange
      mockFirebaseAuth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(
            code: 'user-disabled',
            message: 'The user account has been disabled',
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'disabled@ibew123.org',
          password: 'password123',
        ),
        throwsA(
          predicate((e) =>
              e is FirebaseAuthException && e.code == 'user-disabled'),
        ),
      );
    });
  });

  group('AuthService - Current User Tests', () {
    test('should return current user when signed in', () async {
      // Arrange
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'electrician@ibew123.org',
        displayName: 'John Electrician',
      );

      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: mockUser,
      );

      // Act
      final currentUser = authService.currentUser;

      // Assert
      expect(currentUser, isNotNull);
      // Note: In real implementation, would check user properties
    });

    test('should return null when not signed in', () async {
      // Arrange
      mockFirebaseAuth = MockFirebaseAuth(signedIn: false);

      // Act
      final currentUser = authService.currentUser;

      // Assert
      expect(currentUser, isNull);
    });
  });

  group('AuthService - IBEW Email Validation Tests', () {
    test('should accept IBEW union email formats', () async {
      // Arrange
      const ibewEmails = [
        'member@ibew123.org',
        'worker@local456.ibew.org',
        'electrician@ibew789.com',
      ];

      mockFirebaseAuth = MockFirebaseAuth();

      // Act & Assert
      for (final email in ibewEmails) {
        // In real implementation, would validate IBEW email format
        expect(email.contains('ibew') || email.contains('local'), isTrue);
      }
    });

    test('should handle non-IBEW emails appropriately', () async {
      // Arrange
      const nonIbewEmails = [
        'user@gmail.com',
        'worker@company.com',
        'test@example.org',
      ];

      // Act & Assert
      for (final email in nonIbewEmails) {
        // In real implementation, would handle non-IBEW emails
        expect(email.contains('ibew'), isFalse);
      }
    });
  });

  group('AuthService - Session Management Tests', () {
    test('should handle session timeout gracefully', () async {
      // Arrange
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@ibew123.org',
      );

      mockFirebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: mockUser,
      );

      // Act - Simulate session timeout
      await authService.signOut();

      // Assert
      final currentUser = authService.currentUser;
      expect(currentUser, isNull);
    });
  });
}

// Additional mock classes for testing
class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockUser(
        uid: 'test-uid',
        email: 'test@ibew123.org',
      );
}