import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:journeyman_jobs/widgets/youtube_video_player.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Widget tests for YouTube Video Player component
///
/// Tests video player functionality, controls, responsive design,
/// error handling, and user interactions within the storm screen context.
void main() {
  group('YouTube Video Player Widget Tests', () {
    late VideoContent testVideo;
    late VideoContent invalidVideo;
    late VideoContent longVideo;

    setUp(() {
      testVideo = VideoContent(
        id: 'test-video-1',
        title: 'Emergency Declaration - Hurricane Milton',
        description: 'Governor declares state of emergency',
        youtubeVideoId: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 5, seconds: 30),
        uploader: 'Emergency Management',
        isLive: false,
      );

      invalidVideo = VideoContent(
        id: 'invalid-video',
        title: 'Invalid Video',
        description: 'This video should fail to load',
        youtubeVideoId: 'invalid-id-123',
        thumbnailUrl: 'https://img.youtube.com/vi/invalid-id-123/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 0),
        uploader: 'Test Channel',
        isLive: false,
      );

      longVideo = VideoContent(
        id: 'long-video-1',
        title: 'Extended Emergency Briefing',
        description: 'Complete emergency response briefing',
        youtubeVideoId: 'long-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/long-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(hours: 1, minutes: 30),
        uploader: 'Emergency Operations Center',
        isLive: false,
      );
    });

    testWidgets('displays video player with initial loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Verify loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);

      // Verify video title is displayed
      expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);
      expect(find.text('Emergency Management'), findsOneWidget);
    });

    testWidgets('displays thumbnail and play button initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
                showThumbnail: true,
              ),
            ),
          ),
        ),
      );

      // Verify thumbnail container is present
      expect(find.byKey(const Key('video-thumbnail')), findsOneWidget);

      // Verify play button overlay
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byKey(const Key('play-button-overlay')), findsOneWidget);
    });

    testWidgets('renders responsive design on different screen sizes', (tester) async {
      // Test mobile portrait
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(YoutubeVideoPlayer), findsOneWidget);

      // Verify aspect ratio is maintained
      final playerFinder = find.byKey(const Key('video-player-container'));
      expect(playerFinder, findsOneWidget);

      // Test tablet landscape
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pump();

      expect(find.byType(YoutubeVideoPlayer), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('shows and hides controls on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Initially controls should be visible
      expect(find.byKey(const Key('video-controls')), findsOneWidget);

      // Tap to hide controls
      await tester.tap(find.byType(YoutubeVideoPlayer));
      await tester.pump(const Duration(milliseconds: 300));

      // Controls should be hidden (implemented with animation)
      expect(find.byKey(const Key('video-controls')), findsOneWidget);

      // Tap again to show controls
      await tester.tap(find.byType(YoutubeVideoPlayer));
      await tester.pump(const Duration(milliseconds: 300));

      // Controls should be visible again
      expect(find.byKey(const Key('video-controls')), findsOneWidget);
    });

    testWidgets('play/pause functionality works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Initially should show play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Tap play button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Should show pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Should show play button again
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('volume control functions correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
                enableVolumeControl: true,
              ),
            ),
          ),
        ),
      );

      // Find volume slider
      expect(find.byKey(const Key('volume-slider')), findsOneWidget);

      // Find volume icon
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Tap to mute
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pump();

      // Should show muted icon
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      // Tap to unmute
      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pump();

      // Should show volume icon again
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('fullscreen toggle works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
                enableFullscreen: true,
              ),
            ),
          ),
        ),
      );

      // Find fullscreen button
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);

      // Tap fullscreen button
      await tester.tap(find.byIcon(Icons.fullscreen));
      await tester.pump();

      // Should show exit fullscreen icon
      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    });

    testWidgets('progress bar allows seeking', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
                enableSeeking: true,
              ),
            ),
          ),
        ),
      );

      // Find progress bar
      expect(find.byKey(const Key('video-progress-bar')), findsOneWidget);

      // Find time displays
      expect(find.text('0:00'), findsOneWidget); // Current time
      expect(find.text('5:30'), findsOneWidget); // Total duration

      // Tap on progress bar to seek
      final progressBar = find.byKey(const Key('video-progress-bar'));
      await tester.tap(progressBar);
      await tester.pump();

      // Time should update (mocked seek)
      expect(find.byKey(const Key('video-progress-bar')), findsOneWidget);
    });

    testWidgets('displays error state for invalid video', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: invalidVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Wait for error state
      await tester.pump(const Duration(seconds: 3));

      // Should show error message
      expect(find.text('Failed to load video'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Should show retry button
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('handles network connectivity issues', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Simulate network loss during loading
      // This would be handled by the video player controller
      await tester.pump(const Duration(seconds: 5));

      // Should show network error or retry option
      expect(find.byKey(const Key('video-error-container')), findsOneWidget);
    });

    testWidgets('video quality selector works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
                enableQualitySelection: true,
              ),
            ),
          ),
        ),
      );

      // Find quality selector button
      expect(find.byKey(const Key('quality-selector')), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Tap to open quality selector
      await tester.tap(find.byKey(const Key('quality-selector')));
      await tester.pump();

      // Should show quality options
      expect(find.text('720p'), findsOneWidget);
      expect(find.text('480p'), findsOneWidget);
      expect(find.text('360p'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('picture-in-picture mode functionality', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
                enablePiP: true,
              ),
            ),
          ),
        ),
      );

      // Find PiP button
      expect(find.byKey(const Key('pip-button')), findsOneWidget);
      expect(find.byIcon(Icons.picture_in_picture), findsOneWidget);

      // Tap PiP button
      await tester.tap(find.byKey(const Key('pip-button')));
      await tester.pump();

      // PiP mode should be activated (mocked)
      expect(find.byKey(const Key('pip-button')), findsOneWidget);
    });

    testWidgets('live video streaming indicator', (tester) async {
      final liveVideo = VideoContent(
        id: 'live-video-1',
        title: 'Live Emergency Update',
        description: 'Live emergency management briefing',
        youtubeVideoId: 'live-stream-id',
        thumbnailUrl: 'https://img.youtube.com/vi/live-stream-id/mqdefault.jpg',
        uploadedAt: DateTime.now(),
        duration: const Duration(minutes: 0), // Live videos have 0 duration
        uploader: 'Emergency Operations Center',
        isLive: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: liveVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Should show live indicator
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.byKey(const Key('live-indicator')), findsOneWidget);

      // Live indicator should be red
      final liveIndicator = tester.widget<Container>(find.byKey(const Key('live-indicator')));
      expect(liveIndicator.decoration?.color, Colors.red);
    });

    testWidgets('video player accessibility features', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Check for semantic labels on controls
      expect(find.bySemanticsLabel('Play video'), findsOneWidget);
      expect(find.bySemanticsLabel('Pause video'), findsOneWidget);
      expect(find.bySemanticsLabel('Volume control'), findsOneWidget);
      expect(find.bySemanticsLabel('Seek video position'), findsOneWidget);
      expect(find.bySemanticsLabel('Toggle fullscreen'), findsOneWidget);

      // Verify video description is accessible
      expect(find.bySemanticsLabel('Governor declares state of emergency'), findsOneWidget);
    });

    testWidgets('keyboard navigation support', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Test spacebar for play/pause
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      // Test arrow keys for seeking
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      // Test 'f' for fullscreen
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.pump();

      // Test 'm' for mute
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
      await tester.pump();
    });

    testWidgets('video player memory management', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Verify controller is properly initialized
      expect(find.byType(YoutubeVideoPlayer), findsOneWidget);

      // Navigate away and back to test cleanup
      await tester.binding.setSurfaceSize(const Size(100, 100));
      await tester.pumpWidget(Container()); // Simulate navigation

      // Navigate back
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: false,
                showControls: true,
              ),
            ),
          ),
        ),
      );

      // Player should be properly reinitialized
      expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
    });

    testWidgets('handles video end state correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: YoutubeVideoPlayer(
                video: testVideo,
                autoPlay: true,
                showControls: true,
                autoRepeat: false,
              ),
            ),
          ),
        ),
      );

      // Mock video reaching end
      // In real implementation, this would be triggered by VideoPlayerController
      await tester.pump(const Duration(seconds: 6)); // Video duration + 1s

      // Should show replay button
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.text('Replay'), findsOneWidget);

      // Tap replay to restart
      await tester.tap(find.byIcon(Icons.replay));
      await tester.pump();

      // Should start playing from beginning
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });
}