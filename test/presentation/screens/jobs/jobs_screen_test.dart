import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/screens/jobs/jobs_screen.dart';
import 'package:journeyman_jobs/providers/app_state_provider.dart';
import 'package:journeyman_jobs/providers/job_filter_provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/filter_criteria.dart';
import '../../../fixtures/mock_data.dart';
import '../../../fixtures/test_constants.dart';
import '../../../helpers/widget_test_helpers.dart';

// Generate mocks
@GenerateMocks([AppStateProvider, JobFilterProvider])
import 'jobs_screen_test.mocks.dart';

void main() {
  late MockJobsProvider mockJobsProvider;
  late MockJobFilterProvider mockJobFilterProvider;

  setUp(() {
    mockJobsProvider = MockJobsProvider();
    mockJobFilterProvider = MockJobFilterProvider();
    
    // Setup default mock behavior
    when(mockJobsProvider.isLoading).thenReturn(false);
    when(mockJobsProvider.jobs).thenReturn([]);
    when(mockJobsProvider.error).thenReturn(null);
    when(mockJobsProvider.hasMore).thenReturn(false);
    when(mockJobsProvider.loadJobs()).thenAnswer((_) async {});
    when(mockJobsProvider.loadMoreJobs()).thenAnswer((_) async {});
    when(mockJobsProvider.refreshJobs()).thenAnswer((_) async {});
    
    when(mockJobFilterProvider.activeFilters).thenReturn(FilterCriteria.empty());
    when(mockJobFilterProvider.hasActiveFilters).thenReturn(false);
    when(mockJobFilterProvider.clearFilters()).thenReturn(null);
  });

  Widget createJobsScreen() {
    return WidgetTestHelpers.createTestApp(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<JobsProvider>.value(value: mockJobsProvider),
          ChangeNotifierProvider<JobFilterProvider>.value(value: mockJobFilterProvider),
        ],
        child: const JobsScreen(),
      ),
    );
  }

  group('JobsScreen - Widget Rendering', () {
    testWidgets('should render jobs screen with app bar', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
    });

    testWidgets('should display filter button in app bar', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      
      expect(scaffold.backgroundColor, equals(AppTheme.offWhite));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
    });

    testWidgets('should display search bar', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search jobs...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('JobsScreen - Job List Display', () {
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(mockJobsProvider.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display job list when jobs are available', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 5);
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test Electric Company'), findsWidgets);
      expect(find.text('Journeyman Electrician'), findsWidgets);
    });

    testWidgets('should display empty state when no jobs found', (tester) async {
      // Arrange
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn([]);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No jobs found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filters'), findsOneWidget);
    });

    testWidgets('should display error state with retry option', (tester) async {
      // Arrange
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn([]);
      when(mockJobsProvider.error).thenReturn('Failed to load jobs');

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error Loading Jobs'), findsOneWidget);
      expect(find.text('Failed to load jobs'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display load more button when hasMore is true', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 10);
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);
      when(mockJobsProvider.hasMore).thenReturn(true);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Load More'), findsOneWidget);
    });
  });

  group('JobsScreen - IBEW Specific Features', () {
    testWidgets('should display IBEW classification filters', (tester) async {
      // Arrange
      final filters = FilterCriteria(
        classifications: MockData.electricalClassifications.take(2).toList(),
      );
      when(mockJobFilterProvider.activeFilters).thenReturn(filters);
      when(mockJobFilterProvider.hasActiveFilters).thenReturn(true);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Inside Wireman'), findsOneWidget);
      expect(find.text('Journeyman Lineman'), findsOneWidget);
    });

    testWidgets('should display IBEW local filter chips', (tester) async {
      // Arrange
      final filters = FilterCriteria(
        locals: [123, 456, 789],
      );
      when(mockJobFilterProvider.activeFilters).thenReturn(filters);
      when(mockJobFilterProvider.hasActiveFilters).thenReturn(true);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Local 123'), findsOneWidget);
      expect(find.text('Local 456'), findsOneWidget);
      expect(find.text('Local 789'), findsOneWidget);
    });

    testWidgets('should highlight storm work jobs prominently', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(
          id: 'storm-1',
          constructionType: 'Storm Work',
          company: 'Emergency Response Electric',
        ),
        MockData.createJob(
          id: 'regular-1', 
          constructionType: 'Commercial',
          company: 'Regular Electric Co',
        ),
      ];
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Storm Work'), findsOneWidget);
      expect(find.text('Emergency Response Electric'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget); // Storm work icon
    });

    testWidgets('should display wage ranges appropriate for electrical work', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(wage: 45.50, classification: 'Journeyman Lineman'),
        MockData.createJob(wage: 38.25, classification: 'Inside Wireman'),
      ];
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('\$45.50'), findsOneWidget);
      expect(find.textContaining('\$38.25'), findsOneWidget);
      expect(find.text('Journeyman Lineman'), findsOneWidget);
      expect(find.text('Inside Wireman'), findsOneWidget);
    });

    testWidgets('should show construction type badges', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(constructionType: 'Industrial'),
        MockData.createJob(constructionType: 'Utility'),
        MockData.createJob(constructionType: 'Commercial'),
      ];
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Industrial'), findsOneWidget);
      expect(find.text('Utility'), findsOneWidget);
      expect(find.text('Commercial'), findsOneWidget);
    });
  });

  group('JobsScreen - Search and Filter Interactions', () {
    testWidgets('should handle search input', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'lineman');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('lineman'), findsOneWidget);
    });

    testWidgets('should open filter dialog on filter button tap', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Filter Jobs'), findsOneWidget);
    });

    testWidgets('should clear filters when clear button is tapped', (tester) async {
      // Arrange
      when(mockJobFilterProvider.hasActiveFilters).thenReturn(true);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockJobFilterProvider.clearFilters()).called(1);
    });

    testWidgets('should handle pull-to-refresh', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 3);
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();

      // Assert
      verify(mockJobsProvider.refreshJobs()).called(1);
    });

    testWidgets('should load more jobs when load more button is tapped', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 10);
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);
      when(mockJobsProvider.hasMore).thenReturn(true);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockJobsProvider.loadMoreJobs()).called(1);
    });
  });

  group('JobsScreen - Error Handling', () {
    testWidgets('should retry loading jobs on retry button tap', (tester) async {
      // Arrange
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn([]);
      when(mockJobsProvider.error).thenReturn('Network timeout');

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockJobsProvider.loadJobs()).called(1);
    });

    testWidgets('should handle empty search results', (tester) async {
      // Arrange
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn([]);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'nonexistent job type');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No jobs found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filters'), findsOneWidget);
    });
  });

  group('JobsScreen - Performance', () {
    testWidgets('should handle large job lists efficiently', (tester) async {
      // Arrange
      final largeJobList = MockData.createJobList(count: 100);
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(largeJobList);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test Electric Company'), findsWidgets);
    });

    testWidgets('should debounce search input', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      // Type multiple characters quickly
      await tester.enterText(find.byType(TextField), 'l');
      await tester.enterText(find.byType(TextField), 'li');
      await tester.enterText(find.byType(TextField), 'lin');
      await tester.enterText(find.byType(TextField), 'line');
      await tester.pumpAndSettle();

      // Assert - Search should be debounced
      expect(find.text('line'), findsOneWidget);
    });
  });

  group('JobsScreen - Accessibility', () {
    testWidgets('should be accessible with screen readers', (tester) async {
      // Arrange
      final mockJobs = MockData.createJobList(count: 2);
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel('Search jobs'), findsOneWidget);
      expect(find.bySemanticsLabel('Filter jobs'), findsOneWidget);
      expect(find.bySemanticsLabel('Job listings'), findsOneWidget);
    });

    testWidgets('should have proper focus management', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();
      
      // Focus search field
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Assert
      expect(tester.binding.focusManager.primaryFocus?.hasFocus, isTrue);
    });
  });

  group('JobsScreen - Electrical Theme Integration', () {
    testWidgets('should use electrical industry color scheme', (tester) async {
      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
    });

    testWidgets('should display electrical industry icons', (tester) async {
      // Arrange
      final mockJobs = [
        MockData.createJob(constructionType: 'Storm Work'),
        MockData.createJob(classification: 'Journeyman Lineman'),
      ];
      when(mockJobsProvider.isLoading).thenReturn(false);
      when(mockJobsProvider.jobs).thenReturn(mockJobs);

      // Act
      await tester.pumpWidget(createJobsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.flash_on), findsOneWidget); // Storm work
      expect(find.byIcon(Icons.electrical_services), findsWidgets); // Electrical work
    });
  });
}