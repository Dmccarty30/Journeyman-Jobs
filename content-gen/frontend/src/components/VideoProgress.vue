<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useVideoGeneration } from '../composables/useVideoGeneration'
import type { VideoJob } from '../types/video'

const props = withDefaults(
  defineProps<{
    videoId: string
    autoRefresh?: boolean
  }>(),
  {
    autoRefresh: true
  }
)

const emit = defineEmits<{
  completed: [video: VideoJob]
  failed: [video: VideoJob]
}>()

const { getVideoStatus, error } = useVideoGeneration()

const video = ref<VideoJob | null>(null)
const refreshInterval = ref<number | null>(null)

const statusLabel = computed(() => {
  if (!video.value) return 'Loading...'

  switch (video.value.status) {
    case 'queued':
      return 'Queued'
    case 'in_progress':
      return 'Generating'
    case 'completed':
      return 'Completed'
    case 'failed':
      return 'Failed'
    default:
      return video.value.status
  }
})

const statusColor = computed(() => {
  if (!video.value) return '#666'

  switch (video.value.status) {
    case 'queued':
      return '#999'
    case 'in_progress':
      return '#0066cc'
    case 'completed':
      return '#00aa00'
    case 'failed':
      return '#cc0000'
    default:
      return '#666'
  }
})

const estimatedTimeRemaining = computed(() => {
  if (!video.value || video.value.status !== 'in_progress') return null

  const progress = video.value.progress
  if (progress <= 0) return null

  // Rough estimate based on progress
  const secondsElapsed = (Date.now() / 1000) - video.value.created_at
  const totalEstimated = secondsElapsed / (progress / 100)
  const remaining = totalEstimated - secondsElapsed

  if (remaining < 60) {
    return `~${Math.round(remaining)}s remaining`
  } else {
    return `~${Math.round(remaining / 60)}m remaining`
  }
})

const refresh = async () => {
  try {
    const updatedVideo = await getVideoStatus(props.videoId)
    video.value = updatedVideo

    // Emit events based on status
    if (updatedVideo.status === 'completed') {
      emit('completed', updatedVideo)
      stopRefresh()
    } else if (updatedVideo.status === 'failed') {
      emit('failed', updatedVideo)
      stopRefresh()
    }
  } catch (err) {
    console.error('Failed to refresh video status:', err)
  }
}

const startRefresh = () => {
  if (!props.autoRefresh) return

  refresh() // Initial fetch

  refreshInterval.value = window.setInterval(() => {
    refresh()
  }, 2000) // Poll every 2 seconds
}

const stopRefresh = () => {
  if (refreshInterval.value !== null) {
    clearInterval(refreshInterval.value)
    refreshInterval.value = null
  }
}

onMounted(() => {
  startRefresh()
})

onUnmounted(() => {
  stopRefresh()
})
</script>

<template>
  <div class="video-progress">
    <div v-if="video" class="progress-container">
      <div class="progress-header">
        <h3>{{ statusLabel }}</h3>
        <span class="video-id">ID: {{ videoId }}</span>
      </div>

      <!-- Progress Bar -->
      <div v-if="video.status === 'queued' || video.status === 'in_progress'" class="progress-bar-container">
        <div class="progress-bar">
          <div
            class="progress-fill"
            :style="{ width: `${video.progress}%`, backgroundColor: statusColor }"
          ></div>
        </div>
        <div class="progress-info">
          <span class="progress-percentage">{{ video.progress }}%</span>
          <span v-if="estimatedTimeRemaining" class="time-remaining">
            {{ estimatedTimeRemaining }}
          </span>
        </div>
      </div>

      <!-- Completion Message -->
      <div v-if="video.status === 'completed'" class="status-message success">
        Video generated successfully! Ready for viewing.
      </div>

      <!-- Error Message -->
      <div v-if="video.status === 'failed'" class="status-message error">
        <strong>Generation Failed</strong>
        <p v-if="video.error">{{ video.error.message }}</p>
        <p v-else>An unknown error occurred during video generation.</p>
      </div>

      <!-- Video Details -->
      <div class="video-details">
        <div class="detail-item">
          <span class="label">Model:</span>
          <span class="value">{{ video.model }}</span>
        </div>
        <div class="detail-item">
          <span class="label">Duration:</span>
          <span class="value">{{ video.seconds }}s</span>
        </div>
        <div class="detail-item">
          <span class="label">Resolution:</span>
          <span class="value">{{ video.size }}</span>
        </div>
      </div>
    </div>

    <!-- Error state -->
    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Loading state -->
    <div v-if="!video && !error" class="loading">
      Loading video status...
    </div>
  </div>
</template>

<style scoped>
.video-progress {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

.progress-container {
  color: black;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.progress-header h3 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: bold;
}

.video-id {
  font-size: 0.9rem;
  color: #666;
  font-family: monospace;
}

.progress-bar-container {
  margin-bottom: 1.5rem;
}

.progress-bar {
  width: 100%;
  height: 30px;
  background: #f0f0f0;
  border: 1px solid #ccc;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  transition: width 0.3s ease, background-color 0.3s ease;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-top: 0.5rem;
  font-size: 0.9rem;
  color: #666;
}

.progress-percentage {
  font-weight: 600;
  color: black;
}

.time-remaining {
  font-style: italic;
}

.status-message {
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1.5rem;
}

.status-message.success {
  background: #e8f5e9;
  border: 1px solid #4caf50;
  color: #2e7d32;
}

.status-message.error {
  background: #fee;
  border: 1px solid #fcc;
  color: #c00;
}

.status-message strong {
  display: block;
  margin-bottom: 0.5rem;
}

.status-message p {
  margin: 0;
}

.video-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  padding: 1rem;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

.detail-item {
  display: flex;
  flex-direction: column;
}

.detail-item .label {
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 0.25rem;
}

.detail-item .value {
  font-weight: 600;
  color: black;
}

.error-message {
  padding: 1rem;
  background: #fee;
  border: 1px solid #fcc;
  border-radius: 4px;
  color: #c00;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: #666;
  font-style: italic;
}
</style>
