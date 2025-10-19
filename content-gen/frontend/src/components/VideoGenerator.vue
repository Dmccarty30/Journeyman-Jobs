<template>
  <div class="video-generator">
    <h1>AI Video Generation</h1>
    <p class="subtitle">Create videos with Sora AI</p>

    <!-- Error Display -->
    <div v-if="error" class="error-message">
      {{ error }}
      <button @click="error = null" class="close-btn">×</button>
    </div>

    <!-- Video Creator Form -->
    <div class="creator-section">
      <h2>Create New Video</h2>

      <div class="form-group">
        <label for="prompt">Prompt *</label>
        <textarea
          id="prompt"
          v-model="form.prompt"
          placeholder="Describe your video... (e.g., A calico cat playing piano on stage under spotlight)"
          rows="4"
          :disabled="isGenerating"
        ></textarea>
        <small>{{ form.prompt.length }} / 2000 characters</small>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="model">Model</label>
          <select id="model" v-model="form.model" :disabled="isGenerating">
            <option value="sora-2">Sora 2 (Fast)</option>
            <option value="sora-2-pro">Sora 2 Pro (High Quality)</option>
          </select>
        </div>

        <div class="form-group">
          <label for="duration">Duration</label>
          <select id="duration" v-model="form.seconds" :disabled="isGenerating">
            <option :value="4">4 seconds</option>
            <option :value="8">8 seconds</option>
            <option :value="12">12 seconds</option>
          </select>
        </div>

        <div class="form-group">
          <label for="size">Resolution</label>
          <select id="size" v-model="form.size" :disabled="isGenerating">
            <option value="1280x720">HD 720p (Landscape)</option>
            <option value="720x1280">HD 720p (Portrait)</option>
            <option value="1024x1024">Square (Social)</option>
            <option value="1920x1080">Full HD 1080p</option>
          </select>
        </div>
      </div>

      <button
        @click="handleCreateVideo"
        class="btn-primary"
        :disabled="!form.prompt.trim() || isGenerating"
      >
        {{ isGenerating ? 'Generating...' : 'Generate Video' }}
      </button>
    </div>

    <!-- Progress Section -->
    <div v-if="currentVideo && isGenerating" class="progress-section">
      <h2>Generating Video</h2>
      <div class="video-card">
        <p><strong>Status:</strong> {{ currentVideo.status }}</p>
        <p><strong>Progress:</strong> {{ currentVideo.progress || 0 }}%</p>

        <div class="progress-bar">
          <div
            class="progress-fill"
            :style="{ width: `${currentVideo.progress || 0}%` }"
          ></div>
        </div>

        <p class="video-id">Video ID: {{ currentVideo.id }}</p>
      </div>
    </div>

    <!-- Video Library -->
    <div class="library-section">
      <h2>Your Videos</h2>

      <div class="library-controls">
        <button @click="refreshLibrary" class="btn-secondary" :disabled="loadingLibrary">
          {{ loadingLibrary ? 'Loading...' : 'Refresh' }}
        </button>
      </div>

      <div v-if="loadingLibrary" class="loading">Loading videos...</div>

      <div v-else-if="videos.length === 0" class="empty-state">
        No videos yet. Create one above to get started!
      </div>

      <div v-else class="video-grid">
        <div v-for="video in videos" :key="video.id" class="video-card">
          <div class="video-header">
            <span class="status-badge" :class="`status-${video.status}`">
              {{ video.status }}
            </span>
            <span class="video-model">{{ video.model }}</span>
          </div>

          <div class="video-info">
            <p class="video-id-small">{{ video.id }}</p>
            <p class="video-meta">{{ video.size }} • {{ video.seconds }}s</p>
            <p class="video-date">{{ formatDate(video.created_at) }}</p>
          </div>

          <!-- Video Player (if completed) -->
          <div v-if="video.status === 'completed'" class="video-player">
            <video
              :src="getVideoUrl(video.id, 'video')"
              controls
              preload="metadata"
              class="video-element"
            ></video>
          </div>

          <!-- Progress bar (if in progress) -->
          <div v-else-if="video.status === 'in_progress'" class="mini-progress">
            <div class="progress-bar">
              <div
                class="progress-fill"
                :style="{ width: `${video.progress || 0}%` }"
              ></div>
            </div>
            <small>{{ video.progress || 0 }}% complete</small>
          </div>

          <!-- Error message (if failed) -->
          <div v-else-if="video.status === 'failed'" class="error-info">
            <p>{{ video.error?.message || 'Generation failed' }}</p>
          </div>

          <!-- Actions -->
          <div class="video-actions">
            <button
              v-if="video.status === 'completed'"
              @click="handleDownload(video.id)"
              class="btn-action"
              title="Download"
            >
              ⬇ Download
            </button>
            <button
              @click="handleDelete(video.id)"
              class="btn-action btn-danger"
              title="Delete"
            >
              🗑 Delete
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="hasMore" class="pagination">
        <button @click="loadMore" class="btn-secondary" :disabled="loadingLibrary">
          Load More
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useVideoGeneration } from '../composables/useVideoGeneration'
import type { VideoJob, CreateVideoParams } from '../types/video'

