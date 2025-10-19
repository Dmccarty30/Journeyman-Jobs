<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useVideoLibrary } from '../composables/useVideoLibrary'
import { useVideoGeneration } from '../composables/useVideoGeneration'
import type { VideoStatus } from '../types/video'

const emit = defineEmits<{
  selectVideo: [videoId: string]
  remixVideo: [videoId: string]
}>()

const { videos, loading, error, fetchVideos, removeVideo } = useVideoLibrary()
const { deleteVideo } = useVideoGeneration()

const filterStatus = ref<VideoStatus | 'all'>('all')
const sortOrder = ref<'desc' | 'asc'>('desc')

const filteredVideos = computed(() => {
  let filtered = videos.value

  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(v => v.status === filterStatus.value)
  }

  return filtered
})

const statusCounts = computed(() => {
  return {
    all: videos.value.length,
    completed: videos.value.filter(v => v.status === 'completed').length,
    in_progress: videos.value.filter(v => v.status === 'in_progress').length,
    queued: videos.value.filter(v => v.status === 'queued').length,
    failed: videos.value.filter(v => v.status === 'failed').length
  }
})

const loadVideos = async () => {
  await fetchVideos({
    order: sortOrder.value,
    ...(filterStatus.value !== 'all' && { status: filterStatus.value })
  })
}

const handleDelete = async (videoId: string) => {
  if (!confirm('Are you sure you want to delete this video?')) {
    return
  }

  try {
    await deleteVideo(videoId)
    removeVideo(videoId)
  } catch (err) {
    console.error('Failed to delete video:', err)
  }
}

const handleView = (videoId: string) => {
  emit('selectVideo', videoId)
}

const handleRemix = (videoId: string) => {
  emit('remixVideo', videoId)
}

const formatDate = (timestamp: number) => {
  return new Date(timestamp * 1000).toLocaleString()
}

