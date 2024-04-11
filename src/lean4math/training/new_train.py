from transformers import GPT2Tokenizer, GPT2LMHeadModel, TrainingArguments, Trainer
from datasets import load_dataset, load_metric
from datasets import load_dataset
# import evaluate
import os
import numpy as np
import torch

torch.cuda.empty_cache()

def compute_metrics(eval_pred, 
                    path: str = 'accuracy',  # todo: what t
                    ):
    metric = load_metric(path=path) 
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    print(predictions.shape, labels.shape)
    return metric.compute(predictions=predictions, references=labels)

# Load tokenizer and model
HF_TOKEN = os.environ.get('HUGGINGFACE_TOKEN')

# Load tokenizer and model
model_name = "gpt2"
tokenizer_name = "gpt2"
if tokenizer_name == "gpt2":
    tokenizer = GPT2Tokenizer.from_pretrained(tokenizer_name)
    model = GPT2LMHeadModel.from_pretrained(model_name)
    tokenizer.add_special_tokens({'pad_token': '[PAD]'})
    model.resize_token_embeddings(len(tokenizer))
elif tokenizer_name == "meta-llama/Llama-2-7b" or tokenizer_name == "mistralai/Mistral-7b-v0.1" or tokenizer_name == "google/gemma-7b" or tokenizer_name == "google/gemma-2b":
    model = AutoModelForCausalLM.from_pretrained(model_name, token=HF_TOKEN)
    tokenizer = AutoTokenizer.from_pretrained(tokenizer_name, token=HF_TOKEN)
    tokenizer.pad_token = tokenizer.eos_token if tokenizer.pad_token_id is None else tokenizer.pad_token


# train_dataset_path = "AI4M/prompted_informal_v1"
val_dataset_path = "hoskinson-center/proofnet"
test_dataset_path = "hoskinson-center/proofnet"

# Load your datasets from Hugging Face
# dataset_train = load_dataset(train_dataset_path, split='train')
dataset_val = load_dataset(val_dataset_path, split='validation')
dataset_test = load_dataset(test_dataset_path, split='test')

# Preprocessing function to prepare inputs and labels
def preprocess_function_proofnet(examples):
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

def preprocess_function_custom(examples):
    # Combine the "informal" and "formal" fields into a single input
    # Format: "<informal> <sep> <formal>", where <sep> is a special token like <|endoftext|>
    inputs = [examples["informal"][i] + tokenizer.eos_token + examples["formal"][i] for i in range(len(examples["informal"]))]
    model_inputs = tokenizer(inputs, max_length=512, padding="max_length", truncation=True, return_tensors="pt")
    
    # Labels are the input_ids with -100 assigned to tokens we don't want to include in the loss
    # Here, we want to exclude the input part from the loss so it's only calculated on the "formal" part
    labels = model_inputs.input_ids.clone()
    labels[labels == tokenizer.pad_token_id] = -100  # Don't compute loss on padding tokens
    model_inputs["labels"] = labels
    return model_inputs

custom_columns = ["informal", "formal"]
proofnet_columns = ["nl_statement", "formal_statement"]

# Apply the preprocessing function
# train_dataset = dataset_train.map(preprocess_function_custom, batched=True, remove_columns=custom_columns)
val_dataset = dataset_val.map(preprocess_function_proofnet, batched=True, remove_columns=proofnet_columns)
test_dataset = dataset_test.map(preprocess_function_proofnet, batched=True, remove_columns=proofnet_columns)

# Training arguments
training_args = TrainingArguments(
    output_dir="./proofnet_validation",          # Output directory for model predictions and checkpoints
    evaluation_strategy="epoch",     # Evaluate each `logging_steps`
    learning_rate=5e-5,              # Learning rate
    per_device_train_batch_size=4,   # Batch size per device during training
    per_device_eval_batch_size=4,    # Batch size for evaluation
    weight_decay=0.01,               # Strength of weight decay
    save_total_limit=3,              # Limit the total amount of checkpoints
    num_train_epochs=3,              # Total number of training epochs
)

# Initialize our Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=val_dataset,
    eval_dataset=test_dataset,
    tokenizer=tokenizer,
    compute_metrics=compute_metrics
)

#Get loss before model is trained for baseline
results = trainer.evaluate(test_dataset)
print(results)
# Fine-tune the model
trainer.train()

# Optionally, evaluate the model on the test set
results = trainer.evaluate(test_dataset)
print(results)
model.save_pretrained("./proofnet_validation")