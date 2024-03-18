"""

Training script implementing backtranslation for autoformalization.
Author: Jakob Nordhagen

Usage: python train.py --name <name of run>
Model saved to ./saved_models/<name>

"""
import argparse
import transformers
from transformers import GPT2LMHeadModel, GPT2Tokenizer, Trainer, TrainingArguments
from datasets import load_dataset
import torch
import torch.nn as nn
import time

from unsupervised_trainer import UnsupervisedTrainer
from dataset_utils import load_train_dataset, preprocess_inputs


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

    # Load and preprocess datasets
    dataset_path = "./data/corpus.jsonl"
    train_dataset = load_train_dataset(dataset_path)

    val_dataset_path = "hoskinson-center/proofnet"
    test_dataset_path = "hoskinson-center/proofnet"
    val_dataset = load_dataset(val_dataset_path, split='validation')
    test_dataset = load_dataset(test_dataset_path, split='test')

    val_dataset = val_dataset.map(preprocess_inputs, batched=True, remove_columns=["nl_statement", "formal_statement"], fn_kwargs={"tokenizer": tokenizer})
    test_dataset = test_dataset.map(preprocess_inputs, batched=True, remove_columns=["nl_statement", "formal_statement"], fn_kwargs={"tokenizer": tokenizer})

    # Set train arguments
    training_args = TrainingArguments(
        output_dir=f"./runs/{run_name}",  # Output directory for model predictions and checkpoints
        learning_rate=5e-5,               # Learning rate
        per_device_train_batch_size=4,    # Batch size per device during training
        per_device_eval_batch_size=4,     # Batch size for evaluation
        weight_decay=0.01,                # Strength of weight decay
        evaluation_strategy="steps",      # Evaluate every `eval_steps` steps
        eval_steps=10,
        save_total_limit=5,               # Limit the total amount of checkpoints
        num_train_epochs=3,               # Total number of training epochs
        max_steps=10,                     # Limit to x training steps
    )

    # Set up Trainer
    trainer = UnsupervisedTrainer(
        model=model, 
        args=training_args,
        train_dataset=val_dataset,
        eval_dataset=test_dataset,
        tokenizer=tokenizer
    )

    # Evaluate before training
    results = trainer.evaluate(test_dataset)
    print(results)

    # Train the model and time training
    print(f"---------Starting training. Run name: {run_name}")
    start_time = time.time()
    trainer.train()
    elapsed_time = time.time() - start_time

    # Evaluate the trained model on ProofNet test set
    results = trainer.evaluate(test_dataset)
    print(results)
    model.save_pretrained(f"./saved_models/{run_name}")

    hours, minutes, seconds = int(elapsed_time // 3600), int((elapsed_time % 3600) // 60), int(elapsed_time % 60)

    print(f"---------Finished training run {run_name}---------")
    print(f"Train time: {hours} hr, {minutes} min, {seconds} sec")
    print(f"ProofNet eval loss: {results['eval_loss']}. Model saved to ./saved_models/{run_name}")


if __name__ == '__main__':
    main()