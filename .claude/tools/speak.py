import sys
from elevenlabs import generate, play

if len(sys.argv) < 2:
    response = "Done—check the console for details."
else:
    response = ' '.join(sys.argv[1:])  # Join args as full response

audio = generate(
    text=response,
    voice="Rachel",  # Soft, clear voice—change to "Josh" for deeper/male
    model="eleven_monolingual_v1"  # Fast model
)
play(audio)