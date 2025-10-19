"""API endpoints for video generation."""

from typing import Optional, Literal, Annotated
from fastapi import APIRouter, HTTPException, File, UploadFile, Form, Query
from fastapi.responses import StreamingResponse
from pydantic import field_validator, Field
import io

from ..models import (
    CreateVideoRequest,
    RemixVideoRequest,
    VideoJob,
    VideoListResponse,
    VideoDeleteResponse,
)
from ..services import SoraService, StorageService
from ..config import settings
from ..utils.logging_setup import logger

router = APIRouter(prefix="/api/v1/videos", tags=["videos"])

# Initialize services
sora_service = SoraService()
storage_service = StorageService()


@router.post("", response_model=VideoJob, status_code=201)
async def create_video(
    prompt: str = Form(...),
    model: Literal["sora-2", "sora-2-pro"] = Form(settings.default_model),
    seconds: int = Form(settings.default_seconds),
    size: str = Form(settings.default_size),
    input_reference: Optional[UploadFile] = File(None),
):
    """
    Create a new video generation job.

    Args:
        prompt: Text description of the video to generate
        model: Model to use (sora-2 or sora-2-pro)
        seconds: Duration in seconds (4, 8, or 12)
        size: Resolution as widthxheight (e.g., 1280x720)
        input_reference: Optional reference image

    Returns:
        VideoJob with initial status
    """
    try:
        # Validate seconds parameter
        if seconds not in [4, 8, 12]:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid duration. Must be 4, 8, or 12 seconds, got {seconds}",
            )

        logger.info(f"Received create video request: model={model}, seconds={seconds}, size={size}")

        # Handle input reference if provided
        reference_bytes = None
        if input_reference:
            # Validate file size
            content = await input_reference.read()
            if len(content) > settings.max_file_size:
                raise HTTPException(
                    status_code=413,
                    detail=f"File too large. Maximum size is {settings.max_file_size} bytes",
                )

            # Validate file type
            if not input_reference.content_type or not input_reference.content_type.startswith("image/"):
                raise HTTPException(
                    status_code=400,
                    detail="Input reference must be an image (JPEG, PNG, or WebP)",
                )

            reference_bytes = content
            logger.info(f"Reference image received: {input_reference.filename}, size: {len(content)} bytes")

        # Create video
        video = await sora_service.create_video(
            prompt=prompt,
            model=model,
            seconds=seconds,
            size=size,
            input_reference=reference_bytes,
        )

        return video

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating video: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to create video: {str(e)}")


@router.get("/{video_id}", response_model=VideoJob)
async def get_video_status(video_id: str):
    """
    Get the current status of a video generation job.

    Args:
        video_id: The video job identifier

    Returns:
        VideoJob with current status and progress
    """
    try:
        logger.info(f"Fetching status for video: {video_id}")

        video = await sora_service.get_video_status(video_id)
        return video

    except Exception as e:
        logger.error(f"Error fetching video status: {str(e)}", exc_info=True)
        if "not found" in str(e).lower() or "404" in str(e):
            raise HTTPException(status_code=404, detail=f"Video {video_id} not found")
        raise HTTPException(status_code=500, detail=f"Failed to fetch video status: {str(e)}")


@router.get("/{video_id}/poll", response_model=VideoJob)
async def poll_video(video_id: str, timeout: int = Query(300, ge=1, le=600)):
    """
    Poll video status until completion or timeout.

    Args:
        video_id: The video job identifier
        timeout: Maximum seconds to wait (default: 300, max: 600)

    Returns:
        Final VideoJob status (completed or failed)
    """
    try:
        logger.info(f"Starting poll for video: {video_id}, timeout: {timeout}s")

        video = await sora_service.poll_until_complete(video_id, timeout=timeout)
        return video

    except TimeoutError as e:
        logger.warning(f"Polling timeout for video {video_id}")
        raise HTTPException(status_code=504, detail=str(e))
    except Exception as e:
        logger.error(f"Error polling video: {str(e)}", exc_info=True)
        if "not found" in str(e).lower() or "404" in str(e):
            raise HTTPException(status_code=404, detail=f"Video {video_id} not found")
        raise HTTPException(status_code=500, detail=f"Failed to poll video: {str(e)}")