const getStatusColor = (status: VideoStatus) => {
  switch (status) {
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
}

onMounted(() => {
  loadVideos()
})
</script>

<template>
  <div class="video-library">
    <div class="library-header">
      <h2>Video Library</h2>
      <button class="refresh-btn" @click="loadVideos" :disabled="loading">
        {{ loading ? 'Loading...' : 'Refresh' }}
      </button>
    </div>

    <!-- Filters -->
    <div class="filters">
      <div class="filter-group">
        <label>Filter by Status:</label>
        <div class="filter-buttons">
          <button
            :class="{ active: filterStatus === 'all' }"
            @click="filterStatus = 'all'; loadVideos()"
          >
            All ({{ statusCounts.all }})
          </button>
          <button
            :class="{ active: filterStatus === 'completed' }"
            @click="filterStatus = 'completed'; loadVideos()"
          >
            Completed ({{ statusCounts.completed }})
          </button>
          <button
            :class="{ active: filterStatus === 'in_progress' }"
            @click="filterStatus = 'in_progress'; loadVideos()"
          >
            In Progress ({{ statusCounts.in_progress }})
          </button>
          <button
            :class="{ active: filterStatus === 'failed' }"
            @click="filterStatus = 'failed'; loadVideos()"
          >
            Failed ({{ statusCounts.failed }})
          </button>
        </div>
      </div>

      <div class="filter-group">
        <label>Sort:</label>
        <select v-model="sortOrder" @change="loadVideos">
          <option value="desc">Newest First</option>
          <option value="asc">Oldest First</option>
        </select>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Video Grid -->
    <div v-if="!loading && filteredVideos.length > 0" class="video-grid">
      <div v-for="video in filteredVideos" :key="video.id" class="video-card">
        <div class="card-header">
          <span
            class="status-badge"
            :style="{ backgroundColor: getStatusColor(video.status) }"
          >
            {{ video.status }}
          </span>
          <span class="video-id">{{ video.id }}</span>
        </div>

        <div class="card-body">
          <div class="video-info">
            <div class="info-row">
              <span class="label">Model:</span>
              <span class="value">{{ video.model }}</span>
            </div>
            <div class="info-row">
              <span class="label">Duration:</span>
              <span class="value">{{ video.seconds }}s</span>
            </div>
            <div class="info-row">
              <span class="label">Resolution:</span>
              <span class="value">{{ video.size }}</span>
            </div>
            <div class="info-row">
              <span class="label">Created:</span>
              <span class="value">{{ formatDate(video.created_at) }}</span>
            </div>
            <div v-if="video.status === 'in_progress'" class="info-row">
              <span class="label">Progress:</span>
              <span class="value">{{ video.progress }}%</span>
            </div>
          </div>

          <div v-if="video.error" class="error-info">
            <strong>Error:</strong> {{ video.error.message }}
          </div>
        </div>

        <div class="card-actions">
          <button
            v-if="video.status === 'completed'"
            class="action-btn primary"
            @click="handleView(video.id)"
          >
            View
          </button>
          <button
            v-if="video.status === 'completed'"
            class="action-btn"
            @click="handleRemix(video.id)"
          >
            Remix
          </button>
          <button class="action-btn danger" @click="handleDelete(video.id)">
            Delete
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="!loading && filteredVideos.length === 0" class="empty-state">
      <p>No videos found.</p>
      <p v-if="filterStatus !== 'all'">Try changing the filter.</p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading">
      Loading videos...
    </div>
  </div>
</template>

<style scoped>
.video-library {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.library-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.library-header h2 {
  margin: 0;
  font-size: 1.8rem;
  font-weight: bold;
  color: black;
}

.refresh-btn {
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  color: black;
  font-weight: 500;
  transition: all 0.2s;
}

.refresh-btn:hover:not(:disabled) {
  background: #f5f5f5;
  border-color: #999;
}

.refresh-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.filters {
  margin-bottom: 2rem;
  padding: 1rem;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

.filter-group {
  margin-bottom: 1rem;
}

.filter-group:last-child {
  margin-bottom: 0;
}

.filter-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: black;
}

.filter-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.filter-buttons button {
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  color: black;
  transition: all 0.2s;
}

.filter-buttons button:hover {
  background: #f5f5f5;
}

.filter-buttons button.active {
  background: black;
  color: white;
  border-color: black;
}

.filter-group select {
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: white;
  color: black;
  font-size: 1rem;
}

.error-message {
  padding: 1rem;
  margin-bottom: 1rem;
  background: #fee;
  border: 1px solid #fcc;
  border-radius: 4px;
  color: #c00;
}

.video-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.video-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  overflow: hidden;
  transition: box-shadow 0.2s;
}

.video-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.card-header {
  padding: 1rem;
  background: #f9f9f9;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
  color: white;
}

.video-id {
  font-size: 0.85rem;
  color: #666;
  font-family: monospace;
}

.card-body {
  padding: 1rem;
}

.video-info {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
}

.info-row .label {
  color: #666;
}

.info-row .value {
  font-weight: 600;
  color: black;
}

.error-info {
  margin-top: 1rem;
  padding: 0.75rem;
  background: #fee;
  border: 1px solid #fcc;
  border-radius: 4px;
  font-size: 0.85rem;
  color: #c00;
}

.card-actions {
  padding: 1rem;
  border-top: 1px solid #e0e0e0;
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: white;
  color: black;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.2s;
}

.action-btn:hover {
  background: #f5f5f5;
}

.action-btn.primary {
  background: black;
  color: white;
  border-color: black;
}

.action-btn.primary:hover {
  background: #333;
}

.action-btn.danger {
  color: #c00;
  border-color: #fcc;
}

.action-btn.danger:hover {
  background: #fee;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #666;
}

.empty-state p {
  margin: 0.5rem 0;
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #666;
  font-style: italic;
}
</style>
