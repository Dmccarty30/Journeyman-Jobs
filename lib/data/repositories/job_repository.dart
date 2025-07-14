/// JobRepository interface for data access related to jobs.
abstract class JobRepository {
  Future<List<Job>> fetchJobs();
  Future<Job?> getJobById(String id);
  Future<void> addJob(Job job);
  Future<void> updateJob(Job job);
  Future<void> deleteJob(String id);
}

/// Example Job model (replace with your actual model)
class Job {
  final String id;
  final String title;
  final String description;

  Job({required this.id, required this.title, required this.description});
}