@router.get("/{video_id}/content")
async def download_video_content(
    video_id: str, variant: Literal["video", "thumbnail", "spritesheet"] = Query("video")
):
    """
    Download video content or supporting assets.

    Args:
        video_id: The video job identifier
        variant: Type of asset to download (video, thumbnail, or spritesheet)

    Returns:
        Binary stream of the requested asset
    """
    try:
        logger.info(f"Download request for video {video_id}, variant: {variant}")

        # Check if video is completed first
        video = await sora_service.get_video_status(video_id)
        if video.status != "completed":
            raise HTTPException(
                status_code=409,
                detail=f"Video is not ready for download. Current status: {video.status}",
            )

        # Check if we have it cached locally
        local_path = await storage_service.get_video_path(video_id, variant)

        if local_path:
            # Serve from local storage
            logger.info(f"Serving {variant} from local storage: {local_path}")
            with open(local_path, "rb") as f:
                content = f.read()
        else:
            # Download from OpenAI and cache
            logger.info(f"Downloading {variant} from OpenAI API")
            content = await sora_service.download_video_content(video_id, variant)

            # Save to local storage
            await storage_service.save_video(video_id, content, variant)

        # Return as streaming response
        content_type = storage_service.get_content_type(variant)
        return StreamingResponse(
            io.BytesIO(content),
            media_type=content_type,
            headers={
                "Content-Disposition": f'attachment; filename="{video_id}_{variant}.{variant}"',
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error downloading video content: {str(e)}", exc_info=True)
        if "not found" in str(e).lower() or "404" in str(e):
            raise HTTPException(status_code=404, detail=f"Video {video_id} not found")
        raise HTTPException(status_code=500, detail=f"Failed to download video content: {str(e)}")


@router.get("", response_model=VideoListResponse)
async def list_videos(
    limit: int = Query(20, ge=1, le=100),
    after: Optional[str] = Query(None),
    order: Literal["asc", "desc"] = Query("desc"),
):
    """
    List video generation jobs with pagination.

    Args:
        limit: Maximum number of results (1-100, default: 20)
        after: Pagination cursor (video ID to start after)
        order: Sort order (asc or desc, default: desc)

    Returns:
        VideoListResponse with list of videos
    """
    try:
        logger.info(f"Listing videos: limit={limit}, after={after}, order={order}")

        videos, has_more = await sora_service.list_videos(limit=limit, after=after, order=order)

        return VideoListResponse(data=videos, has_more=has_more)

    except Exception as e:
        logger.error(f"Error listing videos: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to list videos: {str(e)}")


@router.delete("/{video_id}", response_model=VideoDeleteResponse)
async def delete_video(video_id: str):
    """
    Delete a video from OpenAI storage and local cache.

    Args:
        video_id: The video job identifier

    Returns:
        VideoDeleteResponse confirming deletion
    """
    try:
        logger.info(f"Deleting video: {video_id}")

        # Delete from OpenAI
        result = await sora_service.delete_video(video_id)

        # Delete local files
        deleted_files = await storage_service.delete_video_files(video_id)
        logger.info(f"Deleted {deleted_files} local files for video {video_id}")

        return VideoDeleteResponse(**result)

    except Exception as e:
        logger.error(f"Error deleting video: {str(e)}", exc_info=True)
        if "not found" in str(e).lower() or "404" in str(e):
            raise HTTPException(status_code=404, detail=f"Video {video_id} not found")
        raise HTTPException(status_code=500, detail=f"Failed to delete video: {str(e)}")


@router.post("/{video_id}/remix", response_model=VideoJob, status_code=201)
async def remix_video(video_id: str, request: RemixVideoRequest):
    """
    Create a remix of an existing video with modifications.

    Args:
        video_id: Source video identifier (must be completed)
        request: Remix request with new prompt

    Returns:
        VideoJob for the new remix
    """
    try:
        logger.info(f"Creating remix of video {video_id}")

        # Verify source video is completed
        source_video = await sora_service.get_video_status(video_id)
        if source_video.status != "completed":
            raise HTTPException(
                status_code=400,
                detail=f"Source video must be completed. Current status: {source_video.status}",
            )

        # Create remix
        remix = await sora_service.remix_video(video_id, request.prompt)

        return remix

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating remix: {str(e)}", exc_info=True)
        if "not found" in str(e).lower() or "404" in str(e):
            raise HTTPException(status_code=404, detail=f"Video {video_id} not found")
        raise HTTPException(status_code=500, detail=f"Failed to create remix: {str(e)}")
