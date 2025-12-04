# TODO_TASKS.md - Journeyman Jobs Implementation Guide

Generated on: December 1, 2025

## MANDATORY VERIFICATION PROTOCOL — THIS IS LAW

> **NO SECTION IS EVER CONSIDERED FINISHED UNTIL THIS PROCESS IS FOLLOWED. NO EXCEPTIONS.**

As soon as you (or any developer/agent) finish **any section or group of tasks** in this file, you **MUST** run the following agent validation gauntlet **in this exact order** — **before** marking anything complete, before checking any box as [✓], and before moving on:

1. **@task-completion-validator** → Does it actually work end-to-end? No stubs, no TODOs, no silent failures.
2. **@Jenny** → Does the implementation **exactly** match the PRD and current specifications? Line-by-line audit.
3. **@code-quality-pragmatist** → Is there any over-engineering, unnecessary abstraction, or complexity for complexity’s sake?
4. **@claude-md-compliance-checker** → Are there **any** violations of project rules or CLAUDE.md constraints?
5. **@ui-comprehensive-tester** → (UI sections only) Full cross-platform, gesture, orientation, and edge-case testing.
6. **@karen** → Final no-bullshit reality check: “Does this actually work in the real world, or are we lying to ourselves?”

**Only when ALL relevant agents above return PASS** are you allowed to:

- Change section status to **[Completed]**
- Turn any checkbox from [ ] → [✓]
- Move on to the next section

If **any single agent fails**, the section stays **[In Progress]** (or reverts to **[Not Started]** if critical).  
Fix it. Rerun the gauntlet. Repeat until green.

This is not optional. This is not “later.”  
This is the new religion.

---

## INTRODUCTION

This comprehensive implementation guide breaks down all requirements from TODO.md into actionable, manageable tasks. Each task represents a specific, implementable unit of work that can be completed in 1-4 hours by a developer.

### STRUCTURE

- **Grouped by Screens/Pages**: Tasks are organized following the same structure as TODO.md
- **Status Indicators**: Each section has a progress status to track overall completion
- **Task Breakdown**: requirements broken into 5-15 specific, testable tasks per section
- **Domain Labels**: Each task labeled by technical domain for proper assignment
- **Checkboxes**: Mark completion with [ ] → [✓] **ONLY AFTER FULL AGENT GAUNTLET PASSES**

### STATUS LEGEND

- **[Not Started]** - No work begun
- **[In Progress]** - Development underway
- **[Completed]** - All tasks finished, tested, and **passed full agent validation gauntlet**
- **[Final Testing]** - Awaiting integration testing
- **[Blocked]** - Waiting on dependencies

### DOMAIN LABELS

- **[UI-UX]** - User interface and experience design
- **[Backend]** - Server-side logic and APIs
- **[AI-ML]** - Artificial intelligence and machine learning
- **[Security]** - Authentication, authorization, data protection
- **[Database]** - Data storage and management
- **[Integration]** - External API and service integrations
- **[Platform]** - App-wide infrastructure and setup
- **[QA/QC]** - Quality assurance and testing
- **[Performance]** - Optimization and scalability
- **[Accessibility]** - WCAG and disability compliance

---

## APP WIDE CHANGES

Status: [In Progress]

### Custom Model Integration Tasks

- [x] [AI-ML] Define data model interfaces for job summaries, user feedback, and suggestions structures
- [x] [AI-ML] Create pub.dev/package library structure for custom local AI model integration
- [x] [AI-ML] Implement local model initialization and configuration system
- [x] [Backend] Add job feedback logging system to capture user experiences and opinions
- [x] [AI-ML] Build job summarization algorithm that analyzes job data for key highlights
- [x] [AI-ML] Create user experience matching logic to correlate feedback with user preferences
- [x] [UI-UX] Design UI components for displaying personalized job suggestions
- [x] [Backend] Implement real-time feedback collection during job browsing
- [x] [AI-ML] Develop job recommendation engine using preference matching
- [x] [Backend] Add Firebase query optimization for real-time job filtering by suggestions
- [x] [Security] Implement user data privacy controls for feedback sharing
- [x] [Backend] Create admin interface for model training data management
- [x] [AI-ML] Add model accuracy metrics and improvement tracking
- [x] [UI-UX] Integrate suggestion previews in job card hover states
- [x] [QA/QC] Test suggestion accuracy with user feedback validation

### Custom Model Pro Actions

- [x] [AI-ML] Implement subscription-based feature gating for AI interactions
- [x] [Backend] Create settings update API for preferences and notifications
- [x] [AI-ML] Add real-time job query and notification system for matches
- [x] [Security] Implement premium subscription verification before actions
- [x] [Backend] Build Firebase query automation for user's current preferences
- [x] [UI-UX] Create notification dialog system for AI job recommendations
- [x] [Backend] Add direct message composition from AI suggestions to user chats
- [x] [Security] Implement rate limiting for AI action triggering
- [x] [QA/QC] Create user flow testing for AI action automation
- [ ] [Platform] Add billing integration for subscription verification

