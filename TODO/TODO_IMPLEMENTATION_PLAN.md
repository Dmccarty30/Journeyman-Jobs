# 📋 TODO Implementation Plan - Journeyman Jobs

- *Generated from TODO.md analysis with comprehensive task breakdown*

## Phase 1: Dark Mode & Theme Foundation (Days 1-2)

**Dependencies:** None - Can start immediately

### 1.1 Implement Dark Mode Theme System [P]

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 🔧 Medium
- **Agent:** `ui-ux-designer`
- **File:** `lib/design_system/app_theme.dart`
- **Requirements:**
  - Extract dark navy background from Welcome/Auth screens as dark mode base
  - Create complete dark theme with copper accents
  - Ensure text readability on dark backgrounds
- **Validation:** ✅ Dark mode toggle works, text is readable
- **Implementation:**

  ```dart
  // Added to AppTheme class
  static const Color darkBackground = Color(0xFF1A202C);
  static const Color darkSurface = Color(0xFF2D3748);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  static const Color darkTextLight = Color(0xFF9CA3AF);
  ```

### 1.2 Fix Text Field Visibility in Dark Mode [P]

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 📦 Low
- **Agent:** `ui-ux-designer`
- **Issue:** Text color on text fields is light grey, unreadable
- **Files:** Global text field styling
- **Action:** Update text field themes for both light/dark modes
- **Validation:** ✅ Text hints and labels are black/readable in all modes

### 1.3 Convert Welcome/Auth Screens to Light Mode

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **Files:**
  - `lib/screens/onboarding/welcome_screen.dart`
  - `lib/screens/onboarding/auth_screen.dart`
- **Action:** Update background colors to light theme defaults
- **Dependencies:** Task 1.1 complete
- **Validation:** ✅ Screens use light theme by default

## Phase 2: Authentication Flow Deep Analysis (Days 2-3)

**Dependencies:** Phase 1 theme work

### 2.1 Comprehensive Auth System Audit

- [x] **Status:** COMPLETED ✅
- **Difficulty:** ⚡ High
- **Agent:** `auth-expert`
- **Scope:** Complete authentication lifecycle analysis
- **Files:** All auth-related services, screens, providers
- **Action:** Perform deep dive analysis using `*enhanced-auth-eval`
- **Validation:** ✅ Full auth flow documented with issues identified

### 2.2 Fix Auth Screen Tab Bar Alignment

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/onboarding/auth_screen.dart`
- **Issues:**
  - Tab bar gap (see `assets/tab-bar-gap.png`)
  - Border size reduction by 50%
  - Google button overflow error
- **Validation:** ✅ Tab bar properly aligned, no overflow

### 2.3 Fix Onboarding User Document Creation

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 🔧 Medium
- **Agent:** `auth-expert`
- **File:** `lib/screens/onboarding/onboarding_steps_screen.dart`
- **Issue:** User document creation timing on Step 1 → Step 2
- **Action:** Ensure document creation happens correctly on "Next" button
- **Validation:** ✅ User document created properly on step transition

## Phase 3: Onboarding Improvements (Days 3-4)

**Dependencies:** Auth system fixes

### 3.1 Fix Welcome Screen Button Font Size

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/onboarding/welcome_screen.dart`
- **Action:** Reduce complete/next button font size by 15% on third screen
- **Validation:** ✅ Button text properly sized

### 3.2 Update Book Examples with Real Local Numbers [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/onboarding/onboarding_steps_screen.dart`
- **Action:** Replace "Book1, Book2" with "84, 222, 111, 1249, 71"
- **Validation:** ✅ Realistic local numbers displayed

### 3.3 Fix Construction Type Capitalization [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Onboarding Step 3 choice chips
- **Action:** Capitalize construction type values properly
- **Validation:** ✅ "Transmission" not "transmission", etc.

## Phase 4: Home Screen Enhancements (Days 4-5)

**Dependencies:** None - Can run parallel

### 4.1 Add Personalized Welcome Message

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/home_screen.dart`
- **Action:** Display "Welcome Back, [userName]!" under app bar
- **Dependencies:** User data properly loaded
- **Validation:** ✅ User's name displays correctly

### 4.2 Add Resources Quick Action [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/home_screen.dart`
- **Action:** Add Resources screen navigation container
- **Validation:** ✅ Navigation to Resources screen works

