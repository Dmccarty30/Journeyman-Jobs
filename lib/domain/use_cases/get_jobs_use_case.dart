/// Use case for fetching jobs from the repository.
library;
import '../../data/repositories/job_repository.dart';
import '../../models/job_model.dart';

class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  Future<List<Job>> call() async {
    return await repository.fetchJobs();
  }
}