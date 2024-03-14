import json

# Define the path to the original and new JSON files
original_file_path = 'claude_working_updated_dataset_train.json'
new_file_path = 'cleanclaudedataset.json'

# Read the original JSON file
with open(original_file_path, 'r', encoding='utf-8') as file:
    data = json.load(file)

# Function to recursively remove unwanted substrings from all string values
def remove_unwanted_strings(value):
    if isinstance(value, dict):
        return {k: remove_unwanted_strings(v) for k, v in value.items()}
    elif isinstance(value, list):
        return [remove_unwanted_strings(v) for v in value]
    elif isinstance(value, str):
        return value.replace("\\(", "").replace("\\)", "").replace("\\", "").replace("\n", "")
    else:
        return value

# Apply the function to the entire JSON data
modified_data = remove_unwanted_strings(data)

# Write the modified JSON data to a new file
with open(new_file_path, 'w', encoding='utf-8') as file:
    json.dump(modified_data, file, ensure_ascii=False, indent=4)

print(f"Modified JSON file saved as '{new_file_path}'.")
