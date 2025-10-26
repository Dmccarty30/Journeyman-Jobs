import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../design_system/app_theme.dart';
import '../design_system/components/reusable_components.dart';
import '../electrical_components/circuit_board_background.dart';

/// Enum for YouTube video player states
enum JJYouTubePlayerState {
  /// Player is loading and initializing
  loading,
  /// Player is ready and video can be played
  ready,
  /// An error occurred while loading or playing video
  error,
  /// Video is playing
  playing,
  /// Video is paused
  paused,
  /// Video has ended
  ended,
}

/// Data model for YouTube video metadata
class YouTubeVideoMetadata {
  /// YouTube video ID
  final String videoId;
  /// Video title
  final String title;
  /// Video description (optional)
  final String? description;
  /// Video thumbnail URL (optional)
  final String? thumbnailUrl;
  /// Video duration (optional)
  final Duration? duration;
  /// Video publish date (optional)
  final DateTime? publishDate;
  /// Whether this is an emergency/admin video
  final bool isEmergency;

  const YouTubeVideoMetadata({
    required this.videoId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.duration,
    this.publishDate,
    this.isEmergency = false,
  });

  /// Creates a copy of this metadata with the specified fields replaced
  YouTubeVideoMetadata copyWith({
    String? videoId,
    String? title,
    String? description,
    String? thumbnailUrl,
    Duration? duration,
    DateTime? publishDate,
    bool? isEmergency,
  }) {
    return YouTubeVideoMetadata(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      publishDate: publishDate ?? this.publishDate,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}

/// A reusable YouTube video player widget with electrical theming
///
/// This widget provides a comprehensive YouTube video player experience with:
/// - Electrical-themed design matching the app's aesthetic
/// - Responsive design for mobile devices
/// - Comprehensive error handling and loading states
/// - Performance optimizations for video loading
/// - Accessibility features
///
/// Example usage:
/// ```dart
/// JJYouTubeVideoPlayer(
///   metadata: YouTubeVideoMetadata(
///     videoId: 'dQw4w9WgXcQ',
///     title: 'Emergency Declaration - Hurricane Milton',
///     description: 'Official emergency management update',
///     isEmergency: true,
///   ),
///   onReady: (controller) => print('Player ready'),
///   onError: (error) => print('Error: $error'),
/// )
/// ```
class JJYouTubeVideoPlayer extends StatefulWidget {
  /// Video metadata containing video ID and information
  final YouTubeVideoMetadata metadata;

  /// Callback when player is ready and video can be played
  final Function(YoutubePlayerController)? onReady;

  /// Callback when an error occurs
  final Function(String)? onError;

  /// Callback when video starts playing
  final VoidCallback? onPlay;

  /// Callback when video is paused
  final VoidCallback? onPause;

  /// Callback when video ends
  final VoidCallback? onEnded;

  /// Whether to show video controls
  final bool showControls;

  /// Whether to autoplay the video
  final bool autoPlay;

  /// Whether to mute the video initially
  final bool startMuted;

  /// Whether to show video thumbnail initially
  final bool showThumbnail;

  /// Custom width for the player
  final double? width;

  /// Custom height for the player
  final double? height;

  /// Border radius for the player container
  final BorderRadius? borderRadius;

  /// Whether to enable picture-in-picture mode
  final bool enablePiP;

  const JJYouTubeVideoPlayer({
    super.key,
    required this.metadata,
    this.onReady,
    this.onError,
    this.onPlay,
    this.onPause,
    this.onEnded,
    this.showControls = true,
    this.autoPlay = false,
    this.startMuted = false,
    this.showThumbnail = true,
    this.width,
    this.height,
    this.borderRadius,
    this.enablePiP = false,
  });

  @override
  State<JJYouTubeVideoPlayer> createState() => _JJYouTubeVideoPlayerState();
}

class _JJYouTubeVideoPlayerState extends State<JJYouTubeVideoPlayer> {
  late YoutubePlayerController _controller;
  JJYouTubePlayerState _playerState = JJYouTubePlayerState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Initializes the YouTube player with configuration
  void _initializePlayer() {
    try {
      _controller = YoutubePlayerController(
        initialVideoId: widget.metadata.videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: widget.startMuted,
          enableCaption: true,
          captionLanguage: 'en',
          showLiveFullscreenButton: true,
          forceHD: false, // Optimize for mobile performance
          loop: false,
        ),
      )..addListener(_playerListener);

      setState(() {
        _playerState = JJYouTubePlayerState.ready;
      });

      widget.onReady?.call(_controller);
    } catch (e) {
      setState(() {
        _playerState = JJYouTubePlayerState.error;
        _errorMessage = 'Failed to initialize video player: ${e.toString()}';
      });
      widget.onError?.call(_errorMessage!);
    }
  }

  /// Listens to player state changes
  void _playerListener() {
    if (!mounted) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _playerState = JJYouTubePlayerState.playing;
        widget.onPlay?.call();
      } else if (_controller.value.playerState == PlayerState.paused) {
        _playerState = JJYouTubePlayerState.paused;
        widget.onPause?.call();
      } else if (_controller.value.playerState == PlayerState.ended) {
        _playerState = JJYouTubePlayerState.ended;
        widget.onEnded?.call();
      }
    });
  }

  /// Builds the loading state with electrical theme
  Widget _buildLoadingState() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        gradient: AppTheme.splashGradient,
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Stack(
        children: [
          // Circuit pattern background
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
            child: const ElectricalCircuitBackground(
              opacity: 0.1,
              componentDensity: ComponentDensity.medium,
              enableCurrentFlow: true,
            ),
          ),
          // Loading content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const JJPowerLineLoader(
                  width: 200,
                  height: 60,
                  message: 'Loading Video...',
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    widget.metadata.title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error state with retry functionality
  Widget _buildErrorState() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.errorRed.withValues(alpha: 0.3),
          width: AppTheme.borderWidthMedium,
        ),
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Stack(
        children: [
          // Circuit pattern background
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
            child: const ElectricalCircuitBackground(
              opacity: 0.05,
              componentDensity: ComponentDensity.low,
              enableCurrentFlow: false,
            ),
          ),
          // Error content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorRed,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Video Load Error',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    _errorMessage ?? 'Unable to load video',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  JJSecondaryButton(
                    text: 'Retry',
                    icon: Icons.refresh,
                    onPressed: () {
                      setState(() {
                        _playerState = JJYouTubePlayerState.loading;
                        _errorMessage = null;
                      });
                      _initializePlayer();
                    },
                    isFullWidth: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main video player with controls and electrical theme
  Widget _buildVideoPlayer() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowLg],
        border: widget.metadata.isEmergency
            ? Border.all(
                color: AppTheme.errorRed,
                width: AppTheme.borderWidthThick,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
        child: Stack(
          children: [
            // YouTube player
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.accentCopper,
              progressColors: const ProgressBarColors(
                playedColor: AppTheme.accentCopper,
                handleColor: AppTheme.accentCopper,
                backgroundColor: AppTheme.lightGray,
                bufferedColor: AppTheme.mediumGray,
              ),
              onReady: () {
                widget.onReady?.call(_controller);
              },
              onEnded: (data) {
                widget.onEnded?.call();
              },
            ),

            // Emergency indicator overlay
            if (widget.metadata.isEmergency)
              Positioned(
                top: AppTheme.spacingSm,
                left: AppTheme.spacingSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.errorRed.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: AppTheme.white,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        'EMERGENCY',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Video info overlay (optional)
            if (widget.metadata.description != null && _playerState == JJYouTubePlayerState.paused)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryNavy.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.metadata.title,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.metadata.description != null) ...[
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          widget.metadata.description!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_playerState) {
      case JJYouTubePlayerState.loading:
        return _buildLoadingState();
      case JJYouTubePlayerState.error:
        return _buildErrorState();
      case JJYouTubePlayerState.ready:
      case JJYouTubePlayerState.playing:
      case JJYouTubePlayerState.paused:
      case JJYouTubePlayerState.ended:
        return _buildVideoPlayer();
    }
  }
}

