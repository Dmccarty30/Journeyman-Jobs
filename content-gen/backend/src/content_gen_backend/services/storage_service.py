"""Storage service for managing downloaded video files."""

import aiofiles
from pathlib import Path
from typing import Optional, Literal
from ..config import settings
from ..utils.logging_setup import logger


class StorageService:
    """Service for local file storage operations."""

    def __init__(self, storage_path: Optional[str] = None):
        """
        Initialize storage service.

        Args:
            storage_path: Path to video storage directory
        """
        self.storage_path = Path(storage_path or settings.video_storage_path)
        self.storage_path.mkdir(parents=True, exist_ok=True)
        logger.info(f"StorageService initialized with path: {self.storage_path.absolute()}")

    async def save_video(
        self, video_id: str, content: bytes, variant: Literal["video", "thumbnail", "spritesheet"] = "video"
    ) -> Path:
        """
        Save video content to local storage.

        Args:
            video_id: Video identifier
            content: Binary content to save
            variant: Type of asset (video, thumbnail, spritesheet)

        Returns:
            Path to saved file
        """
        try:
            # Determine file extension
            extensions = {
                "video": ".mp4",
                "thumbnail": ".webp",
                "spritesheet": ".jpg",
            }
            ext = extensions.get(variant, ".bin")

            # Create filename
            filename = f"{video_id}_{variant}{ext}"
            filepath = self.storage_path / filename

            # Save file
            async with aiofiles.open(filepath, "wb") as f:
                await f.write(content)

            logger.info(f"Saved {variant} to {filepath} ({len(content)} bytes)")
            return filepath

        except Exception as e:
            logger.error(f"Error saving {variant} for video {video_id}: {str(e)}", exc_info=True)
            raise

    async def get_video_path(
        self, video_id: str, variant: Literal["video", "thumbnail", "spritesheet"] = "video"
    ) -> Optional[Path]:
        """
        Get path to saved video file if it exists.

        Args:
            video_id: Video identifier
            variant: Type of asset

        Returns:
            Path if file exists, None otherwise
        """
        extensions = {
            "video": ".mp4",
            "thumbnail": ".webp",
            "spritesheet": ".jpg",
        }
        ext = extensions.get(variant, ".bin")
        filename = f"{video_id}_{variant}{ext}"
        filepath = self.storage_path / filename

        if filepath.exists():
            logger.debug(f"Found existing file: {filepath}")
            return filepath

        logger.debug(f"File not found: {filepath}")
        return None

    async def delete_video_files(self, video_id: str) -> int:
        """
        Delete all files associated with a video ID.

        Args:
            video_id: Video identifier

        Returns:
            Number of files deleted
        """
        deleted_count = 0

        try:
            # Find all files matching the video_id pattern
            pattern = f"{video_id}_*"
            for filepath in self.storage_path.glob(pattern):
                filepath.unlink()
                deleted_count += 1
                logger.info(f"Deleted file: {filepath}")

            logger.info(f"Deleted {deleted_count} files for video {video_id}")
            return deleted_count

        except Exception as e:
            logger.error(f"Error deleting files for video {video_id}: {str(e)}", exc_info=True)
            raise

    def get_content_type(self, variant: Literal["video", "thumbnail", "spritesheet"]) -> str:
        """
        Get MIME content type for variant.

        Args:
            variant: Type of asset

        Returns:
            MIME type string
        """
        content_types = {
            "video": "video/mp4",
            "thumbnail": "image/webp",
            "spritesheet": "image/jpeg",
        }
        return content_types.get(variant, "application/octet-stream")
