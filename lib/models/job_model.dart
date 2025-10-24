import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Model class representing a Job posting
/// Matches the backend JobsRecord schema
@immutable
class Job {
  // Document reference
  final String id;
  final DocumentReference? reference;
  final String sharerId;
  final Map<String, dynamic>
  jobDetails; // Nested details: hours, payRate, perDiem, contractor, location (GeoPoint)
  final bool matchesCriteria;
  final bool deleted;

  // Core job fields (legacy/flat fields for compatibility)
  final int? local;
  final String? classification;
  final String company;
  final String location;
  final int? hours;
  final double? wage;
  final String? sub;
  final String? jobClass;
  final int? localNumber;
  final String? qualifications;
  final String? datePosted;
  final String? jobDescription;
  final String? jobTitle;
  final String? perDiem;
  final String? agreement;
  final String? numberOfJobs;
  final DateTime? timestamp;
  final String? startDate;
  final String? startTime;
  final List<int>? booksYourOn;
  final String? typeOfWork;
  final String? duration;
  final String? voltageLevel; // New field for voltage categorization

  /// Constructor with required and optional parameters
  const Job({
    required this.id,
    this.reference,
    required this.sharerId,
    required this.jobDetails,
    this.matchesCriteria = false,
    this.deleted = false,
    this.local,
    this.classification,
    required this.company,
    required this.location,
    this.hours,
    this.wage,
    this.sub,
    this.jobClass,
    this.localNumber,
    this.qualifications,
    this.datePosted,
    this.jobDescription,
    this.jobTitle,
    this.perDiem,
    this.agreement,
    this.numberOfJobs,
    this.timestamp,
    this.startDate,
    this.startTime,
    this.booksYourOn,
    this.typeOfWork,
    this.duration,
    this.voltageLevel,
  });

  /// Creates a copy of this Job with the given fields replaced with new values
  Job copyWith({
    String? id,
    DocumentReference? reference,
    String? sharerId,
    Map<String, dynamic>? jobDetails,
    bool? matchesCriteria,
    bool? deleted,
    int? local,
    String? classification,
    String? company,
    String? location,
    int? hours,
    double? wage,
    String? sub,
    String? jobClass,
    int? localNumber,
    String? qualifications,
    String? datePosted,
    String? jobDescription,
    String? jobTitle,
    String? perDiem,
    String? agreement,
    String? numberOfJobs,
    DateTime? timestamp,
    String? startDate,
    String? startTime,
    List<int>? booksYourOn,
    String? typeOfWork,
    String? duration,
    String? voltageLevel,
  }) {
    return Job(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      sharerId: sharerId ?? this.sharerId,
      jobDetails: jobDetails ?? this.jobDetails,
      matchesCriteria: matchesCriteria ?? this.matchesCriteria,
      deleted: deleted ?? this.deleted,
      local: local ?? this.local,
      classification: classification ?? this.classification,
      company: company ?? this.company,
      location: location ?? this.location,
      hours: hours ?? this.hours,
      wage: wage ?? this.wage,
      sub: sub ?? this.sub,
      jobClass: jobClass ?? this.jobClass,
      localNumber: localNumber ?? this.localNumber,
      qualifications: qualifications ?? this.qualifications,
      datePosted: datePosted ?? this.datePosted,
      jobDescription: jobDescription ?? this.jobDescription,
      jobTitle: jobTitle ?? this.jobTitle,
      perDiem: perDiem ?? this.perDiem,
      agreement: agreement ?? this.agreement,
      numberOfJobs: numberOfJobs ?? this.numberOfJobs,
      timestamp: timestamp ?? this.timestamp,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      booksYourOn: booksYourOn ?? this.booksYourOn,
      typeOfWork: typeOfWork ?? this.typeOfWork,
      duration: duration ?? this.duration,
      voltageLevel: voltageLevel ?? this.voltageLevel,
    );
  }

