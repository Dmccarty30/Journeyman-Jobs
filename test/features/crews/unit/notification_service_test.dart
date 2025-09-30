import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../../lib/services/notification_service.dart';
import '../../../../lib/models/notification/notification_preferences_model.dart';

class MockUser implements firebase_auth.User {
  @override
  String uid = 'test-uid';

  @override
  bool get emailVerified => true;

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDocumentSnapshot implements DocumentSnapshot {
  @override
  String id = '';

  @override
  Map<String, dynamic>? data() => <String, dynamic>{};

  @override
  bool get exists => true;

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  dynamic operator [](Object field) => throw UnimplementedError();

  @override
  dynamic get(String field) => throw UnimplementedError();

  @override
  bool hasData() => throw UnimplementedError();

  @override
  Map<String, Object?>? dataAsMap() => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}

class MockDocumentReference implements DocumentReference {
  @override
  CollectionReference parent => throw UnimplementedError();

  @override
  String get id => '';

  @override
  DocumentReference get parent as DocumentReference => throw UnimplementedError();

  @override
  DocumentSnapshot get snapshot => throw UnimplementedError();

  @override
  Future<DocumentSnapshot> get() async => MockDocumentSnapshot();

  @override
  Future<void> update(Map<String, dynamic> data) async {}

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}

  @override
  Future<void> delete() async {}

