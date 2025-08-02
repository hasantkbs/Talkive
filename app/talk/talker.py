# -*- coding: utf-8 -*-
import time
import os
import torch
from transformers import pipeline, AutoTokenizer

class TalkingPartner:
    def __init__(self, language: str = 'en'):
        self.language = language
        self.model_name = self._get_model_for_language(language)
        self.conversation_pipeline = None
        self.conversation_history = None

        # Cihazı otomatik olarak belirle (MPS > CPU)
        if torch.backends.mps.is_available():
            self.device = "mps"
        else:
            self.device = "cpu"
        print(f"Device set to use {self.device}")

        if self.model_name:
            try:
                self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
                if self.tokenizer.pad_token is None:
                    self.tokenizer.pad_token = self.tokenizer.eos_token
                self.tokenizer.padding_side = "left"
                hf_token = os.environ.get("HF_TOKEN")
                self.conversation_pipeline = pipeline(
                    "text-generation",
                    model=self.model_name,
                    tokenizer=self.tokenizer,
                    token=hf_token,
                    device=self.device,  # Belirlenen cihazı kullan
                    max_new_tokens=250,
                    do_sample=True,
                    temperature=0.7,
                    top_k=50,
                    top_p=0.95,
                    pad_token_id=self.tokenizer.eos_token_id
                )
                self.reset_conversation()
            except Exception as e:
                pass

    def _get_model_for_language(self, lang: str) -> str:
        models = {
            'en': "mistralai/Mistral-7B-Instruct-v0.1",
            'tr': "mistralai/Mistral-7B-Instruct-v0.1",
            'es': "mistralai/Mistral-7B-Instruct-v0.1"
        }
        return models.get(lang)

    def reset_conversation(self):
        system_prompt = "You are Talkive, a friendly language partner from Algorix. Your main goal is to have a natural conversation. Your name is Talkive. If the user makes a grammar mistake, correct it and then continue the conversation."
        
        self.conversation_history = [
            {
                "role": "system",
                "content": system_prompt
            }
        ]

    def get_response(self, user_input: str) -> tuple[str, int]:
        if not self.conversation_pipeline:
            return "Error: Conversational AI model is not available.", 0

        try:
            start_time = time.time()

            # Her istek için geçici bir konuşma geçmişi oluştur.
            # Bu, paylaşılan state sorununu çözer.
            # Sistem mesajını al ve kullanıcı mesajını ekle.
            temp_conversation = [
                self.conversation_history[0], # Sistem mesajını kopyala
                {"role": "user", "content": user_input}
            ]

            prompt = self.tokenizer.apply_chat_template(
                temp_conversation,
                tokenize=False,
                add_generation_prompt=True
            )

            results = self.conversation_pipeline(prompt)
            response = results[0]['generated_text'].replace(prompt, "").strip()
            
            # ÖNEMLİ: Ortak geçmişi GÜNCELLEME. Sadece lokal yanıtı döndür.
            # self.conversation_history.append({"role": "assistant", "content": response})

            end_time = time.time()
            duration_ms = int((end_time - start_time) * 1000)
            
            return response, duration_ms
        except Exception as e:
            return f"An error occurred during response generation: {e}", 0
0

