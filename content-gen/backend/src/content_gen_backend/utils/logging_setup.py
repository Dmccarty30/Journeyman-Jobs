"""Logging configuration with hourly log rotation."""

import logging
import sys
from pathlib import Path
from logging.handlers import TimedRotatingFileHandler
from datetime import datetime


def setup_logging(log_dir: str = "./logs", log_level: int = logging.INFO) -> logging.Logger:
    """
    Set up logging with hourly rotation and console output.

    Args:
        log_dir: Directory to store log files
        log_level: Logging level (default: INFO)

    Returns:
        Configured logger instance
    """
    # Create logs directory if it doesn't exist
    log_path = Path(log_dir)
    log_path.mkdir(parents=True, exist_ok=True)

    # Create logger
    logger = logging.getLogger("content_gen_backend")
    logger.setLevel(log_level)

    # Remove existing handlers to avoid duplicates
    logger.handlers.clear()

    # Format for log messages
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # File handler with hourly rotation
    log_file = log_path / f"sora_api_{datetime.now().strftime('%Y%m%d')}.log"
    file_handler = TimedRotatingFileHandler(
        filename=log_file,
        when="H",  # Rotate every hour
        interval=1,
        backupCount=168,  # Keep 7 days worth of logs (24 * 7)
        encoding="utf-8",
    )
    file_handler.setLevel(log_level)
    file_handler.setFormatter(formatter)
    file_handler.suffix = "%Y%m%d_%H"  # Add hour to filename

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)
    console_handler.setFormatter(formatter)

    # Add handlers
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    logger.info("Logging initialized")
    logger.info(f"Log files will be stored in: {log_path.absolute()}")

    return logger


# Global logger instance
logger = setup_logging()
