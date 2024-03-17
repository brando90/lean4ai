import os
import json
from datasets import load_dataset, Dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments, Trainer, pipeline
import torch
from torch.quantization import quantize_dynamic

# Disable Weights & Biases
os.environ["WANDB_DISABLED"] = "true"

# Function to load a custom dataset from a directory
def load_hendricks_math_dataset(directory):
    problems = []
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r') as file:
            data = json.load(file)
            problems.append({'problem': data['problem'], 'solution': data['solution']})
    return problems

# Function to load another custom dataset from a file
def load_our_dataset(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        dataset = [{'formal': entry['formal'], 'informal': entry['informal']} for entry in data]
    return dataset 

# Load and prepare datasets
train_dataset_directory = 'cleanclaudedataset.json'
test_dataset_directory = 'MATH/test/counting_and_probability'

train_data = load_our_dataset(train_dataset_directory)
test_data = load_hendricks_math_dataset(test_dataset_directory)

# Convert datasets to HuggingFace's `Dataset`
train_dataset = Dataset.from_dict({'text': [item['formal'] + '\n' + item['informal'] for item in train_data]})
test_dataset = Dataset.from_dict({'text': [item['problem'] for item in test_data]})

# Load tokenizer and model
base_model = "mistralai/Mistral-7B-v0.1"
tokenizer = AutoTokenizer.from_pretrained(base_model)
model = AutoModelForCausalLM.from_pretrained(base_model)

# Update tokenizer configuration
tokenizer.pad_token = tokenizer.eos_token

# Function to tokenize datasets
def tokenize_function(examples):
    model_inputs = tokenizer(examples["text"], padding="max_length", truncation=True, max_length=512)
    model_inputs["labels"] = model_inputs["input_ids"].copy()
    return model_inputs

# Tokenize datasets
tokenized_train_dataset = train_dataset.map(tokenize_function, batched=True)
tokenized_test_dataset = test_dataset.map(tokenize_function, batched=True)

# Training arguments
training_args = TrainingArguments(
    output_dir='./results',
    num_train_epochs=15,  # Adjust as needed
    per_device_train_batch_size=1,  # Reduced batch size
    per_device_eval_batch_size=1,  # Reduced batch size
    logging_dir='./logs',
    evaluation_strategy="epoch",
    logging_strategy="steps",
    logging_steps=50,
    fp16=True,  # Enable FP16 training
    gradient_accumulation_steps=2,  # Adjust as needed to simulate larger batch sizes
)


# Initialize and start training
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train_dataset,
    eval_dataset=tokenized_test_dataset,
)

trainer.train()
evaluation_results = trainer.evaluate()
print(evaluation_results)

# Apply dynamic quantization to the model
model = quantize_dynamic(model, {torch.nn.Linear}, dtype=torch.qint8)

# Setup the generation pipeline with the quantized model
gen_pipeline = pipeline('text-generation', model=model, tokenizer=tokenizer, device=0 if torch.cuda.is_available() else -1)

# Generate answers for a few examples
for example in test_data[:5]:
    question = example['problem']
    generated_answers = gen_pipeline(question, max_length=100, num_return_sequences=1)
    generated_answer = generated_answers[0]['generated_text']
    print(f"Question (Formal): {question}\nGenerated Answer: {generated_answer}\n")
