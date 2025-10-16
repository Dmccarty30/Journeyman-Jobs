# Journeyman Jobs ⚡

- **IBEW Mobile Application for Electrical Workers**

A comprehensive Flutter application designed to streamline job referrals and storm work opportunities for IBEW (International Brotherhood of Electrical Workers) journeymen, linemen, wiremen, operators, and tree trimmers.

## 🎯 Overview

Journeyman Jobs connects skilled electrical workers with job opportunities across the United States, with special emphasis on emergency storm restoration work. The app provides real-time job listings, union directory access, AI-powered job matching, and critical weather tracking tools for storm response teams.

## ✨ Key Features

### 📱 Core Functionality

- **Smart Job Board**: Browse and filter electrical work opportunities with AI-powered recommendations
- **Storm Work Hub**: Priority listings for emergency power restoration with enhanced compensation
- **Union Directory**: Complete directory of 797+ IBEW locals with contact integration
- **Profile Management**: Maintain certifications, work history, and availability status
- **Real-time Notifications**: Instant alerts for new job postings and storm work opportunities
- **Crew Management**: Organize and manage storm response teams
- **Offline Support**: Full functionality even without internet connection

### 🤖 AI Integration

- **Google Gemini AI**: Intelligent job matching and recommendations
- **Smart Filtering**: AI-powered search and filter optimization
- **Predictive Analytics**: Storm impact prediction and work opportunity forecasting

### 🌩️ Advanced Weather Integration

- **NOAA Weather Radar**: Official US government weather data for storm tracking
- **Live Weather Alerts**: Real-time severe weather warnings from National Weather Service
- **Hurricane Tracking**: National Hurricane Center integration for tropical systems
- **Storm Safety**: Integrated safety protocols and weather-based work recommendations
- **Power Outage Tracking**: Real-time power grid status monitoring

### 🔌 Enhanced Design System

- **Electrical Theme**: Custom electrical components and animations
- **Circuit Patterns**: Dynamic circuit pattern backgrounds
- **Interactive Elements**: Lightning bolt loading indicators and electrical animations
- **Professional UI**: Copper and navy color scheme representing electrical heritage
- **Accessibility**: Full WCAG compliance for all users

## 🛠️ Technology Stack

### Frontend & Core

- **Framework**: Flutter 3.6.0+ with null safety
- **State Management**: Flutter Riverpod with code generation
- **Navigation**: go_router for type-safe routing
- **UI Framework**: Custom design system with shadcn_ui components

### Backend & Services

- **Backend**: Firebase (Authentication, Firestore, Cloud Storage, Cloud Functions)
- **Analytics**: Firebase Analytics, Performance Monitoring, Crashlytics
- **Notifications**: Firebase Cloud Messaging (FCM) with local notifications
- **AI Integration**: Google Generative AI (Gemini)

### External APIs & Data

- **Weather Data**: NOAA/NWS APIs (no API key required)
- **Maps & Location**: flutter_map with OpenStreetMap, Geolocator
- **Authentication**: Google Sign-In, Apple Sign-In

### Development & Quality

- **Testing**: Comprehensive unit, widget, and integration tests
- **Code Quality**: Flutter Lints, static analysis
- **Performance**: Firebase Performance Monitoring
- **CI/CD**: GitHub Actions with automated deployment

## 🚀 Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/journeyman-jobs.git
   cd journeyman-jobs
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at <https://console.firebase.google.com>
   - Add iOS and Android apps to your Firebase project
   - Download and add configuration files:
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Android: `android/app/google-services.json`

