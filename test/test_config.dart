library test_config;

/// Comprehensive Test Configuration for Journeyman Jobs IBEW Platform
/// 
/// This file provides centralized test configuration for the electrical workforce
/// platform, including specialized test utilities for IBEW electrical workers,
/// crew management, job sharing, and viral growth features.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Master test configuration for the IBEW electrical workforce platform
class JJTestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration animationTimeout = Duration(milliseconds: 300);
  static const Duration networkTimeout = Duration(seconds: 10);
  
  /// Test environment configuration
  static const Map<String, dynamic> testEnvironment = {
    'platform': 'test',
    'firebase_emulator': true,
    'mock_location_services': true,
    'mock_contact_services': true,
    'debug_mode': true,
  };
  
  /// IBEW Local test data configuration
  static const Map<String, dynamic> ibewTestData = {
    'total_locals': 797,
    'test_sample_size': 50,
    'classifications': [
      'Inside Wireman',
      'Journeyman Lineman', 
      'Tree Trimmer',
      'Equipment Operator',
      'Sound Technician',
      'Low Voltage Technician'
    ],
    'construction_types': [
      'Commercial',
      'Industrial', 
      'Residential',
      'Utility',
      'Maintenance'
    ],
    'storm_work_enabled': true,
  };
  
  /// Job sharing and viral growth test configuration
  static const Map<String, dynamic> viralGrowthTestConfig = {
    'share_methods': ['email', 'sms', 'in_app'],
    'crew_max_size': 10,
    'invitation_expiry_days': 7,
    'viral_coefficient_target': 1.2,
    'conversion_rate_target': 0.15,
    'signup_time_target_minutes': 2,
  };
}

/// Electrical industry test data generator
class ElectricalTestDataGenerator {
  static const List<String> _companies = [
    'Elite Electric Corp',
    'Power Grid Solutions', 
    'Industrial Electric Co',
    'Storm Response LLC',
    'Commercial Electrical Services',
    'Utility Infrastructure Inc',
    'Emergency Power Systems',
    'Renewable Energy Solutions'
  ];
  
  static const List<String> _locations = [
    'Houston, TX',
    'Los Angeles, CA',
    'Chicago, IL',
    'New York, NY',
    'Miami, FL',
    'Atlanta, GA',
    'Seattle, WA',
    'Denver, CO'
  ];
  
  static const List<int> _majorLocals = [
    1, 3, 11, 26, 46, 58, 98, 134, 143, 176, 191, 202, 292, 302, 332, 353, 440, 569, 595, 613, 697, 728, 756, 769
  ];
  
  static Map<String, dynamic> generateJobData({
    String? id,
    String? classification,
    bool isStormWork = false,
    double? wageMin,
    double? wageMax,
  }) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final companyIndex = random % _companies.length;
    final locationIndex = random % _locations.length;
    final localIndex = random % _majorLocals.length;
    final classificationIndex = random % JJTestConfig.ibewTestData['classifications'].length;
    
