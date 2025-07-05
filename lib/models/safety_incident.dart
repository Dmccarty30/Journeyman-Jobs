import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Enumeration for different types of electrical safety incidents
enum IncidentType {
  electrical('Electrical'),
  arcFlash('Arc Flash'),
  shock('Electrical Shock'),
  fire('Electrical Fire'),
  equipment('Equipment Failure'),
  lockout('Lockout/Tagout'),
  ppe('PPE Related'),
  nearMiss('Near Miss'),
  other('Other');

  const IncidentType(this.displayName);
  final String displayName;
}

/// Enumeration for incident severity levels
enum IncidentSeverity {
  low('Low', 'Minor incident, no injury'),
  medium('Medium', 'Moderate incident, minor injury'),
  high('High', 'Serious incident, injury requiring treatment'),
  critical('Critical', 'Life-threatening incident');

  const IncidentSeverity(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Enumeration for voltage levels involved in incidents
enum VoltageLevel {
  lowVoltage('Low Voltage', '50-1000V AC, 120-1500V DC'),
  mediumVoltage('Medium Voltage', '1-35kV'),
  highVoltage('High Voltage', '35-138kV'),
  extraHighVoltage('Extra High Voltage', '138kV+');

  const VoltageLevel(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Model class representing a safety incident report
@immutable
class SafetyIncident {
  final String id;
  final String reporterName;
  final String reporterEmail;
  final DateTime incidentDate;
  final String location;
  final IncidentType type;
  final IncidentSeverity severity;
  final VoltageLevel? voltageLevel;
  final String description;
  final String immediateActions;
  final List<String> equipmentInvolved;
  final List<String> witnessNames;
  final bool injuryOccurred;
  final String? injuryDetails;
  final String? correctiveActions;
  final DateTime reportedDate;
  final String? photoUrls; // Comma-separated URLs
  final String reportId; // Unique report identifier
  final bool isResolved;
  final DateTime? resolvedDate;
  final String? resolvedBy;
  final DocumentReference? reference;

  const SafetyIncident({
    required this.id,
    required this.reporterName,
    required this.reporterEmail,
    required this.incidentDate,
    required this.location,
    required this.type,
    required this.severity,
    this.voltageLevel,
    required this.description,
    required this.immediateActions,
    this.equipmentInvolved = const [],
    this.witnessNames = const [],
    this.injuryOccurred = false,
    this.injuryDetails,
    this.correctiveActions,
    required this.reportedDate,
    this.photoUrls,
    required this.reportId,
    this.isResolved = false,
    this.resolvedDate,
    this.resolvedBy,
    this.reference,
  });

  /// Creates a copy of this SafetyIncident with the given fields replaced
  SafetyIncident copyWith({
    String? id,
    String? reporterName,
    String? reporterEmail,
    DateTime? incidentDate,
    String? location,
    IncidentType? type,
    IncidentSeverity? severity,
    VoltageLevel? voltageLevel,
    String? description,
    String? immediateActions,
    List<String>? equipmentInvolved,
    List<String>? witnessNames,
    bool? injuryOccurred,
    String? injuryDetails,
    String? correctiveActions,
    DateTime? reportedDate,
    String? photoUrls,
    String? reportId,
    bool? isResolved,
    DateTime? resolvedDate,
    String? resolvedBy,
    DocumentReference? reference,
  }) {
    return SafetyIncident(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      incidentDate: incidentDate ?? this.incidentDate,
      location: location ?? this.location,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      voltageLevel: voltageLevel ?? this.voltageLevel,
      description: description ?? this.description,
      immediateActions: immediateActions ?? this.immediateActions,
      equipmentInvolved: equipmentInvolved ?? this.equipmentInvolved,
      witnessNames: witnessNames ?? this.witnessNames,
      injuryOccurred: injuryOccurred ?? this.injuryOccurred,
      injuryDetails: injuryDetails ?? this.injuryDetails,
      correctiveActions: correctiveActions ?? this.correctiveActions,
      reportedDate: reportedDate ?? this.reportedDate,
      photoUrls: photoUrls ?? this.photoUrls,
      reportId: reportId ?? this.reportId,
      isResolved: isResolved ?? this.isResolved,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      reference: reference ?? this.reference,
    );
  }

  /// Creates a SafetyIncident instance from a JSON map
  factory SafetyIncident.fromJson(Map<String, dynamic> json) {
    // Helper function to parse DateTime from various formats
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      throw FormatException('Unable to parse DateTime from $value');
    }

    // Helper function to parse string lists
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) return value.split(',').map((e) => e.trim()).toList();
      return [];
    }

    // Helper function to parse enums
    T parseEnum<T extends Enum>(List<T> values, dynamic value, T defaultValue) {
      if (value == null) return defaultValue;
      final stringValue = value.toString();
      return values.firstWhere(
        (e) => e.name == stringValue,
        orElse: () => defaultValue,
      );
    }

    try {
      return SafetyIncident(
        id: json['id']?.toString() ?? '',
        reporterName: json['reporterName']?.toString() ?? '',
        reporterEmail: json['reporterEmail']?.toString() ?? '',
        incidentDate: parseDateTime(json['incidentDate']),
        location: json['location']?.toString() ?? '',
        type: parseEnum(IncidentType.values, json['type'], IncidentType.other),
        severity: parseEnum(IncidentSeverity.values, json['severity'], IncidentSeverity.low),
        voltageLevel: json['voltageLevel'] != null 
            ? parseEnum(VoltageLevel.values, json['voltageLevel'], VoltageLevel.lowVoltage)
            : null,
        description: json['description']?.toString() ?? '',
        immediateActions: json['immediateActions']?.toString() ?? '',
        equipmentInvolved: parseStringList(json['equipmentInvolved']),
        witnessNames: parseStringList(json['witnessNames']),
        injuryOccurred: json['injuryOccurred'] == true,
        injuryDetails: json['injuryDetails']?.toString(),
        correctiveActions: json['correctiveActions']?.toString(),
        reportedDate: parseDateTime(json['reportedDate']),
        photoUrls: json['photoUrls']?.toString(),
        reportId: json['reportId']?.toString() ?? '',
        isResolved: json['isResolved'] == true,
        resolvedDate: json['resolvedDate'] != null ? parseDateTime(json['resolvedDate']) : null,
        resolvedBy: json['resolvedBy']?.toString(),
        reference: json['reference'] as DocumentReference?,
      );
    } catch (e) {
      throw FormatException('Failed to parse SafetyIncident from JSON: $e');
    }
  }

  /// Converts this SafetyIncident instance to a JSON map
  Map<String, dynamic> toJson({bool useFirestoreTypes = false}) {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['reporterName'] = reporterName;
    data['reporterEmail'] = reporterEmail;
    data['location'] = location;
    data['type'] = type.name;
    data['severity'] = severity.name;
    data['voltageLevel'] = voltageLevel?.name;
    data['description'] = description;
    data['immediateActions'] = immediateActions;
    data['equipmentInvolved'] = equipmentInvolved;
    data['witnessNames'] = witnessNames;
    data['injuryOccurred'] = injuryOccurred;
    data['injuryDetails'] = injuryDetails;
    data['correctiveActions'] = correctiveActions;
    data['photoUrls'] = photoUrls;
    data['reportId'] = reportId;
    data['isResolved'] = isResolved;
    data['resolvedBy'] = resolvedBy;

    // Handle DateTime fields based on output format
    if (useFirestoreTypes) {
      data['incidentDate'] = Timestamp.fromDate(incidentDate);
      data['reportedDate'] = Timestamp.fromDate(reportedDate);
      if (resolvedDate != null) {
        data['resolvedDate'] = Timestamp.fromDate(resolvedDate!);
      }
    } else {
      data['incidentDate'] = incidentDate.toIso8601String();
      data['reportedDate'] = reportedDate.toIso8601String();
      data['resolvedDate'] = resolvedDate?.toIso8601String();
    }

    if (reference != null) {
      data['reference'] = reference;
    }

    return data;
  }

  /// Converts this SafetyIncident to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return toJson(useFirestoreTypes: true);
  }

  /// Creates a SafetyIncident instance from a Firestore DocumentSnapshot
  factory SafetyIncident.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id;
    return SafetyIncident.fromJson(data);
  }

  @override
  String toString() {
    return 'SafetyIncident('
        'id: $id, '
        'reportId: $reportId, '
        'type: ${type.displayName}, '
        'severity: ${severity.displayName}, '
        'location: $location'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SafetyIncident && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
