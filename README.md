# Journeyman Jobs ⚡

**IBEW Mobile Application for Electrical Workers**

A comprehensive Flutter application designed to streamline job referrals and storm work opportunities for IBEW (International Brotherhood of Electrical Workers) journeymen, linemen, wiremen, operators, and tree trimmers.

## 🎯 Overview

Journeyman Jobs connects skilled electrical workers with job opportunities across the United States, with special emphasis on emergency storm restoration work. The app provides real-time job listings, union directory access, and critical weather tracking tools for storm response teams.

## ✨ Key Features

### 📱 Core Functionality

- **Job Board**: Browse and filter electrical work opportunities by classification, location, and type
- **Storm Work Hub**: Priority listings for emergency power restoration with enhanced compensation
- **Union Directory**: Complete directory of 797+ IBEW locals with contact integration
- **Profile Management**: Maintain certifications, work history, and availability status
- **Real-time Notifications**: Instant alerts for new job postings and storm work opportunities

### 🤝 Job Sharing & Crew Management (NEW)

- **Viral Job Sharing**: Share opportunities with crew members via email, SMS, or in-app messaging
- **Quick Signup Flow**: Non-users can join the platform in under 2 minutes from shared links
- **Crew Management**: Create and manage work crews with shared job boards and notifications
- **Smart User Detection**: Automatic platform user identification for seamless sharing experience
- **Group Applications**: Apply for jobs as a crew with coordinated team management
- **Network Effects**: Each share brings an average of 1.5 new users to the platform

### 🌩️ Weather Integration (NEW)

- **NOAA Weather Radar**: Official US government weather data for storm tracking
- **Live Weather Alerts**: Real-time severe weather warnings from National Weather Service
- **Hurricane Tracking**: National Hurricane Center integration for tropical systems
- **Storm Safety**: Integrated safety protocols and weather-based work recommendations

### 🔌 Electrical-Themed Design

- Custom electrical components and animations
- Circuit pattern backgrounds
- Lightning bolt loading indicators
- Copper and navy color scheme representing electrical heritage

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.x with null safety
- **State Management**: Provider pattern
- **Backend**: Firebase (Authentication, Firestore, Cloud Storage, Cloud Functions)
- **Navigation**: go_router for type-safe routing
- **Weather Data**: NOAA/NWS APIs (no API key required)
- **Maps**: flutter_map with OpenStreetMap
- **Location**: Geolocator for GPS services
- **Sharing**: Email (SendGrid), SMS (Twilio), Push Notifications (FCM)
- **Deep Linking**: uni_links for seamless app entry from shared content

## 📋 Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK (included with Flutter)
- Firebase project configured with Cloud Functions enabled
- SendGrid API key for email sharing
- Twilio account (optional, for SMS sharing)
- iOS: Xcode 14+ for iOS development
- Android: Android Studio for Android development

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
   
   # Edit .env with your configuration values
   # Required: Firebase, SendGrid API key
   # Optional: Twilio for SMS sharing
   ```

5. **Configure Cloud Functions**

   ```bash
   # Navigate to functions directory
   cd functions
   
   # Install dependencies
   npm install
   
   # Deploy functions (requires Firebase CLI)
   firebase deploy --only functions
   ```

6. **Run the app**

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

```
lib/
├── main.dart                    # App entry point
├── screens/                     # Screen widgets
│   ├── home/                   # Home dashboard
│   ├── jobs/                   # Job listings and details
│   ├── storm/                  # Storm work hub with weather radar
│   ├── unions/                 # Union directory
│   └── profile/                # User profile management
├── widgets/                     # Reusable UI components
│   ├── job_card.dart          # Job listing card
│   ├── union_card.dart        # Union local card
│   └── weather/               # Weather radar components
├── services/                    # Business logic and API calls
│   ├── auth_service.dart      # Authentication
│   ├── job_service.dart       # Job data management
│   ├── location_service.dart  # GPS and location
│   ├── noaa_weather_service.dart # NOAA weather integration
│   ├── notification_service.dart # Push notifications
│   └── job_sharing_service.dart  # Job sharing functionality
├── models/                      # Data models
│   ├── job_model.dart         # Job posting structure
│   ├── user_model.dart        # User profile
│   ├── storm_event.dart       # Storm work events
│   ├── job_share.dart         # Job sharing data
│   └── crew_member.dart       # Crew management
├── providers/                   # State management
│   ├── auth_provider.dart     # Authentication state
│   ├── job_provider.dart      # Job listings state
│   ├── user_provider.dart     # User data state
│   └── job_sharing_provider.dart # Job sharing state
├── design_system/              # Theme and styling
│   ├── app_theme.dart         # Colors, typography, spacing
│   └── components/            # Design system components
├── electrical_components/       # Custom electrical UI elements
└── navigation/                 # Router configuration
    └── app_router.dart        # go_router setup
```

## 🌦️ Weather Integration Details

The app integrates with multiple NOAA services for comprehensive weather tracking:

- **National Weather Service API**: Real-time alerts and forecasts
- **NOAA Radar Stations**: Direct radar imagery from 200+ stations
- **National Hurricane Center**: Tropical storm tracking
- **Storm Prediction Center**: Severe weather outlooks

All weather data is free and requires no API keys.

## 🤝 Job Sharing Feature

The job sharing feature enables viral growth through network effects while maintaining excellent user experience.

### Key Components

- **Share Service**: Handles email/SMS distribution and user detection
- **Cloud Functions**: Backend processing for sharing notifications
- **Quick Signup**: 2-minute onboarding for shared job recipients
- **Crew Management**: Group applications and team coordination
- **Analytics**: Track sharing performance and viral coefficient

### API Endpoints (Cloud Functions)

- `POST /sendJobShare` - Send job share via email/SMS
- `POST /recordShare` - Track sharing events
- `GET /detectUser` - Check if recipient is existing user
- `POST /quickSignup` - Handle rapid user onboarding
- `POST /notifyJobShare` - Send push notifications

### Environment Variables

```bash
# Required for job sharing
SENDGRID_API_KEY=your_sendgrid_key
SENDGRID_FROM_EMAIL=no-reply@journeymanjobs.com

# Optional for SMS sharing
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token

# Deep linking
DEEP_LINK_SCHEME=journeymanjobs
APP_STORE_ID=123456789
```

### Implementation Status

- ✅ Core sharing functionality
- ✅ Email integration (SendGrid)
- ✅ SMS integration (Twilio)
- ✅ Quick signup flow
- ✅ Crew management
- ✅ Analytics tracking
- ✅ Push notifications
- ✅ Deep linking

For detailed implementation guides, see `docs/job-sharing-feature/`

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test integration_test/
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

**Built with ⚡ for IBEW electrical workers**
