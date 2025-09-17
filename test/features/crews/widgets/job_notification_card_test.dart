import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:journeyman_jobs/features/crews/widgets/job_notification_card.dart';
import 'package:journeyman_jobs/features/crews/models/job_notification.dart';
import 'package:journeyman_jobs/features/crews/models/crew_enums.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

void main() {
  group('JobNotificationCard Widget Tests', () {
    late JobModel mockJob;
    late JobNotification mockNotification;
    late JobNotification priorityNotification;
    late JobNotification expiredNotification;

    setUp(() {
      mockJob = const JobModel(
        id: 'job1',
        company: 'ABC Electric',
        location: 'Chicago, IL',
        classification: 'Inside Wireman',
        jobTitle: 'Commercial Electrician',
        wage: 45.50,
        hours: 40,
        local: 134,
      );

      mockNotification = JobNotification(
        id: 'notif1',
        jobId: 'job1',
        crewId: 'crew1',
        sharedByUserId: 'user1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        memberResponses: {
          'user2': MemberResponse(
            userId: 'user2',
            type: ResponseType.accepted,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          'user3': MemberResponse(
            userId: 'user3',
            type: ResponseType.pending,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        },
        groupBidStatus: GroupBidStatus.draft,
        isPriority: false,
        viewCount: 5,
        responseCount: 1,
        appliedMembers: [],
        message: 'Great opportunity for overtime work!',
        expiresAt: DateTime.now().add(const Duration(days: 3)),
      );

      priorityNotification = mockNotification.copyWith(
        id: 'notif2',
        isPriority: true,
        message: 'URGENT: Storm restoration work available',
      );

      expiredNotification = mockNotification.copyWith(
        id: 'notif3',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
    });

    testWidgets('displays basic job notification information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: false,
              ),
            ),
          ),
        ),
      );

      // Check job title
      expect(find.text('Commercial Electrician'), findsOneWidget);
      
      // Check location
      expect(find.text('Chicago, IL'), findsOneWidget);
      
      // Check wage
      expect(find.text('\$45.50/hr'), findsOneWidget);
      
      // Check hours
      expect(find.text('40h/week'), findsOneWidget);
      
      // Check local
      expect(find.text('Local 134'), findsOneWidget);
      
      // Check classification badge
      expect(find.text('INSIDE WIREMAN'), findsOneWidget);
      
      // Check shared message
      expect(find.text('Great opportunity for overtime work!'), findsOneWidget);
    });

    testWidgets('shows unread notification styling', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: false,
              ),
            ),
          ),
        ),
      );

      // Should have copper border for unread
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side.color, AppTheme.accentCopper);
    });

    testWidgets('shows priority notification styling', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: priorityNotification,
                job: mockJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Check for urgent indicator
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      
      // Should have red border for priority
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side.color, AppTheme.errorRed);
      
      // Check priority message
      expect(find.text('URGENT: Storm restoration work available'), findsOneWidget);
    });

    testWidgets('shows expired notification state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: expiredNotification,
                job: mockJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Check for expired text
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('This job opportunity has expired'), findsOneWidget);
      
      // Apply button should not be present
      expect(find.text('Apply'), findsNothing);
    });

    testWidgets('displays member response summary', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Check response summary
      expect(find.text('1/2 interested'), findsOneWidget);
      expect(find.text('(1 pending)'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('shows action buttons when not expired', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Check for action buttons
      expect(find.text('Apply'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('triggers callbacks when buttons are tapped', (tester) async {
      bool applyTapped = false;
      bool shareTapped = false;
      bool cardTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: true,
                onApply: () => applyTapped = true,
                onShare: () => shareTapped = true,
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        ),
      );

      // Tap Apply button
      await tester.tap(find.text('Apply'));
      await tester.pump();
      expect(applyTapped, isTrue);

      // Tap Share button
      await tester.tap(find.text('Share'));
      await tester.pump();
      expect(shareTapped, isTrue);

      // Tap card (outside buttons)
      await tester.tap(find.byType(JobNotificationCard));
      await tester.pump();
      expect(cardTapped, isTrue);
    });

    testWidgets('shows popup menu options', (tester) async {
      bool detailsTapped = false;
      bool discussTapped = false;
      bool saveTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: true,
                onViewDetails: () => detailsTapped = true,
                onDiscuss: () => discussTapped = true,
                onSave: () => saveTapped = true,
              ),
            ),
          ),
        ),
      );

      // Tap more options
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Check menu items
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Discuss'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Tap View Details
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();
      expect(detailsTapped, isTrue);
    });

    testWidgets('handles different job classifications correctly', (tester) async {
      final lineJob = mockJob.copyWith(classification: 'Journeyman Lineman');
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: lineJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Check for lineman classification badge
      expect(find.text('JOURNEYMAN LINEMAN'), findsOneWidget);
    });

    testWidgets('handles job without optional fields', (tester) async {
      final minimalJob = const Job(
        id: 'job2',
        company: 'XYZ Corp',
        location: 'Detroit, MI',
      );
      
      final minimalNotification = mockNotification.copyWith(
        message: null,
        expiresAt: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: minimalNotification,
                job: minimalJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Should display company name as fallback
      expect(find.text('XYZ Corp'), findsOneWidget);
      expect(find.text('Detroit, MI'), findsOneWidget);
      
      // Should not display optional fields
      expect(find.text('Local'), findsNothing);
      expect(find.textContaining('\$'), findsNothing);
    });

    testWidgets('shows expiration warning for jobs expiring soon', (tester) async {
      final expiringSoonNotification = mockNotification.copyWith(
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: expiringSoonNotification,
                job: mockJob,
                isRead: true,
              ),
            ),
          ),
        ),
      );

      // Check for schedule icon (expiration indicator)
      expect(find.byIcon(Icons.schedule), findsWidgets);
    });

    testWidgets('hides actions when showActions is false', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: JobNotificationCard(
                notification: mockNotification,
                job: mockJob,
                isRead: true,
                showActions: false,
              ),
            ),
          ),
        ),
      );

      // Action buttons should not be present
      expect(find.text('Apply'), findsNothing);
      expect(find.text('Share'), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });
  });
}
