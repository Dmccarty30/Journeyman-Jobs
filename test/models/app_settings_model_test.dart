import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/app_settings_model.dart';

void main() {
  group('AppSettingsModel', () {
    late AppSettingsModel testSettings;

    setUp(() {
      testSettings = AppSettingsModel(
        userId: 'test-user-id',
        lastUpdated: DateTime(2025, 1, 1),
        themeMode: 'dark',
        highContrastMode: true,
        electricalEffects: false,
        fontSize: 'Large',
        defaultSearchRadius: 100.0,
        distanceUnits: 'Kilometers',
        autoApplyEnabled: true,
        minimumHourlyRate: 50.0,
        offlineModeEnabled: true,
        autoDownloadEnabled: false,
        wifiOnlyDownloads: false,
        profileVisibility: 'Private',
        locationServicesEnabled: false,
        biometricLoginEnabled: true,
        twoFactorEnabled: true,
        language: 'Spanish',
        dateFormat: 'DD/MM/YYYY',
        timeFormat: '24-hour',
        stormAlertRadius: 200.0,
        stormRateMultiplier: 2.0,
      );
    });

    group('Factory Constructors', () {
      test('defaults() creates settings with default values', () {
        final settings = AppSettingsModel.defaults('user-123');

        expect(settings.userId, 'user-123');
        expect(settings.themeMode, 'system');
        expect(settings.highContrastMode, false);
        expect(settings.electricalEffects, true);
        expect(settings.fontSize, 'Medium');
        expect(settings.defaultSearchRadius, 50.0);
        expect(settings.distanceUnits, 'Miles');
        expect(settings.autoApplyEnabled, false);
        expect(settings.minimumHourlyRate, 35.0);
        expect(settings.profileVisibility, 'Union Members Only');
      });

      test('fromJson() creates settings from JSON map', () {
        final json = {
          'themeMode': 'dark',
          'highContrastMode': true,
          'electricalEffects': false,
          'fontSize': 'Large',
          'defaultSearchRadius': 100.0,
          'distanceUnits': 'Kilometers',
          'lastUpdated': '2025-01-01T00:00:00.000',
        };

        final settings = AppSettingsModel.fromJson(json, 'user-123');

        expect(settings.userId, 'user-123');
        expect(settings.themeMode, 'dark');
        expect(settings.highContrastMode, true);
        expect(settings.electricalEffects, false);
        expect(settings.fontSize, 'Large');
        expect(settings.defaultSearchRadius, 100.0);
        expect(settings.distanceUnits, 'Kilometers');
      });

      test('fromJson() handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final settings = AppSettingsModel.fromJson(json, 'user-123');

        expect(settings.themeMode, 'system');
        expect(settings.highContrastMode, false);
        expect(settings.electricalEffects, true);
      });
    });

    group('Serialization', () {
      test('toJson() converts settings to JSON map', () {
        final json = testSettings.toJson();

        expect(json['userId'], 'test-user-id');
        expect(json['themeMode'], 'dark');
        expect(json['highContrastMode'], true);
        expect(json['electricalEffects'], false);
        expect(json['fontSize'], 'Large');
        expect(json['defaultSearchRadius'], 100.0);
        expect(json['distanceUnits'], 'Kilometers');
        expect(json['lastUpdated'], '2025-01-01T00:00:00.000');
      });

      test('toFirestore() includes all required fields', () {
        final data = testSettings.toFirestore();

        expect(data['themeMode'], 'dark');
        expect(data['highContrastMode'], true);
        expect(data['electricalEffects'], false);
        expect(data['fontSize'], 'Large');
        expect(data['lastUpdated'], isA<FieldValue>());
      });

      test('toJson/fromJson roundtrip preserves data', () {
        final json = testSettings.toJson();
        final settings = AppSettingsModel.fromJson(json, testSettings.userId);

        expect(settings.userId, testSettings.userId);
        expect(settings.themeMode, testSettings.themeMode);
        expect(settings.highContrastMode, testSettings.highContrastMode);
        expect(settings.electricalEffects, testSettings.electricalEffects);
        expect(settings.fontSize, testSettings.fontSize);
        expect(settings.defaultSearchRadius, testSettings.defaultSearchRadius);
      });
    });

    group('Validation', () {
      test('validate() returns true for valid settings', () {
        expect(testSettings.validate(), true);
      });

      test('validate() returns false for invalid theme mode', () {
        final settings = testSettings.copyWith(themeMode: 'invalid');
        expect(settings.validate(), false);
        expect(settings.validationError, contains('theme mode'));
      });

      test('validate() returns false for invalid font size', () {
        final settings = testSettings.copyWith(fontSize: 'Huge');
        expect(settings.validate(), false);
        expect(settings.validationError, contains('font size'));
      });

      test('validate() returns false for search radius out of range', () {
        final settings = testSettings.copyWith(defaultSearchRadius: 5.0);
        expect(settings.validate(), false);
        expect(settings.validationError, contains('Search radius'));
      });

      test('validate() returns false for hourly rate out of range', () {
        final settings = testSettings.copyWith(minimumHourlyRate: 150.0);
        expect(settings.validate(), false);
        expect(settings.validationError, contains('hourly rate'));
      });

      test('validate() returns false for invalid distance units', () {
        final settings = testSettings.copyWith(distanceUnits: 'Furlongs');
        expect(settings.validate(), false);
        expect(settings.validationError, contains('Distance units'));
      });

      test('validate() returns false for invalid profile visibility', () {
        final settings = testSettings.copyWith(profileVisibility: 'Everyone');
        expect(settings.validate(), false);
        expect(settings.validationError, contains('profile visibility'));
      });

      test('validate() returns false for invalid language', () {
        final settings = testSettings.copyWith(language: 'German');
        expect(settings.validate(), false);
        expect(settings.validationError, contains('language'));
      });

      test('validate() returns false for storm alert radius out of range', () {
        final settings = testSettings.copyWith(stormAlertRadius: 25.0);
        expect(settings.validate(), false);
        expect(settings.validationError, contains('Storm alert radius'));
      });

      test('validate() returns false for storm rate multiplier out of range', () {
        final settings = testSettings.copyWith(stormRateMultiplier: 5.0);
        expect(settings.validate(), false);
        expect(settings.validationError, contains('Storm rate multiplier'));
      });

      test('validationError returns null for valid settings', () {
        expect(testSettings.validationError, null);
      });
    });

    group('copyWith()', () {
      test('creates new instance with updated values', () {
        final updated = testSettings.copyWith(
          themeMode: 'light',
          fontSize: 'Extra Large',
        );

        expect(updated.themeMode, 'light');
        expect(updated.fontSize, 'Extra Large');
        // Other values should remain unchanged
        expect(updated.highContrastMode, testSettings.highContrastMode);
        expect(updated.electricalEffects, testSettings.electricalEffects);
      });

      test('creates new instance with same values', () {
        final copy = testSettings.copyWith();

        expect(copy.themeMode, testSettings.themeMode);
        expect(copy.userId, testSettings.userId);
        expect(copy.highContrastMode, testSettings.highContrastMode);
        // Note: copyWith creates new instance, but equality is value-based
      });
    });

    group('Equality', () {
      test('identical settings are equal', () {
        final settings1 = AppSettingsModel.defaults('user-123');
        final settings2 = AppSettingsModel.defaults('user-123');

        expect(settings1 == settings2, true);
        expect(settings1.hashCode == settings2.hashCode, true);
      });

      test('different settings are not equal', () {
        final settings1 = AppSettingsModel.defaults('user-123');
        final settings2 = settings1.copyWith(themeMode: 'dark');

        expect(settings1 == settings2, false);
      });
    });
  });
}
