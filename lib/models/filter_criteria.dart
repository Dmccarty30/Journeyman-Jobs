import 'package:cloud_firestore/cloud_firestore.dart';

/// An immutable model that represents a collection of filters for a job search.
///
/// This class holds all possible criteria a user can specify to narrow down
/// job search results, including location, job type, time, work preferences,
/// and sorting options.
class JobFilterCriteria {
  // Location filters
  /// The city to filter jobs by.
  final String? city;
  /// The state to filter jobs by.
  final String? state;
  /// The maximum distance in miles from a central point for a location-based search.
  final double? maxDistance;
  
  // Classification filters
  /// A list of IBEW classifications to include (e.g., 'Inside Wireman').
  final List<String> classifications;
  /// A list of IBEW local union numbers to filter by.
  final List<int> localNumbers;
  
  // Job type filters
  /// A list of construction types to include (e.g., 'Commercial', 'Industrial').
  final List<String> constructionTypes;
  /// A list of job classes to include.
  final List<String> jobClasses;

  // Time filters
  /// Only include jobs posted on or after this date.
  final DateTime? postedAfter;
  /// Only include jobs with a start date on or before this date.
  final DateTime? startDateBefore;
  /// Only include jobs with a start date on or after this date.
  final DateTime? startDateAfter;
  
  // Work preferences
  /// If not null, filters for jobs that either have per diem (`true`) or not (`false`).
  final bool? hasPerDiem;
  /// The preferred duration of the job (e.g., 'short-term', 'long-term').
  final String? durationPreference;
  /// A list of specific company names to filter by.
  final List<String> companies;

  // Sorting
  /// The field to sort the job results by.
  final JobSortOption sortBy;
  /// Whether to sort the results in descending order.
  final bool sortDescending;
  
  // Search query
  /// A general text search query to match against job details.
  final String? searchQuery;

  /// Creates an instance of [JobFilterCriteria].
  const JobFilterCriteria({
    this.city,
    this.state,
    this.maxDistance,
    this.classifications = const [],
    this.localNumbers = const [],
    this.constructionTypes = const [],
    this.jobClasses = const [],
    this.postedAfter,
    this.startDateBefore,
    this.startDateAfter,
    this.hasPerDiem,
    this.durationPreference,
    this.companies = const [],
    this.sortBy = JobSortOption.datePosted,
    this.sortDescending = true,
    this.searchQuery,
  });

  /// Creates a new instance of [JobFilterCriteria] with no filters applied.
  factory JobFilterCriteria.empty() => const JobFilterCriteria();

  /// A boolean indicating whether any filters are currently active.
  bool get hasActiveFilters {
    return city != null ||
        state != null ||
        maxDistance != null ||
        classifications.isNotEmpty ||
        localNumbers.isNotEmpty ||
        constructionTypes.isNotEmpty ||
        jobClasses.isNotEmpty ||
        postedAfter != null ||
        startDateBefore != null ||
        startDateAfter != null ||
        hasPerDiem != null ||
        durationPreference != null ||
        companies.isNotEmpty ||
        searchQuery != null;
  }

  /// Returns the total number of currently active filters.
  int get activeFilterCount {
    int count = 0;
    if (city != null) count++;
    if (state != null) count++;
    if (maxDistance != null) count++;
    if (classifications.isNotEmpty) count++;
    if (localNumbers.isNotEmpty) count++;
    if (constructionTypes.isNotEmpty) count++;
    if (jobClasses.isNotEmpty) count++;
    if (postedAfter != null) count++;
    if (startDateBefore != null) count++;
    if (startDateAfter != null) count++;
    if (hasPerDiem != null) count++;
    if (durationPreference != null) count++;
    if (companies.isNotEmpty) count++;
    if (searchQuery != null) count++;
    return count;
  }

  /// Applies the current filter criteria to a Firestore [Query].
  ///
  /// This method constructs a new query by adding `where` and `orderBy` clauses
  /// based on the set filters. Note that location-based distance filtering
  /// must be handled client-side after the initial query.
  ///
  /// - [query]: The base `Query` to which filters will be applied.
  ///
  /// Returns a new `Query` object with the filters applied.
  Query applyToQuery(Query query) {
    // Apply classification filters
    if (classifications.isNotEmpty) {
      query = query.where('classification', whereIn: classifications);
    }
    
    // Apply local number filters
    if (localNumbers.isNotEmpty) {
      query = query.where('localNumber', whereIn: localNumbers);
    }
    
    // Apply construction type filters
    if (constructionTypes.isNotEmpty) {
      query = query.where('typeOfWork', whereIn: constructionTypes);
    }

    // Apply date filters
    if (postedAfter != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: postedAfter);
    }
    
    if (startDateBefore != null) {
      query = query.where('startDate_timestamp', isLessThanOrEqualTo: startDateBefore);
    }
    
    if (startDateAfter != null) {
      query = query.where('startDate_timestamp', isGreaterThanOrEqualTo: startDateAfter);
    }
    
    // Apply per diem filter
    if (hasPerDiem != null) {
      if (hasPerDiem == true) {
        query = query.where('per_diem', isNotEqualTo: '');
      }
    }
    
    // Apply company filters
    if (companies.isNotEmpty) {
      query = query.where('company', whereIn: companies);
    }

    // Apply sorting
    switch (sortBy) {
      case JobSortOption.datePosted:
        query = query.orderBy('timestamp', descending: sortDescending);
        break;
      case JobSortOption.wage:
        query = query.orderBy('wage_numeric', descending: sortDescending);
        break;
      case JobSortOption.startDate:
        query = query.orderBy('startDate_timestamp', descending: sortDescending);
        break;
      case JobSortOption.distance:
        // Distance sorting would need to be done client-side
        query = query.orderBy('timestamp', descending: sortDescending);
        break;
    }
    