---

## ONBOARDING SCREENS

Status: [Not Started]

### Background Implementation

- [ ] [UI-UX] Identify all onboarding screen files and current background usage
- [ ] [UI-UX] Create electrical circuit background component in design_system
- [ ] [UI-UX] Test circuit background compatibility with auth, step screens
- [ ] [UI-UX] Update ElectricalCircuitBackground component for onboarding variations
- [ ] [UI-UX] Ensure text readability over circuit background across all devices

### AUTH SCREEN Changes

- [ ] [UI-UX] Locate current tab bar implementation in auth screen
- [ ] [UI-UX] Enhance tab bar UI to match modern design specifications
- [ ] [UI-UX] Add copper border reinforcement to all text fields
- [ ] [UI-UX] Test enhanced tab bar functionality with existing sigDl functionality
- [ ] [UI-UX] Apply electrical theme consistency throughout auth screen
- [ ] [QA/QC] Cross-platform testing for enhanced auth screen appearance

### ONBOARDING STEPS SCREEN - STEP 1

- [x] [UI-UX] Locate onboarding steps screen file structure
- [x] [UI-UX] Adjust buildStepHeader positioning for centered alignment
- [x] [UI-UX] Add copper border styling to all text fields in step 1
- [ ] [UI-UX] Reduce state dropdown width by half for better layout
- [ ] [UI-UX] Expand zip code field to fill remaining space
- [x] [Backend] Create user document creation logic on Next button press
- [x] [Database] Implement Cloud Firestore user document schema
- [x] [Integration] Add Firebase authentication user ID to new document
- [x] [UI-UX] Add confirmation feedback when user document is created
- [x] [QA/QC] Test user document creation workflow from onboarding

### ONBOARDING STEPS SCREEN - STEP 2

- [ ] [UI-UX] Verify Next button functionality from step 2 screens
- [ ] [UI-UX] Add copper border styling to all step 2 text fields
- [x] [Backend] Implement field data saving to existing user document on step 2 completion
- [x] [UI-UX] Validate all form fields have proper validation feedback
- [x] [Backend] Add document update logic for step 2 navigation
- [x] [UI-UX] Ensure seamless transition between step 1 and step 2
- [x] [QA/QC] Validate step 2 field persistence and navigation flow

### ONBOARDING STEPS SCREEN - STEP 3

- [x] [UI-UX] Verify Next button functionality from step 3 screens
- [x] [UI-UX] Add copper border styling to all step 3 text fields
- [x] [Backend] Implement final field data saving to user document on step 3 completion
- [x] [Backend] Add navigation logic from step 3 to home screen
- [x] [UI-UX] Create completion animation or success state
- [x] [Backend] Validate all user document fields are properly saved
- [x] [Platform] Ensure user authentication state is properly updated

### General Onboarding Theme

- [x] [UI-UX] Ensure theme consistency (light/dark mode) across all onboarding screens to prevent mode switching after authentication.

### AUTH SCREEN Enhancements

- [x] [UI-UX] Replace the existing `tab bar` on the Auth Screen with the enhanced version specified in `guide/tab-bar-enhancement.md`.
- [x] [UI-UX] Ensure all original tab bar functionality is maintained after the UI upgrade.
- [x] [UI-UX] Fix the layout issue causing a gap between the sign-up/sign-in tabs and the surrounding border.

### ONBOARDING STEPS SCREEN - STEP 1 Enhancements

- [x] [UI-UX] Shorten the `state` dropdown field to half its current width.
- [x] [UI-UX] Expand the `zip code` text field to occupy the remaining horizontal space next to the state dropdown.

---

## HOME SCREEN

Status: [Not Started]

### Personalization Updates

- [x] [Backend] Create user profile data retrieval for personalized greeting
- [x] [UI-UX] Update home screen welcome text to use "Welcome Back! {firstName lastName}"
- [x] [Backend] Add Firebase user document query for name field retrieval
- [x] [UI-UX] Handle missing name scenarios with fallback greeting
- [x] [QA/QC] Test name display across different user profile states

### Active Crews Subsection Removal

- [x] [UI-UX] Remove Active Crews section from home screen
- [x] [UI-UX] Adjust home screen layout to fill empty space
- [x] [UI-UX] Update responsive design without active crews section

### Realtime Summary Feed Implementation

- [x] [UI-UX] Design realtime summary feed component replacing active crews
- [ ] [Backend] Create Firebase listener for user's recent posts, messages, jobs
- [ ] [UI-UX] Implement scrolling horizontal/vertical feed layout
- [ ] [Backend] Build basic query logic for posts, messages, jobs aggregation
- [ ] [UI-UX] Add resource icons for post/message/job types
- [ ] [Backend] Implement caching mechanism for performance optimization
- [ ] [UI-UX] Add gesture-based navigation to detailed post/message/job views
- [ ] [QA/QC] Test feed loading performance with large datasets

