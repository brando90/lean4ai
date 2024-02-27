import os
import json
from datasets import load_dataset, Dataset
from transformers import GPT2Tokenizer, GPT2LMHeadModel, Trainer, TrainingArguments, pipeline
import torch

# Ensure that wandb is not automatically initialized
os.environ["WANDB_DISABLED"] = "true"

# Function to load the Hendricks math dataset, now keeping problems and solutions separate
def load_hendricks_math_dataset(directory):
    problems = []
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r') as file:
            data = json.load(file)
            problems.append({'problem': data['problem'], 'solution': data['solution']})
    return problems

# Load and prepare datasets
train_dataset_directory = 'MATH/train/counting_and_probability'
test_dataset_directory = 'MATH/test/counting_and_probability'

train_problems_data = load_hendricks_math_dataset(train_dataset_directory)
test_problems_data = load_hendricks_math_dataset(test_dataset_directory)

train_dataset = Dataset.from_dict({'text': [item['problem'] + '\n' + item['solution'] for item in train_problems_data]})
test_dataset = Dataset.from_dict({'text': [item['problem'] for item in test_problems_data]})

# Tokenization and model preparation
tokenizer = GPT2Tokenizer.from_pretrained('gpt2')
tokenizer.pad_token = tokenizer.eos_token

def tokenize_function(examples):
    # Tokenize the texts and prepare labels for language modeling
    model_inputs = tokenizer(examples["text"], padding="max_length", truncation=True, max_length=512)
    model_inputs["labels"] = model_inputs["input_ids"].copy()
    return model_inputs

tokenized_train_dataset = train_dataset.map(tokenize_function, batched=True)
tokenized_test_dataset = test_dataset.map(tokenize_function, batched=True)

model = GPT2LMHeadModel.from_pretrained('gpt2')

training_args = TrainingArguments(
    output_dir='./results',
    num_train_epochs=1,
    per_device_train_batch_size=2,
    per_device_eval_batch_size=2,
    logging_dir='./logs',
    evaluation_strategy="epoch",
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train_dataset,
    eval_dataset=tokenized_test_dataset,
)

# Training and evaluation
trainer.train()
evaluation_results = trainer.evaluate()
print(evaluation_results)

# Generating answers for test dataset
gen_pipeline = pipeline('text-generation', model=model, tokenizer=tokenizer, device=0 if torch.cuda.is_available() else -1)

for example in test_problems_data[:5]:  # Limiting to first 5 for brevity
    question = example['problem']
    generated_answers = gen_pipeline(question, max_length=100, num_return_sequences=1)
    generated_answer = generated_answers[0]['generated_text']
    print(f"Question: {question}\nGenerated Answer: {generated_answer}\n")