    return {
      'id': id ?? 'job_${random}_test',
      'company': _companies[companyIndex],
      'location': _locations[locationIndex],
      'classification': classification ?? JJTestConfig.ibewTestData['classifications'][classificationIndex],
      'local': _majorLocals[localIndex],
      'wage_min': wageMin ?? (35.0 + (random % 20)),
      'wage_max': wageMax ?? (wageMin ?? (35.0 + (random % 20))) + 5.0,
      'job_title': isStormWork ? 'Storm Restoration Electrician' : 'Journeyman Electrician',
      'type_of_work': isStormWork ? 'Storm Work' : JJTestConfig.ibewTestData['construction_types'][random % 5],
      'is_storm_work': isStormWork,
      'start_date': DateTime.now().add(Duration(days: 1 + (random % 30))).toIso8601String(),
      'description': isStormWork 
          ? 'Immediate storm restoration work - travel required'
          : 'Standard electrical construction and maintenance',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'status': 'active',
      'applicant_count': random % 25,
      'urgency': isStormWork ? 'high' : 'normal',
    };
  }
  
  static Map<String, dynamic> generateLocalData({
    int? localNumber,
    String? state,
    List<String>? classifications,
  }) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final stateIndex = random % 50; // 50 US states
    final states = ['TX', 'CA', 'IL', 'NY', 'FL', 'GA', 'WA', 'CO', 'PA', 'OH'];
    
    return {
      'local_number': localNumber ?? _majorLocals[random % _majorLocals.length],
      'name': 'IBEW Local ${localNumber ?? _majorLocals[random % _majorLocals.length]}',
      'state': state ?? states[stateIndex % states.length],
      'address': '${100 + (random % 900)} Union Ave, Test City, ${state ?? states[stateIndex % states.length]} ${10000 + (random % 90000)}',
      'phone': '(${200 + (random % 800)}) ${200 + (random % 800)}-${1000 + (random % 9000)}',
      'website': 'https://local${localNumber ?? _majorLocals[random % _majorLocals.length]}.ibew.org',
      'classifications': classifications ?? JJTestConfig.ibewTestData['classifications'],
      'membership_count': 500 + (random % 2000),
      'established_year': 1900 + (random % 125),
      'training_center': true,
      'apprenticeship_program': true,
      'storm_work_certified': true,
    };
  }
  
  static Map<String, dynamic> generateCrewData({
    String? id,
    String? leaderId,
    List<String>? memberIds,
    String? specialization,
  }) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final specializations = ['Storm Response', 'Industrial Maintenance', 'Commercial Construction', 'Utility Work'];
    
    return {
      'id': id ?? 'crew_${random}_test',
      'name': '${specializations[random % specializations.length]} Team Alpha',
      'leader_id': leaderId ?? 'leader_$random',
      'member_ids': memberIds ?? ['leader_$random'],
      'specialization': specialization ?? specializations[random % specializations.length],
      'is_active': true,
      'member_limit': 10,
      'created_at': DateTime.now().toIso8601String(),
      'preferences': {
        'accepted_job_types': ['commercial', 'industrial'],
        'minimum_crew_rate': 40.0 + (random % 15),
        'max_travel_distance_miles': 100 + (random % 400),
        'preferred_states': ['TX', 'LA', 'OK'],
        'auto_share_matching_jobs': true,
        'match_threshold': 70 + (random % 30),
      },
      'stats': {
        'total_jobs_shared': random % 50,
        'total_group_applications': random % 20,
        'successful_group_hires': random % 15,
        'group_success_rate': (random % 100) / 100.0,
        'average_response_time': 1.0 + ((random % 500) / 100.0),
      },
    };
  }
  
  static Map<String, dynamic> generateUserData({
    String? uid,
    String? email,
    String? displayName,
    int? localNumber,
    String? classification,
    bool isIBEWMember = true,
  }) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final classificationIndex = random % JJTestConfig.ibewTestData['classifications'].length;
    
    return {
      'uid': uid ?? 'user_${random}_test',
      'email': email ?? 'test.user$random@ibew${_majorLocals[random % _majorLocals.length]}.org',
      'display_name': displayName ?? 'Test Worker $random',
      'ibew_local': localNumber ?? _majorLocals[random % _majorLocals.length],
      'classification': classification ?? JJTestConfig.ibewTestData['classifications'][classificationIndex],
      'is_ibew_member': isIBEWMember,
      'certifications': ['OSHA 30', 'First Aid/CPR', 'Scissor Lift'],
      'years_experience': 1 + (random % 20),
      'storm_work_certified': true,
      'available_for_travel': true,
      'preferred_job_types': ['commercial', 'industrial'],
      'created_at': DateTime.now().toIso8601String(),
      'last_active': DateTime.now().toIso8601String(),
      'profile_complete': true,
      'notification_preferences': {
        'job_alerts': true,
        'crew_invitations': true,
        'storm_work_alerts': true,
        'email_notifications': true,
        'sms_notifications': false,
      },
    };
  }
}

/// Test environment setup and teardown
class TestEnvironmentManager {
  static FakeFirebaseFirestore? _firestore;
  static MockFirebaseAuth? _auth;
  
  static Future<void> setup() async {
    _firestore = FakeFirebaseFirestore();
    _auth = MockFirebaseAuth();
    
    // Seed test data
    await _seedTestData();
  }
  
  static Future<void> teardown() async {
    _firestore = null;
    _auth = null;
  }
  
  static FakeFirebaseFirestore get firestore => _firestore!;
  static MockFirebaseAuth get auth => _auth!;
  
  static Future<void> _seedTestData() async {
    // Add jobs
    for (int i = 0; i < 20; i++) {
      await _firestore!.collection('jobs').add(
        ElectricalTestDataGenerator.generateJobData(
          isStormWork: i % 5 == 0, // Every 5th job is storm work
        )
      );
    }
    
    // Add locals
    for (int i = 0; i < 25; i++) {
      await _firestore!.collection('locals').add(
        ElectricalTestDataGenerator.generateLocalData()
      );
    }
    
    // Add users
    for (int i = 0; i < 10; i++) {
      await _firestore!.collection('users').add(
        ElectricalTestDataGenerator.generateUserData()
      );
    }
    
    // Add crews
    for (int i = 0; i < 5; i++) {
      await _firestore!.collection('crews').add(
        ElectricalTestDataGenerator.generateCrewData()
      );
    }
  }
  
  /// Reset test data to clean state
  static Future<void> resetTestData() async {
    await teardown();
    await setup();
  }
}

/// Widget test helpers with IBEW theming
class IBEWTestHelpers {
  /// Create a themed test widget with proper IBEW styling
  static Widget createThemedTestWidget(
    Widget child, {
    List<Override> providerOverrides = const [],
  }) {
    return ProviderScope(
      overrides: providerOverrides,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }
  
  /// Pump widget with electrical animation timing
  static Future<void> pumpElectricalWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? settleDuration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(
      settleDuration ?? JJTestConfig.animationTimeout,
    );
  }
  
