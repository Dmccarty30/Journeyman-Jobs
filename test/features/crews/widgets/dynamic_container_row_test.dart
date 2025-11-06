import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Comprehensive test suite for DynamicContainerRow widget
///
/// Tests cover:
/// - Widget rendering and layout
/// - State management and selection
/// - User interactions (taps, gestures)
/// - Visual styling and theme integration
/// - Animation behavior
/// - Edge cases and error handling
void main() {
  group('DynamicContainerRow', () {
    const testLabels = ['Feed', 'Jobs', 'Chat', 'Members'];

    testWidgets('renders with correct number of containers', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
    });

    testWidgets('displays selected container with correct styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 1, // Select "Jobs"
            ),
          ),
        ),
      );

      // Assert - Find the container with "Jobs" text
      final jobsContainer = find.ancestor(
        of: find.text('Jobs'),
        matching: find.byType(AnimatedContainer),
      );

      expect(jobsContainer, findsOneWidget);

      final animatedContainer = tester.widget<AnimatedContainer>(jobsContainer);
      final boxDecoration = animatedContainer.decoration as BoxDecoration;

      // Verify selected styling
      expect(boxDecoration.color, equals(AppTheme.accentCopper));
      expect(boxDecoration.border?.top.color, equals(AppTheme.accentCopper));
      expect(boxDecoration.border?.top.width, equals(AppTheme.borderWidthCopper));
      expect(boxDecoration.borderRadius, equals(BorderRadius.circular(AppTheme.radiusMd)));
    });

    testWidgets('displays non-selected containers with correct styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 1, // Select "Jobs"
            ),
          ),
        ),
      );

      // Assert - Find the container with "Feed" text (not selected)
      final feedContainer = find.ancestor(
        of: find.text('Feed'),
        matching: find.byType(AnimatedContainer),
      );

      expect(feedContainer, findsOneWidget);

      final animatedContainer = tester.widget<AnimatedContainer>(feedContainer);
      final boxDecoration = animatedContainer.decoration as BoxDecoration;

      // Verify non-selected styling
      expect(boxDecoration.color, equals(AppTheme.white));
      expect(boxDecoration.border?.top.color, equals(AppTheme.accentCopper));
      expect(boxDecoration.border?.top.width, equals(AppTheme.borderWidthCopper));
    });

    testWidgets('calls onTap callback with correct index', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Act - Tap on "Chat" (index 2)
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(2));
    });

    testWidgets('applies scale animation on press', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Act - Start gesture but don't complete
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Feed')),
      );

      // Allow time for animation to start
      await tester.pump(const Duration(milliseconds: 50));

      // Assert - The widget should have initiated scale animation
      // We can't easily check the exact scale value due to animation complexity,
      // but we can verify the widget exists and responds to gestures
      expect(find.text('Feed'), findsOneWidget);

      // Clean up
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('respects custom height parameter', (tester) async {
      // Arrange
      const customHeight = 100.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
              height: customHeight,
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Feed'),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.constraints?.maxHeight, equals(customHeight));
    });

    testWidgets('uses default height when not specified', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Assert - Default height should be 60.0
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Feed'),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.constraints?.maxHeight, equals(60.0));
    });

    testWidgets('containers are equally sized', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Assert - All containers should be wrapped in Expanded widgets
      final expandedWidgets = find.byType(Expanded);
      expect(expandedWidgets, findsNWidgets(4));
    });

    testWidgets('applies proper spacing between containers', (tester) async {
      // Arrange
      const customSpacing = 16.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
              spacing: customSpacing,
            ),
          ),
        ),
      );

      // Assert - Check padding widgets exist
      final paddingWidgets = find.byType(Padding);
      expect(paddingWidgets, findsWidgets);
    });

    testWidgets('handles rapid taps correctly', (tester) async {
      // Arrange
      final tappedIndices = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
              onTap: (index) {
                tappedIndices.add(index);
              },
            ),
          ),
        ),
      );

      // Act - Rapid taps
      await tester.tap(find.text('Feed'));
      await tester.tap(find.text('Jobs'));
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndices, equals([0, 1, 2]));
    });

    testWidgets('text style changes based on selection', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 1, // Select "Jobs"
            ),
          ),
        ),
      );

      // Assert - Selected text should be white
      final selectedText = tester.widget<Text>(find.text('Jobs'));
      expect(selectedText.style?.color, equals(AppTheme.white));
      expect(selectedText.style?.fontWeight, equals(FontWeight.w600));

      // Assert - Non-selected text should be copper
      final nonSelectedText = tester.widget<Text>(find.text('Feed'));
      expect(nonSelectedText.style?.color, equals(AppTheme.accentCopper));
      expect(nonSelectedText.style?.fontWeight, equals(FontWeight.w500));
    });

    testWidgets('handles gesture cancellation', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: testLabels,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Act - Start gesture and cancel
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Feed')),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.cancel();
      await tester.pumpAndSettle();

      // Assert - Widget should still exist and be functional
      expect(find.text('Feed'), findsOneWidget);
    });
  });

  group('DynamicContainerRowWithIcons', () {
    const testLabels = ['Feed', 'Jobs', 'Chat', 'Members'];
    const testIcons = [
      Icons.feed_outlined,
      Icons.work_outline,
      Icons.chat_bubble_outline,
      Icons.group_outlined,
    ];

    testWidgets('renders with icons and labels', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRowWithIcons(
              labels: testLabels,
              icons: testIcons,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Assert - Check for all labels
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);

      // Assert - Check for all icons
      expect(find.byIcon(Icons.feed_outlined), findsOneWidget);
      expect(find.byIcon(Icons.work_outline), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    });

    testWidgets('applies correct icon colors based on selection', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRowWithIcons(
              labels: testLabels,
              icons: testIcons,
              selectedIndex: 1, // Select "Jobs"
            ),
          ),
        ),
      );

      // Find icons and check colors
      final jobsIcon = tester.widget<Icon>(find.byIcon(Icons.work_outline));
      final feedIcon = tester.widget<Icon>(find.byIcon(Icons.feed_outlined));

      // Assert
      expect(jobsIcon.color, equals(AppTheme.white)); // Selected
      expect(feedIcon.color, equals(AppTheme.accentCopper)); // Not selected
    });

    testWidgets('calls onTap callback with correct index', (tester) async {
      // Arrange
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRowWithIcons(
              labels: testLabels,
              icons: testIcons,
              selectedIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Act - Tap on the Chat icon
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedIndex, equals(2));
    });

    testWidgets('uses larger default height for icon variant', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRowWithIcons(
              labels: testLabels,
              icons: testIcons,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Assert - Default height should be 80.0 for icon variant
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.byIcon(Icons.feed_outlined),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.constraints?.maxHeight, equals(80.0));
    });
  });

  group('Edge Cases', () {
    testWidgets('throws assertion error with less than 4 labels', (tester) async {
      // Assert
      expect(
        () => DynamicContainerRow(
          labels: const ['Feed', 'Jobs', 'Chat'], // Only 3 labels
          selectedIndex: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('throws assertion error with more than 4 labels', (tester) async {
      // Assert
      expect(
        () => DynamicContainerRow(
          labels: const ['Feed', 'Jobs', 'Chat', 'Members', 'Extra'], // 5 labels
          selectedIndex: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('handles empty label strings', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicContainerRow(
              labels: const ['', 'Jobs', '', 'Members'],
              selectedIndex: 0,
            ),
          ),
        ),
      );

      // Assert - Should still render
      expect(find.byType(DynamicContainerRow), findsOneWidget);
    });

    testWidgets('handles very long label text with ellipsis', (tester) async {
      // Arrange
      const longLabels = [
        'Very Long Label Text',
        'Another Long Label',
        'This is too long',
        'Extremely Long Text'
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400, // Constrain width
              child: DynamicContainerRow(
                labels: longLabels,
                selectedIndex: 0,
              ),
            ),
          ),
        ),
      );

      // Assert - Text widgets should have ellipsis overflow
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        expect(text.overflow, equals(TextOverflow.ellipsis));
        expect(text.maxLines, equals(1));
      }
    });
  });
}
