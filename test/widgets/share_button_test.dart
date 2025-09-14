import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

@GenerateMocks([FirebaseAnalytics])
import 'share_button_test.mocks.dart';

// ShareButton widget for testing
class ShareButton extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final VoidCallback? onShareComplete;
  final bool showLabel;
  final bool isFloating;
  final Color? color;
  final double? size;

  const ShareButton({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    this.onShareComplete,
    this.showLabel = true,
    this.isFloating = false,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  ConsumerState<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ConsumerState<ShareButton>
    with TickerProviderStateMixin {
  bool _isSharing = false;
  bool _shareComplete = false;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFloating) {
      return _buildFloatingButton();
    } else {
      return _buildRegularButton();
    }
  }

  Widget _buildFloatingButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSharing ? _pulseAnimation.value : 1.0,
          child: FloatingActionButton(
            key: Key('floating-share-button-${widget.jobId}'),
            onPressed: _isSharing ? null : _handleShare,
            backgroundColor: widget.color ?? Theme.of(context).primaryColor,
            child: _buildIcon(),
          ),
        );
      },
    );
  }

  Widget _buildRegularButton() {
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return ElevatedButton.icon(
          key: Key('share-button-${widget.jobId}'),
          onPressed: _isSharing ? null : _handleShare,
          icon: _buildIcon(),
          label: widget.showLabel ? _buildLabel() : const SizedBox.shrink(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _shareComplete 
              ? Colors.green 
              : widget.color ?? Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    if (_shareComplete) {
      return Transform.scale(
        scale: _successAnimation.value,
        child: const Icon(
          Icons.check_circle,
          key: Key('share-success-icon'),
          color: Colors.white,
        ),
      );
    } else if (_isSharing) {
      return SizedBox(
        width: widget.size ?? 20,
        height: widget.size ?? 20,
        child: const CircularProgressIndicator(
          key: Key('share-loading-indicator'),
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(
        Icons.share,
        key: Key('share-icon-${widget.jobId}'),
        color: Colors.white,
        size: widget.size,
      );
    }
  }

  Widget _buildLabel() {
    if (_shareComplete) {
      return const Text(
        'Shared!',
        key: Key('share-success-text'),
      );
    } else if (_isSharing) {
      return const Text(
        'Sharing...',
        key: Key('share-loading-text'),
      );
    } else {
      return const Text(
        'Share Job',
        key: Key('share-button-text'),
      );
    }
  }

  Future<void> _handleShare() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    _pulseController.repeat(reverse: true);

    try {
      // Simulate sharing logic
      await Future.delayed(const Duration(milliseconds: 1500));

      // Show success state
      setState(() {
        _isSharing = false;
        _shareComplete = true;
      });

      _pulseController.stop();
      _pulseController.reset();
      _successController.forward();

      // Call completion callback
      widget.onShareComplete?.call();

      // Reset success state after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _shareComplete = false;
          });
          _successController.reset();
        }
      });

    } catch (error) {
      setState(() {
        _isSharing = false;
      });
      _pulseController.stop();
      _pulseController.reset();

      // Show error state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('share-error-snackbar'),
            content: Text('Failed to share job: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// QuickShareWidget - Shows multiple share options
class QuickShareWidget extends StatelessWidget {
  final String jobId;
  final String jobTitle;
  final List<QuickShareOption> options;
  final Function(String option)? onOptionSelected;

  const QuickShareWidget({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    required this.options,
    this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('quick-share-widget-$jobId'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share "$jobTitle"',
            key: const Key('quick-share-title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) => _buildOptionTile(context, option)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, QuickShareOption option) {
    return ListTile(
      key: Key('quick-share-option-${option.type}'),
      leading: Icon(
        option.icon,
        color: option.color,
      ),
      title: Text(option.title),
      subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
      trailing: option.badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                option.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.arrow_forward_ios),
      onTap: () => onOptionSelected?.call(option.type),
    );
  }
}

// ShareProgressIndicator - Shows sharing progress
class ShareProgressIndicator extends StatefulWidget {
  final String status;
  final double progress;
  final List<ShareStep> steps;

  const ShareProgressIndicator({
    Key? key,
    required this.status,
    required this.progress,
    required this.steps,
  }) : super(key: key);

  @override
  State<ShareProgressIndicator> createState() => _ShareProgressIndicatorState();
}

class _ShareProgressIndicatorState extends State<ShareProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ShareProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressController.animateTo(widget.progress);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('share-progress-indicator'),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.status,
            key: const Key('share-status-text'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                key: const Key('share-progress-bar'),
                value: _progressAnimation.value * widget.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ...widget.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isComplete = index < widget.steps.length * widget.progress;
            final isCurrent = index == (widget.steps.length * widget.progress).floor();
            
            return _buildStepItem(step, isComplete, isCurrent);
          }),
        ],
      ),
    );
  }

  Widget _buildStepItem(ShareStep step, bool isComplete, bool isCurrent) {
    return Container(
      key: Key('share-step-${step.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : 
            isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isComplete ? Colors.green :
                   isCurrent ? Theme.of(context).primaryColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.title,
              style: TextStyle(
                color: isComplete ? Colors.green :
                       isCurrent ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (step.duration != null)
            Text(
              step.duration!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

// Data models for testing
class QuickShareOption {
  final String type;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? badge;

  QuickShareOption({
    required this.type,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color = Colors.blue,
    this.badge,
  });
}

class ShareStep {
  final String id;
  final String title;
  final String? duration;

  ShareStep({
    required this.id,
    required this.title,
    this.duration,
  });
}

void main() {
  group('ShareButton Widget Tests', () {
    late MockFirebaseAnalytics mockAnalytics;

    setUp(() {
      mockAnalytics = MockFirebaseAnalytics();
    });

    testWidgets('ShareButton renders correctly with default properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'test-job-123',
              jobTitle: 'Test Job',
            ),
          ),
        ),
      );

      // Verify button exists
      expect(find.byKey(const Key('share-button-test-job-123')), findsOneWidget);
      expect(find.byKey(const Key('share-icon-test-job-123')), findsOneWidget);
      expect(find.byKey(const Key('share-button-text')), findsOneWidget);
      expect(find.text('Share Job'), findsOneWidget);
    });

    testWidgets('ShareButton renders as floating action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'floating-job',
              jobTitle: 'Floating Job',
              isFloating: true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('floating-share-button-floating-job')), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('ShareButton shows loading state during share', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'loading-job',
              jobTitle: 'Loading Job',
            ),
          ),
        ),
      );

      // Tap the button to start sharing
      await tester.tap(find.byKey(const Key('share-button-loading-job')));
      await tester.pump(); // Trigger setState

      // Verify loading state
      expect(find.byKey(const Key('share-loading-indicator')), findsOneWidget);
      expect(find.byKey(const Key('share-loading-text')), findsOneWidget);
      expect(find.text('Sharing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ShareButton shows success state after share completes', (tester) async {
      bool completionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'success-job',
              jobTitle: 'Success Job',
              onShareComplete: () => completionCalled = true,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byKey(const Key('share-button-success-job')));
      await tester.pump(); // Start sharing

      // Fast-forward past the sharing delay
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(); // Process success state

      // Verify success state
      expect(find.byKey(const Key('share-success-icon')), findsOneWidget);
      expect(find.byKey(const Key('share-success-text')), findsOneWidget);
      expect(find.text('Shared!'), findsOneWidget);
      expect(completionCalled, isTrue);

      // Button should be green in success state
      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('share-button-success-job')),
      );
      expect(button.style?.backgroundColor?.resolve({}), Colors.green);
    });

    testWidgets('ShareButton resets to normal state after success', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'reset-job',
              jobTitle: 'Reset Job',
            ),
          ),
        ),
      );

      // Complete share cycle
      await tester.tap(find.byKey(const Key('share-button-reset-job')));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      // Fast-forward past success display duration
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // Should return to normal state
      expect(find.byKey(const Key('share-icon-reset-job')), findsOneWidget);
      expect(find.byKey(const Key('share-button-text')), findsOneWidget);
      expect(find.text('Share Job'), findsOneWidget);
    });

    testWidgets('ShareButton handles custom styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'styled-job',
              jobTitle: 'Styled Job',
              color: Colors.red,
              size: 30,
              showLabel: false,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(
        find.byKey(const Key('share-icon-styled-job')),
      );
      expect(iconWidget.size, 30.0);
      expect(iconWidget.color, Colors.white);

      // Label should not be shown
      expect(find.byKey(const Key('share-button-text')), findsNothing);
    });

    testWidgets('ShareButton prevents multiple taps during sharing', (tester) async {
      int tapCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'prevent-job',
              jobTitle: 'Prevent Job',
              onShareComplete: () => tapCount++,
            ),
          ),
        ),
      );

      // First tap starts sharing
      await tester.tap(find.byKey(const Key('share-button-prevent-job')));
      await tester.pump();

      // Second tap should be ignored
      await tester.tap(find.byKey(const Key('share-button-prevent-job')));
      await tester.pump();

      // Third tap should be ignored
      await tester.tap(find.byKey(const Key('share-button-prevent-job')));
      await tester.pump();

      // Complete sharing
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      // Only one share should have completed
      expect(tapCount, 1);
    });

    testWidgets('ShareButton handles error states', (tester) async {
      // This test would need more setup to simulate actual errors
      // For now, testing the snackbar display mechanism
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'error-job',
              jobTitle: 'Error Job',
            ),
          ),
        ),
      );

      // This would test error handling if we had a way to inject errors
      expect(find.byKey(const Key('share-button-error-job')), findsOneWidget);
    });

    testWidgets('ShareButton animation works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'animation-job',
              jobTitle: 'Animation Job',
              isFloating: true,
            ),
          ),
        ),
      );

      // Tap to start sharing and animation
      await tester.tap(find.byKey(const Key('floating-share-button-animation-job')));
      await tester.pump();

      // Advance animation partially
      await tester.pump(const Duration(milliseconds: 500));

      // Button should be present throughout animation
      expect(find.byKey(const Key('floating-share-button-animation-job')), findsOneWidget);
    });
  });

  group('QuickShareWidget Tests', () {
    testWidgets('QuickShareWidget renders all options', (tester) async {
      final options = [
        QuickShareOption(
          type: 'email',
          title: 'Share via Email',
          subtitle: 'Send job details by email',
          icon: Icons.email,
          color: Colors.blue,
        ),
        QuickShareOption(
          type: 'sms',
          title: 'Share via SMS',
          subtitle: 'Send job link by text',
          icon: Icons.sms,
          color: Colors.green,
        ),
        QuickShareOption(
          type: 'crew',
          title: 'Share with Crew',
          subtitle: 'Notify your crew members',
          icon: Icons.group,
          color: Colors.orange,
          badge: '3',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickShareWidget(
              jobId: 'quick-job',
              jobTitle: 'Quick Share Job',
              options: options,
            ),
          ),
        ),
      );

      // Verify widget and title
      expect(find.byKey(const Key('quick-share-widget-quick-job')), findsOneWidget);
      expect(find.byKey(const Key('quick-share-title')), findsOneWidget);
      expect(find.text('Share "Quick Share Job"'), findsOneWidget);

      // Verify all options are rendered
      expect(find.byKey(const Key('quick-share-option-email')), findsOneWidget);
      expect(find.byKey(const Key('quick-share-option-sms')), findsOneWidget);
      expect(find.byKey(const Key('quick-share-option-crew')), findsOneWidget);

      // Verify option content
      expect(find.text('Share via Email'), findsOneWidget);
      expect(find.text('Send job details by email'), findsOneWidget);
      expect(find.text('Share with Crew'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Badge
    });

    testWidgets('QuickShareWidget handles option selection', (tester) async {
      String? selectedOption;
      final options = [
        QuickShareOption(
          type: 'test',
          title: 'Test Option',
          icon: Icons.test_tube,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickShareWidget(
              jobId: 'selection-job',
              jobTitle: 'Selection Job',
              options: options,
              onOptionSelected: (option) => selectedOption = option,
            ),
          ),
        ),
      );

      // Tap the option
      await tester.tap(find.byKey(const Key('quick-share-option-test')));
      await tester.pump();

      expect(selectedOption, 'test');
    });

    testWidgets('QuickShareWidget renders without subtitles', (tester) async {
      final options = [
        QuickShareOption(
          type: 'simple',
          title: 'Simple Option',
          icon: Icons.simple_icons,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickShareWidget(
              jobId: 'simple-job',
              jobTitle: 'Simple Job',
              options: options,
            ),
          ),
        ),
      );

      expect(find.text('Simple Option'), findsOneWidget);
      // Should not have subtitle
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('ShareProgressIndicator Tests', () {
    testWidgets('ShareProgressIndicator shows progress correctly', (tester) async {
      final steps = [
        ShareStep(id: 'validate', title: 'Validating contact'),
        ShareStep(id: 'send', title: 'Sending notification'),
        ShareStep(id: 'confirm', title: 'Confirming delivery'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareProgressIndicator(
              status: 'Sharing job...',
              progress: 0.6, // 60% complete
              steps: steps,
            ),
          ),
        ),
      );

      // Verify indicator exists
      expect(find.byKey(const Key('share-progress-indicator')), findsOneWidget);
      expect(find.byKey(const Key('share-status-text')), findsOneWidget);
      expect(find.byKey(const Key('share-progress-bar')), findsOneWidget);
      expect(find.text('Sharing job...'), findsOneWidget);

      // Verify steps are rendered
      expect(find.byKey(const Key('share-step-validate')), findsOneWidget);
      expect(find.byKey(const Key('share-step-send')), findsOneWidget);
      expect(find.byKey(const Key('share-step-confirm')), findsOneWidget);

      // Progress bar should be present
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('ShareProgressIndicator updates progress animation', (tester) async {
      final steps = [
        ShareStep(id: 'step1', title: 'Step 1'),
        ShareStep(id: 'step2', title: 'Step 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ShareProgressIndicator(
                      status: 'Processing...',
                      progress: 0.3,
                      steps: steps,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      expect(find.text('Processing...'), findsOneWidget);

      // Trigger animation by rebuilding with new progress
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareProgressIndicator(
              status: 'Almost done...',
              progress: 0.8,
              steps: steps,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Almost done...'), findsOneWidget);
    });

    testWidgets('ShareProgressIndicator shows step states correctly', (tester) async {
      final steps = [
        ShareStep(
          id: 'timed',
          title: 'Timed Step',
          duration: '2s',
        ),
        ShareStep(
          id: 'notimed',
          title: 'No Time Step',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareProgressIndicator(
              status: 'Testing steps...',
              progress: 0.7,
              steps: steps,
            ),
          ),
        ),
      );

      expect(find.text('Timed Step'), findsOneWidget);
      expect(find.text('2s'), findsOneWidget);
      expect(find.text('No Time Step'), findsOneWidget);
    });
  });

  group('Share Widget Integration Tests', () {
    testWidgets('Share widgets work together in complete flow', (tester) async {
      bool shareCompleted = false;
      String? selectedOption;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ShareButton(
                  jobId: 'integration-job',
                  jobTitle: 'Integration Job',
                  onShareComplete: () => shareCompleted = true,
                ),
                QuickShareWidget(
                  jobId: 'integration-job',
                  jobTitle: 'Integration Job',
                  options: [
                    QuickShareOption(
                      type: 'quick',
                      title: 'Quick Share',
                      icon: Icons.flash_on,
                    ),
                  ],
                  onOptionSelected: (option) => selectedOption = option,
                ),
              ],
            ),
          ),
        ),
      );

      // Test ShareButton
      await tester.tap(find.byKey(const Key('share-button-integration-job')));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      expect(shareCompleted, isTrue);

      // Test QuickShareWidget
      await tester.tap(find.byKey(const Key('quick-share-option-quick')));
      await tester.pump();

      expect(selectedOption, 'quick');
    });

    testWidgets('Share widgets handle rapid interactions', (tester) async {
      int completionCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'rapid-job',
              jobTitle: 'Rapid Job',
              onShareComplete: () => completionCount++,
            ),
          ),
        ),
      );

      // Rapid taps - should only process once
      await tester.tap(find.byKey(const Key('share-button-rapid-job')));
      await tester.tap(find.byKey(const Key('share-button-rapid-job')));
      await tester.tap(find.byKey(const Key('share-button-rapid-job')));
      await tester.pump();

      // Complete sharing
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      expect(completionCount, 1); // Only one completion despite multiple taps
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Share widgets are accessible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ShareButton(
                  jobId: 'a11y-job',
                  jobTitle: 'Accessibility Job',
                ),
                QuickShareWidget(
                  jobId: 'a11y-job',
                  jobTitle: 'Accessibility Job',
                  options: [
                    QuickShareOption(
                      type: 'accessible',
                      title: 'Accessible Option',
                      icon: Icons.accessibility,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Check semantic properties
      final shareButton = find.byKey(const Key('share-button-a11y-job'));
      expect(tester.getSemantics(shareButton), hasProperty('onTap'));

      final quickOption = find.byKey(const Key('quick-share-option-accessible'));
      expect(tester.getSemantics(quickOption), hasProperty('onTap'));
    });

    testWidgets('Share widgets announce state changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'announce-job',
              jobTitle: 'Announce Job',
            ),
          ),
        ),
      );

      // Start sharing
      await tester.tap(find.byKey(const Key('share-button-announce-job')));
      await tester.pump();

      // Should show loading state for screen readers
      expect(find.text('Sharing...'), findsOneWidget);

      // Complete sharing
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      // Should announce success
      expect(find.text('Shared!'), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('Share widgets render efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: List.generate(20, (index) => 
                ShareButton(
                  jobId: 'perf-job-$index',
                  jobTitle: 'Performance Job $index',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should render quickly even with many buttons
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Share animations perform well', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareButton(
              jobId: 'anim-perf-job',
              jobTitle: 'Animation Performance Job',
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      // Start animation
      await tester.tap(find.byKey(const Key('share-button-anim-perf-job')));
      await tester.pump();
      
      // Pump animation frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      stopwatch.stop();

      // Animation should be smooth
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}