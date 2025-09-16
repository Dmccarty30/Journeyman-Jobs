# Memory Leak Investigation - CRITICAL P1

## Problem
IBEW electrical workers experiencing severe battery drain during 12+ hour shifts due to memory leaks from undisposed controllers.

## Investigation Plan
1. Find all StatefulWidget files
2. Check dispose() method implementations
3. Verify controller cleanup (TextEditingController, PageController, ScrollController)
4. Check stream subscription cleanup
5. Focus on high-impact screens used during storm work

## Files to Investigate (Priority Order)

### P1 - Storm/Emergency Screens (Battery Critical)
- [ ] Storm roster screens
- [ ] Weather alert screens
- [ ] Emergency job screens

### P2 - Communication Screens (High Usage)
- [ ] lib/features/crews/screens/crew_communication_screen.dart
- [ ] lib/features/crews/screens/crew_detail_screen.dart
- [ ] lib/features/job_sharing/screens/quick_signup_screen.dart

### P3 - Core App Screens
- [ ] lib/screens/nav_bar_page.dart
- [ ] Profile/settings screens

## Investigation Process
Let me start by reading the crew communication screen to identify memory leak patterns.