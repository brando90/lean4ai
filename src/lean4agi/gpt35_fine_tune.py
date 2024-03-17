from openai import OpenAI
import json
import os

client = OpenAI(
    api_key='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'
)

def transform_and_upload_dataset(jsonl_file_path, purpose='fine-tune'):
    transformed_file_path = 'transformed_dataset.jsonl'

    with open(jsonl_file_path, 'r', encoding='utf-8') as infile, open(transformed_file_path, 'w', encoding='utf-8') as outfile:
        count = 0
        for line in infile:
            data = json.loads(line.strip())
            if 'formal' in data and 'informal' in data:  # Ensure the expected keys exist
                transformed_data = {"prompt": data['formal'], "completion": data['informal']}
                outfile.write(json.dumps(transformed_data) + '\n')
                count += 1

        print(f"Transformed and saved {count} entries to {transformed_file_path}")
        
        if count == 0:
            raise ValueError("No data was transformed. Please check the format of your source dataset.")

    with open(transformed_file_path, 'rb') as file:
        if os.stat(transformed_file_path).st_size == 0:
            raise ValueError("The transformed file is empty. Check the transformation logic.")
        
        response = client.files.create(
            file=file,
            purpose=purpose
        )
        print(response)
        return response['id']

train_dataset_path = '/lfs/hyperturing1/0/smion/evals-for-autoformalization/claudeclean.jsonl'

train_file_id = transform_and_upload_dataset(train_dataset_path)

fine_tune_response = client.fine_tuning.create(
    training_file=train_file_id,
    model="gpt-3.5-turbo-1106",
    n_epochs=4,
    batch_size=4,
    learning_rate_multiplier=0.1,
    prompt_loss_weight=0.1
)

print(f"Fine-tuning job started with ID: {fine_tune_response['id']}")
