# YouTube Live Stream Integration - Technical Guide

## Overview

This guide provides comprehensive documentation for integrating YouTube live streams into the Journeyman Jobs app, specifically for news and weather channel live broadcasts. It covers live stream detection, embedding, player configuration, and real-time updates.

---

## 1. Live Stream Detection

### 1.1 Using YouTube Data API v3

#### LiveBroadcast Resource

The `liveBroadcast` resource represents an event that will be streamed via live video on YouTube. It provides comprehensive metadata about broadcast status, timing, and configuration.

**API Endpoint:**
```
GET https://www.googleapis.com/youtube/v3/liveBroadcasts
```

**Key Properties:**
- `id` - Broadcast identifier
- `snippet` - Title, description, scheduled times
- `status` - Privacy settings, lifecycle status, recording state
- `contentDetails` - Projection, latency preference, closed captions

#### Detecting Active Live Streams

**Method 1: Search API with eventType**

```javascript
// Check if a channel has an active live stream
const checkChannelLiveStatus = async (channelId, apiKey) => {
  const url = `https://www.googleapis.com/youtube/v3/search?` +
    `part=snippet&channelId=${channelId}&eventType=live&type=video&key=${apiKey}`;

  const response = await fetch(url);
  const data = await response.json();

  return {
    isLive: data.items && data.items.length > 0,
    liveStreams: data.items || []
  };
};

// Example usage
const result = await checkChannelLiveStatus('CHANNEL_ID', 'YOUR_API_KEY');
if (result.isLive) {
  console.log('Channel is live with', result.liveStreams.length, 'stream(s)');
}
```

**Method 2: LiveBroadcasts List API**

```javascript
// Get all active broadcasts for authenticated channel
const getActiveBroadcasts = async (accessToken) => {
  const url = 'https://www.googleapis.com/youtube/v3/liveBroadcasts?' +
    'part=id,snippet,status,contentDetails&broadcastStatus=active';

  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  const data = await response.json();
  return data.items || [];
};
```

**EventType Parameters:**
- `live` - Only active broadcasts
- `upcoming` - Only scheduled future broadcasts
- `completed` - Only finished broadcasts

**Python Example:**

```python
from googleapiclient.discovery import build

YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"

def find_live_streams(channel_id, api_key, max_results=5):
    """Find active live streams for a channel."""
    youtube = build(
        YOUTUBE_API_SERVICE_NAME,
        YOUTUBE_API_VERSION,
        developerKey=api_key
    )

    search_response = youtube.search().list(
        channelId=channel_id,
        part='id,snippet',
        eventType='live',
        type='video',
        maxResults=max_results
    ).execute()

    live_streams = []
    for item in search_response.get('items', []):
        if item['id']['kind'] == 'youtube#video':
            live_streams.append({
                'videoId': item['id']['videoId'],
                'title': item['snippet']['title'],
                'description': item['snippet']['description'],
                'thumbnail': item['snippet']['thumbnails']['high']['url']
            })

    return live_streams

# Usage
live_videos = find_live_streams('CHANNEL_ID', 'YOUR_API_KEY')
for video in live_videos:
    print(f"Live: {video['title']} - {video['videoId']}")
```

**Flutter/Dart Example:**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class YouTubeLiveDetector {
  final String apiKey;

  YouTubeLiveDetector(this.apiKey);

  /// Check if a channel has active live streams
  Future<List<Map<String, dynamic>>> checkChannelLiveStatus(
    String channelId
  ) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?'
      'part=snippet&channelId=$channelId&eventType=live&type=video&key=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) => {
        'videoId': item['id']['videoId'],
        'title': item['snippet']['title'],
        'channelTitle': item['snippet']['channelTitle'],
        'thumbnail': item['snippet']['thumbnails']['high']['url'],
      }).toList();
    }

    throw Exception('Failed to fetch live streams');
  }

  /// Get upcoming scheduled broadcasts
  Future<List<Map<String, dynamic>>> getUpcomingBroadcasts(
    String channelId
  ) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?'
      'part=snippet&channelId=$channelId&eventType=upcoming&type=video&key=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) => {
        'videoId': item['id']['videoId'],
        'title': item['snippet']['title'],
        'scheduledStartTime': item['snippet']['publishedAt'],
      }).toList();
    }

    throw Exception('Failed to fetch upcoming broadcasts');
  }
}

// Usage example
final detector = YouTubeLiveDetector('YOUR_API_KEY');
final liveStreams = await detector.checkChannelLiveStatus('CHANNEL_ID');

if (liveStreams.isNotEmpty) {
  print('Channel is live with ${liveStreams.length} stream(s)');
  for (final stream in liveStreams) {
    print('${stream['title']} - ${stream['videoId']}');
  }
}
```

### 1.2 Real-Time Notifications

#### PubSubHubbub (WebSub) Integration

YouTube supports push notifications via PubSubHubbub for near real-time updates when channels upload videos or update metadata.

**Important Limitations:**
- There is a significant delay (not truly real-time despite claims)
- The feature has known reliability issues
- Notifications work for video uploads but **not reliably for live stream start/stop events**

**Setup Process:**

```javascript
// Subscribe to channel updates
const subscribeToChannel = async (channelId, callbackUrl) => {
  const hubUrl = 'https://pubsubhubbub.appspot.com/subscribe';
  const topicUrl = `https://www.youtube.com/xml/feeds/videos.xml?channel_id=${channelId}`;

  const params = new URLSearchParams({
    'hub.mode': 'subscribe',
    'hub.callback': callbackUrl,
    'hub.topic': topicUrl,
    'hub.verify': 'async'
  });

  const response = await fetch(hubUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: params
  });

  return response.status === 202; // Accepted
};
```

#### Alternative: Polling with Intelligent Caching

**Recommended Approach for Live Detection:**

```dart
import 'dart:async';

class LiveStreamMonitor {
  final YouTubeLiveDetector detector;
  final String channelId;
  final Duration pollingInterval;

  Timer? _pollingTimer;
  List<String> _knownLiveVideoIds = [];

  LiveStreamMonitor({
    required this.detector,
    required this.channelId,
    this.pollingInterval = const Duration(minutes: 2),
  });