    return query;
  }

  /// Creates a new [JobFilterCriteria] instance with updated values.
  JobFilterCriteria copyWith({
    String? city,
    String? state,
    double? maxDistance,
    List<String>? classifications,
    List<int>? localNumbers,
    List<String>? constructionTypes,
    List<String>? jobClasses,
    DateTime? postedAfter,
    DateTime? startDateBefore,
    DateTime? startDateAfter,
    bool? hasPerDiem,
    String? durationPreference,
    List<String>? companies,
    JobSortOption? sortBy,
    bool? sortDescending,
    String? searchQuery,
  }) {
    return JobFilterCriteria(
      city: city ?? this.city,
      state: state ?? this.state,
      maxDistance: maxDistance ?? this.maxDistance,
      classifications: classifications ?? this.classifications,
      localNumbers: localNumbers ?? this.localNumbers,
      constructionTypes: constructionTypes ?? this.constructionTypes,
      jobClasses: jobClasses ?? this.jobClasses,
      postedAfter: postedAfter ?? this.postedAfter,
      startDateBefore: startDateBefore ?? this.startDateBefore,
      startDateAfter: startDateAfter ?? this.startDateAfter,
      hasPerDiem: hasPerDiem ?? this.hasPerDiem,
      durationPreference: durationPreference ?? this.durationPreference,
      companies: companies ?? this.companies,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Returns a new [JobFilterCriteria] instance with a specific filter category cleared.
  ///
  /// - [filterType]: The [FilterType] to clear.
  JobFilterCriteria clearFilter(FilterType filterType) {
    switch (filterType) {
      case FilterType.location:
        return copyWith(city: null, state: null, maxDistance: null);
      case FilterType.classification:
        return copyWith(classifications: []);
      case FilterType.local:
        return copyWith(localNumbers: []);
      case FilterType.constructionType:
        return copyWith(constructionTypes: []);
      case FilterType.date:
        return copyWith(
          postedAfter: null,
          startDateBefore: null,
          startDateAfter: null,
        );
      case FilterType.perDiem:
        return copyWith(hasPerDiem: null);
      case FilterType.duration:
        return copyWith(durationPreference: null);
      case FilterType.company:
        return copyWith(companies: []);
      case FilterType.search:
        return copyWith(searchQuery: null);
    }
  }

  /// Serializes the [JobFilterCriteria] instance to a JSON map.
  ///
  /// This is useful for saving filter presets.
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'maxDistance': maxDistance,
      'classifications': classifications,
      'localNumbers': localNumbers,
      'constructionTypes': constructionTypes,
      'jobClasses': jobClasses,
      'postedAfter': postedAfter?.toIso8601String(),
      'startDateBefore': startDateBefore?.toIso8601String(),
      'startDateAfter': startDateAfter?.toIso8601String(),
      'hasPerDiem': hasPerDiem,
      'durationPreference': durationPreference,
      'companies': companies,
      'sortBy': sortBy.index,
      'sortDescending': sortDescending,
      'searchQuery': searchQuery,
    };
  }

  /// Creates a [JobFilterCriteria] instance from a JSON map.
  factory JobFilterCriteria.fromJson(Map<String, dynamic> json) {
    return JobFilterCriteria(
      city: json['city'],
      state: json['state'],
      maxDistance: json['maxDistance']?.toDouble(),
      classifications: List<String>.from(json['classifications'] ?? []),
      localNumbers: List<int>.from(json['localNumbers'] ?? []),
      constructionTypes: List<String>.from(json['constructionTypes'] ?? []),
      jobClasses: List<String>.from(json['jobClasses'] ?? []),
      postedAfter: json['postedAfter'] != null
          ? DateTime.parse(json['postedAfter'])
          : null,
      startDateBefore: json['startDateBefore'] != null
          ? DateTime.parse(json['startDateBefore'])
          : null,
      startDateAfter: json['startDateAfter'] != null
          ? DateTime.parse(json['startDateAfter'])
          : null,
      hasPerDiem: json['hasPerDiem'],
      durationPreference: json['durationPreference'],
      companies: List<String>.from(json['companies'] ?? []),
      sortBy: JobSortOption.values[json['sortBy'] ?? 0],
      sortDescending: json['sortDescending'] ?? true,
      searchQuery: json['searchQuery'],
    );
  }
}

/// An enumeration of the different categories of filters that can be applied.
enum FilterType {
  /// Filters related to geographic location (city, state, distance).
  location,
  /// Filters related to IBEW job classifications.
  classification,
  /// Filters for specific IBEW local unions.
  local,
  /// Filters for the type of construction work.
  constructionType,
  /// Filters related to job posting or start dates.
  date,
  /// Filters for whether a job offers per diem.
  perDiem,
  /// Filters for the duration of the job.
  duration,
  /// Filters for specific companies.
  company,
  /// A general text search filter.
  search,
}

/// An enumeration of the available options for sorting job search results.
enum JobSortOption {
  /// Sort by the date the job was posted.
  datePosted,
  /// Sort by the offered wage.
  wage,
  /// Sort by the job's start date.
  startDate,
  /// Sort by distance from a location (requires client-side sorting).
  distance,
}

/// An extension on [JobSortOption] to provide user-friendly display names.
extension JobSortOptionExtension on JobSortOption {
  /// Returns the display-friendly name for the sort option.
  String get displayName {
    switch (this) {
      case JobSortOption.datePosted:
        return 'Date Posted';
      case JobSortOption.wage:
        return 'Wage';
      case JobSortOption.startDate:
        return 'Start Date';
      case JobSortOption.distance:
        return 'Distance';
    }
  }
}