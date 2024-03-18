from datasets import Dataset, load_dataset
import random

dataset_path = "data/corpus.jsonl"

def extract_theorem(example):
    return {'code': [premise['code'] for premise in example['premises']]}
    
dataset = load_dataset('json', data_files={'train': dataset_path}, split='train')
# unpacked_examples = [{'code': code} for example in dataset for code in example['code']]
# unpacked_dataset = Dataset.from_dict({'code': [example['code'] for example in unpacked_examples]})

print(f'{dataset.shape=}')
print(f'{dataset.column_names}')

larger_dataset = [thm['code'] for lst in dataset['premises'] for thm in lst]
print(len(larger_dataset))

dataset = [thm['code'] for lst in dataset['premises'] for thm in lst if thm['code'].startswith('theorem')]
print(len(dataset))

dataset = Dataset.from_dict({'formal': dataset})

print(f'{dataset.shape=}')
print(f'{dataset.column_names}')

print(dataset['formal'][7])