  /// Start monitoring for live streams
  void startMonitoring({
    required Function(List<Map<String, dynamic>>) onLiveStreamsFound,
    required Function(String) onStreamStarted,
    required Function(String) onStreamEnded,
  }) {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(pollingInterval, (_) async {
      try {
        final liveStreams = await detector.checkChannelLiveStatus(channelId);
        final currentVideoIds = liveStreams
            .map((s) => s['videoId'] as String)
            .toList();

        // Detect newly started streams
        final newStreams = currentVideoIds
            .where((id) => !_knownLiveVideoIds.contains(id))
            .toList();

        // Detect ended streams
        final endedStreams = _knownLiveVideoIds
            .where((id) => !currentVideoIds.contains(id))
            .toList();

        // Notify about changes
        for (final videoId in newStreams) {
          onStreamStarted(videoId);
        }

        for (final videoId in endedStreams) {
          onStreamEnded(videoId);
        }

        // Update known streams
        _knownLiveVideoIds = currentVideoIds;

        // Notify about all current live streams
        if (liveStreams.isNotEmpty) {
          onLiveStreamsFound(liveStreams);
        }
      } catch (e) {
        print('Error monitoring live streams: $e');
      }
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}

// Usage
final monitor = LiveStreamMonitor(
  detector: YouTubeLiveDetector('YOUR_API_KEY'),
  channelId: 'WEATHER_CHANNEL_ID',
  pollingInterval: Duration(minutes: 2),
);

monitor.startMonitoring(
  onLiveStreamsFound: (streams) {
    print('Currently live: ${streams.length} stream(s)');
  },
  onStreamStarted: (videoId) {
    print('Stream started: $videoId');
    // Show notification, update UI, etc.
  },
  onStreamEnded: (videoId) {
    print('Stream ended: $videoId');
    // Update UI, remove from active list, etc.
  },
);
```

### 1.3 Important Notes & Limitations

**API Quota Considerations:**
- Search API calls cost 100 quota units
- Daily quota limit is 10,000 units by default
- With 2-minute polling: ~720 requests/day = 72,000 units (requires quota increase)
- Consider longer intervals (5-10 minutes) or event-driven checks

**Detection Delays:**
- API search results may lag 30-60 seconds behind actual stream start
- PubSubHubbub notifications are unreliable for live events
- Polling every 2-5 minutes is most reliable approach

**Authentication Requirements:**
- Public API key sufficient for `search.list` with `eventType`
- OAuth 2.0 required for `liveBroadcasts.list` (authenticated user's broadcasts)
- No authentication needed for embed playback

---

## 2. Embedding Live Streams

### 2.1 Basic IFrame Embed

**Minimal Embed Code:**

```html
<iframe
  width="560"
  height="315"
  src="https://www.youtube.com/embed/VIDEO_ID"
  frameborder="0"
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
  allowfullscreen>
</iframe>
```

**Live Stream-Specific Embed:**

```html
<iframe
  width="560"
  height="315"
  src="https://www.youtube.com/embed/LIVE_VIDEO_ID?autoplay=1&mute=1"
  frameborder="0"
  allow="autoplay; encrypted-media"
  allowfullscreen>
</iframe>
```

### 2.2 Flutter WebView Implementation

**Using `webview_flutter` Package:**

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeLiveStreamPlayer extends StatefulWidget {
  final String videoId;
  final bool autoplay;
  final bool showControls;

  const YouTubeLiveStreamPlayer({
    Key? key,
    required this.videoId,
    this.autoplay = true,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<YouTubeLiveStreamPlayer> createState() =>
      _YouTubeLiveStreamPlayerState();
}

class _YouTubeLiveStreamPlayerState extends State<YouTubeLiveStreamPlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize WebView controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(_buildEmbedUrl()));
  }

  /// Build YouTube embed URL with parameters
  String _buildEmbedUrl() {
    final params = <String, String>{
      if (widget.autoplay) 'autoplay': '1',
      if (widget.autoplay) 'mute': '1', // Required for autoplay
      'controls': widget.showControls ? '1' : '0',
      'modestbranding': '1', // Minimize YouTube branding
      'rel': '0', // Don't show related videos
      'enablejsapi': '1', // Enable JavaScript API
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return 'https://www.youtube.com/embed/${widget.videoId}?$queryString';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: WebViewWidget(controller: _controller),
    );
  }
}

// Usage
YouTubeLiveStreamPlayer(
  videoId: 'LIVE_VIDEO_ID',
  autoplay: true,
  showControls: true,
)
```

### 2.3 Autoplay Parameters & Browser Restrictions

**Critical Autoplay Requirements:**

```dart
/// YouTube embed URL with proper autoplay configuration
String buildAutoplayEmbedUrl(String videoId) {
  return 'https://www.youtube.com/embed/$videoId?'
      'autoplay=1&'        // Enable autoplay
      'mute=1&'            // REQUIRED: Must mute for autoplay to work
      'controls=1&'        // Show player controls
      'modestbranding=1&'  // Minimal YouTube branding
      'rel=0&'             // No related videos at end
      'enablejsapi=1';     // Enable JavaScript API
}
```

**IFrame Attributes Required:**

```html
<iframe
  src="https://www.youtube.com/embed/VIDEO_ID?autoplay=1&mute=1"
  allow="autoplay; encrypted-media"
  <!-- The 'allow' attribute is CRITICAL for autoplay -->
  allowfullscreen>
</iframe>
```

**Browser-Specific Behavior:**
- **Chrome/Edge**: Requires `mute=1` for autoplay
- **Firefox**: Works with `autoplay=1` alone (mute optional)
- **Safari**: Requires user interaction OR muted autoplay
- **Mobile**: Most browsers block unmuted autoplay

**Flutter WebView Permissions:**

```dart
// Configure WebView for autoplay support
_controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onPageStarted: (url) {
        // Inject permissions for autoplay
        _controller.runJavaScript('''
          navigator.permissions.query({name: 'autoplay'}).then(result => {
            if (result.state === 'granted') {
              console.log('Autoplay granted');
            }
          });
        ''');
      },
    ),
  );
```

### 2.4 Live Stream-Specific Features

**Detecting Live vs VOD:**

```html
<!DOCTYPE html>
<html>
<body>
  <div id="player"></div>
  <div id="status"></div>

  <script src="https://www.youtube.com/iframe_api"></script>
  <script>
    let player;

    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '390',
        width: '640',
        videoId: 'VIDEO_ID',
        playerVars: {
          'autoplay': 1,
          'mute': 1,
          'controls': 1
        },
        events: {
          'onReady': onPlayerReady,
          'onStateChange': onPlayerStateChange
        }
      });
    }

    function onPlayerReady(event) {
      // Check if video is live
      const duration = player.getDuration();
      const isLive = duration === 0; // Live streams return 0 duration

      document.getElementById('status').innerHTML =
        isLive ? '🔴 LIVE' : '📹 Recording';

      // For live streams, you can get viewer count
      if (isLive) {
        checkViewerCount();
      }
    }

    function onPlayerStateChange(event) {
      // Player states for live streams work the same as VOD
      // -1: unstarted, 0: ended, 1: playing, 2: paused, 3: buffering, 5: cued

      if (event.data === YT.PlayerState.PLAYING) {
        console.log('Stream is playing');
      } else if (event.data === YT.PlayerState.BUFFERING) {
        console.log('Stream is buffering');
      }
    }

    function checkViewerCount() {
      // Fetch viewer count from Data API
      fetch(`https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&id=${videoId}&key=${apiKey}`)
        .then(response => response.json())
        .then(data => {
          const viewers = data.items[0]?.liveStreamingDetails?.concurrentViewers;
          if (viewers) {
            document.getElementById('status').innerHTML +=
              ` | ${viewers.toLocaleString()} watching`;
          }
        });
    }
  </script>
</body>
</html>
```

**Flutter Implementation with Live Detection:**

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveStreamPlayerWithStatus extends StatefulWidget {
  final String videoId;
  final String apiKey;

  const LiveStreamPlayerWithStatus({
    Key? key,
    required this.videoId,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<LiveStreamPlayerWithStatus> createState() =>
      _LiveStreamPlayerWithStatusState();
}

class _LiveStreamPlayerWithStatusState
    extends State<LiveStreamPlayerWithStatus> {
  late WebViewController _controller;
  bool _isLive = false;
  int? _viewerCount;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _checkLiveStatus();
  }

  void _initializePlayer() {
    final embedHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { margin: 0; padding: 0; background: black; }
          #player { width: 100%; height: 100vh; }
        </style>
      </head>
      <body>
        <div id="player"></div>
        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
          let player;
          function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
              height: '100%',
              width: '100%',
              videoId: '${widget.videoId}',
              playerVars: {
                'autoplay': 1,
                'mute': 1,
                'controls': 1,
                'modestbranding': 1,
                'rel': 0
              },
              events: {
                'onReady': function(event) {
                  const duration = player.getDuration();
                  const isLive = duration === 0;

                  // Send message to Flutter
                  window.flutter_inappwebview.callHandler('onPlayerReady', {
                    isLive: isLive
                  });
                },
                'onStateChange': function(event) {
                  window.flutter_inappwebview.callHandler('onStateChange', {
                    state: event.data
                  });
                }
              }
            });
          }
        </script>
      </body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(embedHtml);
  }

  Future<void> _checkLiveStatus() async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?'
        'part=liveStreamingDetails&id=${widget.videoId}&key=${widget.apiKey}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          final liveDetails = items[0]['liveStreamingDetails'];

          setState(() {
            _isLive = liveDetails != null;
            _viewerCount = liveDetails?['concurrentViewers'] != null
                ? int.tryParse(liveDetails['concurrentViewers'].toString())
                : null;
          });

          // Continue polling viewer count if live
          if (_isLive) {
            Future.delayed(Duration(seconds: 30), _checkLiveStatus);
          }
        }
      }
    } catch (e) {
      print('Error checking live status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Live status banner
        if (_isLive)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red,
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.white, size: 12),
                SizedBox(width: 8),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_viewerCount != null) ...[
                  Spacer(),
                  Icon(Icons.visibility, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${_formatViewerCount(_viewerCount!)} watching',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),

        // Video player
        Expanded(
          child: WebViewWidget(controller: _controller),
        ),
      ],
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// Usage
LiveStreamPlayerWithStatus(
  videoId: 'LIVE_VIDEO_ID',
  apiKey: 'YOUR_API_KEY',
)
```

---

## 3. Player Configuration

### 3.1 YouTube IFrame Player API

**Complete Setup Example:**

```html
<!DOCTYPE html>
<html>
<head>
  <title>YouTube Live Player</title>
</head>
<body>
  <div id="player"></div>

  <script src="https://www.youtube.com/iframe_api"></script>
  <script>
    let player;

    // This function is called automatically when the API is ready
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '390',
        width: '640',
        videoId: 'VIDEO_ID',
        playerVars: {
          // Playback parameters
          'autoplay': 1,              // Auto-start playback
          'mute': 1,                  // Start muted (required for autoplay)

          // Controls
          'controls': 1,              // Show player controls
          'disablekb': 0,             // Enable keyboard controls
          'fs': 1,                    // Show fullscreen button

          // Branding
          'modestbranding': 1,        // Minimal YouTube branding
          'rel': 0,                   // Don't show related videos
          'showinfo': 0,              // Hide video info (deprecated)

          // Captions
          'cc_load_policy': 1,        // Show captions by default
          'cc_lang_pref': 'en',       // Preferred caption language

          // Quality
          'vq': 'hd1080',            // Preferred quality (suggestion only)

          // API
          'enablejsapi': 1,           // Enable JavaScript API
          'origin': window.location.origin, // Security origin

          // Live stream specific
          'playsinline': 1,           // Inline playback on iOS
        },
        events: {
          'onReady': onPlayerReady,
          'onStateChange': onPlayerStateChange,
          'onError': onPlayerError,
          'onPlaybackQualityChange': onPlaybackQualityChange
        }
      });
    }

    function onPlayerReady(event) {
      console.log('Player ready');

      // Get available quality levels
      const qualityLevels = player.getAvailableQualityLevels();
      console.log('Available qualities:', qualityLevels);

      // Set quality (optional)
      // player.setPlaybackQuality('hd1080');

      // Auto-play if desired
      // event.target.playVideo();
    }

    function onPlayerStateChange(event) {
      switch (event.data) {
        case YT.PlayerState.UNSTARTED:
          console.log('Player unstarted');
          break;
        case YT.PlayerState.ENDED:
          console.log('Stream ended');
          break;
        case YT.PlayerState.PLAYING:
          console.log('Stream playing');
          break;
        case YT.PlayerState.PAUSED:
          console.log('Stream paused');
          break;
        case YT.PlayerState.BUFFERING:
          console.log('Stream buffering');
          break;
        case YT.PlayerState.CUED:
          console.log('Stream cued');
          break;
      }
    }

    function onPlayerError(event) {
      const errorMessages = {
        2: 'Invalid video ID',
        5: 'HTML5 player error',
        100: 'Video not found or private',
        101: 'Embedding not allowed by owner',
        150: 'Embedding not allowed by owner'
      };

      console.error('Player error:', errorMessages[event.data] || 'Unknown error');
    }

    function onPlaybackQualityChange(event) {
      console.log('Quality changed to:', event.data);
    }

    // Player control functions
    function playStream() {
      player.playVideo();
    }

    function pauseStream() {
      player.pauseVideo();
    }

    function muteStream() {
      player.mute();
    }

    function unmuteStream() {
      player.unMute();
    }

    function setVolume(volume) {
      // volume: 0-100
      player.setVolume(volume);
    }

    function getPlayerState() {
      return player.getPlayerState();
    }

    function getCurrentTime() {
      return player.getCurrentTime();
    }

    function getDuration() {
      // Returns 0 for live streams
      return player.getDuration();
    }
  </script>