### Quick Actions Enhancement

- [ ] [UI-UX] Add electrical calculator link to Quick Actions section
- [ ] [UI-UX] Add view crews link to Quick Actions section
- [ ] [UI-UX] Restructure Quick Actions layout for additional items
- [ ] [UI-UX] Ensure calculator and crews links navigate to correct screens
- [ ] [Platform] Validate deep linking functionality to calculator and tailboard
- [ ] [UI-UX] Optimize Quick Actions for mobile dashboard usability

### Suggested Jobs Enhancement

- [ ] [UI-UX] Identify current suggested jobs card structure
- [ ] [UI-UX] Condense job card display to essential data (Per Diem, Hours, Rate, Conditions)
- [ ] [Backend] Enhance job preference filtering logic in backend
- [ ] [UI-UX] Create popup dialog component for detailed job display
- [ ] [UI-UX] Implement tap gesture to trigger detailed job popup
- [ ] [UI-UX] Add smooth popup animation for job detail display
- [ ] [Backend] Optimize job data retrieval for popup display performance
- [ ] [QA/QC] Test suggested jobs filtering accuracy against user preferences

---

## JOB SCREEN

Status: [Not Started]

### Enhanced Job Card Theme

- [ ] [UI-UX] Identify current job card theming and color scheme
- [ ] [UI-UX] Redesign job card theme with money, payroll, overtime visual motifs
- [ ] [UI-UX] Add customized job card component with enhanced styling
- [ ] [UI-UX] Integrate money-themed icons and animations to job cards
- [ ] [UI-UX] Ensure new theme maintains readability and information hierarchy
- [ ] [Platform] Test job card display across different device sizes

### Navigation Badge Fix

- [ ] [UI-UX] Locate current notification badge implementation on app bar
- [ ] [UI-UX] Verify notification badge current navigation destination
- [ ] [UI-UX] Redirect notification badge navigation to notification settings screen
- [ ] [Platform] Test notification badge navigation flow correctly functions
- [ ] [UI-UX] Ensure smooth transition to notification settings screen

### Sort/Filter Enhancement

- [ ] [UI-UX] Locate sort/filter horizontal scroll view underneath app bar
- [ ] [UI-UX] Verify "choice chips" implementation and styling
- [ ] [UI-UX] Identify "journeyman lineman" choice chip and error condition
- [ ] [UI-UX] Fix error handling for journeyman lineman filter selection
- [ ] [Backend] Create backend filtering logic for journeyman lineman jobs
- [ ] [UI-UX] Test all choice chip selections for proper filtering behavior
- [ ] [QA/QC] Validate filter accuracy against job classification data

### Job Dialog Expansion

- [ ] [UI-UX] Identify current job dialog popup implementation
- [ ] [UI-UX] Assess job dialog current information display capacity
- [ ] [UI-UX] Enhance job dialog to display full job posting data
- [ ] [UI-UX] Improve job dialog layout for better information organization
- [ ] [UI-UX] Add scrolling capability for lengthy job descriptions
- [ ] [Backend] Optimize job data retrieval for detailed display
- [ ] [Accessibility] Validate job dialog adheres to accessibility guidelines
- [ ] [QA/QC] Test job dialog display across various job data sizes

---

## STORM SCREEN

Status: [In Progress]

### Energetic Vibe Redesign

- [x] [UI-UX] Analyze current storm screen design and identify key components
- [x] [UI-UX] Create custom energetic visual theme for storm screen
- [x] [UI-UX] Redesign icon set specifically for storm work environment
- [x] [UI-UX] Customize color palette emphasizing storm work energy
- [x] [UI-UX] Add thunderstorm-inspired visual motifs and gradients
- [x] [UI-UX] Implement dynamic background elements for storm atmosphere
- [x] [UI-UX] Add lightning bolt animations and electrical spark effects
- [x] [UI-UX] Enhance typography with storm work theme
- [x] [UI-UX] Create custom storm-themed badge/icon system

### Sound Integration Planning

- [ ] [Integration] Research React Native or Flutter sound integration libraries
- [ ] [Platform] Evaluate platform requirements for sound implementation
- [ ] [UI-UX] Design user preference settings for sound notifications
- [ ] [Backend] Create sound file management system for storm alerts
- [ ] [Security] Implement user consent system for sound playback
- [ ] [QA/QC] Test sound functionality across iOS and Android platforms

### Interactive Elements Enhancement

