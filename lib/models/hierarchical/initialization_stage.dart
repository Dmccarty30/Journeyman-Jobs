import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Comprehensive initialization stage system for Flutter app startup sequence.
///
/// This enum defines the complete initialization pipeline with hierarchical levels,
/// dependency relationships, and parallel execution capabilities.
///
/// Architecture Levels:
/// - Level 0: Core infrastructure (Firebase, Auth, Sessions)
/// - Level 1: User data (Profile, Preferences)
/// - Level 2: Core data (Locals, Jobs)
/// - Level 3: Features (Crew, Weather, Notifications)
/// - Level 4: Advanced (Sync, Background, Analytics)
enum InitializationStage {
  // ========================================
  // LEVEL 0: CORE INFRASTRUCTURE
  // ========================================

  /// Firebase Core initialization - Firestore, Auth, Storage setup
  firebaseCore(0, 'Firebase Services', 'Initialize Firebase core services including Firestore, Authentication, and Storage', 800, true, false),

  /// Authentication service initialization - Firebase Auth, session management
  authentication(0, 'Authentication', 'Set up authentication services and verify user session', 1200, true, false),

  /// Session management initialization - Token refresh, session state
  sessionManagement(0, 'Session Management', 'Initialize session state management and token refresh handlers', 600, true, false),

  // ========================================
  // LEVEL 1: USER DATA
  // ========================================

  /// User profile loading - Personal data, preferences, history
  userProfile(1, 'User Profile', 'Load user profile data and personal information', 500, true, true),

  /// User preferences loading - Settings, customization options
  userPreferences(1, 'User Preferences', 'Load user preferences and app customization settings', 300, false, true),

  // ========================================
  // LEVEL 2: CORE DATA
  // ========================================

  /// Locals directory initialization - IBEW locals data
  localsDirectory(2, 'Locals Directory', 'Initialize IBEW locals directory with contact information', 1500, true, true),

  /// Jobs data loading - Job listings, search index
  jobsData(2, 'Jobs Data', 'Load job listings and initialize search capabilities', 2000, true, true),

  // ========================================
  // LEVEL 3: FEATURES
  // ========================================

  /// Crew features initialization - Team management, sharing
  crewFeatures(3, 'Crew Features', 'Initialize crew management and job sharing features', 800, false, true),

  /// Weather services initialization - NOAA data, alerts
  weatherServices(3, 'Weather Services', 'Initialize weather services and storm tracking', 600, false, true),

  /// Notifications initialization - Push notifications, alerts
  notifications(3, 'Notifications', 'Initialize push notification services and alert system', 400, false, true),

  // ========================================
  // LEVEL 4: ADVANCED
  // ========================================

  /// Offline sync initialization - Data synchronization
  offlineSync(4, 'Offline Sync', 'Initialize offline data synchronization capabilities', 1000, false, true),

  /// Background tasks initialization - Periodic updates
  backgroundTasks(4, 'Background Tasks', 'Initialize background task processing and periodic updates', 300, false, true),

  /// Analytics initialization - Performance tracking
  analytics(4, 'Analytics', 'Initialize analytics and performance monitoring', 200, false, true);

  const InitializationStage(
    this.level,
    this.displayName,
    this.description,
    this.estimatedMs,
    this.isCritical,
    this.canRunInParallel,
  );

  /// Hierarchical level in the initialization pipeline (0-4)
  final int level;

  /// Human-readable display name for UI
  final String displayName;

  /// Detailed description of what this stage does
  final String description;

  /// Estimated execution time in milliseconds
  final int estimatedMs;

  /// Whether this stage is critical for app functionality
  final bool isCritical;

  /// Whether this stage can run in parallel with others at the same level
  final bool canRunInParallel;

  /// Gets stages that this stage depends on
  List<InitializationStage> get dependsOn {
    switch (this) {
      case InitializationStage.authentication:
        return [InitializationStage.firebaseCore];
      case InitializationStage.sessionManagement:
        return [InitializationStage.authentication];
      case InitializationStage.userProfile:
      case InitializationStage.userPreferences:
        return [InitializationStage.sessionManagement];
      case InitializationStage.localsDirectory:
      case InitializationStage.jobsData:
        return [InitializationStage.userProfile];
      case InitializationStage.crewFeatures:
      case InitializationStage.weatherServices:
      case InitializationStage.notifications:
        return [InitializationStage.localsDirectory, InitializationStage.jobsData];
      case InitializationStage.offlineSync:
      case InitializationStage.backgroundTasks:
      case InitializationStage.analytics:
        return [InitializationStage.crewFeatures, InitializationStage.weatherServices];
      case InitializationStage.firebaseCore:
      default:
        return [];
    }
  }

  /// Gets stages that depend on this stage
  List<InitializationStage> get requiredFor {
    switch (this) {
      case InitializationStage.firebaseCore:
        return [InitializationStage.authentication];
      case InitializationStage.authentication:
        return [InitializationStage.sessionManagement];
      case InitializationStage.sessionManagement:
        return [InitializationStage.userProfile, InitializationStage.userPreferences];
      case InitializationStage.userProfile:
        return [InitializationStage.localsDirectory, InitializationStage.jobsData];
      case InitializationStage.userPreferences:
        return [];
      case InitializationStage.localsDirectory:
        return [InitializationStage.crewFeatures, InitializationStage.weatherServices, InitializationStage.notifications];
      case InitializationStage.jobsData:
        return [InitializationStage.crewFeatures, InitializationStage.weatherServices, InitializationStage.notifications];
      case InitializationStage.crewFeatures:
        return [InitializationStage.offlineSync, InitializationStage.backgroundTasks, InitializationStage.analytics];
      case InitializationStage.weatherServices:
        return [InitializationStage.offlineSync, InitializationStage.backgroundTasks, InitializationStage.analytics];
      case InitializationStage.notifications:
        return [];
      case InitializationStage.offlineSync:
        return [];
      case InitializationStage.backgroundTasks:
        return [];
      case InitializationStage.analytics:
        return [];
    }
  }

