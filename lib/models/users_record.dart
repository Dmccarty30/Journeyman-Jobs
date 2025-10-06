import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// An immutable data model representing a summarized user record from Firestore.
///
/// This class is a lightweight alternative to the more comprehensive [UserModel],
/// often used for displaying user information in lists or summaries where not all
/// profile details are needed.
@immutable
class UsersRecord {
  /// The unique identifier for the user.
  final String uid;
  /// The user's email address.
  final String email;
  /// The user's display name.
  final String displayName;
  /// The user's IBEW local union number.
  final String? localNumber;
  /// A list of the user's professional certifications.
  final List<String>? certifications;
  /// The user's years of experience in their trade.
  final int? yearsExperience;
  /// The maximum distance the user is willing to travel for work, in miles.
  final double? preferredDistance;
  /// A flag indicating if the user's account is active.
  final bool isActive;
  /// The timestamp when the user account was created.
  final DateTime? createdTime;

  /// Creates an instance of [UsersRecord].
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

  /// Creates a new [UsersRecord] instance with updated field values.
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

  /// Creates a [UsersRecord] instance from a JSON map.
  ///
  /// Includes robust parsing for various data types.
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

  /// Serializes the [UsersRecord] instance to a JSON map.
  ///
  /// - [useFirestoreTypes]: If `true`, converts `DateTime` to Firestore `Timestamp`.
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

  /// A convenience method that converts the instance to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() => toJson(useFirestoreTypes: true);

  /// Creates a [UsersRecord] instance from a Firestore [DocumentSnapshot].
  factory UsersRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['uid'] = doc.id;
    return UsersRecord.fromJson(data);
  }

  /// Checks if the record has the minimum required data to be considered valid.
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
