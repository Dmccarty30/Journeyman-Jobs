# Sora Video Generation Integration Specification

**Version:** 1.0
**Date:** 2025-10-09
**Status:** Planning

---

## Overview

This specification outlines the integration of OpenAI's Sora API for video generation capabilities into the Content Generation Application. The integration will provide a full-featured backend API and frontend UI for creating, managing, and downloading AI-generated videos using both `sora-2` and `sora-2-pro` models.

---

## Important Additional Notes

- Be sure to setup logging structures for the backend and output to specific hour based log files. This way you can validate, monitor, and debug any issues that arise with the Sora API integration. If issues occur you can lean on your output logs to help identify and resolve them. Use typical python logging libraries and best practices.

## Architecture

### Technology Stack

**Backend:**
- FastAPI (existing)
- OpenAI Python SDK (new dependency)
- Async/await for non-blocking operations
- Background tasks for polling video status

**Frontend:**
- Vue 3 + TypeScript (existing)
- Axios for API communication
- Composables for video state management
- Real-time progress tracking UI

**Storage:**
- Local filesystem for downloaded videos
- SQLite/JSON for video metadata tracking (optional enhancement)

---

## API Endpoints

### Backend REST API

All endpoints will be prefixed with `/api/v1/videos`

#### 1. Create Video
**POST** `/api/v1/videos`

Create a new video generation job from a text prompt.

**Request Body:**
```json
{
  "prompt": "string (required)",
  "model": "sora-2 | sora-2-pro (optional, default: sora-2)",
  "seconds": "4 | 8 | 12 (optional, default: 4)",
  "size": "string (optional, default: 1280x720)",
  "input_reference": "file (optional)"
}
```

**Response:**
```json
{
  "id": "video_abc123",
  "object": "video",
  "status": "queued",
  "model": "sora-2",
  "progress": 0,
  "created_at": 1758941485,
  "size": "1280x720",
  "seconds": "4"
}
```

**Notes:**
- Accepts multipart/form-data for image reference uploads
- Validates content against Sora guardrails
- Returns job immediately (async processing)

---

#### 2. Get Video Status
**GET** `/api/v1/videos/{video_id}`

Retrieve current status and progress of a video generation job.

**Path Parameters:**
- `video_id` (string, required)

**Response:**
```json
{
  "id": "video_abc123",
  "object": "video",
  "status": "in_progress | queued | completed | failed",
  "model": "sora-2",
  "progress": 45,
  "created_at": 1758941485,
  "completed_at": 1758941600,
  "size": "1280x720",
  "seconds": "4",
  "error": {
    "message": "string",
    "type": "string"
  }
}
```

**Statuses:**
- `queued` - Job waiting in queue
- `in_progress` - Currently generating (includes progress %)
- `completed` - Ready for download
- `failed` - Generation failed (see error object)

---

#### 3. Download Video Content
**GET** `/api/v1/videos/{video_id}/content`

Download the generated video file or supporting assets.

**Path Parameters:**
- `video_id` (string, required)

**Query Parameters:**
- `variant` (string, optional): `video` (default), `thumbnail`, `spritesheet`

**Response:**
- Content-Type: `video/mp4` (for video), `image/webp` (thumbnail), `image/jpeg` (spritesheet)
- Binary stream of requested asset

**Notes:**
- Only works when status is `completed`
- Download URLs valid for 24 hours
- Supports streaming for large files

---

#### 4. List Videos
**GET** `/api/v1/videos`

List all video generation jobs with pagination.

**Query Parameters:**
- `limit` (integer, optional, default: 20, max: 100)
- `after` (string, optional) - Pagination cursor
- `order` (string, optional) - `asc` or `desc` (default: `desc`)
- `status` (string, optional) - Filter by status

