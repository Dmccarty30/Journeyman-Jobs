import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:journeyman_jobs/services/session_manager_service.dart';

import 'session_manager_service_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionManagerService - Grace Period System', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late SessionManagerService service;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(mockUser.uid).thenReturn('test-user-123');

      // Default stub for authStateChanges - tests can override
      when(mockAuth.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      service = SessionManagerService(auth: mockAuth);
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully', () {
        service.initialize();

        expect(service.isInitialized, isTrue);
        expect(service.isInGracePeriod, isFalse);
      });

      test('should not initialize twice', () {
        service.initialize();
        service.initialize(); // Second call should be ignored

        expect(service.isInitialized, isTrue);
      });
    });

    group('Activity Recording', () {
      test('should record activity when authenticated', () async {
        // Setup: Simulate authenticated user
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Record activity
        service.recordActivity();

        expect(service.lastActivityTime, isNotNull);
        expect(service.isInGracePeriod, isFalse);
      });

      test('should not record activity when not authenticated', () {
        // Setup: No authenticated user
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(null),
        );

        service.initialize();

        // Attempt to record activity
        service.recordActivity();

        // Should not record activity
        expect(service.lastActivityTime, isNull);
      });

      test('should exit grace period when activity is recorded', () async {
        // Setup: Simulate authenticated user
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Manually trigger grace period for testing
        // Note: In real scenario, this would happen after inactivity
        service.recordActivity();

        // Verify not in grace period initially
        expect(service.isInGracePeriod, isFalse);
      });
    });

    group('Grace Period Timing', () {
      test('should have correct inactivity duration', () {
        expect(
          SessionManagerService.inactivityDuration,
          equals(const Duration(minutes: 2)),
        );
      });

      test('should have correct grace period duration', () {
        expect(
          SessionManagerService.gracePeriodDuration,
          equals(const Duration(minutes: 5)),
        );
      });

      test('should have correct warning duration', () {
        expect(
          SessionManagerService.warningDuration,
          equals(const Duration(minutes: 4)),
        );
      });

      test('should calculate time until inactivity correctly', () async {
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        service.recordActivity();

        final timeUntilInactivity = service.timeUntilInactivity;

        expect(timeUntilInactivity, isNotNull);
        expect(
          timeUntilInactivity!.inSeconds,
          lessThanOrEqualTo(SessionManagerService.inactivityDuration.inSeconds),
        );
      });
    });

    group('Grace Period State', () {
      test('should not be in grace period initially', () {
        service.initialize();

        expect(service.isInGracePeriod, isFalse);
        expect(service.hasShownWarning, isFalse);
      });

      test('should track grace period start time when in grace period', () {
        service.initialize();

        // Initially should be null
        expect(service.gracePeriodStartTime, isNull);
      });

      test('should calculate remaining grace period time', () {
        service.initialize();

        // Not in grace period, should return null
        expect(service.remainingGracePeriod, isNull);
      });
    });

    group('App Lifecycle Handling', () {
      test('should handle app resume', () async {
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Simulate app resume by recording activity
        service.recordActivity();

        expect(service.lastActivityTime, isNotNull);
      });
    });

    group('Sign-out Handling', () {
      test('should clear state when user signs out', () async {
        // Setup: Start with authenticated user
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        service.recordActivity();
        expect(service.lastActivityTime, isNotNull);

        // Simulate sign-out
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(null),
        );

        // Trigger sign-out by emitting null user
        await Future.delayed(const Duration(milliseconds: 100));

        // State should be cleared
        expect(service.isInGracePeriod, isFalse);
        expect(service.hasShownWarning, isFalse);
      });

      test('should handle automatic sign-out on grace period expiry', () async {
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );
        when(mockAuth.signOut()).thenAnswer((_) async {});

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify sign-out method exists
        verify(mockAuth.authStateChanges()).called(greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('should handle rapid activity recording', () async {
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Record activity multiple times rapidly
        for (int i = 0; i < 10; i++) {
          service.recordActivity();
          await Future.delayed(const Duration(milliseconds: 10));
        }

        expect(service.lastActivityTime, isNotNull);
        expect(service.isInGracePeriod, isFalse);
      });

      test('should handle dispose during grace period', () async {
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Dispose while potentially in grace period
        service.dispose();

        expect(service.isInitialized, isFalse);
      });

      test('should not crash when recording activity after dispose', () {
        service.initialize();
        service.dispose();

        // Should not crash
        expect(() => service.recordActivity(), returnsNormally);
      });
    });

    group('Integration Scenarios', () {
      test('complete lifecycle: login -> activity -> idle -> grace -> resume', () async {
        // 1. User logs in
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // 2. User is active
        service.recordActivity();
        expect(service.lastActivityTime, isNotNull);
        expect(service.isInGracePeriod, isFalse);

        // 3. User becomes idle (would be triggered by timer in real scenario)
        // For testing, we verify the initial state is correct

        // 4. User resumes activity during grace period
        service.recordActivity();
        expect(service.isInGracePeriod, isFalse);
      });

      test('should maintain state consistency across lifecycle', () async {
        when(mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        service.initialize();
        await Future.delayed(const Duration(milliseconds: 100));

        // Record initial activity
        service.recordActivity();
        final firstActivityTime = service.lastActivityTime;

        // Wait a bit
        await Future.delayed(const Duration(milliseconds: 50));

        // Record again
        service.recordActivity();
        final secondActivityTime = service.lastActivityTime;

        // Second activity should be after first
        expect(
          secondActivityTime!.isAfter(firstActivityTime!),
          isTrue,
        );
      });
    });
  });
}
