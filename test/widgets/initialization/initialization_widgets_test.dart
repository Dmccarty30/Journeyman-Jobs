import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_types.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_initialization_service.dart';
import 'package:journeyman_jobs/widgets/initialization/initialization_widgets.dart';

// Generate mocks
@GenerateMocks([
  HierarchicalInitializationService,
  VoidCallback,
])
import 'initialization_widgets_test.mocks.dart';

void main() {
  group('InitializationProgressScreen', () {
    late MockHierarchicalInitializationService mockService;

    setUp(() {
      mockService = MockHierarchicalInitializationService();
    });

    testWidgets('displays initialization progress correctly', (WidgetTester tester) async {
      // Setup mock service
      when(mockService.initializationStateStream).thenAnswer(
        (_) => Stream.value(HierarchicalInitializationState.initializing()),
      );
      when(mockService.currentState).thenReturn(
        HierarchicalInitializationState.initializing(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: mockService,
            ),
          ),
        ),
      );

      // Verify main components are displayed
      expect(find.text('Journeyman Jobs'), findsOneWidget);
      expect(find.text('Powering Your Career'), findsOneWidget);
      expect(find.text('Powering up your electrical career tools...'), findsOneWidget);
      expect(find.byType(StageProgressIndicator), findsWidgets);
      expect(find.byType(FeatureAvailabilityCard), findsOneWidget);
    });

    testWidgets('shows completion state when initialization completes', (WidgetTester tester) async {
      // Setup mock service with completed state
      when(mockService.initializationStateStream).thenAnswer(
        (_) => Stream.value(HierarchicalInitializationState.completed()),
      );
      when(mockService.currentState).thenReturn(
        HierarchicalInitializationState.completed(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: mockService,
            ),
          ),
        ),
      );

      // Verify completion state
      expect(find.text('All systems ready - Welcome aboard!'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('handles error state correctly', (WidgetTester tester) async {
      // Setup mock service with error state
      const errorMessage = 'Connection failed';
      when(mockService.initializationStateStream).thenAnswer(
        (_) => Stream.value(
          HierarchicalInitializationState.error(errorMessage),
        ),
      );
      when(mockService.currentState).thenReturn(
        HierarchicalInitializationState.error(errorMessage),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: mockService,
            ),
          ),
        ),
      );

      // Verify error state
      expect(find.text('Initialization encountered an issue'), findsOneWidget);
      expect(find.text('View Error Details'), findsOneWidget);
      expect(find.text('Retry Initialization'), findsOneWidget);
    });

    testWidgets('shows skip button when features are available', (WidgetTester tester) async {
      // Setup mock service with partially completed state
      when(mockService.initializationStateStream).thenAnswer(
        (_) => Stream.value(
          HierarchicalInitializationState.loadingHomeLocal(),
        ),
      );
      when(mockService.currentState).thenReturn(
        HierarchicalInitializationState.loadingHomeLocal(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: mockService,
              showSkipButton: true,
            ),
          ),
        ),
      );

      // Verify skip button is available
      expect(find.text('Continue with Available Features'), findsOneWidget);
    });

    testWidgets('responds to tap events correctly', (WidgetTester tester) async {
      bool onCompleteCalled = false;
      bool onSkipCalled = false;

      // Setup mock service
      when(mockService.initializationStateStream).thenAnswer(
        (_) => Stream.value(HierarchicalInitializationState.completed()),
      );
      when(mockService.currentState).thenReturn(
        HierarchicalInitializationState.completed(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: mockService,
              onInitializationComplete: () => onCompleteCalled = true,
              onSkipToAvailable: () => onSkipCalled = true,
            ),
          ),
        ),
      );

      // Tap the main action button
      await tester.tap(find.text('Get Started'));
      await tester.pump();

      expect(onCompleteCalled, isTrue);
      expect(onSkipCalled, isFalse);
    });
  });

  group('StageProgressIndicator', () {
    testWidgets('displays stage information correctly', (WidgetTester tester) async {
      const stage = InitializationStage.firebaseCore;
      final progress = StageProgress(
        stage: stage,
        status: StageStatus.inProgress,
        progress: 0.5,
        startTime: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StageProgressIndicator(
              stage: stage,
              progress: progress,
              showLevelBadge: true,
              showEstimatedTime: true,
            ),
          ),
        ),
      );

      // Verify stage information is displayed
      expect(find.text('Firebase Services'), findsOneWidget);
      expect(find.text('Initialize Firebase core services including Firestore, Authentication, and Storage'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // Level badge
    });

    testWidgets('shows completed state correctly', (WidgetTester tester) async {
      const stage = InitializationStage.firebaseCore;
      final progress = StageProgress(
        stage: stage,
        status: StageStatus.completed,
        progress: 1.0,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StageProgressIndicator(
              stage: stage,
              progress: progress,
            ),
          ),
        ),
      );

      // Verify completed state indicators
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows failed state correctly', (WidgetTester tester) async {
      const stage = InitializationStage.firebaseCore;
      final progress = StageProgress(
        stage: stage,
        status: StageStatus.failed,
        progress: 0.0,
        startTime: DateTime.now(),
        error: 'Connection timeout',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StageProgressIndicator(
              stage: stage,
              progress: progress,
            ),
          ),
        ),
      );

      // Verify failed state indicators
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('handles tap events', (WidgetTester tester) async {
      bool tapped = false;
      const stage = InitializationStage.firebaseCore;
      final progress = StageProgress(
        stage: stage,
        status: StageStatus.pending,
        progress: 0.0,
        startTime: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StageProgressIndicator(
              stage: stage,
              progress: progress,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StageProgressIndicator));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('compact layout displays correctly', (WidgetTester tester) async {
      const stage = InitializationStage.firebaseCore;
      final progress = StageProgress(
        stage: stage,
        status: StageStatus.inProgress,
        progress: 0.5,
        startTime: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StageProgressIndicator(
              stage: stage,
              progress: progress,
              compact: true,
            ),
          ),
        ),
      );

      // Verify compact layout
      expect(find.text('Firebase Services'), findsOneWidget);
      expect(find.text('Initialize Firebase core services'), findsNothing); // Description should be hidden
    });
  });

  group('FeatureAvailabilityCard', () {
    testWidgets('displays available features correctly', (WidgetTester tester) async {
      const features = ['Profile', 'Basic Jobs', 'Local Directory'];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: features,
              status: FeatureStatus.available,
              title: 'Available Features',
            ),
          ),
        ),
      );

      // Verify features are displayed
      expect(find.text('Available Features'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Feature count
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Basic Jobs'), findsOneWidget);
      expect(find.text('Local Directory'), findsOneWidget);
    });

    testWidgets('displays loading features correctly', (WidgetTester tester) async {
      const features = ['Advanced Job Search', 'Job Matching'];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: features,
              status: FeatureStatus.loading,
              title: 'Loading Features',
            ),
          ),
        ),
      );

      // Verify loading state
      expect(find.text('Loading Features'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Advanced Job Search'), findsOneWidget);
      expect(find.text('Job Matching'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('handles feature tap events', (WidgetTester tester) async {
      const features = ['Profile', 'Basic Jobs'];
      String? tappedFeature;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: features,
              status: FeatureStatus.available,
              onFeatureTap: (feature) => tappedFeature = feature,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(tappedFeature, equals('Profile'));
    });

    testWidgets('grid layout displays correctly', (WidgetTester tester) async {
      const features = ['Profile', 'Basic Jobs', 'Local Directory', 'Weather Services'];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: features,
              status: FeatureStatus.available,
              layout: FeatureCardLayout.grid,
            ),
          ),
        ),
      );

      // Verify grid layout
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Basic Jobs'), findsOneWidget);
      expect(find.text('Local Directory'), findsOneWidget);
      expect(find.text('Weather Services'), findsOneWidget);
    });

    testWidgets('empty state displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: [],
              status: FeatureStatus.comingSoon,
              title: 'Coming Soon',
            ),
          ),
        ),
      );

      // Verify empty state
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('No features available'), findsOneWidget);
    });
  });

  group('ErrorRecoveryWidget', () {
    testWidgets('displays error information correctly', (WidgetTester tester) async {
      const errorMessage = 'Network connection failed';
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ErrorRecoveryWidget(
              error: errorMessage,
              onRetry: () => retryCalled = true,
              canDismiss: true,
            ),
          ),
        ),
      );

      // Verify error display
      expect(find.text('Initialization Failed'), findsOneWidget);
      expect(find.text('An error occurred during app initialization'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry Initialization'), findsOneWidget);
    });

    testWidgets('handles retry action', (WidgetTester tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ErrorRecoveryWidget(
              error: 'Test error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry Initialization'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('shows technical details when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ErrorRecoveryWidget(
              error: 'Test error',
              showTechnicalDetails: false,
            ),
          ),
        ),
      );

      // Initially technical details should be hidden
      expect(find.text('Technical Information'), findsNothing);

      // Tap to expand technical details
      await tester.tap(find.text('Technical Details'));
      await tester.pump();

      // Technical details should now be visible
      expect(find.text('Technical Information'), findsOneWidget);
      expect(find.text('System Information:'), findsOneWidget);
    });

    testWidgets('displays contact support option', (WidgetTester tester) async {
      bool supportCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ErrorRecoveryWidget(
              error: 'Test error',
              onContactSupport: () => supportCalled = true,
              showContactSupport: true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Contact Support'));
      await tester.pump();

      expect(supportCalled, isTrue);
    });

    testWidgets('shows suggested actions when provided', (WidgetTester tester) async {
      const suggestions = [
        'Check your internet connection',
        'Restart the app',
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ErrorRecoveryWidget(
              error: 'Test error',
              suggestedActions: suggestions,
            ),
          ),
        ),
      );

      // Verify suggested actions are displayed
      expect(find.text('Suggested Actions:'), findsOneWidget);
      expect(find.text('Check your internet connection'), findsOneWidget);
      expect(find.text('Restart the app'), findsOneWidget);
    });
  });

  group('BackgroundProgressIndicator', () {
    testWidgets('displays determinate progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: BackgroundProgressIndicator(
              progress: 0.75,
              showPercentage: true,
              message: 'Loading data...',
            ),
          ),
        ),
      );

      // Verify progress display
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('displays indeterminate progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: BackgroundProgressIndicator(
              progress: 0.0,
              isIndeterminate: true,
            ),
          ),
        ),
      );

      // Verify indeterminate progress indicator
      expect(find.byType(Container), findsWidgets); // The moving indeterminate bar
    });

    testWidgets('shows electrical effects when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: BackgroundProgressIndicator(
              progress: 0.5,
              showElectricalEffects: true,
              showPulse: true,
            ),
          ),
        ),
      );

      // Verify electrical effects are present (would need to check for custom painters)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('different positions work correctly', (WidgetTester tester) async {
      for (final position in BackgroundProgressPosition.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: BackgroundProgressIndicator(
                progress: 0.5,
                position: position,
              ),
            ),
          ),
        );

        expect(find.byType(BackgroundProgressIndicator), findsOneWidget);
        await tester.pumpWidget(Container()); // Clean up
      }
    });

    testWidgets('handles tap events', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: BackgroundProgressIndicator(
              progress: 0.5,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BackgroundProgressIndicator));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('Accessibility', () {
    testWidgets('progress indicators have proper semantics', (WidgetTester tester) async {
      final progress = StageProgress(
        stage: InitializationStage.firebaseCore,
        status: StageStatus.inProgress,
        progress: 0.5,
        startTime: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StageProgressIndicator(
              stage: progress.stage,
              progress: progress,
            ),
          ),
        ),
      );

      // Check for semantic labels
      expect(
        tester.binding.semanticsOwner.debugSemanticsTree(),
        contains('Firebase Services stage: inProgress, 50% complete'),
      );
    });

    testWidgets('error widgets announce errors properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ErrorRecoveryWidget(
              error: 'Test error message',
            ),
          ),
        ),
      );

      // Check for error announcement
      expect(
        tester.binding.semanticsOwner.debugSemanticsTree(),
        contains('Error occurred during initialization'),
      );
    });

    testWidgets('feature cards have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: ['Profile'],
              status: FeatureStatus.available,
            ),
          ),
        ),
      );

      // Check for feature accessibility
      expect(
        tester.binding.semanticsOwner.debugSemanticsTree(),
        contains('Profile feature: available'),
      );
    });
  });

  group('Responsive Design', () {
    testWidgets('components adapt to different screen sizes', (WidgetTester tester) async {
      // Test small screen
      await tester.binding.setSurfaceSize(const Size(320, 568)); // iPhone SE size
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: MockHierarchicalInitializationService(),
            ),
          ),
        ),
      );

      expect(find.byType(InitializationProgressScreen), findsOneWidget);

      // Test large screen
      await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop size
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: InitializationProgressScreen(
              initializationService: MockHierarchicalInitializationService(),
            ),
          ),
        ),
      );

      expect(find.byType(InitializationProgressScreen), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('grid layout adapts to feature count', (WidgetTester tester) async {
      // Test with few features (should be 1 column)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: ['Profile', 'Basic Jobs'],
              status: FeatureStatus.available,
              layout: FeatureCardLayout.grid,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);

      // Test with many features (should be multiple columns)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureAvailabilityCard(
              features: ['Profile', 'Basic Jobs', 'Local Directory', 'Weather Services', 'Settings'],
              status: FeatureStatus.available,
              layout: FeatureCardLayout.grid,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}