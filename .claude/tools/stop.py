#!/usr/bin/env python3
"""
Stop Hook for Pi Workflow
- Triggers on agent completion (Stop/SubagentStop).
- Generates TTS summary via ElevenLabs.
- Optional: Sends to local voice server for streaming.
- Usage: Called by settings.json with arg: summary text.
"""

import sys
import os
import requests
from elevenlabs import generate, play
from pathlib import Path

# Config (override via env vars)
ELEVENLABS_VOICE = os.environ.get("ELEVENLABS_VOICE", "Kai")  # e.g., "Rachel" for soft, "Josh" for deep
VOICE_SERVER_URL = os.environ.get("VOICE_SERVER_URL", "http://localhost:8000/tts")  # Your server endpoint
USE_SERVER = os.environ.get("USE_VOICE_SERVER", "true").lower() == "true"  # true for server, false for local play

def generate_tts(text: str, voice: str = ELEVENLABS_VOICE) -> bytes:
    """Generate audio via ElevenLabs API."""
    try:
        audio = generate(
            text=text,
            voice=voice,
            model="eleven_monolingual_v1",  # Fast model
            optimize_streaming_latency=2   # Balance speed/quality
        )
        return audio
    except Exception as e:
        print(f"TTS generation error: {e}")
        return None

def play_local(audio: bytes):
    """Play audio locally (non-blocking)."""
    try:
        play(audio)
    except Exception as e:
        print(f"Local play error: {e}")

def send_to_server(text: str):
    """Send text to voice server for streaming TTS."""
    try:
        response = requests.post(
            VOICE_SERVER_URL,
            json={"text": text, "voice": ELEVENLABS_VOICE},
            timeout=10
        )
        if response.status_code == 200:
            print("TTS sent to server—playing now.")
        else:
            print(f"Server error: {response.status_code}")
    except Exception as e:
        print(f"Server send error: {e}")

def main():
    """Main hook entry—expects summary as arg."""
    if len(sys.argv) < 2:
        summary = "Task complete—no details provided."
    else:
        summary = ' '.join(sys.argv[1:])  # Join args as full summary

    print(f"Stop hook triggered: {summary}")

    # Generate and handle TTS
    audio = generate_tts(summary)
    if audio:
        if USE_SERVER:
            send_to_server(summary)
        else:
            play_local(audio)
    else:
        print("Skipping TTS—generation failed.")

    # Optional: Log to file for debugging
    log_path = Path("./hooks/stop.log")
    with open(log_path, "a") as f:
        f.write(f"[{os.getenv('DATE', '2025-10-18')}] {summary}\n")

if __name__ == "__main__":
    main()