# Implementation Plan

The goal is to resolve all Dart analysis errors, warnings, and undefined references in the codebase to achieve a clean build without workspace problems, focusing on lib/main.dart but addressing project-wide issues from the diagnostics.

This implementation is necessary to ensure the Flutter app compiles and runs correctly, enabling development and testing of the Journeyman Jobs application. The errors include missing imports, undefined classes and methods, type mismatches, and test setup issues. The approach involves categorizing errors by type (syntax, types, imports, dependencies), creating shims or stubs for missing elements, fixing provider definitions, and updating tests to match the code. This will be done systematically to avoid introducing new issues, prioritizing core entry point (main.dart) and then propagating fixes to dependent files.

The project uses Flutter with Firebase, Riverpod for state management, and custom models for Job, User, Crew, etc. Fixes will maintain existing functionality while ensuring type safety and completeness, using stubs where real implementations are missing (e.g., from FlutterFlow shims).

[Types]
No new type system changes are required; fixes involve adding missing methods (e.g., fromJson, toJson) to existing models like UserModel, JobModel, and enums, and ensuring correct type arguments (e.g., List<Job> instead of List<dynamic>).

- Job: Extend with fromJson(Map<String, dynamic> json) method returning Job instance from json fields (id, company, location, classification, jobTitle, hours, wage, perDiem, timestamp, deleted, sharerId, jobDetails).
- UserModel: Add missing fields (username, classification, homeLocal, role, crewIds, email, avatarUrl, onlineStatus, lastActive, fcmToken, displayName, isActive, createdTime, certifications, yearsExperience, preferredDistance, localNumber) with types (String, String, String, String, List<String>, String, String, String, DateTime?, String, String, bool, DateTime?, List<String>, int, int, String). Add toJson, fromJson, fromFirestore, toFirestore, isValid methods.
- Crew: Add fields (filters, jobPreferences with minHourlyRate: double, etc.), lastActivityAt, successRate. Add toJson, fromJson, isValid.
- LocalsRecord: Add toJson, fromJson methods. Fields include map data handling for latitude, longitude.
- Message: Add fromMap, toJson. Fix MessageType enum conflict by using alias.
- Post: Define class with authorId, content, timestamp, reactions.
- Conversation: Define class with id, participantIds, lastMessage.
- MemberRole: Define enum with values (e.g., admin, member).
- OnboardingStatus: Define enum for user onboarding.
- AttachmentType: Already defined, but ensure voiceNote is included.
- TestConstants, TestHelpers: Resolve conflicts by using 'as mocks' in imports.
- AppStateProvider, JobFilterProvider: Define notifier classes with required fields (classifications, locals, lastDocument for AppState; payMin, type, etc. for JobFilter).
- ConnectivityService: Ensure consistent import (use from lib/services/ not features/crews/services).
- AnimationInfo: Define class with trigger enum, effect string, duration. AnimationTrigger enum with values.
- JobsRecord, UsersRecord: Already stubbed in shims, ensure fromJson, toJson.

[Files]
Files to be modified include all listed in diagnostics; new files for missing classes/enums; no deletions.

- New files:
  - lib/providers/riverpod/selected_crew_provider.dart: Define selectedCrewProvider using StateProvider<String?> with getter/setter for current crew ID.
  - lib/providers/riverpod/current_user_provider.dart: Define currentUserProvider as StateNotifierProvider<UserModel?> with auth state sync.
  - lib/domain/exceptions/app_exception.dart, crew_exception.dart, member_exception.dart: Already exist, but ensure AppException class with code field.
  - lib/models/job_model.dart: Add sharerId: String?, jobDetails: Map<String, dynamic>? fields, mark as required in constructors, add fromJson.
  - lib/models/user_model.dart: Add missing fields as above, implement toJson (return {'username': username, ...}), fromJson (UserModel(username: json['username'], ...)), fromFirestore, toFirestore, isValid (check required fields not empty).
  - lib/services/connectivity_service.dart: Add isOnline, wasOffline getters to class.
  - docs/tailboard/tailboard-design.dart -> lib/features/crews/screens/tailboard/tailboard_screen.dart: Move from docs to lib, fix as main file, add missing imports at top, define or import models.
  - test_helpers.dart: Add missing imports and classes like createTestWidget (using MaterialApp with providers), MockUserCredential.
  - .dart_tool/build/entrypoint/build.dart: Ignore, generated.