- [ ] [UI-UX] Add gesture-based interactions to storm event cards (swipe, long press)
- [ ] [UI-UX] Implement micro-animations for event card reveals
- [x] [UI-UX] Add weather radar integration with interactive controls
- [ ] [UI-UX] Create animated weather icons that respond to storm conditions
- [ ] [UI-UX] Add haptic feedback for important storm notifications
- [ ] [UI-UX] Implement pull-to-refresh with storm-themed animations
- [ ] [Performance] Optimize animation performance for low-end devices

### App Bar Navigation Fix

- [x] [UI-UX] Verify current notification badge implementation in app bar
- [x] [UI-UX] Change notification badge destination from storm notifications to notifications settings screen
- [x] [UI-UX] Confirm navigation flow to notification settings screen
- [ ] [Platform] Test navigation works on all screen entry points

### Themed Component Consistency

- [x] [UI-UX] Apply energetic storm theme consistently across all components
- [x] [UI-UX] Update power outage cards with storm theme styling
- [x] [UI-UX] Apply theme to statistics cards with animated counters
- [x] [UI-UX] Enhance dropdown filters with stormy visual design
- [x] [UI-UX] Update tornado event cards with interactive theme elements
- [ ] [Platform] Validate theme consistency across light and dark modes

### Emergency Work Section Removal

- [x] [UI-UX] Locate and remove Emergency Work Available section content
- [x] [UI-UX] Adjust storm screen layout to compensate for removed section
- [x] [UI-UX] Update screen scrolling behavior and padding
- [ ] [QA/QC] Test screen layout integrity after section removal

### Storm Contractors Component Creation

- [x] [UI-UX] Create new JJContractorCard widget component class
- [x] [UI-UX] Design contractor card layout with contact information display
- [x] [Platform] Implement interactive elements for email, phone, website
- [x] [Platform] Add URL launching capability for website links
- [x] [Platform] Integrate dial system for phone number contacts
- [x] [Backend] Update contractors data loading from docs\storm_roster.json
- [x] [UI-UX] Apply storm theme styling to JJContractorCard
- [x] [UI-UX] Add interaction animations for phone/email/website actions
- [ ] [Platform] Test cross-platform URL launching functionality
- [ ] [QA/QC] Validate interaction with various contact method types

### App Bar Color Fix

- [ ] [UI-UX] Change the `app bar` color on the Storm Screen to be solid primary navy blue.

### Storm Statistics Feature

- [ ] [UI-UX] Design and implement the "Storm Stats" section UI.
- [ ] [UI-UX] Build the `StormTrackForm` as a modal or bottom sheet for user input, using the provided code from `TODO.md` as a reference.
- [ ] [Backend] Implement the `StormTrackingService` to handle adding, updating, and deleting storm track records in Firestore.
- [ ] [UI-UX] Develop the UI for displaying comprehensive storm stat summaries based on user-provided data.
- [ ] [UI-UX] Create an interactive tool for users to calculate different values from their storm history.
- [ ] [Backend] Implement a feedback mechanism for users to submit their experience with the storm tracking feature.

---

## TAILBOARD SCREEN

Status: [Not Started]

### Create Crews Screen

- [ ] [UI-UX] Design crew creation interface with form validation
- [ ] [UI-UX] Implement crew name, description, and settings form fields
- [ ] [Backend] Create Firebase collection structure for crews
- [ ] [Backend] Add crew creation API with document validation
- [ ] [Security] Implement crew member invitation system with permissions
- [ ] [UI-UX] Add crew creation success feedback and navigation
- [ ] [QA/QC] Test crew creation workflow end-to-end

### Messages Tab Implementation

- [ ] [Backend] Create Firebase collection for crew messages
- [ ] [UI-UX] Build message display layout with sender information
- [ ] [UI-UX] Implement message input and sending functionality
- [ ] [Realtime] Add Firebase real-time listener for new messages
- [ ] [UI-UX] Add message timestamp and delivery status indicators
- [ ] [UI-UX] Implement message threading or reply functionality
- [ ] [Security] Add message visibility controls by crew membership
- [ ] [Performance] Optimize message loading for large conversation history
- [ ] [Accessibility] Ensure message input accessibility for different users
- [ ] [QA/QC] Test message exchange between multiple crew members

### Feed Tab Implementation

- [ ] [UI-UX] Design feed layout for crew posts and announcements
- [ ] [Backend] Create Firebase collection for crew feed posts
- [ ] [UI-UX] Implement post creation interface with rich text support
- [ ] [Realtime] Add real-time feed updates for new posts
- [ ] [UI-UX] Add post interaction features (like, comment, share)
- [ ] [UI-UX] Implement post attachment support (images, files)
- [ ] [Security] Control post visibility based on crew permissions
- [ ] [UI-UX] Add post filtering and sorting options
- [ ] [Performance] Implement feed pagination for large crews
- [ ] [QA/QC] Test feed interaction features across different user roles

### Chat Tab Implementation

