# Implementation Tasks for Integrating FlutterFlow UI into tailboard_screen.dart

Below is a comprehensive, step-by-step set of implementation tasks to integrate the UI you built in FlutterFlow (as shown in the provided tailboard-design.dart code and screenshots) into the existing tailboard_screen.dart file. The goal is to preserve the existing Riverpod state management, routing (via GoRouter), and modular widget structure while incorporating the FlutterFlow-generated UI elements, layouts, and conditional rendering (e.g., no-crew vs. with-crew states). This assumes you're working in a Flutter project with dependencies like flutter_riverpod, go_router, firebase_core, cloud_firestore, firebase_auth, and possibly firebase_storage for media handling.

These tasks are ordered logically: starting with preparation, then structural updates, tab-specific integrations, conditional logic, and finally testing/polish. Each task includes specific actions, rationale, and potential code snippets for clarity.

1. **Preparation and Dependency Setup**
   - Review and compare the two files: Identify key differences. tailboard-design.dart uses FlutterFlow's widget structure (e.g., FFButtonWidget, custom animations, StreamBuilders for jobs/users), while tailboard_screen.dart uses Riverpod providers (e.g., selectedCrewProvider) and custom widgets (e.g., JobMatchCard, ActivityCard).
   - Add required dependencies if missing: Ensure your pubspec.yaml includes flutter_animate, font_awesome_flutter, provider, simple_gradient_text, and any other packages from tailboard-design.dart (e.g., auto_size_text, google_fonts).
   - Import necessary modules: In tailboard_screen.dart, add imports from tailboard-design.dart such as '/flutter_flow/flutter_flow_theme.dart', '/flutter_flow/flutter_flow_util.dart', and model-specific imports (e.g., TailboardModel).
   - Set up a TailboardModel: Copy the TailboardModel class from tailboard-design.dart into a new file (e.g., tailboard_model.dart) and integrate it into_TailboardScreenState for managing local state (e.g., text controllers, animations).

2. **Update Scaffold and Overall Structure**
   - Replace the existing Scaffold body in tailboard_screen.dart with a Column that mirrors the FlutterFlow layout: Include conditional header (no-crew vs. with-crew), TabBar, TabBarView, and FloatingActionButton.
   - Integrate animations: Use the animationsMap from tailboard-design.dart for page load effects (e.g., FadeEffect, MoveEffect on containers). Add with TickerProviderStateMixin if not already present.
   - Handle gesture dismissal: Copy the GestureDetector from tailboard-design.dart to unfocus inputs on tap.
   - Update AppBar: If needed, add an AppBar from tailboard-design.dart (with title 'Page Title' customized to 'Tailboard') and ensure it integrates with the existing backgroundColor from AppTheme.

