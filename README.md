# Talkive

Talkive is a multilingual application designed to help users learn and practice languages through two main features: Writing and Talking. The application currently supports **English, Turkish, and Spanish**.

-   **Write Mode:** Analyzes user-written text to identify and correct grammatical errors in the selected language.
-   **Talk Mode:** Acts as a conversational partner, providing real-time responses and feedback.

## Setup

### 1. Clone the repository
```bash
git clone https://github.com/hasantkbs/Talkive.git
cd talkive
```

### 2. Create and Activate Conda Environment
This project uses Conda for environment management.

```bash
# Create the environment
conda create --name talkive_env python=3.10 -y

# Activate the environment
conda activate talkive_env
```

### 3. Install Dependencies
Install the required Python packages from the `requirements.txt` file.

```bash
pip install -r requirements.txt
```

## Usage

Run the application from the project's root directory.

```bash
python app/main.py
```

Upon starting, you will be prompted to select a language. You can switch languages anytime from the main menu.

## Models Used

This project utilizes pre-trained models from Hugging Face for its core functionalities. The models are selected based on the user's language choice.

| Module     | Language | Model                                       |
|------------|----------|---------------------------------------------|
| **Writing**  | English  | `vennify/t5-base-grammar-correction`        |
|            | Turkish  | `savasy/bert-base-turkish-grammar-correction` |
|            | Spanish  | `unbabel/wmt22-comet-da`                    |
| **Talking**  | English  | `mzbac/gemma-2-9b-grammar-correction`       |
|            | Turkish  | `dbmdz/bert-base-turkish-cased`             |
|            | Spanish  | `Helsinki-NLP/opus-mt-en-es`                |

---

*This is a foundational setup. The model implementation and application logic are located in `app/write/writer.py` and `app/talk/talker.py`.*
