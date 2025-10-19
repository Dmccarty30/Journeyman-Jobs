"""Request models for video generation endpoints."""

from typing import Literal, Optional
from pydantic import BaseModel, Field


class CreateVideoRequest(BaseModel):
    """Request model for creating a new video."""

    prompt: str = Field(..., min_length=1, max_length=2000, description="Text prompt describing the video")
    model: Literal["sora-2", "sora-2-pro"] = Field(default="sora-2", description="Video generation model")
    seconds: Literal[4, 8, 12] = Field(default=4, description="Duration in seconds")
    size: str = Field(default="1280x720", description="Output resolution (widthxheight)")

    class Config:
        json_schema_extra = {
            "example": {
                "prompt": "A calico cat playing piano on stage under spotlight",
                "model": "sora-2",
                "seconds": 4,
                "size": "1280x720",
            }
        }


class RemixVideoRequest(BaseModel):
    """Request model for remixing an existing video."""

    prompt: str = Field(..., min_length=1, max_length=2000, description="Updated prompt for remix")

    class Config:
        json_schema_extra = {
            "example": {
                "prompt": "Change the cat to orange and add confetti falling"
            }
        }
