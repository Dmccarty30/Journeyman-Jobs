import 'package:meta/meta.dart';
import 'union_model.dart';
import '../locals_record.dart';
import '../job_model.dart';

/// Represents the complete hierarchical data structure for IBEW
///
/// This model encapsulates the full hierarchy:
/// Union → Local → Members → Jobs
///
/// Used for efficient data loading and state management of the
/// complete hierarchical structure.
@immutable
class HierarchicalData {
  /// Union information (highest level)
  final Union? union;

  /// Map of local unions by their local number
  final Map<int, LocalsRecord> locals;

  /// Map of members by their user ID
  final Map<String, UnionMember> members;

  /// Map of jobs by their job ID
  final Map<String, Job> jobs;

  /// Loading status for each hierarchical level
  final HierarchicalLoadingStatus loadingStatus;

  /// Error information if loading failed
  final String? error;

  /// Last updated timestamp
  final DateTime lastUpdated;

  const HierarchicalData({
    this.union,
    this.locals = const {},
    this.members = const {},
    this.jobs = const {},
    this.loadingStatus = HierarchicalLoadingStatus.none,
    this.error,
    required this.lastUpdated,
  });

  /// Creates empty hierarchical data
  factory HierarchicalData.empty() {
    return HierarchicalData(
      lastUpdated: DateTime.now(),
    );
  }

  /// Creates hierarchical data with loading status
  factory HierarchicalData.loading({
    required HierarchicalLoadingStatus status,
  }) {
    return HierarchicalData(
      loadingStatus: status,
      lastUpdated: DateTime.now(),
    );
  }

  /// Creates hierarchical data with error
  factory HierarchicalData.error({
    required String error,
    HierarchicalLoadingStatus status = HierarchicalLoadingStatus.none,
  }) {
    return HierarchicalData(
      error: error,
      loadingStatus: status,
      lastUpdated: DateTime.now(),
    );
  }

  /// Checks if a specific local is loaded
  bool hasLocal(int localNumber) {
    return locals.containsKey(localNumber);
  }

  /// Checks if a specific member is loaded
  bool hasMember(String userId) {
    return members.containsKey(userId);
  }

  /// Checks if a specific job is loaded
  bool hasJob(String jobId) {
    return jobs.containsKey(jobId);
  }

  /// Gets locals for a specific union
  List<LocalsRecord> getLocalsForUnion(String unionId) {
    if (union?.id != unionId) return [];
    return locals.values.toList();
  }

  /// Gets members for a specific local
  List<UnionMember> getMembersForLocal(int localNumber) {
    return members.values
        .where((member) => member.localNumber == localNumber)
        .toList();
  }

  /// Gets jobs for a specific local
  List<Job> getJobsForLocal(int localNumber) {
    return jobs.values
        .where((job) => job.local == localNumber || job.localNumber == localNumber)
        .toList();
  }

  /// Gets available jobs (not deleted and matches criteria)
  List<Job> getAvailableJobs() {
    return jobs.values
        .where((job) => !job.deleted && job.matchesCriteria)
        .toList();
  }

  /// Gets available members (not currently working)
  List<UnionMember> getAvailableMembers() {
    return members.values
        .where((member) => member.isAvailable)
        .toList();
  }

