"""

Utilities for loading and preprocessing datasets.
Authors: Michael Souliman, Jakob Nordhagen

"""
from datasets import load_dataset, Dataset


def load_train_dataset(dataset_path):
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

def preprocess_inputs(examples, tokenizer):
    '''
    Preprocessing function to prepare inputs and labels.
    Combines the "informal" and "formal" fields into a single input.
    Format: "<informal> <sep> <formal>", where <sep> is a special token like <|endoftext|>
    '''
    inputs = [examples["nl_statement"][i] + tokenizer.eos_token + examples["formal_statement"][i] for i in range(len(examples["nl_statement"]))]
    model_inputs = tokenizer(inputs, max_length=512, padding="max_length", truncation=True, return_tensors="pt")
    
    # Labels are the input_ids with -100 assigned to tokens we don't want to include in the loss
    # Here, we want to exclude the input part from the loss so it's only calculated on the "formal" part
    labels = model_inputs.input_ids.clone()
    labels[labels == tokenizer.pad_token_id] = -100  # Don't compute loss on padding tokens
    model_inputs["labels"] = labels
    return model_inputs