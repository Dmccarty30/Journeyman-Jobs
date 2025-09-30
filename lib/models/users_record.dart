import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class UsersRecord {
  final String uid;
  final String email;
  final String displayName;
  final String? localNumber;
  final List<String>? certifications;
  final int? yearsExperience;
  final double? preferredDistance;
  final bool isActive;
  final DateTime? createdTime;

  const UsersRecord({
    required this.uid,
    required this.email,
    required this.displayName,
    this.localNumber,
    this.certifications,
    this.yearsExperience,
    this.preferredDistance,
    this.isActive = true,
    this.createdTime,
  });

  UsersRecord copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? localNumber,
    List<String>? certifications,
    int? yearsExperience,
    double? preferredDistance,
    bool? isActive,
    DateTime? createdTime,
  }) {
    return UsersRecord(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      localNumber: localNumber ?? this.localNumber,
      certifications: certifications ?? this.certifications,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      preferredDistance: preferredDistance ?? this.preferredDistance,
      isActive: isActive ?? this.isActive,
      createdTime: createdTime ?? this.createdTime,
    );
  }

  factory UsersRecord.fromJson(Map<String, dynamic> json) {
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
      if (value is String) return double.tryParse(value);
      return null;
    }

    List<String>? parseCertifications(dynamic value) {
      if (value == null) return null;
      if (value is List) return value.cast<String>().where((s) => s.isNotEmpty).toList();
      if (value is String) return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return null;
    }

    try {
      return UsersRecord(
        uid: json['uid']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        displayName: json['displayName']?.toString() ?? '',
        localNumber: json['localNumber']?.toString(),
        certifications: parseCertifications(json['certifications']),
        yearsExperience: parseInt(json['yearsExperience']),
        preferredDistance: parseDouble(json['preferredDistance']),
        isActive: json['isActive'] ?? true,
        createdTime: parseDateTime(json['createdTime']),
      );
    } catch (e) {
      throw FormatException('Failed to parse UsersRecord from JSON: $e');
    }
  }

  Map<String, dynamic> toJson({bool useFirestoreTypes = false}) {
    final Map<String, dynamic> data = {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'localNumber': localNumber,
      'certifications': certifications,
      'yearsExperience': yearsExperience,
      'preferredDistance': preferredDistance,
      'isActive': isActive,
    };

    if (createdTime != null) {
      data['createdTime'] = useFirestoreTypes ? Timestamp.fromDate(createdTime!) : createdTime!.toIso8601String();
    }

    return data;
  }

  Map<String, dynamic> toFirestore() => toJson(useFirestoreTypes: true);

  factory UsersRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['uid'] = doc.id;
    return UsersRecord.fromJson(data);
  }

  bool get isValid => uid.isNotEmpty && email.isNotEmpty && displayName.isNotEmpty;

  @override
  String toString() => 'UsersRecord(uid: $uid, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsersRecord &&
      runtimeType == other.runtimeType &&
      uid == other.uid &&
      email == other.email &&
      displayName == other.displayName &&
      localNumber == other.localNumber &&
      certifications == other.certifications &&
      yearsExperience == other.yearsExperience &&
      preferredDistance == other.preferredDistance &&
      isActive == other.isActive &&
      createdTime == other.createdTime;

  @override
  int get hashCode => Object.hash(
    uid, email, displayName, localNumber, certifications, yearsExperience,
    preferredDistance, isActive, createdTime,
  );
}
