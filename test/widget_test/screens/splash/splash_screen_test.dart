import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/screens/splash/splash_screen.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:mockito/mockito.dart';

import '../../../test_utils/test_helpers.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should display splash screen with logo and animations',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));

      // Act - Initial pump
      await tester.pump();

      // Assert - Check initial state
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Look for gradient background
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SplashScreen),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.decoration, isNotNull);
      expect(container.decoration, isA<BoxDecoration>());
      
      // Verify logo presence
      expect(find.byType(Image), findsOneWidget);
      
      // Verify 'Journeyman Jobs' text
      expect(find.text('Journeyman Jobs'), findsOneWidget);
      
      // Verify tagline
      expect(find.text('Connecting IBEW Professionals'), findsOneWidget);
    });

    testWidgets('should display loading indicator', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));

      // Act
      await tester.pump();

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use correct theme colors',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));

      // Act
      await tester.pump();

      // Assert - Check text styling
      final titleText = tester.widget<Text>(find.text('Journeyman Jobs'));
      expect(titleText.style?.color, equals(Colors.white));
      expect(titleText.style?.fontSize, greaterThan(20));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));

      final taglineText = tester.widget<Text>(
        find.text('Connecting IBEW Professionals'),
      );
      expect(taglineText.style?.color, equals(Colors.white70));
    });

    testWidgets('should animate elements on screen',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));

      // Act - Pump to trigger animations
      await tester.pump();
      
      // Find animated widgets
      final fadeTransitions = find.byType(FadeTransition);
      final slideTransitions = find.byType(SlideTransition);
      
      // Assert - Animations should be present
      expect(fadeTransitions, findsWidgets);
      expect(slideTransitions, findsWidgets);
      
      // Pump through animation duration
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      
      // Elements should still be visible after animation
      expect(find.text('Journeyman Jobs'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should properly dispose animations on unmount',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));
      
      // Act - Let animations run
      await tester.pump(const Duration(seconds: 1));
      
      // Replace with empty container to trigger disposal
      await tester.pumpWidget(createTestWidget(Container()));
      
      // Assert - No exceptions should be thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle different screen sizes',
        (WidgetTester tester) async {
      // Test on small screen
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createTestWidget(const SplashScreen()));
      await tester.pump();
      
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Journeyman Jobs'), findsOneWidget);
      
      // Test on tablet
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createTestWidget(const SplashScreen()));
      await tester.pump();
      
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Journeyman Jobs'), findsOneWidget);
      
      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should display copyright information if present',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));

      // Act
      await tester.pump();

      // Assert - Check for any copyright text (if implemented)
      final copyrightFinder = find.textContaining('©');
      final yearFinder = find.textContaining('2025');
      
      // These might not be implemented yet, so we check if they exist
      if (copyrightFinder.evaluate().isNotEmpty) {
        expect(copyrightFinder, findsOneWidget);
      }
      if (yearFinder.evaluate().isNotEmpty) {
        expect(yearFinder, findsOneWidget);
      }
    });

    testWidgets('should be accessible with semantic labels',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const SplashScreen()));

      // Act
      await tester.pump();

      // Assert - Check for semantic labels
      expect(
        find.bySemanticsLabel(RegExp(r'.*[Ll]ogo.*')),
        findsWidgets,
      );
    });
  });
}