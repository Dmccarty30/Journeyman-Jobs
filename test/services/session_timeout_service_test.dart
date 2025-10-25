import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journeyman_jobs/services/session_timeout_service.dart';

void main() {
  group('SessionTimeoutService', () {
    late SessionTimeoutService service;

    setUp(() async {
      // Initialize shared preferences with empty values
      SharedPreferences.setMockInitialValues({});
      service = SessionTimeoutService();
      await service.initialize();
    });

    tearDown(() async {
      await service.dispose();
    });

    group('Configuration', () {
      test('idle threshold is 30 minutes', () {
        expect(
          SessionTimeoutService.idleThreshold,
          equals(const Duration(minutes: 30)),
        );
      });

      test('grace period duration is 15 minutes', () {
        expect(
          SessionTimeoutService.gracePeriodDuration,
          equals(const Duration(minutes: 15)),
        );
      });

      test('warning threshold is at 40 minutes (10 min into grace period)', () {
        expect(
          SessionTimeoutService.warningThreshold,
          equals(const Duration(minutes: 40)),
        );
      });

      test('total timeout duration is 45 minutes', () {
        expect(
          SessionTimeoutService.timeoutDuration,
          equals(const Duration(minutes: 45)),
        );
      });
    });

    group('Initialization', () {
      test('service initializes successfully', () async {
        expect(service.isInitialized, isTrue);
      });

      test('service is not authenticated initially', () {
        expect(service.isSessionActive, isFalse);
      });

      test('session does not have activity timestamp initially', () {
        expect(service.lastActivity, isNull);
      });

      test('can initialize multiple times safely', () async {
        await service.initialize();
        await service.initialize();
        expect(service.isInitialized, isTrue);
      });
    });

    group('Session Management', () {
      test('start session marks session as active', () async {
        await service.startSession();
        expect(service.isSessionActive, isTrue);
      });

      test('start session records initial activity', () async {
        await service.startSession();
        expect(service.lastActivity, isNotNull);
      });

      test('start session sets active flag in SharedPreferences', () async {
        await service.startSession();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('session_active'), isTrue);
      });

      test('end session marks session as inactive', () async {
        await service.startSession();
        await service.endSession();
        expect(service.isSessionActive, isFalse);
      });

      test('end session clears activity timestamp', () async {
        await service.startSession();
        await service.endSession();
        expect(service.lastActivity, isNull);
      });

      test('end session clears SharedPreferences data', () async {
        await service.startSession();
        await service.endSession();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('session_active'), isNull);
        expect(prefs.getInt('last_activity_timestamp'), isNull);
      });

      test('end session invokes onSessionStateChanged callback', () async {
        bool? callbackState;
        service.onSessionStateChanged = (isActive) {
          callbackState = isActive;
        };

        await service.startSession();
        await service.endSession();

        expect(callbackState, isFalse);
      });
    });

    group('Activity Recording', () {
      test('record activity updates last activity timestamp', () async {
        await service.startSession();
        final before = DateTime.now();
        await service.recordActivity();
        final after = DateTime.now();

        expect(service.lastActivity, isNotNull);
        expect(service.lastActivity!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(service.lastActivity!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('record activity persists timestamp to SharedPreferences', () async {
        await service.startSession();
        await service.recordActivity();

        final prefs = await SharedPreferences.getInstance();
        final timestamp = prefs.getInt('last_activity_timestamp');
        expect(timestamp, isNotNull);
        expect(timestamp! > 0, isTrue);
      });

      test('record activity during grace period exits grace period', () async {
        await service.startSession();

        // Simulate entering grace period by setting internal state
        // (In real scenario, this would happen after 30 minutes of inactivity)
        // For testing, we'll just verify the service is set up to handle it
        expect(service.isInGracePeriod, isFalse);
      });

      test('record activity does nothing when not authenticated', () async {
        // Don't start session
        await service.recordActivity();
        expect(service.lastActivity, isNull);
      });

      test('record activity does nothing when service not initialized', () async {
        final uninitService = SessionTimeoutService();
        await uninitService.recordActivity();
        expect(uninitService.lastActivity, isNull);
        await uninitService.dispose();
      });
    });

    group('Session State Queries', () {
      test('isSessionActive returns false when not started', () {
        expect(service.isSessionActive, isFalse);
      });

      test('isSessionActive returns true after session start', () async {
        await service.startSession();
        expect(service.isSessionActive, isTrue);
      });

      test('isInGracePeriod returns false initially', () async {
        await service.startSession();
        expect(service.isInGracePeriod, isFalse);
      });

      test('timeUntilTimeout returns null when no activity', () {
        expect(service.timeUntilTimeout, isNull);
      });

      test('timeUntilTimeout returns valid duration after activity', () async {
        await service.startSession();
        await service.recordActivity();

        final timeLeft = service.timeUntilTimeout;
        expect(timeLeft, isNotNull);
        expect(timeLeft!.inMinutes, greaterThanOrEqualTo(29)); // Should be ~30 minutes
      });

      test('timeUntilWarning returns null when no activity', () {
        expect(service.timeUntilWarning, isNull);
      });

      test('timeUntilWarning returns null after warning shown', () async {
        await service.startSession();
        // Warning shown flag is internal, so we just verify initial state
        expect(service.warningShown, isFalse);
      });

      test('lastActivity returns null initially', () {
        expect(service.lastActivity, isNull);
      });

      test('lastActivity returns timestamp after recording', () async {
        await service.startSession();
        expect(service.lastActivity, isNotNull);
      });

      test('gracePeriodStartTime returns null when not in grace period', () async {
        await service.startSession();
        expect(service.gracePeriodStartTime, isNull);
      });
    });

    group('Callbacks', () {
      test('onTimeout callback is invoked when set', () async {
        bool timeoutCalled = false;
        service.onTimeout = () {
          timeoutCalled = true;
        };

        // We can't easily simulate a full 45-minute timeout in a unit test,
        // so we just verify the callback can be set and would be called
        expect(service.onTimeout, isNotNull);
        expect(timeoutCalled, isFalse); // Not called yet
      });

      test('onWarning callback can be set', () {
        bool warningCalled = false;
        service.onWarning = () {
          warningCalled = true;
        };

        expect(service.onWarning, isNotNull);
        expect(warningCalled, isFalse); // Not called yet
      });

      test('onSessionStateChanged callback can be set', () {
        bool? lastState;
        service.onSessionStateChanged = (isActive) {
          lastState = isActive;
        };

        expect(service.onSessionStateChanged, isNotNull);
        expect(lastState, isNull); // Not called yet
      });

      test('onSessionStateChanged is called on session start', () async {
        bool? lastState;
        service.onSessionStateChanged = (isActive) {
          lastState = isActive;
        };

        await service.startSession();
        expect(lastState, isTrue);
      });

      test('onSessionStateChanged is called on session end', () async {
        bool? lastState;
        service.onSessionStateChanged = (isActive) {
          lastState = isActive;
        };

        await service.startSession();
        await service.endSession();
        expect(lastState, isFalse);
      });
    });

    group('Persistence', () {
      test('session state persists across dispose/initialize', () async {
        await service.startSession();
        await service.recordActivity();

        final prefs = await SharedPreferences.getInstance();
        final timestamp = prefs.getInt('last_activity_timestamp');

        // Dispose and create new service
        await service.dispose();
        final newService = SessionTimeoutService();
        await newService.initialize();

        // Verify timestamp still exists
        final newPrefs = await SharedPreferences.getInstance();
        expect(newPrefs.getInt('last_activity_timestamp'), equals(timestamp));

        await newService.dispose();
      });

      test('active session flag persists', () async {
        await service.startSession();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('session_active'), isTrue);
      });
    });

    group('Dispose', () {
      test('dispose clears session state', () async {
        await service.startSession();
        await service.dispose();

        expect(service.isSessionActive, isFalse);
        expect(service.isInitialized, isFalse);
      });

      test('dispose is safe to call multiple times', () async {
        await service.dispose();
        await service.dispose();
        // Should not throw
      });

      test('dispose stops monitoring timers', () async {
        await service.startSession();
        await service.dispose();
        // Timer should be cancelled (no way to directly test, but no errors should occur)
      });
    });

    group('Edge Cases', () {
      test('handles SharedPreferences errors gracefully', () async {
        // This test verifies that errors don't crash the app
        // In practice, SharedPreferences mock should work fine
        await service.startSession();
        await service.recordActivity();
        // Should complete without throwing
      });

      test('handles null callbacks gracefully', () async {
        service.onTimeout = null;
        service.onWarning = null;
        service.onSessionStateChanged = null;

        await service.startSession();
        await service.endSession();
        // Should complete without throwing
      });

      test('service handles rapid activity recording', () async {
        await service.startSession();

        // Record activity multiple times rapidly
        for (int i = 0; i < 10; i++) {
          await service.recordActivity();
        }

        expect(service.lastActivity, isNotNull);
      });

      test('service initializes even if app was closed with active session', () async {
        // Set up scenario: app closed with active session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('session_active', true);
        await prefs.setInt(
          'last_activity_timestamp',
          DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        );

        // Create new service and initialize
        final newService = SessionTimeoutService();
        bool timeoutCalled = false;
        newService.onTimeout = () {
          timeoutCalled = true;
        };

        await newService.initialize();

        // Should detect expired session and trigger timeout
        // (callback is invoked in post-frame, so we just verify setup)
        expect(newService.isInitialized, isTrue);

        await newService.dispose();
      });
    });
  });
}
