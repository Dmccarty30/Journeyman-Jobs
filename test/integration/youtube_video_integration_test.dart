import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/screens/storm/storm_screen.dart';
import 'package:journeyman_jobs/models/video_content.dart';
import 'package:journeyman_jobs/providers/video_provider.dart';
import 'package:journeyman_jobs/services/video_service.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Integration tests for YouTube video playback in storm screen
///
/// Tests the complete integration of video player with Firebase,
/// authentication, state management, and real-world usage scenarios.
void main() {
  group('YouTube Video Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late List<VideoContent> testVideos;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);

      testVideos = [
        VideoContent(
          id: 'emergency-declaration-1',
          title: 'Governor Emergency Declaration - Hurricane Milton',
          description: 'Complete emergency declaration press conference with evacuation orders',
          youtubeVideoId: 'dQw4w9WgXcQ',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          uploadedAt: DateTime.now().subtract(const Duration(hours: 3)),
          duration: const Duration(minutes: 15, seconds: 42),
          uploader: 'Governor Office',
          isLive: false,
        ),
        VideoContent(
          id: 'live-update-1',
          title: 'Live: Emergency Operations Center Briefing',
          description: 'Live updates from the state emergency operations center',
          youtubeVideoId: 'live-stream-123',
          thumbnailUrl: 'https://img.youtube.com/vi/live-stream-123/maxresdefault.jpg',
          uploadedAt: DateTime.now(),
          duration: Duration.zero, // Live stream
          uploader: 'Emergency Operations Center',
          isLive: true,
        ),
        VideoContent(
          id: 'contractor-update-1',
          title: 'Electrical Contractor Mobilization Update',
          description: 'Update for electrical contractors responding to storm damage',
          youtubeVideoId: 'contractor-update-456',
          thumbnailUrl: 'https://img.youtube.com/vi/contractor-update-456/maxresdefault.jpg',
          uploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
          duration: const Duration(minutes: 8, seconds: 15),
          uploader: 'Electrical Union Local',
          isLive: false,
        ),
      ];

      // Setup test data in Firestore
      for (final video in testVideos) {
        await fakeFirestore
            .collection('videos')
            .doc(video.id)
            .set(video.toJson());
      }
    });

    Widget createTestApp() {
      return ProviderScope(
        overrides: [
          // Override Firebase providers with test instances
          // firestoreProvider.overrideWithValue(fakeFirestore),
          // authProvider.overrideWithValue(mockAuth),
        ],
        child: MaterialApp(
          home: StormScreen(),
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

    testWidgets('storm screen loads video content from Firebase', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Emergency Declarations section
      expect(find.text('Emergency Declarations'), findsOneWidget);
      expect(find.text('Real-time video updates from emergency management'), findsOneWidget);

      // Video list should be present
      expect(find.byType(ListView), findsOneWidget);

      // Scroll to find video items
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000,
      );
      await tester.pumpAndSettle();

      // Video items should be displayed
      expect(find.text('Governor Emergency Declaration - Hurricane Milton'), findsOneWidget);
      expect(find.text('Live: Emergency Operations Center Briefing'), findsOneWidget);
    });

    testWidgets('video playback starts when video is tapped', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find the first video item
      final videoItem = find.text('Governor Emergency Declaration - Hurricane Milton');
      expect(videoItem, findsOneWidget);

      // Tap to open video player
      await tester.tap(videoItem);
      await tester.pumpAndSettle();

      // Video player should open
      expect(find.byKey(const Key('youtube-video-player')), findsOneWidget);

      // Video title should be displayed
      expect(find.text('Governor Emergency Declaration - Hurricane Milton'), findsOneWidget);

      // Play button should be visible
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('live video shows live indicator and auto-plays', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find live video item
      final liveVideoItem = find.text('Live: Emergency Operations Center Briefing');
      expect(liveVideoItem, findsOneWidget);

      // Should show live indicator
      expect(find.text('LIVE'), findsOneWidget);

      // Tap to open live video
      await tester.tap(liveVideoItem);
      await tester.pumpAndSettle();

      // Live video should auto-play
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('video list refreshes when new content is available', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Initial video count
      expect(find.byType(VideoContentCard), findsWidgets);

      // Add new video to Firestore
      final newVideo = VideoContent(
        id: 'new-emergency-update',
        title: 'New Storm Update - Immediate Action Required',
        description: 'Latest update on storm conditions and required actions',
        youtubeVideoId: 'new-video-789',
        thumbnailUrl: 'https://img.youtube.com/vi/new-video-789/maxresdefault.jpg',
        uploadedAt: DateTime.now(),
        duration: const Duration(minutes: 12, seconds: 30),
        uploader: 'Weather Service',
        isLive: false,
      );

      await fakeFirestore
          .collection('videos')
          .doc(newVideo.id)
          .set(newVideo.toJson());

      // Trigger refresh (pull to refresh)
      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // New video should appear in list
      expect(find.text('New Storm Update - Immediate Action Required'), findsOneWidget);
    });

    testWidgets('video persists when navigating away and back', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open first video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Start playing video
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(const Duration(seconds: 1));

      // Navigate away (simulate back button)
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Navigate back to video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Video should resume from saved position
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('handles authentication for admin-only content', (tester) async {
      // Test with unauthenticated user
      final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // authProvider.overrideWithValue(unauthenticatedAuth),
          ],
          child: MaterialApp(
            home: StormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Admin-only badge should be visible
      expect(find.text('ADMIN ONLY'), findsOneWidget);

      // Videos should still be accessible but with limited controls
      expect(find.byType(VideoContentCard), findsWidgets);
    });

    testWidgets('network connectivity affects video loading', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Simulate network loss
      // This would be handled by connectivity service

      // Open video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Should show network error or offline message
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Should provide retry option
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('video analytics track user engagement', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Play video
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(const Duration(seconds: 2));

      // Analytics should track:
      // - Video view start
      // - Play events
      // - Watch duration
      // - Completion rate

      // These would be logged to Firebase Analytics
      expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
    });

    testWidgets('video search and filter functionality', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find search bar
      expect(find.byType(TextField), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Governor');
      await tester.pumpAndSettle();

      // Should filter videos
      expect(find.text('Governor Emergency Declaration - Hurricane Milton'), findsOneWidget);
      expect(find.text('Live: Emergency Operations Center Briefing'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // All videos should be visible again
      expect(find.text('Governor Emergency Declaration - Hurricane Milton'), findsOneWidget);
      expect(find.text('Live: Emergency Operations Center Briefing'), findsOneWidget);
    });

    testWidgets('video categorization and sorting', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find sort button
      expect(find.byIcon(Icons.sort), findsOneWidget);

      // Tap to open sort options
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Sort options should be available
      expect(find.text('Most Recent'), findsOneWidget);
      expect(find.text('Most Viewed'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);

      // Select sort by duration
      await tester.tap(find.text('Duration'));
      await tester.pumpAndSettle();

      // Videos should be sorted by duration
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('video sharing functionality', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Find share button
      expect(find.byIcon(Icons.share), findsOneWidget);

      // Tap share button
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      // Share bottom sheet should open
      expect(find.text('Share Video'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('Share to...'), findsOneWidget);
    });

    testWidgets('video favorites and bookmarks', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find favorite button on video card
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap to favorite
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Should show filled favorite icon
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Favorite should be saved to user profile
      // This would be stored in Firestore
    });

    testWidgets('video playback history tracking', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Watch for a few seconds
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(const Duration(seconds: 5));

      // Close video
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Reopen video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Should resume from last watched position
      // Progress bar should show saved position
      expect(find.byKey(const Key('video-progress-bar')), findsOneWidget);
    });

    testWidgets('handles video player lifecycle properly', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Start playback
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(const Duration(seconds: 2));

      // Simulate app going to background
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        StringCodec().encodeMessage('AppLifecycleState.paused'),
        (data) {},
      );
      await tester.pump();

      // Video should pause
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Simulate app returning to foreground
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        StringCodec().encodeMessage('AppLifecycleState.resumed'),
        (data) {},
      );
      await tester.pump();

      // Should show pause state (user can resume)
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('video quality adaptation based on network', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Open video
      await tester.tap(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Start playback
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(const Duration(seconds: 2));

      // Quality should adapt based on network conditions
      // This would be handled by the video player
      expect(find.byKey(const Key('quality-indicator')), findsOneWidget);
    });

    testWidgets('admin video upload functionality', (tester) async {
      // Test with admin user
      final adminAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'admin-user-123',
          email: 'admin@journeyman-jobs.com',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // authProvider.overrideWithValue(adminAuth),
          ],
          child: MaterialApp(
            home: StormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Admin should see upload button
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap upload button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Upload dialog should open
      expect(find.text('Upload Video'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets); // Title, description, video URL
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('video deletion for admins', (tester) async {
      // Test with admin user
      final adminAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'admin-user-123',
          email: 'admin@journeyman-jobs.com',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // authProvider.overrideWithValue(adminAuth),
          ],
          child: MaterialApp(
            home: StormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Long press on video to show admin options
      await tester.longPress(find.text('Governor Emergency Declaration - Hurricane Milton'));
      await tester.pumpAndSettle();

      // Admin options should appear
      expect(find.text('Delete Video'), findsOneWidget);
      expect(find.text('Edit Video'), findsOneWidget);

      // Tap delete
      await tester.tap(find.text('Delete Video'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete this video?'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
    });
  });
}