### 4.3 Remove Blue Shadows from Containers [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/home_screen.dart`
- **Action:** Remove light blue shadow from quick action containers
- **Validation:** ✅ Clean container appearance

### 4.4 Remove Colored Fonts from Job Cards [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/home_screen.dart`
- **Action:** Remove grey tint and colored fonts from suggested jobs section
- **Validation:** ✅ Clean, consistent job card styling

## Phase 5: Jobs Screen Improvements (Days 5-6)

**Dependencies:** None - Can run parallel

### 5.1 Implement Local Union Search Feature

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/jobs_screen.dart`
- **Requirements:**
  - Traditional search widget with magnifying glass icon
  - Text hint: "Search For A Specific Local"
  - Search only by local union number
  - Place under horizontal filter
- **Validation:** ✅ Search works for local union numbers only

### 5.2 Remove Storm Work Filter Option [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/jobs_screen.dart`
- **Action:** Remove "Storm Work" from filtering options
- **Validation:** ✅ Filter option removed

## Phase 6: Storm Screen Fixes (Days 6-7)

**Dependencies:** Read Storm-Analysis.md first

### 6.1 Fix Border Thickness Issues

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/storm_screen.dart`
- **Action:** Reduce all border thickness by 50%
- **Validation:** ✅ More subtle, refined borders

### 6.2 Fix Background Container Layout

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/storm_screen.dart`
- **Issue:** Circuit board background incorrectly contained/positioned
- **Action:** Restructure layout for proper background rendering
- **Validation:** ✅ Circuit background renders correctly

### 6.3 Remove Admin Status Check [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/storm_screen.dart:504`
- **Action:** Remove admin status check and related functionality
- **Validation:** ✅ No admin-related code remains

## Phase 7: Crew System Overhaul (Days 7-10)

**Dependencies:** Complex crew functionality

### 7.1 Fix Tailboard Screen Welcome Header

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** `lib/features/crews/screens/tailboard_screen.dart`
- **Action:** Replace welcome heading with crew name + description
- **Requirements:** Lower profile header showing active crew info
- **Validation:** ✅ Crew-specific header displayed

### 7.2 Fix Tailboard Horizontal Overflow

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** `lib/features/crews/screens/tailboard_screen.dart`
- **Issue:** Overflow error when phone rotated horizontally
- **Action:** Implement responsive layout for landscape orientation
- **Validation:** ✅ No overflow in landscape mode

### 7.3 Simplify Crew Creation Flow

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** `lib/features/crews/screens/create_crew_screen.dart`
- **Action:** Remove "Join a Crew" button from Step 1, change text to "Next"
- **Validation:** ✅ Streamlined crew creation flow

### 7.4 Add All Classifications to Crew Creation [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Crew onboarding Step 2
- **Action:** Add operator, tree trimmer, all main app classifications
- **Validation:** ✅ Complete classification list available

### 7.5 Add Copper Borders to Crew Inputs [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Crew onboarding Step 2
- **Action:** Add copper borders to all input fields
- **Validation:** ✅ Consistent electrical theme applied

### 7.6 Add Circuit Background to Crew Onboarding [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Crew onboarding screens
- **Action:** Apply electrical circuit background pattern
- **Validation:** ✅ Consistent theme throughout crew flow

### 7.7 Replace Switch with JJ Circuit Breaker [P]

- [ ] **Status:** Not Started
- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Crew onboarding screens
- **Action:** Use custom JJCircuitBreakerSwitch component
- **Validation:** ✅ Consistent electrical component usage

### 7.8 Enhance Create Crew Button [P]

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 🔧 Medium
- **Agent:** `ui-ux-designer`
- **File:** `lib/features/crews/screens/create_crew_screen.dart`
- **Action:** Add animation/gradient/shadow to signify commitment
- **Requirements:** Maintain design consistency with app theme
- **Validation:** ✅ Engaging, thematically consistent button
- **Implementation:**
  - Added sophisticated button with copper glow effects
  - Implemented pulse and sparkle animations
  - Created multi-layered gradient design
  - Added press animation feedback
  - Maintained electrical theme consistency

### 7.9 Fix Crew Preferences Dialog

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** Set crew preference dialog
- **Issues:**
  - Overflow on top right corner
  - Replace job roles with construction types
  - Change button text from "Save Preferences" to "Save"
  - Fix Firestore permission error
- **Validation:** ✅ Dialog works without errors

