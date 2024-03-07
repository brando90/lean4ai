from transformers import GPT2Tokenizer
from datasets import load_dataset

# Load the tokenizer for GPT-2
tokenizer = GPT2Tokenizer.from_pretrained("gpt2")

# Load the validation set from the "hoskinson-center/proofnet" dataset
dataset = load_dataset("AI4M/prompted_informal_v1", split="train")
# dataset = load_dataset('json', data_files="lean_train.jsonl", split='train')

# Function to tokenize a batch of texts and return their lengths
def tokenize_and_compute_length(batch, column_name):
    tokens = tokenizer(batch[column_name], add_special_tokens=True)
    return {"num_tokens": [len(token_ids) for token_ids in tokens["input_ids"]]}

# Apply the function to the "nl_statement" column
nl_statement_lengths = dataset.map(lambda x: tokenize_and_compute_length(x, "informal"), batched=True)
# Apply the function to the "formal_statement" column
formal_statement_lengths = dataset.map(lambda x: tokenize_and_compute_length(x, "formal"), batched=True)

# Print the total number of tokens for each column
total_nl_tokens = sum(nl_statement_lengths["num_tokens"])
total_formal_tokens = sum(formal_statement_lengths["num_tokens"])
print(f"Total number of tokens in 'nl_statement': {total_nl_tokens}")
print(f"Total number of tokens in 'formal_statement': {total_formal_tokens}")
print(f"Total number of tokens: {total_nl_tokens+total_formal_tokens}")