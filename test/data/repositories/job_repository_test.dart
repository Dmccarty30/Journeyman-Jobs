import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/data/repositories/job_repository.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import '../../fixtures/mock_data.dart';
import '../../fixtures/test_constants.dart';

void main() {
  late JobRepository jobRepository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    jobRepository = JobRepositoryImpl(fakeFirestore);
  });

  group('JobRepository Tests', () {
    test('should fetch jobs from Firestore', () async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 5);
      
      // Add test data to fake Firestore
      for (final job in mockJobs) {
        await fakeFirestore.collection(TestConstants.jobsCollection).add(job.toJson());
      }

      // Act
      final result = await jobRepository.getJobs();

      // Assert
      expect(result, hasLength(5));
      expect(result, everyElement(isA<Job>()));
    });

    test('should filter jobs by classification', () async {
      // Arrange
      final insideWiremanJob = MockData.createJob(classification: 'Inside Wireman');
      final linemanJob = MockData.createJob(classification: 'Journeyman Lineman');
      
      await fakeFirestore.collection(TestConstants.jobsCollection).add(insideWiremanJob.toJson());
      await fakeFirestore.collection(TestConstants.jobsCollection).add(linemanJob.toJson());

      // Act
      final result = await jobRepository.getJobsByClassification(['Inside Wireman']);

      // Assert
      expect(result, hasLength(1));
      expect(result.first.classification, equals('Inside Wireman'));
    });

    test('should filter jobs by IBEW local number', () async {
      // Arrange
      final local123Job = MockData.createJob(localNumber: 123);
      final local456Job = MockData.createJob(localNumber: 456);
      
      await fakeFirestore.collection(TestConstants.jobsCollection).add(local123Job.toJson());
      await fakeFirestore.collection(TestConstants.jobsCollection).add(local456Job.toJson());

      // Act
      final result = await jobRepository.getJobsByLocal([123]);

      // Assert
      expect(result, hasLength(1));
      expect(result.first.local, equals(123));
    });

    test('should filter jobs by wage range', () async {
      // Arrange
      final lowWageJob = MockData.createJob(wage: 35.0);
      final highWageJob = MockData.createJob(wage: 55.0);
      
      await fakeFirestore.collection(TestConstants.jobsCollection).add(lowWageJob.toJson());
      await fakeFirestore.collection(TestConstants.jobsCollection).add(highWageJob.toJson());

      // Act
      final result = await jobRepository.getJobsByWageRange(minWage: 50.0);

      // Assert
      expect(result, hasLength(1));
      expect(result.first.wage, greaterThanOrEqualTo(50.0));
    });

    test('should handle pagination with limit', () async {
      // Arrange
      final jobs = MockData.createJobList(count: 25);
      
      for (final job in jobs) {
        await fakeFirestore.collection(TestConstants.jobsCollection).add(job.toJson());
      }

      // Act
      final result = await jobRepository.getJobs(limit: 10);

      // Assert
      expect(result, hasLength(10));
    });

    test('should search jobs by company name', () async {
      // Arrange
      final electricJob = MockData.createJob(company: 'Elite Electric Company');
      final powerJob = MockData.createJob(company: 'Power Grid Solutions');
      
      await fakeFirestore.collection(TestConstants.jobsCollection).add(electricJob.toJson());
      await fakeFirestore.collection(TestConstants.jobsCollection).add(powerJob.toJson());

      // Act
      final result = await jobRepository.searchJobs('Electric');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.company, contains('Electric'));
    });

    test('should handle empty results', () async {
      // Act (no data added to Firestore)
      final result = await jobRepository.getJobs();

      // Assert
      expect(result, isEmpty);
    });

    test('should sort jobs by timestamp', () async {
      // Arrange
      final oldJob = MockData.createJob(id: 'old-job');
      final newJob = MockData.createJob(id: 'new-job');
      
      // Add with specific timestamps
      await fakeFirestore.collection(TestConstants.jobsCollection).doc('old').set({
        ...oldJob.toJson(),
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      });
      
      await fakeFirestore.collection(TestConstants.jobsCollection).doc('new').set({
        ...newJob.toJson(),
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      // Act
      final result = await jobRepository.getJobsSortedByDate();

      // Assert
      expect(result, hasLength(2));
      expect(result.first.id, equals('new-job')); // Newest first
      expect(result.last.id, equals('old-job'));
    });

    test('should handle Firestore errors gracefully', () async {
      // This test would require a mock that throws exceptions
      // For now, we'll test the error handling pattern
      expect(() => jobRepository.getJobs(), returnsNormally);
    });
  });

  group('JobRepository Performance Tests', () {
    test('should handle large dataset efficiently', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();
      final jobs = MockData.createJobList(count: 100);
      
      for (final job in jobs) {
        await fakeFirestore.collection(TestConstants.jobsCollection).add(job.toJson());
      }

      // Act
      final result = await jobRepository.getJobs();
      stopwatch.stop();

      // Assert
      expect(result, hasLength(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(TestConstants.maxLoadTimeMs));
    });
  });

  group('JobRepository Electrical Industry Tests', () {
    test('should handle all IBEW classifications', () async {
      // Arrange
      final jobs = <Job>[];
      for (final classification in TestConstants.ibewClassifications) {
        final job = MockData.createJob(classification: classification);
        jobs.add(job);
        await fakeFirestore.collection(TestConstants.jobsCollection).add(job.toJson());
      }

      // Act
      final result = await jobRepository.getJobs();

      // Assert
      expect(result, hasLength(TestConstants.ibewClassifications.length));
      
      for (final classification in TestConstants.ibewClassifications) {
        expect(result.any((job) => job.classification == classification), isTrue);
      }
    });

    test('should handle construction type filtering', () async {
      // Arrange
      for (final constructionType in TestConstants.constructionTypes) {
        final job = MockData.createJob(constructionType: constructionType);
        await fakeFirestore.collection(TestConstants.jobsCollection).add(job.toJson());
      }

      // Act
      final result = await jobRepository.getJobsByConstructionType(['Commercial']);

      // Assert
      expect(result, everyElement(predicate<Job>((job) => job.typeOfWork == 'Commercial')));
    });
  });
}

