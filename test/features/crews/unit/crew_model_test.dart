import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('CrewModel Tests', () {
    group('CrewStats', () {
      test('CrewStats fromFirestore creates valid stats from complete data', () {
        final statsData = {
          'totalJobsShared': 10,
          'totalApplications': 5,
          'averageMatchScore': 85.5,
        };

        final stats = CrewStats.fromFirestore(statsData);

        expect(stats.totalJobsShared, 10);
        expect(stats.totalApplications, 5);
        expect(stats.averageMatchScore, 85.5);
      });

      test('CrewStats fromFirestore handles missing fields with defaults', () {
        final incompleteData = <String, dynamic>{};

        final stats = CrewStats.fromFirestore(incompleteData);

        expect(stats.totalJobsShared, 0);
        expect(stats.totalApplications, 0);
        expect(stats.averageMatchScore, 0.0);
      });

      test('CrewStats toFirestore serializes correctly', () {
        final stats = CrewStats(
          totalJobsShared: 10,
          totalApplications: 5,
          averageMatchScore: 85.5,
        );

        final firestoreData = stats.toFirestore();

        expect(firestoreData['totalJobsShared'], 10);
        expect(firestoreData['totalApplications'], 5);
        expect(firestoreData['averageMatchScore'], 85.5);
      });
    });

    group('Crew', () {
      test('fromFirestore creates valid Crew from complete Firestore data', () async {
        final testData = {
          'name': 'Test Crew',
          'foremanId': 'foreman123',
          'memberIds': ['member1', 'member2'],
          'jobPreferences': {'payMin': 25.0, 'hoursMin': 40},
          'stats': {
            'totalJobsShared': 10,
            'totalApplications': 5,
            'averageMatchScore': 85.5,
          },
        };

        final docRef = fakeFirestore.collection('crews').doc('crew123');
        await docRef.set(testData);

        final doc = await docRef.get();
        final crew = Crew.fromFirestore(doc);

        expect(crew.id, 'crew123');
        expect(crew.name, 'Test Crew');
        expect(crew.foremanId, 'foreman123');
        expect(crew.memberIds, ['member1', 'member2']);
        expect(crew.jobPreferences, {'payMin': 25.0, 'hoursMin': 40});
        expect(crew.stats.totalJobsShared, 10);
        expect(crew.stats.totalApplications, 5);
        expect(crew.stats.averageMatchScore, 85.5);
        expect(crew.isValid(), true);
      });

      test('fromFirestore handles missing optional fields with defaults', () async {
        final incompleteData = {
          'name': 'Test Crew',
          'foremanId': 'foreman123',
        };

        final docRef = fakeFirestore.collection('crews').doc('crew123');
        await docRef.set(incompleteData);

        final doc = await docRef.get();
        final crew = Crew.fromFirestore(doc);

        expect(crew.id, 'crew123');
        expect(crew.name, 'Test Crew');
        expect(crew.foremanId, 'foreman123');
        expect(crew.memberIds, []);
        expect(crew.jobPreferences, {});
        expect(crew.stats.totalJobsShared, 0);
        expect(crew.stats.totalApplications, 0);
        expect(crew.stats.averageMatchScore, 0.0);
        expect(crew.isValid(), true);
      });

      test('toFirestore serializes Crew correctly', () {
        final crew = Crew(
          id: 'crew123',
          name: 'Test Crew',
          foremanId: 'foreman123',
          memberIds: ['member1', 'member2'],
          jobPreferences: {'payMin': 25.0, 'hoursMin': 40},
          stats: CrewStats(
            totalJobsShared: 10,
            totalApplications: 5,
            averageMatchScore: 85.5,
          ),
        );

        final firestoreData = crew.toFirestore();

        expect(firestoreData['name'], 'Test Crew');
        expect(firestoreData['foremanId'], 'foreman123');
        expect(firestoreData['memberIds'], ['member1', 'member2']);
        expect(firestoreData['jobPreferences'], {'payMin': 25.0, 'hoursMin': 40});
        expect(firestoreData['stats'], {
          'totalJobsShared': 10,
          'totalApplications': 5,
          'averageMatchScore': 85.5,
        });
      });

      test('isValid returns true for valid data', () {
        final crew = Crew(
          id: 'crew123',
          name: 'Test Crew',
          foremanId: 'foreman123',
          memberIds: ['member1'],
          jobPreferences: {'payMin': 25.0},
          stats: CrewStats(),
        );

        expect(crew.isValid(), true);
      });

      test('isValid returns false for empty name', () {
        final crew = Crew(
          id: 'crew123',
          name: '',
          foremanId: 'foreman123',
          memberIds: ['member1'],
          jobPreferences: {'payMin': 25.0},
          stats: CrewStats(),
        );

        expect(crew.isValid(), false);
      });

      test('isValid returns false for empty foremanId', () {
        final crew = Crew(
          id: 'crew123',
          name: 'Test Crew',
          foremanId: '',
          memberIds: ['member1'],
          jobPreferences: {'payMin': 25.0},
          stats: CrewStats(),
        );

        expect(crew.isValid(), false);
      });

      test('stats updates correctly when using default constructor', () {
        final crew = Crew(
          id: 'crew123',
          name: 'Test Crew',
          foremanId: 'foreman123',
          stats: CrewStats(
            totalJobsShared: 5,
            totalApplications: 2,
            averageMatchScore: 90.0,
          ),
        );

        expect(crew.stats.totalJobsShared, 5);
        expect(crew.stats.totalApplications, 2);
        expect(crew.stats.averageMatchScore, 90.0);
      });
    });
  });
}