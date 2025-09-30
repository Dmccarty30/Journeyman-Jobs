import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a storm work contractor
class Contractor {
  final String id;
  final String company;
  final String howToSignup;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final DateTime createdAt;

  Contractor({
    required this.id,
    required this.company,
    required this.howToSignup,
    this.phoneNumber,
    this.email,
    this.website,
    required this.createdAt,
  });

  /// Creates a Contractor from JSON data
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

  /// Converts Contractor to JSON
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

  /// Converts Contractor to Firestore format
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

  /// Creates a copy of this Contractor with updated fields
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