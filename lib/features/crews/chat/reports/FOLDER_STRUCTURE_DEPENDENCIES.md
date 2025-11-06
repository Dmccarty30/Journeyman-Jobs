# Folder Structure and Dependencies Checklist

## 📁 Complete Folder Structure

```
lib/features/crews/
├── domain/                              # Business Logic Layer
│   ├── models/                         # Core entities
│   │   ├── crew_channel.dart           # Channel model with permissions
│   │   ├── crew_message.dart           # Message model with reactions
│   │   ├── crew_user.dart              # User model with electrical fields
│   │   ├── enums.dart                  # All enums (ChannelType, MessageType, etc.)
│   │   ├── job_attachment.dart         # Job sharing model
│   │   ├── safety_alert.dart           # Safety alert model
│   │   ├── location_share.dart         # Location sharing model
│   │   ├── notification.dart           # Notification model
│   │   ├── feed_post.dart              # Feed post model
│   │   └── electrical_reactions.dart   # Custom reaction definitions
│   ├── usecases/                       # Business operations
│   │   ├── messaging/
│   │   │   ├── send_message_usecase.dart
│   │   │   ├── create_channel_usecase.dart
│   │   │   ├── manage_members_usecase.dart
│   │   │   ├── mark_messages_read_usecase.dart
│   │   │   ├── delete_message_usecase.dart
│   │   │   └── search_messages_usecase.dart
│   │   ├── feed/
│   │   │   ├── publish_to_feed_usecase.dart
│   │   │   ├── moderate_feed_usecase.dart
│   │   │   ├── get_feed_posts_usecase.dart
│   │   │   └── delete_feed_post_usecase.dart
│   │   ├── notifications/
│   │   │   ├── send_notification_usecase.dart
│   │   │   ├── device_token_usecase.dart
│   │   │   ├── handle_safety_alert_usecase.dart
│   │   │   └── notification_preferences_usecase.dart
│   │   ├── jobs/
│   │   │   ├── share_job_usecase.dart
│   │   │   ├── create_job_attachment_usecase.dart
│   │   │   ├── apply_for_job_usecase.dart
│   │   │   └── job_search_usecase.dart
│   │   ├── safety/
│   │   │   ├── create_safety_alert_usecase.dart
│   │   │   ├── acknowledge_alert_usecase.dart
│   │   │   ├── escalate_alert_usecase.dart
│   │   │   └── safety_report_usecase.dart
│   │   └── location/
│   │       ├── share_location_usecase.dart
│   │       ├── get_nearby_crews_usecase.dart
│   │       ├── check_in_usecase.dart
│   │       └── location_history_usecase.dart
│   ├── repositories/                     # Abstract interfaces
│   │   ├── chat_repository.dart         # Chat operations interface
│   │   ├── feed_repository.dart         # Feed operations interface
│   │   ├── notification_repository.dart # Notification operations interface
│   │   ├── crew_repository.dart         # Crew management interface
│   │   ├── job_repository.dart          # Job operations interface
│   │   ├── safety_repository.dart       # Safety operations interface
│   │   ├── location_repository.dart     # Location operations interface
│   │   └── user_repository.dart         # User operations interface
│   └── exceptions/                      # Custom exceptions
│       ├── crew_exceptions.dart
│       ├── chat_exceptions.dart
│       ├── feed_exceptions.dart
│       ├── notification_exceptions.dart
│       ├── safety_exceptions.dart
│       ├── location_exceptions.dart
│       └── validation_exceptions.dart
├── data/                               # Data Layer
│   ├── repositories/                    # Repository implementations
│   │   ├── chat_repository_impl.dart
│   │   ├── feed_repository_impl.dart
│   │   ├── notification_repository_impl.dart
│   │   ├── crew_repository_impl.dart
│   │   ├── job_repository_impl.dart
│   │   ├── safety_repository_impl.dart
│   │   ├── location_repository_impl.dart
│   │   └── user_repository_impl.dart
│   ├── services/                        # External service integrations
│   │   ├── stream_chat_service.dart     # Stream Chat integration
│   │   ├── firebase_messaging_service.dart # FCM integration
│   │   ├── storage_service.dart         # File storage service
│   │   ├── location_service.dart        # GPS/location service
│   │   ├── notification_service.dart    # Push notification service
│   │   ├── image_service.dart           # Image processing
│   │   ├── encryption_service.dart      # Encryption utilities
│   │   ├── safety_alert_service.dart    # Safety alert handling
│   │   └── job_sharing_service.dart    # Job sharing logic
│   ├── datasources/                     # Data sources
│   │   ├── local/
│   │   │   ├── secure_storage_datasource.dart # Secure storage
│   │   │   ├── local_cache_datasource.dart   # Local caching
│   │   │   ├── sqlite_database.dart          # Local database
│   │   │   └── shared_preferences_datasource.dart
│   │   └── remote/
│   │       ├── stream_chat_datasource.dart  # Stream Chat API
│   │       ├── firebase_datasource.dart      # Firebase APIs
│   │       ├── crew_api_datasource.dart      # Crew API
│   │       ├── weather_api_datasource.dart   # Weather API
│   │       └── maps_api_datasource.dart      # Maps API
│   └── dto/                              # Data transfer objects
│       ├── message_dto.dart             # Message data conversion
│       ├── channel_dto.dart             # Channel data conversion
│       ├── user_dto.dart                # User data conversion
│       ├── job_attachment_dto.dart      # Job attachment conversion
│       ├── safety_alert_dto.dart        # Safety alert conversion
│       ├── location_dto.dart             # Location data conversion
│       ├── notification_dto.dart        # Notification conversion
│       └── feed_post_dto.dart           # Feed post conversion
├── presentation/                        # UI Layer
│   ├── screens/                         # Main screens
│   │   ├── messaging/
│   │   │   ├── chat_list_screen.dart     # Main chat list
│   │   │   ├── chat_screen.dart          # Individual chat
│   │   │   ├── direct_message_screen.dart # Direct messages
│   │   │   ├── new_chat_screen.dart      # Create new chat
│   │   │   └── chat_settings_screen.dart # Chat settings
│   │   ├── crew/
│   │   │   ├── crew_chat_screen.dart      # Crew chat
│   │   │   ├── crew_management_screen.dart # Crew management
│   │   │   ├── create_crew_screen.dart    # Create crew
│   │   │   ├── crew_directory_screen.dart # Crew directory
│   │   │   ├── crew_settings_screen.dart  # Crew settings
│   │   │   ├── invite_members_screen.dart # Invite members
│   │   │   └── crew_profile_screen.dart   # Crew profile
│   │   ├── feed/
│   │   │   ├── feed_screen.dart           # Main feed
│   │   │   ├── feed_post_screen.dart      # Create post
│   │   │   ├── feed_mod_screen.dart       # Moderation
│   │   │   ├── create_feed_post_screen.dart
│   │   │   └── feed_settings_screen.dart
│   │   ├── notifications/
│   │   │   ├── notifications_screen.dart   # Notifications list
│   │   │   ├── notification_settings_screen.dart # Settings
│   │   │   └── safety_alerts_screen.dart  # Safety alerts
│   │   ├── safety/
│   │   │   ├── safety_alert_screen.dart    # Create alert
│   │   │   ├── safety_report_screen.dart   # Safety reports
│   │   │   └── emergency_contacts_screen.dart
│   │   ├── jobs/
│   │   │   ├── job_share_screen.dart       # Share job
│   │   │   ├── job_application_screen.dart  # Applications
│   │   │   └── job_recommendations_screen.dart
│   │   └── location/
│   │       ├── location_share_screen.dart  # Share location
│   │       ├── job_site_screen.dart        # Job sites
│   │       ├── crew_map_screen.dart        # Crew map
│   │       └── check_in_screen.dart        # Check-in/out
│   ├── widgets/                          # Reusable components
│   │   ├── message/
│   │   │   ├── message_bubble.dart         # Message bubble
│   │   │   ├── message_input.dart          # Message input
│   │   │   ├── attachment_preview.dart    # Attachment preview
│   │   │   ├── reaction_bar.dart          # Reaction bar
│   │   │   ├── message_status_indicator.dart # Status indicator
│   │   │   ├── typing_indicator.dart      # Typing indicator
│   │   │   ├── message_options_sheet.dart # Message options
│   │   │   └── thread_indicator.dart      # Thread indicator
│   │   ├── channel/
│   │   │   ├── channel_tile.dart          # Channel list item
│   │   │   ├── channel_header.dart        # Chat header
│   │   │   ├── channel_list_view.dart     # Channel list
│   │   │   ├── channel_settings.dart      # Channel settings
│   │   │   ├── create_channel_dialog.dart # Create dialog
│   │   │   └── channel_search_bar.dart    # Search bar
│   │   ├── crew/
│   │   │   ├── crew_card.dart             # Crew card
│   │   │   ├── crew_member_tile.dart      # Member tile
│   │   │   ├── crew_avatar.dart           # Crew avatar
│   │   │   ├── crew_status_indicator.dart # Status indicator
│   │   │   ├── crew_role_badge.dart       # Role badge
│   │   │   ├── member_list_widget.dart    # Member list
│   │   │   └── invite_member_widget.dart  # Invite widget
│   │   ├── feed/
│   │   │   ├── feed_post_card.dart        # Feed post card
│   │   │   ├── feed_filter_chips.dart     # Filter chips
│   │   │   ├── feed_moderation_tools.dart # Moderation tools
│   │   │   ├── feed_post_creator.dart    # Post creator
│   │   │   └── feed_comment_widget.dart  # Comment widget
│   │   ├── attachments/
│   │   │   ├── image_attachment.dart      # Image attachment
│   │   │   ├── document_attachment.dart   # Document attachment
│   │   │   ├── job_attachment.dart        # Job attachment
│   │   │   ├── safety_alert_attachment.dart # Safety alert
│   │   │   ├── location_attachment.dart   # Location attachment
│   │   │   ├── attachment_upload_widget.dart # Upload widget
│   │   │   └── attachment_preview_grid.dart # Preview grid
│   │   ├── reactions/
│   │   │   ├── reaction_picker.dart       # Reaction picker
│   │   │   ├── reaction_display.dart      # Reaction display
│   │   │   ├── electrical_reactions.dart  # Electrical emojis
│   │   │   └── reaction_animation.dart   # Reaction animation
│   │   ├── common/
│   │   │   ├── online_indicator.dart      # Online status
│   │   │   ├── loading_indicator.dart     # Loading spinner
│   │   │   ├── error_widget.dart         # Error display
│   │   │   ├── empty_state_widget.dart   # Empty state
│   │   │   ├── search_bar.dart           # Search bar
│   │   │   ├── pull_to_refresh.dart      # Pull to refresh
│   │   │   ├── loading_shimmer.dart      # Shimmer effect
│   │   │   └── network_status_bar.dart   # Network status
│   │   ├── electrical/
│   │   │   ├── electrical_reactions.dart  # Custom reactions
│   │   │   ├── safety_alert_banner.dart   # Alert banner
│   │   │   ├── job_sharing_card.dart     # Job sharing card
│   │   │   ├── location_share_widget.dart # Location widget
│   │   │   ├── circuit_pattern_background.dart # Circuit background
│   │   │   ├── lightning_animation.dart  # Lightning effect
│   │   │   ├── power_indicator.dart      # Power indicator
│   │   │   └── voltage_color_indicator.dart # Voltage indicator
│   │   ├── input/
│   │   │   ├── enhanced_text_input.dart   # Enhanced input
│   │   │   ├── voice_recorder_widget.dart # Voice recorder
│   │   │   ├── attachment_button.dart    # Attachment button
│   │   │   ├── emoji_picker.dart         # Emoji picker
│   │   │   └── command_input.dart        # Command input
│   │   └── overlays/
│   │       ├── message_options_overlay.dart # Message options
│   │       ├── attachment_options_overlay.dart # Attachment options
│   │       ├── crew_actions_overlay.dart  # Crew actions
│   │       ├── safety_alert_overlay.dart  # Safety alert overlay
│   │       └── location_picker_overlay.dart # Location picker
│   ├── providers/                        # State management
│   │   ├── chat_provider.dart            # Chat state
│   │   ├── crew_provider.dart            # Crew state
│   │   ├── feed_provider.dart            # Feed state
│   │   ├── notification_provider.dart    # Notification state
│   │   ├── auth_provider.dart            # Auth state
│   │   ├── settings_provider.dart        # Settings state
│   │   ├── location_provider.dart        # Location state
│   │   ├── safety_provider.dart          # Safety state
│   │   └── job_provider.dart             # Job state
│   ├── cubits/                           # Cubit state management
│   │   ├── chat_cubit.dart               # Chat cubit
│   │   ├── message_input_cubit.dart      # Message input cubit
│   │   ├── channel_list_cubit.dart       # Channel list cubit
│   │   ├── crew_cubit.dart               # Crew cubit
│   │   ├── feed_cubit.dart               # Feed cubit
│   │   ├── notification_cubit.dart       # Notification cubit
│   │   ├── safety_alert_cubit.dart       # Safety alert cubit
│   │   └── location_cubit.dart           # Location cubit
│   └── shared/                           # Shared UI utilities
│       ├── navigation/
│       │   ├── chat_routes.dart           # Chat routes
│       │   ├── navigation_service.dart    # Navigation helper
│       │   ├── deep_link_handler.dart     # Deep links
│       │   └── route_guard.dart          # Route guards
│       ├── theme/
│       │   ├── chat_theme.dart            # Chat theme
│       │   ├── electrical_colors.dart     # Electrical colors
│       │   ├── dark_theme.dart           # Dark theme
│       │   └── theme_extensions.dart     # Theme extensions
│       ├── utils/
│       │   ├── date_formatter.dart        # Date formatting
│       │   ├── message_helper.dart       # Message utilities
│       │   ├── permission_handler.dart    # Permission handler
│       │   ├── file_utils.dart           # File utilities
│       │   ├── image_utils.dart          # Image utilities
│       │   ├── validation_utils.dart      # Validation
│       │   ├── encryption_utils.dart      # Encryption
│       │   └── network_utils.dart        # Network utilities
│       ├── constants/
│       │   ├── chat_constants.dart        # Chat constants
│       │   ├── notification_constants.dart # Notification constants
│       │   ├── api_endpoints.dart        # API endpoints
│       │   ├── app_constants.dart        # App constants
│       │   ├── design_constants.dart     # Design constants
│       │   └── electrical_constants.dart # Electrical constants
│       └── extensions/
│           ├── string_extensions.dart     # String extensions
│           ├── datetime_extensions.dart   # DateTime extensions
│           ├── context_extensions.dart    # Context extensions
│           └── widget_extensions.dart     # Widget extensions
└── _external/                          # External integrations
    ├── stream_chat/                     # Stream Chat specific
    │   ├── stream_chat_client.dart       # Client wrapper
    │   ├── stream_chat_config.dart       # Configuration
    │   ├── stream_chat_theme.dart        # Theme
    │   ├── stream_chat_extensions.dart   # Extensions
    │   └── stream_chat_webhook_handler.dart # Webhooks
    ├── firebase/                         # Firebase specific
    │   ├── firebase_config.dart          # Configuration
    │   ├── firebase_messaging_handler.dart # Messaging handler
    │   ├── firebase_functions_handler.dart # Functions handler
    │   ├── firebase_security_rules.txt   # Security rules
    │   └── firebase_collections.dart     # Collection definitions
    ├── constants/                        # External constants
    │   ├── stream_chat_constants.dart    # Stream Chat constants
    │   ├── firebase_constants.dart       # Firebase constants
    │   ├── api_keys.dart                 # API keys (template)
    │   └── environment_constants.dart    # Environment variables
    └── adapters/                         # External adapters
        ├── stream_chat_adapter.dart      # Stream Chat adapter
        ├── firebase_adapter.dart         # Firebase adapter
        ├── location_adapter.dart         # Location adapter
        ├── notification_adapter.dart     # Notification adapter
        └── storage_adapter.dart          # Storage adapter
```

