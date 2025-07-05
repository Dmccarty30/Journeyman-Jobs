# Implementation Plan: Journeyman Jobs App Screens

**Project:** Complete IBEW Journeyman Jobs App Implementation  
**Created:** 2025-07-05  
**Status:** Phase 1 - In Progress

## Overview
Transform the current onboarding-focused app into a full-featured job platform for IBEW Journeymen, implementing all screens and functionality described in `guide/screens.md`.

---

## Initial Setup
1. **✅ Save this plan** to `/mnt/c/Users/david/desktop/ui/plan.md` for future reference
2. **Phase-by-phase approach** - Check with user after each phase completion for feedback and additional details

---

## Phase 1: Navigation Infrastructure
**Goal:** Set up complete app navigation system  
**Status:** 🔄 In Progress

**Files to create/modify:**
- `lib/navigation/app_router.dart` - Complete app routing with go_router
- `lib/screens/nav_bar_page.dart` - Bottom navigation wrapper
- Modify `lib/main.dart` - Integrate router

**Key features:**
- Bottom navigation with 5 tabs (Home, Jobs, Storm, Unions, More)
- Proper route handling for authenticated/unauthenticated users
- Deep linking support for job details and profiles
- Electrical theme consistency throughout navigation

**Deliverable:** Working navigation between all main screens  
**Checkpoint:** Review navigation flow and get user input on routing structure

---

## Phase 2: Main Navigation Screens
**Goal:** Implement the 5 core navigation screens  
**Status:** ⏳ Pending

**Files to create:**
- `lib/screens/home/home_screen.dart` - Personalized dashboard with job suggestions
- `lib/screens/jobs/jobs_screen.dart` - Comprehensive job listings with search/filter
- `lib/screens/storm/storm_screen.dart` - Emergency/storm restoration work opportunities  
- `lib/screens/unions/unions_screen.dart` - IBEW locals directory (797+ locals)
- `lib/screens/more/more_screen.dart` - Settings and additional options

**Key features:**
- Personalized job dashboard with suggestions
- Job cards with "Bid" functionality
- Advanced filtering by location, classification, pay rate, construction type
- Local union directory with contact links (phone/email/website)
- Emergency job highlighting for storm work
- Offline access for union directory

**Deliverable:** All 5 main screens functional with basic layouts  
**Checkpoint:** Review screen layouts and get user input on specific features for each screen

---

## Phase 3: Supporting Screens  
**Goal:** Add profile, help, and utility screens  
**Status:** ⏳ Pending

**Files to create:**
- `lib/screens/profile/profile_screen.dart` - User profile management
- `lib/screens/help/help_support_screen.dart` - FAQ and support
- `lib/screens/resources/resources_screen.dart` - Documents and links for Journeymen
- `lib/screens/training/training_certificates_screen.dart` - Professional certification management
- `lib/screens/auth/forgot_password_screen.dart` - Password reset functionality

**Key features:**
- Comprehensive user profile editing
- Professional information management (ticket number, classification, etc.)
- Career goals and preferences updating
- Help documentation and FAQ
- Contact support options
- Resource library for IBEW professionals
- Certificate and training tracking

**Deliverable:** Complete support screen ecosystem  
**Checkpoint:** Review support features and get user input on help content and resources

---

## Phase 4: Data Management & Services
**Goal:** Implement backend data handling and state management  
**Status:** ⏳ Pending

**Files to create:**
- `lib/services/job_service.dart` - Job data operations and API calls
- `lib/services/union_service.dart` - Local union data management
- `lib/providers/job_provider.dart` - Job state management with Provider
- `lib/providers/user_provider.dart` - User profile state management
- `lib/models/union_model.dart` - IBEW local union data structure

**Key features:**
- Job aggregation from multiple union portals
- Real-time job updates and notifications
- Local union data caching for offline access
- User preference synchronization
- Bid submission and tracking
- Job filtering and search optimization

**Deliverable:** Full data integration with Firebase and external job sources  
**Checkpoint:** Review data architecture and get user input on API integrations

---

## Phase 5: Specialized Widgets & Polish
**Goal:** Add advanced components and final polish  
**Status:** ⏳ Pending

**Files to create:**
- `lib/widgets/job_card.dart` - Reusable job listing card component
- `lib/widgets/filter_bottom_sheet.dart` - Advanced filtering UI with multiple criteria
- `lib/widgets/union_card.dart` - Union local information display card
- `lib/widgets/emergency_banner.dart` - Storm work highlighting component
- `lib/widgets/bid_confirmation_dialog.dart` - Job bid submission workflow

**Key features:**
- Polished job cards with electrical theme
- Comprehensive filtering options (location, pay, classification, construction type)
- Contact integration for union communications
- Emergency work highlighting and prioritization
- Smooth animations and transitions
- Accessibility improvements
- Performance optimization

**Deliverable:** Production-ready app with all features and polish  
**Checkpoint:** Final review and comprehensive testing

---

## Technical Implementation Notes

### Design System Consistency
- **Theme:** Maintain copper (#B45309) and navy (#1A202C) electrical theme throughout
- **Typography:** Use existing Google Fonts Inter typography system
- **Components:** Extend existing `JJ` component library
- **Animations:** Use flutter_animate for consistent motion design

### Architecture Patterns
- **State Management:** Provider pattern for consistent state handling
- **Navigation:** go_router for type-safe navigation and deep linking
- **Data Layer:** Firebase/Firestore with local caching using shared_preferences
- **Code Organization:** Feature-based folder structure

### Data Integration
- **User Profiles:** Leverage existing `UsersRecord` schema
- **Job Data:** Extend existing `JobsRecord` for job aggregation
- **Local Unions:** New data structure for 797+ IBEW locals
- **Offline Support:** Cache critical data for union directory access

### Key App Features
1. **Job Aggregation System:** Centralized scraping from legacy union systems
2. **Personalized Dashboard:** AI-powered job recommendations based on user profile
3. **Advanced Filtering:** Multi-criteria search (location, pay, classification, etc.)
4. **Union Directory:** Comprehensive IBEW local directory with contact integration
5. **Emergency Work:** Dedicated storm restoration job highlighting
6. **Bid Management:** Job application and tracking system

---

## Success Criteria
- ✅ Complete navigation between all required screens
- ✅ Functional job browsing and filtering
- ✅ Working union directory with contact integration
- ✅ User profile management and preferences
- ✅ Professional electrical design theme throughout
- ✅ Responsive mobile-first design
- ✅ Integration with existing Firebase backend
- ✅ Offline capability for union directory

---

## Future Enhancements (Post-Launch)
- Push notifications for new job postings
- Advanced analytics and job market insights
- Social features for networking between Journeymen
- Integration with additional union job boards
- Mobile app for iOS and Android
- Web portal for recruiters and contractors

---

**Next Steps:** Complete Phase 1 navigation infrastructure and checkpoint with user for feedback and direction.