**Response:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "video_abc123",
      "object": "video",
      "status": "completed",
      "model": "sora-2",
      "created_at": 1758941485,
      "size": "1280x720",
      "seconds": "4"
    }
  ],
  "has_more": true
}
```

---

#### 5. Delete Video
**DELETE** `/api/v1/videos/{video_id}`

Remove a video from OpenAI storage.

**Path Parameters:**
- `video_id` (string, required)

**Response:**
```json
{
  "id": "video_abc123",
  "object": "video",
  "deleted": true
}
```

---

#### 6. Remix Video
**POST** `/api/v1/videos/{video_id}/remix`

Create a variation of an existing video with targeted modifications.

**Path Parameters:**
- `video_id` (string, required) - Must be a completed video

**Request Body:**
```json
{
  "prompt": "string (required)"
}
```

**Response:**
```json
{
  "id": "video_def456",
  "object": "video",
  "status": "queued",
  "model": "sora-2",
  "progress": 0,
  "remixed_from_video_id": "video_abc123",
  "created_at": 1758941700,
  "size": "1280x720",
  "seconds": "4"
}
```

---

#### 7. Poll Video Until Complete
**GET** `/api/v1/videos/{video_id}/poll`

Convenience endpoint that polls until completion or failure.

**Path Parameters:**
- `video_id` (string, required)

**Query Parameters:**
- `timeout` (integer, optional, default: 300) - Max seconds to wait

**Response:**
Same as "Get Video Status" but only returns when status is `completed` or `failed`, or timeout is reached.

---

## Backend Implementation Details

### Project Structure

```
backend/
└── src/
    └── content_gen_backend/
        ├── __init__.py
        ├── __main__.py
        ├── main.py                 # FastAPI app
        ├── config.py               # Configuration & settings
        ├── routers/
        │   └── videos.py          # Video endpoints
        ├── services/
        │   ├── sora_service.py    # OpenAI Sora API wrapper
        │   └── storage_service.py # Local file storage
        ├── models/
        │   ├── video_request.py   # Pydantic models
        │   └── video_response.py
        └── utils/
            ├── validators.py       # Content validation
            └── polling.py          # Async polling helpers
```

### Key Components

#### 1. Configuration (`config.py`)
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    openai_api_key: str
    video_storage_path: str = "./videos"
    max_poll_timeout: int = 600
    default_model: str = "sora-2"

    class Config:
        env_file = ".env"
```

#### 2. Sora Service (`services/sora_service.py`)
Wraps OpenAI SDK with:
- Async video creation
- Status polling with exponential backoff
- Download management
- Error handling and retries
- Content validation

#### 3. Storage Service (`services/storage_service.py`)
Handles:
- Saving downloaded videos locally
- Metadata tracking
- Cleanup of expired downloads
- File serving for frontend

#### 4. Video Router (`routers/videos.py`)
Implements all API endpoints with:
- Request validation
- Error handling
- Response serialization
- Background tasks for async operations

---

## Sensible Defaults

### Model Selection
- **Default:** `sora-2`
- **Use Case:** Fast iteration, prototyping, social media content
- **When to use Pro:** User explicitly requests high quality, or use case is production/marketing

### Resolution (`size`)
- **Default:** `1280x720` (HD 720p landscape)
- **Rationale:** Good balance of quality and generation time
- **Alternatives:**
  - `720x1280` - Portrait (mobile)
  - `1024x1024` - Square (social media)
  - `1920x1080` - Full HD (premium)

### Duration (`seconds`)
- **Default:** `4` seconds
- **Rationale:** Quick generation, sufficient for most clips
- **Options:** 4, 8, 12 seconds
- **Guidance:** Start short, extend if needed

### Polling Strategy
- **Initial interval:** 2 seconds
- **Max interval:** 10 seconds
- **Backoff:** Exponential (2s → 4s → 8s → 10s)
- **Timeout:** 300 seconds (5 minutes) default, 600 max

### Quality
- **Default:** `standard`
- **Note:** Currently only standard is available in API

### Content Guidelines
Provide user-facing warnings for:
- No copyrighted characters/music
- No real people/public figures
- No faces in reference images
- Content must be appropriate for under-18 audiences

---

## Frontend Implementation

### Components

#### 1. VideoCreator Component
**Location:** `frontend/src/components/VideoCreator.vue`

**Features:**
- Prompt input textarea with character count
- Model selector (sora-2 / sora-2-pro)
- Duration selector (4s / 8s / 12s)
- Resolution preset dropdown
- Optional image reference upload with preview
- Submit button with loading state

**State:**
```typescript
interface VideoCreatorState {
  prompt: string
  model: 'sora-2' | 'sora-2-pro'
  seconds: 4 | 8 | 12
  size: string
  inputReference?: File
  isSubmitting: boolean
}
```

---

#### 2. VideoProgress Component
**Location:** `frontend/src/components/VideoProgress.vue`

**Features:**
- Real-time progress bar with percentage
- Current status display (queued/processing/completed)
- Estimated time remaining
- Cancel option (if supported)
- Auto-refresh every 2 seconds

**Props:**
```typescript
interface VideoProgressProps {
  videoId: string
  autoRefresh?: boolean
}
```

---

