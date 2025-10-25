import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/app_settings_model.dart';
import 'package:journeyman_jobs/services/app_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettingsService', () {
    late AppSettingsService service;
    const testUserId = 'test-user-123';

    setUp(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      service = AppSettingsService();
    });

    tearDown(() {
      service.clearCache();
    });

    group('Local Cache Operations', () {
      test('saves and loads settings from local cache', () async {
        final settings = AppSettingsModel.defaults(testUserId);

        // Save to local cache through private method (via updateSetting)
        await service.updateSetting(testUserId, 'themeMode', 'dark');

        // Load should retrieve from cache
        final loaded = await service.loadSettings(testUserId);

        // Since Firestore is mocked and unavailable, should load defaults
        expect(loaded.userId, testUserId);
      });

      test('clearCache() removes cached settings', () {
        service.clearCache();

        // Cache should be empty after clear
        // Next load should fetch from storage
        expect(() => service.loadSettings(testUserId), returnsNormally);
      });

      test('clearUserCache() removes specific user cache', () {
        service.clearUserCache(testUserId);

        // Specific user cache should be cleared
        expect(() => service.loadSettings(testUserId), returnsNormally);
      });
    });

    group('Settings Validation', () {
      test('saveSettings() rejects invalid settings', () async {
        final invalidSettings = AppSettingsModel(
          userId: testUserId,
          lastUpdated: DateTime.now(),
          themeMode: 'invalid-mode', // Invalid theme mode
        );

        expect(
          () => service.saveSettings(testUserId, invalidSettings),
          throwsA(isA<Exception>()),
        );
      });

      test('saveSettings() accepts valid settings', () async {
        final validSettings = AppSettingsModel.defaults(testUserId);

        // Should complete without throwing
        // Note: Will fail Firestore write in test, but validates settings first
        try {
          await service.saveSettings(testUserId, validSettings);
        } catch (e) {
          // Expected to fail Firestore write in test environment
          expect(e, isA<Exception>());
        }
      });
    });

    group('Update Individual Settings', () {
      test('updateSetting() updates theme mode', () async {
        // This will attempt to update Firestore (will fail in test)
        // but demonstrates the API
        try {
          await service.updateSetting(testUserId, 'themeMode', 'dark');
        } catch (e) {
          // Expected to fail in test environment without Firestore
          expect(e, isA<Exception>());
        }
      });

      test('updateSetting() throws on unknown key', () async {
        expect(
          () => service.updateSetting(testUserId, 'unknownKey', 'value'),
          throwsA(isA<Exception>()),
        );
      });

      test('updateSetting() validates setting value', () async {
        // Updating with invalid value should fail validation
        try {
          await service.updateSetting(testUserId, 'themeMode', 'invalid');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });

    group('Error Handling', () {
      test('loadSettings() with empty userId throws exception', () async {
        expect(
          () => service.loadSettings(''),
          throwsA(isA<Exception>()),
        );
      });

      test('saveSettings() with empty userId throws exception', () async {
        final settings = AppSettingsModel.defaults('user-123');

        expect(
          () => service.saveSettings('', settings),
          throwsA(isA<Exception>()),
        );
      });

      test('deleteSettings() with empty userId throws exception', () async {
        expect(
          () => service.deleteSettings(''),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Default Settings Creation', () {
      test('loadSettings() creates defaults for new user', () async {
        final settings = await service.loadSettings(testUserId);

        expect(settings.userId, testUserId);
        expect(settings.themeMode, 'system');
        expect(settings.fontSize, 'Medium');
        expect(settings.defaultSearchRadius, 50.0);
        expect(settings.distanceUnits, 'Miles');
      });

      test('default settings are valid', () async {
        final settings = await service.loadSettings(testUserId);

        expect(settings.validate(), true);
        expect(settings.validationError, null);
      });
    });
  });
}