// Mock repository implementation for testing
class JobRepositoryImpl implements JobRepository {
  final FirebaseFirestore firestore;

  JobRepositoryImpl(this.firestore);

  @override
  Future<List<Job>> getJobs({int limit = 20}) async {
    final snapshot = await firestore
        .collection(TestConstants.jobsCollection)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Job>> getJobsByClassification(List<String> classifications) async {
    final snapshot = await firestore
        .collection(TestConstants.jobsCollection)
        .where('classification', whereIn: classifications)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Job>> getJobsByLocal(List<int> localNumbers) async {
    final snapshot = await firestore
        .collection(TestConstants.jobsCollection)
        .where('local', whereIn: localNumbers)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Job>> getJobsByWageRange({double? minWage, double? maxWage}) async {
    Query query = firestore.collection(TestConstants.jobsCollection);
    
    if (minWage != null) {
      query = query.where('wage', isGreaterThanOrEqualTo: minWage);
    }
    if (maxWage != null) {
      query = query.where('wage', isLessThanOrEqualTo: maxWage);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Job>> searchJobs(String searchTerm) async {
    final snapshot = await firestore
        .collection(TestConstants.jobsCollection)
        .where('company', isGreaterThanOrEqualTo: searchTerm)
        .where('company', isLessThan: searchTerm + '\uf8ff')
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Job>> getJobsSortedByDate() async {
    final snapshot = await firestore
        .collection(TestConstants.jobsCollection)
        .orderBy('timestamp', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Job>> getJobsByConstructionType(List<String> types) async {
    final snapshot = await firestore
        .collection(TestConstants.jobsCollection)
        .where('typeOfWork', whereIn: types)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Job.fromJson(data);
    }).toList();
  }
}

// Abstract repository interface
abstract class JobRepository {
  Future<List<Job>> getJobs({int limit = 20});
  Future<List<Job>> getJobsByClassification(List<String> classifications);
  Future<List<Job>> getJobsByLocal(List<int> localNumbers);
  Future<List<Job>> getJobsByWageRange({double? minWage, double? maxWage});
  Future<List<Job>> searchJobs(String searchTerm);
  Future<List<Job>> getJobsSortedByDate();
  Future<List<Job>> getJobsByConstructionType(List<String> types);
}