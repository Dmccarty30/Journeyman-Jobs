# Content Generation Application

> Voice-based agentic coding experiment sandbox

## Codebase Structure

```
backend/          # FastAPI backend service
frontend/         # Vue + TypeScript frontend
specs/            # Project specifications
agents/           # Agent working directory
ai_docs/          # AI documentation
.claude/          # Claude Code configuration
```

## Heads up

This codebase has not been tested beyond initial generation. Expect bugs and rough edges.

## Prerequisites

**Backend requires environment variables:**

Copy `.env.sample` to `.env` in the `backend/` directory and fill in required values:

```bash
cd backend
cp .env.sample .env
# Edit .env and add your OPENAI_API_KEY
```

Minimum required configuration:

```bash
OPENAI_API_KEY=sk-...  # Required for Sora video generation
```

## Quick Start

### Start Both Services (Recommended)

```bash
./start.sh
```

### Or Start Individually

**Backend:**

```bash
cd backend
# Ensure .env file exists with OPENAI_API_KEY
uv run dev
```

**Frontend:**

```bash
cd frontend
npm install
npm run dev -- --port 3333
```

## Services

- Backend: <http://localhost:4444>
- Frontend: <http://localhost:3333>
- Health Check: <http://localhost:4444/health>
