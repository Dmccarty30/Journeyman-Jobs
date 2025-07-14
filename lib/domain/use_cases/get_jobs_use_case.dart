/// Use case for fetching jobs from the repository.
import '../../data/repositories/job_repository.dart';

class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  Future<List<Job>> call() async {
    return await repository.fetchJobs();
  }
}