- [ ] [UI-UX] Create chat interface with message bubbles and avatars
- [ ] [Backend] Implement Firebase real-time chat system for crews
- [ ] [UI-UX] Add typing indicators and online status display
- [ ] [UI-UX] Implement file and media sharing in chat
- [ ] [Realtime] Ensure chat synchronization across all crew members
- [ ] [Notification] Add chat notification system within the app
- [ ] [Security] Implement end-to-end encryption for chat messages
- [ ] [Performance] Optimize chat performance for large crews
- [ ] [Accessibility] Ensure chat accessibility for all users
- [ ] [QA/QC] Test chat functionality in multi-user scenarios

### Members Tab Implementation

- [ ] [UI-UX] Build member list interface with profiles and roles
- [ ] [Backend] Implement crew member management APIs
- [ ] [Security] Create role-based permissions (admin, member, moderator)
- [ ] [UI-UX] Add member invitation system with email/QR code options
- [ ] [UI-UX] Implement member role modification interface
- [ ] [UI-UX] Add member removal and ban functionality
- [ ] [Realtime] Update member status in real-time (online/offline)
- [ ] [Backend] Implement crew member audit trails
- [ ] [QA/QC] Test member management across different permission levels

### UI/UX Enhancements

- [ ] [UI-UX] Modify crew selection dropdown to disappear after selection, but remain accessible via a 3-dot menu.
- [ ] [UI-UX] Redesign the screen background to use gradients or patterns (e.g., copper streaks) instead of solid colors.
- [ ] [UI-UX] Implement electrical-themed animations for transitions between the Feed, Jobs, Chat, and Members tabs.
- [ ] [UI-UX] Redefine and improve the layout of all content appearing above the tab bar.

### Permissions & Navigation

- [ ] [Security] Remove the 'Settings' action (the 4th action) from the tab action handlers for users who are not crew foremen.

### Feed Tab Fixes & Features

- [ ] [Backend] Debug and fix the 'Submit' button functionality for creating a new post.
- [ ] [UI-UX] Implement the "My Posts" filter action handler.
- [ ] [UI-UX] Implement the "Sort" (by date, popularity) action handler.
- [ ] [UI-UX] Implement the "History" action handler.

### Jobs Tab Features

- [ ] [UI-UX] Design and implement the UI for the `Jobs Tab`.
- [ ] [Backend] Implement the "Construction Type" filter action handler.
- [ ] [Backend] Implement the "Local" filter action handler.
- [ ] [Backend] Implement the "Classification" filter action handler.

### Chat Tab Features

- [ ] [UI-UX] Implement the "Channels" action handler.
- [ ] [UI-UX] Implement the "DMs" (Direct Messages) action handler.
- [ ] [UI-UX] Implement the "History" action handler.

### Members Tab Features

- [ ] [UI-UX] Implement the "Roster" action handler.
- [ ] [UI-UX] Implement the "Availability" action handler.
- [ ] [UI-UX] Implement the "Roles" action handler.

---

## LOCALS SCREEN

Status: [Not Started]

### State Filter Removal

- [ ] [UI-UX] Locate state filter implementation underneath app bar
- [ ] [UI-UX] Remove all state filter functionality and UI elements
- [ ] [UI-UX] Adjust locals screen layout to accommodate removed filter
- [ ] [UI-UX] Update responsive design without state filtering
- [ ] [Platform] Ensure screen navigation and display consistency
- [ ] [QA/QC] Test locals screen functionality without filter

---

## SETTINGS SCREEN

Status: [Not Started]

### Branch Creation

- [ ] [Platform] Create new Git branch for settings screen modifications
- [ ] [Platform] Ensure branch isolation for safe development practices

### Electrical Background Integration

- [ ] [UI-UX] Apply electrical circuit background to settings screen
- [ ] [UI-UX] Verify background compatibility with all settings content
- [ ] [UI-UX] Test text readability over electrical background
- [ ] [UI-UX] Ensure electrical theme consistency throughout settings

### User Data Enhancement

- [ ] [UI-UX] Identify current settings data display capabilities
- [ ] [UI-UX] Add comprehensive user information display components
- [ ] [UI-UX] Implement data visualization for user activity metrics
- [ ] [UI-UX] Add user engagement statistics and usage patterns
- [ ] [Backend] Create API endpoints for user data aggregation
- [ ] [UI-UX] Design interactive navigational tooltips for complex data

### Themed Component Enhancement

- [ ] [UI-UX] Update all settings screen components with JJ app theme
- [ ] [UI-UX] Implement enhanced interactivity features
- [ ] [UI-UX] Add micro-animations and gesture responses
- [ ] [Platform] Ensure theme consistency across different device types

### Coaching Tooltip Implementation

- [ ] [UI-UX] Design coaching tooltip system for user guidance
- [ ] [UI-UX] Implement contextual help overlays for complex sections
- [ ] [UI-UX] Create tooltip content explaining data meanings
- [ ] [UI-UX] Add progressive disclosure for advanced settings
- [ ] [Platform] Test tooltips accessibility and dismissal behavior

