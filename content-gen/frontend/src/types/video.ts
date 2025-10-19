/**
 * Type definitions for video generation
 */

export type VideoStatus = 'queued' | 'in_progress' | 'completed' | 'failed'

export type VideoModel = 'sora-2' | 'sora-2-pro'

export type VideoDuration = 4 | 8 | 12

export type VideoVariant = 'video' | 'thumbnail' | 'spritesheet'

export interface VideoJob {
  id: string
  object: string
  status: VideoStatus
  model: string
  progress?: number
  created_at: number
  completed_at?: number
  expires_at?: number
  size: string
  seconds: string
  remixed_from_video_id?: string
  error?: {
    message: string
    type: string
  }
}

export interface CreateVideoParams {
  prompt: string
  model?: VideoModel
  seconds?: VideoDuration
  size?: string
  inputReference?: File
}

export interface VideoListResponse {
  object: string
  data: VideoJob[]
  has_more: boolean
}

export interface VideoDeleteResponse {
  id: string
  object: string
  deleted: boolean
}
