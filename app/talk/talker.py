from transformers import pipeline

class TalkingPartner:
    def __init__(self, language: str = 'en'):
        """
        Initializes the TalkingPartner with a pre-trained conversational AI model
        based on the selected language.

        Args:
            language: The language for conversation ('en', 'tr', or 'es').
        """
        self.language = language
        self.model_name = self._get_model_for_language(language)
        self.talk_pipeline = None

        if self.model_name:
            try:
                print(f"Initializing the {language.upper()} conversational AI model: {self.model_name}...")
                task = "text-generation" if self.language != 'es' else "translation_en_to_es"
                self.talk_pipeline = pipeline(
                    task,
                    model=self.model_name,
                    device=-1  # Use -1 for CPU
                )
                print("Model initialized successfully.")
            except Exception as e:
                print(f"Failed to initialize the model: {e}")
        else:
            print(f"No conversational model specified for language: {language}")

    def _get_model_for_language(self, lang: str) -> str:
        models = {
            'en': "mzbac/gemma-2-9b-grammar-correction",
            'tr': "dbmdz/bert-base-turkish-cased", # Using a generic Turkish model
            'es': "Helsinki-NLP/opus-mt-en-es" # Using a translation model for Spanish
        }
        return models.get(lang)

    def get_response(self, user_input: str) -> str:
        """
        Generates a response to the user's input based on the selected language.
        """
        if not self.talk_pipeline:
            return "Error: Conversational AI model is not available."

        try:
            if self.language == 'es': # Translation model expects English input
                prompt = f"Translate to Spanish: {user_input}"
            else:
                prompt = f"User: {user_input}\nAI:"

            print(f"Generating response for: '{user_input}'")
            results = self.talk_pipeline(prompt, max_length=150, num_return_sequences=1)
            
            if isinstance(results, list) and results:
                if 'generated_text' in results[0]:
                    return results[0]['generated_text']
                elif 'translation_text' in results[0]: # For Helsinki-NLP models
                    return results[0]['translation_text']
            return str(results)

        except Exception as e:
            return f"An error occurred during response generation: {e}"

