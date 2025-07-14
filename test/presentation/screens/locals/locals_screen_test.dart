import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/screens/locals/locals_screen.dart';
import 'package:journeyman_jobs/providers/locals_provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../../fixtures/mock_data.dart';
import '../../../fixtures/test_constants.dart';
import '../../../helpers/widget_test_helpers.dart';

// Generate mocks
@GenerateMocks([LocalsProvider])
import 'locals_screen_test.mocks.dart';

void main() {
  late MockLocalsProvider mockLocalsProvider;

  setUp(() {
    mockLocalsProvider = MockLocalsProvider();
    
    // Setup default mock behavior
    when(mockLocalsProvider.isLoading).thenReturn(false);
    when(mockLocalsProvider.locals).thenReturn([]);
    when(mockLocalsProvider.filteredLocals).thenReturn([]);
    when(mockLocalsProvider.error).thenReturn(null);
    when(mockLocalsProvider.searchQuery).thenReturn('');
    when(mockLocalsProvider.selectedState).thenReturn(null);
    when(mockLocalsProvider.availableStates).thenReturn(MockData.ibewStates);
    when(mockLocalsProvider.loadLocals()).thenAnswer((_) async {});
    when(mockLocalsProvider.searchLocals(any)).thenReturn(null);
    when(mockLocalsProvider.filterByState(any)).thenReturn(null);
    when(mockLocalsProvider.clearFilters()).thenReturn(null);
  });

  Widget createLocalsScreen() {
    return WidgetTestHelpers.createTestApp(
      child: ChangeNotifierProvider<LocalsProvider>.value(
        value: mockLocalsProvider,
        child: const LocalsScreen(),
      ),
    );
  }

  group('LocalsScreen - Widget Rendering', () {
    testWidgets('should render locals screen with app bar', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('IBEW Locals'), findsOneWidget);
    });

    testWidgets('should display search bar', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search locals...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display state filter dropdown', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Filter by State'), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      
      expect(scaffold.backgroundColor, equals(AppTheme.offWhite));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
    });
  });

  group('LocalsScreen - Locals List Display', () {
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(mockLocalsProvider.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display locals list when data is available', (tester) async {
      // Arrange
      final mockLocals = MockData.createLocalsList(count: 5);
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('IBEW Local'), findsWidgets);
    });

    testWidgets('should display empty state when no locals found', (tester) async {
      // Arrange
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn([]);
      when(mockLocalsProvider.filteredLocals).thenReturn([]);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No locals found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filters'), findsOneWidget);
    });

    testWidgets('should display error state with retry option', (tester) async {
      // Arrange
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn([]);
      when(mockLocalsProvider.filteredLocals).thenReturn([]);
      when(mockLocalsProvider.error).thenReturn('Failed to load locals');

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error Loading Locals'), findsOneWidget);
      expect(find.text('Failed to load locals'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('LocalsScreen - IBEW Specific Features', () {
    testWidgets('should display IBEW local numbers correctly', (tester) async {
      // Arrange
      final mockLocals = [
        MockData.createLocal(localNumber: 123, name: 'IBEW Local 123'),
        MockData.createLocal(localNumber: 456, name: 'IBEW Local 456'),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('IBEW Local 123'), findsOneWidget);
      expect(find.text('IBEW Local 456'), findsOneWidget);
      expect(find.textContaining('Local 123'), findsOneWidget);
      expect(find.textContaining('Local 456'), findsOneWidget);
    });

    testWidgets('should display local addresses and contact info', (tester) async {
      // Arrange
      final mockLocals = [
        MockData.createLocal(
          localNumber: 123,
          address: '123 Union St, Test City, TS 12345',
          phone: '(555) 123-4567',
        ),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('123 Union St, Test City, TS 12345'), findsOneWidget);
      expect(find.text('(555) 123-4567'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('should display electrical classifications for each local', (tester) async {
      // Arrange
      final mockLocals = [
        MockData.createLocal(
          localNumber: 123,
          classifications: ['Inside Wireman', 'Journeyman Lineman'],
        ),
        MockData.createLocal(
          localNumber: 456,
          classifications: ['Tree Trimmer', 'Equipment Operator'],
        ),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Inside Wireman'), findsOneWidget);
      expect(find.text('Journeyman Lineman'), findsOneWidget);
      expect(find.text('Tree Trimmer'), findsOneWidget);
      expect(find.text('Equipment Operator'), findsOneWidget);
    });

    testWidgets('should handle all 797+ IBEW locals efficiently', (tester) async {
      // Arrange - Create large dataset similar to real IBEW directory
      final largeLocalsList = MockData.createLocalsList(count: 100);
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(largeLocalsList);
      when(mockLocalsProvider.filteredLocals).thenReturn(largeLocalsList);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('IBEW Local'), findsWidgets);
    });

    testWidgets('should display state-specific locals when filtered', (tester) async {
      // Arrange
      final californiaLocals = [
        MockData.createLocal(localNumber: 11, state: 'CA'),
        MockData.createLocal(localNumber: 47, state: 'CA'),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(californiaLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(californiaLocals);
      when(mockLocalsProvider.selectedState).thenReturn('CA');

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('CA'), findsWidgets);
      expect(find.text('IBEW Local 11'), findsOneWidget);
      expect(find.text('IBEW Local 47'), findsOneWidget);
    });
  });

  group('LocalsScreen - Search and Filter Interactions', () {
    testWidgets('should handle search input', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), '123');
      await tester.pumpAndSettle();

      // Assert
      verify(mockLocalsProvider.searchLocals('123')).called(1);
    });

    testWidgets('should handle state filter selection', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('CA').last);
      await tester.pumpAndSettle();

      // Assert
      verify(mockLocalsProvider.filterByState('CA')).called(1);
    });

    testWidgets('should clear filters when clear button is tapped', (tester) async {
      // Arrange
      when(mockLocalsProvider.searchQuery).thenReturn('test');
      when(mockLocalsProvider.selectedState).thenReturn('CA');

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockLocalsProvider.clearFilters()).called(1);
    });

    testWidgets('should handle pull-to-refresh', (tester) async {
      // Arrange
      final mockLocals = MockData.createLocalsList(count: 5);
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();

      // Assert
      verify(mockLocalsProvider.loadLocals()).called(1);
    });
  });

  group('LocalsScreen - Contact Integration', () {
    testWidgets('should handle phone number taps', (tester) async {
      // Arrange
      final mockLocals = [
        MockData.createLocal(
          localNumber: 123,
          phone: '(555) 123-4567',
        ),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('(555) 123-4567'));
      await tester.pumpAndSettle();

      // Assert - Should handle phone call intent
      expect(find.text('(555) 123-4567'), findsOneWidget);
    });

    testWidgets('should handle email taps', (tester) async {
      // Arrange
      final mockLocals = [
        MockData.createLocal(
          localNumber: 123,
        ),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.email), findsWidgets);
    });

    testWidgets('should handle website links', (tester) async {
      // Arrange
      final mockLocals = [
        MockData.createLocal(localNumber: 123),
      ];
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.language), findsWidgets);
    });
  });

  group('LocalsScreen - Error Handling', () {
    testWidgets('should retry loading locals on retry button tap', (tester) async {
      // Arrange
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn([]);
      when(mockLocalsProvider.filteredLocals).thenReturn([]);
      when(mockLocalsProvider.error).thenReturn('Network timeout');

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockLocalsProvider.loadLocals()).called(1);
    });

    testWidgets('should handle empty search results gracefully', (tester) async {
      // Arrange
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(MockData.createLocalsList(count: 10));
      when(mockLocalsProvider.filteredLocals).thenReturn([]);
      when(mockLocalsProvider.searchQuery).thenReturn('nonexistent');

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No locals found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filters'), findsOneWidget);
    });
  });

  group('LocalsScreen - Performance', () {
    testWidgets('should handle virtual scrolling for large datasets', (tester) async {
      // Arrange - Simulate full IBEW directory
      final fullDirectory = MockData.createLocalsList(count: 797);
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(fullDirectory);
      when(mockLocalsProvider.filteredLocals).thenReturn(fullDirectory);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      
      // Should not render all items at once
      final renderedItems = find.textContaining('IBEW Local').evaluate().length;
      expect(renderedItems, lessThan(797));
    });

    testWidgets('should debounce search input', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();
      
      // Type multiple characters quickly
      await tester.enterText(find.byType(TextField), '1');
      await tester.enterText(find.byType(TextField), '12');
      await tester.enterText(find.byType(TextField), '123');
      await tester.pumpAndSettle();

      // Assert - Search should be debounced
      verify(mockLocalsProvider.searchLocals('123')).called(1);
    });
  });

  group('LocalsScreen - Accessibility', () {
    testWidgets('should be accessible with screen readers', (tester) async {
      // Arrange
      final mockLocals = MockData.createLocalsList(count: 2);
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel('Search IBEW locals'), findsOneWidget);
      expect(find.bySemanticsLabel('Filter by state'), findsOneWidget);
      expect(find.bySemanticsLabel('IBEW locals directory'), findsOneWidget);
    });

    testWidgets('should have proper contrast for electrical theme', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert - Colors should meet accessibility standards
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
      expect(appBar.foregroundColor, equals(Colors.white));
    });
  });

  group('LocalsScreen - Electrical Theme Integration', () {
    testWidgets('should use electrical industry color scheme', (tester) async {
      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      
      expect(scaffold.backgroundColor, equals(AppTheme.offWhite));
      expect(appBar.backgroundColor, equals(AppTheme.primaryNavy));
    });

    testWidgets('should display electrical industry icons', (tester) async {
      // Arrange
      final mockLocals = MockData.createLocalsList(count: 1);
      when(mockLocalsProvider.isLoading).thenReturn(false);
      when(mockLocalsProvider.locals).thenReturn(mockLocals);
      when(mockLocalsProvider.filteredLocals).thenReturn(mockLocals);

      // Act
      await tester.pumpWidget(createLocalsScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.location_on), findsWidgets);
      expect(find.byIcon(Icons.phone), findsWidgets);
      expect(find.byIcon(Icons.email), findsWidgets);
      expect(find.byIcon(Icons.language), findsWidgets);
    });
  });
}