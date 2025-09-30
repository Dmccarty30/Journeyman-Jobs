import '../../models/job_model.dart';

/// JobRepository interface for data access related to jobs.
abstract class JobRepository {
  Future<List<Job>> fetchJobs();
  Future<Job?> getJobById(String id);
  Future<void> addJob(Job job);
  Future<void> updateJob(Job job);
  Future<void> deleteJob(String id);
}
