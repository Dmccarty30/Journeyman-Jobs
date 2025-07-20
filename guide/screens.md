# Journeyman Jobs App Analysis Report

`App Overview`

The Journeyman Jobs app is designed for IBEW (International Brotherhood of Electrical Workers) Journeymen to navigate and consolidate job opportunities from archaic job board systems. It helps unemployed Journeymen find work opportunities, particularly those looking to travel for work.

## Screens and Their Purposes

`Authentication Screens`

**Welcome Screen**: Entry point for non-authenticated users, provides navigation to login and signup options
**Login Screen**: Handles user authentication with email/password login and validation
**Signup Screen**: New user registration, collects basic user information
**Forgot Password Screen**: Allows users to reset their password

`Main Navigation Screens`

**Home Screen**: Dashboard with personalized job suggestions, entry point after authentication
**Jobs Screen**: Comprehensive job listings with filtering and searching capabilities
**Storm Screen**: Dedicated to emergency/storm restoration work opportunities (high-priority jobs)
**Unions Screen**: Directory of IBEW locals with contact information and details for union halls
**More/Settings Screen**: App configuration options and entry point to additional features

`Settings and Profile Screens`

**Profile Screen**: User information management, displays and allows editing of user details
**Help & Support Screen**: User assistance with FAQ, contact options, and troubleshooting
**Resources Screen**: Additional information, useful links and documents for Journeymen
**Training & Certificates Screen**: Manages user's professional certifications

`Core Features`

1. Onboarding Flow
3-step wizard collecting user metadata for personalized job recommendations
Captures basic info, job preferences, and feedback
Stores data in Supabase with validation rules
Uses AsyncStorage to persist onboarding state

2. Job Aggregation System
Centralizes job board scraping from legacy union systems
Scheduled scrapers run at specific times (4:30 PM local time)
Normalizes inconsistent job formats
Provides timezone-aware job posting timestamps

3. Job Browsing
Personalized dashboard with suggested jobs
Scrollable job cards with "Bid" action
Filter/search by location, union, job type
Bid submission confirmation flow

4. Local Union Directory
Searchable directory of 797+ IBEW locals
Contact information with hyperlinked phone/email/website
Offline access through local caching

5. User Profile Management
Stores comprehensive user information:
Personal details (name, address)
Professional information (ticket number, classification)
Job preferences (travel range, construction type)
Career goals and preferences

`Navigation Structure`

The app uses GoRouter for navigation with a bottom navigation bar (NavBarPage) for authenticated users:

Unauthenticated users start at WelcomeWidget
Authenticated users navigate through NavBarPage with tabs for:
Home
Jobs
Storm
Unions
More/Settings
Data Management
Database Structure
The app uses Firebase/Firestore for data storage with three main collections:

Users Collection - Stores user profiles with fields:
Basic info (name, email, address)
Professional details (ticket number, classification)
Preferences (construction type, travel preferences)
Onboarding status
Jobs Collection - Stores job listings scraped from union portals:
Job details (title, description, location)
Requirements (classification, construction type)
Timing information (start date, duration)
Contact details
Locals Collection - Stores information about IBEW local unions:
Contact information
Location details
Referral policies
Job board URLs for scraping
Authentication
The app uses Firebase Authentication with:

Email/password authentication
Possible social login options
Session management
Authorization for protected routes
Data Synchronization
Backend uses FastAPI for API endpoints
Celery workers handle job scraping tasks
Delta sync minimizes database writes
Offline caching for local union directory
Technical Architecture
Frontend: Flutter/Dart with FlutterFlow components
Backend: Python FastAPI
Database: Firebase Firestore
Authentication: Firebase Auth
Job Scraping: Celery workers with BeautifulSoup/Playwright
Caching: AsyncStorage and SQLite for offline access
