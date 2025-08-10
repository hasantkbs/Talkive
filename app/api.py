
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.talk.talker import TalkingPartner
from app.utils.voice import VoiceInteraction
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from fastapi.responses import StreamingResponse, Response
import asyncio
import os

# --- Configuration ---
SUPPORTED_LANGUAGES = os.getenv("SUPPORTED_LANGUAGES", "en,tr,es").split(',')

# --- Application State ---
talkers = {}
voice_assistant = None

# --- Lifespan Management (Model Loading/Unloading) ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Load ML models and utilities on application startup.
    """
    global voice_assistant
    print("Application startup: Loading models and utilities...")
    
    # Load voice assistant
    voice_assistant = VoiceInteraction()
    print("  -> Voice assistant loaded.")

    # Load language models
    for lang in SUPPORTED_LANGUAGES:
        print(f"  -> Loading model for language: {lang}...")
        talkers[lang] = TalkingPartner(language=lang)
        print(f"  -> Model for {lang} loaded.")
    print("All models loaded.")
    
    yield
    
    # Cleanup on shutdown
    talkers.clear()
    print("Application shutdown: Resources cleared.")

app = FastAPI(lifespan=lifespan)

# --- Middleware ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # WARNING: Restrict for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- API Models ---
class ChatRequest(BaseModel):
    message: str
    language: str

class SynthesizeRequest(BaseModel):
    text: str
    language: str # For future use with language-specific voices

# --- Helper Functions ---
async def stream_generator(talker: TalkingPartner, message: str):
    try:
        response, _ = talker.get_response(message)
        words = response.split()
        for word in words:
            yield f"{word} "
            await asyncio.sleep(0.05)
    except Exception as e:
        print(f"Error during response generation stream: {e}")
        yield "Sorry, an error occurred while generating the response."

# --- API Endpoints ---
@app.get("/")
async def read_root():
    return {"message": "Talkive server is running"}

@app.post("/chat")
async def chat(request: ChatRequest):
    if request.language not in talkers:
        raise HTTPException(
            status_code=400, 
            detail=f"Language '{request.language}' not supported. Supported languages are: {list(talkers.keys())}"
        )
    talker = talkers[request.language]
    return StreamingResponse(stream_generator(talker, request.message), media_type="text/event-stream")

@app.post("/synthesize")
async def synthesize(request: SynthesizeRequest):
    """
    Converts text to speech and returns the audio data.
    """
    if not voice_assistant:
        raise HTTPException(status_code=500, detail="Voice assistant not initialized.")

    audio_buffer = voice_assistant.text_to_audio(request.text)
    
    if not audio_buffer:
        raise HTTPException(status_code=500, detail="Failed to generate audio.")
    
    # Return the audio data as a response
    return Response(content=audio_buffer.read(), media_type="audio/mpeg")

