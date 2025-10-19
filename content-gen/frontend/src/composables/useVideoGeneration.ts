/**
 * Composable for video generation operations
 */

import { ref } from 'vue'
import axios from 'axios'
import type {
  VideoJob,
  CreateVideoParams,
  VideoListResponse,
  VideoDeleteResponse,
  VideoVariant,
} from '../types/video'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4444/api/v1'

export function useVideoGeneration() {
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Create a new video generation job
   */
  const createVideo = async (params: CreateVideoParams): Promise<VideoJob> => {
    loading.value = true
    error.value = null

    try {
      const formData = new FormData()
      formData.append('prompt', params.prompt)
      formData.append('model', params.model || 'sora-2')
      formData.append('seconds', String(params.seconds || 4))
      formData.append('size', params.size || '1280x720')

      if (params.inputReference) {
        formData.append('input_reference', params.inputReference)
      }

      const response = await axios.post<VideoJob>(`${API_BASE_URL}/videos`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })

      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to create video'
      throw err
    } finally {
      loading.value = false
    }
  }

  /**
   * Get video status
   */
  const getVideoStatus = async (videoId: string): Promise<VideoJob> => {
    try {
      const response = await axios.get<VideoJob>(`${API_BASE_URL}/videos/${videoId}`)
      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to fetch video status'
      throw err
    }
  }

  /**
   * Poll video until completion
   */
  const pollVideo = async (videoId: string, timeout = 300): Promise<VideoJob> => {
    try {
      const response = await axios.get<VideoJob>(`${API_BASE_URL}/videos/${videoId}/poll`, {
        params: { timeout },
        timeout: (timeout + 10) * 1000, // Add buffer to axios timeout
      })
      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to poll video'
      throw err
    }
  }

  /**
   * Download video content
   */
  const downloadVideo = async (
    videoId: string,
    variant: VideoVariant = 'video'
  ): Promise<Blob> => {
    try {
      const response = await axios.get(`${API_BASE_URL}/videos/${videoId}/content`, {
        params: { variant },
        responseType: 'blob',
      })
      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to download video'
      throw err
    }
  }

  /**
   * Get video URL for streaming
   */
  const getVideoUrl = (videoId: string, variant: VideoVariant = 'video'): string => {
    return `${API_BASE_URL}/videos/${videoId}/content?variant=${variant}`
  }

  /**
   * List videos
   */
  const listVideos = async (
    limit = 20,
    after?: string,
    order: 'asc' | 'desc' = 'desc'
  ): Promise<VideoListResponse> => {
    try {
      const response = await axios.get<VideoListResponse>(`${API_BASE_URL}/videos`, {
        params: { limit, after, order },
      })
      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to list videos'
      throw err
    }
  }

  /**
   * Delete video
   */
  const deleteVideo = async (videoId: string): Promise<VideoDeleteResponse> => {
    try {
      const response = await axios.delete<VideoDeleteResponse>(
        `${API_BASE_URL}/videos/${videoId}`
      )
      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to delete video'
      throw err
    }
  }

  /**
   * Remix video
   */
  const remixVideo = async (videoId: string, prompt: string): Promise<VideoJob> => {
    loading.value = true
    error.value = null

    try {
      const response = await axios.post<VideoJob>(`${API_BASE_URL}/videos/${videoId}/remix`, {
        prompt,
      })
      return response.data
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Failed to remix video'
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    loading,
    error,
    createVideo,
    getVideoStatus,
    pollVideo,
    downloadVideo,
    getVideoUrl,
    listVideos,
    deleteVideo,
    remixVideo,
  }
}