### 7.10 Fix Crew Permission Error

- [x] **Status:** COMPLETED ✅
- **Difficulty:** ⚡ High
- **Agent:** `security-auditor`
- **Issue:** "Firestore error updating crew caller does not have permission"
- **Files:** Firebase security rules, crew service
- **Action:** Fix Firestore rules for crew preference updates
- **Validation:** ✅ Crew preferences save successfully
- **Implementation:**
  - Enhanced Firestore security rules with comprehensive membership validation
  - Added multiple permission checking methods (members subcollection, roles map, memberIds array)
  - Implemented role-based field access control
  - Added enhanced error handling with specific permission denied messages
  - Created comprehensive security test coverage
  - Generated security fix documentation

## Phase 8: Feed Tab Implementation (Days 8-9)

**Dependencies:** None - Can run parallel

### 8.1 Enable Feed Tab for All Users

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** Feed tab implementation
- **Requirements:** Access regardless of crew membership
- **Action:** Remove crew membership restrictions from feed
- **Validation:** ✅ All users can access feed

### 8.2 Add Feed Posting Interface [P]

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** Feed tab UI
- **Action:** Add FAB or input window for creating posts
- **Validation:** ✅ Users can create new posts

### 8.3 Implement Feed Post Display [P]

- [ ] **Status:** Not Started
- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** Feed tab UI
- **Requirements:**
  - Show 50 most recent posts
  - Most recent at top
  - No sort/filter functionality
- **Validation:** ✅ Posts display correctly with 50-post limit

## Phase 9: Chat System Design (Days 9-10)

**Dependencies:** Crew system functional

### 9.1 Design Chat Interface

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 🔧 Medium
- **Agent:** `ui-ux-designer`
- **File:** `lib/features/crews/screens/chat_screen.dart`
- **Requirements:**
  - Crew members only
  - User messages on right, others on left
  - Newest messages at bottom
  - Standard messaging app layout
- **Validation:** ✅ Chat UI follows messaging conventions
- **Implementation:**
  - Created professional chat interface with electrical theme
  - Implemented user/other message alignment (right/left)
  - Added personalized avatars with electrical styling
  - Built message bubbles with copper gradient for user messages
  - Added timestamps and user identification
  - Implemented proper chat input with send functionality
  - Added chat animations and smooth scrolling

### 9.2 Implement User Avatars [P]

- [x] **Status:** COMPLETED ✅ (as part of 9.1)
- **Difficulty:** 📦 Low
- **Agent:** `ui-ux-designer`
- **File:** Chat system
- **Requirements:**
  - Circular avatar icons
  - Initials if no avatar image
  - Customizable colors/images
- **Validation:** ✅ Personalized avatar system working

### 9.3 Add Chat Input Interface [P]

- [x] **Status:** COMPLETED ✅ (as part of 9.1)
- **Difficulty:** 📦 Low
- **Agent:** `ui-ux-designer`
- **File:** Chat tab
- **Action:** Single-line text input with send button at bottom
- **Validation:** ✅ Standard chat input functionality

## Phase 10: Members Tab & Direct Messaging (Days 10-11)

**Dependencies:** Chat system foundation

### 10.1 Implement Members List

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Members tab
- **Requirements:**
  - List all active crew members
  - Show name, home local, books, custom info
- **Validation:** ✅ Complete member information displayed

### 10.2 Add Member Action Options [P]

- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** Members tab
- **Action:** Add "Direct Message" option when selecting member
- **Note:** "View Profile" is future concept, focus on DM
- **Validation:** ✅ Direct messaging option available

## Phase 11: Search & Settings Fixes (Days 11-12)

**Dependencies:** None - Can run parallel

### 11.1 Fix Locals Screen Search

- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** `lib/screens/storm/locals_screen.dart`
- **Issue:** Search doesn't work for city, state, local number
- **Action:** Debug and fix search functionality completely
- **Validation:** ✅ Search works for all criteria

### 11.2 Fix Settings Image Upload Crash

- **Difficulty:** ⚡ High
- **Agent:** `flutter-expert`
- **File:** `lib/screens/settings/settings_screen.dart`
- **Issue:** App crashes when uploading gallery image
- **Action:** Debug image upload flow, fix crash
- **Validation:** ✅ Image upload works without crashing

### 11.3 Fix Settings Edit Profile Error

