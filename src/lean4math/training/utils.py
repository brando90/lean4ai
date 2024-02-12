
from itertools import chain
import math
import random
from typing import Optional, Any

import torch

import datasets
from datasets import load_dataset, interleave_datasets

from transformers import PreTrainedTokenizer, AutoTokenizer, AutoModelForCausalLM, Trainer, TrainingArguments, AutoConfig
from transformers.testing_utils import CaptureLogger
from transformers import GPT2Tokenizer

def get_weight_norms(model: torch.nn.Module, verbose: bool = False) -> None:
    """
    Prints the L1 norm of the weights of each module in the given PyTorch model.

    Args:
    model (nn.Module): The PyTorch model whose weight norms are to be printed.

    Returns:
    None
    """
    total_weight_norm: float = 0.0
    for name, module in model.named_modules():
        # Check if the module has the 'weight' attribute
        if hasattr(module, 'weight') and isinstance(module.weight, torch.Tensor):
            # Calculate the L1 norm of the weights
            w_norm: float = module.weight.norm(1).item()
            total_weight_norm += w_norm
            if verbose:
                print(f"Norm of weights in module {name}: {w_norm}")
    return total_weight_norm

def get_column_names(dataset, 
                    #   split: str = 'train',
                      method: str = 'keys', 
                      streaming: bool = True,
                      ):
    if method == 'features':
        # column_names = list(dataset[spit].features)
        column_names = list(dataset.features)
    elif method == 'keys':
        batch = get_data_from_hf_dataset(dataset, streaming=streaming, batch_size=1)
        column_names = next(iter(batch)).keys()
        # column_names = next(iter(dataset)).keys()
    else:
        raise ValueError(f"method {method} not supported")
    return column_names


def get_data_from_hf_dataset(dataset, 
                             streaming: bool = True, 
                             batch_size: int = 4, 
                            #  shuffle: bool= False, # shuffle is better but slower afaik
                            #  seed: int = 0, 
                            #  buffer_size: int = 500_000,
                             ):
    """ Gets data from a HF dataset, it's usually an iterator object e.g., some ds.map(fn, batched=True, remove_columns=remove_columns) has been applied. 
    Handles both streaming and non-streaming datasets, take for streaming and select for non-streaming.
    """
    # sample_data = dataset.select(range(batch_size)) if not isinstance(dataset, datasets.iterable_dataset.IterableDataset) else dataset.take(batch_size)
    batch = dataset.take(batch_size) if streaming else dataset.select(random.sample(list(range(len(dataset))), batch_size))
    return batch

def raw_dataset_2_lm_data(raw_dataset, 
                          tokenizer, 
                          block_size: int, 
                          desired_dataset_column: str = 'text',
                          method_to_remove_columns: str = 'keys',
                          debug: bool = False, 
                          streaming: bool = True,
                          batch_size: int = 2,
                          fromat: str = 'torch',
                          ):
    """ Get lm data set but note it uses the grou_texts function which concatenates all tests into a single sequence according to block size (some seq length e.g., max seq length)."""
    raw_dataset = raw_dataset.with_format(fromat)
    remove_columns = get_column_names(raw_dataset, method_to_remove_columns)  # remove all keys that are not tensors to avoid bugs in collate function in task2vec's pytorch data loader
    # - Get tokenized train data set
    # Note: Setting `batched=True` in the `dataset.map` function of Hugging Face's datasets library processes the data in batches rather than one item at a time, significantly speeding up the tokenization and preprocessing steps.
    tokenize_function = lambda examples: tokenizer(examples[desired_dataset_column])
    tokenized_train_datasets = raw_dataset.map(tokenize_function, batched=True, remove_columns=remove_columns)
    _group_texts = lambda examples : group_texts(examples, block_size)
    # - Get actual data set for lm training (in this case each seq is of length block_size, no need to worry about pad = eos since we are filling each sequence)
    lm_dataset = tokenized_train_datasets.map(_group_texts, batched=True)
    if debug:
        batch = get_data_from_hf_dataset(lm_dataset, streaming=streaming, batch_size=batch_size)
        print(f'{len(next(iter(batch))["input_ids"])=}')
        assert all(len(data_dict['input_ids']) == block_size for data_dict in iter(batch)), f'Error, some seq in batch are not of length {block_size}'
    return lm_dataset

