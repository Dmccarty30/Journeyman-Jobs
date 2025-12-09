import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/services/user_profile_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserProfileService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = UserProfileService(firestore: fakeFirestore);
  });

  group('UserProfileService', () {
    const String userId = 'testUser123';

    group('getUserCrews', () {
      test('returns empty list when user document does not exist', () async {
        // Act
        final result = await service.getUserCrews(userId);

        // Assert
        expect(result, isEmpty);
      });

      test('returns empty list when crews field is null', () async {
        // Arrange
        await fakeFirestore.collection('users').doc(userId).set({'otherField': 'value'});

        // Act
        final result = await service.getUserCrews(userId);

        // Assert
        expect(result, isEmpty);
      });

      test('returns crews list when exists', () async {
        // Arrange
        final expectedCrews = ['crew1', 'crew2'];
        await fakeFirestore.collection('users').doc(userId).set({
          'crews': expectedCrews,
        });

        // Act
        final result = await service.getUserCrews(userId);

        // Assert
        expect(result, expectedCrews);
      });

      test('returns casted list from dynamic', () async {
        // Arrange
        final expectedCrews = ['crew1', 'crew2'];
        await fakeFirestore.collection('users').doc(userId).set({
          'crews': expectedCrews.map((c) => c as dynamic).toList(),
        });

        // Act
        final result = await service.getUserCrews(userId);

        // Assert
        expect(result, expectedCrews);
      });
    });

    group('getCurrentCrewId', () {
      test('returns null when user document does not exist', () async {
        // Act
        final result = await service.getCurrentCrewId(userId);

        // Assert
        expect(result, isNull);
      });

      test('returns null when currentCrewId field is null', () async {
        // Arrange
        await fakeFirestore.collection('users').doc(userId).set({'otherField': 'value'});

        // Act
        final result = await service.getCurrentCrewId(userId);

        // Assert
        expect(result, isNull);
      });

      test('returns currentCrewId when exists', () async {
        // Arrange
        const expectedCrewId = 'currentCrew123';
        await fakeFirestore.collection('users').doc(userId).set({
          'currentCrewId': expectedCrewId,
        });

        // Act
        final result = await service.getCurrentCrewId(userId);

        // Assert
        expect(result, expectedCrewId);
      });
    });

    group('addToCrewsAndSetCurrent', () {
      test('adds new crew and sets current when user document does not exist', () async {
        // Arrange
        const crewId = 'newCrew123';

        // Act
        await service.addToCrewsAndSetCurrent(userId, crewId);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(userId).get();
        expect(userDoc.exists, true);
        expect(userDoc.data()?['crews'], [crewId]);
        expect(userDoc.data()?['currentCrewId'], crewId);
      });

      test('adds crew to existing list without duplicates and sets current', () async {
        // Arrange
        const crewId = 'newCrew123';
        const existingCrews = ['existingCrew1', 'existingCrew2'];
        await fakeFirestore.collection('users').doc(userId).set({
          'crews': existingCrews,
          'currentCrewId': 'oldCurrent',
        });

        // Act
        await service.addToCrewsAndSetCurrent(userId, crewId);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(userId).get();
        final data = userDoc.data()!;
        expect((data['crews'] as List).length, 3);
        expect((data['crews'] as List).contains(crewId), true);
        expect(data['currentCrewId'], crewId);
      });

      test('does not add duplicate crew to list', () async {
        // Arrange
        const crewId = 'existingCrew123';
        await fakeFirestore.collection('users').doc(userId).set({
          'crews': [crewId],
          'currentCrewId': 'other',
        });

        // Act
        await service.addToCrewsAndSetCurrent(userId, crewId);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(userId).get();
        final data = userDoc.data()!;
        expect((data['crews'] as List).length, 1);
        expect(data['currentCrewId'], crewId);
      });

      test('sets current even if crew not in list (edge case)', () async {
        // Arrange
        const crewId = 'newCrew123';
        await fakeFirestore.collection('users').doc(userId).set({
          'crews': [],
        });

        // Act
        await service.addToCrewsAndSetCurrent(userId, crewId);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(userId).get();
        final data = userDoc.data()!;
        expect((data['crews'] as List), [crewId]);
        expect(data['currentCrewId'], crewId);
      });
    });

    group('Streams', () {
      test('userCrewsStream emits empty list when document does not exist', () async {
        // Act & Assert
        expectLater(
          service.userCrewsStream(userId),
          emits(isEmpty),
        );
      });

      test('currentCrewIdStream emits null when document does not exist', () async {
        // Act & Assert
        expectLater(
          service.currentCrewIdStream(userId),
          emits(isNull),
        );
      });
    });
  });
}