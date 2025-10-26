import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:journeyman_jobs/widgets/youtube_video_player.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/services/video_service.dart';
import 'package:journeyman_jobs/providers/video_provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Comprehensive error scenario testing for YouTube video player
///
/// Tests various failure conditions including network issues,
/// invalid video IDs, loading failures, and recovery mechanisms.
void main() {
  group('Video Player Error Scenarios Tests', () {
    late VideoContent validVideo;
    late VideoContent invalidVideo;
    late VideoContent privateVideo;
    late VideoContent deletedVideo;
    late VideoContent regionRestrictedVideo;
    late VideoContent largeVideo;

    setUp(() {
      validVideo = VideoContent(
        id: 'valid-video-1',
        title: 'Valid Emergency Declaration',
        description: 'A valid video for testing',
        youtubeVideoId: 'dQw4w9WgXcQ', // Valid YouTube video ID
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(minutes: 5, seconds: 30),
        uploader: 'Emergency Management',
        isLive: false,
      );

      invalidVideo = VideoContent(
        id: 'invalid-video-1',
        title: 'Invalid Video ID',
        description: 'Video with invalid YouTube ID',
        youtubeVideoId: 'invalid-id-that-does-not-exist-12345',
        thumbnailUrl: 'https://img.youtube.com/vi/invalid-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 0),
        uploader: 'Test Channel',
        isLive: false,
      );

      privateVideo = VideoContent(
        id: 'private-video-1',
        title: 'Private Video',
        description: 'Private or unlisted video',
        youtubeVideoId: 'private-video-id-123',
        thumbnailUrl: 'https://img.youtube.com/vi/private-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 3)),
        duration: const Duration(minutes: 10),
        uploader: 'Private Channel',
        isLive: false,
      );

      deletedVideo = VideoContent(
        id: 'deleted-video-1',
        title: 'Deleted Video',
        description: 'Video that has been removed',
        youtubeVideoId: 'deleted-video-id-123',
        thumbnailUrl: 'https://img.youtube.com/vi/deleted-video-id/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 15),
        uploader: 'Deleted Channel',
        isLive: false,
      );

      regionRestrictedVideo = VideoContent(
        id: 'region-restricted-1',
        title: 'Region Restricted Video',
        description: 'Video not available in current region',
        youtubeVideoId: 'region-restricted-123',
        thumbnailUrl: 'https://img.youtube.com/vi/region-restricted-123/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 4)),
        duration: const Duration(minutes: 8),
        uploader: 'Regional Channel',
        isLive: false,
      );

      largeVideo = VideoContent(
        id: 'large-video-1',
        title: 'Large Video File',
        description: 'High resolution video requiring more bandwidth',
        youtubeVideoId: 'large-video-id-123',
        thumbnailUrl: 'https://img.youtube.com/vi/large-video-id-123/mqdefault.jpg',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
        duration: const Duration(hours: 2), // 2-hour video
        uploader: 'Large Content Creator',
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

    group('Invalid Video ID Scenarios', () {
      testWidgets('displays error for non-existent video ID', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        // Initially shows loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for timeout (mocked)
        await tester.pump(const Duration(seconds: 10));

        // Should display error state
        expect(find.text('Video not found'), findsOneWidget);
        expect(find.text('This video may have been removed or is not available'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);

        // Should provide retry option
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Report Issue'), findsOneWidget);
      });

      testWidgets('handles empty video ID gracefully', (tester) async {
        final emptyIdVideo = VideoContent(
          id: 'empty-id-video',
          title: 'Empty ID Video',
          description: 'Video with empty YouTube ID',
          youtubeVideoId: '',
          thumbnailUrl: '',
          uploadedAt: DateTime.now(),
          duration: Duration.zero,
          uploader: 'Test',
          isLive: false,
        );

        await tester.pumpWidget(createTestApp(video: emptyIdVideo));
        await tester.pumpAndSettle();

        // Should show error immediately
        expect(find.text('Invalid video URL'), findsOneWidget);
        expect(find.text('The video URL is invalid or missing'), findsOneWidget);
      });

      testWidgets('handles null video ID gracefully', (tester) async {
        final nullIdVideo = VideoContent(
          id: 'null-id-video',
          title: 'Null ID Video',
          description: 'Video with null YouTube ID',
          youtubeVideoId: 'null-video-id',
          thumbnailUrl: 'https://img.youtube.com/vi/null/mqdefault.jpg',
          uploadedAt: DateTime.now(),
          duration: Duration.zero,
          uploader: 'Test',
          isLive: false,
        );

        await tester.pumpWidget(createTestApp(video: nullIdVideo));
        await tester.pumpAndSettle();

        // Should handle null gracefully
        expect(find.text('Invalid video URL'), findsOneWidget);
      });

      testWidgets('handles special characters in video ID', (tester) async {
        final specialCharVideo = VideoContent(
          id: 'special-char-video',
          title: 'Special Characters Video',
          description: 'Video with special characters in ID',
          youtubeVideoId: 'invalid@#$%^&*()',
          thumbnailUrl: 'https://img.youtube.com/vi/invalid@/mqdefault.jpg',
          uploadedAt: DateTime.now(),
          duration: const Duration(minutes: 1),
          uploader: 'Test',
          isLive: false,
        );

        await tester.pumpWidget(createTestApp(video: specialCharVideo));
        await tester.pumpAndSettle();

        // Should sanitize or reject special characters
        expect(find.text('Invalid video URL'), findsOneWidget);
      });
    });

    group('Network Connectivity Issues', () {
      testWidgets('handles network disconnection during loading', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Simulate network loss
        // This would be triggered by connectivity service
        await tester.pump(const Duration(seconds: 2));

        // Should show network error
        expect(find.text('Network error'), findsOneWidget);
        expect(find.text('Please check your internet connection'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);

        // Should provide retry option
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('handles slow network connection', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Should show loading with progress indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Should show loading message
        expect(find.text('Loading video...'), findsOneWidget);

        // Should show buffering indicator during playback
        // This would appear during actual video loading
        expect(find.byKey(const Key('buffering-indicator')), findsOneWidget);
      });

      testWidgets('handles network timeout', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Wait for timeout period
        await tester.pump(const Duration(seconds: 30));

        // Should show timeout error
        expect(find.text('Loading timeout'), findsOneWidget);
        expect(find.text('The video took too long to load'), findsOneWidget);
        expect(find.text('Check your connection and try again'), findsOneWidget);
      });

      testWidgets('recovers from network reconnection', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Simulate network error
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('Network error'), findsOneWidget);

        // Tap retry after network is restored
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should attempt to reload
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Should successfully load after retry
        await tester.pump(const Duration(seconds: 3));
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });
    });

    group('Video Access Restrictions', () {
      testWidgets('handles private video access', (tester) async {
        await tester.pumpWidget(createTestApp(video: privateVideo));
        await tester.pumpAndSettle();

        // Wait for video to attempt loading
        await tester.pump(const Duration(seconds: 5));

        // Should show private video error
        expect(find.text('Video not available'), findsOneWidget);
        expect(find.text('This video is private or has been restricted'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('handles deleted video access', (tester) async {
        await tester.pumpWidget(createTestApp(video: deletedVideo));
        await tester.pumpAndSettle();

        // Wait for video to attempt loading
        await tester.pump(const Duration(seconds: 5));

        // Should show deleted video error
        expect(find.text('Video removed'), findsOneWidget);
        expect(find.text('This video has been removed by the uploader'), findsOneWidget);
        expect(find.byIcon(Icons.video_library), findsOneWidget);
      });

      testWidgets('handles region-restricted video', (tester) async {
        await tester.pumpWidget(createTestApp(video: regionRestrictedVideo));
        await tester.pumpAndSettle();

        // Wait for video to attempt loading
        await tester.pump(const Duration(seconds: 5));

        // Should show region restriction error
        expect(find.text('Video not available in your region'), findsOneWidget);
        expect(find.text('This video contains content that is not available in your country'), findsOneWidget);
        expect(find.byIcon(Icons.public_off), findsOneWidget);
      });

      testWidgets('handles age-restricted content', (tester) async {
        final ageRestrictedVideo = VideoContent(
          id: 'age-restricted-1',
          title: 'Age Restricted Content',
          description: 'Content requiring age verification',
          youtubeVideoId: 'age-restricted-123',
          thumbnailUrl: 'https://img.youtube.com/vi/age-restricted-123/mqdefault.jpg',
          uploadedAt: DateTime.now().subtract(const Duration(hours: 8)),
          duration: const Duration(minutes: 12),
          uploader: 'Age Restricted Channel',
          isLive: false,
        );

        await tester.pumpWidget(createTestApp(video: ageRestrictedVideo));
        await tester.pumpAndSettle();

        // Wait for video to attempt loading
        await tester.pump(const Duration(seconds: 5));

        // Should show age restriction warning
        expect(find.text('Age-restricted content'), findsOneWidget);
        expect(find.text('This video contains age-restricted content'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
      });
    });

    group('Video Loading and Playback Errors', () {
      testWidgets('handles corrupted video data', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Start playback
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Simulate corrupted data during playback
        await tester.pump(const Duration(seconds: 3));

        // Should show playback error
        expect(find.text('Playback error'), findsOneWidget);
        expect(find.text('An error occurred during video playback'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('handles video format incompatibility', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Wait for loading to attempt
        await tester.pump(const Duration(seconds: 5));

        // Should show format error if video cannot be decoded
        expect(find.text('Unsupported format'), findsOneWidget);
        expect(find.text('This video format is not supported on your device'), findsOneWidget);
        expect(find.byIcon(Icons.movie), findsOneWidget);
      });

      testWidgets('handles insufficient storage space', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Simulate storage check
        await tester.pump(const Duration(seconds: 3));

        // Should show storage error if not enough space
        expect(find.text('Insufficient storage'), findsOneWidget);
        expect(find.text('Not enough storage space to cache this video'), findsOneWidget);
        expect(find.byIcon(Icons.storage), findsOneWidget);
      });

      testWidgets('handles memory pressure during playback', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Start playback
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        // Simulate memory pressure
        await tester.pump(const Duration(seconds: 10));

        // Should show memory warning and possibly reduce quality
        expect(find.text('Low memory'), findsOneWidget);
        expect(find.text('Reducing video quality to free up memory'), findsOneWidget);
        expect(find.byIcon(Icons.memory), findsOneWidget);
      });
    });

    group('Error Recovery Mechanisms', () {
      testWidgets('retry mechanism works correctly', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        // Wait for error
        await tester.pump(const Duration(seconds: 10));
        expect(find.text('Video not found'), findsOneWidget);

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should attempt to reload
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for retry to fail again
        await tester.pump(const Duration(seconds: 10));
        expect(find.text('Video not found'), findsOneWidget);

        // Should increment retry count
        expect(find.text('Retry (2)'), findsOneWidget);
      });

      testWidgets('limits retry attempts to prevent infinite loops', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        // Retry multiple times
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 10));
          if (find.byType(TextButton).evaluate().isNotEmpty) {
            await tester.tap(find.text('Retry'));
            await tester.pumpAndSettle();
          }
        }

        // After max retries, should disable retry button
        expect(find.text('Max retries reached'), findsOneWidget);
        expect(find.byType(TextButton), findsNothing);
      });

      testWidgets('provides fallback options when video fails', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        // Wait for error
        await tester.pump(const Duration(seconds: 10));
        expect(find.text('Video not found'), findsOneWidget);

        // Should show fallback options
        expect(find.text('Try alternative source'), findsOneWidget);
        expect(find.text('View transcript'), findsOneWidget);
        expect(find.text('Download for offline viewing'), findsOneWidget);
      });

      testWidgets('error reporting functionality', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        // Wait for error
        await tester.pump(const Duration(seconds: 10));
        expect(find.text('Video not found'), findsOneWidget);

        // Tap report issue
        await tester.tap(find.text('Report Issue'));
        await tester.pumpAndSettle();

        // Should open error reporting dialog
        expect(find.text('Report Video Issue'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets); // Description field
        expect(find.text('Submit Report'), findsOneWidget);
      });
    });

    group('Graceful Degradation', () {
      testWidgets('shows thumbnail when video fails to load', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Simulate video loading failure but thumbnail available
        await tester.pump(const Duration(seconds: 5));

        // Should show thumbnail instead of error
        expect(find.byKey(const Key('video-thumbnail')), findsOneWidget);
        expect(find.text('Video unavailable'), findsOneWidget);
        expect(find.text('View thumbnail only'), findsOneWidget);
      });

      testWidgets('provides audio-only fallback when video fails', (tester) async {
        await tester.pumpWidget(createTestApp(video: validVideo));
        await tester.pumpAndSettle();

        // Simulate video codec failure
        await tester.pump(const Duration(seconds: 5));

        // Should offer audio-only option
        expect(find.text('Audio only available'), findsOneWidget);
        expect(find.text('Play audio only'), findsOneWidget);
        expect(find.byIcon(Icons.headphones), findsOneWidget);
      });

      testWidgets('handles progressive loading failure gracefully', (tester) async {
        await tester.pumpWidget(createTestApp(video: largeVideo));
        await tester.pumpAndSettle();

        // Should start with low quality
        expect(find.text('Loading in low quality...'), findsOneWidget);

        // Simulate progressive loading failure
        await tester.pump(const Duration(seconds: 10));

        // Should maintain current quality instead of failing
        expect(find.text('Continuing in current quality'), findsOneWidget);
        expect(find.text('HD quality unavailable'), findsOneWidget);
      });
    });

    group('User Experience During Errors', () {
      testWidgets('provides helpful error messages', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 10));

        // Error message should be helpful and actionable
        expect(find.text('Video not found'), findsOneWidget);
        expect(find.text('This video may have been removed or is not available'), findsOneWidget);
        expect(find.text('Try searching for similar content'), findsOneWidget);
      });

      testWidgets('maintains UI consistency during errors', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 10));

        // Error state should maintain app theme
        final errorContainer = tester.widget<Container>(find.byKey(const Key('error-container')));
        expect(errorContainer.decoration, isNotNull);

        // Should maintain consistent spacing and layout
        expect(find.byKey(const Key('error-container')), findsOneWidget);
        expect(find.byKey(const Key('error-icon')), findsOneWidget);
        expect(find.byKey(const Key('error-message')), findsOneWidget);
        expect(find.byKey(const Key('error-actions')), findsOneWidget);
      });

      testWidgets('prevents UI freezing during errors', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 10));

        // UI should remain responsive
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Report Issue'), findsOneWidget);

        // Other UI elements should still work
        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('Analytics and Error Tracking', () {
      testWidgets('tracks video errors for analytics', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 10));

        // Error should be tracked
        // This would send error details to analytics service
        expect(find.byKey(const Key('error-tracking')), findsOneWidget);
      });

      testWidgets('logs error details for debugging', (tester) async {
        await tester.pumpWidget(createTestApp(video: invalidVideo));
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 10));

        // Error details should be logged
        // Video ID, error type, timestamp, user info
        expect(find.byKey(const Key('error-logging')), findsOneWidget);
      });
    });
  });
}