"""Configuration settings for the Content Generation Backend."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    openai_api_key: str
    video_storage_path: str = "./videos"
    max_poll_timeout: int = 600
    default_model: str = "sora-2"
    default_size: str = "1280x720"
    default_seconds: int = 4
    max_file_size: int = 10485760  # 10MB

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


# Global settings instance
settings = Settings()
