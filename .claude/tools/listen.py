import speech_recognition as sr
import sys

r = sr.Recognizer()
with sr.Microphone() as source:
    print("Go ahead—talk about the error...")
    audio = r.listen(source, timeout=10, phrase_time_limit=30)  # 10s timeout, 30s max phrase
    try:
        text = r.recognize_sphinx(audio)  # Offline STT with pocketsphinx
        print(f"You said: {text}")
        sys.stdout.write(text)  # Output to pipe into Claude/coordinator
    except sr.UnknownValueError:
        print("Couldn't catch that—try again?")
        sys.stdout.write("")  # Empty if fail
    except sr.RequestError as e:
        print(f"STT error: {e}")
        sys.stdout.write("")