4. **Set up environment**

   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Add your configuration values
   ```

5. **Run the app**

   ```bash
   # Run on iOS simulator
   flutter run -d ios
   
   # Run on Android emulator
   flutter run -d android
   ```

## 📱 Platform Configuration

### iOS Setup

The following permissions are configured in `ios/Runner/Info.plist`:

- Location Services (for weather radar and job proximity)
- Camera/Photo Library (for profile pictures)
- Push Notifications (for job alerts)

### Android Setup

The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:

- Fine/Coarse Location
- Internet Access
- Notification permissions
- Camera and Storage

## 🏗️ Project Structure

```dart
journeyman-jobs/
├── lib/                                    # Main Flutter application
│   ├── main.dart                          # App entry point with Firebase initialization
│   ├── main_riverpod.dart                 # Riverpod-specific app entry point
│   ├── firebase_options.dart              # Firebase configuration
│   ├── navigation/
│   │   └── app_router.dart                # Type-safe routing with go_router
│   ├── screens/                           # Screen widgets
│   │   ├── auth/                         # Authentication screens
│   │   │   └── forgot_password_screen.dart
│   │   ├── nav_bar_page.dart             # Main navigation shell
│   │   └── sync_settings_screen.dart     # Settings and sync screen
│   ├── widgets/                          # Reusable UI components
│   │   ├── chat_input.dart               # Chat input widget
│   │   ├── emoji_reaction_picker.dart   # Emoji reactions
│   │   ├── enhanced_job_card.dart       # Advanced job display card
│   │   ├── job_card_skeleton.dart       # Loading skeleton
│   │   ├── job_details_dialog.dart      # Job details modal
│   │   ├── like_animation.dart          # Like button animation
│   │   ├── message_bubble.dart          # Chat message bubble
│   │   ├── notification_badge.dart      # Notification indicator
│   │   ├── notification_popup.dart      # Notification overlay
│   │   └── offline_indicator.dart       # Offline status indicator
│   ├── models/                           # Data models
│   │   ├── contractor_model.dart         # Electrical contractor data
│   │   ├── conversation_model.dart      # Chat conversations
│   │   ├── crew_model.dart              # Storm response teams
│   │   ├── filter_criteria.dart         # Job filtering logic
│   │   ├── filter_preset.dart           # Saved filter configurations
│   │   ├── job_model.dart               # Job posting structure
│   │   ├── jobs_record.dart             # Firestore job records
│   │   ├── locals_record.dart           # IBEW local union data
│   │   ├── message_model.dart           # Chat messages
│   │   ├── post_model.dart              # Social posts
│   │   ├── power_grid_status.dart       # Power outage tracking
│   │   ├── storm_event.dart             # Storm work events
│   │   ├── transformer_models.dart      # Electrical transformer data
│   │   ├── user_job_preferences.dart    # User job preferences
│   │   ├── user_model.dart              # User profile data
│   │   ├── users_record.dart            # Firestore user records
│   │   └── notification/
│   │       └── notification_preferences_model.dart
│   ├── providers/                        # State management (Riverpod)
│   │   ├── core_providers.dart          # Core app providers
│   │   ├── riverpod/                    # Riverpod-specific providers
│   │   │   ├── app_state_riverpod_provider.dart
│   │   │   ├── auth_riverpod_provider.dart
│   │   │   ├── contractor_provider.dart
│   │   │   ├── job_filter_riverpod_provider.dart
│   │   │   ├── jobs_riverpod_provider.dart
│   │   │   └── locals_riverpod_provider.dart
│   ├── services/                         # Business logic and API services
│   │   ├── analytics_service.dart        # Firebase Analytics
│   │   ├── auth_service.dart             # Authentication logic
│   │   ├── avatar_service.dart           # User avatar management
│   │   ├── cache_service.dart            # Offline data caching
│   │   ├── connectivity_service.dart     # Network status monitoring
│   │   ├── contractor_service.dart       # Contractor data management
│   │   ├── database_service.dart         # Database operations
│   │   ├── enhanced_notification_service.dart # Advanced notifications
│   │   ├── fcm_service.dart              # Firebase Cloud Messaging
│   │   ├── feed_service.dart             # Social feed management
│   │   ├── firestore_service.dart        # Firestore operations
│   │   ├── geographic_firestore_service.dart # Location-based queries
│   │   ├── local_notification_service.dart # Local notifications
│   │   ├── location_service.dart         # GPS and location services
│   │   ├── noaa_weather_service.dart     # NOAA weather integration
│   │   ├── notification_manager.dart     # Notification coordination
│   │   ├── notification_permission_service.dart # Permission handling
│   │   ├── notification_service.dart     # Main notification service
│   │   ├── offline_data_service.dart     # Offline data management
│   │   ├── onboarding_service.dart       # User onboarding flow
│   │   ├── performance_monitoring_service.dart # Performance tracking
│   │   ├── power_outage_service.dart     # Power grid monitoring
│   │   ├── resilient_firestore_service.dart # Robust Firestore operations
│   │   ├── search_analytics_service.dart # Search analytics
│   │   ├── search_optimized_firestore_service.dart # Optimized search
│   │   ├── storage_service.dart          # File storage management
│   │   ├── usage_report_service.dart     # Usage analytics
│   │   ├── user_analytics_service.dart   # User behavior analytics
│   │   └── weather_radar_service.dart    # Weather radar functionality
│   ├── utils/                           # Utility functions and helpers
│   │   ├── background_wrapper.dart      # Background task wrapper
│   │   ├── collection_extensions.dart   # Collection helpers
│   │   ├── color_extensions.dart        # Color manipulation
│   │   ├── compressed_state_manager.dart # State compression
│   │   ├── concurrent_operations.dart   # Parallel processing
│   │   ├── crew_utils.dart              # Crew management helpers
│   │   ├── enum_utils.dart              # Enum utilities
│   │   ├── error_handling.dart          # Error management
│   │   ├── error_sanitizer.dart         # Error sanitization
│   │   ├── filter_performance.dart      # Filter optimization
│   │   ├── firebase_test.dart           # Firebase testing utilities
│   │   ├── job_formatting.dart          # Job display formatting
│   │   ├── lat_lng.dart                 # Geographic coordinates
│   │   ├── memory_management.dart       # Memory optimization
│   │   ├── structured_logging.dart      # Advanced logging
│   │   ├── text_formatting_wrapper.dart # Text formatting
│   │   ├── type_utils.dart              # Type checking utilities
│   │   └── validation.dart              # Input validation
│   ├── shims/                           # Compatibility shims
│   │   └── flutterflow_shims.dart       # FlutterFlow compatibility
│   └── design_system/                   # Design system (in development)
├── firebase/                           # Firebase configuration
│   ├── FIREBASE_SETUP.md              # Firebase setup instructions
│   ├── firebase.json                  # Firebase CLI configuration
│   ├── firestore.indexes.json         # Firestore search indexes
│   ├── firestore.rules                # Firestore security rules
│   └── storage.rules                  # Cloud Storage rules
├── functions/                          # Firebase Cloud Functions
│   ├── .firebaserc                    # Firebase project configuration
│   ├── package.json                   # Node.js dependencies
│   ├── tsconfig.json                  # TypeScript configuration
│   └── src/                           # Cloud Functions source code
├── scraping_scripts/                   # Data collection scripts
│   ├── README.md                      # Scraping documentation
│   ├── populate_contractors.dart      # Contractor data import
│   ├── 71_application_form.yaml      # Form configuration
│   ├── 125.py                         # Data scraper
│   ├── completed/                     # Completed scraping jobs
│   └── outputs/                       # Scraping results
├── test/                              # Test suites
│   ├── data/                          # Data layer tests
│   ├── domain/                        # Business logic tests
│   ├── features/                      # Feature-specific tests
│   ├── helpers/                       # Test utilities
│   ├── fixtures/                      # Test data
│   └── integration_test/              # End-to-end tests
├── android/                           # Android platform code
├── ios/                              # iOS platform code
├── assets/                           # Static assets
├── guide/                            # User and developer guides
└── docs/                             # Additional documentation
```

## 🌦️ Advanced Weather Integration

The app integrates with multiple government weather services for comprehensive storm tracking and electrical worker safety:

### NOAA/NWS Integration

- **National Weather Service API**: Real-time alerts, forecasts, and observations
- **NOAA Radar Stations**: Direct radar imagery from 200+ weather stations
- **National Hurricane Center**: Tropical storm and hurricane tracking
- **Storm Prediction Center**: Severe weather outlooks and convective forecasts
- **Weather Alerts**: Automated parsing of weather warnings and advisories

### Power Grid Monitoring

- **Outage Tracking**: Real-time power grid status monitoring
- **Storm Impact Analysis**: Weather-based impact predictions for electrical infrastructure
- **Safety Recommendations**: Weather-appropriate work safety guidelines

### Weather Services Architecture

- **weather_radar_service.dart**: Core radar functionality
- **noaa_weather_service.dart**: NOAA API integration
- **power_outage_service.dart**: Grid status monitoring
- **geographic_firestore_service.dart**: Location-based weather queries

All weather data is sourced from official US government APIs and requires no API keys.

## 🧪 Comprehensive Testing Suite

The project includes extensive testing across multiple layers:

### Test Structure

```bash
test/
├── data/                          # Data layer tests
│   ├── models/                    # Model validation tests
│   ├── repositories/              # Repository pattern tests
│   └── services/                  # Service layer tests
├── domain/                        # Business logic tests
│   └── use_cases/                 # Use case testing
├── features/                      # Feature-specific tests
│   ├── crews/                     # Crew management tests
│   └── integration/               # Cross-feature integration tests
├── helpers/                       # Test utilities and mocks
├── fixtures/                      # Test data and constants
└── integration_test/              # End-to-end user journey tests
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/data/             # Data layer tests
flutter test test/domain/           # Business logic tests
flutter test test/features/         # Feature tests

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run tests on specific platforms
flutter test -d android            # Android emulator
flutter test -d ios               # iOS simulator
```

### Testing Tools & Frameworks

- **Mockito & Mocktail**: Mock dependencies for unit tests
- **Fake Cloud Firestore**: Test Firestore operations safely
- **Firebase Auth Mocks**: Test authentication flows
- **Widget Testing**: Component isolation and interaction testing
- **Integration Testing**: End-to-end user journey validation

## 📊 Data Collection & Scraping

The project includes automated data collection scripts for populating contractor and job data:

### Scraping Infrastructure

- **Python Scripts**: Automated web scraping for contractor data
- **Dart Scripts**: Firebase data import and processing
- **Data Validation**: Comprehensive validation of scraped data
- **Error Handling**: Robust error handling and retry logic

### Scraping Scripts Location

```dart
scraping_scripts/
├── populate_contractors.dart      # Main data import script
├── *.py                          # Individual scraping scripts
├── completed/                    # Archive of completed jobs
└── outputs/                      # Scraping results and logs
```

## 📦 Building for Production

### iOS

```bash
flutter build ios --release
```

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

## 🚀 Deployment

### Firebase Project Deployment

The application consists of multiple deployable components:

#### 1. Flutter Web App (Firebase Hosting)

```bash
# Build for production
flutter build web --web-renderer canvaskit --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