#### 3. VideoLibrary Component
**Location:** `frontend/src/components/VideoLibrary.vue`

**Features:**
- Grid/list view of generated videos
- Thumbnail previews
- Filter by status (all/completed/in_progress/failed)
- Sort by date (newest/oldest)
- Pagination controls
- Actions: View, Download, Remix, Delete

**State:**
```typescript
interface VideoLibraryState {
  videos: VideoJob[]
  filter: 'all' | 'completed' | 'in_progress' | 'failed'
  sort: 'desc' | 'asc'
  currentPage: number
  hasMore: boolean
}
```

---

#### 4. VideoPlayer Component
**Location:** `frontend/src/components/VideoPlayer.vue`

**Features:**
- Native HTML5 video player
- Download button
- Remix button
- Metadata display (model, resolution, duration)
- Share options (future)

---

### Composables

#### 1. `useVideoGeneration`
**Location:** `frontend/src/composables/useVideoGeneration.ts`

**Purpose:** State management and API interactions for video generation

```typescript
export function useVideoGeneration() {
  const createVideo = async (params: CreateVideoParams) => {}
  const getVideoStatus = async (videoId: string) => {}
  const pollVideo = async (videoId: string) => {}
  const downloadVideo = async (videoId: string, variant?: string) => {}
  const deleteVideo = async (videoId: string) => {}
  const remixVideo = async (videoId: string, prompt: string) => {}

  return {
    createVideo,
    getVideoStatus,
    pollVideo,
    downloadVideo,
    deleteVideo,
    remixVideo
  }
}
```

#### 2. `useVideoLibrary`
**Location:** `frontend/src/composables/useVideoLibrary.ts`

**Purpose:** Manage video list state and operations

```typescript
export function useVideoLibrary() {
  const videos = ref<VideoJob[]>([])
  const loading = ref(false)

  const fetchVideos = async (options?: FetchOptions) => {}
  const refreshVideo = async (videoId: string) => {}

  return {
    videos,
    loading,
    fetchVideos,
    refreshVideo
  }
}
```

---

### User Experience Flow

1. **Create Video:**
   - User enters prompt in VideoCreator
   - Selects model, duration, resolution (or uses defaults)
   - Optionally uploads reference image
   - Clicks "Generate Video"
   - VideoProgress component appears with job ID

2. **Monitor Progress:**
   - Progress bar updates every 2 seconds
   - Status changes from queued → in_progress → completed
   - User sees estimated time and percentage

3. **View/Download:**
   - On completion, user redirected to VideoPlayer
   - Can play inline, download MP4, or access thumbnail/spritesheet
   - Can initiate remix with modification prompt

4. **Library Management:**
   - VideoLibrary shows all jobs
   - Can filter by status, sort by date
   - Quick actions on each video card
   - Cleanup failed/old jobs with delete

---

## Error Handling

### Backend Errors

**OpenAI API Errors:**
- `401 Unauthorized` → Invalid API key (config error)
- `400 Bad Request` → Content policy violation (show user-friendly message)
- `429 Rate Limit` → Too many requests (implement retry with backoff)
- `500 Server Error` → OpenAI service issue (retry with exponential backoff)

**Application Errors:**
- Invalid video ID → 404 Not Found
- Video not completed → 409 Conflict ("Video still processing")
- File too large → 413 Payload Too Large
- Timeout → 504 Gateway Timeout

### Frontend Errors

**User-Facing Messages:**
- Content policy: "Your prompt contains restricted content. Please avoid copyrighted characters, real people, or inappropriate content."
- Rate limit: "Too many requests. Please wait a moment and try again."
- Generation failed: "Video generation failed. Please try again with a different prompt."
- Network error: "Connection lost. Retrying..."

**Retry Strategy:**
- Auto-retry transient errors (network, 5xx) up to 3 times
- Exponential backoff between retries
- User notification after final failure
- Option to manually retry

---

## Prompting Best Practices

### Built-in Prompt Templates

Provide users with starter templates:

1. **Cinematic Scene:**
   ```
   Wide shot of [subject] in [setting], [lighting], [camera movement]
   ```

2. **Product Showcase:**
   ```
   Close-up of [product] on [surface], [lighting], soft focus background
   ```

3. **Text Animation:**
   ```
   A video of the words '[text]' in [style] letters, [animation]
   ```

4. **Nature Scene:**
   ```
   [Shot type] of [natural subject] in [environment], [weather/time of day]
   ```

### Prompt Enhancement

