"""Response models for video generation endpoints."""

from typing import Optional, List, Literal
from pydantic import BaseModel, Field


class ErrorDetail(BaseModel):
    """Error detail structure."""

    message: str
    type: str


class VideoJob(BaseModel):
    """Video generation job status and metadata."""

    id: str = Field(..., description="Unique video job identifier")
    object: str = Field(default="video", description="Object type")
    status: Literal["queued", "in_progress", "completed", "failed"] = Field(..., description="Job status")
    model: str = Field(..., description="Model used for generation")
    progress: Optional[int] = Field(None, ge=0, le=100, description="Progress percentage")
    created_at: int = Field(..., description="Unix timestamp of creation")
    completed_at: Optional[int] = Field(None, description="Unix timestamp of completion")
    expires_at: Optional[int] = Field(None, description="Unix timestamp when assets expire")
    size: str = Field(..., description="Video resolution")
    seconds: str = Field(..., description="Video duration")
    remixed_from_video_id: Optional[str] = Field(None, description="Source video ID if remix")
    error: Optional[ErrorDetail] = Field(None, description="Error details if failed")

    class Config:
        json_schema_extra = {
            "example": {
                "id": "video_abc123",
                "object": "video",
                "status": "in_progress",
                "model": "sora-2",
                "progress": 45,
                "created_at": 1758941485,
                "size": "1280x720",
                "seconds": "4",
            }
        }


class VideoListResponse(BaseModel):
    """Response model for listing videos."""

    object: str = Field(default="list", description="Object type")
    data: List[VideoJob] = Field(default_factory=list, description="List of video jobs")
    has_more: bool = Field(default=False, description="Whether more results exist")


class VideoDeleteResponse(BaseModel):
    """Response model for video deletion."""

    id: str = Field(..., description="Deleted video ID")
    object: str = Field(default="video", description="Object type")
    deleted: bool = Field(default=True, description="Deletion confirmation")
