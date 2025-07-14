import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import '../../fixtures/mock_data.dart';
import '../../fixtures/test_constants.dart';

void main() {
  group('Job Model Tests', () {
    test('should create Job with required fields', () {
      // Arrange & Act
      final job = Job(
        id: 'test-job-id',
        company: 'Test Electric Company',
        location: 'Test City, TS',
      );

      // Assert
      expect(job.id, equals('test-job-id'));
      expect(job.company, equals('Test Electric Company'));
      expect(job.location, equals('Test City, TS'));
    });

    test('should create Job from JSON correctly', () {
      // Arrange
      final jsonData = {
        'id': 'test-job-1',
        'company': 'Elite Electric',
        'location': 'New York, NY',
        'classification': 'Inside Wireman',
        'local': 3,
        'wage': 45.50,
        'job_title': 'Journeyman Electrician',
        'typeOfWork': 'Commercial',
      };

      // Act
      final job = Job.fromJson(jsonData);

      // Assert
      expect(job.id, equals('test-job-1'));
      expect(job.company, equals('Elite Electric'));
      expect(job.location, equals('New York, NY'));
      expect(job.classification, equals('Inside Wireman'));
      expect(job.local, equals(3));
      expect(job.wage, equals(45.50));
      expect(job.jobTitle, equals('Journeyman Electrician'));
      expect(job.typeOfWork, equals('Commercial'));
    });

    test('should convert Job to JSON correctly', () {
      // Arrange
      final job = MockData.createJob(
        id: 'test-job-2',
        company: 'Power Grid Solutions',
        classification: 'Journeyman Lineman',
      );

      // Act
      final json = job.toJson();

      // Assert
      expect(json['id'], equals('test-job-2'));
      expect(json['company'], equals('Power Grid Solutions'));
      expect(json['classification'], equals('Journeyman Lineman'));
      expect(json, containsPair('local', isA<int>()));
      expect(json, containsPair('wage', isA<double>()));
    });

    test('should handle wage parsing from string', () {
      // Arrange
      final jsonData = {
        'id': 'test-wage-job',
        'company': 'Test Co',
        'location': 'Test City',
        'wage': '\$42.50/hr',
      };

      // Act
      final job = Job.fromJson(jsonData);

      // Assert
      expect(job.wage, equals(42.50));
    });

    test('should handle malformed JSON gracefully', () {
      // Arrange
      final badJsonData = {
        'company': 'Test Co',
        'location': 'Test City',
        'wage': 'not-a-number',
        'local': 'not-an-int',
      };

      // Act & Assert
      expect(() => Job.fromJson(badJsonData), throwsA(isA<FormatException>()));
    });

    test('should create Firestore-compatible JSON', () {
      // Arrange
      final job = MockData.createJob();

      // Act
      final firestoreJson = job.toFirestore();

      // Assert
      expect(firestoreJson, isA<Map<String, dynamic>>());
      expect(firestoreJson['timestamp'], isA<Timestamp>());
      expect(firestoreJson, isNot(contains(null)));
    });

    test('should support copyWith functionality', () {
      // Arrange
      final originalJob = MockData.createJob(
        company: 'Original Company',
        wage: 40.0,
      );

      // Act
      final updatedJob = originalJob.copyWith(
        company: 'Updated Company',
        wage: 50.0,
      );

      // Assert
      expect(updatedJob.company, equals('Updated Company'));
      expect(updatedJob.wage, equals(50.0));
      expect(updatedJob.id, equals(originalJob.id)); // Unchanged
      expect(updatedJob.location, equals(originalJob.location)); // Unchanged
    });

    test('should implement equality correctly', () {
      // Arrange
      final job1 = MockData.createJob(id: 'same-job');
      final job2 = MockData.createJob(id: 'same-job');
      final job3 = MockData.createJob(id: 'different-job');

      // Act & Assert
      expect(job1, equals(job2));
      expect(job1, isNot(equals(job3)));
      expect(job1.hashCode, equals(job2.hashCode));
      expect(job1.hashCode, isNot(equals(job3.hashCode)));
    });

    test('should handle electrical industry specific fields', () {
      // Arrange & Act
      final job = Job.fromJson({
        'id': 'electrical-job',
        'company': 'High Voltage Corp',
        'location': 'Utility Site',
        'classification': 'Journeyman Lineman',
        'voltageLevel': '69kV',
        'typeOfWork': 'Transmission',
        'local': 58,
      });

      // Assert
      expect(job.classification, equals('Journeyman Lineman'));
      expect(job.voltageLevel, equals('69kV'));
      expect(job.typeOfWork, equals('Transmission'));
      expect(job.local, equals(58));
    });

    test('should handle IBEW local numbers correctly', () {
      // Arrange
      final testLocals = TestConstants.commonIBEWLocals;

      for (final localNumber in testLocals.take(5)) {
        // Act
        final job = MockData.createJob(localNumber: localNumber);

        // Assert
        expect(job.local, equals(localNumber));
        expect(TestConstants.commonIBEWLocals, contains(job.local));
      }
    });
  });

  group('Job Model Performance Tests', () {
    test('should handle large JSON parsing efficiently', () {
      // Arrange
      final stopwatch = Stopwatch()..start();
      final jobs = <Job>[];

      // Act
      for (int i = 0; i < 1000; i++) {
        final job = MockData.createJob(id: 'perf-job-$i');
        jobs.add(job);
      }
      stopwatch.stop();

      // Assert
      expect(jobs.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete in under 1 second
    });
  });
}