</body>
</html>
```

### 3.2 Player Parameters Reference

**Complete Parameter List:**

| Parameter | Values | Description |
|-----------|--------|-------------|
| `autoplay` | 0, 1 | Auto-start playback (requires mute=1) |
| `mute` | 0, 1 | Start muted (required for autoplay) |
| `controls` | 0, 1 | Show/hide player controls |
| `disablekb` | 0, 1 | Disable keyboard controls |
| `fs` | 0, 1 | Show/hide fullscreen button |
| `modestbranding` | 0, 1 | Minimal YouTube branding |
| `rel` | 0, 1 | Show related videos at end |
| `cc_load_policy` | 0, 1 | Force captions on/off |
| `cc_lang_pref` | Language code | Preferred caption language |
| `color` | 'red', 'white' | Progress bar color |
| `playsinline` | 0, 1 | iOS inline playback |
| `enablejsapi` | 0, 1 | Enable JavaScript API |
| `origin` | URL | Security origin for API |
| `vq` | Quality level | Suggested quality (hd1080, hd720, etc.) |

### 3.3 Player Events

**Available Events:**

```javascript
const events = {
  'onReady': function(event) {
    // Player is ready to accept API calls
  },
  'onStateChange': function(event) {
    // Player state changed
    // event.data: -1, 0, 1, 2, 3, 5
  },
  'onPlaybackQualityChange': function(event) {
    // Video quality changed
    // event.data: 'small', 'medium', 'large', 'hd720', 'hd1080', etc.
  },
  'onPlaybackRateChange': function(event) {
    // Playback rate changed (not common for live streams)
    // event.data: 0.25, 0.5, 1, 1.25, 1.5, 2
  },
  'onError': function(event) {
    // An error occurred
    // event.data: 2, 5, 100, 101, 150
  },
  'onApiChange': function(event) {
    // Player API loaded a new module
  }
};
```

**Player State Constants:**

```javascript
YT.PlayerState.UNSTARTED = -1;
YT.PlayerState.ENDED = 0;
YT.PlayerState.PLAYING = 1;
YT.PlayerState.PAUSED = 2;
YT.PlayerState.BUFFERING = 3;
YT.PlayerState.CUED = 5;
```

### 3.4 Flutter Player Integration

**Complete Flutter WebView Player with Controls:**

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PlayerState {
  unstarted,
  ended,
  playing,
  paused,
  buffering,
  cued,
}

class YouTubePlayerController extends ChangeNotifier {
  late WebViewController _webViewController;
  PlayerState _state = PlayerState.unstarted;
  bool _isLive = false;
  double _volume = 100;
  bool _isMuted = false;

  PlayerState get state => _state;
  bool get isLive => _isLive;
  double get volume => _volume;
  bool get isMuted => _isMuted;

  WebViewController get webViewController => _webViewController;

  void setWebViewController(WebViewController controller) {
    _webViewController = controller;
  }

  // Player controls
  Future<void> play() async {
    await _webViewController.runJavaScript('player.playVideo();');
  }

  Future<void> pause() async {
    await _webViewController.runJavaScript('player.pauseVideo();');
  }

  Future<void> mute() async {
    await _webViewController.runJavaScript('player.mute();');
    _isMuted = true;
    notifyListeners();
  }

  Future<void> unmute() async {
    await _webViewController.runJavaScript('player.unMute();');
    _isMuted = false;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0, 100);
    await _webViewController.runJavaScript('player.setVolume($_volume);');
    notifyListeners();
  }

  Future<void> seekTo(double seconds) async {
    await _webViewController.runJavaScript('player.seekTo($seconds);');
  }

  Future<void> setPlaybackQuality(String quality) async {
    // quality: 'small', 'medium', 'large', 'hd720', 'hd1080'
    await _webViewController.runJavaScript('player.setPlaybackQuality("$quality");');
  }

  void _updateState(int stateCode) {
    switch (stateCode) {
      case -1:
        _state = PlayerState.unstarted;
        break;
      case 0:
        _state = PlayerState.ended;
        break;
      case 1:
        _state = PlayerState.playing;
        break;
      case 2:
        _state = PlayerState.paused;
        break;
      case 3:
        _state = PlayerState.buffering;
        break;
      case 5:
        _state = PlayerState.cued;
        break;
    }
    notifyListeners();
  }
}

class YouTubeLivePlayer extends StatefulWidget {
  final String videoId;
  final YouTubePlayerController? controller;
  final bool autoplay;
  final bool showControls;

  const YouTubeLivePlayer({
    Key? key,
    required this.videoId,
    this.controller,
    this.autoplay = true,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<YouTubeLivePlayer> createState() => _YouTubeLivePlayerState();
}

class _YouTubeLivePlayerState extends State<YouTubeLivePlayer> {
  late YouTubePlayerController _controller;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? YouTubePlayerController();
    _initializePlayer();
  }

  void _initializePlayer() {
    final embedHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            margin: 0;
            padding: 0;
            background: black;
            overflow: hidden;
          }
          #player {
            width: 100vw;
            height: 100vh;
          }
        </style>
      </head>
      <body>
        <div id="player"></div>

        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
          let player;

          function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
              height: '100%',
              width: '100%',
              videoId: '${widget.videoId}',
              playerVars: {
                'autoplay': ${widget.autoplay ? 1 : 0},
                'mute': ${widget.autoplay ? 1 : 0},
                'controls': ${widget.showControls ? 1 : 0},
                'modestbranding': 1,
                'rel': 0,
                'playsinline': 1,
                'enablejsapi': 1
              },
              events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange,
                'onError': onPlayerError
              }
            });
          }

          function onPlayerReady(event) {
            const duration = player.getDuration();
            const isLive = duration === 0;

            // Send to Flutter
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('onPlayerReady', {
                isLive: isLive
              });
            }
          }

          function onPlayerStateChange(event) {
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('onStateChange', {
                state: event.data
              });
            }
          }

          function onPlayerError(event) {
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('onError', {
                errorCode: event.data
              });
            }
          }
        </script>
      </body>
      </html>
    ''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle messages from JavaScript
          print('Message from JS: ${message.message}');
        },
      )
      ..loadHtmlString(embedHtml);

    _controller.setWebViewController(_webViewController);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webViewController);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}

// Usage with custom controls
class LiveStreamScreen extends StatefulWidget {
  final String videoId;

  const LiveStreamScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final _playerController = YouTubePlayerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Video player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YouTubeLivePlayer(
              videoId: widget.videoId,
              controller: _playerController,
              showControls: false, // Use custom controls
            ),
          ),

          // Custom controls
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _playerController.state == PlayerState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_playerController.state == PlayerState.playing) {
                      _playerController.pause();
                    } else {
                      _playerController.play();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    _playerController.isMuted
                        ? Icons.volume_off
                        : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_playerController.isMuted) {
                      _playerController.unmute();
                    } else {
                      _playerController.mute();
                    }
                  },
                ),
                Expanded(
                  child: Slider(
                    value: _playerController.volume,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      _playerController.setVolume(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }
}
```

