import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/providers/riverpod/jobs_riverpod_provider.dart';
import '../../lib/providers/riverpod/error_handling_provider.dart';
import '../../lib/models/job_model.dart';
import '../../lib/models/filter_criteria.dart';
import '../../lib/utils/error_handler.dart';
import '../fixtures/mock_data.dart';
import '../test_config.dart';

import 'jobs_riverpod_provider_test.mocks.dart';

/// Generate mocks
@GenerateMocks([ErrorHandler])
void main() {
  group('JobsRiverpodProvider Tests', () {
    late ProviderContainer container;
    late MockErrorHandler mockErrorHandler;
    late List<Job> testJobs;

    setUp(() {
      mockErrorHandler = MockErrorHandler();
      testJobs = MockData.createTestJobList(count: 5);

      container = ProviderContainer(
        overrides: [
          errorHandlerProvider.overrideWithValue(mockErrorHandler),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('JobsNotifier', () {
      test('should initialize with empty state', () {
        // Arrange & Act
        final jobsState = container.read(jobsProvider);

        // Assert
        expect(jobsState.isLoading, isFalse);
        expect(jobsState.jobs, isEmpty);
        expect(jobsState.error, isNull);
        expect(jobsState.hasMore, isTrue);
      });

      test('should load jobs successfully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
          context: anyNamed('context'),
        )).thenAnswer((_) async => testJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.jobs, hasLength(5));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);

        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadJobs',
          errorMessage: 'Failed to load jobs',
          showToast: false,
          context: argThat(
            contains('isRefresh'),
            named: 'context',
          ),
        )).called(1);
      });

      test('should load jobs with filter', () async {
        // Arrange
        final filter = JobFilterCriteria(
          localNumbers: [3],
          classifications: ['Inside Wireman'],
          maxDistance: 50.0,
        );

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs(filter: filter);

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadJobs',
          errorMessage: 'Failed to load jobs',
          context: argThat(
            allOf([
              contains('filter'),
              contains('localNumbers'),
            ]),
            named: 'context',
          ),
        )).called(1);
      });

      test('should refresh jobs', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.refreshJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.jobs, hasLength(5));

        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadJobs',
          errorMessage: 'Failed to load jobs',
          context: argThat(
            containsPair('isRefresh', true),
            named: 'context',
          ),
        )).called(1);
      });

      test('should load more jobs (pagination)', () async {
        // Arrange
        final moreJobs = MockData.createTestJobList(count: 5, startIndex: 5);
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => moreJobs);

        // First load initial jobs
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        // Reset mock for next call
        reset(mockErrorHandler);
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => moreJobs);

        // Act - Load more
        await notifier.loadMoreJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.jobs, hasLength(10)); // 5 initial + 5 more
      });

      test('should apply filter', () async {
        // Arrange
        final filter = JobFilterCriteria(
          searchQuery: 'electrician',
          localNumbers: [3],
        );

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.applyFilter(filter);

        // Assert
        final state = container.read(jobsProvider);
        expect(state.currentFilter.searchQuery, equals('electrician'));
        expect(state.currentFilter.localNumbers, contains(3));

        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadJobs',
          errorMessage: 'Failed to load jobs',
        )).called(1);
      });

      test('should clear filter', () async {
        // Arrange
        final filter = JobFilterCriteria(searchQuery: 'test');

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        final notifier = container.read(jobsProvider.notifier);

        // First apply filter
        await notifier.applyFilter(filter);

        // Reset mock for next call
        reset(mockErrorHandler);
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        // Act - Clear filter
        await notifier.clearFilter();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.currentFilter.searchQuery, isNull);
      });

      test('should bookmark job', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async {});

        final testJob = testJobs.first;
        final notifier = container.read(jobsProvider.notifier);

        // Act
        await notifier.bookmarkJob(testJob);

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: 'bookmarkJob',
          errorMessage: 'Failed to bookmark job',
          showToast: true,
          context: argThat(
            containsPair('jobId', testJob.id),
            named: 'context',
          ),
        )).called(1);
      });

      test('should remove bookmark', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async {});

        final testJob = testJobs.first;
        final notifier = container.read(jobsProvider.notifier);

        // Act
        await notifier.removeBookmark(testJob);

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<void>(
          operation: anyNamed('operation'),
          operationName: 'removeBookmark',
          errorMessage: 'Failed to remove bookmark',
          showToast: true,
          context: argThat(
            containsPair('jobId', testJob.id),
            named: 'context',
          ),
        )).called(1);
      });

      test('should load suggested jobs', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async => testJobs.take(3).toList());

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadSuggestedJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.suggestedJobs, hasLength(3));

        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadSuggestedJobs',
          errorMessage: 'Failed to load suggested jobs',
          showToast: false,
        )).called(1);
      });

      test('should load bookmarked jobs', () async {
        // Arrange
        final bookmarkedJobs = testJobs.take(2).toList();
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          showToast: anyNamed('showToast'),
        )).thenAnswer((_) async => bookmarkedJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadBookmarkedJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.bookmarkedJobs, hasLength(2));

        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadBookmarkedJobs',
          errorMessage: 'Failed to load bookmarked jobs',
          showToast: false,
        )).called(1);
      });

      test('should clear error', () {
        // Arrange
        final notifier = container.read(jobsProvider.notifier);

        // Act
        notifier.clearError();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.error, isNull);
      });

      test('should retry loading jobs', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
          context: anyNamed('context'),
        )).thenAnswer((_) async => testJobs);

        final notifier = container.read(jobsProvider.notifier);

        // Act
        await notifier.retryLoadJobs();

        // Assert
        verify(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: 'loadJobs',
          errorMessage: 'Failed to load jobs',
          context: argThat(
            containsPair('retryCount', 1),
            named: 'context',
          ),
        )).called(1);
      });
    });

    group('Computed Providers', () {
      test('jobsProvider should return jobs list', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobsProvider.overrideWith((ref) => JobsState(
              jobs: testJobs,
              isLoading: false,
              error: null,
              hasMore: true,
            )),
          ],
        );

        // Act
        final jobs = container.read(jobsProvider);

        // Assert
        expect(jobs.jobs, hasLength(5));
        expect(jobs.isLoading, isFalse);
      });

      test('isLoadingJobsProvider should return loading state', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobsProvider.overrideWith((ref) => const JobsState(
              jobs: [],
              isLoading: true,
              error: null,
              hasMore: true,
            )),
          ],
        );

        // Act
        final isLoading = container.read(isLoadingJobsProvider);

        // Assert
        expect(isLoading, isTrue);
      });

      test('jobsErrorProvider should return error state', () {
        // Arrange
        const testError = 'Failed to load jobs';
        container = ProviderContainer(
          overrides: [
            jobsProvider.overrideWith((ref) => const JobsState(
              jobs: [],
              isLoading: false,
              error: testError,
              hasMore: false,
            )),
          ],
        );

        // Act
        final error = container.read(jobsErrorProvider);

        // Assert
        expect(error, equals(testError));
      });

      test('hasMoreJobsProvider should return hasMore state', () {
        // Arrange
        container = ProviderContainer(
          overrides: [
            jobsProvider.overrideWith((ref) => const JobsState(
              jobs: [],
              isLoading: false,
              error: null,
              hasMore: false,
            )),
          ],
        );

        // Act
        final hasMore = container.read(hasMoreJobsProvider);

        // Assert
        expect(hasMore, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle network errors', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(ErrorTestUtils.createNetworkError());

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('Network'));
      });

      test('should handle timeout errors', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenThrow(ErrorTestUtils.createTimeoutError());

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('timeout'));
      });

      test('should handle empty results gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => []);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.jobs, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('Filter Behavior', () {
      test('should maintain filter state across operations', () async {
        // Arrange
        final filter = JobFilterCriteria(
          searchQuery: 'test',
          localNumbers: [3, 124],
        );

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        final notifier = container.read(jobsProvider.notifier);

        // Act
        await notifier.applyFilter(filter);

        // Reset mock for refresh
        reset(mockErrorHandler);
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        await notifier.refreshJobs();

        // Assert
        final state = container.read(jobsProvider);
        expect(state.currentFilter.searchQuery, equals('test'));
        expect(state.currentFilter.localNumbers, contains(3));
      });

      test('should preserve sort order when applying filters', () async {
        // Arrange
        final filter = JobFilterCriteria(
          sortBy: JobSortOption.wage,
          sortDescending: true,
        );

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.applyFilter(filter);

        // Assert
        final state = container.read(jobsProvider);
        expect(state.currentFilter.sortBy, equals(JobSortOption.wage));
        expect(state.currentFilter.sortDescending, isTrue);
      });
    });

    group('Performance', () {
      test('should handle large job lists efficiently', () async {
        // Arrange
        final largeJobList = MockData.createTestJobList(count: 100);

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => largeJobList);

        final stopwatch = Stopwatch()..start();

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should load in under 1 second
        final state = container.read(jobsProvider);
        expect(state.jobs, hasLength(100));
      });
    });

    group('Edge Cases', () {
      test('should handle null filter gracefully', () async {
        // Arrange
        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => testJobs);

        final notifier = container.read(jobsProvider.notifier);

        // Act - Should not throw
        await notifier.applyFilter(null);

        // Assert
        final state = container.read(jobsProvider);
        expect(state.currentFilter, isA<JobFilterCriteria>());
      });

      test('should handle duplicate jobs in results', () async {
        // Arrange
        final duplicateJobs = [...testJobs, testJobs.first];

        when(mockErrorHandler.handleAsyncOperation<List<Job>>(
          operation: anyNamed('operation'),
          operationName: anyNamed('operationName'),
          errorMessage: anyNamed('errorMessage'),
        )).thenAnswer((_) async => duplicateJobs);

        // Act
        final notifier = container.read(jobsProvider.notifier);
        await notifier.loadJobs();

        // Assert
        final state = container.read(jobsProvider);
        // Implementation should handle duplicates (depends on actual implementation)
        expect(state.jobs, isNotEmpty);
      });
    });
  });
}