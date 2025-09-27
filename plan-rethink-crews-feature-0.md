# CREWS Makeover

## Observations

I analyzed the current crews feature navigation flow and found that when users tap the "Crews" icon in the bottom navigation, it currently navigates to a `CrewsScreen` that shows either an empty state with create/join buttons OR delegates to `TailboardScreen` if the user has crews. The user wants to change this so the "Crews" icon navigates directly to `TailboardScreen` (the main hub), allow messaging access regardless of crew membership, and combine the create/join screens into a single screen accessible from the tailboard.

### Approach

The implementation will involve three main changes: 1) Update the `/crews` route to point directly to `TailboardScreen` instead of `CrewsScreen`, 2) Modify `TailboardScreen` to work gracefully when no crew is selected by leveraging existing direct messaging providers and adding a button to access crew creation/joining, and 3) Create a new combined `CrewOnboardingScreen` that merges the create and join functionality similar to the welcome screen pattern. This approach reuses existing infrastructure and providers while minimizing breaking changes.

### Reasoning

I explored the current navigation structure by examining the app router, bottom navigation implementation, and existing crew screens. I found that the current flow goes from bottom nav → `/crews` route → `CrewsScreen` → either empty state or `TailboardScreen`. I also examined the messaging providers and discovered that direct messaging functionality already exists independently of crews, which means users can access messaging without being in a crew. The welcome screen provided a good pattern for combining multiple options on one screen.

## Mermaid Diagram

sequenceDiagram
    participant User
    participant BottomNav as Bottom Navigation
    participant Router as App Router
    participant Tailboard as TailboardScreen
    participant Onboarding as CrewOnboardingScreen
    participant ChatTab as Chat Tab
    participant Messaging as Messaging Providers

    User->>BottomNav: Tap "Crews" icon
    BottomNav->>Router: Navigate to /crews
    Router->>Tailboard: Load TailboardScreen directly
    
    alt User has no crew selected
        Tailboard->>User: Show welcome message + "Create/Join Crew" button
        Tailboard->>ChatTab: Enable Chat tab for direct messages
        ChatTab->>Messaging: Use directMessagesProvider
        Messaging->>ChatTab: Return direct message conversations
        
        User->>Tailboard: Tap "Create/Join Crew" button
        Tailboard->>Router: Navigate to /crews/onboarding
        Router->>Onboarding: Load CrewOnboardingScreen
        
        alt User chooses Create Crew
            Onboarding->>User: Show create crew form
            User->>Onboarding: Submit crew creation
            Onboarding->>Router: Navigate back to /crews
            Router->>Tailboard: Load TailboardScreen with new crew
        else User chooses Join Crew
            Onboarding->>User: Show join crew form
            User->>Onboarding: Submit join request
            Onboarding->>Router: Navigate back to /crews
            Router->>Tailboard: Load TailboardScreen with joined crew
        end
    else User has crew selected
        Tailboard->>User: Show full crew functionality
        Tailboard->>ChatTab: Enable crew chat + direct messages
        ChatTab->>Messaging: Use crewMessagesProvider + directMessagesProvider
    end

## Proposed File Changes

### \lib\navigation\app_router.dart(NEW)

References:

- \lib\screens\crews\tailboard_screen.dart(NEW)
- \lib\features\crews\screens\crew_onboarding_screen.dart(NEW)

Update the `/crews` route (line 124-127) to point directly to `TailboardScreen()` instead of `CrewsScreen()`. Add a new route `/crews/onboarding` that points to the new `CrewOnboardingScreen`. Remove or deprecate the `/crews/create` and `/crews/join` routes since they will be replaced by the onboarding screen. Update the import statement to include the new `CrewOnboardingScreen` and remove the `CrewsScreen` import if it's being deleted.

### \lib\features\crews\screens\crew_onboarding_screen.dart(NEW)

References:

- \lib\screens\onboarding\welcome_screen.dart
- \lib\features\crews\screens\create_crew_screen.dart(NEW)
- \lib\features\crews\screens\join_crew_screen.dart(NEW)
- \lib\design_system\app_theme.dart

Create a new screen that combines the create crew and join crew functionality into a single interface. Use the `welcome_screen.dart` as a design pattern reference - create a centered layout with a large icon, title, description, and two prominent action buttons. The first button should be "Create a Crew" (primary style) and the second should be "Join a Crew" (outlined style). When users tap "Create a Crew", show the create crew form inline or navigate to a create crew flow. When users tap "Join a Crew", show the join crew form inline or navigate to a join crew flow. After successful crew creation or joining, navigate back to `/crews` so users land on the tailboard. Include proper error handling and loading states. Import necessary dependencies including the app theme, navigation, and crew services.

### \lib\screens\crews\tailboard_screen.dart(NEW)

References:

- \lib\features\crews\providers\messaging_riverpod_provider.dart(NEW)
- \lib\navigation\app_router.dart(NEW)

Modify the `_buildNoCrewSelected` method (lines 80-112) to show a more user-friendly interface that still allows access to the messaging system. Instead of showing just a message about no crew selected, create a layout that includes: 1) A welcome message explaining the tailboard, 2) A prominent button to access the new crew onboarding screen (`context.push('/crews/onboarding')`), 3) Keep the tab structure visible so users can still access the Chat tab for direct messaging. Update the `ChatTab` class (lines 630-808) to handle the case when `selectedCrew == null` by showing direct messages instead of crew chat. Modify the chat toggle logic to show "Direct Messages" and "Global Chat" instead of "Crew Chat" and "Direct Messages" when no crew is selected. Update the floating action button logic in `_buildFloatingActionButton` to work appropriately when no crew is selected.

### \lib\features\crews\providers\messaging_riverpod_provider.dart(NEW)

References:

- \lib\providers\riverpod\auth_riverpod_provider.dart
- \lib\features\crews\services\message_service.dart

Add a new provider called `globalMessagesProvider` that can provide a list of recent direct messages or conversations for users who are not in any crew. This could aggregate recent direct message conversations or provide a list of users the current user has messaged with. The provider should work independently of crew membership and leverage the existing `directMessagesProvider` functionality. Consider adding a `recentConversationsProvider` that returns a list of users the current user has had direct message conversations with, making it easier to show a conversation list in the Chat tab when no crew is selected.

### \lib\features\crews\screens\create_crew_screen.dart(NEW)

References:

- \lib\navigation\app_router.dart(NEW)

Update the navigation after successful crew creation (line 56) to navigate to `/crews` instead of `AppRouter.crews` if they're different, ensuring users land on the tailboard after creating a crew. Consider whether this screen should be kept as a standalone screen or integrated into the new `CrewOnboardingScreen`. If keeping it standalone, update any navigation references to point to the new onboarding flow.

### \lib\features\crews\screens\join_crew_screen.dart(NEW)

References:

- \lib\navigation\app_router.dart(NEW)

Update the navigation after successful crew joining (line 41) to navigate to `/crews` to ensure users land on the tailboard after joining a crew. Consider whether this screen should be kept as a standalone screen or integrated into the new `CrewOnboardingScreen`. If keeping it standalone, update any navigation references to point to the new onboarding flow.