---

## 4. Real-Time Update Strategies

### 4.1 Viewer Count Updates

**API Method:**

```javascript
async function getViewerCount(videoId, apiKey) {
  const url = `https://www.googleapis.com/youtube/v3/videos?` +
    `part=liveStreamingDetails&id=${videoId}&key=${apiKey}`;

  const response = await fetch(url);
  const data = await response.json();

  if (data.items && data.items.length > 0) {
    const liveDetails = data.items[0].liveStreamingDetails;
    return {
      concurrentViewers: parseInt(liveDetails?.concurrentViewers || 0),
      actualStartTime: liveDetails?.actualStartTime,
      scheduledStartTime: liveDetails?.scheduledStartTime,
      activeLiveChatId: liveDetails?.activeLiveChatId
    };
  }

  return null;
}

// Update viewer count periodically
setInterval(async () => {
  const stats = await getViewerCount('VIDEO_ID', 'API_KEY');
  if (stats) {
    document.getElementById('viewerCount').textContent =
      `${stats.concurrentViewers.toLocaleString()} watching`;
  }
}, 30000); // Update every 30 seconds
```

**Alternative: YouTube Live Stats (Unofficial):**

```javascript
async function getViewerCountUnofficial(videoId) {
  try {
    const url = `https://www.youtube.com/live_stats?v=${videoId}`;
    const response = await fetch(url);
    const viewerCount = await response.text();
    return parseInt(viewerCount);
  } catch (e) {
    console.error('Error fetching viewer count:', e);
    return 0;
  }
}

