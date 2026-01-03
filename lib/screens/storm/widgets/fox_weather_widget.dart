import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../design_system/app_theme.dart';

class FoxWeatherWidget extends StatefulWidget {
  const FoxWeatherWidget({super.key});

  @override
  State<FoxWeatherWidget> createState() => _FoxWeatherWidgetState();
}

class _FoxWeatherWidgetState extends State<FoxWeatherWidget> {
  late YoutubePlayerController _controller;
  // Using a recent Fox Weather video ID or live stream ID.
  // Note: Live stream IDs change. This is a placeholder or a specific video.
  // User can update this ID to the current live stream ID.
  final String _videoId =
      'wt6SIE7BXS8'; // Current working Fox Weather live stream ID

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowMd],
        border: Border.all(color: AppTheme.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Icon(Icons.tv, color: AppTheme.primaryNavy),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Fox Weather',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppTheme.accentCopper,
            progressColors: const ProgressBarColors(
              playedColor: AppTheme.accentCopper,
              handleColor: AppTheme.accentCopper,
            ),
          ),
        ],
      ),
    );
  }
}