---

## ACCOUNT - PROFILE SCREEN

Status: [Not Started]

### Profile Dismantling

- [ ] [UI-UX] Identify settings tab location in profile screen
- [ ] [UI-UX] Extract functionality to be moved to appropriate locations
- [ ] [UI-UX] Remove settings tab from profile screen completely

### Coaching Tooltip Addition

- [ ] [UI-UX] Locate pencil icon in top right corner of app bar
- [ ] [UI-UX] Implement contextual tooltip explaining pencil icon functionality
- [ ] [UI-UX] Add tooltip animation and dismissal options
- [ ] [UI-UX] Test tooltip behavior across different screen states

### Theme Application

- [ ] [UI-UX] Apply JJ App Theme to entire profile screen
- [ ] [UI-UX] Update all components with themed styling
- [ ] [Backend] Ensure all user data from onboarding populates correctly
- [ ] [UI-UX] Replace all hardcoded user information with dynamic data
- [ ] [QA/QC] Validate user data display accuracy against onboarding inputs

### Personal Tab Implementation

- [ ] [UI-UX] Create personal information editing interface
- [ ] [Backend] Implement user data save functionality on form submission
- [ ] [UI-UX] Add confirmation toast/snack bar for data saving
- [ ] [UI-UX] Implement real-time validation feedback
- [ ] [Database] Ensure data persistence to Firebase user document
- [ ] [QA/QC] Test personal tab data saving and retrieval

### Professional Tab Implementation

- [ ] [UI-UX] Create professional information editing interface
- [ ] [UI-UX] Convert ticketNumber field to numeric keypad only
- [ ] [Backend] Implement user data save functionality for professional tab
- [ ] [UI-UX] Add confirmation toast/snack bar for data saving
- [ ] [Database] Ensure professional data persistence to Firebase
- [ ] [QA/QC] Test professional tab data saving and numeric input validation

### Settings Tab Redirection

- [ ] [UI-UX] Redirect settings tab to notifications settings screen (preferred among duplicates)
- [ ] [Platform] Ensure consistent navigation to single notifications settings location

### Account Actions Implementation

- [ ] [Security] Implement the end-to-end process for a user to change their password securely.
- [ ] [Backend] Develop a service to gather all of a user's data from Firestore and Storage for download.
- [ ] [UI-UX] Implement the "Download my Data" feature, allowing the user to trigger the data export.
- [ ] [Security] Implement a secure, multi-step process for a user to permanently delete their account and associated data.

### Support and About Implementation

- [ ] [Platform] Wire up the "Help and Support" link to navigate to the `Help and Support Screen`.
- [ ] [Content] Compose the official `Journeyman Jobs Terms of Service` document and create a view to display it.
- [ ] [Content] Compose the official `Journeyman Jobs Privacy Policy` document and create a view to display it.

---

## ACCOUNT - TRAINING CERTIFICATIONS SCREEN

Status: [Not Started]

### Certificates Tab Implementation

- [ ] [UI-UX] Design certificates display grid/list layout
- [ ] [UI-UX] Create certificate detail expansion view
- [ ] [Backend] Implement certificate data retrieval from Firebase
- [ ] [UI-UX] Add certificate validation status indicators
- [ ] [UI-UX] Implement certificate search and filtering
- [ ] [Backend] Add certificate upload functionality
- [ ] [Security] Validate certificate authenticity processes
- [ ] [QA/QC] Test certificate display and management workflow

### Courses Tab Implementation

- [ ] [UI-UX] Design courses catalog interface with progress tracking
- [ ] [UI-UX] Implement course enrollment and completion components
- [ ] [Backend] Create course data management system
- [ ] [UI-UX] Add course progress visualization (progress bars, completion status)
- [ ] [Backend] Implement learning management APIs
- [ ] [UI-UX] Create course content viewing interface
- [ ] [Platform] Add offline course access capabilities
- [ ] [QA/QC] Test course enrollment and progress tracking

### History Tab Implementation

- [ ] [UI-UX] Build training history timeline interface
- [ ] [UI-UX] Implement filtering and search within history
- [ ] [Backend] Create certificate and course completion tracking
- [ ] [UI-UX] Add certificate expiration warnings and renewal requests
- [ ] [UI-UX] Implement history export functionality
- [ ] [Backend] Add audit trail for credential management
- [ ] [Security] Implement data verification for historical records
- [ ] [QA/QC] Test history display and export capabilities

---

## SUPPORT - CALCULATORS

Status: [Not Started]

### Calculation Helper Screen

- [ ] [UI-UX] Design calculation helper interface with step-by-step guidance
- [ ] [UI-UX] Implement calculation history and saved formulas
- [ ] [Backend] Create calculation engine with formula validation
- [ ] [Platform] Add unit conversion utilities
- [ ] [QA/QC] Test calculation accuracy and helper guidance