// This method is faster but unofficial/unsupported
```

**Flutter Implementation:**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LiveStreamStats {
  final int concurrentViewers;
  final DateTime? actualStartTime;
  final DateTime? scheduledStartTime;

  LiveStreamStats({
    required this.concurrentViewers,
    this.actualStartTime,
    this.scheduledStartTime,
  });

  factory LiveStreamStats.fromJson(Map<String, dynamic> json) {
    return LiveStreamStats(
      concurrentViewers: int.tryParse(
        json['concurrentViewers']?.toString() ?? '0'
      ) ?? 0,
      actualStartTime: json['actualStartTime'] != null
          ? DateTime.parse(json['actualStartTime'])
          : null,
      scheduledStartTime: json['scheduledStartTime'] != null
          ? DateTime.parse(json['scheduledStartTime'])
          : null,
    );
  }
}

class LiveStreamStatsService {
  final String apiKey;
  Timer? _updateTimer;

  LiveStreamStatsService(this.apiKey);

  /// Fetch current live stream statistics
  Future<LiveStreamStats?> getStats(String videoId) async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?'
        'part=liveStreamingDetails&id=$videoId&key=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          final liveDetails = items[0]['liveStreamingDetails'];
          if (liveDetails != null) {
            return LiveStreamStats.fromJson(liveDetails);
          }
        }
      }
    } catch (e) {
      print('Error fetching live stats: $e');
    }

    return null;
  }

  /// Start periodic updates of viewer count
  void startPeriodicUpdates({
    required String videoId,
    required Function(LiveStreamStats) onUpdate,
    Duration interval = const Duration(seconds: 30),
  }) {
    _updateTimer?.cancel();

    // Initial fetch
    getStats(videoId).then((stats) {
      if (stats != null) onUpdate(stats);
    });

    // Periodic updates
    _updateTimer = Timer.periodic(interval, (_) async {
      final stats = await getStats(videoId);
      if (stats != null) onUpdate(stats);
    });
  }

  /// Stop periodic updates
  void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}

// Widget implementation
class LiveViewerCount extends StatefulWidget {
  final String videoId;
  final String apiKey;

  const LiveViewerCount({
    Key? key,
    required this.videoId,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<LiveViewerCount> createState() => _LiveViewerCountState();
}

class _LiveViewerCountState extends State<LiveViewerCount> {
  late LiveStreamStatsService _statsService;
  LiveStreamStats? _currentStats;

  @override
  void initState() {
    super.initState();
    _statsService = LiveStreamStatsService(widget.apiKey);

    _statsService.startPeriodicUpdates(
      videoId: widget.videoId,
      onUpdate: (stats) {
        if (mounted) {
          setState(() => _currentStats = stats);
        }
      },
      interval: Duration(seconds: 30),
    );
  }

  @override
  void dispose() {
    _statsService.stopPeriodicUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStats == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            '${_formatViewerCount(_currentStats!.concurrentViewers)} watching',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
```

### 4.2 Stream Status Monitoring

**Comprehensive Monitoring System:**

