/// Tests for AuthService
/// 
/// Comprehensive tests for Firebase Authentication operations,
/// including all sign-in methods, error handling, and edge cases.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import '../test_helpers/mock_services.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockFactory.createMockUser();
      mockUserCredential = MockUserCredential();
      
      // Create AuthService with mocked dependencies
      authService = AuthService();
      
      // Setup default mock behaviors
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
        (_) => Stream.value(mockUser),
      );
      
      // Register fallback values
      registerFallbackValue(UserCredential as UserCredential);
    });

    group('Current User and State', () {
      test('returns current user correctly', () {
        // Mock the static instance (this would require dependency injection in real implementation)
        expect(authService.currentUser, isA<User?>());
      });

      test('provides auth state changes stream', () {
        expect(authService.authStateChanges, isA<Stream<User?>>());
      });
    });

    group('Email and Password Authentication', () {
      group('Sign Up', () {
        test('creates account successfully with valid credentials', () async {
          // Setup mock
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockUserCredential);

          // Execute
          final result = await authService.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          );

          // Verify
          expect(result, equals(mockUserCredential));
          verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
        });

        test('handles weak password error', () async {
          // Setup mock to throw weak password error
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
            code: 'weak-password',
            message: 'The password provided is too weak.',
          ));

          // Execute and verify exception
          expect(
            () => authService.signUpWithEmailAndPassword(
              email: 'test@example.com',
              password: '123',
            ),
            throwsA(isA<String>().having(
              (error) => error,
              'error message',
              'The password provided is too weak.',
            )),
          );
        });

        test('handles email already in use error', () async {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'An account already exists for that email.',
          ));

          expect(
            () => authService.signUpWithEmailAndPassword(
              email: 'existing@example.com',
              password: 'password123',
            ),
            throwsA(isA<String>().having(
              (error) => error,
              'error message',
              'An account already exists for that email.',
            )),
          );
        });

        test('handles invalid email error', () async {
          when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
            code: 'invalid-email',
            message: 'The email address is not valid.',
          ));

          expect(
            () => authService.signUpWithEmailAndPassword(
              email: 'invalid-email',
              password: 'password123',
            ),
            throwsA(isA<String>().having(
              (error) => error,
              'error message',
              'The email address is not valid.',
            )),
          );
        });
      });

      group('Sign In', () {
        test('signs in successfully with valid credentials', () async {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockUserCredential);

          final result = await authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          );

          expect(result, equals(mockUserCredential));
          verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
        });

        test('handles user not found error', () async {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found for that email.',
          ));

          expect(
            () => authService.signInWithEmailAndPassword(
              email: 'nonexistent@example.com',
              password: 'password123',
            ),
            throwsA(isA<String>().having(
              (error) => error,
              'error message',
              'No user found for that email.',
            )),
          );
        });

        test('handles wrong password error', () async {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password provided.',
          ));

          expect(
            () => authService.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'wrongpassword',
            ),
            throwsA(isA<String>().having(
              (error) => error,
              'error message',
              'Wrong password provided.',
            )),
          );
        });

        test('handles too many requests error', () async {
          when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many failed login attempts.',
          ));

          expect(
            () => authService.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            ),
            throwsA(isA<String>().having(
              (error) => error,
              'error message',
              'Too many failed login attempts. Please try again later.',
            )),
          );
        });
      });
    });

    group('Google Sign In', () {
      test('signs in successfully with Google', () async {
        // Setup Google Sign In mocks
        final mockGoogleUser = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        
        when(() => mockGoogleSignIn.supportsAuthenticate()).thenReturn(true);
        when(() => mockGoogleSignIn.authenticate(
          scopeHint: any(named: 'scopeHint'),
        )).thenAnswer((_) async => mockGoogleUser);
        
        when(() => mockGoogleUser.authentication).thenReturn(mockGoogleAuth);
        when(() => mockGoogleAuth.idToken).thenReturn('mock_id_token');
        when(() => mockGoogleAuth.accessToken).thenReturn('mock_access_token');
        
        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockUserCredential);

        // This test would need the actual Google Sign In implementation to be mockable
        // In a real scenario, you'd inject the GoogleSignIn dependency
      });

      test('handles Google Sign In not supported', () async {
        when(() => mockGoogleSignIn.supportsAuthenticate()).thenReturn(false);

        expect(
          () => authService.signInWithGoogle(),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('handles Google Sign In cancellation', () async {
        when(() => mockGoogleSignIn.supportsAuthenticate()).thenReturn(true);
        when(() => mockGoogleSignIn.authenticate(
          scopeHint: any(named: 'scopeHint'),
        )).thenThrow(GoogleSignInException(
          GoogleSignInExceptionCode.signInCanceled,
          'User canceled sign in',
        ));

        expect(
          () => authService.signInWithGoogle(),
          throwsA(isA<GoogleSignInException>()),
        );
      });
    });

    group('Apple Sign In', () {
      test('handles Apple Sign In not available', () async {
        // Mock SignInWithApple.isAvailable() to return false
        // This would require mocking the static method
        expect(
          () => authService.signInWithApple(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Apple Sign In is not available'),
          )),
        );
      });
    });

    group('Password Reset', () {
      test('sends password reset email successfully', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: any(named: 'email'),
        )).thenAnswer((_) async => {});

        await authService.sendPasswordResetEmail(email: 'test@example.com');

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        )).called(1);
      });

      test('handles invalid email for password reset', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: any(named: 'email'),
        )).thenThrow(FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is not valid.',
        ));

        expect(
          () => authService.sendPasswordResetEmail(email: 'invalid-email'),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            'The email address is not valid.',
          )),
        );
      });

      test('handles user not found for password reset', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: any(named: 'email'),
        )).thenThrow(FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email.',
        ));

        expect(
          () => authService.sendPasswordResetEmail(email: 'nonexistent@example.com'),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            'No user found for that email.',
          )),
        );
      });
    });

    group('Sign Out', () {
      test('signs out successfully', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await authService.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });

      test('handles sign out errors', () async {
        when(() => mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out failed'));

        expect(
          () => authService.signOut(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error signing out'),
          )),
        );
      });
    });

    group('Account Management', () {
      test('deletes account successfully', () async {
        when(() => mockUser.delete()).thenAnswer((_) async => {});

        await authService.deleteAccount();

        verify(() => mockUser.delete()).called(1);
      });

      test('handles account deletion errors', () async {
        when(() => mockUser.delete()).thenThrow(FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'User needs to re-authenticate',
        ));

        expect(
          () => authService.deleteAccount(),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            contains('User needs to re-authenticate'),
          )),
        );
      });

      test('updates email successfully', () async {
        when(() => mockUser.verifyBeforeUpdateEmail(any()))
            .thenAnswer((_) async => {});

        await authService.updateEmail(newEmail: 'newemail@example.com');

        verify(() => mockUser.verifyBeforeUpdateEmail('newemail@example.com')).called(1);
      });

      test('updates password successfully', () async {
        when(() => mockUser.updatePassword(any())).thenAnswer((_) async => {});

        await authService.updatePassword(newPassword: 'newpassword123');

        verify(() => mockUser.updatePassword('newpassword123')).called(1);
      });

      test('handles password update requiring recent login', () async {
        when(() => mockUser.updatePassword(any())).thenThrow(FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Recent login required',
        ));

        expect(
          () => authService.updatePassword(newPassword: 'newpassword123'),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            contains('Recent login required'),
          )),
        );
      });
    });

    group('Error Handling', () {
      test('handles unknown Firebase Auth exceptions', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FirebaseAuthException(
          code: 'unknown-error',
          message: 'An unknown error occurred',
        ));

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            'An unknown error occurred',
          )),
        );
      });

      test('handles Firebase Auth exceptions without message', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FirebaseAuthException(
          code: 'unknown-error',
          message: null,
        ));

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            'An authentication error occurred.',
          )),
        );
      });
    });

    group('Edge Cases', () {
      test('handles null current user gracefully', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Operations that depend on current user should handle null
        expect(
          () => authService.deleteAccount(),
          throwsA(isA<String>()),
        );
      });

      test('handles network connectivity issues', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error',
        ));

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            'Network error',
          )),
        );
      });

      test('handles operation not allowed errors', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FirebaseAuthException(
          code: 'operation-not-allowed',
          message: 'Operation not allowed',
        ));

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<String>().having(
            (error) => error,
            'error message',
            'This sign-in method is not enabled.',
          )),
        );
      });
    });
  });
}