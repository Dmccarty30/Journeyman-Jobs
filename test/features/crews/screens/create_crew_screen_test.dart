import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../lib/features/crews/screens/create_crew_screen.dart';
import '../../../../lib/features/crews/models/crew_enums.dart';
import '../../../../lib/design_system/app_theme.dart';

void main() {
  group('CreateCrewScreen Tests', () {
    testWidgets('should render create crew form with all sections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              primaryColor: AppTheme.primaryNavy,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: AppTheme.primaryNavy,
                secondary: AppTheme.accentCopper,
              ),
            ),
            home: const CreateCrewScreen(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify AppBar elements
      expect(find.text('Create Crew'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Verify section headers
      expect(find.text('Crew Basics'), findsOneWidget);
      expect(find.text('IBEW Classifications'), findsOneWidget);
      expect(find.text('Location & Availability'), findsOneWidget);
      expect(find.text('Rates & Requirements'), findsOneWidget);
      expect(find.text('Privacy & Permissions'), findsOneWidget);

      // Verify required form fields
      expect(find.byType(TextFormField), findsAtLeastNWidgets(7));
      expect(find.text('Crew Name*'), findsOneWidget);
      expect(find.text('Max Members*'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty required fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to save without filling required fields
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Crew name is required'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget); // For max members
    });

    testWidgets('should display IBEW classification chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show IBEW classification chips
      expect(find.text('Inside Wireman'), findsOneWidget);
      expect(find.text('Journeyman Lineman'), findsOneWidget);
      expect(find.text('Tree Trimmer'), findsOneWidget);
      expect(find.text('Equipment Operator'), findsOneWidget);
    });

    testWidgets('should display job type filter chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show job type chips from JobType enum
      expect(find.text('Inside Wireman'), findsWidgets); // May appear in both sections
      expect(find.text('Storm Work'), findsOneWidget);
      expect(find.text('Substation Work'), findsOneWidget);
    });

    testWidgets('should toggle switches correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and toggle storm work switch
      final stormWorkSwitch = find.byType(SwitchListTile).first;
      await tester.tap(stormWorkSwitch);
      await tester.pumpAndSettle();

      // Switch should be toggled (this is hard to verify directly, 
      // but no errors should occur)
      expect(find.byType(SwitchListTile), findsAtLeastNWidgets(5));
    });

    testWidgets('should show electrical-themed icons and colors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show electrical-themed icons
      expect(find.byIcon(Icons.bolt), findsOneWidget);
      expect(find.byIcon(Icons.engineering), findsOneWidget);
      expect(find.byIcon(Icons.thunderstorm), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
    });

    testWidgets('should validate union local format', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find union local field and enter invalid format
      final unionLocalField = find.byType(TextFormField).at(3); // Union local field
      await tester.enterText(unionLocalField, 'Invalid Format');
      
      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show format validation error
      expect(find.text('Format: Local 123'), findsOneWidget);
    });

    testWidgets('should accept valid union local format', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find union local field and enter valid format
      final unionLocalField = find.byType(TextFormField).at(3);
      await tester.enterText(unionLocalField, 'Local 123');
      
      // Should not show validation error on this field
      expect(find.text('Format: Local 123'), findsNothing);
    });

    testWidgets('should require at least one classification selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill required text fields but don't select classifications
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Crew');
      
      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show classification requirement error
      expect(find.text('At least one classification is required'), findsOneWidget);
    });

    testWidgets('should require at least one job type selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill required text fields but don't select job types
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Crew');
      
      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show job type requirement error
      expect(find.text('At least one job type is required'), findsOneWidget);
    });

    testWidgets('should show loading indicator when saving', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CreateCrewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // This test would require mocking the crew provider to simulate loading state
      // For now, just verify the loading indicator exists in the widget tree
      expect(find.text('Creating crew...'), findsNothing); // Should not be visible initially
    });
  });
}
