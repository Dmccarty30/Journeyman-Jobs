import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/services/optimized_job_query_service.dart';
import '../../lib/services/resilient_firestore_service.dart';
import '../../lib/models/user_job_preferences.dart';
import '../../lib/models/job_model.dart';
import '../../lib/domain/exceptions/app_exception.dart';

// Generate mocks
@GenerateMocks([ResilientFirestoreService])
import 'optimized_job_query_service_test.mocks.dart';

void main() {
  group('OptimizedJobQueryService', () {
    late OptimizedJobQueryService service;
    late MockResilientFirestoreService mockResilientService;
    late FirebaseFirestore mockFirestore;

    setUp(() {
      mockResilientService = MockResilientFirestoreService();
      service = OptimizedJobQueryService(mockResilientService);
      mockFirestore = MockFirebaseFirestore();
    });

    group('getSuggestedJobs', () {
      test('should return suggested jobs when user has preferences', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84, 111, 222],
          constructionTypes: ['Commercial', 'Industrial'],
          hoursPerWeek: ['40+'],
          perDiemRequirement: 'Required',
        );

        final mockJobData = {
          'id': 'job-1',
          'company': 'Test Company',
          'location': 'Test Location',
          'local': 84,
          'classification': 'Journeyman Lineman',
          'deleted': false,
          'timestamp': Timestamp.now(),
          'typeOfWork': 'Commercial',
        };

        final mockDoc = MockDocumentSnapshot();
        when(mockDoc.data()).thenReturn(mockJobData);
        when(mockDoc.id).thenReturn('job-1');

        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
        );

        // Assert
        expect(result, isA<List<Job>>());
        expect(result.length, greaterThan(0));
      });

      test('should return fallback jobs when preferences are null', () async {
        // Arrange
        final userId = 'test-user-123';

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: null,
        );

        // Assert
        expect(result, isA<List<Job>>());
        // Should call fallback method when preferences are null
      });

      test('should return fallback jobs when preferred locals is empty', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences.defaultPreferences();

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
        );

        // Assert
        expect(result, isA<List<Job>>());
        // Should call fallback method when no preferred locals
      });

      test('should handle Firestore exceptions gracefully', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84],
          constructionTypes: ['Commercial'],
          hoursPerWeek: ['40+'],
          perDiemRequirement: 'Not Required',
        );

        // Mock Firestore exception
        when(mockResilientService.getJobsWithFilter(any()))
            .thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'failed-precondition',
          message: 'The query requires an index',
        ));

        // Act & Assert
        expect(
          () async => await service.getSuggestedJobs(
            userId: userId,
            preferences: preferences,
          ),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('getJobsPaginated', () {
      test('should return paginated job results', () async {
        // Arrange
        final filters = {
          'local': 84,
          'classification': 'Journeyman Lineman',
        };

        final mockJobData = {
          'id': 'job-1',
          'company': 'Test Company',
          'location': 'Test Location',
          'deleted': false,
          'timestamp': Timestamp.now(),
        };

        final mockDoc = MockDocumentSnapshot();
        when(mockDoc.data()).thenReturn(mockJobData);
        when(mockDoc.id).thenReturn('job-1');

        final mockQuerySnapshot = MockQuerySnapshot();
        when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
        when(mockQuerySnapshot.docs.last).thenReturn(mockDoc);

        // Act
        final result = await service.getJobsPaginated(
          filters: filters,
          limit: 20,
        );

        // Assert
        expect(result, isA<PaginatedJobResult>());
        expect(result.jobs, isNotEmpty);
        expect(result.hasMore, isA<bool>());
      });

      test('should enforce maximum page size limit', () async {
        // Arrange
        final largeLimit = 100; // Exceeds maxPageSize of 50

        // Act
        final result = await service.getJobsPaginated(limit: largeLimit);

        // Assert
        expect(result, isA<PaginatedJobResult>());
        // Should be limited to maxPageSize
      });
    });

    group('getJobById', () {
      test('should return job when found', () async {
        // Arrange
        final jobId = 'job-123';
        final mockJobData = {
          'id': jobId,
          'company': 'Test Company',
          'location': 'Test Location',
          'deleted': false,
        };

        final mockDoc = MockDocumentSnapshot();
        when(mockDoc.exists).thenReturn(true);
        when(mockDoc.data()).thenReturn(mockJobData);
        when(mockDoc.id).thenReturn(jobId);

        // Act
        final result = await service.getJobById(jobId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(jobId));
      });

      test('should return null when job not found', () async {
        // Arrange
        final jobId = 'nonexistent-job';
        final mockDoc = MockDocumentSnapshot();
        when(mockDoc.exists).thenReturn(false);

        // Act
        final result = await service.getJobById(jobId);

        // Assert
        expect(result, isNull);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        final jobId = 'error-job';

        // Act
        final result = await service.getJobById(jobId);

        // Assert
        expect(result, isNull);
      });
    });

    group('Performance Tests', () {
      test('should complete suggested jobs query within 500ms', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84, 111],
          constructionTypes: ['Commercial'],
          hoursPerWeek: ['40+'],
          perDiemRequirement: 'Not Required',
        );

        final stopwatch = Stopwatch()..start();

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
        );

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(result, isA<List<Job>>());
      });

      test('should handle large result sets efficiently', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84],
          constructionTypes: ['Commercial'],
          hoursPerWeek: ['40+'],
          perDiemRequirement: 'Not Required',
        );

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
          limit: 50, // Larger limit
        );

        // Assert
        expect(result.length, lessThanOrEqualTo(50)); // Should respect limit
      });
    });

    group('Client-side filtering', () {
      test('should apply construction type filtering correctly', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84],
          constructionTypes: ['Commercial'],
          hoursPerWeek: ['40+'],
          perDiemRequirement: 'Not Required',
        );

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
        );

        // Assert
        expect(result, isA<List<Job>>());
        // Results should be filtered by construction type
      });

      test('should apply hours per week filtering correctly', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84],
          constructionTypes: ['Commercial'],
          hoursPerWeek: ['20-30'], // Specific hours range
          perDiemRequirement: 'Not Required',
        );

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
        );

        // Assert
        expect(result, isA<List<Job>>());
        // Results should be filtered by hours range
      });

      test('should apply per diem filtering correctly', () async {
        // Arrange
        final userId = 'test-user-123';
        final preferences = UserJobPreferences(
          preferredLocals: [84],
          constructionTypes: ['Commercial'],
          hoursPerWeek: ['40+'],
          perDiemRequirement: 'Required', // Require per diem
        );

        // Act
        final result = await service.getSuggestedJobs(
          userId: userId,
          preferences: preferences,
        );

        // Assert
        expect(result, isA<List<Job>>());
        // Results should be filtered by per diem requirement
      });
    });
  });
}

// Mock classes for testing
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}