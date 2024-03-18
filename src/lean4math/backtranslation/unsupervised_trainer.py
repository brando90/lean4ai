"""

Custom Trainer class implementing backtranslation for autoformalization.
Author: Jakob Nordhagen

"""
import transformers
from transformers import GPT2LMHeadModel, GPT2Tokenizer, Trainer
import torch
import torch.nn as nn
from typing import Any, Callable, Dict, List, Union


class UnsupervisedTrainer(Trainer):
    def __init__(self, model: GPT2LMHeadModel, tokenizer: GPT2Tokenizer, *args, **kwargs):
        super().__init__(model, *args, **kwargs)
        self.tokenizer = tokenizer
        self.model = model

    def translate(self, input_texts, prompt):
        '''
        Given a batch of input texts, return the translated texts.
        '''
        # Ensure the model is in evaluation mode for generating translations
        self.model.eval()
        translated_texts = []
        for text in input_texts:
            input_text = prompt + text
            input_ids = self.tokenizer.encode(input_text, return_tensors="pt", padding=True, truncation=True).to(self.model.device)
            outputs = self.model.generate(input_ids, max_length=512, attention_mask=input_ids.ne(0))
            translated_text = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            translated_texts.append(translated_text)
        return translated_texts
        

    def training_step(self, model: nn.Module, inputs: Dict[str, Union[torch.Tensor, Any]]) -> torch.Tensor:
        '''
        Overriding HF Trainer's training step method to add custom behavior.
        '''
        model.train() # put model in train mode

        prompt_to_source = "Translate Lean code to text: "
        # prompt_to_target = "Translate text to Lean code: "

        # Decode the input_ids to texts (note: inputs are only in target language)
        target_texts = self.tokenizer.batch_decode(inputs["input_ids"], skip_special_tokens=True)

        source_translations = self.translate(target_texts, prompt_to_source)
        new_input_texts = [source_translations[i] + self.tokenizer.eos_token + target_texts[i] for i in range(len(target_texts))]
        new_inputs = self.tokenizer(new_input_texts, max_length=512, padding="max_length", truncation=True, return_tensors="pt").to(self.model.device)

        # Update inputs for training
        labels = new_inputs.input_ids.clone()
        labels[labels == self.tokenizer.pad_token_id] = -100  # Don't compute loss on padding tokens
        new_inputs["labels"] = labels

        # Call the Trainer training_step
        return super().training_step(model, new_inputs)