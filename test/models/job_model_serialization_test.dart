import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/job_model.dart';

void main() {
  group('Job Serialization Tests', () {
    test('toJson creates valid JSON for API', () {
      final job = Job(
        id: 'test-123',
        title: 'Senior Flutter Developer',
        company: 'Tech Corp',
        location: 'San Francisco, CA',
        description: 'We are looking for an experienced Flutter developer...',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        jobType: 'Full-time',
        skills: ['Flutter', 'Dart', 'Firebase'],
        openPositions: 2,
        isRemote: true,
      );

      final json = job.toJson();

      expect(json['id'], 'test-123');
      expect(json['title'], 'Senior Flutter Developer');
      expect(json['createdAt'], '2024-01-15T10:30:00.000');
      expect(json['skills'], ['Flutter', 'Dart', 'Firebase']);
      expect(json['openPositions'], 2);
      expect(json['isRemote'], true);
      expect(json.containsKey('benefits'), false); // null values excluded by default
    });

    test('toJson with includeNullValues includes all fields', () {
      final job = Job(
        id: 'test-123',
        title: 'Developer',
        company: 'Tech Corp',
        location: 'Remote',
        description: 'Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = job.toJson(includeNullValues: true);

      expect(json.containsKey('benefits'), true);
      expect(json['benefits'], null);
      expect(json.containsKey('skills'), true);
      expect(json['skills'], null);
    });

    test('fromJson handles various DateTime formats', () {
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      // Test with Timestamp (Firestore format)
      final json1 = {
        'id': 'test-1',
        'title': 'Job 1',
        'company': 'Company',
        'location': 'Location',
        'description': 'Description',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      final job1 = Job.fromJson(json1);
      expect(job1.createdAt.millisecondsSinceEpoch, 
             timestamp.toDate().millisecondsSinceEpoch);

      // Test with ISO string
      final json2 = {
        'id': 'test-2',
        'title': 'Job 2',
        'company': 'Company',
        'location': 'Location',
        'description': 'Description',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final job2 = Job.fromJson(json2);
      expect(job2.createdAt.toIso8601String(), now.toIso8601String());

      // Test with milliseconds
      final json3 = {
        'id': 'test-3',
        'title': 'Job 3',
        'company': 'Company',
        'location': 'Location',
        'description': 'Description',
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      };

      final job3 = Job.fromJson(json3);
      expect(job3.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('fromJson handles type conversions safely', () {
      final json = {
        'id': 123, // number instead of string
        'title': 'Job Title',
        'company': 'Company',
        'location': 'Location',
        'description': 'Description',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'openPositions': '5', // string instead of int
        'isRemote': 'true', // string instead of bool
        'skills': ['Skill1', 123, true], // mixed types in list
      };

      final job = Job.fromJson(json);

      expect(job.id, '123');
      expect(job.openPositions, 5);
      expect(job.isRemote, true);
      expect(job.skills, ['Skill1', '123', 'true']);
    });

    test('fromJson handles missing required fields gracefully', () {
      final json = {
        'title': 'Job Title',
        'company': 'Company',
        // Missing id, location, description, dates
      };

      final job = Job.fromJson(json);

      expect(job.id, ''); // defaults to empty string
      expect(job.location, '');
      expect(job.description, '');
      expect(job.createdAt, isA<DateTime>()); // defaults to current time
    });

    test('toFirestore creates Firestore-compatible map', () {
      final job = Job(
        id: 'test-123',
        title: 'Developer',
        company: 'Tech Corp',
        location: 'Remote',
        description: 'Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        skills: ['Flutter', 'Dart'],
      );

      final firestoreData = job.toFirestore();

      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect(firestoreData['updatedAt'], isA<Timestamp>());
      expect(firestoreData.containsKey('benefits'), false); // null excluded
    });

    test('round trip serialization maintains data integrity', () {
      final original = Job(
        id: 'test-123',
        title: 'Senior Developer',
        company: 'Tech Corp',
        location: 'San Francisco, CA',
        description: 'Detailed job description here',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        companyLogo: 'https://example.com/logo.png',
        jobType: 'Full-time',
        experienceLevel: 'Senior',
        salaryRange: '$120k - $180k',
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
        benefits: ['Health Insurance', '401k', 'Remote Work'],
        applicationDeadline: '2024-02-15',
        contactEmail: 'hr@techcorp.com',
        contactPhone: '+1-555-1234',
        department: 'Engineering',
        openPositions: 3,
        isRemote: true,
        isActive: true,
        applicationUrl: 'https://techcorp.com/apply',
        additionalInfo: {
          'teamSize': 15,
          'requiredYears': 5,
          'visa': 'H1B sponsorship available',
        },
      );

      // Convert to JSON and back
      final json = original.toJson();
      final restored = Job.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.company, original.company);
      expect(restored.location, original.location);
      expect(restored.description, original.description);
      expect(restored.createdAt.toIso8601String(), 
             original.createdAt.toIso8601String());
      expect(restored.skills, original.skills);
      expect(restored.benefits, original.benefits);
      expect(restored.openPositions, original.openPositions);
      expect(restored.isRemote, original.isRemote);
      expect(restored.additionalInfo, original.additionalInfo);
    });
  });
}