  /// Creates a Job instance from a JSON map
  /// Handles both Firestore documents and standard JSON
  ///
  /// This factory method is schema-agnostic and handles:
  /// - local/localNumber as int, string, or double
  /// - Missing 'deleted' field (defaults to false)
  /// - timestamp with fallback to createdAt or epoch
  /// - typeOfWork normalization to lowercase
  /// - Hours and perDiem with robust parsing
  factory Job.fromJson(Map<String, dynamic> json) {
    /// Helper to parse DateTime from various formats with robust fallback
    ///
    /// Handles Firestore Timestamp, DateTime, String, int (milliseconds)
    /// Falls back to 'createdAt' field, returns null if no valid timestamp found
    ///
    /// CRITICAL FIX: Returns nullable DateTime? to maintain contract with Job.timestamp field
    DateTime? parseTimestamp(dynamic value, Map<String, dynamic> json) {
      // Try primary timestamp field
      if (value != null) {
        if (value is Timestamp) return value.toDate();
        if (value is DateTime) return value;
        if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          if (parsed != null) return parsed;
        }
      }

      // Fallback to createdAt field
      final createdAt = json['createdAt'];
      if (createdAt != null) {
        if (createdAt is Timestamp) return createdAt.toDate();
        if (createdAt is DateTime) return createdAt;
        if (createdAt is String) {
          final parsed = DateTime.tryParse(createdAt);
          if (parsed != null) return parsed;
        }
      }

      // Return null if no valid timestamp found (preserves nullable contract)
      return null;
    }

