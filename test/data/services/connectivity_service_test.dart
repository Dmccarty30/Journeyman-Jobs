import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';

// Generate mocks
@GenerateMocks([Connectivity])
import 'connectivity_service_test.mocks.dart';

void main() {
  late ConnectivityService connectivityService;
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityController = StreamController<List<ConnectivityResult>>.broadcast();
    
    when(mockConnectivity.onConnectivityChanged).thenAnswer(
      (_) => connectivityController.stream,
    );
    
    connectivityService = ConnectivityService();
  });

  tearDown(() {
    connectivityController.close();
    connectivityService.dispose();
  });

  group('ConnectivityService - Initial State', () {
    test('should start with online state by default', () {
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.isOffline, isFalse);
      expect(connectivityService.wasOffline, isFalse);
    });

    test('should have unknown connection type initially', () {
      expect(connectivityService.connectionType, equals('unknown'));
      expect(connectivityService.isConnectedToWifi, isFalse);
      expect(connectivityService.isMobileData, isFalse);
    });

    test('should have null offline/online times initially', () {
      expect(connectivityService.lastOfflineTime, isNull);
      expect(connectivityService.lastOnlineTime, isNull);
    });
  });

  group('ConnectivityService - Connection State Changes', () {
    test('should update state when going offline', () async {
      // Arrange
      bool notificationFired = false;
      connectivityService.addListener(() {
        notificationFired = true;
      });

      // Act
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isFalse);
      expect(connectivityService.isOffline, isTrue);
      expect(connectivityService.wasOffline, isTrue);
      expect(connectivityService.lastOfflineTime, isNotNull);
      expect(notificationFired, isTrue);
    });

    test('should update state when coming back online', () async {
      // Arrange
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 50));
      
      bool notificationFired = false;
      connectivityService.addListener(() {
        notificationFired = true;
      });

      // Act
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.isOffline, isFalse);
      expect(connectivityService.isConnectedToWifi, isTrue);
      expect(connectivityService.connectionType, equals('wifi'));
      expect(connectivityService.lastOnlineTime, isNotNull);
      expect(notificationFired, isTrue);
    });

    test('should detect mobile data connection', () async {
      // Act
      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.isMobileData, isTrue);
      expect(connectivityService.isConnectedToWifi, isFalse);
      expect(connectivityService.connectionType, equals('mobile'));
    });

    test('should handle ethernet connection', () async {
      // Act
      connectivityController.add([ConnectivityResult.ethernet]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.connectionType, equals('ethernet'));
      expect(connectivityService.isConnectedToWifi, isFalse);
      expect(connectivityService.isMobileData, isFalse);
    });

    test('should handle multiple connection types', () async {
      // Act
      connectivityController.add([
        ConnectivityResult.wifi,
        ConnectivityResult.mobile,
      ]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.isConnectedToWifi, isTrue);
      expect(connectivityService.isMobileData, isTrue);
    });
  });

  group('ConnectivityService - IBEW Jobsite Scenarios', () {
    test('should handle construction site connectivity (mobile only)', () async {
      // Arrange - Simulating a remote construction site with only mobile data
      
      // Act
      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.isMobileData, isTrue);
      expect(connectivityService.isConnectedToWifi, isFalse);
      expect(connectivityService.connectionType, equals('mobile'));
    });

    test('should handle underground electrical work (no connectivity)', () async {
      // Arrange - Simulating underground utility work with no signal
      
      // Act
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOffline, isTrue);
      expect(connectivityService.wasOffline, isTrue);
      expect(connectivityService.lastOfflineTime, isNotNull);
    });

    test('should handle power plant connectivity (ethernet)', () async {
      // Arrange - Simulating work at a power plant with wired internet
      
      // Act
      connectivityController.add([ConnectivityResult.ethernet]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.connectionType, equals('ethernet'));
    });

    test('should handle storm work scenarios (intermittent connectivity)', () async {
      // Arrange - Simulating storm restoration work with unstable connection
      int changeCount = 0;
      connectivityService.addListener(() {
        changeCount++;
      });

      // Act - Simulate intermittent connectivity
      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 50));
      
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 50));
      
      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(changeCount, greaterThan(1));
      expect(connectivityService.wasOffline, isTrue);
      expect(connectivityService.isOnline, isTrue); // Should be back online
    });
  });

  group('ConnectivityService - Edge Cases', () {
    test('should handle rapid connection changes', () async {
      // Arrange
      int notificationCount = 0;
      connectivityService.addListener(() {
        notificationCount++;
      });

      // Act - Rapid state changes
      for (int i = 0; i < 5; i++) {
        connectivityController.add([
          i % 2 == 0 ? ConnectivityResult.wifi : ConnectivityResult.none
        ]);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Assert
      expect(notificationCount, greaterThan(0));
      expect(connectivityService.wasOffline, isTrue);
    });

    test('should handle unknown connection result', () async {
      // Act
      connectivityController.add([ConnectivityResult.other]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.connectionType, equals('other'));
    });

    test('should handle empty connectivity results', () async {
      // Act
      connectivityController.add([]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.isOffline, isTrue);
    });
  });

  group('ConnectivityService - Timing and History', () {
    test('should track offline duration correctly', () async {
      // Arrange
      final startTime = DateTime.now();
      
      // Act
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));
      
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityService.lastOfflineTime, isNotNull);
      expect(connectivityService.lastOnlineTime, isNotNull);
      expect(connectivityService.lastOfflineTime!.isAfter(startTime), isTrue);
      expect(connectivityService.lastOnlineTime!.isAfter(connectivityService.lastOfflineTime!), isTrue);
    });

    test('should maintain offline history flag', () async {
      // Act
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 50));
      
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(connectivityService.isOnline, isTrue);
      expect(connectivityService.wasOffline, isTrue); // Should remember being offline
    });
  });

  group('ConnectivityService - Performance and Memory', () {
    test('should properly dispose of resources', () {
      // Act
      connectivityService.dispose();

      // Assert - No exceptions should be thrown
      expect(() => connectivityService.dispose(), returnsNormally);
    });

    test('should handle multiple listeners efficiently', () {
      // Arrange
      final listeners = <VoidCallback>[];
      for (int i = 0; i < 10; i++) {
        void listener() {}
        listeners.add(listener);
        connectivityService.addListener(listener);
      }

      // Act
      connectivityController.add([ConnectivityResult.wifi]);

      // Assert - Should handle multiple listeners without issues
      expect(connectivityService.hasListeners, isTrue);

      // Cleanup
      for (final listener in listeners) {
        connectivityService.removeListener(listener);
      }
    });
  });

  group('ConnectivityService - Electrical Industry Requirements', () {
    test('should support offline job viewing for field workers', () async {
      // Arrange - Worker goes to remote jobsite
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Service should track offline state for cache decisions
      expect(connectivityService.isOffline, isTrue);
      expect(connectivityService.wasOffline, isTrue);
    });

    test('should detect optimal connection for large file downloads', () async {
      // Arrange - Worker needs to download technical drawings
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - WiFi preferred for large downloads
      expect(connectivityService.isConnectedToWifi, isTrue);
      expect(connectivityService.connectionType, equals('wifi'));
    });

    test('should warn about mobile data usage', () async {
      // Arrange - Worker on mobile data might have limited data plan
      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Service can identify mobile data for usage warnings
      expect(connectivityService.isMobileData, isTrue);
      expect(connectivityService.isConnectedToWifi, isFalse);
    });
  });
}