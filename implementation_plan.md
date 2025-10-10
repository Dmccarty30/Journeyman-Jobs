# Implementation Plan

[Overview]
Identify and fix the root cause of the "Failed to create crew" error related to insufficient permissions. The error occurs when users attempt to create a new crew but are blocked by Firebase security rules or permission checks within the application.

This implementation will focus on analyzing the crew creation flow, Firebase security rules, and permission system to identify why users are incorrectly flagged as lacking permission to create crews. The solution will ensure that authenticated users with appropriate roles can successfully create crews.

[Types]
The permission system and Firebase security rules need to be analyzed to ensure they correctly handle crew creation permissions. The key types involved are:
- MemberRole enum (foreman, lead, member, admin)
- Permission enum (createCrew, updateCrew, deleteCrew, etc.)
- AuthState (tracks user authentication status)
- Crew model with foremanId field

[Files]
The following files need to be examined and potentially modified:

1. `firebase/firestore.rules` - Firebase security rules that govern crew creation
2. `lib/features/crews/services/crew_service.dart` - Contains the createCrew method and permission checks
3. `lib/features/crews/screens/create_crew_screen.dart` - UI for crew creation
4. `lib/features/crews/providers/crews_riverpod_provider.dart` - Provides crew service and related providers
5. `lib/providers/riverpod/auth_riverpod_provider.dart` - Manages authentication state

[Functions]
Key functions involved in crew creation:

1. `CrewService.createCrew()` - Main method that creates crews in Firestore
2. `CrewService._getNextCrewId()` - Generates unique crew IDs
3. `CrewService._checkCrewCreationLimit()` - Verifies user hasn't exceeded creation limits
4. Firebase security rule for crew creation - Checks if request.auth.uid matches foremanId
5. CreateCrewScreen._createCrew() - UI handler for crew creation

[Classes]
Classes that need examination:

1. `CrewService` - Contains all crew-related operations
2. `RolePermissions` - Maps roles to permissions
3. `AuthNotifier` - Manages authentication state
4. `Crew` - Model representing a crew
5. `CrewMember` - Model representing crew members

[Dependencies]
No new dependencies are needed for this fix. The existing Firebase and Flutter dependencies are sufficient.

[Testing]
Testing approach:
1. Verify that authenticated users can create crews
2. Test Firebase security rules with different user scenarios
3. Check permission validation in CrewService
4. Test crew creation flow with UI
5. Verify error messages are clear and helpful

[Implementation Order]
1. Examine Firebase security rules for crew creation
2. Analyze CrewService.createCrew method for permission checks
3. Verify authentication state handling in crew creation flow
4. Test with different user roles and scenarios
5. Fix permission issues found in the analysis
6. Update error handling to provide better feedback
7. Test the fix thoroughly
