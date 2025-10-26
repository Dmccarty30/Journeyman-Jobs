import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/widgets/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_data_model.dart';
import 'package:journeyman_jobs/providers/riverpod/hierarchical_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';

// Generate mocks
@GenerateMocks([
  HierarchicalDataNotifier,
])
import 'hierarchical_initializer_test.mocks.dart';

void main() {
  group('HierarchicalInitializer Widget', () {
    late MockHierarchicalDataNotifier mockHierarchicalNotifier;

    setUp(() {
      mockHierarchicalNotifier = MockHierarchicalDataNotifier();
    });

    group('Loading States', () {
      testWidgets('should show loading widget when hierarchical data is loading', (tester) async {
        // Setup mock to return loading state
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        )));

        // Create provider override
        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)), // No authenticated user
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        // Verify loading UI is shown
        expect(find.text('Initializing IBEW Network...'), findsOneWidget);
        expect(find.text('Loading Union • Local • Member • Job data'), findsOneWidget);
        expect(find.byIcon(Icons.wifi), findsOneWidget);
        expect(find.byIcon(Icons.account_balance), findsOneWidget);
      });

      testWidgets('should show custom loading widget when provided', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        )));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
                loadingWidget: const Text('Custom Loading...'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Loading...'), findsOneWidget);
        expect(find.text('Initializing IBEW Network...'), findsNothing);
      });
    });

    group('Error States', () {
      testWidgets('should show error widget when hierarchical data has error', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: false,
          error: 'Connection failed',
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: false,
          error: 'Connection failed',
          lastUpdated: DateTime.now(),
        )));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        // Verify error UI is shown
        expect(find.text('Connection Error'), findsOneWidget);
        expect(find.text('Unable to load IBEW network data'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Continue Offline'), findsOneWidget);
      });

      testWidgets('should show custom error widget when provided', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: false,
          error: 'Connection failed',
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: false,
          error: 'Connection failed',
          lastUpdated: DateTime.now(),
        )));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
                errorWidget: const Text('Custom Error'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Error'), findsOneWidget);
        expect(find.text('Connection Error'), findsNothing);
      });

      testWidgets('should show debug error details in debug mode', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: false,
          error: 'Detailed error message with stack trace',
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: false,
          error: 'Detailed error message with stack trace',
          lastUpdated: DateTime.now(),
        )));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        // Should show technical error details in debug mode
        expect(find.text('Detailed error message with stack trace'), findsOneWidget);
      });
    });

    group('Authentication States', () {
      testWidgets('should show authentication error when auth state has error', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => AsyncValue.error('Auth failed', StackTrace.current)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        // Verify authentication error UI is shown
        expect(find.text('Authentication Error'), findsOneWidget);
        expect(find.text('There was an issue with authentication'), findsOneWidget);
        expect(find.byIcon(Icons.security), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
      });

      testWidgets('should show loading when auth state is loading', (tester) async {
        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.loading()),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        // Should show hierarchical loading while auth is loading
        expect(find.text('Initializing IBEW Network...'), findsOneWidget);
      });
    });

    group('Success States', () {
      testWidgets('should show child widget when data is loaded successfully', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData(
            loadingStatus: HierarchicalLoadingStatus.loaded,
            lastUpdated: DateTime.now(),
          ),
          isLoading: false,
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData(
            loadingStatus: HierarchicalLoadingStatus.loaded,
            lastUpdated: DateTime.now(),
          ),
          isLoading: false,
          lastUpdated: DateTime.now(),
        )));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        // Should show the child content
        expect(find.text('Content'), findsOneWidget);
        expect(find.text('Initializing IBEW Network...'), findsNothing);
      });
    });

    group('Progress Indicators', () {
      testWidgets('should show correct progress steps for each initialization phase', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        ));

        // Mock initialization state stream to show different phases
        final states = [
          HierarchicalInitializationState.initializing(),
          HierarchicalInitializationState.loadingMinimal(),
          HierarchicalInitializationState.loadingHomeLocal(),
          HierarchicalInitializationState.loadingPreferredLocals(),
          HierarchicalInitializationState.loadingComprehensive(),
          HierarchicalInitializationState.completed(),
        ];

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.fromIterable(states));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            hierarchicalInitializationStateProvider.override((ref) => Stream.fromIterable(states)),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify progress steps are shown
        expect(find.text('Connecting'), findsOneWidget);
        expect(find.text('Loading Union'), findsOneWidget);
        expect(find.text('Loading Locals'), findsOneWidget);
        expect(find.text('Loading Members'), findsOneWidget);
        expect(find.text('Loading Jobs'), findsOneWidget);

        // Verify icons are shown
        expect(find.byIcon(Icons.wifi), findsOneWidget);
        expect(find.byIcon(Icons.account_balance), findsOneWidget);
        expect(find.byIcon(Icons.location_city), findsOneWidget);
        expect(find.byIcon(Icons.people), findsOneWidget);
        expect(find.byIcon(Icons.work), findsOneWidget);
      });

      testWidgets('should hide progress indicators when showProgressIndicator is false', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        )));

        final container = ProviderContainer(
          overrides: [
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            authStateProvider.override((ref) => const AsyncValue.data(null)),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: HierarchicalInitializer(
                child: const Text('Content'),
                showProgressIndicator: false,
              ),
            ),
          ),
        );

        // Should show loading message but no progress indicators
        expect(find.text('Initializing IBEW Network...'), findsOneWidget);
        expect(find.byIcon(Icons.wifi), findsNothing);
        expect(find.byIcon(Icons.account_balance), findsNothing);
      });
    });

    group('HierarchicalStatsWidget', () {
      testWidgets('should display hierarchical statistics correctly', (tester) async {
        final stats = HierarchicalStats(
          totalLocals: 10,
          totalMembers: 500,
          totalJobs: 25,
          availableJobs: 15,
          availableMembers: 100,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        final container = ProviderContainer(
          overrides: [
            hierarchicalStatsProvider.override((ref) => stats),
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: HierarchicalStatsWidget(),
              ),
            ),
          ),
        );

        // Verify statistics are displayed
        expect(find.text('IBEW Network Statistics'), findsOneWidget);
        expect(find.text('10'), findsOneWidget); // Total locals
        expect(find.text('500'), findsOneWidget); // Total members
        expect(find.text('25'), findsOneWidget); // Total jobs
        expect(find.text('15/100'), findsOneWidget); // Available jobs/members
        expect(find.text('5m ago'), findsOneWidget); // Last updated time

        // Verify icons are shown
        expect(find.byIcon(Icons.analytics), findsOneWidget);
        expect(find.byIcon(Icons.location_city), findsOneWidget);
        expect(find.byIcon(Icons.people), findsOneWidget);
        expect(find.byIcon(Icons.work), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('should show refreshing indicator when data is loading', (tester) async {
        when(mockHierarchicalNotifier.state).thenReturn(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        ));

        when(mockHierarchicalNotifier.stream).thenAnswer((_) => Stream.value(HierarchicalDataState(
          data: HierarchicalData.empty(),
          isLoading: true,
          lastUpdated: DateTime.now(),
        )));

        final stats = HierarchicalStats(
          totalLocals: 10,
          totalMembers: 500,
          totalJobs: 25,
          availableJobs: 15,
          availableMembers: 100,
          lastUpdated: DateTime.now(),
        );

        final container = ProviderContainer(
          overrides: [
            hierarchicalStatsProvider.override((ref) => stats),
            hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: HierarchicalStatsWidget(),
              ),
            ),
          ),
        );

        // Should show refreshing indicator
        expect(find.byType<CircularProgressIndicator>(), findsOneWidget);
      });

      testWidgets('should format time correctly', (tester) async {
        final now = DateTime.now();
        final testCases = [
          now.subtract(const Duration(seconds: 30)), // 'Just now'
          now.subtract(const Duration(minutes: 5)), // '5m ago'
          now.subtract(const Duration(hours: 2)), // '2h ago'
          now.subtract(const Duration(days: 1)), // '1d ago'
        ];

        for (final testTime in testCases) {
          final stats = HierarchicalStats(
            totalLocals: 10,
            totalMembers: 500,
            totalJobs: 25,
            availableJobs: 15,
            availableMembers: 100,
            lastUpdated: testTime,
          );

          final container = ProviderContainer(
            overrides: [
              hierarchicalStatsProvider.override((ref) => stats),
              hierarchicalDataProvider.override((ref) => mockHierarchicalNotifier),
            ],
          );

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                home: Scaffold(
                  body: HierarchicalStatsWidget(),
                ),
              ),
            ),
          );

          // Verify time formatting
          expect(find.byType(HierarchicalStatsWidget), findsOneWidget);
        }
      });
    });
  });
}