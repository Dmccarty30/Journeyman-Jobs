import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/user_model.dart';

class MockDocumentSnapshot implements DocumentSnapshot {
  @override
  String get id => '';

  @override
  Map<String, dynamic>? get data => <String, dynamic>{};

  @override
  bool get exists => true;

  @override
  DocumentSnapshot get reference => throw UnimplementedError();

  @override
  dynamic get(String field) => throw UnimplementedError();

  @override
  bool hasData() => throw UnimplementedError();

  @override
  Map<String, Object?>? dataAsMap() => throw UnimplementedError();
}

void main() {
  group('UserModel Tests', () {
    late MockDocumentSnapshot mockDoc;
    late Map<String, dynamic> testData;
    late Timestamp testTimestamp;

    setUp(() {
      mockDoc = MockDocumentSnapshot();
      testTimestamp = Timestamp.fromDate(DateTime(2023, 1, 1));
      testData = {
        'username': 'testuser',
        'classification': 'Journeyman',
        'homeLocal': 123,
        'role': 'member',
        'crewIds': ['crew1'],
        'email': 'test@example.com',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'onlineStatus': true,
        'lastActive': testTimestamp,
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '123-456-7890',
        'address1': '123 Main St',
        'address2': 'Apt 4',
        'city': 'Anytown',
        'state': 'CA',
        'zipcode': 12345,
        'ticketNumber': 'T12345',
        'isWorking': true,
        'booksOn': true,
        'constructionTypes': ['transmission', 'distribution'],
        'hoursPerWeek': 40,
        'perDiemRequirement': 100.0,
        'preferredLocals': [123, 456],
        'fcmToken': 'test-fcm-token',
      };
    });

    test('fromFirestore creates valid UserModel from complete Firestore data', () {
      // Manually set properties for mock
      (mockDoc as dynamic).id = 'test-uid';
      (mockDoc as dynamic).data = () => testData;

      final user = UserModel.fromFirestore(mockDoc);

      expect(user.uid, 'test-uid');
      expect(user.username, 'testuser');
      expect(user.classification, 'Journeyman');
      expect(user.homeLocal, 123);
      expect(user.role, 'member');
      expect(user.crewIds, ['crew1']);
      expect(user.email, 'test@example.com');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.onlineStatus, true);
      expect(user.lastActive, testTimestamp);
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.phoneNumber, '123-456-7890');
      expect(user.address1, '123 Main St');
      expect(user.address2, 'Apt 4');
      expect(user.city, 'Anytown');
      expect(user.state, 'CA');
      expect(user.zipcode, 12345);
      expect(user.ticketNumber, 'T12345');
      expect(user.isWorking, true);
      expect(user.booksOn, true);
      expect(user.constructionTypes, ['transmission', 'distribution']);
      expect(user.hoursPerWeek, 40);
      expect(user.perDiemRequirement, 100.0);
      expect(user.preferredLocals, [123, 456]);
      expect(user.fcmToken, 'test-fcm-token');
      expect(user.isValid(), true);
    });

    test('fromFirestore handles missing optional fields with defaults', () {
      final incompleteData = {
        'username': 'testuser',
        'classification': 'Journeyman',
        'homeLocal': 123,
        'role': 'member',
        'email': 'test@example.com',
        'lastActive': testTimestamp,
        'firstName': 'John',
        'lastName': 'Doe',
      };

      (mockDoc as dynamic).id = 'test-uid';
      (mockDoc as dynamic).data = () => incompleteData;

      final user = UserModel.fromFirestore(mockDoc);

      expect(user.uid, 'test-uid');
      expect(user.username, 'testuser');
      expect(user.classification, 'Journeyman');
      expect(user.homeLocal, 123);
      expect(user.role, 'member');
      expect(user.email, 'test@example.com');
      expect(user.avatarUrl, null);
      expect(user.onlineStatus, false);
      expect(user.lastActive, testTimestamp);
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.phoneNumber, '');
      expect(user.address1, '');
      expect(user.address2, null);
      expect(user.city, '');
      expect(user.state, '');
      expect(user.zipcode, 0);
      expect(user.ticketNumber, '');
      expect(user.isWorking, false);
      expect(user.booksOn, false);
      expect(user.constructionTypes, []);
      expect(user.hoursPerWeek, 0);
      expect(user.perDiemRequirement, 0.0);
      expect(user.preferredLocals, []);
      expect(user.fcmToken, null);
      expect(user.isValid(), true);
    });

    test('toFirestore serializes UserModel correctly including fcmToken', () {
      final user = UserModel(
        uid: 'test-uid',
        username: 'testuser',
        classification: 'Journeyman',
        homeLocal: 123,
        role: 'member',
        email: 'test@example.com',
        lastActive: testTimestamp,
        firstName: 'John',
        lastName: 'Doe',
        fcmToken: 'test-fcm-token',
      );

      final firestoreData = user.toFirestore();

      expect(firestoreData['username'], 'testuser');
      expect(firestoreData['classification'], 'Journeyman');
      expect(firestoreData['homeLocal'], 123);
      expect(firestoreData['role'], 'member');
      expect(firestoreData['crewIds'], []);
      expect(firestoreData['email'], 'test@example.com');
      expect(firestoreData['avatarUrl'], null);
      expect(firestoreData['onlineStatus'], false);
      expect(firestoreData['lastActive'], testTimestamp);
      expect(firestoreData['fcmToken'], 'test-fcm-token');
    });

    test('toFirestore excludes fcmToken if null', () {
      final user = UserModel(
        uid: 'test-uid',
        username: 'testuser',
        classification: 'Journeyman',
        homeLocal: 123,
        role: 'member',
        email: 'test@example.com',
        lastActive: testTimestamp,
        firstName: 'John',
        lastName: 'Doe',
      );

      final firestoreData = user.toFirestore();

      expect(firestoreData.containsKey('fcmToken'), false);
    });

    test('isValid returns true for valid data', () {
      final user = UserModel(
        uid: 'test-uid',
        username: 'testuser',
        classification: 'Journeyman',
        homeLocal: 123,
        role: 'member',
        email: 'test@example.com',
        lastActive: testTimestamp,
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(user.isValid(), true);
    });

    test('isValid returns false for empty username', () {
      final user = UserModel(
        uid: 'test-uid',
        username: '',
        classification: 'Journeyman',
        homeLocal: 123,
        role: 'member',
        email: 'test@example.com',
        lastActive: testTimestamp,
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(user.isValid(), false);
    });

    test('isValid returns false for empty classification', () {
      final user = UserModel(
        uid: 'test-uid',
        username: 'testuser',
        classification: '',
        homeLocal: 123,
        role: 'member',
        email: 'test@example.com',
        lastActive: testTimestamp,
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(user.isValid(), false);
    });

    test('fromFirestore handles null fcmToken', () {
      testData.remove('fcmToken');
      (mockDoc as dynamic).id = 'test-uid';
      (mockDoc as dynamic).data = () => testData;

      final user = UserModel.fromFirestore(mockDoc);

      expect(user.fcmToken, null);
    });

    test('fromFirestore handles perDiemRequirement as double', () {
      testData['perDiemRequirement'] = 100.5;
      (mockDoc as dynamic).id = 'test-uid';
      (mockDoc as dynamic).data = () => testData;

      final user = UserModel.fromFirestore(mockDoc);

      expect(user.perDiemRequirement, 100.5);
    });
  });
}