**Auto-suggestions shown in UI:**
- Add shot type: wide, close-up, medium, aerial
- Specify lighting: golden hour, dramatic, soft, natural
- Include camera movement: static, panning, tracking, dolly
- Detail environment: specific location, atmosphere, time of day

---

## Webhook Support (Future Enhancement)

**When to implement:** After MVP launch

**Benefits:**
- Eliminates polling overhead
- Instant notifications on completion
- Reduced API calls

**Implementation:**
- Webhook endpoint: `POST /api/v1/webhooks/sora`
- Verify signatures from OpenAI
- Update internal job status
- Notify frontend via WebSocket

---

## Performance Optimization

### Caching Strategy
- Cache video metadata in memory (Redis future)
- Cache thumbnails for quick preview loading
- Implement CDN for video delivery (future)

### Rate Limiting
- Client-side: Prevent duplicate submissions
- Server-side: Rate limit per user/IP
- Queue system for high load (future)

### Progressive Enhancement
- Show thumbnail immediately when available
- Load spritesheet for scrubbing
- Stream video content (avoid full download wait)

---

## Security Considerations

### API Key Management
- Store in `.env` file (never commit)
- Rotate keys periodically
- Use environment-specific keys (dev/prod)

### Content Validation
- Validate file uploads (type, size)
- Sanitize user prompts (XSS prevention)
- Enforce Sora content policies on backend

### Access Control (Future)
- User authentication
- Per-user rate limits
- Video ownership/privacy settings

---

## Testing Strategy

### Backend Tests
1. **Unit Tests:**
   - Sora service methods
   - Request/response validation
   - Error handling

2. **Integration Tests:**
   - Full API endpoint flows
   - OpenAI SDK integration (with mocks)
   - File upload/download

3. **E2E Tests:**
   - Create → Poll → Download flow
   - Remix workflow
   - Error scenarios

### Frontend Tests
1. **Component Tests:**
   - VideoCreator form validation
   - VideoProgress updates
   - VideoLibrary filtering/sorting

2. **Composable Tests:**
   - useVideoGeneration state management
   - API call mocking

3. **E2E Tests:**
   - Full user journey with Playwright/Cypress

---

## Deployment Checklist

- [ ] Add `openai` to backend dependencies
- [ ] Configure OPENAI_API_KEY in environment
- [ ] Create video storage directory with proper permissions
- [ ] Set up CORS for frontend-backend communication
- [ ] Configure file upload size limits
- [ ] Implement logging for video operations
- [ ] Set up monitoring for API usage/costs
- [ ] Document user-facing API rate limits

---

## Cost Estimation

**Sora Pricing (as of Jan 2025):**
- Models have different costs per second
- Factor in resolution impact on pricing
- Budget monitoring recommendations

**Usage Tracking:**
- Log all generation requests
- Track total seconds generated
- Implement usage alerts/caps

---

## Future Enhancements

### Phase 2 (Post-MVP)
- [ ] Webhook support for completion notifications
- [ ] Storyboard: Multi-video sequence generation
- [ ] Video editing: Trim, merge, add overlays
- [ ] Batch operations: Generate multiple videos
- [ ] Templates library: Pre-made prompt templates
- [ ] User accounts with video history
- [ ] Cost tracking dashboard

### Phase 3 (Advanced)
- [ ] Real-time collaboration on prompts
- [ ] AI-powered prompt suggestions
- [ ] Video analytics (views, downloads)
- [ ] Social sharing integrations
- [ ] Custom branding/watermarks
- [ ] API access for external applications

---

## Documentation Requirements

### Developer Documentation
- API reference with examples
- Setup guide for local development
- Architecture diagrams
- Contribution guidelines

### User Documentation
- Getting started guide
- Prompt writing best practices
- Troubleshooting common issues
- Example gallery with prompts

---

## Success Metrics

**Technical Metrics:**
- Average video generation time
- Success rate (completed vs failed)
- API response times
- Error rates by type

**User Metrics:**
- Number of videos generated
- Remix usage rate
- Average prompt length
- Model preference (sora-2 vs pro)

**Business Metrics:**
- Cost per video
- API credit utilization
- User retention
- Feature adoption

---

## Acceptance Criteria

### MVP Must-Have Features
- ✅ Create video from text prompt
- ✅ Monitor generation progress in real-time
- ✅ Download completed videos
- ✅ List all generated videos
- ✅ Delete videos
- ✅ Basic error handling
- ✅ Sensible defaults applied
- ✅ Responsive UI

