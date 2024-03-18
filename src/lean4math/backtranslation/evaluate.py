"""

Script for evaluating already trained and saved HF models
Author: Jakob Nordhagen

"""
import argparse
from transformers import GPT2LMHeadModel, GPT2Tokenizer, Trainer, TrainingArguments
from datasets import load_dataset, Dataset
from dataset_utils import NlFormalDataset, data_collator
import torch
import torch.nn as nn
from torch.nn import CrossEntropyLoss
from typing import Any, Callable, Dict, List, Union
from unsupervised_trainer import UnsupervisedTrainer

def main():
    # Get model name from args
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", type=str) 
    args = parser.parse_args()
    name = args.name
    model_path = f"saved_models/{name}"

    model = GPT2LMHeadModel.from_pretrained(model_path)
    tokenizer = GPT2Tokenizer.from_pretrained('gpt2')

    # Ensure that the tokenizer does not split on spaces within tokens
    tokenizer.add_special_tokens({'pad_token': '[PAD]'})
    model.resize_token_embeddings(len(tokenizer))

    # Dataset
    test_dataset = load_dataset('hoskinson-center/proofnet')

    # Preprocessing function to prepare inputs and labels (written by Michael)
    def preprocess_function(examples):
        # Combine the "informal" and "formal" fields into a single input
        # Format: "<informal> <sep> <formal>", where <sep> is a special token like <|endoftext|>
        inputs = [examples["nl_statement"][i] + tokenizer.eos_token + examples["formal_statement"][i] for i in range(len(examples["nl_statement"]))]
        model_inputs = tokenizer(inputs, max_length=512, padding="max_length", truncation=True, return_tensors="pt")
        
        # Labels are the input_ids with -100 assigned to tokens we don't want to include in the loss
        # Here, we want to exclude the input part from the loss so it's only calculated on the "formal" part
        labels = model_inputs.input_ids.clone()
        labels[labels == tokenizer.pad_token_id] = -100  # Don't compute loss on padding tokens
        model_inputs["labels"] = labels
        return model_inputs

    test_dataset = test_dataset.map(preprocess_function, batched=True, remove_columns=["nl_statement", "formal_statement"])

    # Training arguments
    training_args = TrainingArguments(
        output_dir="./results",          # Output directory for model predictions and checkpoints
        evaluation_strategy="epoch",     # Evaluate each `logging_steps`
        learning_rate=5e-5,              # Learning rate
        per_device_train_batch_size=4,   # Batch size per device during training
        per_device_eval_batch_size=4,    # Batch size for evaluation
        weight_decay=0.01,               # Strength of weight decay
        save_total_limit=3,              # Limit the total amount of checkpoints
        num_train_epochs=3,              # Total number of training epochs
    )

    # Set up Trainer
    trainer = UnsupervisedTrainer(
        model=model, 
        args=training_args,
        train_dataset=test_dataset,
        eval_dataset=test_dataset,
        tokenizer=tokenizer
    )

    # Run eval
    results = trainer.evaluate(test_dataset)
    print(results)

if __name__ == '__main__':
    main()