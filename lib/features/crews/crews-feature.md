# CREWS FEATURE

## Overview

The Crews feature mimics real-world journeyman networking practices. Journeymen meet others pursuing similar job opportunities—whether seeking specific hours, pay rates, per diems, construction types, or other criteria. They maintain contact through a core group that shares the latest job information in real-time.

This feature provides a single hub where multiple users chasing similar job types can join the same crew and receive identical job data simultaneously. The feature includes a centralized location for interacting with other members in the app, called the `Tailboard Screen`.

The `Tailboard Screen` features a tab bar with four tabs: `Feed Tab`, `Jobs Tab`, `Chat Tab`, and `Members Tab`. Additional screens include the `Create Crew Screen` and `Crew Onboarding Screen`.

## CREATE CREW SCREEN

### Overview

The `Create Crew Screen` allows users to create a new crew. The user who creates the crew is automatically assigned the `Foreman` role. The Foreman is the only crew member who can set and modify crew preferences and settings; all others are standard members.

### Crew Preferences

Crew preferences mirror the job preferences users set during initial onboarding:

- Construction type
- Per diem rates
- Work hours
- Other job-related criteria

These preferences further filter jobs so that the Jobs tab displays only those matching the crew's criteria.

### Crew Settings

The Foreman names the crew and configures settings including:

- **Member Limits**

- Default maximum: 10 members (including Foreman)
- Adjustable: Foreman can set lower limits (e.g., 4 members)
- Once limit reached, no additional members can join

- **Membership Rules**

- Single user can be Foreman of only one crew at a time
- Users can be active members in up to three crews simultaneously
- Crews support maximum of 10 total members

## CREW ONBOARDING SCREEN

### Overview

*TBD - To be defined after core crew functionality is implemented*

## TAILBOARD SCREEN

### Overview

The Tailboard Screen provides a centralized hub for receiving and interacting with crew members. Users can:

- Chat with crew members
- Search for and view available crew-relevant jobs
- Access suggested jobs
- Read and post on the Feed Tab

### FEED TAB

The Feed tab is available to all authenticated app users. Users can post content that other authenticated users can view and interact with, including:

- Images
- Job-related posts
- Daily work experiences
- Any other content they choose

Posts appear in a list view with interaction icons at the bottom (similar to popular social media feeds), including:

- Like/unlike reactions
- Comments
- Share options

**Key Difference**: Unlike the Chat tab, users do not need to be crew members to access the Feed tab.

### JOBS TAB

The Jobs tab displays a list view of all available jobs, sorted and filtered by the crew preferences set during creation or modified by the Foreman. This functions identically to the suggested jobs feature on individual user home screens, but applied at the crew level.

- Same filtering logic and implementation as individual job suggestions
- Different app location, same core functionality
- Filters from the complete database of jobs
- Displays only jobs matching crew preferences

### CHAT TAB

The Chat tab provides private group messaging exclusively for crew members. Features include:

- Member-only access (private and restricted)
- Standard messaging app interface when activated:
  - Message bubbles
  - Bottom keyboard input
  - Reaction support
  - Custom user profiles
  - Standard chat app features

**Implementation Note**: Using the Flutter Chat UI package for consistent messaging experience.

### MEMBERS TAB

The Members tab displays a list of all crew members, showing:

- Username
- Basic member information
- *[TBD]* Profile view functionality when selecting a member

This ensures crew transparency so all members know who's on the team.
