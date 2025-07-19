import 'package:cloud_firestore/cloud_firestore.dart';

/// Locals Record Model
/// 
/// Represents a local union record with member information
class LocalsRecord {
  final String id;
  final String localNumber;
  final String localName;
  final String? classification; // Added for job classification
  final String location;
  final String? address; // Added for full address
  final String contactEmail;
  final String contactPhone;
  final String? website; // Added for website URL
  final int memberCount;
  final List<String> specialties;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DocumentReference? reference; // Added for Firestore reference
  final Map<String, dynamic>? rawData; // Added to store all document data

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

  // Getter aliases for compatibility with backend schema expectations
  String get localUnion => localNumber;
  String get phone => contactPhone;
  String get email => contactEmail;
  
  // Extract city and state from location string
  String get city {
    final parts = location.split(', ');
    return parts.isNotEmpty ? parts[0] : '';
  }
  
  String get state {
    final parts = location.split(', ');
    return parts.length > 1 ? parts[1] : '';
  }
  
  // Alias for rawData
  Map<String, dynamic>? get data => rawData;

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

/// Mock data for LocalsRecord
class LocalsRecordMockData {
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