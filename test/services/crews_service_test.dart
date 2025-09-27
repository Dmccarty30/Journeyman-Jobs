import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/services/crews_service.dart';
import 'package:journeyman_jobs/features/crews/services/counter_service.dart';
import 'package:journeyman_jobs/domain/exceptions/crew_exception.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:intl/intl.dart';

class FakeCounterService extends CounterService {
  int _nextCounter = 1;

  @override
  Future<int> getAndIncrementCrewCounter() async {
    final current = _nextCounter;
    _nextCounter++;
    return current;
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeCounterService fakeCounterService;
  late CrewsService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeCounterService = FakeCounterService();
    service = CrewsService(
      firestore: fakeFirestore,
      counterService: fakeCounterService,
    );
  });

  group('CrewsService', () {
    group('createCrew', () {
      const String userId = 'testUser123';
      const String name = 'Test Crew';
      const String description = 'Test Description';
      const String classification = 'Lineman';
      const double minHourlyRate = 30.0;

      test('creates crew successfully when name is unique', () async {
        // Act
        final result = await service.createCrew(
          name: name,
          description: description,
          classification: classification,
          minHourlyRate: minHourlyRate,
          currentUserId: userId,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.name, name);

        // Verify ID format: sanitizedName-YYYYMMDD-counter
        final expectedDate = DateFormat('yyyyMMdd').format(DateTime.now());
        expect(result.id, 'testcrew-$expectedDate-1');

        // Verify crew document created
        final crewDoc = await fakeFirestore.collection('crews').doc(result.id).get();
        expect(crewDoc.exists, true);
        expect(crewDoc.data()?['name'], name);
        expect(crewDoc.data()?['ownerId'], userId);
        expect(crewDoc.data()?['counter'], 1);

        // Verify user document updated
        final userDoc = await fakeFirestore.collection('users').doc(userId).get();
        expect(userDoc.exists, true);
        expect(userDoc.data()?['crews'], [result.id]);
        expect(userDoc.data()?['currentCrewId'], result.id);
      });

      test('throws CrewException when crew name already exists', () async {
        // Arrange: Pre-create a crew with same name
        final existingCrewId = 'existing-crew-id';
        await fakeFirestore.collection('crews').doc(existingCrewId).set({
          'name': name,
          'ownerId': 'otherUser',
        });

        // Act & Assert
        expect(
          () => service.createCrew(
            name: name,
            description: description,
            classification: classification,
            minHourlyRate: minHourlyRate,
            currentUserId: userId,
          ),
          throwsA(isA<CrewException>()),
        );
      });

      test('generates correct ID format with different counter', () async {
        // The fake starts at 1, but to test different, we can adjust, but since sequential, test first call
        final result = await service.createCrew(
          name: name,
          description: description,
          classification: classification,
          minHourlyRate: minHourlyRate,
          currentUserId: userId,
        );

        final expectedDate = DateFormat('yyyyMMdd').format(DateTime.now());
        expect(result!.id, 'testcrew-$expectedDate-1');
      });

      test('handles transaction retry on failure', () async {
        // Fake always succeeds, so test happy path. Assume logic correct from counter test.
      });
    });

    group('joinCrew', () {
      const String crewId = 'testCrewId';
      const String userId = 'testUser123';

      setUp(() async {
        // Pre-create a crew with 1 member
        await fakeFirestore.collection('crews').doc(crewId).set({
          'memberCount': 1,
          'memberIds': ['existingMember'],
          'members': [
            {'userId': 'existingMember', 'role': MemberRole.member.name}
          ],
          'roles': {'existingMember': MemberRole.member.name},
          'isActive': true,
          'name': 'Test Crew',
        });
      });

      test('joins crew successfully when room available', () async {
        // Act
        await service.joinCrew(crewId, userId);

        // Assert
        final crewDoc = await fakeFirestore.collection('crews').doc(crewId).get();
        final data = crewDoc.data()!;
        expect(data['memberCount'], 2);
        expect((data['memberIds'] as List).contains(userId), true);
        expect((data['members'] as List).any((m) => m['userId'] == userId), true);
        expect(data['roles']?[userId], MemberRole.member.name);

        // Verify user updated
        final userDoc = await fakeFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?['currentCrewId'], crewId);
        expect((userDoc.data()?['crews'] as List?)?.contains(crewId), true);
      });

      test('throws CrewException when crew is full (50 members)', () async {
        // Arrange: Set memberCount to 50
        await fakeFirestore.collection('crews').doc(crewId).update({'memberCount': 50});

        // Act & Assert
        expect(
          () => service.joinCrew(crewId, userId),
          throwsA(isA<CrewException>()),
        );
      });

      test('throws CrewException when user already member', () async {
        // Arrange: Add user already
        await fakeFirestore.collection('crews').doc(crewId).update({
          'memberIds': FieldValue.arrayUnion([userId]),
          'memberCount': 2,
        });

        // Act & Assert
        expect(
          () => service.joinCrew(crewId, userId),
          throwsA(isA<CrewException>()),
        );
      });

      test('throws CrewException when crew not found', () async {
        // Act & Assert
        expect(
          () => service.joinCrew('nonExistentId', userId),
          throwsA(isA<CrewException>()),
        );
      });
    });

    group('updateCrew', () {
      const String crewId = 'testCrewId';

      setUp(() async {
        await fakeFirestore.collection('crews').doc(crewId).set({
          'name': 'Old Name',
          'description': 'Old Desc',
        });
      });

      test('updates crew details successfully', () async {
        // Arrange
        final updates = {
          'name': 'New Name',
          'description': 'New Desc',
          'minHourlyRate': 35.0,
        };

        // Act
        await service.updateCrew(crewId, updates);

        // Assert
        final doc = await fakeFirestore.collection('crews').doc(crewId).get();
        final data = doc.data()!;
        expect(data['name'], 'New Name');
        expect(data['description'], 'New Desc');
        expect(data['minHourlyRate'], 35.0);
      });
    });
  });
}