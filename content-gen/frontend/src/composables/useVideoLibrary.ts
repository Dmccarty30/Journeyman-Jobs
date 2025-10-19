import { ref } from 'vue'
import axios from 'axios'
import type { VideoJob, VideoListResponse, FetchVideosOptions } from '../types/video'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4444/api/v1'

export function useVideoLibrary() {
  const videos = ref<VideoJob[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const hasMore = ref(false)

  const fetchVideos = async (options: FetchVideosOptions = {}): Promise<void> => {
    loading.value = true
    error.value = null

    try {
      const params = {
        limit: options.limit || 20,
        ...(options.after && { after: options.after }),
        ...(options.order && { order: options.order }),
        ...(options.status && { status: options.status })
      }

      const response = await axios.get<VideoListResponse>(`${API_BASE_URL}/videos`, { params })

      videos.value = response.data.data
      hasMore.value = response.data.has_more
    } catch (err) {
      if (axios.isAxiosError(err)) {
        error.value = err.response?.data?.detail || err.message
      } else {
        error.value = 'Failed to fetch videos'
      }
      console.error('Error fetching videos:', err)
    } finally {
      loading.value = false
    }
  }

  const refreshVideo = async (videoId: string): Promise<void> => {
    try {
      const response = await axios.get<VideoJob>(`${API_BASE_URL}/videos/${videoId}`)

      // Update the video in the list
      const index = videos.value.findIndex(v => v.id === videoId)
      if (index !== -1) {
        videos.value[index] = response.data
      }
    } catch (err) {
      console.error('Error refreshing video:', err)
    }
  }

  const removeVideo = (videoId: string): void => {
    videos.value = videos.value.filter(v => v.id !== videoId)
  }

  const addVideo = (video: VideoJob): void => {
    // Add to beginning of list
    videos.value.unshift(video)
  }

  return {
    videos,
    loading,
    error,
    hasMore,
    fetchVideos,
    refreshVideo,
    removeVideo,
    addVideo
  }
}
