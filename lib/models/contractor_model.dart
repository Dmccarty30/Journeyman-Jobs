import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model representing a storm work contractor.
///
/// This class encapsulates the details of a contracting company, including contact
/// information and instructions for how electrical workers can sign up for storm
/// restoration jobs.
class Contractor {
  /// The unique identifier for the contractor, typically the Firestore document ID.
  final String id;
  /// The legal name of the contracting company.
  final String company;
  /// Instructions for electrical workers on how to register or apply.
  final String howToSignup;
  /// The primary contact phone number for the contractor.
  final String? phoneNumber;
  /// The primary contact email address for the contractor.
  final String? email;
  /// The official website of the contractor.
  final String? website;
  /// The timestamp when the contractor record was created.
  final DateTime createdAt;

  /// Creates an instance of the [Contractor] model.
  Contractor({
    required this.id,
    required this.company,
    required this.howToSignup,
    this.phoneNumber,
    this.email,
    this.website,
    required this.createdAt,
  });

  /// Creates a [Contractor] instance from a JSON map.
  ///
  /// This factory constructor can handle variations in key casing (e.g., 'COMPANY' vs 'company')
  /// and correctly parses `Timestamp` or `String` date formats.
  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'] ?? '',
      company: json['COMPANY'] ?? json['company'] ?? '',
      howToSignup: json['HOW TO SIGNUP'] ?? json['howToSignup'] ?? '',
      phoneNumber: json['PHONE NUMBER'] ?? json['phoneNumber'],
      email: json['EMAIL'] ?? json['email'],
      website: json['WEBSITE'] ?? json['website'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt']))
          : DateTime.now(),
    );
  }

  /// Converts the [Contractor] instance into a JSON-encodable map.
  ///
  /// Dates are converted to ISO 8601 string format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'howToSignup': howToSignup,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts the [Contractor] instance into a map format suitable for Cloud Firestore.
  ///
  /// Dates are converted to Firestore `Timestamp` objects.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'company': company,
      'howToSignup': howToSignup,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a new instance of [Contractor] with updated field values.
  Contractor copyWith({
    String? id,
    String? company,
    String? howToSignup,
    String? phoneNumber,
    String? email,
    String? website,
    DateTime? createdAt,
  }) {
    return Contractor(
      id: id ?? this.id,
      company: company ?? this.company,
      howToSignup: howToSignup ?? this.howToSignup,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Contractor(id: $id, company: $company, howToSignup: $howToSignup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contractor &&
        other.id == id &&
        other.company == company &&
        other.howToSignup == howToSignup &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.website == website;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        company.hashCode ^
        howToSignup.hashCode ^
        (phoneNumber?.hashCode ?? 0) ^
        (email?.hashCode ?? 0) ^
        (website?.hashCode ?? 0);
  }
}