## 📦 Dependencies Checklist

### Core Dependencies

```yaml
# Add to pubspec.yaml

dependencies:
  # Chat & Real-time
  stream_chat_flutter: ^6.0.0
  stream_chat_persistence: ^5.0.0
  stream_chat_localizations: ^6.0.0

  # State Management
  provider: ^6.0.0
  flutter_bloc: ^8.1.0
  equatable: ^2.0.5

  # Navigation
  go_router: ^12.0.0

  # Firebase Integration
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  firebase_messaging: ^14.7.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_functions: ^4.6.0

  # Security & Storage
  flutter_secure_storage: ^8.0.0
  crypto: ^3.0.3
  local_auth: ^2.1.6

  # UI & Media
  image_picker: ^1.0.0
  file_picker: ^6.0.0
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0

  # Image Processing
  image: ^4.0.17

  # Permissions
  permission_handler: ^11.0.0

  # Location & Maps
  geolocator: ^10.1.0
  geocoding: ^2.1.0
  google_maps_flutter: ^2.5.0
  flutter_polyline_points: ^2.0.0

  # HTTP & Networking
  dio: ^5.3.0
  http: ^1.1.0
  connectivity_plus: ^5.0.0

  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0
  path_provider: ^2.1.0
  path: ^1.8.3
  url_launcher: ^6.2.0
  share_plus: ^7.2.0

  # Date & Time
  timezone: ^0.9.2

  # Local Database
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2

  # Animation
  flutter_animate: ^4.5.0

  # JSON Serialization
  json_annotation: ^4.8.1

  # Logging
  logger: ^2.0.2+1

  # Device Info
  device_info_plus: ^9.1.1
  package_info_plus: ^4.2.0

dev_dependencies:
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
  golden_toolkit: ^0.15.0

  # Code Generation
  build_runner: ^2.4.0
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.0

  # Linting & Formatting
  flutter_lints: ^3.0.0
  very_good_analysis: ^5.1.0

  # Documentation
  dartdoc: ^6.3.0
```

