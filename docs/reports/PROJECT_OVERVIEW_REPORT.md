# Journeyman Jobs - Comprehensive Project Overview Report

## Executive Summary

Journeyman Jobs is a specialized Flutter mobile application designed to revolutionize job discovery and collaboration for IBEW (International Brotherhood of Electrical Workers) electrical professionals. The app serves journeymen, linemen, wiremen, operators, and tree trimmers across the United States by consolidating job opportunities from 797+ union locals into a unified, modern platform with advanced filtering, real-time notifications, and weather-integrated safety features.

## App Purpose & Mission

**Primary Purpose:** To streamline job referrals and storm work opportunities for skilled electrical workers by centralizing job discovery from disparate union websites into a single, user-friendly mobile platform.

**Mission Statement:** Empower IBEW Journeymen with the most comprehensive, user-friendly job discovery platform that connects skilled electrical workers with meaningful employment opportunities while preserving union values and traditions.

**Target Users:**

- Inside Wiremen
- Journeyman Linemen
- Tree Trimmers
- Equipment Operators
- Inside Journeyman Electricians

## Core Features & Functionality

### 1. Job Discovery & Management

- **Job Board**: Browse and filter electrical work opportunities by classification, location, and type
- **Advanced Filtering**: Multi-criteria search with saved presets (location, wage, construction type, duration)
- **Real-time Updates**: Live job posting synchronization from union sources
- **Personalized Recommendations**: AI-driven job matching based on user profiles and preferences
- **Saved Jobs**: Bookmark functionality with organized collections
- **Bid Management**: Application tracking and status updates

### 2. Storm Work & Emergency Response

- **Storm Work Hub**: Priority listings for emergency power restoration with enhanced compensation
- **Real-time Notifications**: Immediate push notifications for storm work opportunities
- **Weather Integration**: NOAA radar, live weather alerts, hurricane tracking
- **Safety Protocols**: Weather-integrated safety recommendations and work guidelines
- **Emergency Response**: Rapid application process for time-sensitive jobs

### 3. Union Directory & Networking

- **IBEW Local Directory**: Complete database of 797+ IBEW local unions with contact information
- **One-tap Integration**: Direct calling, email, and website links to local offices
- **Offline Access**: Cached directory data for areas with poor connectivity
- **Referral Information**: Local-specific rules and procedures

### 4. Crew Collaboration System

- **Crew Formation**: Create and manage work crews with role-based permissions
- **Job Sharing**: Share job opportunities within crew networks
- **Member Management**: Invite, manage, and coordinate with crew members
- **Communication Tools**: In-app messaging and coordination features
- **Performance Tracking**: Crew statistics and success metrics

### 5. Weather & Safety Integration

- **NOAA Weather Radar**: Official US government weather data for storm tracking
- **Live Weather Alerts**: Real-time severe weather warnings from National Weather Service
- **Hurricane Tracking**: National Hurricane Center integration for tropical systems
- **Location-Based Alerts**: Automatic severe weather notifications
- **Safety Protocols**: Integrated weather-based work recommendations

### 6. Professional Tools & Resources

- **Electrical Calculators**: Voltage drop, conduit fill, load calculations
- **Training Resources**: Certification tracking and continuing education
- **Code References**: NEC (National Electrical Code) quick reference
- **Career Development**: Skill assessment and career path planning

## Technical Architecture

### Frontend Technology Stack

- **Framework**: Flutter 3.6+ with Dart programming language
- **State Management**: Riverpod (Provider pattern) for reactive state management
- **Navigation**: go_router for type-safe routing
- **UI Components**: Custom electrical-themed component library
- **Platform Support**: iOS and Android native deployment

### Backend Infrastructure

- **Authentication**: Firebase Authentication with multi-provider support
- **Database**: Cloud Firestore for real-time data synchronization
- **Storage**: Firebase Storage for document and image management
- **Functions**: Firebase Cloud Functions for server-side logic
- **Hosting**: Firebase Hosting for web admin interfaces

### Data Aggregation System

- **Job Scraping**: Backend services that aggregate jobs from union websites
- **Data Processing**: Job normalization and categorization
- **Caching**: Redis-based performance optimization
- **Scheduling**: Automated job discovery and updates

### Mobile Platform Features

- **Push Notifications**: Firebase Cloud Messaging for real-time alerts
- **Offline Capability**: Local SQLite database for critical features
- **Location Services**: GPS integration for proximity-based features
- **Camera Integration**: Document scanning and profile photo capture
- **Biometric Authentication**: Touch ID/Face ID for secure access

## Project Structure & Organization

### Directory Architecture

