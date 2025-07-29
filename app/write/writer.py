from transformers import pipeline

class WritingCorrector:
    def __init__(self, language: str = 'en'):
        """
        Initializes the WritingCorrector with a pre-trained grammar correction model
        based on the selected language.

        Args:
            language: The language for grammar correction ('en', 'tr', or 'es').
        """
        self.language = language
        self.model_name = self._get_model_for_language(language)
        self.correction_pipeline = None
        
        if self.model_name:
            try:
                print(f"Initializing the {language.upper()} grammar correction model: {self.model_name}...")
                # For BERT-based models, the task is often 'fill-mask' or needs a custom setup.
                # For T5/generative models, it's 'text2text-generation' or 'text-generation'.
                task = self._get_pipeline_task(self.model_name)
                self.correction_pipeline = pipeline(
                    task,
                    model=self.model_name,
                    device=-1  # Use -1 for CPU
                )
                print("Model initialized successfully.")
            except Exception as e:
                print(f"Failed to initialize the model: {e}")
        else:
            print(f"No grammar correction model specified for language: {language}")

    def _get_model_for_language(self, lang: str) -> str:
        models = {
            'en': "vennify/t5-base-grammar-correction",
            'tr': "savasy/bert-base-turkish-grammar-correction",
            'es': "unbabel/wmt22-comet-da"  # Using a quality estimation model for Spanish
        }
        return models.get(lang)

    def _get_pipeline_task(self, model_name: str) -> str:
        if "bert" in model_name.lower():
            return "fill-mask" # BERT models are often used this way for grammar correction
        elif "t5" in model_name.lower():
            return "text2text-generation"
        else: # Default for other generative models like COMET
            return "text-generation"

    def correct_text(self, text: str) -> str:
        """
        Corrects the grammar of the given text based on the selected language.
        """
        if not self.correction_pipeline:
            return "Error: Grammar correction model is not available."

        try:
            # BERT-based models might require a different prompt structure
            if self.language == 'tr':
                # This is a placeholder. The actual usage might be more complex.
                # For now, we assume it can work with a simple prompt.
                prompt = text.replace("yanlış", "[MASK]") # Example for a fill-mask model
            else:
                prompt = f"grammar: {text}"

            print(f"Correcting text: '{text}'")
            results = self.correction_pipeline(prompt, max_length=1024)
            
            # The output format can vary significantly between models
            if isinstance(results, list) and results:
                if 'generated_text' in results[0]:
                    return results[0]['generated_text']
                elif 'sequence' in results[0]: # For fill-mask
                    return results[0]['sequence']
            return str(results)

        except Exception as e:
            return f"An error occurred during correction: {e}"

