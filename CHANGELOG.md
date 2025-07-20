# Changelog

All notable changes to Journeyman Jobs will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Interactive NOAA weather radar integration on Storm Work screen
- Real-time weather alerts from National Weather Service
- Hurricane tracking from National Hurricane Center
- Storm Prediction Center severe weather outlooks
- Location-based weather warnings with safety protocols
- Enhanced location permissions handling with user-friendly dialogs
- Offline caching for weather data during storms
- Weather alert details with storm work safety information

### Changed
- Updated LocationService from mock to real device GPS using geolocator
- Enhanced storm screen with "View Live Weather Radar" button
- Improved app permissions for iOS and Android to include location access

### Dependencies
- Added flutter_map ^7.0.2 for interactive map widget
- Added latlong2 ^0.9.1 for coordinate handling
- Added dio ^5.7.0 for HTTP requests
- Added geolocator ^13.0.2 for device location services

## [1.0.0] - 2025-07-01

### Added
- Initial release of Journeyman Jobs app
- Core navigation with electrical-themed design
- Firebase authentication with email/password
- Job board with filtering capabilities
- Storm work hub for emergency opportunities
- Union directory with 797+ IBEW locals
- User profile management
- Electrical-themed UI components
- Offline support for union directory

### Features
- Bottom navigation with 5 main sections
- Personalized job recommendations
- Advanced job filtering by location, wage, and type
- Real-time notifications for job alerts
- Professional networking capabilities
- Electrical calculators and resources

### Technical
- Flutter 3.x with null safety
- Provider state management
- Firebase backend integration
- go_router for navigation
- Comprehensive design system

---

For more details on each release, see the [GitHub releases](https://github.com/journeyman-jobs/releases) page.