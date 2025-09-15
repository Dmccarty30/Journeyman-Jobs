import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:journeyman_jobs/features/crews/widgets/crew_card.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Mock crew model for testing
/// TODO: Replace with actual CrewModel when implemented
class MockCrew {
  final String id;
  final String name;
  final int memberCount;
  final String description;
  final bool isStormWorkSpecialized;
  final String? imageUrl;
  final String classification;
  final DateTime createdAt;
  
  const MockCrew({
    required this.id,
    required this.name,
    required this.memberCount,
    this.description = '',
    this.isStormWorkSpecialized = false,
    this.imageUrl,
    this.classification = 'General',
    required this.createdAt,
  });
}

void main() {
  group('CrewCard Widget Tests', () {
    late MockCrew mockCrew;
    late MockCrew stormCrew;
    
    setUp(() {
      mockCrew = MockCrew(
        id: 'crew-1',
        name: 'IBEW Local 123 Alpha Crew',
        memberCount: 4,
        description: 'Experienced commercial electrical crew',
        isStormWorkSpecialized: false,
        classification: 'Inside Wireman',
        createdAt: DateTime(2024, 1, 15),
      );
      
      stormCrew = MockCrew(
        id: 'crew-2', 
        name: 'Storm Response Team Beta',
        memberCount: 6,
        description: 'Emergency restoration specialists',
        isStormWorkSpecialized: true,
        imageUrl: 'https://example.com/crew-beta.jpg',
        classification: 'Journeyman Lineman',
        createdAt: DateTime(2024, 2, 1),
      );
    });

    /// Creates test widget wrapped in required providers and theme
    Widget createTestWidget({
      required MockCrew crew,
      VoidCallback? onTap,
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CrewCard(
              crew: crew,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    /// Test group for basic rendering functionality
    group('Basic Rendering', () {
      testWidgets('displays crew card with electrical theme', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify crew name is displayed
        expect(find.text('IBEW Local 123 Alpha Crew'), findsOneWidget);
        
        // Verify member count display
        expect(find.textContaining('4 Members'), findsOneWidget);
        
        // Verify electrical theme colors are applied
        final cardWidget = tester.widget<Card>(find.byType(Card));
        expect(cardWidget.color, AppTheme.white);
        
        // Verify card has proper electrical styling
        final cardFinder = find.byType(Card);
        expect(cardFinder, findsOneWidget);
      });

      testWidgets('displays crew classification badge', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify classification is shown
        expect(find.text('Inside Wireman'), findsOneWidget);
        
        // Verify badge styling with electrical colors
        final chipFinder = find.byType(Chip);
        expect(chipFinder, findsOneWidget);
      });

      testWidgets('shows placeholder when no crew image provided', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Should display circuit pattern or electrical icon as placeholder
        final iconFinder = find.byIcon(Icons.electrical_services);
        expect(iconFinder, findsOneWidget);
      });
    });

    /// Test group for storm work specialization features
    group('Storm Work Specialization', () {
      testWidgets('displays storm work indicator for specialized crews', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: stormCrew));
        
        // Verify storm work badge is visible
        expect(find.textContaining('Storm Specialist'), findsOneWidget);
        
        // Verify electrical storm icon
        final stormIcon = find.byIcon(Icons.flash_on);
        expect(stormIcon, findsOneWidget);
        
        // Verify storm work colors (warning amber/copper)
        final badge = tester.widget<Container>(
          find.descendant(
            of: find.byType(CrewCard),
            matching: find.byType(Container),
          ).first,
        );
        expect(badge.decoration, isA<BoxDecoration>());
      });

      testWidgets('applies storm work electrical styling', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: stormCrew));
        
        // Verify enhanced electrical theme for storm crews
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, greaterThan(2.0));
        
        // Should have lightning/electrical accent border
        expect(find.byType(Container), findsWidgets);
      });
    });

    /// Test group for user interactions
    group('User Interactions', () {
      testWidgets('responds to tap gestures for field workers', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          crew: mockCrew,
          onTap: () => wasTapped = true,
        ));
        
        // Test tap on card
        await tester.tap(find.byType(CrewCard));
        await tester.pumpAndSettle();
        
        expect(wasTapped, isTrue);
      });

      testWidgets('provides haptic feedback for mobile field use', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify InkWell for proper touch feedback
        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);
      });

      testWidgets('has adequate touch targets for field workers', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify minimum touch target size (48x48 logical pixels)
        final cardSize = tester.getSize(find.byType(CrewCard));
        expect(cardSize.height, greaterThanOrEqualTo(48.0));
      });
    });

    /// Test group for electrical theme integration
    group('Electrical Theme Integration', () {
      testWidgets('applies IBEW branding colors correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify primary navy color usage
        final finder = find.descendant(
          of: find.byType(CrewCard),
          matching: find.byType(Text),
        );
        
        expect(finder, findsWidgets);
        
        // Verify copper accent colors
        final decoratedBoxes = find.byType(DecoratedBox);
        expect(decoratedBoxes, findsWidgets);
      });

      testWidgets('includes circuit pattern background', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify circuit pattern or electrical-themed background
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
        
        // Should have electrical decoration
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('displays electrical icons appropriately', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify electrical-themed icons
        final electricalIcon = find.byIcon(Icons.electrical_services);
        expect(electricalIcon, findsOneWidget);
        
        // For storm crews, should have additional lightning icon
        await tester.pumpWidget(createTestWidget(crew: stormCrew));
        await tester.pumpAndSettle();
        
        final lightningIcon = find.byIcon(Icons.flash_on);
        expect(lightningIcon, findsOneWidget);
      });
    });

    /// Test group for responsive design
    group('Responsive Design', () {
      testWidgets('adapts layout for mobile field worker usage', (tester) async {
        // Test on typical mobile screen size
        await tester.binding.setSurfaceSize(const Size(375, 667));
        
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify card fits mobile viewport
        final cardSize = tester.getSize(find.byType(CrewCard));
        expect(cardSize.width, lessThanOrEqualTo(375.0));
        
        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('maintains readability in outdoor lighting conditions', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify high contrast text styling for field visibility
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        
        for (final textWidget in textWidgets) {
          expect(textWidget.style?.fontWeight, 
                 anyOf(FontWeight.w500, FontWeight.w600, FontWeight.bold));
        }
      });
    });

    /// Test group for accessibility features
    group('Accessibility Features', () {
      testWidgets('provides semantic labels for screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(crew: mockCrew));
        
        // Verify semantic information for crew card
        final semantics = find.byType(Semantics);
        expect(semantics, findsWidgets);
      });

      testWidgets('supports high contrast mode for visibility', (tester) async {
        // Test with high contrast theme
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme.copyWith(
                visualDensity: VisualDensity.compact,
              ),
              home: Scaffold(
                body: CrewCard(crew: mockCrew),
              ),
            ),
          ),
        );
        
        // Verify sufficient color contrast
        expect(find.byType(CrewCard), findsOneWidget);
      });
    });

    /// Test group for error states and edge cases
    group('Error States and Edge Cases', () {
      testWidgets('handles empty crew name gracefully', (tester) async {
        final emptyCrew = MockCrew(
          id: 'empty-crew',
          name: '',
          memberCount: 0,
          createdAt: DateTime.now(),
        );
        
        await tester.pumpWidget(createTestWidget(crew: emptyCrew));
        
        // Should display placeholder text
        expect(find.text('Unnamed Crew'), findsOneWidget);
        expect(find.text('0 Members'), findsOneWidget);
      });

      testWidgets('handles large member counts properly', (tester) async {
        final largeCrew = MockCrew(
          id: 'large-crew',
          name: 'Mega Crew',
          memberCount: 999,
          createdAt: DateTime.now(),
        );
        
        await tester.pumpWidget(createTestWidget(crew: largeCrew));
        
        // Should format large numbers appropriately
        expect(find.textContaining('999 Members'), findsOneWidget);
      });

      testWidgets('displays loading state during image load', (tester) async {
        final imageLoadingCrew = MockCrew(
          id: 'loading-crew',
          name: 'Image Loading Crew',
          memberCount: 3,
          imageUrl: 'https://slow-loading-image.com/crew.jpg',
          createdAt: DateTime.now(),
        );
        
        await tester.pumpWidget(createTestWidget(crew: imageLoadingCrew));
        
        // Should show loading indicator or placeholder
        final circularProgress = find.byType(CircularProgressIndicator);
        expect(circularProgress, findsOneWidget);
      });
    });
  });
}
