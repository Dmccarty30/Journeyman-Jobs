/// Locals Record Model
/// 
/// Represents a local union record with member information
class LocalsRecord {
  final String id;
  final String localNumber;
  final String localName;
  final String location;
  final String contactEmail;
  final String contactPhone;
  final int memberCount;
  final List<String> specialties;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocalsRecord({
    required this.id,
    required this.localNumber,
    required this.localName,
    required this.location,
    required this.contactEmail,
    required this.contactPhone,
    required this.memberCount,
    required this.specialties,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocalsRecord.fromJson(Map<String, dynamic> json) {
    return LocalsRecord(
      id: json['id'] ?? '',
      localNumber: json['localNumber'] ?? '',
      localName: json['localName'] ?? '',
      location: json['location'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      specialties: List<String>.from(json['specialties'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localNumber': localNumber,
      'localName': localName,
      'location': location,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
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
        location: 'Chicago, IL',
        contactEmail: 'contact@local134.org',
        contactPhone: '(312) 555-0134',
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
        location: 'New York, NY',
        contactEmail: 'info@local3.org',
        contactPhone: '(212) 555-0003',
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
        location: 'Los Angeles, CA',
        contactEmail: 'contact@local11.org',
        contactPhone: '(213) 555-0011',
        memberCount: 9800,
        specialties: ['Solar', 'Commercial', 'Entertainment'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}