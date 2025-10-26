import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/user_job_preferences.dart';

/// Mock data for hierarchical initialization testing
class HierarchicalMockData {
  // Test constants
  static const String testUserId = 'test_user_123';
  static const String testUnionId = 'union_1';
  static const String testLocalId = 'local_3';
  static const String testJobId = 'job_456';

  // Level 1: Unions
  static final testUnion = _createMockUnion('union_1', 'IBEW International', 'International', 797);
  static final regionalUnion = _createMockUnion('union_2', 'IBEW Northeast', 'Regional', 124);
  static final localUnion = _createMockUnion('union_3', 'IBEW Local 3', 'Local', 1);

  static final List<Map<String, dynamic>> mockUnionDocs = [
    testUnion,
    regionalUnion,
    localUnion,
  ];

  // Level 2: Locals (797+ records sample)
  static final testLocal = LocalsRecord(
    id: testLocalId,
    localNumber: '3',
    localName: 'New York Electrical Workers',
    classification: 'Inside Wireman',
    location: 'New York, NY',
    address: '158-29 George Meany Blvd, Flushing, NY 11365',
    contactEmail: 'info@ibewlocal3.org',
    contactPhone: '(212) 555-0003',
    website: 'https://www.ibewlocal3.org',
    memberCount: 15200,
    specialties: ['High Voltage', 'Commercial', 'Industrial'],
    isActive: true,
    createdAt: DateTime.now().subtract(Duration(days: 400)),
    updatedAt: DateTime.now().subtract(Duration(days: 15)),
  );

