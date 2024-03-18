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
    model = GPT2LMHeadModel.from_pretrained(model_path, pad_token_id=50256)
    tokenizer = GPT2Tokenizer.from_pretrained('gpt2')

    tokenizer.add_special_tokens({'pad_token': '[PAD]'})
    model.resize_token_embeddings(len(tokenizer))
    model.eval()
    
    # Load dataset
    dataset = load_dataset('hoskinson-center/proofnet', split='test')

    device = "cuda:0"
    model.to(device)

    while True: 
        input_text = input("\nEnter a theorem statement:\n").strip()
        # input_text += tokenizer.eos_token
        input_ids = tokenizer.encode(input_text, return_tensors="pt", padding=True, truncation=True).to(model.device)
        output = model.generate(input_ids, max_length=512, attention_mask=input_ids.ne(0))
        translated_text = tokenizer.decode(output[0], skip_special_tokens=True)

        print("\n\n" + translated_text)


if __name__ == '__main__':
    main()