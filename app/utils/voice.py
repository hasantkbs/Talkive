import speech_recognition as sr
import pyttsx3
import tempfile
import os
import io

class VoiceInteraction:
    """
    Handles Speech-to-Text (STT) and Text-to-Speech (TTS) functionalities.
    """
    def __init__(self):
        """
        Initializes the recognizer and the text-to-speech engine.
        """
        self.recognizer = sr.Recognizer()
        self.tts_engine = pyttsx3.init()

    def listen(self) -> str:
        """
        Listens for user input from the microphone and returns the recognized text.
        Returns None if speech is not understood or an error occurs.
        """
        with sr.Microphone() as source:
            print("Adjusting for ambient noise... Please wait.")
            self.recognizer.adjust_for_ambient_noise(source, duration=1)
            print("Listening...")
            try:
                audio = self.recognizer.listen(source, timeout=5, phrase_time_limit=15)
                text = self.recognizer.recognize_google(audio)
                return text
            except sr.UnknownValueError:
                print("Google Speech Recognition could not understand audio")
                return None
            except sr.RequestError as e:
                print(f"Could not request results from Google Speech Recognition service; {e}")
                return None
            except sr.WaitTimeoutError:
                print("Listening timed out while waiting for phrase to start")
                return None

    def speak_out(self, text: str):
        """
        (For CLI use) Converts the given text to speech and speaks it out directly.
        """
        if text:
            self.tts_engine.say(text)
            self.tts_engine.runAndWait()

    def text_to_audio(self, text: str) -> io.BytesIO:
        """
        Converts text to speech and returns it as an in-memory audio buffer.
        This is suitable for use in an API.
        """
        if not text:
            return None

        # Use a temporary file to capture the audio output from pyttsx3
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as temp_audio_file:
            temp_filename = temp_audio_file.name
        
        try:
            # Save the speech to the temporary file
            self.tts_engine.save_to_file(text, temp_filename)
            self.tts_engine.runAndWait()

            # Read the audio data from the temporary file into a buffer
            with open(temp_filename, 'rb') as f:
                audio_buffer = io.BytesIO(f.read())
        finally:
            # Ensure the temporary file is deleted
            if os.path.exists(temp_filename):
                os.remove(temp_filename)
        
        audio_buffer.seek(0)  # Rewind the buffer to the beginning
        return audio_buffer

    def detect_language(self, text: str) -> str:
        """
        Detects the language of a given text.
        """
        # This is a placeholder. For a real implementation, you would use a library
        # like langdetect, but it's removed to keep dependencies minimal until needed.
        # from langdetect import detect
        # try:
        #     return detect(text)
        # except:
        #     return "en" # Default to English on error
        if any(ord(c) > 127 for c in text): # Simple heuristic
            return "tr" # Assume Turkish if non-ASCII chars are present
        return "en"
