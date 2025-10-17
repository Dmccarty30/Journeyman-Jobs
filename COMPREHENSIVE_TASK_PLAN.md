# 📋 Comprehensive Task Plan for Journeyman Jobs

## Phase 1: Critical Fixes & Security (Days 1-3)
**Dependencies:** None - Can start immediately

### 1.1 Fix Google Sign-In API Compatibility [P]
- **Difficulty:** ⚡ High
- **Agent:** `auth-expert`
- **Location:** `lib/services/auth_service.dart:77-90`
- **Issue:** Using deprecated Google Sign-In v7 API patterns
- **Action:** Update to latest Google Sign-In API, fix authentication flow
- **Validation:** ✅ Google OAuth works on iOS/Android

### 1.2 Implement Missing Security Rules [P]
- **Difficulty:** ⚡ High  
- **Agent:** `security-auditor`
- **Files:** `firebase/firestore.rules`, `firebase/storage.rules`
- **Action:** Add RBAC rules for crews, validate user permissions
- **Validation:** ✅ All collections have proper security rules

### 1.3 Fix Crew Cloud Function Trigger
- **Difficulty:** 🔧 Medium
- **Agent:** `backend-architect`
- **Location:** `lib/features/crews/services/crew_service.dart:1186`
- **TODO:** Implement Cloud Function trigger for crew notifications
- **Validation:** ✅ Crew events trigger notifications

## Phase 2: Database Optimization (Days 4-7)
**Dependencies:** Phase 1 security rules complete

### 2.1 Create Composite Indexes [P]
- **Difficulty:** 🔧 Medium
- **Agent:** `database-optimizer`
- **Files:** `firebase/firestore.indexes.json`
- **Action:** Add indexes for job queries, crew searches, location filtering
- **Validation:** ✅ Query performance <200ms

### 2.2 Optimize Large Collection Queries [P]
- **Difficulty:** ⚡ High
- **Agent:** `database-optimizer`
- **Issue:** 797+ union locals causing performance issues
- **Action:** Implement pagination, caching, virtualization
- **Validation:** ✅ Locals screen loads in <2s

### 2.3 Implement Offline Data Sync
- **Difficulty:** 🔧 Medium
- **Agent:** `backend-architect`
- **Files:** `lib/services/offline_data_service.dart`
- **Action:** Add conflict resolution, queue management
- **Validation:** ✅ Offline changes sync when reconnected

## Phase 3: Feature Implementation (Week 2)
**Dependencies:** Database optimization complete

### 3.1 Implement Favorites System
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **Location:** `lib/widgets/virtual_job_list.dart:289,485`
- **TODO:** Implement favorites tracking and UI
- **Action:** Add favorites collection, UI toggles, persistence
- **Validation:** ✅ Users can favorite/unfavorite jobs

### 3.2 Add Job Bidding Feature
- **Difficulty:** 🔧 Medium
- **Agent:** `backend-architect`
- **Location:** `lib/widgets/virtual_job_list.dart:478`
- **TODO:** Implement bidding functionality
- **Action:** Create bid model, UI, Firestore integration
- **Validation:** ✅ Users can submit and track bids

### 3.3 Implement Report Functionality [P]
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **Locations:** 
  - `lib/features/crews/widgets/post_card.dart:285`
  - `lib/widgets/comment_item.dart:183`
- **Action:** Add report UI, moderation queue, admin panel
- **Validation:** ✅ Content can be reported and moderated

### 3.4 Add Like/Unlike System [P]
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **Location:** `lib/widgets/comment_thread.dart:126-127`
- **TODO:** Implement like tracking and counts
- **Validation:** ✅ Comments show likes with real-time updates

## Phase 4: Testing & Quality (Week 2-3)
**Dependencies:** Features implemented

### 4.1 Fix Riverpod Test Providers
- **Difficulty:** 🔧 Medium
- **Agent:** `test-automator`
- **Location:** `test/helpers/test_helpers.dart:6`
- **Action:** Update provider mocks for Riverpod 2.5.1+
- **Validation:** ✅ All tests pass with proper mocking

### 4.2 Add Integration Tests [P]
- **Difficulty:** 🔧 Medium
- **Agent:** `test-automator`
- **Coverage Gaps:** Auth flow, crew creation, job bidding
- **Action:** Create E2E tests for critical user journeys
- **Validation:** ✅ 80% code coverage achieved

### 4.3 Performance Testing Suite [P]
- **Difficulty:** 🔧 Medium
- **Agent:** `performance`
- **Files:** `test/performance/*`
- **Action:** Add load tests, memory profiling, render tests
- **Validation:** ✅ Performance benchmarks established

## Phase 5: UI/UX Enhancements (Week 3)
**Dependencies:** Core features working

### 5.1 Implement Search Functionality
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **Location:** `lib/screens/tools/transformer_reference_screen.dart:33`
- **Action:** Add search bar, filters, results display
- **Validation:** ✅ Users can search transformers

### 5.2 Add Settings Panel [P]
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **Location:** `lib/screens/tools/transformer_reference_screen.dart:39`
- **Action:** Create settings UI with preferences
- **Validation:** ✅ Settings persist and apply

### 5.3 Browse Public Crews Screen [P]
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **Location:** `lib/features/crews/screens/join_crew_screen.dart:144`
- **Action:** Create crew discovery UI with filters
- **Validation:** ✅ Users can browse and join crews

## Phase 6: Weather Integration (Week 3-4)
**Dependencies:** None - Can run parallel

### 6.1 Complete NWS API Integration
- **Difficulty:** 🔧 Medium
- **Agent:** `backend-architect`
- **Location:** `lib/services/weather_radar_service.dart:155`
- **TODO:** Integrate with NWS API for US weather alerts
- **Action:** Add API client, parse alerts, display UI
- **Validation:** ✅ Real-time weather alerts working

## Phase 7: Production & Monitoring (Week 4)
**Dependencies:** All features tested

### 7.1 Firebase Analytics Integration [P]
- **Difficulty:** 📦 Low
- **Agent:** `backend-architect`
- **Location:** `lib/utils/structured_logging.dart:377`
- **Action:** Connect logging to Firebase Analytics
- **Validation:** ✅ Events tracked in Firebase Console

### 7.2 Error Monitoring Setup [P]
- **Difficulty:** 📦 Low
- **Agent:** `devops`
- **Action:** Configure Crashlytics, Sentry integration
- **Validation:** ✅ Errors reported with stack traces

### 7.3 Performance Monitoring [P]
- **Difficulty:** 📦 Low
- **Agent:** `performance`
- **Action:** Add Firebase Performance traces, metrics
- **Validation:** ✅ Performance dashboard active

## Summary Metrics
- **Total Tasks:** 24
- **Parallel Executable:** 15 tasks [P]
- **Critical Priority:** 3 tasks
- **High Complexity:** 4 tasks
- **Medium Complexity:** 12 tasks
- **Low Complexity:** 8 tasks
- **Estimated Duration:** 4 weeks
- **Required Agents:** 9 specialists

## Agent Allocation
- `auth-expert`: Authentication fixes
- `security-auditor`: Security rules
- `backend-architect`: API, services, integration
- `database-optimizer`: Firestore optimization
- `flutter-expert`: UI/UX implementation
- `test-automator`: Testing suite
- `performance`: Performance optimization
- `devops`: Deployment, monitoring
- `team-coordinator`: Multi-agent coordination

This plan ensures proper dependency management, maximizes parallel execution where possible, and assigns the most competent agents to each task based on their specialization.