### MVP Nice-to-Have Features
- ✅ Image reference support
- ✅ Remix functionality
- ✅ Thumbnail/spritesheet download
- ✅ Progress percentage display
- ✅ Prompt templates
- ⏳ Webhook support (Phase 2)

---

## Timeline Estimate

**Backend Development:** 2-3 days
- Day 1: Setup, models, Sora service
- Day 2: API endpoints, error handling
- Day 3: Testing, refinement

**Frontend Development:** 2-3 days
- Day 1: Components (Creator, Progress)
- Day 2: Components (Library, Player)
- Day 3: Integration, styling, testing

**Integration & Testing:** 1-2 days
- E2E testing
- Bug fixes
- Documentation

**Total:** 5-8 days for MVP

---

## Dependencies

### Backend
```toml
[project.dependencies]
fastapi = ">=0.118.2"
uvicorn = { version = ">=0.37.0", extras = ["standard"] }
openai = ">=1.54.0"  # NEW
pydantic = ">=2.0.0"  # NEW
pydantic-settings = ">=2.0.0"  # NEW
python-multipart = ">=0.0.6"  # NEW (file uploads)
aiofiles = ">=23.0.0"  # NEW (async file operations)
```

### Frontend
```json
{
  "dependencies": {
    "vue": "^3.5.13",
    "axios": "^1.7.2",  // NEW for API calls
    "vue-router": "^4.5.0"  // NEW if routing needed
  }
}
```

---

## Configuration Example

### Backend `.env`
```bash
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
VIDEO_STORAGE_PATH=./videos
MAX_POLL_TIMEOUT=600
DEFAULT_MODEL=sora-2
DEFAULT_SIZE=1280x720
DEFAULT_SECONDS=4
MAX_FILE_SIZE=10485760  # 10MB for reference images
```

### Frontend `.env`
```bash
VITE_API_BASE_URL=http://localhost:4444/api/v1
VITE_VIDEO_POLL_INTERVAL=2000
```

---

## API Usage Examples

### Create Video (cURL)
```bash
curl -X POST "http://localhost:4444/api/v1/videos" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "A calico cat playing piano on stage under spotlight",
    "model": "sora-2",
    "seconds": 4,
    "size": "1280x720"
  }'
```

### Poll Until Complete (Python)
```python
import requests
import time

video_id = "video_abc123"
base_url = "http://localhost:4444/api/v1"

while True:
    response = requests.get(f"{base_url}/videos/{video_id}")
    video = response.json()

    if video["status"] in ["completed", "failed"]:
        break

    print(f"Progress: {video['progress']}%")
    time.sleep(2)

if video["status"] == "completed":
    # Download video
    download_url = f"{base_url}/videos/{video_id}/content"
    video_content = requests.get(download_url)
    with open("output.mp4", "wb") as f:
        f.write(video_content.content)
```

### Frontend Usage (TypeScript)
```typescript
import { useVideoGeneration } from '@/composables/useVideoGeneration'

const { createVideo, pollVideo } = useVideoGeneration()

async function generateVideo() {
  const video = await createVideo({
    prompt: 'A serene mountain lake at sunset',
    model: 'sora-2',
    seconds: 4,
    size: '1280x720'
  })

  // Poll until complete
  const completed = await pollVideo(video.id)
  console.log('Video ready:', completed)
}
```

---

## Appendix: Sora API Reference Quick Sheet

| Endpoint               | Method | Purpose               |
| ---------------------- | ------ | --------------------- |
| `/videos`              | POST   | Create video job      |
| `/videos/{id}`         | GET    | Get job status        |
| `/videos/{id}/content` | GET    | Download video/assets |
| `/videos`              | GET    | List all videos       |
| `/videos/{id}`         | DELETE | Delete video          |
| `/videos/{id}/remix`   | POST   | Create remix          |

**Models:**
- `sora-2` - Fast, good quality, cost-effective
- `sora-2-pro` - Slower, high quality, premium

**Resolution Options:**
- `1280x720` (HD landscape)
- `720x1280` (HD portrait)
- `1024x1024` (square)
- `1920x1080` (Full HD)

**Duration Options:** 4s, 8s, 12s

**Variants:**
- `video` - MP4 file
- `thumbnail` - WebP preview
- `spritesheet` - JPEG contact sheet

---

## Contact & Support

**Technical Questions:** Reference this spec document
**OpenAI API Issues:** https://platform.openai.com/docs
**Project Repository:** [Link to repo]

---

**End of Specification**
