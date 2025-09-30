import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class JobsRecord {
  final String id;
  final String company;
  final String location;
  final String classification;
  final int? hours;
  final double? wage;
  final String? jobTitle;
  final DateTime? timestamp;
  final String? startDate;
  final String? jobDescription;
  final String? qualifications;
  final String? perDiem;
  final String? typeOfWork;
  final String? duration;
  final String? voltageLevel;
  final int? localNumber;
  final List<String>? certifications;
  final bool deleted;

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

  Map<String, dynamic> toFirestore() => toJson(useFirestoreTypes: true);

  factory JobsRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['id'] = doc.id;
    return JobsRecord.fromJson(data);
  }

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
