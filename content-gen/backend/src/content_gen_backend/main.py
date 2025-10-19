from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import videos
from .utils.logging_setup import logger

app = FastAPI(
    title="Content Gen Backend",
    description="AI-powered content generation with Sora video API",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3333", "http://localhost:3334", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(videos.router)

logger.info("FastAPI application initialized")


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    logger.debug("Health check requested")
    return {"status": "healthy", "service": "content-gen-backend", "version": "1.0.0"}


@app.on_event("startup")
async def startup_event():
    """Application startup event."""
    logger.info("Application starting up...")
    logger.info("Video API endpoints available at /api/v1/videos")


@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown event."""
    logger.info("Application shutting down...")
