
from fastapi import FastAPI
from pydantic import BaseModel
from app.talk.talker import TalkingPartner
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

# Modelleri hafızada tutmak için bir sözlük
talkers = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Sunucu başlangıcında çalışacak kod
    print("Application startup: Loading models...")
    supported_languages = ['en', 'tr', 'es']
    for lang in supported_languages:
        print(f"  -> Loading model for language: {lang}...")
        talkers[lang] = TalkingPartner(language=lang)
        print(f"  -> Model for {lang} loaded.")
    print("All models loaded.")
    yield
    # Sunucu kapanırken çalışacak kod (temizlik)
    talkers.clear()
    print("Application shutdown: Models cleared.")

app = FastAPI(lifespan=lifespan)

# CORS Middleware Ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme için tüm kaynaklara izin ver
    allow_credentials=True,
    allow_methods=["*"],  # Tüm metotlara izin ver (GET, POST, vb.)
    allow_headers=["*"],  # Tüm başlıklara izin ver
)

class ChatRequest(BaseModel):
    message: str
    language: str

@app.post("/chat")
def chat(request: ChatRequest):
    # Önceden yüklenmiş modeli sözlükten al
    talker = talkers.get(request.language)
    if not talker:
        return {"error": f"Language '{request.language}' not supported or model not loaded."}
    
    response, _ = talker.get_response(request.message)
    return {"response": response}
