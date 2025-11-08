import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/services/stream_chat_service.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';

import 'tailboard_screen_team_isolation_test.mocks.dart';

// Generate mocks
@GenerateMocks([StreamChatService])
void main() {
  group('TailboardScreen Team Isolation Tests', () {
    late ProviderContainer container;
    late MockStreamChatService mockStreamService;
    late Crew testCrew1;
    late Crew testCrew2;

    setUp(() {
      mockStreamService = MockStreamChatService();

      testCrew1 = Crew(
        id: 'crew-123',
        name: 'IBEW Local 123',
        description: 'Test crew 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        memberCount: 10,
        isActive: true,
      );

      testCrew2 = Crew(
        id: 'crew-456',
        name: 'IBEW Local 456',
        description: 'Test crew 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        memberCount: 15,
        isActive: true,
      );

      // Override providers with mocks
      container = ProviderContainer(
        overrides: [
          streamChatServiceProvider.overrideWithValue(mockStreamService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should call updateUserTeam when crew selection changes', (tester) async {
      // Arrange
      when(mockStreamService.updateUserTeam(any))
          .thenAnswer((_) async {});

      // Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // Simulate crew selection change
                  return ElevatedButton(
                    onPressed: () {
                      container.read(selectedCrewProvider.notifier).setCrew(testCrew1);
                    },
                    child: const Text('Select Crew'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Select Crew'));
      await tester.pump();

      // Wait for async operations
      await tester.pump(Duration.zero);

      // Assert
      verify(mockStreamService.updateUserTeam('crew-123')).called(1);
    });

    testWidgets('should call updateUserTeam only when crew ID actually changes', (tester) async {
      // Arrange
      when(mockStreamService.updateUserTeam(any))
          .thenAnswer((_) async {});

      // Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          container.read(selectedCrewProvider.notifier).setCrew(testCrew1);
                        },
                        child: const Text('Select Crew 1'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Select same crew (different instance but same ID)
                          final sameCrew = Crew(
                            id: 'crew-123', // Same ID
                            name: 'Different Name', // Different name
                            description: 'Different description',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            memberCount: 20,
                            isActive: true,
                          );
                          container.read(selectedCrewProvider.notifier).setCrew(sameCrew);
                        },
                        child: const Text('Select Same Crew'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          container.read(selectedCrewProvider.notifier).setCrew(testCrew2);
                        },
                        child: const Text('Select Crew 2'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Act - Select first crew
      await tester.tap(find.text('Select Crew 1'));
      await tester.pump();
      await tester.pump(Duration.zero);

      // Select same crew (should not trigger update)
      await tester.tap(find.text('Select Same Crew'));
      await tester.pump();
      await tester.pump(Duration.zero);

      // Select different crew
      await tester.tap(find.text('Select Crew 2'));
      await tester.pump();
      await tester.pump(Duration.zero);

      // Assert
      verify(mockStreamService.updateUserTeam('crew-123')).called(1);
      verify(mockStreamService.updateUserTeam('crew-456')).called(1);
      // Total should be 2 calls (not 3)
      verifyNever(mockStreamService.updateUserTeam(any)).called(3);
    });

    test('should not call updateUserTeam when crew is null', () async {
      // Arrange
      when(mockStreamService.updateUserTeam(any))
          .thenAnswer((_) async {});

      // Act - Set crew to null
      container.read(selectedCrewProvider.notifier).setCrew(null);

      // Wait for async operations
      await Future.delayed(Duration.zero);

      // Assert - No update should be called
      verifyNever(mockStreamService.updateUserTeam(any));
    });

    test('should handle updateUserTeam errors gracefully', () async {
      // Arrange
      when(mockStreamService.updateUserTeam(any))
          .thenThrow(Exception('Failed to update team'));

      // Act
      container.read(selectedCrewProvider.notifier).setCrew(testCrew1);

      // Wait for async operations
      await Future.delayed(Duration.zero);

      // Assert - Exception should not be thrown
      verify(mockStreamService.updateUserTeam('crew-123')).called(1);
    });

    testWidgets('should update team assignment when navigating to crew chat', (tester) async {
      // This test would require more complex setup to test the _navigateToCrewChat method
      // It would need mocking of streamChatClientProvider and navigation
      // For now, we'll just verify the call is made

      when(mockStreamService.updateUserTeam(any))
          .thenAnswer((_) async {});

      // Build TailboardScreen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      // Initial state - no crew selected
      expect(container.read(selectedCrewProvider), isNull);

      // Select a crew
      container.read(selectedCrewProvider.notifier).setCrew(testCrew1);
      await tester.pump();
      await tester.pump(Duration.zero);

      // Verify team update was called
      verify(mockStreamService.updateUserTeam('crew-123')).called(1);
    });
  });
}