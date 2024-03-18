import argparse
import os
import yaml
import ndjson 
from pathlib import Path
from tqdm import tqdm 

from dataset import NlFormalDataset, data_collator

import torch 
import torch.nn
from torch.optim import AdamW 

import transformers 
from transformers import AutoModelForCausalLM, AutoTokenizer
from transformers import TrainingArguments, Trainer
from transformers import get_cosine_schedule_with_warmup
from transformers.trainer_pt_utils import get_parameter_names 

def main(): 

    experiment_name = ''
    train_path = '../data/proofnet_train.jsonl'
    eval_path = ''
    lr = 1e-4
    warmup_steps = 
    weight_decay = 0.1
    gradient_clipping = 
    train_steps = 1024
    logging_steps = 
    save_steps = 
    eval_steps = 
    batch_size = 2
    model_name = 'gpt2'
    max_length = 1024
    accum_steps = 

    save_dir = os.path.join("runs/", experiment_name)

    Path(save_dir).mkdir(exist_ok=True, parents=True)

    with open(train_path) as f: 
        train_data = ndjson.load(f)

    with open(eval_path) as f:
        eval_data = ndjson.load(f)

    # Tokenizers and data 
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    if not tokenizer.eos_token:
        tokenizer.add_special_tokens({"eos_token": "<|endoftext|>"})
    tokenizer.pad_token=tokenizer.eos_token

    train_set = NlFormalDataset(train_data, tokenizer, max_length)
    eval_set = NlFormalDataset(eval_data, tokenizer, max_length)

    # Models 
    model = AutoModelForCausalLM.from_pretrained(model_name)
    model.resize_token_embeddings(len(tokenizer))

    # Initialize optimizer and scheduler
    decay_parameters = get_parameter_names(model, [torch.nn.LayerNorm])
    decay_parameters = [name for name in decay_parameters if "bias" not in name]
    optimizer_grouped_parameters = [
        {
            "params": [p for n, p in model.named_parameters() if n in decay_parameters],
            "weight_decay": weight_decay,
        },
        {
            "params": [p for n, p in model.named_parameters() if n not in decay_parameters],
            "weight_decay": 0.0,
        },
    ]


    optimizer = AdamW(optimizer_grouped_parameters, 
            lr=lr)

    scheduler = get_cosine_schedule_with_warmup(
            optimizer, 
            num_warmup_steps=warmup_steps,
            num_training_steps=train_steps)

    training_args = TrainingArguments(
            output_dir = save_dir,
            max_steps = train_steps,
            per_device_train_batch_size = batch_size,
            logging_strategy= "steps", 
            logging_steps = logging_steps, 
            save_strategy = "steps",
            save_steps = save_steps,
            evaluation_strategy = "steps",
            eval_steps = eval_steps,
            max_grad_norm=gradient_clipping, 
            gradient_accumulation_steps = accum_steps,
            fp16=True, 
            )


    with open(os.path.join(save_dir, "config.yaml"), "w") as f: 
        yaml.dump(cfg, f)

    Trainer(model=model, args=training_args, 
            train_dataset=train_set, eval_dataset=eval_set,
            data_collator=data_collator, 
            optimizers=(optimizer, scheduler),).train()

if __name__=="__main__": 
    main()