  /// Gets locals by geographic location
  List<LocalsRecord> getLocalsByLocation(String location) {
    return locals.values
        .where((local) =>
            local.location.toLowerCase().contains(location.toLowerCase()) ||
            local.city.toLowerCase().contains(location.toLowerCase()) ||
            local.state.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }

  /// Gets members by classification
  List<UnionMember> getMembersByClassification(String classification) {
    return members.values
        .where((member) =>
            member.classification.toLowerCase().contains(classification.toLowerCase()))
        .toList();
  }

  /// Gets jobs by classification
  List<Job> getJobsByClassification(String classification) {
    return jobs.values
        .where((job) =>
            job.classification?.toLowerCase().contains(classification.toLowerCase()) == true)
        .toList();
  }

  /// Creates a copy with updated data
  HierarchicalData copyWith({
    Union? union,
    Map<int, LocalsRecord>? locals,
    Map<String, UnionMember>? members,
    Map<String, Job>? jobs,
    HierarchicalLoadingStatus? loadingStatus,
    String? error,
    DateTime? lastUpdated,
  }) {
    return HierarchicalData(
      union: union ?? this.union,
      locals: locals ?? this.locals,
      members: members ?? this.members,
      jobs: jobs ?? this.jobs,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Creates a copy with union data
  HierarchicalData withUnion(Union union) {
    return copyWith(union: union);
  }

  /// Creates a copy with added/updated local
  HierarchicalData withLocal(LocalsRecord local) {
    final newLocals = Map<int, LocalsRecord>.from(locals);
    newLocals[int.parse(local.localNumber)] = local;
    return copyWith(locals: newLocals);
  }

  /// Creates a copy with added/updated member
  HierarchicalData withMember(UnionMember member) {
    final newMembers = Map<String, UnionMember>.from(members);
    newMembers[member.userId] = member;
    return copyWith(members: newMembers);
  }

  /// Creates a copy with added/updated job
  HierarchicalData withJob(Job job) {
    final newJobs = Map<String, Job>.from(jobs);
    newJobs[job.id] = job;
    return copyWith(jobs: newJobs);
  }

  /// Creates a copy with removed local
  HierarchicalData withoutLocal(int localNumber) {
    final newLocals = Map<int, LocalsRecord>.from(locals);
    newLocals.remove(localNumber);
    return copyWith(locals: newLocals);
  }

  /// Creates a copy with removed member
  HierarchicalData withoutMember(String userId) {
    final newMembers = Map<String, UnionMember>.from(members);
    newMembers.remove(userId);
    return copyWith(members: newMembers);
  }

  /// Creates a copy with removed job
  HierarchicalData withoutJob(String jobId) {
    final newJobs = Map<String, Job>.from(jobs);
    newJobs.remove(jobId);
    return copyWith(jobs: newJobs);
  }

  /// Creates a copy with updated loading status
  HierarchicalData withLoadingStatus(HierarchicalLoadingStatus status) {
    return copyWith(loadingStatus: status, error: null);
  }

  /// Creates a copy with error
  HierarchicalData withError(String error, {HierarchicalLoadingStatus? status}) {
    return copyWith(
      error: error,
      loadingStatus: status ?? loadingStatus,
    );
  }

  /// Gets statistics about the hierarchical data
  HierarchicalStats get stats {
    return HierarchicalStats(
      totalLocals: locals.length,
      totalMembers: members.length,
      totalJobs: jobs.length,
      availableJobs: getAvailableJobs().length,
      availableMembers: getAvailableMembers().length,
      lastUpdated: lastUpdated,
    );
  }

  /// Validates if the hierarchical data is consistent
  bool isValid() {
    // Check if union exists and is valid
    if (union != null && !union!.isValid()) {
      return false;
    }

    // Check if all locals have valid data
    for (final local in locals.values) {
      if (local.localNumber.isEmpty) return false;
    }

    // Check if all members have valid data
    for (final member in members.values) {
      if (!member.isValid()) return false;

      // Check if member's local exists in locals
      if (!locals.containsKey(member.localNumber)) {
        return false;
      }
    }

    // Check if all jobs have valid data
    for (final job in jobs.values) {
      if (!job.isValid()) return false;

      // Check if job's local exists in locals
      if (job.local != null && !locals.containsKey(job.local!) &&
          job.localNumber != null && !locals.containsKey(job.localNumber!)) {
        return false;
      }
    }

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HierarchicalData &&
        other.union == union &&
        other.locals == locals &&
        other.members == members &&
        other.jobs == jobs &&
        other.loadingStatus == loadingStatus &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      union,
      locals,
      members,
      jobs,
      loadingStatus,
      error,
    );
  }

  @override
  String toString() {
    return 'HierarchicalData('
        'union: ${union?.name}, '
        'locals: ${locals.length}, '
        'members: ${members.length}, '
        'jobs: ${jobs.length}, '
        'loadingStatus: $loadingStatus, '
        'error: $error'
        ')';
  }
}

/// Represents the loading status of hierarchical data
enum HierarchicalLoadingStatus {
  /// No data loaded yet
  none,

  /// Loading union data
  loadingUnion,

  /// Loading locals for union
  loadingLocals,

  /// Loading members for locals
  loadingMembers,

  /// Loading jobs for locals
  loadingJobs,

  /// All data loaded successfully
  loaded,

  /// Loading failed with error
  error,

  /// Refreshing data
  refreshing,
}

/// Statistics about hierarchical data
@immutable
class HierarchicalStats {
  final int totalLocals;
  final int totalMembers;
  final int totalJobs;
  final int availableJobs;
  final int availableMembers;
  final DateTime lastUpdated;

  const HierarchicalStats({
    required this.totalLocals,
    required this.totalMembers,
    required this.totalJobs,
    required this.availableJobs,
    required this.availableMembers,
    required this.lastUpdated,
  });

  @override
  String toString() {
    return 'HierarchicalStats('
        'locals: $totalLocals, '
        'members: $totalMembers, '
        'jobs: $totalJobs, '
        'availableJobs: $availableJobs, '
        'availableMembers: $availableMembers, '
        'lastUpdated: $lastUpdated'
        ')';
  }
}