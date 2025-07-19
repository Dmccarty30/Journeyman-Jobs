import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Model class representing a Job posting
/// Matches the backend JobsRecord schema
@immutable
class Job {
  // Document reference
  final String id;
  final DocumentReference? reference;
  
  // Core job fields
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
  factory Job.fromJson(Map<String, dynamic> json) {
    // Helper function to parse DateTime from various formats
    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        return DateTime.parse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      throw FormatException('Unable to parse DateTime from $value');
    }


    // Helper function to safely parse integers
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      if (value is double) {
        return value.toInt();
      }
      return null;
    }

    // Helper function to safely parse doubles
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



    // Helper function to parse list of integers
    List<int>? parseIntList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => parseInt(e) ?? 0).toList();
      }
      return null;
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
      
      return Job(
        id: json['id']?.toString() ?? '',
        reference: json['reference'] as DocumentReference?,
        local: parseInt(json['local']) ?? parseInt(json['localNumber']),
        classification: extractedClassification ?? json['jobClass']?.toString(),
        company: json['company']?.toString() ?? json['employer']?.toString() ?? '',
        location: json['location']?.toString() ?? json['Location']?.toString() ?? '',
        hours: hoursInt ?? parseInt(json['Shift']),
        wage: parseDouble(json['wage']) ?? parseDouble(json['hourlyWage']),
        sub: json['sub']?.toString(),
        jobClass: json['jobClass']?.toString() ?? certifications,
        localNumber: parseInt(json['localNumber']) ?? parseInt(json['local']),
        qualifications: json['qualifications']?.toString() ?? json['certifications']?.toString() ?? certifications,
        datePosted: json['date_posted']?.toString() ?? json['datePosted']?.toString(),
        jobDescription: json['description']?.toString() ?? json['job_description']?.toString(),
        jobTitle: extractedJobTitle ?? json['title']?.toString(),
        perDiem: json['per_diem']?.toString() ?? json['perDiem']?.toString() ?? json['Benefits']?.toString(),
        agreement: json['agreement']?.toString(),
        numberOfJobs: json['numberOfJobs']?.toString() ?? json['positionsAvailable']?.toString() ?? json['Men Needed']?.toString(),
        timestamp: json['timestamp'] != null ? parseDateTime(json['timestamp']) : null,
        startDate: json['startDate']?.toString() ?? json['requestDate']?.toString(),
        startTime: json['startTime']?.toString(),
        booksYourOn: parseIntList(json['booksYourOn']),
        typeOfWork: json['work_type']?.toString() ?? json['typeOfWork']?.toString() ?? json['Type of Work']?.toString(),
        duration: json['duration']?.toString() ?? json['Duration']?.toString(),
        voltageLevel: json['voltageLevel']?.toString() ?? json['voltage_level']?.toString(),
      );
    } catch (e) {
      throw FormatException('Failed to parse Job from JSON: $e');
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
