"""

Training script for fine-tuning an LLM on a custom dataset.
Author: Jakob Nordhagen

Usage: python finetune.py --name <name of run> --model <name of HF model> --dataset <path to HF dataset>
Model saved to ./finetune_models/<name>

"""
import argparse
import transformers
from transformers import AutoTokenizer, AutoModelForCausalLM, GPT2LMHeadModel, GPT2Tokenizer, Trainer, TrainingArguments
from datasets import load_dataset
import torch
import torch.nn as nn
import time

from dataset_utils import preprocess_inputs, preprocess_inputs_custom


def main():
    torch.cuda.empty_cache()

    # Get run name and model from args
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", type=str) 
    parser.add_argument("--model", type=str)
    # parser.add_argument("--dataset", type=str)
    args = parser.parse_args()
    run_name = args.name
    model_name = args.model

    # Initialize model and tokenizer
    if model_name == 'gpt2':
        model = GPT2LMHeadModel.from_pretrained(model_name)
        tokenizer = GPT2Tokenizer.from_pretrained(model_name)
    else:
        model = AutoModelForCausalLM.from_pretrained(model_name)
        tokenizer = AutoTokenizer.from_pretrained(model_name)

    tokenizer.add_special_tokens({'pad_token': '[PAD]'})
    model.resize_token_embeddings(len(tokenizer))

    # Load and preprocess datasets
    # train_dataset_path = "../dataset_gen/lean_train.jsonl"
    # train_dataset = load_dataset("json", data_files=train_dataset_path)

    train_dataset_path = "AI4M/gpt-4fp_minif2f_mix"
    train_dataset = load_dataset(train_dataset_path, split='train')

    val_dataset = load_dataset("hoskinson-center/proofnet", split='validation')
    test_dataset = load_dataset("hoskinson-center/proofnet", split='test')

    train_dataset = train_dataset.map(preprocess_inputs_custom, batched=True, remove_columns=["informal", "formal"], fn_kwargs={"tokenizer": tokenizer})
    val_dataset = val_dataset.map(preprocess_inputs, batched=True, remove_columns=["nl_statement", "formal_statement"], fn_kwargs={"tokenizer": tokenizer})
    test_dataset = test_dataset.map(preprocess_inputs, batched=True, remove_columns=["nl_statement", "formal_statement"], fn_kwargs={"tokenizer": tokenizer})

    # Set train arguments
    training_args = TrainingArguments(
        output_dir=f"./runs/{run_name}",  # Output directory for model predictions and checkpoints
        learning_rate=1e-5,               # Learning rate
        per_device_train_batch_size=2,    # Batch size per device during training
        per_device_eval_batch_size=2,     # Batch size for evaluation
        weight_decay=0.01,                # Strength of weight decay
        evaluation_strategy="epoch",      # Evaluate every `eval_steps` steps or every epoch
        # eval_steps=20,
        save_total_limit=5,               # Limit the total amount of checkpoints
        num_train_epochs=3,               # Total number of training epochs
        # max_steps=10,                     # Limit to x training steps
    )

    # Set up Trainer
    trainer = Trainer(
        model=model, 
        args=training_args,
        train_dataset=train_dataset, 
        eval_dataset=test_dataset,
        tokenizer=tokenizer
    )

    # Evaluate before training
    results = trainer.evaluate(test_dataset)
    print(results)

    # Train the model and time training
    print(f"---------Starting training {model_name}. Run name: {run_name}---------")
    start_time = time.time()
    trainer.train()
    elapsed_time = time.time() - start_time

    # Evaluate the trained model on ProofNet test set
    results = trainer.evaluate(test_dataset)
    print(results)
    model.save_pretrained(f"./finetune_models/{run_name}")

    hours, minutes, seconds = int(elapsed_time // 3600), int((elapsed_time % 3600) // 60), int(elapsed_time % 60)

    print(f"---------Finished training run {run_name}---------")
    print(f"Train time: {hours} hr, {minutes} min, {seconds} sec")
    print(f"ProofNet eval loss: {results['eval_loss']}. Model saved to ./finetune_models/{run_name}")


if __name__ == '__main__':
    main()