3. **Implement Conditional Header Logic**
   - Enhance _buildNoCrewHeader: Port the welcome text, subtitle ('This is where you can, fuck off!' – replace with appropriate text if placeholder), and '+ Create or Join a Crew' button from tailboard-design.dart. Use FFButtonWidget for the button, wiring onPressed to context.go(AppRouter.crewOnboarding).
   - Enhance _buildHeader (for selectedCrew != null): Integrate the crew info row (avatar, name, member count), quick actions (more_vert icon), and stats row from tailboard_screen.dart, but style them to match FlutterFlow (e.g., use Container with boxShadow, border from tailboard-design.dart's post containers).
   - Add SafeArea wrapping: Wrap the entire body Column in SafeArea as in tailboard-design.dart to handle device notches.

4. **Integrate TabBar and TabBarView**
   - Update _buildTabBar: Copy the TabBar from tailboard-design.dart, including icons (Icons.feed, Icons.forest for Jobs, etc.), controller setup, and onTap listener. Adjust labelStyle to use AppTheme instead of FlutterFlowTheme.
   - Set up TabBarView children: Replace existing placeholders with structured Columns from tailboard-design.dart:
     - Feed Tab: Use ListView.builder for posts, porting the Container with Row for user avatar, username, time, content, and reactions (likes, comments, shares).
     - Jobs Tab: Integrate StreamBuilder<List<JobsRecord>> to query jobs, displaying them in cards with fields like Local, Classification, Posted ago, Location, Hours, Per Diem, and buttons (View Details, Bid Now).
     - Chat Tab: Port the chat UI with message bubbles (right-aligned for sent, left for received), input row (TextField, IconButtons for media/send), and sample messages.
     - Members Tab: Use StreamBuilder<List<UsersRecord>> for ListView.builder, porting user rows with avatar, name, email, and chevron icon.
   - Handle tab changes: Keep _handleTabSelection from tailboard_screen.dart and integrate _model.tabBarController from FlutterFlow.

5. **Port Custom Widgets and Components**
   - Create reusable widgets: Extract elements like social posts (from tailboard-design.dart's Builder/ListView.builder) into a new widget (e.g., SocialPostCard) and use in FeedTab.
   - Integrate dividers and rows: Copy structures like TimeLocationRow, PostedRow, LocalClassRow for Jobs/Members tabs.
   - Add input fields: For Chat, port the AutocompleteOptionsList/TextField setup, ensuring it works with Riverpod for state.
   - Handle placeholders: Replace random_data/randomString with actual data from providers (e.g., ref.watch(feedPostsProvider)).

6. **Integrate FloatingActionButton Logic**
   - Keep _buildFloatingActionButton from tailboard_screen.dart but style the button to match FlutterFlow (e.g., borderRadius: 8, elevation: 0).
   - Wire actions: For Feed (+ post), Jobs (share job), Chat (new message), using dialogs from tailboard_screen.dart (_showCreatePostDialog, etc.).

7. **Add Animations and Interactions**
   - Setup animations: Copy setupAnimations and animationsMap, applying to containers (e.g., .animateOnPageLoad for member cards).
   - Add interactions: Port onPressed handlers for buttons, ensuring they trigger Riverpod notifiers (e.g., ref.read(crewNotifierProvider.notifier).createPost()).

8. **Testing and Polish**
   - Test conditional rendering: Use mock providers to simulate selectedCrew == null and != null.
   - Responsive design: Ensure widths/heights from FlutterFlow (e.g., width: 405.6) adapt to device sizes using MediaQuery.
   - Debug animations: Verify Fade/Move effects work without conflicts.
   - Lint and refactor: Remove unused code from tailboard-design.dart, align naming (e.g., replace FlutterFlowTheme with AppTheme).
   - Run integration tests: Write tests for tab switching, button clicks, and conditional UI.

Backend Logic Definition

For the Tailboard screen to function as a complex, conditional hub (e.g., no-crew shows limited features like direct messaging; with-crew enables full feed/jobs/chat/members), we need robust backend logic using Firebase (Firestore for data, Firebase Auth for users, Firebase Storage for media, Firebase Cloud Messaging for notifications). Below is a thorough, specific definition, including database schema, queries, real-time listeners, authentication/authorization, error handling, and integration with Riverpod providers. This builds on the spec I provided earlier but refines it for this screen's conditionals.

1. **Database Schema (Firestore)**
   - **users Collection**: Documents for user profiles.
     - Fields: uid (doc ID), username (string), classification (string, e.g., 'Lineman'), homeLocal (string, e.g., 'Local 123'), role (string: 'foreman' or 'crew_member'), crewIds (array of strings), email (string), avatarUrl (string), onlineStatus (boolean), lastActive (timestamp).
     - Indexes: Composite on crewIds + uid for fast member queries.
   - **crews Collection**: Documents for crews.
     - Fields: crewId (doc ID), foremanId (string ref to users), memberIds (array of user uids), name (string), stats (map: {totalJobsShared: int, totalApplications: int, averageMatchScore: double}), jobPreferences (map: {hours: int, payRate: double, perDiem: double, location: GeoPoint, contractor: string}), createdAt (timestamp).
     - Indexes: On foremanId and memberIds for access checks.
   - **feedPosts Subcollection** (under crews/crewId/feedPosts): For crew-specific posts.
     - Fields: postId (doc ID), authorId (user ref), content (string), mediaUrls (array of strings from Storage), timestamp (timestamp), likes (array of user uids).
     - Indexes: On timestamp desc for sorting.
   - **jobs Subcollection** (under crews/crewId/jobs): Shared/filtered jobs.
     - Fields: jobId (doc ID), postedBy (user ref), jobDetails (map: {local: string, classification: string, location: GeoPoint, hours: int, perDiem: double}), matchesCriteria (bool, computed via algorithm), timestamp (timestamp).
     - Indexes: On timestamp desc, matchesCriteria.
   - **conversations Subcollection** (under crews/crewId/conversations): For chats (one doc per conversation, e.g., crew-wide or direct).
     - Fields: conversationId (doc ID), type (string: 'crew' or 'direct'), participantIds (array of uids), lastMessage (string), lastMessageTime (timestamp).
     - Sub-subcollection: messages (fields: messageId (doc ID), senderId (user ref), content (string), mediaUrls (array), timestamp (timestamp), readBy (array of uids)).
     - Indexes: On lastMessageTime desc for recent chats.
   - **Security Rules**: Enforce RBAC.

     ```dart
     match /crews/{crewId} {
       allow read: if request.auth.uid in resource.data.memberIds;
       allow write: if request.auth.uid == resource.data.foremanId; // For updates like jobPreferences
     }
     match /crews/{crewId}/feedPosts/{postId} {
       allow read, write: if request.auth.uid in get(/databases/$(database)/documents/crews/$(crewId)).data.memberIds;
     }
     // Similar for jobs, conversations. For direct messages (no crewId), check participantIds.
     ```

2. **Authentication and Authorization Logic**
   - Use FirebaseAuth: On screen init, check auth.currentUser. If null, redirect to login.
   - RBAC Checks: In providers, query users collection for role/crewIds. E.g., if role != 'foreman', disable jobPreferences editing UI/buttons.
   - Conditional Access: If selectedCrew == null (from provider), disable Feed/Jobs/Members writes; allow read-only or global direct messaging via a separate conversations collection without crewId.

3. **Real-Time Data Fetching and Updates**
   - Use StreamProviders for all tabs:
     - Feed: Stream query feedPosts where crewId == selectedCrew.id, orderBy timestamp desc. Use PaginationController for infinite scroll (limit 20, load more on scroll).
     - Jobs: Stream query jobs where crewId == selectedCrew.id and matchesCriteria == true, orderBy timestamp desc. Implement match algorithm: On job post, compare jobDetails to crew.jobPreferences (e.g., if job.hours >= preferences.hours && distance(job.location, preferences.location) < 100km, set matchesCriteria=true).
     - Chat: Stream messages subcollection orderBy timestamp asc. Use StreamController for typing indicators (update a 'typing' field in conversation doc). Auto-scroll with ScrollController.animateTo(maxScrollExtent).
     - Members: Stream query users where uid in selectedCrew.memberIds, with onlineStatus/lastActive.
   - Offline Support: Enable Firestore persistence (firebase.firestore().enablePersistence() in main.dart).

4. **CRUD Operations (via DatabaseService)**
   - Create Post (Feed): Upload media to Storage, get URLs, add to feedPosts. Notify members via FCM.
   - Read Jobs: Filter/sort client-side if needed (e.g., proximity: use Geolocator.distanceBetween).
   - Update Message Status: On message view, arrayUnion readBy with current uid.
   - Delete Member: Foreman-only: Remove from memberIds, update stats.
   - Error Handling: Wrap operations in try-catch, show SnackBar (e.g., 'Network error: Offline mode enabled'). Validate inputs (e.g., content.length > 0).

5. **Notification and Push Logic**
   - Integrate FCM: On new post/job/message, send to member devices (tokens stored in users). Use notification_service.dart to handle.

6. **Provider Integration**
   - selectedCrewProvider: Family<AsyncValue<Crew?>> based on user.crewIds.
   - feedProvider: StreamProvider<List<Post>> querying feedPosts.
   - Use StateNotifier for actions (e.g., ChatNotifier with sendMessage method).

7. **Edge Cases and Validation**
   - Empty States: Show custom UI (icons/text from tailboard_screen.dart) if no data.
   - Loading: Use skeletons (e.g., shimmer package).
   - Connectivity: Listen to Connectivity.onConnectivityChanged, cache data with hive or shared_preferences.
   - Validation: Use form keys for inputs; regex for emails/locations.

This covers the backend thoroughly. Once implemented, we can proceed to next tasks like code generation or testing.
