import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing job filter criteria
class JobFilterCriteria {
  // Location filters
  final String? city;
  final String? state;
  final double? maxDistance; // in miles
  
  // Classification filters
  final List<String> classifications;
  final List<int> localNumbers;
  
  // Job type filters
  final List<String> constructionTypes;
  final List<String> jobClasses;

  // Time filters
  final DateTime? postedAfter;
  final DateTime? startDateBefore;
  final DateTime? startDateAfter;
  
  // Work preferences
  final bool? hasPerDiem;
  final String? durationPreference; // 'short-term', 'long-term', 'any'
  final List<String> companies;

  // Sorting
  final JobSortOption sortBy;
  final bool sortDescending;
  
  // Search query
  final String? searchQuery;

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

  /// Create an empty filter criteria
  factory JobFilterCriteria.empty() => const JobFilterCriteria();

  /// Check if any filters are active
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

  /// Get the count of active filters
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

  /// Apply filters to a Firestore query
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

  /// Copy with new values
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

  /// Clear specific filter
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

  /// Convert to JSON for storage
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

  /// Create from JSON
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

/// Enum for different filter types
enum FilterType {
  location,
  classification,
  local,
  constructionType,
  date,
  perDiem,
  duration,
  company,
  search,
}

/// Enum for job sorting options
enum JobSortOption {
  datePosted,
  wage,
  startDate,
  distance,
}

/// Extension to get display names for sort options
extension JobSortOptionExtension on JobSortOption {
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