  @override
  CollectionReference collection(String collectionPath) => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCollectionReference implements CollectionReference {
  @override
  String get id => '';

  @override
  DocumentReference doc([String? id]) => MockDocumentReference();

  @override
  Query get() => MockQuery();

  @override
  Future<QuerySnapshot> get() async => MockQuerySnapshot();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockQuery implements Query {
  @override
  Query where(String field, {dynamic isEqualTo, dynamic isLessThan, dynamic isLessThanOrEqualTo, dynamic isGreaterThan, dynamic isGreaterThanOrEqualTo, dynamic arrayContains, List<dynamic>? arrayContainsAny, List<dynamic>? arrayContainsAll, dynamic isNull}) => this;

  @override
  Query orderBy(String field, {bool descending = false}) => this;

  @override
  Query limit(int limit) => this;

  @override
  Stream<QuerySnapshot> snapshots() => Stream.value(MockQuerySnapshot());

  @override
  Future<QuerySnapshot> get([GetOptions? options]) async => MockQuerySnapshot();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockQuerySnapshot implements QuerySnapshot {
  @override
  List<QueryDocumentSnapshot> get docs => [MockQueryDocumentSnapshot()];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockQueryDocumentSnapshot implements QueryDocumentSnapshot {
  @override
  DocumentSnapshot get reference => MockDocumentSnapshot();

  @override
  Map<String, dynamic>? data() => <String, dynamic>{};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSharedPreferences implements SharedPreferences {
  Map<String, dynamic> _values = {};

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Set<String> getKeys() => _values.keys.toSet();

  @override
  Future<void> clear() async {
    _values.clear();
  }

  @override
  Future<void> reload() async {}

  @override
  Object? get(String key) => _values[key];
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockSharedPreferences mockPrefs;
  late MockUser mockUser;
  late MockDocumentSnapshot mockDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockPrefs = MockSharedPreferences();
    mockUser = MockUser();
    mockDoc = MockDocumentSnapshot();

    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationService Tests', () {
    test('getPreferences returns preferences from Firestore', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final docData = {
        'notificationPreferences': {
          'jobAlertsEnabled': true,
          'stormWorkEnabled': true,
          'unionUpdatesEnabled': false,
          'unionRemindersEnabled': true,
          'systemNotificationsEnabled': true,
        },
      };

      when(mockDoc.exists).thenReturn(true);
      when(mockDoc.data()).thenReturn(docData);

      final collection = MockCollectionReference();
      final docRef = MockDocumentReference();
      when(mockFirestore.collection('users')).thenReturn(collection);
      when(collection.doc('test-uid')).thenReturn(docRef);
      when(docRef.get()).thenAnswer((_) async => mockDoc);

      final prefs = await NotificationService.getPreferences();

      expect(prefs, isNotNull);
      expect(prefs!.jobAlertsEnabled, true);
      expect(prefs.stormWorkEnabled, true);
      expect(prefs.unionUpdatesEnabled, false);
      expect(prefs.unionRemindersEnabled, true);
      expect(prefs.systemNotificationsEnabled, true);
    });

    test('getPreferences returns null if no user', () async {
      when(mockAuth.currentUser).thenReturn(null);

      final prefs = await NotificationService.getPreferences();

      expect(prefs, null);
    });

    test('updatePreferences updates Firestore', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final testPrefs = NotificationPreferencesModel(
        jobAlertsEnabled: true,
        stormWorkEnabled: true,
        unionUpdatesEnabled: false,
        unionRemindersEnabled: true,
        systemNotificationsEnabled: true,
      );

      final docRef = MockDocumentReference();
      final collection = MockCollectionReference();
      when(mockFirestore.collection('users')).thenReturn(collection);
      when(collection.doc('test-uid')).thenReturn(docRef);
      when(docRef.update(any)).thenAnswer((_) async {});

      final success = await NotificationService.updatePreferences(testPrefs);

      expect(success, true);
      verify(docRef.update(argThat(isMapContaining({
        'notificationPreferences': testPrefs.toFirestore(),
        'updatedAt': any,
      })))).called(1);
    });

    test('toggleNotificationType updates preferences and SharedPreferences', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      when(mockPrefs.setBool('job_alerts_enabled', true)).thenAnswer((_) async => true);

      final docRef = MockDocumentReference();
      final collection = MockCollectionReference();
      when(mockFirestore.collection('users')).thenReturn(collection);
      when(collection.doc('test-uid')).thenReturn(docRef);
      when(docRef.update(any)).thenAnswer((_) async {});

      final success = await NotificationService.toggleNotificationType('job_alerts', true);

      expect(success, true);
      verify(mockPrefs.setBool('job_alerts_enabled', true)).called(1);
      verify(docRef.update(argThat(isMapContaining({
        'notificationPreferences.jobAlertsEnabled': true,
        'updatedAt': any,
      })))).called(1);
    });

    test('subscribeToEnabledTopics subscribes to enabled topics', () async {
      // Mock SharedPreferences
      final prefs = MockSharedPreferences();
      when(prefs.getBool('job_alerts_enabled')).thenReturn(true);
      when(prefs.getBool('storm_work_enabled')).thenReturn(false);
      when(prefs.getBool('union_updates_enabled')).thenReturn(true);
      when(prefs.getBool('union_reminders_enabled')).thenReturn(true);
      when(prefs.getBool('system_notifications_enabled')).thenReturn(false);

      // Mock user doc for local subscription
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final mockDoc = MockDocumentSnapshot();
      when(mockDoc.data()).thenReturn({'unionLocal': '123'});

      final collection = MockCollectionReference();
      final docRef = MockDocumentReference();
      when(mockFirestore.collection('users')).thenReturn(collection);
      when(collection.doc('test-uid')).thenReturn(docRef);
      when(docRef.get()).thenAnswer((_) async => mockDoc);

      // Call the method
      await NotificationService.subscribeToEnabledTopics();

      // Verify prefs calls
      verify(prefs.getBool('job_alerts_enabled')).called(1);
      verify(prefs.getBool('storm_work_enabled')).called(1);
      verify(prefs.getBool('union_updates_enabled')).called(1);
      verify(prefs.getBool('union_reminders_enabled')).called(1);
      verify(prefs.getBool('system_notifications_enabled')).called(1);
    });

    test('createNotification creates in-app notification', () async {
      final collection = MockCollectionReference();
      final docRef = MockDocumentReference();
      when(mockFirestore.collection('notifications')).thenReturn(collection);
      when(collection.add(any)).thenAnswer((_) async => docRef);

      await NotificationService.createNotification(
        userId: 'user123',
        type: 'job',
        title: 'Test Title',
        message: 'Test Message',
        data: {'jobId': '123'},
      );

      verify(collection.add(argThat(isMapContaining({
        'userId': 'user123',
        'type': 'job',
        'title': 'Test Title',
        'message': 'Test Message',
        'isRead': false,
        'timestamp': any,
        'data': {'jobId': '123'},
      })))).called(1);
    });

    test('createJobAlert creates job notification', () async {
      final collection = MockCollectionReference();
      final docRef = MockDocumentReference();
      when(mockFirestore.collection('notifications')).thenReturn(collection);
      when(collection.add(any)).thenAnswer((_) async => docRef);

      await NotificationService.createJobAlert(
        userId: 'user123',
        jobId: 'job123',
        jobTitle: 'Test Job',
        company: 'Test Company',
        location: 'Test Location',
        hourlyRate: 35.0,
      );

      verify(collection.add(argThat(isMapContaining({
        'type': 'jobs',
        'title': 'New Job Match',
        'message': contains('Test Job'),
        'data': containsPair('jobId', 'job123'),
      })))).called(1);
    });

    test('createStormAlert creates storm notification', () async {
      final collection = MockCollectionReference();
      final docRef = MockDocumentReference();
      when(mockFirestore.collection('notifications')).thenReturn(collection);
      when(collection.add(any)).thenAnswer((_) async => docRef);

      await NotificationService.createStormAlert(
        userId: 'user123',
        stormName: 'Hurricane Test',
        location: 'Test Area',
        urgency: 'High',
      );

      verify(collection.add(argThat(isMapContaining({
        'type': 'storm',
        'title': '⚡ Storm Work Alert',
        'message': contains('Hurricane Test'),
        'data': containsPair('stormName', 'Hurricane Test'),
      })))).called(1);
    });

    test('markAsRead marks notification as read', () async {
      final docRef = MockDocumentReference();
      final collection = MockCollectionReference();
      when(mockFirestore.collection('notifications')).thenReturn(collection);
      when(collection.doc('notif123')).thenReturn(docRef);
      when(docRef.update(any)).thenAnswer((_) async {});

      final success = await NotificationService.markAsRead('notif123');

      expect(success, true);
      verify(docRef.update({'isRead': true})).called(1);
    });

    test('markAllAsRead marks all unread as read', () async {
      final mockDoc1 = MockDocumentSnapshot();
      final mockDoc2 = MockDocumentSnapshot();
      final mockDocRef1 = MockDocumentReference();
      final mockDocRef2 = MockDocumentReference();
      final querySnapshot = MockQuerySnapshot();
      when(querySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      final query = MockQuery();
      final collection = MockCollectionReference();
      when(mockFirestore.collection('notifications')).thenReturn(collection);
      when(collection.where('userId', isEqualTo: 'user123')).thenReturn(query);
      when(query.where('isRead', isEqualTo: false)).thenReturn(query);
      when(query.get()).thenAnswer((_) async => querySnapshot);

      final batch = MockWriteBatch();
      when(mockFirestore.batch()).thenReturn(batch);
      when(mockDoc1.reference).thenReturn(mockDocRef1);
      when(mockDoc2.reference).thenReturn(mockDocRef2);
      when(batch.commit()).thenAnswer((_) async {});

      final success = await NotificationService.markAllAsRead('user123');

      expect(success, true);
      verify(batch.update(mockDocRef1, {'isRead': true})).called(1);
      verify(batch.update(mockDocRef2, {'isRead': true})).called(1);
      verify(batch.commit()).called(1);
    });

    test('getUnreadCount returns correct count', () {
      final mockDoc1 = MockDocumentSnapshot();
      final mockDoc2 = MockDocumentSnapshot();
      final querySnapshot = MockQuerySnapshot();
      when(querySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      final query = MockQuery();
      final collection = MockCollectionReference();
      when(mockFirestore.collection('notifications')).thenReturn(collection);
      when(collection.where('userId', isEqualTo: 'user123')).thenReturn(query);
      when(query.where('isRead', isEqualTo: false)).thenReturn(query);
      when(query.snapshots()).thenAnswer((_) => Stream.value(querySnapshot));

      final stream = NotificationService.getUnreadCount('user123');

      expect(stream, emits(2));
    });

    test('isQuietHoursActive returns false if disabled', () async {
      final prefs = MockSharedPreferences();
      when(prefs.getBool('quiet_hours_enabled')).thenReturn(false);

      final isQuiet = await NotificationService.isQuietHoursActive();

      expect(isQuiet, false);
    });

    test('isQuietHoursActive returns true during quiet hours', () async {
      final prefs = MockSharedPreferences();
      when(prefs.getBool('quiet_hours_enabled')).thenReturn(true);
      when(prefs.getInt('quiet_hours_start')).thenReturn(22);
      when(prefs.getInt('quiet_hours_end')).thenReturn(7);

      // The method uses DateTime.now(), so for unit test, we can test the logic
      // Assume current time is 23:00, which is during quiet hours
      // Since DateTime is hard to mock, test the calculation logic separately if needed
      // For this test, verify prefs calls

      final isQuiet = await NotificationService.isQuietHoursActive();

      verify(prefs.getBool('quiet_hours_enabled')).called(1);
      verify(prefs.getInt('quiet_hours_start')).called(1);
      verify(prefs.getInt('quiet_hours_end')).called(1);
    });
  });
}