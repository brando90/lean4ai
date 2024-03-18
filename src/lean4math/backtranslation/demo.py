"""

Script for demo-ing pre-trained and saved HF models
Author: Jakob Nordhagen

Usage: python demo.py --name <name of run>

"""
import argparse
from transformers import GPT2LMHeadModel, GPT2Tokenizer
from datasets import load_dataset
import random

def main():
    # Get model name from args
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", type=str) 
    args = parser.parse_args()
    name = args.name
    model_path = f"saved_models/{name}"

    # Load saved model and tokenizer
    model = GPT2LMHeadModel.from_pretrained(model_path)
    tokenizer = GPT2Tokenizer.from_pretrained('gpt2')

    tokenizer.add_special_tokens({'pad_token': '[PAD]'})
    model.resize_token_embeddings(len(tokenizer))
    model.eval()
    
    # Load dataset
    dataset = load_dataset('hoskinson-center/proofnet', split='test')

    while True: 
        text = input("\nEnter a theorem statement:\n").strip()

        text += "<SEP>"

        tokens = tokenizer(text, return_tensors="pt").to(device)

        output = model.generate(input_ids=tokens["input_ids"], attention_mask=tokens["attention_mask"], do_sample=False, max_new_tokens=150)

        decoded_texts = tokenizer.batch_decode(output, skip_special_tokens=False)[0]

        decoded_texts = decoded_texts[len(text)+2:]

        decoded_texts = decoded_texts.replace("<|endoftext|>", "")

        print("\n\n" + decoded_texts)


if __name__ == '__main__':
    main()