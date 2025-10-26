import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/widgets/youtube_video_player.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/screens/storm/storm_screen.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Responsive design tests for YouTube video player
///
/// Tests video player behavior across different screen sizes,
/// orientations, and device types to ensure optimal user experience.
void main() {
  group('YouTube Video Player Responsive Design Tests', () {
    late VideoContent testVideo;
    late VideoContent liveVideo;
    late VideoContent longVideo;

    setUp(() {
      testVideo = VideoContent(
        id: 'test-video-1',
        title: 'Emergency Declaration - Hurricane Milton',
        description: 'Governor declares state of emergency with evacuation orders',
        youtubeVideoId: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 15, seconds: 42),
        uploader: 'Emergency Management',
        isLive: false,
      );

      liveVideo = VideoContent(
        id: 'live-video-1',
        title: 'Live: Emergency Operations Center Briefing',
        description: 'Live updates from the state emergency operations center',
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

    Widget createTestApp({required VideoContent video, bool useStormScreen = false}) {
      return ProviderScope(
        child: MaterialApp(
          home: useStormScreen
              ? StormScreen()
              : Scaffold(
                  body: YoutubeVideoPlayer(
                    video: video,
                    autoPlay: false,
                    showControls: true,
                    showThumbnail: true,
                  ),
                ),
          theme: ThemeData(
            primaryColor: AppTheme.primaryNavy,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppTheme.primaryNavy,
              secondary: AppTheme.accentCopper,
            ),
          ),
        ),
      );
    }

    group('Mobile Phone Sizes', () {
      testWidgets('displays correctly on small phone (iPhone SE)', (tester) async {
        // iPhone SE: 375x667
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should fit within screen bounds
        expect(find.byType(YoutubeVideoPlayer), findsOneWidget);

        // Check aspect ratio maintenance (16:9)
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 375.0);
        expect(videoPlayer.constraints?.maxHeight, 211.0); // 375 * 9/16

        // Controls should be appropriately sized for small screen
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
        final controls = tester.widget<Container>(
          find.byKey(const Key('video-controls')),
        );
        expect(controls.constraints?.minHeight, 48.0); // Minimum touch target

        // Text should be readable
        expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);
        final title = tester.widget<Text>(
          find.text('Emergency Declaration - Hurricane Milton'),
        );
        expect(title.style?.fontSize, lessThanOrEqualTo(16.0));
      });

      testWidgets('displays correctly on standard phone (iPhone 12)', (tester) async {
        // iPhone 12: 390x844
        await tester.binding.setSurfaceSize(const Size(390, 844));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should use available width
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 390.0);
        expect(videoPlayer.constraints?.maxHeight, 219.0); // 390 * 9/16

        // Controls should have adequate spacing
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
      });

      testWidgets('displays correctly on large phone (iPhone 12 Pro Max)', (tester) async {
        // iPhone 12 Pro Max: 428x926
        await tester.binding.setSurfaceSize(const Size(428, 926));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should scale appropriately
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 428.0);
        expect(videoPlayer.constraints?.maxHeight, 241.0); // 428 * 9/16

        // Should show more detail due to larger screen
        expect(find.text('Emergency Management'), findsOneWidget);
        expect(find.text('15:42'), findsOneWidget); // Duration
      });

      testWidgets('handles landscape orientation on phones', (tester) async {
        // Phone in landscape: 844x390
        await tester.binding.setSurfaceSize(const Size(844, 390));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video should take more height in landscape
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 844.0);
        expect(videoPlayer.constraints?.maxHeight, 474.0); // 844 * 9/16

        // Controls should adapt to landscape layout
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
      });

      testWidgets('handles very small screens (320x568)', (tester) async {
        // Very small phone: iPhone 5
        await tester.binding.setSurfaceSize(const Size(320, 568));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video should still fit
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 320.0);
        expect(videoPlayer.constraints?.maxHeight, 180.0); // 320 * 9/16

        // Text might be truncated on very small screens
        expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);
      });
    });

    group('Tablet Sizes', () {
      testWidgets('displays correctly on small tablet (iPad Mini)', (tester) async {
        // iPad Mini: 768x1024
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should be larger on tablet
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 768.0);
        expect(videoPlayer.constraints?.maxHeight, 432.0); // 768 * 9/16

        // Should show additional information
        expect(find.text('Emergency Management'), findsOneWidget);
        expect(find.text('2 hours ago'), findsOneWidget);

        // Controls should be larger and more spaced
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
      });

      testWidgets('displays correctly on standard tablet (iPad)', (tester) async {
        // iPad: 820x1180
        await tester.binding.setSurfaceSize(const Size(820, 1180));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should use more space
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 820.0);
        expect(videoPlayer.constraints?.maxHeight, 461.0); // 820 * 9/16

        // Should show enhanced UI elements
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
        expect(find.byKey(const Key('quality-selector')), findsOneWidget);
        expect(find.byKey(const Key('pip-button')), findsOneWidget);
      });

      testWidgets('displays correctly on large tablet (iPad Pro)', (tester) async {
        // iPad Pro 12.9": 1024x1366
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should be significantly larger
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 1024.0);
        expect(videoPlayer.constraints?.maxHeight, 576.0); // 1024 * 9/16

        // Should show all controls and features
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
        expect(find.byKey(const Key('quality-selector')), findsOneWidget);
        expect(find.byKey(const Key('playback-speed-selector')), findsOneWidget);
        expect(find.byKey(const Key('subtitle-selector')), findsOneWidget);
      });

      testWidgets('handles tablet landscape orientation', (tester) async {
        // iPad in landscape: 1366x1024
        await tester.binding.setSurfaceSize(const Size(1366, 1024));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video should take full width in landscape
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 1366.0);
        expect(videoPlayer.constraints?.maxHeight, 768.0); // 1366 * 9/16

        // Should show sidebar layout on large tablets
        expect(find.byKey(const Key('video-sidebar')), findsOneWidget);
      });
    });

    group('Desktop and Large Screens', () {
      testWidgets('displays correctly on small desktop (1280x720)', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 720));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video player should be optimized for desktop viewing
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 1280.0);
        expect(videoPlayer.constraints?.maxHeight, 720.0); // 1280 * 9/16

        // Should show desktop-specific controls
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
        expect(find.byKey(const Key('keyboard-shortcuts-hint')), findsOneWidget);
      });

      testWidgets('displays correctly on large desktop (1920x1080)', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1920, 1080));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video should be large and immersive
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 1920.0);
        expect(videoPlayer.constraints?.maxHeight, 1080.0); // 1920 * 9/16

        // Should show full feature set
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
        expect(find.byKey(const Key('advanced-controls')), findsOneWidget);
      });

      testWidgets('handles ultra-wide displays (2560x1440)', (tester) async {
        await tester.binding.setSurfaceSize(const Size(2560, 1440));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video should not exceed reasonable size limits
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, lessThanOrEqualTo(1920.0)); // Cap at 1920
        expect(videoPlayer.constraints?.maxHeight, 1080.0); // Maintain 16:9
      });
    });

    group('Adaptive UI Elements', () {
      testWidgets('controls adapt to screen size', (tester) async {
        // Test on small phone
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Controls should be compact
        expect(find.byKey(const Key('compact-controls')), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);

        // Test on large tablet
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Controls should be expanded
        expect(find.byKey(const Key('expanded-controls')), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget); // Additional controls
        expect(find.byIcon(Icons.subtitles), findsOneWidget);
      });

      testWidgets('text scaling adapts to screen size', (tester) async {
        // Test on small phone
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final phoneTitle = tester.widget<Text>(
          find.text('Emergency Declaration - Hurricane Milton'),
        );
        expect(phoneTitle.style?.fontSize, lessThanOrEqualTo(16.0));

        // Test on large tablet
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final tabletTitle = tester.widget<Text>(
          find.text('Emergency Declaration - Hurricane Milton'),
        );
        expect(tabletTitle.style?.fontSize, greaterThanOrEqualTo(18.0));
      });

      testWidgets('touch targets meet accessibility requirements', (tester) async {
        // Test on smallest supported size
        await tester.binding.setSurfaceSize(const Size(320, 568));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // All interactive elements should be at least 44x44 points
        final playButton = tester.getSize(find.byIcon(Icons.play_arrow));
        expect(playButton.width, greaterThanOrEqualTo(44.0));
        expect(playButton.height, greaterThanOrEqualTo(44.0));

        final volumeButton = tester.getSize(find.byIcon(Icons.volume_up));
        expect(volumeButton.width, greaterThanOrEqualTo(44.0));
        expect(volumeButton.height, greaterThanOrEqualTo(44.0));
      });
    });

    group('Dynamic Content Adaptation', () {
      testWidgets('live video indicators adapt to screen size', (tester) async {
        // Small phone
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: liveVideo));
        await tester.pumpAndSettle();

        expect(find.text('LIVE'), findsOneWidget);
        final liveIndicator = tester.widget<Container>(
          find.byKey(const Key('live-indicator')),
        );
        expect(liveIndicator.constraints?.minHeight, 24.0);

        // Large tablet
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: liveVideo));
        await tester.pumpAndSettle();

        final tabletLiveIndicator = tester.widget<Container>(
          find.byKey(const Key('live-indicator')),
        );
        expect(tabletLiveIndicator.constraints?.minHeight, 32.0);
      });

      testWidgets('video quality options adapt to screen size', (tester) async {
        // Small phone - limited quality options
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('quality-selector')));
        await tester.pumpAndSettle();

        // Should show fewer options on small screens
        expect(find.text('360p'), findsOneWidget);
        expect(find.text('480p'), findsOneWidget);
        expect(find.text('720p'), findsOneWidget);
        expect(find.text('1080p'), findsNothing); // Not on small screens

        // Large tablet - all quality options
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('quality-selector')));
        await tester.pumpAndSettle();

        // Should show all options on large screens
        expect(find.text('360p'), findsOneWidget);
        expect(find.text('480p'), findsOneWidget);
        expect(find.text('720p'), findsOneWidget);
        expect(find.text('1080p'), findsOneWidget);
        expect(find.text('1440p'), findsOneWidget);
      });

      testWidgets('long video descriptions are truncated on small screens', (tester) async {
        final longDescVideo = VideoContent(
          id: 'long-desc-video',
          title: 'Video with Long Description',
          description: 'This is a very long description that should be truncated on small screens to maintain readability and proper layout without breaking the user interface design or causing overflow issues.',
          youtubeVideoId: 'long-desc-video-id',
          thumbnailUrl: 'https://img.youtube.com/vi/long-desc-video-id/mqdefault.jpg',
          uploadedAt: DateTime.now(),
          duration: const Duration(minutes: 5),
          uploader: 'Test Channel',
          isLive: false,
        );

        // Small phone
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: longDescVideo));
        await tester.pumpAndSettle();

        // Description should be truncated
        expect(find.byKey(const Key('video-description-truncated')), findsOneWidget);
        expect(find.text('...'), findsOneWidget);

        // Large tablet
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: longDescVideo));
        await tester.pumpAndSettle();

        // Full description should be visible
        expect(find.byKey(const Key('video-description-full')), findsOneWidget);
        expect(find.textContaining('This is a very long description'), findsOneWidget);
      });
    });

    group('Storm Screen Integration', () {
      testWidgets('video list adapts to different screen sizes', (tester) async {
        // Small phone
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo, useStormScreen: true));
        await tester.pumpAndSettle();

        // Should show compact list items
        expect(find.byKey(const Key('video-item-compact')), findsWidgets);

        // Large tablet
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo, useStormScreen: true));
        await tester.pumpAndSettle();

        // Should show expanded list items with thumbnails
        expect(find.byKey(const Key('video-item-expanded')), findsWidgets);
        expect(find.byKey(const Key('video-thumbnail')), findsWidgets);
      });

      testWidgets('emergency declarations section adapts', (tester) async {
        // Small phone
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo, useStormScreen: true));
        await tester.pumpAndSettle();

        // Section should be compact
        expect(find.byKey(const Key('emergency-section-compact')), findsOneWidget);

        // Large tablet
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo, useStormScreen: true));
        await tester.pumpAndSettle();

        // Section should be expanded with grid layout
        expect(find.byKey(const Key('emergency-section-expanded')), findsOneWidget);
        expect(find.byKey(const Key('video-grid')), findsOneWidget);
      });
    });

    group('Orientation Changes', () {
      testWidgets('handles orientation change smoothly', (tester) async {
        // Start in portrait
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Verify portrait layout
        expect(find.byKey(const Key('video-player-container')), findsOneWidget);

        // Change to landscape
        await tester.binding.setSurfaceSize(const Size(667, 375));
        await tester.pump();

        // Should adapt to landscape
        expect(find.byKey(const Key('video-player-container')), findsOneWidget);

        // Controls should reposition
        expect(find.byKey(const Key('video-controls')), findsOneWidget);

        // Change back to portrait
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pump();

        // Should restore portrait layout
        expect(find.byKey(const Key('video-player-container')), findsOneWidget);
      });

      testWidgets('maintains video state during orientation change', (tester) async {
        // Start in portrait
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing video
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Change orientation
        await tester.binding.setSurfaceSize(const Size(667, 375));
        await tester.pump();

        // Video should continue playing
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Change back
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pump();

        // Should still be playing
        expect(find.byIcon(Icons.pause), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles extremely wide aspect ratios', (tester) async {
        await tester.binding.setSurfaceSize(const Size(2000, 500));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should maintain reasonable dimensions
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, lessThanOrEqualTo(1920.0));
        expect(videoPlayer.constraints?.maxHeight, 1080.0);
      });

      testWidgets('handles extremely tall aspect ratios', (tester) async {
        await tester.binding.setSurfaceSize(const Size(500, 2000));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should maintain 16:9 aspect ratio
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 500.0);
        expect(videoPlayer.constraints?.maxHeight, 281.0); // 500 * 9/16
      });

      testWidgets('handles minimum supported size', (tester) async {
        await tester.binding.setSurfaceSize(const Size(300, 400));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should still display video
        expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 300.0);
        expect(videoPlayer.constraints?.maxHeight, 169.0); // 300 * 9/16
      });
    });

    group('Performance Considerations', () {
      testWidgets('performance on low-end devices', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should use lower quality by default on small screens
        expect(find.byKey(const Key('video-quality-low')), findsOneWidget);

        // Should reduce animations
        expect(find.byKey(const Key('reduced-animations')), findsOneWidget);

        // Should optimize memory usage
        expect(find.byKey(const Key('memory-optimized')), findsOneWidget);
      });

      testWidgets('performance on high-end devices', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1366));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should use higher quality by default on large screens
        expect(find.byKey(const Key('video-quality-high')), findsOneWidget);

        // Should enable animations
        expect(find.byKey(const Key('full-animations')), findsOneWidget);

        // Should use enhanced features
        expect(find.byKey(const Key('enhanced-features')), findsOneWidget);
      });
    });

    group('Accessibility and Responsive Design', () {
      testWidgets('maintains accessibility across screen sizes', (tester) async {
        // Test across multiple sizes
        final sizes = [
          const Size(375, 667), // Small phone
          const Size(768, 1024), // Tablet
          const Size(1920, 1080), // Desktop
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(createTestApp(video: testVideo));
          await tester.pumpAndSettle();

          // Check semantic labels are present
          expect(find.bySemanticsLabel('Play video'), findsOneWidget);
          expect(find.bySemanticsLabel('Pause video'), findsOneWidget);
          expect(find.bySemanticsLabel('Video player controls'), findsOneWidget);

          // Check contrast and readability
          expect(find.byKey(const Key('accessible-controls')), findsOneWidget);
        }
      });

      testWidgets('font scaling works correctly', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Test with larger font sizes
        await tester.binding.window.clearSemantics();
        await tester.binding.window
            .updateSemantics(TestSemantics.root(textScaleFactor: 1.5));
        await tester.pump();

        // Text should still be readable and fit
        expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);

        // Controls should remain accessible
        expect(find.bySemanticsLabel('Play video'), findsOneWidget);
      });
    });

    group('Multi-window and Split Screen', () {
      testWidgets('handles split-screen on tablets', (tester) async {
        // Simulate split-screen: half width
        await tester.binding.setSurfaceSize(const Size(512, 1024));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Video should adapt to smaller width
        final videoPlayer = tester.widget<Container>(
          find.byKey(const Key('video-player-container')),
        );
        expect(videoPlayer.constraints?.maxWidth, 512.0);
        expect(videoPlayer.constraints?.maxHeight, 288.0); // 512 * 9/16

        // Should still show all essential controls
        expect(find.byKey(const Key('video-controls')), findsOneWidget);
      });

      testWidgets('handles picture-in-picture mode', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Enable PiP
        await tester.tap(find.byKey(const Key('pip-button')));
        await tester.pump();

        // Video should be minimized
        expect(find.byKey(const Key('pip-video-player')), findsOneWidget);
        final pipPlayer = tester.widget<Container>(
          find.byKey(const Key('pip-video-player')),
        );
        expect(pipPlayer.constraints?.maxWidth, 200.0);
        expect(pipPlayer.constraints?.maxHeight, 112.0); // 200 * 9/16
      });
    });

    group('Dark Mode and Theme Adaptation', () {
      testWidgets('adapts to dark mode across screen sizes', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
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
        await tester.pumpAndSettle();

        // Should use dark theme colors
        expect(find.byKey(const Key('dark-video-player')), findsOneWidget);
        expect(find.byKey(const Key('dark-controls')), findsOneWidget);

        // Text should be readable in dark mode
        expect(find.text('Emergency Declaration - Hurricane Milton'), findsOneWidget);
      });
    });
  });
}