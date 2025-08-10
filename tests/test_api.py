from fastapi.testclient import TestClient
from app.api import app

client = TestClient(app)

def test_read_root():
    """Test the root endpoint to ensure the server is running."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Talkive server is running"}

def test_chat_endpoint_success():
    """Test the /chat endpoint with a valid request."""
    response = client.post("/chat", json={"message": "hello", "language": "en"})
    assert response.status_code == 200
    assert "text/event-stream" in response.headers["content-type"]
    # We can also check if the stream is not empty
    assert len(response.content) > 0

def test_chat_endpoint_unsupported_language():
    """Test the /chat endpoint with an unsupported language."""
    response = client.post("/chat", json={"message": "hello", "language": "xx"})
    assert response.status_code == 400
    assert "not supported" in response.json()["detail"]

def test_synthesize_endpoint_success():
    """Test the /synthesize endpoint with a valid request."""
    # This test can be slow as it actually generates audio
    response = client.post("/synthesize", json={"text": "hello world", "language": "en"})
    assert response.status_code == 200
    assert response.headers["content-type"] == "audio/mpeg"
    assert len(response.content) > 0

def test_synthesize_with_empty_text():
    """Test the /synthesize endpoint with empty text."""
    response = client.post("/synthesize", json={"text": "", "language": "en"})
    # The API should return an error if the text is empty and audio cannot be generated
    assert response.status_code == 500 # Based on current implementation
    assert "Failed to generate audio" in response.json()["detail"]
