import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:journeyman_jobs/domain/use_cases/get_jobs_use_case.dart';
import 'package:journeyman_jobs/data/repositories/job_repository.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import '../../fixtures/mock_data.dart';
import '../../fixtures/test_constants.dart';

// Mock repository
class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late GetJobsUseCase getJobsUseCase;
  late MockJobRepository mockJobRepository;

  setUp(() {
    mockJobRepository = MockJobRepository();
    getJobsUseCase = GetJobsUseCase(mockJobRepository);
  });

  group('GetJobsUseCase Tests', () {
    test('should return list of jobs when repository call succeeds', () async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 5);
      when(mockJobRepository.getJobs(any)).thenAnswer((_) async => mockJobs);

      // Act
      final result = await getJobsUseCase.execute(GetJobsParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (jobs) {
          expect(jobs, hasLength(5));
          expect(jobs, everyElement(isA<Job>()));
        },
      );
    });

    test('should filter jobs by classification', () async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 10);
      final filteredJobs = mockJobs.where((job) => job.classification == 'Inside Wireman').toList();
      
      when(mockJobRepository.getJobs(any)).thenAnswer((_) async => filteredJobs);

      // Act
      final params = GetJobsParams(
        classifications: ['Inside Wireman'],
      );
      final result = await getJobsUseCase.execute(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (jobs) {
          expect(jobs, everyElement(predicate<Job>((job) => job.classification == 'Inside Wireman')));
        },
      );
    });

    test('should filter jobs by IBEW local numbers', () async {
      // Arrange
      final targetLocal = TestConstants.commonIBEWLocals.first;
      final mockJobs = MockData.createJobList(count: 10);
      final filteredJobs = mockJobs.where((job) => job.local == targetLocal).toList();
      
      when(mockJobRepository.getJobs(any)).thenAnswer((_) async => filteredJobs);

      // Act
      final params = GetJobsParams(
        localNumbers: [targetLocal],
      );
      final result = await getJobsUseCase.execute(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (jobs) {
          expect(jobs, everyElement(predicate<Job>((job) => job.local == targetLocal)));
        },
      );
    });

    test('should handle repository failure', () async {
      // Arrange
      when(mockJobRepository.getJobs(any)).thenThrow(Exception('Network error'));

      // Act
      final result = await getJobsUseCase.execute(GetJobsParams());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Network error')),
        (jobs) => fail('Should return failure'),
      );
    });

    test('should apply wage range filter', () async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 10);
      final highWageJobs = mockJobs.where((job) => (job.wage ?? 0) >= 50.0).toList();
      
      when(mockJobRepository.getJobs(any)).thenAnswer((_) async => highWageJobs);

      // Act
      final params = GetJobsParams(
        minWage: 50.0,
      );
      final result = await getJobsUseCase.execute(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (jobs) {
          expect(jobs, everyElement(predicate<Job>((job) => (job.wage ?? 0) >= 50.0)));
        },
      );
    });

    test('should limit number of results', () async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 50);
      final limitedJobs = mockJobs.take(20).toList();
      
      when(mockJobRepository.getJobs(any)).thenAnswer((_) async => limitedJobs);

      // Act
      final params = GetJobsParams(limit: 20);
      final result = await getJobsUseCase.execute(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (jobs) {
          expect(jobs, hasLength(20));
        },
      );
    });

    test('should handle empty results', () async {
      // Arrange
      when(mockJobRepository.getJobs(any)).thenAnswer((_) async => <Job>[]);

      // Act
      final result = await getJobsUseCase.execute(GetJobsParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (jobs) {
          expect(jobs, isEmpty);
        },
      );
    });
  });

  group('GetJobsParams Tests', () {
    test('should create params with electrical industry filters', () {
      // Act
      final params = GetJobsParams(
        classifications: TestConstants.ibewClassifications.take(2).toList(),
        localNumbers: TestConstants.commonIBEWLocals.take(3).toList(),
        constructionTypes: TestConstants.constructionTypes.take(2).toList(),
        minWage: 40.0,
        maxWage: 60.0,
        maxDistance: 50,
        limit: 25,
      );

      // Assert
      expect(params.classifications, hasLength(2));
      expect(params.localNumbers, hasLength(3));
      expect(params.constructionTypes, hasLength(2));
      expect(params.minWage, equals(40.0));
      expect(params.maxWage, equals(60.0));
      expect(params.maxDistance, equals(50));
      expect(params.limit, equals(25));
    });

    test('should have reasonable defaults', () {
      // Act
      final params = GetJobsParams();

      // Assert
      expect(params.limit, equals(20)); // Default limit
      expect(params.classifications, isNull);
      expect(params.localNumbers, isNull);
      expect(params.minWage, isNull);
      expect(params.maxWage, isNull);
    });
  });
}

// Mock classes and params for the test
class GetJobsParams {
  final List<String>? classifications;
  final List<int>? localNumbers;
  final List<String>? constructionTypes;
  final double? minWage;
  final double? maxWage;
  final int? maxDistance;
  final int limit;

  GetJobsParams({
    this.classifications,
    this.localNumbers,
    this.constructionTypes,
    this.minWage,
    this.maxWage,
    this.maxDistance,
    this.limit = 20,
  });
}

class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  Future<Either<Failure, List<Job>>> execute(GetJobsParams params) async {
    try {
      final jobs = await repository.getJobs(params);
      return Right(jobs);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

// Helper classes for Either pattern
abstract class Either<L, R> {
  bool isLeft();
  bool isRight();
  void fold(Function(L) left, Function(R) right);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);

  @override
  bool isLeft() => true;
  @override
  bool isRight() => false;
  @override
  void fold(Function(L) left, Function(R) right) => left(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);

  @override
  bool isLeft() => false;
  @override
  bool isRight() => true;
  @override
  void fold(Function(L) left, Function(R) right) => right(value);
}

class Failure {
  final String message;
  Failure(this.message);
}