const {
  createVideo,
  getVideoStatus,
  downloadVideo,
  listVideos,
  deleteVideo,
  getVideoUrl,
  error: apiError
} = useVideoGeneration()

// State
const form = ref<CreateVideoParams>({
  prompt: '',
  model: 'sora-2',
  seconds: 4,
  size: '1280x720'
})

const currentVideo = ref<VideoJob | null>(null)
const isGenerating = ref(false)
const videos = ref<VideoJob[]>([])
const hasMore = ref(false)
const loadingLibrary = ref(false)
const error = ref<string | null>(null)

// Create video
const handleCreateVideo = async () => {
  if (!form.value.prompt.trim()) return

  try {
    isGenerating.value = true
    error.value = null

    currentVideo.value = await createVideo(form.value)

    // Start polling for progress
    pollVideoProgress(currentVideo.value.id)

    // Add to library
    videos.value.unshift(currentVideo.value)
  } catch (err: any) {
    error.value = apiError.value || 'Failed to create video'
  }
}

// Poll video progress
const pollVideoProgress = async (videoId: string) => {
  const pollInterval = 2000 // 2 seconds
  const maxDuration = 600000 // 10 minutes

  const startTime = Date.now()

  const poll = async () => {
    try {
      const video = await getVideoStatus(videoId)
      currentVideo.value = video

      // Update in library
      const index = videos.value.findIndex(v => v.id === videoId)
      if (index !== -1) {
        videos.value[index] = video
      }

      if (video.status === 'completed' || video.status === 'failed') {
        isGenerating.value = false

        if (video.status === 'completed') {
          // Success!
          form.value.prompt = '' // Reset form
        } else {
          error.value = video.error?.message || 'Video generation failed'
        }
        return
      }

      // Check timeout
      if (Date.now() - startTime > maxDuration) {
        isGenerating.value = false
        error.value = 'Video generation timed out'
        return
      }

      // Continue polling
      setTimeout(poll, pollInterval)
    } catch (err: any) {
      error.value = 'Failed to check video status'
      isGenerating.value = false
    }
  }

  poll()
}