#### 2. Firebase Cloud Functions

```bash
# Install dependencies
cd functions
npm install

# Deploy functions
firebase deploy --only functions
```

#### 3. Firestore Rules & Indexes

```bash
# Deploy security rules and indexes
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

#### 4. Full Deployment

```bash
# Deploy everything
firebase deploy
```

### CI/CD with GitHub Actions

The project includes comprehensive automated deployment workflows:

#### Production Deployment

- **Trigger**: Push to `main` branch
- **Actions**:
  - Runs complete test suite
  - Builds Flutter web app
  - Deploys to Firebase Hosting (live channel)
  - Updates Cloud Functions
  - Applies Firestore rules and indexes

#### Pull Request Previews

- **Trigger**: Pull request opened/updated
- **Actions**:
  - Runs tests
  - Builds web app
  - Deploys to preview channel
  - Provides unique preview URL in PR comments

#### Workflow Files

```dart
.github/workflows/
├── firebase-hosting-merge.yml      # Production deployment
└── firebase-hosting-pull-request.yml # PR previews
```

### Setup Requirements

1. **Firebase Project**: Configured with all required services
2. **GitHub Secrets**: Add `FIREBASE_SERVICE_ACCOUNT_JOURNEYMAN_JOBS`
3. **Flutter Cache**: Enabled for faster builds
4. **Service Account**: Generated from Firebase Console

### Deployment Components Checklist

- ✅ Flutter Web App (Firebase Hosting)
- ✅ Cloud Functions (Serverless backend)
- ✅ Firestore Security Rules
- ✅ Firestore Search Indexes
- ✅ Storage Security Rules
- ✅ Automated Testing
- ✅ Performance Monitoring
- ✅ Error Reporting (Crashlytics)

## ☁️ Firebase Cloud Functions

The application includes serverless backend functions for advanced data processing and automation:

### Function Categories

#### Data Processing Functions

- **Contractor Data Processing**: Automated processing and validation of scraped contractor data
- **Job Data Validation**: Server-side validation and sanitization of job postings
- **Geographic Data Processing**: Location-based data aggregation and optimization

#### Notification Functions

- **Push Notification Scheduling**: Timed notification delivery for job alerts
- **Weather Alert Processing**: Automated weather alert parsing and user targeting
- **Emergency Broadcast System**: Critical alert broadcasting for storm work

#### Analytics & Reporting Functions

- **Usage Analytics Aggregation**: Server-side analytics processing and aggregation
- **Performance Data Collection**: Backend performance metric aggregation
- **Custom Report Generation**: Automated report creation for stakeholders

### Functions Architecture

```dart
functions/
├── src/
│   ├── index.ts                   # Main functions entry point
│   ├── contractors/               # Contractor data processing
│   ├── notifications/             # Notification services
│   ├── analytics/                 # Analytics processing
│   └── utils/                     # Shared utilities
├── package.json                   # Node.js dependencies
├── tsconfig.json                  # TypeScript configuration
└── .firebaserc                   # Firebase project targeting
```

### Development & Deployment

```bash
# Install dependencies
cd functions
npm install

