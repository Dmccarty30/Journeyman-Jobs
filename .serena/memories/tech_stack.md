# Journeyman Jobs - Technology Stack

## Core Technologies
- **Framework**: Flutter 3.x with null safety
- **Language**: Dart SDK (^3.6.0)
- **Development Environment**: Linux (WSL2)
- **Flutter Binary Location**: `/mnt/c/flutter/flutter/bin/flutter`

## State Management
- **Primary**: Provider pattern
- **Secondary**: flutter_riverpod (^3.0.0-dev.17) with riverpod_annotation and riverpod_generator
- **Navigation**: go_router (^16.0.0) for type-safe routing
- **Reactive Streams**: rxdart (^0.28.0)

## Backend & Cloud Services
- **Backend**: Firebase
  - firebase_core (^4.0.0)
  - firebase_auth (^6.0.1) 
  - cloud_firestore (^6.0.0)
  - firebase_storage (^13.0.0)
  - firebase_messaging (^16.0.0)
  - firebase_analytics (^12.0.0)
  - firebase_performance (^0.11.0)

## Authentication
- google_sign_in (^7.1.0)
- sign_in_with_apple (^7.0.1)

## UI & Design
- **Design System**: shadcn_ui (^0.12.0)
- **Fonts**: google_fonts (^6.2.1) - Google Fonts Inter
- **Animations**: flutter_animate (^4.2.0)
- **Icons**: 
  - font_awesome_flutter (^10.8.0)
  - flutter_svg (^2.0.10)
- **Images**: cached_network_image (^3.2.3)
- **Colors**: from_css_color (^2.0.0)

## Notifications
- flutter_local_notifications (^19.3.0)
- permission_handler (^12.0.1)
- badges (^3.1.1)

## Location & Weather
- **Location**: geolocator (^14.0.2)
- **Maps**: flutter_map (^8.2.1) with latlong2 (^0.9.1)
- **Weather Data**: NOAA/NWS APIs (no API key required)
- **HTTP Client**: dio (^5.7.0)
- **Timezone**: timezone (^0.10.1)
- **Connectivity**: connectivity_plus (^6.0.3)

## AI Integration
- google_generative_ai (^0.4.7)

## Development Dependencies
- **Testing**: 
  - flutter_test (SDK)
  - test (^1.24.0)
  - mockito (^5.4.0)
  - mocktail (^1.0.0)
  - integration_test (SDK)
  - fake_cloud_firestore (^4.0.0)
  - firebase_auth_mocks (^0.15.0)

- **Code Generation**: 
  - build_runner (^2.4.6)
  - riverpod_generator (^3.0.0-dev.17)

- **Quality**: 
  - flutter_lints (^6.0.0)
  - analysis_options.yaml with package:flutter_lints/flutter.yaml

- **Assets**: 
  - flutter_launcher_icons (^0.14.4)

## Platform Support
- **iOS**: Configured with Xcode project
- **Android**: Configured with Gradle build system
- **Assets**: Located in `assets/images/` directory

## Data Persistence
- shared_preferences (^2.2.0)
- Firebase Firestore for cloud storage
- Local caching for offline functionality

## Utilities
- collection (^1.18.0)
- meta (^1.15.0)
- url_launcher (^6.2.4)