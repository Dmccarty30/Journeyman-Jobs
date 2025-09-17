import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';

/// Centralized mock data for all tests
class MockData {
  // IBEW Local Numbers for testing (real locals)
  static const List<int> realIBEWLocals = [
    1, 3, 11, 26, 46, 58, 98, 134, 146, 176, 191, 212, 292, 332, 353, 369, 424, 
    441, 453, 474, 488, 520, 558, 569, 595, 611, 640, 659, 683, 697, 714, 728, 
    760, 776, 817, 852, 876, 915, 934, 953, 993
  ];

  // Electrical Classifications
  static const List<String> electricalClassifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
    'Low Voltage Technician',
    'Sound Technician',
    'Maintenance Electrician',
    'Utility Worker',
  ];

  // Construction Types
  static const List<String> constructionTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Utility',
    'Maintenance',
    'Storm Work',
    'Emergency Restoration',
  ];

  // US States with IBEW presence
  static const List<String> ibewStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 
    'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 
    'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 
    'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 
    'WI', 'WY'
  ];

  /// Create mock job data
  static JobModel createJob({
    String? id,
    String? company,
    String? location,
    String? classification,
    int? localNumber,
    double? wage,
    String? constructionType,
  }) {
    final jobId = id ?? 'job-${DateTime.now().millisecondsSinceEpoch}';
    final jobLocal = localNumber ?? realIBEWLocals.first;
    
    return JobModel(
      id: jobId,
      company: company ?? 'Test Electric Company',
      location: location ?? 'Test City, TS',
      classification: classification ?? electricalClassifications.first,
      local: jobLocal,
      wage: wage ?? 42.50,
      jobTitle: 'Journeyman Electrician',
      timestamp: DateTime.now(),
      startDate: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      typeOfWork: constructionType ?? constructionTypes.first,
      jobDescription: 'Test job description for electrical work',
      qualifications: 'Valid driver\'s license, OSHA 30 certification, 5+ years experience',
      perDiem: 'Health insurance, Retirement plan, Tool allowance',
    );
  }

  /// Create mock user data
  static UserModel createUser({
    String? uid,
    String? email,
    String? displayName,
    int? localNumber,
    String? classification,
    List<String>? certifications,
  }) {
    return UserModel(
      uid: uid ?? 'user-${DateTime.now().millisecondsSinceEpoch}',
      firstName: displayName?.split(' ').first ?? 'Test',
      lastName: displayName?.split(' ').last ?? 'User',
      phoneNumber: '555-123-4567',
      email: email ?? 'test@ibew.local',
      address1: '123 Main St',
      city: 'Test City',
      state: 'TS',
      zipcode: '12345',
      homeLocal: localNumber?.toString() ?? realIBEWLocals.first.toString(),
      ticketNumber: '12345',
      classification: classification ?? electricalClassifications.first,
      isWorking: false,
      constructionTypes: ['Commercial'],
      networkWithOthers: true,
      careerAdvancements: true,
      betterBenefits: true,
      higherPayRate: true,
      learnNewSkill: true,
      travelToNewLocation: true,
      findLongTermWork: true,
      onboardingStatus: 'completed',
      createdTime: DateTime.now(),
    );
  }

  /// Create mock IBEW local data
  static LocalsRecord createLocal({
    int? localNumber,
    String? name,
    String? state,
    String? address,
    String? phone,
    List<String>? classifications,
  }) {
    final local = localNumber ?? realIBEWLocals.first;
    
    return LocalsRecord(
      id: 'local-$local',
      localNumber: local.toString(),
      localName: name ?? 'IBEW Local $local',
      location: state ?? ibewStates.first,
      address: address ?? '$local Union Street, Test City, ${state ?? ibewStates.first} 12345',
      contactPhone: phone ?? '(555) ${local.toString().padLeft(3, '0')}-4567',
      contactEmail: 'info@local$local.ibew.org',
      website: 'https://local$local.ibew.org',
      memberCount: 100 + local,
      specialties: classifications ?? electricalClassifications.take(3).toList(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reference: FirebaseFirestore.instance.collection('locals').doc('local-$local'),
    );
  }

  /// Create multiple mock jobs for testing lists
  static List<JobModel> createJobList({
    int count = 10,
    bool includeStormWork = false,
  }) {
    return List.generate(count, (index) {
      final local = realIBEWLocals[index % realIBEWLocals.length];
      final classification = electricalClassifications[index % electricalClassifications.length];
      final constructionType = constructionTypes[index % constructionTypes.length];
      
      return createJob(
        id: 'job-list-$index',
        company: 'Electric Company ${index + 1}',
        localNumber: local,
        classification: classification,
        constructionType: constructionType,
        wage: 35.0 + (index * 2.5),
      );
    });
  }

  /// Create multiple mock locals for testing
  static List<LocalsRecord> createLocalsList({int count = 20}) {
    return List.generate(count, (index) {
      final local = realIBEWLocals[index % realIBEWLocals.length];
      final state = ibewStates[index % ibewStates.length];
      
      return createLocal(
        localNumber: local,
        state: state,
        classifications: electricalClassifications.take(2 + (index % 3)).toList(),
      );
    });
  }

  /// Create mock filter criteria data
  static Map<String, dynamic> createFilterCriteria({
    List<String>? classifications,
    List<String>? constructionTypes,
    List<int>? locals,
    double? minWage,
    double? maxWage,
    int? maxDistance,
  }) {
    return {
      'classifications': classifications ?? [electricalClassifications.first],
      'constructionTypes': constructionTypes ?? [MockData.constructionTypes.first],
      'locals': locals ?? [realIBEWLocals.first],
      'minWage': minWage ?? 30.0,
      'maxWage': maxWage ?? 60.0,
      'maxDistance': maxDistance ?? 50,
      'includeStormWork': true,
    };
  }

  /// Create mock notification data
  static Map<String, dynamic> createNotificationData({
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return {
      'title': title ?? 'New Job Posted',
      'body': body ?? 'A new job matching your criteria has been posted',
      'type': type ?? 'job_notification',
      'timestamp': DateTime.now().toIso8601String(),
      'data': data ?? {
        'jobId': 'test-job-id',
        'localNumber': realIBEWLocals.first,
      },
    };
  }

  /// Create mock Firebase document snapshot
  static Map<String, dynamic> createFirestoreDocument({
    String? collection,
    String? documentId,
    Map<String, dynamic>? data,
  }) {
    return {
      'id': documentId ?? 'doc-${DateTime.now().millisecondsSinceEpoch}',
      'collection': collection ?? 'test',
      'data': data ?? {},
      'exists': true,
      'createTime': DateTime.now().toIso8601String(),
      'updateTime': DateTime.now().toIso8601String(),
    };
  }

  /// Create mock authentication data
  static Map<String, dynamic> createAuthData({
    String? uid,
    String? email,
    String? displayName,
    bool isEmailVerified = true,
  }) {
    return {
      'uid': uid ?? 'auth-${DateTime.now().millisecondsSinceEpoch}',
      'email': email ?? 'test@ibew.local',
      'displayName': displayName ?? 'Test User',
      'emailVerified': isEmailVerified,
      'creationTime': DateTime.now().toIso8601String(),
      'lastSignInTime': DateTime.now().toIso8601String(),
      'providerData': [
        {
          'providerId': 'password',
          'uid': email ?? 'test@ibew.local',
          'email': email ?? 'test@ibew.local',
        }
      ],
    };
  }

  /// Generate realistic electrical industry test scenarios
  static Map<String, List<JobModel>> createElectricalScenarios() {
    return {
      'commercial_projects': createJobList(count: 8)
          .where((job) => job.typeOfWork == 'Commercial')
          .toList(),
      'high_voltage_work': createJobList(count: 6)
          .where((job) => job.classification == 'Journeyman Lineman')
          .toList(),
      'low_voltage_tech': createJobList(count: 4)
          .where((job) => job.classification == 'Low Voltage Technician')
          .toList(),
    };
  }

  /// Create test data for performance testing
  static List<JobModel> createLargeJobDataset({int count = 1000}) {
    return createJobList(count: count);
  }

  /// Create test data for offline scenarios
  static Map<String, dynamic> createOfflineTestData() {
    return {
      'cached_jobs': createJobList(count: 20),
      'cached_locals': createLocalsList(count: 50),
      'user_preferences': createFilterCriteria(),
      'last_sync': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    };
  }
}
