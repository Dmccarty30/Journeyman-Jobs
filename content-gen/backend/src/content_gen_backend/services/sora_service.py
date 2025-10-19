"""Sora API service wrapper for video generation."""

import asyncio
from typing import Optional, List, Literal
from openai import AsyncOpenAI, OpenAIError
from ..config import settings
from ..models.video_response import VideoJob, ErrorDetail
from ..utils.logging_setup import logger


class SoraService:
    """Service class for interacting with OpenAI's Sora API."""

    def __init__(self):
        """Initialize the Sora service with OpenAI client."""
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        logger.info("SoraService initialized")

    async def create_video(
        self,
        prompt: str,
        model: str = "sora-2",
        seconds: int = 4,
        size: str = "1280x720",
        input_reference: Optional[bytes] = None,
    ) -> VideoJob:
        """
        Create a new video generation job.

        Args:
            prompt: Text description of the video
            model: Model to use (sora-2 or sora-2-pro)
            seconds: Duration in seconds
            size: Resolution as widthxheight
            input_reference: Optional reference image bytes

        Returns:
            VideoJob with initial status

        Raises:
            OpenAIError: If API call fails
        """
        try:
            logger.info(f"Creating video with prompt: '{prompt[:50]}...', model: {model}, seconds: {seconds}, size: {size}")

            # Build request parameters
            params = {
                "model": model,
                "prompt": prompt,
                "seconds": str(seconds),
                "size": size,
            }

            # Add input reference if provided
            if input_reference:
                params["input_reference"] = input_reference
                logger.info("Input reference image included")

            # Call OpenAI API
            video = await self.client.videos.create(**params)

            logger.info(f"Video creation started: {video.id}, status: {video.status}")

            # Convert to our model
            return self._convert_to_video_job(video)

        except OpenAIError as e:
            logger.error(f"OpenAI API error during video creation: {str(e)}", exc_info=True)
            raise
        except Exception as e:
            logger.error(f"Unexpected error during video creation: {str(e)}", exc_info=True)
            raise

    async def get_video_status(self, video_id: str) -> VideoJob:
        """
        Retrieve the current status of a video generation job.

        Args:
            video_id: The video job identifier

        Returns:
            VideoJob with current status

        Raises:
            OpenAIError: If API call fails
        """
        try:
            logger.debug(f"Fetching status for video: {video_id}")

            video = await self.client.videos.retrieve(video_id)

            logger.debug(f"Video {video_id} status: {video.status}, progress: {getattr(video, 'progress', 'N/A')}")

            return self._convert_to_video_job(video)

        except OpenAIError as e:
            logger.error(f"OpenAI API error fetching video status for {video_id}: {str(e)}", exc_info=True)
            raise
        except Exception as e:
            logger.error(f"Unexpected error fetching video status for {video_id}: {str(e)}", exc_info=True)
            raise

    async def poll_until_complete(
        self, video_id: str, timeout: int = 300, poll_interval: int = 2
    ) -> VideoJob:
        """
        Poll video status until completion or failure with exponential backoff.

        Args:
            video_id: The video job identifier
            timeout: Maximum seconds to wait
            poll_interval: Initial polling interval in seconds

        Returns:
            Final VideoJob status

        Raises:
            TimeoutError: If timeout is reached
            OpenAIError: If API call fails
        """
        logger.info(f"Starting polling for video {video_id}, timeout: {timeout}s")

        start_time = asyncio.get_event_loop().time()
        current_interval = poll_interval
        max_interval = 10

        while True:
            elapsed = asyncio.get_event_loop().time() - start_time

            if elapsed > timeout:
                logger.warning(f"Polling timeout reached for video {video_id} after {elapsed:.1f}s")
                raise TimeoutError(f"Polling timeout after {timeout} seconds")

            video = await self.get_video_status(video_id)

            if video.status in ["completed", "failed"]:
                logger.info(f"Video {video_id} finished with status: {video.status}")
                return video

            # Exponential backoff
            await asyncio.sleep(current_interval)
            current_interval = min(current_interval * 2, max_interval)

    async def download_video_content(
        self, video_id: str, variant: Literal["video", "thumbnail", "spritesheet"] = "video"
    ) -> bytes:
        """
        Download video content or supporting assets.

        Args:
            video_id: The video job identifier
            variant: Type of asset to download

        Returns:
            Binary content of the asset

        Raises:
            OpenAIError: If API call fails
        """
        try:
            logger.info(f"Downloading {variant} for video {video_id}")

            content = await self.client.videos.download_content(video_id, variant=variant)

            # Read the content
            if hasattr(content, "read"):
                data = content.read()
            elif hasattr(content, "content"):
                data = content.content
            else:
                # Assume it's already bytes
                data = bytes(content)

            logger.info(f"Downloaded {len(data)} bytes of {variant} for video {video_id}")
            return data

        except OpenAIError as e:
            logger.error(f"OpenAI API error downloading {variant} for {video_id}: {str(e)}", exc_info=True)
            raise
        except Exception as e:
            logger.error(f"Unexpected error downloading {variant} for {video_id}: {str(e)}", exc_info=True)
            raise

    async def list_videos(
        self,
        limit: int = 20,
        after: Optional[str] = None,
        order: Literal["asc", "desc"] = "desc",
    ) -> tuple[List[VideoJob], bool]:
        """
        List video generation jobs with pagination.

        Args:
            limit: Maximum number of results
            after: Pagination cursor
            order: Sort order

        Returns:
            Tuple of (list of VideoJobs, has_more flag)

        Raises:
            OpenAIError: If API call fails
        """
        try:
            logger.info(f"Listing videos: limit={limit}, after={after}, order={order}")

            params = {"limit": limit, "order": order}
            if after:
                params["after"] = after

            page = await self.client.videos.list(**params)

            videos = [self._convert_to_video_job(v) for v in page.data]
            has_more = getattr(page, "has_more", False)

            logger.info(f"Retrieved {len(videos)} videos, has_more: {has_more}")

            return videos, has_more

        except OpenAIError as e:
            logger.error(f"OpenAI API error listing videos: {str(e)}", exc_info=True)
            raise
        except Exception as e:
            logger.error(f"Unexpected error listing videos: {str(e)}", exc_info=True)
            raise

    async def delete_video(self, video_id: str) -> dict:
        """
        Delete a video from OpenAI storage.

        Args:
            video_id: The video job identifier

        Returns:
            Deletion confirmation dict

        Raises:
            OpenAIError: If API call fails
        """
        try:
            logger.info(f"Deleting video {video_id}")

            result = await self.client.videos.delete(video_id)

            logger.info(f"Video {video_id} deleted successfully")

            return {"id": video_id, "object": "video", "deleted": True}

        except OpenAIError as e:
            logger.error(f"OpenAI API error deleting video {video_id}: {str(e)}", exc_info=True)
            raise
        except Exception as e:
            logger.error(f"Unexpected error deleting video {video_id}: {str(e)}", exc_info=True)
            raise

    async def remix_video(self, video_id: str, prompt: str) -> VideoJob:
        """
        Create a remix of an existing video.

        Args:
            video_id: Source video identifier
            prompt: New prompt describing the modification

        Returns:
            VideoJob for the new remix

        Raises:
            OpenAIError: If API call fails
        """
        try:
            logger.info(f"Creating remix of video {video_id} with prompt: '{prompt[:50]}...'")

            video = await self.client.videos.remix(video_id=video_id, prompt=prompt)

            logger.info(f"Remix created: {video.id}, remixed from: {video_id}")

            return self._convert_to_video_job(video)

        except OpenAIError as e:
            logger.error(f"OpenAI API error remixing video {video_id}: {str(e)}", exc_info=True)
            raise
        except Exception as e:
            logger.error(f"Unexpected error remixing video {video_id}: {str(e)}", exc_info=True)
            raise

    def _convert_to_video_job(self, video) -> VideoJob:
        """
        Convert OpenAI video object to our VideoJob model.

        Args:
            video: OpenAI video object

        Returns:
            VideoJob instance
        """
        error_detail = None
        if hasattr(video, "error") and video.error:
            error_detail = ErrorDetail(
                message=getattr(video.error, "message", "Unknown error"),
                type=getattr(video.error, "type", "unknown"),
            )

        return VideoJob(
            id=video.id,
            object=getattr(video, "object", "video"),
            status=video.status,
            model=video.model,
            progress=getattr(video, "progress", None),
            created_at=video.created_at,
            completed_at=getattr(video, "completed_at", None),
            expires_at=getattr(video, "expires_at", None),
            size=video.size,
            seconds=str(video.seconds) if hasattr(video, "seconds") else "4",
            remixed_from_video_id=getattr(video, "remixed_from_video_id", None),
            error=error_detail,
        )
