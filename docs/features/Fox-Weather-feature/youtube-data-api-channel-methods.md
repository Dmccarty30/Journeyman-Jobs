# YouTube Data API v3 - Channel Data Retrieval Guide

## 📋 Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Channel Data Retrieval](#channel-data-retrieval)
- [Video Listing & Pagination](#video-listing--pagination)
- [Playlist Retrieval](#playlist-retrieval)
- [Quota Management](#quota-management)
- [Code Examples](#code-examples)
- [Best Practices](#best-practices)
- [Error Handling](#error-handling)

---

## Overview

This guide focuses on retrieving data from the **@Foxweather** YouTube channel (11k+ videos, 554M views) using YouTube Data API v3. It covers efficient methods for handling large video catalogs while managing API quota constraints.

### Base API URL
```
https://www.googleapis.com/youtube/v3
```

### Key Statistics - Fox Weather Channel
- **Channel Handle**: @Foxweather
- **Videos**: 11,000+
- **Total Views**: 554 million
- **Content Type**: Weather news, forecasts, live streams

---

## Authentication

### Method 1: API Key (Recommended for Public Data)

**Use Case**: Reading publicly available data (channel info, public videos)

**Setup**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable YouTube Data API v3
4. Create API Key credentials

**JavaScript Example**:
```javascript
const API_KEY = process.env.YOUTUBE_API_KEY;

// Basic request with API key
const response = await fetch(
  `https://www.googleapis.com/youtube/v3/channels?` +
  `part=snippet,statistics,contentDetails&` +
  `forHandle=Foxweather&` +
  `key=${API_KEY}`
);
```

**TypeScript Type Definition**:
```typescript
interface YouTubeConfig {
  apiKey: string;
  baseUrl: string;
}

const config: YouTubeConfig = {
  apiKey: process.env.YOUTUBE_API_KEY || '',
  baseUrl: 'https://www.googleapis.com/youtube/v3'
};
```

### Method 2: OAuth 2.0 (Required for Private Data)

**Use Case**: Accessing private videos, user-specific data, write operations

**Setup Flow**:
```javascript
import { google } from 'googleapis';

const oauth2Client = new google.auth.OAuth2(
  process.env.CLIENT_ID,
  process.env.CLIENT_SECRET,
  process.env.REDIRECT_URI
);

// Generate auth URL
const authUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline', // Get refresh token
  scope: ['https://www.googleapis.com/auth/youtube.readonly']
});

// After user authorizes, exchange code for tokens
const { tokens } = await oauth2Client.getToken(code);
oauth2Client.setCredentials(tokens);

// Use with YouTube API
const youtube = google.youtube({
  version: 'v3',
  auth: oauth2Client
});
```

### Security Best Practices

1. **Never commit API keys**: Use environment variables
   ```javascript
   // ✅ GOOD
   const apiKey = process.env.YOUTUBE_API_KEY;

   // ❌ BAD
   const apiKey = 'AIzaSyD...';
   ```

2. **Implement key rotation**: Regularly regenerate API keys

3. **Use API restrictions**: Limit keys to specific APIs and domains

4. **Store OAuth tokens securely**:
   ```javascript
   // Store refresh tokens encrypted
   const encryptedToken = encrypt(oauth2Client.credentials.refresh_token);
   await db.saveToken(userId, encryptedToken);
   ```

5. **Implement incremental authorization**: Request scopes as needed

---

## Channel Data Retrieval

### channels.list Method

**Quota Cost**: 1 unit per request

**Endpoint**:
```
GET https://www.googleapis.com/youtube/v3/channels
```

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `part` | Resource properties to include | `snippet,statistics,contentDetails` |

### Filter Parameters (Choose One)

| Parameter | Description | Example |
|-----------|-------------|---------|
| `id` | Channel ID(s) | `UCiYFH0VJ9gl0ljnAxAiJeA` |
| `forHandle` | YouTube handle | `Foxweather` |
| `forUsername` | Legacy username | `foxweatherchannel` |
| `mine` | Authenticated user's channels | `true` |

### Optional Parameters

| Parameter | Description | Default | Range |
|-----------|-------------|---------|-------|
| `maxResults` | Items per page | 5 | 0-50 |
| `hl` | Localization language | en_US | ISO 639-1 |

### Complete TypeScript Example

```typescript
interface ChannelSnippet {
  title: string;
  description: string;
  customUrl: string;
  publishedAt: string;
  thumbnails: {
    default: Thumbnail;
    medium: Thumbnail;
    high: Thumbnail;
  };
  localized: {
    title: string;
    description: string;
  };
  country: string;
}

interface ChannelStatistics {
  viewCount: string;
  subscriberCount: string;
  hiddenSubscriberCount: boolean;
  videoCount: string;
}

interface ChannelContentDetails {
  relatedPlaylists: {
    likes: string;
    uploads: string; // 🔑 Key for retrieving all videos
  };
}

interface ChannelResponse {
  kind: string;
  etag: string;
  pageInfo: {
    totalResults: number;
    resultsPerPage: number;
  };
  items: Array<{
    kind: string;
    etag: string;
    id: string;
    snippet: ChannelSnippet;
    statistics: ChannelStatistics;
    contentDetails: ChannelContentDetails;
  }>;
}

async function getChannelData(handle: string): Promise<ChannelResponse> {
  const params = new URLSearchParams({
    part: 'snippet,statistics,contentDetails',
    forHandle: handle,
    key: API_KEY
  });

  const response = await fetch(
    `https://www.googleapis.com/youtube/v3/channels?${params}`
  );

  if (!response.ok) {
    throw new Error(`API error: ${response.status} ${response.statusText}`);
  }

  return response.json();
}

// Usage
const foxWeatherData = await getChannelData('Foxweather');
const uploadsPlaylistId = foxWeatherData.items[0].contentDetails.relatedPlaylists.uploads;
console.log('Uploads Playlist ID:', uploadsPlaylistId);
```

### Sample Response

```json
{
  "kind": "youtube#channelListResponse",
  "etag": "abc123",
  "pageInfo": {
    "totalResults": 1,
    "resultsPerPage": 5
  },
  "items": [
    {
      "kind": "youtube#channel",
      "etag": "xyz789",
      "id": "UCiYFH0VJ9gl0ljnAxAiJeA",
      "snippet": {
        "title": "FOX Weather",
        "description": "America's Weather Team...",
        "customUrl": "@foxweather",
        "publishedAt": "2021-09-13T18:30:45Z",
        "thumbnails": {
          "high": {
            "url": "https://yt3.ggpht.com/...",
            "width": 800,
            "height": 800
          }
        },
        "country": "US"
      },
      "statistics": {
        "viewCount": "554000000",
        "subscriberCount": "250000",
        "videoCount": "11234"
      },
      "contentDetails": {
        "relatedPlaylists": {
          "uploads": "UUiYFH0VJ9gl0ljnAxAiJeA"
        }
      }
    }
  ]
}
```

---

## Video Listing & Pagination

### ⚠️ Important: Choose the Right Method

| Method | Quota Cost | Max Results | Best For |
|--------|------------|-------------|----------|
| `search.list` | **100 units** | 500 videos | Searching across YouTube |
| `playlistItems.list` | **1 unit** | Unlimited | Channel's all videos |

**Recommendation**: Use `playlistItems.list` with the uploads playlist for 99% less quota cost!

### Method 1: playlistItems.list (Recommended)

**Quota Cost**: 1 unit per request (50 videos)

**Complete Implementation**:

```typescript
interface PlaylistItem {
  kind: string;
  etag: string;
  id: string;
  snippet: {
    publishedAt: string;
    channelId: string;
    title: string;
    description: string;
    thumbnails: {
      default: Thumbnail;
      medium: Thumbnail;
      high: Thumbnail;
      standard?: Thumbnail;
      maxres?: Thumbnail;
    };
    channelTitle: string;
    playlistId: string;
    position: number;
    resourceId: {
      kind: string;
      videoId: string;
    };
    videoOwnerChannelTitle: string;
    videoOwnerChannelId: string;
  };
  contentDetails: {
    videoId: string;
    videoPublishedAt: string;
  };
}

interface PlaylistItemsResponse {
  kind: string;
  etag: string;
  nextPageToken?: string;
  prevPageToken?: string;
  pageInfo: {
    totalResults: number;
    resultsPerPage: number;
  };
  items: PlaylistItem[];
}

async function getAllChannelVideos(
  uploadsPlaylistId: string,
  maxVideos: number = Infinity
): Promise<PlaylistItem[]> {
  const allVideos: PlaylistItem[] = [];
  let pageToken: string | undefined;
  let pageCount = 0;

  do {
    const params = new URLSearchParams({
      part: 'snippet,contentDetails',
      playlistId: uploadsPlaylistId,
      maxResults: '50', // Maximum allowed
      key: API_KEY
    });

    if (pageToken) {
      params.append('pageToken', pageToken);
    }

    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/playlistItems?${params}`
    );

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const data: PlaylistItemsResponse = await response.json();
    allVideos.push(...data.items);

    pageToken = data.nextPageToken;
    pageCount++;

    console.log(
      `Fetched page ${pageCount}: ${allVideos.length}/${data.pageInfo.totalResults} videos`
    );

    // Respect quota limits
    if (allVideos.length >= maxVideos) {
      break;
    }

    // Rate limiting: Wait 100ms between requests
    if (pageToken) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }

  } while (pageToken);

  return allVideos.slice(0, maxVideos);
}

// Usage: Fetch all Fox Weather videos (11k+)
const uploadsId = 'UUiYFH0VJ9gl0ljnAxAiJeA';
const videos = await getAllChannelVideos(uploadsId);

console.log(`Total videos fetched: ${videos.length}`);
console.log('Quota used:', Math.ceil(videos.length / 50), 'units');
```

### Pagination with Progress Tracking

```typescript
interface FetchProgress {
  currentPage: number;
  totalPages: number;
  videosCollected: number;
  totalVideos: number;
  quotaUsed: number;
  estimatedQuotaRemaining: number;
}

async function getAllVideosWithProgress(
  uploadsPlaylistId: string,
  onProgress?: (progress: FetchProgress) => void
): Promise<PlaylistItem[]> {
  const allVideos: PlaylistItem[] = [];
  let pageToken: string | undefined;
  let currentPage = 0;
  let totalResults = 0;

  do {
    currentPage++;

    const params = new URLSearchParams({
      part: 'snippet,contentDetails',
      playlistId: uploadsPlaylistId,
      maxResults: '50',
      key: API_KEY
    });

    if (pageToken) params.append('pageToken', pageToken);

    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/playlistItems?${params}`
    );

    const data: PlaylistItemsResponse = await response.json();

    if (currentPage === 1) {
      totalResults = data.pageInfo.totalResults;
    }

    allVideos.push(...data.items);
    pageToken = data.nextPageToken;

    // Progress callback
    if (onProgress) {
      const totalPages = Math.ceil(totalResults / 50);
      const quotaUsed = currentPage;
      const estimatedQuotaRemaining = 10000 - quotaUsed;

      onProgress({
        currentPage,
        totalPages,
        videosCollected: allVideos.length,
        totalVideos: totalResults,
        quotaUsed,
        estimatedQuotaRemaining
      });
    }

    // Rate limiting
    if (pageToken) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }

  } while (pageToken);

  return allVideos;
}

// Usage with progress tracking
const videos = await getAllVideosWithProgress(
  uploadsId,
  (progress) => {
    console.log(
      `Progress: ${progress.currentPage}/${progress.totalPages} pages | ` +
      `${progress.videosCollected}/${progress.totalVideos} videos | ` +
      `Quota: ${progress.quotaUsed} units`
    );
  }
);
```

### Method 2: search.list (High Quota Cost)

**⚠️ Warning**: 100 units per request, 500 video limit

**Only use when**:
- Searching across multiple channels
- Need real-time search results
- Filtering by specific criteria

```typescript
interface SearchResult {
  kind: string;
  etag: string;
  id: {
    kind: string;
    videoId: string;
  };
  snippet: {
    publishedAt: string;
    channelId: string;
    title: string;
    description: string;
    thumbnails: {
      default: Thumbnail;
      medium: Thumbnail;
      high: Thumbnail;
    };
    channelTitle: string;
    liveBroadcastContent: string;
  };
}

async function searchChannelVideos(
  channelId: string,
  maxResults: number = 50
): Promise<SearchResult[]> {
  const params = new URLSearchParams({
    part: 'snippet',
    channelId: channelId,
    type: 'video',
    order: 'date', // date, rating, relevance, title, videoCount, viewCount
    maxResults: Math.min(maxResults, 50).toString(),
    key: API_KEY
  });

  const response = await fetch(
    `https://www.googleapis.com/youtube/v3/search?${params}`
  );

  const data = await response.json();

  console.warn(`⚠️ Quota cost: 100 units for ${data.items.length} videos`);

  return data.items;
}
```

---

## Playlist Retrieval

### playlists.list Method

**Quota Cost**: 1 unit

**Use Cases**:
- List all playlists for a channel
- Get specific playlist details
- Retrieve playlist metadata

```typescript
interface Playlist {
  kind: string;
  etag: string;
  id: string;
  snippet: {
    publishedAt: string;
    channelId: string;
    title: string;
    description: string;
    thumbnails: {
      default: Thumbnail;
      medium: Thumbnail;
      high: Thumbnail;
      standard?: Thumbnail;
      maxres?: Thumbnail;
    };
    channelTitle: string;
    localized: {
      title: string;
      description: string;
    };
  };
  contentDetails: {
    itemCount: number;
  };
}

async function getChannelPlaylists(channelId: string): Promise<Playlist[]> {
  const allPlaylists: Playlist[] = [];
  let pageToken: string | undefined;

  do {
    const params = new URLSearchParams({
      part: 'snippet,contentDetails',
      channelId: channelId,
      maxResults: '50',
      key: API_KEY
    });

    if (pageToken) params.append('pageToken', pageToken);

    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/playlists?${params}`
    );

    const data = await response.json();
    allPlaylists.push(...data.items);
    pageToken = data.nextPageToken;

  } while (pageToken);

  return allPlaylists;
}

// Get specific playlist by ID
async function getPlaylist(playlistId: string): Promise<Playlist> {
  const params = new URLSearchParams({
    part: 'snippet,contentDetails',
    id: playlistId,
    key: API_KEY
  });

  const response = await fetch(
    `https://www.googleapis.com/youtube/v3/playlists?${params}`
  );

  const data = await response.json();
  return data.items[0];
}
```

---

## Quota Management

### Daily Quota Allocation

- **Default**: 10,000 units per day
- **Reset Time**: Midnight Pacific Time (PT)
- **Rate Limits**:
  - 1.6 million queries per minute (effectively limited by daily quota)
  - Per-user limits also apply

### Quota Costs Reference

| Operation | Quota Cost | Notes |
|-----------|------------|-------|
| `channels.list` | 1 unit | Get channel data |
| `playlistItems.list` | 1 unit | **Most efficient for videos** |
| `playlists.list` | 1 unit | List channel playlists |
| `videos.list` | 1 unit | Get video details |
| `search.list` | **100 units** | ⚠️ Very expensive |
| `captions.list` | 50 units | Read captions |
| `videos.update` | 50 units | Modify video metadata |
| `videos.insert` | 1,600 units | Upload video |

### Quota Calculation for Fox Weather (11k videos)

```typescript
interface QuotaEstimate {
  operation: string;
  itemsPerRequest: number;
  totalItems: number;
  requestsNeeded: number;
  quotaCostPerRequest: number;
  totalQuotaCost: number;
  daysNeeded: number;
}

function calculateQuota(
  totalVideos: number,
  method: 'playlistItems' | 'search'
): QuotaEstimate {
  const costs = {
    playlistItems: 1,
    search: 100
  };

  const requestsNeeded = Math.ceil(totalVideos / 50);
  const totalQuotaCost = requestsNeeded * costs[method];
  const daysNeeded = Math.ceil(totalQuotaCost / 10000);

  return {
    operation: method,
    itemsPerRequest: 50,
    totalItems: totalVideos,
    requestsNeeded,
    quotaCostPerRequest: costs[method],
    totalQuotaCost,
    daysNeeded
  };
}

// Example: Fox Weather's 11,000 videos
const playlistMethod = calculateQuota(11000, 'playlistItems');
console.log('Using playlistItems.list:');
console.log(`  Requests needed: ${playlistMethod.requestsNeeded}`);
console.log(`  Total quota: ${playlistMethod.totalQuotaCost} units`);
console.log(`  Days needed: ${playlistMethod.daysNeeded} day(s)`);
console.log(`  Remaining quota: ${10000 - playlistMethod.totalQuotaCost} units`);

const searchMethod = calculateQuota(500, 'search'); // 500 = max with search
console.log('\nUsing search.list (max 500 videos):');
console.log(`  Requests needed: ${searchMethod.requestsNeeded}`);
console.log(`  Total quota: ${searchMethod.totalQuotaCost} units`);
console.log(`  Days needed: ${searchMethod.daysNeeded} day(s)`);
console.log(`  ⚠️ Cannot retrieve all 11k videos with this method`);
```

**Output**:
```
Using playlistItems.list:
  Requests needed: 220
  Total quota: 220 units
  Days needed: 1 day(s)
  Remaining quota: 9780 units

Using search.list (max 500 videos):
  Requests needed: 10
  Total quota: 1000 units
  Days needed: 1 day(s)
  ⚠️ Cannot retrieve all 11k videos with this method
```

### Quota Optimization Strategies

#### 1. Batch Operations

```typescript
// ❌ BAD: Multiple individual requests
async function getVideoDetailsBad(videoIds: string[]) {
  const details = [];
  for (const id of videoIds) {
    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/videos?` +
      `part=snippet&id=${id}&key=${API_KEY}`
    );
    details.push(await response.json());
  }
  return details; // Cost: videoIds.length units
}

// ✅ GOOD: Batch request (up to 50 IDs)
async function getVideoDetailsGood(videoIds: string[]) {
  const batches = [];
  for (let i = 0; i < videoIds.length; i += 50) {
    const batch = videoIds.slice(i, i + 50);
    const params = new URLSearchParams({
      part: 'snippet,statistics,contentDetails',
      id: batch.join(','),
      key: API_KEY
    });

    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/videos?${params}`
    );
    batches.push(await response.json());
  }
  return batches.flatMap(b => b.items);
  // Cost: Math.ceil(videoIds.length / 50) units
}
```

#### 2. Smart Caching

```typescript
class YouTubeCache {
  private cache = new Map<string, { data: any; timestamp: number }>();
  private readonly TTL = 3600000; // 1 hour in milliseconds