- Existing files to be modified:
  - lib/main.dart: Add import 'dart:ui'; at top to fix PlatformDispatcher. Wrap FirebaseCrashlytics calls if needed. Add import 'services/error_handling.dart'; if used.
  - lib/data/repositories/job_repository_impl.dart: Fix hidden Job export by removing or defining Job class in job_repository.dart. Change return types to List<Job>, implement getJobs with Firebase query.
  - lib/domain/use_cases/get_jobs_use_case.dart: Use Job type argument if defined.
  - lib/electrical_components/transformer_trainer/modes/guided_mode.dart and quiz_mode.dart: Fix BorderRadius to double? for cornerRadius param (use .x or value).
  - lib/electrical_components/transformer_trainer/widgets/trainer_widget.dart: Same BorderRadius fix.
  - lib/features/crews/providers/crews_riverpod_provider.dart: Define all undefined providers (connectivityServiceProvider, crewServiceProvider, currentUserProvider, userCrewsStreamProvider, crewMembersStreamProvider) using StreamProvider, StateNotifierProvider.
  - lib/features/crews/providers/crew_jobs_riverpod_provider.dart: Define currentUserProvider, jobMatchingServiceProvider, crewByIdProvider.
  - lib/features/crews/providers/global_feed_riverpod_provider.dart: Add fromMap to Message class, resolve MessageType conflict with as prefix.
  - lib/features/crews/screens/home_tab.dart: Define globalMessagesProvider, import providers.
  - lib/providers/riverpod/auth_riverpod_provider.dart: Generate .g.dart by running build_runner, define authServiceProvider, authStateStreamProvider.
  - lib/providers/riverpod/jobs_riverpod_provider.dart: Define firestoreServiceProvider, fix state handling with AsyncValue.
  - lib/providers/riverpod/locals_riverpod_provider.dart: Similar, define firestoreServiceProvider, fix state.
  - lib/screens/jobs/jobs_screen.dart: Define jobsProvider.
  - lib/services/noaa_weather_service.dart, weather_radar_service.dart: Import 'dart:math' for sin, cos, sqrt, atan2, pi.
  - lib/utils/compressed_state_manager.dart: Add toJson, fromJson to UserModel (use jsonEncode/jsonDecode if needed, add import 'dart:convert';).
  - lib/utils/error_handling.dart: Define FirebaseCrashlytics, debugPrint (use print), or stub if not used.
  - lib/widgets/offline_indicator.dart, offline_indicators.dart: Define connectivityServiceProvider, fix Consumer generic, use ref.watch for isOnline.
  - lib/widgets/optimized_job_card.dart: Remove unused _DetailChip if not referenced.
  - lib/widgets/virtual_job_list.dart: Define jobsProvider, connectivityServiceProvider.
  - lib/widgets/weather/interactive_radar_map.dart: Define CancellableNetworkTileProvider (use NetworkImageProvider), fix backgroundColor param in whatever widget it's used.
  - test/* files: Fix missing params in constructors (e.g., add isActive:true in mocks), resolve import conflicts with as, stub missing methods in mocks, use proper types.
  - lib/features/crews/screens/tailboard_screen.dart: Move imports to top, fix BorderRadius, define AnimationTrigger, FlutterFlowTheme with colors.
  - lib/main.dart: Add import 'dart:ui';

- Configuration updates: pubspec.yaml - Ensure all deps versions match, add missing like font_awesome_flutter if used, but seems complete.

[Functions]
New functions: Add toJson, fromJson, fromFirestore, toFirestore, isValid to models (UserModel, JobModel, Crew); add getters like displayName, isActive to UserModel; add providers in riverpod files; stub missing like storeCrewsOffline in mocks.

- New functions (e.g., in lib/models/user_model.dart):
  - UserModel toJson(): Map<String, dynamic> - Returns {'username': username, 'classification': classification, ...}.
  - UserModel fromJson(Map<String, dynamic> json): UserModel - Instantiates with json['username'], etc.
  - UserModel fromFirestore(DocumentSnapshot snapshot): UserModel - Call fromJson(snapshot.data()).
  - UserModel toFirestore(): Map<String, dynamic> - Return map for Firestore.
  - UserModel isValid(): bool - Check required fields not empty/null.
  - Similar for JobModel, Crew, Message (fromMap), LocalsRecord.
  - In providers, define providers like final authServiceProvider = Provider<AuthService>((ref) => AuthService());

- Modified functions (e.g., in riverpod providers):
  - jobsProvider.build: Add ref.watch(firestoreServiceProvider), handle AsyncValue.
  - authProvider.build: Fix state assignments with if (state is AuthState...).
  - queryJobsRecord, queryUsersRecord: Implement actual Firestore queries using FirebaseFirestore.instance.collection('jobs').get(), convert snapshot to List<Job>.
  - In test files, update constructor calls to include missing params (e.g., UserModel(..., isActive: true)).

- Removed functions: None, but remove unused like dead code warnings.

[Classes]
New classes: Stub missing like Post, Conversation, MemberRole enum, OnboardingStatus enum in lib/models/ or lib/domain/enums/.

- New classes:
  - lib/models/post_model.dart: class Post { String authorId; String content; DateTime timestamp; Map reactions; Post.fromJson, toJson. }
  - lib/models/conversation_model.dart: class Conversation { String id; List<String> participantIds; Message? lastMessage; fromJson, toJson. }
  - lib/domain/enums/member_role.dart: enum MemberRole { admin, member; }
  - lib/domain/enums/onboarding_status.dart: enum OnboardingStatus { incomplete, complete; }
  - lib/domain/enums/message_type.dart: enum MessageType { text, image, voiceNote; }
  - lib/providers/app_state_provider.dart: class AppStateNotifier extends StateNotifier<AppState> { fields: List<String> classifications; List locals; DocumentSnapshot? lastDocument; methods to update. }
  - Similar for JobFilterNotifier.
  - Mock classes in tests: Update mocks to include missing methods (e.g., MockJobRepository getJobs returns Future<List<Job>>.value([])).

- Modified classes:
  - UserModel: Add constructor params for all fields, getters for displayName, isActive, etc.
  - JobModel: Add sharerId, jobDetails, require in constructor.
  - CacheService: Add missing methods like clearMemoryCache, setMemoryCache, getMemoryCache, etc.
  - ConnectivityService: Add isOnline, wasOffline.
  - TailboardModel: Extend ChangeNotifier, add dispose override.
  - In tailboard-design.dart: Define TailboardWidgetState as StatefulWidget, fix mounted to if (mounted).

- Removed classes: None.

[Dependencies]
No new packages needed; all listed in pubspec.yaml (Firebase, Riverpod, etc.). 

- Version changes: Ensure riverpod_annotation ^3.0.0-dev.17 matches riverpod_generator for build_runner to generate .g.dart files.
- Integration: Run flutter pub get after changes; build_runner generate if needed for providers.

[Testing]
Testing approach involves updating existing test files to use correct constructors and mocks, adding missing params, and running flutter test to verify fixes, plus manual verification for main.dart by running the app.

- Test file requirements: Update mocks in test/data/services/*_test_mocks.dart to implement missing methods (e.g., MockCacheService: add clearMemoryCache() => Future.value();).
- Existing test modifications: Fix const variables with const expressions; resolve import conflicts; update assertions to match fixed code (e.g., expect(user.displayName, 'test')).
- Validation: After fixes, run flutter analyze and expect 0 issues; run flutter test for passing tests.

[Implementation Order]
The implementation sequence prioritizes syntax fixes first to allow compilation, then type/method fixes, then test updates to verify.

1. Add missing imports to all files (dart:ui for PlatformDispatcher; dart:math for math funcs; json for serialization).
2. Fix syntax errors (move imports to top in tailboard-design.dart, remove incomplete lines, fix unterminated strings).
3. Define missing enums and classes (MemberRole, OnboardingStatus, Post, Conversation in lib/domain/enums/ and lib/models/).
4. Implement missing methods in models (toJson, fromJson, etc. for UserModel, JobModel; getters like displayName).
5. Update providers (define all undefined like jobsProvider, authServiceProvider as Provider<>() => ...).
6. Fix type errors in Riverpod files (AsyncValue<Job>, ref.watch).
7. Update widget files (BorderRadius to double.x; Consumer<WidgetRef>).
8. Fix test files (add missing params, resolve conflicts with as mocks, stub methods).
9. For main.dart specifically: Add import 'dart:ui';, test run flutter run.
10. Verify overall: Run flutter analyze, ensure no errors.
