import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/security/input_validator.dart';
import 'package:journeyman_jobs/security/rate_limiter.dart';
import 'package:journeyman_jobs/security/secure_firestore_service.dart';

/// Integration tests for SecureFirestoreService.
///
/// Tests security features including:
/// - Input validation for all Firestore operations
/// - Rate limiting for write operations
/// - IBEW-specific field validation
/// - Injection prevention
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SecureFirestoreService secureFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    secureFirestore = SecureFirestoreService(
      firestore: fakeFirestore,
      rateLimiter: RateLimiter(
        customConfigs: {
          'firestore_write': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
            costPerRequest: 2,
          ),
        },
      ),
    );
  });

  tearDown(() {
    secureFirestore.dispose();
  });

  group('SecureFirestoreService - Document Operations', () {
    test('should get document with validated parameters', () async {
      // Setup: Create test document
      await fakeFirestore.collection('users').doc('user123').set({
        'name': 'Test User',
        'email': 'test@example.com',
      });

      // Execute: Get document
      final doc = await secureFirestore.getDocument(
        collection: 'users',
        documentId: 'user123',
      );

      // Verify
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('name', 'Test User'));
    });

    test('should reject invalid collection paths', () async {
      expect(
        () => secureFirestore.getDocument(
          collection: 'users/123', // Even number of segments
          documentId: 'doc1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should reject invalid document IDs', () async {
      expect(
        () => secureFirestore.getDocument(
          collection: 'users',
          documentId: 'user/123', // Contains forward slash
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should set document with validated data', () async {
      await secureFirestore.setDocument(
        collection: 'users',
        documentId: 'user123',
        data: {
          'name': 'John Doe',
          'email': 'john@example.com',
        },
        userId: 'user123',
      );

      final doc = await fakeFirestore.collection('users').doc('user123').get();
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('name', 'John Doe'));
    });

    test('should reject data with invalid field names', () async {
      expect(
        () => secureFirestore.setDocument(
          collection: 'users',
          documentId: 'user123',
          data: {
            'user.name': 'Invalid', // Contains dot
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should update document with validated data', () async {
      // Setup: Create initial document
      await fakeFirestore.collection('users').doc('user123').set({
        'name': 'Old Name',
        'email': 'old@example.com',
      });

      // Execute: Update
      await secureFirestore.updateDocument(
        collection: 'users',
        documentId: 'user123',
        data: {'name': 'New Name'},
        userId: 'user123',
      );

      // Verify
      final doc = await fakeFirestore.collection('users').doc('user123').get();
      expect(doc.data(), containsPair('name', 'New Name'));
      expect(doc.data(), containsPair('email', 'old@example.com'));
    });

    test('should delete document', () async {
      // Setup: Create document
      await fakeFirestore.collection('users').doc('user123').set({
        'name': 'Test User',
      });

      // Execute: Delete
      await secureFirestore.deleteDocument(
        collection: 'users',
        documentId: 'user123',
        userId: 'user123',
      );

      // Verify
      final doc = await fakeFirestore.collection('users').doc('user123').get();
      expect(doc.exists, isFalse);
    });
  });

  group('SecureFirestoreService - Rate Limiting', () {
    test('should enforce rate limits on write operations', () async {
      // Make 5 writes (5 * 2 tokens = 10 tokens)
      for (var i = 0; i < 5; i++) {
        await secureFirestore.setDocument(
          collection: 'users',
          documentId: 'user$i',
          data: {'name': 'User $i'},
          userId: 'user123',
        );
      }

      // 6th write should fail (would need 12 tokens)
      expect(
        () => secureFirestore.setDocument(
          collection: 'users',
          documentId: 'user6',
          data: {'name': 'User 6'},
          userId: 'user123',
        ),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('should track rate limits separately per user', () async {
      // User 1 makes writes
      for (var i = 0; i < 5; i++) {
        await secureFirestore.setDocument(
          collection: 'users',
          documentId: 'user1_$i',
          data: {'name': 'User 1 - $i'},
          userId: 'user1',
        );
      }

      // User 1 should be rate limited
      expect(
        () => secureFirestore.setDocument(
          collection: 'users',
          documentId: 'user1_6',
          data: {'name': 'User 1 - 6'},
          userId: 'user1',
        ),
        throwsA(isA<RateLimitException>()),
      );

      // User 2 should still have tokens
      await secureFirestore.setDocument(
        collection: 'users',
        documentId: 'user2_1',
        data: {'name': 'User 2 - 1'},
        userId: 'user2',
      );

      final doc = await fakeFirestore.collection('users').doc('user2_1').get();
      expect(doc.exists, isTrue);
    });
  });

  group('SecureFirestoreService - Query Operations', () {
    test('should query with validated field names', () async {
      // Setup: Create test documents
      await fakeFirestore.collection('jobs').doc('job1').set({
        'company': 'ABC Electric',
        'local': 123,
        'wage': 45.50,
      });

      await fakeFirestore.collection('jobs').doc('job2').set({
        'company': 'XYZ Electric',
        'local': 456,
        'wage': 50.00,
      });

      // Execute: Query
      final results = await secureFirestore.query(
        collection: 'jobs',
        field: 'local',
        value: 123,
      );

      // Verify
      expect(results.docs.length, equals(1));
      expect(results.docs.first.data(), containsPair('company', 'ABC Electric'));
    });

    test('should reject queries with invalid field names', () async {
      expect(
        () => secureFirestore.query(
          collection: 'jobs',
          field: 'local.number', // Contains dot
          value: 123,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should enforce query limit bounds', () async {
      expect(
        () => secureFirestore.query(
          collection: 'jobs',
          field: 'local',
          value: 123,
          limit: 0, // Too low
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => secureFirestore.query(
          collection: 'jobs',
          field: 'local',
          value: 123,
          limit: 101, // Too high
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should query with multiple conditions', () async {
      // Setup
      await fakeFirestore.collection('jobs').doc('job1').set({
        'company': 'ABC Electric',
        'local': 123,
        'classification': 'Inside Wireman',
      });

      await fakeFirestore.collection('jobs').doc('job2').set({
        'company': 'XYZ Electric',
        'local': 123,
        'classification': 'Journeyman Lineman',
      });

      // Execute: Query with multiple conditions
      final results = await secureFirestore.queryMultiple(
        collection: 'jobs',
        conditions: {
          'local': 123,
          'classification': 'Inside Wireman',
        },
      );

      // Verify
      expect(results.docs.length, equals(1));
      expect(results.docs.first.data(), containsPair('company', 'ABC Electric'));
    });

    test('should get collection with pagination', () async {
      // Setup: Create multiple documents
      for (var i = 0; i < 30; i++) {
        await fakeFirestore.collection('jobs').doc('job$i').set({
          'company': 'Company $i',
          'local': i,
        });
      }

      // Execute: Get first page
      final page1 = await secureFirestore.getCollection(
        collection: 'jobs',
        limit: 10,
      );

      expect(page1.docs.length, equals(10));

      // Execute: Get second page
      final page2 = await secureFirestore.getCollection(
        collection: 'jobs',
        limit: 10,
        startAfter: page1.docs.last,
      );

      expect(page2.docs.length, equals(10));
      expect(page2.docs.first.id, isNot(equals(page1.docs.first.id)));
    });
  });

  group('SecureFirestoreService - IBEW-Specific Validations', () {
    test('should validate local number when creating job', () async {
      expect(
        () => secureFirestore.createJobDocument(
          documentId: 'job1',
          jobData: {
            'company': 'ABC Electric',
            'local': 0, // Invalid: must be 1-9999
            'wage': 45.50,
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => secureFirestore.createJobDocument(
          documentId: 'job1',
          jobData: {
            'company': 'ABC Electric',
            'local': 10000, // Invalid: too high
            'wage': 45.50,
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should validate classification when creating job', () async {
      expect(
        () => secureFirestore.createJobDocument(
          documentId: 'job1',
          jobData: {
            'company': 'ABC Electric',
            'local': 123,
            'classification': 'Invalid Classification',
            'wage': 45.50,
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should validate wage when creating job', () async {
      expect(
        () => secureFirestore.createJobDocument(
          documentId: 'job1',
          jobData: {
            'company': 'ABC Electric',
            'local': 123,
            'wage': 0.50, // Too low
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => secureFirestore.createJobDocument(
          documentId: 'job1',
          jobData: {
            'company': 'ABC Electric',
            'local': 123,
            'wage': 1000.0, // Too high
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should create job with valid IBEW fields', () async {
      await secureFirestore.createJobDocument(
        documentId: 'job1',
        jobData: {
          'company': 'ABC Electric',
          'local': 123,
          'classification': 'Inside Wireman',
          'wage': 45.50,
        },
        userId: 'user123',
      );

      final doc = await fakeFirestore.collection('jobs').doc('job1').get();
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('local', 123));
      expect(doc.data(), containsPair('classification', 'Inside Wireman'));
      expect(doc.data(), containsPair('wage', 45.50));
    });
  });

  group('SecureFirestoreService - Nested Data Validation', () {
    test('should validate nested field names', () async {
      await secureFirestore.setDocument(
        collection: 'users',
        documentId: 'user123',
        data: {
          'name': 'John Doe',
          'preferences': {
            'theme': 'dark',
            'notifications': true,
          },
        },
        userId: 'user123',
      );

      final doc = await fakeFirestore.collection('users').doc('user123').get();
      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['preferences'], isA<Map>());
    });

    test('should reject nested data with invalid field names', () async {
      expect(
        () => secureFirestore.setDocument(
          collection: 'users',
          documentId: 'user123',
          data: {
            'name': 'John Doe',
            'preferences': {
              'theme.color': 'dark', // Invalid: contains dot
            },
          },
          userId: 'user123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
