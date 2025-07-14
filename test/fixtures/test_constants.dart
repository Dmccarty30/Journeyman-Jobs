/// Test constants and configuration values
class TestConstants {
  // Test Environment Configuration
  static const String testEnvironment = 'test';
  static const bool enableDebugLogs = false;
  static const bool mockFirebase = true;

  // Timeouts
  static const Duration microTimeout = Duration(milliseconds: 100);
  static const Duration shortTimeout = Duration(seconds: 2);
  static const Duration mediumTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 10);
  static const Duration veryLongTimeout = Duration(seconds: 30);

  // Widget Test Keys
  static const String appKey = 'journeyman-jobs-app';
  static const String homeScreenKey = 'home-screen';
  static const String jobsScreenKey = 'jobs-screen';
  static const String localsScreenKey = 'locals-screen';
  static const String settingsScreenKey = 'settings-screen';
  static const String authScreenKey = 'auth-screen';
  static const String splashScreenKey = 'splash-screen';

  // Component Keys
  static const String jobCardKey = 'job-card';
  static const String localCardKey = 'local-card';
  static const String jobCardPrefix = 'job-card-';
  static const String localCardPrefix = 'local-card-';
  static const String filterButtonKey = 'filter-button';
  static const String searchBarKey = 'search-bar';
  static const String navigationBarKey = 'navigation-bar';

  // Electrical Component Keys
  static const String circuitBreakerSwitchKey = 'circuit-breaker-switch';
  static const String circuitBreakerListTileKey = 'circuit-breaker-list-tile';
  static const String electricalLoaderKey = 'electrical-loader';
  static const String powerLineLoaderKey = 'power-line-loader';
  static const String threePhaseLoaderKey = 'three-phase-loader';
  static const String electricalToastKey = 'electrical-toast';
  static const String hardHatIconKey = 'hard-hat-icon';
  static const String transmissionTowerKey = 'transmission-tower-icon';

  // Form Keys
  static const String loginFormKey = 'login-form';
  static const String registerFormKey = 'register-form';
  static const String emailFieldKey = 'email-field';
  static const String passwordFieldKey = 'password-field';
  static const String confirmPasswordFieldKey = 'confirm-password-field';
  static const String submitButtonKey = 'submit-button';

  // Loading and Error States
  static const String loadingIndicatorKey = 'loading-indicator';
  static const String errorMessageKey = 'error-message';
  static const String emptyStateKey = 'empty-state';
  static const String retryButtonKey = 'retry-button';
  static const String refreshIndicatorKey = 'refresh-indicator';

  // Test Data Constants
  static const String testEmail = 'test@ibew.local';
  static const String testPassword = 'TestPassword123!';
  static const String testUserId = 'test-user-12345';
  static const String testUserName = 'Test Electrician';
  static const int testLocalNumber = 123;
  static const String testClassification = 'Inside Wireman';

  // Firebase Collections (Test)
  static const String jobsCollection = 'jobs_test';
  static const String localsCollection = 'locals_test';
  static const String usersCollection = 'users_test';
  static const String notificationsCollection = 'notifications_test';
  static const String preferencesCollection = 'preferences_test';

  // API Endpoints (Mock)
  static const String baseApiUrl = 'https://test-api.journeymanjobs.com';
  static const String authEndpoint = '/auth';
  static const String jobsEndpoint = '/jobs';
  static const String localsEndpoint = '/locals';
  static const String notificationsEndpoint = '/notifications';

  // Error Messages
  static const String networkErrorMessage = 'Network connection failed';
  static const String authErrorMessage = 'Authentication failed';
  static const String invalidCredentialsMessage = 'Invalid email or password';
  static const String firestoreErrorMessage = 'Database operation failed';
  static const String permissionErrorMessage = 'Permission denied';
  static const String timeoutErrorMessage = 'Operation timed out';
  static const String genericErrorMessage = 'An unexpected error occurred';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String registrationSuccessMessage = 'Registration successful';
  static const String dataLoadedMessage = 'Data loaded successfully';
  static const String dataSavedMessage = 'Data saved successfully';

  // Electrical Industry Constants
  static const List<String> ibewClassifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
    'Low Voltage Technician',
    'Sound Technician',
    'Maintenance Electrician',
    'Utility Worker',
  ];

  static const List<String> constructionTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Utility',
    'Maintenance',
    'Storm Work',
    'Emergency Restoration',
  ];

  static const List<int> commonIBEWLocals = [
    1, 3, 11, 26, 46, 58, 98, 134, 146, 176, 191, 212, 292, 332, 353, 369,
    424, 441, 453, 474, 488, 520, 558, 569, 595, 611, 640, 659, 683, 697,
    714, 728, 760, 776, 817, 852, 876, 915, 934, 953, 993
  ];

  static const Map<String, String> stateAbbreviations = {
    'Alabama': 'AL',
    'Alaska': 'AK',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Pennsylvania': 'PA',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY',
  };

  // Test Performance Thresholds
  static const int maxRenderTimeMs = 16; // 60 FPS target
  static const int maxLoadTimeMs = 3000; // 3 second load time
  static const int maxMemoryUsageMB = 256; // 256 MB memory limit
  static const int maxCacheItems = 1000; // Cache size limit

  // Test Scroll Constants
  static const double scrollDelta = 300.0;
  static const int maxScrollAttempts = 10;
  static const Duration scrollTimeout = Duration(seconds: 2);

  // Animation Test Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration microAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Network Simulation
  static const Duration networkDelay = Duration(milliseconds: 500);
  static const Duration slowNetworkDelay = Duration(seconds: 2);
  static const Duration timeoutDelay = Duration(seconds: 10);

  // Test User Permissions
  static const List<String> basicUserPermissions = [
    'read:jobs',
    'read:locals',
    'update:profile',
  ];

  static const List<String> adminUserPermissions = [
    'read:jobs',
    'write:jobs',
    'read:locals',
    'write:locals',
    'read:users',
    'write:users',
    'delete:jobs',
    'admin:dashboard',
  ];

  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxSearchLength = 100;

  // UI Test Constants
  static const double minTapSize = 44.0; // Accessibility minimum
  static const double maxCardWidth = 400.0;
  static const double minCardWidth = 280.0;
  static const double standardPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;

  // Theme Test Constants
  static const String primaryNavyHex = '#1A202C';
  static const String accentCopperHex = '#B45309';
  static const String backgroundLightHex = '#F7FAFC';
  static const String textPrimaryHex = '#1A202C';

  // Feature Flags for Testing
  static const bool enableElectricalAnimations = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableAnalytics = false; // Disabled in tests
  static const bool enableOfflineMode = true;
  static const bool enableNotifications = false; // Disabled in tests

  // Test Categories
  static const String unitTestCategory = 'unit';
  static const String widgetTestCategory = 'widget';
  static const String integrationTestCategory = 'integration';
  static const String performanceTestCategory = 'performance';
  static const String accessibilityTestCategory = 'accessibility';
}

/// Test environment configuration
class TestEnvironment {
  static const String development = 'dev';
  static const String testing = 'test';
  static const String staging = 'staging';
  static const String production = 'prod';

  static String get current => testing;

  static bool get isTest => current == testing;
  static bool get isDevelopment => current == development;
  static bool get isProduction => current == production;
}

/// Test device configurations
class TestDevices {
  static const Map<String, Map<String, double>> devices = {
    'iphone_se': {'width': 375, 'height': 667, 'devicePixelRatio': 2.0},
    'iphone_12': {'width': 390, 'height': 844, 'devicePixelRatio': 3.0},
    'iphone_12_pro_max': {'width': 428, 'height': 926, 'devicePixelRatio': 3.0},
    'pixel_4': {'width': 393, 'height': 851, 'devicePixelRatio': 2.75},
    'pixel_6': {'width': 411, 'height': 914, 'devicePixelRatio': 2.625},
    'ipad': {'width': 820, 'height': 1180, 'devicePixelRatio': 2.0},
    'ipad_pro': {'width': 1024, 'height': 1366, 'devicePixelRatio': 2.0},
  };
}