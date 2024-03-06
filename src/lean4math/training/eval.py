from transformers import GPT2Tokenizer, GPT2LMHeadModel, TrainingArguments, Trainer, AutoModelForCausalLM, AutoTokenizer
from datasets import load_dataset
import os

HF_TOKEN = os.environ.get('HUGGINGFACE_TOKEN')
print(HF_TOKEN)

# Load tokenizer and model
model_name = "google/gemma-2b"
tokenizer_name = "google/gemma-2b"
if tokenizer_name == "gpt2":
    tokenizer = GPT2Tokenizer.from_pretrained(tokenizer_name)
    model = GPT2LMHeadModel.from_pretrained(model_name)
elif tokenizer_name == "meta-llama/Llama-2-7b" or tokenizer_name == "mistralai/Mistral-7b-v0.1" or tokenizer_name == "google/gemma-7b" or tokenizer_name == "google/gemma-2b":
    model = AutoModelForCausalLM.from_pretrained(model_name, token=HF_TOKEN)
    tokenizer = AutoTokenizer.from_pretrained(tokenizer_name, token=HF_TOKEN)
    tokenizer.pad_token = tokenizer.eos_token if tokenizer.pad_token_id is None else tokenizer.pad_token

# dataset_path = "AI4M/mma-dataset"
dataset_path = "hoskinson-center/proofnet"

# Load your datasets from Hugging Face
# dataset_train = load_dataset(dataset_path, split='train')
dataset_val = load_dataset(dataset_path, split='validation')
dataset_test = load_dataset(dataset_path, split='test')

# Ensure that the tokenizer does not split on spaces within tokens
tokenizer.add_special_tokens({'pad_token': '[PAD]'})
model.resize_token_embeddings(len(tokenizer))

# Preprocessing function to prepare inputs and labels
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

# Apply the preprocessing function
# train_dataset = dataset_train.map(preprocess_function, batched=True, remove_columns=["input", "output"])
val_dataset = dataset_val.map(preprocess_function, batched=True, remove_columns=["nl_statement", "formal_statement"])
test_dataset = dataset_test.map(preprocess_function, batched=True, remove_columns=["nl_statement", "formal_statement"])

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

# Initialize our Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=val_dataset,
    eval_dataset=val_dataset,
    tokenizer=tokenizer
)

results = trainer.evaluate(test_dataset)
print(results)