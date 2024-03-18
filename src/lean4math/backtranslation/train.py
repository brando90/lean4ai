"""

Training script implementing backtranslation for autoformalization.
Author: Jakob Nordhagen

Usage: python train.py --name <name of run>
Model saved to ./saved_models/<name>

"""
import argparse
import transformers
from transformers import GPT2LMHeadModel, GPT2Tokenizer, Trainer, TrainingArguments
from datasets import load_dataset, Dataset
import torch
import torch.nn as nn
from unsupervised_trainer import UnsupervisedTrainer
import time

def init_train_dataset(dataset_path):
    """
    Loads and preprocesses the train dataset (LeanDojo Benchmark 4).
    I believe this is just mathlib4.
    Dataset download link https://zenodo.org/records/10114185
    """
    dataset = load_dataset('json', data_files={'train': dataset_path}, split='train')
    # Parse theorems out of nested JSON structure
    theorems = [thm['code'] for lst in dataset['premises'] for thm in lst if thm['code'].startswith('theorem')]
    train_dataset = Dataset.from_dict({'formal': theorems})
    return train_dataset

def main():
    # Get model name from args
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", type=str) 
    args = parser.parse_args()
    run_name = args.name

    # Initialize model and tokenizer
    model_name = 'gpt2'
    model = GPT2LMHeadModel.from_pretrained(model_name, pad_token_id=50256)
    tokenizer = GPT2Tokenizer.from_pretrained(model_name)
    tokenizer.add_special_tokens({'pad_token': '[PAD]'})
    model.resize_token_embeddings(len(tokenizer))

    # Get datasets
    dataset_path = "./data/corpus.jsonl"
    train_dataset = init_train_dataset(dataset_path)

    val_dataset_path = "hoskinson-center/proofnet"
    test_dataset_path = "hoskinson-center/proofnet"

    dataset_val = load_dataset(val_dataset_path, split='validation')
    dataset_test = load_dataset(test_dataset_path, split='test')

    # Preprocessing function to prepare inputs and labels
    # Written by Michael Souliman
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

    # Apply preprocessing function
    val_dataset = dataset_val.map(preprocess_function, batched=True, remove_columns=["nl_statement", "formal_statement"])
    test_dataset = dataset_test.map(preprocess_function, batched=True, remove_columns=["nl_statement", "formal_statement"])

    training_args = TrainingArguments(
        output_dir=f"./runs/{run_name}",  # Output directory for model predictions and checkpoints
        evaluation_strategy="epoch",      # Evaluate each `logging_steps`
        learning_rate=5e-5,               # Learning rate
        per_device_train_batch_size=4,    # Batch size per device during training
        per_device_eval_batch_size=4,     # Batch size for evaluation
        weight_decay=0.01,                # Strength of weight decay
        save_total_limit=3,               # Limit the total amount of checkpoints
        num_train_epochs=3,               # Total number of training epochs
        max_steps=100,                    # Limit to x training steps
    )

    # Set up Trainer
    trainer = UnsupervisedTrainer(
        model=model, 
        args=training_args,
        train_dataset=val_dataset,
        eval_dataset=test_dataset,
        tokenizer=tokenizer
    )

    # Run experiments
    results = trainer.evaluate(test_dataset)
    print(results)

    # Train the model and time training
    print(f"---------Starting training. Run name: {run_name}")
    start_time = time.time()
    trainer.train()
    elapsed_time = time.time() - start_time

    # Evaluate the model on ProofNet test set
    results = trainer.evaluate(test_dataset)
    print(results)
    model.save_pretrained(f"./saved_models/{run_name}")

    print(f"---------Finished training run {run_name}. Train time: \
        {int(elapsed_time // 3600)} hours, \
        {int((elapsed_time % 3600) // 60)} minutes, \
        {int(elapsed_time % 60)} seconds")
    print(f"ProofNet eval loss: {results['eval_loss']}. Model saved to ./saved_models/{run_name}")


if __name__ == '__main__':
    main()