  async get<T>(
    key: string,
    fetcher: () => Promise<T>
  ): Promise<T> {
    const cached = this.cache.get(key);

    if (cached && Date.now() - cached.timestamp < this.TTL) {
      console.log(`✓ Cache hit: ${key}`);
      return cached.data as T;
    }

    console.log(`✗ Cache miss: ${key} - Fetching from API`);
    const data = await fetcher();
    this.cache.set(key, { data, timestamp: Date.now() });

    return data;
  }

  clear(pattern?: RegExp) {
    if (!pattern) {
      this.cache.clear();
      return;
    }

    for (const key of this.cache.keys()) {
      if (pattern.test(key)) {
        this.cache.delete(key);
      }
    }
  }
}

// Usage
const cache = new YouTubeCache();

const channelData = await cache.get(
  'channel:Foxweather',
  () => getChannelData('Foxweather')
);
```

#### 3. Incremental Updates

```typescript
interface VideoUpdate {
  videoId: string;
  publishedAt: string;
  title: string;
}

async function getNewVideosSince(
  uploadsPlaylistId: string,
  lastFetchDate: Date
): Promise<VideoUpdate[]> {
  const newVideos: VideoUpdate[] = [];
  let pageToken: string | undefined;

  do {
    const params = new URLSearchParams({
      part: 'snippet',
      playlistId: uploadsPlaylistId,
      maxResults: '50',
      key: API_KEY
    });

    if (pageToken) params.append('pageToken', pageToken);

    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/playlistItems?${params}`
    );

    const data = await response.json();

    for (const item of data.items) {
      const publishedAt = new Date(item.snippet.publishedAt);

      if (publishedAt <= lastFetchDate) {
        // Reached videos we already have
        return newVideos;
      }

      newVideos.push({
        videoId: item.contentDetails.videoId,
        publishedAt: item.snippet.publishedAt,
        title: item.snippet.title
      });
    }

    pageToken = data.nextPageToken;
  } while (pageToken);

  return newVideos;
}

// Usage: Only fetch videos uploaded since last check
const lastCheck = new Date('2025-01-15T00:00:00Z');
const newVideos = await getNewVideosSince(uploadsId, lastCheck);
console.log(`Found ${newVideos.length} new videos`);
console.log(`Quota saved: ${Math.ceil(11000 / 50) - Math.ceil(newVideos.length / 50)} units`);
```

#### 4. Quota Monitoring

```typescript
class QuotaMonitor {
  private quotaUsed = 0;
  private readonly dailyLimit = 10000;
  private resetTime = this.getNextResetTime();

  private getNextResetTime(): Date {
    const now = new Date();
    const reset = new Date(now);
    reset.setUTCHours(8, 0, 0, 0); // Midnight PT = 8am UTC

    if (now.getUTCHours() >= 8) {
      reset.setUTCDate(reset.getUTCDate() + 1);
    }

    return reset;
  }

  trackRequest(cost: number) {
    const now = new Date();

    if (now >= this.resetTime) {
      console.log('🔄 Daily quota reset');
      this.quotaUsed = 0;
      this.resetTime = this.getNextResetTime();
    }

    this.quotaUsed += cost;

    const remaining = this.dailyLimit - this.quotaUsed;
    const percentUsed = (this.quotaUsed / this.dailyLimit) * 100;

    console.log(
      `📊 Quota: ${this.quotaUsed}/${this.dailyLimit} (${percentUsed.toFixed(1)}%) | ` +
      `Remaining: ${remaining} | ` +
      `Resets: ${this.resetTime.toLocaleTimeString()}`
    );

    if (percentUsed >= 90) {
      console.warn('⚠️ WARNING: 90% quota used!');
    }

    if (remaining <= 0) {
      throw new Error('❌ Daily quota exceeded!');
    }
  }

  getRemainingQuota(): number {
    return this.dailyLimit - this.quotaUsed;
  }

  canAfford(cost: number): boolean {
    return this.getRemainingQuota() >= cost;
  }
}

// Usage
const monitor = new QuotaMonitor();

async function getVideosWithMonitoring(playlistId: string) {
  const estimatedCost = Math.ceil(11000 / 50); // 220 units

  if (!monitor.canAfford(estimatedCost)) {
    throw new Error('Insufficient quota for this operation');
  }

  const videos = await getAllChannelVideos(playlistId);
  monitor.trackRequest(estimatedCost);

  return videos;
}
```

### Requesting Additional Quota

If 10,000 units/day is insufficient:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services → YouTube Data API v3
3. Click "Quotas & System Limits"
4. Submit quota increase request form
5. Provide justification for increased quota

---

## Code Examples

### Complete Working Example: Fox Weather Channel Analyzer

```typescript
import fs from 'fs/promises';

// Configuration
const CONFIG = {
  API_KEY: process.env.YOUTUBE_API_KEY || '',
  BASE_URL: 'https://www.googleapis.com/youtube/v3',
  CHANNEL_HANDLE: 'Foxweather',
  OUTPUT_DIR: './data'
};

// Main orchestrator
class FoxWeatherAnalyzer {
  private cache: YouTubeCache;
  private monitor: QuotaMonitor;
  private channelId?: string;
  private uploadsPlaylistId?: string;

  constructor() {
    this.cache = new YouTubeCache();
    this.monitor = new QuotaMonitor();
  }

  async initialize() {
    console.log('🚀 Initializing Fox Weather Analyzer...\n');

    // Step 1: Get channel data
    const channelData = await this.cache.get(
      `channel:${CONFIG.CHANNEL_HANDLE}`,
      async () => {
        this.monitor.trackRequest(1);
        return await this.getChannelData();
      }
    );

    this.channelId = channelData.items[0].id;
    this.uploadsPlaylistId = channelData.items[0].contentDetails.relatedPlaylists.uploads;

    console.log('✓ Channel initialized:');
    console.log(`  ID: ${this.channelId}`);
    console.log(`  Name: ${channelData.items[0].snippet.title}`);
    console.log(`  Videos: ${channelData.items[0].statistics.videoCount}`);
    console.log(`  Views: ${channelData.items[0].statistics.viewCount}`);
    console.log(`  Uploads Playlist: ${this.uploadsPlaylistId}\n`);
  }

  async getChannelData(): Promise<ChannelResponse> {
    const params = new URLSearchParams({
      part: 'snippet,statistics,contentDetails',
      forHandle: CONFIG.CHANNEL_HANDLE,
      key: CONFIG.API_KEY
    });

    const response = await fetch(`${CONFIG.BASE_URL}/channels?${params}`);

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    return response.json();
  }

  async getAllVideos(maxVideos: number = Infinity): Promise<PlaylistItem[]> {
    if (!this.uploadsPlaylistId) {
      throw new Error('Must call initialize() first');
    }

    console.log(`📥 Fetching videos (max: ${maxVideos})...\n`);

    const videos: PlaylistItem[] = [];
    let pageToken: string | undefined;
    let page = 0;

    do {
      page++;
      const params = new URLSearchParams({
        part: 'snippet,contentDetails',
        playlistId: this.uploadsPlaylistId,
        maxResults: '50',
        key: CONFIG.API_KEY
      });

      if (pageToken) params.append('pageToken', pageToken);

      const response = await fetch(
        `${CONFIG.BASE_URL}/playlistItems?${params}`
      );

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const data: PlaylistItemsResponse = await response.json();
      videos.push(...data.items);

      this.monitor.trackRequest(1);

      console.log(
        `  Page ${page}: ${videos.length}/${data.pageInfo.totalResults} videos`
      );

      pageToken = data.nextPageToken;

      if (videos.length >= maxVideos) break;

      // Rate limiting
      if (pageToken) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }

    } while (pageToken && this.monitor.canAfford(1));

    console.log(`\n✓ Fetched ${videos.length} videos\n`);
    return videos.slice(0, maxVideos);
  }

  async analyzeVideos(videos: PlaylistItem[]) {
    console.log('📊 Analyzing videos...\n');

    // Group by year
    const byYear = videos.reduce((acc, video) => {
      const year = new Date(video.snippet.publishedAt).getFullYear();
      acc[year] = (acc[year] || 0) + 1;
      return acc;
    }, {} as Record<number, number>);

    // Most recent videos
    const recent = videos
      .sort((a, b) =>
        new Date(b.snippet.publishedAt).getTime() -
        new Date(a.snippet.publishedAt).getTime()
      )
      .slice(0, 10);

    // Statistics
    const stats = {
      totalVideos: videos.length,
      videosByYear: byYear,
      recentVideos: recent.map(v => ({
        title: v.snippet.title,
        publishedAt: v.snippet.publishedAt,
        videoId: v.contentDetails.videoId
      })),
      oldestVideo: videos[videos.length - 1]?.snippet.publishedAt,
      newestVideo: videos[0]?.snippet.publishedAt
    };

    console.log('Statistics:');
    console.log(`  Total videos: ${stats.totalVideos}`);
    console.log(`  Date range: ${stats.oldestVideo} to ${stats.newestVideo}`);
    console.log('  Videos by year:', stats.videosByYear);

    return stats;
  }

  async saveToFile(data: any, filename: string) {
    await fs.mkdir(CONFIG.OUTPUT_DIR, { recursive: true });
    const filepath = `${CONFIG.OUTPUT_DIR}/${filename}`;
    await fs.writeFile(filepath, JSON.stringify(data, null, 2));
    console.log(`\n💾 Saved to ${filepath}`);
  }

  async run() {
    try {
      await this.initialize();

      // Fetch first 1000 videos (20 API calls = 20 quota units)
      const videos = await this.getAllVideos(1000);

      // Analyze
      const stats = await this.analyzeVideos(videos);

      // Save results
      await this.saveToFile(videos, 'foxweather-videos.json');
      await this.saveToFile(stats, 'foxweather-stats.json');

      console.log('\n✅ Analysis complete!');
      console.log(`📈 Quota used: ${this.monitor['quotaUsed']} / 10000 units`);

    } catch (error) {
      console.error('❌ Error:', error);
      throw error;
    }
  }
}

// Execute
const analyzer = new FoxWeatherAnalyzer();
analyzer.run();
```

### Running the Example

```bash
# Install dependencies
npm install dotenv

# Set up environment
echo "YOUTUBE_API_KEY=your_api_key_here" > .env

# Run the analyzer
npx tsx foxweather-analyzer.ts
```

**Expected Output**:
```
🚀 Initializing Fox Weather Analyzer...

✓ Cache hit: channel:Foxweather
✓ Channel initialized:
  ID: UCiYFH0VJ9gl0ljnAxAiJeA
  Name: FOX Weather
  Videos: 11234
  Views: 554000000
  Uploads Playlist: UUiYFH0VJ9gl0ljnAxAiJeA

📥 Fetching videos (max: 1000)...

  Page 1: 50/11234 videos
📊 Quota: 1/10000 (0.0%) | Remaining: 9999 | Resets: 12:00:00 AM
  Page 2: 100/11234 videos
📊 Quota: 2/10000 (0.0%) | Remaining: 9998 | Resets: 12:00:00 AM
  ...
  Page 20: 1000/11234 videos
📊 Quota: 20/10000 (0.2%) | Remaining: 9980 | Resets: 12:00:00 AM

✓ Fetched 1000 videos

📊 Analyzing videos...

Statistics:
  Total videos: 1000
  Date range: 2021-09-15 to 2025-01-26
  Videos by year: { 2021: 45, 2022: 312, 2023: 298, 2024: 285, 2025: 60 }

💾 Saved to ./data/foxweather-videos.json
💾 Saved to ./data/foxweather-stats.json

✅ Analysis complete!
📈 Quota used: 20 / 10000 units
```

---

## Best Practices

### 1. Efficient Data Retrieval

✅ **DO**:
- Use `playlistItems.list` for channel videos (1 unit/request)
- Batch video detail requests (up to 50 IDs per request)
- Cache frequently accessed data
- Implement incremental updates
- Use pagination wisely

❌ **DON'T**:
- Use `search.list` for channel videos (100 units/request)
- Make individual requests in loops
- Fetch all data every time
- Ignore pagination tokens

### 2. Quota Management

```typescript
// ✅ GOOD: Calculate cost before proceeding
async function safeOperation(estimatedCost: number) {
  if (!monitor.canAfford(estimatedCost)) {
    const remaining = monitor.getRemainingQuota();
    throw new Error(
      `Insufficient quota. Need ${estimatedCost}, have ${remaining}`
    );
  }

  // Proceed with operation
  await expensiveAPICall();
  monitor.trackRequest(estimatedCost);
}

// ❌ BAD: No quota checking
async function unsafeOperation() {
  await expensiveAPICall(); // May fail if quota exceeded
}
```

### 3. Error Handling

```typescript
interface YouTubeError {
  error: {
    code: number;
    message: string;
    errors: Array<{
      domain: string;
      reason: string;
      message: string;
    }>;
  };
}

async function robustAPICall<T>(
  url: string,
  retries: number = 3
): Promise<T> {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const response = await fetch(url);

      if (!response.ok) {
        const error: YouTubeError = await response.json();

        // Handle specific error codes
        switch (response.status) {
          case 403:
            if (error.error.errors[0]?.reason === 'quotaExceeded') {
              throw new Error('Daily quota exceeded. Try again tomorrow.');
            }
            throw new Error(`Access denied: ${error.error.message}`);

          case 404:
            throw new Error('Resource not found');

          case 429:
            // Rate limited - exponential backoff
            const delay = Math.pow(2, attempt) * 1000;
            console.log(`Rate limited. Retrying in ${delay}ms...`);
            await new Promise(resolve => setTimeout(resolve, delay));
            continue;

          case 500:
          case 503:
            // Server error - retry with backoff
            if (attempt < retries) {
              const delay = Math.pow(2, attempt) * 1000;
              console.log(`Server error. Retrying in ${delay}ms...`);
              await new Promise(resolve => setTimeout(resolve, delay));
              continue;
            }
            throw new Error('YouTube API server error');

          default:
            throw new Error(`API error ${response.status}: ${error.error.message}`);
        }
      }

      return response.json();

    } catch (err) {
      if (attempt === retries) {
        throw err;
      }
      console.log(`Attempt ${attempt}/${retries} failed. Retrying...`);
    }
  }

  throw new Error('Max retries exceeded');
}
```

### 4. Rate Limiting

```typescript
class RateLimiter {
  private queue: Array<() => Promise<any>> = [];
  private processing = false;
  private readonly delayMs: number;

  constructor(requestsPerSecond: number = 10) {
    this.delayMs = 1000 / requestsPerSecond;
  }

  async execute<T>(operation: () => Promise<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push(async () => {
        try {
          const result = await operation();
          resolve(result);
        } catch (err) {
          reject(err);
        }
      });

      this.processQueue();
    });
  }

  private async processQueue() {
    if (this.processing || this.queue.length === 0) return;

    this.processing = true;

    while (this.queue.length > 0) {
      const operation = this.queue.shift()!;
      await operation();
      await new Promise(resolve => setTimeout(resolve, this.delayMs));
    }

    this.processing = false;
  }
}

// Usage: Limit to 10 requests per second
const limiter = new RateLimiter(10);

const results = await Promise.all(
  videoIds.map(id =>
    limiter.execute(() => getVideoDetails(id))
  )
);
```

### 5. Data Storage Optimization

```typescript
interface VideoMetadata {
  id: string;
  title: string;
  publishedAt: string;
  thumbnailUrl: string;
  // Only store essential fields
}

async function storeVideosEfficiently(videos: PlaylistItem[]) {
  // Extract only needed data
  const metadata: VideoMetadata[] = videos.map(v => ({
    id: v.contentDetails.videoId,
    title: v.snippet.title,
    publishedAt: v.snippet.publishedAt,
    thumbnailUrl: v.snippet.thumbnails.medium.url
  }));

  // Compress if needed
  const compressed = JSON.stringify(metadata);

  // Store with timestamp
  const data = {
    fetchedAt: new Date().toISOString(),
    count: metadata.length,
    videos: metadata
  };

  await fs.writeFile('videos.json', JSON.stringify(data, null, 2));

  console.log(`Stored ${metadata.length} videos`);
  console.log(`File size: ${Buffer.byteLength(compressed)} bytes`);
}
```

---

## Error Handling

### Common Error Codes

| Code | Reason | Solution |
|------|--------|----------|
| 400 | Bad Request | Check parameter syntax |
| 401 | Unauthorized | Verify API key/OAuth token |
| 403 | Forbidden | Check API key restrictions or quota |
| 404 | Not Found | Verify channel/video ID exists |
| 429 | Too Many Requests | Implement rate limiting |
| 500 | Internal Server Error | Retry with exponential backoff |
| 503 | Service Unavailable | Retry later |

### Quota-Specific Errors

```typescript
{
  "error": {
    "code": 403,
    "message": "The request cannot be completed because you have exceeded your quota.",
    "errors": [
      {
        "domain": "youtube.quota",
        "reason": "quotaExceeded",
        "message": "The request cannot be completed because you have exceeded your quota."
      }
    ]
  }
}
```

### Comprehensive Error Handler

```typescript
class YouTubeAPIError extends Error {
  constructor(
    public code: number,
    public reason: string,
    message: string
  ) {
    super(message);
    this.name = 'YouTubeAPIError';
  }
}

async function handleYouTubeRequest<T>(
  url: string,
  options: {
    retries?: number;
    onQuotaExceeded?: () => void;
    onRateLimit?: (retryAfter: number) => void;
  } = {}
): Promise<T> {
  const { retries = 3, onQuotaExceeded, onRateLimit } = options;

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const response = await fetch(url);

      if (response.ok) {
        return response.json();
      }

      const error: YouTubeError = await response.json();
      const reason = error.error.errors[0]?.reason || 'unknown';

      // Quota exceeded - no point retrying
      if (reason === 'quotaExceeded') {
        if (onQuotaExceeded) onQuotaExceeded();
        throw new YouTubeAPIError(
          403,
          'quotaExceeded',
          'Daily quota limit reached. Resets at midnight PT.'
        );
      }

      // Rate limited - retry with backoff
      if (response.status === 429) {
        const retryAfter = parseInt(response.headers.get('Retry-After') || '5');
        const delay = retryAfter * 1000;

        if (onRateLimit) onRateLimit(retryAfter);

        if (attempt < retries) {
          console.log(`Rate limited. Retrying in ${retryAfter}s...`);
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
      }

      // Server errors - retry
      if (response.status >= 500 && attempt < retries) {
        const delay = Math.pow(2, attempt) * 1000;
        console.log(`Server error. Retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }

      throw new YouTubeAPIError(
        response.status,
        reason,
        error.error.message
      );

    } catch (err) {
      if (err instanceof YouTubeAPIError) throw err;
      if (attempt === retries) throw err;

      console.log(`Network error. Retry ${attempt}/${retries}...`);
      await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
    }
  }

  throw new Error('Max retries exceeded');
}

