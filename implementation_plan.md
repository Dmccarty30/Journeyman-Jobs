# Implementation Plan

## [Overview]
This implementation plan addresses the compilation errors in the Flutter app caused by missing providers and methods in the crews feature, specifically implementing crewMembersStreamProvider, getJoinableCrews, joinCrew, crewsServiceProvider reference, and connectivityServiceProvider to enable successful builds and crew joining functionality.

The app is a Flutter mobile application for electrical journeyman jobs using Riverpod for state management and Firebase for backend services. The errors indicate incomplete implementation of crew-related features, including streams for members, service methods for joining crews, and provider dependencies. This plan integrates these fixes seamlessly into the existing architecture, ensuring offline support via OfflineDataService, permission checks via RolePermissions, and validation using existing utils like CrewValidation. The changes focus on the crews module without altering unrelated components like authentication or job matching, while maintaining consistency with the pubspec.yaml dependencies (e.g., cloud_firestore, riverpod_annotation). The goal is to resolve all build failures, enable the join crew screen, and support real-time member streams in the tailboard screen, ultimately allowing users to join and interact with crews without crashes.

## [Types]  
No new type system changes are required; leverage existing models like Crew, CrewMember, and enums such as MemberRole and InvitationStatus for consistency.

Existing types will be extended implicitly through service methods: CrewMember streams will use the existing CrewMember.fromFirestore for deserialization, and join operations will update Crew.memberIds and roles maps without new data structures. Validation rules remain as per CrewValidation (e.g., max 10 members for joinCrew, unique names). Relationships: Crew has a roles Map<String, MemberRole> and memberIds List<String>; new methods will append to these atomically using Firestore transactions to prevent race conditions.

## [Files]
Several files require modifications to implement missing providers and methods, with one new provider file for connectivity.

- New files to be created: lib/features/crews/providers/connectivity_service_provider.dart (defines connectivityServiceProvider using connectivity_plus package from pubspec.yaml; purpose: provide stream of connectivity status for offline handling).
- Existing files to be modified:
  - lib/features/crews/services/crews_service.dart: Add getJoinableCrews() returning Stream<List<Crew>> of public crews (where isPublic: true or member limit <10); implement joinCrew({required String crewId, required String userId}) with validation (check limits, permissions, offline sync via OfflineDataService), Firestore updates (add to memberIds, create CrewMember doc, send acceptance notification), and error handling (CrewException for full crews or duplicates). Update leaveCrew for completeness.
  - lib/features/crews/screens/tailboard_screen.dart: In _ChatTabState and MembersTab, replace undefined crewMembersStreamProvider(crewId) with ref.watch(crewMembersStreamProvider(crewId)) after defining the provider; ensure import for new provider.
  - lib/providers/riverpod/auth_riverpod_provider.dart: In AuthNotifier.cleanupUserData, replace ref.read(crewsServiceProvider) with ref.read(crewsServiceProvider) after ensuring provider import; add import for crews_riverpod_provider.dart.
  - lib/providers/riverpod/offline_data_service_provider.dart: Fix undefined connectivityServiceProvider by importing and watching the new connectivity_service_provider.dart; update provider to pass ConnectivityService instance.
  - lib/features/crews/providers/crews_riverpod_provider.dart: Add @riverpod Stream<List<CrewMember>> crewMembersStream(String crewId, Ref ref) { return ref.watch(crewsServiceProvider).getCrewMembersStream(crewId).map((snapshot) => snapshot.docs.map((doc) => CrewMember.fromFirestore(doc)).toList()); }; Add crewMembersStreamProvider family.
- No files to be deleted or moved.
- Configuration file updates: None required; pubspec.yaml already includes connectivity_plus.

## [Functions]
Implement missing service methods and providers to resolve undefined references.

