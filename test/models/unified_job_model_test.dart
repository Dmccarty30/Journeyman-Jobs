import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/unified_job_model.dart';

/// Test suite for UnifiedJobModel
///
/// Tests cover:
/// - Model creation with required fields
/// - copyWith functionality
/// - JSON serialization/deserialization
/// - Firestore integration
/// - Validation logic
/// - Computed properties
void main() {
  group('UnifiedJobModel Creation', () {
    test('creates with required fields only', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
      );

      expect(job.id, 'test-123');
      expect(job.company, 'ACME Electric');
      expect(job.location, 'Seattle, WA');
      expect(job.isValid, true);
    });

    test('creates with all fields populated', () {
      final now = DateTime.now();
      final job = UnifiedJobModel(
        id: 'test-456',
        sharerId: 'user-789',
        company: 'IBEW Local 46',
        location: 'Seattle, WA',
        classification: 'Inside Wireman',
        wage: 48.50,
        hours: 40,
        jobTitle: 'Journeyman Electrician',
        jobDescription: 'Commercial construction project',
        timestamp: now,
        matchesCriteria: true,
        deleted: false,
        local: 46,
        qualifications: 'State certification required',
        typeOfWork: 'Commercial',
        voltageLevel: 'Low Voltage',
      );

      expect(job.id, 'test-456');
      expect(job.sharerId, 'user-789');
      expect(job.classification, 'Inside Wireman');
      expect(job.wage, 48.50);
      expect(job.hours, 40);
      expect(job.timestamp, now);
      expect(job.matchesCriteria, true);
      expect(job.isValid, true);
    });

    test('default values are applied correctly', () {
      final job = UnifiedJobModel(
        id: 'test-789',
        company: 'Test Company',
        location: 'Portland, OR',
      );

      expect(job.sharerId, '');
      expect(job.jobDetails, {});
      expect(job.matchesCriteria, false);
      expect(job.deleted, false);
      expect(job.isSaved, false);
      expect(job.isApplied, false);
    });
  });

  group('UnifiedJobModel copyWith', () {
    late UnifiedJobModel baseJob;

    setUp(() {
      baseJob = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        wage: 45.00,
        hours: 40,
      );
    });

    test('updates single field', () {
      final updated = baseJob.copyWith(wage: 50.00);

      expect(updated.wage, 50.00);
      expect(updated.company, 'ACME Electric'); // Other fields preserved
      expect(updated.hours, 40);
    });

    test('updates multiple fields', () {
      final updated = baseJob.copyWith(
        wage: 50.00,
        hours: 50,
        classification: 'Journeyman Lineman',
      );

      expect(updated.wage, 50.00);
      expect(updated.hours, 50);
      expect(updated.classification, 'Journeyman Lineman');
      expect(updated.id, 'test-123'); // ID preserved
    });

    test('creates new instance (not mutating original)', () {
      final updated = baseJob.copyWith(wage: 50.00);

      expect(baseJob.wage, 45.00); // Original unchanged
      expect(updated.wage, 50.00);
    });
  });

  group('UnifiedJobModel Validation', () {
    test('isValid returns true for valid job', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
      );

      expect(job.isValid, true);
    });

    test('isValid returns false for empty ID', () {
      final job = UnifiedJobModel(
        id: '',
        company: 'ACME Electric',
        location: 'Seattle, WA',
      );

      expect(job.isValid, false);
    });

    test('isValid returns false for empty company', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: '',
        location: 'Seattle, WA',
      );

      expect(job.isValid, false);
    });

    test('isValid returns false for empty location', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: '',
      );

      expect(job.isValid, false);
    });
  });

  group('UnifiedJobModel Computed Properties', () {
    test('effectiveWage uses wage field when available', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        wage: 45.50,
      );

      expect(job.effectiveWage, 45.50);
    });

    test('effectiveWage falls back to jobDetails', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        jobDetails: {'payRate': 48.00},
      );

      expect(job.effectiveWage, 48.00);
    });

    test('effectiveHours uses hours field when available', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        hours: 40,
      );

      expect(job.effectiveHours, 40);
    });

    test('effectiveLocal handles both field names', () {
      final job1 = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        local: 46,
      );

      final job2 = UnifiedJobModel(
        id: 'test-456',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        localNumber: 77,
      );

      expect(job1.effectiveLocal, 46);
      expect(job2.effectiveLocal, 77);
    });

    test('isHighVoltage detects high voltage jobs', () {
      final highVoltage = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        voltageLevel: 'High Voltage',
      );

      final lowVoltage = UnifiedJobModel(
        id: 'test-456',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        voltageLevel: 'Low Voltage',
      );

      expect(highVoltage.isHighVoltage, true);
      expect(lowVoltage.isHighVoltage, false);
    });

    test('isLinemanPosition detects lineman jobs', () {
      final lineman = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        classification: 'Journeyman Lineman',
      );

      final wireman = UnifiedJobModel(
        id: 'test-456',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        classification: 'Inside Wireman',
      );

      expect(lineman.isLinemanPosition, true);
      expect(wireman.isLinemanPosition, false);
    });

    test('wageDisplay formats wage correctly', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        wage: 45.50,
      );

      expect(job.wageDisplay, '\$45.50/hr');
    });

    test('wageDisplay handles missing wage', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
      );

      expect(job.wageDisplay, 'Wage not specified');
    });

    test('shortDescription truncates long descriptions', () {
      final longDescription = 'A' * 150;
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        jobDescription: longDescription,
      );

      expect(job.shortDescription.length, 100);
      expect(job.shortDescription.endsWith('...'), true);
    });
  });

  group('UnifiedJobModel JSON Serialization', () {
    test('toJson includes all fields', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        wage: 45.50,
        hours: 40,
        classification: 'Inside Wireman',
      );

      final json = job.toJson();

      expect(json['id'], 'test-123');
      expect(json['company'], 'ACME Electric');
      expect(json['location'], 'Seattle, WA');
      expect(json['wage'], 45.50);
      expect(json['hours'], 40);
      expect(json['classification'], 'Inside Wireman');
    });

    test('fromJson creates correct model', () {
      final json = {
        'id': 'test-123',
        'company': 'ACME Electric',
        'location': 'Seattle, WA',
        'wage': 45.50,
        'hours': 40,
        'classification': 'Inside Wireman',
      };

      final job = UnifiedJobModel.fromJson(json);

      expect(job.id, 'test-123');
      expect(job.company, 'ACME Electric');
      expect(job.location, 'Seattle, WA');
      expect(job.wage, 45.50);
      expect(job.hours, 40);
      expect(job.classification, 'Inside Wireman');
    });

    test('toFirestore removes client-side fields', () {
      final job = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        isSaved: true,
        isApplied: true,
      );

      final firestore = job.toFirestore();

      expect(firestore.containsKey('isSaved'), false);
      expect(firestore.containsKey('isApplied'), false);
      expect(firestore.containsKey('reference'), false);
    });
  });

  group('UnifiedJobModel Equality', () {
    test('identical jobs are equal', () {
      final job1 = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        wage: 45.50,
      );

      final job2 = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
        wage: 45.50,
      );

      expect(job1, job2);
      expect(job1.hashCode, job2.hashCode);
    });

    test('different jobs are not equal', () {
      final job1 = UnifiedJobModel(
        id: 'test-123',
        company: 'ACME Electric',
        location: 'Seattle, WA',
      );

      final job2 = UnifiedJobModel(
        id: 'test-456',
        company: 'Different Company',
        location: 'Portland, OR',
      );

      expect(job1 == job2, false);
    });
  });

  group('UnifiedJobModel Migration Helpers', () {
    test('fromLegacyJob converts correctly', () {
      final legacyData = {
        'id': 'test-123',
        'company': 'ACME Electric',
        'location': 'Seattle, WA',
        'sharerId': 'user-456',
        'jobDetails': {'payRate': 45.50},
        'matchesCriteria': true,
      };

      final job = UnifiedJobModelMigration.fromLegacyJob(legacyData);

      expect(job.id, 'test-123');
      expect(job.company, 'ACME Electric');
      expect(job.sharerId, 'user-456');
      expect(job.matchesCriteria, true);
    });

    test('fromJobsRecord converts correctly', () {
      final recordData = {
        'id': 'test-456',
        'company': 'Local 46',
        'location': 'Seattle, WA',
        'classification': 'Inside Wireman',
        'wage': 48.00,
        'hours': 40,
      };

      final job = UnifiedJobModelMigration.fromJobsRecord(recordData);

      expect(job.id, 'test-456');
      expect(job.classification, 'Inside Wireman');
      expect(job.wage, 48.00);
      expect(job.hours, 40);
    });
  });
}