// Usage with callbacks
try {
  const data = await handleYouTubeRequest<ChannelResponse>(url, {
    retries: 5,
    onQuotaExceeded: () => {
      console.log('⚠️ Quota exceeded! Saving progress...');
      saveProgressToFile();
    },
    onRateLimit: (seconds) => {
      console.log(`⏳ Rate limited for ${seconds} seconds`);
    }
  });
} catch (err) {
  if (err instanceof YouTubeAPIError) {
    console.error(`YouTube API Error [${err.code}]: ${err.message}`);
    console.error(`Reason: ${err.reason}`);
  } else {
    console.error('Unexpected error:', err);
  }
}
```

---

## Summary

### For Fox Weather Channel (@Foxweather)

**Recommended Approach**:

1. **Get Channel Data** (1 unit):
   ```typescript
   GET /youtube/v3/channels?part=snippet,statistics,contentDetails&forHandle=Foxweather
   ```

2. **Get All 11k+ Videos** (220 units):
   ```typescript
   GET /youtube/v3/playlistItems?part=snippet,contentDetails&playlistId=UUiYFH0VJ9gl0ljnAxAiJeA&maxResults=50
   // Repeat with pageToken for all 220 pages
   ```

3. **Get Detailed Video Stats** (batches of 50 = ~220 units):
   ```typescript
   GET /youtube/v3/videos?part=statistics,contentDetails&id={50_video_ids}
   // Repeat for all video IDs
   ```

**Total Quota Cost**: ~441 units (4.4% of daily quota)
**Time to Complete**: ~30-45 minutes with rate limiting
**Result**: Complete Fox Weather video catalog with metadata

### Key Takeaways

✅ **Use `playlistItems.list`** instead of `search.list` (99% quota savings)
✅ **Batch operations** where possible (50 items per request)
✅ **Implement caching** to avoid redundant API calls
✅ **Monitor quota usage** to prevent exceeding limits
✅ **Handle errors gracefully** with retries and exponential backoff
✅ **Use incremental updates** for regular data synchronization

### Resources

- [Official YouTube Data API Documentation](https://developers.google.com/youtube/v3)
- [Quota Calculator](https://developers.google.com/youtube/v3/determine_quota_cost)
- [API Explorer](https://developers.google.com/youtube/v3/docs)
- [OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)

---

**Generated**: 2025-01-26
**API Version**: YouTube Data API v3
**Target Channel**: @Foxweather (11k+ videos, 554M views)
