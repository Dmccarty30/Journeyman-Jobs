import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/services/counter_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CounterService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = CounterService(firestore: fakeFirestore);
  });

  group('CounterService', () {
    test('getAndIncrementCrewCounter initializes to 1 when document does not exist', () async {
      // Act
      final result = await service.getAndIncrementCrewCounter();

      // Assert
      expect(result, 1);

      // Verify the document was created with counter 1
      final doc = fakeFirestore
          .collection('config')
          .doc('globalCounters');
      final snapshot = await doc.get();
      expect(snapshot.exists, true);
      expect(snapshot.data()!['crewCounter'], 1);
    });

    test('getAndIncrementCrewCounter increments from existing value', () async {
      // Arrange: Pre-set counter to 5
      await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .set({'crewCounter': 5});

      // Act
      final result = await service.getAndIncrementCrewCounter();

      // Assert
      expect(result, 6);

      // Verify updated
      final snapshot = await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .get();
      expect(snapshot.data()!['crewCounter'], 6);
    });

    test('getAndIncrementCrewCounter handles sequential increments correctly', () async {
      // Arrange: Start from 0
      await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .set({'crewCounter': 0});

      // Act: Multiple calls
      final results = await Future.wait([
        service.getAndIncrementCrewCounter(),
        service.getAndIncrementCrewCounter(),
        service.getAndIncrementCrewCounter(),
      ]);

      // Assert
      expect(results, [1, 2, 3]);

      final snapshot = await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .get();
      expect(snapshot.data()!['crewCounter'], 3);
    });

    test('getCurrentCrewCounter returns 0 when document does not exist', () async {
      // Act
      final result = await service.getCurrentCrewCounter();

      // Assert
      expect(result, 0);
    });

    test('getCurrentCrewCounter returns current value when exists', () async {
      // Arrange
      await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .set({'crewCounter': 10});

      // Act
      final result = await service.getCurrentCrewCounter();

      // Assert
      expect(result, 10);
    });

    test('resetCrewCounter sets new value', () async {
      // Arrange
      await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .set({'crewCounter': 5});

      // Act
      await service.resetCrewCounter(20);

      // Assert
      final snapshot = await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .get();
      expect(snapshot.data()!['crewCounter'], 20);
    });

    test('resetCrewCounter throws for negative value', () async {
      // Act & Assert
      expect(
        () => service.resetCrewCounter(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('ensureCounterDocumentExists creates document if missing', () async {
      // Act
      await service.ensureCounterDocumentExists();

      // Assert
      final snapshot = await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .get();
      expect(snapshot.exists, true);
      expect(snapshot.data()!['crewCounter'], 0);
    });

    test('ensureCounterDocumentExists does nothing if exists', () async {
      // Arrange
      await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .set({'crewCounter': 5});

      // Act
      await service.ensureCounterDocumentExists();

      // Assert: still 5, not reset
      final snapshot = await fakeFirestore
          .collection('config')
          .doc('globalCounters')
          .get();
      expect(snapshot.data()!['crewCounter'], 5);
    });
  });
}