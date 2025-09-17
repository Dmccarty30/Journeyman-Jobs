import '../../models/job_model.dart';

/// JobRepository interface for data access related to jobs.
abstract class JobRepository {
  Future<List<JobModel>> fetchJobs();
  Future<JobModel?> getJobById(String id);
  Future<void> addJob(JobModel job);
  Future<void> updateJob(JobModel job);
  Future<void> deleteJob(String id);
}