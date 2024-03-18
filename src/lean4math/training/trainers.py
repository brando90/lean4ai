from transformers import Trainer
import torch
import torch.nn as nn


class UnsupervisedTrainer(Trainer):

    def __init__(self, model: GPT2LMHeadModel, tokenizer: GPT2Tokenizer, *args, **kwargs):
        super().__init__(model, *args, **kwargs)
        self.tokenizer = tokenizer
        self.model = model

    def translate(self, input_texts, prompt):
        # Ensures the model is in evaluation mode for generating translations
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
        """
        Perform a training step on a batch of inputs.

        Args:
            model (`nn.Module`):
                The model to train.
            inputs (`Dict[str, Union[torch.Tensor, Any]]`):
                The inputs and targets of the model.

                The dictionary will be unpacked before being fed to the model. Most models expect the targets under the
                argument `labels`. Check your model's documentation for all accepted arguments.

        Return:
            `torch.Tensor`: The tensor with training loss on this batch.
        """
        model.train()

        # Example prompt for English to French and back to English
        prompt_to_source = "Translate Lean code to text: "
        prompt_to_target = "Translate text to Lean code: "

        # Decode the input_ids to texts
        input_texts = self.tokenizer.batch_decode(inputs["input_ids"], skip_special_tokens=True)

        # Backtranslation: Formal -> Informal -> Formal
        translated_to_source_texts = self.translate(input_texts, prompt_to_source)
        backtranslated_to_target_texts = self.translate(translated_to_source_texts, prompt_to_target)

        # Re-tokenize the backtranslated texts for training
        new_inputs = self.tokenizer(backtranslated_to_target_texts, return_tensors='pt', padding=True, truncation=True, max_length=512).to(self.model.device)

        # Update inputs for training
        inputs['labels'] = inputs['input_ids']
        inputs['input_ids'] = new_inputs['input_ids']
        inputs['attention_mask'] = new_inputs['attention_mask']

        # Call the original training_step
        return super().training_step(model, inputs)

