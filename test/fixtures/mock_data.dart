import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../lib/models/job_model.dart';
import '../../lib/models/user_model.dart';
import '../../lib/models/filter_criteria.dart';
import '../../lib/models/filter_preset.dart';

/// Mock data generators for testing
class MockData {
  /// Creates a mock Firebase user
  static MockUser createMockFirebaseUser({
    String? uid,
    String? email,
    String? displayName,
    bool isEmailVerified = true,
  }) {
    final mockUser = MockUser();
    when(mockUser.uid).thenReturn(uid ?? 'test_user_123');
    when(mockUser.email).thenReturn(email ?? 'test@example.com');
    when(mockUser.displayName).thenReturn(displayName ?? 'Test User');
    when(mockUser.isEmailVerified).thenReturn(isEmailVerified);
    when(mockUser.getIdToken()).thenAnswer((_) async => 'mock_token');
    when(mockUser.getIdToken(refresh: true))
        .thenAnswer((_) async => 'mock_token_refreshed');
    return mockUser;
  }

  /// Creates a test Job model
  static Job createTestJob({
    String? id,
    String? company,
    String? location,
    int? local,
    String? classification,
    double? wage,
    bool? perDiem,
    String? typeOfWork,
    String? jobDescription,
    String? startDate,
    String? postedAt,
    bool? booked,
    String? status,
  }) {
    final now = DateTime.now();
    return Job.fromJson({
      'id': id ?? 'test_job_123',
      'company': company ?? 'PowerGrid Solutions',
      'location': location ?? 'New York, NY',
      'local': local ?? 3,
      'classification': classification ?? 'Inside Wireman',
      'wage': wage ?? 45.50,
      'hours': 40,
      'typeOfWork': typeOfWork ?? 'Commercial',
      'jobDescription': jobDescription ?? 'Installing electrical systems',
      'startDate': startDate ?? now.add(const Duration(days: 7)).toIso8601String(),
      'postedAt': postedAt ?? now.toIso8601String(),
      'perDiem': perDiem ?? true,
      'perDiemAmount': '100',
      'booked': booked ?? false,
      'status': status ?? 'active',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'createdBy': 'test_user@example.com',
      'contactInfo': {
        'email': 'contact@company.com',
        'phone': '555-0123-4567',
      },
      'jobDetails': {
        'requirements': ['Journeyman license', 'OSHA 10', 'Reliable transportation'],
        'benefits': ['Health insurance', '401k', 'Paid time off'],
        'equipment': ['Basic hand tools provided'],
      },
    });
  }

  /// Creates a list of test jobs
  static List<Job> createTestJobList({
    int count = 5,
    int startIndex = 0,
  }) {
    return List.generate(count, (index) => createTestJob(
      id: 'test_job_${startIndex + index + 1}',
      company: 'Company ${startIndex + index + 1}',
      location: 'Location ${startIndex + index + 1}',
      local: startIndex + index + 1,
      wage: 40.0 + (index * 5.0),
    ));
  }

  /// Creates a test User model
  static UserModel createTestUser({
    String? uid,
    String? email,
    String? displayName,
    String? local,
    List<String>? classifications,
  }) {
    final now = DateTime.now();
    return UserModel.fromJson({
      'uid': uid ?? 'test_user_123',
      'email': email ?? 'test@example.com',
      'displayName': displayName ?? 'Test User',
      'local': local ?? '3',
      'classifications': classifications ?? ['Inside Wireman', 'Lineman'],
      'isEmailVerified': true,
      'createdAt': now.toIso8601String(),
      'lastSignInAt': now.toIso8601String(),
      'preferences': {
        'notifications': true,
        'darkMode': false,
        'autoApply': true,
      },
    });
  }

  /// Creates a test job filter criteria
  static JobFilterCriteria createTestFilter({
    String? searchQuery,
    List<int>? localNumbers,
    List<String>? classifications,
    String? city,
    String? state,
    double? maxDistance,
    bool? hasPerDiem,
    JobSortOption? sortBy,
    bool? sortDescending,
  }) {
    return JobFilterCriteria(
      searchQuery: searchQuery,
      localNumbers: localNumbers ?? [3],
      classifications: classifications ?? ['Inside Wireman'],
      city: city,
      state: state,
      maxDistance: maxDistance ?? 50.0,
      hasPerDiem: hasPerDiem ?? true,
      sortBy: sortBy ?? JobSortOption.date,
      sortDescending: sortDescending ?? true,
    );
  }

