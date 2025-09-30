import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../../lib/models/job_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('JobModel Tests', () {
    test('fromJson creates valid Job from complete JSON data', () {
      final testJson = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {
          'hours': 40,
          'payRate': 35.0,
          'perDiem': 100.0,
          'contractor': 'Test Company',
          'location': GeoPoint(37.7749, -122.4194),
        },
        'matchesCriteria': true,
        'deleted': false,
        'local': 123,
        'classification': 'Journeyman Lineman',
        'company': 'Test Company',
        'location': 'San Francisco, CA',
        'hours': 40,
        'wage': 35.0,
        'sub': 'Subcontractor A',
        'jobClass': 'Transmission',
        'localNumber': 123,
        'qualifications': 'CDL required',
        'datePosted': '2023-01-01',
        'jobDescription': 'Test job description',
        'jobTitle': 'Lineman Position',
        'perDiem': '100/day',
        'agreement': 'Union Agreement',
        'numberOfJobs': '3',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'startDate': '2023-01-15',
        'startTime': '08:00',
        'booksYourOn': [123, 456],
        'typeOfWork': 'Transmission',
        'duration': '6 months',
        'voltageLevel': 'High Voltage',
      };

      final job = Job.fromJson(testJson);

      expect(job.id, 'job123');
      expect(job.sharerId, 'user123');
      expect(job.jobDetails['hours'], 40);
      expect(job.jobDetails['payRate'], 35.0);
      expect(job.jobDetails['perDiem'], '100/day');
      expect(job.jobDetails['contractor'], 'Test Company');
      expect(job.jobDetails['location'], GeoPoint(37.7749, -122.4194));
      expect(job.matchesCriteria, true);
      expect(job.deleted, false);
      expect(job.local, 123);
      expect(job.classification, 'Journeyman Lineman');
      expect(job.company, 'Test Company');
      expect(job.location, 'San Francisco, CA');
      expect(job.hours, 40);
      expect(job.wage, 35.0);
      expect(job.sub, 'Subcontractor A');
      expect(job.jobClass, 'Transmission');
      expect(job.localNumber, 123);
      expect(job.qualifications, 'CDL required');
      expect(job.datePosted, '2023-01-01');
      expect(job.jobDescription, 'Test job description');
      expect(job.jobTitle, 'Lineman Position');
      expect(job.perDiem, '100/day');
      expect(job.agreement, 'Union Agreement');
      expect(job.numberOfJobs, '3');
      expect(job.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(job.startDate, '2023-01-15');
      expect(job.startTime, '08:00');
      expect(job.booksYourOn, [123, 456]);
      expect(job.typeOfWork, 'Transmission');
      expect(job.duration, '6 months');
      expect(job.voltageLevel, 'High Voltage');
      expect(job.isValid(), true);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {},
        'company': 'Test Company',
        'location': 'Test Location',
      };

      final job = Job.fromJson(minimalJson);

      expect(job.id, 'job123');
      expect(job.sharerId, 'user123');
      expect(job.jobDetails, isNotNull);
      expect(job.company, 'Test Company');
      expect(job.location, 'Test Location');
      expect(job.matchesCriteria, false);
      expect(job.deleted, false);
      expect(job.local, null);
      expect(job.classification, null);
      expect(job.hours, null);
      expect(job.wage, null);
      expect(job.isValid(), true);
    });

    test('toJson serializes Job correctly with Firestore types', () {
      final job = Job(
        id: 'job123',
        sharerId: 'user123',
        jobDetails: {
          'hours': 40,
          'payRate': 35.0,
          'location': GeoPoint(37.7749, -122.4194),
        },
        matchesCriteria: true,
        deleted: false,
        company: 'Test Company',
        location: 'San Francisco, CA',
        timestamp: Timestamp.fromDate(DateTime(2023, 1, 1)),
      );

      final jsonData = job.toJson(useFirestoreTypes: true);

      expect(jsonData['id'], 'job123');
      expect(jsonData['sharerId'], 'user123');
      expect(jsonData['jobDetails'], {
        'hours': 40,
        'payRate': 35.0,
        'location': GeoPoint(37.7749, -122.4194),
      });
      expect(jsonData['matchesCriteria'], true);
      expect(jsonData['deleted'], false);
      expect(jsonData['company'], 'Test Company');
      expect(jsonData['location'], 'San Francisco, CA');
      expect(jsonData['timestamp'], Timestamp.fromDate(DateTime(2023, 1, 1)));
    });

    test('toFirestore convenience method works', () {
      final job = Job(
        id: 'job123',
        sharerId: 'user123',
        jobDetails: {
          'hours': 40,
          'payRate': 35.0,
        },
        company: 'Test Company',
        location: 'Test Location',
      );

      final firestoreData = job.toFirestore();

      expect(firestoreData['id'], 'job123');
      expect(firestoreData['sharerId'], 'user123');
      expect(firestoreData['jobDetails'], {
        'hours': 40,
        'payRate': 35.0,
      });
      expect(firestoreData['matchesCriteria'], false);
      expect(firestoreData['deleted'], false);
      expect(firestoreData['company'], 'Test Company');
      expect(firestoreData['location'], 'Test Location');
    });

    test('fromFirestore creates Job from Firestore document', () async {
      final testData = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {
          'hours': 40,
          'payRate': 35.0,
        },
        'company': 'Test Company',
        'location': 'Test Location',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      final docRef = fakeFirestore.collection('jobs').doc('job123');
      await docRef.set(testData);

      final doc = await docRef.get();
      final job = Job.fromFirestore(doc);

      expect(job.id, 'job123');
      expect(job.sharerId, 'user123');
      expect(job.jobDetails['hours'], 40);
      expect(job.jobDetails['payRate'], 35.0);
      expect(job.company, 'Test Company');
      expect(job.location, 'Test Location');
      expect(job.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(job.isValid(), true);
    });

    test('isValid returns true for valid data', () {
      final job = Job(
        id: 'job123',
        sharerId: 'user123',
        jobDetails: {'hours': 40},
        company: 'Test Company',
        location: 'Test Location',
      );

      expect(job.isValid(), true);
    });

    test('isValid returns false for empty id', () {
      final job = Job(
        id: '',
        sharerId: 'user123',
        jobDetails: {'hours': 40},
        company: 'Test Company',
        location: 'Test Location',
      );

      expect(job.isValid(), false);
    });

    test('isValid returns false for empty sharerId', () {
      final job = Job(
        id: 'job123',
        sharerId: '',
        jobDetails: {'hours': 40},
        company: 'Test Company',
        location: 'Test Location',
      );

      expect(job.isValid(), false);
    });

    test('isValid returns false for empty jobDetails', () {
      final job = Job(
        id: 'job123',
        sharerId: 'user123',
        jobDetails: {},
        company: 'Test Company',
        location: 'Test Location',
      );

      expect(job.isValid(), false);
    });

    test('copyWith creates new instance with updated fields', () {
      final originalJob = Job(
        id: 'job123',
        sharerId: 'user123',
        jobDetails: {'hours': 40},
        company: 'Original Company',
        location: 'Original Location',
      );

      final updatedJob = originalJob.copyWith(
        company: 'Updated Company',
        location: 'Updated Location',
        matchesCriteria: true,
      );

      expect(updatedJob.company, 'Updated Company');
      expect(updatedJob.location, 'Updated Location');
      expect(updatedJob.matchesCriteria, true);
      expect(updatedJob.id, 'job123'); // Unchanged
      expect(originalJob.company, 'Original Company'); // Original unchanged
    });

    test('parseDateTime handles different formats correctly', () {
      final jobJson = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {},
        'company': 'Test Company',
        'location': 'Test Location',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      final job = Job.fromJson(jobJson);

      expect(job.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
    });

    test('parseInt handles different input types correctly', () {
      final jobJson = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {},
        'company': 'Test Company',
        'location': 'Test Location',
        'local': '123', // String
        'hours': 40.5, // Double
      };

      final job = Job.fromJson(jobJson);

      expect(job.local, 123);
      expect(job.hours, 40); // Truncated from double
    });

    test('parseDouble handles currency formatting correctly', () {
      final jobJson = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {},
        'company': 'Test Company',
        'location': 'Test Location',
        'wage': '\$35.50/hr',
      };

      final job = Job.fromJson(jobJson);

      expect(job.wage, 35.5);
    });

    test('fromJson handles certification in hours field', () {
      final jobJson = {
        'id': 'job123',
        'sharerId': 'user123',
        'jobDetails': {},
        'company': 'Test Company',
        'location': 'Test Location',
        'hours': 'CDL, First Aid/CPR', // Certification string
      };

      final job = Job.fromJson(jobJson);

      expect(job.jobClass, 'CDL, First Aid/CPR');
      expect(job.qualifications, 'CDL, First Aid/CPR');
      expect(job.hours, null);
    });

    test('toJson excludes null values when includeNullValues is false', () {
      final job = Job(
        id: 'job123',
        sharerId: 'user123',
        jobDetails: {'hours': 40},
        company: 'Test Company',
        location: 'Test Location',
        local: null,
        classification: null,
      );

      final jsonData = job.toJson(includeNullValues: false);

      expect(jsonData.containsKey('local'), false);
      expect(jsonData.containsKey('classification'), false);
    });
  });
}