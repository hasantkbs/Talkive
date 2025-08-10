# Talkive

Talkive is a multilingual AI backend designed to power language-learning applications. It provides conversational AI and text-to-speech capabilities for **English, Turkish, and Spanish**.

## Setup

### 1. Clone the repository
```bash
git clone https://github.com/hasantkbs/Talkive.git
cd talkive
```

### 2. Create and Activate Conda Environment
```bash
conda create --name talkive_env python=3.10 -y
conda activate talkive_env
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

## Running the API Server

To start the server, run the following command from the project's root directory:

```bash
python -m app.main
```

The API will be available at `http://127.0.0.1:8000`.

## API Endpoints

The server provides the following endpoints for a mobile or web client.

### 1. `POST /chat`

Provides a real-time, streaming conversational response.

-   **Request Body:**
    ```json
    {
        "message": "hello, how are you?",
        "language": "en"
    }
    ```
-   **Response:** A `text/event-stream` response that streams the AI's answer word by word.

### 2. `POST /synthesize`

Converts a string of text into speech and returns it as an audio file.

-   **Request Body:**
    ```json
    {
        "text": "This is the text to be spoken.",
        "language": "en"
    }
    ```
-   **Response:** An `audio/mpeg` file.

## Testing

This project uses `pytest` for automated testing. To run the tests, execute the following command from the root directory:

```bash
pytest -v
```

This will discover and run all tests in the `tests/` directory.

## Models Used

This project utilizes pre-trained models from Hugging Face for its core functionalities.

| Capability | Language(s) | Model Used                                   |
|------------|-------------|----------------------------------------------|
| Talking    | All         | `mistralai/Mistral-7B-Instruct-v0.1`         |
| Writing    | All         | `mistralai/Mistral-7B-Instruct-v0.1` (planned) |

---
*This is a foundational setup. The model implementation and application logic are located in `app/talk/talker.py`.*
