"""
Training script for autoformalization, using HuggingFace Trainer API
"""

from pathlib import Path
from typing import Callable
import datasets
from datasets import load_dataset, interleave_datasets
import torch
import transformers
from transformers import GPT2LMHeadModel, GPT2Tokenizer, PreTrainedTokenizer, AutoTokenizer, Trainer, TrainingArguments, AutoConfig, AutoModelForCausalLM, BitsAndBytesConfig
import math
import os
import random
import datetime
import wandb
import ndjson

import sys
sys.path = [''] + sys.path

from utils import eval_hf_with_subsample, get_column_names, get_data_from_hf_dataset, group_texts, raw_dataset_2_lm_data, get_weight_norms
from dataset import NlFormalDataset, data_collator

# -- Experiments 

def train():
    """
    Main training method
    """
    # Set params
    torch.cuda.empty_cache()
    probabilities = []
    data_mixture_name = None
    streaming = True
    data_files = [None]
    seed = 0
    split = 'train'
    shuffle = False
    max_length = 1024  # gpt2 context length
    report_to = 'none'  # safest default
    num_epochs = 1
    num_tokens_trained = None
    pretrained_model_name_or_path = 'gpt2'
    max_steps = 2
    num_batches = 1
    batch_size = 4
    gradient_accumulation_steps = 8 
    learning_rate = 1e-4
    optim='paged_adamw_32bit'
    weight_decay=0.1
    warmup_ratio=0.01
    lr_scheduler_type='cosine' 
    gradient_checkpointing = True
    print(f'{batch_size=} {gradient_accumulation_steps=} {gradient_checkpointing=} {num_epochs=}')

    # Set up Wandb
    mode = 'dryrun'
    CUDA_VISIBLE_DEVICES = os.environ.get('CUDA_VISIBLE_DEVICES')
    print(f"CUDA_VISIBLE_DEVICES = {CUDA_VISIBLE_DEVICES}")
    num_tokens_trained = max_steps * batch_size * max_length * num_batches 
    print(f'{num_tokens_trained=}')
    today = datetime.datetime.now().strftime('%Y-m%m-d%d-t%Hh_%Mm_%Ss')
    current_tmux_session = os.environ.get("TMUX", "").split(",")[-1]
    run_name = f'beyond scale: ({today=} {pretrained_model_name_or_path=} {data_files=} {max_steps=} {batch_size=} {num_tokens_trained=} {gradient_accumulation_steps=} {optim=} {learning_rate=} {max_length=} {weight_decay=} {warmup_ratio=} {CUDA_VISIBLE_DEVICES=} {current_tmux_session=})'
    print(f'\n---> {run_name=}\n')

    debug = mode == 'dryrun' 
    run = wandb.init(mode=mode, project="lean4ai", name=run_name, save_code=True)
    print(f'{run.url=}')
    wandb.config.update({"today": today, 'probabilities': probabilities, 'batch_size': batch_size, 'debug': debug, 'data_mixture_name': data_mixture_name, 'streaming': streaming, 'data_files': data_files, 'seed': seed, 'pretrained_model_name_or_path': pretrained_model_name_or_path, 'num_epochs': num_epochs, 'gradient_accumulation_steps': gradient_accumulation_steps, 'CUDA_VISIBLE_DEVICES': CUDA_VISIBLE_DEVICES, "current_tmux_session": current_tmux_session})
    output_dir = Path(f'~/data/results_{today}/').expanduser() if not debug else Path(f'~/data/results/').expanduser()
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f'{output_dir=}')
    print(f'{debug=}')
    print(f'{wandb.config=}')

    # Load model and tokenizer  
    print(f'{pretrained_model_name_or_path=}')
    if pretrained_model_name_or_path == 'gpt2':
        tokenizer = GPT2Tokenizer.from_pretrained(pretrained_model_name_or_path, max_length=1024)
        if tokenizer.pad_token_id is None:
            tokenizer.pad_token = tokenizer.eos_token
            print(f'{tokenizer.pad_token=}')
        print(f'{tokenizer.eos_token=}')
        print(f'{tokenizer.eos_token_id=}')
        model = GPT2LMHeadModel.from_pretrained(pretrained_model_name_or_path)
        device = torch.device(f"cuda:{0}" if torch.cuda.is_available() else "cpu")
        model = model.to(device)
        block_size: int = tokenizer.model_max_length
        print(f'{block_size=}\n')
    elif 'Llama-2' in pretrained_model_name_or_path or 'Mistral' in pretrained_model_name_or_path:
        torch_dtype = torch.bfloat16 if torch.cuda.get_device_capability(torch.cuda.current_device())[0] >= 8 else torch.float32
        model = AutoModelForCausalLM.from_pretrained(pretrained_model_name_or_path, trust_remote_code=True, torch_dtype=torch_dtype, use_auth_token=True)
        tokenizer = AutoTokenizer.from_pretrained(pretrained_model_name_or_path, padding_side="right", use_fast=False, trust_remote_code=True, use_auth_token=True)
        tokenizer.pad_token = tokenizer.eos_token if tokenizer.pad_token_id is None else tokenizer.pad_token
        print(f'{tokenizer.pad_token=} {tokenizer.eos_token_id=}')
        # get context length for setting max length for training
        if hasattr(model.config, "context_length"):
            print("Context length:", model.config.context_length)
            max_length = model.config.context_length
        else:
            max_length = 4096
        block_size = 4096
        print(f'{block_size=}')
    print("Number of parameters:", sum(p.numel() for p in model.parameters()))
    print(f"Total weight norm: {get_weight_norms(model)=}")
    print(f'{torch.cuda.device_count()=} (makes sure GPUs are visible and accesible to Pytorch.)')
    print(f'Model is currently on: {next(iter(model.parameters())).device=}')
    print(f'Model is currently on: {next(iter(model.parameters())).dtype=}')
    # Sanity check -- is loss random? lnV = -ln(1/V) = -ln(1/50257) = 10.82 since CE = avg_i v_i * ln(1/p_i) but only one token is right so vi = 1 for some i so CE = ln(1/p_i)
    print(f'vocab_size: {len(tokenizer)=} \nExpected random loss: {math.log(len(tokenizer))=}')
    print(f"CUDA version: {torch.version.cuda=}")
    print(f'{output_dir=}')
    eval_hf_with_subsample('hoskinson-center/proofnet', None, 'validation', model, tokenizer, block_size, output_dir, max_eval_samples=2, print_str='> Eval ProofNet mdl before training')
    
    # -- Get train data set
    with open('../data/proofnet_train.jsonl') as f:
        train_data = ndjson.load(f)
    train_dataset = NlFormalDataset(train_data, tokenizer, max_length)

    # -- max steps manually decided depending on how many tokens we want to train on
    per_device_train_batch_size = batch_size
    print(f'{per_device_train_batch_size=}')
    print(f'{num_epochs=} {max_steps=}')
    print(f'{output_dir=}')

    training_args = TrainingArguments(
        output_dir=output_dir,
        max_steps=max_steps, 
        per_device_train_batch_size=per_device_train_batch_size,
        gradient_accumulation_steps=gradient_accumulation_steps, 
        gradient_checkpointing = gradient_checkpointing, 
        optim=optim,
        warmup_ratio=warmup_ratio, 
        weight_decay=weight_decay, 
        learning_rate = learning_rate, 
        max_grad_norm=1.0,
        lr_scheduler_type=lr_scheduler_type,
        logging_dir=Path('~/data/maf/logs').expanduser(),
        save_steps=max_steps//3,  
        logging_first_step=True,
        logging_steps=1,
        remove_unused_columns=False, 
        report_to=report_to, 
        fp16=False,  # never ever set to True
        bf16=torch.cuda.get_device_capability(torch.cuda.current_device())[0] >= 8,  # if >= 8 ==> brain float 16 available or set to True if you always want fp32
    )
    print(f'{pretrained_model_name_or_path=}\n{optim=}\n{learning_rate=}')

    # -- Init Trainer
    print(f'{train_dataset=}')
    trainer: Trainer = Trainer(
        model=model,
        args=training_args,  
        train_dataset=train_dataset,
    )

    # - Train
    trainer.train()
    trainer.save_model(output_dir=output_dir)

    # --- Evaluation, NOTE: we are evaluating at the end not during training
    print('\n---- Evaluate model on ProofNet')
    max_eval_samples = None
    metrics = eval_hf_with_subsample('hoskinson-center/proofnet', None, 'validation', model, tokenizer, block_size, output_dir, max_eval_samples=max_eval_samples) 
    print(f'ProofNet ({max_eval_samples=}): {metrics=}')

    # -- Print config to show in log what this run was especially data set
    print(f'{wandb.config=}')
    print('Done!\a')

def main():  
    """Since accelerate config wants this, main_training_function: main"""
    train()

if __name__ == '__main__':
    print(f'\n\n\n------------------- Running {__file__} -------------------')
    # -- Run tests and time it
    import time
    time_start = time.time()
    # -- Run tests
    main()
    # -- End tests, report how long it took in seconds, minutes, hours, days
    print(f'Time it took to run {__file__}: {time.time() - time_start} seconds, {(time.time() - time_start)/60} minutes, {(time.time() - time_start)/60/60} hours, {(time.time() - time_start)/60/60/24} days\a')