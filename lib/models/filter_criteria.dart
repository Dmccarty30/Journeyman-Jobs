
enum JobSortOption {
  datePosted,
  wage,
  startDate,
  distance,
}

enum FilterType {
  searchQuery,
  constructionTypes,
  classifications,
  state,
  city,
  hasPerDiem,
  minWage,
  maxDistance,
  postedAfter,
  localNumbers,
  companies,
  startDate,
  durationPreference,
}

class JobFilterCriteria {
  final String? searchQuery;
  final JobSortOption? sortBy;
  final bool sortDescending;
  final List<String>? constructionTypes;
  final List<String>? classifications;
  final String? state;
  final String? city;
  final bool? hasPerDiem;
  final double? minWage;
  final double? maxDistance;
  final DateTime? postedAfter;
  final List<String>? localNumbers;
  final List<String>? companies;
  final DateTime? startDateAfter;
  final DateTime? startDateBefore;
  final String? durationPreference;

  const JobFilterCriteria({
    this.searchQuery,
    this.sortBy,
    this.sortDescending = true,
    this.constructionTypes,
    this.classifications,
    this.state,
    this.city,
    this.hasPerDiem,
    this.minWage,
    this.maxDistance,
    this.postedAfter,
    this.localNumbers,
    this.companies,
    this.startDateAfter,
    this.startDateBefore,
    this.durationPreference,
  });

  JobFilterCriteria copyWith({
    String? searchQuery,
    JobSortOption? sortBy,
    bool? sortDescending,
    List<String>? constructionTypes,
    List<String>? classifications,
    String? state,
    String? city,
    bool? hasPerDiem,
    double? minWage,
    double? maxDistance,
    DateTime? postedAfter,
    List<String>? localNumbers,
    List<String>? companies,
    DateTime? startDateAfter,
    DateTime? startDateBefore,
    String? durationPreference,
  }) {
    return JobFilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      constructionTypes: constructionTypes ?? this.constructionTypes,
      classifications: classifications ?? this.classifications,
      state: state ?? this.state,
      city: city ?? this.city,
      hasPerDiem: hasPerDiem ?? this.hasPerDiem,
      minWage: minWage ?? this.minWage,
      maxDistance: maxDistance ?? this.maxDistance,
      postedAfter: postedAfter ?? this.postedAfter,
      localNumbers: localNumbers ?? this.localNumbers,
      companies: companies ?? this.companies,
      startDateAfter: startDateAfter ?? this.startDateAfter,
      startDateBefore: startDateBefore ?? this.startDateBefore,
      durationPreference: durationPreference ?? this.durationPreference,
    );
  }

  factory JobFilterCriteria.empty() => const JobFilterCriteria();

  bool get hasActiveFilters {
    return searchQuery != null ||
        (constructionTypes != null && constructionTypes!.isNotEmpty) ||
        (classifications != null && classifications!.isNotEmpty) ||
        state != null ||
        city != null ||
        hasPerDiem != null ||
        minWage != null ||
        maxDistance != null ||
        postedAfter != null ||
        (localNumbers != null && localNumbers!.isNotEmpty) ||
        (companies != null && companies!.isNotEmpty) ||
        startDateAfter != null ||
        startDateBefore != null ||
        durationPreference != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null) count++;
    if (constructionTypes != null && constructionTypes!.isNotEmpty) count++;
    if (classifications != null && classifications!.isNotEmpty) count++;
    if (state != null) count++;
    if (city != null) count++;
    if (hasPerDiem != null) count++;
    if (minWage != null) count++;
    if (maxDistance != null) count++;
    if (postedAfter != null) count++;
    if (localNumbers != null && localNumbers!.isNotEmpty) count++;
    if (companies != null && companies!.isNotEmpty) count++;
    if (startDateAfter != null) count++;
    if (startDateBefore != null) count++;
    if (durationPreference != null) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'sortBy': sortBy?.index,
      'sortDescending': sortDescending,
      'constructionTypes': constructionTypes,
      'classifications': classifications,
      'state': state,
      'city': city,
      'hasPerDiem': hasPerDiem,
      'minWage': minWage,
      'maxDistance': maxDistance,
      'postedAfter': postedAfter?.toIso8601String(),
      'localNumbers': localNumbers,
      'companies': companies,
      'startDateAfter': startDateAfter?.toIso8601String(),
      'startDateBefore': startDateBefore?.toIso8601String(),
      'durationPreference': durationPreference,
    };
  }

  factory JobFilterCriteria.fromJson(Map<String, dynamic> json) {
    return JobFilterCriteria(
      searchQuery: json['searchQuery'],
      sortBy:
          json['sortBy'] != null ? JobSortOption.values[json['sortBy']] : null,
      sortDescending: json['sortDescending'] ?? true,
      constructionTypes:
          (json['constructionTypes'] as List<dynamic>?)?.cast<String>(),
      classifications:
          (json['classifications'] as List<dynamic>?)?.cast<String>(),
      state: json['state'],
      city: json['city'],
      hasPerDiem: json['hasPerDiem'],
      minWage: (json['minWage'] as num?)?.toDouble(),
      maxDistance: (json['maxDistance'] as num?)?.toDouble(),
      postedAfter: json['postedAfter'] != null
          ? DateTime.parse(json['postedAfter'])
          : null,
      localNumbers: (json['localNumbers'] as List<dynamic>?)?.cast<String>(),
      companies: (json['companies'] as List<dynamic>?)?.cast<String>(),
      startDateAfter: json['startDateAfter'] != null
          ? DateTime.parse(json['startDateAfter'])
          : null,
      startDateBefore: json['startDateBefore'] != null
          ? DateTime.parse(json['startDateBefore'])
          : null,
      durationPreference: json['durationPreference'],
    );
  }

  JobFilterCriteria clearFilter(FilterType filterType) {
    switch (filterType) {
      case FilterType.searchQuery:
        return copyWith(searchQuery: null);
      case FilterType.constructionTypes:
        return copyWith(constructionTypes: <String>[]);
      case FilterType.classifications:
        return copyWith(classifications: <String>[]);
      case FilterType.state:
        return copyWith(state: null);
      case FilterType.city:
        return copyWith(city: null);
      case FilterType.hasPerDiem:
        return copyWith(hasPerDiem: null);
      case FilterType.minWage:
        return copyWith(minWage: null);
      case FilterType.maxDistance:
        return copyWith(maxDistance: null);
      case FilterType.postedAfter:
        return copyWith(postedAfter: null);
      case FilterType.localNumbers:
        return copyWith(localNumbers: <String>[]);
      case FilterType.companies:
        return copyWith(companies: <String>[]);
      case FilterType.startDate:
        return copyWith(startDateAfter: null, startDateBefore: null);
      case FilterType.durationPreference:
        return copyWith(durationPreference: null);
    }
  }
}
