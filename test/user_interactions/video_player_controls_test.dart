import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/widgets/youtube_video_player.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// User interaction tests for YouTube video player controls
///
/// Tests all user interactions including play/pause, seeking,
* volume control, fullscreen, quality selection, and gesture controls.
void main() {
  group('Video Player Controls User Interaction Tests', () {
    late VideoContent testVideo;
    late VideoContent liveVideo;
    late VideoContent longVideo;

    setUp(() {
      testVideo = VideoContent(
        id: 'test-video-1',
        title: 'Emergency Declaration - Hurricane Milton',
        description: 'Governor declares state of emergency',
        youtubeVideoId: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 15, seconds: 42),
        uploader: 'Emergency Management',
        isLive: false,
      );

      liveVideo = VideoContent(
        id: 'live-video-1',
        title: 'Live Emergency Operations Center Briefing',
        description: 'Live updates from emergency operations center',
        youtubeVideoId: 'live-stream-123',
        thumbnailUrl: 'https://img.youtube.com/vi/live-stream-123/mqdefault.jpg',
        uploadedAt: DateTime.now(),
        duration: Duration.zero,
        uploader: 'Emergency Operations Center',
        isLive: true,
      );

      longVideo = VideoContent(
        id: 'long-video-1',
        title: 'Extended Emergency Briefing - Complete Coverage',
        description: 'Complete emergency response briefing with detailed information',
        youtubeVideoId: 'long-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/long-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 4)),
        duration: const Duration(hours: 2, minutes: 30),
        uploader: 'Emergency Operations Center',
        isLive: false,
      );
    });

    Widget createTestApp({required VideoContent video}) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: YoutubeVideoPlayer(
              video: video,
              autoPlay: false,
              showControls: true,
              showThumbnail: true,
            ),
          ),
        ),
      );
    }

    group('Play/Pause Controls', () {
      testWidgets('play button starts video playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Initially should show play button
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.bySemanticsLabel('Play video'), findsOneWidget);

        // Tap play button
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should show pause button
        expect(find.byIcon(Icons.pause), findsOneWidget);
        expect(find.bySemanticsLabel('Pause video'), findsOneWidget);

        // Video should be playing (mocked state)
        expect(find.byKey(const Key('video-playing')), findsOneWidget);
      });

      testWidgets('pause button stops video playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Tap pause button
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pump();

        // Should show play button again
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byKey(const Key('video-paused')), findsOneWidget);
      });

      testWidgets('play/pause toggle works with video tap', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Tap on video to play
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump();

        // Should start playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Tap again to pause
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump();

        // Should pause
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('play/pause state persists when controls hide', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Wait for controls to auto-hide
        await tester.pump(const Duration(seconds: 3));

        // Controls should hide but video continues playing
        expect(find.byKey(const Key('video-controls-hidden')), findsOneWidget);
        expect(find.byKey(const Key('video-playing')), findsOneWidget);

        // Tap to show controls
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump();

        // Should show pause button (still playing)
        expect(find.byIcon(Icons.pause), findsOneWidget);
      });

      testWidgets('live video auto-plays and shows stop button', (tester) async {
        await tester.pumpWidget(createTestApp(video: liveVideo));
        await tester.pumpAndSettle();

        // Live video should auto-play
        expect(find.byIcon(Icons.stop), findsOneWidget);
        expect(find.bySemanticsLabel('Stop live video'), findsOneWidget);
        expect(find.byKey(const Key('video-playing')), findsOneWidget);

        // Tap stop button
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pump();

        // Should show play button for live stream
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byKey(const Key('video-paused')), findsOneWidget);
      });
    });

    group('Seeking Controls', () {
      testWidgets('progress bar allows seeking to specific position', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find progress bar
        final progressBar = find.byKey(const Key('video-progress-bar'));
        expect(progressBar, findsOneWidget);

        // Initially should show 0:00 / 15:42
        expect(find.text('0:00'), findsOneWidget);
        expect(find.text('15:42'), findsOneWidget);

        // Tap on progress bar at 50% position
        await tester.tap(progressBar);
        await tester.pump();

        // Should update current time (mocked)
        expect(find.text('7:51'), findsOneWidget); // 50% of 15:42

        // Progress indicator should move
        expect(find.byKey(const Key('progress-indicator-moved')), findsOneWidget);
      });

      testWidgets('progress bar dragging works smoothly', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final progressBar = find.byKey(const Key('video-progress-bar'));

        // Start dragging
        await tester.drag(progressBar, const Offset(100, 0));
        await tester.pump();

        // Should show seeking state
        expect(find.byKey(const Key('video-seeking')), findsOneWidget);

        // Continue dragging
        await tester.drag(progressBar, const Offset(50, 0));
        await tester.pump();

        // Release drag
        await tester.pump();

        // Should complete seek
        expect(find.byKey(const Key('seek-complete')), findsOneWidget);
      });

      testWidgets('time displays update correctly during seeking', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final progressBar = find.byKey(const Key('video-progress-bar'));

        // Drag to different positions
        await tester.drag(progressBar, const Offset(50, 0));
        await tester.pump();

        // Time should update during drag
        expect(find.textContaining(':'), findsOneWidget);

        // Complete drag
        await tester.pump();
      });

      testWidgets('seeking works during video playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Let video play for a moment
        await tester.pump(const Duration(seconds: 2));

        // Seek to different position
        final progressBar = find.byKey(const Key('video-progress-bar'));
        await tester.tap(progressBar);
        await tester.pump();

        // Should continue playing from new position
        expect(find.byIcon(Icons.pause), findsOneWidget);
        expect(find.byKey(const Key('video-playing')), findsOneWidget);
      });

      testWidgets('skip forward/back buttons work correctly', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Find skip buttons
        expect(find.byIcon(Icons.fast_forward), findsOneWidget);
        expect(find.byIcon(Icons.fast_rewind), findsOneWidget);

        // Skip forward 10 seconds
        await tester.tap(find.byIcon(Icons.fast_forward));
        await tester.pump();

        // Should show new position
        expect(find.text('0:10'), findsOneWidget);

        // Skip backward 10 seconds
        await tester.tap(find.byIcon(Icons.fast_rewind));
        await tester.pump();

        // Should return to previous position
        expect(find.text('0:00'), findsOneWidget);
      });

      testWidgets('chapter navigation works for long videos', (tester) async {
        await tester.pumpWidget(createTestApp(video: longVideo));
        await tester.pumpAndSettle();

        // Should show chapter markers for long videos
        expect(find.byKey(const Key('chapter-markers')), findsOneWidget);

        // Tap on chapter marker
        await tester.tap(find.byKey(const Key('chapter-marker-1')));
        await tester.pump();

        // Should seek to chapter position
        expect(find.byKey(const Key('chapter-seek-complete')), findsOneWidget);
      });
    });

    group('Volume Controls', () {
      testWidgets('volume slider adjusts volume level', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find volume control
        expect(find.byKey(const Key('volume-control')), findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        // Tap volume button to show slider
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pump();

        // Volume slider should appear
        expect(find.byKey(const Key('volume-slider')), findsOneWidget);

        // Drag slider to adjust volume
        await tester.drag(find.byKey(const Key('volume-slider')), const Offset(-50, 0));
        await tester.pump();

        // Volume level should change
        expect(find.byKey(const Key('volume-changed')), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
      });

      testWidgets('mute/unmute functionality works', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find volume button
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        // Tap to mute
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pump();

        // Should show muted icon
        expect(find.byIcon(Icons.volume_off), findsOneWidget);
        expect(find.byKey(const Key('video-muted')), findsOneWidget);

        // Tap to unmute
        await tester.tap(find.byIcon(Icons.volume_off));
        await tester.pump();

        // Should restore volume
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
        expect(find.byKey(const Key('video-unmuted')), findsOneWidget);
      });

      testWidgets('volume control works with keyboard shortcuts', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Press 'M' key to mute
        await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
        await tester.pump();

        // Should mute
        expect(find.byIcon(Icons.volume_off), findsOneWidget);

        // Press 'M' again to unmute
        await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
        await tester.pump();

        // Should unmute
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        // Use arrow keys for volume
        await tester.sendKeyDown(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        // Volume should increase
        expect(find.byKey(const Key('volume-increased')), findsOneWidget);

        await tester.sendKeyDown(LogicalKeyboardKey.arrowDown);
        await tester.pump();

        // Volume should decrease
        expect(find.byKey(const Key('volume-decreased')), findsOneWidget);
      });
    });

    group('Fullscreen Controls', () {
      testWidgets('fullscreen button toggles fullscreen mode', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find fullscreen button
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);
        expect(find.bySemanticsLabel('Enter fullscreen'), findsOneWidget);

        // Tap to enter fullscreen
        await tester.tap(find.byIcon(Icons.fullscreen));
        await tester.pump();

        // Should show exit fullscreen icon
        expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
        expect(find.bySemanticsLabel('Exit fullscreen'), findsOneWidget);
        expect(find.byKey(const Key('fullscreen-active')), findsOneWidget);

        // Tap to exit fullscreen
        await tester.tap(find.byIcon(Icons.fullscreen_exit));
        await tester.pump();

        // Should return to normal view
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);
        expect(find.byKey(const Key('fullscreen-inactive')), findsOneWidget);
      });

      testWidgets('fullscreen works with keyboard shortcut', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Press 'F' key for fullscreen
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.pump();

        // Should enter fullscreen
        expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);

        // Press 'F' again to exit
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.pump();

        // Should exit fullscreen
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      });

      testWidgets('escape key exits fullscreen', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enter fullscreen
        await tester.tap(find.byIcon(Icons.fullscreen));
        await tester.pump();

        expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);

        // Press escape key
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        // Should exit fullscreen
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      });

      testWidgets('controls auto-hide in fullscreen mode', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enter fullscreen
        await tester.tap(find.byIcon(Icons.fullscreen));
        await tester.pump();

        // Wait for controls to auto-hide
        await tester.pump(const Duration(seconds: 3));

        // Controls should hide faster in fullscreen
        expect(find.byKey(const Key('video-controls-hidden')), findsOneWidget);

        // Tap to show controls
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump();

        // Controls should reappear
        expect(find.byKey(const Key('video-controls-visible')), findsOneWidget);
      });
    });

    group('Quality Selection', () {
      testWidgets('quality selector opens quality options', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find quality selector
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byKey(const Key('quality-selector')), findsOneWidget);

        // Tap to open quality menu
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();

        // Should show quality options
        expect(find.text('Video Quality'), findsOneWidget);
        expect(find.text('Auto'), findsOneWidget);
        expect(find.text('1080p'), findsOneWidget);
        expect(find.text('720p'), findsOneWidget);
        expect(find.text('480p'), findsOneWidget);
        expect(find.text('360p'), findsOneWidget);
      });

      testWidgets('quality selection changes video quality', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Open quality selector
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();

        // Select 720p quality
        await tester.tap(find.text('720p'));
        await tester.pump();

        // Should change quality
        expect(find.byKey(const Key('quality-changed-720p')), findsOneWidget);

        // Quality selector should show current quality
        expect(find.text('720p'), findsOneWidget);
      });

      testWidgets('auto quality adjusts based on network', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Open quality selector
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();

        // Select auto quality
        await tester.tap(find.text('Auto'));
        await tester.pump();

        // Should enable auto quality
        expect(find.byKey(const Key('auto-quality-enabled')), findsOneWidget);

        // Should adapt quality based on conditions (mocked)
        expect(find.byKey(const Key('quality-adapting')), findsOneWidget);
      });

      testWidgets('quality changes work during playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Change quality during playback
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();
        await tester.tap(find.text('480p'));
        await tester.pump();

        // Should change quality without stopping
        expect(find.byIcon(Icons.pause), findsOneWidget);
        expect(find.byKey(const Key('quality-changed-during-playback')), findsOneWidget);
      });
    });

    group('Playback Speed Control', () {
      testWidgets('playback speed selector opens speed options', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find speed control
        expect(find.byKey(const Key('playback-speed-control')), findsOneWidget);
        expect(find.text('1x'), findsOneWidget);

        // Tap to open speed options
        await tester.tap(find.text('1x'));
        await tester.pump();

        // Should show speed options
        expect(find.text('Playback Speed'), findsOneWidget);
        expect(find.text('0.5x'), findsOneWidget);
        expect(find.text('0.75x'), findsOneWidget);
        expect(find.text('1x'), findsOneWidget);
        expect(find.text('1.25x'), findsOneWidget);
        expect(find.text('1.5x'), findsOneWidget);
        expect(find.text('2x'), findsOneWidget);
      });

      testWidgets('playback speed changes video speed', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Change speed to 1.5x
        await tester.tap(find.text('1x'));
        await tester.pump();
        await tester.tap(find.text('1.5x'));
        await tester.pump();

        // Should change playback speed
        expect(find.byKey(const Key('playback-speed-1.5x')), findsOneWidget);
        expect(find.text('1.5x'), findsOneWidget);

        // Time display should update faster
        await tester.pump(const Duration(seconds: 2));
        expect(find.textContaining('0:03'), findsOneWidget); // 2s * 1.5x = 3s
      });

      testWidgets('speed changes work for different content types', (tester) async {
        // Test with normal video
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1x'));
        await tester.pump();
        await tester.tap(find.text('2x'));
        await tester.pump();

        expect(find.byKey(const Key('playback-speed-2x')), findsOneWidget);

        // Test with live video (speed control should be disabled)
        await tester.pumpWidget(createTestApp(video: liveVideo));
        await tester.pumpAndSettle();

        // Speed control should not be available for live video
        expect(find.byKey(const Key('playback-speed-control')), findsNothing);
      });
    });

    group('Subtitle and Caption Controls', () {
      testWidgets('subtitle selector opens caption options', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find subtitle control
        expect(find.byIcon(Icons.subtitles), findsOneWidget);
        expect(find.byKey(const Key('subtitle-control')), findsOneWidget);

        // Tap to open subtitle options
        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();

        // Should show subtitle options
        expect(find.text('Subtitles'), findsOneWidget);
        expect(find.text('Off'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Spanish'), findsOneWidget);
      });

      testWidgets('subtitle selection enables captions', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enable subtitles
        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();
        await tester.tap(find.text('English'));
        await tester.pump();

        // Should show subtitles
        expect(find.byKey(const Key('subtitles-enabled')), findsOneWidget);
        expect(find.byKey(const Key('subtitle-track')), findsOneWidget);

        // Icon should change to indicate subtitles are on
        expect(find.byIcon(Icons.subtitles), findsOneWidget);
      });

      testWidgets('subtitle appearance settings work', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enable subtitles
        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();
        await tester.tap(find.text('English'));
        await tester.pump();

        // Open subtitle settings
        await tester.tap(find.byKey(const Key('subtitle-settings')));
        await tester.pump();

        // Should show subtitle appearance options
        expect(find.text('Subtitle Settings'), findsOneWidget);
        expect(find.text('Font Size'), findsOneWidget);
        expect(find.text('Font Color'), findsOneWidget);
        expect(find.text('Background'), findsOneWidget);

        // Change font size
        await tester.tap(find.text('Font Size'));
        await tester.pump();
        await tester.tap(find.text('Large'));
        await tester.pump();

        // Subtitles should be larger
        expect(find.byKey(const Key('subtitles-large')), findsOneWidget);
      });
    });

    group('Picture-in-Picture Controls', () {
      testWidgets('PiP button activates picture-in-picture mode', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find PiP button
        expect(find.byIcon(Icons.picture_in_picture), findsOneWidget);
        expect(find.byKey(const Key('pip-button')), findsOneWidget);

        // Tap to activate PiP
        await tester.tap(find.byIcon(Icons.picture_in_picture));
        await tester.pump();

        // Should enter PiP mode
        expect(find.byKey(const Key('pip-active')), findsOneWidget);
        expect(find.byKey(const Key('pip-video-player')), findsOneWidget);

        // Main video should be minimized
        expect(find.byKey(const Key('video-player-minimized')), findsOneWidget);
      });

      testWidgets('PiP mode maintains video playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Enter PiP mode
        await tester.tap(find.byIcon(Icons.picture_in_picture));
        await tester.pump();

        // Video should continue playing in PiP
        expect(find.byKey(const Key('pip-video-playing')), findsOneWidget);

        // PiP window should show current time
        expect(find.textContaining(':'), findsOneWidget);
      });

      testWidgets('PiP exit restores full video player', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enter PiP mode
        await tester.tap(find.byIcon(Icons.picture_in_picture));
        await tester.pump();

        // Tap PiP window to exit
        await tester.tap(find.byKey(const Key('pip-video-player')));
        await tester.pump();

        // Should restore full video player
        expect(find.byKey(const Key('pip-inactive')), findsOneWidget);
        expect(find.byKey(const Key('video-player-restored')), findsOneWidget);
      });
    });

    group('Gesture Controls', () {
      testWidgets('double tap toggles play/pause', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Double tap to play
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump();

        // Should start playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Double tap to pause
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump();

        // Should pause
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('horizontal swipe seeks forward/backward', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Swipe right to seek forward
        await tester.fling(
          find.byKey(const Key('video-player-container')),
          const Offset(100, 0),
          1000,
        );
        await tester.pump();

        // Should seek forward
        expect(find.byKey(const Key('seek-forward')), findsOneWidget);

        // Swipe left to seek backward
        await tester.fling(
          find.byKey(const Key('video-player-container')),
          const Offset(-100, 0),
          1000,
        );
        await tester.pump();

        // Should seek backward
        expect(find.byKey(const Key('seek-backward')), findsOneWidget);
      });

      testWidgets('vertical swipe adjusts volume', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Swipe up on right side to increase volume
        await tester.fling(
          find.byKey(const Key('video-player-right-side')),
          const Offset(0, -100),
          1000,
        );
        await tester.pump();

        // Volume should increase
        expect(find.byKey(const Key('volume-increase')), findsOneWidget);

        // Swipe down on right side to decrease volume
        await tester.fling(
          find.byKey(const Key('video-player-right-side')),
          const Offset(0, 100),
          1000,
        );
        await tester.pump();

        // Volume should decrease
        expect(find.byKey(const Key('volume-decrease')), findsOneWidget);
      });

      testWidgets('vertical swipe on left side adjusts brightness', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Swipe up on left side to increase brightness
        await tester.fling(
          find.byKey(const Key('video-player-left-side')),
          const Offset(0, -100),
          1000,
        );
        await tester.pump();

        // Brightness should increase
        expect(find.byKey(const Key('brightness-increase')), findsOneWidget);

        // Swipe down on left side to decrease brightness
        await tester.fling(
          find.byKey(const Key('video-player-left-side')),
          const Offset(0, 100),
          1000,
        );
        await tester.pump();

        // Brightness should decrease
        expect(find.byKey(const Key('brightness-decrease')), findsOneWidget);
      });

      testWidgets('pinch zoom adjusts video size', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Pinch to zoom in
        await tester.pinch(
          find.byKey(const Key('video-player-container')),
          const Offset(200, 200),
          const Offset(100, 100),
        );
        await tester.pump();

        // Video should zoom in
        expect(find.byKey(const Key('video-zoomed-in')), findsOneWidget);

        // Pinch to zoom out
        await tester.pinch(
          find.byKey(const Key('video-player-container')),
          const Offset(100, 100),
          const Offset(200, 200),
        );
        await tester.pump();

        // Video should zoom out
        expect(find.byKey(const Key('video-zoomed-out')), findsOneWidget);
      });
    });

    group('Keyboard Shortcuts', () {
      testWidgets('spacebar toggles play/pause', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Press spacebar to play
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        // Should start playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Press spacebar to pause
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        // Should pause
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('arrow keys control seeking', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Right arrow to seek forward
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        // Should seek forward 5 seconds
        expect(find.text('0:05'), findsOneWidget);

        // Left arrow to seek backward
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        // Should seek backward 5 seconds
        expect(find.text('0:00'), findsOneWidget);

        // Hold shift + arrow for larger jumps
        await tester.sendKeyDown(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        // Should seek forward 30 seconds
        expect(find.text('0:30'), findsOneWidget);
      });

      testWidgets('number keys control playback speed', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Press '2' for 2x speed
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await tester.pump();

        // Should change to 2x speed
        expect(find.byKey(const Key('playback-speed-2x')), findsOneWidget);

        // Press '1' for normal speed
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pump();

        // Should return to normal speed
        expect(find.byKey(const Key('playback-speed-1x')), findsOneWidget);
      });

      testWidgets('C key toggles subtitles', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Press 'C' to enable subtitles
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.pump();

        // Should enable subtitles
        expect(find.byKey(const Key('subtitles-enabled')), findsOneWidget);

        // Press 'C' again to disable
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.pump();

        // Should disable subtitles
        expect(find.byKey(const Key('subtitles-disabled')), findsOneWidget);
      });

      testWidgets('L key toggles loop', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Press 'L' to enable loop
        await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
        await tester.pump();

        // Should enable loop
        expect(find.byKey(const Key('loop-enabled')), findsOneWidget);

        // Press 'L' again to disable
        await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
        await tester.pump();

        // Should disable loop
        expect(find.byKey(const Key('loop-disabled')), findsOneWidget);
      });
    });

    group('Advanced Controls', () {
      testWidgets('playlist navigation works', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find playlist controls
        expect(find.byKey(const Key('playlist-controls')), findsOneWidget);
        expect(find.byIcon(Icons.skip_next), findsOneWidget);
        expect(find.byIcon(Icons.skip_previous), findsOneWidget);

        // Next video
        await tester.tap(find.byIcon(Icons.skip_next));
        await tester.pump();

        // Should load next video
        expect(find.byKey(const Key('next-video-loaded')), findsOneWidget);

        // Previous video
        await tester.tap(find.byIcon(Icons.skip_previous));
        await tester.pump();

        // Should load previous video
        expect(find.byKey(const Key('previous-video-loaded')), findsOneWidget);
      });

      testWidgets('shuffle and repeat controls work', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find shuffle and repeat buttons
        expect(find.byIcon(Icons.shuffle), findsOneWidget);
        expect(find.byIcon(Icons.repeat), findsOneWidget);

        // Enable shuffle
        await tester.tap(find.byIcon(Icons.shuffle));
        await tester.pump();

        // Should enable shuffle
        expect(find.byKey(const Key('shuffle-enabled')), findsOneWidget);

        // Enable repeat
        await tester.tap(find.byIcon(Icons.repeat));
        await tester.pump();

        // Should enable repeat
        expect(find.byKey(const Key('repeat-enabled')), findsOneWidget);

        // Tap repeat again for repeat one
        await tester.tap(find.byIcon(Icons.repeat));
        await tester.pump();

        // Should enable repeat one
        expect(find.byKey(const Key('repeat-one-enabled')), findsOneWidget);
      });

      testWidgets('video info panel shows metadata', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find info button
        expect(find.byIcon(Icons.info_outline), findsOneWidget);

        // Tap to show info
        await tester.tap(find.byIcon(Icons.info_outline));
        await tester.pump();

        // Should show video information
        expect(find.text('Video Information'), findsOneWidget);
        expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);
        expect(find.text('Uploaded by: Emergency Management'), findsOneWidget);
        expect(find.text('Duration: 15:42'), findsOneWidget);
        expect(find.text('Uploaded: 2 hours ago'), findsOneWidget);
      });

      testWidgets('share functionality works', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find share button
        expect(find.byIcon(Icons.share), findsOneWidget);

        // Tap to share
        await tester.tap(find.byIcon(Icons.share));
        await tester.pump();

        // Should show share options
        expect(find.text('Share Video'), findsOneWidget);
        expect(find.text('Copy Link'), findsOneWidget);
        expect(find.text('Share to...'), findsOneWidget);
        expect(find.text('Embed'), findsOneWidget);
      });

      testWidgets('download button works for eligible videos', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Find download button
        expect(find.byIcon(Icons.download), findsOneWidget);

        // Tap to download
        await tester.tap(find.byIcon(Icons.download));
        await tester.pump();

        // Should show download options
        expect(find.text('Download Video'), findsOneWidget);
        expect(find.text('360p (10 MB)'), findsOneWidget);
        expect(find.text('720p (25 MB)'), findsOneWidget);
        expect(find.text('1080p (45 MB)'), findsOneWidget);
      });
    });

    group('Accessibility Interactions', () {
      testWidgets('all controls have semantic labels', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Check semantic labels for all controls
        expect(find.bySemanticsLabel('Play video'), findsOneWidget);
        expect(find.bySemanticsLabel('Video progress bar'), findsOneWidget);
        expect(find.bySemanticsLabel('Volume control'), findsOneWidget);
        expect(find.bySemanticsLabel('Quality settings'), findsOneWidget);
        expect(find.bySemanticsLabel('Enter fullscreen'), findsOneWidget);
        expect(find.bySemanticsLabel('Enable subtitles'), findsOneWidget);
        expect(find.bySemanticsLabel('Picture in picture'), findsOneWidget);
      });

      testWidgets('screen reader announcements work', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing - should announce
        await tester.tap(find.bySemanticsLabel('Play video'));
        await tester.pump();

        // Should announce playback state
        expect(find.bySemanticsLabel('Video playing'), findsOneWidget);

        // Pause - should announce
        await tester.tap(find.bySemanticsLabel('Pause video'));
        await tester.pump();

        // Should announce pause state
        expect(find.bySemanticsLabel('Video paused'), findsOneWidget);
      });

      testWidgets('voice control commands work', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate voice command "play video"
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'voice_control',
          StringCodec().encodeMessage('play video'),
          (data) {},
        );
        await tester.pump();

        // Should start playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Simulate voice command "pause"
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'voice_control',
          StringCodec().encodeMessage('pause'),
          (data) {},
        );
        await tester.pump();

        // Should pause
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });
    });

    group('Error Recovery Interactions', () {
      testWidgets('retry button works after errors', (tester) async {
        // Simulate error scenario
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Wait for error (mocked)
        await tester.pump(const Duration(seconds: 10));

        // Should show retry button
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Should attempt to reload
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Should succeed on retry (mocked)
        await tester.pump(const Duration(seconds: 3));
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('report issue button works', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Wait for error
        await tester.pump(const Duration(seconds: 10));

        // Tap report issue
        await tester.tap(find.text('Report Issue'));
        await tester.pump();

        // Should open error reporting dialog
        expect(find.text('Report Video Issue'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('Submit Report'), findsOneWidget);
      });
    });

    group('Performance Interactions', () {
      testWidgets('controls respond quickly during playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Test control responsiveness
        final startTime = DateTime.now();

        // Pause quickly
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pump();

        final responseTime = DateTime.now().difference(startTime);

        // Should respond within 100ms
        expect(responseTime.inMilliseconds, lessThan(100));
      });

      testWidgets('multiple rapid interactions work correctly', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Rapid play/pause toggles
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.play_arrow));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.tap(find.byIcon(Icons.pause));
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Should handle rapid interactions gracefully
        expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
      });
    });
  });
}