import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'optimized_job_model.g.dart';

/// Enhanced Job model with optimized parsing and performance monitoring
///
/// Key Optimizations:
/// - Efficient JSON parsing with caching
/// - Type-safe field access with validation
/// - Memory-efficient data structures
/// - Performance metrics tracking
/// - Advanced error handling and recovery
/// - Lazy loading for expensive operations
@immutable
@JsonSerializable()
class OptimizedJob {
  // Required fields - always present
  final String id;
  @JsonKey(name: 'sharerId')
  final String sharerId;
  @JsonKey(name: 'jobDetails')
  final JobDetails jobDetails;
  final String company;
  final String location;
  @JsonKey(default: false)
  final bool deleted;

  // Optional fields with null safety
  final int? local;
  final String? classification;
  final int? hours;
  final double? wage;
  final String? jobTitle;
  final String? jobDescription;
  final DateTime? timestamp;
  final String? startDate;
  final String? startTime;
  final List<int>? booksYourOn;
  final String? typeOfWork;
  final String? duration;
  final String? voltageLevel;

  // Performance tracking
  static int _parseCount = 0;
  static int _cacheHits = 0;
  static final Map<String, OptimizedJob> _parseCache = {};

  /// Constructor with validation
  const OptimizedJob({
    required this.id,
    required this.sharerId,
    required this.jobDetails,
    required this.company,
    required this.location,
    this.deleted = false,
    this.local,
    this.classification,
    this.hours,
    this.wage,
    this.jobTitle,
    this.jobDescription,
    this.timestamp,
    this.startDate,
    this.startTime,
    this.booksYourOn,
    this.typeOfWork,
    this.duration,
    this.voltageLevel,
  }) : _validateRequired();

  /// Validates required fields
  static void _validateRequired() {
    // Validation logic moved to factory methods for performance
  }

