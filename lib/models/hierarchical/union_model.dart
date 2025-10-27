import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import '../user_model.dart';

/// Represents a complete IBEW Union in the hierarchical data structure
///
/// A Union represents the highest level in the IBEW hierarchy:
/// Union → Local → Members → Jobs
///
/// Each union contains multiple locals and serves as the primary
/// organizational unit for IBEW electrical workers.
@immutable
class Union {
  /// Unique identifier for the union
  final String id;

  /// Union name (e.g., "International Brotherhood of Electrical Workers")
  final String name;

  /// Union abbreviation (e.g., "IBEW")
  final String abbreviation;

  /// Union type (e.g., "International", "District", "Local")
  final String type;

  /// Geographic jurisdiction (e.g., "North America", "United States")
  final String jurisdiction;

  /// Number of locals under this union
  final int localCount;

  /// Total membership across all locals
  final int totalMembership;

  /// Union headquarters location
  final String headquartersLocation;

  /// Union contact information
  final String contactEmail;
  final String contactPhone;
  final String? website;

  /// Union establishment date
  final DateTime foundedDate;

  /// Active status of the union
  final bool isActive;

  /// Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Firestore document reference
  final DocumentReference? reference;

  /// Raw document data for flexibility
  final Map<String, dynamic>? rawData;

  const Union({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.type,
    required this.jurisdiction,
    required this.localCount,
    required this.totalMembership,
    required this.headquartersLocation,
    required this.contactEmail,
    required this.contactPhone,
    this.website,
    required this.foundedDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.reference,
    this.rawData,
  });

