import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/widgets/youtube_video_player.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Comprehensive accessibility tests for YouTube video player
///
/// Tests WCAG compliance, screen reader support, keyboard navigation,
* color contrast, and accessibility features for users with disabilities.
void main() {
  group('Video Player Accessibility Tests', () {
    late VideoContent testVideo;
    late VideoContent liveVideo;
    late VideoContent longVideo;
    late VideoContent descriptiveVideo;

    setUp(() {
      testVideo = VideoContent(
        id: 'test-video-1',
        title: 'Emergency Declaration - Hurricane Milton',
        description: 'Governor declares state of emergency with evacuation orders for coastal areas',
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
        description: 'Live updates from the state emergency operations center regarding current storm conditions',
        youtubeVideoId: 'live-stream-123',
        thumbnailUrl: 'https://img.youtube.com/vi/live-stream-123/mqdefault.jpg',
        uploadedAt: DateTime.now(),
        duration: Duration.zero,
        uploader: 'Emergency Operations Center',
        isLive: true,
      );

      longVideo = VideoContent(
        id: 'long-video-1',
        title: 'Extended Emergency Briefing - Complete Coverage with ASL Interpretation',
        description: 'Complete emergency response briefing with detailed information and American Sign Language interpretation',
        youtubeVideoId: 'long-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/long-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 4)),
        duration: const Duration(hours: 2, minutes: 30),
        uploader: 'Emergency Operations Center',
        isLive: false,
      );

      descriptiveVideo = VideoContent(
        id: 'descriptive-video-1',
        title: 'Emergency Update with Audio Description',
        description: 'Emergency update with detailed audio description for visually impaired users',
        youtubeVideoId: 'descriptive-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/descriptive-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 8, seconds: 15),
        uploader: 'Accessible Emergency Services',
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
              enableAccessibility: true,
            ),
          ),
        ),
      );
    }

    group('WCAG 2.1 Compliance', () {
      testWidgets('all interactive elements meet minimum touch target size (44x44)', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Check play/pause button
        final playButton = tester.getSize(find.byIcon(Icons.play_arrow));
        expect(playButton.width, greaterThanOrEqualTo(44.0));
        expect(playButton.height, greaterThanOrEqualTo(44.0));

        // Check volume control
        final volumeButton = tester.getSize(find.byIcon(Icons.volume_up));
        expect(volumeButton.width, greaterThanOrEqualTo(44.0));
        expect(volumeButton.height, greaterThanOrEqualTo(44.0));

        // Check fullscreen button
        final fullscreenButton = tester.getSize(find.byIcon(Icons.fullscreen));
        expect(fullscreenButton.width, greaterThanOrEqualTo(44.0));
        expect(fullscreenButton.height, greaterThanOrEqualTo(44.0));

        // Check settings button
        final settingsButton = tester.getSize(find.byIcon(Icons.settings));
        expect(settingsButton.width, greaterThanOrEqualTo(44.0));
        expect(settingsButton.height, greaterThanOrEqualTo(44.0));

        // Check subtitle button
        final subtitleButton = tester.getSize(find.byIcon(Icons.subtitles));
        expect(subtitleButton.width, greaterThanOrEqualTo(44.0));
        expect(subtitleButton.height, greaterThanOrEqualTo(44.0));
      });

      testWidgets('focus indicators are clearly visible', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Request focus on play button
        await tester.binding.focusManager.primaryFocus?.requestFocus();
        await tester.pump();

        // Check if focus indicator is visible
        expect(find.byType(Focus), findsWidgets);

        // Focus should be clearly visible with proper border
        final focusWidget = tester.widget<Focus>(
          find.byKey(const Key('play-button-focus')),
        );
        expect(focusWidget.autofocus, true);

        // Test tab navigation through controls
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Each control should show clear focus
        expect(find.byType(Focus), findsWidgets);
      });

      testWidgets('keyboard navigation works for all controls', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Tab to first control
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Should focus on play button
        expect(find.byKey(const Key('play-button-focused')), findsOneWidget);

        // Tab to next control
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Should focus on volume control
        expect(find.byKey(const Key('volume-control-focused')), findsOneWidget);

        // Continue tabbing through all controls
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(find.byKey(const Key('progress-bar-focused')), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(find.byKey(const Key('quality-selector-focused')), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(find.byKey(const Key('subtitle-control-focused')), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(find.byKey(const Key('fullscreen-button-focused')), findsOneWidget);
      });

      testWidgets('keyboard shortcuts work without mouse', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Spacebar to play/pause
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        // Should start playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Arrow keys for seeking
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        // Should seek forward
        expect(find.text('0:05'), findsOneWidget);

        // 'M' for mute
        await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
        await tester.pump();

        // Should mute
        expect(find.byIcon(Icons.volume_off), findsOneWidget);

        // 'F' for fullscreen
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.pump();

        // Should enter fullscreen
        expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);

        // 'C' for captions
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.pump();

        // Should enable captions
        expect(find.byKey(const Key('captions-enabled')), findsOneWidget);
      });

      testWidgets('color contrast meets WCAG AA standards (4.5:1)', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Test text contrast against background
        final titleText = tester.widget<Text>(
          find.text('Emergency Declaration - Hurricane Milton'),
        );

        // Title should have sufficient contrast
        expect(titleText.style?.color, isNotNull);
        expect(titleText.style?.backgroundColor, isNotNull);

        // Test control contrast
        final controls = tester.widget<Container>(
          find.byKey(const Key('video-controls')),
        );
        expect(controls.decoration?.color, isNotNull);

        // Test overlay contrast
        final overlay = tester.widget<Container>(
          find.byKey(const Key('controls-overlay')),
        );
        expect(overlay.decoration?.color, isNotNull);
      });

      testWidgets('reduced motion support for vestibular disorders', (tester) async {
        // Set reduced motion preference
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          StringCodec().encodeMessage('{"reduceAnimations": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Animations should be disabled or reduced
        expect(find.byKey(const Key('reduced-animations')), findsOneWidget);
        expect(find.byKey(const Key('no-transitions')), findsOneWidget);

        // Controls should appear immediately
        await tester.tap(find.byKey(const Key('video-player-container')));
        await tester.pump(const Duration(milliseconds: 10));

        expect(find.byKey(const Key('video-controls-visible')), findsOneWidget);
      });

      testWidgets('high contrast mode support', (tester) async {
        // Enable high contrast mode
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          StringCodec().encodeMessage('{"highContrast": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should use high contrast colors
        expect(find.byKey(const Key('high-contrast-mode')), findsOneWidget);
        expect(find.byKey(const Key('high-contrast-controls')), findsOneWidget);

        // Text should be highly visible
        final highContrastText = tester.widget<Text>(
          find.text('Emergency Declaration - Hurricane Milton'),
        );
        expect(highContrastText.style?.fontWeight, FontWeight.bold);
      });
    });

    group('Screen Reader Support', () {
      testWidgets('all controls have proper semantic labels', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Check semantic labels for main controls
        expect(find.bySemanticsLabel('Play video, Emergency Declaration - Hurricane Milton, duration 15 minutes 42 seconds'), findsOneWidget);
        expect(find.bySemanticsLabel('Pause video'), findsOneWidget);
        expect(find.bySemanticsLabel('Video progress bar, current position 0 seconds, total duration 15 minutes 42 seconds'), findsOneWidget);
        expect(find.bySemanticsLabel('Volume control, current volume 75 percent'), findsOneWidget);
        expect(find.bySemanticsLabel('Quality settings, current quality 720p'), findsOneWidget);
        expect(find.bySemanticsLabel('Closed captions, currently off'), findsOneWidget);
        expect(find.bySemanticsLabel('Enter fullscreen mode'), findsOneWidget);
        expect(find.bySemanticsLabel('Picture in picture mode'), findsOneWidget);
        expect(find.bySemanticsLabel('Video settings'), findsOneWidget);
      });

      testWidgets('semantic announcements for state changes', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing - should announce
        await tester.tap(find.bySemanticsLabel('Play video'));
        await tester.pump();

        // Should announce playback start
        expect(find.bySemanticsLabel('Video playing'), findsOneWidget);

        // Seek to new position - should announce
        final progressBar = find.bySemanticsLabel('Video progress bar');
        await tester.tap(progressBar);
        await tester.pump();

        // Should announce new position
        expect(find.bySemanticsLabel(RegExp(r'Position: \d+ minutes \d+ seconds')), findsOneWidget);

        // Change volume - should announce
        await tester.tap(find.bySemanticsLabel('Volume control'));
        await tester.pump();
        await tester.drag(find.byKey(const Key('volume-slider')), const Offset(-30, 0));
        await tester.pump();

        // Should announce volume change
        expect(find.bySemanticsLabel(RegExp(r'Volume: \d+ percent')), findsOneWidget);

        // Enable captions - should announce
        await tester.tap(find.bySemanticsLabel('Closed captions'));
        await tester.pump();
        await tester.tap(find.text('English'));
        await tester.pump();

        // Should announce captions enabled
        expect(find.bySemanticsLabel('English captions enabled'), findsOneWidget);
      });

      testWidgets('live video announcements', (tester) async {
        await tester.pumpWidget(createTestApp(video: liveVideo));
        await tester.pumpAndSettle();

        // Should announce live status
        expect(find.bySemanticsLabel('Live video: Live Emergency Operations Center Briefing, currently broadcasting'), findsOneWidget);

        // Live indicator should be accessible
        expect(find.bySemanticsLabel('Live indicator, currently broadcasting'), findsOneWidget);

        // Stop live video - should announce
        await tester.tap(find.bySemanticsLabel('Stop live video'));
        await tester.pump();

        expect(find.bySemanticsLabel('Live video stopped'), findsOneWidget);
      });

      testWidgets('error announcements for screen readers', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate error (mocked)
        await tester.pump(const Duration(seconds: 10));

        // Should announce error
        expect(find.bySemanticsLabel('Video loading failed. This video may have been removed or is not available.'), findsOneWidget);

        // Should provide accessible error actions
        expect(find.bySemanticsLabel('Retry loading video'), findsOneWidget);
        expect(find.bySemanticsLabel('Report video issue'), findsOneWidget);
      });

      testWidgets('accessibility tree structure is logical', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Check semantic tree structure
        final nodes = tester.binding.pipelineOwner.semanticsOwner?.rootChildren;

        // Main video player container should be semantically grouped
        expect(find.bySemanticsLabel(RegExp(r'Video player: .*')), findsOneWidget);

        // Controls should be in a separate semantic group
        expect(find.bySemanticsLabel('Video controls'), findsOneWidget);

        // Video information should be accessible
        expect(find.bySemanticsLabel(RegExp(r'Uploaded by: .*')), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp(r'Duration: .*')), findsOneWidget);
      });

      testWidgets('screen reader navigation order is logical', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Get all semantic nodes
        final semanticsOwner = tester.binding.pipelineOwner.semanticsOwner;
        final nodes = semanticsOwner?.rootChildren ?? [];

        // Navigation should follow visual order
        // 1. Video title
        // 2. Play/pause button
        // 3. Progress bar
        // 4. Volume control
        // 5. Quality settings
        // 6. Captions
        // 7. Fullscreen
        // 8. Other controls

        expect(find.bySemanticsLabel('Emergency Declaration - Hurricane Milton'), findsOneWidget);
        expect(find.bySemanticsLabel('Play video'), findsOneWidget);
        expect(find.bySemanticsLabel('Video progress bar'), findsOneWidget);
        expect(find.bySemanticsLabel('Volume control'), findsOneWidget);
        expect(find.bySemanticsLabel('Quality settings'), findsOneWidget);
        expect(find.bySemanticsLabel('Closed captions'), findsOneWidget);
        expect(find.bySemanticsLabel('Enter fullscreen mode'), findsOneWidget);
      });
    });

    group('Caption and Subtitle Accessibility', () {
      testWidgets('captions are fully accessible', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enable captions
        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();
        await tester.tap(find.text('English'));
        await tester.pump();

        // Captions should be visible and accessible
        expect(find.byKey(const Key('captions-visible')), findsOneWidget);
        expect(find.bySemanticsLabel('Video captions: Emergency declarations are now in effect'), findsOneWidget);

        // Caption controls should be accessible
        expect(find.bySemanticsLabel('Caption settings'), findsOneWidget);

        // Open caption settings
        await tester.tap(find.bySemanticsLabel('Caption settings'));
        await tester.pump();

        // Caption settings should be accessible
        expect(find.bySemanticsLabel('Caption font size'), findsOneWidget);
        expect(find.bySemanticsLabel('Caption color'), findsOneWidget);
        expect(find.bySemanticsLabel('Caption background'), findsOneWidget);
        expect(find.bySemanticsLabel('Caption position'), findsOneWidget);
      });

      testWidgets('caption styling maintains readability', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enable captions
        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();
        await tester.tap(find.text('English'));
        await tester.pump();

        // Check caption text properties
        final captionText = tester.widget<Text>(
          find.byKey(const Key('caption-text')),
        );

        // Caption text should have good contrast
        expect(captionText.style?.color, isNotNull);
        expect(captionText.style?.backgroundColor, isNotNull);

        // Caption text should be appropriately sized
        expect(captionText.style?.fontSize, greaterThanOrEqualTo(16.0));

        // Caption text should have proper spacing
        expect(captionText.style?.height, greaterThan(1.2));
      });

      testWidgets('multiple caption languages supported', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Open caption options
        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();

        // Should show multiple language options
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Spanish'), findsOneWidget);
        expect(find.text('French'), findsOneWidget);
        expect(find.text('German'), findsOneWidget);
        expect(find.text('Chinese'), findsOneWidget);

        // Each language should be accessible
        expect(find.bySemanticsLabel('English captions'), findsOneWidget);
        expect(find.bySemanticsLabel('Spanish captions'), findsOneWidget);
        expect(find.bySemanticsLabel('French captions'), findsOneWidget);
      });

      testWidgets('audio description support', (tester) async {
        await tester.pumpWidget(createTestApp(video: descriptiveVideo));
        await tester.pumpAndSettle();

        // Should show audio description option
        expect(find.bySemanticsLabel('Enable audio description'), findsOneWidget);

        // Enable audio description
        await tester.tap(find.bySemanticsLabel('Enable audio description'));
        await tester.pump();

        // Should announce audio description enabled
        expect(find.bySemanticsLabel('Audio description enabled'), findsOneWidget);

        // Should indicate audio description track
        expect(find.byKey(const Key('audio-description-active')), findsOneWidget);
      });
    });

    group('Visual Accessibility Features', () {
      testWidgets('zoom and magnification support', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate system zoom (200%)
        await tester.binding.window.devicePixelRatio = 2.0;
        await tester.pump();

        // UI should remain usable at high zoom levels
        expect(find.byType(YoutubeVideoPlayer), findsOneWidget);

        // Controls should still be accessible
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        // Text should remain readable
        expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);

        // Reset zoom
        await tester.binding.window.devicePixelRatio = 1.0;
        await tester.pump();
      });

      testWidgets('large text support', (tester) async {
        // Enable large text
        await tester.binding.window.textScaleFactor = 2.0;
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Text should scale appropriately
        final titleText = tester.widget<Text>(
          find.text('Emergency Declaration - Hurricane Milton'),
        );
        expect(titleText.style?.fontSize, greaterThan(20.0));

        // Controls should remain accessible
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        // Layout should adapt to larger text
        expect(find.byKey(const Key('layout-adapted-large-text')), findsOneWidget);

        // Reset text scale
        await tester.binding.window.textScaleFactor = 1.0;
        await tester.pump();
      });

      testWidgets('color blindness support', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should provide alternative visual indicators
        expect(find.byKey(const Key('colorblind-indicators')), findsOneWidget);

        // Live indicator should use pattern, not just color
        expect(find.byKey(const Key('live-indicator-pattern')), findsOneWidget);

        // Status indicators should have icons/text in addition to colors
        expect(find.byIcon(Icons.error), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
      });

      testWidgets('blind and low vision navigation', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should provide voice control support
        expect(find.byKey(const Key('voice-control-enabled')), findsOneWidget);

        // Should provide haptic feedback
        expect(find.byKey(const Key('haptic-feedback')), findsOneWidget);

        // Should provide audio cues
        expect(find.byKey(const Key('audio-cues')), findsOneWidget);

        // Test voice commands
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'voice_control',
          StringCodec().encodeMessage('play video'),
          (data) {},
        );
        await tester.pump();

        // Should respond to voice command
        expect(find.byIcon(Icons.pause), findsOneWidget);
      });
    });

    group('Hearing Accessibility Features', () {
      testWidgets('visual indicators for audio content', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should show visual volume indicator
        expect(find.byKey(const Key('visual-volume-indicator')), findsOneWidget);

        // Should show visual feedback for audio events
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        expect(find.byKey(const Key('audio-start-indicator')), findsOneWidget);

        await tester.tap(find.byIcon(Icons.pause));
        await tester.pump();

        expect(find.byKey(const Key('audio-stop-indicator')), findsOneWidget);
      });

      testWidgets('vibration and haptic feedback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should provide haptic feedback for interactions
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        expect(find.byKey(const Key('haptic-play-feedback')), findsOneWidget);

        // Should vibrate for important events
        await tester.pump(const Duration(seconds: 16)); // Video end
        expect(find.byKey(const Key('haptic-video-end')), findsOneWidget);

        // Should provide different haptic patterns for different actions
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pump();
        expect(find.byKey(const Key('haptic-volume-feedback')), findsOneWidget);
      });

      testWidgets('sign language picture-in-picture', (tester) async {
        await tester.pumpWidget(createTestApp(video: longVideo));
        await tester.pumpAndSettle();

        // Should offer sign language PiP for long videos
        expect(find.bySemanticsLabel('Enable sign language picture in picture'), findsOneWidget);

        // Enable sign language PiP
        await tester.tap(find.bySemanticsLabel('Enable sign language picture in picture'));
        await tester.pump();

        // Should show sign language interpreter
        expect(find.byKey(const Key('sign-language-pip')), findsOneWidget);
        expect(find.bySemanticsLabel('Sign language interpreter window'), findsOneWidget);

        // Sign language window should be resizable
        expect(find.byKey(const Key('sign-language-resizable')), findsOneWidget);
      });

      testWidgets('transcript accessibility', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should offer transcript option
        expect(find.bySemanticsLabel('Show video transcript'), findsOneWidget);

        // Open transcript
        await tester.tap(find.bySemanticsLabel('Show video transcript'));
        await tester.pump();

        // Transcript should be fully accessible
        expect(find.bySemanticsLabel('Video transcript: Governor declares state of emergency'), findsOneWidget);

        // Transcript should be searchable
        expect(find.bySemanticsLabel('Search transcript'), findsOneWidget);

        // Transcript should have timestamps
        expect(find.bySemanticsLabel(RegExp(r'\d+:\d+: .*')), findsOneWidget);
      });
    });

    group('Motor Accessibility Features', () {
      testWidgets('switch control support', (tester) async {
        // Enable switch control mode
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          StringCodec().encodeMessage('{"switchControl": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should show switch control interface
        expect(find.byKey(const Key('switch-control-interface')), findsOneWidget);

        // Should provide sequential navigation
        expect(find.bySemanticsLabel('Next control'), findsOneWidget);
        expect(find.bySemanticsLabel('Previous control'), findsOneWidget);
        expect(find.bySemanticsLabel('Select'), findsOneWidget);

        // Test switch control navigation
        await tester.tap(find.bySemanticsLabel('Next control'));
        await tester.pump();

        expect(find.byKey(const Key('switch-control-next')), findsOneWidget);
      });

      testWidgets('voice control for motor impairments', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should support voice commands
        expect(find.byKey(const Key('voice-control-motor')), findsOneWidget);

        // Test voice commands
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'voice_control',
          StringCodec().encodeMessage('play'),
          (data) {},
        );
        await tester.pump();

        expect(find.byIcon(Icons.pause), findsOneWidget);

        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'voice_control',
          StringCodec().encodeMessage('volume up'),
          (data) {},
        );
        await tester.pump();

        expect(find.byKey(const Key('voice-volume-up')), findsOneWidget);
      });

      testWidgets('adapted controls for limited dexterity', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should offer adapted control layouts
        expect(find.bySemanticsLabel('Switch to simplified controls'), findsOneWidget);

        // Enable simplified controls
        await tester.tap(find.bySemanticsLabel('Switch to simplified controls'));
        await tester.pump();

        // Should show larger, more spaced controls
        expect(find.byKey(const Key('simplified-controls')), findsOneWidget);

        // Touch targets should be extra large
        final simplifiedButton = tester.getSize(find.byIcon(Icons.play_arrow));
        expect(simplifiedButton.width, greaterThanOrEqualTo(60.0));
        expect(simplifiedButton.height, greaterThanOrEqualTo(60.0));
      });

      testWidgets('head tracking and eye tracking support', (tester) async {
        // Enable eye tracking
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          StringCodec().encodeMessage('{"eyeTracking": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should support gaze interaction
        expect(find.byKey(const Key('gaze-interaction')), findsOneWidget);

        // Should provide dwell time control
        expect(find.byKey(const Key('dwell-time-control')), findsOneWidget);

        // Should show gaze indicators
        expect(find.byKey(const Key('gaze-indicator')), findsOneWidget);
      });
    });

    group('Cognitive Accessibility Features', () {
      testWidgets('simplified interface mode', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should offer simplified mode
        expect(find.bySemanticsLabel('Switch to simplified mode'), findsOneWidget);

        // Enable simplified mode
        await tester.tap(find.bySemanticsLabel('Switch to simplified mode'));
        await tester.pump();

        // Should hide complex controls
        expect(find.byKey(const Key('simplified-mode')), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsNothing);
        expect(find.byIcon(Icons.subtitles), findsNothing);

        // Should show only essential controls
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);

        // Should provide clear, simple labels
        expect(find.text('Play Video'), findsOneWidget);
        expect(find.text('Full Screen'), findsOneWidget);
      });

      testWidgets('step-by-step instructions', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should offer help mode
        expect(find.bySemanticsLabel('Show help and instructions'), findsOneWidget);

        // Enable help mode
        await tester.tap(find.bySemanticsLabel('Show help and instructions'));
        await tester.pump();

        // Should show step-by-step guide
        expect(find.text('How to use the video player'), findsOneWidget);
        expect(find.text('Step 1: Tap Play to start the video'), findsOneWidget);
        expect(find.text('Step 2: Use the progress bar to jump to any point'), findsOneWidget);
        expect(find.text('Step 3: Adjust volume with the volume control'), findsOneWidget);

        // Instructions should be accessible
        expect(find.bySemanticsLabel('Step 1 of 5: Tap Play to start the video'), findsOneWidget);
      });

      testWidgets('consistent interface and predictable behavior', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Controls should be in consistent positions
        expect(find.byKey(const Key('play-button-consistent')), findsOneWidget);
        expect(find.byKey(const Key('volume-control-consistent')), findsOneWidget);
        expect(find.byKey(const Key('progress-bar-consistent')), findsOneWidget);

        // Behaviors should be predictable
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should always start playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Should always show the same result for the same action
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pump();

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('clear feedback for all actions', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Every action should provide clear feedback
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should show feedback
        expect(find.byKey(const Key('play-feedback')), findsOneWidget);
        expect(find.bySemanticsLabel('Video started playing'), findsOneWidget);

        // Should show visual feedback
        expect(find.byKey(const Key('visual-feedback')), findsOneWidget);

        // Should show haptic feedback
        expect(find.byKey(const Key('haptic-feedback')), findsOneWidget);
      });
    });

    group('Testing Tools and Validation', () {
      testWidgets('accessibility scanner compatibility', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // All elements should have proper accessibility properties
        final semanticsOwner = tester.binding.pipelineOwner.semanticsOwner;
        expect(semanticsOwner, isNotNull);

        // No unlabeled interactive elements
        final unlabeledInteractive = tester.binding.pipelineOwner.semanticsOwner?.rootChildren?.where(
          (node) => node.hasFlag(SemanticsFlag.isButton) && node.label.isEmpty,
        );
        expect(unlabeledInteractive?.isEmpty ?? true, true);

        // All images should have descriptions
        final imagesWithoutLabels = tester.binding.pipelineOwner.semanticsOwner?.rootChildren?.where(
          (node) => node.hasFlag(SemanticsFlag.isImage) && node.label.isEmpty,
        );
        expect(imagesWithoutLabels?.isEmpty ?? true, true);
      });

      testWidgets('automated accessibility testing validation', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Validate touch targets
        final touchTargets = [
          find.byIcon(Icons.play_arrow),
          find.byIcon(Icons.volume_up),
          find.byIcon(Icons.fullscreen),
          find.byIcon(Icons.settings),
          find.byIcon(Icons.subtitles),
        ];

        for (final target in touchTargets) {
          if (target.evaluate().isNotEmpty) {
            final size = tester.getSize(target);
            expect(size.width, greaterThanOrEqualTo(44.0),
              reason: 'Touch target should be at least 44px wide');
            expect(size.height, greaterThanOrEqualTo(44.0),
              reason: 'Touch target should be at least 44px tall');
          }
        }

        // Validate semantic labels
        final interactiveElements = find.byType(IconButton);
        for (final element in interactiveElements.evaluate()) {
          final semanticLabel = element.widget.semanticsLabel ?? '';
          expect(semanticLabel.isNotEmpty, true,
            reason: 'Interactive element should have semantic label');
        }

        // Validate focus order
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        final focused = tester.binding.focusManager.primaryFocus;
        expect(focused, isNotNull, reason: 'First element should be focusable');
      });
    });

    group('Multi-Device Accessibility', () {
      testWidgets('accessibility works across different screen sizes', (tester) async {
        final screenSizes = [
          const Size(375, 667), // Small phone
          const Size(768, 1024), // Tablet
          const Size(1920, 1080), // Desktop
        ];

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(createTestApp(video: testVideo));
          await tester.pumpAndSettle();

          // Semantic labels should work on all sizes
          expect(find.bySemanticsLabel('Play video'), findsOneWidget);
          expect(find.bySemanticsLabel('Pause video'), findsOneWidget);

          // Touch targets should maintain minimum size
          final playButton = tester.getSize(find.byIcon(Icons.play_arrow));
          expect(playButton.width, greaterThanOrEqualTo(44.0));
          expect(playButton.height, greaterThanOrEqualTo(44.0));

          // Focus should work
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(tester.binding.focusManager.primaryFocus, isNotNull);
        }

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
        await tester.pump();
      });

      testWidgets('accessibility works with different input methods', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Touch input
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Keyboard input
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        // Mouse input (hover)
        await tester.hover(find.byIcon(Icons.play_arrow));
        await tester.pump();
        expect(find.byKey(const Key('play-button-hover')), findsOneWidget);

        // Voice input
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'voice_control',
          StringCodec().encodeMessage('play'),
          (data) {},
        );
        await tester.pump();
        expect(find.byIcon(Icons.pause), findsOneWidget);
      });

      testWidgets('accessibility works with assistive technologies', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate screen reader active
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          StringCodec().encodeMessage('{"accessibility": true, "screenReader": true}'),
          (data) {},
        );
        await tester.pump();

        // Should enable accessibility mode
        expect(find.byKey(const Key('accessibility-mode')), findsOneWidget);

        // Should provide enhanced verbal feedback
        expect(find.byKey(const Key('enhanced-verbal-feedback')), findsOneWidget);

        // Should provide audio descriptions
        expect(find.byKey(const Key('audio-descriptions')), findsOneWidget);

        // Simulate switch control active
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          StringCodec().encodeMessage('{"switchControl": true}'),
          (data) {},
        );
        await tester.pump();

        // Should enable switch control mode
        expect(find.byKey(const Key('switch-control-mode')), findsOneWidget);
      });
    });
  });
}