  /// Find electrical component widgets
  static Finder findElectricalComponent(String componentType) {
    switch (componentType) {
      case 'circuit_breaker':
        return find.byKey(const Key('jj-circuit-breaker-switch'));
      case 'power_line_loader':
        return find.byKey(const Key('jj-power-line-loader'));
      case 'rotation_meter':
        return find.byKey(const Key('jj-electrical-rotation-meter'));
      case 'job_card':
        return find.byKey(const Key('jj-enhanced-job-card'));
      case 'local_card':
        return find.byKey(const Key('jj-local-card'));
      default:
        return find.byKey(Key('jj-$componentType'));
    }
  }
  
  /// Verify IBEW branding elements
  static void verifyIBEWBranding(WidgetTester tester) {
    // Check for navy blue primary color
    expect(find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        return decoration.color == AppTheme.primaryNavy;
      }
      return false;
    }), findsAtLeastNWidgets(1));
    
    // Check for copper accent color usage
    expect(find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        return decoration.color == AppTheme.accentCopper;
      }
      return false;
    }), findsAtLeastNWidgets(1));
  }
}

/// Performance test configuration
class PerformanceTestConfig {
  static const Map<String, int> benchmarks = {
    'job_list_render_time_ms': 1000,
    'search_response_time_ms': 500,
    'crew_creation_time_ms': 2000,
    'share_flow_time_ms': 1500,
    'contact_picker_load_time_ms': 800,
    'max_memory_usage_mb': 150,
    'startup_time_ms': 3000,
  };
  
  static const Map<String, double> thresholds = {
    'frame_render_time_ms': 16.67, // 60 FPS
    'cpu_usage_percent': 30.0,
    'memory_leak_tolerance_mb': 5.0,
    'network_timeout_seconds': 10.0,
  };
}

/// Integration test scenarios for electrical workflows
class ElectricalWorkflowScenarios {
  /// Storm work emergency response scenario
  static const Map<String, dynamic> stormWorkScenario = {
    'scenario_name': 'Hurricane Response Deployment',
    'trigger': 'Hurricane landfall alert',
    'steps': [
      'Receive storm work notification',
      'View available storm jobs',
      'Join storm response crew',
      'Apply for storm jobs as crew',
      'Receive deployment confirmation',
    ],
    'expected_completion_time_minutes': 15,
    'crew_size_target': 8,
    'geographic_scope': 'Multi-state',
  };
  
  /// Job sharing viral growth scenario
  static const Map<String, dynamic> viralGrowthScenario = {
    'scenario_name': 'Job Share Viral Loop',
    'trigger': 'User finds good job opportunity',
    'steps': [
      'Share job via SMS to non-user',
      'Non-user receives share link',
      'Quick signup flow (< 2 minutes)',
      'New user applies for job',
      'New user shares with their contacts',
    ],
    'viral_coefficient_target': 1.2,
    'conversion_rate_target': 0.15,
    'retention_rate_target': 0.40,
  };
  
  /// Union local directory scenario
  static const Map<String, dynamic> localDirectoryScenario = {
    'scenario_name': 'Find IBEW Local for Travel Job',
    'trigger': 'User considers out-of-state job',
    'steps': [
      'Search for locals by state/city',
      'View local details and classifications',
      'Contact local for reciprocity info',
      'Save local to favorites',
      'Apply for job with local info',
    ],
    'locals_database_size': 797,
    'search_performance_target_ms': 300,
    'offline_availability': true,
  };
}

/// Test result validation helpers
class TestValidationHelpers {
  /// Validate electrical worker data structure
  static bool validateElectricalWorkerData(Map<String, dynamic> data) {
    final requiredFields = [
      'uid', 'email', 'display_name', 'ibew_local', 
      'classification', 'is_ibew_member'
    ];
    
    return requiredFields.every((field) => data.containsKey(field));
  }
  
  /// Validate job data structure for electrical industry
  static bool validateJobData(Map<String, dynamic> data) {
    final requiredFields = [
      'id', 'company', 'location', 'classification', 
      'local', 'wage_min', 'type_of_work'
    ];
    
    return requiredFields.every((field) => data.containsKey(field)) &&
           JJTestConfig.ibewTestData['classifications'].contains(data['classification']);
  }
  
  /// Validate crew data structure
  static bool validateCrewData(Map<String, dynamic> data) {
    final requiredFields = [
      'id', 'name', 'leader_id', 'member_ids', 
      'is_active', 'member_limit'
    ];
    
    return requiredFields.every((field) => data.containsKey(field)) &&
           data['member_ids'] is List &&
           data['member_limit'] is int &&
           data['member_limit'] <= 10;
  }
  
  /// Validate viral sharing data
  static bool validateShareData(Map<String, dynamic> data) {
    final requiredFields = [
      'share_id', 'job_id', 'sharer_user_id', 
      'share_method', 'created_at'
    ];
    
    return requiredFields.every((field) => data.containsKey(field)) &&
           ['email', 'sms', 'in_app'].contains(data['share_method']);
  }
}