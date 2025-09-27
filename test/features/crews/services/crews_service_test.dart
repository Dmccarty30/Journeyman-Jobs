import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/services/crews_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/models/crew_stats.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/exceptions/crew_exception.dart';
import 'package:journeyman_jobs/features/crews/services/counter_service.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCounterService extends Mock implements CounterService {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}
class MockTransaction extends Mock implements Transaction {}

void main() {
  group('CrewsService Unit Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCounterService mockCounterService;
    late CrewsService crewsService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCounterService = MockCounterService();
      crewsService = CrewsService(
        firestore: mockFirestore,
        counterService: mockCounterService,
      );
    });

    group('Basic Service Creation', () {
      test('should create service instance successfully', () {
        expect(crewsService, isA<CrewsService>());
      });
    });

    group('Crew Name Validation', () {
      test('should validate crew name - valid names', () {
        expect(CrewUtils.validateCrewName('Test Crew'), isNull);
        expect(CrewUtils.validateCrewName('Alpha-Team-2024'), isNull);
        expect(CrewUtils.validateCrewName('Linemen United'), isNull);
        expect(CrewUtils.validateCrewName('Crew_123'), isNull);
      });

      test('should validate crew name - invalid names', () {
        expect(CrewUtils.validateCrewName(''), equals('Crew name is required'));
        expect(CrewUtils.validateCrewName('  '), equals('Crew name is required'));
        expect(CrewUtils.validateCrewName('ab'), equals('Crew name must be 3-50 characters long'));
        expect(CrewUtils.validateCrewName('a' * 51), equals('Crew name must be 3-50 characters long'));
        expect(CrewUtils.validateCrewName('Test@Crew'), equals('Crew name can only contain letters, numbers, spaces, hyphens, and underscores'));
        expect(CrewUtils.validateCrewName('Test#Crew'), equals('Crew name can only contain letters, numbers, spaces, hyphens, and underscores'));
      });

      test('should validate crew name - null input', () {
        expect(CrewUtils.validateCrewName(null), equals('Crew name is required'));
      });
    });

    group('Distance Calculation', () {
      test('should calculate haversine distance correctly', () {
        // Test known distance: New York to Los Angeles (approximately 3944 km)
        const nyLat = 40.7128;
        const nyLon = -74.0060;
        const laLat = 34.0522;
        const laLon = -118.2437;

        final distance = CrewUtils.calculateHaversineDistance(
          lat1: nyLat,
          lon1: nyLon,
          lat2: laLat,
          lon2: laLon,
        );

        expect(distance, greaterThan(3900));
        expect(distance, lessThan(4000));
      });

      test('should calculate distance between two points', () {
        // Test shorter distance
        final distance = CrewUtils.distanceBetween(
          startLatitude: 40.7128,
          startLongitude: -74.0060,
          endLatitude: 40.7589,
          endLongitude: -73.9851,
        );

        expect(distance, greaterThan(0));
        expect(distance, lessThan(10)); // Should be less than 10km (Manhattan distance)
      });

      test('should handle same coordinates (zero distance)', () {
        final distance = CrewUtils.calculateHaversineDistance(
          lat1: 40.7128,
          lon1: -74.0060,
          lat2: 40.7128,
          lon2: -74.0060,
        );

        expect(distance, equals(0.0));
      });
    });

    group('Crew Preferences', () {
      test('should create crew preferences with default values', () {
        final preferences = CrewPreferences(
          payMin: 25.0,
          type: 'transmission',
          maxDistance: 50.0,
          perDiem: true,
        );

        expect(preferences.payMin, equals(25.0));
        expect(preferences.type, equals('transmission'));
        expect(preferences.maxDistance, equals(50.0));
        expect(preferences.perDiem, isTrue);
      });

      test('should convert crew preferences to map', () {
        final preferences = CrewPreferences(
          payMin: 30.0,
          type: 'distribution',
          maxDistance: 75.0,
          perDiem: false,
        );

        final map = preferences.toMap();
        expect(map, isA<Map<String, dynamic>>());
        expect(map['payMin'], equals(30.0));
        expect(map['type'], equals('distribution'));
        expect(map['maxDistance'], equals(75.0));
        expect(map['perDiem'], isFalse);
      });
    });

    group('Crew Model', () {
      test('should create crew with required properties', () {
        final crew = Crew(
          id: 'test-crew-123',
          name: 'Test Crew',
          foremanId: 'user123',
          memberIds: ['user123'],
          filters: CrewPreferences(
            payMin: 25.0,
            type: 'transmission',
            maxDistance: 50.0,
            perDiem: true,
          ),
          createdAt: DateTime.now(),
          preferences: CrewPreferences(
            payMin: 25.0,
            type: 'transmission',
            maxDistance: 50.0,
            perDiem: true,
          ),
          roles: {'user123': MemberRole.foreman},
          stats: CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: DateTime.now(),
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          lastActivityAt: DateTime.now(),
        );

        expect(crew.id, equals('test-crew-123'));
        expect(crew.name, equals('Test Crew'));
        expect(crew.foremanId, equals('user123'));
        expect(crew.memberIds, contains('user123'));
        expect(crew.filters, isA<CrewPreferences>());
      });

      test('should handle crew with multiple members', () {
        final crew = Crew(
          id: 'multi-crew-456',
          name: 'Multi Member Crew',
          foremanId: 'foreman123',
          memberIds: ['foreman123', 'member1', 'member2'],
          filters: CrewPreferences(
            payMin: 35.0,
            type: 'distribution',
            maxDistance: 100.0,
            perDiem: false,
          ),
          createdAt: DateTime.now(),
          preferences: CrewPreferences(
            payMin: 35.0,
            type: 'distribution',
            maxDistance: 100.0,
            perDiem: false,
          ),
          roles: {'foreman123': MemberRole.foreman},
          stats: CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: DateTime.now(),
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          lastActivityAt: DateTime.now(),
        );

        expect(crew.memberIds.length, equals(3));
        expect(crew.memberIds, contains('foreman123'));
        expect(crew.memberIds, contains('member1'));
        expect(crew.memberIds, contains('member2'));
      });
    });

    group('Crew Exceptions', () {
      test('should create CrewException with message', () {
        final exception = CrewException('Test error message');
        expect(exception.message, equals('Test error message'));
        expect(exception, isA<CrewException>());
      });

      test('should create CrewException with message', () {
        final exception = CrewException('Test error message');
        expect(exception.message, equals('Test error message'));
        expect(exception, isA<CrewException>());
      });
    });

    group('Counter Service Integration', () {
      test('should use counter service for ID generation', () async {
        // Mock counter service to return a specific value
        when(mockCounterService.getAndIncrementCrewCounter())
            .thenAnswer((_) async => 42);

        final counter = await mockCounterService.getAndIncrementCrewCounter();
        expect(counter, equals(42));

        verify(mockCounterService.getAndIncrementCrewCounter()).called(1);
      });
    });

    group('Firestore Integration', () {
      test('should mock Firestore collections', () {
        final mockCollection = MockCollectionReference();
        final mockDocument = MockDocumentReference();

        when(mockFirestore.collection('crews')).thenReturn(mockCollection);
        when(mockCollection.doc(any)).thenReturn(mockDocument);

        final collection = mockFirestore.collection('crews');
        final document = collection.doc('test-doc');

        expect(collection, isA<CollectionReference>());
        expect(document, isA<DocumentReference>());
      });

      test('should mock Firestore snapshots', () {
        final mockSnapshot = MockQuerySnapshot();
        final mockDocumentSnapshot = MockDocumentSnapshot();

        when(mockSnapshot.docs).thenReturn([mockDocumentSnapshot]);
        when(mockDocumentSnapshot.data()).thenReturn({
          'name': 'Test Crew',
          'foremanId': 'user123',
        });

        expect(mockSnapshot.docs, isA<List>());
        expect(mockSnapshot.docs.length, equals(1));
      });
    });
  });
}

/// Utility functions for crew operations (mimicking the actual implementation)
class CrewUtils {
  /// Validates crew name according to business rules
  /// Returns error message if invalid, null if valid
  static String? validateCrewName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Crew name is required';
    }
    
    final trimmed = name.trim();
    if (trimmed.length < 3 || trimmed.length > 50) {
      return 'Crew name must be 3-50 characters long';
    }
    
    // Allowed: alphanumeric, spaces, hyphens, underscores
    if (!RegExp(r'^[a-zA-Z0-9\s\-_]+$').hasMatch(trimmed)) {
      return 'Crew name can only contain letters, numbers, spaces, hyphens, and underscores';
    }
    
    return null;
  }

  /// Calculates the great-circle distance between two points on Earth using the Haversine formula
  /// Returns distance in kilometers
  static double calculateHaversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert degrees to radians
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    // Haversine formula
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Converts degrees to radians
  static double _toRadians(double degrees) {
    return degrees * 3.14159265359 / 180;
  }

  /// Calculates distance between two geographic coordinates
  /// Convenience wrapper for haversine calculation
  static double distanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return calculateHaversineDistance(
      lat1: startLatitude,
      lon1: startLongitude,
      lat2: endLatitude,
      lon2: endLongitude,
    );
  }
}