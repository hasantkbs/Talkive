import speech_recognition as sr
import pyttsx3

class VoiceAssistant:
    def __init__(self):
        """
        Initializes the recognizer and the text-to-speech engine.
        """
        self.recognizer = sr.Recognizer()
        self.tts_engine = pyttsx3.init()

    def listen_from_microphone(self) -> str:
        """
        Listens for user input from the microphone and returns the recognized text.
        Returns an empty string if speech is not understood or an error occurs.
        """
        with sr.Microphone() as source:
            self.recognizer.adjust_for_ambient_noise(source)
            audio = self.recognizer.listen(source)
        
        try:
            text = self.recognizer.recognize_google(audio)
            return text
        except sr.UnknownValueError:
            return ""
        except sr.RequestError as e:
            print(f"Could not request results from Google Speech Recognition service; {e}")
            return ""

    def speak(self, text: str):
        """
        Converts the given text to speech and speaks it out.
        
        Args:
            text: The text to be spoken.
        """
        if text:
            print(f"AI: {text}")
            self.tts_engine.say(text)
            self.tts_engine.runAndWait()