  /// Creates a test filter preset
  static FilterPreset createTestPreset({
    String? id,
    String? name,
    String? description,
    JobFilterCriteria? criteria,
    bool isPinned = false,
  }) {
    final now = DateTime.now();
    return FilterPreset(
      id: id ?? 'preset_123',
      name: name ?? 'Test Preset',
      description: description ?? 'A test filter preset',
      criteria: criteria ?? JobFilterCriteria(),
      createdAt: now,
      lastUsedAt: now.subtract(const Duration(days: 1)),
      isPinned: isPinned,
      icon: Icons.filter_list,
    );
  }

  /// Creates test bookmark data
  static Map<String, dynamic> createTestBookmark({
    String? userId,
    String? jobId,
    DateTime? createdAt,
  }) {
    return {
      'userId': userId ?? 'test_user_123',
      'jobId': jobId ?? 'test_job_123',
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Creates test user preferences
  static Map<String, dynamic> createTestPreferences({
    bool? notifications,
    bool? darkMode,
    String? preferredLocal,
    List<String>? savedSearches,
  }) {
    return {
      'notifications': notifications ?? true,
      'darkMode': darkMode ?? false,
      'preferredLocal': preferredLocal ?? '3',
      'savedSearches': savedSearches ?? ['electrician', 'lineman'],
      'autoApply': true,
      'showInactiveJobs': false,
    };
  }

  /// Creates test session data
  static Map<String, dynamic> createTestSession({
    String? userId,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? deviceInfo,
  }) {
    final now = DateTime.now();
    return {
      'userId': userId ?? 'test_user_123',
      'createdAt': (createdAt ?? now).toIso8601String(),
      'expiresAt': (expiresAt ?? now.add(const Duration(hours: 24))).toIso8601String(),
      'deviceInfo': deviceInfo ?? 'Test Device',
      'isActive': true,
      'lastActivity': now.toIso8601String(),
    };
  }

  /// Creates test crew data
  static Map<String, dynamic> createTestCrew({
    String? id,
    String? name,
    String? foremanId,
    List<Map<String, dynamic>>? members,
  }) {
    return {
      'id': id ?? 'crew_123',
      'name': name ?? 'Test Crew',
      'foremanId': foremanId ?? 'foreman_123',
      'description': 'Test crew for electrical work',
      'createdAt': DateTime.now().toIso8601String(),
      'members': members ?? [
        {
          'userId': 'member_1',
          'role': 'lead',
          'joinedAt': DateTime.now().toIso8601String(),
        },
        {
          'userId': 'member_2',
          'role': 'member',
          'joinedAt': DateTime.now().toIso8601String(),
        },
      ],
      'isActive': true,
    };
  }

  /// Creates test application data
  static Map<String, dynamic> createTestApplication({
    String? id,
    String? userId,
    String? jobId,
    String? status,
    DateTime? appliedAt,
  }) {
    return {
      'id': id ?? 'app_123',
      'userId': userId ?? 'user_123',
      'jobId': jobId ?? 'job_123',
      'status': status ?? 'pending',
      'appliedAt': (appliedAt ?? DateTime.now()).toIso8601String(),
      'coverLetter': 'Experienced electrician looking for opportunity',
      'availability': 'Immediate',
    };
  }
}

/// Mock error test utilities
class ErrorTestUtils {
  /// Creates a mock network error
  static SocketException createNetworkError({String? message}) {
    return SocketException(
      message ?? 'Network unreachable',
      osError: const OSError('Connection refused', 61),
    );
  }

  /// Creates a mock timeout error
  static TimeoutException createTimeoutError({String? message}) {
    return TimeoutException(
      message ?? 'Request timeout',
      const Duration(seconds: 30),
    );
  }

  /// Creates a mock Firebase auth error
  static FirebaseAuthException createAuthError({
    String? code,
    String? message,
  }) {
    return FirebaseAuthException(
      code: code ?? 'unknown',
      message: message ?? 'Authentication error',
    );
  }

  /// Creates a mock Firestore error
  static FirebaseException createFirestoreError({
    String? code,
    String? message,
  }) {
    return FirebaseException(
      code: code ?? 'unknown',
      message: message ?? 'Firestore error',
    );
  }

  /// Creates a mock validation error
  static Exception createValidationError({String? message}) {
    return Exception(message ?? 'Validation failed');
  }

  /// Creates a mock system error
  static AssertionError createSystemError({String? message}) {
    return AssertionError(message ?? 'System assertion failed');
  }
}