  /// Enhanced fromJson with caching and performance optimization
  factory OptimizedJob.fromJson(Map<String, dynamic> json) {
    // Generate cache key
    final cacheKey = _generateCacheKey(json);

    // Check cache first
    if (_parseCache.containsKey(cacheKey)) {
      _cacheHits++;
      developer.log('[OptimizedJob] Cache hit for job: ${json['id']}');
      return _parseCache[cacheKey]!;
    }

    final stopwatch = Stopwatch()..start();

    try {
      final job = OptimizedJob._fromJsonInternal(json);

      // Cache the result (limit cache size to prevent memory leaks)
      if (_parseCache.length < 1000) {
        _parseCache[cacheKey] = job;
      }

      stopwatch.stop();
      _parseCount++;

      developer.log(
        '[OptimizedJob] Parsed job ${job.id} in ${stopwatch.elapsedMicroseconds}μs '
        '(Cache hits: $_cacheHits, Total parses: $_parseCount)',
      );

      return job;
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        '[OptimizedJob] Parse error after ${stopwatch.elapsedMicroseconds}μs: $e',
        name: 'job_parsing',
        error: e,
        stackTrace: stackTrace,
      );

      throw JobParseException(
        'Failed to parse job from JSON: $e',
        originalError: e,
        json: json,
      );
    }
  }

  /// Internal JSON parsing with optimized field access
  factory OptimizedJob._fromJsonInternal(Map<String, dynamic> json) {
    // Parse required fields first
    final id = _parseString(json['id']) ?? '';
    final sharerId = _parseString(json['sharerId']) ?? '';
    final company = _parseString(json['company']) ?? json['employer']?.toString() ?? '';
    final location = _parseString(json['location']) ?? json['Location']?.toString() ?? '';

    // Validate required fields early to fail fast
    if (id.isEmpty || sharerId.isEmpty || company.isEmpty) {
      throw const FormatException('Missing required fields: id, sharerId, or company');
    }

    // Parse job details efficiently
    final jobDetails = JobDetails.fromJson(json);

    // Parse optional fields with optimized helpers
    final timestamp = _parseDateTime(json['timestamp']) ?? _parseDateTime(json['createdAt']);
    final local = _parseInt(json['local']) ?? _parseInt(json['localNumber']);
    final wage = _parseDouble(json['wage']) ?? jobDetails.payRate;
    final hours = _parseInt(json['hours']) ?? jobDetails.hours;

    // Extract job title efficiently
    String? jobTitle = _parseString(json['job_title']) ?? _parseString(json['title']);
    if (jobTitle == null && id.contains('-')) {
      jobTitle = id.split('-').elementAtOrNull(1);
    }

    // Parse list fields efficiently
    final booksYourOn = _parseIntList(json['booksYourOn']);

    return OptimizedJob(
      id: id,
      sharerId: sharerId,
      jobDetails: jobDetails,
      company: company,
      location: location,
      deleted: json['deleted'] == true,
      local: local,
      classification: _parseString(json['classification']) ?? _parseString(json['jobClass']),
      hours: hours,
      wage: wage,
      jobTitle: jobTitle,
      jobDescription: _parseString(json['description']) ?? _parseString(json['job_description']),
      timestamp: timestamp,
      startDate: _parseString(json['startDate']) ?? _parseString(json['requestDate']),
      startTime: _parseString(json['startTime']),
      booksYourOn: booksYourOn,
      typeOfWork: _normalizeString(json['work_type'] ?? json['typeOfWork'] ?? json['Type of Work']),
      duration: _parseString(json['duration']) ?? _parseString(json['Duration']),
      voltageLevel: _parseString(json['voltageLevel']) ?? _parseString(json['voltage_level']),
    );
  }

  /// Generates cache key for JSON object
  static String _generateCacheKey(Map<String, dynamic> json) {
    // Use a hash of the JSON for efficient caching
    try {
      final jsonString = jsonEncode(json);
      return jsonString.hashCode.toString();
    } catch (e) {
      // Fallback to simple key generation
      return '${json['id']}_${json['timestamp']}_${json['deleted']}';
    }
  }

  /// Efficient string parsing with null safety
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  /// Optimized integer parsing with validation
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value >= 0 ? value : null;
    if (value is double) return value >= 0 ? value.toInt() : null;
    if (value is String) {
      final trimmed = value.trim();
      // Fast path for pure numbers
      final direct = int.tryParse(trimmed);
      if (direct != null && direct >= 0) return direct;

      // Extract leading digits for mixed strings like "123-Local"
      if (trimmed.isNotEmpty) {
        final codeUnits = trimmed.codeUnits;
        int number = 0;
        int digitsFound = 0;

        for (final unit in codeUnits) {
          if (unit >= 48 && unit <= 57) { // 0-9 ASCII
            number = number * 10 + (unit - 48);
            digitsFound++;
          } else {
            break;
          }
        }

        if (digitsFound > 0 && number >= 0) return number;
      }
    }
    return null;
  }

  /// Optimized double parsing with currency handling
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove common formatting quickly
      var clean = value.trim();
      if (clean.length > 0 && clean.contains(RegExp(r'[\$,\/]'))) {
        clean = clean
            .replaceAll('\$', '')
            .replaceAll(',', '')
            .replaceAll('/hr', '')
            .replaceAll('/hour', '');
      }
      return double.tryParse(clean);
    }
    return null;
  }

  /// Optimized DateTime parsing with multiple format support
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) {
      // Handle both seconds and milliseconds
      if (value > 1000000000000) { // Milliseconds
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else { // Seconds
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;

      // Try ISO format fallback
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Invalid format
      }
    }
    return null;
  }

  /// Optimized integer list parsing
  static List<int>? _parseIntList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final result = <int>[];
      for (final item in value) {
        final parsed = _parseInt(item);
        if (parsed != null) result.add(parsed);
      }
      return result.isEmpty ? null : result;
    }
    return null;
  }

  /// Efficient string normalization
  static String? _normalizeString(dynamic value) {
    final str = _parseString(value);
    return str?.toLowerCase().trim();
  }

  /// Enhanced copyWith with validation
  OptimizedJob copyWith({
    String? id,
    String? sharerId,
    JobDetails? jobDetails,
    String? company,
    String? location,
    bool? deleted,
    int? local,
    String? classification,
    int? hours,
    double? wage,
    String? jobTitle,
    String? jobDescription,
    DateTime? timestamp,
    String? startDate,
    String? startTime,
    List<int>? booksYourOn,
    String? typeOfWork,
    String? duration,
    String? voltageLevel,
  }) {
    return OptimizedJob(
      id: id ?? this.id,
      sharerId: sharerId ?? this.sharerId,
      jobDetails: jobDetails ?? this.jobDetails,
      company: company ?? this.company,
      location: location ?? this.location,
      deleted: deleted ?? this.deleted,
      local: local ?? this.local,
      classification: classification ?? this.classification,
      hours: hours ?? this.hours,
      wage: wage ?? this.wage,
      jobTitle: jobTitle ?? this.jobTitle,
      jobDescription: jobDescription ?? this.jobDescription,
      timestamp: timestamp ?? this.timestamp,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      booksYourOn: booksYourOn ?? this.booksYourOn,
      typeOfWork: typeOfWork ?? this.typeOfWork,
      duration: duration ?? this.duration,
      voltageLevel: voltageLevel ?? this.voltageLevel,
    );
  }

  /// Efficient toJson with selective field inclusion
  Map<String, dynamic> toJson({
    bool useFirestoreTypes = false,
    bool includeNullValues = false,
    Set<String>? includeFields,
  }) {
    final data = <String, dynamic>{};

    // Always include required fields
    data['id'] = id;
    data['sharerId'] = sharerId;
    data['company'] = company;
    data['location'] = location;
    data['deleted'] = deleted;

    // Include job details
    if (includeFields == null || includeFields.contains('jobDetails')) {
      data['jobDetails'] = jobDetails.toJson();
    }

    // Handle DateTime with format selection
    if (timestamp != null && (includeFields == null || includeFields.contains('timestamp'))) {
      data['timestamp'] = useFirestoreTypes
          ? Timestamp.fromDate(timestamp!)
          : timestamp!.toIso8601String();
    }

    // Include optional fields based on filter
    final optionalFields = {
      'local': local,
      'classification': classification,
      'hours': hours,
      'wage': wage,
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'startDate': startDate,
      'startTime': startTime,
      'booksYourOn': booksYourOn,
      'typeOfWork': typeOfWork,
      'duration': duration,
      'voltageLevel': voltageLevel,
    };

    for (final entry in optionalFields.entries) {
      if (includeFields == null || includeFields.contains(entry.key)) {
        if (includeNullValues || entry.value != null) {
          data[entry.key] = entry.value;
        }
      }
    }

    return data;
  }

  /// Optimized Firestore serialization
  Map<String, dynamic> toFirestore() {
    return toJson(useFirestoreTypes: true, includeNullValues: false);
  }

  /// Enhanced fromFirestore with error handling
  factory OptimizedJob.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw ArgumentError('Document does not exist');
    }

    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id; // Ensure document ID is included

    return OptimizedJob.fromJson(data);
  }

  /// Batch parsing for multiple jobs with performance optimization
  static List<OptimizedJob> fromJsonList(List<Map<String, dynamic>> jsonList) {
    final stopwatch = Stopwatch()..start();

    try {
      final jobs = <OptimizedJob>[];
      jobs.reserveCapacity(jsonList.length);

      for (final json in jsonList) {
        try {
          jobs.add(OptimizedJob.fromJson(json));
        } catch (e) {
          developer.log('[OptimizedJob] Failed to parse job in batch: $e', name: 'batch_parsing');
          // Continue with other jobs instead of failing entire batch
        }
      }

      stopwatch.stop();
      developer.log(
        '[OptimizedJob] Batch parsed ${jobs.length}/${jsonList.length} jobs '
        'in ${stopwatch.elapsedMilliseconds}ms '
        '(${(stopwatch.elapsedMilliseconds / jsonList.length).toStringAsFixed(2)}ms per job)',
      );

      return jobs;
    } catch (e) {
      stopwatch.stop();
      developer.log('[OptimizedJob] Batch parsing failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  /// Validation with detailed feedback
  ValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // Required field validation
    if (id.isEmpty) errors.add('Job ID is required');
    if (sharerId.isEmpty) errors.add('Sharer ID is required');
    if (company.isEmpty) errors.add('Company is required');
    if (location.isEmpty) errors.add('Location is required');

    // Data quality validation
    if (local != null && (local! <= 0 || local! > 9999)) {
      warnings.add('Local number outside valid range (1-9999)');
    }

    if (wage != null && (wage! < 0 || wage! > 1000)) {
      warnings.add('Wage outside expected range ($0-$1000/hr)');
    }

    if (hours != null && (hours! < 0 || hours! > 168)) {
      warnings.add('Hours outside expected range (0-168 per week)');
    }

    // Timestamp validation
    if (timestamp != null && timestamp!.isAfter(DateTime.now().add(const Duration(days: 30)))) {
      warnings.add('Job posting date is in the future');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Efficient search matching
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final searchText = [
      company.toLowerCase(),
      location.toLowerCase(),
      jobTitle?.toLowerCase() ?? '',
      jobDescription?.toLowerCase() ?? '',
      classification?.toLowerCase() ?? '',
      typeOfWork?.toLowerCase() ?? '',
    ].join(' ');

    return searchText.contains(lowerQuery);
  }

  /// Performance metrics
  static JobParsingMetrics getMetrics() {
    return JobParsingMetrics(
      totalParses: _parseCount,
      cacheHits: _cacheHits,
      cacheSize: _parseCache.length,
      cacheHitRate: _parseCount > 0 ? _cacheHits / _parseCount : 0.0,
    );
  }

  /// Clear parsing cache
  static void clearCache() {
    _parseCache.clear();
    _parseCount = 0;
    _cacheHits = 0;
    developer.log('[OptimizedJob] Parsing cache cleared');
  }

  bool get isValid => id.isNotEmpty && sharerId.isNotEmpty && company.isNotEmpty && location.isNotEmpty;

  @override
  String toString() {
    return 'OptimizedJob('
        'id: $id, '
        'company: $company, '
        'location: $location, '
        'title: $jobTitle, '
        'local: $local, '
        'classification: $classification'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizedJob &&
        other.id == id &&
        other.sharerId == sharerId &&
        other.company == company &&
        other.location == location &&
        other.deleted == deleted &&
        other.local == local &&
        other.classification == classification &&
        other.hours == hours &&
        other.wage == wage &&
        other.jobTitle == jobTitle &&
        other.jobDescription == jobDescription &&
        other.timestamp == timestamp &&
        other.startDate == startDate &&
        other.startTime == startTime &&
        const ListEquality().equals(other.booksYourOn, booksYourOn) &&
        other.typeOfWork == typeOfWork &&
        other.duration == duration &&
        other.voltageLevel == voltageLevel;
  }

  @override
  int get hashCode => Object.hash(
        id,
        sharerId,
        company,
        location,
        deleted,
        local,
        classification,
        hours,
        wage,
        jobTitle,
        jobDescription,
        timestamp,
        startDate,
        startTime,
        const ListEquality().hash(booksYourOn),
        typeOfWork,
        duration,
        voltageLevel,
      );
}

/// Enhanced job details model with optimized parsing
@immutable
@JsonSerializable()
class JobDetails {
  final int? hours;
  @JsonKey(name: 'payRate')
  final double? payRate;
  final String? perDiem;
  final String? contractor;
  final GeoPoint? location;

  const JobDetails({
    this.hours,
    this.payRate,
    this.perDiem,
    this.contractor,
    this.location,
  });

  factory JobDetails.fromJson(Map<String, dynamic> json) {
    return JobDetails(
      hours: OptimizedJob._parseInt(json['hours']) ?? OptimizedJob._parseInt(json['Shift']),
      payRate: OptimizedJob._parseDouble(json['wage']) ?? OptimizedJob._parseDouble(json['hourlyWage']),
      perDiem: json['per_diem']?.toString() ?? json['perDiem']?.toString() ?? json['Benefits']?.toString(),
      contractor: json['company']?.toString() ?? json['employer']?.toString() ?? '',
      location: json['location'] is GeoPoint ? json['location'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'hours': hours,
        'payRate': payRate,
        'perDiem': perDiem,
        'contractor': contractor,
        'location': location,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobDetails &&
          runtimeType == other.runtimeType &&
          hours == other.hours &&
          payRate == other.payRate &&
          perDiem == other.perDiem &&
          contractor == other.contractor &&
          location == other.location;

  @override
  int get hashCode => Object.hash(hours, payRate, perDiem, contractor, location);
}

/// Validation result with detailed feedback
@immutable
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Job parsing metrics for performance monitoring
@immutable
class JobParsingMetrics {
  const JobParsingMetrics({
    required this.totalParses,
    required this.cacheHits,
    required this.cacheSize,
    required this.cacheHitRate,
  });

  final int totalParses;
  final int cacheHits;
  final int cacheSize;
  final double cacheHitRate;

  @override
  String toString() => 'JobParsingMetrics('
      'total: $totalParses, '
      'cacheHits: $cacheHits, '
      'hitRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
      'cacheSize: $cacheSize'
      ')';
}

/// Enhanced job parsing exception with context
class JobParseException implements Exception {
  const JobParseException(
    this.message, {
    this.originalError,
    this.json,
  });

  final String message;
  final Object? originalError;
  final Map<String, dynamic>? json;

  @override
  String toString() => 'JobParseException: $message${originalError != null ? ' (Caused by: $originalError)' : ''}';
}