### Conduit Fill Calculator Screen

- [ ] [UI-UX] Design conduit fill interface with wire specification inputs
- [ ] [Backend] Implement NEC conduit fill calculation algorithms
- [ ] [Platform] Add wire gauge and conduit size reference data
- [ ] [UI-UX] Create visual conduit fill visualization
- [ ] [QA/QC] Validate calculations against NEC standards

### Electrical Constants Screen

- [ ] [UI-UX] Design electrical constants reference interface
- [ ] [Backend] Implement searchable constants database
- [ ] [UI-UX] Add categorization and unit conversion features
- [ ] [Platform] Ensure offline accessibility
- [ ] [QA/QC] Verify constant accuracy and completeness

### Load Calculator Screen

- [ ] [UI-UX] Design load calculation workflow interface
- [ ] [Backend] Implement electrical load calculation algorithms
- [ ] [UI-UX] Add circuit breaker and conductor sizing recommendations
- [ ] [Platform] Integrate with other calculation tools
- [ ] [QA/QC] Test calculation accuracy against electrical codes

### Wire Size Chart Screen

- [ ] [UI-UX] Design wire size chart reference interface
- [ ] [Backend] Implement wire sizing calculation based on length and current
- [ ] [UI-UX] Add conductor material and insulation type selection
- [ ] [Platform] Add voltage drop calculation integration
- [ ] [QA/QC] Validate wire size recommendations

---

## SUPPORT - FEEDBACK SCREEN

Status: [Not Started]

### Feedback Form Implementation

- [ ] [UI-UX] Design comprehensive feedback collection interface
- [ ] [UI-UX] Implement rating, category, and description form fields
- [ ] [Backend] Create Firebase feedback submission API
- [ ] [Platform] Add attachment/photo support for issues
- [ ] [UI-UX] Implement submission confirmation and tracking
- [ ] [Backend] Add feedback categorization and priority routing
- [ ] [Security] Implement user data protection for feedback submission
- [ ] [QA/QC] Test feedback submission and confirmation flow

---

## SUPPORT - HELP AND SUPPORT SCREEN

Status: [Not Started]

### FAQ Tab Implementation

- [ ] [UI-UX] Design FAQ interface with search and category filtering
- [ ] [Backend] Create FAQ database with search functionality
- [ ] [UI-UX] Implement collapsible FAQ sections
- [ ] [Platform] Ensure offline FAQ accessibility
- [ ] [QA/QC] Test FAQ search and user satisfaction

### Contact Tab Implementation

- [ ] [UI-UX] Design contact form with subject line and priority options
- [ ] [Backend] Implement support ticket creation system
- [ ] [UI-UX] Add contact method preferences (chat, email, phone)
- [ ] [Backend] Integrate with support CRM if applicable
- [ ] [Security] Add data protection for user contact information
- [ ] [QA/QC] Test support ticket creation and routing

### Guides Tab Implementation

- [ ] [UI-UX] Design guides library with categories and search
- [ ] [Backend] Create guide content management system
- [ ] [UI-UX] Implement guide viewing and bookmarking features
- [ ] [Platform] Add offline guide download capabilities
- [ ] [QA/QC] Test guide accessibility and content accuracy

---

## SUPPORT - RESOURCES SCREEN

Status: [Not Started]

### Documents Tab - IBEW Documents

- [ ] [UI-UX] Design document library interface with categories
- [ ] [Backend] Create document management and search system
- [ ] [UI-UX] Implement document viewing and bookmarking
- [ ] [Platform] Add offline document access
- [ ] [Security] Implement document access control

### Documents Tab - Safety

- [ ] [UI-UX] Design safety document organization by hazard type
- [ ] [Backend] Implement safety document database with version control
- [ ] [UI-UX] Add emergency reference quick-access features
- [ ] [Platform] Ensure offline safety document availability
- [ ] [QA/QC] Validate safety information accuracy

### Documents Tab - Technical

- [ ] [UI-UX] Design technical reference library interface
- [ ] [Backend] Create technical document tagging and search
- [ ] [UI-UX] Implement code/technical reference viewer
- [ ] [Platform] Add download and sharing capabilities
- [ ] [QA/QC] Test technical information accessibility

### Tools Tab - Calculators (Redirected)

- [ ] [Integration] Redirect calculator links to main calculator screens
- [ ] [UI-UX] Ensure tools tab provides clear navigation to calculator screens
- [ ] [Platform] Validate calculator deep linking

### Tools Tab - Reference

- [ ] [UI-UX] Design reference material browser interface
- [ ] [Backend] Create reference material organization system
- [ ] [UI-UX] Implement search and filtering capabilities
- [ ] [Platform] Ensure offline reference availability
- [ ] [QA/QC] Test reference material accessibility

