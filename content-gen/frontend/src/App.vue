<script setup lang="ts">
import { ref } from 'vue'
import VideoCreator from './components/VideoCreator.vue'
import VideoProgress from './components/VideoProgress.vue'
import VideoLibrary from './components/VideoLibrary.vue'
import VideoPlayer from './components/VideoPlayer.vue'
import type { VideoJob } from './types/video'

type View = 'home' | 'progress' | 'player' | 'library'

const currentView = ref<View>('home')
const currentVideoId = ref<string | null>(null)
const remixPrompt = ref('')
const showRemixDialog = ref(false)

const handleVideoCreated = (videoId: string) => {
  currentVideoId.value = videoId
  currentView.value = 'progress'
}

const handleProgressCompleted = (video: VideoJob) => {
  console.log('Video completed:', video)
  // Automatically switch to player view when complete
  currentView.value = 'player'
}

const handleProgressFailed = (video: VideoJob) => {
  console.error('Video failed:', video)
  // Stay on progress view to show error
}

const handleSelectVideo = (videoId: string) => {
  currentVideoId.value = videoId
  currentView.value = 'player'
}

const handleRemixVideo = (videoId: string) => {
  currentVideoId.value = videoId
  showRemixDialog.value = true
}

const confirmRemix = () => {
  if (remixPrompt.value.trim()) {
    // In a full implementation, this would call the remix API
    // For now, just close the dialog
    showRemixDialog.value = false
    remixPrompt.value = ''
  }
}

const cancelRemix = () => {
  showRemixDialog.value = false
  remixPrompt.value = ''
}

const goToHome = () => {
  currentView.value = 'home'
  currentVideoId.value = null
}

const goToLibrary = () => {
  currentView.value = 'library'
}
</script>

<template>
  <div class="app-container">
    <!-- Header -->
    <header class="app-header">
      <h1 @click="goToHome" class="app-title">SORA VIDEO GENERATOR</h1>
      <nav class="app-nav">
        <button
          :class="{ active: currentView === 'home' }"
          @click="goToHome"
        >
          Create
        </button>
        <button
          :class="{ active: currentView === 'library' }"
          @click="goToLibrary"
        >
          Library
        </button>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="app-main">
      <!-- Home View: Video Creator -->
      <div v-if="currentView === 'home'" class="view">
        <VideoCreator @video-created="handleVideoCreated" />
      </div>

      <!-- Progress View -->
      <div v-if="currentView === 'progress' && currentVideoId" class="view">
        <VideoProgress
          :video-id="currentVideoId"
          :auto-refresh="true"
          @completed="handleProgressCompleted"
          @failed="handleProgressFailed"
        />
        <div class="view-actions">
          <button @click="goToHome" class="secondary-btn">Create Another Video</button>
          <button @click="goToLibrary" class="secondary-btn">View Library</button>
        </div>
      </div>

      <!-- Player View -->
      <div v-if="currentView === 'player' && currentVideoId" class="view">
        <VideoPlayer
          :video-id="currentVideoId"
          @remix="handleRemixVideo"
          @close="goToLibrary"
        />
      </div>

      <!-- Library View -->
      <div v-if="currentView === 'library'" class="view">
        <VideoLibrary
          @select-video="handleSelectVideo"
          @remix-video="handleRemixVideo"
        />
      </div>
    </main>

    <!-- Remix Dialog -->
    <div v-if="showRemixDialog" class="dialog-overlay" @click="cancelRemix">
      <div class="dialog" @click.stop>
        <h3>Remix Video</h3>
        <p>Enter a prompt to create a variation of this video:</p>
        <textarea
          v-model="remixPrompt"
          placeholder="Describe the changes you want to make..."
          rows="4"
        ></textarea>
        <div class="dialog-actions">
          <button @click="cancelRemix" class="secondary-btn">Cancel</button>
          <button @click="confirmRemix" class="primary-btn" :disabled="!remixPrompt.trim()">
            Create Remix
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.app-container {
  min-height: 100vh;
  background: white;
  color: black;
}

.app-header {
  background: black;
  color: white;
  padding: 1.5rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid #333;
}

.app-title {
  margin: 0;
  font-size: 1.5rem;
  font-weight: bold;
  cursor: pointer;
  transition: opacity 0.2s;
}

.app-title:hover {
  opacity: 0.8;
}

.app-nav {
  display: flex;
  gap: 1rem;
}

.app-nav button {
  padding: 0.5rem 1rem;
  background: transparent;
  color: white;
  border: 1px solid white;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.2s;
}

.app-nav button:hover {
  background: white;
  color: black;
}

.app-nav button.active {
  background: white;
  color: black;
}

.app-main {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.view {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.view-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 2rem;
}

.secondary-btn {
  padding: 0.75rem 1.5rem;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  color: black;
  transition: all 0.2s;
}

.secondary-btn:hover {
  background: #f5f5f5;
  border-color: #999;
}

.primary-btn {
  padding: 0.75rem 1.5rem;
  background: black;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: background 0.2s;
}

.primary-btn:hover:not(:disabled) {
  background: #333;
}

.primary-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.dialog {
  background: white;
  padding: 2rem;
  border-radius: 4px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
}

.dialog h3 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.5rem;
  color: black;
}

.dialog p {
  margin-bottom: 1rem;
  color: #666;
}

.dialog textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-family: inherit;
  font-size: 1rem;
  color: black;
  resize: vertical;
  box-sizing: border-box;
}

.dialog textarea:focus {
  outline: none;
  border-color: #666;
}

.dialog-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
}
</style>