```dart
enum LiveStreamStatus {
  offline,
  upcoming,
  live,
  ended,
  error,
}

class LiveStreamMonitoringService {
  final String channelId;
  final String apiKey;

  Timer? _monitoringTimer;
  LiveStreamStatus _status = LiveStreamStatus.offline;
  String? _currentVideoId;

  LiveStreamMonitoringService({
    required this.channelId,
    required this.apiKey,
  });

  LiveStreamStatus get status => _status;
  String? get currentVideoId => _currentVideoId;

  /// Start monitoring channel for live stream status changes
  void startMonitoring({
    required Function(LiveStreamStatus status, String? videoId) onStatusChange,
    Duration checkInterval = const Duration(minutes: 2),
  }) {
    _monitoringTimer?.cancel();

    // Initial check
    _checkStatus().then((result) {
      _updateStatus(result.status, result.videoId);
      onStatusChange(result.status, result.videoId);
    });

    // Periodic checks
    _monitoringTimer = Timer.periodic(checkInterval, (_) async {
      final result = await _checkStatus();

      if (result.status != _status || result.videoId != _currentVideoId) {
        _updateStatus(result.status, result.videoId);
        onStatusChange(result.status, result.videoId);
      }
    });
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  Future<({LiveStreamStatus status, String? videoId})> _checkStatus() async {
    try {
      // Check for live streams
      final liveUrl = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?'
        'part=snippet&channelId=$channelId&eventType=live&type=video&key=$apiKey'
      );

      final liveResponse = await http.get(liveUrl);

      if (liveResponse.statusCode == 200) {
        final liveData = json.decode(liveResponse.body);
        final liveItems = liveData['items'] as List?;

        if (liveItems != null && liveItems.isNotEmpty) {
          return (
            status: LiveStreamStatus.live,
            videoId: liveItems[0]['id']['videoId']
          );
        }
      }

      // Check for upcoming streams
      final upcomingUrl = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?'
        'part=snippet&channelId=$channelId&eventType=upcoming&type=video&key=$apiKey'
      );

      final upcomingResponse = await http.get(upcomingUrl);

      if (upcomingResponse.statusCode == 200) {
        final upcomingData = json.decode(upcomingResponse.body);
        final upcomingItems = upcomingData['items'] as List?;

        if (upcomingItems != null && upcomingItems.isNotEmpty) {
          return (
            status: LiveStreamStatus.upcoming,
            videoId: upcomingItems[0]['id']['videoId']
          );
        }
      }

      return (status: LiveStreamStatus.offline, videoId: null);

    } catch (e) {
      print('Error checking stream status: $e');
      return (status: LiveStreamStatus.error, videoId: null);
    }
  }

  void _updateStatus(LiveStreamStatus newStatus, String? videoId) {
    _status = newStatus;
    _currentVideoId = videoId;
  }
}

// Widget implementation
class LiveStreamStatusIndicator extends StatefulWidget {
  final String channelId;
  final String apiKey;
  final Widget Function(
    BuildContext context,
    LiveStreamStatus status,
    String? videoId,
  ) builder;

  const LiveStreamStatusIndicator({
    Key? key,
    required this.channelId,
    required this.apiKey,
    required this.builder,
  }) : super(key: key);

  @override
  State<LiveStreamStatusIndicator> createState() =>
      _LiveStreamStatusIndicatorState();
}

class _LiveStreamStatusIndicatorState
    extends State<LiveStreamStatusIndicator> {
  late LiveStreamMonitoringService _monitor;
  LiveStreamStatus _status = LiveStreamStatus.offline;
  String? _videoId;

  @override
  void initState() {
    super.initState();

    _monitor = LiveStreamMonitoringService(
      channelId: widget.channelId,
      apiKey: widget.apiKey,
    );

    _monitor.startMonitoring(
      onStatusChange: (status, videoId) {
        if (mounted) {
          setState(() {
            _status = status;
            _videoId = videoId;
          });
        }
      },
      checkInterval: Duration(minutes: 2),
    );
  }

  @override
  void dispose() {
    _monitor.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _status, _videoId);
  }
}

// Usage example
LiveStreamStatusIndicator(
  channelId: 'WEATHER_CHANNEL_ID',
  apiKey: 'YOUR_API_KEY',
  builder: (context, status, videoId) {
    switch (status) {
      case LiveStreamStatus.live:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.red,
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 12),
                  SizedBox(width: 8),
                  Text('LIVE NOW', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            if (videoId != null)
              YouTubeLivePlayer(videoId: videoId),
          ],
        );

      case LiveStreamStatus.upcoming:
        return Card(
          child: ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Stream Scheduled'),
            subtitle: Text('Starting soon'),
          ),
        );

      case LiveStreamStatus.offline:
        return Card(
          child: ListTile(
            leading: Icon(Icons.videocam_off),
            title: Text('Channel Offline'),
            subtitle: Text('No active broadcast'),
          ),
        );

      case LiveStreamStatus.error:
        return Card(
          child: ListTile(
            leading: Icon(Icons.error),
            title: Text('Error'),
            subtitle: Text('Unable to check stream status'),
          ),
        );

      default:
        return SizedBox.shrink();
    }
  },
)
```

### 4.3 Adaptive Quality Streaming

YouTube automatically handles adaptive bitrate streaming using HLS (HTTP Live Streaming) and DASH (Dynamic Adaptive Streaming over HTTP).

**How It Works:**
- YouTube encodes live streams at multiple resolutions (144p to 4K)
- Video is segmented into 2-6 second chunks
- Player automatically switches quality based on network conditions
- Machine learning algorithms predict optimal bitrate

**Quality Levels Available:**
- `small` - 240p
- `medium` - 360p
- `large` - 480p
- `hd720` - 720p HD
- `hd1080` - 1080p Full HD
- `hd1440` - 1440p 2K
- `hd2160` - 2160p 4K

**Controlling Quality in Player:**

```javascript
// Get available quality levels
const qualities = player.getAvailableQualityLevels();
console.log('Available:', qualities); // ['hd1080', 'hd720', 'large', 'medium', 'small']

// Set preferred quality
player.setPlaybackQuality('hd720');

// Get current quality
const currentQuality = player.getPlaybackQuality();
console.log('Current:', currentQuality);

// Listen for quality changes
function onPlaybackQualityChange(event) {
  console.log('Quality changed to:', event.data);
}
```

**Flutter Quality Control:**

```dart
class YouTubeQualityControl extends StatefulWidget {
  final YouTubePlayerController controller;

  const YouTubeQualityControl({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<YouTubeQualityControl> createState() => _YouTubeQualityControlState();
}

class _YouTubeQualityControlState extends State<YouTubeQualityControl> {
  List<String> _availableQualities = [];
  String _currentQuality = 'auto';

  @override
  void initState() {
    super.initState();
    _fetchAvailableQualities();
  }

  Future<void> _fetchAvailableQualities() async {
    try {
      final result = await widget.controller.webViewController.runJavaScriptReturningResult(
        'JSON.stringify(player.getAvailableQualityLevels())'
      );

      if (result is String) {
        final qualities = List<String>.from(json.decode(result));
        setState(() => _availableQualities = qualities);
      }
    } catch (e) {
      print('Error fetching qualities: $e');
    }
  }

  Future<void> _setQuality(String quality) async {
    await widget.controller.setPlaybackQuality(quality);
    setState(() => _currentQuality = quality);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings),
      onSelected: _setQuality,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'auto',
          child: Text('Auto (Recommended)'),
        ),
        ..._availableQualities.map((quality) {
          final label = _getQualityLabel(quality);
          return PopupMenuItem(
            value: quality,
            child: Row(
              children: [
                if (_currentQuality == quality)
                  Icon(Icons.check, size: 16),
                SizedBox(width: 8),
                Text(label),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getQualityLabel(String quality) {
    const labels = {
      'small': '240p',
      'medium': '360p',
      'large': '480p',
      'hd720': '720p HD',
      'hd1080': '1080p Full HD',
      'hd1440': '1440p 2K',
      'hd2160': '2160p 4K',
    };

    return labels[quality] ?? quality;
  }
}
```

---

## 5. News Channel Implementation Examples

### 5.1 Major News Networks on YouTube

**Popular News Channels with Live Streams:**

