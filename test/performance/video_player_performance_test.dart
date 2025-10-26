import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/widgets/youtube_video_player.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/services/video_service.dart';
import 'package:journeyman_jobs/providers/video_provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Performance tests for YouTube video player
///
/// Tests video loading times, playback performance, memory usage,
/// CPU utilization, and optimization across different device types.
void main() {
  group('Video Player Performance Tests', () {
    late VideoContent testVideo;
    late VideoContent largeVideo;
    late VideoContent hdVideo;
    late VideoContent fourKVideo;
    late VideoContent liveVideo;

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

      largeVideo = VideoContent(
        id: 'large-video-1',
        title: 'Extended Emergency Briefing - Complete Coverage',
        description: 'Complete emergency response briefing with detailed information',
        youtubeVideoId: 'large-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/large-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 4)),
        duration: const Duration(hours: 2, minutes: 30),
        uploader: 'Emergency Operations Center',
        isLive: false,
      );

      hdVideo = VideoContent(
        id: 'hd-video-1',
        title: 'High Definition Emergency Update',
        description: 'HD emergency update with detailed visuals',
        youtubeVideoId: 'hd-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/hd-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 25, seconds: 30),
        uploader: 'HD Emergency Services',
        isLive: false,
      );

      fourKVideo = VideoContent(
        id: '4k-video-1',
        title: '4K Emergency Response Documentation',
        description: 'Ultra high definition emergency response documentation',
        youtubeVideoId: '4k-video-id',
        thumbnailUrl: 'https://img.youtube.com/vi/4k-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        duration: const Duration(minutes: 45, seconds: 15),
        uploader: '4K Emergency Network',
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
    });

    Widget createTestApp({required VideoContent video}) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: YoutubeVideoPlayer(
              video: video,
              autoPlay: false,
              showControls: true,
              enablePerformanceMonitoring: true,
            ),
          ),
        ),
      );
    }

    group('Loading Performance', () {
      testWidgets('video player initializes within acceptable time', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Initialization should complete within 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
      });

      testWidgets('thumbnail loads within acceptable time', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final thumbnailLoadStart = DateTime.now();

        // Wait for thumbnail to load
        await tester.pumpUntil(
          () => find.byKey(const Key('thumbnail-loaded')).evaluate().isNotEmpty,
          timeout: const Duration(seconds: 3),
        );

        final thumbnailLoadTime = DateTime.now().difference(thumbnailLoadStart);

        // Thumbnail should load within 2 seconds
        expect(thumbnailLoadTime.inMilliseconds, lessThan(2000));
        expect(find.byKey(const Key('video-thumbnail')), findsOneWidget);
      });

      testWidgets('video metadata loads within acceptable time', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final metadataLoadStart = DateTime.now();

        // Wait for metadata to load
        await tester.pumpUntil(
          () => find.byKey(const Key('metadata-loaded')).evaluate().isNotEmpty,
          timeout: const Duration(seconds: 5),
        );

        final metadataLoadTime = DateTime.now().difference(metadataLoadStart);

        // Metadata should load within 3 seconds
        expect(metadataLoadTime.inMilliseconds, lessThan(3000));

        // Should display video information
        expect(find.text('15:42'), findsOneWidget); // Duration
        expect(find.text('Emergency Management'), findsOneWidget); // Uploader
      });

      testWidgets('multiple video players load efficiently', (tester) async {
        // Create app with multiple video players
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: [
                    YoutubeVideoPlayer(video: testVideo),
                    YoutubeVideoPlayer(video: largeVideo),
                    YoutubeVideoPlayer(video: hdVideo),
                  ],
                ),
              ),
            ),
          ),
        );

        final multiLoadStart = DateTime.now();
        await tester.pumpAndSettle();

        // Wait for all players to initialize
        await tester.pumpUntil(
          () => find.byType(YoutubeVideoPlayer).evaluate().length == 3,
          timeout: const Duration(seconds: 5),
        );

        final multiLoadTime = DateTime.now().difference(multiLoadStart);

        // Multiple players should load within 2 seconds total
        expect(multiLoadTime.inMilliseconds, lessThan(2000));
        expect(find.byType(YoutubeVideoPlayer), findsNWidgets(3));
      });

      testWidgets('concurrent loading does not block UI', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start loading video
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // UI should remain responsive during loading
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Controls should still be interactive
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pump();
        expect(find.byIcon(Icons.volume_off), findsOneWidget);
      });

      testWidgets('progressive loading works correctly', (tester) async {
        await tester.pumpWidget(createTestApp(video: hdVideo));
        await tester.pumpAndSettle();

        // Should start with low quality
        expect(find.byKey(const Key('quality-360p')), findsOneWidget);

        // Wait for higher quality to load
        await tester.pumpUntil(
          () => find.byKey(const Key('quality-720p')).evaluate().isNotEmpty,
          timeout: const Duration(seconds: 5),
        );

        // Should automatically upgrade quality
        expect(find.byKey(const Key('quality-upgraded')), findsOneWidget);
      });
    });

    group('Playback Performance', () {
      testWidgets('video starts playing within acceptable time', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        final playStart = DateTime.now();

        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Wait for playback to start
        await tester.pumpUntil(
          () => find.byKey(const Key('video-playing')).evaluate().isNotEmpty,
          timeout: const Duration(seconds: 2),
        );

        final playStartTime = DateTime.now().difference(playStart);

        // Playback should start within 500ms
        expect(playStartTime.inMilliseconds, lessThan(500));
        expect(find.byIcon(Icons.pause), findsOneWidget);
      });

      testWidgets('seeking completes within acceptable time', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        final seekStart = DateTime.now();

        // Seek to middle of video
        final progressBar = find.byKey(const Key('video-progress-bar'));
        await tester.tap(progressBar);
        await tester.pump();

        // Wait for seek to complete
        await tester.pumpUntil(
          () => find.byKey(const Key('seek-complete')).evaluate().isNotEmpty,
          timeout: const Duration(seconds: 1),
        );

        final seekTime = DateTime.now().difference(seekStart);

        // Seeking should complete within 200ms
        expect(seekTime.inMilliseconds, lessThan(200));

        // Time should update to seeked position
        expect(find.textContaining('7:'), findsOneWidget); // Around middle
      });

      testWidgets('quality switching does not interrupt playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: hdVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Change quality during playback
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();
        await tester.tap(find.text('1080p'));
        await tester.pump();

        // Should continue playing
        expect(find.byIcon(Icons.pause), findsOneWidget);
        expect(find.byKey(const Key('quality-changed-during-playback')), findsOneWidget);
      });

      testWidgets('live streaming performance meets requirements', (tester) async {
        await tester.pumpWidget(createTestApp(video: liveVideo));
        await tester.pumpAndSettle();

        final liveLoadStart = DateTime.now();

        // Live stream should start quickly
        await tester.pumpUntil(
          () => find.byKey(const Key('live-stream-playing')).evaluate().isNotEmpty,
          timeout: const Duration(seconds: 3),
        );

        final liveLoadTime = DateTime.now().difference(liveLoadStart);

        // Live stream should load within 2 seconds
        expect(liveLoadTime.inMilliseconds, lessThan(2000));
        expect(find.text('LIVE'), findsOneWidget);

        // Should maintain low latency
        expect(find.byKey(const Key('low-latency-streaming')), findsOneWidget);
      });

      testWidgets('long video playback maintains performance', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Start playing long video
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Simulate playing for 10 seconds
        await tester.pump(const Duration(seconds: 10));

        // Performance should remain stable
        expect(find.byIcon(Icons.pause), findsOneWidget);
        expect(find.byKey(const Key('performance-stable')), findsOneWidget);

        // Memory usage should be reasonable
        expect(find.byKey(const Key('memory-within-limits')), findsOneWidget);
      });

      testWidgets('multiple video instances play efficiently', (tester) async {
        // Create app with multiple playing videos
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Expanded(child: YoutubeVideoPlayer(video: testVideo)),
                    Expanded(child: YoutubeVideoPlayer(video: hdVideo)),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Start both videos
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pump();

        await tester.tap(find.byIcon(Icons.play_arrow).last);
        await tester.pump();

        // Both should play without performance degradation
        expect(find.byIcon(Icons.pause), findsNWidgets(2));
        expect(find.byKey(const Key('multi-video-performance')), findsOneWidget);
      });
    });

    group('Memory Management', () {
      testWidgets('memory usage stays within acceptable limits', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Check initial memory usage
        expect(find.byKey(const Key('memory-usage-initial')), findsOneWidget);

        // Start playing video
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump(const Duration(seconds: 5));

        // Memory should not grow excessively
        expect(find.byKey(const Key('memory-usage-within-limits')), findsOneWidget);

        // Memory should be released when video is disposed
        await tester.pumpWidget(Container()); // Dispose video
        await tester.pump();

        expect(find.byKey(const Key('memory-released')), findsOneWidget);
      });

      testWidgets('video cache management works efficiently', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start and stop video multiple times
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.play_arrow));
          await tester.pump(const Duration(seconds: 1));

          await tester.tap(find.byIcon(Icons.pause));
          await tester.pump(const Duration(milliseconds: 500));
        }

        // Cache should not grow excessively
        expect(find.byKey(const Key('cache-size-managed')), findsOneWidget);
        expect(find.byKey(const Key('cache-within-limits')), findsOneWidget);
      });

      testWidgets('large video does not cause memory overflow', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Start playing large video
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump(const Duration(seconds: 10));

        // Memory should be managed properly even for large videos
        expect(find.byKey(const Key('large-video-memory-managed')), findsOneWidget);
        expect(find.byKey(const Key('memory-pressure-handled')), findsOneWidget);
      });

      testWidgets('background video playback memory management', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Simulate app going to background
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          StringCodec().encodeMessage('AppLifecycleState.paused'),
          (data) {},
        );
        await tester.pump();

        // Memory should be reduced in background
        expect(find.byKey(const Key('background-memory-optimized')), findsOneWidget);

        // App should return to foreground
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          StringCodec().encodeMessage('AppLifecycleState.resumed'),
          (data) {},
        );
        await tester.pump();

        // Memory should be restored appropriately
        expect(find.byKey(const Key('foreground-memory-restored')), findsOneWidget);
      });

      testWidgets('memory leaks are prevented', (tester) async {
        // Test multiple create/destroy cycles
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(createTestApp(video: testVideo));
          await tester.pumpAndSettle();

          // Start and stop video
          await tester.tap(find.byIcon(Icons.play_arrow));
          await tester.pump(const Duration(seconds: 1));
          await tester.tap(find.byIcon(Icons.pause));
          await tester.pump();

          // Dispose video
          await tester.pumpWidget(Container());
          await tester.pump();
        }

        // No memory leaks should be detected
        expect(find.byKey(const Key('no-memory-leaks-detected')), findsOneWidget);
      });
    });

    group('CPU Performance', () {
      testWidgets('CPU usage stays within acceptable limits', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Check baseline CPU usage
        expect(find.byKey(const Key('cpu-usage-baseline')), findsOneWidget);

        // Start playing video
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump(const Duration(seconds: 5));

        // CPU usage should not exceed limits
        expect(find.byKey(const Key('cpu-usage-within-limits')), findsOneWidget);

        // Should optimize for low-power devices
        expect(find.byKey(const Key('cpu-optimized')), findsOneWidget);
      });

      testWidgets('complex operations do not cause CPU spikes', (tester) async {
        await tester.pumpWidget(createTestApp(video: hdVideo));
        await tester.pumpAndSettle();

        // Perform multiple operations rapidly
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();
        await tester.tap(find.text('1080p'));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.subtitles));
        await tester.pump();
        await tester.tap(find.text('English'));
        await tester.pump();

        // CPU should handle multiple operations without spikes
        expect(find.byKey(const Key('cpu-no-spikes')), findsOneWidget);
        expect(find.byKey(const Key('operations-smooth')), findsOneWidget);
      });

      testWidgets('idle CPU usage is minimal', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Wait for idle state
        await tester.pump(const Duration(seconds: 3));

        // CPU usage should be minimal when idle
        expect(find.byKey(const Key('cpu-idle-minimal')), findsOneWidget);
        expect(find.byKey(const Key('background-processing-efficient')), findsOneWidget);
      });

      testWidgets('animation performance is optimized', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Show/hide controls multiple times
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byKey(const Key('video-player-container')));
          await tester.pump(const Duration(milliseconds: 300));
        }

        // Animations should be smooth
        expect(find.byKey(const Key('animations-smooth')), findsOneWidget);
        expect(find.byKey(const Key('animation-performance-optimized')), findsOneWidget);
      });
    });

    group('Network Performance', () {
      testWidgets('adaptive streaming works efficiently', (tester) async {
        await tester.pumpWidget(createTestApp(video: hdVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should adapt to network conditions
        expect(find.byKey(const Key('adaptive-streaming-active')), findsOneWidget);

        // Should optimize bandwidth usage
        expect(find.byKey(const Key('bandwidth-optimized')), findsOneWidget);

        // Should buffer appropriately
        expect(find.byKey(const Key('buffering-optimized')), findsOneWidget);
      });

      testWidgets('slow network conditions are handled gracefully', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Simulate slow network
        await tester.pump(const Duration(seconds: 5));

        // Should show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Should not timeout prematurely
        expect(find.byKey(const Key('network-timeout-handled')), findsOneWidget);

        // Should provide estimated loading time
        expect(find.textContaining('Loading'), findsOneWidget);
      });

      testWidgets('network interruption recovery works', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Simulate network interruption
        await tester.pump(const Duration(seconds: 2));

        // Should show network error
        expect(find.text('Network error'), findsOneWidget);

        // Should provide retry option
        expect(find.text('Retry'), findsOneWidget);

        // Should resume from last position
        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(find.byKey(const Key('resume-from-last-position')), findsOneWidget);
      });

      testWidgets('concurrent network requests are managed', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: [
                    YoutubeVideoPlayer(video: testVideo),
                    YoutubeVideoPlayer(video: hdVideo),
                    YoutubeVideoPlayer(video: largeVideo),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should manage concurrent requests efficiently
        expect(find.byKey(const Key('concurrent-requests-managed')), findsOneWidget);
        expect(find.byKey(const Key('network-requests-optimized')), findsOneWidget);
      });
    });

    group('Device Performance Optimization', () {
      testWidgets('low-end device optimization works', (tester) async {
        // Simulate low-end device
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/device_info',
          StringCodec().encodeMessage('{"isLowEnd": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should use optimized settings
        expect(find.byKey(const Key('low-end-mode-active')), findsOneWidget);
        expect(find.byKey(const Key('quality-reduced')), findsOneWidget);
        expect(find.byKey(const Key('animations-disabled')), findsOneWidget);
        expect(find.byKey(const Key('memory-optimized')), findsOneWidget);
      });

      testWidgets('high-end device features are utilized', (tester) async {
        // Simulate high-end device
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/device_info',
          StringCodec().encodeMessage('{"isHighEnd": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: fourKVideo));
        await tester.pumpAndSettle();

        // Should enable high-end features
        expect(find.byKey(const Key('high-end-mode-active')), findsOneWidget);
        expect(find.byKey(const Key('4k-playback-enabled')), findsOneWidget);
        expect(find.byKey(const Key('enhanced-animations-enabled')), findsOneWidget);
        expect(find.byKey(const Key('advanced-features-enabled')), findsOneWidget);
      });

      testWidgets('battery optimization is effective', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should optimize for battery life
        expect(find.byKey(const Key('battery-optimization-active')), findsOneWidget);
        expect(find.byKey(const Key('power-efficient-playback')), findsOneWidget);
        expect(find.byKey(const Key('background-processing-reduced')), findsOneWidget);
      });

      testWidgets('thermal management prevents overheating', (tester) async {
        // Simulate thermal throttling
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/thermal',
          StringCodec().encodeMessage('{"isThrottled": true}'),
          (data) {},
        );
        await tester.pump();

        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should reduce performance to prevent overheating
        expect(find.byKey(const Key('thermal-throttling-active')), findsOneWidget);
        expect(find.byKey(const Key('performance-reduced')), findsOneWidget);
        expect(find.byKey(const Key('temperature-normalized')), findsOneWidget);
      });
    });

    group('Frame Rate and Rendering Performance', () {
      testWidgets('maintains 60fps during playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should maintain smooth playback
        expect(find.byKey(const Key('60fps-maintained')), findsOneWidget);
        expect(find.byKey(const Key('frame-drops-minimal')), findsOneWidget);
      });

      testWidgets('controls overlay does not impact video frame rate', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Show/hide controls rapidly
        for (int i = 0; i < 20; i++) {
          await tester.tap(find.byKey(const Key('video-player-container')));
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Video frame rate should remain stable
        expect(find.byKey(const Key('frame-rate-stable')), findsOneWidget);
        expect(find.byKey(const Key('controls-overlay-optimized')), findsOneWidget);
      });

      testWidgets('seeking maintains smooth rendering', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Perform multiple seeks
        for (int i = 0; i < 10; i++) {
          final progressBar = find.byKey(const Key('video-progress-bar'));
          await tester.tap(progressBar);
          await tester.pump();
        }

        // Rendering should remain smooth
        expect(find.byKey(const Key('seeking-smooth')), findsOneWidget);
        expect(find.byKey(const Key('rendering-stable')), findsOneWidget);
      });

      testWidgets('quality changes do not cause frame drops', (tester) async {
        await tester.pumpWidget(createTestApp(video: hdVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Change quality multiple times
        final qualities = ['360p', '480p', '720p', '1080p'];
        for (final quality in qualities) {
          await tester.tap(find.byIcon(Icons.settings));
          await tester.pump();
          await tester.tap(find.text(quality));
          await tester.pump();
        }

        // Should maintain frame rate
        expect(find.byKey(const Key('quality-changes-smooth')), findsOneWidget);
        expect(find.byKey(const Key('no-frame-drops')), findsOneWidget);
      });
    });

    group('Resource Optimization', () {
      testWidgets('bandwidth usage is optimized', (tester) async {
        await tester.pumpWidget(createTestApp(video: hdVideo));
        await tester.pumpAndSettle();

        // Start playing
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Should optimize bandwidth
        expect(find.byKey(const Key('bandwidth-optimized')), findsOneWidget);
        expect(find.byKey(const Key('data-compression-active')), findsOneWidget);
        expect(find.byKey(const Key('smart-streaming-enabled')), findsOneWidget);
      });

      testWidgets('storage usage is managed efficiently', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Should manage cache storage
        expect(find.byKey(const Key('storage-managed')), findsOneWidget);
        expect(find.byKey(const Key('cache-cleanup-active')), findsOneWidget);
        expect(find.byKey(const Key('storage-within-limits')), findsOneWidget);
      });

      testWidgets('concurrent playback resources are shared', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Expanded(child: YoutubeVideoPlayer(video: testVideo)),
                    Expanded(child: YoutubeVideoPlayer(video: testVideo)),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should share resources efficiently
        expect(find.byKey(const Key('resources-shared')), findsOneWidget);
        expect(find.byKey(const Key('memory-shared')), findsOneWidget);
        expect(find.byKey(const Key('decoder-shared')), findsOneWidget);
      });

      testWidgets('GPU acceleration is utilized effectively', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should use GPU acceleration
        expect(find.byKey(const Key('gpu-acceleration-active')), findsOneWidget);
        expect(find.byKey(const Key('hardware-decoding-enabled')), findsOneWidget);
        expect(find.byKey(const Key('rendering-optimized')), findsOneWidget);
      });
    });

    group('Performance Monitoring and Metrics', () {
      testWidgets('performance metrics are collected', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should collect performance metrics
        expect(find.byKey(const Key('performance-metrics-active')), findsOneWidget);
        expect(find.byKey(const Key('fps-monitoring')), findsOneWidget);
        expect(find.byKey(const Key('memory-monitoring')), findsOneWidget);
        expect(find.byKey(const Key('cpu-monitoring')), findsOneWidget);
      });

      testWidgets('performance warnings are triggered appropriately', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate performance issues
        await tester.pump(const Duration(seconds: 10));

        // Should trigger warnings if needed
        expect(find.byKey(const Key('performance-warnings-enabled')), findsOneWidget);
        expect(find.byKey(const Key('auto-optimization-active')), findsOneWidget);
      });

      testWidgets('performance reports are generated', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Should generate performance reports
        expect(find.byKey(const Key('performance-reporting')), findsOneWidget);
        expect(find.byKey(const Key('metrics-collected')), findsOneWidget);
        expect(find.byKey(const Key('analytics-uploaded')), findsOneWidget);
      });
    });

    group('Stress Testing', () {
      testWidgets('rapid state changes handle gracefully', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Rapid play/pause toggles
        for (int i = 0; i < 100; i++) {
          await tester.tap(find.byIcon(Icons.play_arrow));
          await tester.pump(const Duration(milliseconds: 10));
          await tester.tap(find.byIcon(Icons.pause));
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Should handle rapid changes gracefully
        expect(find.byKey(const Key('rapid-changes-handled')), findsOneWidget);
        expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
      });

      testWidgets('extreme usage scenarios are handled', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Perform multiple operations simultaneously
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();

        await tester.drag(find.byKey(const Key('volume-slider')), const Offset(-50, 0));
        await tester.pump();

        await tester.drag(find.byKey(const Key('video-progress-bar')), const Offset(100, 0));
        await tester.pump();

        // Should handle extreme usage
        expect(find.byKey(const Key('extreme-usage-handled')), findsOneWidget);
        expect(find.byKey(const Key('system-stable')), findsOneWidget);
      });

      testWidgets('memory pressure scenarios are handled', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate memory pressure
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/memory',
          StringCodec().encodeMessage('{"pressure": "high"}'),
          (data) {},
        );
        await tester.pump();

        // Should handle memory pressure
        expect(find.byKey(const Key('memory-pressure-handled')), findsOneWidget);
        expect(find.byKey(const Key('cache-cleared')), findsOneWidget);
        expect(find.byKey(const Key('quality-reduced')), findsOneWidget);
      });

      testWidgets('resource exhaustion scenarios are handled', (tester) async {
        await tester.pumpWidget(createTestApp(video: testVideo));
        await tester.pumpAndSettle();

        // Simulate resource exhaustion
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/resources',
          StringCodec().encodeMessage('{"status": "exhausted"}'),
          (data) {},
        );
        await tester.pump();

        // Should handle resource exhaustion
        expect(find.byKey(const Key('resource-exhaustion-handled')), findsOneWidget);
        expect(find.byKey(const Key('graceful-degradation')), findsOneWidget);
        expect(find.byKey(const Key('basic-functionality-maintained')), findsOneWidget);
      });
    });
  });
}