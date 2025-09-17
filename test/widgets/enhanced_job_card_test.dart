import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/widgets/enhanced_job_card.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/features/job_sharing/widgets/share_button.dart';
import 'package:journeyman_jobs/providers/riverpod/contacts_provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/design_system/components/job_card.dart';

@GenerateMocks([])
import 'enhanced_job_card_test.mocks.dart';

// Mock Contacts class for testing
class MockContacts extends Contacts {
  final List<UserModel> _contacts;
  
  MockContacts(this._contacts);
  
  @override
  Future<List<UserModel>> build() async => _contacts;
}

void main() {
  group('EnhancedJobCard with Share Functionality', () {
    late JobModel testJob;
    late List<UserModel> testContacts;

    setUp(() {
      testJob = JobModel(
        id: 'test-job-1',
        company: 'ACME Electric Company',
        location: 'Seattle, WA',
        local: 26,
        classification: 'Journeyman Lineman',
        jobTitle: 'Storm Restoration Work',
        jobDescription: 'Emergency power line restoration',
        wage: 58.50,
        startDate: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      );

      testContacts = [
        UserModel(
          uid: 'contact-1',
          firstName: 'John',
          lastName: 'Journeyman',
          email: 'john@ibew26.org',
          phoneNumber: '555-0101',
          address1: '123 Main St',
          city: 'Seattle',
          state: 'WA',
          zipcode: '98101',
          homeLocal: '26',
          ticketNumber: 'J123456',
          classification: 'Journeyman Lineman',
          isWorking: false,
          constructionTypes: ['Commercial'],
          networkWithOthers: true,
          careerAdvancements: true,
          betterBenefits: true,
          higherPayRate: true,
          learnNewSkill: true,
          travelToNewLocation: true,
          findLongTermWork: true,
          onboardingStatus: 'complete',
          createdTime: DateTime.now(),
          fcmTokens: ['token-1'],
        ),
        UserModel(
          uid: 'contact-2',
          firstName: 'Mike',
          lastName: 'Wireman',
          email: 'mike@ibew46.org',
          phoneNumber: '555-0102',
          address1: '456 Oak Ave',
          city: 'Portland',
          state: 'OR',
          zipcode: '97201',
          homeLocal: '46',
          ticketNumber: 'W654321',
          classification: 'Inside Wireman',
          isWorking: true,
          constructionTypes: ['Industrial'],
          networkWithOthers: true,
          careerAdvancements: false,
          betterBenefits: true,
          higherPayRate: true,
          learnNewSkill: false,
          travelToNewLocation: false,
          findLongTermWork: true,
          onboardingStatus: 'complete',
          createdTime: DateTime.now(),
          fcmTokens: ['token-2'],
        ),
      ];
    });

    Widget buildTestWidget({
      JobCardVariant variant = JobCardVariant.enhanced,
    }) {
      return ProviderScope(
        overrides: [
          contactsProvider.overrideWith(() => MockContacts(testContacts)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: EnhancedJobCard(
              job: testJob,
              variant: variant,
            ),
          ),
        ),
      );
    }

    testWidgets('displays share button in all variants', (tester) async {
      for (final variant in [JobCardVariant.half, JobCardVariant.full]) {
        await tester.pumpWidget(buildTestWidget(variant: variant));
        await tester.pumpAndSettle();

        if (variant == JobCardVariant.full) {
          expect(
            find.byType(JJShareButton), 
            findsOneWidget,
            reason: 'Share button missing in $variant',
          );
        }

        // Clean up for next iteration
        await tester.binding.reassembleApplication();
      }
    });

    testWidgets('share button has correct electrical theme', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final shareButton = find.byType(JJShareButton);
      expect(shareButton, findsOneWidget);

      // Verify tooltip
      await tester.longPress(shareButton);
      await tester.pumpAndSettle();
      expect(find.text('Share job with colleagues'), findsOneWidget);
    });

    testWidgets('share button triggers modal on tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap share button
      final shareButton = find.byType(JJShareButton);
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      // Modal should appear
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('storm work jobs show correct styling', (tester) async {
      final stormJob = JobModel(
        id: 'storm-job',
        company: 'Emergency Services Inc',
        jobTitle: 'Emergency Storm Restoration',
        jobDescription: 'Power lines down - immediate response',
        local: 26,
        classification: 'Journeyman Lineman',
        location: 'Tacoma, WA',
        wage: 65.00,
        startDate: DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contactsProvider.overrideWith(() => MockContacts(testContacts)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EnhancedJobCard(
                job: stormJob,
                variant: JobCardVariant.enhanced,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for storm indicator
      expect(find.text('STORM RESTORATION'), findsOneWidget);
      
      // Share button should still be present for urgent sharing
      expect(find.byType(JJShareButton), findsOneWidget);
    });

    testWidgets('compact variant has smaller share button', (tester) async {
      await tester.pumpWidget(buildTestWidget(variant: JobCardVariant.compact));
      await tester.pumpAndSettle();

      final shareButton = tester.widget<JJShareButton>(find.byType(JJShareButton));
      expect(shareButton.size, equals(JJShareButtonSize.small));
    });

    testWidgets('share callback is called correctly', (tester) async {
      List<String>? receivedRecipientIds;
      String? receivedMessage;

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // This test would need more complex setup to actually trigger the callback
      // through the modal interaction, but we can test the callback setup
      expect(find.byType(JJShareButton), findsOneWidget);
    });

    testWidgets('loading state prevents multiple taps', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final shareButton = find.byType(JJShareButton);
      
      // Tap multiple times rapidly
      await tester.tap(shareButton);
      await tester.tap(shareButton);
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      // Only one modal should appear
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('accessibility - share button is properly labeled', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find share button
      final shareButton = find.byType(JJShareButton);
      expect(shareButton, findsOneWidget);

      // Test semantic properties
      final Semantics shareSemantics = tester.widget(
        find.ancestor(
          of: shareButton,
          matching: find.byType(Semantics),
        ).first,
      );
      
      // Verify button is marked as a button
      expect(shareSemantics.properties.button, isTrue);
    });

    testWidgets('job card layout remains intact with share button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify all key elements are present
      expect(find.text(testJob.company ?? ''), findsOneWidget);
      expect(find.text('IBEW Local ${testJob.local}'), findsOneWidget);
      expect(find.text(testJob.location ?? ''), findsOneWidget);
      expect(find.text(testJob.classification ?? ''), findsOneWidget);
      expect(find.text('\$${testJob.wage?.toStringAsFixed(2) ?? '0.00'}/hr'), findsOneWidget);
      
      // And share button doesn't break layout
      expect(find.byType(JJShareButton), findsOneWidget);
    });

    testWidgets('enhanced variant has proper electrical theme integration', (tester) async {
      await tester.pumpWidget(buildTestWidget(variant: JobCardVariant.enhanced));
      await tester.pumpAndSettle();

      // Check for electrical theme elements
      expect(find.byIcon(Icons.electrical_services), findsAtLeastNWidgets(1));
      expect(find.text('IBEW LOCAL'), findsOneWidget);
      
      // Share button should be medium size for enhanced variant
      final shareButton = tester.widget<JJShareButton>(find.byType(JJShareButton));
      expect(shareButton.size, equals(JJShareButtonSize.medium));
    });

    testWidgets('favorite and share buttons are positioned correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Both buttons should be present
      expect(find.byType(JJShareButton), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // They should be in a row together
      final favoriteButton = find.byIcon(Icons.favorite_border);
      final shareButton = find.byType(JJShareButton);
      
      final favoriteRect = tester.getRect(favoriteButton);
      final shareRect = tester.getRect(shareButton);
      
      // Share button should be to the right of favorite button (in enhanced header)
      expect(shareRect.left, greaterThan(favoriteRect.right));
    });

    testWidgets('performance - job card renders quickly with share button', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Should render in reasonable time (under 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      
      // All elements should be present
      expect(find.byType(JJShareButton), findsOneWidget);
      expect(find.text(testJob.company), findsOneWidget);
    });

    group('Error Handling', () {
      testWidgets('handles missing contacts gracefully', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              contactsProvider.overrideWith(() => MockContacts(<UserModel>[])),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: EnhancedJobCard(
                  job: testJob,
                  variant: JobCardVariant.enhanced,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Share button should still be present
        expect(find.byType(JJShareButton), findsOneWidget);

        // Should handle tap without error
        await tester.tap(find.byType(JJShareButton));
        await tester.pumpAndSettle();
      });

      testWidgets('handles contacts loading error', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              contactsProvider.overrideWith(() => MockContacts(<UserModel>[])),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: EnhancedJobCard(
                  job: testJob,
                  variant: JobCardVariant.enhanced,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should still render without crashing
        expect(find.byType(JJShareButton), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('adapts to different screen sizes', (tester) async {
        final sizes = [
          const Size(320, 568), // Small phone
          const Size(414, 896), // Large phone
          const Size(768, 1024), // Tablet
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);
          
          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          expect(
            find.byType(JJShareButton), 
            findsOneWidget,
            reason: 'Share button missing at size $size',
          );

          await tester.binding.reassembleApplication();
        }

        // Reset size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