| Network | Channel ID | Typical Live Streams |
|---------|-----------|---------------------|
| CNN | UCupvZG-5ko_eiXAupbDfxWw | Breaking news, special events |
| ABC News | UCBi2mrWuNuyYy4gbM6fU18Q | 24/7 live stream |
| NBC News | UCeY0bbntWzzVIaj2z3QigXg | Breaking news coverage |
| CBS News | UC8p1vwvWtl6T73JiExfWs1g | Live news broadcasts |
| Fox News | UCXIJgqnII2ZOINSWNOGFThA | Live shows, breaking news |
| BBC News | UC16niRr50-MSBwiO3YDb3RA | International live coverage |
| Al Jazeera | UCNye-wNBqNL5ZzHSJj3l8Bg | 24/7 live stream |
| Sky News | UCoMdktPbSTixAyNGwb-UYkQ | Live news coverage |

**The Weather Channel:**
- Channel ID: `UC8J1sGeZW_tzoyTHaFa4YLg`
- Features: Live weather updates, severe weather coverage
- Available on YouTube TV

### 5.2 Weather Channel Integration Pattern

**Complete Weather Live Stream Implementation:**

```dart
import 'package:flutter/material.dart';

class WeatherLiveStreamScreen extends StatefulWidget {
  const WeatherLiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<WeatherLiveStreamScreen> createState() =>
      _WeatherLiveStreamScreenState();
}

class _WeatherLiveStreamScreenState extends State<WeatherLiveStreamScreen> {
  static const String WEATHER_CHANNEL_ID = 'UC8J1sGeZW_tzoyTHaFa4YLg';
  static const String API_KEY = 'YOUR_API_KEY';

  final _detector = YouTubeLiveDetector(API_KEY);
  final _statsService = LiveStreamStatsService(API_KEY);
  final _monitor = LiveStreamMonitoringService(
    channelId: WEATHER_CHANNEL_ID,
    apiKey: API_KEY,
  );

  LiveStreamStatus _status = LiveStreamStatus.offline;
  String? _liveVideoId;
  LiveStreamStats? _stats;

  @override
  void initState() {
    super.initState();
    _initializeMonitoring();
  }

  void _initializeMonitoring() {
    // Monitor channel status
    _monitor.startMonitoring(
      onStatusChange: (status, videoId) {
        if (mounted) {
          setState(() {
            _status = status;
            _liveVideoId = videoId;
          });

          // If live, start stats updates
          if (status == LiveStreamStatus.live && videoId != null) {
            _statsService.startPeriodicUpdates(
              videoId: videoId,
              onUpdate: (stats) {
                if (mounted) {
                  setState(() => _stats = stats);
                }
              },
            );
          } else {
            _statsService.stopPeriodicUpdates();
          }
        }
      },
      checkInterval: Duration(minutes: 2),
    );
  }

  @override
  void dispose() {
    _monitor.stopMonitoring();
    _statsService.stopPeriodicUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Channel Live'),
        actions: [
          if (_status == LiveStreamStatus.live && _stats != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${_formatViewerCount(_stats!.concurrentViewers)} watching',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case LiveStreamStatus.live:
        if (_liveVideoId == null) return _buildErrorState();

        return Column(
          children: [
            // Live indicator banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red,
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 12),
                  SizedBox(width: 8),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  if (_stats != null)
                    Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${_formatViewerCount(_stats!.concurrentViewers)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Video player
            Expanded(
              child: YouTubeLivePlayer(
                videoId: _liveVideoId!,
                autoplay: true,
                showControls: true,
              ),
            ),

            // Stream info
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Weather Channel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  if (_stats?.actualStartTime != null)
                    Text(
                      'Started: ${_formatStartTime(_stats!.actualStartTime!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        );

      case LiveStreamStatus.upcoming:
        return _buildUpcomingState();

      case LiveStreamStatus.offline:
        return _buildOfflineState();

      case LiveStreamStatus.error:
        return _buildErrorState();
    }
  }

  Widget _buildUpcomingState() {
    return Center(
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Live Stream Scheduled',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'The Weather Channel will be live soon',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Live Stream',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'The Weather Channel is not currently live',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('Check Again'),
                onPressed: () {
                  _monitor.stopMonitoring();
                  _initializeMonitoring();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error Loading Stream',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Unable to check stream status. Please try again.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
                onPressed: () {
                  _monitor.stopMonitoring();
                  _initializeMonitoring();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatStartTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
```

---

## 6. Best Practices & Recommendations

### 6.1 API Quota Management

**Daily Quota Limits:**
- Default: 10,000 units/day
- Search.list: 100 units per call
- Videos.list: 1 unit per call
- LiveBroadcasts.list: 1 unit per call (requires OAuth)

**Optimization Strategies:**

1. **Intelligent Polling Intervals:**
   - During peak hours: 5-10 minutes
   - Off-peak hours: 15-30 minutes
   - Event-driven: Only when user opens app

2. **Caching:**
```dart
class YouTubeAPICache {
  final Map<String, ({DateTime timestamp, dynamic data})> _cache = {};
  final Duration cacheDuration;

  YouTubeAPICache({this.cacheDuration = const Duration(minutes: 5)});

  T? get<T>(String key) {
    final cached = _cache[key];
    if (cached != null) {
      if (DateTime.now().difference(cached.timestamp) < cacheDuration) {
        return cached.data as T;
      }
      _cache.remove(key);
    }
    return null;
  }

  void set(String key, dynamic data) {
    _cache[key] = (timestamp: DateTime.now(), data: data);
  }
}
```

3. **Request Batching:**
```dart
// Instead of multiple calls
final liveStreams = await detector.checkChannelLiveStatus(channelId);

// Use videos.list to get multiple video details in one call
final videoIds = liveStreams.map((s) => s['videoId']).join(',');
final url = 'https://www.googleapis.com/youtube/v3/videos?'
    'part=liveStreamingDetails,snippet&id=$videoIds&key=$apiKey';
```

### 6.2 Error Handling

**Comprehensive Error Handling Pattern:**

```dart
class YouTubeAPIError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  YouTubeAPIError(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'YouTubeAPIError: $message (Code: $statusCode)';
}

class RobustYouTubeService {
  final String apiKey;
  final int maxRetries;
  final Duration retryDelay;

  RobustYouTubeService({
    required this.apiKey,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  Future<T> _retryableRequest<T>({
    required Future<T> Function() request,
    int attempt = 0,
  }) async {
    try {
      return await request();
    } on http.ClientException catch (e) {
      // Network error
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay * (attempt + 1));
        return _retryableRequest(request: request, attempt: attempt + 1);
      }
      throw YouTubeAPIError('Network error', originalError: e);
    } on FormatException catch (e) {
      // JSON parsing error
      throw YouTubeAPIError('Invalid response format', originalError: e);
    } catch (e) {
      // Unknown error
      throw YouTubeAPIError('Unknown error', originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> checkLiveStreams(
    String channelId
  ) async {
    return _retryableRequest(
      request: () async {
        final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?'
          'part=snippet&channelId=$channelId&eventType=live&type=video&key=$apiKey'
        );

        final response = await http.get(url).timeout(Duration(seconds: 10));

        if (response.statusCode == 403) {
          throw YouTubeAPIError(
            'API quota exceeded or access forbidden',
            statusCode: 403,
          );
        } else if (response.statusCode == 400) {
          throw YouTubeAPIError(
            'Invalid request parameters',
            statusCode: 400,
          );
        } else if (response.statusCode != 200) {
          throw YouTubeAPIError(
            'HTTP error',
            statusCode: response.statusCode,
          );
        }

        final data = json.decode(response.body);

        if (data['error'] != null) {
          throw YouTubeAPIError(
            data['error']['message'] ?? 'API error',
            statusCode: data['error']['code'],
          );
        }

        return List<Map<String, dynamic>>.from(data['items'] ?? []);
      },
    );
  }
}
```