def group_texts(examples, # if batched=True it's a dict of input_ids, attention_mask, labels of len(examples['input_ids']) = 1000 
                block_size: int,  # 4096, 1024
                ):
    """
    tokenizer = ...obtained from your model... 
    tokenize_function = lambda examples: tokenize_function(examples, tokenizer=tokenizer) 
    tokenized_datasets = raw_datasets.map(tokenize_function, batched=True, remove_columns=column_names)

    if used as above then examples is
    examples = {'input_ids': [[...], [...], ...], 'attention_mask': [[...], [...], ...], 'labels': [[...], [...], ...]]]}
    examples.keys() = dict_keys(['input_ids', 'attention_mask'])
    type(examples) = <class 'dict'>
    type(examples['input_ids']) = <class 'list'>
    len(examples['input_ids']) = 1000  # if batched=True

    # Note that with `batched=True`, this map processes 1,000 texts together, so group_texts throws away a remainder
    # for each of those groups of 1,000 texts. You can adjust that batch_size here but a higher value might be slower
    # to preprocess.
    #
    # To speed up this part, we use multiprocessing. See the documentation of the map method for more information:
    # https://huggingface.co/docs/datasets/package_reference/main_classes.html#datasets.Dataset.map    
    """
    # Concatenate all texts.
    # concatenated_examples = {k: list(chain(examples[k])) for k in examples.keys()}
    concatenated_examples = {k: examples[k].tolist() for k in examples.keys()}
    total_length = len(concatenated_examples[list(examples.keys())[0]])
    # We drop the small remainder, and if the total_length < block_size  we exclude this batch and return an empty dict.
    # We could add padding if the model supported it instead of this drop, you can customize this part to your needs.
    total_length = (total_length // block_size) * block_size  # rounds down
    # Split by chunks of max_len.
    if total_length > 0:
        result = {
            k: [t[i : i + block_size] for i in range(0, total_length, block_size)]
            for k, t in concatenated_examples.items()
        }
    else:
        result = concatenated_examples
    result["labels"] = result["input_ids"].copy()
    return result

def raw_dataset_2_lm_data(raw_dataset, 
                          tokenizer, 
                          block_size: int, 
                          desired_dataset_column: list[str] = ['formal', 'informal'],
                          method_to_remove_columns: str = 'keys',
                          debug: bool = False, 
                          streaming: bool = True,
                          batch_size: int = 2,
                          fromat: str = 'torch',
                          ):
    """ Get lm data set but note it uses the grou_texts function which concatenates all tests into a single sequence according to block size (some seq length e.g., max seq length)."""
    raw_dataset = raw_dataset.with_format(fromat)
    remove_columns = get_column_names(raw_dataset, method_to_remove_columns)  # remove all keys that are not tensors to avoid bugs in collate function in task2vec's pytorch data loader
    # - Get tokenized train data set
    # Note: Setting `batched=True` in the `dataset.map` function of Hugging Face's datasets library processes the data in batches rather than one item at a time, significantly speeding up the tokenization and preprocessing steps.
    print(desired_dataset_column)
    if isinstance(desired_dataset_column, str):
        tokenize_function = lambda examples: tokenizer(examples[desired_dataset_column])
    if len(desired_dataset_column) == 2:
        def tokenize_function(examples):
            data: str = ''
            print("Desired", desired_dataset_column)
            print("Actual", examples.keys())
            for key in desired_dataset_column:
                data += f'{data} {key}: {examples[key]}'
            data = data[:1024]
            print(len(data))
            x = tokenizer(data)
            return x
    else:
        raise ValueError(f"desired_dataset_column {desired_dataset_column=} not supported")
    tokenized_train_datasets = raw_dataset.map(tokenize_function, batched=True, remove_columns=remove_columns)
    _group_texts = lambda examples : group_texts(examples, block_size)
    # - Get actual data set for lm training (in this case each seq is of length block_size, no need to worry about pad = eos since we are filling each sequence)
    lm_dataset = tokenized_train_datasets.map(_group_texts, batched=True)
    if debug:
        batch = get_data_from_hf_dataset(lm_dataset, streaming=streaming, batch_size=batch_size)
        print(f'{len(next(iter(batch))["input_ids"])=}')
        assert all(len(data_dict['input_ids']) == block_size for data_dict in iter(batch)), f'Error, some seq in batch are not of length {block_size}'
    return lm_dataset

def get_data_from_hf_dataset(dataset, 
                            streaming: bool = True, 
                            batch_size: int = 4, 
                        #  shuffle: bool= False, # shuffle is better but slower afaik
                        #  seed: int = 0, 
                        #  buffer_size: int = 500_000,
                            ):
    """ Gets data from a HF dataset, it's usually an iterator object e.g., some ds.map(fn, batched=True, remove_columns=remove_columns) has been applied. 
    Handles both streaming and non-streaming datasets, take for streaming and select for non-streaming.
    """
    # sample_data = dataset.select(range(batch_size)) if not isinstance(dataset, datasets.iterable_dataset.IterableDataset) else dataset.take(batch_size)
    batch = dataset.take(batch_size) if streaming else dataset.select(random.sample(list(range(len(dataset))), batch_size))
    return batch

def eval_hf(trainer: Trainer, path: str, name: str, split: str, max_eval_samples: Any = 'Unknown_Eval_Max_Samples',):
    metrics = trainer.evaluate()
    try:
        perplexity = math.exp(metrics["eval_loss"])
    except OverflowError:
        perplexity = float("inf")
    metrics["perplexity"] = perplexity
    path = path.replace('/', '_')  # needed only when saving results
    print(f'Eval metrics {path} {name} {split} {max_eval_samples}: {metrics=}')
    trainer.log_metrics(f"eval_{path}_{name}_{split}_{max_eval_samples}", metrics)  # display metrics
    trainer.save_metrics(f"eval_{path}_{name}_{split}_{max_eval_samples}", metrics)
    return metrics

def eval_hf_with_subsample(path, name, split, model, tokenizer, block_size, output_dir, 
                           max_eval_samples: int = 1024,
                           streaming: bool = True, 
                           verbose: bool = True,
                           print_str: Optional[str] = None,
                           ):
    eval_dataset = load_dataset(path, name, streaming=streaming, split=split).with_format("torch") 
    eval_dataset2 = raw_dataset_2_lm_data(eval_dataset, tokenizer, block_size, desired_dataset_column=["nl_statement", "formal_statement"])
    if max_eval_samples is None:
        eval_batch2 = eval_dataset2 
    else:
        eval_batch2 = eval_dataset2.take(max_eval_samples)
    print(f'Saving eval results at: {output_dir=}') # The output directory where the model predictions and checkpoints will be written.
    eval_args = TrainingArguments(output_dir=output_dir, fp16=False, bf16=torch.cuda.get_device_capability(torch.cuda.current_device())[0] >= 8)
    trainer = Trainer(model=model, args=eval_args, train_dataset=None, eval_dataset=eval_batch2)
    metrics = eval_hf(trainer, path, name, split,)
    if verbose:
        print(f'----> {path=}, {name=}, {split=}, {metrics=}, {max_eval_samples=}')
    if print_str is not None:
        print(print_str)
    return metrics