// Download video
const handleDownload = async (videoId: string) => {
  try {
    const blob = await downloadVideo(videoId, 'video')
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${videoId}.mp4`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
  } catch (err: any) {
    error.value = 'Failed to download video'
  }
}

// Delete video
const handleDelete = async (videoId: string) => {
  if (!confirm('Are you sure you want to delete this video?')) return

  try {
    await deleteVideo(videoId)
    videos.value = videos.value.filter(v => v.id !== videoId)
  } catch (err: any) {
    error.value = 'Failed to delete video'
  }
}

// Refresh library
const refreshLibrary = async () => {
  loadingLibrary.value = true
  try {
    const response = await listVideos(20, undefined, 'desc')
    videos.value = response.data
    hasMore.value = response.has_more
  } catch (err: any) {
    error.value = 'Failed to load videos'
  } finally {
    loadingLibrary.value = false
  }
}

// Load more videos
const loadMore = async () => {
  if (!videos.value.length) return

  loadingLibrary.value = true
  try {
    const lastVideo = videos.value[videos.value.length - 1]
    const response = await listVideos(20, lastVideo.id, 'desc')
    videos.value.push(...response.data)
    hasMore.value = response.has_more
  } catch (err: any) {
    error.value = 'Failed to load more videos'
  } finally {
    loadingLibrary.value = false
  }
}

// Format date
const formatDate = (timestamp: number): string => {
  return new Date(timestamp * 1000).toLocaleString()
}

// Load videos on mount
onMounted(() => {
  refreshLibrary()
})
</script>

<style scoped>
.video-generator {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.subtitle {
  color: #666;
  margin-bottom: 2rem;
}

h2 {
  font-size: 1.5rem;
  margin-bottom: 1rem;
  color: #2c3e50;
}

/* Error Message */
.error-message {
  background: #fee;
  border: 1px solid #fcc;
  color: #c33;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #c33;
}

/* Creator Section */
.creator-section {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 12px;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.form-group textarea,
.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  font-family: inherit;
}

.form-group textarea {
  resize: vertical;
}

.form-group small {
  color: #666;
  font-size: 0.875rem;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

/* Buttons */
.btn-primary,
.btn-secondary,
.btn-action {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background: #3498db;
  color: white;
  width: 100%;
  margin-top: 1rem;
}

.btn-primary:hover:not(:disabled) {
  background: #2980b9;
}

.btn-primary:disabled {
  background: #95a5a6;
  cursor: not-allowed;
}

.btn-secondary {
  background: #ecf0f1;
  color: #2c3e50;
}

.btn-secondary:hover:not(:disabled) {
  background: #d5d8dc;
}

.btn-action {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
  background: #3498db;
  color: white;
}

.btn-action:hover {
  background: #2980b9;
}

.btn-danger {
  background: #e74c3c;
}

.btn-danger:hover {
  background: #c0392b;
}

/* Progress Section */
.progress-section {
  background: #e8f5e9;
  padding: 2rem;
  border-radius: 12px;
  margin-bottom: 2rem;
}

.progress-bar {
  width: 100%;
  height: 24px;
  background: #ecf0f1;
  border-radius: 12px;
  overflow: hidden;
  margin: 1rem 0;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #3498db, #2ecc71);
  transition: width 0.3s ease;
}

/* Library Section */
.library-section {
  margin-top: 3rem;
}

.library-controls {
  margin-bottom: 1rem;
}

.loading,
.empty-state {
  text-align: center;
  padding: 3rem;
  color: #666;
  font-size: 1.1rem;
}

.video-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
  margin-top: 1rem;
}

.video-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.video-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.video-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-queued {
  background: #fff3cd;
  color: #856404;
}

.status-in_progress {
  background: #cfe2ff;
  color: #084298;
}

.status-completed {
  background: #d1e7dd;
  color: #0f5132;
}

.status-failed {
  background: #f8d7da;
  color: #842029;
}

.video-model {
  font-size: 0.875rem;
  color: #666;
}

.video-info p {
  margin: 0.25rem 0;
  font-size: 0.875rem;
  color: #666;
}

.video-id-small {
  font-family: monospace;
  font-size: 0.75rem;
  color: #999;
}

.video-meta {
  font-weight: 600;
  color: #2c3e50;
}

.video-player {
  margin: 1rem 0;
}

.video-element {
  width: 100%;
  border-radius: 8px;
  background: #000;
}

.mini-progress {
  margin: 1rem 0;
}

.error-info {
  color: #c33;
  font-size: 0.875rem;
  margin: 1rem 0;
}

.video-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
}

.pagination {
  text-align: center;
  margin-top: 2rem;
}
</style>
