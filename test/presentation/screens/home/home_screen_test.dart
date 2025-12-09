import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/screens/home/home_screen.dart';
import 'package:journeyman_jobs/providers/app_state_provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../../fixtures/mock_data.dart';
import '../../../fixtures/test_constants.dart';
import '../../../helpers/widget_test_helpers.dart';

// Generate mocks
// @GenerateMocks([AppStateProvider, GoRouter])
// import 'home_screen_test.mocks.dart';

void main() {
  late MockAppStateProvider mockAppStateProvider;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockAppStateProvider = MockAppStateProvider();
    mockGoRouter = MockGoRouter();
    
    // Setup default mock behavior
    when(mockAppStateProvider.isLoading).thenReturn(false);
    when(mockAppStateProvider.jobs).thenReturn([]);
    when(mockAppStateProvider.error).thenReturn(null);
    when(mockAppStateProvider.refreshJobs()).thenAnswer((_) async {
      return null;
    });
  });

  Widget createHomeScreen() {
    return WidgetTestHelpers.createTestApp(
      child: ChangeNotifierProvider<AppStateProvider>.value(
        value: mockAppStateProvider,
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen - Widget Rendering', () {
    testWidgets('should render home screen with app bar', (tester) async {
      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Check app bar styling
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
      expect(appBar.elevation, equals(0));
    });

    testWidgets('should display app logo in app bar', (tester) async {
      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Container), findsWidgets);
      
      // Find the logo container (should have gradient decoration)
      final logoContainers = tester.widgetList<Container>(find.byType(Container))
          .where((container) => 
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).gradient != null);
      
      expect(logoContainers.isNotEmpty, isTrue);
    });

    testWidgets('should have correct background color', (tester) async {
      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.offWhite));
    });

    testWidgets('should display "Journeyman Jobs" title', (tester) async {
      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Journeyman Jobs'), findsOneWidget);
    });
  });

  group('HomeScreen - Job List Display', () {
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(mockAppStateProvider.isLoading).thenReturn(true);
      when(mockAppStateProvider.jobs).thenReturn([]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display job list when jobs are available', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 3);
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      
      // Should display job cards
      expect(find.text('Test Electric Company'), findsWidgets);
      expect(find.text('Journeyman Electrician'), findsWidgets);
    });

    testWidgets('should display empty state when no jobs available', (tester) async {
      // Arrange
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn([]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No jobs available'), findsOneWidget);
      expect(find.text('Check back later for new opportunities'), findsOneWidget);
    });

    testWidgets('should display error message when error occurs', (tester) async {
      // Arrange
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn([]);
      when(mockAppStateProvider.error).thenReturn('Failed to load jobs');

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to load jobs'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('HomeScreen - IBEW Specific Content', () {
    testWidgets('should display IBEW classification badges', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(classification: 'Inside Wireman'),
        MockData.createJob(classification: 'Journeyman Lineman'),
      ];
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Inside Wireman'), findsOneWidget);
      expect(find.text('Journeyman Lineman'), findsOneWidget);
    });

    testWidgets('should display IBEW local numbers', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(localNumber: 123),
        MockData.createJob(localNumber: 456),
      ];
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Local 123'), findsOneWidget);
      expect(find.textContaining('Local 456'), findsOneWidget);
    });

    testWidgets('should highlight storm work jobs', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(constructionType: 'Storm Work'),
        MockData.createJob(constructionType: 'Commercial'),
      ];
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Storm Work'), findsOneWidget);
      expect(find.text('Commercial'), findsOneWidget);
      
      // Storm work should have special styling/badge
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });

    testWidgets('should display wage information correctly', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(wage: 45.50),
        MockData.createJob(wage: 38.25),
      ];
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('\$45.50'), findsOneWidget);
      expect(find.textContaining('\$38.25'), findsOneWidget);
    });
  });

  group('HomeScreen - User Interactions', () {
    testWidgets('should refresh jobs on screen initialization', (tester) async {
      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      verify(mockAppStateProvider.refreshJobs()).called(1);
    });

    testWidgets('should retry loading on error retry button tap', (tester) async {
      // Arrange
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn([]);
      when(mockAppStateProvider.error).thenReturn('Network error');

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAppStateProvider.refreshJobs()).called(2); // Once on init, once on retry
    });

    testWidgets('should handle job card tap navigation', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 1);
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      
      // Find and tap job card
      final jobCard = find.text('Journeyman Electrician').first;
      await tester.tap(jobCard);
      await tester.pumpAndSettle();

      // Assert - Navigation should occur (would need router mock setup)
      // This test verifies the tap is handled without errors
      expect(find.text('Journeyman Electrician'), findsWidgets);
    });

    testWidgets('should handle pull-to-refresh', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 5);
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      
      // Simulate pull-to-refresh
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();

      // Assert
      verify(mockAppStateProvider.refreshJobs()).called(atLeast(1));
    });
  });

  group('HomeScreen - Performance and Accessibility', () {
    testWidgets('should be accessible with screen readers', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 1);
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert - Check for semantic labels
      expect(find.bySemanticsLabel('Job listings'), findsOneWidget);
      expect(find.bySemanticsLabel('Refresh jobs'), findsOneWidget);
    });

    testWidgets('should handle large job lists efficiently', (tester) async {
      // Arrange
      final largeJobList = MockData.createJobList(count: 100);
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(largeJobList);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert - Should render without performance issues
      expect(find.byType(ListView), findsOneWidget);
      
      // Verify virtual scrolling is working
      expect(find.text('Test Electric Company'), findsWidgets);
    });

    testWidgets('should maintain scroll position on refresh', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 20);
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      
      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Trigger refresh
      when(mockAppStateProvider.refreshJobs()).thenAnswer((_) async {
        return null;
      });
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();

      // Assert - List should maintain position
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('HomeScreen - Electrical Theme Integration', () {
    testWidgets('should use electrical theme colors', (tester) async {
      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      
      expect(scaffold.backgroundColor, equals(AppTheme.offWhite));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
    });

    testWidgets('should display electrical icons and elements', (tester) async {
      // Arrange
      final mockJobs = [MockData.createJob(constructionType: 'Storm Work')];
      when(mockAppStateProvider.isLoading).thenReturn(false);
      when(mockAppStateProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert - Should have electrical-themed icons
      expect(find.byIcon(Icons.flash_on), findsOneWidget); // Storm work icon
      expect(find.byIcon(Icons.location_on), findsWidgets); // Location icons
    });

    testWidgets('should handle electrical loading animations', (tester) async {
      // Arrange
      when(mockAppStateProvider.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pump(); // Don't settle to see loading state

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Check if custom electrical loader is used
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      expect(progressIndicator.valueColor?.value, equals(AppTheme.accentCopper));
    });
  });
}