/// A specialized widget for displaying emergency declaration videos
///
/// This widget extends JJYouTubeVideoPlayer with additional emergency-specific
/// styling and functionality for storm-related emergency declarations.
class JJEmergencyVideoPlayer extends StatelessWidget {
  /// Video metadata
  final YouTubeVideoMetadata metadata;

  /// Emergency level (Critical, High, Moderate)
  final String emergencyLevel;

  /// Additional emergency information
  final String? emergencyInfo;

  /// Callback when player is ready
  final Function(YoutubePlayerController)? onReady;

  /// Callback when error occurs
  final Function(String)? onError;

  const JJEmergencyVideoPlayer({
    super.key,
    required this.metadata,
    required this.emergencyLevel,
    this.emergencyInfo,
    this.onReady,
    this.onError,
  });

  Color get _emergencyColor {
    switch (emergencyLevel.toLowerCase()) {
      case 'critical':
        return AppTheme.errorRed;
      case 'high':
        return AppTheme.warningOrange;
      case 'moderate':
        return AppTheme.warningYellow;
      default:
        return AppTheme.infoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: _emergencyColor,
          width: AppTheme.borderWidthThick,
        ),
        boxShadow: [
          BoxShadow(
            color: _emergencyColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _emergencyColor,
                  _emergencyColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg - 2),
                topRight: Radius.circular(AppTheme.radiusLg - 2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppTheme.white,
                  size: AppTheme.iconLg,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY DECLARATION',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        emergencyLevel.toUpperCase(),
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Text(
                    'OFFICIAL',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Emergency info (if provided)
          if (emergencyInfo != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              color: _emergencyColor.withValues(alpha: 0.1),
              child: Text(
                emergencyInfo!,
                style: AppTheme.bodyMedium.copyWith(
                  color: _emergencyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Video player
          JJYouTubeVideoPlayer(
            metadata: metadata.copyWith(isEmergency: true),
            onReady: onReady,
            onError: onError,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusLg - 2),
              bottomRight: Radius.circular(AppTheme.radiusLg - 2),
            ),
            height: 250,
            autoPlay: false,
            startMuted: true,
            showControls: true,
          ),
        ],
      ),
    );
  }
}