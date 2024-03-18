"""

Script for evaluating already trained and saved HF models
Author: Jakob Nordhagen

"""
import argparse
from transformers import GPT2LMHeadModel, GPT2Tokenizer, Trainer, TrainingArguments
from datasets import load_dataset
from dataset_utils import preprocess_inputs
from unsupervised_trainer import UnsupervisedTrainer
import time

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
    test_dataset = load_dataset('hoskinson-center/proofnet', split='test')
    test_dataset = test_dataset.map(preprocess_inputs, batched=True, remove_columns=["nl_statement", "formal_statement"], fn_kwargs={"tokenizer": tokenizer})

    # Training arguments
    training_args = TrainingArguments(
        output_dir='results',
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

    print(f"---------Starting evaluation on model {name}")
    start_time = time.time()
    results = trainer.evaluate(test_dataset)
    elapsed_time = time.time() - start_time
    print(results)
    hours, minutes, seconds = int(elapsed_time // 3600), int((elapsed_time % 3600) // 60), int(elapsed_time % 60)

    print(f"---------Finished eval---------")
    print(f"Time elapsed: {hours} hr, {minutes} min, {seconds} sec")
    print(f"ProofNet eval loss: {results['eval_loss']}")

if __name__ == '__main__':
    main()