import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// An immutable data model representing a single job record from Firestore.
///
/// This class provides a clean, type-safe representation of a job document,
/// suitable for use throughout the application. It is distinct from the more
/// complex `Job` model and serves as a direct mapping to the `jobs` collection schema.
@immutable
class JobsRecord {
  /// The unique identifier for the job record (document ID).
  final String id;
  /// The name of the company offering the job.
  final String company;
  /// The geographic location of the job.
  final String location;
  /// The IBEW classification for the job (e.g., 'Journeyman Lineman').
  final String classification;
  /// The expected hours per shift or week.
  final int? hours;
  /// The hourly wage for the job.
  final double? wage;
  /// The official title of the job.
  final String? jobTitle;
  /// The timestamp when the record was created or last updated.
  final DateTime? timestamp;
  /// The expected start date of the job.
  final String? startDate;
  /// A detailed description of the job's duties and responsibilities.
  final String? jobDescription;
  /// A summary of the required qualifications.
  final String? qualifications;
  /// Information on per diem payments, if available.
  final String? perDiem;
  /// The type of work involved (e.g., 'Transmission', 'Distribution').
  final String? typeOfWork;
  /// The expected duration of the job.
  final String? duration;
  /// The voltage level of the work (e.g., 'High Voltage').
  final String? voltageLevel;
  /// The IBEW local union number associated with the job.
  final int? localNumber;
  /// A list of required certifications (e.g., 'CDL', 'First Aid').
  final List<String>? certifications;
  /// A flag for soft-deleting the job record.
  final bool deleted;

  /// Creates an instance of [JobsRecord].
  const JobsRecord({
    required this.id,
    required this.company,
    required this.location,
    required this.classification,
    this.hours,
    this.wage,
    this.jobTitle,
    this.timestamp,
    this.startDate,
    this.jobDescription,
    this.qualifications,
    this.perDiem,
    this.typeOfWork,
    this.duration,
    this.voltageLevel,
    this.localNumber,
    this.certifications,
    this.deleted = false,
  });

  /// Creates a new [JobsRecord] instance with updated field values.
  JobsRecord copyWith({
    String? id,
    String? company,
    String? location,
    String? classification,
    int? hours,
    double? wage,
    String? jobTitle,
    DateTime? timestamp,
    String? startDate,
    String? jobDescription,
    String? qualifications,
    String? perDiem,
    String? typeOfWork,
    String? duration,
    String? voltageLevel,
    int? localNumber,
    List<String>? certifications,
    bool? deleted,
  }) {
    return JobsRecord(
      id: id ?? this.id,
      company: company ?? this.company,
      location: location ?? this.location,
      classification: classification ?? this.classification,
      hours: hours ?? this.hours,
      wage: wage ?? this.wage,
      jobTitle: jobTitle ?? this.jobTitle,
      timestamp: timestamp ?? this.timestamp,
      startDate: startDate ?? this.startDate,
      jobDescription: jobDescription ?? this.jobDescription,
      qualifications: qualifications ?? this.qualifications,
      perDiem: perDiem ?? this.perDiem,
      typeOfWork: typeOfWork ?? this.typeOfWork,
      duration: duration ?? this.duration,
      voltageLevel: voltageLevel ?? this.voltageLevel,
      localNumber: localNumber ?? this.localNumber,
      certifications: certifications ?? this.certifications,
      deleted: deleted ?? this.deleted,
    );
  }

  /// Creates a [JobsRecord] instance from a JSON map.
  ///
  /// This factory includes robust parsing logic to handle various data types
  /// that might be received from Firestore or other JSON sources.
  factory JobsRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final clean = value.replaceAll(RegExp(r'[\$,]'), '').trim();
        return double.tryParse(clean);
      }
      return null;
    }

    List<String>? parseCertifications(dynamic value) {
      if (value == null) return null;
      if (value is List) return value.cast<String>().toList();
      if (value is String) return value.split(',').map((s) => s.trim()).toList();
      return null;
    }

    try {
      return JobsRecord(
        id: json['id']?.toString() ?? '',
        company: json['company']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        classification: json['classification']?.toString() ?? '',
        hours: parseInt(json['hours']),
        wage: parseDouble(json['wage']),
        jobTitle: json['jobTitle']?.toString(),
        timestamp: parseDateTime(json['timestamp']),
        startDate: json['startDate']?.toString(),
        jobDescription: json['jobDescription']?.toString(),
        qualifications: json['qualifications']?.toString(),
        perDiem: json['perDiem']?.toString(),
        typeOfWork: json['typeOfWork']?.toString(),
        duration: json['duration']?.toString(),
        voltageLevel: json['voltageLevel']?.toString(),
        localNumber: parseInt(json['localNumber']),
        certifications: parseCertifications(json['certifications']),
        deleted: json['deleted'] ?? false,
      );
    } catch (e) {
      throw FormatException('Failed to parse JobsRecord from JSON: $e');
    }
  }

  /// Serializes the [JobsRecord] instance to a JSON map.
  ///
  /// - [useFirestoreTypes]: If `true`, `DateTime` objects are converted to
  ///   Firestore `Timestamp` objects. Otherwise, they are converted to
  ///   ISO 8601 strings.
  Map<String, dynamic> toJson({bool useFirestoreTypes = false}) {
    final Map<String, dynamic> data = {
      'id': id,
      'company': company,
      'location': location,
      'classification': classification,
      'hours': hours,
      'wage': wage,
      'jobTitle': jobTitle,
      'startDate': startDate,
      'jobDescription': jobDescription,
      'qualifications': qualifications,
      'perDiem': perDiem,
      'typeOfWork': typeOfWork,
      'duration': duration,
      'voltageLevel': voltageLevel,
      'localNumber': localNumber,
      'certifications': certifications,
      'deleted': deleted,
    };

    if (timestamp != null) {
      data['timestamp'] = useFirestoreTypes ? Timestamp.fromDate(timestamp!) : timestamp!.toIso8601String();
    }

    return data;
  }

  /// A convenience method that converts the instance to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => toJson(useFirestoreTypes: true);

  /// Creates a [JobsRecord] instance from a Firestore [DocumentSnapshot].
  factory JobsRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['id'] = doc.id;
    return JobsRecord.fromJson(data);
  }

  /// A quick check to determine if the record has the essential required data.
  bool get isValid => id.isNotEmpty && company.isNotEmpty && location.isNotEmpty;

  @override
  String toString() => 'JobsRecord(id: $id, company: $company)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobsRecord &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      company == other.company &&
      location == other.location &&
      classification == other.classification &&
      hours == other.hours &&
      wage == other.wage &&
      jobTitle == other.jobTitle &&
      timestamp == other.timestamp &&
      startDate == other.startDate &&
      jobDescription == other.jobDescription &&
      qualifications == other.qualifications &&
      perDiem == other.perDiem &&
      typeOfWork == other.typeOfWork &&
      duration == other.duration &&
      voltageLevel == other.voltageLevel &&
      localNumber == other.localNumber &&
      certifications == other.certifications &&
      deleted == other.deleted;

  @override
  int get hashCode => Object.hash(
    id, company, location, classification, hours, wage, jobTitle, timestamp,
    startDate, jobDescription, qualifications, perDiem, typeOfWork, duration,
    voltageLevel, localNumber, certifications, deleted,
  );
}
