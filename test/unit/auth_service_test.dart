import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

// Note: To run these tests with mocks, you'll need to:
// 1. Add mockito to dev_dependencies
// 2. Run: flutter pub run build_runner build

@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService', () {
    test('should initialize with null current user', () {
      // This test will only work after Firebase is properly configured
      expect(authService.currentUser, isNull);
    });

    test('should provide auth state changes stream', () {
      // This test will only work after Firebase is properly configured
      expect(authService.authStateChanges, isA<Stream<User?>>());
    });

    group('Error Handling', () {
      test('should handle weak password error correctly', () {
        final exception = FirebaseAuthException(code: 'weak-password');
        final message = authService.handleAuthException(exception);
        expect(message, 'The password provided is too weak.');
      });

      test('should handle email already in use error correctly', () {
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        final message = authService.handleAuthException(exception);
        expect(message, 'An account already exists for that email.');
      });

      test('should handle invalid email error correctly', () {
        final exception = FirebaseAuthException(code: 'invalid-email');
        final message = authService.handleAuthException(exception);
        expect(message, 'The email address is not valid.');
      });
    });
  });
}
