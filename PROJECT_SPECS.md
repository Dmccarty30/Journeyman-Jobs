# Journeyman Jobs Project Specifications Summary

## Project Overview

**Journeyman Jobs** is a Flutter-based mobile application designed specifically for IBEW (International Brotherhood of Electrical Workers) members to find electrical work opportunities. The app serves journeymen linemen, wiremen, electricians, tree trimmers, and equipment operators.

## Key Project Specifications

### 1. **Technology Stack**

- **Framework**: Flutter 3.x with Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider pattern
- **Navigation**: go_router for type-safe routing
- **UI Components**: Custom JJ-prefixed components

### 2. **Design System**

- **Primary Colors**:
  - Navy Blue (#1A202C)
  - Copper (#B45309)
- **Typography**: Google Fonts Inter
- **Theme**: Electrical/industrial design with circuit patterns and lightning effects
- **Components**: All custom components use JJ prefix (JJButton, JJElectricalLoader)

### 3. **Architecture**

- **Directory Structure**:
  - `/screens` - Feature-based screen organization
  - `/widgets` - Reusable UI components
  - `/services` - Business logic and API calls
  - `/providers` - State management
  - `/models` - Data structures
  - `/design_system` - Theme and styling
  - `/electrical_components` - Electrical-themed UI elements

### 4. **Core Features**

1. **Job Aggregation System** - Scrapes legacy union job boards
2. **Personalized Dashboard** - AI-powered job recommendations
3. **Advanced Filtering** - By location, pay, classification, construction type
4. **Union Directory** - 797+ IBEW locals with contact integration
5. **Storm Work** - Emergency restoration job highlighting
6. **Bid Management** - Job application tracking system

### 5. **User Classifications**

- Inside Wireman
- Journeyman Lineman
- Tree Trimmer
- Equipment Operator
- Low Voltage Technician

### 6. **Construction Types**

- Commercial
- Industrial
- Residential
- Utility
- Maintenance

### 7. **Navigation Structure**

- **Bottom Navigation**: 5 main tabs
  - Home (Personalized dashboard)
  - Jobs (Comprehensive listings)
  - Storm (Emergency work)
  - Unions (IBEW locals directory)
  - More (Settings & profile)

### 8. **Development Guidelines**

- **File Size Limit**: 500 lines maximum per file
- **Testing**: Widget tests required for all screens and components
- **Documentation**: Comprehensive dartdoc comments
- **Offline Support**: Critical features must work offline
- **Performance**: Optimized for large data sets (797+ unions)

### 9. **Firebase Collections**

- `users` - User profiles and preferences
- `jobs` - Job postings from various sources
- `locals` - IBEW union local information
- `bids` - User job applications
- `storm_work` - Emergency restoration opportunities

### 10. **Security Requirements**

- No logging of PII (ticket numbers, SSN)
- Environment variables for API keys
- Proper Firebase security rules
- Member-only union data protection

### 11. **Implementation Phases**

1. **Phase 1**: Navigation Infrastructure
2. **Phase 2**: Main Navigation Screens
3. **Phase 3**: Supporting Screens
4. **Phase 4**: Data Management & Services
5. **Phase 5**: Specialized Widgets & Polish

### 12. **Unique Electrical Theme Elements**

- Circuit pattern backgrounds
- Lightning bolt animations for loading states
- Electrical symbols in iconography
- Copper wire visual elements
- Voltage meter progress indicators

This project aims to modernize how IBEW electrical workers find and apply for jobs by aggregating opportunities from multiple union portals into a single, user-friendly mobile application with offline capabilities and personalized job matching.
