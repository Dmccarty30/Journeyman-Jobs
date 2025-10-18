import '../../models/job_model.dart';

// Export the Job model for convenience when importing this repository
export '../../models/job_model.dart';

/// JobRepository interface for data access related to jobs.
///
/// This repository provides the contract for all job-related data operations,
/// including fetching, creating, updating, and deleting jobs from the data source.
///
/// Implementations of this interface should handle:
/// - Firestore database interactions
/// - Error handling and logging
/// - Data transformation between Firestore and model objects
/// - Caching strategies for offline support
abstract class JobRepository {
  /// Fetches a list of all jobs from the data source.
  ///
  /// Returns a list of [Job] objects sorted by most recent first.
  /// Throws an exception if the fetch operation fails.
  Future<List<Job>> fetchJobs();

  /// Retrieves a specific job by its unique identifier.
  ///
  /// Returns the [Job] if found, or null if no job exists with the given [id].
  /// Throws an exception if the retrieval operation fails.
  Future<Job?> getJobById(String id);

  /// Adds a new job to the data source.
  ///
  /// The [job] parameter should be a valid Job object.
  /// Throws an exception if the add operation fails or validation fails.
  Future<void> addJob(Job job);

  /// Updates an existing job in the data source.
  ///
  /// The [job] parameter should contain the updated data with a valid ID.
  /// Throws an exception if the update operation fails or the job doesn't exist.
  Future<void> updateJob(Job job);

  /// Permanently deletes a job from the data source.
  ///
  /// Removes the job with the specified [id] from the database.
  /// Throws an exception if the delete operation fails.
  Future<void> deleteJob(String id);
}