  /// Creates a Union from a Firestore DocumentSnapshot
  factory Union.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Union(
      id: doc.id,
      name: data['name'] ?? '',
      abbreviation: data['abbreviation'] ?? '',
      type: data['type'] ?? 'International',
      jurisdiction: data['jurisdiction'] ?? '',
      localCount: data['localCount'] ?? 0,
      totalMembership: data['totalMembership'] ?? 0,
      headquartersLocation: data['headquartersLocation'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      website: data['website'],
      foundedDate: (data['foundedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reference: doc.reference,
      rawData: data,
    );
  }

  /// Creates a Union from JSON data
  factory Union.fromJson(Map<String, dynamic> json) {
    return Union(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      type: json['type'] ?? 'International',
      jurisdiction: json['jurisdiction'] ?? '',
      localCount: json['localCount'] ?? 0,
      totalMembership: json['totalMembership'] ?? 0,
      headquartersLocation: json['headquartersLocation'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      website: json['website'],
      foundedDate: DateTime.parse(json['foundedDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      rawData: json,
    );
  }

  /// Converts Union to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'type': type,
      'jurisdiction': jurisdiction,
      'localCount': localCount,
      'totalMembership': totalMembership,
      'headquartersLocation': headquartersLocation,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'foundedDate': foundedDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts Union to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'abbreviation': abbreviation,
      'type': type,
      'jurisdiction': jurisdiction,
      'localCount': localCount,
      'totalMembership': totalMembership,
      'headquartersLocation': headquartersLocation,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'foundedDate': Timestamp.fromDate(foundedDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy of this Union with updated fields
  Union copyWith({
    String? id,
    String? name,
    String? abbreviation,
    String? type,
    String? jurisdiction,
    int? localCount,
    int? totalMembership,
    String? headquartersLocation,
    String? contactEmail,
    String? contactPhone,
    String? website,
    DateTime? foundedDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DocumentReference? reference,
    Map<String, dynamic>? rawData,
  }) {
    return Union(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      type: type ?? this.type,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      localCount: localCount ?? this.localCount,
      totalMembership: totalMembership ?? this.totalMembership,
      headquartersLocation: headquartersLocation ?? this.headquartersLocation,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      foundedDate: foundedDate ?? this.foundedDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reference: reference ?? this.reference,
      rawData: rawData ?? this.rawData,
    );
  }

  /// Validates if the union data is complete and valid
  bool isValid() {
    return id.isNotEmpty &&
           name.isNotEmpty &&
           abbreviation.isNotEmpty &&
           contactEmail.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Union && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Union(id: $id, name: $name, abbreviation: $abbreviation, localCount: $localCount)';
  }
}

/// Represents a member within a local union
///
/// A Member represents an individual electrical worker who belongs to a specific local.
/// This model bridges the gap between UserModel and the hierarchical structure.
@immutable
class UnionMember {
  /// User ID from Firebase Auth
  final String userId;

  /// Local union number this member belongs to
  final int localNumber;

  /// Member's full name
  final String fullName;

  /// IBEW classification
  final String classification;

  /// Journeyman ticket number
  final String ticketNumber;

  /// Member status (active, retired, apprentice, etc.)
  final String status;

  /// Member join date
  final DateTime joinDate;

  /// Member's work status (working, available, etc.)
  final bool isWorking;

  /// Contact information
  final String email;
  final String phoneNumber;

  /// Member's current location
  final String location;

  /// Skills and certifications
  final List<String> skills;
  final List<String> certifications;

  /// Years of experience
  final int yearsExperience;

  /// Whether member is available for work
  final bool isAvailable;

  /// Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Firestore document reference
  final DocumentReference? reference;

  /// Raw document data
  final Map<String, dynamic>? rawData;

  const UnionMember({
    required this.userId,
    required this.localNumber,
    required this.fullName,
    required this.classification,
    required this.ticketNumber,
    this.status = 'active',
    required this.joinDate,
    this.isWorking = false,
    required this.email,
    required this.phoneNumber,
    required this.location,
    this.skills = const [],
    this.certifications = const [],
    this.yearsExperience = 0,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.reference,
    this.rawData,
  });

  /// Creates a UnionMember from a Firestore DocumentSnapshot
  factory UnionMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UnionMember(
      userId: doc.id,
      localNumber: data['localNumber'] ?? 0,
      fullName: data['fullName'] ?? '',
      classification: data['classification'] ?? '',
      ticketNumber: data['ticketNumber'] ?? '',
      status: data['status'] ?? 'active',
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isWorking: data['isWorking'] ?? false,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      yearsExperience: data['yearsExperience'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reference: doc.reference,
      rawData: data,
    );
  }

  /// Creates a UnionMember from a UserModel
  factory UnionMember.fromUserModel(UserModel user) {
    final now = DateTime.now();
    return UnionMember(
      userId: user.uid,
      localNumber: user.homeLocal,
      fullName: user.displayNameStr,
      classification: user.classification,
      ticketNumber: user.ticketNumber,
      status: 'active',
      joinDate: user.createdTime ?? now,
      isWorking: user.isWorking,
      email: user.email,
      phoneNumber: user.phoneNumber,
      location: '${user.city}, ${user.state}',
      skills: user.constructionTypes,
      certifications: user.certifications,
      yearsExperience: user.yearsExperience,
      isAvailable: !user.isWorking,
      createdAt: user.createdTime ?? now,
      updatedAt: now,
    );
  }

  /// Creates a UnionMember from JSON data
  factory UnionMember.fromJson(Map<String, dynamic> json) {
    return UnionMember(
      userId: json['userId'] ?? '',
      localNumber: json['localNumber'] ?? 0,
      fullName: json['fullName'] ?? '',
      classification: json['classification'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
      status: json['status'] ?? 'active',
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      isWorking: json['isWorking'] ?? false,
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      location: json['location'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      yearsExperience: json['yearsExperience'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      rawData: json,
    );
  }

  /// Converts UnionMember to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'localNumber': localNumber,
      'fullName': fullName,
      'classification': classification,
      'ticketNumber': ticketNumber,
      'status': status,
      'joinDate': joinDate.toIso8601String(),
      'isWorking': isWorking,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'skills': skills,
      'certifications': certifications,
      'yearsExperience': yearsExperience,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts UnionMember to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      'localNumber': localNumber,
      'fullName': fullName,
      'classification': classification,
      'ticketNumber': ticketNumber,
      'status': status,
      'joinDate': Timestamp.fromDate(joinDate),
      'isWorking': isWorking,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'skills': skills,
      'certifications': certifications,
      'yearsExperience': yearsExperience,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy of this UnionMember with updated fields
  UnionMember copyWith({
    String? userId,
    int? localNumber,
    String? fullName,
    String? classification,
    String? ticketNumber,
    String? status,
    DateTime? joinDate,
    bool? isWorking,
    String? email,
    String? phoneNumber,
    String? location,
    List<String>? skills,
    List<String>? certifications,
    int? yearsExperience,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    DocumentReference? reference,
    Map<String, dynamic>? rawData,
  }) {
    return UnionMember(
      userId: userId ?? this.userId,
      localNumber: localNumber ?? this.localNumber,
      fullName: fullName ?? this.fullName,
      classification: classification ?? this.classification,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      isWorking: isWorking ?? this.isWorking,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reference: reference ?? this.reference,
      rawData: rawData ?? this.rawData,
    );
  }

  /// Validates if the member data is complete and valid
  bool isValid() {
    return userId.isNotEmpty &&
           localNumber > 0 &&
           fullName.isNotEmpty &&
           classification.isNotEmpty &&
           email.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnionMember && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UnionMember(userId: $userId, localNumber: $localNumber, fullName: $fullName, classification: $classification)';
  }
}