    /// Helper to safely parse integers from any type
    ///
    /// Handles int, double, string (with digit extraction)
    /// Tolerates strings like "123-Journeyman" by extracting numeric prefix
    /// SECURITY FIX: Validates positive integers to prevent overflow and invalid data
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value >= 0 ? value : null;
      if (value is double) return value >= 0 ? value.toInt() : null;
      if (value is String) {
        // First try direct parse
        final direct = int.tryParse(value.trim());
        if (direct != null && direct >= 0) return direct;

        // Extract leading digits from strings like "123-Local" or "123 Main St"
        // Only accept positive numbers (IBEW locals are numbered 1-9999)
        final match = RegExp(r'^\d+').firstMatch(value.trim());
        if (match != null) {
          final parsed = int.tryParse(match.group(0)!);
          if (parsed != null && parsed >= 0) return parsed;
        }
      }
      return null;
    }

    /// Helper to safely parse doubles from any type
    ///
    /// Removes common currency symbols and formatting
    /// Handles: "$45.50/hr", "45.50", 45.5, 45
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Remove common currency symbols and formatting
        String cleanValue = value
            .replaceAll(RegExp(r'[\$,]'), '')
            .replaceAll('/hr', '')
            .replaceAll('/hour', '')
            .trim();
        return double.tryParse(cleanValue);
      }
      return null;
    }

    /// Helper function to parse list of integers
    ///
    /// CRITICAL FIX: Filters out null/invalid values instead of converting to 0
    /// Prevents invalid data like "book 0" from entering the system
    List<int>? parseIntList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        // Filter out null values instead of converting to 0
        return value
            .map((e) => parseInt(e))
            .where((e) => e != null)
            .cast<int>()
            .toList();
      }
      return null;
    }

    // Helper to build jobDetails map
    Map<String, dynamic> buildJobDetails(Map<String, dynamic> json) {
      final details = <String, dynamic>{};
      details['hours'] = parseInt(json['hours']) ?? parseInt(json['Shift']);
      details['payRate'] =
          parseDouble(json['wage']) ?? parseDouble(json['hourlyWage']);
      details['perDiem'] =
          json['per_diem']?.toString() ??
          json['perDiem']?.toString() ??
          json['Benefits']?.toString();
      details['contractor'] =
          json['company']?.toString() ?? json['employer']?.toString() ?? '';
      // location as GeoPoint if available, else null
      // QUALITY FIX: Use null instead of GeoPoint(0,0) to avoid "Null Island" invalid data
      if (json['location'] is GeoPoint) {
        details['location'] = json['location'];
      } else {
        details['location'] = null; // Explicit null for missing GeoPoint
      }
      return details;
    }

    try {
      // Extract job title from ID if needed (format: "1249-Journeyman_Lineman-Company")
      String? extractedJobTitle = json['job_title']?.toString();
      String? extractedClassification = json['classification']?.toString();

      if (extractedJobTitle == null && json['id'] != null) {
        // Try to extract from ID
        final idParts = json['id'].toString().split('-');
        if (idParts.length >= 2) {
          extractedJobTitle = idParts[1]; // e.g., "Journeyman_Lineman"
        }
      }

      // Handle hours field which might contain certifications
      dynamic hoursValue = json['hours'];
      int? hoursInt;
      String? certifications;

      if (hoursValue != null) {
        // Check if it's a certification string like "CDL, fa/cpr"
        if (hoursValue is String && hoursValue.contains(',')) {
          certifications = hoursValue;
        } else {
          hoursInt = parseInt(hoursValue);
        }
      }

      final jobDetailsMap = buildJobDetails(json);

      // Schema-agnostic local/localNumber parsing
      // Try both fields, handle int/string/double, prefer local over localNumber
      final localValue =
          parseInt(json['local']) ?? parseInt(json['localNumber']);
      final localNumberValue =
          parseInt(json['localNumber']) ?? parseInt(json['local']);

      // Parse timestamp with fallback chain: timestamp → createdAt → epoch
      final parsedTimestamp = parseTimestamp(json['timestamp'], json);

      // Normalize typeOfWork to lowercase for consistent matching
      String? normalizedTypeOfWork =
          json['work_type']?.toString() ??
          json['typeOfWork']?.toString() ??
          json['Type of Work']?.toString();
      if (normalizedTypeOfWork != null) {
        normalizedTypeOfWork = normalizedTypeOfWork.toLowerCase().trim();
      }

      return Job(
        id: json['id']?.toString() ?? '',
        reference: json['reference'] as DocumentReference?,
        sharerId: json['sharerId']?.toString() ?? '',
        jobDetails: jobDetailsMap,
        matchesCriteria: json['matchesCriteria'] ?? false,
        // Robust deleted parsing: missing field = false, explicit true = true
        deleted: json['deleted'] == true,
        // Schema-agnostic local parsing (handles int/string/double)
        local: localValue,
        classification: extractedClassification ?? json['jobClass']?.toString(),
        company:
            json['company']?.toString() ?? json['employer']?.toString() ?? '',
        location:
            json['location']?.toString() ?? json['Location']?.toString() ?? '',
        hours: hoursInt ?? parseInt(json['Shift']),
        wage:
            jobDetailsMap['payRate'] ??
            parseDouble(json['wage']) ??
            parseDouble(json['hourlyWage']),
        sub: json['sub']?.toString(),
        jobClass: json['jobClass']?.toString() ?? certifications,
        // Schema-agnostic localNumber parsing (handles int/string/double)
        localNumber: localNumberValue,
        qualifications:
            json['qualifications']?.toString() ??
            json['certifications']?.toString() ??
            certifications,
        datePosted:
            json['date_posted']?.toString() ?? json['datePosted']?.toString(),
        jobDescription:
            json['description']?.toString() ??
            json['job_description']?.toString(),
        jobTitle: extractedJobTitle ?? json['title']?.toString(),
        perDiem:
            jobDetailsMap['perDiem'] ??
            json['per_diem']?.toString() ??
            json['perDiem']?.toString() ??
            json['Benefits']?.toString(),
        agreement: json['agreement']?.toString(),
        numberOfJobs:
            json['numberOfJobs']?.toString() ??
            json['positionsAvailable']?.toString() ??
            json['Men Needed']?.toString(),
        // Robust timestamp with fallback chain
        timestamp: parsedTimestamp,
        startDate:
            json['startDate']?.toString() ?? json['requestDate']?.toString(),
        startTime: json['startTime']?.toString(),
        booksYourOn: parseIntList(json['booksYourOn']),
        // Normalized typeOfWork for consistent lowercase matching
        typeOfWork: normalizedTypeOfWork,
        duration: json['duration']?.toString() ?? json['Duration']?.toString(),
        voltageLevel:
            json['voltageLevel']?.toString() ??
            json['voltage_level']?.toString(),
      );
    } catch (e, stackTrace) {
      // QUALITY FIX: Preserve stack trace for better debugging
      throw FormatException(
        'Failed to parse Job from JSON: $e\nStack trace: $stackTrace'
      );
    }
  }

  /// Converts this Job instance to a JSON map
  /// [useFirestoreTypes] - If true, converts DateTime to Timestamp for Firestore
  /// [includeNullValues] - If true, includes null values in the output map
  Map<String, dynamic> toJson({
    bool useFirestoreTypes = false,
    bool includeNullValues = false,
  }) {
    final Map<String, dynamic> data = {};

    // Helper function to add non-null values
    void addIfNotNull(String key, dynamic value) {
      if (includeNullValues || value != null) {
        data[key] = value;
      }
    }

    // Required fields (always included)
    data['id'] = id;
    data['sharerId'] = sharerId;
    data['jobDetails'] = jobDetails;
    data['matchesCriteria'] = matchesCriteria;
    data['company'] = company;
    data['location'] = location;

    // Handle reference field
    if (reference != null) {
      data['reference'] = reference;
    }

    // Handle DateTime fields based on output format
    if (timestamp != null) {
      if (useFirestoreTypes) {
        data['timestamp'] = Timestamp.fromDate(timestamp!);
      } else {
        data['timestamp'] = timestamp!.toIso8601String();
      }
    }

    data['deleted'] = deleted;

    // Optional fields
    addIfNotNull('local', local);
    addIfNotNull('classification', classification);
    addIfNotNull('hours', hours);
    addIfNotNull('wage', wage);
    addIfNotNull('sub', sub);
    addIfNotNull('jobClass', jobClass);
    addIfNotNull('localNumber', localNumber);
    addIfNotNull('qualifications', qualifications);
    addIfNotNull('date_posted', datePosted);
    addIfNotNull('job_description', jobDescription);
    addIfNotNull('job_title', jobTitle);
    addIfNotNull('per_diem', perDiem);
    addIfNotNull('agreement', agreement);
    addIfNotNull('numberOfJobs', numberOfJobs);
    addIfNotNull('startDate', startDate);
    addIfNotNull('startTime', startTime);
    addIfNotNull('booksYourOn', booksYourOn);
    addIfNotNull('typeOfWork', typeOfWork);
    addIfNotNull('duration', duration);
    addIfNotNull('voltageLevel', voltageLevel);

    return data;
  }

  /// Converts this Job instance to a Firestore-compatible map
  /// This is a convenience method that calls toJson with Firestore settings
  Map<String, dynamic> toFirestore() {
    return toJson(useFirestoreTypes: true, includeNullValues: false);
  }

  /// Creates a Job instance from a Firestore DocumentSnapshot
  /// This is a convenience factory that extracts data and adds the document ID
  factory Job.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id; // Ensure the document ID is included
    return Job.fromJson(data);
  }

  bool isValid() =>
      id.isNotEmpty && sharerId.isNotEmpty && jobDetails.isNotEmpty;

  @override
  String toString() {
    return 'Job('
        'id: $id, '
        'company: $company, '
        'location: $location, '
        'jobTitle: $jobTitle, '
        'local: $local, '
        'classification: $classification'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const ListEquality().equals;

    return other is Job &&
        other.id == id &&
        other.reference == reference &&
        other.deleted == deleted &&
        other.local == local &&
        other.classification == classification &&
        other.company == company &&
        other.location == location &&
        other.hours == hours &&
        other.wage == wage &&
        other.sub == sub &&
        other.jobClass == jobClass &&
        other.localNumber == localNumber &&
        other.qualifications == qualifications &&
        other.datePosted == datePosted &&
        other.jobDescription == jobDescription &&
        other.jobTitle == jobTitle &&
        other.perDiem == perDiem &&
        other.agreement == agreement &&
        other.numberOfJobs == numberOfJobs &&
        other.timestamp == timestamp &&
        other.startDate == startDate &&
        other.startTime == startTime &&
        listEquals(other.booksYourOn, booksYourOn) &&
        other.typeOfWork == typeOfWork &&
        other.duration == duration &&
        other.voltageLevel == voltageLevel;
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    reference,
    deleted,
    local,
    classification,
    company,
    location,
    hours,
    wage,
    sub,
    jobClass,
    localNumber,
    qualifications,
    datePosted,
    jobDescription,
    jobTitle,
    perDiem,
    agreement,
    numberOfJobs,
    timestamp,
    startDate,
    startTime,
    const ListEquality().hash(booksYourOn),
    typeOfWork,
    duration,
    voltageLevel,
  ]);
}
