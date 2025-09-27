# Implementation Plan

[Overview]
This plan outlines the steps to fix the Riverpod `_TypeError` and implement new messaging features, including a list of direct message conversations, a mechanism for sending direct messages, and a new "Home" tab with global chat functionality. The implementation will involve modifying existing providers and services, creating new ones, and refactoring the `TailboardScreen` to support these features.

The overall goal is to enhance the messaging capabilities of the application, providing users with a global chat experience, private crew chats, and direct messaging with other users. This fits into the existing system by extending the current messaging infrastructure and improving user interaction within the `TailboardScreen`.

[Types]
No new complex type definitions are strictly required beyond the existing `Message` model. However, a conceptual `ConversationSummary` might be useful for the direct message conversations list, but for this implementation, we will use existing user IDs as conversation identifiers.

[Files]
File modifications will include:

- `lib/screens/crews/tailboard_screen.dart`: Modify `_TailboardScreenState` to adjust `_tabController` and `TabBarView` for the new `HomeTab`. Refactor `ChatTab`'s `build` method, rename `_buildDirectMessages` to `_buildDirectMessageConversations`, and add `_buildDirectMessageConversation`.
- `lib/features/crews/providers/messaging_riverpod_provider.dart`: Add new Riverpod providers for `directMessageConversationsProvider` and `globalMessagesProvider`.
- `lib/features/crews/services/message_service.dart`: Add new methods `getDirectMessageConversationsStream`, `sendDirectMessage`, `getGlobalMessagesStream`, and `sendGlobalMessage`.
- `lib/screens/crews/home_tab.dart`: Create a new file for the `HomeTab` widget.

[Functions]
Function modifications will include:

- **New Functions:**
  - `MessageService.getDirectMessageConversationsStream(String currentUserId)`: Returns a stream of user IDs representing active direct message conversations.
  - `MessageService.sendDirectMessage(String senderId, String recipientId, String content)`: Sends a direct message.
  - `MessageService.getGlobalMessagesStream(String currentUserId)`: Returns a stream of global chat messages.
  - `MessageService.sendGlobalMessage(String senderId, String content)`: Sends a global chat message.
  - `directMessageConversationsProvider(String currentUserId)`: Riverpod provider for direct message conversations.
  - `globalMessagesProvider()`: Riverpod provider for global chat messages.
  - `_buildDirectMessageConversation(String currentUserId, String otherUserId)` in `_ChatTabState`: Displays a specific direct message conversation.
  - `HomeTab.build(BuildContext context, WidgetRef ref)`: Builds the UI for the new Home tab, including global chat.
- **Modified Functions:**
  - `_ChatTabState.build(BuildContext context)`: Update logic to handle `_selectedDmUserId` for direct messages and integrate the new `HomeTab`.
  - `_ChatTabState._buildDirectMessageConversations(String currentUserId)`: Update to use `directMessageConversationsProvider` to display actual conversations.
  - `_ChatTabState._buildDirectMessageConversation(String currentUserId, String otherUserId)`: Update `ChatInput` to call `MessageService.sendDirectMessage`.
  - `_ChatTabState._buildGlobalChat(String currentUserId)`: Update to use `globalMessagesProvider` and `MessageService.sendGlobalMessage`.
  - `_TailboardScreenState.initState()`: Adjust `_tabController` length.
  - `_TailboardScreenState._buildTabBar()`: Add the new `Home` tab.

[Classes]
Class modifications will include:

- **Modified Classes:**
  - `_ChatTabState` in `lib/screens/crews/tailboard_screen.dart`: Add `_selectedDmUserId` state variable.
  - `MessageService` in `lib/features/crews/services/message_service.dart`: Add new methods for fetching and sending direct and global messages.
- **New Classes:**
  - `HomeTab` in `lib/screens/crews/home_tab.dart`: A new `ConsumerWidget` for the Home tab.

[Dependencies]
Dependency modifications will include:

- No new external packages are expected to be added.
- Existing Riverpod dependencies will be utilized.
- `build_runner` will need to be run after modifying `messaging_riverpod_provider.dart` to regenerate `messaging_riverpod_provider.g.dart`. (Note: This action is outside the scope of this planning phase but is a necessary step for implementation.)

[Testing]
Testing will involve:

- **Unit Tests:**
  - For new `MessageService` methods (`getDirectMessageConversationsStream`, `sendDirectMessage`, `getGlobalMessagesStream`, `sendGlobalMessage`).
  - For new Riverpod providers (`directMessageConversationsProvider`, `globalMessagesProvider`).
- **Widget Tests:**
  - For `ChatTab` to verify correct rendering of conversation lists and individual chats.
  - For `HomeTab` to verify global chat functionality.
- **Integration Tests:**
  - To ensure seamless interaction between `TailboardScreen`, `ChatTab`, `HomeTab`, and the messaging providers/services.

[Implementation Order]
The implementation will proceed in the following logical order:

1. **Update `MessageService`:**
    - Add `getDirectMessageConversationsStream` to `lib/features/crews/services/message_service.dart`.
    - Add `sendDirectMessage` to `lib/features/crews/services/message_service.dart`.
    - Add `getGlobalMessagesStream` to `lib/features/crews/services/message_service.dart`.
    - Add `sendGlobalMessage` to `lib/features/crews/services/message_service.dart`.
2. **Update `messaging_riverpod_provider.dart`:**
    - Create `directMessageConversationsProvider` using `getDirectMessageConversationsStream`.
    - Create `globalMessagesProvider` using `getGlobalMessagesStream`.
    - Run `build_runner` (manual step, outside this task).
3. **Create `home_tab.dart`:**
    - Create the basic `HomeTab` widget in `lib/screens/crews/home_tab.dart`.
4. **Refactor `tailboard_screen.dart` - `_TailboardScreenState`:**
    - Adjust `_tabController` length to 5 (for Home, Feed, Jobs, Chat, Members).
    - Update `TabBarView` to include `HomeTab()`.
    - Modify `_buildTabBar` to add the `Home` tab.
5. **Refactor `tailboard_screen.dart` - `_ChatTabState`:**
    - Update `_buildDirectMessageConversations` to use `directMessageConversationsProvider`.
    - Update `_buildDirectMessageConversation` to integrate `MessageService.sendDirectMessage` via `ChatInput`.
    - Update `_buildGlobalChat` to use `globalMessagesProvider` and `MessageService.sendGlobalMessage`.
    - Adjust `ChatTab`'s toggle labels and logic to reflect the new `Home` tab and its global chat functionality.