- New functions:
  - In lib/features/crews/services/crews_service.dart: Stream<List<Crew>> getJoinableCrews() - Queries Firestore for active crews with <10 members and isPublic: true, ordered by createdAt descending; handles offline by returning cached joinable crews.
  - In lib/features/crews/services/crews_service.dart: Future<void> joinCrew({required String crewId, required String userId}) - Validates crew existence/membership/capacity, creates CrewMember doc, updates crew memberIds/roles via transaction, syncs offline, throws CrewException on failures.
  - In lib/features/crews/providers/crews_riverpod_provider.dart: Stream<List<CrewMember>> crewMembersStream(String crewId, Ref ref) - Returns transformed stream from CrewsService.getCrewMembersStream(crewId).
  - In lib/features/crews/providers/connectivity_service_provider.dart: Stream<ConnectivityResult> connectivityStream(Ref ref) - Uses Connectivity().onConnectivityChanged; and ConnectivityService connectivityService(Ref ref) - Wraps connectivity_plus for status checks.
- Modified functions: None; additions are new without altering existing signatures.
- Removed functions: None.

## [Classes]
No class modifications required; extensions are via providers and service methods on existing classes like CrewsService (add methods) and AuthNotifier (fix provider reference).

- New classes: None.
- Modified classes:
  - CrewsService in lib/features/crews/services/crews_service.dart: Add getJoinableCrews and joinCrew methods with offline/transaction logic.
  - No inheritance changes; all extend existing patterns.
- Removed classes: None.

## [Dependencies]
No new packages required; utilize existing pubspec.yaml entries like cloud_firestore (^6.0.0), connectivity_plus (^7.0.0), and riverpod_annotation (^3.0.0-dev.17).

Version changes: None. Integration: Ensure riverpod_generator run after provider additions (dev_dependencies includes it); no external API changes.

## [Testing]
Comprehensive unit and integration tests will validate the new functionality using existing mockito and fake_cloud_firestore.

- New test files: test/features/crews/services/crews_service_test.dart - Unit tests for getJoinableCrews (mock Firestore snapshots with 5-15 mock crews, assert filtering), joinCrew (scenarios: empty crew success, full crew throws CrewException, duplicate membership throws MemberException, offline sync calls OfflineDataService.storeCrewMembersOffline), crewMembersStream (mock stream emits 3 members, assert CrewMember.fromFirestore called).
- Existing test modifications: test/features/crews/screens/join_crew_screen_test.dart - Add widget test for successful join (mock crewsServiceProvider returns Stream with 2 crews, tap join button, assert navigation to /crews and success snackbar); failure case (full crew, assert error snackbar).
- Validation strategies: Mock Firestore transactions for atomicity; integration_test for end-to-end join flow (use fake_cloud_firestore to simulate db state); coverage >80% for new code via flutter test --coverage.

## [Implementation Order]
Implement in a logical sequence starting from providers, then services, screens, and finally tests to ensure incremental builds succeed.

1. Create lib/features/crews/providers/connectivity_service_provider.dart with connectivityServiceProvider and generate with riverpod_generator.
2. Update lib/providers/riverpod/offline_data_service_provider.dart to watch the new connectivityServiceProvider.
3. Add getJoinableCrews and joinCrew methods to lib/features/crews/services/crews_service.dart with offline handling.
4. Add crewMembersStreamProvider family to lib/features/crews/providers/crews_riverpod_provider.dart and regenerate.
5. Fix lib/providers/riverpod/auth_riverpod_provider.dart to import and read crewsServiceProvider correctly.
6. Update lib/features/crews/screens/tailboard_screen.dart to use the new crewMembersStreamProvider in _ChatTabState and MembersTab.
7. Update lib/features/crews/screens/join_crew_screen.dart to call the new getJoinableCrews and joinCrew methods.
8. Run flutter pub get and riverpod_generator to regenerate providers.
9. Add unit tests to test/features/crews/services/crews_service_test.dart for new methods.
10. Add widget tests to test/features/crews/screens/join_crew_screen_test.dart for join flow.
11. Run flutter test and integration_test to verify fixes; address any linter issues from analysis_options.yaml.