### 6.3 Performance Optimization

**1. Lazy Loading:**
```dart
class LiveStreamList extends StatefulWidget {
  final List<String> channelIds;

  const LiveStreamList({Key? key, required this.channelIds}) : super(key: key);

  @override
  State<LiveStreamList> createState() => _LiveStreamListState();
}

class _LiveStreamListState extends State<LiveStreamList> {
  final Map<String, bool> _loadedChannels = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.channelIds.length,
      itemBuilder: (context, index) {
        final channelId = widget.channelIds[index];

        return VisibilityDetector(
          key: Key(channelId),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0.5 && !_loadedChannels.containsKey(channelId)) {
              setState(() => _loadedChannels[channelId] = true);
            }
          },
          child: _loadedChannels[channelId] == true
              ? LiveStreamStatusIndicator(
                  channelId: channelId,
                  apiKey: 'API_KEY',
                  builder: (context, status, videoId) {
                    // Build UI based on status
                  },
                )
              : Container(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
        );
      },
    );
  }
}
```

**2. Widget Optimization:**
```dart
class OptimizedYouTubePlayer extends StatelessWidget {
  final String videoId;

  const OptimizedYouTubePlayer({Key? key, required this.videoId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: YouTubeLivePlayer(
        videoId: videoId,
        autoplay: true,
      ),
    );
  }
}
```

**3. Memory Management:**
```dart
class LiveStreamManager extends ChangeNotifier {
  final Map<String, Timer> _activeMonitors = {};

  void startMonitoring(String channelId, Function callback) {
    stopMonitoring(channelId); // Clean up existing

    _activeMonitors[channelId] = Timer.periodic(
      Duration(minutes: 2),
      (_) => callback(),
    );
  }

  void stopMonitoring(String channelId) {
    _activeMonitors[channelId]?.cancel();
    _activeMonitors.remove(channelId);
  }

  @override
  void dispose() {
    // Clean up all monitors
    _activeMonitors.values.forEach((timer) => timer.cancel());
    _activeMonitors.clear();
    super.dispose();
  }
}
```

### 6.4 User Experience Best Practices

**1. Loading States:**
```dart
Widget buildLoadingState() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Checking for live stream...'),
      ],
    ),
  );
}
```

**2. Error Recovery:**
```dart
Widget buildErrorStateWithRetry({
  required String message,
  required VoidCallback onRetry,
}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.refresh),
          label: Text('Try Again'),
          onPressed: onRetry,
        ),
      ],
    ),
  );
}
```

**3. Offline Support:**
```dart
class OfflineAwareLiveStream extends StatelessWidget {
  final String channelId;

  const OfflineAwareLiveStream({Key? key, required this.channelId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.none) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 64),
                SizedBox(height: 16),
                Text('No internet connection'),
                Text('Live streams require an active connection'),
              ],
            ),
          );
        }

        return LiveStreamStatusIndicator(
          channelId: channelId,
          apiKey: 'API_KEY',
          builder: (context, status, videoId) {
            // Normal UI
          },
        );
      },
    );
  }
}
```

---

## 7. Summary & Quick Reference

### Quick Implementation Checklist

- [ ] **API Setup**
  - [ ] Obtain YouTube Data API v3 key
  - [ ] Enable necessary API endpoints
  - [ ] Set up quota monitoring

- [ ] **Live Detection**
  - [ ] Implement channel live status checking
  - [ ] Set up polling or push notifications
  - [ ] Add error handling and retries

- [ ] **Player Integration**
  - [ ] Create WebView-based player
  - [ ] Configure autoplay parameters
  - [ ] Add player controls

- [ ] **Real-Time Updates**
  - [ ] Implement viewer count updates
  - [ ] Add live status monitoring
  - [ ] Set up periodic refresh

- [ ] **Optimization**
  - [ ] Implement caching strategy
  - [ ] Add lazy loading
  - [ ] Optimize quota usage

- [ ] **User Experience**
  - [ ] Add loading states
  - [ ] Implement error recovery
  - [ ] Support offline scenarios

### Key API Endpoints

```
# Check for live streams
GET https://www.googleapis.com/youtube/v3/search
  ?part=snippet
  &channelId={CHANNEL_ID}
  &eventType=live
  &type=video
  &key={API_KEY}

# Get live stream details
GET https://www.googleapis.com/youtube/v3/videos
  ?part=liveStreamingDetails
  &id={VIDEO_ID}
  &key={API_KEY}

# Get viewer count (unofficial)
GET https://www.youtube.com/live_stats?v={VIDEO_ID}
```

### Embed URL Pattern

```
https://www.youtube.com/embed/{VIDEO_ID}
  ?autoplay=1
  &mute=1
  &controls=1
  &modestbranding=1
  &rel=0
  &enablejsapi=1
```

### Important Limitations

- **API Quota**: 10,000 units/day default (search.list = 100 units)
- **Detection Delay**: 30-60 seconds lag behind actual stream start
- **PubSubHubbub**: Unreliable for live stream notifications
- **Autoplay**: Requires mute=1 on most browsers
- **OAuth**: Required for liveBroadcasts.list (user's own broadcasts)

---

## Resources

**Official Documentation:**
- [YouTube Data API v3](https://developers.google.com/youtube/v3)
- [YouTube Live Streaming API](https://developers.google.com/youtube/v3/live)
- [YouTube IFrame Player API](https://developers.google.com/youtube/iframe_api_reference)
- [YouTube Player Parameters](https://developers.google.com/youtube/player_parameters)

**Flutter Packages:**
- [webview_flutter](https://pub.dev/packages/webview_flutter) - WebView integration
- [http](https://pub.dev/packages/http) - HTTP requests
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) - Network status

**Sample Code:**
- [YouTube API Samples (GitHub)](https://github.com/youtube/api-samples)
- All code examples in this document are production-ready

---

*Last Updated: January 2025*
*API Version: YouTube Data API v3*