# Run functions locally
npm run serve

# Deploy to Firebase
firebase deploy --only functions

# View function logs
firebase functions:log
```

### Monitoring and Analytics

The application includes comprehensive monitoring and analytics:

#### Performance Monitoring

- **Firebase Performance Monitoring**: Automatic tracing of network requests, screen rendering, and custom traces
- **Custom Traces**: Detailed performance metrics for critical operations (job loading, weather data fetching)
- **Real User Monitoring**: Actual user experience metrics and performance bottlenecks

#### Error Tracking & Crash Reporting

- **Firebase Crashlytics**: Automatic crash reporting with detailed stack traces
- **Error Boundaries**: Graceful error handling throughout the application
- **Custom Error Events**: Detailed error logging for debugging and maintenance

#### User Analytics

- **Firebase Analytics**: Comprehensive user behavior tracking
- **Custom Events**: Job views, applications, crew formations, weather alerts
- **Conversion Tracking**: User journey optimization and feature adoption metrics

#### Service-Specific Analytics

- **analytics_service.dart**: Core analytics functionality
- **search_analytics_service.dart**: Search behavior and optimization
- **usage_report_service.dart**: Feature usage patterns
- **user_analytics_service.dart**: User engagement metrics

#### Monitoring Dashboards

Access comprehensive insights via Firebase Console:

- **Performance Tab**: Response times, network performance, rendering metrics
- **Crashlytics Tab**: Crash reports, error trends, user impact analysis
- **Analytics Tab**: User behavior, conversion funnels, retention metrics
- **Custom Dashboards**: Tailored views for electrical industry KPIs

#### Additional Setup Requirements

- Enable all monitoring services in Firebase Console
- Configure performance collection in production builds
- Set up analytics dashboards for key stakeholders
- Review Firebase quotas and billing for production scale

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software for IBEW use. All rights reserved.

## 👥 Team

- **Development**: Terragon Labs
- **Design**: Electrical theme inspired by IBEW heritage
- **Weather Data**: NOAA/National Weather Service

## 📞 Support

For support, please contact:

- Technical Issues: <support@journeymanjobs.com>
- IBEW Questions: Contact your local union

## 🔒 Security

- All user data is encrypted in transit and at rest
- Firebase Authentication handles secure login
- Location data is only used for job matching and weather alerts
- No personal information is shared without consent

---