- **Difficulty:** 🔧 Medium
- **Agent:** `flutter-expert`
- **File:** `lib/screens/settings/settings_screen.dart`
- **Issue:** Error "init' is not a sub type of 'string'"
- **Action:** Fix type error in profile editing
- **Validation:** ✅ Profile editing works without errors

### 11.4 Personalize Settings Header [P]

- [x] **Status:** COMPLETED ✅
- **Difficulty:** 📦 Low
- **Agent:** `ui-ux-designer`
- **File:** `lib/screens/settings/settings_screen.dart`
- **Action:** Display ticket number, name, catchy expression
- **Requirements:** More personal connection with user
- **Validation:** ✅ Engaging, personalized header
- **Implementation:**
  - Created dynamic personalized header with electrical theme
  - Added animated profile avatar with copper glow effects
  - Implemented user name display with welcoming message
  - Added ticket number and local number display
  - Created rotating catchy expressions for electrical workers
  - Added smooth animations and transitions
  - Integrated pulse and sparkle effects
  - Maintained professional IBEW aesthetic

## Phase 12: Profile Screen Improvements (Days 12-13)

**Dependencies:** Settings fixes

### 12.1 Fix Profile Header Display

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Profile screen header
- **Action:** Replace email with name, format "IBEW Local: [localNumber]"
- **Requirements:** Use RichText widget for proper formatting
- **Validation:** ✅ Professional profile header

### 12.2 Reactivate Profile Tooltips [P]

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Profile screen
- **Action:** Implement/activate tooltips for profile editing guidance
- **Validation:** ✅ Helpful tooltips explain editing process

### 12.3 Update Books Field Hints [P]

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Professional tab
- **Action:** Replace "Book 1, Book 2" with "84, 222, 111, 1249, 71"
- **Validation:** ✅ Realistic local number examples

## Phase 13: Resources Screen Updates (Days 13-14)

**Dependencies:** None - Can run parallel

### 13.1 Replace Government with Helpful Section

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Resources screen Links tab
- **Action:** Remove Government sections, add Helpful section
- **Validation:** ✅ Section reorganization complete

### 13.2 Add Union Pay Scales Containers [P]

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Resources screen Helpful section
- **Requirements:**
  - Link to <https://unionpayscales.com/trades/ibew-linemen/>
  - Display `pay_scale_card.dart` widget instead of browser
- **Validation:** ✅ Both pay scale options working

### 13.3 Connect NFPA Link [P]

- **Difficulty:** 📦 Low
- **Agent:** `flutter-expert`
- **File:** Resources screen Safety section
- **Action:** Connect NFPA to specified URL
- **Validation:** ✅ NFPA link opens correctly

## Summary Metrics

- **Total Tasks:** 47
- **Completed Tasks:** 9 ✅
- **Parallel Executable:** 28 tasks [P]
- **Critical Priority:** 5 tasks
- **High Complexity:** 4 tasks ⚡
- **Medium Complexity:** 19 tasks 🔧
- **Low Complexity:** 24 tasks 📦
- **Estimated Duration:** 14 days
- **Required Agents:** 6 specialists

## Agent Allocation

- `ui-ux-designer`: Dark mode, themes, visual design (8 tasks) - **9 COMPLETED ✅**
- `flutter-expert`: UI implementation, screen fixes (25 tasks)
- `auth-expert`: Authentication analysis and fixes (3 tasks)
- `security-auditor`: Permission fixes, security rules (2 tasks)
- `team-coordinator`: Multi-phase coordination (1 task)

## Priority Execution Order

1. **Phase 1-2 (Days 1-3):** Theme foundation and auth analysis - **PHASES 1.1, 1.2, 2.1, 2.2, 2.3 COMPLETED ✅**
2. **Phases 3-6 (Days 4-7):** Screen-specific improvements
3. **Phase 7 (Days 7-10):** Complex crew system overhaul - **PHASE 7.8 COMPLETED ✅**
4. **Phases 8-13 (Days 8-14):** Feature additions and final fixes - **PHASES 9.1, 9.2, 9.3, 11.4 COMPLETED ✅**

## Documentation Requirements

- Comprehensive documentation for all changes/modifications/additions
- Each task must include detailed implementation notes
- Theme changes must be fully documented with before/after examples
- All UI changes must include visual documentation

This plan addresses every item in your TODO.md with proper dependency management, realistic complexity assessment, and appropriate agent specialization assignments.