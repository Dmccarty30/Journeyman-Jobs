#!/bin/bash
# Start both backend and frontend services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Kill processes on ports if needed
echo "🧹 Cleaning up ports..."
lsof -ti:4444 | xargs kill -9 2>/dev/null || true
lsof -ti:3333 | xargs kill -9 2>/dev/null || true

echo ""
echo "🚀 Starting services..."
echo ""

# Start backend
echo "📦 Starting backend on http://localhost:4444"
cd backend
uv run uvicorn src.content_gen_backend.main:app --reload --port 4444 &
BACKEND_PID=$!

# Start frontend
echo "🎨 Starting frontend on http://localhost:3333"
cd ../frontend
npm run dev -- --port 3333 &
FRONTEND_PID=$!

echo ""
echo "✅ Services started!"
echo ""
echo "Backend:  http://localhost:4444"
echo "Frontend: http://localhost:3333"
echo "Health:   http://localhost:4444/health"
echo ""
echo "Press Ctrl+C to stop both services"
echo ""

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

wait
