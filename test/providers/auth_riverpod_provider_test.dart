import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../../lib/providers/riverpod/auth_riverpod_provider.dart';
import '../../lib/providers/riverpod/error_handling_provider.dart';
import '../../lib/utils/error_handler.dart';
import '../../lib/models/user_model.dart';
import '../fixtures/mock_data.dart';
import '../test_config.dart';

import 'auth_riverpod_provider_test.mocks.dart';

/// Generate mocks
@GenerateMocks([ErrorHandler])
void main() {
  group('AuthRiverpodProvider Tests', () {
    late ProviderContainer container;
    late MockErrorHandler mockErrorHandler;
    late MockUser mockFirebaseUser;

    setUp(() {
      mockErrorHandler = MockErrorHandler();
      mockFirebaseUser = MockData.createMockFirebaseUser();

      container = ProviderContainer(
        overrides: [
          errorHandlerProvider.overrideWithValue(mockErrorHandler),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('AuthNotifier', () {
      test('should initialize with unauthenticated state', () {
        // Arrange & Act
        final authState = container.read(authProvider);

        // Assert
        expect(authState.isLoading, isFalse);
        expect(authState.user, isNull);
        expect(authState.error, isNull);
      });

      test('should sign in user successfully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
          context: anyNamed('context'),
        )).thenAnswer((_) async => 'test_token');

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        verify(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: 'signIn',
          errorMessage: 'Failed to sign in',
          showToast: true,
        )).called(1);
      });

      test('should handle sign in error', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenThrow(Exception('Invalid credentials'));

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
      });

      test('should register user successfully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<UserModel>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async => MockData.createTestUser());

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.registerWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'password123',
          displayName: 'New User',
          local: '3',
          classifications: ['Inside Wireman'],
        );

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<UserModel>(
          operation: anyNamed('operation'),
          operationName: 'register',
          errorMessage: 'Failed to create account',
          showToast: true,
        )).called(1);
      });

      test('should sign out user successfully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async {});

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signOut();

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: 'signOut',
          errorMessage: 'Failed to sign out',
          showToast: false,
        )).called(1);
      });

      test('should reset password successfully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async {});

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.resetPassword(email: 'test@example.com');

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: 'resetPassword',
          errorMessage: 'Failed to reset password',
          showToast: true,
        )).called(1);
      });

      test('should clear error state', () {
        // Arrange - First simulate an error
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(Exception('Test error'));

        final notifier = container.read(authProvider.notifier);

        // Act
        notifier.clearError();

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNull);
      });

      test('should update user profile successfully', () async {
        // Arrange
        final testUser = MockData.createTestUser();
        when(mockErrorHandler.handleAsyncOperation<UserModel>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async => testUser);

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.updateProfile(displayName: 'Updated Name');

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<UserModel>(
          operation: anyNamed('operation'),
          operationName: 'updateProfile',
          errorMessage: 'Failed to update profile',
          showToast: true,
        )).called(1);
      });

      test('should reload user successfully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<UserModel>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async => MockData.createTestUser());

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.reloadUser();

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<UserModel>(
          operation: anyNamed('operation'),
          operationName: 'reloadUser',
          errorMessage: 'Failed to reload user',
          showToast: false,
        )).called(1);
      });
    });

    group('Computed Providers', () {
      test('currentUserProvider should return user from auth state', () {
        // Arrange
        final testUser = MockData.createTestUser();
        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith((ref) => AuthState(
              user: testUser,
              isLoading: false,
              error: null,
            )),
          ],
        );

        // Act
        final currentUser = container.read(currentUserProvider);

        // Assert
        expect(currentUser, equals(testUser));
      });

      test('isAuthenticatedProvider should return true when user exists', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith((ref) => AuthState(
              user: MockData.createTestUser(),
              isLoading: false,
              error: null,
            )),
          ],
        );

        // Act
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // Assert
        expect(isAuthenticated, isTrue);
      });

      test('isAuthenticatedProvider should return false when user is null', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith((ref) => const AuthState(
              user: null,
              isLoading: false,
              error: null,
            )),
          ],
        );

        // Act
        final isAuthenticated = container.read(isAuthenticatedProvider);

        // Assert
        expect(isAuthenticated, isFalse);
      });

      test('authLoadingProvider should return loading state', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith((ref) => const AuthState(
              user: null,
              isLoading: true,
              error: null,
            )),
          ],
        );

        // Act
        final isLoading = container.read(authLoadingProvider);

        // Assert
        expect(isLoading, isTrue);
      });

      test('authErrorProvider should return error state', () {
        // Arrange
        const testError = 'Test error message';
        container = ProviderContainer(
          overrides: [
            authProvider.overrideWith((ref) => const AuthState(
              user: null,
              isLoading: false,
              error: testError,
            )),
          ],
        );

        // Act
        final error = container.read(authErrorProvider);

        // Assert
        expect(error, equals(testError));
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(ErrorTestUtils.createNetworkError());

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('Network'));
      });

      test('should handle timeout errors gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(ErrorTestUtils.createTimeoutError());

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('timeout'));
      });

      test('should handle auth errors gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(ErrorTestUtils.createAuthError(
          code: 'user-not-found',
          message: 'User not found',
        ));

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'nonexistent@example.com',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('User not found'));
      });
    });

    group('State Persistence', () {
      test('should maintain state across provider reads', () {
        // Arrange
        final notifier = container.read(authProvider.notifier);

        // Act
        notifier.clearError();

        // Assert - Multiple reads should return same state
        final state1 = container.read(authProvider);
        final state2 = container.read(authProvider);
        expect(identical(state1, state2), isFalse); // Different instances
        expect(state1.error, equals(state2.error)); // Same values
      });
    });

    group('Edge Cases', () {
      test('should handle empty email gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(Exception('Email cannot be empty'));

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: '',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
      });

      test('should handle empty password gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(Exception('Password cannot be empty'));

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: '',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
      });

      test('should handle invalid email format gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<String>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(Exception('Invalid email format'));

        // Act
        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmailAndPassword(
          email: 'invalid-email',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('Invalid email'));
      });
    });
  });
}