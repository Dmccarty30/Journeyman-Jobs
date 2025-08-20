#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "openai",
#     "python-dotenv",
# ]
# ///

import os
import sys
from pathlib import Path
from dotenv import load_dotenv


def transcribe_file(audio_path: str) -> str:
    """
    Minimal OpenAI STT transcription for a local audio file.

    Args:
        audio_path: Path to an audio file (wav/mp3/m4a)

    Returns:
        The transcribed text, or an empty string on error.
    """
    load_dotenv()
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY not set in environment. Add it to your .env.", file=sys.stderr)
        return ""

    try:
        from openai import OpenAI
    except Exception as e:
        print(f"Error importing openai: {e}", file=sys.stderr)
        return ""

    if not os.path.exists(audio_path):
        print(f"Error: file not found: {audio_path}", file=sys.stderr)
        return ""

    try:
        client = OpenAI(api_key=api_key)
        # Prefer gpt-4o-transcribe if available; fallback to whisper-1
        model = os.getenv("OPENAI_STT_MODEL", "gpt-4o-transcribe")
        with open(audio_path, "rb") as f:
            try:
                resp = client.audio.transcriptions.create(model=model, file=f)
            except Exception:
                # Fallback to whisper-1 if first attempt fails
                f.seek(0)
                resp = client.audio.transcriptions.create(model="whisper-1", file=f)
        text = getattr(resp, "text", None) or (resp.get("text") if isinstance(resp, dict) else None)
        return text or ""
    except Exception as e:
        print(f"Transcription error: {e}", file=sys.stderr)
        return ""


def main():
    if len(sys.argv) < 2:
        print("Usage: ./openai_stt.py <audio_file.(wav|mp3|m4a)>", file=sys.stderr)
        sys.exit(2)

    audio_path = sys.argv[1]
    text = transcribe_file(audio_path)
    if text:
        print(text)
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
