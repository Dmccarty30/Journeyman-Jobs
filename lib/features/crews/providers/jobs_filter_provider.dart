// lib/features/crews/providers/jobs_filter_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../models/job_model.dart';
import 'crew_jobs_riverpod_provider.dart';

part 'jobs_filter_provider.g.dart';

/// State class for jobs filters
class JobsFilterState {
  final String? constructionType;
  final int? localNumber;
  final String? classification;
  final String searchQuery;

  const JobsFilterState({
    this.constructionType,
    this.localNumber,
    this.classification,
    this.searchQuery = '',
  });

  JobsFilterState copyWith({
    String? constructionType,
    int? localNumber,
    String? classification,
    String? searchQuery,
    bool clearConstructionType = false,
    bool clearLocalNumber = false,
    bool clearClassification = false,
  }) {
    return JobsFilterState(
      constructionType: clearConstructionType ? null : (constructionType ?? this.constructionType),
      localNumber: clearLocalNumber ? null : (localNumber ?? this.localNumber),
      classification: clearClassification ? null : (classification ?? this.classification),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      constructionType != null ||
      localNumber != null ||
      classification != null ||
      searchQuery.isNotEmpty;

  /// Get filter summary text for display
  String getFilterSummary() {
    final filters = <String>[];
    if (constructionType != null) filters.add(constructionType!);
    if (localNumber != null) filters.add('Local $localNumber');
    if (classification != null) filters.add(classification!);
    if (searchQuery.isNotEmpty) filters.add('Search: "$searchQuery"');

    if (filters.isEmpty) return 'No active filters';
    return filters.join(' • ');
  }
}

/// State notifier for managing jobs filters
class JobsFilterNotifier extends StateNotifier<JobsFilterState> {
  JobsFilterNotifier() : super(const JobsFilterState());

  /// Set construction type filter
  void setConstructionType(String? type) {
    state = state.copyWith(
      constructionType: type,
      clearConstructionType: type == null,
    );
  }

  /// Set local number filter
  void setLocalNumber(int? local) {
    state = state.copyWith(
      localNumber: local,
      clearLocalNumber: local == null,
    );
  }

  /// Set classification filter
  void setClassification(String? classification) {
    state = state.copyWith(
      classification: classification,
      clearClassification: classification == null,
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear all filters
  void clearAllFilters() {
    state = const JobsFilterState();
  }

  /// Clear a specific filter type
  void clearFilter(String filterType) {
    switch (filterType) {
      case 'constructionType':
        state = state.copyWith(clearConstructionType: true);
        break;
      case 'local':
        state = state.copyWith(clearLocalNumber: true);
        break;
      case 'classification':
        state = state.copyWith(clearClassification: true);
        break;
      case 'search':
        state = state.copyWith(searchQuery: '');
        break;
    }
  }
}

/// Provider for jobs filter state
@riverpod
class JobsFilter extends _$JobsFilter {
  @override
  JobsFilterState build() => const JobsFilterState();

  /// Set construction type filter
  void setConstructionType(String? type) {
    state = state.copyWith(
      constructionType: type,
      clearConstructionType: type == null,
    );
  }

  /// Set local number filter
  void setLocalNumber(int? local) {
    state = state.copyWith(
      localNumber: local,
      clearLocalNumber: local == null,
    );
  }

  /// Set classification filter
  void setClassification(String? classification) {
    state = state.copyWith(
      classification: classification,
      clearClassification: classification == null,
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear all filters
  void clearAllFilters() {
    state = const JobsFilterState();
  }

  /// Clear a specific filter type
  void clearFilter(String filterType) {
    switch (filterType) {
      case 'constructionType':
        state = state.copyWith(clearConstructionType: true);
        break;
      case 'local':
        state = state.copyWith(clearLocalNumber: true);
        break;
      case 'classification':
        state = state.copyWith(clearClassification: true);
        break;
      case 'search':
        state = state.copyWith(searchQuery: '');
        break;
    }
  }
}

/// Provider for filtered jobs based on crew preferences AND user filters
@riverpod
List<Job> filteredCrewJobs(Ref ref, String crewId) {
  final crewJobs = ref.watch(crewFilteredJobsProvider(crewId));
  final filterState = ref.watch(jobsFilterProvider);

  // If no additional filters, return crew-filtered jobs
  if (!filterState.hasActiveFilters) {
    return crewJobs;
  }

  return crewJobs.where((job) {
    // Apply construction type filter
    if (filterState.constructionType != null) {
      final jobConstructionType = job.typeOfConstruction?.toLowerCase() ??
                                   job.typeOfWork?.toLowerCase() ?? '';
      if (!jobConstructionType.contains(filterState.constructionType!.toLowerCase())) {
        return false;
      }
    }

    // Apply local number filter
    if (filterState.localNumber != null) {
      if (job.local != filterState.localNumber) {
        return false;
      }
    }

    // Apply classification filter
    if (filterState.classification != null) {
      final jobClassification = job.classification?.toLowerCase() ?? '';
      if (!jobClassification.contains(filterState.classification!.toLowerCase())) {
        return false;
      }
    }

    // Apply search query filter
    if (filterState.searchQuery.isNotEmpty) {
      final query = filterState.searchQuery.toLowerCase();
      final company = job.company.toLowerCase();
      final location = job.location.toLowerCase();
      final jobTitle = job.jobTitle?.toLowerCase() ?? '';
      final typeOfWork = job.typeOfWork?.toLowerCase() ?? '';

      if (!company.contains(query) &&
          !location.contains(query) &&
          !jobTitle.contains(query) &&
          !typeOfWork.contains(query)) {
        return false;
      }
    }

    return true;
  }).toList();
}

/// Provider to check if any filters are active
@riverpod
bool hasActiveJobFilters(Ref ref) {
  final filterState = ref.watch(jobsFilterProvider);
  return filterState.hasActiveFilters;
}

/// Provider to get filter summary text
@riverpod
String jobFilterSummary(Ref ref) {
  final filterState = ref.watch(jobsFilterProvider);
  return filterState.getFilterSummary();
}