### Environment Variables

Create `.env` file in project root:

```bash
# Stream Chat Configuration
STREAM_CHAT_API_KEY=your_stream_chat_api_key
STREAM_CHAT_APP_ID=your_stream_chat_app_id
STREAM_CHAT_SECRET=your_stream_chat_secret

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# API Endpoints
API_BASE_URL=https://api.journeyman-jobs.com
WEATHER_API_URL=https://api.weather.gov

# Environment
FLUTTER_ENV=development
```

### Platform Configuration

#### Android (android/app/build.gradle)

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

#### iOS (ios/Runner/Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to share job sites and find nearby crew members.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track job site check-ins and provide safety alerts.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to share photos of job sites and work conditions.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to share images and documents with your crew.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice messages and safety reports.</string>
<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
    <string>background-processing</string>
    <string>remote-notification</string>
</array>
```

## 🔧 Setup Checklist

### Phase 1 Setup (Day 1)

1. **Dependencies Installation**
   - [ ] Run `flutter pub get`
   - [ ] Verify all dependencies install without conflicts
   - [ ] Check for version conflicts
   - [ ] Update `analysis_options.yaml`

2. **Project Structure**
   - [ ] Create all folders according to structure
   - [ ] Add placeholder files for each component
   - [ ] Update imports in existing files
   - [ ] Verify folder structure matches blueprint

3. **Environment Configuration**
   - [ ] Create `.env` file
   - [ ] Add all required environment variables
   - [ ] Add `.env` to `.gitignore`
   - [ ] Test environment variable loading

### Phase 2 Setup (Day 2-3)

1. **Stream Chat Setup**
   - [ ] Create Stream Chat account
   - [ ] Generate API keys
   - [ ] Configure app settings
   - [ ] Set up user authentication
   - [ ] Test basic connection

2. **Firebase Setup**
   - [ ] Create Firebase project
   - [ ] Add Android/iOS apps
   - [ ] Download config files
   - [ ] Enable Cloud Messaging
   - [ ] Configure Firestore security rules
   - [ ] Set up Storage buckets

3. **Code Generation**
   - [ ] Run `flutter packages pub run build_runner build`
   - [ ] Verify generated files
   - [ ] Add to watch mode if needed
   - [ ] Check for compilation errors

### Phase 3 Setup (Day 4-5)

1. **Testing Configuration**
   - [ ] Configure test environment
   - [ ] Create test utilities
   - [ ] Set up mock services
   - [ ] Write initial tests

2. **CI/CD Setup**
   - [ ] Configure GitHub Actions
   - [ ] Set up build pipelines
   - [ ] Configure test automation
   - [ ] Set up deployment workflows

3. **Documentation**
   - [ ] Create README for chat module
   - [ ] Document API endpoints
   - [ ] Write developer guide
   - [ ] Create user documentation

## 📋 Verification Checklist

### Pre-Development Verification

- [ ] All dependencies installed successfully
- [ ] Project structure created correctly
- [ ] Environment variables configured
- [ ] Stream Chat account active
- [ ] Firebase project configured
- [ ] Code generation working
- [ ] Tests can run
- [ ] App builds without errors

### Post-Development Verification

- [ ] All features working as specified
- [ ] Tests passing (80% coverage minimum)
- [ ] Performance benchmarks met
- [ ] Security requirements satisfied
- [ ] Documentation complete
- [ ] Deployment ready
- [ ] User acceptance received

## 🚨 Common Issues and Solutions

### 1. Stream Chat Connection Issues

**Problem**: Unable to connect to Stream Chat
**Solution**:
- Verify API keys are correct
- Check network connectivity
- Ensure user is authenticated
- Check token format and validity

### 2. Firebase Configuration Issues

**Problem**: Firebase not initializing
**Solution**:
- Verify `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Check Firebase project settings
- Ensure package/bundle ID matches
- Verify Firebase initialization in main.dart

### 3. Permission Issues

**Problem**: Location/Camera permissions not working
**Solution**:
- Add permissions to Info.plist (iOS) and AndroidManifest.xml (Android)
- Check permission request flow
- Verify permission strings are user-friendly
- Test on physical device

### 4. Build Issues

**Problem**: Build failures after adding dependencies
**Solution**:
- Run `flutter clean`
- Delete `.dart_tool` and `build` folders
- Run `flutter pub get` again
- Check for version conflicts
- Update Flutter SDK if needed

### 5. Performance Issues

**Problem**: App is slow or memory heavy
**Solution**:
- Profile with Flutter Inspector
- Optimize image loading with caching
- Use const widgets where possible
- Implement lazy loading for lists
- Reduce unnecessary rebuilds

---

This comprehensive folder structure and dependencies checklist ensures a smooth setup process and provides a clear reference for maintaining the project structure as it evolves.