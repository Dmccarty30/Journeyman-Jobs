import 'package:cloud_firestore/cloud_firestore.dart';

/// A data model representing an IBEW (International Brotherhood of Electrical Workers)
/// local union.
///
/// This class encapsulates all the relevant details for a local union hall,
/// including contact information, location, and specialties.
class LocalsRecord {
  /// The unique identifier for the local union, typically the Firestore document ID.
  final String id;
  /// The official number of the IBEW local (e.g., "124").
  final String localNumber;
  /// The official name of the local union (e.g., "Chicago Electrical Workers").
  final String localName;
  /// The primary job classification associated with this local.
  final String? classification;
  /// A formatted string of the local's primary location (e.g., "Chicago, IL").
  final String location;
  /// The full street address of the local union's office.
  final String? address;
  /// The primary contact email address for the local.
  final String contactEmail;
  /// The primary contact phone number for the local.
  final String contactPhone;
  /// The official website URL of the local union.
  final String? website;
  /// The approximate number of members in the local union.
  final int memberCount;
  /// A list of work specialties covered by this local (e.g., 'Commercial', 'Solar').
  final List<String> specialties;
  /// A flag indicating whether the local union record is active.
  final bool isActive;
  /// The timestamp when the record was created.
  final DateTime createdAt;
  /// The timestamp when the record was last updated.
  final DateTime updatedAt;
  /// The direct Firestore reference to the document.
  final DocumentReference? reference;
  /// A map containing the raw, unprocessed data from the Firestore document.
  final Map<String, dynamic>? rawData;

  /// Creates an instance of [LocalsRecord].
  const LocalsRecord({
    required this.id,
    required this.localNumber,
    required this.localName,
    this.classification,
    required this.location,
    this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.website,
    required this.memberCount,
    required this.specialties,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.reference,
    this.rawData,
  });

  /// An alias for [localNumber] for compatibility with different data schemas.
  String get localUnion => localNumber;
  /// An alias for [contactPhone].
  String get phone => contactPhone;
  /// An alias for [contactEmail].
  String get email => contactEmail;
  
  /// Extracts the city part from the [location] string.
  String get city {
    final parts = location.split(', ');
    return parts.isNotEmpty ? parts[0] : '';
  }
  
  /// Extracts the state part from the [location] string.
  String get state {
    final parts = location.split(', ');
    return parts.length > 1 ? parts[1] : '';
  }
  
  /// An alias for [rawData].
  Map<String, dynamic>? get data => rawData;

  /// Creates a [LocalsRecord] instance from a Firestore [DocumentSnapshot].
  ///
  /// This factory is responsible for parsing the raw data from Firestore,
  /// including handling `Timestamp` objects and constructing the `location` string.
  factory LocalsRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Build location from city and state
    final city = data['city'] ?? '';
    final state = data['state'] ?? '';
    final location = city.isNotEmpty && state.isNotEmpty ? '$city, $state' : '';
    
    return LocalsRecord(
      id: doc.id,
      localNumber: data['local_union']?.toString() ?? '',
      localName: data['local_name'] ?? 'IBEW Local ${data['local_union'] ?? ''}',
      classification: data['classification'],
      location: location,
      address: data['address'],
      contactEmail: data['email'] ?? '',
      contactPhone: data['phone'] ?? '',
      website: data['website'],
      memberCount: data['memberCount'] ?? 0,
      specialties: List<String>.from(data['specialties'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reference: doc.reference,
      rawData: data,
    );
  }

  /// Creates a [LocalsRecord] instance from a JSON map.
  factory LocalsRecord.fromJson(Map<String, dynamic> json) {
    return LocalsRecord(
      id: json['id'] ?? '',
      localNumber: json['localNumber'] ?? '',
      localName: json['localName'] ?? '',
      classification: json['classification'],
      location: json['location'] ?? '',
      address: json['address'],
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      website: json['website'],
      memberCount: json['memberCount'] ?? 0,
      specialties: List<String>.from(json['specialties'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      rawData: json,
    );
  }

  /// Converts the [LocalsRecord] instance into a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localNumber': localNumber,
      'localName': localName,
      'classification': classification,
      'location': location,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'memberCount': memberCount,
      'specialties': specialties,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// A utility class that provides mock data for [LocalsRecord].
///
/// This is useful for testing, UI previews, and development without a live
/// database connection.
class LocalsRecordMockData {
  /// Returns a static list of sample [LocalsRecord] objects.
  static List<LocalsRecord> getSampleData() {
    return [
      LocalsRecord(
        id: '1',
        localNumber: '134',
        localName: 'Chicago Electrical Workers',
        classification: 'Inside Wireman',
        location: 'Chicago, IL',
        address: '600 W Washington Blvd, Chicago, IL 60661',
        contactEmail: 'contact@local134.org',
        contactPhone: '(312) 555-0134',
        website: 'https://www.local134.org',
        memberCount: 12500,
        specialties: ['Commercial', 'Industrial', 'Residential'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      LocalsRecord(
        id: '2',
        localNumber: '3',
        localName: 'New York Electrical Workers',
        classification: 'Inside Wireman',
        location: 'New York, NY',
        address: '158-29 George Meany Blvd, Flushing, NY 11365',
        contactEmail: 'info@local3.org',
        contactPhone: '(212) 555-0003',
        website: 'https://www.local3.org',
        memberCount: 15200,
        specialties: ['High Voltage', 'Commercial', 'Industrial'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      LocalsRecord(
        id: '3',
        localNumber: '11',
        localName: 'Los Angeles Electrical Workers',
        classification: 'Inside Wireman',
        location: 'Los Angeles, CA',
        address: '297 N Marengo Ave, Pasadena, CA 91101',
        contactEmail: 'contact@local11.org',
        contactPhone: '(213) 555-0011',
        website: 'https://www.ibew11.org',
        memberCount: 9800,
        specialties: ['Commercial', 'Solar', 'Industrial'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }
}