  /// Gets the estimated duration as a Duration object
  Duration get estimatedDuration => Duration(milliseconds: estimatedMs);

  /// Check if this stage can be executed given the completed stages
  bool canExecute(Set<InitializationStage> completedStages) {
    for (final dependency in dependsOn) {
      if (!completedStages.contains(dependency)) {
        return false;
      }
    }
    return true;
  }

  /// Gets stages at the same level that can run in parallel
  List<InitializationStage> get parallelStages {
    return InitializationStage.values
        .where((stage) => stage.level == level && stage != this && stage.canRunInParallel)
        .toList();
  }

  /// Gets the initialization group name based on level
  String get groupName {
    switch (level) {
      case 0:
        return 'Core Infrastructure';
      case 1:
        return 'User Data';
      case 2:
        return 'Core Data';
      case 3:
        return 'Features';
      case 4:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }

  /// Gets the category for UI organization
  InitializationCategory get category {
    switch (level) {
      case 0:
        return InitializationCategory.infrastructure;
      case 1:
        return InitializationCategory.userData;
      case 2:
        return InitializationCategory.coreData;
      case 3:
        return InitializationCategory.features;
      case 4:
        return InitializationCategory.advanced;
      default:
        return InitializationCategory.infrastructure;
    }
  }

  /// Priority for stage execution (higher = more important)
  int get priority {
    switch (this) {
      case InitializationStage.firebaseCore:
        return 100;
      case InitializationStage.authentication:
        return 95;
      case InitializationStage.sessionManagement:
        return 90;
      case InitializationStage.userProfile:
        return 80;
      case InitializationStage.userPreferences:
        return 75;
      case InitializationStage.localsDirectory:
        return 70;
      case InitializationStage.jobsData:
        return 65;
      case InitializationStage.crewFeatures:
        return 50;
      case InitializationStage.weatherServices:
        return 45;
      case InitializationStage.notifications:
        return 40;
      case InitializationStage.offlineSync:
        return 30;
      case InitializationStage.backgroundTasks:
        return 25;
      case InitializationStage.analytics:
        return 20;
    }
  }

  /// Checks if this stage depends on another stage
  bool dependsOnStage(InitializationStage other) {
    return dependsOn.contains(other);
  }

  /// Category getters for quick type checking
  bool get isInfrastructure => level == 0;
  bool get isDataStage => level == 1 || level == 2;
  bool get isFeatureStage => level == 3;
  bool get isAdvancedStage => level == 4;

  /// Gets all stages that depend on this stage (transitively)
  List<InitializationStage> get allDependents {
    final directDependents = requiredFor.toList();
    final allDependents = <InitializationStage>{};

    void collectDependents(InitializationStage stage) {
      for (final dependent in stage.requiredFor) {
        if (allDependents.add(dependent)) {
          collectDependents(dependent);
        }
      }
    }

    for (final dependent in directDependents) {
      collectDependents(dependent);
    }

    return allDependents.toList();
  }

  @override
  String toString() => displayName;
}

/// Stage status enumeration
enum StageStatus {
  pending,
  inProgress,
  completed,
  failed,
  skipped,
}

/// Stage execution result containing timing and outcome information
@immutable
class StageExecutionResult {
  const StageExecutionResult({
    required this.stage,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.data,
    this.metrics,
    this.error,
    this.stackTrace,
  });

  final InitializationStage stage;
  final StageStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final dynamic? data;
  final StageMetrics? metrics;
  final String? error;
  final StackTrace? stackTrace;

  Duration get duration => endTime.difference(startTime);
  bool get isSuccess => status == StageStatus.completed;
  bool get isFailure => status == StageStatus.failed;
  bool get isSkipped => status == StageStatus.skipped;

  @override
  String toString() {
    return 'StageExecutionResult('
        'stage: $stage, '
        'status: $status, '
        'duration: ${duration.inMilliseconds}ms'
        '${data != null ? ', data: $data' : ''}'
        '${error != null ? ', error: $error' : ''}'
        ')';
  }
}

/// Initialization category enumeration
enum InitializationCategory {
  infrastructure,
  userData,
  coreData,
  features,
  advanced,
}

/// Stage performance metrics
@immutable
class StageMetrics {
  const StageMetrics({
    required this.stage,
    this.memoryUsageMB,
    this.networkRequests,
    this.cacheHits,
    this.customMetrics,
  });

  final InitializationStage stage;
  final double? memoryUsageMB;
  final int? networkRequests;
  final int? cacheHits;
  final Map<String, dynamic>? customMetrics;

  @override
  String toString() {
    return 'StageMetrics('
        'stage: $stage, '
        'memory: ${memoryUsageMB?.toStringAsFixed(1) ?? 'N/A'}MB, '
        'requests: ${networkRequests ?? 'N/A'}, '
        'cacheHits: ${cacheHits ?? 'N/A'}'
        ')';
  }
}