```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── screens/                     # Screen widgets (jobs, crews, storm, unions, profile)
├── widgets/                     # Reusable UI components (job_card, weather widgets)
├── services/                    # Business logic and API integrations
│   ├── auth_service.dart       # Authentication handling
│   ├── firestore_service.dart  # Database operations
│   ├── weather services/       # NOAA weather integration
│   ├── notification services/  # Push notification management
│   └── location_service.dart   # GPS and geolocation
├── providers/                   # State management (Riverpod providers)
├── models/                      # Data models (Job, User, Crew, Weather)
├── navigation/                  # Router configuration
├── design_system/              # Theme and styling constants
├── electrical_components/       # Custom electrical-themed widgets
└── utils/                       # Helper utilities and extensions
```

### Key Services Overview

- **25+ Specialized Services**: Authentication, notifications, weather, location, analytics, performance monitoring
- **Offline-First Design**: Critical features available without internet connectivity
- **Resilient Architecture**: Error handling and retry mechanisms throughout
- **Performance Optimized**: Caching, lazy loading, and background processing

## Data Models & Schema

### Core Data Entities

- **Users**: Professional profiles with certifications, preferences, and work history
- **Jobs**: Job postings with compensation, requirements, and application tracking
- **Crews**: Work teams with member roles, permissions, and collaboration features
- **Weather Events**: Storm tracking, alerts, and safety protocols
- **Union Locals**: Directory of 797+ IBEW locals with contact information

### Database Collections

- **users**: User profiles and authentication data
- **jobs**: Job postings and applications
- **crews**: Crew information and member relationships
- **notifications**: Push notification history and preferences
- **weather_alerts**: NOAA weather data and user alerts

## Security & Privacy

### Data Protection Measures

- **End-to-end Encryption**: Sensitive data encrypted in transit and at rest
- **GDPR Compliance**: European privacy regulation compliance
- **PII Handling**: Strict controls on personally identifiable information
- **Location Privacy**: GPS data used only for job matching and weather alerts

### Authentication & Authorization

- **Multi-provider Auth**: Email/password, Google, Apple Sign-In
- **Role-based Access**: Permission systems for crew management
- **Session Security**: Secure token management with automatic expiration
- **Biometric Support**: Touch ID/Face ID for enhanced security

## Development Status & Roadmap

### Current Implementation (Phase 2)

- ✅ Core infrastructure and authentication
- ✅ Job discovery and basic filtering
- ✅ Union directory with offline access
- ✅ Weather radar integration
- ✅ Crew formation and messaging
- 🔄 Advanced job matching algorithms
- 🔄 Push notification system

### Planned Features (Phase 3-4)

- **Bid Management System**: Streamlined application workflows
- **Analytics Dashboard**: Job market insights and career tracking
- **Offline Job Applications**: Full functionality without connectivity
- **Advanced Crew Tools**: Scheduling, equipment tracking, travel coordination

## Business Impact & Success Metrics

### User Adoption Goals

- **10,000+ Active Users**: Within first 6 months of launch
- **75% Match Accuracy**: Personalized job recommendations
- **25% Placement Increase**: Successful job applications through platform
- **60% Retention Rate**: Monthly active user engagement

### Operational Metrics

- **< 3 seconds**: App launch time (cold start)
- **< 500ms**: Job search result response time
- **< 100ms**: Real-time notification latency
- **4.5+ Stars**: App store rating maintained

## Unique Value Propositions

### For Electrical Workers

- **Centralized Job Discovery**: No more checking dozens of union websites
- **Emergency Work Priority**: Storm work notifications and rapid response
- **Professional Networking**: Connect with union brothers across locals
- **Weather-Aware Safety**: Integrated weather monitoring for work safety

### For Union Locals

- **Increased Visibility**: Better exposure for job postings
- **Streamlined Referrals**: Digital application and tracking systems
- **Member Support**: Enhanced tools for journeyman career development

### For the Electrical Industry

- **Workforce Optimization**: Better matching of skills to job requirements
- **Emergency Response**: Faster storm restoration through organized crews
- **Professional Standards**: Maintained union values in digital platform

## Conclusion

Journeyman Jobs represents a comprehensive digital transformation of the electrical trades job market, specifically designed for IBEW union members. By combining modern mobile technology with deep industry knowledge, the app addresses critical pain points in job discovery while maintaining the professional standards and collaborative spirit of the electrical brotherhood.

The platform's electrical-themed design, robust weather integration, and crew collaboration features create a uniquely tailored experience that goes beyond traditional job boards to serve the specific needs of skilled electrical workers during both routine work and emergency storm restoration efforts.

This overview provides the foundational context needed for any new agent to understand the app's purpose, capabilities, and technical implementation, enabling effective contribution to the project's ongoing development and enhancement.