  static final List<LocalsRecord> allLocals = List.generate(797, (index) {
    final localNumber = (index + 1).toString();
    final states = ['NY', 'CA', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI'];
    final state = states[index % states.length];

    return LocalsRecord(
      id: 'local_$localNumber',
      localNumber: localNumber,
      localName: 'IBEW Local $localNumber',
      classification: 'Inside Wireman',
      location: 'City $localNumber, $state',
      address: '$localNumber Main St, City $localNumber, $state ${10000 + index}',
      contactEmail: 'contact@local$localNumber.org',
      contactPhone: '(${state == 'NY' ? '212' : '555'}) 555-$localNumber',
      website: 'https://www.local$localNumber.org',
      memberCount: 1000 + (index * 10),
      specialties: _getSpecialties(index),
      isActive: true,
      createdAt: DateTime.now().subtract(Duration(days: 365 + index)),
      updatedAt: DateTime.now().subtract(Duration(days: index)),
    );
  });

  static final List<Map<String, dynamic>> mockLocalDocs = allLocals
      .map((local) => local.toJson())
      .toList();

  // Level 3: Members
  static final testMember = _createMockMember(
    id: testUserId,
    name: 'John Doe',
    email: 'john.doe@example.com',
    localUnion: '3',
    certifications: ['Journeyman', 'OSHA 30'],
    memberRole: MemberRole.regular,
  );

  static final adminMember = _createMockMember(
    id: 'admin_123',
    name: 'Admin User',
    email: 'admin@ibew.org',
    localUnion: '3',
    certifications: ['Master Electrician', 'OSHA 30'],
    memberRole: MemberRole.admin,
  );

  static final List<Map<String, dynamic>> mockMemberDocs = [
    testMember.toJson(),
    adminMember.toJson(),
  ];

  // Level 4: Jobs
  static final testJob = Job(
    id: testJobId,
    sharerId: 'sharer_123',
    jobDetails: {
      'hours': 40,
      'payRate': 45.50,
      'perDiem': 'Daily',
      'contractor': 'Electrical Corp',
      'location': null,
    },
    matchesCriteria: true,
    deleted: false,
    local: 3,
    classification: 'Inside Wireman',
    company: 'Electrical Corp',
    location: 'New York, NY',
    hours: 40,
    wage: 45.50,
    sub: 'Commercial',
    jobClass: 'Journeyman',
    localNumber: 3,
    qualifications: 'Journeyman Electrician',
    datePosted: '2024-01-15',
    jobDescription: 'Commercial electrical installation project',
    jobTitle: 'Journeyman Electrician',
    perDiem: 'Daily',
    agreement: 'IBEW Agreement',
    numberOfJobs: '5',
    timestamp: DateTime.now().subtract(Duration(days: 7)),
    startDate: '2024-02-01',
    startTime: '7:00 AM',
    booksYourOn: [3, 11, 134],
    typeOfWork: 'commercial',
    duration: '3 months',
    voltageLevel: '480V',
  );

  static final List<Job> allJobs = List.generate(200, (index) {
    final localNumber = (index % 50) + 1; // Distribute across 50 locals
    final classifications = ['Inside Wireman', 'Journeyman Lineman', 'Tree Trimmer', 'Equipment Operator'];
    final companies = ['Electrical Corp', 'Power Systems Inc', 'Grid Solutions', 'Lightning Electric'];
    final locations = ['New York, NY', 'Los Angeles, CA', 'Chicago, IL', 'Houston, TX'];

    return Job(
      id: 'job_${1000 + index}',
      sharerId: 'sharer_${index % 10}',
      jobDetails: {
        'hours': 40 + (index % 20),
        'payRate': 35.0 + (index % 30),
        'perDiem': index % 2 == 0 ? 'Daily' : 'Weekly',
        'contractor': companies[index % companies.length],
        'location': null,
      },
      matchesCriteria: index % 3 == 0,
      deleted: index % 20 == 0, // 5% deleted
      local: localNumber,
      classification: classifications[index % classifications.length],
      company: companies[index % companies.length],
      location: locations[index % locations.length],
      hours: 40 + (index % 20),
      wage: 35.0 + (index % 30),
      sub: index % 2 == 0 ? 'Commercial' : 'Industrial',
      jobClass: 'Journeyman',
      localNumber: localNumber,
      qualifications: 'Journeyman Electrician',
      datePosted: DateTime.now().subtract(Duration(days: index % 30)).toIso8601String(),
      jobDescription: 'Electrical project #${1000 + index}',
      jobTitle: '${classifications[index % classifications.length]} Needed',
      perDiem: index % 2 == 0 ? 'Daily' : 'Weekly',
      agreement: 'IBEW Agreement',
      numberOfJobs: '${1 + (index % 10)}',
      timestamp: DateTime.now().subtract(Duration(days: index % 30)),
      startDate: DateTime.now().add(Duration(days: index % 60)).toIso8601String(),
      startTime: '${7 + (index % 4)}:00 AM',
      booksYourOn: [localNumber, (localNumber % 10) + 1, (localNumber % 20) + 1],
      typeOfWork: index % 2 == 0 ? 'commercial' : 'industrial',
      duration: '${1 + (index % 6)} months',
      voltageLevel: ['120V', '240V', '480V', '13.8kV'][index % 4],
    );
  });

  static final List<Map<String, dynamic>> mockJobDocs = allJobs
      .map((job) => job.toJson())
      .toList();

  // Test scenarios
  static final Map<String, dynamic> corruptedLocalData = {
    'id': 'corrupted_local',
    'local_union': null, // Missing required field
    'local_name': 'Corrupted Local',
    'city': 'Test City',
    'state': 'TS',
  };

  static final Map<String, dynamic> incompleteJobData = {
    'id': 'incomplete_job',
    'local': null, // Missing local association
    'company': '', // Empty company
    'wage': 'invalid_number', // Invalid wage format
  };

  static final List<Map<String, dynamic>> emptyHierarchyData = [];

  // Helper methods
  static Map<String, dynamic> _createMockUnion(
    String id,
    String name,
    String jurisdiction,
    int localCount,
  ) {
    return {
      'id': id,
      'name': name,
      'jurisdiction': jurisdiction,
      'localCount': localCount,
      'establishedDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 36500))),
      'website': 'https://www.$name.toLowerCase().replaceAll(' ', '')}.org',
      'contactEmail': 'info@$name.toLowerCase().replaceAll(' ', '').replaceAll('ibew', 'ibew')}.org',
      'isActive': true,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 36500))),
      'updatedAt': Timestamp.now(),
    };
  }

  static Map<String, dynamic> _createMockMember({
    required String id,
    required String name,
    required String email,
    required String localUnion,
    required List<String> certifications,
    required MemberRole memberRole,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'localUnion': localUnion,
      'certifications': certifications,
      'memberRole': memberRole.toString(),
      'joinDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 730))),
      'isActive': true,
      'preferences': UserJobPreferences(
        preferredLocals: [int.tryParse(localUnion) ?? 0],
        preferredClassifications: ['Inside Wireman'],
        constructionTypes: ['Commercial'],
        hoursPerWeek: '40',
        perDiem: 'Daily',
      ).toJson(),
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 730))),
      'updatedAt': Timestamp.now(),
    };
  }

  static List<String> _getSpecialties(int index) {
    final allSpecialties = [
      'Commercial',
      'Industrial',
      'Residential',
      'High Voltage',
      'Solar',
      'Wind',
      'Telecommunications',
      'Instrumentation',
    ];

    final specialties = <String>[];
    specialties.add(allSpecialties[index % allSpecialties.length]);

    if (index % 3 == 0) {
      specialties.add(allSpecialties[(index + 1) % allSpecialties.length]);
    }

    if (index % 5 == 0) {
      specialties.add(allSpecialties[(index + 2) % allSpecialties.length]);
    }

    return specialties;
  }

  // Performance test data
  static final List<Job> largeJobDataset = List.generate(1000, (index) {
    return Job(
      id: 'perf_job_$index',
      sharerId: 'perf_sharer',
      jobDetails: {'hours': 40, 'payRate': 50.0},
      matchesCriteria: true,
      deleted: false,
      local: (index % 100) + 1,
      classification: 'Inside Wireman',
      company: 'Performance Test Corp',
      location: 'Test City, TS',
      hours: 40,
      wage: 50.0,
      timestamp: DateTime.now().subtract(Duration(minutes: index)),
    );
  });

  static final List<LocalsRecord> largeLocalDataset = List.generate(2000, (index) {
    return LocalsRecord(
      id: 'perf_local_$index',
      localNumber: (index + 1).toString(),
      localName: 'Performance Local ${index + 1}',
      location: 'Perf City, TS',
      contactEmail: 'perf$index@test.com',
      contactPhone: '(555) 555-${index.toString().padLeft(4, '0')}',
      memberCount: 1000 + index,
      specialties: ['Performance Testing'],
      isActive: true,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now(),
    );
  });

  // Error scenario data
  static final List<Map<String, dynamic>> networkErrorScenarios = [
    {'code': 'unavailable', 'message': 'Network unavailable'},
    {'code': 'deadline-exceeded', 'message': 'Request timeout'},
    {'code': 'permission-denied', 'message': 'Access denied'},
    {'code': 'not-found', 'message': 'Resource not found'},
    {'code': 'resource-exhausted', 'message': 'Quota exceeded'},
  ];

  static final List<Map<String, dynamic>> malformedDataScenarios = [
    {'id': null, 'local_union': '123'}, // Missing ID
    {'id': 'test', 'local_union': null}, // Missing local union
    {'id': 'test', 'local_union': 'invalid_number'}, // Invalid local number
    {'id': 'test', 'local_union': '999999999'}, // Out of range local number
    {'id': 'test', 'local_union': '-1'}, // Negative local number
  ];
}

/// Enum for member roles
enum MemberRole {
  regular,
  admin,
  steward,
  businessManager,
}

/// Extension methods for test data
extension MockDataExtensions on Map<String, dynamic> {
  Map<String, dynamic> withTimestamps({
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final data = Map<String, dynamic>.from(this);
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt);
    }
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt);
    }
    return data;
  }

  Map<String, dynamic> withNullField(String fieldName) {
    final data = Map<String, dynamic>.from(this);
    data[fieldName] = null;
    return data;
  }

  Map<String, dynamic> withInvalidField(String fieldName, dynamic value) {
    final data = Map<String, dynamic>.from(this);
    data[fieldName] = value;
    return data;
  }
}