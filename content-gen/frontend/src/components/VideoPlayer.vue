<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useVideoGeneration } from '../composables/useVideoGeneration'
import type { VideoJob, VideoVariant } from '../types/video'

const props = defineProps<{
  videoId: string
}>()

const emit = defineEmits<{
  remix: [videoId: string]
  close: []
}>()

const { getVideoStatus, downloadVideo, error } = useVideoGeneration()

const video = ref<VideoJob | null>(null)
const videoUrl = ref<string | null>(null)
const downloading = ref(false)

const isCompleted = computed(() => video.value?.status === 'completed')

const loadVideo = async () => {
  try {
    const videoData = await getVideoStatus(props.videoId)
    video.value = videoData

    if (videoData.status === 'completed') {
      await loadVideoContent()
    }
  } catch (err) {
    console.error('Failed to load video:', err)
  }
}

const loadVideoContent = async () => {
  try {
    const blob = await downloadVideo(props.videoId, 'video')
    videoUrl.value = URL.createObjectURL(blob)
  } catch (err) {
    console.error('Failed to load video content:', err)
  }
}

const handleDownload = async (variant: VideoVariant = 'video') => {
  downloading.value = true

  try {
    const blob = await downloadVideo(props.videoId, variant)

    // Create download link
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url

    // Set filename based on variant
    let extension = 'mp4'
    if (variant === 'thumbnail') extension = 'webp'
    if (variant === 'spritesheet') extension = 'jpg'

    a.download = `${props.videoId}_${variant}.${extension}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (err) {
    console.error('Failed to download:', err)
  } finally {
    downloading.value = false
  }
}

const handleRemix = () => {
  emit('remix', props.videoId)
}

const handleClose = () => {
  emit('close')
}

const formatDate = (timestamp: number) => {
  return new Date(timestamp * 1000).toLocaleString()
}

onMounted(() => {
  loadVideo()
})
</script>

<template>
  <div class="video-player">
    <div class="player-header">
      <h2>Video Player</h2>
      <button class="close-btn" @click="handleClose">Close</button>
    </div>

    <div v-if="video" class="player-content">
      <!-- Video Display -->
      <div v-if="isCompleted && videoUrl" class="video-container">
        <video :src="videoUrl" controls class="video-element">
          Your browser does not support the video tag.
        </video>
      </div>

      <!-- Not Ready Message -->
      <div v-else-if="!isCompleted" class="not-ready">
        <p>Video is not ready for playback.</p>
        <p>Status: <strong>{{ video.status }}</strong></p>
        <p v-if="video.status === 'in_progress'">Progress: {{ video.progress }}%</p>
      </div>

      <!-- Error Loading Video -->
      <div v-else-if="!videoUrl" class="error-loading">
        <p>Failed to load video content.</p>
        <button @click="loadVideoContent" class="retry-btn">Retry</button>
      </div>

      <!-- Video Metadata -->
      <div class="video-metadata">
        <h3>Video Details</h3>
        <div class="metadata-grid">
          <div class="metadata-item">
            <span class="label">Video ID:</span>
            <span class="value">{{ video.id }}</span>
          </div>
          <div class="metadata-item">
            <span class="label">Model:</span>
            <span class="value">{{ video.model }}</span>
          </div>
          <div class="metadata-item">
            <span class="label">Duration:</span>
            <span class="value">{{ video.seconds }} seconds</span>
          </div>
          <div class="metadata-item">
            <span class="label">Resolution:</span>
            <span class="value">{{ video.size }}</span>
          </div>
          <div class="metadata-item">
            <span class="label">Created:</span>
            <span class="value">{{ formatDate(video.created_at) }}</span>
          </div>
          <div v-if="video.completed_at" class="metadata-item">
            <span class="label">Completed:</span>
            <span class="value">{{ formatDate(video.completed_at) }}</span>
          </div>
          <div v-if="video.remixed_from_video_id" class="metadata-item">
            <span class="label">Remixed From:</span>
            <span class="value">{{ video.remixed_from_video_id }}</span>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div v-if="isCompleted" class="player-actions">
        <button class="action-btn primary" @click="handleDownload('video')" :disabled="downloading">
          {{ downloading ? 'Downloading...' : 'Download Video' }}
        </button>
        <button class="action-btn" @click="handleDownload('thumbnail')" :disabled="downloading">
          Download Thumbnail
        </button>
        <button class="action-btn" @click="handleDownload('spritesheet')" :disabled="downloading">
          Download Spritesheet
        </button>
        <button class="action-btn remix-btn" @click="handleRemix">
          Create Remix
        </button>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Loading State -->
    <div v-if="!video && !error" class="loading">
      Loading video...
    </div>
  </div>
</template>

<style scoped>
.video-player {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

.player-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.player-header h2 {
  margin: 0;
  font-size: 1.8rem;
  font-weight: bold;
  color: black;
}

.close-btn {
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  color: black;
  font-weight: 500;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #f5f5f5;
  border-color: #999;
}

.player-content {
  color: black;
}

.video-container {
  margin-bottom: 2rem;
  background: #000;
  border-radius: 4px;
  overflow: hidden;
}

.video-element {
  width: 100%;
  height: auto;
  display: block;
}

.not-ready,
.error-loading {
  padding: 3rem;
  text-align: center;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  margin-bottom: 2rem;
}

.not-ready p,
.error-loading p {
  margin: 0.5rem 0;
  color: #666;
}

.not-ready strong {
  color: black;
}

.retry-btn {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background: black;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.retry-btn:hover {
  background: #333;
}

.video-metadata {
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

.video-metadata h3 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.3rem;
  font-weight: bold;
  color: black;
}

.metadata-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.metadata-item {
  display: flex;
  flex-direction: column;
}

.metadata-item .label {
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 0.25rem;
}

.metadata-item .value {
  font-weight: 600;
  color: black;
  word-break: break-all;
}

.player-actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.action-btn {
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: white;
  color: black;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.2s;
}

.action-btn:hover:not(:disabled) {
  background: #f5f5f5;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.action-btn.primary {
  background: black;
  color: white;
  border-color: black;
}

.action-btn.primary:hover:not(:disabled) {
  background: #333;
}

.action-btn.remix-btn {
  background: #0066cc;
  color: white;
  border-color: #0066cc;
}

.action-btn.remix-btn:hover:not(:disabled) {
  background: #0052a3;
}

.error-message {
  padding: 1rem;
  margin-top: 1rem;
  background: #fee;
  border: 1px solid #fcc;
  border-radius: 4px;
  color: #c00;
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #666;
  font-style: italic;
}
</style>