### Links Tab - Training

- [ ] [UI-UX] Design training resource link collection interface
- [ ] [Integration] Add links to IBEW training centers
- [ ] [Integration] Add links to NECA education centers
- [ ] [UI-UX] Implement link verification and status checking
- [ ] [Platform] Test external link opening across platforms

### Links Tab - Safety

- [ ] [UI-UX] Design safety resource link collection
- [ ] [Integration] Add NFPA fire safety links
- [ ] [UI-UX] Implement resource categorization
- [ ] [Platform] Add link validation scripts
- [ ] [QA/QC] Verify safety resource link accuracy

### Links Tab - Government

- [ ] [UI-UX] Design government resource interface
- [ ] [Integration] Add Department of Labor links
- [ ] [UI-UX] Implement compliance resource organization
- [ ] [Platform] Ensure secure opening of government links
- [ ] [QA/QC] Validate government resource accuracy

---

## APP SETTINGS REDESIGN

Status: [Not Started]

### Settings Screen Theme Consistency

- [ ] [UI-UX] Apply electrical circuit background to app settings screen
- [ ] [UI-UX] Ensure background compatibility with all setting categories
- [ ] [UI-UX] Test readability over electrical background theme
- [ ] [Platform] Validate theme consistency with app's electrical motif

### Settings Screen Structural Redesign

- [ ] [UI-UX] Remove duplicate notification settings from wherever they appear
- [ ] [UI-UX] Consolidate single notification settings screen location
- [ ] [UI-UX] Merge app settings, privacy, and account actions into unified interface
- [ ] [Platform] Ensure consistent navigation to merged settings sections

### Appearance & Display Settings

- [ ] [UI-UX] Implement the `Dark Mode` toggle switch (`JJBreaker_switch`) to change the app's theme.
- [ ] [UI-UX] Implement the `High Contrast` toggle switch to apply a high-contrast theme.
- [ ] [UI-UX] Implement the `Electrical Effects` toggle switch to enable/disable visual effects.
- [ ] [UI-UX] Implement the `Font Size` control for accessibility.

### Data & Storage Settings

- [ ] [Performance] Implement a basic `Offline Mode`.
- [ ] [Backend] Implement the `Auto-Download` feature.
- [ ] [Backend] Implement the `WIFI-Only Downloads` setting.
- [ ] [Performance] Create and implement a `Clear Cache` function.

---

## NOTIFICATION SETTINGS SCREEN

Status: [Not Started]

### Electrical Background Application

- [ ] [UI-UX] Apply electrical circuit background to notification settings
- [ ] [UI-UX] Verify text readability with electrical background
- [ ] [UI-UX] Test visual consistency with other thematically designed screens

### Component and Theme Enhancements

- [ ] [UI-UX] Replace generic toggle switches with the custom `JJBreaker_switch` component.
- [ ] [UI-UX] Ensure the electrical background correctly adapts to the user's selected theme (light or dark mode).

---

## PRIVACY AND SECURITY SCREEN

Status: [Not Started]

### Content Migration Implementation

- [ ] [UI-UX] Identify content in app settings screen under settings tab
- [ ] [UI-UX] Transfer all applicable content to privacy and security screen
- [ ] [UI-UX] Organize transferred content logically within privacy screen
- [ ] [UI-UX] Update navigation references to point to privacy screen
- [ ] [QA/QC] Validate all content successfully migrated without loss

---

## ABOUT SCREEN

Status: [Not Started]

### About Screen Implementation

- [ ] [UI-UX] Design about screen with app information and branding
- [ ] [Platform] Add version information and build details
- [ ] [UI-UX] Implement appropriate electrical background theming
- [ ] [UI-UX] Add company attribution and legal compliance information
- [ ] [QA/QC] Test about screen information accuracy and display

---

## IMPLEMENTATION NOTES

- **Each checkbox represents a specific, achievable task**
- **Status indicators help track overall section progress**
- **Domain labeling ensures proper developer assignment**
- **Tasks are designed for 1-4 hour completion windows**
- **Interdependencies are noted within major feature groups**
- **QA/QC tasks ensure quality throughout development**

## UPDATED GITHUB WORKFLOW FILE CONTENT

### Next Steps for Final Bug Squashing

Visit your updated project for the finalized round-robin builder that includes fixes for hanging imports, project builder improvements, and the implementation of ignore files for `/ios` and `/android`.

### Local Application Startup Instructions

To start the Flutter application locally, open your terminal and navigate to the journeyman-jobs directory, then run:

```bash
flutter run
```

### Firebase Setup Instructions

Ensure Firebase plugins are configured appropriately for Android and iOS builds, and that your Firebase project is associated with your GitHub repository for cloud deployments.

This completes the comprehensive implementation guide for all TODO.md requirements. The TODO-TASKS.md file has been successfully created in the root directory.
